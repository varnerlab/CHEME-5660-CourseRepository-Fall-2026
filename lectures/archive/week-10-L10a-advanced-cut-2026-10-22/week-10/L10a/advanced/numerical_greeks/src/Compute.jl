"""
    at_the_money(optionschain::DataFrame, type::String, Sₒ::Float64) -> DataFrameRow

Pick the at-the-money contract of one type from an options chain. The at-the-money
contract is the one whose strike price is nearest the share price `Sₒ`. Contracts
with no implied volatility in the chain are skipped, because the Greeks need one.
If two strikes are equally close, the first one in the chain is kept.

### Arguments
- `optionschain::DataFrame`: the chain for one ticker, trading session, and expiration.
  It must have the columns `type` (`"call"` or `"put"`), `strike` (USD/share), and
  `implied_vol` (units: yr^-1/2, or `missing`).
- `type::String`: the contract type to pick, `"call"` or `"put"`.
- `Sₒ::Float64`: the share price on the quote date (USD/share).

### Returns
- `DataFrameRow`: the row of `optionschain` that holds the at-the-money contract. Read
  its fields with a dot, for example `row.strike` or `row.implied_vol`.

### Example
```julia
call_row = at_the_money(optionschain, "call", Sₒ); # the at-the-money call
call_row.strike # its strike price (USD/share)
```
"""
function at_the_money(optionschain::DataFrame, type::String, Sₒ::Float64)::DataFrameRow

    # initialize -
    best_row = 0; # row number of the nearest strike found so far (0 means none yet)
    best_distance = Inf; # distance from Sₒ to that strike (USD/share), Inf means none yet

    # main loop: check every contract in the chain -
    for i ∈ 1:nrow(optionschain) # nrow(...) is the number of rows in a DataFrame

        # skip contracts of the other type, and contracts with no implied volatility -
        if optionschain[i, :type] != type || ismissing(optionschain[i, :implied_vol])
            continue; # this means skip to the next iteration of the loop
        end

        # is this strike nearer the share price than the best one so far?
        distance = abs(optionschain[i, :strike] - Sₒ); # (USD/share)
        if distance < best_distance
            best_distance = distance; # yes: remember how near it is
            best_row = i; # ... and which row it is in
        end
    end

    # We could have used filter(...) and argmin(...) to find the row in two lines,
    # but the loop above is more explicit and easier to read.

    # checks: the chain has at least one contract of this type with an implied volatility -
    @assert best_row > 0 "no $(type) contract in the chain has an implied volatility"

    # return -
    return optionschain[best_row, :]; # the whole row: every column, one contract
end

"""
    bsm_call(S::Float64, K::Float64, σ::Float64, g::Float64, T::Float64) -> NamedTuple

Compute the Black–Scholes–Merton premium and the five Greeks of a European call on a
share that pays no dividend:

    premium = S*N(d₊) - K*exp(-g*T)*N(d₋)
    Delta   = N(d₊)
    Gamma   = ϕ(d₊)/(S*σ*√T)
    Theta   = -S*ϕ(d₊)*σ/(2√T) - g*K*exp(-g*T)*N(d₋)
    Vega    = S*ϕ(d₊)*√T
    Rho     = K*T*exp(-g*T)*N(d₋)

where `d₊ = (ln(S/K) + (g + σ²/2)T)/(σ√T)`, `d₋ = d₊ - σ√T`, `N` is the standard normal
cumulative distribution function, and `ϕ` is the standard normal density.

Each Greek is a raw derivative. To match the quotes a trading platform shows, divide
Theta by 365 for a change per day, and divide Vega and Rho by 100 for a change per
percentage point of volatility or rate.

### Arguments
- `S::Float64`: the share price (USD/share). Must be positive.
- `K::Float64`: the strike price (USD/share). Must be positive.
- `σ::Float64`: the volatility (units: yr^-1/2). Must be positive.
- `g::Float64`: the continuously compounded risk-free rate (units: 1/yr).
- `T::Float64`: the time to expiration (years). Must be positive.

### Returns
- `NamedTuple` with fields, read with a dot (for example `bsm.delta`):
    - `premium::Float64`: the call premium (USD/share).
    - `delta::Float64`: change in premium per unit change in share price (share/share).
    - `gamma::Float64`: change in Delta per unit change in share price (1/(USD/share)).
    - `theta::Float64`: change in premium per year of calendar time (USD/share per year).
    - `vega::Float64`: change in premium per unit change in σ (USD/share per unit σ).
    - `rho::Float64`: change in premium per unit change in g (USD/share per unit g).

### Example
```julia
bsm = bsm_call(Sₒ, european_call.K, european_call.IV, gᵧ, T); # Greeks at today's share price
bsm.gamma # the BSM Gamma (1/(USD/share))
```
"""
function bsm_call(S::Float64, K::Float64, σ::Float64, g::Float64, T::Float64)::NamedTuple

    # initialize -
    Z = Normal(0.0, 1.0); # standard normal distribution, from the Distributions package
    discount = exp(-g*T); # discount factor from expiration back to today (dimensionless)

    # compute d₊ and d₋ -
    d₊ = (log(S/K) + (g + σ^2/2)*T)/(σ*sqrt(T)); # (dimensionless)
    d₋ = d₊ - σ*sqrt(T); # (dimensionless)

    # evaluate the normal functions once, so the formulas below read like the math -
    N₊ = cdf(Z, d₊); # N(d₊): cdf(...) is the cumulative distribution function
    N₋ = cdf(Z, d₋); # N(d₋)
    ϕ₊ = pdf(Z, d₊); # ϕ(d₊): pdf(...) is the probability density function

    # premium and the five Greeks -
    premium = S*N₊ - K*discount*N₋; # (USD/share)
    delta = N₊; # (share/share)
    gamma = ϕ₊/(S*σ*sqrt(T)); # (1/(USD/share))
    theta = -S*ϕ₊*σ/(2*sqrt(T)) - g*K*discount*N₋; # (USD/share per year)
    vega = S*ϕ₊*sqrt(T); # (USD/share per unit σ)
    rho = K*T*discount*N₋; # (USD/share per unit g)

    # return -
    return (premium = premium, delta = delta, gamma = gamma, theta = theta, vega = vega, rho = rho);
