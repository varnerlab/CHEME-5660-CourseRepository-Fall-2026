"""
    MyMarketData

Daily end-of-day market data for the study universe. Matrices are days × tickers;
`dates` and the price vectors have one entry per SPY trading day.

Fields: `dates`, `tickers` (sorted, SPY excluded), `open`/`close` (USD/share),
`volume` (shares/day), `spy_open`/`spy_close` (USD/share), `sector` (GICS, one per ticker),
`g_f` (risk-free growth rate, yr⁻¹, one per day).
"""
mutable struct MyMarketData
    dates::Vector{Date}
    tickers::Vector{String}
    open::Matrix{Float64}
    close::Matrix{Float64}
    volume::Matrix{Float64}
    spy_open::Vector{Float64}
    spy_close::Vector{Float64}
    sector::Vector{String}
    g_f::Vector{Float64}
    MyMarketData() = new()
end

"""
    MySIMParameterEstimate

Single Index Model fit for one asset: `α` (yr⁻¹), `β` (dimensionless), `σ_ε` (residual SD, yr⁻¹),
`r²` (dimensionless).
"""
mutable struct MySIMParameterEstimate
    α::Float64
    β::Float64
    σ_ε::Float64
    r²::Float64
    MySIMParameterEstimate() = new()
end

"""
    MyEWLSState

Exponentially weighted least-squares state for the online SIM update. Sufficient statistics
`Sw…Swyy` decay by `η` per observation; `α` (yr⁻¹), `β`, `σ_ε` (yr⁻¹) are the running estimates.
"""
mutable struct MyEWLSState
    Sw::Float64; Swx::Float64; Swy::Float64
    Swxx::Float64; Swxy::Float64; Swyy::Float64
    η::Float64
    α::Float64; β::Float64; σ_ε::Float64
    MyEWLSState() = new()
end

"""
    MyEWVarState

Exponentially weighted mean/variance state for the market growth rate. `Sw`, `Sx`, `Sxx` are the
decayed sums of weight, g_m and g_m² (g_m in yr⁻¹); `η` is the per-observation decay.
"""
mutable struct MyEWVarState
    Sw::Float64; Sx::Float64; Sxx::Float64
    η::Float64
    MyEWVarState() = new()
end

"""
    MyForecastModels

The JumpHMM models of the method-v2 factor forecast and their standardizing moments. Built with
`build_forecast_models` from the synthetic-market generator, or with `build(MyForecastModels, nt)`.

Fields:
- `tickers::Vector{String}`: the tickers that have a name model.
- `market`, `factors::Vector`, `names::Vector`: the JumpHMM models of SPY, of each sector factor and of each
  ticker (any type with a `forecast_draws` method).
- `sector_index::Vector{Int}`: the sector of each ticker (an index into `factors`).
- `δ::Vector{Float64}`: each ticker's sector loading (dimensionless).
- `ρ::Vector{Float64}`: the sector share of each ticker's non-market variance (dimensionless, in [0, 1]).
- `m_market`, `s_market`, `m_factor`, `s_factor`, `m_name`, `s_name`: the long-run mean and standard deviation
  (yr⁻¹) of each model's draws, which turn its draws into standardized draws.
"""
mutable struct MyForecastModels
    tickers::Vector{String}
    market::Any
    factors::Vector
    names::Vector
    sector_index::Vector{Int}
    δ::Vector{Float64}
    ρ::Vector{Float64}
    m_market::Float64
    s_market::Float64
    m_factor::Vector{Float64}
    s_factor::Vector{Float64}
    m_name::Vector{Float64}
    s_name::Vector{Float64}
    MyForecastModels() = new()
end
