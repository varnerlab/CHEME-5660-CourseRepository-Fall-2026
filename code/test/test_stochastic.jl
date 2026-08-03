using Test
using VLQuantitativeFinancePackage
using Random
using Statistics
using LinearAlgebra

@testset "stochastic" begin

    @testset "GBM expectation/variance closed forms (deterministic)" begin
        m = build(MyGeometricBrownianMotionEquityModel, (μ = 0.08, σ = 0.2))
        data = (T₁ = 0.0, T₂ = 1.0, Δt = 0.25, Sₒ = 100.0)
        E = expectation(m, data)
        V = variance(m, data)
        @test size(E) == (5, 2)
        for i ∈ 1:5
            h = E[i, 1]
            @test isapprox(E[i, 2], 100.0 * exp(0.08 * h); atol = 1e-8)
            @test isapprox(V[i, 2], 100.0^2 * exp(2 * 0.08 * h) * (exp(0.2^2 * h) - 1); atol = 1e-6)
        end
    end

    @testset "GBM sample: drift/vol recovery (seeded)" begin
        Random.seed!(20260803)
        m = build(MyGeometricBrownianMotionEquityModel, (μ = 0.10, σ = 0.25))
        X = VLQuantitativeFinancePackage.sample(m, (T₁ = 0.0, T₂ = 1.0, Δt = 1.0 / 252.0, Sₒ = 100.0); number_of_paths = 2000)
        @test all(X[1, 2:end] .== 100.0)
        @test X[1, 1] == 0.0

        logret = log.(X[end, 2:end] ./ 100.0)
        @test isapprox(mean(X[end, 2:end]), 100.0 * exp(0.10); rtol = 2e-2)
        @test isapprox(mean(logret), 0.10 - 0.25^2 / 2; atol = 1e-2)
        @test isapprox(std(logret), 0.25; rtol = 5e-2)
    end

    @testset "GBM sample_endpoint (seeded)" begin
        Random.seed!(20260803)
        m = build(MyGeometricBrownianMotionEquityModel, (μ = 0.10, σ = 0.25))
        X = VLQuantitativeFinancePackage.sample_endpoint(m, (T = 1.0, Sₒ = 100.0); number_of_paths = 5000)
        @test length(X) == 5000
        @test isapprox(mean(X), 100.0 * exp(0.10); rtol = 2e-2)
    end

    @testset "multi-asset GBM recovers drift and covariance (seeded)" begin
        Random.seed!(20260803)
        μ = [0.08, 0.10]
        A = [0.20 0.0; 0.10 sqrt(0.03)]
        target_covariance = A * transpose(A)
        m = build(MyMultipleAssetGeometricBrownianMotionEquityModel, (μ = μ, A = A))
        paths = VLQuantitativeFinancePackage.sample(
            m, (T₁ = 0.0, T₂ = 1.0, Δt = 1.0, Sₒ = [100.0, 100.0]);
            number_of_paths = 6000,
        )
        log_returns = reduce(vcat, [
            reshape(log.(paths[i][end, 2:end] ./ paths[i][1, 2:end]), 1, :)
            for i ∈ eachindex(paths)
        ])

        expected_log_drift = μ .- 0.5 .* diag(target_covariance)
        @test isapprox(vec(mean(log_returns; dims = 1)), expected_log_drift; atol = 6e-3)
        @test isapprox(cov(log_returns), target_covariance; atol = 3e-3)
    end

    @testset "Euler-Maruyama OU: zero-noise deterministic limit" begin
        # dX = θ(μ - X)dt exactly solvable: X(t) = μ + (X₀ - μ)e^{-θt}
        m = build(MyOrnsteinUhlenbeckModel, (μ = (x, t) -> 2.0, σ = (x, t) -> 0.0, θ = (x, t) -> 1.5))
        (T, X) = solve(m, (start = 0.0, stop = 1.0, step = 0.001), [0.0]; N = 3)
        @test isapprox(X[end, 1], 2.0 * (1 - exp(-1.5)); atol = 1e-2)   # EM error O(dt)
        @test all(X[:, 1] .== X[:, 2] .== X[:, 3])                      # no noise → identical paths
    end

    @testset "Euler-Maruyama OU: stationary moments (seeded)" begin
        Random.seed!(20260803)
        m = build(MyOrnsteinUhlenbeckModel, (μ = (x, t) -> 1.0, σ = (x, t) -> 0.2, θ = (x, t) -> 5.0))
        (T, X) = solve(m, (start = 0.0, stop = 5.0, step = 0.001), [1.0]; N = 50)
        tail = X[end - 999:end, :]                                       # last 1000 steps, 50 paths
        @test isapprox(mean(tail), 1.0; atol = 5e-2)
        @test isapprox(std(tail), sqrt(0.2^2 / (2 * 5.0)); rtol = 3e-1)  # σ/√(2θ) ≈ 0.0632
    end

    @testset "Euler-Maruyama Heston: runs finite (seeded, Feller-safe params)" begin
        Random.seed!(20260803)
        m = build(MyHestonModel, (μ = (x, t) -> 0.05, κ = (x, t) -> 3.0, θ = (x, t) -> 0.04,
                                  ξ = (x, t) -> 0.10, Σ = [1.0 0.0; 0.0 1.0]))
        (T, X, V) = solve(m, (start = 0.0, stop = 1.0, step = 0.001), [100.0, 0.04]; N = 10)
        @test all(isfinite, X)
        @test all(isfinite, V)     # no variance-truncation guard exists in src — Task 10 suspect if this is fragile
    end

    @testset "Euler-Maruyama Heston: non-Feller params with variance guard" begin
        # Non-Feller params: κ=0.5, θ=0.01, ξ=1.0 violate 2κθ ≥ ξ² (0.01 < 1.0)
        Random.seed!(20260803)
        m = build(MyHestonModel, (μ = (x, t) -> 0.05, κ = (x, t) -> 0.5, θ = (x, t) -> 0.01,
                                  ξ = (x, t) -> 1.0, Σ = [1.0 0.0; 0.0 1.0]))
        (T, X, V) = solve(m, (start = 0.0, stop = 1.0, step = 0.01), [100.0, 0.01]; N = 20)
        @test all(isfinite, X)
        @test all(isfinite, V)
    end
end
