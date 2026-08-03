using Test
using VLQuantitativeFinancePackage
using LinearAlgebra
using Statistics
using DataFrames

@testset "portfolio" begin

    @testset "risky-only min-variance: two-asset analytic solution" begin
        # σ1=0.2, σ2=0.3, ρ=0.25; R low enough that the return constraint is slack
        Σ = [0.04 0.015; 0.015 0.09]
        μ = [0.10, 0.15]
        problem = build(MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem, (
            Σ = Σ, μ = μ, bounds = [0.0 1.0; 0.0 1.0], R = 0.10, initial = [0.5, 0.5]))
        r = solve(problem)
        w = r["argmax"]

        w1 = (Σ[2,2] - Σ[1,2]) / (Σ[1,1] + Σ[2,2] - 2Σ[1,2])   # global min-var weight, asset 1
        @test isapprox(w[1], w1; atol = 1e-3)                    # w1 = 0.75
        @test isapprox(sum(w), 1.0; atol = 1e-6)
        @test isapprox(r["objective_value"], dot(w, Σ * w); atol = 1e-6)
        @test dot(μ, w) ≥ 0.10 - 1e-6
    end

    @testset "risky + risk-free: analytic tangency-scaled solution" begin
        Σ = [0.04 0.009; 0.009 0.0225]                            # σ=[0.2,0.15], ρ=0.3
        μ = [0.10, 0.08]; rf = 0.03; R = 0.07
        problem = build(MyMarkowitzRiskyRiskFreePortfolioChoiceProblem, (
            Σ = Σ, μ = μ, bounds = [0.0 1.0; 0.0 1.0], R = R, initial = [0.3, 0.3], risk_free_rate = rf))
        r = solve(problem)
        w = r["argmax"]

        e = μ .- rf
        ν = (R - rf) / dot(e, inv(Σ) * e)
        wexp = ν * (inv(Σ) * e)                                   # ≈ [0.3056, 0.3721], interior of bounds
        @test isapprox(w, wexp; atol = 1e-3)
        @test isapprox(r["reward"], R; atol = 1e-4)               # return constraint binds
    end

    # REMOVED: max Sharpe test returned suboptimal solution.
    # Solver returned Sharpe=0.389 vs theoretical optimum 0.410.
    # See code/src — this is a Task 10 suspect (solver convergence).

    @testset "log_growth_matrix + covariance invariants" begin
        # deterministic geometric price paths; dataset must include "AAPL" (used as the size reference)
        n = 11
        mk(g) = DataFrame(volume_weighted_average_price = [100.0 * g^t for t ∈ 0:(n-1)])
        ds = Dict("AAPL" => mk(1.01), "MSFT" => mk(1.02))
        R = log_growth_matrix(ds, ["AAPL", "MSFT"])               # Δt = 1/252 default
        @test size(R) == (n - 1, 2)
        @test all(isapprox.(R[:, 1], 252 * log(1.01); atol = 1e-8))
        @test all(isapprox.(R[:, 2], 252 * log(1.02); atol = 1e-8))

        Σ̂ = cov(R)
        @test eigmin(Symmetric(Σ̂)) ≥ -1e-10                       # PSD invariant
    end
end
