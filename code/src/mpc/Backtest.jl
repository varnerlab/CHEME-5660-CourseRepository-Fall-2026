# End-of-day backtest engine (spec §8): one strategy configuration replayed day by day. Decisions are
# made after the close on day t from data dated ≤ t; their orders fill at the open of day t+1.
#
# Units: shares (shares), prices (USD/share), equity, cash, costs and fees (USD), growth rates g_f, g,
# μ_g and σ_m (yr⁻¹), Σ_g (yr⁻²), weights (dimensionless).

const _BT_DT = 1 / 252          # trading-day step Δt (yr)
const _BT_ADV_DAYS = 63         # trailing trading days in the ADV mean (R26)
const _BT_C̄_FRAC = 5e-4         # turnover cost per share c̄ = 5e-4·mean(prices) (USD/share)
const _BT_ε = 1e-3              # floor for γ ≤ 0 names under the utility rules (shares)
const _BT_HELD_W = 1e-3         # |wᵢ| above which a name counts as held: toward n_names, and in the study's orders (dimensionless)
const _BT_BISECT_ITERS = 60     # bisection steps for the R25 buy scale factor

"""
    MyRunConfig

One backtest configuration (`run_backtest`). Fields:

| Field | Meaning |
|---|---|
| `rule::AbstractPortfolioRule` | portfolio rule |
| `covariance::AbstractCovarianceModel` | C1 (`MySIMCovariance`) or C2 (`MyShrunkResidualCovariance`) |
| `w_max`, `s_max`, `σ_g_max` | per-name cap, sector cap (dimensionless; `s_max ≥ 1` = none), vol cap (yr⁻¹) |
| `mpc::MyMPCSpec` | trigger and projection settings |
| `start::Date`, `stop::Date` | window; `start` must be a trading day with a previous trading day in the data |
| `W0` | starting equity (USD, default 100_000) |
| `seed::Int` | projection RNG seed (default 5660) |
| `basket_schedule::Vector{Pair{Date,Vector{String}}}` | basket from each date on; first entry at `start` |
| `forced_dates::Vector{Date}` | forced decision dates (trading days in the window; default none) |
| `natural_triggers::Bool` | whether cash_revisit/drawdown/horizon/band can fire (default true) |
| `ewls_calendar::Union{Nothing,Vector{Date}}` | validation only: EWLS update days (default `nothing` = daily) |
| `base_sim::Dict{String,MySIMParameterEstimate}` | base SIM fit that seeds EWLS (α, σ_ε in yr⁻¹) |
| `σ_m::Float64` | initial market growth SD (yr⁻¹) |
| `σ_m_mode::Symbol` | `:ewls` (default) updates σ_m with `ewvar_update!`; `:fixed` holds it at `σ_m` |
| `K_turnover_frac`, `borrow_rate` | turnover budget as a fraction of equity (default 0.10); borrow fee (yr⁻¹, default 0.0075) |
| `label::String` | run label (default "") |
| `ewls_g_m::Union{Nothing,Vector{Float64}}` | validation only: market growth g_m (yr⁻¹) for each `ewls_calendar` entry, in order (`NaN` = use the data); default `nothing` |
| `decision_market::Union{Nothing,Dict{Date,NamedTuple}}` | validation only: `(g_m, λ)` to use at a decision date instead of `market_state`; default `nothing` |
| `ewls_state0::Union{Nothing,Dict{String,MyEWLSState}}` | validation only: EWLS states (by ticker) in place of `ewls_init` from `base_sim`; default `nothing` |
"""
mutable struct MyRunConfig
    rule::AbstractPortfolioRule
    covariance::AbstractCovarianceModel
    w_max::Float64
    s_max::Float64
    σ_g_max::Float64
    mpc::MyMPCSpec
    start::Date
    stop::Date
    W0::Float64
    seed::Int
    basket_schedule::Vector{Pair{Date,Vector{String}}}
    forced_dates::Vector{Date}
    natural_triggers::Bool
    ewls_calendar::Union{Nothing,Vector{Date}}
    base_sim::Dict{String,MySIMParameterEstimate}
    σ_m::Float64
    σ_m_mode::Symbol
    K_turnover_frac::Float64
    borrow_rate::Float64
    label::String
    ewls_g_m::Union{Nothing,Vector{Float64}}
    decision_market::Union{Nothing,Dict{Date,NamedTuple{(:g_m, :λ),Tuple{Float64,Float64}}}}
    ewls_state0::Union{Nothing,Dict{String,MyEWLSState}}
    MyRunConfig() = new()
