"""
`VLQuantitativeFinancePackage` provides the teaching models, pricing routines,
simulation tools, and optimization helpers used by CHEME 5660.
"""
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
    export MySIMParameterEstimate, MyCobbDouglasChoiceProblem, MyCESChoiceProblem, MyEWLSState
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

    # adaptive portfolio functions -
    export sim_portfolio_inputs, build_sim_covariance, minimum_variance_weights, covariance_from_volatility
    export simulate_rebalanced_path, evaluate_rebalancing_scenario
    export adaptive_preference_weights, allocate_cobb_douglas, allocate_ces
    export compute_ema, adaptive_target_weights, run_rebalancing_engine
    export ewls_init, ewls_update!, ewls_path
    export evaluate_validation_gates, route_portfolio_event
    
    # export the greeks -
    export theta, delta, gamma, vega, rho

    # data functions -
    export MyTrainingMarketDataSet;
    export MyTestingMarketDataSet;
    export MyOptionsChainDataSet;
    export MySIMCalibration, MyCurrentPrices, MyAdaptivePortfolioCourseData
end
