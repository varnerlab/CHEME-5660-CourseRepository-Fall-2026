# fitted_normal_ad_bootstrap

```julia
fitted_normal_ad_bootstrap(x::AbstractVector{<:Real}; replicates::Int=1000, seed::Int=5660)
```

Defined in the [single-asset GBM parameter-estimation example](../CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb), under “Check: Are the Growth Rates Consistent with a Normal Distribution?” Run its defining cell before calling it elsewhere in the notebook.

The helper fits a normal distribution by maximum likelihood, computes the observed Anderson–Darling statistic, and compares it with statistics from independent simulated samples of the same size. It refits the normal distribution in every replicate.

## Arguments

- `x`: A vector of observations. The notebook supplies one-step growth rates in inverse years. The calculation assumes independent observations from a common normal distribution under the null hypothesis. Supply finite, nonconstant data; the helper does not validate these conditions.
- `replicates`: Number of simulated samples; use a positive integer. The default is `1000`.
- `seed`: Integer seed for a local `MersenneTwister` random-number generator. The default is `5660`.

## Return value

A named tuple with three fields:

- `A²`: The dimensionless Anderson–Darling statistic for the observations and their fitted normal distribution.
- `bootstrap_pvalue`: `(exceedances + 1)/(replicates + 1)`, where `exceedances` counts simulated statistics at least as large as the observed statistic. This value is dimensionless. With 1,000 replicates, its smallest possible value is `1/1001`.
- `replicates`: The number of simulated samples used.

The p-value accounts for fitting the normal parameters. It does not separately test independence or identify why observations disagree with the assumed model.

## References

- [Anderson–Darling tests in HypothesisTests.jl](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/)
- [Parametric-bootstrap goodness-of-fit procedure](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.goodness_of_fit.html)
