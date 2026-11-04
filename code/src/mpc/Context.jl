# Everything that depends only on market data for one settings group, shared by many backtest runs.

"""
    MyStudyContext

Market-data-only precomputation for one settings group. `rows` are the run's market-data rows;
`G` is the ξ gain (dimensionless); `ξ` (dimensionless) and `g̃` (yr⁻¹) are per market-data row;
`sim` is the online SIM path; `γ` (yr⁻¹) is `length(rows) × tickers`; `pool` holds, per run row,
the hedge-pool ticker indices; `X` is the excess-growth window matrix (yr⁻¹) for the bandit.
"""
mutable struct MyStudyContext
    md::MyMarketData
    calib::MyCalibration
    settings::MyStudySettings
    rows::UnitRange{Int}
    G::Float64
    ξ::Vector{Float64}
    g̃::Vector{Float64}
    sim::MyOnlineSIM
    γ::Matrix{Float64}
    pool::Vector{Vector{Int}}
    X::Matrix{Float64}
    MyStudyContext() = new()
end

"""
    build(::Type{MyStudyContext}, data::NamedTuple)::MyStudyContext

Build a `MyStudyContext` from a NamedTuple holding every field; throws `ArgumentError` on a missing one.
"""
function build(::Type{MyStudyContext}, data::NamedTuple)::MyStudyContext
    ctx = MyStudyContext()
    for f ∈ fieldnames(MyStudyContext)
        haskey(data, f) || throw(ArgumentError("Cannot build MyStudyContext: missing field $(f)"))
        setfield!(ctx, f, data[f])
    end
    return ctx
end

"""
    build_context(md::MyMarketData, calib::MyCalibration, s::MyStudySettings)::MyStudyContext

Compute G (from SPY closes over the training rows), ξ and g̃ per row, the online SIM path, γ and the
hedge pool per run row, and the bandit excess-growth matrix. Row s of `γ`/`pool` uses data dated
≤ `rows[s]` only. Throws `ArgumentError` when `first(rows) ≤ max(omega_window, downday_lookback)`
(trading days), or when `calib`'s training window (`train_start`, `train_stop`) differs from `s`'s.
`omega_window` is not part of `context_key`, so `run_study` checks it again for each run.
"""
function build_context(md::MyMarketData, calib::MyCalibration, s::MyStudySettings)::MyStudyContext
    (calib.train_start == s.train_start && calib.train_stop == s.train_stop) ||
        throw(ArgumentError("calibration window $(calib.train_start) → $(calib.train_stop) differs from the " *
            "settings' training window $(s.train_start) → $(s.train_stop)"))
    i0 = index_of(md, s.start)
    i0 > max(s.omega_window, s.downday_lookback) ||
        throw(ArgumentError("run starts at row $(i0), which must exceed max(omega_window, downday_lookback) = " *
            "$(max(s.omega_window, s.downday_lookback))"))
    tr = index_of(md, s.train_start):searchsortedlast(md.dates, s.train_stop)
    G = xi_gain(md.spy_close[tr]; short = s.xi_short, long = s.xi_long, q = s.xi_quantile)
    ξ = xi_series(md.spy_close; short = s.xi_short, long = s.xi_long, G = G)
    g̃ = gtilde_series(md.spy_close; window = s.gtilde_window)
    sim = online_sim(md, calib; start = s.start, stop = s.stop,
        half_life = s.ewls_half_life, prior_weight = s.ewls_prior_weight)
    rows = sim.rows
    n = length(md.tickers)
    γ = Matrix{Float64}(undef, length(rows), n)
    pool = Vector{Vector{Int}}(undef, length(rows))
    for (k, t) in enumerate(rows)
        γ[k, :] = gamma_weights(sim.α[k, :], sim.β[k, :], g̃[t], ξ[t]; β_floor = s.beta_floor)
        pool[k] = hedge_pool(sim.β[k, :], down_day_beta(md, t; lookback = s.downday_lookback); H = s.pool_H)
    end
    X = excess_growth_windows(md; horizon = s.bandit_horizon)
    return build(MyStudyContext, (md = md, calib = calib, settings = s, rows = rows, G = G, ξ = ξ, g̃ = g̃,
        sim = sim, γ = γ, pool = pool, X = X))
end
