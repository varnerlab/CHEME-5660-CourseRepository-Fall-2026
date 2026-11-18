# 2014–2024 calibration bundle for the screened utility-panel study.

"""
    MyCalibration

Baseline values fitted once on the training window: `base_sim` (per-ticker SIM fit, α in yr⁻¹),
`σ_m` (yr⁻¹, N−1 SD of SPY growth), `m_m` (yr⁻¹, mean SPY growth), `v_m` (yr⁻², population
variance of SPY growth), `λ` (dimensionless residual shrinkage), and the window `train_start`,
`train_stop`.
"""
mutable struct MyCalibration
    base_sim::Dict{String,MySIMParameterEstimate}
    σ_m::Float64
    m_m::Float64
    v_m::Float64
    λ::Float64
    train_start::Date
    train_stop::Date
    MyCalibration() = new()
end

"""
    build(::Type{MyCalibration}, data::NamedTuple)::MyCalibration

Build a `MyCalibration` from a NamedTuple holding every field; throws `ArgumentError` on a missing one.
"""
function build(::Type{MyCalibration}, data::NamedTuple)::MyCalibration
    model = MyCalibration()
    for f ∈ fieldnames(MyCalibration)
        haskey(data, f) || throw(ArgumentError("Cannot build MyCalibration: missing field $(f)"))
        setfield!(model, f, data[f])
    end
    return model
end

"""
    calibrate(md::MyMarketData; train_start::Date, train_stop::Date, seed::Int=5660,
        n_portfolios::Int=200, window::Int=126)::MyCalibration

Fit the SIM, SPY growth moments (yr⁻¹, yr⁻²) and residual shrinkage λ on the dates in
[`train_start`, `train_stop`]. `seed`, `n_portfolios` (count) and `window` (the study's residual
covariance window `omega_window`, trading days) drive `choose_shrinkage`.
"""
function calibrate(md::MyMarketData; train_start::Date, train_stop::Date, seed::Int=5660,
    n_portfolios::Int=200, window::Int=126)::MyCalibration
    fit = fit_base_sim(md, train_start, train_stop)
    λ = choose_shrinkage(md, train_start, train_stop; n_portfolios=n_portfolios, seed=seed, window=window)
    return build(MyCalibration, (base_sim=fit.params, σ_m=fit.σ_m, m_m=fit.m_m, v_m=fit.v_m, λ=λ,
        train_start=train_start, train_stop=train_stop))
end

"""
    save_calibration(path::AbstractString, c::MyCalibration)

Write `c` to a JLD2 file at `path` under the key `"calibration"`.
"""
function save_calibration(path::AbstractString, c::MyCalibration)
    jldsave(path; calibration=c)
    return nothing
end

"""
    load_calibration(path::AbstractString)::MyCalibration

Read the `"calibration"` entry of the JLD2 file at `path`.
"""
function load_calibration(path::AbstractString)::MyCalibration
    return load(path, "calibration")
end

"""
    calibration_summary(md::MyMarketData, c::MyCalibration, s)::Dict{String,Any}

Summary of `c` for `results/calibration_summary.toml`. `s` is a `MyStudySettings` (untyped here because
`StudySettings.jl` is included after this file); it supplies `xi_short`, `xi_long` and `xi_quantile`.
Keys: `lambda` (dimensionless), `sigma_m` (yr⁻¹), `vol_cap_annual` (yr⁻¹ᐟ², `σ_m·√Δt` with Δt = 1/252 yr),
`m_m` (yr⁻¹), `v_m` (yr⁻²), `xi_short`, `xi_long` (trading days), `xi_quantile`, `G` (dimensionless ξ gain on
the SPY closes of the training window), `train_start`, `train_stop` (ISO dates), `universe_size` (count) and
`sector_counts` (name => count). Print a TOML file with `TOML.print(io, d; sorted=true)` for a stable key order.
"""
function calibration_summary(md::MyMarketData, c::MyCalibration, s)::Dict{String,Any}
    Δt = 1 / 252    # yr
    i0, i1 = index_of(md, c.train_start), index_of(md, c.train_stop)
    G = xi_gain(md.spy_close[i0:i1]; short=s.xi_short, long=s.xi_long, q=s.xi_quantile)
    sectors = Dict{String,Int}()
    for x in md.sector
        sectors[x] = get(sectors, x, 0) + 1
    end
    return Dict{String,Any}("lambda" => c.λ, "sigma_m" => c.σ_m, "vol_cap_annual" => c.σ_m * sqrt(Δt),
        "m_m" => c.m_m, "v_m" => c.v_m, "xi_short" => s.xi_short, "xi_long" => s.xi_long,
        "xi_quantile" => s.xi_quantile, "G" => G, "train_start" => string(c.train_start),
        "train_stop" => string(c.train_stop), "universe_size" => length(md.tickers), "sector_counts" => sectors)
end
