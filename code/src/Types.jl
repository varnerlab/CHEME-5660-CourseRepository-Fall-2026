abstract type AbstractAssetModel end
abstract type AbstractEquityPriceTreeModel <: AbstractAssetModel end
abstract type AbstractInterestRateTreeModel <: AbstractAssetModel end
abstract type AbstractContractModel <: AbstractAssetModel end
abstract type AbstractTreasuryDebtSecurity end
abstract type AbstractCompoundingModel end
abstract type AbstractStochasticChoiceProblem end
abstract type AbstractReturnModel end
abstract type AbstractProbabilityMeasure end
abstract type AbstractStochasticSolverModel end
abstract type AbstractMarkovModel end
abstract type AbstractSamplingModel end
abstract type AbstractWorldModel end
abstract type AbstractPolicyModel end
abstract type AbstractLearningModel end
abstract type AbstractAgentModel end

# --- Equity models ------------------------------------------------------------------------ #
struct MyLocalExpectationRegressionModel 
    
    # parameters -
    a0::Float64
    a1::Float64
    a2::Float64

    function MyLocalExpectationRegressionModel(a0,a1,a2)
        this = new(a0,a1,a2)
    end
end

"""
    mutable struct MyCRRLatticeNodeModel

The `MyCRRLatticeNodeModel` mutable struct represents a node in a [Cox-Ross-Rubinstein (CRR) model](https://en.wikipedia.org/wiki/Binomial_options_pricing_model) for pricing
American style option contracts.

### Required fields
- `price::Float64`: The price of the price at the node
- `probability::Float64`: The probability of reaching the node

### Optional or computed fields
- `intrinsic::Union{Nothing,Float64}`: The intrinsic value of the option contract at the node
- `extrinsic::Union{Nothing,Float64}`: The extrinsic value of the option contract at the node
"""
mutable struct MyCRRLatticeNodeModel

    # data -
    price::Float64
    probability::Float64
    intrinsic::Union{Nothing,Float64}
    extrinsic::Union{Nothing,Float64}

    # constructor -
    MyCRRLatticeNodeModel() = new();
end

"""
    mutable struct MyAdjacencyBasedCRREquityPriceTree <: AbstractEquityPriceTreeModel

The `MyAdjacencyBasedCRREquityPriceTree` mutable struct represents a [Cox-Ross-Rubinstein (CRR) model](https://en.wikipedia.org/wiki/Binomial_options_pricing_model) for pricing
American style option contracts. The lattice is constructed using an adjacency list to represent the connectivity of the nodes in the lattice.
The lattice is populated using the [`populate`](@ref) function, and the contract pricing is performed using the [`premium`](@ref) function.

### Required fields
- `μ::Float64`: The drift rate of the asset price
- `σ::Float64`: The volatility of the asset price
- `T::Float64`: The time to expiration of the option contract (measured in units of years)

### Optional or computed fields
- `ΔT::Union{Nothing,Float64}`: The time step size
- `u::Union{Nothing,Float64}`: The up-factor for the lattice
- `d::Union{Nothing,Float64}`: The down-factor for the lattice
- `p::Union{Nothing,Float64}`: The probability of an up move in the lattice
- `data::Union{Nothing, Dict{Int, MyCRRLatticeNodeModel}}`: A dictionary that holds the lattice data for each node where nodes are modeled as [`MyCRRLatticeNodeModel`](@ref) instances.
- `connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}`: A dictionary that holds the connectivity of the lattice where the `key` is the node index and the `value` is an array of the connected nodes.
- `levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}`: A dictionary that holds the nodes on each level of the lattice where the `key` is the level index and the `value` is an array of the nodes on that level.

The `optional` fields are computed when the lattice is passed to the [`populate`](@ref) function.
"""
mutable struct MyAdjacencyBasedCRREquityPriceTree <: AbstractEquityPriceTreeModel

    # data -
    μ::Float64
    σ::Float64
    T::Float64

    # we compute these values -
    ΔT::Union{Nothing,Float64}
    u::Union{Nothing,Float64}
    d::Union{Nothing,Float64}
    p::Union{Nothing,Float64}
    data::Union{Nothing, Dict{Int, MyCRRLatticeNodeModel}}
    connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}
    levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}
   
    # constructor 
    MyAdjacencyBasedCRREquityPriceTree() = new()
end

"""
    mutable struct  MyGeneralAdjacencyRecombiningCommodityPriceTree <: AbstractPriceTreeModel

The `MyGeneralAdjacencyRecombiningCommodityPriceTree` type is a model of a commodity price tree that uses an dictionary to store the price data.
This model stores the connectivity information between nodes.

### Fields
- `data::Union{Nothing, Dict{Int64,NamedTuple}}` - A dictionary that stores the price data and path informationfor the tree.
- `connectivity::Dict{Int64,Array{Int64,1}}` - A dictionary that stores the connectivity information between nodes.
"""
mutable struct MyGeneralAdjacencyRecombiningCommodityPriceTree  <: AbstractEquityPriceTreeModel

    # data -
    data::Union{Nothing, Dict{Int64,NamedTuple}}
    connectivity::Dict{Int64,Array{Int64,1}}
    h::Int64 # height of the tree
    n::Int64 # branching factor

    # constructor 
    MyGeneralAdjacencyRecombiningCommodityPriceTree() = new()
end

mutable struct MyLongstaffSchwartzContractPricingModel <: AbstractEquityPriceTreeModel

    # data -
    S::Array{Float64,2}
    r̄::Float64
    Δt::Float64

    # constructor -
    MyLongstaffSchwartzContractPricingModel() = new();
end

