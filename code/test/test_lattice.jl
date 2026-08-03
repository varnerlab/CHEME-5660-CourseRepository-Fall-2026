using Test
using VLQuantitativeFinancePackage

const EURO = (current, future) -> future   # European choice function for tree premium

@testset "lattice" begin

    @testset "Hull price lattice (from test_hull_example.jl)" begin
        m = build(MyBinomialEquityPriceTree, (u = 1.1, d = 0.9, p = 0.6523)) |> (x -> populate(x, Sₒ = 20.0, h = 2))
        hull = Dict(0 => 20.0, 1 => 22.0, 2 => 18.0, 3 => 24.2, 4 => 19.8, 5 => 16.2)
        @test length(m.data) == 6
        for (i, expected) ∈ hull
            @test isapprox(m.data[i].price, expected; rtol = 1e-4)
        end
        for level ∈ 0:2   # reach probabilities sum to 1 on each level
            @test isapprox(sum(m.data[j].probability for j ∈ m.levels[level]), 1.0; atol = 1e-8)
        end
    end

    @testset "Hull two-step European call = 1.2823" begin
        m = build(MyBinomialEquityPriceTree, (u = 1.1, d = 0.9, p = 0.6523, μ = 0.12, T = 0.5)) |>
            (x -> populate(x, Sₒ = 20.0, h = 2))
        c = build(MyEuropeanCallContractModel, (K = 21.0, sense = 1))
        @test isapprox(premium(c, m; choice = EURO), 1.2823; rtol = 2e-3)
    end

    @testset "Hull two-step American put = 5.0894 (European = 4.1923)" begin
        p = (exp(0.05) - 0.8) / (1.2 - 0.8)
        m = build(MyBinomialEquityPriceTree, (u = 1.2, d = 0.8, p = p, μ = 0.05, T = 2.0)) |>
            (x -> populate(x, Sₒ = 50.0, h = 2))
        put = build(MyAmericanPutContractModel, (K = 52.0, sense = 1))
        amer = premium(put, m)
        euro = premium(put, m; choice = EURO)
        @test isapprox(amer, 5.0894; rtol = 1e-3)
        @test isapprox(euro, 4.1923; rtol = 1e-3)
        @test amer > euro
    end

    @testset "CRR risk-neutral parameterization" begin
        m = build(MyAdjacencyBasedCRREquityPriceTree, (μ = 0.05, σ = 0.2, T = 1.0)) |>
            (x -> populate(x, Sₒ = 100.0, h = 4))
        ΔT = 1.0 / 4
        u = exp(0.2 * sqrt(ΔT)); d = 1 / u
        @test isapprox(m.u, u; atol = 1e-12)
        @test isapprox(m.d, d; atol = 1e-12)
        @test isapprox(m.p, (exp(0.05 * ΔT) - d) / (u - d); atol = 1e-12)
        @test isapprox(m.data[0].price, 100.0; atol = 1e-12)
        @test isapprox(sum(m.data[j].probability for j ∈ m.levels[4]), 1.0; atol = 1e-8)
    end

    @testset "CRR European call converges to Black-Scholes" begin
        c   = build(MyEuropeanCallContractModel, (K = 100.0, sense = 1, DTE = 0.5, IV = 0.2))
        bsm = build(MyBlackScholesContractPricingModel, (Sₒ = 100.0, r = 0.05))
        C_bsm = premium(c, bsm)
        m = build(MyAdjacencyBasedCRREquityPriceTree, (μ = 0.05, σ = 0.2, T = 0.5)) |>
            (x -> populate(x, Sₒ = 100.0, h = 500))
        @test isapprox(premium(c, m; choice = EURO), C_bsm; atol = 5e-2)
    end

    @testset "AMD American put (from test_AMD_CRR_put.jl)" begin
        DTE = 31.0 / 365.0
        put = build(MyAmericanPutContractModel, (K = 110.0, IV = 0.5175, DTE = DTE, sense = 1))
        m200 = build(MyAdjacencyBasedCRREquityPriceTree, (σ = 0.5175, μ = 0.0418, T = DTE)) |>
               (x -> populate(x, Sₒ = 117.50, h = 200))
        P200 = premium(put, m200)

        # lower bound: same-parameter European put via Black-Scholes (American ≥ European, no dividends)
        eput = build(MyEuropeanPutContractModel, (K = 110.0, IV = 0.5175, DTE = DTE, sense = 1))
        bsm  = build(MyBlackScholesContractPricingModel, (Sₒ = 117.50, r = 0.0418))
        @test P200 ≥ premium(eput, bsm) - 1e-2
        @test 0.0 < P200 < 110.0

        # lattice-height convergence
        m201 = build(MyAdjacencyBasedCRREquityPriceTree, (σ = 0.5175, μ = 0.0418, T = DTE)) |>
               (x -> populate(x, Sₒ = 117.50, h = 201))
        @test isapprox(P200, premium(put, m201); atol = 5e-2)
    end

    @testset "premium on data-parameterized tree (from test_utility_contract.jl)" begin
        DTE = 31.0 / 365.0
        put = build(MyAmericanPutContractModel, (K = 110.0, IV = 0.5175, DTE = DTE, sense = 1))
        m = build(MyBinomialEquityPriceTree,
                (u = 1.0079252620171597, d = 0.9921370538909811, p = 0.49864256260778633, T = DTE, μ = 0.0418)) |>
            (x -> populate(x, Sₒ = 117.50, h = 100))
        P = premium(put, m)
        @test isfinite(P)
        @test 0.0 < P < 110.0
    end

    @testset "implied-volatility round trip (from test_IV_put.jl)" begin
        # generate an observed premium at a known σ*, then recover σ* from a different start
        σstar = 0.30
        DTE = 0.25; K = 100.0; S = 95.0; r = 0.05; h = 100
        m = build(MyAdjacencyBasedCRREquityPriceTree, (σ = σstar, μ = r, T = DTE)) |>
            (x -> populate(x, Sₒ = S, h = h))
        put = build(MyAmericanPutContractModel, (K = K, IV = σstar, DTE = DTE, sense = 1))
        Pstar = premium(put, m)

        contract = build(MyAmericanPutContractModel, (K = K, IV = 0.20, DTE = DTE, sense = 1, premium = Pstar))
        (likelihood, IVest) = estimate_implied_volatility(contract; Sₒ = S, h = h, r̄ = r)
        @test isapprox(IVest, σstar; atol = 2e-2)
        @test likelihood > 0.0
    end
end
