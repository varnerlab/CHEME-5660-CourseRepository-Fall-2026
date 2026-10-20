"""
    forward_premium(type::Symbol, F::Float64, K::Float64, T::Float64, 𝒟⁻¹::Float64,
        σ::Float64) -> Float64

Black–Scholes–Merton premium of a European call or put, written with the forward
level `F` in place of the index level (replace `S(0)` by `𝒟⁻¹*F`):

    call:  𝒟⁻¹*(N(d₊)*F - N(d₋)*K)
    put:   𝒟⁻¹*(N(-d₋)*K - N(-d₊)*F)

where `d₊ = (ln(F/K) + σ²T/2)/(σ√T)`, `d₋ = d₊ - σ√T`, and `N` is the standard
normal cumulative distribution function.

### Arguments
- `type::Symbol`: `:call` or `:put`.
- `F::Float64`: forward index level, the expected index level at expiration under ℚ (index points).
- `K::Float64`: strike price (index points).
- `T::Float64`: time to expiration (years).
- `𝒟⁻¹::Float64`: discount factor from today to expiration (dimensionless).
- `σ::Float64`: volatility (units: yr^-1/2). Must be positive.

### Returns
- `Float64`: the premium (index points).
"""
function forward_premium(type::Symbol, F::Float64, K::Float64, T::Float64, 𝒟⁻¹::Float64,
    σ::Float64)::Float64

    # the BSM arguments, written with the forward -
    d₊ = (log(F/K) + 0.5*σ^2*T)/(σ*sqrt(T));
    d₋ = d₊ - σ*sqrt(T);
    N(x) = cdf(Normal(), x); # standard normal CDF

    # return -
    return type == :call ? 𝒟⁻¹*(N(d₊)*F - N(d₋)*K) : 𝒟⁻¹*(N(-d₋)*K - N(-d₊)*F);
end

"""
    implied_volatility(type::Symbol, premium::Float64, F::Float64, K::Float64, T::Float64,
        𝒟⁻¹::Float64; σ_lo::Float64 = 1e-4, σ_hi::Float64 = 3.0, ϵ::Float64 = 1e-8,
        maxiter::Int64 = 100) -> Float64

Back out the implied volatility `σ̂` of a European call or put by bisection, following
the lecture's pseudocode: halve the bracket `[σ_lo, σ_hi]` until it is narrower than
`ϵ` or `maxiter` steps have run, keeping the half whose premiums bracket the market
premium. The BSM premium rises with `σ`, so exactly one `σ` matches the market premium.

### Arguments
- `type::Symbol`: `:call` or `:put`.
- `premium::Float64`: market premium 𝒫^market, here the quote midpoint (index points).
- `F::Float64`, `K::Float64`, `T::Float64`, `𝒟⁻¹::Float64`: forward index level (index points),
  strike price (index points), time to expiration (years), and discount factor
  (dimensionless), as in [`forward_premium`](@ref).
- `σ_lo::Float64`, `σ_hi::Float64`: starting volatility bracket (units: yr^-1/2).
- `ϵ::Float64`: stop when the bracket is narrower than this (units: yr^-1/2).
- `maxiter::Int64`: largest number of bisection steps.

### Returns
- `Float64`: the implied volatility, the midpoint of the final bracket (units: yr^-1/2).

Throws a `DomainError` if the market premium lies outside the premiums at `σ_lo` and
`σ_hi`, for example when a quote sits below the option's lowest possible premium.
"""
function implied_volatility(type::Symbol, premium::Float64, F::Float64, K::Float64,
    T::Float64, 𝒟⁻¹::Float64; σ_lo::Float64 = 1e-4, σ_hi::Float64 = 3.0,
    ϵ::Float64 = 1e-8, maxiter::Int64 = 100)::Float64

    # check: the starting bracket must contain the market premium -
    P_lo = forward_premium(type, F, K, T, 𝒟⁻¹, σ_lo);
    P_hi = forward_premium(type, F, K, T, 𝒟⁻¹, σ_hi);
    (P_lo ≤ premium ≤ P_hi) || throw(DomainError(premium, "market premium outside [$(P_lo), $(P_hi)]"));

    # bisection: keep the half of the bracket that still contains the market premium -
    i = 1;
    while (σ_hi - σ_lo > ϵ) && (i ≤ maxiter)
        σ_mid = (σ_lo + σ_hi)/2;
        if forward_premium(type, F, K, T, 𝒟⁻¹, σ_mid) < premium
            σ_lo = σ_mid; # the premium at σ_mid is too low: the answer is above σ_mid
        else
            σ_hi = σ_mid;
        end
        i += 1;
    end

    # return the midpoint of the final bracket -
    return (σ_lo + σ_hi)/2;
end
