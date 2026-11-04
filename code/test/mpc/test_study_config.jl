using Test, Dates
include("helpers.jl")
const REPO = normpath(joinpath(@__DIR__, "..", ".."))
same(a, b) = all(isequal(getfield(a, f), getfield(b, f)) for f in fieldnames(MyStudySettings))
@testset "settings and config file" begin
    s = MyStudySettings()
    @test (s.xi_short, s.xi_long, s.gtilde_window, s.N_per_sector, s.w_max, s.ces_eta, s.pool_H) == (21, 63, 252, 3, 0.10, 0.5, 5)
    @test isnan(s.lambda) && isnan(s.vol_cap_annual) && s.hedge && s.repick_on_band_exit
    cfg = load_study(default_study_path())
    @test same(cfg.settings, s)                                        # the file holds the spec defaults
    @test cfg.grid.n_seeds == 30 && cfg.grid.base_seed == 5660
    @test cfg.grid.allocators == ["CD", "CES", "CESw", "SG", "MinVar", "Tangent", "LS"]
    @test cfg.grid.screens == [:bandit, :gamma, :random] && cfg.grid.hedge == [true, false]
    bad = joinpath(mktempdir(), "bad.toml"); write(bad, "[market]\nxi_shrot = 21\n")
    @test_throws ArgumentError load_study(bad)
    @test_throws ArgumentError build(MyStudySettings, (beta_min=-0.1,))
    @test_throws ArgumentError build(MyStudySettings, (N_per_sector=0,))
    @test with_settings(s; hedge=false).hedge == false && s.hedge
end
@testset "study context" begin
    md = synthetic_md(ρ=0.3)
    fit = fit_base_sim(md, md.dates[1], md.dates[800])
    c = build(MyCalibration, (base_sim=fit.params, σ_m=fit.σ_m, m_m=fit.m_m, v_m=fit.v_m, λ=0.5,
        train_start=md.dates[1], train_stop=md.dates[800]))
    s = build(MyStudySettings, (train_start=md.dates[1], train_stop=md.dates[800], start=md.dates[801], stop=md.dates[900]))
    ctx = build_context(md, c, s)
    @test ctx.rows == 801:900 && ctx.G == xi_gain(md.spy_close[1:800]; short=21, long=63, q=0.99)
    @test ctx.γ[10, :] == gamma_weights(ctx.sim.α[10, :], ctx.sim.β[10, :], ctx.g̃[810], ctx.ξ[810]; β_floor=0.1)
    @test ctx.pool[10] == hedge_pool(ctx.sim.β[10, :], down_day_beta(md, 810; lookback=252); H=5)
    q = build_context(perturb_after(md, md.dates[850]), c, s)          # canary
    @test q.ξ[1:850] == ctx.ξ[1:850] && isequal(q.g̃[1:850], ctx.g̃[1:850])
    @test q.γ[1:50, :] == ctx.γ[1:50, :] && q.pool[1:50] == ctx.pool[1:50]
    @test_throws ArgumentError build_context(md, c, with_settings(s; start=md.dates[200], train_stop=md.dates[150]))
    # the calibration must come from the settings' training window
    @test_throws ArgumentError build_context(md, c, with_settings(s; train_stop=md.dates[799]))
    @test_throws ArgumentError build_context(md, c, with_settings(s; train_start=md.dates[2]))
end

@testset "addendum settings and grid" begin
    s = MyStudySettings()
    @test (s.basket_K, s.liquidity_shortlist, s.liquidity_window, s.corr_max, s.corr_window, s.w_max_scale) == (13, 100, 63, 0.7, 252, 1.5)
    @test s.fixed_tickers == ["AAPL", "MSFT", "INTC", "MU", "AMD", "NVDA", "GS", "BAC", "WFC", "C", "F", "GM", "JNJ"]
    cfg = load_study(default_study_path())
    @test same(cfg.settings, s)
    @test cfg.grid.K == [5, 8, 13, 21, 34] && length(cfg.grid.universe_screens) == 5
    @test first.(cfg.grid.fixed_lists) == ["l8b_13", "l8b_15"] && last(cfg.grid.fixed_lists[2])[14:15] == ["WMT", "PG"]
    @test cfg.grid.eta == [0.1, 0.25, 0.5, 2.0, 4.0, 10.0] && cfg.grid.eta_ces_drop == [0.1]
    @test cfg.grid.eta_limits == [0.05, 0.1, 0.25, 0.5, 2.0, 4.0, 10.0, 20.0] && cfg.grid.limits_list == "l8b_13"
    src = read(default_study_path(), String)
    for (from, to) in ("limits_list = \"l8b_13\"" => "limits_list = \"nope\"", "eta = [0.1," => "eta = [-0.1,",
        "eta_ces_drop = [0.1]" => "eta_ces_drop = [0.3]")
        p = joinpath(mktempdir(), "s.toml"); write(p, replace(src, from => to))
        @test_throws ArgumentError load_study(p)
    end
    @test_throws ArgumentError build(MyStudySettings, (corr_max=1.5,))
    @test_throws ArgumentError build(MyStudySettings, (fixed_tickers=String[],))
end
