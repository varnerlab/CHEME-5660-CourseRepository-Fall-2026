# terminal_outcomes

Defined in Task 2 of the [execution-aware probability-of-profit notebook](../CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb).

Evaluates the discounted fractional return at each terminal node of a binomial
mid-price lattice, then sums the probabilities of nodes strictly above the target.

```julia
terminal_outcomes(;
    S₀_mid::Real, u::Real, d::Real, p::Real, N::Int, Δt::Real, g_y::Real,
    n₀::Int, ρ_star::Real, spread_bps::Real=0.0, slippage_bps::Real=0.0,
    fixed_fee_per_side::Real=0.0, per_share_fee::Real=0.0,
)
```

All arguments are keyword arguments. The four execution-cost arguments default
to zero, yielding the frictionless calculation.

| Argument | Meaning and units |
| --- | --- |
| `S₀_mid` | Positive initial mid-price, USD/share. |
| `u`, `d` | Dimensionless one-step price factors, with `0 < d < u`. |
| `p` | Real-world up-move probability, between zero and one inclusive. |
| `N` | Number of steps to the scheduled sale, integer ≥ 1. |
| `Δt` | Positive step duration in years; the holding period is `N*Δt`. |
| `g_y` | Continuously compounded annual benchmark growth rate, year⁻¹. |
| `n₀` | Positive integer number of shares. |
| `ρ_star` | Dimensionless strict target for discounted fractional return; must exceed −1. |
| `spread_bps` | Full bid–ask spread in basis points of the mid-price, constant at entry and exit; `0 ≤ spread_bps < 20000`. |
| `slippage_bps` | Adverse exit adjustment in basis points of the terminal bid; `0 ≤ slippage_bps < 10000`. |
| `fixed_fee_per_side` | Nonnegative fixed fee at each of entry and exit, USD. |
| `per_share_fee` | Nonnegative fee per share at each of entry and exit, USD/share. |

## Returned values

Returns a named tuple with the following fields:

| Field | Meaning |
| --- | --- |
| `outcomes` | DataFrame with one row for each up-move count `k = 0:N`. |
| `entry_ask` | Entry price including the half-spread, USD/share. |
| `initial_outlay` | Share purchase cost plus entry fee, USD. |
| `entry_fee`, `exit_fee` | Total fee at each date, USD. Both equal `fixed_fee_per_side + n₀*per_share_fee`. |
| `k_min` | Smallest up-move count strictly exceeding the target; `N + 1` if no node succeeds, and zero if every node succeeds. |
| `probability_of_profit` | Sum of probabilities of nodes strictly exceeding `ρ_star`. This is a target-exceedance probability; the target need not be zero. |

The `outcomes` table contains `up_moves`, `probability`, `terminal_mid`
(USD/share), `executable_exit` (USD/share), `npv` (time-0 USD), `ρ`
(dimensionless NPV divided by initial outlay), and `success` (the Boolean
comparison `ρ > ρ_star`). Node probabilities follow the binomial distribution
with parameters `N` and `p`.

The implementation evaluates the strict comparison directly in floating-point
arithmetic. It asserts the argument bounds above, that node probabilities sum
approximately to one, and that returns are sorted by up-move count.
