# Peizer-Pratt inversion (method 2) for an odd number of steps -
function _peizer_pratt_probability(z::Float64, n::Int)::Float64
    exponent = -(z / (n + 1 / 3 + 0.1 / (n + 1)))^2 * (n + 1 / 6)
    root = sqrt(-expm1(exponent)); # retain precision when z is close to zero
    return z > 0 ? (1 + root) / 2 : exp(exponent) / (2 * (1 + root))
end

"""
    binomial_premium(contract; method=:crr, h=201, T=1/365, σ=0.15,
        Sₒ=1.0, μ=0.0015, dividend_yield=0.0)

Compute the full-precision, per-share long-option value of a European or American
vanilla call or put. `method=:crr` uses Cox-Ross-Rubinstein factors;
`method=:leisen_reimer` uses the Leisen-Reimer Peizer-Pratt method-2 construction.
For Leisen-Reimer, an even `h` is increased by one to obtain an odd step count.

`T` is remaining time in years, `σ` is annualized decimal volatility, `Sₒ` and the
contract's strike `K` are in USD/share, and `μ` is the continuously compounded
risk-free rate in inverse years. `dividend_yield` is a continuous yield in inverse
years. American contracts allow exercise at every tree date; European contracts
allow exercise only at maturity. At `T=0`, return the intrinsic value.

The contract's `premium`, `sense`, and `copy` fields do not enter this unit value.
Apply the signed position count and contract multiplier separately. The rolling
valuation uses O(h) storage and O(h²) work, with no intermediate rounding.

Reference: Leisen and Reimer (1996), *Applied Mathematical Finance* 3, 319-346,
doi:10.1080/13504869600000015. The lattice is rebuilt for each contract and input
perturbation because the Leisen-Reimer factors depend on the strike.
"""
function binomial_premium(contract::AbstractContractModel; method::Symbol=:crr,
    h::Integer=201, T::Real=1 / 365, σ::Real=0.15, Sₒ::Real=1.0,
    μ::Real=0.0015, dividend_yield::Real=0.0)::Float64

    # Validate the model inputs -
    supported = contract isa Union{MyEuropeanCallContractModel,MyEuropeanPutContractModel,
        MyAmericanCallContractModel,MyAmericanPutContractModel}
    supported || throw(ArgumentError("binomial_premium supports vanilla call and put contracts"))
    method in (:crr, :leisen_reimer) || throw(ArgumentError("method must be :crr or :leisen_reimer"))
    h >= 1 || throw(ArgumentError("h must be at least one"))
    S, K, maturity, volatility, rate, yield = Float64.((Sₒ, contract.K, T, σ, μ, dividend_yield))
    all(isfinite, (S, K, maturity, volatility, rate, yield)) || throw(ArgumentError("inputs must be finite"))
    S > 0 && K > 0 || throw(ArgumentError("spot and strike must be positive"))
    maturity >= 0 || throw(ArgumentError("remaining time must be nonnegative"))
    volatility > 0 || throw(ArgumentError("volatility must be positive"))
    maturity == 0 && return _payoff(contract, S)

    # Construct the risk-neutral factors -
    n = method == :leisen_reimer && iseven(h) ? Int(h + 1) : Int(h)
    dt = maturity / n
    carry = exp((rate - yield) * dt)
    if method == :crr
        u = exp(volatility * sqrt(dt))
        d = 1 / u
        p = (carry - d) / (u - d)
    else
        d2 = (log(S / K) + (rate - yield - volatility^2 / 2) * maturity) / (volatility * sqrt(maturity))
        d1 = d2 + volatility * sqrt(maturity)
        p = _peizer_pratt_probability(d2, n)
        u = carry * _peizer_pratt_probability(d1, n) / p
        d = carry * _peizer_pratt_probability(-d1, n) / _peizer_pratt_probability(-d2, n)
    end
    0 < p < 1 && 0 < d < carry < u && all(isfinite, (u, d)) ||
        throw(ArgumentError("invalid tree factors; increase h or inspect extreme inputs"))

    # Initialize terminal exercise values -
    is_american = contract isa Union{MyAmericanCallContractModel,MyAmericanPutContractModel}
    logd, logratio = log(d), log(u / d)
    values = [_payoff(contract, S * exp(n * logd + j * logratio)) for j in 0:n]
    discount = exp(-rate * dt)

    # Roll the values back toward the current date -
    for level in (n - 1):-1:0
        spot = S * exp(level * logd)
        for j in 0:level
            continuation = discount * ((1 - p) * values[j + 1] + p * values[j + 2])
            values[j + 1] = is_american ? max(_payoff(contract, spot), continuation) : continuation
            spot *= u / d
        end
    end

    # Return -
    return values[1]