"""
    mutable struct MyBlackScholesContractPricingModel <: AbstractAssetModel

The `MyBlackScholesContractPricingModel` mutable struct represents a [Black-Scholes model](https://en.wikipedia.org/wiki/Black–Scholes_model) for pricing
European option contracts. 

### Required fields
- `r::Float64`: The annual risk-free discount rate
- `Sₒ::Float64`: The current price of the underlying asset
"""
mutable struct MyBlackScholesContractPricingModel <: AbstractAssetModel

    # data -
    r::Float64
    Sₒ::Float64

    # constructor -
    MyBlackScholesContractPricingModel() = new();
end

"""
    mutable struct MyGeometricBrownianMotionEquityModel <: AbstractAssetModel

The `MyGeometricBrownianMotionEquityModel` mutable struct represents a [geometric Brownian motion](https://en.wikipedia.org/wiki/Geometric_Brownian_motion) model for 
a single equity asset.

### Fields
- `μ::Float64`: The drift rate of the asset price
- `σ::Float64`: The volatility of the asset price
"""
mutable struct MyGeometricBrownianMotionEquityModel <: AbstractAssetModel

    # data -
    μ::Float64
    σ::Float64

    # constructor -
    MyGeometricBrownianMotionEquityModel() = new()
end

"""
    mutable struct MyMultipleAssetGeometricBrownianMotionEquityModel <: AbstractAssetModel

The `MyMultipleAssetGeometricBrownianMotionEquityModel` mutable struct represents a [geometric Brownian motion](https://en.wikipedia.org/wiki/Geometric_Brownian_motion) model for
multiple equity assets. 

### Fields
- `μ::Array{Float64,1}`: The drift rates of the asset prices
- `A::Array{Float64,2}`: The [Cholesky decomposition](https://en.wikipedia.org/wiki/Cholesky_decomposition) of the covariance matrix between the asset returns.
"""
mutable struct MyMultipleAssetGeometricBrownianMotionEquityModel <: AbstractAssetModel

    # data -
    μ::Array{Float64,1}
    A::Array{Float64,2}

    # constructor -
    MyMultipleAssetGeometricBrownianMotionEquityModel() = new()
end



"""
    mutable struct MyOrnsteinUhlenbeckModel <: AbstractAssetModel

A mutable struct that represents a [Ornstein-Uhlenbeck process](https://en.wikipedia.org/wiki/Ornstein–Uhlenbeck_process).
An instance of `MyOrnsteinUhlenbeckModel` is configured and constructed using a corresponding `build` method.

### Fields
- `μ::Function`: The price drift function (long term price level)
- `σ::Function`: The price volatility function
- `θ::Function`: The mean reversion function. This function determines how quickly the price reverts to the long-term mean.
"""
mutable struct MyOrnsteinUhlenbeckModel <: AbstractAssetModel
    
    # data -
    μ::Function
    σ::Function
    θ::Function

    # constructor -
    MyOrnsteinUhlenbeckModel() = new();
end


"""
    mutable struct MyHestonModel <: AbstractAssetModel

A mutable struct that represents the [Heston model](https://en.wikipedia.org/wiki/Heston_model). 
An instance of `MyHestonModel` is configured and constructed using a corresponding `build` method.

### Fields
- `μ::Function`: Drift function takes the state matrix `X` and time `t` and returns a scalar, i.e., ``\\mu:X\\times{t}\\rightarrow\\mathbb{R}``
- `κ::Function`: Mean reversion function
- `θ::Function`: Long-run volatility function
- `ξ::Function`: Volatility of volatility function
- `Σ::Array{Float64,2}`: Covariance matrix between the asset price and the volatility process
"""
mutable struct MyHestonModel <: AbstractAssetModel
    
    # data -
    μ::Function
    κ::Function
    θ::Function
    ξ::Function
    Σ::Array{Float64,2}

    # constructor -
    MyHestonModel() = new();
end

"""
    mutable struct MySisoLegSHippoModel <: AbstractAssetModel

A mutable struct that represents a single-input, single-output (SISO) linear time-invariant (LTI) system
that used the Leg-S parameterization. An instance of `MySisoLegSHippoModel` is configuired and constructed using
a corresponding `build` method.

### Fields
- `Â::Array{Float64,2}`: Discretized state matrix of the system `Â ∈ ℝ^(n x n)` where `n` is the number of hidden states
- `B̂::Array{Float64,1}`: Discretized input matrix of the system `B̂ ∈ ℝ^n x 1`
- `Ĉ::Array{Float64,1}`: Discretized output matrix of the system `Ĉ ∈ ℝ^1 x n`
- `D̂::Array{Float64,1}`: Discretized feedforward matrix of the system `D̂ ∈ ℝ^1 x 1`
- `n::Int`: Number of hidden states in the system
- `Xₒ::Array{Float64,1}`: Initial conditions of the system
"""
mutable struct MySisoLegSHippoModel <: AbstractAssetModel

    # data -
    Â::Array{Float64,2}
    B̂::Array{Float64,1}
    Ĉ::Array{Float64,1}
    D̂::Array{Float64,1}
    n::Int
    Xₒ::Array{Float64,1}

    # constructor -
    MySisoLegSHippoModel() = new();
end

# tagging type -
"""
    struct EulerMaruyamaMethod <: AbstractStochasticSolverModel

Immutable type that represents the [Euler-Maruyama method](https://en.wikipedia.org/wiki/Euler–Maruyama_method) for solving stochastic differential equations.
This type is passed to various functions in their `method` argument to indicate that the [Euler-Maruyama method](https://en.wikipedia.org/wiki/Euler–Maruyama_method) 
should be used in calculations.
"""
struct EulerMaruyamaMethod <: AbstractStochasticSolverModel
end
# ------------------------------------------------------------------------------------------- #

# --- Contract models ----------------------------------------------------------------------- #