end

"""
    MyBacktestResult

Output of `run_backtest`, one entry per trading day of the window in `dates`, `equity` (USD, at the
close), `cash` (USD, at the close) and `borrow_fees` (USD charged that day). Also:
- `trades::DataFrame`: `date` (fill day), `ticker`, `qty` (signed whole shares), `price` (the fill
  day's open, USD/share), `cost` (USD), `scale` (the R25 buy scale factor applied on that fill; 1.0
  for sells and for unscaled buys). When cash cannot pay for even one share of any buy, each dropped
  buy is logged as a row with `qty = 0`, `cost = 0` and the factor found (0 when cash was already
  negative before the buys).
- `decisions::DataFrame`: `date`, `reason` (trigger), `status` (allocator), `n_names` (basket names
  with |target weight| > 1e-3), `invested_frac` (allocator `s_star`: Σwᵢ, net for 130/30),
  `μ_T`, `σ_T` (projected value mean/SD at the horizon T, USD).
- `targets[date]`: target weight wᵢ = nᵢSᵢ/W per basket name (continuous allocator output at the
  decision close; names outside the basket have target 0).
- `projections[date]`: the full `MyProjection` (μ_τ, σ_τ for τ = 1..T, USD) of each decision.
"""
mutable struct MyBacktestResult
    dates::Vector{Date}
    equity::Vector{Float64}
    cash::Vector{Float64}
    borrow_fees::Vector{Float64}
    trades::DataFrame
    decisions::DataFrame
    targets::Dict{Date,Dict{String,Float64}}
    projections::Dict{Date,MyProjection}
    MyBacktestResult() = new()
end

const _RUN_CONFIG_REQUIRED = (:rule, :covariance, :w_max, :σ_g_max, :start, :stop, :basket_schedule,
    :base_sim, :σ_m)

"""
    build(::Type{MyRunConfig}, data::NamedTuple)::MyRunConfig

Build a run configuration. Required: `rule`, `covariance`, `w_max`, `σ_g_max` (yr⁻¹), `start`, `stop`,
`basket_schedule`, `base_sim`, `σ_m` (yr⁻¹). Defaults: `s_max = 1.0` (no sector cap),
`mpc = MyMPCSpec()`, `W0 = 100_000.0` (USD), `seed = 5660`, `forced_dates = Date[]`,
`natural_triggers = true`, `ewls_calendar = nothing`, `σ_m_mode = :ewls`, `K_turnover_frac = 0.10`,
`borrow_rate = 0.0075` (yr⁻¹), `label = ""`. Unknown field names throw `ArgumentError`, as do
invalid values: non-positive `w_max`, `s_max`, `W0` or `σ_m`; `σ_g_max < 0`; `stop < start`; a
`σ_m_mode` other than `:ewls`/`:fixed`; an empty schedule, a first entry not at `start`, entry dates
not strictly increasing, or an empty or duplicated basket; `mpc.T < 1` or `mpc.N < 2`; `seed < 0`.
"""
function build(::Type{MyRunConfig}, data::NamedTuple)::MyRunConfig
    for f in _RUN_CONFIG_REQUIRED
        _require(data, MyRunConfig, f)
    end
    unknown = setdiff(keys(data), fieldnames(MyRunConfig))
    isempty(unknown) || throw(ArgumentError("Cannot build MyRunConfig: unknown field(s) $(collect(unknown))"))
    c = MyRunConfig()
    c.rule = data.rule
    c.covariance = data.covariance
    c.w_max = data.w_max
    c.s_max = get(data, :s_max, 1.0)
    c.σ_g_max = data.σ_g_max
    c.mpc = haskey(data, :mpc) ? data.mpc : MyMPCSpec()
    c.start = data.start
    c.stop = data.stop
    c.W0 = get(data, :W0, 100_000.0)
    c.seed = get(data, :seed, 5660)
    c.basket_schedule = [Date(first(p)) => String.(collect(last(p))) for p in data.basket_schedule]
    c.forced_dates = Date.(collect(get(data, :forced_dates, Date[])))
    c.natural_triggers = get(data, :natural_triggers, true)
    cal = get(data, :ewls_calendar, nothing)
    c.ewls_calendar = cal === nothing ? nothing : Date.(collect(cal))
    c.base_sim = Dict{String,MySIMParameterEstimate}(data.base_sim)
    c.σ_m = data.σ_m
    c.σ_m_mode = get(data, :σ_m_mode, :ewls)
    c.K_turnover_frac = get(data, :K_turnover_frac, 0.10)
    c.borrow_rate = get(data, :borrow_rate, 0.0075)
    c.label = get(data, :label, "")
    c.ewls_g_m = get(data, :ewls_g_m, nothing)
    dm = get(data, :decision_market, nothing)
    c.decision_market = dm === nothing ? nothing :
        Dict{Date,NamedTuple{(:g_m, :λ),Tuple{Float64,Float64}}}(Date(k) => (g_m=Float64(v.g_m), λ=Float64(v.λ)) for (k, v) in dm)
    c.ewls_state0 = get(data, :ewls_state0, nothing)
    _check_run_config(c)
    return c
