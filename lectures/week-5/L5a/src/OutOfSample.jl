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

"""
    plot_gbm_oos(ticker::String, parameters_df::DataFrame,
        dataset::Dict{String,DataFrame}; Δt::Float64,
        number_of_observations::Int, number_of_paths::Int = 100)

Plot a selected asset's GBM simulations, analytical price distribution, and
observed testing prices using the same visual conventions as Task 2.

# Arguments
- `ticker`: asset symbol present in both `parameters_df` and `dataset`.
- `parameters_df`: training estimates with columns `ticker`, `drift` (the
  mean growth rate `μ̂_g`, in year⁻¹), and `volatility` (in year⁻¹ᐟ²).
- `dataset`: testing tables keyed by ticker, with chronologically ordered
  `volume_weighted_average_price` observations in USD/share.
- `Δt`: positive interval between observations, in years.
- `number_of_observations`: at least two testing rows, including the initial
  observation; the selected asset must have at least this many rows.
- `number_of_paths`: positive number of simulated trajectories.

# Returns and assumptions
A `Plots.Plot` with gray simulated paths, a dashed blue expectation, a blue
median, shaded 68%/95%/99% pointwise prediction bands, and red observed VWAP.
The title reports the observed 95% coverage, excluding the initial observation.
Time is measured in years from the first testing observation.

All paths start from the selected asset's first testing VWAP. Its training
estimates remain fixed; mean growth is converted to GBM drift as `μ̂_g + σ̂²/2`.
The bands exclude parameter uncertainty and describe separate forecast dates,
not simultaneous coverage of a path. Prices must be positive and finite, with
finite mean growth and nonnegative finite volatility, as in the scoring helpers.
Simulations use the current random-number stream; rerunning draws new paths
while the analytical curves, observed prices, and coverage remain unchanged.
The input tables and the notebook's Task 1 simulation variables are not modified.
"""
function plot_gbm_oos(ticker::String, parameters_df::DataFrame,
    dataset::Dict{String,DataFrame}; Δt::Float64,
    number_of_observations::Int, number_of_paths::Int = 100)

    # Match this selection to its own testing prices and training estimates -
    haskey(dataset, ticker) || throw(ArgumentError("no testing prices for $(ticker)"));
    j = findfirst(==(ticker), parameters_df.ticker);
    isnothing(j) && throw(ArgumentError("no training parameters for $(ticker)"));
    2 <= number_of_observations <= nrow(dataset[ticker]) ||
        throw(ArgumentError("number_of_observations must be between 2 and the testing-history length"));
    isfinite(Δt) && Δt > 0 || throw(ArgumentError("Δt must be positive and finite"));
    number_of_paths > 0 || throw(ArgumentError("number_of_paths must be positive"));

    actual = dataset[ticker][1:number_of_observations, :volume_weighted_average_price] |> collect;
    S₀ = actual[1]; # selected asset's first testing VWAP (USD/share)
    ĝ = parameters_df[j, :drift]; # fitted mean growth rate μ̂_g (1/year)
    σ̂ = parameters_df[j, :volatility]; # fitted volatility (1/sqrt(year))
    μ̂ = ĝ + 0.5*σ̂^2; # GBM drift (1/year)
    model = build(MyGeometricBrownianMotionEquityModel, (μ = μ̂, σ = σ̂));

    # Use one time point per observed price, including the shared initial condition -
    T₁ = 0.0; # elapsed time at the initial observation (years)
    T₂ = (number_of_observations - 1)*Δt; # elapsed time at the final observation (years)
    simulation_data = (Sₒ = S₀, T₁ = T₁, T₂ = T₂, Δt = Δt);
    X = VLQuantitativeFinancePackage.sample(model, simulation_data;
        number_of_paths = number_of_paths);
    expectation_array = expectation(model, simulation_data);
    τ = expectation_array[:, 1]; # elapsed time from this asset's initial observation (years)
    median_value = S₀*exp.(ĝ*τ); # analytical median price (USD/share)
    (L68, U68) = gbm_prediction_band(median_value, σ̂, τ; z = 1.0);
    (L95, U95) = gbm_prediction_band(median_value, σ̂, τ; z = 1.96);
    (L99, U99) = gbm_prediction_band(median_value, σ̂, τ; z = 2.576);
    c95 = band_coverage(S₀, ĝ, σ̂, τ, actual; z = 1.96); # forecast-day coverage fraction

    # Match Task 2: layer the widest band first and keep the observed path on top -
    p = plot(τ, U99, fillrange=L99, c=:deepskyblue1, alpha=0.25, label="99% band", lw=0);
    plot!(p, τ, U95, fillrange=L95, c=:deepskyblue1, alpha=0.35, label="95% band", lw=0);
    plot!(p, τ, U68, fillrange=L68, c=:deepskyblue1, alpha=0.6, label="68% band", lw=0);
    plot!(p, τ, expectation_array[:, 2], c=:blue, lw=3, ls=:dash, label="expectation");
    plot!(p, τ, median_value, c=:blue, lw=1, label="median");
    for i ∈ 2:size(X, 2) # column 1 is time; columns 2:end are simulated prices
        plot!(p, X[:, 1], X[:, i], c=:gray50, lw=1, alpha=0.2, label="");
    end
    plot!(p, τ, actual, lw=3, c=:red, label="Firm-$(ticker) actual (2025)");
    plot!(p, xlabel="Time (years)", ylabel="Firm-$(ticker) VWAP (USD/share)",
        title="$(ticker): 95% band coverage = $(round(100*c95, digits=1))%",
        bg="gray95", background_color_outside="white", framestyle=:box,
        fg_legend=:transparent, legend=:topleft,
        left_margin=5Plots.mm, bottom_margin=5Plots.mm);
    return p
end
