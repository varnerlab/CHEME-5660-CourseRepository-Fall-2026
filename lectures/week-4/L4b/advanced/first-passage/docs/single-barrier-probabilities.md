# Single-barrier probability functions

These functions are defined and documented in [src/Probabilities.jl](../src/Probabilities.jl). They use the log price ratio
$X_t=\mu_g t+\sigma W(t)$, with $X_0=0$ and constant parameters.

## Arguments

Both functions accept the same arguments:

| Argument | Meaning and units |
| --- | --- |
| `b::Real` | Log-price boundary, $b=\ln(U/S_0)$; dimensionless. A take-profit price above the initial price gives $b>0$. |
| `μ_g::Real` | Mean growth rate, $\mu_g=\mu-\sigma^2/2$; year$^{-1}$. |
| `σ::Real` | Positive volatility; year$^{-1/2}$. |
| `T::Real` | Positive holding period; years. |

## terminal_above

```julia
terminal_above(b::Real, μ_g::Real, σ::Real, T::Real)
```

Returns $\mathbb P(X_T\geq b)$, the probability that the share price is at or above $U=S_0e^b$ at time $T$. The result is dimensionless. This function uses only the final price; it does not check for an earlier exit. The formula also allows $b\leq0$, although this notebook uses $b>0$.

The caller must supply $\sigma>0$ and $T>0$; this helper does not check those conditions.

## reach_upper

```julia
reach_upper(b::Real, μ_g::Real, σ::Real, T::Real)
```

Returns $\mathbb P(\max_{0\leq t\leq T}X_t\geq b)$, the probability that the share price reaches $U=S_0e^b$ by time $T$ under continuous monitoring. The result is dimensionless. There is a single upper boundary and no competing stop-loss.

The function raises an assertion error unless $b>0$. The caller must also supply $\sigma>0$ and $T>0$; those two conditions are not checked inside this helper.
