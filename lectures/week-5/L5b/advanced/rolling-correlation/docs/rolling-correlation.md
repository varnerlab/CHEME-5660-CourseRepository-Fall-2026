# Rolling-correlation helper

The helper is defined and documented in [src/RollingCorrelation.jl](../src/RollingCorrelation.jl)
and loaded by [Include.jl](../Include.jl). The
[rolling-correlation notebook](../CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb) develops the calculation and interprets the results.

## rolling_correlation

```julia
rolling_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, L::Int)
```

The inputs `x` and `y` contain equally many finite, aligned observations. In the
notebook their units are inverse years, and corresponding entries refer to the
same trading interval. `L` is the window length in observations (trading days),
with `2 ≤ L ≤ length(x)`. Ordinary one-based indexing is assumed.

Returns a `Vector{Float64}` of dimensionless sample correlations, one per input
observation. The first `L-1` entries are `NaN`. Entry `k ≥ L` is the correlation
of entries `k-L+1:k`, after each series is centered on its own window mean.
A window with zero variance in either input has undefined correlation and gives
`NaN`. The helper uses [the cor(...) function](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.cor).

Unequal input lengths raise `DimensionMismatch`; an invalid window raises
`ArgumentError`. The caller supplies aligned, finite data. The function does not
filter the input or construct uncertainty intervals.

## Sampling uncertainty

The notebook's standard-error approximation `(1-rho^2)/sqrt(L)` is a large-sample
scale calculation for independent pairs from a bivariate normal distribution
with fixed population correlation `rho`. It is not a confidence bound established
for the historical time series.

One way to obtain this approximation is to start with the Fisher transform
`z = atanh(r)`. Its approximate standard error is `1/sqrt(L-3)` under the normal
sampling model, as described in the [Fisher-transform reference](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats._result_classes.PearsonRResult.confidence_interval.html).
The derivative of the inverse transform at the population value is `1-rho^2`.
A first-order propagation gives `(1-rho^2)/sqrt(L-3)`; replacing `L-3` by `L`
gives the leading large-sample expression used in the notebook.
