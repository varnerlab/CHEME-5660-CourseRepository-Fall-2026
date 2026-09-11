# First-exit probability helpers

These functions are defined in the [first-passage example notebook](../CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb).
Run its setup and function-definition cells before calling them. The notebook
develops the probability equations; this page documents the inputs and results.

<a id="price_at"></a>
## price_at

```julia
price_at(S₀::Real, u::Real, d::Real, j::Int, k::Int)
```

Calculates the binomial node price `S₀*u^k*d^(j-k)`.

| Argument | Meaning |
|---|---|
| `S₀` | Initial share price, in USD/share. |
| `u`, `d` | Dimensionless one-step price-change factors. |
| `j` | Number of lattice steps, a nonnegative integer. |
| `k` | Number of up moves, with `0 ≤ k ≤ j`. |

Returns the node price in the same units as `S₀`. The helper evaluates the
expression directly; it does not validate the indices or test exit boundaries.

<a id="first_passage_binomial"></a>
## first_passage_binomial

```julia
first_passage_binomial(
    S₀::Real, u::Real, d::Real, p::Real, N::Int;
    lower::Real, upper::Real,
)
```

Calculates the probabilities of the first lower-boundary exit, first
upper-boundary exit, and still holding the shares after `N` steps. Moves are
independent with fixed factors and probabilities. Boundaries are checked after
each step: a price at or below `lower` triggers a stop-loss exit; a price at or
above `upper` triggers a take-profit exit. Positions already sold contribute
nothing to later steps.

| Argument | Meaning |
|---|---|
| `S₀` | Initial share price, in USD/share. For this price model, use a positive value. |
| `u`, `d` | Dimensionless one-step factors; the function requires `0 < d < u`. |
| `p` | Up-move probability, between zero and one inclusive. The down-move probability is `1-p`. |
| `N` | Number of monitored steps, an integer at least one. |
| `lower`, `upper` | Required keyword arguments giving price boundaries in USD/share, with `lower < S₀ < upper`. |

The horizon is a number of steps; the function does not take a step duration or
calculate discounting or sale proceeds. Because positive prices cannot reach
zero, `lower=0.0` disables the lower exit for the notebook's upper-only comparison.

### Returned values

The result is a named tuple:

| Field | Meaning |
|---|---|
| `summary` | A DataFrame with one row for each step from zero through `N`; columns are described below. |
| `alive` | The `N+1` terminal open-position probabilities. Entry `k+1` is the probability of `k` up moves and still holding the shares after checking step `N`. |
| `hit_lower` | Cumulative probability of a stop-loss exit by step `N`. |
| `hit_upper` | Cumulative probability of a take-profit exit by step `N`. |
| `still_open` | Probability of neither exit through step `N`, equal to `sum(alive)`. |

The summary columns distinguish exits **at** a step from exits **by** that step:

| Column | Meaning |
|---|---|
| `step` | Monitored step number; zero is the initial condition. |
| `hit_lower_at_step` | Probability of a new stop-loss exit at this step. |
| `hit_upper_at_step` | Probability of a new take-profit exit at this step. |
| `cumulative_lower` | Probability of a stop-loss exit by this step. |
| `cumulative_upper` | Probability of a take-profit exit by this step. |
| `open_probability` | Probability of still holding the shares after checking this step. |

At step zero, all exit probabilities are zero and `open_probability=1.0`.
At each subsequent step the function checks that `cumulative_lower +
cumulative_upper + open_probability` is approximately one, using Julia's
`isapprox(...; atol=1e-12)` with its default relative tolerance.

### Connection to the equations

The notebook uses the notation `a_{j,k}` for the probability of a
position still open after the current boundary check. The code stores the
corresponding values in `alive[k+1]`, because Julia arrays start at one. During
the transition to the next step, `next_alive` collects the probabilities that
remain open after the new boundary check.

The implementation sends each up/down contribution to its destination separately.
Contributions reaching the same node face the same price and boundary test, so
this is equivalent to adding them into the arrival probability first, as in the
notebook's derivation. The calculation uses `Float64` arrays and compares the
computed node prices directly with the boundaries.

<a id="terminal_upper_probability"></a>
## terminal_upper_probability

```julia
terminal_upper_probability(
    S₀::Real, u::Real, d::Real, p::Real, N::Int, upper::Real,
)
```

Calculates the probability that the stock price is at or above `upper` after
`N` binomial steps. It evaluates each terminal node price with `price_at` and
adds the binomial probabilities of the qualifying up-move counts. Earlier
boundary crossings do not remove paths from this terminal-only calculation.

| Argument | Meaning |
|---|---|
| `S₀` | Initial share price, in USD/share; use a positive value for this model. |
| `u`, `d` | Positive dimensionless one-step price-change factors, with `u > d`. |
| `p` | Up-move probability, between zero and one inclusive. |
| `N` | Number of steps, a nonnegative integer. |
| `upper` | Terminal price threshold in USD/share, supplied as a positional argument. |

Returns a scalar probability. A node whose computed price equals `upper` is
included. The sum starts at `0.0`, so an unreachable threshold returns zero
instead of attempting to reduce an empty collection. If every terminal node
qualifies, the result is one up to floating-point rounding.

The function checks only the terminal price. It does not implement a stop-loss
rule or calculate the probability of an earlier sale. For the notebook's
comparison, use `first_passage_binomial` with `lower=0.0` and the same upper
boundary and model parameters to obtain the monitored upper-exit probability.
