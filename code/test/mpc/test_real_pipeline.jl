# The real-data pipeline on the course's S&P 500 files: the INFORMS universe, the DTB3 risk-free rate,
# the 2014–2024 calibration, and one study run on a sector-balanced subset (the full universe runs in L12b).
@testset "real-data pipeline" begin
    dir = joinpath(dirname(pathof(VLQuantitativeFinancePackage)), "data")
    md = load_market_data(dir; start = Date(2014, 1, 3), stop = Date(2026, 9, 4))

    # the INFORMS universe: names with a complete 2014–2026 history and a sector
    @test length(md.tickers) == 373
    @test all(isfinite, md.close) && all(md.close .> 0)

    # the risk-free rate comes from DTB3, not the 4% default
    @test isfile(joinpath(dir, "DTB3.csv"))
    @test all(md.g_f .!= 0.04) && all(-0.01 .< md.g_f .< 0.07)   # bill rates dipped below 0 in 2015 and 2020

    # calibrate on 2014–2024 and run one book on 2025-01-02 to 2026-09-04 with 30 names
    calib = calibrate(md; train_start = Date(2014, 1, 3), train_stop = Date(2024, 12, 31))
    small = subset_universe(md, select_universe(md, 30))
    s = with_settings(load_study(default_study_path()).settings; hedge = false)
    ctx = build_context(small, calib, s)
    res = run_study(ctx, build(MyStudyRun, (settings = s, allocator = "CD", screen = :gamma, seed = 5660)))
    @test length(res.equity) == length(res.dates) && all(isfinite, res.equity) && all(res.equity .> 0)
    @test res.dates[1] == Date(2025, 1, 2) && res.dates[end] == Date(2026, 9, 4)
    @test nrow(res.decisions) >= 1

    # parity with the INFORMS study: Cobb–Douglas, γ picker, hedge off, seed 5660 on the full universe ended at
    # 122169.64016343099 USD with 27 decisions (results/tier1_summary.csv, INFORMS repository 2fc998c)
    full = build_context(md, calib, s)
    ref = run_study(full, build(MyStudyRun, (settings = s, allocator = "CD", screen = :gamma, seed = 5660)))
    @test isapprox(ref.equity[end], 122169.64016343099; rtol = 1e-6)
    @test nrow(ref.decisions) == 27
end
