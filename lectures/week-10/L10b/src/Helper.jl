"""
    𝒫(model::AbstractContractModel; S::Float64, σ::Float64, T::Float64, g::Float64, h::Int64) -> Float64

Compute the premium of a call or put on the Leisen–Reimer tree. The name and the
inputs follow the lecture's premium function `𝒫(S, σ, T, g)`: we estimate a Greek by
calling `𝒫` twice, once with one input moved up and once with it moved down, and
holding the other inputs fixed.

The tree's factors depend on every input, so each call builds a new tree. The
backward induction, including the American exercise decision, is the same as on the
CRR tree. The work is done by `binomial_premium(...)` from the course package.

### Arguments
- `model::AbstractContractModel`: the contract, for example a
  `MyAmericanCallContractModel` or a `MyAmericanPutContractModel`. Its strike price `K`
  is used. Its `premium`, `sense`, and `copy` fields are not.
- `S::Float64`: the share price today (USD/share). Must be positive.
- `σ::Float64`: the volatility (units: yr^-1/2). Must be positive.
- `T::Float64`: the time to expiration (years). Must not be negative.
- `g::Float64`: the continuously compounded risk-free rate (units: 1/yr).
- `h::Int64`: the number of levels of the tree. The Leisen–Reimer tree needs an odd
  number, so an even `h` stops with an error.

### Returns
- `Float64`: the premium of one long contract, per share (USD/share), at full
  precision. Multiply by 100 for one contract.

### Example
```julia
𝒫_up = 𝒫(call_option_model; S = Sₒ + ε_S, σ = call_option_model.IV, T = T, g = gᵧ, h = h); # (USD/share)
```
"""
function 𝒫(model::AbstractContractModel; S::Float64, σ::Float64, T::Float64, g::Float64, h::Int64)::Float64

    # checks: the Leisen–Reimer tree is centered on the strike only when h is odd -
    @assert isodd(h) "the Leisen–Reimer tree needs an odd number of levels, but h = $(h)"

    # price the contract on the Leisen–Reimer tree (μ is the package's name for the risk-free rate) -
    premium = binomial_premium(model; method = :leisen_reimer, h = h, Sₒ = S, σ = σ, T = T, μ = g); # (USD/share)

    # return -
    return premium;
end
