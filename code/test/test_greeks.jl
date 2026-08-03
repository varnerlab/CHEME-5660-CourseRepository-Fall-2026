using Test
using VLQuantitativeFinancePackage
using Distributions

@testset "greeks (delta/gamma/theta)" begin
    K = 100.0; S = 100.0; σ = 0.20; r = 0.05; T = 0.5; h = 200
    c = build(MyEuropeanCallContractModel, (K = K, sense = 1))
    european_choice = (current, future) -> future

    # analytic Black-Scholes quantities, computed here from first principles
    d1 = (log(S / K) + (r + σ^2 / 2) * T) / (σ * sqrt(T))
    d2 = d1 - σ * sqrt(T)
    N = Normal(0, 1)
    Δbs = cdf(N, d1)
    Γbs = pdf(N, d1) / (S * σ * sqrt(T))
    Θbs_per_day = (-(S * pdf(N, d1) * σ) / (2 * sqrt(T)) - r * K * exp(-r * T) * cdf(N, d2)) / 365.0

    @testset "delta" begin
        Δ = delta(c; h = h, T = T, σ = σ, Sₒ = S, μ = r)
        @test 0.0 < Δ < 1.0
        @test isapprox(Δ, Δbs; atol = 5e-2)          # secant ≈ tangent + ½Γ ≈ 0.013 offset

        # structural cross-check: delta must equal the hand-built premium secant exactly
        m0 = build(MyAdjacencyBasedCRREquityPriceTree, (μ = r, T = T, σ = σ)) |> (x -> populate(x, Sₒ = S, h = h))
        m1 = build(MyAdjacencyBasedCRREquityPriceTree, (μ = r, T = T, σ = σ)) |> (x -> populate(x, Sₒ = S + 1, h = h))
        @test isapprox(Δ, premium(c, m1) - premium(c, m0); atol = 1e-10)
    end

    @testset "gamma" begin
        Γ = gamma(c; h = h, T = T, σ = σ, Sₒ = S, μ = r, choice = european_choice)
        @test Γ > 0.0
        @test isapprox(Γ, Γbs; atol = 5e-4)
        @test_throws ArgumentError gamma(c; h = 1, T = T, σ = σ, Sₒ = S, μ = r)
    end

    @testset "theta" begin
        Θ = theta(c; h = h, T = T, σ = σ, Sₒ = S, μ = r)
        @test Θ < 0.0                                 # long option decays
        @test isapprox(Θ, Θbs_per_day; atol = 1e-2)
    end

    @testset "vector variants" begin
        vals = delta([c, c]; h = 50, T = T, σ = σ, Sₒ = S, μ = r)
        @test length(vals) == 2
        @test isapprox(vals[1], vals[2]; atol = 1e-12)
    end
end
