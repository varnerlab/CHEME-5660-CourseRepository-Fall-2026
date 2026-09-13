"""
    lattice_from_gbm(μ::Real, σ::Real, T::Real, N::Int)

Construct binomial price factors and an up probability for a GBM approximation.
The calibration matches the mean log return over each step; its log-return
variance approaches the GBM value as the time step decreases.

# Arguments
- `μ`: constant arithmetic GBM drift, in year⁻¹.
- `σ`: positive volatility, in year⁻¹ᐟ².
- `T`: positive holding period, in years.
- `N`: positive integer number of lattice steps.

# Returns
A named tuple `(u, d, p, Δt)`. The up factor `u`, down factor `d = 1/u`, and
up probability `p` are dimensionless; `Δt = T/N` is measured in years.

Raises `AssertionError` unless `0 < p < 1`. For valid model parameters, reduce
the time step if this check fails. Positive `σ`, `T`, and `N` are caller
requirements and are not checked separately.
"""
function lattice_from_gbm(μ::Real, σ::Real, T::Real, N::Int)
    Δt = T/N
    μ_g = μ - 0.5*σ^2
    u = exp(σ*sqrt(Δt)); d = 1/u
    p = 0.5*(1 + (μ_g/σ)*sqrt(Δt))
    @assert 0 < p < 1
    return (u = u, d = d, p = p, Δt = Δt)
end

"""
    first_passage_lattice(S₀::Real, μ::Real, σ::Real, T::Real, N::Int;
        lower::Real, upper::Real, check_every::Int = 1)

Calculate first-exit probabilities on a GBM-calibrated binomial lattice.
Carry forward only the probability of positions still open, testing the exit
conditions every `check_every` lattice steps.

# Arguments
- `S₀`: positive initial share price, in USD/share.
- `μ`: constant arithmetic GBM drift, in year⁻¹.
- `σ`: positive volatility, in year⁻¹ᐟ².
- `T`: positive holding period, in years.
- `N`: positive integer number of lattice steps.
- `lower`: positive stop-loss price below `S₀`, in USD/share.
- `upper`: take-profit price above `S₀`, in USD/share.
- `check_every`: positive integer number of steps between checks; must divide `N`.

# Returns
A named tuple of dimensionless probabilities:
- `take_profit_first`: first detected exit is at or above `upper`.
- `stop_loss_first`: first detected exit is at or below `lower`.
- `still_open`: no exit was detected through the final check at time `T`.

Crossings between checks do not trigger an exit. Initially all probability is at
`S₀`; contributions reaching the same open node are added. On a check, boundary
contributions are accumulated as exits and removed from subsequent propagation.

Asserts the check spacing, the calibration condition from [`lattice_from_gbm`](@ref),
and probability conservation within absolute tolerance `1e-12`. Other positivity
and boundary-ordering conditions are caller requirements and are not checked.
For `T = 0.25` and `N = 63*64`, `check_every = 64` gives daily monitoring.
"""
function first_passage_lattice(S₀::Real, μ::Real, σ::Real, T::Real, N::Int; lower::Real, upper::Real, check_every::Int = 1)
    @assert check_every >= 1 && N % check_every == 0 "the number of steps must be a multiple of check_every"
    lat = lattice_from_gbm(μ, σ, T, N)
    alive = [1.0]                      # open probability mass by up-count k = 0
    hit_lower = 0.0; hit_upper = 0.0
    for j ∈ 1:N
        next_alive = zeros(Float64, j + 1)
        monitor = (j % check_every == 0) # test the barriers only on monitoring dates
        for k_prev ∈ 0:(j-1)
            open_mass = alive[k_prev + 1]
            open_mass == 0.0 && continue
            for (k_new, branch_probability) ∈ ((k_prev, 1 - lat.p), (k_prev + 1, lat.p))
                mass = open_mass*branch_probability
                price = S₀*lat.u^k_new*lat.d^(j - k_new)
                if monitor && price <= lower
                    hit_lower += mass
                elseif monitor && price >= upper
                    hit_upper += mass
                else
                    next_alive[k_new + 1] += mass
                end
            end
        end
        alive = next_alive
    end
    still_open = sum(alive)
    @assert isapprox(hit_lower + hit_upper + still_open, 1.0; atol = 1e-12)
    return (take_profit_first = hit_upper, stop_loss_first = hit_lower, still_open = still_open)
end