"""
    mutable struct MyEuropeanCallContractModel <: AbstractContractModel

The `MyEuropeanCallContractModel` mutable struct represents a European call option contract.
A `call` option is a financial contract that gives the holder the right, but not the obligation, to buy an asset at a specified price (the strike price) 
within a specified time period. For European options, the contract can only be exercised by the buyer at the expiration date.
    
### Required fields
- `K::Float64`: The strike price of the option. 

### Optional fields
- `sense::Union{Nothing, Int64}`: The sense of the option. A value of `1` indicates a long position, and a value of `-1` indicates a short position.
- `DTE::Union{Nothing,Float64}`: The days to expiration of the option (measured in units of years).
- `IV::Union{Nothing, Float64}`: The implied volatility of the option contract.
- `premium::Union{Nothing, Float64}`: The premium of the option contract. This is the price paid to the seller by the buyer for the option contract.
- `ticker::Union{Nothing,String}`: The ticker symbol of the underlying asset.
- `copy::Union{Nothing, Int64}`: Number of contracts purchased or sold.
"""
mutable struct MyEuropeanCallContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyEuropeanCallContractModel() = new()
end

"""
    mutable struct MyEuropeanPutContractModel <: AbstractContractModel

The `MyEuropeanPutContractModel` mutable struct represents a European put option contract. 
A `put` option is a financial contract that gives the holder the right, but not the obligation, to sell an asset at a specified price (the strike price)
within a specified time period. For European options, the contract can only be exercised by the buyer at the expiration date.

### Required fields
- `K::Float64`: The strike price of the option.

### Optional fields
- `sense::Union{Nothing, Int64}`: The sense of the option. A value of `1` indicates a long position, and a value of `-1` indicates a short position.
- `DTE::Union{Nothing,Float64}`: The days to expiration of the option (measured in units of years).
- `IV::Union{Nothing, Float64}`: The implied volatility of the option contract.
- `premium::Union{Nothing, Float64}`: The premium of the option contract. This is the price paid to the seller by the buyer for the option contract.
- `ticker::Union{Nothing,String}`: The ticker symbol of the underlying asset.
- `copy::Union{Nothing, Int64}`: Number of contracts purchased or sold.
"""
mutable struct MyEuropeanPutContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyEuropeanPutContractModel() = new()
end

"""
    mutable struct MyAmericanCallContractModel <: AbstractContractModel

The `MyAmericanCallContractModel` mutable struct represents an American call option contract. 
An `American call` option is a financial contract that gives the holder the right, but not the obligation, to buy an asset at a specified price (the strike price).
American option contracts can be exercised at any time on or before the expiration date.

### Required fields
- `K::Float64`: The strike price of the option.

### Optional fields
- `sense::Union{Nothing, Int64}`: The sense of the option. A value of `1` indicates a long position, and a value of `-1` indicates a short position.
- `DTE::Union{Nothing,Float64}`: The days to expiration of the option (measured in units of years).
- `IV::Union{Nothing, Float64}`: The implied volatility of the option contract.
- `premium::Union{Nothing, Float64}`: The premium of the option contract. This is the price paid to the seller by the buyer for the option contract.
- `ticker::Union{Nothing,String}`: The ticker symbol of the underlying asset.
- `copy::Union{Nothing, Int64}`: Number of contracts purchased or sold.
"""
mutable struct MyAmericanCallContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyAmericanCallContractModel() = new()
end

"""
    mutable struct MyAmericanPutContractModel <: AbstractContractModel

The `MyAmericanPutContractModel` mutable struct represents an American put option contract. 
A `put` option is a financial contract that gives the holder the right, but not the obligation, to sell an asset at a specified price (the strike price).
For American options, the contract can be exercised at any time on or before the expiration date.

### Required fields
- `K::Float64`: The strike price of the option.

### Optional fields
- `sense::Union{Nothing, Int64}`: The sense of the option. A value of `1` indicates a long position, and a value of `-1` indicates a short position.
- `DTE::Union{Nothing,Float64}`: The days to expiration of the option (measured in units of years).
- `IV::Union{Nothing, Float64}`: The implied volatility of the option contract.
- `premium::Union{Nothing, Float64}`: The premium of the option contract. This is the price paid to the seller by the buyer for the option contract.
- `ticker::Union{Nothing,String}`: The ticker symbol of the underlying asset.
- `copy::Union{Nothing, Int64}`: Number of contracts purchased or sold.
"""
mutable struct MyAmericanPutContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Union{Nothing, Int64}
    DTE::Union{Nothing,Float64}
    IV::Union{Nothing, Float64}
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}
    copy::Union{Nothing, Int64}

    # constructor -
    MyAmericanPutContractModel() = new()
end

"""
    mutable struct MyEquityModel <: AbstractAssetModel

Models a single equity asset. We use this model when thinking about equity as counter assets in hedging strategies.

### Fields
- `ticker::String`: The ticker symbol of the equity asset
- `purchase_price::Float64`: The purchase price of the equity asset
- `current_price::Float64`: The current price of the equity asset
- `direction::Int64`: The direction of the position (1 for long, -1 for short)
- `number_of_shares::Int64`: The number of shares held

"""
mutable struct MyEquityModel <: AbstractAssetModel

    # data -
    ticker::String
    purchase_price::Float64
    current_price::Float64
    direction::Int64
    number_of_shares::Int64

    # constructor -
    MyEquityModel() = new()
end
# -------------------------------------------------------------------------------------------- #

# --- Term structure of interest rates and fixed income types -------------------------------- #

