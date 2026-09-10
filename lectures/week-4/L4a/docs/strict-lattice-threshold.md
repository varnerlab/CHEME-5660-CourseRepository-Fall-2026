# strict_lattice_threshold

Find the smallest up-move count whose computed scaled NPV strictly exceeds a
chosen terminal target. This helper is defined in
[the L4a cumulative-probability example](../CHEME-5660-L4a-Example-CumulativeProbabilityLattice-Fall-2026.ipynb),
under Task 2. Run its definition cell before calling it.

```julia
strict_lattice_threshold(ρ_star::Real, u::Real, d::Real,
                         N::Int, g_y::Real, Δt::Real)
```

## Arguments

| Argument | Meaning |
| --- | --- |
| `ρ_star` | Target scaled NPV, expressed as a dimensionless fraction. |
| `u`, `d` | Multiplicative up and down factors, with `u > d > 0`. |
| `N` | Number of lattice steps; a nonnegative integer. |
| `g_y` | Continuously compounded annual benchmark growth rate, in inverse years. |
| `Δt` | Duration of one lattice step in years; strictly positive. |

## Calculation and return value

For each integer `k` from `0` through `N`, the helper computes:

```julia
terminal_return = u^k * d^(N-k) * exp(-g_y*N*Δt) - 1
```

It returns the first `k` for which `terminal_return > ρ_star`. Equality does
not satisfy the target. A return value of `0` means every node exceeds the
target; `N + 1` means no node exceeds it. Targets at or below `-1` return `0`
immediately because positive model prices imply a scaled NPV greater than `-1`.

The helper checks computed returns directly rather than rounding a logarithmic
threshold. The computation still uses the numeric precision of its inputs.

The notebook stores the returned integer with:

```julia
kmin = strict_lattice_threshold(ρ₊, ū, d̄, TSIM, g_y, Δt)
```
