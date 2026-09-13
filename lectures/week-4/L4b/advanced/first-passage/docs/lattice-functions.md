# Lattice functions for first-passage probabilities

These helpers are defined and documented in [src/Lattice.jl](../src/Lattice.jl).

## lattice_from_gbm

```julia
lattice_from_gbm(μ::Real, σ::Real, T::Real, N::Int)
```

Constructs the binomial factors and up probability from the GBM parameters.

| Argument | Meaning and units |
| --- | --- |
| `μ` | Arithmetic GBM drift; year$^{-1}$. |
| `σ` | Positive GBM volatility; year$^{-1/2}$. |
| `T` | Positive holding period; years. |
| `N` | Positive integer number of lattice steps. |

Returns the named tuple `(u, d, p, Δt)`: the dimensionless up and down factors, dimensionless up probability, and step duration in years. The mean growth rate used in the calibration is $\mu_g=\mu-\sigma^2/2$.

The function asserts that $0<p<1$. For positive volatility and step duration, this requires $|(\mu_g/\sigma)\sqrt{\Delta t}|<1$. The caller must supply positive `σ`, `T`, and `N`; these conditions are not checked separately.

## first_passage_lattice

```julia
first_passage_lattice(
    S₀::Real, μ::Real, σ::Real, T::Real, N::Int;
    lower::Real, upper::Real, check_every::Int = 1,
)
```

Calculates the probabilities of the first take-profit exit, the first stop-loss exit, and no exit by the end of the holding period. It uses the calibration returned by [the lattice_from_gbm(...) function](#lattice_from_gbm) and checks the exit conditions every `check_every` lattice steps.

The arguments `μ`, `σ`, `T`, and `N` have the meanings and units given above. The additional arguments are:

| Argument | Meaning and units |
| --- | --- |
| `S₀` | Positive initial share price; USD/share. |
| `lower` | Positive stop-loss boundary below `S₀`; USD/share. |
| `upper` | Take-profit boundary above `S₀`; USD/share. |
| `check_every` | Positive integer number of lattice steps between exit checks. Must divide `N`. |

Returns a named tuple with three dimensionless probabilities:

- `take_profit_first`: first detected exit has price at or above `upper`.
- `stop_loss_first`: first detected exit has price at or below `lower`.
- `still_open`: no exit has been detected through the final check at time `T`.

The function asserts that `check_every >= 1`, that `N` is a multiple of `check_every`, and that the returned probabilities sum to one within an absolute tolerance of $10^{-12}$. It also inherits the calibration check on `p`. The caller must supply valid positive model parameters and ordered prices, $0<\texttt{lower}<S_0<\texttt{upper}$; these conditions are not checked separately.

For `N = 63*64`, setting `check_every = 64` gives 63 checks over the holding period; setting `check_every = 1` checks at all 4032 lattice steps. The former represents daily monitoring for the notebook's quarter-year example. The latter is a finite-step approximation to continuous monitoring.
