"""
    fit_parity(K::Vector{Float64}, ΔP::Vector{Float64}) -> NamedTuple

Fit the put–call parity line `ΔP = α + β*K` by least squares, where `ΔP` is the
call premium minus the put premium at the strike price `K`. For European options
with expected index level `F` under ℚ at expiration (the forward index level), parity
gives `α = 𝒟⁻¹*F` and `β = -𝒟⁻¹`, so the fit recovers the discount factor `𝒟⁻¹`
and the forward index level `F` without today's index level.

### Arguments
- `K::Vector{Float64}`: strike prices (index points). At least two distinct strikes.
- `ΔP::Vector{Float64}`: call premium minus put premium at each strike (index points).

### Returns
- `NamedTuple` with fields:
    - `𝒟⁻¹::Float64`: the discount factor from today to expiration, `-β` (dimensionless).
    - `F::Float64`: the forward index level, `α/𝒟⁻¹` (index points).
    - `α::Float64`, `β::Float64`: the intercept (index points) and slope (dimensionless) of the line.
    - `residual::Vector{Float64}`: `ΔP` minus the fitted line at each strike (index points).
"""
function fit_parity(K::Vector{Float64}, ΔP::Vector{Float64})::NamedTuple

    # least squares: one column of ones (intercept) and one of strikes (slope) -
    A = hcat(ones(length(K)), K);
    α, β = A \ ΔP; # β is negative: a higher strike lowers the call and raises the put

    # parity: α = 𝒟⁻¹F and β = -𝒟⁻¹ -
    𝒟⁻¹ = -β;
    F = α/𝒟⁻¹;
    residual = ΔP .- (α .+ β .* K);

    # return -
    return (𝒟⁻¹ = 𝒟⁻¹, F = F, α = α, β = β, residual = residual);
end
