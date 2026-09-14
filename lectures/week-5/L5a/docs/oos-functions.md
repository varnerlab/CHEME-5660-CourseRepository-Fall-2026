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
initial VWAP in USD/share; `ĝ` is mean growth in year⁻¹, distinct from arithmetic
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

All helpers assume finite inputs satisfying the documented conditions. They do
not perform input validation; see their source docstrings for the full contracts.
