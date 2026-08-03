function _build(modeltype::Type{T}, data::NamedTuple) where T <: Union{AbstractEquityPriceTreeModel, AbstractAssetModel, AbstractTreasuryDebtSecurity, AbstractStochasticChoiceProblem, AbstractReturnModel, AbstractSamplingModel, AbstractWorldModel, AbstractPolicyModel, AbstractLearningModel, MyBinaryInterestRateLatticeNodeModel}
    
    # build an empty model
    model = modeltype();

    # if we have options, add them to the contract model -
    if (isempty(data) == false)
        for key ∈ fieldnames(modeltype)
            
            # check the for the key - if we have it, then grab this value
            value = nothing
            if (haskey(data, key) == true)
                # get the value -
                value = data[key]
            end

            # set -
            setproperty!(model, key, value)
        end
    end
 
    # return -
    return model
end

# """
#     _build_nodes_level_dictionary(levels::Int64) -> Dict{Int64,Array{Int64,1}}
# """
function _build_nodes_level_dictionary(levels::Int64)::Dict{Int64,Array{Int64,1}}

    # initialize -
    index_dict = Dict{Int64, Array{Int64,1}}()

    counter = 0
    for l = 0:levels
        
        # create index set for this level -
        index_array = Array{Int64,1}()
        for _ = 1:(l+1)
            counter = counter + 1
            push!(index_array, counter)
        end

        index_dict[l] = (index_array .- 1) # zero based
    end

    # return -
    return index_dict
end

function _build_connectivity_dictionary(h::Int)::Dict{Int64, Array{Int64,1}}

    # compute connectivity - 
    number_items_per_level = [i for i = 1:(h+1)]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for _ = 1:value
            push!(tmp_array, theta)
        end
        theta = theta + 1
    end

    N = sum(number_items_per_level[1:(h)])
    connectivity_index_array = Array{Int64,2}(undef, N, 3)
    for row_index = 1:N

        # index_array[row_index,1] = tmp_array[row_index]
        connectivity_index_array[row_index, 1] = row_index
        connectivity_index_array[row_index, 2] = row_index + 1 + tmp_array[row_index]
        connectivity_index_array[row_index, 3] = row_index + 2 + tmp_array[row_index]
    end
    
    # adjust for zero base -
    zero_based_array = connectivity_index_array .- 1;

    # build connectivity dictionary -
    N = sum(number_items_per_level[1:end-1])
    connectivity = Dict{Int64, Array{Int64,1}}()
    for i ∈ 0:(N-1)
        # grab the connectivity -
        connectivity[i] = reverse(zero_based_array[i+1,2:end])
    end

    # put it back in order -
    for i ∈ 0:(N-1)
        # grab the connectivity -
        connectivity[i] = zero_based_array[i+1,2:end]
    end

    return connectivity
end

# Old IMPL that works - do not delete, just in case .... switched to two phase impl, *seems* to be ok??
# However, we need this here for backward compatibility
function build(modeltype::Type{MyAdjacencyBasedCRREquityPriceTree}; 
    h::Int = 1, μ::Float64 = 0.01, σ::Float64 = 0.1, T::Float64 = (1.0/365.0), 
    Sₒ::Float64 = 1.0)::MyAdjacencyBasedCRREquityPriceTree
     
    # initialize -
    model = MyAdjacencyBasedCRREquityPriceTree(); # this model is empty
    nodes_dictionary = Dict{Int, MyCRRLatticeNodeModel}()

    # compute u, d and p
    ΔT = T / h
    u = exp(σ * sqrt(ΔT))
    d = 1.0/u;
    p = (exp(µ * ΔT) - d) / (u - d)

    # # compute connectivity - 
    # number_items_per_level = [i for i = 1:(h+1)]
    # tmp_array = Array{Int64,1}()
    # theta = 0
    # for value in number_items_per_level
    #     for _ = 1:value
    #         push!(tmp_array, theta)
    #     end
    #     theta = theta + 1
    # end

    # N = sum(number_items_per_level[1:(h)])
    # connectivity_index_array = Array{Int64,2}(undef, N, 3)
    # for row_index = 1:N

    #     # index_array[row_index,1] = tmp_array[row_index]
    #     connectivity_index_array[row_index, 1] = row_index
    #     connectivity_index_array[row_index, 2] = row_index + 1 + tmp_array[row_index]
    #     connectivity_index_array[row_index, 3] = row_index + 2 + tmp_array[row_index]
    # end
    
    # # adjust for zero base -
    # zero_based_array = connectivity_index_array .- 1;

    # # build connectivity dictionary -
    # N = sum(number_items_per_level[1:end-1])
    # connectivity = Dict{Int64, Array{Int64,1}}()
    # for i ∈ 0:(N-1)
    #     # grab the connectivity -
    #     connectivity[i] = reverse(zero_based_array[i+1,2:end])
    # end

    # compute the price and probability, and store in the nodes dictionary
    counter = 0;
    for t ∈ 0:h

        # prices -
        for k ∈ 0:t
            
            t′ = big(t)
            k′ = big(k)

            # compute the prices and P for this level
            price = Sₒ*(u^(t-k))*(d^(k));
            P = binomial(t′,k′)*(p^(t-k))*(1-p)^(k);

            # create a node model -
            node = MyCRRLatticeNodeModel();
            node.price = price
            node.probability = P;
            node.intrinsic = 0.0; # intrinsic value gets updated later, for now -> 0.0
            node.extrinsic = 0.0; # extrinsic value gets updated later, for now -> 0.0
            
            # push this into the array -
            nodes_dictionary[counter] = node;
            counter += 1
        end
    end

    # # put it back in order -
    # for i ∈ 0:(N-1)
    #     # grab the connectivity -
    #     connectivity[i] = zero_based_array[i+1,2:end]
    # end

    # # set the data, and connectivity for the model -
    model.data = nodes_dictionary;
    # model.connectivity = connectivity;
    model.connectivity = _build_connectivity_dictionary(h)
    model.levels = _build_nodes_level_dictionary(h)
    model.p = p;
    model.u = u;
    model.ΔT = ΔT
    model.μ = μ
    model.d = d
    model.T = T

    # return -
    return model
