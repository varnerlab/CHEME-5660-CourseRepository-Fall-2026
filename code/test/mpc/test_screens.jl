using Test, Dates, Random
include("helpers.jl")
@testset "screens" begin
    md = synthetic_md(ρ=0.3); X = excess_growth_windows(md; horizon=21)
    @test size(X) == (length(md.dates) - 21, 48)
    @test X[100, 5] ≈ (log(md.close[121, 5] / md.close[100, 5]) - log(md.spy_close[121] / md.spy_close[100])) / (21 / 252)

    rng = MersenneTwister(1); Xt = 0.1 .* randn(rng, 200, 10); Xt[:, 4] .+= 1.0
    res = train_ticker_bandit(collect(1:10), 1:200, Xt; seed=7)
    @test sum(res.count) == 500
    @test first(rank_arms(res)) == 4
    @test train_ticker_bandit(collect(1:10), 1:200, Xt; seed=7).mean == res.mean
    @test sum(train_ticker_bandit(collect(1:120), 1:200, 0.1 .* randn(rng, 200, 120); seed=7).count) == 5000

    t = 1000; γ = collect(1:48) ./ 100
    b = pick(MyBanditScreen(), md, t; X=X, γ_t=γ, N=3, seed=5660)
    @test length(b) == 12 && issorted(b) && all(count(j -> md.sector[j] == s, b) == 3 for s in unique(md.sector))
    X2 = copy(X); X2[(t - 21 + 1):end, :] .= 1e6                         # windows ending after t: unused
    @test pick(MyBanditScreen(), md, t; X=X2, γ_t=γ, N=3, seed=5660) == b
    p = perturb_after(md, md.dates[t])
    @test pick(MyBanditScreen(), p, t; X=excess_growth_windows(p), γ_t=γ, N=3, seed=5660) == b
    @test_throws ArgumentError pick(MyBanditScreen(), md, 100; X=X, γ_t=γ, N=3, seed=1)

    @test pick(MyGammaScreen(), md, t; X=X, γ_t=γ, N=3, seed=1) == [10, 11, 12, 22, 23, 24, 34, 35, 36, 46, 47, 48]
    r1 = pick(MyRandomScreen(), md, t; X=X, γ_t=γ, N=3, seed=1)
    @test r1 == pick(MyRandomScreen(), md, t; X=X, γ_t=γ, N=3, seed=1)
    @test r1 != pick(MyRandomScreen(), md, t; X=X, γ_t=γ, N=3, seed=2)
    @test r1 != pick(MyRandomScreen(), md, t + 1; X=X, γ_t=γ, N=3, seed=1)
end
@testset "small sectors and short candidates" begin                   # Review Focus 5
    md0 = synthetic_md(ρ=0.3)
    md = build(MyMarketData, merge(NamedTuple(f => getfield(md0, f) for f in fieldnames(MyMarketData)),
        (sector=vcat(md0.sector[1:46], ["S9", "S9"]),)))
    X = excess_growth_windows(md); γ = collect(1:48) ./ 100
    for scr in (MyBanditScreen(), MyGammaScreen(), MyRandomScreen())
        @test count(j -> md.sector[j] == "S9", pick(scr, md, 1000; X=X, γ_t=γ, N=3, seed=3)) == 2
    end
    g = [isodd(j) ? -0.01j : 0.02 for j in 1:48]; g[13:24] .= 0.05      # sector 2: no γ < 0
    s = short_candidates(g, md0; N=3, exclude=[11])
    @test filter(j -> j <= 12, s) == [5, 7, 9]
    @test !any(13 .<= s .<= 24)
    @test issorted(s)
    @test length(short_candidates(g, md0; N=10)) == 6 + 6 + 6            # all γ < 0 names of sectors 1, 3, 4
end
