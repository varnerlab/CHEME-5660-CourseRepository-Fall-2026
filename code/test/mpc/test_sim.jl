using Test, Dates, Random, Statistics
include("helpers.jl")

@testset "SIM / EWLS / market state" begin
    gm = randn(MersenneTwister(5660), 2000) .* 3; gi = 0.5 .+ 1.2 .* gm .+ randn(MersenneTwister(1), 2000)
    @test estimate_sim(gm, gi).β ≈ 1.2 atol=0.05
    s = ewls_init(0.1, 1.1, 2.0); @test (s.α, s.β, s.σ_ε) == (0.1, 1.1, 2.0)
    s = ewls_init(0.0, 0.0, 1.0; half_life=1e12, prior_weight=1e-12)
    foreach(t -> ewls_update!(s, gi[t], gm[t]), 1:2000)
    @test s.β ≈ estimate_sim(gm, gi).β rtol=1e-6
    v = ewvar_init(2.7); @test ewvar_update!(v, 0.0) < 2.7
    v = ewvar_init(1.0; half_life=1e12, prior_weight=1e-12); foreach(x -> ewvar_update!(v, x), gm)
    @test ewvar_update!(v, gm[end]) ≈ std(vcat(gm, gm[end]); corrected=false) rtol=1e-3
    @test preference_weights([0.2], [0.5], 1.0, 0.0) ≈ [tanh(0.2 + 0.5)]
    @test preference_weights([0.2], [0.5], 1.0, 1.0) ≈ [tanh(0.2/0.5 + 1.0)]
    dates = collect(Date(2025,1,1):Day(1):Date(2025,6,30)); spy = 100 .* exp.(cumsum(0.001 .+ 0.01 .* randn(MersenneTwister(2), length(dates))))
    d = Date(2025,5,1); spy2 = copy(spy); spy2[findfirst(==(d), dates)+1:end] .*= 2
    @test market_state(spy, dates, d) == market_state(spy2, dates, d)
    @test_throws ArgumentError market_state(spy, dates, Date(2024,1,1))
    @test_throws ArgumentError market_state(spy, dates, dates[1])
    i = findfirst(==(d), dates)
    @test market_state(spy, dates, d).g_m ≈ 252 * log(spy[i] / spy[i-1])

    @testset "fit_base_sim recovers betas" begin
        n = 300; dts = collect(Date(2024,1,1):Day(1):Date(2024,1,1)+Day(n-1))
        spy_c = 100 .* exp.(cumsum(0.01 .* randn(MersenneTwister(3), n)))
        gmm = diff(log.(spy_c))
        cl = hcat(50 .* exp.(cumsum(vcat(0.0, 1.5 .* gmm .+ 0.001 .* randn(MersenneTwister(4), n-1)))),
                  50 .* exp.(cumsum(vcat(0.0, 0.5 .* gmm .+ 0.001 .* randn(MersenneTwister(5), n-1)))))
        md = build(MyMarketData, (dates = dts, tickers = ["A","B"], open = cl, close = cl,
            volume = ones(n, 2), spy_open = spy_c, spy_close = spy_c, sector = ["X","X"], g_f = zeros(n)))
        fit = fit_base_sim(md, dts[11], dts[250])
        @test fit.params["A"].β ≈ 1.5 atol=0.02
        @test fit.params["B"].β ≈ 0.5 atol=0.02
        @test fit.σ_m ≈ std(growth_rates(spy_c[11:250]))
    end

    @testset "estimate_sim hand case" begin
        x = [0.0, 1.0, 2.0, 3.0, 4.0]; y = [1.0, 3.0, 2.0, 5.0, 4.0]
        e = estimate_sim(x, y)   # OLS: β = 0.8, α = 1.4
        @test e.β ≈ 0.8; @test e.α ≈ 1.4
        res = y .- (1.4 .+ 0.8 .* x); ssr = sum(abs2, res)
        @test ssr ≈ 3.6
        @test e.σ_ε ≈ sqrt(ssr / 3)
        @test e.r² ≈ 1 - ssr / sum(abs2, y .- mean(y))
    end

    @testset "market_state values (weekday dates)" begin
        wd = filter(x -> dayofweek(x) <= 5, collect(Date(2024,1,1):Day(1):Date(2025,12,31)))
        spy = 100 .+ 0.1 .* (1:length(wd)) .+ 3 .* sin.(0.3 .* (1:length(wd)))
        ema(p, n) = (a = 2/(n+1); e = p[1]; for k in 2:length(p); e = a*p[k] + (1-a)*e; end; e)
        d = Date(2025,3,14); i = findfirst(==(d), wd)
        ms = market_state(spy, wd, d)
        lo = findfirst(x -> x >= d - Day(105), wd)    # start INCLUSIVE (R31)
        @test wd[lo] == d - Day(105) && wd[lo-1] < d - Day(105)
        w = spy[lo:i]
        @test ms.λ ≈ -20 * (ema(w, 21) / ema(w, 63) - 1)
        # window start matters: a window starting one day earlier gives a different λ
        w2 = spy[lo-1:i]
        @test !isapprox(ms.λ, -20 * (ema(w2, 21) / ema(w2, 63) - 1); rtol=1e-12)
        # ḡ_M: more than 253 closes -> last 252 growth rates
        @test i > 253
        g = 252 .* diff(log.(spy[1:i]))
        @test ms.ḡ_M ≈ mean(g[end-251:end])
        # fewer closes -> all available growth rates
        d2 = wd[100]; ms2 = market_state(spy, wd, d2)
        @test ms2.ḡ_M ≈ mean(252 .* diff(log.(spy[1:100])))
    end
end

@testset "ewls_init market prior (CHEME-5660 seeding)" begin
    m, v = 0.12, 7.0
    s = ewls_init(0.05, 1.0, 2.0; market_mean=m, market_variance=v)
    @test s.Swx ≈ 63m && s.Swxx ≈ 63(v + m^2)
    β = (s.Sw*s.Swxy - s.Swx*s.Swy) / (s.Sw*s.Swxx - s.Swx^2); α = (s.Swy - β*s.Swx) / s.Sw
    @test β ≈ 1.0 rtol=1e-12
    @test α ≈ 0.05 rtol=1e-10
    l = ewls_init(0.05, 1.0, 2.0)                                  # legacy default unchanged
    @test (l.Swx, l.Swxx, l.Swxy, l.Swyy) == (0.0, 63.0, 63.0, 63 * (0.05^2 + 1.0 + 4.0))
    # 64 data points with the prior's market moments pull β exactly halfway to the data's β = 0;
    # the legacy unit-variance seed is ~7× weaker in growth units and lets β fall below 0.2.
    x = [isodd(k) ? m + sqrt(v) : m - sqrt(v) for k in 1:64]
    p = ewls_init(0.0, 1.0, 1.0; half_life=Inf, prior_weight=64.0, market_mean=m, market_variance=v)
    q = ewls_init(0.0, 1.0, 1.0; half_life=Inf, prior_weight=64.0)
    foreach(xk -> (ewls_update!(p, 0.0, xk); ewls_update!(q, 0.0, xk)), x)
    @test p.β ≈ 0.5 rtol=1e-9
    @test q.β < 0.2
end

@testset "fit_base_sim market moments" begin
    md = synthetic_md(ρ=0.3)
    fit = fit_base_sim(md, md.dates[1], md.dates[800])
    g = growth_rates(md.spy_close[1:800])
    @test fit.m_m ≈ mean(g) && fit.v_m ≈ var(g; corrected=false) && fit.σ_m ≈ std(g)
end
