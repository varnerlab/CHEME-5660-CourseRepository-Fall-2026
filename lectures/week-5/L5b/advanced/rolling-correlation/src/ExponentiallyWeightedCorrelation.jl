"""
    ewma_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, λ::Real;
        burn_in::Int = 63)

Compute exponentially weighted correlations using the zero-mean second-moment
convention and only data available at each reported endpoint.

# Arguments
- `x`, `y`: Equally long vectors of finite, aligned real observations with ordinary
  one-based indexing. In this notebook they contain growth rates in inverse years,
  with corresponding entries covering the same trading interval.
- `λ`: Dimensionless decay factor with `0 < λ < 1`. Each new observation receives
  weight `1-λ`, and the previous second-moment estimate receives weight `λ`.
- `burn_in`: Number of initial observations used for equally weighted second
  moments; `1 ≤ burn_in ≤ length(x)`. The default is 63 trading-day observations.

# Returns
A `Vector{Float64}` of dimensionless correlations with the same length as `x`.
The first `burn_in-1` entries are `NaN`. At `burn_in`, the function divides the
mean product by the square root of the two mean squares over the initial block.
Later entries use exponentially updated second moments. An endpoint with a zero
second moment in either series has undefined correlation and returns `NaN`.

# Assumptions and errors
The function does not subtract a sample mean. Its second moments represent
covariances under a zero-mean approximation, which is appropriate when mean
growth is small relative to daily growth-rate variation. This does not assume
zero long-run asset growth. Returned correlations do not include uncertainty
intervals. Dates must already be aligned, and inputs must be finite; neither is checked
or repaired here. Unequal lengths raise `DimensionMismatch`; invalid `λ` or
`burn_in` raises `ArgumentError`.
"""
function ewma_correlation(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, λ::Real; burn_in::Int = 63)
    n = length(x); # Number of aligned growth observations.
    length(y) == n || throw(DimensionMismatch("The two input vectors must have equal lengths."))
    0 < λ < 1 || throw(ArgumentError("The decay factor must lie strictly between zero and one."))
    1 <= burn_in <= n || throw(ArgumentError("The initialization length must lie between 1 and the number of observations."))

    # Initialize second moments using only the first observed block.
    vx = mean(abs2, x[1:burn_in]); # First asset's mean square, in inverse years squared.
    vy = mean(abs2, y[1:burn_in]); # Second asset's mean square, in inverse years squared.
    cxy = mean(x[1:burn_in] .* y[1:burn_in]); # Mean product, in inverse years squared.
    rho = fill(NaN, n); # Undefined until the initial block is complete.
    rho[burn_in] = cxy/sqrt(vx*vy);

    # Update with the newest observation and the previous second moments.
    for k in (burn_in+1):n
        vx = λ*vx + (1 - λ)*x[k]^2;
        vy = λ*vy + (1 - λ)*y[k]^2;
        cxy = λ*cxy + (1 - λ)*x[k]*y[k];
        rho[k] = cxy/sqrt(vx*vy);
    end
    return rho
end
