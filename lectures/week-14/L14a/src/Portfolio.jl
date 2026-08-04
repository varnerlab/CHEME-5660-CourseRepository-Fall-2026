"""
    shares(t::Int64, model::MyInvestorMarketContextModel;
        fillpriceconvention = :volume_weighted_average_price,
        cutoff::Float64 = 0.5, penalty::Float64 = -100.0) -> NamedTuple

Compute the share allocation for trading day `t` using a single-index model blended with ticker-picker
preferences stored in a [`MyInvestorMarketContextModel`](@ref).

### Arguments
- `t::Int64`: Trading-day index used to pull prices from the market data for each ticker.
- `model::MyInvestorMarketContextModel`: Investor context containing budget, tickers, market data,
  preference tables, single-index model parameters, and risk attitude (`mood`).
- `fillpriceconvention::Symbol`: Which price to treat as the fill price for each ticker. Options are
  `:random`, `:open`, `:close`, `:high`, `:low`, and `:volume_weighted_average_price` (default).
- `cutoff::Float64`: Probability threshold that determines when a ticker is treated as preferred; values
  below this cutoff receive a penalty.
- `penalty::Float64`: Score applied to low-probability tickers before active-set selection.

### Returns
- `NamedTuple`: `(shares, price, gamma, tickers, cash)` where `shares` is the optimal share vector,
  `price` holds the fill prices used for each ticker, `gamma` are the bounded preference weights,
  `tickers` preserves the ticker order, and `cash` is any unallocated budget.

### Notes
- Only tickers with a positive bounded score enter the active set; excluded tickers receive zero shares.
- Signed SIM beta is converted to a positive scale using its magnitude before applying a possibly
  noninteger exponent. The score itself retains beta's sign in the market-exposure term.
"""
function shares(t::Int64, model::MyInvestorMarketContextModel;
    fillpriceconvention = :volume_weighted_average_price,
    cutoff::Float64 = 0.5, penalty::Float64 = -100.0)::NamedTuple

    # get data from the model -
    B = model.B;
    mylocaltickers = model.tickers;
    marketdata = model.marketdata;
    preferences = model.preferences;
    Ḡₘ = model.Ḡₘ;
    singleindexmodel_parameters = model.singleindexmodel_parameters;
    ξ = model.ξ;
    mood = model.mood;

    # size of the problem -
    K = length(mylocaltickers);

    # get some parameters from the preference data frame -
    preferences_df = preferences[mood];
    λ = preferences_df[1, :lambda]; # all the same in the table

    # compute the preference coefficients -
    γ = Array{Float64,1}(undef, K);
    for i ∈ eachindex(mylocaltickers)
        ticker = mylocaltickers[i];

        # get the model -
        simmodel = singleindexmodel_parameters[ticker];
        α = simmodel.alpha;
        β = simmodel.beta;

        # let's assume the mean value for the single index model parameters
        αᵢ = α; # use the mean value
        βᵢ = β; # use the mean value
        pᵢ = filter(:ticker => x-> x == ticker, preferences_df)[1, :probability];

        # if pᵢ is too low, then
        ξᵢ = penalty; # we penalize low probability assets
        if pᵢ > cutoff
            ξᵢ = ξ;
        end
        risk_scale = max(abs(βᵢ), sqrt(eps(Float64)))^λ;
        R = αᵢ/risk_scale + (βᵢ/risk_scale)*Ḡₘ + ξᵢ*pᵢ; # score
        γ[i] = tanh_fast(R);
    end

    # compute the fill price -
    price = Array{Float64,1}(undef, K);
    for i ∈ eachindex(mylocaltickers)
        ticker = mylocaltickers[i];
        firm_data = marketdata[ticker];

        if (fillpriceconvention == :random)
            H = firm_data[t, :high];
            L = firm_data[t, :low];
            f = rand();
            price[i] = f*H + (1-f)*L; # randomness in the fill price
        elseif (fillpriceconvention == :open)
            price[i] = firm_data[t, :open];
        elseif (fillpriceconvention == :close)
            price[i] = firm_data[t, :close];
        elseif (fillpriceconvention == :high)
            price[i] = firm_data[t, :high];
        elseif (fillpriceconvention == :low)
            price[i] = firm_data[t, :low];
        elseif (fillpriceconvention == :volume_weighted_average_price)
            price[i] = firm_data[t, :volume_weighted_average_price];
        else
            error("Invalid fillpriceconvention specified: $fillpriceconvention. Valid options are :random, :open, :close, :high, :low, :volume_weighted_average_price.");
        end
    end

     # Compute the optimal share count -
    n = zeros(K); # initialize space for optimal solution
    S = findall(γᵢ -> γᵢ > 0, γ); # Which assets does our preference model tell is to buy?
    # S = 1:K; # TEMPORARY: consider all assets for now

    if isempty(S) == false
        γ̄ = sum(γ[S]);
        for s ∈ S
            n[s] = (γ[s]/γ̄)*(B/price[s]);
        end
    end

    # how much did we spend?
    total_spent = sum(n .* price);
    cash_leftover = B - total_spent;

    # return -
    return (shares = n, price = price, gamma = γ, tickers = mylocaltickers, cash = cash_leftover);
