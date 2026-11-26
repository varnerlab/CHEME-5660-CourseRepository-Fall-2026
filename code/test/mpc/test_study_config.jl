using Test, Dates
include("helpers.jl")
const REPO = normpath(joinpath(@__DIR__, "..", ".."))
same(a, b) = all(isequal(getfield(a, f), getfield(b, f)) for f in fieldnames(MyStudySettings))
@testset "settings and config file" begin
    s = MyStudySettings()
    @test (s.xi_short, s.xi_long, s.gtilde_window, s.N_per_sector, s.w_max, s.ces_eta, s.pool_H) == (21, 63, 252, 3, 0.10, 0.5, 5)
    @test isnan(s.lambda) && isnan(s.vol_cap_annual) && s.hedge
    cfg = load_study(default_study_v1_path())
    @test same(cfg.settings, s)                                        # the v1 file holds the spec defaults
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

@testset "fixed fits and carried EWLS estimates" begin
    md = synthetic_md(ρ=0.3)
    train_start, train_stop = md.dates[[1, 800]]
    fit = fit_base_sim(md, train_start, train_stop)
    c = build(MyCalibration, (base_sim=fit.params, σ_m=fit.σ_m, m_m=fit.m_m, v_m=fit.v_m, λ=0.5,
        train_start=train_start, train_stop=train_stop))
    s = build(MyStudySettings, (train_start=train_start, train_stop=train_stop,
        start=md.dates[801], stop=md.dates[900]))
    updated = build_context(md, c, s)
    carried = build_context(md, c, with_settings(s; start=md.dates[851], estimates_start=md.dates[801]))
    fixed = build_context(md, c, with_settings(s; estimates="fixed"))

    @test carried.rows == 851:900
    for field in (:α, :β, :σ_ε, :σ_m)
        @test getproperty(carried.sim, field) == selectdim(getproperty(updated.sim, field), 1, 51:100)
    end
    @test carried.γ == updated.γ[51:end, :]
    @test carried.pool == updated.pool[51:end]
    for (j, ticker) in enumerate(md.tickers)
        params = c.base_sim[ticker]
        @test all(==(params.α), fixed.sim.α[:, j])
        @test all(==(params.β), fixed.sim.β[:, j])
        @test all(==(params.σ_ε), fixed.sim.σ_ε[:, j])
    end
    @test all(==(c.σ_m), fixed.sim.σ_m)
    @test context_key(fixed.settings) != context_key(updated.settings)
    @test_throws ArgumentError with_settings(s; estimates_start=train_stop)
end

@testset "addendum settings and grid" begin
    s = MyStudySettings()
    @test (s.basket_K, s.liquidity_shortlist, s.liquidity_window, s.corr_max, s.corr_window, s.w_max_scale) == (13, 100, 63, 0.7, 252, 1.5)
    @test s.fixed_tickers == ["AAPL", "MSFT", "INTC", "MU", "AMD", "NVDA", "GS", "BAC", "WFC", "C", "F", "GM", "JNJ"]
    cfg = load_study(default_study_v1_path())
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

# Method v2 (design 2026-11-13, plan Task 1): six new switches, each defaulting to the v1 behavior, and the
# β limit the allocators see.
@testset "v2 switches: defaults, config keys, validation" begin
    s = MyStudySettings()
    # every new field defaults to the v1 behavior
    @test s.forecast_model == "gbm"
    @test s.forecast_band == "sigma"
    @test s.market_turn == false
    @test s.beta_over_cap == Inf
    @test s.spy_short == false
    @test s.beta_min == 0.0

    # the loader reads each new key from its table (keys equal field names)
    text = read(default_study_v1_path(), String)
    text = replace(text, "forecast_model = \"gbm\"" => "forecast_model = \"factor\"")
    text = replace(text, "forecast_band = \"sigma\"" => "forecast_band = \"quantile\"")
    text = replace(text, "market_turn = false" => "market_turn = true")
    text = replace(text, "beta_over_cap = inf" => "beta_over_cap = 0.1")
    text = replace(text, "spy_short = false" => "spy_short = true")
    text = replace(text, "beta_min = 0.0" => "beta_min = -0.5")
    path = joinpath(mktempdir(), "v2.toml")
    write(path, text)
    v2 = load_study(path).settings
    @test v2.forecast_model == "factor"
    @test v2.forecast_band == "quantile"
    @test v2.market_turn == true
    @test v2.beta_over_cap == 0.1
    @test v2.spy_short == true
    @test v2.beta_min == -0.5

    # The two configurations share one grid.
    v1_file = load_study(default_study_v1_path())
    v2_file = load_study(default_study_path())
    @test same(v2_file.settings, v2)
    @test v2_file.grid == v1_file.grid

    # validation of the new fields
    @test_throws ArgumentError build(MyStudySettings, (forecast_model="garch",))
    @test_throws ArgumentError build(MyStudySettings, (forecast_band="wide",))
    @test_throws ArgumentError build(MyStudySettings, (beta_over_cap=-0.1,))
    @test_throws ArgumentError build(MyStudySettings, (beta_min=-0.5,))                  # a negative floor needs the SPY short
    @test_throws ArgumentError build(MyStudySettings, (beta_min=-1.5, spy_short=true))   # the floor is at least -1
    @test build(MyStudySettings, (beta_min=-0.5, spy_short=true)).beta_min == -0.5
end

@testset "v2: the beta limit the allocators see" begin
    s = build(MyStudySettings, (beta_min=-0.5, spy_short=true))
    # the allocators never see a negative limit: the SPY short covers the part below zero
    @test allocator_beta_max(s, 1.3) == 0.0
    @test allocator_beta_max(s, 0.4) ≈ 0.6
    @test allocator_beta_max(s, -0.5) ≈ 1.5
    # with the hedge off there is no limit
    @test allocator_beta_max(with_settings(s; hedge=false), 0.4) == Inf
    # with the v1 floor of 0 it equals the v1 cap
    v1 = MyStudySettings()
    @test allocator_beta_max(v1, 0.4) == beta_cap(0.4; β_ref=1.0, κ_β=1.0, β_min=0.0)
    @test allocator_beta_max(v1, 1.3) == 0.0
end
