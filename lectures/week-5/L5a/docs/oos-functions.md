# Out-of-sample GBM functions

These helpers are defined and documented in
[src/OutOfSample.jl](../src/OutOfSample.jl) and loaded through
[`Include.jl`](../Include.jl). The
[out-of-sample example](../CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb)
develops the equations and interprets the results.

## gbm_prediction_band

```julia
gbm_prediction_band(median_price::Vector{Float64}, σ̂::Float64,
    τ::Vector{Float64}; z::Float64 = 1.96)
```

Returns `(lower, upper)`, the price limits `median_price .* exp.(±z*σ̂*sqrt.(τ))`,
in USD/share. `median_price` is the positive model median-price vector in
USD/share; `σ̂` is nonnegative volatility in year⁻¹ᐟ²; `τ` contains nonnegative
elapsed times in years. The dimensionless multiplier `z` must be nonnegative.
The two input vectors must have equal lengths.

Multipliers 1.0, 1.96, and 2.576 give approximately 68%, 95%, and 99% pointwise
intervals with fitted parameters held fixed. At time zero the two limits coincide.
These bands do not include uncertainty in estimated parameters.

## band_coverage

```julia
band_coverage(S₀::Float64, ĝ::Float64, σ̂::Float64,
    τ::Vector{Float64}, actual::Vector{Float64}; z::Float64 = 1.96)
```

Returns the dimensionless fraction of forecast observations inside the selected
GBM price band, including equality with either limit. `S₀` is the positive
initial VWAP in USD/share; `ĝ` is mean growth in year⁻¹, distinct from the
GBM drift; `σ̂` is nonnegative volatility in year⁻¹ᐟ². The keyword `z` is the
nonnegative, dimensionless normal interval multiplier.

The equally long vectors `τ` (years) and `actual` (positive VWAP in USD/share)
must contain at least two aligned entries. The first elapsed time is zero and
the later times are positive and increasing. The initial observation is excluded
from the numerator and denominator. Coverage describes the observed fraction of
forecast dates inside pointwise intervals along one realized path.

## max_abs_z

```julia
max_abs_z(S₀::Float64, ĝ::Float64, σ̂::Float64,
    τ::Vector{Float64}, actual::Vector{Float64})
```

Returns the largest absolute value of
`(log(actual[k]/S₀) - ĝ*τ[k]) / (σ̂*sqrt(τ[k]))` over array entries `k ≥ 2`.
Arguments and units match `band_coverage`, except that volatility must be
strictly positive and there is no `z` keyword. Initial time zero is excluded.
The result is a dimensionless diagnostic measured in modeled log-price standard
deviations; it is not a p-value.

These three numerical helpers assume finite inputs satisfying the documented
conditions. They do not perform input validation; see their source docstrings
for the full contracts.

## plot_gbm_oos

```julia
plot_gbm_oos(ticker::String, parameters_df::DataFrame,
    dataset::Dict{String,DataFrame}; Δt::Float64,
    number_of_observations::Int, number_of_paths::Int = 100)
```

Returns a `Plots.Plot` comparing simulated prices, the analytical expectation
and median, 68%/95%/99% pointwise bands, and observed testing VWAP. The title
reports the observed 95% coverage, excluding the initial observation.

`ticker` must be in both the training parameter table and testing dictionary.
`parameters_df.drift` stores mean growth in year⁻¹, and `volatility` is in
year⁻¹ᐟ². Testing tables supply chronologically ordered
`volume_weighted_average_price` values in USD/share. `Δt` is the positive
interval in years; `number_of_observations` includes the initial testing price
and must be between two and the selected history's length. `number_of_paths`
is a positive simulation count.

The helper constructs a fresh model using the selected asset's fixed training
estimates and starts every path at its first testing VWAP. It uses the current
random-number stream, so rerunning changes the sampled paths but not the
analytical curves or coverage. It leaves the input tables and the earlier
simulation variables unchanged. See the [source docstring](../src/OutOfSample.jl)
for the full assumptions.