end

"""
    shares(t::Int64, context::MySimpleRobotInvestorContextModel) -> NamedTuple

Allocate shares for trading day `t` using a simplified robot investor model driven by a market factor
time series and single-index model parameters.

### Arguments
- `t::Int64`: Trading-day index used to pull prices and market factor values.
- `context::MySimpleRobotInvestorContextModel`: Investor context containing budget, tickers, market
  factor series, market data matrix, SIM parameters, and share floor `ϵ`.

### Returns
- `NamedTuple`: `(shares, price, gamma, tickers, cash)` where `shares` is the target share vector,
  `price` holds positive synthetic fill prices used for each ticker, `gamma` are bounded scores,
  `tickers` preserves the ticker order, and `cash` is any unallocated budget.
"""
function shares(t::Int64, context::MySimpleRobotInvestorContextModel)

    # initialize -
    B = context.B;
    mylocaltickers = context.tickers;
    marketdata = context.marketdata;
    ḡₘ = context.marketfactor[t-1]; # market factor at time t
    λ = context.λ;
    K = length(mylocaltickers);
    singleindexmodel_parameters = context.singleindexmodel_parameters;

    # compute the risk factor array -
    riskfactors = Array{Float64,1}(undef, K);
    for i ∈ eachindex(mylocaltickers)
        ticker = mylocaltickers[i];
        simmodel = singleindexmodel_parameters[ticker];
        βᵢ = simmodel.beta;
        riskfactors[i] = max(abs(βᵢ), sqrt(eps(Float64)))^λ;
    end;

    # compute the fill price -
    price = Array{Float64,1}(undef, K);
    for i ∈ eachindex(mylocaltickers)
        reference_price = marketdata[t,i+1];
        reference_price > 0 || throw(ArgumentError("reference prices must be strictly positive"));
        price[i] = reference_price*exp(0.01*randn() - 0.5*0.01^2); # positive synthetic fill perturbation
    end

    # compute the preference coefficient for each ticker -
    γ = Array{Float64,1}(undef, K);
    for i ∈ eachindex(mylocaltickers)

        ticker = mylocaltickers[i];
        simmodel = singleindexmodel_parameters[ticker];
        αᵢ = simmodel.alpha;
        βᵢ = simmodel.beta;
        RF = riskfactors[i];

        ĝᵢ = αᵢ/RF + (βᵢ/RF)*(ḡₘ); # expected excess return
        γ[i] = tanh_fast(ĝᵢ); # preference coefficient
    end

    n = zeros(K); # initialize space for optimal solution
    S = findall(γᵢ -> γᵢ > 0, γ); # assets selected by the positive-score policy
    if isempty(S) == false
        γ̄ = sum(γ[S]);
        for s ∈ S
            n[s] = (γ[s]/γ̄)*(B/price[s]);
        end
    end

    # how much did we spend?
    total_spent = sum(n .* price);
    cash_leftover = B - total_spent;

    # return -
    return (shares = n, price = price, gamma = γ, tickers = mylocaltickers, cash = cash_leftover);
end

"""
    nextprice(model::Union{MyHiddenMarkovModel, MyHiddenMarkovModelWithJumps}, decode::Dict{Int64, Normal}, s::Int64, Sₒ::Float64;
        Δt::Float64 = (1.0/252.0), number_of_steps::Int64 = 2, risk_free_rate::Float64 = 0.0431) -> Tuple{Int64, Float64}

Simulate the next latent state and asset price using a hidden Markov model with optional jump dynamics.

### Arguments
- `model::Union{MyHiddenMarkovModel, MyHiddenMarkovModelWithJumps}`: Stochastic model that maps the
  current state to a future state path.
- `decode::Dict{Int64, Normal}`: Mapping from latent state index to a Normal distribution for growth.
- `s::Int64`: Current latent state.
- `Sₒ::Float64`: Current asset price.
- `Δt::Float64`: Time step (years) used to convert growth to price; defaults to one trading day.
- `number_of_steps::Int64`: How many steps ahead to simulate when drawing the next state.
- `risk_free_rate::Float64`: Risk-free rate used in the model (currently unused but kept for API parity).

### Returns
- `Tuple{Int64, Float64}`: `(snext, S)` where `snext` is the simulated next state and `S` is the
  corresponding next price.
"""
function nextprice(model::Union{MyHiddenMarkovModel, MyHiddenMarkovModelWithJumps}, decode::Dict{Int64, Normal}, s::Int64, Sₒ::Float64;
    Δt::Float64 = (1.0/252.0), number_of_steps::Int64 = 2, risk_free_rate::Float64 = 0.0431)::Tuple{Int64, Float64}

    # generate the state, decode the state, generate a growth
    tmp = model(s, number_of_steps); # call the model, compute the next mood
    snext = tmp[end,1] # what is the next state?
    g = snext |> s-> decode[s] |> d -> rand(d) # what is the mood at the next time step?
    S = Sₒ*exp((g)*Δt); # compute the next price
    return (snext, S); # return the next state and next price
end
