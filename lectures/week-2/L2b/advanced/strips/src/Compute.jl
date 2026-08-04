function _net_present_value(model::MyUSTreasuryZeroCouponBondModel, Y::Float64;
    TR::Float64 = 1.0,
    price::Float64 = 1.0)::Float64

    # initialize -
    cashflow = 0.0;

    # get data from the model -
    T = TR; # years
    Vₚ = model.par

    # derived values
    D = exp(Y*T);
    cashflow = (1/D)*Vₚ;

    # return -
    return cashflow - price;
end

function _net_present_value(model::MyUSTreasuryCouponSecurityModel, Y::Float64;
    TR::Float64 = 1.0,
    price::Float64 = 1.0)::Float64

    # initialize -
    cashflow = Dict{Int,Float64}()
    discount = Dict{Int,Float64}()

    # get data from the model -
    λ = model.λ  # per year
    T = TR; # years
    rate = Y; # yield to maturity
    coupon = model.coupon
    Vₚ = model.par

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = (rate/λ);
    discount[0] = 1.0;

    # internal timescale -
    Δ = 1/λ;

    # compute the cash flows -
    for i ∈ 1:N

        # update the internal timescale -
        τ = (i)*Δ;

        # build the discount rate -
        𝒟ᵢ = (1+rᵢ)^i
        discount[i] = 𝒟ᵢ;

        # compute the coupon payments -
        payment =  (1/𝒟ᵢ)*Cᵢ;

        # final payment includes the par value -
        if (i == N)
            cashflow[i] = payment + (1/𝒟ᵢ)*Vₚ;
        else
            cashflow[i] = payment;
        end
    end

    # compute the NPV -
    NPV = sum(values(cashflow));

    # return -
    return NPV - price;
end

"""
    function yieldtomaturity(model::MyUSTreasuryCouponSecurityModel; TR::Float64 = 1.0,
        price::Float64 = 1.0, ϵ::Float64 = 1e-6, maxiter::Int64 = 100) -> Tuple{Float64, Dict{Int, Float64}}

Compute the yield to maturity (YTM) of a U.S. Treasury Coupon Security using the Secant Method.

### Arguments
- `model::MyUSTreasuryCouponSecurityModel`: An instance of the `MyUSTreasuryCouponSecurityModel` type containing the security's parameters.
- `TR::Float64`: The total time to maturity in years. Default is `1.0`.
- `price::Float64`: The current market price of the security. Default is `1.0`.
- `ϵ::Float64`: The convergence tolerance for the YTM calculation. Default is `1e-6`.
- `maxiter::Int64`: The maximum number of iterations to perform. Default is `100`.

### Returns
- `Union{Float64, Dict{Int, Float64}}`: The estimated YTM as a `Float64`, and a dictionary containing the YTM estimates at each iteration.
"""
function yieldtomaturity(model::T;
    TR::Float64 = 1.0,
    price::Float64 = 1.0,
    ϵ::Float64 = 1e-6,
    maxiter::Int64 = 100)::Tuple{Float64, Dict{Int, Float64}} where T <: AbstractTreasuryDebtSecurity

    # initialize -
    should_stop_iterating = false;
    iteration = 0;
    Y₁ = 0.01; # rule of thumb initial guess
    Y₂ = 0.10; # rule of thumb initial guess
    Y = 0.0;
    solution_archive = Dict{Int, Float64}(); # storage for solutions

    # set initial stored value -
    solution_archive[0] = Y;

    while (should_stop_iterating == false)

        f₁ = _net_present_value(model, Y₁, TR=TR, price=price); # NPV(Y₁)
        f₂ = _net_present_value(model, Y₂, TR=TR, price=price); # NPV(Y₂)

        # compute next guess -
        Y = Y₂ - f₂ * (Y₂ - Y₁) / (f₂ - f₁);

        # compute error -
        error = abs(Y - Y₂);

        # should we stop?
        if (error < ϵ) || (iteration >= maxiter)
            should_stop_iterating = true; # ok, no more, we are done

            # But why are we done? So one of the stopping criteria was met, which one?
            # we don't really care: except if we hit maxiter and didn't converge
            if (error > ϵ)
                @warn("Maximum number of iterations ($maxiter) reached before convergence. Current error: $error");
            end
        end

        # update -
        Y₁ = Y₂;
        Y₂ = Y;
        iteration += 1;
        solution_archive[iteration] = Y; # store solution so far
    end

    return Y, solution_archive; # return the best YTM estimate and the solution archive
end

