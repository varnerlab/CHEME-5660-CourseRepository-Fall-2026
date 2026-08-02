# Equity Securities
This should update now.

## Computing returns
Fill me in.

```@docs
VLQuantitativeFinancePackage.log_growth_matrix
VLQuantitativeFinancePackage.typicalprice
```

## Lattice Models
```@docs
VLQuantitativeFinancePackage.RealWorldBinomialProbabilityMeasure
VLQuantitativeFinancePackage.RiskNeutralBinomialProbabilityMeasure
VLQuantitativeFinancePackage.MyBinomialEquityPriceTree
VLQuantitativeFinancePackage.MyBiomialLatticeEquityNodeModel
VLQuantitativeFinancePackage.build(model::Type{MyBinomialEquityPriceTree}, data::NamedTuple)
VLQuantitativeFinancePackage.populate(model::MyBinomialEquityPriceTree; Sₒ::Float64 = 100.0, h::Int64 = 1)
VLQuantitativeFinancePackage.sample(model::MyBinomialEquityPriceTree, L::Int64; 
    number_of_paths::Int64 = 100)
VLQuantitativeFinancePackage.RealWorldGeneralProbabilityMeasure
VLQuantitativeFinancePackage.MyGeneralAdjacencyRecombiningCommodityPriceTree
VLQuantitativeFinancePackage.build(model::Type{MyGeneralAdjacencyRecombiningCommodityPriceTree}, data::NamedTuple)
VLQuantitativeFinancePackage.populate(model::MyGeneralAdjacencyRecombiningCommodityPriceTree, 
    price::Float64, Δ::Array{Float64,1})
```

### Short cut syntax for data-driven binomial trees
We provide a short-cut syntax to estimate the values of the $(u, d, p)$ parameters of a binomial tree model using historical data. The short-cut syntax allows the user to specify a probability measure, the time step in the data, and the historical growth rate data required to estimate the parameters.

For example, to estimate the expected $(\bar{u}, \bar{d}, \bar{p})$ parameters of using historical growth data for a single-asset with time-step $\Delta{t}$ assuming a real-world probability measure, the user can use the following code:

```julia
(ū,d̄,p̄) = (RealWorldBinomialProbabilityMeasure())(growth_rate_array; Δt = Δt);
```

## Geometric Brownian Motion
```@docs
VLQuantitativeFinancePackage.MyGeometricBrownianMotionEquityModel
VLQuantitativeFinancePackage.MyMultipleAssetGeometricBrownianMotionEquityModel
VLQuantitativeFinancePackage.build(model::Type{MyGeometricBrownianMotionEquityModel}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyMultipleAssetGeometricBrownianMotionEquityModel}, data::NamedTuple)
VLQuantitativeFinancePackage.sample(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)
VLQuantitativeFinancePackage.sample(model::MyMultipleAssetGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)
VLQuantitativeFinancePackage.sample_endpoint(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)
VLQuantitativeFinancePackage.expectation(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple)
VLQuantitativeFinancePackage.variance(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple)
```

## Advanced Stochastic Pricing and Return Models
```@docs
VLQuantitativeFinancePackage.EulerMaruyamaMethod
VLQuantitativeFinancePackage.MyOrnsteinUhlenbeckModel
VLQuantitativeFinancePackage.MyHestonModel
VLQuantitativeFinancePackage.build(model::Type{MyOrnsteinUhlenbeckModel}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyHestonModel}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::AbstractAssetModel, tspan::NamedTuple,
    initialconditions::AbstractArray; method::AbstractStochasticSolverModel = EulerMaruyamaMethod(), 
    N::Int64 = 100)
```

## Structured State-Space Models
Update this section with some groooovy text.

```@docs
VLQuantitativeFinancePackage.MySisoLegSHippoModel
VLQuantitativeFinancePackage.build(model::Type{MySisoLegSHippoModel}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::MySisoLegSHippoModel, tspan::NamedTuple, signal::Array{Float64})
VLQuantitativeFinancePackage.prediction(model::MySisoLegSHippoModel, tspan::NamedTuple, signal::Array{Float64,1};
    S::Int64 = 10, B::Float64 = 40.0, α::Float64 = 0.25, β::Float64 = 0.10)
VLQuantitativeFinancePackage.estimate_hippo_parameters(model::MySisoLegSHippoModel, tspan::NamedTuple, 
    signal::Array{Float64}; method = LBFGS())
```