# Online SIM path for the whole universe, shared by every backtest run.

"""
    MyOnlineSIM

Daily online SIM estimates over a run window. `rows` are the market-data row indices of the run;
`α` (yr⁻¹), `β` (dimensionless) and `σ_ε` (yr⁻¹) are `length(rows) × length(tickers)` matrices;
`σ_m` (yr⁻¹) is the EW SD of SPY growth. Row s holds the estimates after the update with the
growth into day `rows[s]`.
"""
mutable struct MyOnlineSIM
    rows::UnitRange{Int}
    α::Matrix{Float64}
    β::Matrix{Float64}
    σ_ε::Matrix{Float64}
    σ_m::Vector{Float64}
    MyOnlineSIM() = new()
end

"""
    build(::Type{MyOnlineSIM}, data::NamedTuple)::MyOnlineSIM

Build a `MyOnlineSIM` from a NamedTuple holding every field; throws `ArgumentError` on a missing one.
"""
function build(::Type{MyOnlineSIM}, data::NamedTuple)::MyOnlineSIM
    model = MyOnlineSIM()
    for f ∈ fieldnames(MyOnlineSIM)
        haskey(data, f) || throw(ArgumentError("Cannot build MyOnlineSIM: missing field $(f)"))
        setfield!(model, f, data[f])
    end
    return model
end

"""
    online_sim(md::MyMarketData, calib::MyCalibration; start::Date, stop::Date,
        half_life::Float64=63.0, prior_weight::Float64=63.0)::MyOnlineSIM

One EWLS pass over the trading days `start`..`stop` for every ticker in `md` (α, σ_ε in yr⁻¹,
β dimensionless), plus the EW SD of SPY growth σ_m (yr⁻¹). Daily growth is `log(a / b) / Δt`
with Δt = 1/252 yr. States start from `calib.base_sim` with market moments `calib.m_m` (yr⁻¹)
and `calib.v_m` (yr⁻²); half_life and prior_weight are in trading days. Uses data dated up to
each row's day only. Throws `ArgumentError` if `start` has no previous trading day or a ticker
is missing from `calib.base_sim`.
"""
function online_sim(md::MyMarketData, calib::MyCalibration; start::Date, stop::Date,
        half_life::Float64 = 63.0, prior_weight::Float64 = 63.0)::MyOnlineSIM
    i0 = index_of(md, start)
    i0 > 1 || throw(ArgumentError("start $(start) needs a previous trading day"))
    rows = i0:searchsortedlast(md.dates, stop)
    for t in md.tickers
        haskey(calib.base_sim, t) || throw(ArgumentError("ticker $(t) has no calibration entry"))
    end
    Δt = 1 / 252
    n = length(md.tickers)
    states = [ewls_init(calib.base_sim[t].α, calib.base_sim[t].β, calib.base_sim[t].σ_ε;
        half_life, prior_weight, market_mean = calib.m_m, market_variance = calib.v_m) for t in md.tickers]
    v = ewvar_init(calib.σ_m; half_life, prior_weight)
    α = Matrix{Float64}(undef, length(rows), n); β = similar(α); σ_ε = similar(α)
    σ_m = Vector{Float64}(undef, length(rows))
    for (s, i) in enumerate(rows)
        g_m = log(md.spy_close[i] / md.spy_close[i-1]) / Δt
        for j in 1:n
            ewls_update!(states[j], log(md.close[i, j] / md.close[i-1, j]) / Δt, g_m)
            α[s, j] = states[j].α; β[s, j] = states[j].β; σ_ε[s, j] = states[j].σ_ε
        end
        σ_m[s] = ewvar_update!(v, g_m)
    end
    return build(MyOnlineSIM, (rows = rows, α = α, β = β, σ_ε = σ_ε, σ_m = σ_m))
end
