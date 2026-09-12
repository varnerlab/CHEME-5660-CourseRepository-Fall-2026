# `target_probability`

```julia
target_probability(μ_g::Real, σ::Real, T::Real, g_y::Real, ρ_star::Real)
```

Calculate the GBM probability that a long position exceeds a target scaled NPV
at its scheduled sale time.

| Argument | Meaning | Units and conditions |
| --- | --- | --- |
| `μ_g` | Mean growth rate, μ − σ²/2 | yr⁻¹ |
| `σ` | Volatility | Positive; yr⁻¹ᐟ² |
| `T` | Holding period | Positive; years |
| `g_y` | Constant, continuously compounded benchmark growth rate | yr⁻¹ |
| `ρ_star` | Target scaled NPV | Dimensionless; greater than −1 |

Returns the dimensionless probability

$$
\mathbb P(\rho_T>\rho_\star)
=1-\Phi\!\left(
\frac{\ln(1+\rho_\star)+(g_y-\mu_g)T}{\sigma\sqrt T}
\right).
$$

The function evaluates the normal complementary CDF directly. Volatility and
holding period must be positive, and the target must exceed −1; inputs outside
these domains raise `ArgumentError`. The calculation assumes a constant-parameter
GBM, a constant benchmark growth rate, and a scheduled sale without trading costs.
It does not incorporate estimation uncertainty automatically; Task 3 varies the
parameter inputs explicitly to examine their separate effects.

Defined in [Task 3 of the notebook](../CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb#Task-3:-Propagate-Regression-Uncertainty-to-the-Target-Probability).
