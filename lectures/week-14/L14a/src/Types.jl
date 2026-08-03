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

"""
    mutable MyEpsilonGreedyAlgorithmModel < : AbstractBanditAlgorithmModel

A mutable struct that defines the epsilon-greedy bandit algorithm model.

### Fields
- `K::Int64`: The number of arms in each category.
- `α::Float64`: The learning rate.
"""
mutable struct MyEpsilonGreedyAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyAlgorithmModel() = new();
end

"""
    mutable MyEpsilonGreedyDynamicAlgorithmModel < : AbstractBanditAlgorithmModel

A mutable struct that defines the dynamic epsilon-greedy bandit algorithm model.

### Fields
- `K::Int64`: The number of arms in each category.
- `α::Float64`: The learning rate.
"""
mutable struct MyEpsilonGreedyDynamicAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyDynamicAlgorithmModel() = new();
end

"""
    mutable MyEpsilonGreedyStaticNoiseAlgorithmModel < : AbstractBanditAlgorithmModel

A mutable struct that defines the static noise epsilon-greedy bandit algorithm model.

### Fields
- `K::Int64`: The number of arms in each category.
- `α::Float64`: The learning rate.
"""
mutable struct MyEpsilonGreedyStaticNoiseAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyStaticNoiseAlgorithmModel() = new();
end

"""
    mutable MyEpsilonGreedyDynamicNoiseAlgorithmModel < : AbstractBanditAlgorithmModel

A mutable struct that defines the dynamic noise epsilon-greedy bandit algorithm model.

### Fields
- `K::Int64`: The number of arms in each category.
- `α::Float64`: The learning rate.
"""
mutable struct MyEpsilonGreedyDynamicNoiseAlgorithmModel <: AbstractBanditAlgorithmModel

    # data -
    K::Int64 # number of arms in each category
    α::Float64 # learning rate

    # constructor -
    MyEpsilonGreedyDynamicNoiseAlgorithmModel() = new();
end

"""
    mutable MyBanditPortfolioAllocationContextModel < : AbstractBanditProblemContextModel
A mutable struct that defines the bandit portfolio allocation context model.

### Fields
- `γ::Array{Float64,1}`: Investors preference for each category of goods.
- `Sₒ::Array{Float64,1}`: Cost of each good.
- `bounds::Array{Float64,2}`: Bounds on the assets that we can purchase.
- `B::Float64`: Budget that we have to spend on the collection of assets.
- `nₒ::Array{Float64,1}`: Initial guess for the solution.
- `number_of_assets::Int64`: Number of assets that we can purchase.
"""
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

"""
    mutable MyDynamicBanditPortfolioAllocationContextModel < : AbstractBanditProblemContextModel

A mutable struct that defines the dynamic bandit portfolio allocation context model.

### Fields
- `singleindexmodels::Dict{String, NamedTuple}`: Single index models for each asset.
- `dataset::Dict{String, DataFrame}`: Dataset for each asset.
- `tickers::Array{String,1}`: Tickers for each asset.
- `bounds::Array{Float64,2}`: Bounds on the assets that we can purchase.
- `number_of_assets::Int64`: Number of assets that we can purchase.
- `B::Float64`: Budget that we have to spend on the collection of assets.
- `nₒ::Array{Float64,1}`: Initial guess for the solution.
- `X̄::Array{Float64,2}`: inv(X^T*X)*X^T.
- `number_of_samples_to_draw::Int64`: Number of samples needed by the error model.
- `μₒ::Array{Float64,1}`: Initial guess for the mean of the error model.
- `R̄ₘ::Float64`: Average return of the market (to use in the SIM).
"""
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

"""
    mutable MyBanditPortfolioModel

A mutable struct that defines the bandit portfolio model.

### Fields
- `utility::Float64`: Utility of the portfolio.
- `n::Array{Float64,1}`: Share array.
- `a::Array{Int,1}`: Action array.
- `converged::Bool`: Has the model converged?   
"""
struct MyBanditPortfolioModel

    # data -
    utility::Float64 # utility of the portfolio
    n::Array{Float64,1} # share array
    a::Array{Int,1} # action array
    converged::Bool # has the model converged?   

    # constructor -
    MyBanditPortfolioModel(U,n,a, converged) = new(U,n, a, converged);
end