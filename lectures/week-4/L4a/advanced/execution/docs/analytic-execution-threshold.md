# analytic_execution_threshold

Defined in Task 2, under “Derive and check the success thresholds,” of the [execution-aware probability-of-profit notebook](../CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb).

Computes the analytic terminal mid-price and real-valued up-count thresholds,
then checks node returns to determine the first successful integer up-move count.

```julia
analytic_execution_threshold(;
    S₀_mid::Real, u::Real, d::Real, N::Int, Δt::Real, g_y::Real, n₀::Int,
    ρ_star::Real, spread_bps::Real=0.0, slippage_bps::Real=0.0,
    fixed_fee_per_side::Real=0.0, per_share_fee::Real=0.0,
)
```

All arguments are keywords. Prices, cost conventions, and the intended parameter
domain match [terminal_outcomes](terminal-outcomes.md); the up-move probability
`p` is not needed because this function identifies successful nodes without
calculating their probabilities.

| Argument | Meaning and units |
| --- | --- |
| `S₀_mid` | Positive initial mid-price, USD/share. |
| `u`, `d` | Dimensionless one-step price factors, with `0 < d < u`. |
| `N` | Number of lattice steps to sale, integer ≥ 1. |
| `Δt` | Positive step duration in years; holding period is `N*Δt`. |
| `g_y` | Continuously compounded annual benchmark growth rate, year⁻¹. |
| `n₀` | Positive integer number of shares. |
| `ρ_star` | Dimensionless strict target for discounted fractional return; must exceed −1. |
| `spread_bps` | Constant full spread in basis points of the mid-price; `0 ≤ spread_bps < 20000`. |
| `slippage_bps` | Adverse exit adjustment in basis points of the terminal bid; `0 ≤ slippage_bps < 10000`. |
| `fixed_fee_per_side` | Nonnegative fixed fee at each of entry and exit, USD. |
| `per_share_fee` | Nonnegative fee per share at each of entry and exit, USD/share. |

The implementation asserts only `ρ_star > -1`. The caller must supply the other
arguments within the intended domain above.

## Returned values and numerical behavior

Returns a named tuple containing:

| Field | Meaning |
| --- | --- |
| `minimum_terminal_mid` | Strict terminal mid-price threshold, USD/share. The terminal mid-price must exceed this value. |
| `τ` | Real-valued up-count threshold derived by taking logarithms of the price inequality. In exact arithmetic, successful counts satisfy `k > τ`. |
| `k_min` | First integer count in `0:N` whose computed discounted fractional return strictly exceeds `ρ_star`; `N + 1` if none succeeds. |

The function calculates `minimum_terminal_mid` and `τ` analytically, but obtains
`k_min` by checking node returns in increasing order using the same floating-point
cash-flow comparison as `terminal_outcomes`. It does not compute `k_min` by
rounding `τ`. This keeps the comparison consistent between the two functions;
it does not eliminate floating-point sensitivity at exact equality. The notebook
checks that the two functions return the same `k_min`.
