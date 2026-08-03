# Quick script to check type hierarchy and build methods

# All exported types from VLQuantitativeFinancePackage.jl
exported_types = [
    # Line 22
    "MyCRRLatticeNodeModel", "MyGeometricBrownianMotionEquityModel", 
    "MyMultipleAssetGeometricBrownianMotionEquityModel", "MyAdjacencyBasedCRREquityPriceTree", 
    "MyLongstaffSchwartzContractPricingModel", "MyBlackScholesContractPricingModel",
    # Line 23
    "MyEuropeanCallContractModel", "MyEuropeanPutContractModel", "MyAmericanPutContractModel", 
    "MyAmericanCallContractModel", "MyEquityModel",
    # Line 24
    "MyUSTreasuryZeroCouponBondModel", "MyUSTreasuryCouponSecurityModel",
    "DiscreteCompoundingModel", "ContinuousCompoundingModel",
    # Line 25
    "MySymmetricBinaryInterestRateLatticeModel", "MyBinaryInterestRateLatticeNodeModel",
    # Line 26
    "MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem", 
    "MyMarkowitzRiskyRiskFreePortfolioChoiceProblem", 
    "MySharpeRatioPortfolioChoiceProblem",
    # Line 27
    "MyBiomialLatticeEquityNodeModel", "MyBinomialEquityPriceTree",
    # Line 28
    "MySingleIndexModel",
    # Line 30
    "MyOrnsteinUhlenbeckModel", "MyHestonModel", "EulerMaruyamaMethod",
    # Line 31
    "MySisoLegSHippoModel",
    # Line 32
    "MyGeneralAdjacencyRecombiningCommodityPriceTree",
    # Line 35
    "MyHiddenMarkovModel", "MyHiddenMarkovModelWithJumps", "MyPeriodicRectangularGridWorldModel",
    # Line 36
    "MyEpsilonSamplingBanditModel", "MyTickerPickerWorldModel", 
    "MyTickerPickerRiskAwareWorldModel", "MyTickerPickerSIMRiskAwareWorldModel",
    # Line 40-42
    "MyOneDimensionalTotalisticWolframRuleModel", "MyOneDimensionalElementarWolframRuleModel",
    "MyTwoDimensionalElementaryWolframRuleModel", "MyTwoDimensionalTotalisticWolframRuleModel",
    "MyElementaryWolframRuleModel", "MyWolframRuleQLearningAgentModel",
    "MyWolframGridWorldModel", "MyTwoDimensionalFixedBoundaryGridWorld", 
    "MySimpleTwoDimensionalAgentModel"
]

puts exported_types.length