end

# short build methods -
build(model::Type{MyLongstaffSchwartzContractPricingModel}, data::NamedTuple)::MyLongstaffSchwartzContractPricingModel = _build(model, data)
build(model::Type{MyBlackScholesContractPricingModel}, data::NamedTuple)::MyBlackScholesContractPricingModel = _build(model, data)

"""
    function build(model::Type{MySymmetricBinaryInterestRateLatticeModel}, data::NamedTuple) -> MySymmetricBinaryInterestRateLatticeModel
"""
build(model::Type{MySymmetricBinaryInterestRateLatticeModel}, data::NamedTuple)::MySymmetricBinaryInterestRateLatticeModel = _build(model, data);
build(model::Type{MyBinaryInterestRateLatticeNodeModel}, data::NamedTuple)::MyBinaryInterestRateLatticeNodeModel = _build(model, data);


"""
    function build(model::Type{MyBinomialEquityPriceTree}, data::NamedTuple) -> MyBinomialEquityPriceTree

This `build` method constructs an instance of the [`MyBinomialEquityPriceTree`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyBinomialEquityPriceTree}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `u::Float64`: The up-factor for the lattice (return for an up move during a single time step)
- `d::Float64`: The down-factor for the lattice (return for a down move during a single time step)
- `p::Float64`: The probability of an up move in the lattice

The other properties of the [`MyBinomialEquityPriceTree`](@ref) model are set to `nothing` by default and are populated during the construction of the model using the 
`populate` method.
"""
build(model::Type{MyBinomialEquityPriceTree}, data::NamedTuple)::MyBinomialEquityPriceTree = _build(model, data);

"""
    function build(model::Type{MySingleIndexModel}, data::NamedTuple) -> MySingleIndexModel

This `build` method constructs an instance of the [`MySingleIndexModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MySingleIndexModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `α::Float64`: The firm specific unexplained return
- `β::Float64`: The relationship between the firm and the market
- `r::Float64`: The risk-free rate of return
- `ϵ::Distribution`: The random shocks to the model (unexplained return) 

### Return
This function returns an instance of the [`MySingleIndexModel`](@ref) type. 

### See also:
- The unexplained return is modeled as a random variable, and the user can specify the distribution of this variable using the `ϵ::Distribution` argument.
See the [Distributions.jl package](https://juliastats.org/Distributions.jl/stable/) package for more information on the available distributions.
"""
build(model::Type{MySingleIndexModel}, data::NamedTuple) = _build(model, data);


"""
    function build(model::Type{MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem}, data::NamedTuple)  -> MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem

This `build` method constructs an instance of the [`MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `μ::Array{Float64,1}`: The drift rates of the assets.
"""
build(model::Type{MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem}, data::NamedTuple)::MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem = _build(model, data);

"""
   function build(model::Type{MyMarkowitzRiskyRiskFreePortfolioChoiceProblem}, data::NamedTuple) -> MyMarkowitzRiskyRiskFreePortfolioChoiceProblem

This `build` method constructs an instance of the [`MyMarkowitzRiskyRiskFreePortfolioChoiceProblem`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyMarkowitzRiskyRiskFreePortfolioChoiceProblem}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `Σ::Array{Float64,2}`: The covariance matrix of the risky asset returns
- `μ::Array{Float64,1}`: The expected returns of the risky assets
- `bounds::Array{Float64,2}`: The bounds on the risky asset weights
- `R::Float64`: The desired return of the portfolio
- `initial::Array{Float64,1}`: The initial portfolio weights
- `risk_free_rate::Float64`: The risk-free rate of return
"""
build(model::Type{MyMarkowitzRiskyRiskFreePortfolioChoiceProblem}, data::NamedTuple)::MyMarkowitzRiskyRiskFreePortfolioChoiceProblem = _build(model, data);

"""
    function build(model::Type{MySharpeRatioPortfolioChoiceProblem}, data::NamedTuple) -> MySharpeRatioPortfolioChoiceProblem

This `build` method constructs an instance of the [`MySharpeRatioPortfolioChoiceProblem`](@ref) type using the data 
in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MySharpeRatioPortfolioChoiceProblem}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `μ::Array{Float64,1}`: The expected returns of the risky assets.
- `bounds::Array{Float64,2}`: The bounds on the risky asset weights.
- `R::Float64`: The desired return of the portfolio.
- `initial::Array{Float64,1}`: The initial portfolio weights.
- `risk_free_rate::Float64`: The risk-free rate of return.
"""
build(model::Type{MySharpeRatioPortfolioChoiceProblem}, data::NamedTuple)::MySharpeRatioPortfolioChoiceProblem = _build(model, data);

