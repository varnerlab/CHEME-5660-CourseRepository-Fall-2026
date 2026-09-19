"""
    ema_gbm_parameters(prices, mu_g, sigma; start_index=1, dt=1/252,
        half_life=21, decay=2.0^(-1/half_life))

Return daily GBM parameter estimates as a DataFrame, using only observations
available at each date. `prices` contains
positive USD/share observations; `mu_g` (year⁻¹) and `sigma` (year⁻¹ᐟ²) are
the training baseline. Initialize at the one-based `start_index`, then update
using each subsequent observed growth rate `g = log(S_k/S_(k-1))/dt` (year⁻¹).
No earlier testing growth rates are used as a warm-up. `dt` is measured in years per
interval; `half_life` is measured in observations.

Columns are `index`, mean growth `mu_g` (year⁻¹), `variance_growth` (year⁻²),
GBM volatility `sigma = sqrt(variance_growth*dt)` (year⁻¹ᐟ²), and arithmetic
drift `mu = mu_g + sigma^2/2` (year⁻¹). The centered variance is a weighted
population moment, not a finite-sample unbiased estimate. `decay=1` freezes the
initial states and is useful for checking the frozen-model limit.
"""
function ema_gbm_parameters(prices, mu_g, sigma; start_index=1, dt=1/252,
    half_life=21, decay=2.0^(-1/half_life))

    all(x -> isfinite(x) && x > 0, prices) || throw(ArgumentError("prices must be finite and positive"))
    start_index isa Integer && 1 <= start_index <= length(prices) || throw(ArgumentError("invalid start index"))
    isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be positive"))
    isfinite(half_life) && half_life > 0 || throw(ArgumentError("half-life must be positive"))
    isfinite(decay) && 0 < decay <= 1 || throw(ArgumentError("decay must lie in (0,1]"))
    isfinite(mu_g) && isfinite(sigma) && sigma >= 0 || throw(ArgumentError("invalid baseline parameters"))

    # Seed the observed growth-rate moments from the training estimates -
    m = Float64(mu_g); # mean growth (year⁻¹)
    v = Float64(sigma^2 / dt); # growth-rate variance (year⁻²), since Var(g) = σ²/Δt
    states = DataFrame(index=Int[], mu_g=Float64[], variance_growth=Float64[],
        sigma=Float64[], mu=Float64[]);
    for k in start_index:length(prices)
        if k > start_index
            g = (log(prices[k]) - log(prices[k-1])) / dt; # observed growth rate (year⁻¹)
            delta = g - m; # observed growth rate minus the previous mean
            m += (1-decay) * delta;
            v = decay * (v + (1-decay) * delta^2); # center consistently as the mean changes
        end
        push!(states, (k, m, v, sqrt(v*dt), m + v*dt/2)); # convert growth variance to GBM volatility
    end
    return states
end
