
"""
    function build(modeltype::Type{MyTickerPickerSIMRiskAwareWorldModel}, data::NamedTuple) -> MyTickerPickerSIMRiskAwareWorldModel

This `build` method constructs an instance of the [`MyTickerPickerSIMRiskAwareWorldModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyTickerPickerSIMRiskAwareWorldModel}`: The type of model to build, in this case, the [`MyTickerPickerSIMRiskAwareWorldModel`](@ref) type.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `tickers::Array{String,1}`: An array of ticker symbols that we explore
- `data::Dict{String, DataFrame}`: A dictionary that holds the data for each ticker symbol
- `horizon::Int64`: The number of days to look ahead for the ticker picker
- `buffersize::Int64`: The size of the buffer for storing the data
"""
function build(modeltype::Type{MyTickerPickerSIMRiskAwareWorldModel}, data::NamedTuple)::MyTickerPickerSIMRiskAwareWorldModel

    # initialize -
    model = modeltype(); # build an empty model

    # Fields required in data NamedTuple:
    # tickers::Array{String,1}
    # risk_free_rate::Float64
    # world::Function
    # Δt::Float64
    # Ḡₘ::Float64 # expected excess market return (market factor)
    # parameters::Dict{String, NamedTuple} # single index model parameters for each ticker
    # buffersize::Int64 # how many days to use in the buffer
    # risk::Dict{String, Float64}

    # set the data on the object
    model.tickers = data.tickers;
    model.buffersize = data.buffersize;
    model.risk = data.risk;
    model.Ḡₘ = data.Ḡₘ;
    model.risk_free_rate = data.risk_free_rate;
    model.world = data.world;
    model.Δt = data.Δt;
    model.parameters = data.parameters;
    model.buffersize = data.buffersize;

    # return
    return model;
end

"""
    function build(modeltype::Type{MyEpsilonSamplingBanditModel}, data::NamedTuple) -> MyEpsilonSamplingBanditModel

This `build` method constructs an instance of the [`MyEpsilonSamplingBanditModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyEpsilonSamplingBanditModel}`: The type of model to build, in this case, the [`MyEpsilonSamplingBanditModel`](@ref) type.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `α::Array{Float64,1}`: A vector holding the number of successful pulls for each arm. Each element in the vector represents the number of successful pulls for a specific arm.
- `β::Array{Float64,1}`: A vector holding the number of unsuccessful pulls for each arm. Each element in the vector represents the number of unsuccessful pulls for a specific arm.
- `K::Int64`: The number of arms in the bandit model
- `ϵ::Float64`: The exploration parameter. A value of `0.0` indicates no exploration, and a value of `1.0` indicates full exploration.

"""
function build(modeltype::Type{MyEpsilonSamplingBanditModel}, data::NamedTuple)::MyEpsilonSamplingBanditModel

    # initialize -
    model = modeltype(); # build an empty model

    # set the data on the object
    model.α = data.α;
    model.β = data.β;
    model.K = data.K;

    # return
    return model;
end