"""
    function build(model::Type{MyAdjacencyBasedCRREquityPriceTree}, data::NamedTuple) -> MyAdjacencyBasedCRREquityPriceTree

This `build` method constructs an instance of the [`MyAdjacencyBasedCRREquityPriceTree`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyAdjacencyBasedCRREquityPriceTree}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `μ::Float64`: The drift rate of the asset price. For a risk-neutral measure, this is the risk-free rate.
- `σ::Float64`: The volatility of the asset price. This is the implied volatility for a risk-neutral measure.
- `T::Float64`: The time to expiration of the option contract (measured in units of years)
"""
build(model::Type{MyAdjacencyBasedCRREquityPriceTree}, data::NamedTuple)::MyAdjacencyBasedCRREquityPriceTree = _build(model, data);

"""
    function build(type::Type{MyGeneralAdjacencyRecombiningCommodityPriceTree}, data::NamedTuple) -> MyGeneralAdjacencyRecombiningCommodityPriceTree

Builds an `MyGeneralAdjacencyRecombiningCommodityPriceTree` model given the data in the `NamedTuple`. 
This method builds the connectivity of the tree. To compute the price at each node, use the `populate!` method.

### Arguments
- `type::Type{MyGeneralAdjacencyRecombiningCommodityPriceTree}`: The type of the model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data` `NamedTuple` must contain the following fields:
- `h::Int64`: The height of the tree.
- `price::Float64`: The price at the root node.
- `u::Float64`: The price increase factor.
- `d::Float64`: The price decrease factor.

### Returns
- `MyGeneralAdjacencyRecombiningCommodityPriceTree`: the price tree model holding the computed price data.
"""
function build(modeltype::Type{MyGeneralAdjacencyRecombiningCommodityPriceTree}, 
    data::NamedTuple)::MyGeneralAdjacencyRecombiningCommodityPriceTree

    # get data -
    n = data.n; # branching factor
    h = data.h; # height of the tree
    model = modeltype(); # create an empty model
    
    # initialize -
    connectivity = Dict{Int64, Array{Int64,1}}()
    Nₕ = binomial(h + n, h) # number of nodes in the tree

    # main loop -
    for i ∈ 0:(Nₕ - 1)
        connectivity[i] = children_indices(i, n; base=0)
    end

    
    # set the data, and connectivity for the model -
    model.data = nothing; # we don't have any data yet, set as nothing
    model.connectivity = connectivity;
    model.h = h; # height of the tree
    model.n = n; # branching factor

    # return -
    return model;
end

"""
    function build(model::Type{MyEuropeanCallContractModel}, data::NamedTuple) -> MyEuropeanCallContractModel

This `build` method constructs an instance of the [`MyEuropeanCallContractModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyEuropeanCallContractModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `K::Float64`: The strike price of the contract.

The other fields of the [`MyEuropeanCallContractModel`](@ref) model are set to `nothing` by default. 
These optional fields can be updated by the user after the model is built, or by passing the values in the `data::NamedTuple` argument.
"""
build(model::Type{MyEuropeanCallContractModel}, data::NamedTuple)::MyEuropeanCallContractModel = _build(model, data)

"""
    function build(model::Type{MyEuropeanPutContractModel}, data::NamedTuple) -> MyEuropeanPutContractModel

This `build` method constructs an instance of the [`MyEuropeanPutContractModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple). 

### Arguments
- `model::Type{MyEuropeanPutContractModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `K::Float64`: The strike price of the contract.

The other fields of the [`MyEuropeanPutContractModel`](@ref) model are set to `nothing` by default.
These optional fields can be updated by the user after the model is built, or by passing the values in the `data::NamedTuple` argument.
"""
build(model::Type{MyEuropeanPutContractModel}, data::NamedTuple)::MyEuropeanPutContractModel = _build(model, data)


"""
    function build(model::Type{MyAmericanPutContractModel}, data::NamedTuple) -> MyAmericanPutContractModel

This `build` method constructs an instance of the [`MyAmericanPutContractModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyAmericanPutContractModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `K::Float64`: The strike price of the contract.

The other fields of the [`MyAmericanPutContractModel`](@ref) model are set to `nothing` by default. 
These optional fields can be updated by the user after the model is built, or by passing the values in the `data::NamedTuple` argument.
"""
build(model::Type{MyAmericanPutContractModel}, data::NamedTuple)::MyAmericanPutContractModel = _build(model, data)

"""
    function build(model::Type{MyAmericanCallContractModel}, data::NamedTuple) -> MyAmericanCallContractModel

This `build` method constructs an instance of the [`MyAmericanCallContractModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyAmericanCallContractModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `K::Float64`: The strike price of the contract.

The other fields of the [`MyAmericanCallContractModel`](@ref) model are set to `nothing` by default.
These optional fields can be updated by the user after the model is built, or by passing the values in the `data::NamedTuple` argument.
"""
build(model::Type{MyAmericanCallContractModel}, data::NamedTuple)::MyAmericanCallContractModel = _build(model, data)