"""
    mutable struct MyUSTreasuryZeroCouponBondModel <: AbstractTreasuryDebtSecurity

A mutable struct that represents a [U.S. Treasury zero coupon security](https://www.treasurydirect.gov/marketable-securities/treasury-bills/). 

### Fields
- `par::Float64`: The face or par value of the bond
- `rate::Union{Nothing, Float64}`: Effective annual interest rate (discount rate specified as a decimal)
- `T::Union{Nothing,Float64}`: Duration in years of the instrument, measured as a 365 day or a 52 week year
- `n::Int`: Number of compounding periods per year (typically 2)

### Computed Fields
- `price::Union{Nothing, Float64}`: Price of the bond or note (computed property)
- `cashflow::Union{Nothing, Dict{Int,Float64}}`: Cashflow dictionary (computed property) where the `key` is the period and the `value` is the discounted cashflow in a period
- `discount::Union{Nothing, Dict{Int,Float64}}`: Discount factor dictionary (computed property) where the `key` is the period and the `value` is the discount factor in that period
"""
mutable struct MyUSTreasuryZeroCouponBondModel <: AbstractTreasuryDebtSecurity
    
    # data -
    par::Float64                                    # Par value of the bill
    rate::Union{Nothing, Float64}                   # Annual interest rate
    T::Union{Nothing,Float64}                       # Duration in years, measured as a 365 day or a 52 week year
    price::Union{Nothing, Float64}                  # Price of the bond or note
    n::Int                                          # Number of compounding periods per year (typically 2)
    cashflow::Union{Nothing, Dict{Int,Float64}}     # Cashflow
    discount::Union{Nothing, Dict{Int,Float64}}     # discount factors
    
    # constructor -
    MyUSTreasuryZeroCouponBondModel() = new()
end

"""
    mutable struct MyUSTreasuryCouponSecurityModel <: AbstractTreasuryDebtSecurity

A mutable struct that represents a [U.S. Treasury coupon bond](https://www.treasurydirect.gov/marketable-securities/treasury-bonds/). 
This type of security (note or bond) pays the holder of the instrument a fixed interest rate at regular intervals over the life of the security.

### Fields
- `par::Float64`: Par value of the bond
- `rate::Union{Nothing, Float64}`: Annualized effective discount rate
- `coupon::Union{Nothing, Float64}`: Coupon interest rate
- `T::Union{Nothing,Float64}`: Duration in years of the note or bond, measured as a 365 day or a 52 week year
- `λ::Int`: Number of coupon payments per year (typically 2)

### Computed Fields
- `price::Union{Nothing, Float64}`: Price of the bond or note (computed property)
- `cashflow::Union{Nothing, Dict{Int,Float64}}`: Cashflow dictionary (computed property) where the `key` is the period and the `value` is the discounted cashflow in a period
- `discount::Union{Nothing, Dict{Int,Float64}}`: Discount factor dictionary(computed property) where the `key` is the period and the `value` is the discount factor in that period
"""
mutable struct MyUSTreasuryCouponSecurityModel <: AbstractTreasuryDebtSecurity

    # data -
    par::Float64                                    # Par value of the bill
    rate::Union{Nothing, Float64}                   # Annualized effective interest rate
    coupon::Union{Nothing, Float64}                 # Coupon rate
    T::Union{Nothing,Float64}                       # Duration in years, measured as a 365 day or a 52 week year
    λ::Int                                          # Number of coupon payments per year (typcially 2)
    price::Union{Nothing, Float64}                  # Price of the bond or note
    cashflow::Union{Nothing, Dict{Int,Float64}}     # Cashflow
    discount::Union{Nothing, Dict{Int,Float64}}     # discount factors

    # consturctor -
    MyUSTreasuryCouponSecurityModel() = new();
end

"""
    struct DiscreteCompoundingModel <: AbstractCompoundingModel

Immutable type that represents discrete compounding.
This type has no fields and is passed as an argument to various functions to indicate that discrete compounding should be used in calculations.
"""
struct DiscreteCompoundingModel <: AbstractCompoundingModel 
    DiscreteCompoundingModel() = new()
end

"""
    struct ContinuousCompoundingModel <: AbstractCompoundingModel
        
Immutable type that represents continuous compounding. 
This type has no fields and is passed as an argument to various functions to indicate that continuous compounding should be used in calculations.
"""
struct ContinuousCompoundingModel <: AbstractCompoundingModel 
    ContinuousCompoundingModel() = new()
end

"""
   struct RealWorldBinomialProbabilityMeasure <: AbstractProbabilityMeasure

Immutable type that represents the real-world probability measure. 
This type is passed as an argument to various functions to indicate that the real-world probability measure should be used in calculations.   
"""
struct RealWorldBinomialProbabilityMeasure <: AbstractProbabilityMeasure
    RealWorldBinomialProbabilityMeasure() = new()
end


"""
   struct RealWorldGeneralProbabilityMeasure <: AbstractProbabilityMeasure

Immutable type that represents the real-world probability measure for a n-ary tree.
This type is passed as an argument to various functions to indicate that the real-world probability measure should be used in calculations.   
"""
struct RealWorldGeneralProbabilityMeasure <: AbstractProbabilityMeasure
    RealWorldGeneralProbabilityMeasure() = new()
end

"""
    struct RiskNeutralBinomialProbabilityMeasure <: AbstractProbabilityMeasure

Immutable type that represents the risk-neutral probability measure. 
This type is passed as an argument to various functions to indicate that the risk-neutral probability measure should be used in calculations.        
"""
struct RiskNeutralBinomialProbabilityMeasure <: AbstractProbabilityMeasure
    RiskNeutralBinomialProbabilityMeasure() = new()
end

"""
    mutable struct MyBinaryInterestRateLatticeNodeModel

The `MyBinaryInterestRateLatticeNodeModel` mutable struct represents a node in a binary lattice model for simulating interest rates.
This node type is created during the initialization of a lattice model and is used to store the probability, rate, and price data for each node.

### Fields
- `probability::Float64`: The probability of reaching the node in the binary lattice
- `rate::Float64`: The interest rate at the node
- `price::Float64`: The price at the node (used for Treasury security pricing)
"""
mutable struct MyBinaryInterestRateLatticeNodeModel

    # data -
    probability::Float64
    rate::Float64
    price::Float64

    # constructor -
    MyBinaryInterestRateLatticeNodeModel() = new();
