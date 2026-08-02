# === PRIVATE BELOW HERE ============================================================================================= #
_payoff(contract::Union{MyEuropeanCallContractModel, MyAmericanCallContractModel}, S::Float64) = max(0.0, S - contract.K)
_payoff(contract::Union{MyEuropeanPutContractModel, MyAmericanPutContractModel}, S::Float64) = max(0.0, contract.K - S)
_rational(a, b) = max(a, b)
_encode(array,value) = findfirst(x->x>=value, array)
_U(x,λ) = x^λ
_IU(x,λ) = x^(1/λ);

# compute the intrinsic value 
function _intrinsic(model::T, underlying::Array{Float64,1})::Array{Float64,1} where {T<:AbstractAssetModel}

    # initialize -
    intrinsic_value_array = Array{Float64,1}()

    for value ∈ underlying
        (payoff_value, _) = _expiration(model, value)
        push!(intrinsic_value_array, payoff_value)
    end

    # rerturn -
    return intrinsic_value_array
end

function _expiration(contract::Union{MyEuropeanPutContractModel, MyAmericanPutContractModel}, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.sense
    K = contract.K
    premium = contract.premium
    number_of_contracts = 1;

    # we may not have a premium yet -
    if (isnothing(premium) == true)
        premium = 0.0;
    end

    payoff_value = 0.0
    profit_value = 0.0

    # PUT contract -
    payoff_value = number_of_contracts * direction * max((K - underlying), 0.0)
    profit_value = (payoff_value - direction * premium * number_of_contracts)

    # return -
    return (payoff_value, profit_value)
end

function _expiration(contract::Union{MyEuropeanCallContractModel, MyAmericanCallContractModel}, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.sense
    K = contract.K
    premium = contract.premium
    payoff_value = 0.0
    profit_value = 0.0
    number_of_contracts = 1;

    # we may not have a premium yet -
    if (isnothing(premium) == true)
        premium = 0.0;
    end

    # PUT contract -
    payoff_value = number_of_contracts * direction * max((underlying - K), 0.0)
    profit_value = (payoff_value - direction * premium * number_of_contracts)

    # return -
    return (payoff_value, profit_value)
end

function _expiration(equity::MyEquityModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from Equity model -
    direction = equity.sense
    purchase_price = equity.purchase_price
    number_of_shares = equity.number_of_shares

    # Equity -
    payoff_value = number_of_shares * underlying
    profit_value = direction * (payoff_value - number_of_shares * purchase_price)

    # return -
    return (payoff_value, profit_value)
end

function _intrinsic(model::T, underlying::Float64)::Float64 where {T<:AbstractAssetModel}

    # compute the payoff -
    (payoff_value, _) = _expiration(model, underlying)
    return payoff_value
end

function _price_continuous_compounding(model::MyUSTreasuryCouponSecurityModel)

    # initialize -
    cashflow = Dict{Int,Float64}()
    discount = Dict{Int,Float64}()

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    rate = model.rate
    coupon = model.coupon
    Vₚ = model.par

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = rate;
    discount[0] = 1.0;

    # internal timescale -
    Δ = 1/λ;

    # main loop -
    for i ∈ 1:N

        # update the internal timescale -
        τ = (i)*Δ;

        # build the discount rate -
        𝒟ᵢ = exp(τ*rᵢ);
        discount[i] = 𝒟ᵢ;

        # compute the coupon payments -
        payment =  (1/𝒟ᵢ)*Cᵢ;

        if (i == N)
            cashflow[i] = payment + (1/𝒟ᵢ)*Vₚ;
        else
            cashflow[i] = payment;     
        end
    end

    # compute the sum -
    cumulative_sum = 0.0
    for i ∈ 1:N
        cumulative_sum += cashflow[i]
    end
    cashflow[0] = -1*cumulative_sum

    # add stuff to model -
    model.cashflow = cashflow;
    model.price = abs(cashflow[0]);
    model.discount = discount;

    # return the updated model -
    return model
end

function _price_discrete_compounding(model::MyUSTreasuryCouponSecurityModel)
    
    # initialize -
    cashflow = Dict{Int,Float64}()
    discount = Dict{Int,Float64}()

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    rate = model.rate
    coupon = model.coupon
    Vₚ = model.par

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = (rate/λ);
    discount[0] = 1.0;

    # internal timescale -
    Δ = 1/λ;


    # edge case, we have a duration less than 6-months
    if (N == 0)
        
        # we have a zero coupon bond -
        𝒟 = (1+rᵢ)^(λ*T);
        # 𝒟 = exp(rate*T);
         
        # compute the price -
        price = (1/𝒟)*Vₚ;
   
        # casflow -
        cashflow[0] = -1*price;
        cashflow[1] = Vₚ; # we get the face value back

        # discount -
        discount[0] = 1.0;
        discount[1] = 𝒟;

        # update the model -
        model.price = price;
        model.cashflow = cashflow;
        model.discount = discount;
   
        # return -
        return model;
    end


    # main loop - we have a duration greater than 6-months
    for i ∈ 1:N

        # update the internal timescale -
        τ = (i)*Δ;

        # build the discount rate -
        𝒟ᵢ = (1+rᵢ)^i
        discount[i] = 𝒟ᵢ;
        
        # compute the coupon payments -
        payment =  (1/𝒟ᵢ)*Cᵢ;

        if (i == N)
            cashflow[i] = payment + (1/𝒟ᵢ)*Vₚ;
        else
            cashflow[i] = payment;     
        end
    end

    # compute the sum -
    cumulative_sum = 0.0
    for i ∈ 1:N
        cumulative_sum += cashflow[i]
    end
    cashflow[0] = -1*cumulative_sum

    # add stuff to model -
    model.cashflow = cashflow;
    model.price = abs(cashflow[0]);
    model.discount = discount;

    # return the updated model -
    return model
end

function _price_continuous_compounding(model::MyUSTreasuryZeroCouponBondModel)

    # initialize -
    discount = Dict{Int,Float64}()
    cashflow = Dict{Int,Float64}()

    # get data from the model -
    T = model.T;
    rate = model.rate
    Vₚ = model.par

    # compute the discount factor -
    𝒟 = exp(rate*T);
    discount[0] = 1.0;
    discount[1] = 𝒟;

    # compute the price -
    price = (1/𝒟)*Vₚ
    cashflow[0] = -1*price;
    cashflow[1] = Vₚ;

    # update the model -
    model.price = price;
    model.discount = discount;
    model.cashflow = cashflow;

    # return the updated model -
    return model
end

function _price_discrete_compounding(model::MyUSTreasuryZeroCouponBondModel)
    
    # initialize -
    cashflow = Dict{Int,Float64}()
    discount = Dict{Int,Float64}()

    # get data from the model -
    T = model.T;
    rate = model.rate
    Vₚ = model.par
    n = model.n
    
    # compute the discount factor -
    𝒟 = (1+(rate/n))^(n*T)

    # compute the price -
    price = (1/𝒟)*Vₚ
   
    # casflow -
    cashflow[0] = -1*price;
    cashflow[1] = Vₚ;

    # discount -
    discount[0] = 1.0;
    discount[1] = 𝒟;

    # update the model -
    model.price = price;
    model.cashflow = cashflow;
    model.discount = discount;
   
    # return -
    return model
end

function _analyze_risk_neutral_single_asset(R::Array{Float64,1};  
    Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.05)::Tuple{Float64,Float64,Float64}

    # initialize -
    u,d,p = 0.0, 0.0, 0.0;
    darray = Array{Float64,1}();
    uarray = Array{Float64,1}();
    N₊ = 0;

    # up -
    # compute the up moves, and estimate the average u value -
    index_up_moves = findall(x->x>0, R);
    for index ∈ index_up_moves
        R[index] |> (μ -> push!(uarray, exp(μ*Δt)))
    end
    u = mean(uarray);

    # down -
    # compute the down moves, and estimate the average d value -
    index_down_moves = findall(x->x<0, R);
    for index ∈ index_down_moves
        R[index] |> (μ -> push!(darray, exp(μ*Δt)))
    end
    d = mean(darray);

    # risk-neutral probability -
    p = (exp(risk_free_rate*Δt) - d)/(u-d);

    # return -
    return (u,d,p);
end

function _analyze_risk_neutral_multiple_asset(R::Array{Float64,2}, tikers::Array{String,1};  
    Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.05)::Dict{String,Tuple{Float64,Float64,Float64}}
    
    # initialize -
    risk_neutral_measure = Dict{String, Tuple{Float64,Float64,Float64}}()

    # main loop -
    for i ∈ eachindex(tikers)
        
        # get the tiker -
        tiker = tikers[i];

        # get the returns -
        returns = R[:,i];

        # analyze -
        (u,d,p) = _analyze_risk_neutral_single_asset(returns, Δt=Δt, risk_free_rate = risk_free_rate);

        # store -
        risk_neutral_measure[tiker] = (u,d,p);
    end
    
    # return -
    return risk_neutral_measure;
end

function _analyze_real_world_single_asset(R::Array{Float64,1};  Δt::Float64 = (1.0/252.0))::Tuple{Float64,Float64,Float64}
    
    # initialize -
    u,d,p = 0.0, 0.0, 0.0;
    darray = Array{Float64,1}();
    uarray = Array{Float64,1}();
    N₊ = 0;

    # up -
    # compute the up moves, and estimate the average u value -
    index_up_moves = findall(x->x>0, R);
    for index ∈ index_up_moves
        R[index] |> (μ -> push!(uarray, exp(μ*Δt)))
    end
    u = mean(uarray);

    # down -
    # compute the down moves, and estimate the average d value -
    index_down_moves = findall(x->x<0, R);
    for index ∈ index_down_moves
        R[index] |> (μ -> push!(darray, exp(μ*Δt)))
    end
    d = mean(darray);

    # probability -
    N₊ = length(index_up_moves);
    p = N₊/length(R);

    # return -
    return (u,d,p);
end

function _analyze_real_world_multiple_asset(R::Array{Float64,2}, tikers::Array{String,1};  
    Δt::Float64 = (1.0/252.0))::Dict{String,Tuple{Float64,Float64,Float64}}
    
    # initialize -
    real_world_measure = Dict{String, Tuple{Float64,Float64,Float64}}()

    # main loop -
    for i ∈ eachindex(tikers)
        
        # get the tiker -
        tiker = tikers[i];

        # get the returns -
        returns = R[:,i];

        # analyze -
        (u,d,p) = _analyze_real_world_single_asset(returns, Δt=Δt);

        # store -
        real_world_measure[tiker] = (u,d,p);
    end
    
    # return -
    return real_world_measure;
end

function _analyze_real_world_single_asset_nary_tree(R::Array{Float64,1}, n::Int64;  Δt::Float64 = (1.0/252.0))

    # initialize -
    minvalue = minimum(R);
    maxvalue = maximum(R);
    range = maxvalue - minvalue;
    step = range/n;


    

end

function _expectation(model::MySymmetricBinaryInterestRateLatticeModel, l::Int64; 
    p::Int64= 1)::Float64
    
    # initialize -
    expectation_value = 0.0;
    levels = model.levels;
    node_index_array = levels[l];
    
    N = length(node_index_array);
    probability_array = Array{Float64,1}(undef, N);
    rate_array = Array{Float64,1}(undef, N);
    for i ∈ 1:N
        node = node_index_array[i] |> index -> model.data[index];
        probability_array[i] = node.probability;
        rate_array[i] = (node.rate)^(p);
    end
    expectation_value = dot(probability_array, rate_array);

    # return -
    return expectation_value;
end

function _variance(model::MySymmetricBinaryInterestRateLatticeModel, l::Int64)::Float64
    
    # initialize -
    variance_value = 0.0;
    levels = model.levels;
    node_index_array = levels[l];
    
    # N = length(node_index_array);
    # rate_array = Array{Float64,1}(undef, N);
    # for i ∈ 1:N
    #     node = node_index_array[i] |> index -> model.data[index];
    #     rate_array[i] = node.rate;
    # end
    # variance_value = var(rate_array); # compute the variance -

    term_1 = _expectation(model, l, p = 2);
    term_2 = _expectation(model,l, p = 1);
    variance_value = term_1 - (term_2)^2;

    # return -
    return variance_value;
end
# === PRIVATE ABOVE HERE ============================================================================================= #

# === PUBLIC METHODS BELOW HERE ====================================================================================== #
𝒟(r,T) = exp(r*T);


# Shortcut syntax -
(m::RealWorldBinomialProbabilityMeasure)(R::Array{Float64,1};  Δt::Float64 = (1.0/252.0))::Tuple{Float64,Float64,Float64} = _analyze_real_world_single_asset(R, Δt=Δt)
(m::RealWorldBinomialProbabilityMeasure)(R::Array{Float64,2}, tickers::Array{String,1};  Δt::Float64 = (1.0/252.0))::Dict{String,Tuple{Float64,Float64,Float64}} = _analyze_real_world_multiple_asset(R, tickers, Δt=Δt)
(m::RiskNeutralBinomialProbabilityMeasure)(R::Array{Float64,1};  Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.05)::Tuple{Float64,Float64,Float64} = _analyze_risk_neutral_single_asset(R, Δt = Δt, risk_free_rate = risk_free_rate)
(m::RiskNeutralBinomialProbabilityMeasure)(R::Array{Float64,2}, tickers::Array{String,1};  Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.05)::Dict{String,Tuple{Float64,Float64,Float64}} = _analyze_risk_neutral_multiple_asset(R, tickers, Δt = Δt, risk_free_rate = risk_free_rate)
(m::RealWorldGeneralProbabilityMeasure)(R::Array{Float64,1}, n::Int64;  
    Δt::Float64 = (1.0/252.0))::Tuple{Float64,Float64,Float64} = _analyze_real_world_single_asset_nary_tree(R, n, Δt=Δt);

# """
#     analyze(R::Array{Float64,1};  Δt::Float64 = (1.0/365.0)) -> Tuple{Float64,Float64,Float64}
# """


# -- GBM Model Methods --------------------------------------------------------------------------------------------- #

"""
    function expectation(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple) -> Array{Float64,2}
"""
function expectation(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple)::Array{Float64,2}

    # get information from data -
    T₁ = data[:T₁]
    T₂ = data[:T₂]
    Δt = data[:Δt]
    Sₒ = data[:Sₒ]
    
    # get information from model -
    μ = model.μ

    # setup the time range -
    time_array = range(T₁,stop=T₂, step = Δt) |> collect
    N = length(time_array)

    # expectation -
    expectation_array = Array{Float64,2}(undef, N, 2)

    # main loop -
    for i ∈ 1:N

        # get the time value -
        h = (time_array[i] - time_array[1])

        # compute the expectation -
        value = Sₒ*exp(μ*h)

        # capture -
        expectation_array[i,1] = h + time_array[1]
        expectation_array[i,2] = value
    end
   
    # return -
    return expectation_array
end

"""
    function variance(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple) -> Array{Float64,2}
"""
function variance(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple)::Array{Float64,2}

    # get information from data -
    T₁ = data[:T₁]
    T₂ = data[:T₂]
    Δt = data[:Δt]
    Sₒ = data[:Sₒ]

    # get information from model -
    μ = model.μ
    σ = model.σ

    # setup the time range -
    time_array = range(T₁,stop=T₂, step = Δt) |> collect
    N = length(time_array)

    # expectation -
    variance_array = Array{Float64,2}(undef, N, 2)

    # main loop -
    for i ∈ 1:N

        # get the time value -
        h = time_array[i] - time_array[1]

        # compute the expectation -
        value = (Sₒ^2)*exp(2*μ*h)*(exp((σ^2)*h) - 1)

        # capture -
        variance_array[i,1] = h + time_array[1]
        variance_array[i,2] = value
    end
   
    # return -
    return variance_array
end



"""
    sample_endpoint(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
        number_of_paths::Int64 = 100) -> Array{Float64,1}

The `sample_endpoint` function simulates the geometric Brownian motion model for a single equity using the analytical solution at time `T`.

### Arguments
- `model::MyGeometricBrownianMotionEquityModel`: An instance of the [MyGeometricBrownianMotionEquityModel](@ref) type which models the geometric Brownian motion for the equity.
- `data::NamedTuple`: A named tuple that contains the data for the simulation.

The `data::NamedTuple` must contain the following keys:
- `T::Float64`: The time at which to sample the equity price.
- `Sₒ::Float64`: The initial price of the equity at time `0`.

### Returns
- `Array{Float64,1}`: An array of size `number_of_paths` that contains the equity price at time `T`.

### Optional Arguments
- `number_of_paths::Int64 = 100`: The number of paths to simulate. Default value is `100` paths.
"""
function sample_endpoint(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)::Array{Float64,1}

    # get information from data -
    T = data[:T]
    Sₒ = data[:Sₒ]

    # get information from model -
    μ = model.μ
    σ = model.σ

	# initialize -
    X = zeros(number_of_paths) # extra column for time -

	# build a noise array of Z(0,1)
	d = Normal(0,1)
	ZM = rand(d, number_of_paths);

	# main simulation loop -
	for p ∈ 1:number_of_paths
        X[p] = Sₒ*exp((μ - σ^2/2)*T + σ*(sqrt(T))*ZM[p])
	end

	# return -
	return X
end

"""
    sample(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
        number_of_paths::Int64 = 100) -> Array{Float64,2}

The `sample` function simulates the geometric Brownian motion model for a single equity using the analytical solution.
The model is defined by the parameters `μ` and `σ` which are the drift and volatility of the equity return, respectively.
The simulation is performed over a time interval `T` and the initial price of the equity is `Sₒ`. 
The function returns a matrix of size `(number_of_time_steps, number_of_paths + 1)` where each row represents a single path of the equity price over time.

### Arguments
- `model::MyGeometricBrownianMotionEquityModel`: An instance of the [MyGeometricBrownianMotionEquityModel](@ref) type which models the geometric Brownian motion for the equity.
- `data::NamedTuple`: A named tuple that contains the data for the simulation. 

The `data::NamedTuple` must contain the following keys:
- `T₁::Float64`: The start time of the simulation.
- `T₂::Float64`: The end time of the simulation.
- `Δt::Float64`: The time increment for the simulation.
- `Sₒ::Float64`: The initial price of the equity.

### Returns
- `Array{Float64,2}`: A matrix of size `(number_of_time_steps, number_of_paths + 1)` where each row represents a single path of the equity price over time. The first column contains the time values.

### Optional Arguments
- `number_of_paths::Int64 = 100`: The number of paths to simulate. Default value is `100` paths.
"""
function sample(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)::Array{Float64,2}

    # get information from data -
    Δt = data[:Δt]
    T₁ = data[:T₁]; 
    T₂ = data[:T₂];
    Sₒ = data[:Sₒ]
    T = T₁*Δt;

    # get information from model -
    μ = model.μ
    σ = model.σ

	# initialize -
	time_array = range(T₁, stop=T₂, step=Δt) |> collect
	number_of_time_steps = length(time_array)
    X = zeros(number_of_time_steps, number_of_paths + 1) # extra column for time -

    # put the time in the first col -
    for t ∈ 1:number_of_time_steps
        X[t,1] = time_array[t]
    end

	# replace first-row w/Sₒ -
	for p ∈ 1:number_of_paths
		X[1, p+1] = Sₒ
	end

	# build a noise array of Z(0,1)
	d = Normal(0,1)
	ZM = rand(d,number_of_time_steps, number_of_paths);

	# main simulation loop -
	for p ∈ 1:number_of_paths
		for t ∈ 1:number_of_time_steps-1
			X[t+1,p+1] = X[t,p+1]*exp((μ - (σ^2)/2)*Δt + σ*(sqrt(Δt))*ZM[t,p])
		end
	end

	# return -
	return X
end

"""
    sample(model::MyMultipleAssetGeometricBrownianMotionEquityModel, data::NamedTuple; 
        number_of_paths::Int64 = 100) -> Dict{Int64, Array{Float64,2}}

The `sample` function simulates the geometric Brownian motion model for multiple equities using the analytical solution.

### Arguments
- `model::MyMultipleAssetGeometricBrownianMotionEquityModel`: An instance of the [MyMultipleAssetGeometricBrownianMotionEquityModel](@ref) type which models the geometric Brownian motion for multiple equities.
- `data::NamedTuple`: A named tuple that contains the data for the simulation.

The `data::NamedTuple` must contain the following keys:
- `T₁::Float64`: The start time of the simulation.
- `T₂::Float64`: The end time of the simulation.
- `Δt::Float64`: The time increment for the simulation.
- `Sₒ::Array{Float64,1}`: The initial prices of the equities.

### Returns
- `Dict{Int64, Array{Float64,2}}`: A dictionary of simulations where the `key` is the path index and the `value` is a matrix of size `(number_of_time_steps, number_of_assets + 1)` where each row represents a time step, and columns represents an asset price. The first column contains the time values.
"""
function sample(model::MyMultipleAssetGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)::Dict{Int64, Array{Float64,2}}

    # get information from the model and data -
    μ̂ = model.μ
    A = model.A
    Ā = diagm(0 => diag(A));
    T₁ = data[:T₁]
    T₂ = data[:T₂]
    Δt = data[:Δt]
    Sₒ = data[:Sₒ]
    number_of_states = length(Sₒ);
    time_array = range(T₁, stop=T₂, step=Δt) |> collect
    number_of_steps = length(time_array)

    # main simulation loop -
    simulation_dictionary = Dict{Int64,Array{Float64,2}}(); # this is our dictionary of simulations (what gets rerturned)
    Z = Normal(0,1); # this is our noise model -
    for trial_index ∈ 1:number_of_paths
        simulation_array = Array{Float64,2}(undef, number_of_steps, number_of_states + 1);
    
        # add initial condition to the array -
        simulation_array[1,1] = T₁;
        for i ∈ 1:number_of_states
            simulation_array[1,i+1] = Sₒ[i];
        end
    
        # forward simulation -
        for i ∈ 2:number_of_steps
            t = time_array[i];
            simulation_array[i,1] = t;

            for j ∈ 1:number_of_states
            
                # compute the noise term for this state -
                noise_term = 0.0;
                for k ∈ 1:number_of_states
                    noise_term += A[j,k]*rand(Z)
                end
            
                # compute the next share price -
                simulation_array[i,j+1] = simulation_array[i-1,j+1]*exp((μ̂[j] -  Ā[j,j]/2)*Δt + (sqrt(Δt))*noise_term);
            end
        end
        simulation_dictionary[trial_index] = simulation_array;
    end

    # return the sim dictionary -
    return simulation_dictionary;
end
# ------------------------------------------------------------------------------------------------------------------ #


"""
    payoff(contracts::Array{T,1}, S::Array{Float64,1}) -> Array{Float64,2} where T <: AbstractContractModel

The `payoff` function computes the payoff for a set of option contracts at expiration given the underlying prices contained in the `S::Array{Float64,1}` array.
    
### Arguments
- `contracts::Array{T,1}`: An array of option contracts where `T` is a subtype of the `AbstractContractModel` type.
- `S::Array{Float64,1}`: An array of underlying prices.
    
### Returns
- `Array{Float64,2}`: A matrix of size `(number_of_underlying_prices, number_of_contracts + 2)` where each row represents an underlying price and each column containts the payoff for each contract. 
The first column contains the underlying price, the second column contains the payoff for the first contract, the third column contains the payoff for the second contract, and so on.
The last column contains the sum of the payoffs for all contracts.
"""
function payoff(contracts::Array{T,1}, S::Array{Float64,1})::Array{Float64,2} where T <: AbstractContractModel

    # initialize - 
    number_of_underlying_prices = length(S);
    number_of_contracts = length(contracts);
    payoff_array = Array{Float64,2}(undef, number_of_underlying_prices, number_of_contracts+2);

    # main loop -
    for i ∈ 1:number_of_underlying_prices

        # get the underlying price -
        Sᵢ = S[i];

        # compute the payoff -
        payoff_array[i,1] = Sᵢ;

        # loop over the contracts -
        for j ∈ 1:number_of_contracts

            # get the contract -
            contract = contracts[j];
            sense = contract.sense |> Float64;
            copy = contract.copy |> Float64;
            payoff_value = _payoff(contract, Sᵢ);

            # compute the payoff -
            payoff_array[i,j+1] = (copy*sense)*payoff_value;
        end
    end

    # compute the sum -
    for i ∈ 1:number_of_underlying_prices
        payoff_array[i,end] = sum(payoff_array[i,2:end-1]);
    end

    # return -
    return payoff_array;
end

"""
    profit(contracts::Array{T,1}, S::Array{Float64,1}) -> Array{Float64,2} where T <: AbstractContractModel

The `profit` function computes the profit for a set of option contracts at expiration given the underlying prices contained in the `S::Array{Float64,1}` array.
This function requires the contracts to have the `premium` field set on each contract model.
    
### Arguments
- `contracts::Array{T,1}`: An array of option contracts where `T` is a subtype of the `AbstractContractModel` type. Each contract must have the `premium` field set.
- `S::Array{Float64,1}`: An array of underlying prices at expiration.

### Returns
- `Array{Float64,2}`: A matrix of size `(number_of_underlying_prices, number_of_contracts + 2)` where each row represents an underlying price and each column containts the profit for a contract.
The first column contains the underlying price, the second column contains the profit for the first contract, the third column contains the profit for the second contract, and so on.
The last column contains the sum of the profits for all contracts.
"""
function profit(contracts::Array{T,1}, S::Array{Float64,1})::Array{Float64,2} where T <: AbstractContractModel

    # initialize - 
    number_of_underlying_prices = length(S);
    number_of_contracts = length(contracts);
    profit_array = Array{Float64,2}(undef, number_of_underlying_prices, number_of_contracts+2);

    # main loop -
    for i ∈ 1:number_of_underlying_prices

        # get the underlying price -
        Sᵢ = S[i];

        # compute the payoff -
        profit_array[i,1] = Sᵢ;

        # loop over the contracts -
        for j ∈ 1:number_of_contracts

            # get the contract -
            contract = contracts[j];
            sense = contract.sense |> Float64;
            copy = contract.copy |> Float64;
            premium = contract.premium;

            # compute the payoff -
            profit_array[i,j+1] = (copy*sense)*(_payoff(contract, Sᵢ) - premium)
        end
    end

    # compute the sum -
    for i ∈ 1:number_of_underlying_prices
        profit_array[i,end] = sum(profit_array[i,2:end-1]);
    end

    # return -
    return profit_array;    
end

function profit(contracts::Array{T,1}, equity::MyEquityModel, S::Array{Float64,1}) where T <: AbstractContractModel

    # initialize - 
    number_of_underlying_prices = length(S);
    number_of_contracts = length(contracts);
    profit_array = Array{Float64,2}(undef, number_of_underlying_prices, number_of_contracts+3);

    # main loop -
    for i ∈ 1:number_of_underlying_prices

        # get the underlying price -
        Sᵢ = S[i];

        # compute the payoff -
        profit_array[i,1] = Sᵢ;

        # loop over the contracts -
        for j ∈ 1:number_of_contracts

            # get the contract -
            contract = contracts[j];
            sense = contract.sense |> Float64;
            copy = contract.copy |> Float64;
            premium = contract.premium;

            # compute the payoff -
            profit_array[i,j+1] = (copy*sense)*(_payoff(contract, Sᵢ) - premium)
        end

        # update the equity profit
        n = equity.number_of_shares;
        Sₒ = equity.purchase_price;
        profit_array[i,number_of_contracts+2] = (Sᵢ - Sₒ);
    end
    
    # compute the overall sum
    for i ∈ 1:number_of_underlying_prices
        profit_array[i,end] = sum(profit_array[i, 2:end-1]);
    end

    # return -
    return profit_array;
end

"""
    premium(contract::T, model::MyAdjacencyBasedCRREquityPriceTree; 
        choice::Function=_rational, sigdigits::Int64 = 4) -> Float64 where {T<:AbstractContractModel}

Computes the premium for an American style option contract using the [Cox-Ross-Rubinstein model](https://en.wikipedia.org/wiki/Binomial_options_pricing_model).

### Arguments
- `contract::T`: An instance of the `AbstractContractModel` type which models the option contract. 
- `model::MyAdjacencyBasedCRREquityPriceTree`: An instance of the [MyAdjacencyBasedCRREquityPriceTree](@ref) type which models the Cox-Ross-Rubinstein model.
- `choice::Function=_rational`: A function that determines the choice of the option contract. Default value is `_rational`.
- `sigdigits::Int64 = 4`: The number of significant digits to round the premium to. Default value is `4`.

### Returns
- `Float64`: The premium for the American style option contract.
"""
function premium(contract::T, model::MyAdjacencyBasedCRREquityPriceTree; 
    choice::Function=_rational, sigdigits::Int64 = 4)::Float64 where {T<:AbstractContractModel}

    # initialize -
    data = model.data
    connectivity = model.connectivity
    levels = model.levels

    # get stuff from the model -
    p = model.p
    μ = model.μ
    #ΔT = model.T
    ΔT = model.ΔT
    dfactor = exp(-μ * ΔT)

    # Step 1: compute the intrinsic value
    for (_, node) ∈ data
          
        # grab the price -
        price = node.price
        node.intrinsic = _intrinsic(contract,price)
        node.extrinsic = _intrinsic(contract,price)
    end

    # get the levels that are going to process -
    list_of_levels = sort(keys(levels) |> collect,rev=true);
    for level ∈ list_of_levels[2:end]
        
        # get nodes on this level -
        parent_node_index = levels[level];
        for i ∈ parent_node_index
            
            children_nodes = connectivity[i];
            up_node_index = children_nodes[1];
            down_node_index = children_nodes[2];

            # compute the future_payback, and current payback
            current_payback = data[i].intrinsic
            future_payback = dfactor*((p*data[up_node_index].extrinsic)+(1-p)*(data[down_node_index].extrinsic))
            node_price = choice(current_payback, future_payback) # encode the choice
            data[i].extrinsic = node_price;
        end
    end

    # # return -
    return (data[0].extrinsic) |> x-> round(x, sigdigits = sigdigits)
end

function premium(contract::T, model::MyBinomialEquityPriceTree; 
    choice::Function=_rational)::Float64 where {T<:AbstractContractModel}

    # initialize -
    data = model.data
    connectivity = model.connectivity
    levels = model.levels
    
    # get stuff from the model -
    p = model.p
    μ = model.μ
    ΔT = model.ΔT
    dfactor = exp(-μ * ΔT)

    # Step 1: compute the intrinsic value
    for (_, node) ∈ data
          
        # grab the price -
        price = node.price
        node.intrinsic = _intrinsic(contract, price)
        node.extrinsic = _intrinsic(contract, price)
    end

    # get the levels that are going to process -
    list_of_levels = sort(keys(levels) |> collect,rev=true);
    for level ∈ list_of_levels[2:end]
        
        # get nodes on this level -
        parent_node_index = levels[level];
        for i ∈ parent_node_index
            
            children_nodes = connectivity[i];
            up_node_index = children_nodes[1];
            down_node_index = children_nodes[2];

            # compute the future_payback, and current payback
            current_payback = data[i].intrinsic;
            future_payback = dfactor*((p*data[up_node_index].extrinsic)+(1-p)*(data[down_node_index].extrinsic))
            node_price = choice(current_payback, future_payback) # encode the choice
            data[i].extrinsic = node_price;
        end
    end

    # # return -
    return data[0].extrinsic
end

"""
   function premium(contract::MyEuropeanCallContractModel, 
                model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)

The `premium` function computes the premium for a European call option contract using the [Black-Scholes-Merton model](https://en.wikipedia.org/wiki/Black–Scholes_model).
This function requires the contract to have the `K`, `DTE`, and `IV` fields set on the contract model, and the `Sₒ` and `r` fields set on the pricing `model::MyBlackScholesContractPricingModel` instance.

### Arguments
- `contract::MyEuropeanCallContractModel`: An instance of the [MyEuropeanCallContractModel](@ref) type which models the European call option contract.
- `model::MyBlackScholesContractPricingModel`: An instance of the [MyBlackScholesContractPricingModel](@ref) type which models the [Black-Scholes-Merton model calculation](https://en.wikipedia.org/wiki/Black–Scholes_model).

### Returns
- `Float64`: The premium for the European call option contract.
"""
function premium(contract::MyEuropeanCallContractModel, 
    model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)::Float64

    # get data from the contract model - 
    K = contract.K
    T = contract.DTE
    σ = contract.IV
    
    # get data from the BSM model -
    Sₒ = model.Sₒ
    r = model.r

    # compute the premium -
    d₊ = (1/(σ*sqrt(T)))*(log(Sₒ/K)+(r+(σ^2)/2)*T);
    d₋ = d₊ - σ*sqrt(T);
    premium = (cdf(Normal(0,1), d₊)*Sₒ - cdf(Normal(0,1), d₋)*K*(1/𝒟(r,T))) |> x-> round(x, sigdigits = sigdigits)

    # return -
    return premium
end

"""
    function premium(contract::MyEuropeanPutContractModel, 
                model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4) -> Float64

The `premium` function computes the premium for a European put option contract using the [Black-Scholes-Merton model](https://en.wikipedia.org/wiki/Black–Scholes_model).
This function requires the contract to have the `K`, `DTE`, and `IV` fields set on the contract model, and the `Sₒ` and `r` fields set on the pricing `model::MyBlackScholesContractPricingModel` instance.

### Arguments
- `contract::MyEuropeanPutContractModel`: An instance of the [`MyEuropeanPutContractModel`](@ref) type which models the European put option contract.
- `model::MyBlackScholesContractPricingModel`: An instance of the [`MyBlackScholesContractPricingModel`](@ref) type which models the [Black-Scholes-Merton model calculation](https://en.wikipedia.org/wiki/Black–Scholes_model).

### Returns
- `Float64`: The premium for the European put option contract.
"""
function premium(contract::MyEuropeanPutContractModel, 
    model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)::Float64

    # get data from the contract model - 
    K = contract.K
    T = contract.DTE
    σ = contract.IV
    
    # get data from the BSM model -
    Sₒ = model.Sₒ
    r = model.r

    # compute the premium -
    # d₊ = (1/(σ*sqrt(T)))*(log(Sₒ/K)+(r+(σ^2)/2)*T);
    # d₋ = d₊ - σ*sqrt(T);
    # premium = cdf(Normal(0,1), -d₋)*K*(1/𝒟(r,T)) - cdf(Normal(0,1), -d₊)*Sₒ |> x-> round(x,sigdigits=sigdigits)

    # crate a call model -
    call_model = build(MyEuropeanCallContractModel, (
        K=K, 
        DTE=T, 
        IV=σ
    ));

    C = premium(call_model, model, sigdigits = sigdigits);
    P = C + K*(1/𝒟(r,T)) - Sₒ;

    # return -
    return P
end

# --- lattice model methods ------------------------------------------------------------- #
function solve(model::MySymmetricBinaryInterestRateLatticeModel; Vₚ::Float64 = 100.0)

    # initialize -
    # ...

    # get stuff from the model -
    T = model.T;
    levels = model.levels;
    connectivity = model.connectivity;
    nodes = model.data;

    # all the leaves, have the par value -
    leaves = levels[T];
    for i ∈ leaves
        nodes[i].price = Vₚ; # all the leaves have the par value
    end

    # compute the other values -
    # get the levels that are going to process -
    list_of_levels = sort(keys(levels) |> collect, rev=true);
    for level ∈ list_of_levels[2:end]
        
        # get nodes on this level -
        parent_node_index = levels[level];
        for i ∈ parent_node_index
            
            # for this node, get the kids
            children_nodes = connectivity[i];
            up_node_index = children_nodes[1];
            down_node_index = children_nodes[2];

            # compute the dfactor -
            parent_node = nodes[i]
            rate_parent = parent_node.rate;
            dfactor = 1/(1+rate_parent);

            # compute the future_payback, and current payback
            node_price = dfactor*((p*nodes[up_node_index].price)+(1-p)*(nodes[down_node_index].price))
            nodes[i].price = node_price;
        end
    end

    # return -
    return model;
end

"""
    function populate(model::MySymmetricBinaryInterestRateLatticeModel) -> MySymmetricBinaryInterestRateLatticeModel

The `populate` function completes the initializing of a [`MySymmetricBinaryInterestRateLatticeModel`](@ref) model. 

### Arguments
- `model::MySymmetricBinaryInterestRateLatticeModel`: An instance of the [`MySymmetricBinaryInterestRateLatticeModel`](@ref) type constructed using the corresponding `build` function.
"""
function populate(model::MySymmetricBinaryInterestRateLatticeModel)::MySymmetricBinaryInterestRateLatticeModel

    # initialize -
    nodes_dictionary = Dict{Int, MyBinaryInterestRateLatticeNodeModel}()

    # get stuff from the model -
    T = model.T;
    u = model.u;
    d = model.d;
    p = model.p;
    rₒ = model.rₒ;
    h = T;

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

    # compute the price and probability, and store in the nodes dictionary
    counter = 0;
    for t ∈ 0:h

        # prices -
        for k ∈ 0:t
            
            t′ = big(t)
            k′ = big(k)

            # compute the prices and P for this level
            rate = rₒ*(u^(t-k))*(d^(k));
            P = binomial(t′,k′)*(p^(t-k))*(1-p)^(k);

            # create a node model -
            node = MyBinaryInterestRateLatticeNodeModel();
            node.probability = P;
            node.rate = rate;
            
            # push this into the array -
            nodes_dictionary[counter] = node;
            counter += 1
        end
    end

    # put it back in order -
    for i ∈ 0:(N-1)
        # grab the connectivity -
        connectivity[i] = zero_based_array[i+1,2:end]
    end

    # add data to the model -
    model.connectivity = connectivity
    model.data = nodes_dictionary;
    model.levels = _build_nodes_level_dictionary(h)

    # return -
    return model;
end

"""
    function expectation(model::MySymmetricBinaryInterestRateLatticeModel) -> Dict{Int64, Float64}

The `expectation` function computes the expectation for each tree level in the lattice model.

### Arguments
- `model::MySymmetricBinaryInterestRateLatticeModel`: An instance of the [`MySymmetricBinaryInterestRateLatticeModel`](@ref) type constructed using the corresponding `build` and `populate` functions.

### Returns
- `Dict{Int64, Float64}`: A dictionary where the `key` is the level index and the `value` is the expectation at that level.
"""
function expectation(model::MySymmetricBinaryInterestRateLatticeModel)::Dict{Int64,Float64}

    # initialize -
    expectation_dictionary = Dict{Int64,Float64}();
    levels = model.levels;

    # iterate over the levels, and compute the expectation -
    number_of_levels = length(levels);
    for i ∈ 1:number_of_levels
        expectation_dictionary[i-1] = _expectation(model, i-1);
    end

    # return
    return expectation_dictionary;
end

"""
    function variance(model::MySymmetricBinaryInterestRateLatticeModel) -> Dict{Int64, Float64}

The `variance` function computes the variance for each tree level in the lattice model.

### Arguments
- `model::MySymmetricBinaryInterestRateLatticeModel`: An instance of the [`MySymmetricBinaryInterestRateLatticeModel`](@ref) type constructed using the corresponding `build` and `populate` functions.

### Returns
- `Dict{Int64, Float64}`: A dictionary where the `key` is the level index and the `value` is the variance at that level.
"""
function variance(model::MySymmetricBinaryInterestRateLatticeModel)::Dict{Int64,Float64}

    # initialize -
    variance_dictionary = Dict{Int64,Float64}();
    levels = model.levels;

    # iterate over the levels, and compute the expectation -
    number_of_levels = length(levels);
    for i ∈ 1:number_of_levels
        if (i == 1)
            variance_dictionary[i-1] = 0.0; # no uncertainty at root
        else
            variance_dictionary[i-1] = _variance(model, i-1);
        end
    end

    # return
    return variance_dictionary;
end

"""
    function populate(model::MyBinomialEquityPriceTree; 
                Sₒ::Float64 = 100.0, h::Int = 1) -> MyBinomialEquityPriceTree

The `populate` function initializes a [`MyBinomialEquityPriceTree`](@ref) model with share prices and probabilities for each node in a lattice of height `h`.

### Arguments
- `model::MyBinomialEquityPriceTree`: An instance of the [`MyBinomialEquityPriceTree`](@ref) type constructed using the corresponding `build` function.
- `Sₒ::Float64 = 100.0`: The initial price of the equity at time `0`. Default value is `100.0` dollars per share.
- `h::Int = 1`: The height of the binomial price tree. Default value is `1`.

### Returns
- `MyBinomialEquityPriceTree`: An updated instance of the [`MyBinomialEquityPriceTree`](@ref) type with the share prices and probabilities computed for each node in the lattice. 

Node data is stored in the `data` field of the model (as MyBiomialLatticeEquityNodeModel instances), and the connectivity of the lattice is stored in the `connectivity` field.
See the [`MyBinomialEquityPriceTree`](@ref) type for more information on the tree.
"""
function populate(model::MyBinomialEquityPriceTree; 
    Sₒ::Float64 = 100.0, h::Int = 1)::MyBinomialEquityPriceTree

    # initialize -
    nodes_dictionary = Dict{Int, MyBiomialLatticeEquityNodeModel}()

    # get stuff from the model -
    ū = model.u;
    d̄ = model.d;
    p̄ = model.p;
    T = model.T;

    # we need this so that we can use the same type to compute option premiums
    if (isnothing(T) == true)
        T = h;
    end

    # compute u, d and p
    ΔT = T / h
    u = ū
    d = d̄
    p = p̄

    # main loop -
    counter = 0;
    for t ∈ 0:h
        
        # prices -
        for k ∈ 0:t
            
            t′ = big(t)
            k′ = big(k)

            # compute the prices and P for this level
            price = Sₒ*(u^(t′-k′))*(d^(k′)) |> x -> round(x, sigdigits = 10);
            P = binomial(t′,k′)*(p^(t′-k′))*(1-p)^(k′) |> x -> round(x, sigdigits = 10);

            # create a NamedTuple that holds values
            node = MyBiomialLatticeEquityNodeModel()
            node.price = price
            node.probability = P
          
            
            # push this into the array -
            nodes_dictionary[counter] = node;
            counter += 1
        end
    end

    # update the model -
    model.data = nodes_dictionary;
    model.levels = _build_nodes_level_dictionary(h);
    model.connectivity = _build_connectivity_dictionary(h);
    model.ΔT = ΔT;

    # return -
    return model
end

"""
    function sample(model::MyBinomialEquityPriceTree, L::Int64; number_of_paths::Int64 = 100) -> Array{Float64,2}
"""
function sample(model::MyBinomialEquityPriceTree, L::Int64; number_of_paths::Int64 = 100)::Array{Float64,2}

    # initialize -
    levels_array = range(0,stop=L-1,step=1) |> collect
    number_of_steps = length(levels_array);
    samples = zeros(number_of_steps, number_of_paths);

    for i ∈ 1:number_of_paths
        for j ∈ eachindex(levels_array)
            l = levels_array[j];
    
            prices = model.levels[l] .|> x -> model.data[x].price
            p = model.levels[l] .|> x-> model.data[x].probability;
            k = Categorical(p) |> d -> rand(d);
    
            if (l == 0)
                samples[j,i] = prices[1];
            else
                samples[j,i] = prices[k];
            end
        end
    end
        
    # return -
    return samples;
end

"""
    function populate(model::MyAdjacencyBasedCRREquityPriceTree; 
                Sₒ::Float64 = 100.0, h::Int64 = 1)

The `populate` function initializes the `MyAdjacencyBasedCRREquityPriceTree` model with share prices and probabilities for each node in the lattice.
In addition, this methods sets the intrinsic and extrinsic values of each node to `0.0` and computes the connectivity and levels of the lattice.

### Arguments
- `model::MyAdjacencyBasedCRREquityPriceTree`: An instance of the `MyAdjacencyBasedCRREquityPriceTree` type.
- `Sₒ::Float64 = 100.0`: The initial price of the equity.
- `h::Int64 = 1`: The number of time steps in the lattice (the height of the binomial price tree).

### Returns
- `MyAdjacencyBasedCRREquityPriceTree`: An updated instance of the `MyAdjacencyBasedCRREquityPriceTree` type with the share prices and probabilities computed for each node in the lattice.
"""
function populate(model::MyAdjacencyBasedCRREquityPriceTree; 
    Sₒ::Float64 = 100.0, h::Int64 = 1)::MyAdjacencyBasedCRREquityPriceTree

    # initialize -
    nodes_dictionary = Dict{Int, MyCRRLatticeNodeModel}()

    T = model.T;
    μ = model.μ;
    σ = model.σ;

    # compute u, d and p
    ΔT = T / h
    u = exp(σ * sqrt(ΔT))
    d = 1.0/u;
    p = (exp(µ * ΔT) - d) / (u - d)

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

    # set the data, and connectivity for the model -
    model.data = nodes_dictionary;
    model.connectivity = _build_connectivity_dictionary(h)
    model.levels = _build_nodes_level_dictionary(h)
    model.p = p;
    model.u = u;
    model.ΔT = ΔT
    model.μ = μ
    model.d = d

    # return -
    return model
end

# ------------------------------------------------------------------------------------------------------------------------------------`#`

# Shortcut methods that map to a 
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_discrete_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_continuous_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryZeroCouponBondModel) = _price_discrete_compounding(model::MyUSTreasuryZeroCouponBondModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryZeroCouponBondModel) = _price_continuous_compounding(model::MyUSTreasuryZeroCouponBondModel)

# == PUBLIC METHODS BELOW HERE ======================================================================================================== #
"""
    function price(model::MyUSTreasuryCouponSecurityModel, compounding::T) -> MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel

The `price(...)` function computes the price of a `MyUSTreasuryCouponSecurityModel` instance using a discrete or continuous compounding model.

### Arguments
- `model::MyUSTreasuryCouponSecurityModel`: an instance of the `MyUSTreasuryCouponSecurityModel` type.
- `compounding::T`: an instance of a type that is a subtype of `AbstractCompoundingModel`, i.e., a discrete or continuous compounding model.

### Returns
- `MyUSTreasuryCouponSecurityModel`: an updated instance of the `MyUSTreasuryCouponSecurityModel` type with the price computed using the compounding model.

"""
function price(model::MyUSTreasuryCouponSecurityModel, compounding::T)::MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel 
    return compounding(model)
end

"""
    function price(model::MyUSTreasuryZeroCouponBondModel, compounding::T) -> MyUSTreasuryZeroCouponBondModel where T <: AbstractCompoundingModel
    
The `price(...)` function computes the price of a `MyUSTreasuryZeroCouponBondModel` instance using a discrete or continuous compounding model.

### Arguments
- `model::MyUSTreasuryZeroCouponBondModel`: an instance of the `MyUSTreasuryZeroCouponBondModel` type.
- `compounding::T`: an instance of a type that is a subtype of `AbstractCompoundingModel`, i.e., a discrete or continuous compounding model.

### Returns
- `MyUSTreasuryZeroCouponBondModel`: an updated instance of the `MyUSTreasuryZeroCouponBondModel` type with the price computed using the compounding model.
"""
function price(model::MyUSTreasuryZeroCouponBondModel, compounding::T)::MyUSTreasuryZeroCouponBondModel where T <: AbstractCompoundingModel 
    return compounding(model)
end

"""
    function strip(model::MyUSTreasuryCouponSecurityModel) -> Dict{Int, MyUSTreasuryZeroCouponBondModel}

Strips the coupon and par value payments from a parent coupon security. 

The `strip(...)` function takes a `model::MyUSTreasuryCouponSecurityModel` of the security we wish to strip and returns a [Dictionary](https://docs.julialang.org/en/v1/base/collections/#Dictionaries) 
holding `MyUSTreasuryZeroCouponBondModel` instances created from the parent security. 
The keys of the dictionary correspond to the temporal index of the created security.
"""
function strip(model::MyUSTreasuryCouponSecurityModel)::Dict{Int, MyUSTreasuryZeroCouponBondModel}

    # initialize -
    strips_dictionary = Dict{Int64,MyUSTreasuryZeroCouponBondModel}()

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    coupon = model.coupon
    Vₚ = model.par;

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ; # this becomes the new face value 

    # main loop -
    T′ = 0.0;
    for i ∈ 1:N
        
        # update the time -
        T′ += 1.0/λ;

        # build a zero-coupon bond -
        zero_model = build(MyUSTreasuryZeroCouponBondModel, (
            par = Cᵢ, T = T′, n = λ
        ))

        # store -
        strips_dictionary[i] = zero_model;
    end

    # add a final zero coupon bond model that returns the face value -
    final_zero_model = build(MyUSTreasuryZeroCouponBondModel, (
        par = Vₚ, T = T, n = λ
    ))

    strips_dictionary[N+1] = final_zero_model;

    # return -
    return strips_dictionary
end
# ------------------------------------------------------------------------------------------------ #

# -- SHORT CUT METHODS BELOW --------------------------------------------------------------------- #
(contract::MyAmericanCallContractModel)(S::Array{Float64,1}) = payoff([contract], S)
(contract::MyAmericanPutContractModel)(S::Array{Float64,1}) = payoff([contract], S)
# -- SHORT CUT METHODS ABOVE --------------------------------------------------------------------- #