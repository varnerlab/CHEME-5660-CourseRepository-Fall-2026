"""
    ⊗(a::AbstractVector{<:Real}, b::AbstractVector{<:Real}) -> Matrix

Return the outer product of the real-valued vectors `a` and `b`, the matrix
`a*transpose(b)`. Type `\\otimes` then Tab to enter the symbol `⊗`.

### Arguments
- `a::AbstractVector{<:Real}`: a vector of length `m`.
- `b::AbstractVector{<:Real}`: a vector of length `n`.

### Returns
- `Y::Matrix`: an `m × n` matrix with `Y[i,j] = a[i]*b[j]`. Its element type is
  wide enough to hold both inputs, e.g. `Float64` when `a` holds integers and
  `b` holds floats.

### Example
```julia
[1, 2] ⊗ [3.0, 4.0, 5.0] # 2 × 3 matrix [3.0 4.0 5.0; 6.0 8.0 10.0]
```
"""
function ⊗(a::AbstractVector{<:Real}, b::AbstractVector{<:Real})::Matrix

    # Initialize -
    m = length(a); # number of rows
    n = length(b); # number of columns
    T = promote_type(eltype(a), eltype(b)); # element type that can hold both inputs
    Y = Matrix{T}(undef, m, n); # allocate without filling, every entry is set below

    # Populate the outer product -
    for i ∈ 1:m
        for j ∈ 1:n
            Y[i,j] = a[i]*b[j]; # row i scales b by a[i]
        end
    end

    # Return the matrix -
    return Y
end

"""
    scaled_wealth_quantiles(wealth::AbstractMatrix{<:Real}, initial_wealth::Real,
                           probabilities::AbstractVector{<:Real}) -> Matrix{Float64}

Calculate wealth quantiles across simulated paths at each observation time,
then divide by the initial investment.

### Arguments
- `wealth`: simulated wealth in USD, with observation times in rows and paths
  in columns. Each row must contain at least one path and finite observations.
- `initial_wealth`: the finite, positive initial investment in USD.
- `probabilities`: requested quantile probabilities between zero and one.

### Returns
- A dimensionless matrix with one row per observation time and one column per
  probability, in the supplied order. Each entry is a wealth quantile divided
  by `initial_wealth`.

### Notes
Uses the default interpolation rule of `Statistics.quantile`. Quantiles are
calculated separately at each observation time, so a band drawn from two columns
describes the spread of wealth at each time. A single path can leave and re-enter
that band, so the band does not contain a stated fraction of complete paths.

### Example
```julia
Q = scaled_wealth_quantiles(wealth, 10_000.0, [0.05, 0.5, 0.95]);
Q[:, 2] # median scaled wealth W_t/W₀ at each observation time
```
"""
function scaled_wealth_quantiles(wealth::AbstractMatrix{<:Real}, initial_wealth::Real,
    probabilities::AbstractVector{<:Real})::Matrix{Float64}

    # Check the inputs -
    # `cond || throw(...)` runs the throw only when cond is false.
    isfinite(initial_wealth) && initial_wealth > 0 ||
        throw(ArgumentError("initial_wealth must be finite and positive"))
    size(wealth, 2) > 0 || throw(ArgumentError("wealth must contain at least one path"))

    # Initialize the time-by-quantile output -
    number_of_times = size(wealth, 1); # number of observation times
    number_of_quantiles = length(probabilities); # number of requested probabilities
    Q = Matrix{Float64}(undef, number_of_times, number_of_quantiles);

    # Summarize the paths separately at each time -
    # eachrow gives one row (one time, all paths) per step, and enumerate adds the row index t.
    for (t, values) ∈ enumerate(eachrow(wealth))
        Q[t, :] = quantile(values, probabilities) ./ initial_wealth; # USD / USD, dimensionless
    end

    # Return the scaled quantiles -
    return Q
end