end

"""
    mutable struct MySymmetricBinaryInterestRateLatticeModel <: AbstractInterestRateTreeModel

The `MySymmetricBinaryInterestRateLatticeModel` mutable struct represents a binary lattice model for simulating interest rates.

### Required fields
- `u::Float64`: The up-factor for the lattice
- `d::Float64`: The down-factor for the lattice
- `p::Float64`: The probability of an up move in the lattice
- `rₒ::Float64`: The initial interest rate (the root value of the lattice)
- `T::Int64`: The number of levels in the tree (zero based), so the tree will have a total of `T + 1` levels (including the root level).

### Computed fields
- `connectivity::Union{Nothing,Dict{Int64, Array{Int64,1}}}`: A dictionary that holds the connectivity of the lattice where the `key` is the node index and the `value` is an array of the connected nodes.
- `levels::Union{Nothing,Dict{Int64,Array{Int64,1}}}`: A dictionary that holds the node indexes on each level of the lattice where the `key` is the level index and the `value` is an array of the node indexes on that level.
- `data::Union{Nothing, Dict{Int64, MyBinaryInterestRateLatticeNodeModel}}`: A dictionary that holds the lattice data for each node where nodes are modeled as `MyBinaryInterestRateLatticeNodeModel` instances.
"""
mutable struct MySymmetricBinaryInterestRateLatticeModel <: AbstractInterestRateTreeModel
    
    # data -
    u::Float64      # up-factor
    d::Float64      # down-factor
    p::Float64      # probability of an up move
    rₒ::Float64     # root value
    T::Int64        # number of levels in the tree (zero based)
    
    connectivity::Union{Nothing,Dict{Int64, Array{Int64,1}}}    # holds the connectivity of the tree
    levels::Union{Nothing,Dict{Int64,Array{Int64,1}}} # nodes on each level of the tree
    data::Union{Nothing, Dict{Int64, MyBinaryInterestRateLatticeNodeModel}} # holds data in the tree

    # constructor -
    MySymmetricBinaryInterestRateLatticeModel() = new()
end



# --- Portfolio choice models ---------------------------------------------------------------------------------- # 

"""
    mutable struct MyMarkowitzRiskyAssetOnlyPortfiolioChoiceProblem <: AbstractStochasticChoiceProblem

The `MyMarkowitzRiskyAssetOnlyPortfiolioChoiceProblem` mutable struct represents a [Minimum Variance portfolio problem](https://en.wikipedia.org/wiki/Modern_portfolio_theory) with risky assets only.

### Required fields
- `Σ::Array{Float64,2}`: The covariance matrix of the risky asset Returns
- `μ::Array{Float64,1}`: The expected returns of the risky assets
- `bounds::Array{Float64,2}`: The bounds on the risky asset weights
- `R::Float64`: The desired return of the portfolio
- `initial::Array{Float64,1}`: The initial portfolio weights    
"""
mutable struct MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem <: AbstractStochasticChoiceProblem

    # data -
    Σ::Array{Float64,2}
    μ::Array{Float64,1}
    bounds::Array{Float64,2}
    R::Float64
    initial::Array{Float64,1}

    # constructor
    MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem() = new();
end

"""
    mutable struct MyMarkowitzRiskyRiskFreePortfolioChoiceProblem <: AbstractStochasticChoiceProblem

The `MyMarkowitzRiskyRiskFreePortfolioChoiceProblem` mutable struct represents a [Minimum Variance portfolio problem](https://en.wikipedia.org/wiki/Modern_portfolio_theory) with a combination of risky and risk-free assets.

### Required fields
- `Σ::Array{Float64,2}`: The covariance matrix of the risky asset returns
- `μ::Array{Float64,1}`: The expected returns of the risky assets
- `bounds::Array{Float64,2}`: The bounds on the risky asset weights
- `R::Float64`: The desired return of the portfolio
- `initial::Array{Float64,1}`: The initial portfolio weights
- `risk_free_rate::Float64`: The risk-free rate of return
"""
mutable struct MyMarkowitzRiskyRiskFreePortfolioChoiceProblem <: AbstractStochasticChoiceProblem

    # data -
    Σ::Array{Float64,2}
    μ::Array{Float64,1}
    bounds::Array{Float64,2}
    R::Float64
    initial::Array{Float64,1}
    risk_free_rate::Float64

    # constructor -
    MyMarkowitzRiskyRiskFreePortfolioChoiceProblem() = new();
end

"""
    mutable struct MySharpeRatioPortfolioChoiceProblem <: AbstractStochasticChoiceProblem

The `MySharpeRatioPortfolioChoiceProblem` mutable struct represents a [Maximum Sharpe Ratio portfolio problem](https://en.wikipedia.org/wiki/Sharpe_ratio).

### Required fields
- `Σ::Array{Float64,2}`: The covariance matrix of the risky asset returns
- `risk_free_rate::Float64`: The risk-free rate of return
- `α::Array{Float64,1}`: The firm specific unexplained returns
- `β::Array{Float64,1}`: The relationship between the firm and the market
- `gₘ::Float64`: The expected market return
- `τ::Float64`: The growth parameter
"""
mutable struct MySharpeRatioPortfolioChoiceProblem <: AbstractStochasticChoiceProblem

    # data -
    Σ::Array{Float64,2}     # covariance matrix of the risky asset returns
    risk_free_rate::Float64 # risk free rate of return
    α::Array{Float64,1}     # firm specific unexplained returns
    β::Array{Float64,1}     # relationship between the firm and the market
    gₘ::Float64             # expected market return
    τ::Float64              # growth parameter

    # constructor -
    MySharpeRatioPortfolioChoiceProblem() = new();
