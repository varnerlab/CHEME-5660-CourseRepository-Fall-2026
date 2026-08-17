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

    # limit-order-book types -
    export OrderSide, Buy, Sell, TimeInForce, GTC, IOC, FOK
    export MyLimitOrder, MyMarketOrder, MyOrderBookFill
    export MyOrderBookExecutionReport, MyOrderBookLevel, MyOrderBookSnapshot, MyOrderBook
    
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
    export estimate_sim, bootstrap_sim, propagate_sim_uncertainty
    export sim_portfolio_inputs, build_sim_covariance, minimum_variance_weights, covariance_from_volatility
    export hill_tail_index, sample_autocorrelation, stylized_facts_report
    export simulate_rebalanced_path, evaluate_rebalancing_scenario
    export adaptive_preference_weights, allocate_cobb_douglas, allocate_ces
    export compute_ema, adaptive_target_weights, run_rebalancing_engine, run_utility_engine
    export realized_scorecard, ensemble_scorecard
    export ewls_init, ewls_update!, ewls_path
    export evaluate_validation_gates, route_portfolio_event

    # limit-order-book functions -
    export submit_order!, cancel_order!, clear_order_book!
    export order_book_depth, order_book_snapshot, validate_order_book
    export best_quote_ticks, best_quotes, midpoint_ticks, midprice, bid_ask_spread
    export displayed_volume, resting_order_count, account_orders
    export order_book_imbalance, microprice
    export ticks_to_price, price_to_ticks
    export execution_vwap_ticks, execution_vwap, executed_notional, implementation_shortfall
    
    # export the greeks -
    export theta, delta, gamma, vega, rho

    # data functions -
    export MyTrainingMarketDataSet;
    export MyTestingMarketDataSet;
    export MyOptionsChainDataSet;
    export MySIMCalibration, MyCurrentPrices, MyAdaptivePortfolioCourseData
end