end

"""
    binomial_greeks(contract; method=:crr, h=201, T=1/365, σ=0.15,
        Sₒ=1.0, μ=0.0015, dividend_yield=0.0, spot_bump=0.01*Sₒ,
        volatility_bump=0.001, rate_bump=0.0001, time_bump=min(1/365, T/4))

Return `(delta, gamma, theta, vega, rho)` as raw derivatives of the unit long-option
value, using central differences of [`binomial_premium`](@ref). Each bumped price
rebuilds the lattice at the same step count. `theta` is the calendar-time derivative,
the negative derivative with respect to remaining time. Its units are USD/share/year.
Divide theta by 365 for a local daily quote, and vega and rho by 100 for quotes per
one percentage-point increase in decimal volatility and rate. Delta is share/share;
gamma is inverse USD/share. Multiply by the signed contract count and multiplier
for position sensitivities.

Bumps have the units of their inputs: USD/share, decimal volatility, inverse years,
and years, respectively. All must be positive; the spot, volatility, and remaining
time must stay positive after a negative bump. Sweep both bumps and tree depths:
a small bump can expose lattice noise, especially with CRR or near an American
exercise boundary. The daily theta quote is a scaled derivative; a full one-day
repricing can differ from it. Existing `delta`, `gamma`, `theta`, `vega`, and `rho`
functions retain their original numerical conventions.
"""
function binomial_greeks(contract::AbstractContractModel; method::Symbol=:crr,
    h::Integer=201, T::Real=1 / 365, σ::Real=0.15, Sₒ::Real=1.0,
    μ::Real=0.0015, dividend_yield::Real=0.0, spot_bump::Real=0.01 * Sₒ,
    volatility_bump::Real=0.001, rate_bump::Real=0.0001,
    time_bump::Real=min(1 / 365, T / 4))

    # Validate the finite-difference intervals -
    ds, dv, dr, dt = Float64.((spot_bump, volatility_bump, rate_bump, time_bump))
    all(x -> isfinite(x) && x > 0, (ds, dv, dr, dt)) || throw(ArgumentError("bumps must be finite and positive"))
    Sₒ > ds && σ > dv && T > dt || throw(ArgumentError("negative bumps must preserve positive spot, volatility, and maturity"))

    # Rebuild and reprice for each perturbation, keeping full precision -
    value(s, v, r, t) = binomial_premium(contract; method=method, h=h,
        Sₒ=s, σ=v, μ=r, T=t, dividend_yield=dividend_yield)
    base = value(Sₒ, σ, μ, T)
    up, down = value(Sₒ + ds, σ, μ, T), value(Sₒ - ds, σ, μ, T)
    delta_value = (up - down) / (2 * ds)
    gamma_value = (up - 2 * base + down) / ds^2
    theta_value = (value(Sₒ, σ, μ, T - dt) - value(Sₒ, σ, μ, T + dt)) / (2 * dt)
    vega_value = (value(Sₒ, σ + dv, μ, T) - value(Sₒ, σ - dv, μ, T)) / (2 * dv)
    rho_value = (value(Sₒ, σ, μ + dr, T) - value(Sₒ, σ, μ - dr, T)) / (2 * dr)

    # Return -
    return (delta=delta_value, gamma=gamma_value, theta=theta_value, vega=vega_value, rho=rho_value)
end
