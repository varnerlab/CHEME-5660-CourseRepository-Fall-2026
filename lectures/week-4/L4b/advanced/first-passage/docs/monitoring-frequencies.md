# monitored_reach_frequencies

Defined and documented in [src/Simulation.jl](../src/Simulation.jl).

`monitored_reach_frequencies(b::Real, μ_g::Real, σ::Real, T::Real; steps_per_day::Int = 64, days::Int = 63, monitor_every = (64, 32, 16, 8, 4, 2, 1), number_of_paths::Int = 100_000, seed::Int = 5660)`

Simulates log prices relative to the initial price on a fine grid and estimates the probability of detecting an upper-boundary crossing under each requested monitoring schedule. Each schedule observes the same simulated paths.

| Argument | Meaning and units |
| --- | --- |
| `b` | Positive upper log-price boundary, `log(U/S₀)`; dimensionless. |
| `μ_g` | Mean growth rate, `μ - σ²/2`; year$^{-1}$. |
| `σ` | Positive GBM volatility; year$^{-1/2}$. |
| `T` | Positive holding period; years. |
| `steps_per_day` | Positive integer number of fine simulation steps per modeled trading day. |
| `days` | Positive integer number of modeled trading days in the holding period. |
| `monitor_every` | Positive integer spacings between observations, measured in fine-grid steps. Each spacing should divide `days * steps_per_day` so the schedule includes the final time. |
| `number_of_paths` | Positive integer number of independently simulated paths. |
| `seed` | Integer seed for the local `MersenneTwister` random-number generator. |

The fine grid has `N_grid = days * steps_per_day` intervals, each lasting `T/N_grid` years. The function starts each relative log price at zero and uses independent normal increments with mean `μ_g * T/N_grid` and standard deviation `σ * sqrt(T/N_grid)`. For spacing `m`, it observes indices `m, 2m, …, N_grid`. A path counts as a detected crossing if any observed log price is at least `b`; crossings between those observations are not detected.

Returns `(monitor_every = ..., probability = ..., number_of_paths = ..., N_grid = ...)`. The `probability` vector contains detected-crossing counts divided by `number_of_paths`, in the same order as `monitor_every`. The probabilities are dimensionless.

The default schedules observe prices 1, 2, 4, 8, 16, 32, and 64 times per modeled trading day. Their observation grids are nested, so a crossing detected by a coarser schedule remains detected by every finer schedule. Arbitrary schedules need not have this nesting property. The caller is responsible for the positive inputs and divisibility conditions above; the function does not validate them.
