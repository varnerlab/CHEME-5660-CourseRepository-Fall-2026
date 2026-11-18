"""
    estimate_sim(g_m::AbstractVector, g_i::AbstractVector)::MySIMParameterEstimate

OLS Single Index Model g_i = α + β·g_m + ε. Inputs are growth rates (yr⁻¹); `α`, `σ_ε` are in yr⁻¹.
`σ_ε` uses the N−2 residual denominator.
"""
function estimate_sim(g_m::AbstractVector, g_i::AbstractVector)::MySIMParameterEstimate
    length(g_m) == length(g_i) || throw(DimensionMismatch("series must have equal length"))
    N = length(g_m)
    N > 2 || throw(ArgumentError("at least three observations are required"))
    m = Float64.(g_m); y = Float64.(g_i)
    X = hcat(ones(N), m)
    θ = X \ y
    res = y - X * θ
    ssr = dot(res, res)
    sst = sum(abs2, y .- mean(y))
    r² = sst > eps(Float64) ? 1 - ssr / sst : (ssr <= eps(Float64) ? 1.0 : 0.0)
    return build(MySIMParameterEstimate, (α = θ[1], β = θ[2], σ_ε = sqrt(max(ssr / (N - 2), 0.0)), r² = r²))
end

"""
    fit_base_sim(md::MyMarketData, start::Date, stop::Date)

Fit a SIM per ticker on growth rates (yr⁻¹, Δt = 1/252) between consecutive trading days inside
[`start`, `stop`]. Returns `(params, σ_m, m_m, v_m)`: `params::Dict{String,MySIMParameterEstimate}`;
`σ_m` (yr⁻¹) the sample SD (N−1) of SPY growth over the same days; `m_m` (yr⁻¹) the mean and
`v_m` (yr⁻²) the population variance (`corrected=false`) of that SPY growth, the training market
moments that seed `ewls_init`.
"""
function fit_base_sim(md::MyMarketData, start::Date, stop::Date)
    idx = findall(d -> start <= d <= stop, md.dates)
    length(idx) > 3 || throw(ArgumentError("fit window [$(start), $(stop)] has too few trading days"))
    rows = first(idx):last(idx)
    g_m = growth_rates(md.spy_close[rows])
    G = growth_rates(md.close[rows, :])
    params = Dict{String,MySIMParameterEstimate}()
    for (j, t) ∈ enumerate(md.tickers)
        params[t] = estimate_sim(g_m, G[:, j])
    end
    return (params = params, σ_m = std(g_m), m_m = mean(g_m), v_m = var(g_m; corrected = false))
end

"""
    ewls_init(α₀, β₀, σ_ε₀; half_life=63.0, prior_weight=63.0, market_mean=0.0, market_variance=1.0)::MyEWLSState

Initialize EWLS from a prior (α₀ yr⁻¹, β₀, σ_ε₀ yr⁻¹) worth `prior_weight` = N₀ pseudo-observations
(CHEME-5660 `AdaptivePortfolio.ewls_init`). The prior second-moment matrix is N₀·E[x xᵀ], x = [1, g_M],
with `market_mean` m (yr⁻¹) and `market_variance` v (yr⁻², population variance) the training-period
moments of market growth, so E[g_M²] = v + m². The defaults (0, 1) reproduce the legacy
unit-variance seed exactly. Decay η = 2^(−1/half_life) per observation (`half_life = Inf` gives η = 1).
The state returns the prior on day 0.
"""
function ewls_init(α₀::Real, β₀::Real, σ_ε₀::Real; half_life::Real = 63.0, prior_weight::Real = 63.0,
        market_mean::Real = 0.0, market_variance::Real = 1.0)::MyEWLSState
    half_life > 0 || throw(ArgumentError("half_life must be positive"))
    isfinite(prior_weight) && prior_weight > 0 || throw(ArgumentError("prior_weight must be finite and positive"))
    isfinite(market_variance) && market_variance > 0 || throw(ArgumentError("market_variance must be finite and positive"))
    isfinite(market_mean) || throw(ArgumentError("market_mean must be finite"))
    all(isfinite, (α₀, β₀, σ_ε₀)) && σ_ε₀ >= 0 || throw(ArgumentError("the prior (α₀, β₀, σ_ε₀) must be finite with σ_ε₀ ≥ 0"))
    m, v, N₀ = Float64(market_mean), Float64(market_variance), Float64(prior_weight)
    Exx = v + m^2
    s = MyEWLSState()
    s.Sw   = N₀
    s.Swx  = N₀ * m
    s.Swy  = N₀ * (α₀ + β₀ * m)
    s.Swxx = N₀ * Exx
    s.Swxy = N₀ * (α₀ * m + β₀ * Exx)
    s.Swyy = N₀ * (α₀^2 + 2α₀ * β₀ * m + β₀^2 * Exx + σ_ε₀^2)
    s.η = 2.0^(-1.0 / half_life)
    s.α = α₀; s.β = β₀; s.σ_ε = σ_ε₀
    return s
end

