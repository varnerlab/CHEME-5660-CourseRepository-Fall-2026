# monte_carlo_first_passage

Defined and documented in [src/Simulation.jl](../src/Simulation.jl).

```julia
monte_carlo_first_passage(
    S₀::Real, μ::Real, σ::Real, T::Real, N::Int;
    lower::Real, upper::Real,
    number_of_paths::Int = 100_000, seed::Int = 5660,
)
```

Simulates exact GBM transitions on a uniform observation grid, checks the exit conditions at each observation, and estimates the probabilities of a take-profit exit, a stop-loss exit, and no exit by the end of the holding period.

| Argument | Meaning and units |
| --- | --- |
| `S₀` | Positive initial share price; USD/share. |
| `μ` | Arithmetic GBM drift; year$^{-1}$. |
| `σ` | Positive GBM volatility; year$^{-1/2}$. |
| `T` | Positive holding period; years. |
| `N` | Positive integer number of observation intervals; their duration is `T/N` years. |
| `lower` | Positive stop-loss boundary below `S₀`; USD/share. |
| `upper` | Take-profit boundary above `S₀`; USD/share. |
| `number_of_paths` | Positive integer number of independently simulated paths. |
| `seed` | Integer seed for the local `MersenneTwister` random-number generator. |

At each observation, a price at or below `lower` is counted as a stop-loss exit, and a price at or above `upper` is counted as a take-profit exit. Simulation of that path stops at its first detected exit. A path without a detected exit by time `T` is counted as still open. Crossings between observations are not detected.

Returns `(probability = ..., standard_error = ...)`. Both entries are named tuples with fields `take_profit_first`, `stop_loss_first`, and `still_open`. Each probability is the count of paths with that outcome divided by `number_of_paths`. Each standard error is $\sqrt{\hat q(1-\hat q)/M}$, where $\hat q$ is that outcome's estimated probability and $M$ is `number_of_paths`. All returned values are dimensionless.

The caller must supply positive `σ`, `T`, `N`, and `number_of_paths`, with $0<\texttt{lower}<S_0<\texttt{upper}$. The function does not validate these conditions. With `T = 0.25` and `N = 63`, the observations correspond to daily checks under the notebook's 252-day trading-year convention.