end

# Field checks that need no market data (see the build docstring).
function _check_run_config(c::MyRunConfig)
    bad(msg) = throw(ArgumentError("Invalid MyRunConfig: $(msg)"))
    (c.w_max > 0 && c.s_max > 0) || bad("w_max and s_max must be positive")
    c.σ_g_max >= 0 || bad("σ_g_max must be ≥ 0")
    c.start <= c.stop || bad("stop $(c.stop) is before start $(c.start)")
    (isfinite(c.W0) && c.W0 > 0) || bad("W0 must be positive and finite")
    (isfinite(c.σ_m) && c.σ_m > 0) || bad("σ_m must be positive and finite")
    c.σ_m_mode in (:ewls, :fixed) || bad("σ_m_mode must be :ewls or :fixed, got :$(c.σ_m_mode)")
    (c.K_turnover_frac >= 0 && c.borrow_rate >= 0) || bad("K_turnover_frac and borrow_rate must be ≥ 0")
    (c.mpc.T >= 1 && c.mpc.N >= 2) || bad("mpc.T must be ≥ 1 and mpc.N ≥ 2")
    c.seed >= 0 || bad("seed must be ≥ 0")
    c.ewls_g_m === nothing || (c.ewls_calendar !== nothing && length(c.ewls_g_m) == length(c.ewls_calendar)) ||
        bad("ewls_g_m needs an ewls_calendar of the same length")
    s = c.basket_schedule
    isempty(s) && bad("basket_schedule is empty")
    first(s[1]) == c.start || bad("the first basket_schedule entry must be at start $(c.start), got $(first(s[1]))")
    all(first(s[k]) < first(s[k+1]) for k in 1:length(s)-1) || bad("basket_schedule dates must be strictly increasing")
    for (d, names) in s
        isempty(names) && bad("empty basket at $(d)")
        allunique(names) || bad("duplicate names in the basket at $(d)")
    end
    return nothing
end

"""
    build(::Type{MyBacktestResult}, data::NamedTuple)::MyBacktestResult

Build a backtest result from a NamedTuple holding every field (see `MyBacktestResult`).
"""
function build(::Type{MyBacktestResult}, data::NamedTuple)::MyBacktestResult
    model = MyBacktestResult()
    for f in fieldnames(MyBacktestResult)
        _require(data, MyBacktestResult, f)
        setproperty!(model, f, data[f])
    end
    return model
end

