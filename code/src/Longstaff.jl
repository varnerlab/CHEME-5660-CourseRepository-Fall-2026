# --- PRIVATE METHODS BELOW HERE -------------------------------------------------------------------------------------- #
"""
    _lsqfit_local_regression_model(X, Y) -> MyLocalExpectationRegressionModel

Fit the continuation-value regression `Y ≈ a0 + a1*X + a2*X^2` by linear least squares
(Longstaff and Schwartz, 2001, use a low-order polynomial basis in the share price).
"""
function _lsqfit_local_regression_model(X::Array{Float64,1},Y::Array{Float64,1})::MyLocalExpectationRegressionModel

    # design matrix with the basis 1, S, S² -
    A = hcat(ones(length(X)), X, X.^2);

    # least-squares coefficients -
    a = A \ Y;

    # return the model -
    return MyLocalExpectationRegressionModel(a[1], a[2], a[3]);
end

function _evaluate_local_regression_model(model::MyLocalExpectationRegressionModel, X::Array{Float64,1})::Array{Float64,1}
    return model.a0 .+ model.a1 .* X .+ model.a2 .* X.^2;
end
# --- PRIVATE METHODS ABOVE HERE -------------------------------------------------------------------------------------- #

"""
    premium(contract::T, model::MyLongstaffSchwartzContractPricingModel;
        choice::Function=_rational) -> Float64 where {T<:AbstractContractModel}

Computes the premium of an American-style contract from simulated share price paths with the
least-squares Monte Carlo method of [Longstaff and Schwartz (2001)](https://doi.org/10.1093/rfs/14.1.113).

The paths in `model.S` (rows: paths, columns: dates `0, Δt, 2Δt, …, T`, with today's price in column 1)
must be simulated under the risk-neutral measure, for example GBM with drift equal to the risk-free rate.
Working backward from expiration, at each date the discounted cash flows that the in-the-money paths
receive later are regressed on the share price (basis `1, S, S²`) to estimate the continuation value.
A path exercises when its payoff now beats that estimate, which replaces its later cash flow. The premium
is the discounted average cash flow over all paths, compared with immediate exercise at `t = 0`.

### Arguments
- `contract::T`: the option contract, e.g. a [`MyAmericanPutContractModel`](@ref).
- `model::MyLongstaffSchwartzContractPricingModel`: the simulated paths `S`, the risk-free rate `r̄`, and the time step `Δt`.
- `choice::Function=_rational`: the decision `choice(intrinsic, continuation)`, as for the lattice
  [`premium`](@ref). The default takes the larger value. `(intrinsic, continuation) -> continuation`
  always holds, which gives the European Monte Carlo premium on the same paths.

### Returns
- `Float64`: the premium (USD/share), not rounded.
"""
function premium(contract::T, model::MyLongstaffSchwartzContractPricingModel;
    choice::Function=_rational)::Float64 where {T<:AbstractContractModel}

    # initialize -
    S = model.S; # rows: paths, cols: dates 0, Δt, ..., T
    r̄ = model.r̄
    Δt = model.Δt;
    (number_of_paths, number_of_dates) = size(S);
    discount = 1/𝒟(r̄,Δt); # one-step discount factor

    # at expiration, each path's cash flow is the payoff -
    cash_flow = [_payoff(contract, S[i,end]) for i ∈ 1:number_of_paths];

    # work backward over the exercise dates before expiration (column 1 is today) -
    for t ∈ (number_of_dates-1):-1:2

        # the later cash flow, seen from date t -
        cash_flow .*= discount;

        # regress on the in-the-money paths only -
        intrinsic = [_payoff(contract, S[i,t]) for i ∈ 1:number_of_paths];
        idx_in_the_money = findall(x -> x > 0.0, intrinsic);
        length(idx_in_the_money) < 3 && continue; # too few points to fit 1, S, S²

        X = S[idx_in_the_money,t];
        Y = cash_flow[idx_in_the_money];
        local_expectation_model = _lsqfit_local_regression_model(X,Y);
        continuation = _evaluate_local_regression_model(local_expectation_model, X);

        # exercise where the payoff now beats the estimated continuation value -
        for (k, i) ∈ enumerate(idx_in_the_money)
            value_now = intrinsic[i];
            if (choice(value_now, continuation[k]) == value_now && value_now > continuation[k])
                cash_flow[i] = value_now; # exercising replaces the later cash flow
            end
        end
    end

    # discount the date-Δt cash flows to today, then compare with exercising today -
    held_value = discount*(sum(cash_flow)/number_of_paths);
    return choice(_payoff(contract, S[1,1]), held_value);
end
