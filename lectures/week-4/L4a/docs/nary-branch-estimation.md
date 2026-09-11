# Estimating N-ary branch parameters

These local helpers are defined in [src/Split.jl](../src/Split.jl) and loaded
by [Include.jl](../Include.jl). They are used in Task 1 of
[the N-ary lattice example](../CHEME-5660-L4a-Example-N-Ary-Lattice-Fall-2026.ipynb).

## build_nary_lattice_from_growth_rate

```julia
build_nary_lattice_from_growth_rate(g::AbstractVector{<:Real};
    n::Int=3, dt::Real=1.0, method::Symbol=:quantile)
```

Estimates a one-step factor and probability for each branch. This function
returns branch parameters; the notebook constructs the multistep tree separately.

| Argument | Meaning |
| --- | --- |
| `g` | Vector of real log-growth rates. The example uses annualized rates in inverse years. Nonfinite values are discarded; at least one finite observation must remain. |
| `n` | Number of branches, an integer at least two; the notebook passes its branch-count variable using `n = m`. |
| `dt` | Positive step duration, in units reciprocal to those of `g`. The example explicitly passes `Δt = 1/252` years. The default is `1.0`. |
| `method` | `:equalwidth` divides the observed growth-rate range into equal-width bins. `:quantile` uses empirical quantiles to obtain approximately equal counts; ties can prevent equal counts. |

For each bin, the function averages the observed factors `exp(g * dt)` and
divides the bin count by the total retained observation count. Bins include
their lower edge and exclude their upper edge, except that the final bin
also includes its upper edge.

It returns a `NamedTuple` with these fields:

| Field | Contents |
| --- | --- |
| `edges` | `n + 1` bin boundaries, in the same units as `g`. |
| `avg_factor` | `n` dimensionless average price-change factors, ordered from smallest to largest. |
| `freq` | Corresponding empirical branch probabilities, summing to one. |
| `counts` | Number of retained observations in each bin. |
| `labels` | Bin labels `S1` through `Sn`. |
| `method`, `dt` | The chosen method and step duration. |
| `N` | Number of retained growth observations. This field is a sample count, not the lecture's holding-period step count. |

An empty bin raises an `ArgumentError`; use fewer branches or another binning
method. An unsupported method also raises an error. The function checks
`n ≥ 2` and that finite observations remain; callers must supply a positive `dt`.

## print_lattice

```julia
print_lattice(summary; digits=6)
```

Accepts the `NamedTuple` returned by the estimator, constructs a `DataFrame`,
and displays it using the course's compact `pretty_table` format. The columns
are `branch`, `growth_interval`, `factor`, `probability`, and `observations`.
Growth intervals use the units of the input growth rates; probabilities are
fractions. The last interval includes its upper boundary.

`digits` controls the displayed decimal places for factors and probabilities
and the rounding of interval boundaries. It returns `nothing` and does not
change the stored estimates. `DataFrames` and `PrettyTables` are loaded by
the notebook's setup file.