# Row indices (i0, i1) of the window: i0 = start (a trading day with a previous one, which the growth
# rates and market_state need), i1 = the last trading day ≤ stop.
function _bt_window(md::MyMarketData, cfg::MyRunConfig)
    i0 = index_of(md, cfg.start)
    i0 >= 2 || throw(ArgumentError("start $(cfg.start) needs a previous trading day in the market data"))
    return i0, searchsortedlast(md.dates, cfg.stop)
end

# Basket schedule as universe column indices; every name must be in md.tickers and in base_sim (R6).
function _bt_schedule(cfg::MyRunConfig, col::Dict{String,Int})::Vector{Pair{Date,Vector{Int}}}
    for (d, names) in cfg.basket_schedule, t in names
        haskey(col, t) || throw(ArgumentError("basket name $(t) (schedule entry $(d)) is not in the market data"))
        haskey(cfg.base_sim, t) ||
            throw(ArgumentError("basket name $(t) (schedule entry $(d)) has no base SIM fit in base_sim"))
    end
    return [d => [col[t] for t in names] for (d, names) in cfg.basket_schedule]
end

# Number of EWLS (and σ_m) updates on each window day i0..i1. Daily mode: one per day. Calendar
# mode: one per entry equal to the day; entries before start or on a non-trading day throw, entries
# after the window's last day are ignored.
function _bt_update_counts(md::MyMarketData, cfg::MyRunConfig, i0::Int, i1::Int)::Vector{Int}
    cfg.ewls_calendar === nothing && return ones(Int, i1 - i0 + 1)
    counts = zeros(Int, i1 - i0 + 1)
    for e in cfg.ewls_calendar
        e > md.dates[i1] && continue
        e < cfg.start && throw(ArgumentError("ewls_calendar entry $(e) is before start $(cfg.start)"))
        i = searchsortedfirst(md.dates, e)
        md.dates[i] == e || throw(ArgumentError("ewls_calendar entry $(e) is not a trading day"))
        counts[i-i0+1] += 1
    end
    return counts
end

# g_m (yr⁻¹) of each EWLS update on each window day (same order as the day's calendar entries);
# `NaN` means "use the data". Only used when cfg.ewls_g_m is set.
function _bt_update_gm(md::MyMarketData, cfg::MyRunConfig, i0::Int, i1::Int)::Vector{Vector{Float64}}
    out = [Float64[] for _ in i0:i1]
    cfg.ewls_g_m === nothing && return out
    for (e, g) in zip(cfg.ewls_calendar, cfg.ewls_g_m)
        e > md.dates[i1] && continue
        push!(out[searchsortedfirst(md.dates, e)-i0+1], g)
    end
    return out
end

# Mean volume (shares/day) over the trailing 63 trading days ending at day t, floored at 1 (R26).
_bt_adv(md::MyMarketData, t::Int, j::Int)::Float64 =
    max(mean(@view md.volume[max(1, t - _BT_ADV_DAYS + 1):t, j]), 1.0)

# Residuals for the covariance model: nothing for C1; for C2 the SIM residuals (yr⁻¹) of the basket
# over its trailing `window` growth rates ending at day t, with the current EWLS α, β.
_bt_residuals(::AbstractCovarianceModel, md, t, b, α, β) = nothing
function _bt_residuals(model::MyShrunkResidualCovariance, md::MyMarketData, t::Int, b::Vector{Int}, α, β)
    r0 = max(1, t - model.window)                       # growth rows r0+1..t
    return residual_matrix(growth_rates(md.close[r0:t, b]), growth_rates(md.spy_close[r0:t]), α, β)
end

# Value (USD) of the share positions at day t's close.
function _bt_holdings_value(held::AbstractVector{<:Real}, md::MyMarketData, t::Int)::Float64
    v = 0.0
    for j in eachindex(held)
        held[j] == 0 || (v += held[j] * md.close[t, j])
    end
    return v
end

# Short notional (USD) at day t's close.
function _bt_short_notional(held::AbstractVector{<:Real}, md::MyMarketData, t::Int)::Float64
    v = 0.0
    for j in eachindex(held)
        held[j] < 0 && (v -= held[j] * md.close[t, j])
    end
    return v