"""
    function build(model::Type{MyGeometricBrownianMotionEquityModel}, data::NamedTuple) -> MyGeometricBrownianMotionEquityModel

This `build` method constructs an instance of the [`MyGeometricBrownianMotionEquityModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyGeometricBrownianMotionEquityModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `μ::Float64`: The drift of the process.
- `σ::Float64`: The volatility of the process.
"""
build(model::Type{MyGeometricBrownianMotionEquityModel}, data::NamedTuple)::MyGeometricBrownianMotionEquityModel = _build(model, data)

"""
    function build(model::Type{MyMultipleAssetGeometricBrownianMotionEquityModel}, data::NamedTuple) -> MyMultipleAssetGeometricBrownianMotionEquityModel

This `build` method constructs an instance of the [`MyMultipleAssetGeometricBrownianMotionEquityModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyMultipleAssetGeometricBrownianMotionEquityModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `μ::Array{Float64,1}`: Array of drift rates for each asset.
- `A::Array{Float64,2}`: [Cholesky decomposition](https://en.wikipedia.org/wiki/Cholesky_decomposition) of the covariance matrix of the process.
"""
build(model::Type{MyMultipleAssetGeometricBrownianMotionEquityModel}, data::NamedTuple)::MyMultipleAssetGeometricBrownianMotionEquityModel = _build(model, data)


"""
    function build(model::Type{MyHestonModel}, data::NamedTuple) -> MyHestonModel

This `build` method constructs an instance of the [`MyHestonModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyHestonModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model. 

The `data::NamedTuple` must contain the following `keys`:
- `μ::Function`: The long-term mean of the process.
- `κ::Function`: The mean reversion rate of the process.
- `θ::Function`: The volatility of the process.
- `ξ::Function`: The volatility of the volatility of the process.
- `Σ::Array{Float64,2}`: The covariance matrix of the process.
"""
build(model::Type{MyHestonModel}, data::NamedTuple)::MyHestonModel = _build(model, data);


"""
    function build(model::Type{MyUSTreasuryCouponSecurityModel}, data::NamedTuple) -> MyUSTreasuryCouponSecurityModel

This `build` method constructs an instance of the [`MyUSTreasuryCouponSecurityModel`](@ref) type using the data in the [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{MyUSTreasuryCouponSecurityModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model. 

The `data::NamedTuple` must contain the following `keys`:
- `par::Float64`: Par value of the bond
- `rate::Union{Nothing, Float64}`: Annualized effective discount rate
- `coupon::Union{Nothing, Float64}`: Coupon interest rate
- `T::Union{Nothing,Float64}`: Duration in years of the note or bond, measured as a 365 day or a 52 week year
- `λ::Int`: Number of coupon payments per year (typically 2)

### Return
This function returns an instance of the [`MyUSTreasuryCouponSecurityModel`](@ref) type. 
To populate the model, use the `price` function or a short-cut function involving a compounding model.

### Example
Let's build a [`MyUSTreasuryCouponSecurityModel`](@ref) instance and populate the `price`, `cashflow` and `discount` datastructures for a `T = 20-yr` 
bond, with a coupon rate of `c = 1.750%`, a yield (discount rate) `rate = 1.850%`, two coupon payments per year, i.e., ``\\lambda = 2`` 
and a face (par) value of ``V_{P}`` = `100 USD`:

```julia
test_bond = build(MyUSTreasuryCouponSecurityModel, (
    T = 20.0, rate = 0.01850, coupon = 0.01750, λ = 2, par = 100.0
)) |> discount_model;
```

where the `discount_model` refers to either a [`DiscreteCompoundingModel`](@ref) or a [`ContinuousCompoundingModel`](@ref) instance.

"""
build(model::Type{MyUSTreasuryCouponSecurityModel}, data::NamedTuple)::MyUSTreasuryCouponSecurityModel = _build(model, data);


"""
    function build(model::Type{MyUSTreasuryZeroCouponBondModel}, data::NamedTuple) -> MyUSTreasuryZeroCouponBondModel

This `build` method constructs an instance of the [`MyUSTreasuryZeroCouponBondModel`](@ref) type using the 
data in the [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple) argument.

### Arguments
- `model::Type{MyUSTreasuryZeroCouponBondModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model. 

The `data::NamedTuple` argument must contain the following `keys`:
- `par::Float64`: The face or par value of the bond
- `rate::Union{Nothing, Float64}`: Effective annual interest rate (discount rate specified as a decimal)
- `T::Union{Nothing,Float64}`: Duration in years measured as a 365 day or a 52 week year
- `n::Int`: Number of compounding periods per year (typically 2)

"""
build(model::Type{MyUSTreasuryZeroCouponBondModel}, data::NamedTuple)::MyUSTreasuryZeroCouponBondModel = _build(model, data);


"""
    function build(modeltype::Type{MyOrnsteinUhlenbeckModel}, data::NamedTuple) -> MyOrnsteinUhlenbeckModel

This method builds an instance of the [`MyOrnsteinUhlenbeckModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyOrnsteinUhlenbeckModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model. 

The `data::NamedTuple` argument must contain the following `keys`:
- `μ::Float64`: The long-term mean of the process.
- `σ::Float64`: The volatility of the process.
- `θ::Float64`: The mean reversion rate of the process.
"""
function build(modeltype::Type{MyOrnsteinUhlenbeckModel}, data::NamedTuple)::MyOrnsteinUhlenbeckModel

    # initialize -
    model = modeltype();

    model.μ = data.μ
    model.σ = data.σ
    model.θ = data.θ

    # return -
    return model;
