
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
