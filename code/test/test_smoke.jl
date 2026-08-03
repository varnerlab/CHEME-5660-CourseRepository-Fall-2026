using Test
using VLQuantitativeFinancePackage
using DataFrames
using Distributions

@testset "smoke: every buildable exported type constructs" begin

    @testset "contracts + pricing models" begin
        @test build(MyEuropeanCallContractModel, (K = 100.0, sense = 1)) isa MyEuropeanCallContractModel
        @test build(MyEuropeanPutContractModel,  (K = 100.0, sense = 1)) isa MyEuropeanPutContractModel
        @test build(MyAmericanCallContractModel, (K = 100.0, sense = 1)) isa MyAmericanCallContractModel
        @test build(MyAmericanPutContractModel,  (K = 100.0, sense = 1)) isa MyAmericanPutContractModel
        @test build(MyBlackScholesContractPricingModel, (Sₒ = 100.0, r = 0.05)) isa MyBlackScholesContractPricingModel
        @test build(MyLongstaffSchwartzContractPricingModel,
                    (S = [100.0 101.0; 99.0 102.0], r̄ = 0.05, Δt = 1.0 / 365.0)) isa MyLongstaffSchwartzContractPricingModel
    end

    @testset "trees + lattices" begin
        @test build(MyBinomialEquityPriceTree, (u = 1.1, d = 0.9, p = 0.5)) isa MyBinomialEquityPriceTree
        @test build(MyAdjacencyBasedCRREquityPriceTree, (μ = 0.05, σ = 0.2, T = 1.0)) isa MyAdjacencyBasedCRREquityPriceTree
        @test build(MySymmetricBinaryInterestRateLatticeModel,
                    (u = 1.1, d = 0.9, p = 0.5, rₒ = 0.05, T = 2)) isa MySymmetricBinaryInterestRateLatticeModel
        @test build(MyBinaryInterestRateLatticeNodeModel, (probability = 0.5, rate = 0.05, price = 100.0)) isa MyBinaryInterestRateLatticeNodeModel

        g = build(MyGeneralAdjacencyRecombiningCommodityPriceTree, (h = 2, n = 2))
        @test g isa MyGeneralAdjacencyRecombiningCommodityPriceTree
        g = populate(g, 100.0, [1.1, 0.9])
        @test length(g.data) == 6                       # binomial(2+2, 2)
        @test isapprox(g.data[0].price, 100.0; atol = 1e-12)
    end

    @testset "treasury" begin
        @test build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, rate = 0.05, T = 1.0, n = 2)) isa MyUSTreasuryZeroCouponBondModel
        @test build(MyUSTreasuryCouponSecurityModel,
                    (par = 100.0, rate = 0.05, coupon = 0.04, T = 2.0, λ = 2)) isa MyUSTreasuryCouponSecurityModel
    end

    @testset "stochastic models" begin
        @test build(MyGeometricBrownianMotionEquityModel, (μ = 0.05, σ = 0.2)) isa MyGeometricBrownianMotionEquityModel
        @test build(MyMultipleAssetGeometricBrownianMotionEquityModel,
                    (μ = [0.05, 0.06], A = [0.2 0.0; 0.05 0.15])) isa MyMultipleAssetGeometricBrownianMotionEquityModel
        @test build(MyOrnsteinUhlenbeckModel,
                    (μ = (x, t) -> 1.0, σ = (x, t) -> 0.1, θ = (x, t) -> 2.0)) isa MyOrnsteinUhlenbeckModel
        @test build(MyHestonModel, (μ = (x, t) -> 0.05, κ = (x, t) -> 3.0, θ = (x, t) -> 0.04,
                                    ξ = (x, t) -> 0.1, Σ = [1.0 0.0; 0.0 1.0])) isa MyHestonModel
        # NOTE: docstring says uₒ::Array{Float64,1}, but build computes Xₒ = B̂*uₒ which requires a scalar.
        # Scalar keeps this green; the docstring/implementation mismatch is a Task 10 suspect.
        @test build(MySisoLegSHippoModel,
                    (number_of_hidden_states = 4, Δt = 0.1, uₒ = 1.0, C = ones(4))) isa MySisoLegSHippoModel
    end

    @testset "portfolio problems + SIM" begin
        @test build(MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem,
                    (Σ = [0.04 0.0; 0.0 0.09], μ = [0.1, 0.15], bounds = [0.0 1.0; 0.0 1.0],
                     R = 0.1, initial = [0.5, 0.5])) isa MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem
        @test build(MyMarkowitzRiskyRiskFreePortfolioChoiceProblem,
                    (Σ = [0.04 0.0; 0.0 0.09], μ = [0.1, 0.15], bounds = [0.0 1.0; 0.0 1.0],
                     R = 0.1, initial = [0.5, 0.5], risk_free_rate = 0.03)) isa MyMarkowitzRiskyRiskFreePortfolioChoiceProblem
        @test build(MySharpeRatioPortfolioChoiceProblem,
                    (Σ = [0.04 0.0; 0.0 0.09], risk_free_rate = 0.03, α = [0.01, 0.005],
                     β = [1.2, 0.8], gₘ = 0.08, τ = 1.0)) isa MySharpeRatioPortfolioChoiceProblem
        @test build(MySingleIndexModel, (α = 0.01, β = 1.1, r = 0.03, ϵ = Normal(0.0, 0.05))) isa MySingleIndexModel
    end

    @testset "Markov / bandits / RL / Wolfram" begin
        T2 = [0.9 0.1; 0.2 0.8]; E2 = [0.8 0.2; 0.3 0.7]
        @test build(MyHiddenMarkovModel, (states = [1, 2], T = T2, E = E2)) isa MyHiddenMarkovModel
        @test build(MyHiddenMarkovModelWithJumps,
                    (states = [1, 2], T = T2, E = E2, ϵ = 0.05, λ = 2.0)) isa MyHiddenMarkovModelWithJumps
        @test build(MyEpsilonSamplingBanditModel,
                    (α = ones(3), β = ones(3), K = 3, ϵ = 0.1)) isa MyEpsilonSamplingBanditModel

        df = DataFrame(volume_weighted_average_price = [100.0, 101.0])
        tickerdata = Dict("A" => df, "B" => df)
        world = (args...) -> 0.0
        @test build(MyTickerPickerWorldModel,
                    (tickers = ["A", "B"], data = tickerdata, risk_free_rate = 0.05, world = world,
                     Δt = 1.0 / 252.0, buffersize = 10)) isa MyTickerPickerWorldModel
        @test build(MyTickerPickerRiskAwareWorldModel,
                    (tickers = ["A", "B"], data = tickerdata, risk_free_rate = 0.05, world = world,
                     Δt = 1.0 / 252.0, buffersize = 10,
                     risk = Dict("A" => 0.1, "B" => 0.2))) isa MyTickerPickerRiskAwareWorldModel
        @test build(MyTickerPickerSIMRiskAwareWorldModel,
                    (tickers = ["A", "B"], risk_free_rate = 0.05, world = world, Δt = 1.0 / 252.0,
                     Ḡₘ = 0.08, parameters = Dict("A" => (α = 0.01, β = 1.1), "B" => (α = 0.0, β = 0.9)),
                     buffersize = 10, risk = Dict("A" => 0.1, "B" => 0.2))) isa MyTickerPickerSIMRiskAwareWorldModel

        @test build(MyWolframRuleQLearningAgentModel,
                    (states = [1, 2], actions = [1, 2], γ = 0.95, α = 0.1, Q = zeros(2, 2))) isa MyWolframRuleQLearningAgentModel
        r30 = build(MyOneDimensionalElementarWolframRuleModel, (index = 30, colors = 2, radius = 3))
        @test r30 isa MyOneDimensionalElementarWolframRuleModel
        @test length(r30.rule) == 8
        @test build(MyOneDimensionalTotalisticWolframRuleModel,
                    (index = 5, colors = 2, radius = 3)) isa MyOneDimensionalTotalisticWolframRuleModel
        rule2d = build(MyTwoDimensionalTotalisticWolframRuleModel, (index = 5, colors = 2, radius = 8))
        @test rule2d isa MyTwoDimensionalTotalisticWolframRuleModel
        @test build(MyPeriodicRectangularGridWorldModel,
                    (nrows = 3, ncols = 3, rewards = Dict((1, 1) => 10.0))) isa MyPeriodicRectangularGridWorldModel
        @test build(MyWolframGridWorldModel,
                    (number_of_states = 4, data = Dict(1 => [1, 0, 1, 0]),
                     policymap = Dict(0.0 => 1), world = (args...) -> (1, 0.0))) isa MyWolframGridWorldModel
        gw = build(MyTwoDimensionalFixedBoundaryGridWorld, (width = 3, height = 3))
        @test gw isa MyTwoDimensionalFixedBoundaryGridWorld
        @test build(MySimpleTwoDimensionalAgentModel, gw,
                    (index = 5, rule = rule2d)) isa MySimpleTwoDimensionalAgentModel   # index 5 = center of 3×3
    end

    @testset "data loaders" begin
        train = MyTrainingMarketDataSet()
        @test train isa Dict{String, Any}
        @test haskey(train, "dataset")
        dataset = train["dataset"]
        @test haskey(dataset, "AAPL")
        @test nrow(dataset["AAPL"]) > 2000

        test = MyTestingMarketDataSet()
        @test test isa Dict{String, Any}
        @test haskey(test, "dataset")
        test_dataset = test["dataset"]
        @test haskey(test_dataset, "AAPL")

        chain = MyOptionsChainDataSet(ticker = "amd")
        @test chain isa NamedTuple
        @test haskey(chain.metadata, "DTE")
        @test chain.data isa DataFrame
        @test nrow(chain.data) > 0
    end
end