end

"""
    function build(modeltype::Type{MySisoLegSHippoModel}, data::NamedTuple) -> MySisoLegSHippoModel

This `build` method constructs an instance of the [`MySisoLegSHippoModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).
This implementation uses the bilinear method to discretize the model, where the `A` and `B` matrices are computed
using the [Leg-S parameterization](https://arxiv.org/abs/2008.07669).

### Arguments
- `modeltype::Type{MySisoLegSHippoModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model. 

The `data::NamedTuple` must contain the following `keys`:
- `number_of_hidden_states::Int64`: The number of hidden states in the model.
- `Δt::Float64`: The time step size used to discretize the model (constant).
- `uₒ::Array{Float64,1}`: The initial input to the model.
- `C::Array{Float64,1}`: The output matrix of the model.
"""
function build(modeltype::Type{MySisoLegSHippoModel}, data::NamedTuple)::MySisoLegSHippoModel

    # initialize -
    model = modeltype(); # build an empty model

    # get data -
    number_of_hidden_states = data.number_of_hidden_states;
    Δt = data.Δt;
    uₒ = data.uₒ;
    uₒval = uₒ isa AbstractArray ? uₒ[1] : uₒ;
    C = data.C;

    # A matrix -
    A = zeros(number_of_hidden_states,number_of_hidden_states);
    for i ∈ 1:number_of_hidden_states
        for j ∈ 1:number_of_hidden_states
        
            a = -sqrt((2*i+1))*sqrt((2*j+1));
            b = nothing;
            if (i > j)
                b = 1;
            elseif (i == j)
                b = (i+1)/(2*i+1);
            else
                b = 0
            end
            A[i,j] = a*b;
        end
    end

    # B matrix -
    B = zeros(number_of_hidden_states);
    for i ∈ 1:number_of_hidden_states
        B[i] = (2*i+1) |> sqrt
    end


    # discretize the arrays using the Bilinear method -
    Â = inv((I - (Δt/2)*A))*(I + (Δt/2)*A);
    B̂ = inv((I - (Δt/2)*A))*(Δt)*B;
    Ĉ = C; # initialize a random C matrix (user can update this later)
    D̂ = zeros(number_of_hidden_states); # initialize a zero D matrix (user can update this later)

    # set the values -
    model.Â = Â;
    model.B̂ = B̂;
    model.Ĉ = Ĉ;
    model.D̂ = D̂;
    model.n = number_of_hidden_states;
    model.Xₒ = B̂*uₒval;

    # return -
    return model;
end

# --- Markov models --------------------------------------------------------------------------- #
"""
   function build(model::Type{M}, data::NamedTuple) -> AbstractMarkovModel where {M <: AbstractMarkovModel}

This `build` method constructs a concrete instance of type `M` where `M` is a subtype of `AbstractMarkovModel` type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{M}`: The type of model to build. This type must be a subtype of `AbstractMarkovModel`.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` argument must contain the following `keys`:
- `states::Array{Int64,1}`: The states of the model.
- `T::Array{Float64,2}`: The transition matrix of the model.
- `E::Array{Float64,2}`: The emission matrix of the model.
"""
function build(model::Type{MyHiddenMarkovModel}, data::NamedTuple)::MyHiddenMarkovModel
    
    # initialize -
    m = model(); # build an empty model, add data to it below
    transition = Dict{Int64, Categorical}();
    emission = Dict{Int64, Categorical}();

    # get stuff from the data NamedTuple -
    states = data.states;
    T = data.T; # this is the transition matrix
    E = data.E; # this is the emission matrix

    # build the transition and emission distributions -
    for s ∈ states
        transition[s] = Categorical(T[s,:]);
        emission[s] = Categorical(E[s,:]);
    end

    # add data to the model -
    m.transition = transition;
    m.emission = emission;
    m.states = states;

    # return -
    return m;
end

"""
   function build(model::Type{M}, data::NamedTuple) -> AbstractMarkovModel where {M <: AbstractMarkovModel}

This `build` method constructs a concrete instance of type `M` where `M` is a subtype of `AbstractMarkovModel` type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `model::Type{M}`: The type of model to build. This type must be a subtype of `AbstractMarkovModel`.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` argument must contain the following `keys`:
- `states::Array{Int64,1}`: The states of the model.
- `T::Array{Float64,2}`: The transition matrix of the model.
- `E::Array{Float64,2}`: The emission matrix of the model.
"""
function build(model::Type{MyHiddenMarkovModelWithJumps}, data::NamedTuple)::MyHiddenMarkovModelWithJumps
    
    # initialize -
    m = model(); # build an empty model, add data to it below
    transition = Dict{Int64, Categorical}();
    inverse_transition = Dict{Int64, Categorical}();
    emission = Dict{Int64, Categorical}();
    ϵ = data.ϵ;
    λ = data.λ;

    # get stuff from the data NamedTuple -
    states = data.states;
    T = data.T; # this is the transition matrix
    E = data.E; # this is the emission matrix

    # build the transition and emission distributions -
    for s ∈ states
        transition[s] = Categorical(T[s,:]);
        emission[s] = Categorical(E[s,:]);
    end

    # build the inverse transition matrix -
    for s ∈ states
        F = sum(1 .- T[s,:]);
        d = (1/F)*(1 .- T[s,:]);
        inverse_transition[s] = Categorical(d);
    end

    # add data to the model -
    m.transition = transition;
    m.inverse_transition = inverse_transition;
    m.emission = emission;
    m.states = states;
    m.ϵ = ϵ;
    m.λ = λ;
    m.jump_distribution = Poisson(λ); # jump distribution

    # return -
    return m;