end

"""
    mutable struct MySingleIndexModel <: AbstractReturnModel

The `MySingleIndexModel` mutable struct represents a single index model of risky asset returns.

### Required fields
- `α::Float64`: The firm specific unexplained return
- `β::Float64`: The relationship between the firm and the market
- `r::Float64`: The risk-free rate of return
- `ϵ::Distribution`: The random shocks to the model (unexplained return)    
"""
mutable struct MySingleIndexModel <: AbstractReturnModel

    # model -
    α::Float64          # firm specific unexplained return
    β::Float64          # relationship between the firm and the market
    r::Float64          # risk free rate of return 
    ϵ::Distribution     # random shocks 

    # constructor -
    MySingleIndexModel() = new()
end
# --------------------------------------------------------------------------------------------------------------- #

# Lattice model -
"""
    mutable struct MyBiomialLatticeEquityNodeModel

The `MyBiomialLatticeEquityNodeModel` mutable struct represents a node in a binomial lattice model for simulating equity prices.
This node type is created during the initialization of a lattice model and is used to store the price, probability, intrinsic, and extrinsic values for each node.

### Fields
- `price::Float64`: The price of the asset at the node
- `probability::Float64`: The probability of reaching the node in the binomial lattice
- `intrinsic::Union{Nothing,Float64}`: The intrinsic value of the option contract at the node
- `extrinsic::Union{Nothing,Float64}`: The extrinsic value of the option contract at the node
"""
mutable struct MyBiomialLatticeEquityNodeModel

    # data -
    price::Float64
    probability::Float64
    intrinsic::Union{Nothing,Float64} # these are needed *only* for option pricing
    extrinsic::Union{Nothing,Float64} # these are needed *only* for option pricing

    # constructor -
    MyBiomialLatticeEquityNodeModel() = new();
end

"""
    mutable struct MyBinomialEquityPriceTree <: AbstractEquityPriceTreeModel

This mutable struct represents a binomial lattice model for simulating equity prices.
The lattice is constructed using values for the up-factor `u`, down-factor `d`, and probability `p` of an up move computed
using either a real-world or risk-neutral probability measure. 
A default (largely empty) lattice is created using a build method, and the lattice is populated using the `populate` function.

### Required fields
- `u::Float64`: The up-factor for the lattice (return for an up move during a single time step)
- `d::Float64`: The down-factor for the lattice (return for a down move during a single time step)
- `p::Float64`: The probability of an up move in the lattice

### Optional or computed fields
- `μ::Union{Nothing,Float64}`: The drift rate of the asset price (needed for option pricing)
- `T::Union{Nothing,Float64}`: The time to expiration of the option contract (needed for option pricing)
- `connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}`: A dictionary that holds the connectivity of the lattice where the `key` is the node index and the `value` is an array of the connected nodes.
- `levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}`: A dictionary that holds the nodes on each level of the lattice where the `key` is the level index and the `value` is an array of the nodes on that level.
- `ΔT::Union{Nothing,Float64}`: The time step size for a single time step in the lattice
- `data::Union{Nothing, Dict{Int64, MyBiomialLatticeEquityNodeModel}}`: A dictionary that holds the lattice data for each node where nodes are modeled as `MyBiomialLatticeEquityNodeModel` instances.         
"""
mutable struct MyBinomialEquityPriceTree <: AbstractEquityPriceTreeModel

    # data -
    u::Float64
    d::Float64
    p::Float64
    μ::Union{Nothing,Float64} # this is needed *only* for option pricing
    T::Union{Nothing,Float64}

    # we compute these values -
    connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}
    levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}
    ΔT::Union{Nothing,Float64}
    data::Union{Nothing, Dict{Int64, MyBiomialLatticeEquityNodeModel}} # holds data in the tree
    
    # constructor 
    MyBinomialEquityPriceTree() = new()
end
# -------------------------------------------------------------------------------------------------------------- #

# --- Markov models ------------------------------------------------------------------------------------------- #
"""
    mutable struct MyHiddenMarkovModel <: AbstractMarkovModel

The `MyHiddenMarkovModel` mutable struct represents a hidden Markov model (HMM) with discrete states.

### Required fields
- `states::Array{Int64,1}`: The states of the model
- `transition::Dict{Int64, Categorical}`: The transition matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Categorical` distribution
- `emission::Dict{Int64, Categorical}`: The emission matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Categorical` distribution   
"""
mutable struct MyHiddenMarkovModel <: AbstractMarkovModel
    
    # data -
    states::Array{Int64,1}
    transition::Dict{Int64, Categorical}
    emission::Dict{Int64, Categorical}

    # constructor -
    MyHiddenMarkovModel() = new();
end

"""
    mutable struct MyHiddenMarkovModelWithJumps <: AbstractMarkovModel

The `MyHiddenMarkovModelWithJumps` mutable struct represents a hidden Markov model (HMM) with discrete states and jump dynamics.

### Required fields
- `states::Array{Int64,1}`: The states of the model
- `transition::Dict{Int64, Categorical}`: The transition matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Categorical` distribution
- `inverse_transition::Dict{Int64, Categorical}`: The inverse transition matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Categorical` distribution
- `emission::Dict{Int64, Categorical}`: The emission matrix of the model encoded as a dictionary where the `key` is the state and the `value` is a `Categorical` distribution
- `ϵ::Float64`: The jump probability
- `λ::Float64`: The jump distribution parameter
- `jump_distribution::Poisson`: The jump distribution
"""
mutable struct MyHiddenMarkovModelWithJumps <: AbstractMarkovModel
    
    # data -
    states::Array{Int64,1}
    transition::Dict{Int64, Categorical}
    inverse_transition::Dict{Int64, Categorical}; # high-low probability states reversed
    emission::Dict{Int64, Categorical}
    ϵ::Float64; # jump probability
    λ::Float64; # jump distribution parameter
    jump_distribution::Poisson; # jump distribution


    # constructor -
    MyHiddenMarkovModelWithJumps() = new();
