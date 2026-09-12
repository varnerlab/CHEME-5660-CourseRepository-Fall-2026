# `estimate_replicates`

```julia
estimate_replicates(μ_g::Real, σ::Real, T_span::Real, Δt::Real, R::Int;
                    seed::Int = 5660)
```

Simulate `R` independent GBM log-price histories and fit an intercept and slope
to each by ordinary least squares. Estimate volatility from each history's
one-step growth rates.

| Argument | Meaning | Units and conditions |
| --- | --- | --- |
| `μ_g` | True mean growth rate, μ − σ²/2 | yr⁻¹ |
| `σ` | True volatility | Positive; yr⁻¹ᐟ² |
| `T_span` | Observation period | Positive; years |
| `Δt` | Observation interval | Positive; years |
| `R` | Number of independent histories | Integer, at least 2 |
| `seed` | Seed for a local random-number generator | Integer; defaults to 5660 |

`T_span` must contain a whole number `N` of observation intervals, within
floating-point tolerance, and `N` must be at least 2. Invalid positive-domain,
interval-count, or replicate-count inputs raise `ArgumentError`.

Each history starts at log price zero (normalized initial price 1). Independent
normal increments generate the log-price path. Changing the initial log price
would shift the intercept without changing the slope or volatility estimate.
The regression uses all `N + 1` log prices, including the initial observation.

Returns a named tuple:

- `N`: number of growth intervals, unitless.
- `μ̂_g`: vector of `R` fitted regression slopes, in yr⁻¹.
- `σ_hat`: vector of `R` volatility estimates, in yr⁻¹ᐟ².

The slope is the second component of `A \ log_prices`, where `A` has a column
of ones and a column of times. Volatility is the sample standard deviation of
the growth rates, using the `N - 1` denominator, multiplied by `sqrt(Δt)`.

Defined in [Task 1 of the notebook](../CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb#Task-1:-Quantify-Uncertainty-in-the-Regression-Slope).
