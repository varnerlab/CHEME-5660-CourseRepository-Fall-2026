using Test, Dates
include("helpers.jl")
# Market from SPY growth gm (yr⁻¹, one per day after the first) and ticker growth G (days−1 × names).
function growth_md(gm::Vector{Float64}, G::Matrix{Float64})
    n = length(gm) + 1; m = size(G, 2)
    dates = first(filter(d -> dayofweek(d) <= 5, collect(Date(2020,1,1):Day(1):Date(2030,12,31))), n)
    cl = 100 .* exp.(vcat(zeros(1, m), cumsum(G ./ 252; dims=1))); spy = 100 .* exp.(vcat(0.0, cumsum(gm ./ 252)))
    build(MyMarketData, (dates=dates, tickers=["N$(j)" for j in 1:m], open=cl, close=cl, volume=fill(1e6, n, m),
        spy_open=spy, spy_close=spy, sector=fill("S1", m), g_f=zeros(n)))
end
@testset "down-day β" begin
    gm = 2.0 .* sin.(0.7 .* (1:299))
    G = hcat([x < 0 ? -0.5x : 0.8x for x in gm], gm)                    # hedge on down days; plain β = 1
    md = growth_md(gm, G)
    b = down_day_beta(md, 300; lookback=252)
    @test b[1] ≈ -0.5 rtol=1e-8
    @test b[2] ≈ 1.0 rtol=1e-8
    G2 = copy(G); G2[10, 1] += 50.0                                     # outside the window: no effect
    @test down_day_beta(growth_md(gm, G2), 300; lookback=252) ≈ b rtol=1e-10   # later prices shift: last-bit noise only
    @test all(isnan, down_day_beta(growth_md(abs.(gm), G), 300; lookback=252))   # no down days
end
@testset "down-day β perturb-after-d canary" begin
    gm = 2.0 .* sin.(0.7 .* (1:299))
    G = hcat([x < 0 ? -0.5x : 0.8x for x in gm], gm .+ 0.3 .* cos.(1.3 .* (1:299)))
    md = growth_md(gm, G)
    d = 200
    pert = perturb_after(md, md.dates[d])
    @test down_day_beta(pert, d; lookback=252) == down_day_beta(md, d; lookback=252)
    # The doubling is a pure rescale, so it only adds an up-day jump that the filter drops. A halving of
    # SPY alone after d makes day d+1 a down day: the later result must change, so the canary can fail.
    f = ifelse.(md.dates .> md.dates[d], 0.5, 1.0)
    shock = build(MyMarketData, (dates=md.dates, tickers=md.tickers, open=md.open, close=md.close,
        volume=md.volume, spy_open=md.spy_open .* f, spy_close=md.spy_close .* f, sector=md.sector, g_f=md.g_f))
    @test down_day_beta(shock, d; lookback=252) == down_day_beta(md, d; lookback=252)
    @test down_day_beta(shock, d + 1; lookback=252) != down_day_beta(md, d + 1; lookback=252)
end
@testset "hedge pool and β cap" begin
    β_t = [-0.2, -0.1, 0.3, -0.4, -0.05, -0.3, -0.01]
    βd = [-0.3, 0.2, -0.5, -0.1, NaN, -0.3, -0.6]
    @test hedge_pool(β_t, βd; H=5) == [7, 1, 6, 4]
    @test hedge_pool(β_t, βd; H=2) == [7, 1]
    @test isempty(hedge_pool(fill(0.5, 3), fill(-1.0, 3)))
    @test beta_cap(0.0) == 1.0 && beta_cap(0.5) == 0.5 && beta_cap(-0.5) == 1.5 && beta_cap(2.0) == 0.0
    @test beta_cap(0.5; β_ref=1.2, κ_β=0.4, β_min=0.3) ≈ 1.0
end
