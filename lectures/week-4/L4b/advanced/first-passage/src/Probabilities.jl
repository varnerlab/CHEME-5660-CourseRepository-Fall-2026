"""
    terminal_above(b::Real, μ_g::Real, σ::Real, T::Real)

Return the probability that a GBM share price finishes at or above
`U = S₀ * exp(b)` at time `T`. The relative log price starts at zero and has
mean `μ_g * T` and standard deviation `σ * sqrt(T)`.

# Arguments
- `b`: dimensionless log-price boundary `log(U/S₀)`; any real value.
- `μ_g`: constant mean growth rate `μ - σ²/2`, in year⁻¹.
- `σ`: positive volatility, in year⁻¹ᐟ².
- `T`: positive holding period, in years.

# Returns
A dimensionless terminal probability. Earlier boundary crossings are not counted
if the price finishes below the boundary.

The caller must supply positive `σ` and `T`; the function does not validate them.
See also [`reach_upper`](@ref).
"""
terminal_above(b::Real, μ_g::Real, σ::Real, T::Real) = ccdf(Normal(), (b - μ_g*T)/(σ*sqrt(T))) # P(X_T ≥ b)

"""
    reach_upper(b::Real, μ_g::Real, σ::Real, T::Real)

Return the probability that a GBM share price reaches the upper boundary
`U = S₀ * exp(b)` by time `T` under continuous monitoring. Uses the reflection
formula for the relative log price `Xₜ = μ_g * t + σ * W(t)`, starting at zero.

# Arguments
- `b`: positive, dimensionless log-price boundary `log(U/S₀)`.
- `μ_g`: constant mean growth rate `μ - σ²/2`, in year⁻¹.
- `σ`: positive volatility, in year⁻¹ᐟ².
- `T`: positive holding period, in years.

# Returns
A dimensionless probability of reaching the upper boundary. There is no competing
lower boundary, and a path remains counted if it subsequently falls below `U`.

Raises `AssertionError` unless `b > 0`. The caller must also supply positive `σ`
and `T`; those conditions are not checked here. See also [`terminal_above`](@ref).
"""
function reach_upper(b::Real, μ_g::Real, σ::Real, T::Real) # P(max_{s≤T} X_s ≥ b), reflection principle with drift
    @assert b > 0
    z = σ*sqrt(T)
    return cdf(Normal(), (μ_g*T - b)/z) + exp(2μ_g*b/σ^2)*cdf(Normal(), (-μ_g*T - b)/z)
end