end
# --------------------------------------------------------------------------------------------- #

# -- Bandit, MDP and RL models --------------------------------------------------------------- #
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
build(modeltype::Type{MyEpsilonSamplingBanditModel}, data::NamedTuple)::MyEpsilonSamplingBanditModel = _build(modeltype, data);

"""
    function build(modeltype::Type{MyTickerPickerWorldModel}, data::NamedTuple) -> MyTickerPickerWorldModel

This `build` method constructs an instance of the [`MyTickerPickerWorldModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyTickerPickerWorldModel}`: The type of model to build, in this case, the [`MyTickerPickerWorldModel`](@ref) type.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `tickers::Array{String,1}`: An array of ticker symbols that we explore
- `data::Dict{String, DataFrame}`: A dictionary that holds the data for each ticker symbol
- `horizon::Int64`: The number of days to look ahead for the ticker picker
- `buffersize::Int64`: The size of the buffer for storing the data
"""
build(modeltype::Type{MyTickerPickerWorldModel}, data::NamedTuple)::MyTickerPickerWorldModel = _build(modeltype, data);



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
    function build(modeltype::Type{MyTickerPickerRiskAwareWorldModel}, data::NamedTuple) -> MyTickerPickerRiskAwareWorldModel

This `build` method constructs an instance of the [`MyTickerPickerRiskAwareWorldModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyTickerPickerRiskAwareWorldModel}`: The type of model to build, in this case, the [`MyTickerPickerRiskAwareWorldModel`](@ref) type.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `tickers::Array{String,1}`: An array of ticker symbols that we explore
- `data::Dict{String, DataFrame}`: A dictionary that holds the price data for each ticker symbol
- `risk_free_rate::Float64`: The risk-free rate of return in the world (assumed constant)
- `world::Function`: A function that represents the world model. The function takes an action `a`, data about the world, and returns the reward `r` for taking action `a`.
- `Δt::Float64`: The time step size in the world model
- `buffersize::Int64`: The size of the buffer used in the world model
- `risk::Dict{String, Float64}`: A dictionary that holds the risk measure for each ticker symbol
"""
build(modeltype::Type{MyTickerPickerRiskAwareWorldModel}, data::NamedTuple)::MyTickerPickerRiskAwareWorldModel = _build(modeltype, data);



"""
    function build(modeltype::Type{MyWolframRuleQLearningAgentModel}, data::NamedTuple) -> MyWolframRuleQLearningAgentModel
"""
build(modeltype::Type{MyWolframRuleQLearningAgentModel}, data::NamedTuple)::MyWolframRuleQLearningAgentModel = _build(modeltype, data);


"""
    function build(modeltype::Type{MyOneDimensionalElementarWolframRuleModel}, data::NamedTuple) -> MyOneDimensionalElementarWolframRuleModel

This `build` method constructs an instance of the [`MyOneDimensionalElementarWolframRuleModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyOneDimensionalElementarWolframRuleModel}`: The type of model to build, in this case, the [`MyOneDimensionalElementarWolframRuleModel`](@ref) type.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `index::Int64`: The index of the Wolfram rule
- `colors::Int64`: The number of colors in the rule
- `radius::Int64`: The radius, i.e., the number of cells to consider in the rule

### Return
This function returns a populated instance of the [`MyOneDimensionalElementarWolframRuleModel`](@ref) type.
"""
function build(modeltype::Type{MyOneDimensionalElementarWolframRuleModel}, 
    data::NamedTuple)::MyOneDimensionalElementarWolframRuleModel

    # initialize -
    index = data.index;
    colors = data.colors;
    radius = data.radius;

    # create an empty model instance -
    model = MyOneDimensionalElementarWolframRuleModel();
    rule = Dict{Int,Int}();

    # build the rule -
    number_of_states = colors^radius;
    states = digits(index, base=colors, pad=number_of_states);
    for i ∈ 0:number_of_states-1
        rule[i] = states[i+1];
    end
    
    # set the data on the object
    model.index = index;
    model.rule = rule;
    model.radius = radius;
    model.number_of_colors = colors;

    # return
    return model;
end

function build(modeltype::Type{MyOneDimensionalTotalisticWolframRuleModel}, 
    data::NamedTuple)::MyOneDimensionalTotalisticWolframRuleModel


    # initialize -
    index = data.index;
    levels = data.colors;
    radius = data.radius;

    # create instance, and storage for the model components that we are going to build
    model = modeltype();
    Q = Dict{Float64, Int64}();
    rule = Dict{Int,Int}();

    # build the rule -
    number_of_states = range(0, stop = (levels - 1), step = (1/radius)) |> length;
    states = digits(index, base = levels, pad = number_of_states);
    for i ∈ 0:number_of_states-1
        rule[i] = states[i+1];
    end

    # setup Q -
    values = range(0.0, stop=(levels - 1), step = (1/radius));
    for i ∈ eachindex(values)
        Q[round(values[i], digits=2)] = (i - 1);
    end
    
    # set the data on the object
    model.index = index;
    model.rule = rule;
    model.radius = radius;
    model.number_of_colors = levels;
    model.Q = Q;

    # return
    return model;
end

"""
    function build(modeltype::Type{MyTwoDimensionalTotalisticWolframRuleModel}, data::NamedTuple) -> MyTwoDimensionalTotalisticWolframRuleModel

This `build` method constructs an instance of the [`MyTwoDimensionalTotalisticWolframRuleModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyTwoDimensionalTotalisticWolframRuleModel}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `index::Int64`: The index of the Wolfram rule
- `colors::Int64`: The number of colors in the rule
- `radius::Int64`: The radius, i.e., the number of neighbor cells to consider in the rule

### Return
This function returns a populated instance of the [`MyTwoDimensionalTotalisticWolframRuleModel`](@ref) type.
"""
function build(modeltype::Type{MyTwoDimensionalTotalisticWolframRuleModel}, 
    data::NamedTuple)::MyTwoDimensionalTotalisticWolframRuleModel
    
    # initialize -
    index = data.index;
    levels = data.colors;
    radius = data.radius;

    # create instance, and storage for the model components that we are going to build
    model = modeltype();
    Q = Dict{Float64, Int64}();
    rule = Dict{Int,Int}();

    # build the rule -
    number_of_states = range(0, stop = (levels - 1), step = (1/radius)) |> length;
    states = digits(index, base = levels, pad = number_of_states);
    for i ∈ 0:number_of_states-1
        rule[i] = states[i+1];
    end

    # setup Q -
    values = range(0.0, stop=(levels - 1), step = (1/radius));
    for i ∈ eachindex(values)
        Q[round(values[i], digits=2)] = (i - 1);
    end

    # initialize the weights -
    weights = Array{Float64,1}(undef, radius);
    for i ∈ 1:radius
        weights[i] = 1.0/radius; # uniform weights
    end
    
    # set the data on the object
    model.index = index;
    model.rule = rule;
    model.radius = radius;
    model.number_of_colors = levels;
    model.neighborhoodstatesmap = Q;
    model.weights = weights;

    # return
    return model;
end
    
"""
    function build(type::MyPeriodicRectangularGridWorldModel, nrows::Int, ncols::Int, 
        rewards::Dict{Tuple{Int,Int}, Float64}; defaultreward::Float64 = -1.0) -> MyPeriodicRectangularGridWorldModel

The `build` method constructs an instance of the [`MyPeriodicRectangularGridWorldModel`](@ref) type using the data in the [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `type::MyPeriodicRectangularGridWorldModel`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `nrows::Int`: The number of rows in the grid
- `ncols::Int`: The number of columns in the grid
- `rewards::Dict{Tuple{Int,Int}, Float64}`: A dictionary that maps the coordinates of the grid to the rewards at those coordinates
- `defaultreward::Float64`: The default reward for the grid. This is set to `-1.0` by default.

### Return
This function returns a populated instance of the [`MyPeriodicRectangularGridWorldModel`](@ref) type.
"""
function build(modeltype::Type{MyPeriodicRectangularGridWorldModel}, 
    data::NamedTuple)::MyPeriodicRectangularGridWorldModel

    # initialize and empty model -
    model = MyPeriodicRectangularGridWorldModel()

    # get the data -
    nrows = data[:nrows]
    ncols = data[:ncols]
    rewards = data[:rewards]
    defaultreward = haskey(data, :defaultreward) == false ? -1.0 : data[:defaultreward]

    # derived data -
    nstates = nrows*ncols;
    nactions = 4; # up, down, left, right

    # setup storage
    rewards_dict = Dict{Int,Float64}()
    coordinates = Dict{Int,Tuple{Int,Int}}()
    states = Dict{Tuple{Int,Int},Int}()
    moves = Dict{Int,Tuple{Int,Int}}()
    stateactionmap = Array{Int,2}(undef, nstates, nactions);

    # build all the stuff 
    position_index = 1;
    for i ∈ 1:nrows
        for j ∈ 1:ncols
            coordinate = (i,j); # capture this corrdinate 
            coordinates[position_index] = coordinate;  # set the coordinate: map between index, and coordinate tuple
            states[coordinate] = position_index; # set the state: map between coordinate tuple, and index

            if (haskey(rewards,coordinate) == true)
                rewards_dict[position_index] = rewards[coordinate];
            else
                rewards_dict[position_index] = defaultreward;
            end

            # update position_index -
            position_index += 1;
        end
    end

    # setup the moves dictionary -
    moves[1] = (-1,0)   # a = 1 up
    moves[2] = (1,0)    # a = 2 down
    moves[3] = (0,-1)   # a = 3 left
    moves[4] = (0,1)    # a = 4 right

    # setup the state-action map -
    for i ∈ 1:nrows
        for j ∈ 1:ncols
            state = states[(i,j)];
            for a ∈ 1:nactions
                move = moves[a];
                newi = i + move[1];
                newj = j + move[2];
                newi = newi < 1 ? i : newi;
                newi = newi > nrows ? i : newi;
                newj = newj < 1 ? ncols : newj;
                newj = newj > ncols ? 1 : newj;
                newstate = states[(newi,newj)];
                stateactionmap[state,a] = newstate;
            end
        end
    end

    # add items to the model -
    model.rewards = rewards_dict
    model.coordinates = coordinates
    model.states = states;
    model.moves = moves;
    model.number_of_rows = nrows
    model.number_of_cols = ncols
    model.number_of_states = nstates
    model.stateactionnextstate = stateactionmap

    # return -
    return model
end

"""
    function build(modeltype::Type{MyWolframGridWorldModel}, data::NamedTuple) -> MyWolframGridWorldModel
"""
function build(modeltype::Type{MyWolframGridWorldModel}, data::NamedTuple)::MyWolframGridWorldModel 

    # build empty model -
    model = modeltype();

    # get data -
    model.number_of_states = data.number_of_states;
    model.data = data.data;
    model.policymap = data.policymap;
    model.world = data.world;

    # return 
    return model;
end

"""
    function build(modeltype::Type{MyTwoDimensionalFixedBoundaryGridWorld}, data::NamedTuple) -> MyTwoDimensionalFixedBoundaryGridWorld

This `build` method constructs an instance of the [`MyTwoDimensionalFixedBoundaryGridWorld`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MyTwoDimensionalFixedBoundaryGridWorld}`: The type of model to build.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `width::Int64`: The width of the grid world.
- `height::Int64`: The height of the grid world.
"""
function build(modeltype::Type{MyTwoDimensionalFixedBoundaryGridWorld}, data::NamedTuple)::MyTwoDimensionalFixedBoundaryGridWorld
    
    # initialize -
    model = modeltype();
    states = Dict{Int, Tuple{Int,Int}}()
    coordinates = Dict{Tuple{Int,Int},Int}()

    # get stuff from the data
    width = data.width;
    height = data.height;

    # build all the stuff 
    position_index = 1;
    for i ∈ 1:height # rows
        for j ∈ 1:width # cols
            
            # capture this corrdinate information -
            coordinate = (i,j);
            states[position_index] = coordinate;
            coordinates[coordinate] = position_index;

            # update position_index -
            position_index += 1;
        end
    end

    # set the data on the model -
    model.width = width;
    model.height = height;
    model.states = states;
    model.coordinates = coordinates;

    # return
    return model;
end

"""
    function build(modeltype::Type{MySimpleTwoDimensionalAgentModel}, 
        world::MyTwoDimensionalFixedBoundaryGridWorld, data::NamedTuple) -> MySimpleTwoDimensionalAgentModel

This `build` method constructs an instance of the [`MySimpleTwoDimensionalAgentModel`](@ref) type using the data in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple).

### Arguments
- `modeltype::Type{MySimpleTwoDimensionalAgentModel}`: The type of model to build.
- `world::MyTwoDimensionalFixedBoundaryGridWorld`: The grid world in which the agent operates.
- `data::NamedTuple`: The data to use to build the model.

The `data::NamedTuple` must contain the following `keys`:
- `index::Int64`: The index of the agent in the world.
- `rule::MyTwoDimensionalTotalisticWolframRuleModel`: The rule model that the agent uses to decide its actions.

"""
function build(modeltype::Type{MySimpleTwoDimensionalAgentModel}, 
    world::MyTwoDimensionalFixedBoundaryGridWorld, data::NamedTuple)::MySimpleTwoDimensionalAgentModel
    
    # create and empty instance. We'll fill this in with the data that we have
    model = modeltype();
    
    # get the data required to build the model -
    width = world.width; # width of the world
    height = world.height; # height of the world
    index = data.index; # index of the agent
    rule = data.rule # rule model
    radius = rule.radius; # radius of the rule model
    myposition = world.states[index]; # what is my position in the world?

    coordinates = world.coordinates; # coordinates of the world

    # setup the moves - 
    moves = Dict{Int, Tuple{Int,Int}}();
    moves[1] = (-1,0); # up
    moves[2] = (1,0); # down
    moves[3] = (0,-1); # left
    moves[4] = (0,1); # right
    moves[5] = (-1,-1); # up-left
    moves[6] = (-1,1); # up-right
    moves[7] = (1,-1); # down-left
    moves[8] = (1,1); # down-right

    # check: radius can only be 4 or 8, or custom connections
    connections = nothing;
    if radius == 4 || radius == 8
        connections = Array{Int,1}(undef, radius); # setup the connections - which cells are in my neighborhood?
        
        # setup the connections -
        for i ∈ 1:radius
            Δ = moves[i]; # get the move 
            newposition = myposition .+ Δ; # new position

            if (haskey(coordinates, newposition) == true)
                newindex = world.coordinates[newposition]; # what is the index of this new position?
                connections[i] = newindex; # set the connection 
            else
                connections[i] = -1; # set the connection to -1
            end
        end

    else
        throw(ArgumentError("Automatic neighborhood generation is supported for radius = {4 | 8}. Otherwise, specify the connections manually."))
    end

    # set data on the model -
    model.index = index;
    model.rule = rule;
    model.connections = connections;

    # return
    return model;
end
# -------------------------------------------------------------------------------------------- #
