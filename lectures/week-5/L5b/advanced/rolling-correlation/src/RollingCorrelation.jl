"""
    rolling_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, L::Int)

Compute the sample Pearson correlation in each complete trailing window of `L`
aligned observations from `x` and `y`.

# Arguments
- `x`, `y`: Finite, real-valued vectors with equal lengths and ordinary one-based
  indexing. In this notebook they contain growth rates in inverse years, with
  corresponding entries covering the same trading interval.
- `L`: Number of observations per window, in trading days here; `2 ≤ L ≤ length(x)`.

# Returns
A `Vector{Float64}` of length `length(x)` containing dimensionless correlations.
Entries `1:L-1` are `NaN` because those endpoints lack a complete window. Entry
`k ≥ L` uses only entries `k-L+1:k`, centering each vector on its own window mean.
A window with zero sample variance in either vector has undefined correlation
and returns `NaN`.

# Assumptions and errors
Observations must already be aligned and finite; the function does not remove
missing or nonfinite values or inspect trading dates. It throws `DimensionMismatch`
for unequal input lengths and `ArgumentError` for a window outside the stated range.
Sample correlations are descriptive estimates; no sampling-independence assumption
is needed to compute them. The function does not calculate confidence intervals.
"""
function rolling_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, L::Int)
    n = length(x); # Number of aligned growth observations.
    length(y) == n || throw(DimensionMismatch("The two input vectors must have equal lengths."))
    2 <= L <= n || throw(ArgumentError("The window length must lie between 2 and the number of observations."))
    rho = fill(NaN, n); # Undefined until the first complete window is available.

    for k in L:n
        xs = @view x[(k-L+1):k]; # First asset's observations in the current window.
        ys = @view y[(k-L+1):k]; # Second asset's observations over the same intervals.
        rho[k] = cor(xs, ys);
    end
    return rho
end
