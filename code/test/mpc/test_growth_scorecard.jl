using Test, Statistics
@testset "growth scorecard" begin
    n = 300; Δt = 1/252
    spy = 100 .* exp.(cumsum(vcat(0.0, 0.01 .* sin.(0.3 .* (1:n-1)))))
    W = 1e5 .* (spy ./ spy[1]) .^ 2 .* exp.(0.05 .* (0:n-1) .* Δt)       # g_W = 2·g_SPY + 0.05
    sc = growth_scorecard(W, spy, fill(0.04, n))
    gW = diff(log.(W)) ./ Δt
    @test sc.sharpe ≈ mean(gW .- 0.04) / (std(gW .- 0.04) * sqrt(Δt))
    @test sc.sharpe ≈ mean(diff(log.(W)) .- 0.04Δt) / std(diff(log.(W)) .- 0.04Δt) * sqrt(1 / Δt)   # realized_scorecard
    @test sc.beta ≈ 2.0 rtol=1e-10
    @test sc.alpha ≈ 0.09 rtol=1e-8                                                                 # 0.05 + g_f
    @test sc.realized_growth ≈ log(W[end] / W[1]) / ((n - 1) * Δt)
    @test sc.terminal == W[end]
    @test sc.vol ≈ std(gW) * sqrt(Δt)
    @test growth_scorecard([100.0, 120.0, 90.0, 130.0, 110.0], fill(100.0, 5) .* [1, 1.01, 1.0, 1.02, 1.01], zeros(5)).max_drawdown ≈ 0.25
    @test !any(occursin("return", String(k)) for k in keys(sc))
end
