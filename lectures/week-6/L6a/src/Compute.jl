"""
    ⊗(a::AbstractVector{<:Real}, b::AbstractVector{<:Real}) -> Matrix

Return the outer product of the real-valued vectors `a` and `b`, the matrix
`a*transpose(b)`. Type `\\otimes` then Tab to enter the symbol `⊗`.

### Arguments
- `a::AbstractVector{<:Real}`: a vector of length `m`.
- `b::AbstractVector{<:Real}`: a vector of length `n`.

### Returns
- `Y::Matrix`: an `m × n` matrix with `Y[i,j] = a[i]*b[j]`. Its element type is
  `promote_type(eltype(a), eltype(b))`, e.g. `Float64` for `Int64` and `Float64` inputs.

### Example
```julia
[1, 2] ⊗ [3.0, 4.0, 5.0] # 2 × 3 matrix [3.0 4.0 5.0; 6.0 8.0 10.0]
```
"""
function ⊗(a::AbstractVector{<:Real}, b::AbstractVector{<:Real})::Matrix

    # Initialize -
    m = length(a); # number of rows
    n = length(b); # number of columns
    T = promote_type(eltype(a), eltype(b)); # common element type of the two inputs
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
