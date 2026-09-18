"""
    gbm_prediction_band(median_price::Vector{Float64}, σ̂::Float64,
        τ::Vector{Float64}; z::Float64 = 1.96)

Return the lower and upper pointwise GBM price limits around `median_price`.

# Arguments
- `median_price`: positive model median prices, in USD/share, evaluated as
  `S₀ * exp(μ_g * τ)` for a fixed initial price and mean growth rate.
- `σ̂`: fixed, nonnegative volatility estimate, in year⁻¹ᐟ².
- `τ`: nonnegative elapsed times from the initial observation, in years.
- `z`: nonnegative standard normal interval multiplier; dimensionless.
  Values 1.0, 1.96, and 2.576 give approximately 68%, 95%, and 99% intervals.

# Returns
A tuple `(lower, upper)` of price vectors in USD/share, with one entry per
elapsed time. At zero elapsed time both limits equal the supplied median price.
The probabilities apply separately to each date with fitted parameters held
fixed; they do not include uncertainty in those parameter estimates.

The caller must supply finite inputs and equally long `median_price` and `τ`
vectors satisfying the conditions above; this helper does not validate them.
"""
function gbm_prediction_band(median_price::Vector{Float64}, σ̂::Float64,
    τ::Vector{Float64}; z::Float64 = 1.96)

    # Convert the normal interval limits to multiplicative price factors -
    lower = median_price .* exp.(-z * σ̂ * sqrt.(τ));
    upper = median_price .* exp.(z * σ̂ * sqrt.(τ));
    return lower, upper
end

"""
    band_coverage(S₀::Float64, ĝ::Float64, σ̂::Float64,
        τ::Vector{Float64}, actual::Vector{Float64}; z::Float64 = 1.96)

Return the fraction of forecast prices inside a fitted GBM prediction band.

# Arguments
- `S₀`: positive initial VWAP, in USD/share.
- `ĝ`: fixed mean growth rate estimate `μ̂_g = μ̂ - σ̂²/2`, in year⁻¹;
  this is the value stored in the parameter table's legacy `drift` column.
- `σ̂`: fixed, nonnegative volatility estimate, in year⁻¹ᐟ².
- `τ`: elapsed times in years; the first entry is zero and later entries
  are positive forecast times in increasing order.
- `actual`: positive observed VWAP values in USD/share, aligned with `τ`;
  the first entry is the initial observation.
- `z`: nonnegative, dimensionless interval multiplier; defaults to 1.96.

# Returns
A dimensionless fraction in `[0, 1]`. Equality with either limit counts as
inside. The first observation is excluded from both the count and denominator,
so only forecast dates contribute. This is observed pointwise-band coverage
along one price path; it is not a probability for an entire path.

The caller must supply finite inputs satisfying these conditions and equally
long `τ` and `actual` vectors with at least two entries. Inputs are not validated.
"""
function band_coverage(S₀::Float64, ĝ::Float64, σ̂::Float64,
    τ::Vector{Float64}, actual::Vector{Float64}; z::Float64 = 1.96)

    # Construct the same median-price path used in the notebook plot -
    μ̂ = ĝ + 0.5 * σ̂^2;
    median_value = S₀ * exp.((μ̂ - 0.5 * σ̂^2) * τ);
    lower, upper = gbm_prediction_band(median_value, σ̂, τ; z = z);

    # Score forecast dates, including prices equal to either band limit -
    inside = (actual .>= lower) .& (actual .<= upper);
    return count(inside[2:end]) / length(inside[2:end])
end

"""
    max_abs_z(S₀::Float64, ĝ::Float64, σ̂::Float64,
        τ::Vector{Float64}, actual::Vector{Float64})

Return the largest absolute standardized log-price deviation over forecast dates.

# Arguments
- `S₀`: positive initial VWAP, in USD/share.
- `ĝ`: fixed mean growth rate estimate `μ̂_g`, in year⁻¹.
- `σ̂`: fixed, strictly positive volatility estimate, in year⁻¹ᐟ².
- `τ`: elapsed times in years; the first entry is zero and later entries
  are positive forecast times in increasing order.
- `actual`: positive observed VWAP values in USD/share, aligned with `τ`;
  the first entry is the initial observation.

# Returns
The dimensionless maximum of
`abs((log(actual[k]/S₀) - ĝ*τ[k]) / (σ̂*sqrt(τ[k])))` for array indices
`k = 2:length(τ)`. Excluding the first entry avoids division by zero at
initialization. This summarizes deviations from the model's median path in
units of the modeled log-price standard deviation; it is not a p-value.

The caller must supply finite inputs satisfying these conditions and equally
long `τ` and `actual` vectors with at least two entries. Inputs are not validated.
"""
function max_abs_z(S₀::Float64, ĝ::Float64, σ̂::Float64,
    τ::Vector{Float64}, actual::Vector{Float64})

    # Standardize the observed log-price ratios at positive forecast times -
    z = (log.(actual[2:end] ./ S₀) .- ĝ .* τ[2:end]) ./
        (σ̂ .* sqrt.(τ[2:end]));
    return maximum(abs.(z))
end
