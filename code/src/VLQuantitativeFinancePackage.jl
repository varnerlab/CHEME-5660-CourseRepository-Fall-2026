module VLQuantitativeFinancePackage

    # include -
    include("Include.jl")

    # export abstract types -
    export AbstractAssetModel
    export AbstractEquityPriceTreeModel
    export AbstractInterestRateTreeModel
    export AbstractContractModel
    export AbstractTreasuryDebtSecurity
    export AbstractCompoundingModel
    export AbstractStochasticChoiceProblem
    export AbstractMarkovModel
    export AbstractSamplingModel
    export AbstractWorldModel
    export AbstractPolicyModel
    export AbstractLearningModel
    export AbstractAgentModel

    # export concrete types -
    export MyCRRLatticeNodeModel, MyGeometricBrownianMotionEquityModel, MyMultipleAssetGeometricBrownianMotionEquityModel, MyAdjacencyBasedCRREquityPriceTree, MyLongstaffSchwartzContractPricingModel, MyBlackScholesContractPricingModel
    export MyEuropeanCallContractModel, MyEuropeanPutContractModel, MyAmericanPutContractModel, MyAmericanCallContractModel, MyEquityModel
    export MyUSTreasuryZeroCouponBondModel, MyUSTreasuryCouponSecurityModel, DiscreteCompoundingModel, ContinuousCompoundingModel
    export MySymmetricBinaryInterestRateLatticeModel, MyBinaryInterestRateLatticeNodeModel
    export MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem, MyMarkowitzRiskyRiskFreePortfolioChoiceProblem, MySharpeRatioPortfolioChoiceProblem
    export MyBiomialLatticeEquityNodeModel, MyBinomialEquityPriceTree
    export MySingleIndexModel, AbstractReturnModel
    export RealWorldBinomialProbabilityMeasure, RiskNeutralBinomialProbabilityMeasure, RealWorldGeneralProbabilityMeasure, AbstractProbabilityMeasure
    export MyOrnsteinUhlenbeckModel, MyHestonModel, EulerMaruyamaMethod
    export MySisoLegSHippoModel, estimate_hippo_parameters, prediction
    export MyGeneralAdjacencyRecombiningCommodityPriceTree
    
    # Markov models, MDPs, Bandits types and methods -
    export MyHiddenMarkovModel,MyHiddenMarkovModelWithJumps,MyPeriodicRectangularGridWorldModel
    export MyEpsilonSamplingBanditModel, MyTickerPickerWorldModel, MyTickerPickerRiskAwareWorldModel, MyTickerPickerSIMRiskAwareWorldModel
    export preference

    # wolfram rules etc
    export MyOneDimensionalTotalisticWolframRuleModel, MyOneDimensionalElementarWolframRuleModel
    export MyTwoDimensionalElementaryWolframRuleModel, MyTwoDimensionalTotalisticWolframRuleModel, MyElementaryWolframRuleModel
    export MyWolframRuleQLearningAgentModel, MyWolframGridWorldModel, MyTwoDimensionalFixedBoundaryGridWorld, MySimpleTwoDimensionalAgentModel, MyElementaryWolframRuleModel
    
    # Base functions -
    export log_growth_matrix

    # export functions/methods
    export build, payoff, profit, premium, sample, sample_endpoint, price, strip, populate, solve, YTM, typicalprice, discount
    export estimate_implied_volatility
    export expectation, variance
    
    # export the greeks -
    export theta, delta, gamma, vega, rho

    # data functions -
    export MyTrainingMarketDataSet;
    export MyTestingMarketDataSet;
    export MyOptionsChainDataSet;
end
