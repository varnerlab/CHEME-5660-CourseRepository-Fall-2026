using Test, Dates, Random, Statistics
include("helpers.jl")
# Market with constant closes (zero growth) except where `G` (days−1 × names, yr⁻¹) says otherwise,
# and volume (days × names, shares/day); 300 weekdays from 2020-01-01, one sector.
function uni_md(; n=300, m=48, G=zeros(n - 1, m), volume=ones(n, m))
    dates = first(filter(d -> dayofweek(d) <= 5, collect(Date(2020,1,1):Day(1):Date(2030,12,31))), n)
    cl = 10 .* exp.(vcat(zeros(1, m), cumsum(G ./ 252; dims=1)))
    build(MyMarketData, (dates=dates, tickers=["N$(lpad(j, 2, '0'))" for j in 1:m], open=cl, close=cl, volume=volume,
        spy_open=fill(100.0, n), spy_close=100 .* exp.(cumsum(vcat(0.0, 0.5 .* sin.(1:n-1)) ./ 252)), sector=fill("S1", m), g_f=zeros(n)))
end
X0 = zeros(1, 1)
@testset "global γ and liquid shortlist" begin
    md = uni_md(volume=repeat(Float64.((1:48)'), 300, 1))                     # dollar volume ∝ column index
    γ = collect(1:48) ./ 100
    @test pick(MyGlobalGammaScreen(5), md, 280; X=X0, γ_t=γ, N=3, seed=1) == [44, 45, 46, 47, 48]
    @test liquid_shortlist(md, 280; size=10, window=63) == collect(48:-1:39)
    v = repeat(Float64.((1:48)'), 300, 1); v[270, 1] = 1e12           # one huge day inside the window: median unmoved
    @test liquid_shortlist(uni_md(volume=v), 280; size=10, window=63) == collect(48:-1:39)
    γr = collect(48:-1:1) ./ 100                                     # name 1 has the highest γ, but it is illiquid
    @test pick(MyLiquidGammaScreen(3, 10, 63), md, 280; X=X0, γ_t=γr, N=3, seed=1) == [39, 40, 41]
    @test pick(MyGlobalGammaScreen(100), md, 280; X=X0, γ_t=γ, N=3, seed=1) == collect(1:48)   # K > universe
end
@testset "correlation-aware γ" begin                                # Review Focus 1, 3
    rng = MersenneTwister(3); G = randn(rng, 299, 6)
    G[:, 2] = G[:, 1]                                                # names 1 and 2 identical (ρ = 1)
    md = uni_md(m=6, G=G)
    γ = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4]
    @test pick(MyCorrGammaScreen(2, 0.7, 252), md, 299; X=X0, γ_t=γ, N=3, seed=1) == [1, 3]
    Gs = repeat(G[:, 1], 1, 6); same = uni_md(m=6, G=Gs)             # every pair ρ = 1: one accepted, fill by γ
    @test pick(MyCorrGammaScreen(3, 0.7, 252), same, 299; X=X0, γ_t=γ, N=3, seed=1) == [1, 2, 3]
    Gz = copy(G); Gz[:, 3] .= 0.0                                    # name 3 has zero variance: NaN ρ is accepted
    @test 3 in pick(MyCorrGammaScreen(3, 0.7, 252), uni_md(m=6, G=Gz), 299; X=X0, γ_t=γ, N=3, seed=1)
    p = perturb_after(md, md.dates[250])                             # canary: data after t unused
    @test pick(MyCorrGammaScreen(2, 0.7, 200), p, 250; X=X0, γ_t=γ, N=3, seed=1) ==
          pick(MyCorrGammaScreen(2, 0.7, 200), md, 250; X=X0, γ_t=γ, N=3, seed=1)
end
@testset "random controls and the fixed list" begin                 # Review Focus 2
    md = uni_md(volume=repeat(Float64.((1:48)'), 300, 1)); γ = zeros(48)
    r = pick(MyGlobalRandomScreen(8), md, 280; X=X0, γ_t=γ, N=3, seed=11)
    @test length(r) == 8 && allunique(r) && issorted(r)
    @test r == pick(MyGlobalRandomScreen(8), md, 280; X=X0, γ_t=γ, N=3, seed=11)
    @test r != pick(MyGlobalRandomScreen(8), md, 280; X=X0, γ_t=γ, N=3, seed=12)
    rl = pick(MyLiquidRandomScreen(5, 10, 63), md, 280; X=X0, γ_t=γ, N=3, seed=11)
    @test length(rl) == 5 && all(in(39:48), rl)
    p = perturb_after(md, md.dates[280])
    @test pick(MyLiquidRandomScreen(5, 10, 63), p, 280; X=X0, γ_t=γ, N=3, seed=11) == rl
    @test pick(MyFixedScreen(["N05", "N02", "N40"]), md, 280; X=X0, γ_t=γ, N=3, seed=1) == [2, 5, 40]
    @test_throws ArgumentError pick(MyFixedScreen(["N05", "ZZZ"]), md, 280; X=X0, γ_t=γ, N=3, seed=1)
end
