"""
    mp(λ, s², q)

Evaluate the Marchenko-Pastur reference density at eigenvalue `λ`.

# Arguments
- `λ`: dimensionless correlation eigenvalue where the density is evaluated.
- `s²`: positive, dimensionless variance scale. Use `1.0` for the original
  noise reference or the residual mean eigenvalue for the rescaled reference.
- `q`: dimensionless ratio of firms to observations, with `0 < q < 1`.

# Returns
A scalar density, zero at and outside `s²*(1 ± sqrt(q))^2`. Its units are
inverse to those of `λ`; correlation eigenvalues are dimensionless here.

The reference assumes independent, equal-variance observations in the
large-matrix limit. The caller supplies positive `s²` and `0 < q < 1`;
these conditions are not checked by the function.
"""
function mp(λ, s², q)
    λ_minus = (1 - sqrt(q))^2; # lower edge at unit variance
    λ_plus = (1 + sqrt(q))^2; # upper edge at unit variance
    if s²*λ_minus < λ < s²*λ_plus
        return sqrt((s²*λ_plus - λ)*(λ - s²*λ_minus))/(2π*q*s²*λ)
    end
    return 0.0
end

"""
    minvar(Σ)

Compute portfolio weights that minimize variance subject to their sum being one.

# Arguments
- `Σ`: square, symmetric positive-definite covariance matrix, with assets in
  the same order along both dimensions. Growth-rate covariances in this
  notebook have units of inverse years squared.

# Returns
A dimensionless weight vector in the matrix's asset order. The weights sum
to one, and negative weights (short positions) are allowed.

The calculation solves `Σ*w = ones(size(Σ, 1))` and normalizes the result.
The caller supplies a symmetric positive-definite matrix; the function does
not repair the covariance or impose bounds on individual or gross weights.
"""
function minvar(Σ)
    w = Symmetric(Σ) \ ones(size(Σ, 1)); # solve before normalizing the weights
    return w ./ sum(w)
end

"""
    realized_std(w, X)

Compute the sample standard deviation of the linear growth-rate proxy `X*w`.

# Arguments
- `w`: dimensionless portfolio-weight vector, with one entry per column of `X`.
- `X`: matrix of growth rates in inverse years, with observations in rows and
  assets in columns. The columns must follow the same asset order as `w`.

# Returns
A scalar in inverse years, using the sample variance denominator
`size(X, 1) - 1`. This measures variability of the linear growth-rate proxy.

The caller supplies at least two observations. The function does not
annualize the standard deviation or calculate exact portfolio log growth.
"""
function realized_std(w, X)
    return std(X*w)
end