"""
    ewls_update!(s::MyEWLSState, g_i, g_m)::Tuple{Float64,Float64,Float64}

Decay the sums by η, add the observation (g_i, g_m in yr⁻¹) with unit weight, and return the
updated `(α, β, σ_ε)` (yr⁻¹, dimensionless, yr⁻¹).
"""
function ewls_update!(s::MyEWLSState, g_i::Real, g_m::Real)::Tuple{Float64,Float64,Float64}
    η = s.η
    s.Sw   = η * s.Sw   + 1.0
    s.Swx  = η * s.Swx  + g_m
    s.Swy  = η * s.Swy  + g_i
    s.Swxx = η * s.Swxx + g_m * g_m
    s.Swxy = η * s.Swxy + g_i * g_m
    s.Swyy = η * s.Swyy + g_i * g_i
    denom = s.Sw * s.Swxx - s.Swx^2
    if abs(denom) > 1e-12
        s.β = (s.Sw * s.Swxy - s.Swx * s.Swy) / denom
        s.α = (s.Swy - s.β * s.Swx) / s.Sw
        mse = (s.Swyy - 2.0 * s.β * s.Swxy - 2.0 * s.α * s.Swy + s.β^2 * s.Swxx +
               2.0 * s.α * s.β * s.Swx + s.α^2 * s.Sw) / s.Sw
        s.σ_ε = sqrt(max(mse, 0.0))
    end
    return (s.α, s.β, s.σ_ε)
end

"""
    ewvar_init(σ₀; half_life=63.0, prior_weight=63.0)::MyEWVarState

Initialize the EW variance of market growth from a prior SD `σ₀` (yr⁻¹) with prior mean 0.
η = 2^(−1/half_life); the prior seeds Sw = prior_weight, Sx = 0, Sxx = prior_weight·σ₀².
"""
function ewvar_init(σ₀::Real; half_life::Real = 63.0, prior_weight::Real = 63.0)::MyEWVarState
    return build(MyEWVarState, (Sw = prior_weight, Sx = 0.0, Sxx = prior_weight * σ₀^2,
                                η = 2.0^(-1.0 / half_life)))
end

"""
    ewvar_update!(s::MyEWVarState, g_m::Real)::Float64

Decay by η, add the market growth `g_m` (yr⁻¹) with unit weight, and return the updated σ_m (yr⁻¹):
the population SD around the exponentially weighted mean.
"""
function ewvar_update!(s::MyEWVarState, g_m::Real)::Float64
    s.Sw  = s.η * s.Sw  + 1.0
    s.Sx  = s.η * s.Sx  + g_m
    s.Sxx = s.η * s.Sxx + g_m * g_m
    return sqrt(max(s.Sxx / s.Sw - (s.Sx / s.Sw)^2, 0.0))
end

"""
    ema_series(prices::AbstractVector; span)::Vector{Float64}

Exponential moving average (smoothing 2/(span+1)) seeded at the first price (USD/share).
"""
function ema_series(prices::AbstractVector; span::Integer)::Vector{Float64}
    a = 2.0 / (span + 1.0)
    e = Vector{Float64}(undef, length(prices))
    e[1] = prices[1]
    for t ∈ 2:length(prices)
        e[t] = a * prices[t] + (1.0 - a) * e[t-1]
    end
    return e
end

"""
    market_state(spy_close, dates, d)::NamedTuple{(:g_m, :λ, :ḡ_M)}

Causal market state at decision date `d` (uses data through `d` only).
`g_m` = 252·log(spy[i]/spy[i−1]) (yr⁻¹); `λ` = −20·(EMA21/EMA63 − 1) on SPY closes with dates in
[d − 105 days, d] (start inclusive, as the trial's data request), seeded at the window's first close; `ḡ_M` (yr⁻¹) = mean of the last
min(252, i−1) SPY growth rates ending at `d`.
"""
function market_state(spy_close::AbstractVector, dates::Vector{Date}, d::Date)
    i = searchsortedfirst(dates, d)
    (i > length(dates) || dates[i] != d) && throw(ArgumentError("date $(d) is not a trading date"))
    i > 1 || throw(ArgumentError("market_state needs a previous trading day; $(d) is the first date"))
    g_m = growth_rates(spy_close[(i-1):i])[1]
    lo = searchsortedfirst(dates, d - Day(105))
    w = spy_close[lo:i]
    λ = -20.0 * (ema_series(w; span = 21)[end] / ema_series(w; span = 63)[end] - 1.0)
    ḡ_M = mean(growth_rates(spy_close[max(1, i - 252):i]))
    return (g_m = g_m, λ = λ, ḡ_M = ḡ_M)
end

"""
    preference_weights(α::Vector, β::Vector, g_m::Float64, λ::Float64)::Vector{Float64}

γᵢ = tanh(αᵢ/max(|βᵢ|^λ, 1e-8) + |βᵢ|^(1−λ)·g_m), with α, g_m in yr⁻¹; γ is dimensionless in (−1, 1).
"""
function preference_weights(α::Vector, β::Vector, g_m::Float64, λ::Float64)::Vector{Float64}
    return [tanh(α[i] / max(abs(β[i])^λ, 1e-8) + abs(β[i])^(1.0 - λ) * g_m) for i ∈ eachindex(α)]
end
