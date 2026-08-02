
function _iv_objective_function(p, contract::T, Sₒ::Float64, h::Int64, r̄::Float64)::Float64 where {T<:AbstractContractModel}
    
    # set the volatility -
    IVᵢ = p[1]
    DTE = contract.DTE; # this is measured in years
    observed_premium = contract.premium;

    # build a lattice model with the current parameters, populate it and compute the premium -
    treemodel = build(MyAdjacencyBasedCRREquityPriceTree, 
        (μ = r̄, T = DTE, σ = IVᵢ)) |> (x-> populate(x, Sₒ = Sₒ, h = h));
    
    # compute the premium -
    computed_premium = premium(contract, treemodel, sigdigits = 6);

    # compute the error -
    error_term = (computed_premium - observed_premium)^2;
    L = exp(-error_term/2);
    
    # return -
    return (1/L);
end

"""
    estimate_implied_volatility(contract::T; Sₒ::Float64 = 100.0, h::Int64 = 1, r̄::Float64 = 0.05) -> Tuple{Float64,Float64} where {T<:AbstractContractModel}

The `estimate_implied_volatility` function estimates the implied volatility for a given contract using the [Nelder-Mead optimization algorithm](https://en.wikipedia.org/wiki/Nelder–Mead_method). 

### Arguments
- `contract::T`: An instance of a contract model that defines the contract parameters, where `T` is a subtype of the `AbstractContractModel` type.
- `Sₒ::Float64`: The initial stock price used to compute the premium. The default value is `100.0`.
- `h::Int64`: The height of the lattice model used to compute the premium. The default value is `1`.
- `r̄::Float64`: The annual risk-free rate used to compute the premium. The default value is `0.05`.  

### Returns
- `Tuple{Float64,Float64}`: The likelihood and estimated implied volatility for the given contract.

### See:
* We use the [Nelder-Mead optimization algorithm](https://en.wikipedia.org/wiki/Nelder–Mead_method) from the [Optim.jl package](https://github.com/JuliaNLSolvers/Optim.jl) to estimate the implied volatility.
   
"""
function estimate_implied_volatility(contract::T; 
    Sₒ::Float64 = 100.0, h::Int64 = 1, r̄::Float64 = 0.05)::Tuple{Float64,Float64} where {T<:AbstractContractModel}
    
    # initialize -
    IVₒ = contract.IV;
    p = [IVₒ]; # initial guess for the implied volatility

    # setup the objective function -
    loss(p) = _iv_objective_function(p, contract, Sₒ, h, r̄);

    # call the optimizer -
    opt_result = Optim.optimize(loss, [0], [1], [IVₒ], Fminbox(NelderMead()));

    # grab the results -
    likelihood = 1/(Optim.minimum(opt_result));
    IV = Optim.minimizer(opt_result)[1];

    # return the result -
    return (likelihood, IV);
end