end

"""
    peizer_pratt(z::Float64, h::Int64) -> Float64

Compute the Peizer–Pratt inversion `H(z; h)` of the binomial distribution (method 2 in
Leisen and Reimer, 1996):

    H(z; h) = 1/2 + (sgn(z)/2)*√(1 - exp[-(z/(h + 1/3 + 0.1/(h + 1)))²*(h + 1/6)])

`H(z; h)` is an up probability. With that probability on every step, the chance that
more than half of the `h` moves are up is close to `N(z)`, the standard normal
cumulative distribution function at `z`. When the strike sits between the two middle
terminal nodes, more than half up means finishing above the strike.

The Leisen–Reimer tree uses `q = H(d₋; h)` as its risk-neutral up probability and
`q′ = H(d₊; h)` as the second probability that sets its up and down factors.

### Arguments
- `z::Float64`: the point at which to match `N(z)`, either `d₋` or `d₊` (dimensionless).
- `h::Int64`: the number of tree steps. Leisen and Reimer use an odd `h`, so the strike
  can sit between the two middle terminal nodes.

### Returns
- `Float64`: the probability `H(z; h)` (dimensionless). It is above 1/2 when `z > 0`,
  below 1/2 when `z < 0`, and equal to 1/2 when `z = 0`.

### Example
```julia
q = peizer_pratt(d₋, 51); # risk-neutral up probability on a 51-step tree
```
"""
function peizer_pratt(z::Float64, h::Int64)::Float64

    # the term inside the exponential -
    scaled_z = z/(h + 1/3 + 0.1/(h + 1)); # z divided by a correction for the number of steps
    exponent = -(scaled_z^2)*(h + 1/6); # always zero or negative

    # the square root: between 0 and 1, because the exponential is between 0 and 1 -
    root = sqrt(1 - exp(exponent));

    # return: sign(z) is +1 when z > 0, -1 when z < 0, and 0 when z = 0 -
    return 1/2 + (sign(z)/2)*root;
end

"""
    _premium_minus_payoff(contract::MyAmericanPutContractModel, S::Float64; method::Symbol,
        h::Int64, T::Float64, σ::Float64, μ::Float64) -> Float64

Compute the American put's tree premium minus its payoff `K - S` from exercising today.
The difference is zero where the holder exercises today, and positive where holding
the put is worth more. `exercise_boundary(...)` calls this helper at each step.

### Arguments
- `contract::MyAmericanPutContractModel`: the American put. Its strike `K` sets the payoff (USD/share).
- `S::Float64`: the share price at which to price the put (USD/share).
- `method::Symbol`: the tree, `:leisen_reimer` or `:crr`.
- `h::Int64`: the number of tree steps.
- `T::Float64`: the time to expiration (years).
- `σ::Float64`: the volatility (units: yr^-1/2).
- `μ::Float64`: the continuously compounded risk-free rate (units: 1/yr).

### Returns
- `Float64`: the premium minus the payoff (USD/share). It is never negative, because an
  American holder can always exercise.
"""
function _premium_minus_payoff(contract::MyAmericanPutContractModel, S::Float64; method::Symbol,
    h::Int64, T::Float64, σ::Float64, μ::Float64)::Float64

    # premium of the put on the tree, at the share price S -
    premium = binomial_premium(contract; method = method, h = h, T = T, σ = σ, Sₒ = S, μ = μ); # (USD/share)

    # payoff from exercising today -
    payoff = contract.K - S; # (USD/share)

    # return -
    return premium - payoff;
