# Synthetic markets for the study: the INFORMS calibration and runner on JumpHMM.jl's SectorFactorModel.
# The toy universe is synthetic_md (helpers.jl): 2014–2019 weekdays, 4 sectors × 12 names.
import JumpHMM

# A small generator on the toy market: untuned JumpHMM models (N = 10), fixed β, no pull.
function toy_sector_generator(md)
    prices = hcat(md.spy_close, md.close)
    gen, _ = JumpHMM.fit(JumpHMM.SectorFactorModel, ["SPY"; md.tickers], prices, "SPY", md.sector;
        N = 10, center_steps = 20_000)
    return gen
end

@testset "synthetic markets" begin
    md = synthetic_md(; ρ = 0.3)
    gen = toy_sector_generator(md)
    n = length(md.dates) - 1

    # market data from growth: the real calendar, the real first closes, compounding at Δt = 1/252
    g_m = fill(0.1, n)
    G = fill(0.2, n, length(md.tickers))
    m1 = market_data_from_growth(md, g_m, G)
    @test m1.dates == md.dates && m1.tickers == md.tickers && m1.sector == md.sector && m1.g_f == md.g_f
    @test m1.close[end, 1] ≈ md.close[1, 1] * exp(0.2 * n / 252) && m1.spy_close[end] ≈ md.spy_close[1] * exp(0.1 * n / 252)
    @test m1.open == m1.close && all(m1.volume[:, 3] .== median(md.volume[:, 3]))
    G[5, 2] = Inf
    err = try market_data_from_growth(md, g_m, G); nothing catch e; e end
    @test err isa NonFiniteCloseError && occursin(md.tickers[2], err.msg)
    @test_throws ArgumentError market_data_from_growth(md, g_m[1:end-1], G)   # a shape error is not a non-finite close

    # one synthetic path: reproducible, on the real calendar, SPY from the generator's market draw
    a = synthetic_market_data(gen, md, 3)
    b = synthetic_market_data(gen, md, 3)
    @test a.close == b.close && a.dates == md.dates && all(a.close .> 0)
    @test a.spy_close ≈ md.spy_close[1] .* exp.(vcat(0.0, cumsum(JumpHMM.sample_draws(gen, n; seed = 3).g_m ./ 252)))

    # market path statistics use the same market draw
    window = (Date(2019, 1, 2), Date(2019, 12, 31))
    train = (Date(2014, 1, 2), Date(2018, 12, 31))
    st = market_path_stats(gen, md, [3, 4, 5]; window = window, train = train)
    i0, i1 = findfirst(==(window[1]), md.dates), findfirst(==(window[2]), md.dates)
    @test st.path_id == [3, 4, 5]
    @test st.window_growth[1] ≈ log(a.spy_close[i1] / a.spy_close[i0]) / ((i1 - i0) / 252)
    @test all(0 .<= st.window_max_drawdown .< 1)

    # path sets: the deepest drawdowns in each stress pool, a seeded typical set
    stats = DataFrame(path_id = 1:10, window_max_drawdown = collect(0.01:0.01:0.10),
        window_growth = zeros(10), train_growth = zeros(10), has_burst = [isodd(i) for i in 1:10])
    ps = path_sets(stats; n_burst = 2, n_bear = 2, n_typical = 4, seed = 1)
    @test ps.path_id[ps.burst_stress] == [7, 9] && ps.path_id[ps.bear_stress] == [8, 10]
    @test count(ps.typical) == 4 && isequal(ps, path_sets(stats; n_burst = 2, n_bear = 2, n_typical = 4, seed = 1))
    @test_throws ArgumentError path_sets(stats; n_burst = 6, n_bear = 2, n_typical = 4)

    # drift targets and fits on the toy market (its own training window and halves)
    calib = calibrate(md; train_start = train[1], train_stop = train[2])
    halves = ((Date(2014, 1, 2), Date(2018, 12, 31)), (Date(2014, 1, 2), Date(2016, 12, 30)),
        (Date(2017, 1, 2), Date(2018, 12, 31)))
    targets = real_drift_targets(md, calib; train = train, alpha_windows = halves)
    @test length(targets.sd_β) == 48 && length(targets.α_full) == 48 && isfinite(targets.acf252)
    bank = [JumpHMM.sample_draws(gen, n; seed = p) for p in 1:2]
    fb = fit_beta_drift(gen, bank, targets, md.dates; h_grid = [63.0, 252.0], train = train)
    @test fb.h_β in (63.0, 252.0) && length(fb.k_β) == 48 && all(fb.k_β .>= 0) && nrow(fb.table) == 2
    fa = fit_alpha_pull(gen, bank, targets, md.dates; φ_grid = 0.0:0.25:1.5, alpha_windows = halves)
    @test fa.φ in 0.0:0.25:1.5 && isfinite(fa.loss)

    # one synthetic path through the study: calibrate on the path, run two books, score them
    s = with_settings(load_study(default_study_path()).settings; start = window[1], stop = window[2],
        train_start = train[1], train_stop = train[2], hedge = false, N_per_sector = 2)
    runs = [build(MyStudyRun, (settings = s, allocator = "CD", screen = :gamma, seed = 5660)),
        build(MyStudyRun, (settings = s, allocator = "CD", screen = :random, seed = 5660))]
    out = run_synthetic_path(a, runs)
    @test nrow(out) == 2 && all(out.status .== "ok") && all(isfinite, out.wealth_ratio)
    @test all(isfinite, out.growth) && all(out.spy_growth .== out.spy_growth[1])
    @test out.screen == [:gamma, :random]

    # a market whose calibration fails gives one error row per run, not a crash
    bad = with_settings(s; train_start = Date(2018, 12, 31))   # a one-day training window: calibrate throws
    bad_runs = [build(MyStudyRun, (settings = bad, allocator = "CD", screen = :gamma, seed = 5660)),
        build(MyStudyRun, (settings = bad, allocator = "CD", screen = :random, seed = 5660))]
    failed = run_synthetic_path(a, bad_runs)
    @test nrow(failed) == 2 && all(failed.status .== "error") && all(occursin.("calibration", failed.error))

    # the whole generator fit, at toy scale (untuned models, two bank paths, two half-lives)
    gen2, summary = fit_generator(md, calib; market_model = gen.market_model, train = train, alpha_windows = halves,
        bank_seeds = 1:2, tune = false, N = 10, center_steps = 20_000, h_grid = [63.0, 252.0])
    @test gen2 isa JumpHMM.SectorFactorModel && gen2.tickers == md.tickers && gen2.β_halflife in (63.0, 252.0)
    @test gen2.market_model === gen.market_model && all(gen2.β_scale .>= 0)
    @test haskey(summary, "beta") && haskey(summary, "alpha") && haskey(summary, "model_sd_ratio")
    ā = mean(summary["alpha"]["alpha_full"])
    @test gen2.α ≈ ā .+ summary["alpha"]["phi"] .* (summary["alpha"]["alpha_full"] .- ā)
end
