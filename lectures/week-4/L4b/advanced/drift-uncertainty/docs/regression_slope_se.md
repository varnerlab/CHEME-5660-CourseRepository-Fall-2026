# `regression_slope_se`

```julia
regression_slope_se(σ::Real, T_span::Real, N::Integer)
```

Calculate the standard error of the ordinary least-squares slope fitted to
`N + 1` equally spaced log-price observations, including time zero, under a
constant-parameter geometric Brownian motion model. The fit includes an intercept.

| Argument | Meaning | Units and conditions |
| --- | --- | --- |
| `σ` | Model volatility | Positive; yr⁻¹ᐟ² |
| `T_span` | Time from the first to the last observation | Positive; years |
| `N` | Number of growth intervals | Integer, at least 2; unitless |

The function returns `σ*sqrt(c_N/T_span)`, in yr⁻¹, where

$$
c_N=\frac{6}{5}\frac{N^2+2N+2}{(N+1)(N+2)}.
$$

Using estimated volatility gives an estimated standard error. Arguments outside
the stated domain raise `ArgumentError`.

## Derivation for an equally spaced grid

Let $t_j=j\Delta t$, $j=0,\ldots,N$, with
$T_{\mathrm{span}}=N\Delta t$. The ordinary least-squares slope can be written as

$$
\hat\mu_g=\sum_{j=0}^{N}w_j\ln(S_{t_j}),\qquad
w_j=\frac{t_j-\bar t}{\sum_{i=0}^{N}(t_i-\bar t)^2},
\qquad \bar t=\frac{T_{\mathrm{span}}}{2}.
$$

The GBM log-price model is $\ln(S_{t_j})=\ln(S_0)+\mu_g t_j+\epsilon_j$,
where $\epsilon_0=0$ and
$\epsilon_j=\sigma\sqrt{\Delta t}\sum_{k=1}^{j}Z_k$ for $j\geq1$.
The draws $Z_k$ are independent standard normal random variables.
Substitution leaves the random component $\sum_jw_j\epsilon_j$.
Collecting the coefficient of each draw gives

$$
\hat\mu_g-\mu_g
=\sum_{j=0}^{N}w_j\epsilon_j
=\sigma\sqrt{\Delta t}\sum_{k=1}^{N}
\left(\sum_{j=k}^{N}w_j\right)Z_k.
$$

Each $Z_k$ appears in every error from observation $k$ onward, explaining
its coefficient $\sum_{j=k}^{N}w_j$. Independence and unit variance of the
draws then give

$$
\operatorname{Var}(\hat\mu_g)
=\sigma^2\Delta t\sum_{k=1}^{N}
\left(\sum_{j=k}^{N}w_j\right)^2.
$$

The time-grid sums are

$$
\sum_{j=0}^{N}(t_j-\bar t)^2
=\frac{\Delta t^2N(N+1)(N+2)}{12},
\qquad
\sum_{j=k}^{N}(t_j-\bar t)
=\frac{\Delta t\,k(N+1-k)}{2}.
$$

Using

$$
\sum_{k=1}^{N}k^2(N+1-k)^2
=\frac{N(N+1)(N+2)(N^2+2N+2)}{30}
$$

then yields $\operatorname{Var}(\hat\mu_g)=c_N\sigma^2/T_{\mathrm{span}}$.
This is the same result as the slope entry of the full parameter covariance
matrix $\sigma^2\mathbf B\mathbf K\mathbf B^\top$, with
$K_{ij}=\min(t_i,t_j)$.

The equivalent covariance $K_{ij}=\min(t_i,t_j)$ is described in
[Fabrice Baudoin's Brownian-motion notes](https://fabricebaudoin.blog/2012/04/30/lecture-12-the-brownian-motion-definition-and-basic-properties/).
The general covariance transformation for least squares appears in
[William & Mary's regression notes, equation (6)](https://econ.pages.code.wm.edu/407/notes/docs/ols.html).

Defined in [Task 1 of the notebook](../CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb#Task-1:-Quantify-Uncertainty-in-the-Regression-Slope).
