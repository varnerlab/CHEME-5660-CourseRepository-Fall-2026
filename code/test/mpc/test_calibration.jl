using Test, Dates, Statistics
include("helpers.jl")
@testset "calibration" begin
    md = synthetic_md(ρ=0.3)
    a, b = md.dates[1], md.dates[1000]
    c = calibrate(md; train_start=a, train_stop=b, n_portfolios=50)
    fit = fit_base_sim(md, a, b)
    @test all(c.base_sim[t].β == fit.params[t].β && c.base_sim[t].α == fit.params[t].α for t in md.tickers)
    @test (c.σ_m, c.m_m, c.v_m) == (fit.σ_m, fit.m_m, fit.v_m)
    @test c.λ == choose_shrinkage(md, a, b; n_portfolios=50, seed=5660)
    # λ is fitted with the study's residual window
    @test calibrate(md; train_start=a, train_stop=b, n_portfolios=50, window=63).λ ==
        choose_shrinkage(md, a, b; n_portfolios=50, seed=5660, window=63)
    @test (c.train_start, c.train_stop) == (a, b)
    path = joinpath(mktempdir(), "cal.jld2"); save_calibration(path, c); d = load_calibration(path)
    @test d.λ == c.λ && d.σ_m == c.σ_m && d.base_sim[md.tickers[3]].β == c.base_sim[md.tickers[3]].β
    @test_throws ArgumentError build(MyCalibration, (σ_m=1.0,))
    st = (xi_short=21, xi_long=63, xi_quantile=0.99)
    sm = calibration_summary(md, c, st)
    @test sm["G"] == xi_gain(md.spy_close[1:1000]; short=21, long=63, q=0.99)
    @test sm["vol_cap_annual"] == c.σ_m * sqrt(1 / 252) && sm["lambda"] == c.λ
    @test sm["universe_size"] == length(md.tickers)
    @test sum(values(sm["sector_counts"])) == length(md.tickers)
    @test sm["sector_counts"] == Dict(x => count(==(x), md.sector) for x in unique(md.sector))
    @test sm["train_start"] == string(a) && sm["train_stop"] == string(b)
end