"""
    build(modeltype::Type{MyInvestorMarketContextModel}, data::NamedTuple) -> MyInvestorMarketContextModel

Construct an [`MyInvestorMarketContextModel`](@ref) using market data, ticker-picker preferences, and
single-index model parameters supplied in a `NamedTuple`.

### Arguments
- `modeltype::Type{MyInvestorMarketContextModel}`: Concrete type to instantiate.
- `data::NamedTuple`: Source data used to populate the model. Must include:
  - `B::Float64`: Total budget (USD)
  - `tickers::Array{String,1}`: Ordered ticker symbols under consideration
  - `marketdata::Dict{String, DataFrame}`: Historical price data keyed by ticker
  - `preferences::Dict{Symbol, DataFrame}`: Ticker-picker preference tables keyed by mood
  - `Ḡₘ::Float64`: Expected excess market return
  - `risk_free_rate::Float64`: Annual risk-free rate
  - `singleindexmodel_parameters::Dict{String, NamedTuple}`: SIM parameters per ticker
  - `ξ::Float64`: Weight applied to the ticker-picker preference score
  - `mood::Symbol`: Investor mood (:optimistic, :neutral, :pessimistic)
  - `ϵ::Float64`: Minimum number of shares to buy/sell per trade

### Returns
- `MyInvestorMarketContextModel`: Model instance populated with the supplied data.
"""
function build(modeltype::Type{MyInvestorMarketContextModel}, data::NamedTuple)::MyInvestorMarketContextModel

    # initialize -
    model = modeltype(); # build an empty model

    # Fields required in data NamedTuple:
    # B::Float64 # total budget for investment (in USD)
    # tickers::Array{String,1} # array of ticker symbols
    # marketdata::Dict{String, DataFrame} # market data for the tickers
    # preferences::Dict{Symbol, DataFrame} # ticker-picker preferences
    # Ḡₘ::Float64 # expected excess market return (market factor)
    # risk_free_rate::Float64 # risk-free rate of return
    # singleindexmodel_parameters::Dict{String, NamedTuple} # single index model parameters for each ticker
    # ξ::Float64 # weight of the ticker-picker preference in the investor context model

    # set the data on the object
    model.B = data.B;
    model.tickers = data.tickers;
    model.marketdata = data.marketdata;
    model.preferences = data.preferences;
    model.Ḡₘ = data.Ḡₘ;
    model.risk_free_rate = data.risk_free_rate;
    model.singleindexmodel_parameters = data.singleindexmodel_parameters;
    model.ξ = data.ξ;
    model.mood = data.mood;
    model.ϵ = data.ϵ;

    # return
    return model;
end

"""
    build(modeltype::Type{MySimpleRobotInvestorContextModel}, data::NamedTuple) -> MySimpleRobotInvestorContextModel

Build a [`MySimpleRobotInvestorContextModel`](@ref) using precomputed market factors and SIM parameters
for a simplified robot investor scenario.

### Arguments
- `modeltype::Type{MySimpleRobotInvestorContextModel}`: Concrete type to instantiate.
- `data::NamedTuple`: Source data used to populate the model. Must include:
  - `B::Float64`: Total budget (USD)
  - `tickers::Array{String,1}`: Ordered ticker symbols under consideration
  - `marketdata::Array{Float64,2}`: Price matrix (rows: time, columns: tickers, col1 is time)
  - `singleindexmodel_parameters::Dict{String, NamedTuple}`: SIM parameters per ticker
  - `λ::Float64`: Risk-aversion exponent applied to beta
  - `Δt::Float64`: Time step (years)
  - `marketfactor::Array{Float64,1}`: Market factor time series aligned with `marketdata`
  - `ϵ::Float64`: Minimum number of shares to hold for non-preferred assets

### Returns
- `MySimpleRobotInvestorContextModel`: Model instance populated with the supplied data.
"""
function build(modeltype::Type{MySimpleRobotInvestorContextModel}, data::NamedTuple)::MySimpleRobotInvestorContextModel

    # initialize -
    model = modeltype(); # build an empty model

    # Fields required in data NamedTuple:
    # B::Float64 # total budget for investment (in USD)
    # tickers::Array{String,1} # array of ticker symbols
    # marketdata::Array{Float64,2} # market data matrix (rows: time steps, columns: tickers, first column is time)
    # singleindexmodel_parameters::Dict{String, NamedTuple} # single index model parameters for each ticker
    # λ::Float64 # risk aversion parameter
    # Δt::Float64 # time step size (units: years)

    # set the data on the object
    model.B = data.B;
    model.tickers = data.tickers;
    model.marketdata = data.marketdata;
    model.singleindexmodel_parameters = data.singleindexmodel_parameters;
    model.λ = data.λ;
    model.Δt = data.Δt;
    model.marketfactor = data.marketfactor;
    model.ϵ = data.ϵ;

    # return
    return model;
end
