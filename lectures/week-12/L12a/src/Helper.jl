"""
    annualized_volatility(A::Vector{Int}; λ::Float64, Δt::Float64, σ_S::Float64, rng::AbstractRNG,
        noise_model::Symbol = :normal, ν::Float64 = 5.0) -> Float64

Compute the annualized volatility of the growth rates of one minority game, in percent.
The function adds the price noise to the attendance to get the growth rate in each
recorded round, `g = A/(λΔt) + (σ_S/√Δt) Z`. It returns the standard deviation of `g`
times `√Δt`, which has the same units as `σ_S`.

### Arguments
- `A::Vector{Int}`: the attendance in each recorded round (number of agents).
- `λ::Float64`: the liquidity, the attendance that moves the log price by one (number of agents). Must be positive.
- `Δt::Float64`: the length of one round (years). Must be positive.
- `σ_S::Float64`: the annualized volatility of the price noise (units: yr^-1/2). Must not be negative.
- `rng::AbstractRNG`: the random number generator for the price noise.
- `noise_model::Symbol`: the distribution of the standardized noise `Z`, either `:normal` or `:studentt`.
- `ν::Float64`: the degrees of freedom of the Student-t noise, used only when
  `noise_model = :studentt`. Must be greater than 2, so that the noise has a finite variance.

### Returns
- `Float64`: the annualized volatility of the growth rates (percent).

### Example
```julia
volatility = annualized_volatility(result.attendance; λ = λ, Δt = Δt, σ_S = σ_S, rng = price_rng); # (percent)
```
"""
function annualized_volatility(A::Vector{Int}; λ::Float64, Δt::Float64, σ_S::Float64, rng::AbstractRNG,
    noise_model::Symbol = :normal, ν::Float64 = 5.0)::Float64

    # checks: the inputs must describe a valid price rule -
    @assert λ > 0 "the liquidity λ must be positive"
    @assert Δt > 0 "the length of a round Δt must be positive"
    @assert σ_S >= 0 "the noise volatility σ_S must not be negative"
    @assert noise_model == :normal || noise_model == :studentt "noise_model must be :normal or :studentt"
    @assert noise_model == :normal || ν > 2 "the Student-t noise needs ν > 2 for a finite variance"

    # draw one standardized noise value for each recorded round -
    n = length(A); # number of recorded rounds
    if noise_model == :normal
        Z = randn(rng, n); # standard Normal draws
    else
        Z = sqrt((ν - 2)/ν) .* rand(rng, TDist(ν), n); # Student-t draws, rescaled to unit variance
    end

    # compute the growth rate in each round -
    g = A ./ (λ*Δt) .+ (σ_S/sqrt(Δt)) .* Z; # (1/yr)

    # return -
    return 100*std(g)*sqrt(Δt); # annualized, in percent
end