end

# --- Bandits, MDP and RL models ---------------------------------------------------------------------------------------- #

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
    ϵ::Float64

    # constructor -
    MyEpsilonSamplingBanditModel() = new();
end

"""
    mutable struct MyTickerPickerWorldModel <: AbstractWorldModel

The `MyTickerPickerWorldModel` mutable struct represents a world model for a ticker picker problem.
    
### Required fields
- `tickers::Array{String,1}`: An array of ticker symbols that we explore
- `data::Dict{String, DataFrame}`: A dictionary that holds the data for each ticker symbol
- `risk_free_rate::Float64`: The risk-free rate of return in the world (assumed constant)
- `world::Function`: A function that represents the world model. The function takes an action `a`, data about the world, and returns the reward for taking action `a`.
- `Δt::Float64`: The time step size in the world model
- `buffersize::Int64`: The size of the buffer used in the world model
"""
mutable struct MyTickerPickerWorldModel <: AbstractWorldModel

    # data -
    tickers::Array{String,1}
    data::Dict{String, DataFrame}
    risk_free_rate::Float64
    world::Function
    Δt::Float64
    buffersize::Int64

    # constructor -
    MyTickerPickerWorldModel() = new();
end

"""
    mutable struct MyTickerPickerRiskAwareWorldModel <: AbstractWorldModel

The `MyTickerPickerRiskAwareWorldModel` mutable struct represents a world model for a ticker picker problem that is risk-aware.

### Required fields
- `tickers::Array{String,1}`: An array of ticker symbols that we explore
- `data::Dict{String, DataFrame}`: A dictionary that holds the price data for each ticker symbol
- `risk_free_rate::Float64`: The risk-free rate of return in the world (assumed constant)
- `world::Function`: A function that represents the world model. The function takes an action `a`, data about the world, and returns the reward `r` for taking action `a`.
- `Δt::Float64`: The time step size in the world model
- `buffersize::Int64`: The size of the buffer used in the world model
- `risk::Dict{String, Float64}`: A dictionary that holds the risk measure for each ticker symbol
"""
mutable struct MyTickerPickerRiskAwareWorldModel <: AbstractWorldModel

    # data -
    tickers::Array{String,1}
    data::Dict{String, DataFrame}
    risk_free_rate::Float64
    world::Function
    Δt::Float64
    buffersize::Int64
    risk::Dict{String, Float64}

    # constructor -
    MyTickerPickerRiskAwareWorldModel() = new();
end

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
    mutable struct MyOneDimensionalElementarWolframRuleModel <: AbstractPolicyModel

The `MyOneDimensionalElementarWolframRuleModel` mutable struct represents a one-dimensional elementary Wolfram rule model.

### Required fields
- `index::Int`: The index of the rule
- `radius::Int`: The radius, i.e, the number of cells that influence the next state for this rule
- `rule::Dict{Int,Int}`: A dictionary that holds the rule where the `key` is the binary representation of the neighborhood and the `value` is the next state
"""
mutable struct MyOneDimensionalElementarWolframRuleModel <: AbstractPolicyModel
    
    # data
    index::Int
    radius::Int
    number_of_colors::Int
    rule::Dict{Int,Int}

    # constructor -
    MyOneDimensionalElementarWolframRuleModel() = new();
end


mutable struct MyTwoDimensionalElementaryWolframRuleModel <: AbstractPolicyModel
    
    # data -
    index::Int
    radius::Int
    number_of_colors::Int
    rule::Dict{Int,Int}

    # constructor
    MyTwoDimensionalElementaryWolframRuleModel() = new()
end


mutable struct MyOneDimensionalTotalisticWolframRuleModel <: AbstractPolicyModel
    
    # data
    index::Int
    radius::Int
    number_of_colors::Int
    Q::Dict{Float64, Int64}
    rule::Dict{Int,Int}

    # constructor -
    MyOneDimensionalTotalisticWolframRuleModel() = new();
end

"""
    mutable struct MyTwoDimensionalTotalisticWolframRuleModel <: AbstractPolicyModel

The `MyTwoDimensionalTotalisticWolframRuleModel` mutable struct represents a two-dimensional totalistic Wolfram rule model.

### Required fields
- `index::Int`: The index of the rule
- `radius::Int`: The radius, i.e, the number of cells that influence the next state for this rule
- `number_of_colors::Int`: The number of colors in the rule, i.e., the number of states a cell can exist in
- `rule::Dict{Int,Int}`: A dictionary that holds the rule where the `key` is index of the neighborhood state and the `value` is the next state
- `neighborhoodstatesmap::Dict{Float64, Int64}`: A dictionary whose `keys` are the average of the neighborhood states and the `value` the neighborhood state index
- `weights::Array{Float64,1}`: An array of weights associated with the neighborhood states
"""
mutable struct MyTwoDimensionalTotalisticWolframRuleModel <: AbstractPolicyModel
    
    # data -
    index::Int
    radius::Int
    number_of_colors::Int
    neighborhoodstatesmap::Dict{Float64, Int64}
    rule::Dict{Int,Int}
    weights::Array{Float64,1}

    # constructor
    MyTwoDimensionalTotalisticWolframRuleModel() = new()
end


"""
    mutable struct MyPeriodicRectangularGridWorldModel <: AbstractWorldModel

The `MyPeriodicRectangularGridWorldModel` mutable struct represents a rectangular grid world model.

