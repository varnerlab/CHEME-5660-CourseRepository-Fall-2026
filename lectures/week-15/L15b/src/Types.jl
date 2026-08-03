"""
    AbstractWorldModel

Abstract supertype for world models that generate rewards given an action and environment state.
"""
abstract type AbstractWorldModel end

"""
    AbstractSamplingModel

Abstract supertype for bandit-style sampling models that select actions over time.
"""
abstract type AbstractSamplingModel end

"""
    AbstractInvestorContextModel

Abstract supertype for investor context models that combine preferences, risk, and market data.
"""
abstract type AbstractInvestorContextModel end

"""
    mutable struct MyTickerPickerSIMRiskAwareWorldModel <: AbstractWorldModel

The `MyTickerPickerSIMRiskAwareWorldModel` mutable struct represents a world model for a ticker picker problem 
that is risk-aware and uses a single index model (SIM) for returns.

### Required fields
- `tickers::Array{String,1}`: An array of ticker symbols that we explore
- `risk_free_rate::Float64`: The risk-free rate of return in the world (assumed constant)
- `world::Function`: A function that represents the world model. The function takes an action `a`, data about the world, and returns the reward `r` for taking action `a`.
- `Δt::Float64`: The time step size in the world model
- `Ḡₘ::Float64`: The expected excess market return (market factor)
- `parameters::Dict{String, NamedTuple}`: A dictionary that holds the single index model parameters for each ticker symbol
- `buffersize::Int64`: The size of the buffer used in the world model
- `risk::Dict{String, Float64}`: A dictionary that holds the risk measure for each ticker symbol
"""
mutable struct MyTickerPickerSIMRiskAwareWorldModel <: AbstractWorldModel

    # data -
    tickers::Array{String,1}
    risk_free_rate::Float64
    world::Function
    Δt::Float64
    Ḡₘ::Float64 # expected excess market return (market factor)
    parameters::Dict{String, NamedTuple} # single index model parameters for each ticker
    buffersize::Int64 # how many days to use in the buffer
    risk::Dict{String, Float64}

    # constructor -
    MyTickerPickerSIMRiskAwareWorldModel() = new();
end

"""
    mutable struct MyEpsilonSamplingBanditModel <: AbstractSamplingModel

The `MyEpsilonSamplingBanditModel` mutable struct represents a multi-armed bandit model that uses epsilon-sampling for exploration.

### Required fields
- `α::Array{Float64,1}`: A vector holding the number of successful pulls for each arm. Each element in the vector represents the number of successful pulls for a specific arm.
- `β::Array{Float64,1}`: A vector holding the number of unsuccessful pulls for each arm. Each element in the vector represents the number of unsuccessful pulls for a specific arm.
- `K::Int64`: The number of arms in the bandit model
- `ϵ::Float64`: The exploration parameter. A value of `0.0` indicates no exploration, and a value of `1.0` indicates full exploration.
"""
mutable struct MyEpsilonSamplingBanditModel <: AbstractSamplingModel

    # data -
    α::Array{Float64,1}
    β::Array{Float64,1}
    K::Int64

    # constructor -
    MyEpsilonSamplingBanditModel() = new();
end

"""
    mutable struct MyInvestorMarketContextModel <: AbstractInvestorContextModel

Investor context that blends ticker-picker preferences with a single-index model (SIM) for allocating
a fixed budget across tickers.

### Fields
- `B::Float64`: Total budget available (USD).
- `tickers::Array{String,1}`: Ordered ticker symbols.
- `marketdata::Dict{String, DataFrame}`: Historical price data keyed by ticker.
- `preferences::Dict{Symbol, DataFrame}`: Ticker-picker preference tables keyed by mood.
- `Ḡₘ::Float64`: Expected excess market return (market factor).
- `risk_free_rate::Float64`: Annual risk-free rate.
- `singleindexmodel_parameters::Dict{String, NamedTuple}`: SIM parameters per ticker.
- `ξ::Float64`: Weight given to ticker-picker preferences in the allocation rule.
- `mood::Symbol`: Investor mood controlling which preference table is used.
- `ϵ::Float64`: Minimum number of shares to buy/sell for non-preferred assets.
"""
mutable struct MyInvestorMarketContextModel <: AbstractInvestorContextModel

    # data -
    B::Float64 # total budget for investment (in USD)
    tickers::Array{String,1} # array of ticker symbols
    marketdata::Dict{String, DataFrame} # market data for the tickers
    preferences::Dict{Symbol, DataFrame} # ticker-picker preferences
    Ḡₘ::Float64 # expected excess market return (market factor)
    risk_free_rate::Float64 # risk-free rate of return
    singleindexmodel_parameters::Dict{String, NamedTuple} # single index model parameters for each ticker
    ξ::Float64 # weight of the ticker-picker preference in the investor context model
    mood::Symbol # mood of the investor (:optimistic, :neutral, :pessimistic)
    ϵ::Float64 # minimum number of shares to buy/sell per trade

    # constructor -
    MyInvestorMarketContextModel() = new();
end

"""
    mutable struct MySimpleRobotInvestorContextModel <: AbstractInvestorContextModel

Lightweight investor context used by a robot trader that relies on a precomputed market factor series
and SIM parameters to allocate shares.

### Fields
- `B::Float64`: Total budget available (USD).
- `tickers::Array{String,1}`: Ordered ticker symbols.
- `marketfactor::Array{Float64,1}`: Market factor value at each time step.
- `marketdata::Array{Float64,2}`: Price matrix (rows: time, columns: tickers, first column is time).
- `singleindexmodel_parameters::Dict{String, NamedTuple}`: SIM parameters per ticker.
- `λ::Float64`: Risk-aversion exponent applied to beta.
- `Δt::Float64`: Time step size (years).
- `ϵ::Float64`: Minimum number of shares to hold for non-preferred assets.
"""
mutable struct MySimpleRobotInvestorContextModel <: AbstractInvestorContextModel

    # data -
    B::Float64 # total budget for investment (in USD)
    tickers::Array{String,1} # array of ticker symbols
    marketfactor::Array{Float64,1} # market factor at current time step
    marketdata::Array{Float64,2} # market data matrix (rows: time steps, columns: tickers, first column is time)
    singleindexmodel_parameters::Dict{String, NamedTuple} # single index model parameters for each ticker
    λ::Float64 # risk aversion parameter
    Δt::Float64 # time step size
    ϵ::Float64 # minimum number of shares to buy for non-preferred asset 
    
    # constructor -
    MySimpleRobotInvestorContextModel() = new();
end