end

# Trade log columns; `qty` has the holdings' type (Int: whole shares, Float64: fractional shares).
struct _BTTrades{T<:Real}
    date::Vector{Date}; ticker::Vector{String}; qty::Vector{T}
    price::Vector{Float64}; cost::Vector{Float64}; scale::Vector{Float64}
end
_BTTrades{T}() where {T<:Real} = _BTTrades{T}(Date[], String[], T[], Float64[], Float64[], Float64[])
_BTTrades() = _BTTrades{Int}()

# A share quantity as the holdings type T can hold it: whole shares rounded toward zero (Int, the
# trial's), or the exact fractional quantity (Float64, the study's).
_bt_lot(::Type{Int}, x::Real)::Int = trunc(Int, x)
_bt_lot(::Type{Float64}, x::Real)::Float64 = Float64(x)

# Cash (USD) after the buys `q[k]` (shares > 0), each scaled by f and cut to a lot (`_bt_lot`), at `px`
# (USD/share) with trade costs (`half_spread_bps` in bps, impact `κ` dimensionless, as in `trade_cost`);
# the fills apply them in this order with this arithmetic, so the sign is exact.
function _bt_cash_after_buys(cash::Float64, q::Vector{T}, px::Vector{Float64}, adv::Vector{Float64},
        buys::Vector{Int}, f::Float64; half_spread_bps::Float64=5.0, κ::Float64=0.001)::Float64 where {T<:Real}
    for k in buys
        qk = _bt_lot(T, f * q[k])
        qk == 0 || (cash -= qk * px[k] + trade_cost(qk, px[k], adv[k]; half_spread_bps=half_spread_bps, κ=κ))
    end
    return cash
end

# Fill queued orders at the open of day t (R25 as amended by R27). Orders are q = lot(n_target) − held
# (`_bt_lot`). With whole shares (Int holdings, the trial's) the target is rounded toward zero first, so
# a fill ends at trunc(n_target) (an ε pin of 1e-3 shares exits fully, and a reduction never stops above
# its target); with fractional shares (Float64 holdings) a fill ends at the target. Sells and short
# sales execute first, then buys. If cash after the sells cannot pay for every buy at the open plus
# costs, every buy is scaled by one factor f ∈ [0, 1] (the largest, by bisection) and cut to a lot, so
# cash ≥ 0 after the fills; if that leaves no buy at all, each dropped buy is logged with qty 0.
# Costs use `half_spread_bps` (bps) and impact `κ` (dimensionless), as in `trade_cost`; the defaults are
# the trial's. Updates `held` and the trade log; returns cash (USD).
function _bt_fill!(held::Vector{T}, cash::Float64, order, md::MyMarketData, t::Int, tr::_BTTrades{T};
        half_spread_bps::Float64=5.0, κ::Float64=0.001)::Float64 where {T<:Real}
    ckw = (half_spread_bps=half_spread_bps, κ=κ)
    cols = order.cols
    q = [_bt_lot(T, order.n[k]) - held[j] for (k, j) in enumerate(cols)]
    px = [md.open[t, j] for j in cols]
    for k in eachindex(q)
        q[k] < 0 && (cash = _bt_execute!(held, cash, tr, md, t, cols[k], q[k], px[k], order.adv[k], 1.0; ckw...))
    end
    buys = findall(>(0), q)
    isempty(buys) && return cash
    f = 1.0
    if _bt_cash_after_buys(cash, q, px, order.adv, buys, 1.0; ckw...) < 0
        lo, hi = 0.0, 1.0
        for _ in 1:_BT_BISECT_ITERS
            mid = (lo + hi) / 2
            _bt_cash_after_buys(cash, q, px, order.adv, buys, mid; ckw...) >= 0 ? (lo = mid) : (hi = mid)
        end
        f = lo
    end
    for k in buys
        qk = _bt_lot(T, f * q[k])
        qk == 0 || (cash = _bt_execute!(held, cash, tr, md, t, cols[k], qk, px[k], order.adv[k], f; ckw...))
    end
    if all(k -> _bt_lot(T, f * q[k]) == 0, buys)          # cash could not pay for any buy: log the drops
        for k in buys
            cash = _bt_execute!(held, cash, tr, md, t, cols[k], zero(T), px[k], order.adv[k], f; ckw...)
        end
    end
    return cash