### Required fields
- `number_of_rows::Int`: The number of rows in the grid
- `number_of_cols::Int`: The number of columns in the grid
- `coordinates::Dict{Int,Tuple{Int,Int}}`: A dictionary that holds the coordinates of each cell in the grid where the `key` is the cell index and the `value` is a tuple of the row and column index
- `states::Dict{Tuple{Int,Int},Int}`: A dictionary that holds the states of each cell in the grid where the `key` is the cell coordinates and the `value` is the state index
- `moves::Dict{Int,Tuple{Int,Int}}`: A dictionary that holds the moves that can be made from each cell in the grid where the `key` is the move index and the `value` is a tuple of the row and column changes associated with the move
- `rewards::Dict{Int,Float64}`: A dictionary that holds the rewards for each cell in the grid where the `key` is the cell index and the `value` is the reward
"""
mutable struct MyPeriodicRectangularGridWorldModel <: AbstractWorldModel

    # data -
    number_of_rows::Int
    number_of_cols::Int
    number_of_states::Int
    coordinates::Dict{Int,Tuple{Int,Int}}
    states::Dict{Tuple{Int,Int},Int}
    moves::Dict{Int,Tuple{Int,Int}}
    rewards::Dict{Int,Float64}
    stateactionnextstate::Array{Int,2}

    # constructor -
    MyPeriodicRectangularGridWorldModel() = new();
end

"""
    mutable struct MyWolframRuleQLearningAgentModel <: AbstractLearningModel

The `MyWolframRuleQLearningAgentModel` mutable struct represents a Q-learning agent model for a Wolfram rule.

### Required fields
- `states::Array{Int,1}`: The states of the model
- `actions::Array{Int,1}`: The actions of the model
- `γ::Float64`: The discount factor
- `α::Float64`: The learning rate
- `Q::Array{Float64,2}`: The Q-table of the model   
"""
mutable struct MyWolframRuleQLearningAgentModel <: AbstractLearningModel

    # data -
    states::Array{Int,1}
    actions::Array{Int,1}
    γ::Float64
    α::Float64 
    Q::Array{Float64,2}

    # constructor
    MyWolframRuleQLearningAgentModel() = new();
end

"""
    mutable struct MyWolframGridWorldModel <: AbstractWorldModel

The `MyWolframGridWorldModel` mutable struct represents a grid world model for a Wolfram rule.

### Required fields
- `number_of_states::Int64`: The number of states of the agent
- `data::Dict{Int64, Array{Int64,1}}`: A dictionary that holds temporal playback data where the `key` is the time step and the `value` is an array holding the neighborhood (first radius elemnts) of the agent and the next state (last element).
- `policymap::Dict{Float64, Int64}`: A dictionary that holds the policy map where the `key` is the average of the neighborhood and the `value` is the state index
- `world::Function`: A function that represents the world model. The function takes the world model, the time step `t`, the state `s` and proposed action `a` and returns the next state of the agent, and the immediate reward for taking action `a` in state `s`.
"""
mutable struct MyWolframGridWorldModel <: AbstractWorldModel

    # data -
    number_of_states::Int64
    data::Dict{Int64, Array{Int64,1}}
    policymap::Dict{Float64, Int64}
    world::Function

    # constructor -
    MyWolframGridWorldModel() = new();
end

""" 
    mutable struct MyTwoDimensionalFixedBoundaryGridWorld <: AbstractWorldModel

Model for the two-dimensional fixed boundary grid world of the Wolfram rules.

### Required fields
- `states::Dict{Int, Tuple{Int, Int}}`: A dictionary that holds the states of each cell in the grid where the `key` is the cell index and the `value` is a tuple of the row and column index
- `coordinates::Dict{Tuple{Int, Int}, Int}`: A dictionary that holds the coordinates of each cell in the grid where the `key` is a tuple of the row and column index and the `value` is the cell index
- `width::Int`: The width of the grid
- `height::Int`: The height of the grid
"""
mutable struct MyTwoDimensionalFixedBoundaryGridWorld <: AbstractWorldModel
    
    # data -
    states::Dict{Int, Tuple{Int, Int}}
    coordinates::Dict{Tuple{Int, Int}, Int}
    width::Int
    height::Int

    # constructor -
    MyTwoDimensionalFixedBoundaryGridWorld() = new();
end

"""
    mutable struct MyElementaryWolframRuleModel <: AbstractPolicyModel

The `MyElementaryWolframRuleModel` mutable struct represents an elementary Wolfram rule model.

### Required fields
- `index::Int`: The index of the rule
- `radius::Int`: The radius, i.e, the number of cells that influence the next state for this rule
- `colors::Int`: The number of colors in the rule, i.e., the number of states a cell can exist in
- `rule::Dict{Int, Int}`: A dictionary that holds the rule where the `key` is the binary representation of the neighborhood and the `value` is the next state
"""
mutable struct MyElementaryWolframRuleModel <: AbstractPolicyModel
    
    # data -
    index::Int
    radius::Int
    colors::Int
    rule::Dict{Int, Int}

    # constructor
    MyElementaryWolframRuleModel() = new()
end

"""
    mutable struct MySimpleTwoDimensionalAgentModel <: AbstractAgentModel

The `MySimpleTwoDimensionalAgentModel` mutable struct represents a simple two-dimensional agent model for a Wolfram rule.

### Required fields
- `index::Int`: The index of the agent
- `rule::Union{MyElementaryWolframRuleModel, MyTotalisticWolframRuleModel}`: The Wolfram rule model used by the agent
- `connections::Array{Int,1}`: An array that holds the indices of the cells in the agent's neighborhood
"""
mutable struct MySimpleTwoDimensionalAgentModel <: AbstractAgentModel
    
    # data -
    index::Int
    rule::Union{MyElementaryWolframRuleModel, MyTwoDimensionalTotalisticWolframRuleModel}
    connections::Array{Int,1} # which cells are in my neighborhood?

    # constructor -
    MySimpleTwoDimensionalAgentModel() = new();
end




# -------------------------------------------------------------------------------------------------------------- #
