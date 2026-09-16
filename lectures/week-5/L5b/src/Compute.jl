
"""
    ⊗(a::AbstractVector{<:Real}, b::AbstractVector{<:Real}) -> Matrix

Return the outer product of the real-valued vectors `a` and `b`.

### Arguments
- `a::AbstractVector{<:Real}`: a vector of length `m`.
- `b::AbstractVector{<:Real}`: a vector of length `n`.

### Returns
- `Y::Matrix`: an `m × n` matrix with `Y[i,j] = a[i]*b[j]`.
"""
function ⊗(a::AbstractVector{<:Real}, b::AbstractVector{<:Real})::Matrix

    # Initialize -
    m = length(a); # number of rows
    n = length(b); # number of columns
    T = promote_type(eltype(a), eltype(b)); # element type that can hold both inputs
    Y = Matrix{T}(undef, m, n);

    # Populate the outer product -
    for i ∈ 1:m
        for j ∈ 1:n
            Y[i,j] = a[i]*b[j];
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
calculated separately at each observation time; they do not specify a band
containing a stated fraction of complete paths.
"""
function scaled_wealth_quantiles(wealth::AbstractMatrix{<:Real}, initial_wealth::Real,
    probabilities::AbstractVector{<:Real})::Matrix{Float64}

    isfinite(initial_wealth) && initial_wealth > 0 ||
        throw(ArgumentError("initial_wealth must be finite and positive"))
    size(wealth, 2) > 0 || throw(ArgumentError("wealth must contain at least one path"))

    # Initialize the time-by-quantile output -
    number_of_times = size(wealth, 1); # number of observation times
    number_of_quantiles = length(probabilities); # number of requested probabilities
    Q = Matrix{Float64}(undef, number_of_times, number_of_quantiles);

    # Summarize the paths separately at each time -
    for (t, values) ∈ enumerate(eachrow(wealth))
        Q[t, :] = quantile(values, probabilities) ./ initial_wealth;
    end

    return Q
end