end

# Projection RNG seed (R28): an integer mix of the run seed and the decision date's day number, so the
# paths do not depend on `hash` (which may change between Julia versions) or on the row index.
_bt_projection_seed(seed::Int, d::Date)::Int = seed * 1_000_003 + Dates.value(d)

# One fill of `qk` shares (signed) of column j at `px` (USD/share) on day t: pay qk·px plus the trade
# cost (`half_spread_bps` in bps, impact `κ` dimensionless) from cash, update the position, log the
# trade with its buy scale factor. Returns cash (USD).
function _bt_execute!(held::Vector{T}, cash::Float64, tr::_BTTrades{T}, md::MyMarketData, t::Int, j::Int,
        qk::T, px::Float64, adv::Float64, scale::Float64; half_spread_bps::Float64=5.0,
        κ::Float64=0.001)::Float64 where {T<:Real}
    cost = trade_cost(qk, px, adv; half_spread_bps=half_spread_bps, κ=κ)
    held[j] += qk
    push!(tr.date, md.dates[t]); push!(tr.ticker, md.tickers[j]); push!(tr.qty, qk)
    push!(tr.price, px); push!(tr.cost, cost); push!(tr.scale, scale)
    return cash - (qk * px + cost)
end

"""
    run_backtest(md::MyMarketData, cfg::MyRunConfig)::MyBacktestResult

Replay `cfg` on end-of-day data from `cfg.start` to the last trading day ≤ `cfg.stop`. Equity starts
at `W0` (USD) in cash at the start close. On each trading day t, in order:

1. **Fill** the orders queued on day t−1 at `open[t]` (R25, R27): whole shares q = trunc(n_target) −
   held, sells and short sales first, then buys scaled by one factor if cash would go negative; costs from
   `trade_cost` with ADV = trailing 63-day mean volume at the decision day, floored at 1 share (R26).
2. **Accrue** positive cash by exp(g_f[t]·Δt) and charge `borrow_fee` on the short notional at
   `close[t]` (USD). Skipped on the first day (the account opens at that close).
3. **Mark** equity = cash + Σ nᵢ·close[t, i] (USD).
4. **Update EWLS** for every ticker in keys(base_sim) ∩ md.tickers with day t's growth (yr⁻¹,
   close[t−1] → close[t]), and σ_m with SPY's growth when `σ_m_mode == :ewls`. With `ewls_calendar`,
   apply one such update per calendar entry equal to t (none if t has no entry). EWLS starts from
   `ewls_init` on base_sim at `start` (half-life 63, prior weight 63); σ_m from `ewvar_init(σ_m)`.
5. Activate the basket of the latest schedule entry dated ≤ t; a change sets `basket_changed`.
6. **Trigger:** `check_trigger` with τ = trading days since the last decision (0 on a decision day),
   V_t = equity, wealth_peak = running max of equity (never reset), `initial` on the first day,
   `forced` on `forced_dates`, `natural = natural_triggers`.
7. **On a fire:** build γ (`preference_weights` on the EWLS α, β and `market_state` at t), μ_g
   (`expected_growth`) and Σ_g (`growth_covariance`; C2 residuals over the trailing `window` growth
   days with the EWLS α, β) for the basket, then a fresh `MyConstraintSet`/`MyAllocationProblem`
   (prices = close[t], W = equity, n_prev = held shares, K_turnover = K_turnover_frac·W,
   c̄ = 5e-4·mean(prices), ε = 1e-3) and `allocate`. A result with non-finite shares counts as
   `:solver_failed` and holds the current shares (R29). Store the target weights; queue orders for
   t+1 (held names outside the basket target 0); run `project_gbm` on the targets with cash
   W − Σ n·close and `rng = MersenneTwister(seed·1_000_003 + Dates.value(date))` (R28); reset τ = 0; set
   `last_alloc_was_cash = (status == :no_preferred)` (R19). A decision on the last day is recorded
   but has no fill.

γ, μ_g and Σ_g are only computed on decision days; they do not enter `check_trigger`, so this matches
the spec's daily order. Throws `ArgumentError` when `start` is not a trading day or is the first day
of the data, a basket name is missing from md.tickers or base_sim, a forced date is not a trading day
in the window, or an `ewls_calendar` entry is before `start` or not a trading day. Errors from the
allocator or the projection (e.g. a non-positive-definite Σ_g) propagate to the caller.
"""
function run_backtest(md::MyMarketData, cfg::MyRunConfig)::MyBacktestResult
    i0, i1 = _bt_window(md, cfg)
    col = Dict(t => j for (j, t) in enumerate(md.tickers))
    sched = _bt_schedule(cfg, col)
    window_days = md.dates[i0:i1]
    for d in cfg.forced_dates
        insorted(d, window_days) || throw(ArgumentError("forced date $(d) is not a trading day in the window"))
    end
    forced = Set(cfg.forced_dates)
    n_updates = _bt_update_counts(md, cfg, i0, i1)

    # Online SIM state for keys(base_sim) ∩ md.tickers (R6); ew_of[j] indexes column j's state.
    ew_cols = sort!([col[t] for t in keys(cfg.base_sim) if haskey(col, t)])
    ews = [ewls_init(cfg.base_sim[md.tickers[j]].α, cfg.base_sim[md.tickers[j]].β, cfg.base_sim[md.tickers[j]].σ_ε)
        for j in ew_cols]
    if cfg.ewls_state0 !== nothing
        for (k, j) in enumerate(ew_cols)
            haskey(cfg.ewls_state0, md.tickers[j]) && (ews[k] = deepcopy(cfg.ewls_state0[md.tickers[j]]))
        end
    end
    upd_gm = _bt_update_gm(md, cfg, i0, i1)
    ew_of = zeros(Int, length(md.tickers)); ew_of[ew_cols] .= eachindex(ew_cols)
    σ_state = ewvar_init(cfg.σ_m); σ_m = cfg.σ_m

    nd = i1 - i0 + 1
    equity = Vector{Float64}(undef, nd); cash_hist = Vector{Float64}(undef, nd); fees = zeros(nd)
    held = zeros(Int, length(md.tickers)); cash = cfg.W0
    tr = _BTTrades()
    dec = (date=Date[], reason=Symbol[], status=Symbol[], n_names=Int[], invested_frac=Float64[],
        μ_T=Float64[], σ_T=Float64[])
    targets = Dict{Date,Dict{String,Float64}}(); projections = Dict{Date,MyProjection}()

    trig = MyTriggerState()
    trig.natural = cfg.natural_triggers; trig.wealth_peak = cfg.W0; trig.initial = true
    k_sched = 1; basket = last(sched[1])
    pending = nothing

    for t in i0:i1
        d = md.dates[t]; s = t - i0 + 1
        # 1. fills at the open
        if pending !== nothing
            cash = _bt_fill!(held, cash, pending, md, t, tr)
            pending = nothing
        end
        # 2. cash accrual and borrow fee
        if t > i0
            cash > 0 && (cash *= exp(md.g_f[t] * _BT_DT))
            short = _bt_short_notional(held, md, t)
            if short > 0
                fees[s] = borrow_fee(short; rate=cfg.borrow_rate, Δt=_BT_DT)
                cash -= fees[s]
            end
        end
        # 3. mark at the close
        V = cash + _bt_holdings_value(held, md, t)
        equity[s] = V; cash_hist[s] = cash
        # 4. online SIM updates with day t's growth
        if n_updates[s] > 0
            g_m = log(md.spy_close[t] / md.spy_close[t-1]) / _BT_DT
            for u in 1:n_updates[s]
                g_u = (cfg.ewls_g_m === nothing || isnan(upd_gm[s][u])) ? g_m : upd_gm[s][u]
                for (k, j) in enumerate(ew_cols)
                    ewls_update!(ews[k], log(md.close[t, j] / md.close[t-1, j]) / _BT_DT, g_u)
                end
                σ_new = ewvar_update!(σ_state, g_u)
                cfg.σ_m_mode == :ewls && (σ_m = σ_new)
            end
        end
        # 5. basket schedule
        while k_sched < length(sched) && first(sched[k_sched+1]) <= d
            k_sched += 1; basket = last(sched[k_sched]); trig.basket_changed = true
        end
        # 6. triggers
        t > i0 && (trig.τ += 1)
        trig.V_t = V; trig.wealth_peak = max(trig.wealth_peak, V); trig.forced = d in forced
        reason = check_trigger(trig, cfg.mpc)
        reason == :in_spec && continue

        # 7. decide
        b = basket
        S = md.close[t, b]
        α = [ews[ew_of[j]].α for j in b]; β = [ews[ew_of[j]].β for j in b]; σε = [ews[ew_of[j]].σ_ε for j in b]
        ms = market_state(md.spy_close, md.dates, d)
        if cfg.decision_market !== nothing && haskey(cfg.decision_market, d)
            ms = (g_m=cfg.decision_market[d].g_m, λ=cfg.decision_market[d].λ, ḡ_M=ms.ḡ_M)
        end
        γ = preference_weights(α, β, ms.g_m, ms.λ)
        μ_g = expected_growth(cfg.rule, α, β, ms.ḡ_M)
        Σ_g = growth_covariance(cfg.covariance, β, σε, σ_m; residuals=_bt_residuals(cfg.covariance, md, t, b, α, β))
        cs = build(MyConstraintSet, (w_max=cfg.w_max, s_max=cfg.s_max, σ_g_max=cfg.σ_g_max,
            K_turnover=cfg.K_turnover_frac * V, c̄=_BT_C̄_FRAC * mean(S), sector=md.sector[b],
            n_prev=Float64.(held[b]), ε=_BT_ε))
        p = build(MyAllocationProblem, (γ=γ, μ_g=μ_g, Σ_g=Σ_g, prices=S, W=V, g_f=md.g_f[t], constraints=cs))
        r = allocate(cfg.rule, p)
        all(isfinite, r.n) || (r = _result(p, copy(p.constraints.n_prev), :solver_failed))   # R29
        proj = project_gbm(r.n, S, V - dot(r.n, S), μ_g, Σ_g, md.g_f[t]; T=cfg.mpc.T, N=cfg.mpc.N,
            rng=MersenneTwister(_bt_projection_seed(cfg.seed, d)))

        targets[d] = Dict(md.tickers[b[i]] => r.w[i] for i in eachindex(b))
        projections[d] = proj
        push!(dec.date, d); push!(dec.reason, reason); push!(dec.status, r.status)
        push!(dec.n_names, count(w -> abs(w) > _BT_HELD_W, r.w)); push!(dec.invested_frac, r.s_star)
        push!(dec.μ_T, proj.μ[end]); push!(dec.σ_T, proj.σ[end])

        if t < i1
            leaving = [j for j in eachindex(held) if held[j] != 0 && !(j in b)]
            cols = vcat(b, leaving)
            pending = (cols=cols, n=vcat(r.n, zeros(length(leaving))), adv=[_bt_adv(md, t, j) for j in cols])
        end
        trig.τ = 0; trig.projection = proj
        trig.initial = false; trig.basket_changed = false
        trig.last_alloc_was_cash = (r.status == :no_preferred)
    end

    return build(MyBacktestResult, (dates=md.dates[i0:i1], equity=equity, cash=cash_hist, borrow_fees=fees,
        trades=DataFrame(date=tr.date, ticker=tr.ticker, qty=tr.qty, price=tr.price, cost=tr.cost, scale=tr.scale),
        decisions=DataFrame(dec), targets=targets, projections=projections))
end
