# Exponentially weighted correlation

This helper is defined and documented in
[src/ExponentiallyWeightedCorrelation.jl](../src/ExponentiallyWeightedCorrelation.jl)
and loaded by [Include.jl](../Include.jl). The
[rolling-correlation notebook](../CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb) develops the update, memory interpretation,
and comparison with rolling windows.

## ewma_correlation

```julia
ewma_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, λ::Real;
    burn_in::Int = 63)
```

`x` and `y` are equally long, finite, aligned observation vectors. Their units in
the notebook are inverse years, and each corresponding pair covers the same
trading interval. Ordinary one-based indexing is assumed. The dimensionless
decay factor satisfies `0 < λ < 1`. The initialization length satisfies
`1 ≤ burn_in ≤ length(x)` and is measured in observations (trading days here).

Returns a `Vector{Float64}` of dimensionless correlations. Entries before
`burn_in` are `NaN`. At `burn_in`, it uses the uncentered mean product and mean
squares of the first block. After that, each second moment follows
`moment[k] = λ*moment[k-1] + (1-λ)*new_product`. Each endpoint uses only current
and earlier observations. If either mean-square estimate is zero, correlation
is undefined and the result is `NaN`.

The helper does not subtract a mean. Its second moments are interpreted as
covariances under a zero-mean approximation; small mean growth relative to daily
variation motivates this approximation. It does not imply that expected asset
growth is exactly zero. Unequal input lengths raise `DimensionMismatch`;
invalid decay factors or initialization lengths raise `ArgumentError`. The
caller supplies finite, aligned data. No uncertainty intervals are calculated.

## Initialization and memory

After `m = k-burn_in` updates, the initial block has combined weight `λ^m`.
Each of its `burn_in` observations therefore has weight `λ^m/burn_in`. An
observation at index `q > burn_in` has weight `(1-λ)*λ^(k-q)` at endpoint `k`.
These weights sum to one. A constant nonzero series has zero centered variance
but a positive mean square, so the zero-mean convention can return a defined
value in that case; this differs from centered Pearson correlation.

The decay time `-1/log(λ)` is approximately `1/(1-λ)` observations when `λ` is
close to one. For `λ=0.94` the exact time is about 16.2 trading days and the
approximation gives 16.7 (rounded to 17 in the notebook). For `λ=0.99` the exact
time is about 99.5 and the approximation is 100.

For independent observations with a common variance `v`, a normalized weighted
average has variance `v*sum(w.^2)`. An average of `N` equally weighted observations
has variance `v/N`. Equating these variances defines `N_eff = 1/sum(w.^2)`.
For the long-history weights `(1-λ)*λ^m`, the geometric sum gives
`sum(w.^2) = (1-λ)/(1+λ)`, hence `N_eff = (1+λ)/(1-λ)`.
This count is about 32.3 for `λ=0.94` and 199 for `λ=0.99`. The initial equally
weighted block changes the finite-history weights until its contribution has
decayed. The count does not provide a confidence interval for the nonlinear
correlation ratio or account for dependence in the historical observations.

## Reference

The [RiskMetrics Technical Document (1996)](https://www.msci.com/documents/10199/5915b101-4206-4ba0-aee2-3449d5c7e95a)
describes exponentially weighted covariance and correlation in section 5.2.1.1
and its zero daily mean convention in section 5.3.1.1. The notebook applies that
convention to growth rates rather than log returns; the common time scaling
cancels in the correlation ratio.
