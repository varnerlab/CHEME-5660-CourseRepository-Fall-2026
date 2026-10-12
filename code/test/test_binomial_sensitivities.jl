using Test
using Distributions
using VLQuantitativeFinancePackage

@testset "full-precision CRR and Leisen-Reimer sensitivities" begin
    # Independent European formulas, including a continuous dividend yield -
    function analytic_value_and_greeks(S, K, T, σ, r, q, is_call)
        d1 = (log(S / K) + (r - q + σ^2 / 2) * T) / (σ * sqrt(T))
        d2 = d1 - σ * sqrt(T)
        normal = Normal()
        a, b = exp(-q * T), exp(-r * T)
        gamma = a * pdf(normal, d1) / (S * σ * sqrt(T))
        vega = S * a * pdf(normal, d1) * sqrt(T)
        diffusion_theta = -S * a * pdf(normal, d1) * σ / (2 * sqrt(T))
        if is_call
            price = S * a * cdf(normal, d1) - K * b * cdf(normal, d2)
            delta = a * cdf(normal, d1)
            theta = diffusion_theta - r * K * b * cdf(normal, d2) + q * S * a * cdf(normal, d1)
            rho = K * T * b * cdf(normal, d2)
        else
            price = K * b * cdf(normal, -d2) - S * a * cdf(normal, -d1)
            delta = -a * cdf(normal, -d1)
            theta = diffusion_theta + r * K * b * cdf(normal, -d2) - q * S * a * cdf(normal, -d1)
            rho = -K * T * b * cdf(normal, -d2)
        end
        return (; price, delta, gamma, theta, vega, rho)
    end

    @testset "European values and all five derivatives" begin
        for is_call in (true, false), S in (80.0, 100.0, 120.0), q in (0.0, 0.02)
            K, T, σ, r = 100.0, 0.5, 0.3, 0.05
            contract_type = is_call ? MyEuropeanCallContractModel : MyEuropeanPutContractModel
            contract = build(contract_type, (K=K, sense=1))
            reference = analytic_value_and_greeks(S, K, T, σ, r, q, is_call)
            value = binomial_premium(contract; method=:leisen_reimer, h=801, Sₒ=S, T=T, σ=σ, μ=r, dividend_yield=q)
            greeks = binomial_greeks(contract; method=:leisen_reimer, h=801, Sₒ=S, T=T, σ=σ, μ=r,
                dividend_yield=q, spot_bump=0.1, volatility_bump=0.0005)
            @test isapprox(value, reference.price; atol=1e-4)
            for key in (:delta, :gamma, :theta, :vega, :rho)
                @test isapprox(greeks[key], reference[key]; atol=2e-4, rtol=2e-4)
            end
        end
    end

    @testset "American exercise and existing CRR integration" begin
        for contract_type in (MyAmericanCallContractModel, MyAmericanPutContractModel,
            MyEuropeanCallContractModel, MyEuropeanPutContractModel)
            contract = build(contract_type, (K=100.0, sense=1))
            tree = build(MyAdjacencyBasedCRREquityPriceTree, (μ=0.05, T=0.5, σ=0.2)) |>
                x -> populate(x; Sₒ=100.0, h=101)
            american = contract isa Union{MyAmericanCallContractModel,MyAmericanPutContractModel}
            choice = american ? max : ((current, future) -> future)
            @test isapprox(binomial_premium(contract; h=101, Sₒ=100.0, T=0.5, σ=0.2, μ=0.05),
                premium(contract, tree; choice=choice, sigdigits=16); atol=1e-10)
        end
        call = build(MyEuropeanCallContractModel, (K=100.0, sense=1))
        acall = build(MyAmericanCallContractModel, (K=100.0, sense=1))
        put = build(MyEuropeanPutContractModel, (K=100.0, sense=1))
        aput = build(MyAmericanPutContractModel, (K=100.0, sense=1))
        inputs = (method=:leisen_reimer, h=801, Sₒ=100.0, T=0.5, σ=0.2, μ=0.05)
        @test isapprox(binomial_premium(call; inputs...), binomial_premium(acall; inputs...); atol=1e-10)
        @test binomial_premium(aput; inputs...) > binomial_premium(put; inputs...)
        @test 20.0 <= binomial_premium(aput; inputs..., Sₒ=80.0) <= 100.0
        @test binomial_premium(aput; inputs..., T=0.0, Sₒ=80.0) == 20.0
        short = build(MyAmericanPutContractModel, (K=100.0, sense=-1, copy=3, premium=9.0))
        @test binomial_premium(short; inputs...) == binomial_premium(aput; inputs...)
        @test binomial_premium(call; inputs..., h=800) == binomial_premium(call; inputs...)
    end

    @testset "invalid inputs" begin
        call = build(MyEuropeanCallContractModel, (K=100.0, sense=1))
        @test_throws ArgumentError binomial_premium(call; method=:unknown)
        @test_throws ArgumentError binomial_premium(call; h=0)
        @test_throws ArgumentError binomial_premium(call; T=-1.0)
        @test_throws ArgumentError binomial_premium(call; Sₒ=NaN)
        @test_throws ArgumentError binomial_premium(call; Sₒ=0.0)
        @test_throws ArgumentError binomial_greeks(call; spot_bump=0.0)
        @test_throws ArgumentError binomial_greeks(call; time_bump=1.0)
        @test_throws ArgumentError binomial_greeks(call; volatility_bump=1.0)
    end
end
