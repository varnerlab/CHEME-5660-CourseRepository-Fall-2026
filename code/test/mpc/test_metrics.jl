using Test
using Statistics
curve(r) = 100.0 .* vcat(1.0, cumprod(1 .+ r))

@testset "scorecard" begin
    spy = [100.0, 101, 99, 102, 103]
    @test scorecard([100.0, 120, 90, 130], [100.0, 101, 102, 103], zeros(4)).max_drawdown ≈ 0.25

    s = scorecard(spy, spy, fill(0.03, 5))
    @test s.alpha_ann ≈ 0 atol = 1e-10
    @test s.beta ≈ 1

    rs = [0.01, -0.02, 0.015, 0.005, -0.01, 0.02]
    s2 = scorecard(curve(2 .* rs), curve(rs), zeros(7))
    @test s2.beta ≈ 2

    eq = [100.0, 101, 100, 102, 101]
    r = [0.01, -1/101, 0.02, -1/102]
    s3 = scorecard(eq, [100.0, 100, 101, 100, 102], zeros(5))
    @test s3.sharpe ≈ sqrt(252) * mean(r) / std(r)
    @test s3.ann_vol ≈ sqrt(252) * std(r)
    @test s3.ann_return ≈ (101 / 100)^(252 / 4) - 1

    # Hand-computed OLS: x = r_SPY = (-2,-1,0,1,2)%, y = r = (1,-1,2,0,3)%, g_f = 0.
    # slope 0.5, intercept 0.01, SSR 7.5e-4, s² = SSR/3, SE(int) = sqrt(s²/5) => t = sqrt(2).
    s4 = scorecard(curve([0.01, -0.01, 0.02, 0.0, 0.03]), curve([-0.02, -0.01, 0.0, 0.01, 0.02]), zeros(6))
    @test s4.beta ≈ 0.5
    @test s4.alpha_ann ≈ 2.52
    @test s4.alpha_t ≈ sqrt(2)

    # Risk-free: g_f at day t applies to the return ending at t.
    gf = [0.0, 0.05, 0.05, 0.05, 0.05, 0.05]
    s5 = scorecard(curve([0.01, -0.01, 0.02, 0.0, 0.03]), curve([-0.02, -0.01, 0.0, 0.01, 0.02]), gf)
    @test s5.beta ≈ 0.5 atol = 1e-12
    @test s5.alpha_ann < s4.alpha_ann

    @test isnan(scorecard([100.0, 101, 102.01, 103.0301], [100.0, 101, 99, 102], zeros(4)).sharpe)
    @test_throws ArgumentError scorecard([1.0, 2, 3], [1.0, 2], zeros(3))
    @test_throws ArgumentError scorecard([1.0, 2], [1.0, 2], zeros(2))
    @test_throws ArgumentError scorecard([1.0, 2, 3], [1.0, 2, 3], zeros(3))
    @test_throws ArgumentError scorecard([1.0, 2, 0, 3], [1.0, 2, 3, 4], zeros(4))
    @test_throws ArgumentError scorecard([1.0, 2, 3, 4], [1.0, 2, -3, 4], zeros(4))

    # Perfect fit with g_f > 0: degenerate SE -> alpha_t NaN.
    s6 = scorecard(spy, spy, fill(0.03, 5))
    @test isnan(s6.alpha_t)
    @test s6.alpha_ann ≈ 0 atol = 1e-10
    @test s6.beta ≈ 1
end
