"""
    monte_carlo_first_passage(S₀::Real, μ::Real, σ::Real, T::Real, N::Int;
        lower::Real, upper::Real, number_of_paths::Int = 100_000,
        seed::Int = 5660)

Estimate first-exit probabilities by simulating exact GBM transitions on a
uniform grid of `N` observation intervals. Stop each path at its first detected
take-profit or stop-loss exit.

# Arguments
- `S₀`: positive initial share price, in USD/share.
- `μ`: constant arithmetic GBM drift, in year⁻¹.
- `σ`: positive volatility, in year⁻¹ᐟ².
- `T`: positive holding period, in years.
- `N`: positive integer number of observation intervals, each lasting `T/N` years.
- `lower`: positive stop-loss price below `S₀`, in USD/share.
- `upper`: take-profit price above `S₀`, in USD/share.
- `number_of_paths`: positive integer number of independent simulated paths.
- `seed`: integer seed for a local `MersenneTwister` generator.

# Returns
`(probability = ..., standard_error = ...)`. Each entry is a named tuple with
fields `take_profit_first`, `stop_loss_first`, and `still_open`. Probabilities
are outcome counts divided by `M = number_of_paths`; standard errors are
`sqrt(q̂ * (1 - q̂) / M)`. All returned quantities are dimensionless.

At an observation, equality with either boundary counts as an exit. A path with
no detected exit by `T` is still open. Crossings between observations are missed.
The caller must supply the positive inputs and ordered boundaries described
above; the function does not validate them. The local seed leaves the global
random-number generator unchanged.
"""
function monte_carlo_first_passage(S₀::Real, μ::Real, σ::Real, T::Real, N::Int; lower::Real, upper::Real,
        number_of_paths::Int = 100_000, seed::Int = 5660)
    rng = MersenneTwister(seed)
    Δt = T/N
    drift = (μ - 0.5*σ^2)*Δt
    shock = σ*sqrt(Δt)
    counts = Dict(:take_profit_first => 0, :stop_loss_first => 0, :still_open => 0)
    for _ ∈ 1:number_of_paths
        S = S₀
        outcome = :still_open
        for _ ∈ 1:N
            S *= exp(drift + shock*randn(rng)) # exact one-step GBM transition
            if S <= lower
                outcome = :stop_loss_first; break
            elseif S >= upper
                outcome = :take_profit_first; break
            end
        end
        counts[outcome] += 1
    end
    M = number_of_paths
    probs = (take_profit_first = counts[:take_profit_first]/M, stop_loss_first = counts[:stop_loss_first]/M, still_open = counts[:still_open]/M)
    se = map(p -> sqrt(p*(1 - p)/M), probs) # binomial standard errors
    return (probability = probs, standard_error = se)
end

"""
    monitored_reach_frequencies(b::Real, μ_g::Real, σ::Real, T::Real;
        steps_per_day::Int = 64, days::Int = 63,
        monitor_every = (64, 32, 16, 8, 4, 2, 1),
        number_of_paths::Int = 100_000, seed::Int = 5660)

Estimate upper-boundary reach probabilities for several observation schedules
using the same simulated GBM log-price paths. The relative log price starts at
zero and is simulated with exact normal increments on a uniform fine grid.

# Arguments
- `b`: positive, dimensionless upper log-price boundary `log(U/S₀)`.
- `μ_g`: constant mean growth rate `μ - σ²/2`, in year⁻¹.
- `σ`: positive volatility, in year⁻¹ᐟ².
- `T`: positive holding period, in years.
- `steps_per_day`: positive integer fine-grid steps per modeled trading day.
- `days`: positive integer modeled trading days in the holding period.
- `monitor_every`: positive integer spacings between checks, in fine-grid steps;
  each should divide `N_grid = days * steps_per_day` to include the final time.
- `number_of_paths`: positive integer number of independent simulated paths.
- `seed`: integer seed for a local `MersenneTwister` generator.

# Returns
`(monitor_every, probability, number_of_paths, N_grid)`, a named tuple.
`probability` contains dimensionless detected-crossing fractions, in the same
order as the returned `monitor_every` vector. The fine-step duration is `T/N_grid`
years; a spacing `m` observes indices `m, 2m, ..., N_grid` when `m` divides `N_grid`.

A path counts as a crossing if any observed log price is at least `b`; crossings
between observations are missed. Default schedules check 1, 2, 4, 8, 16, 32, and
64 times per modeled trading day. Those grids are nested, so detected crossings
cannot decrease with added observations. Arbitrary schedules need not be nested.
Positive inputs and divisibility are caller requirements and are not validated.
"""
function monitored_reach_frequencies(b::Real, μ_g::Real, σ::Real, T::Real; steps_per_day::Int = 64, days::Int = 63,
        monitor_every = (64, 32, 16, 8, 4, 2, 1), number_of_paths::Int = 100_000, seed::Int = 5660)
    N_grid = days*steps_per_day
    Δt_grid = T/N_grid
    drift = μ_g*Δt_grid; shock = σ*sqrt(Δt_grid)
    hits = zeros(Int, length(monitor_every))
    rng = MersenneTwister(seed)
    X = zeros(Float64, N_grid)
    for _ ∈ 1:number_of_paths
        x = 0.0
        for j ∈ 1:N_grid
            x += drift + shock*randn(rng)      # exact log-price increment on the fine grid
            X[j] = x
        end
        for (i, m) ∈ enumerate(monitor_every)  # same path, monitored at every m-th grid step
            reached = false
            for j ∈ m:m:N_grid
                if X[j] >= b
                    reached = true; break
                end
            end
            hits[i] += reached
        end
    end
    return (monitor_every = collect(monitor_every), probability = hits ./ number_of_paths, number_of_paths = number_of_paths, N_grid = N_grid)
end