end

"""
    exercise_boundary(contract::MyAmericanPutContractModel; h::Int64, T::Float64,
        σ::Float64, μ::Float64, lo::Float64, hi::Float64, method::Symbol = :leisen_reimer,
        maxiter::Int64 = 50, tolerance::Float64 = 1e-9) -> Float64

Find the early-exercise boundary `S⋆` of an American put by bisection. Below `S⋆`,
exercising the put today is worth more than holding it, so the tree premium equals
the payoff `K - S`. `S⋆` is the largest share price at which they are equal.

The search starts from a bracket `[lo, hi]` that holds `S⋆`. Each step prices the put
at the middle of the bracket. If the premium equals the payoff there, `S⋆` is at or
above the middle, so the bottom of the bracket moves up to it. Otherwise, the top
moves down to it. Each step halves the bracket, so after `maxiter` steps its width is
`(hi - lo)/2^maxiter`.

### Arguments
- `contract::MyAmericanPutContractModel`: the American put. Its strike `K` sets the payoff (USD/share).
- `h::Int64`: the number of tree steps.
- `T::Float64`: the time to expiration (years).
- `σ::Float64`: the volatility (units: yr^-1/2).
- `μ::Float64`: the continuously compounded risk-free rate (units: 1/yr).
- `lo::Float64`: a share price below `S⋆`, where the holder exercises (USD/share).
- `hi::Float64`: a share price above `S⋆`, where holding beats exercising (USD/share).
- `method::Symbol`: the tree, `:leisen_reimer` or `:crr`. Default is `:leisen_reimer`.
- `maxiter::Int64`: the number of bisection steps. Default is `50`.
- `tolerance::Float64`: a premium minus payoff below this counts as zero (USD/share).
  Default is `1e-9`.

### Returns
- `Float64`: the bottom of the final bracket, our estimate of `S⋆` (USD/share).

Throws an `AssertionError` if `S⋆` is not inside the final bracket, which happens when
the starting `lo` is not in the exercise region or the starting `hi` is.

### Example
```julia
S_boundary = exercise_boundary(american_put; h = 801, T = T, σ = american_put.IV, μ = gᵧ,
    lo = 0.3*american_put.K, hi = american_put.K); # S⋆ on an 801-step Leisen–Reimer tree
```
"""
function exercise_boundary(contract::MyAmericanPutContractModel; h::Int64, T::Float64,
    σ::Float64, μ::Float64, lo::Float64, hi::Float64, method::Symbol = :leisen_reimer,
    maxiter::Int64 = 50, tolerance::Float64 = 1e-9)::Float64

    # initialize: the bracket [lower, upper] holds S⋆ -
    lower = lo; # in the exercise region (USD/share)
    upper = hi; # above the exercise region (USD/share)

    # main loop: each step halves the bracket -
    for _ ∈ 1:maxiter # the _ means we do not need the step number inside the loop

        # premium minus payoff at the middle of the bracket -
        middle = (lower + upper)/2; # (USD/share)
        gap = _premium_minus_payoff(contract, middle; method = method, h = h, T = T, σ = σ, μ = μ); # (USD/share)

        # move one end of the bracket to the middle -
        if gap < tolerance
            lower = middle; # the holder exercises at the middle, so S⋆ is at or above it
        else
            upper = middle; # the holder keeps the put at the middle, so S⋆ is below it
        end
    end

    # checks: lower is still in the exercise region and upper is not, so S⋆ lies between them -
    gap_lower = _premium_minus_payoff(contract, lower; method = method, h = h, T = T, σ = σ, μ = μ);
    gap_upper = _premium_minus_payoff(contract, upper; method = method, h = h, T = T, σ = σ, μ = μ);
    @assert gap_lower < tolerance && gap_upper > tolerance "the bracket lost the exercise boundary"

    # return -
    return lower;
end
