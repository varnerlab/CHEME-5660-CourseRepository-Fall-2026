# Frontier calculations

These helpers are defined in [src/FrontierGeometry.jl](../src/FrontierGeometry.jl)
and loaded by [Include.jl](../Include.jl). Task 1 of the
[frontier-geometry notebook](../CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb)
derives the formulas and constructs their inputs.

## frontier_weights

```julia
frontier_weights(g_target::Float64, parameters::NamedTuple)
```

The target `g_target` is an expected growth rate in inverse years. The named tuple
contains the two vectors `x = Σ \ ones(M)` and `y = Σ \ μ`, followed by the four
coefficients `a = sum(x)`, `b = sum(y)`, `c = dot(μ, y)`, and `d = a*c-b^2`.
The covariance `Σ` has units of inverse years squared, and the mean vector `μ`
has units of inverse years. All fields must come from the same inputs and asset
order. The covariance is positive definite, the means are not all equal, and
`d > 0`. Task 1 checks this condition once before sweeping over targets.

Returns a `Vector{Float64}` of dimensionless minimum-variance weights. The weights
sum to one and meet the equality growth target up to floating-point roundoff.
Negative weights are allowed. The helper reuses the supplied vectors and
coefficients; it does not repeat the matrix solves.

## frontier_variance

```julia
frontier_variance(g_target::Float64, parameters::NamedTuple)
```

Uses the same target, coefficients, and assumptions as `frontier_weights`.
Returns the `Float64` minimum variance in inverse years squared, computed as
`(a*g_target^2 - 2*b*g_target + c)/d`. Its square root is the standard deviation
plotted on the frontier's risk axis. The formula covers both frontier branches.

## solve_frontier_point

```julia
solve_frontier_point(g_target::Float64, mean_growth::Vector{Float64},
    covariance::Matrix{Float64}; lower::Float64 = -Inf, upper::Float64 = Inf)
```

Builds the fully invested, equality-target variance-minimization problem in JuMP
and solves it with MadNLP. The target and mean vector have units of inverse years;
the positive-definite covariance has units of inverse years squared and the same
asset order. Each portfolio weight lies between the dimensionless `lower` and
`upper` bounds. The defaults allow unrestricted weights; bounds `0.0` and `1.0`
give the long-only problem used in Task 3.

Returns a `Vector{Float64}` of dimensionless weights when JuMP reports a solved,
feasible model, or `nothing` otherwise. An infeasible target is one possible
reason for `nothing`. Budget, growth, and bound constraints hold to solver
tolerance. The caller supplies finite, dimensionally consistent inputs;
infinite weight bounds are allowed.

## interpolate_frontier_risk

```julia
interpolate_frontier_risk(frontier::DataFrame, g_target::Float64)
```

Estimates the frontier standard deviation at a target expected growth rate by
linear interpolation. The table has finite Float64 columns `g` and `σ`, both in
inverse years, with growth values in strictly increasing order. The target is
also finite and in inverse years.

Returns a `Float64` standard deviation. At a sampled target it returns the stored
risk; between two targets it linearly interpolates their risks. It returns `NaN`
outside the sampled range and does not extrapolate or solve another portfolio
problem. Task 3 uses it to compare the three frontiers at common growth targets
because their grids start at different GMV growth rates.
