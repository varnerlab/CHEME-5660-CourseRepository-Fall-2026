abstract type AbstractBanditAlgorithmModel end
abstract type AbstractBanditProblemContextModel end
abstract type AbstractSimpleChoiceProblem end
abstract type AbstractReturnModel end

"""
    mutable MySimpleCobbDouglasChoiceProblem

A mutable struct that defines a simple Cobb-Douglas choice problem. 
The problem is defined by the following fields:

### Fields
- `γ::Array{Float64,1}`: The Cobb-Douglas utility function exponents. One exponent for each object.
- `c::Array{Float64,1}`: The unit cost of each objects.
- `B::Float64`: The budget that we have to spend on the collection of objects.
- `bounds::Array{Float64,2}`: The bounds on the objects that we can purchase. First column is the lower bound, second column is the upper bound.
- `initial::Array{Float64,1}`: The initial guess for the solution.

"""
mutable struct MySimpleCobbDouglasChoiceProblem <: AbstractSimpleChoiceProblem

    # data -
    γ::Array{Float64,1}
    c::Array{Float64,1}
    B::Float64
    bounds::Array{Float64,2}
    initial::Array{Float64,1}

    # constructor
    MySimpleCobbDouglasChoiceProblem() = new();
end

mutable struct MyEpsilonGreedyAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyAlgorithmModel() = new();
end

mutable struct MyEpsilonGreedyDynamicAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyDynamicAlgorithmModel() = new();
end

mutable struct MyEpsilonGreedyStaticNoiseAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyStaticNoiseAlgorithmModel() = new();
end

mutable struct MyEpsilonGreedyDynamicNoiseAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyDynamicNoiseAlgorithmModel() = new();
end


mutable struct MyBanditPortfolioAllocationContextModel <: AbstractBanditProblemContextModel

    # data -
    γ::Array{Float64,1} # investors preference for each category of goods
    Sₒ::Array{Float64,1} # share price at which we can purchase the asset 
    bounds::Array{Float64,2} # bounds on the assets that we can purchase
    B::Float64 # budget that we have to spend on the collection of assets
    nₒ::Array{Float64,1} # initial guess for the solution
    number_of_assets::Int64 # number of assets that we can purchase
    

    # constructor -
    MyBanditPortfolioAllocationContextModel() = new();
end

mutable struct MyDynamicBanditPortfolioAllocationContextModel <: AbstractBanditProblemContextModel

    # data -
    singleindexmodels::Dict{String, NamedTuple} # single index models for each asset
    dataset::Dict{String, DataFrame} # dataset for each asset
    tickers::Array{String,1} # tickers for each asset
    bounds::Array{Float64,2} # bounds on the assets that we can purchase
    number_of_assets::Int64 # number of assets that we can purchase
    B::Float64 # budget that we have to spend on the collection of assets
    nₒ::Array{Float64,1} # initial guess for the solution
    X̄::Array{Float64,2} # inv(X^T*X)*X^T
    number_of_samples_to_draw::Int64 # number of samples needed by the error model -
    μₒ::Array{Float64,1} # initial guess for the mean of the error model
    R̄ₘ::Float64 # average return of the market (to use in the SIM)

    # constructor -
    MyDynamicBanditPortfolioAllocationContextModel() = new();
end

struct MyBanditPortfolioModel

    # data -
    utility::Float64 # utility of the portfolio
    n::Array{Float64,1} # share array
    a::Array{Int,1} # action array
    converged::Bool # has the model converged?   

    # constructor -
    MyBanditPortfolioModel(U,n,a, converged) = new(U,n, a, converged);
end