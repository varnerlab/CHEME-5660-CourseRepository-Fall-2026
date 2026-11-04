"""Price-file names (calibration, 2025, 2026 windows), in chronological order."""
const DATA_FILES = [
    "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2",
    "SP500-Daily-OHLC-1-2-2025-to-12-31-2025.jld2",
    "SP500-Daily-OHLC-1-2-2026-to-09-04-2026.jld2",
]

const SECTORS_FILE = "sp500-sectors.csv"
const DTB3_FILE = "DTB3.csv"
const DEFAULT_G_F = 0.04   # yr⁻¹, used when DTB3.csv is absent
const DTB3_DAYS = 91       # maturity of the 3-month bill DTB3 quotes (calendar days)

"""
    growth_rates(x::AbstractVecOrMat; Δt=1/252)

Annualized growth rates (yr⁻¹) `log(x[t]/x[t-1])/Δt` along rows, with Δt in years.
Returns `size(x,1) - 1` rows.
"""
function growth_rates(x::AbstractVecOrMat; Δt::Real=1/252)
    r = size(x, 1)
    return log.(selectdim(x, 1, 2:r) ./ selectdim(x, 1, 1:r-1)) ./ Δt
end

"""
    index_of(md::MyMarketData, d::Date)::Int

Row index of date `d` in `md.dates`. Throws `ArgumentError` if `d` is not a trading day.
"""
function index_of(md::MyMarketData, d::Date)::Int
    i = searchsortedfirst(md.dates, d)
    (i <= length(md.dates) && md.dates[i] == d) || throw(ArgumentError("$(d) is not a trading day"))
    return i
end

# Per-ticker (open, close, volume) series keyed by date, restricted to [start, stop]. Prices are divided
# and volume multiplied by the split factor `k` (dimensionless), which puts the rows on a later file's basis.
function _slice(df::DataFrame, start::Date, stop::Date, k::Float64=1.0)::Dict{Date,NTuple{3,Float64}}
    d = Date.(df.timestamp)
    keep = (d .>= start) .& (d .<= stop)
    return Dict{Date,NTuple{3,Float64}}(d[i] => (Float64(df.open[i]) / k, Float64(df.close[i]) / k,
        Float64(df.volume[i]) * k) for i in findall(keep))
end

"""Split ratios a boundary basis change is rounded to (dimensionless); reverse splits use the reciprocals.
25 is included for BKNG's 25:1 split at the 2026 boundary."""
const SPLIT_RATIOS = [2.0, 3.0, 4.0, 5.0, 10.0, 15.0, 20.0, 25.0]
const SPLIT_GATE = 0.4          # |log(open_b/close_{b−1})| above which a boundary move is tested (dimensionless)
const SPLIT_RATIO_TOL = 0.1     # largest |log(close_{b−1}/open_b ÷ k)| accepted as a split by k (dimensionless)
const SPLIT_VOLUME_TOL = 3.0    # the volume ratio must lie within this factor of k, on k's side of 1 (dimensionless)
const SPLIT_SPY_MAX = 0.05      # largest |SPY overnight log move| on the boundary day (dimensionless)
const LARGE_MOVE_WARN = 0.9     # |one-day close log move| the loader warns about without adjusting (dimensionless)

"""
    boundary_split_factor(close_prev, open_b, vol_prev, vol_b, spy_move)::Float64

Split factor k (dimensionless) of a basis change between the last row of one price file (close USD/share,
volume shares/day) and the first row of the next, or 1.0 for none. A split needs all of: an overnight move
|log(open_b/close_prev)| > $(SPLIT_GATE); close_prev/open_b within e^$(SPLIT_RATIO_TOL) of a ratio in
`SPLIT_RATIOS` or its reciprocal (k is the nearest one in log); a volume ratio vol_b/vol_prev on k's side
of 1 and within a factor $(SPLIT_VOLUME_TOL) of k; and SPY's overnight log move `spy_move` within
±$(SPLIT_SPY_MAX). k > 1 is a forward split (k new shares per old share), k < 1 a reverse split.
"""
function boundary_split_factor(close_prev::Real, open_b::Real, vol_prev::Real, vol_b::Real, spy_move::Real)::Float64
    g = log(open_b / close_prev)
    (isfinite(g) && abs(g) > SPLIT_GATE && abs(spy_move) <= SPLIT_SPY_MAX) || return 1.0
    raw = close_prev / open_b
    cands = vcat(SPLIT_RATIOS, 1 ./ SPLIT_RATIOS)
    k = cands[argmin(abs.(log.(raw ./ cands)))]
    abs(log(raw / k)) <= SPLIT_RATIO_TOL || return 1.0
    lv = log(vol_b / vol_prev)
    (isfinite(lv) && sign(lv) == sign(log(k)) && abs(lv - log(k)) <= log(SPLIT_VOLUME_TOL)) || return 1.0
    return k
end

const _SplitRecord = NamedTuple{(:ticker, :date, :k),Tuple{String,Date,Float64}}

"""
    split_adjustments(sets::AbstractVector, tickers)::Vector{NamedTuple{(:ticker, :date, :k)}}

Basis changes at the price-file boundaries. `sets` are the raw datasets (ticker => DataFrame) in
`DATA_FILES` order; each file is split-adjusted only as of its own creation. At each boundary b (the
first SPY day of a file), every ticker in `tickers` with a row on the previous file's last SPY day and on
day b is tested with `boundary_split_factor` (SPY's overnight move from the same two rows). Returns one
`(ticker, date = b, k)` per detected split, sorted by date, then ticker.
"""
function split_adjustments(sets::AbstractVector, tickers)::Vector{_SplitRecord}
    out = _SplitRecord[]
    for f in 2:length(sets)
        sp, sn = sets[f-1]["SPY"], sets[f]["SPY"]
        dp, dn = Date.(sp.timestamp), Date.(sn.timestamp)
        ip, ib = argmax(dp), argmin(dn)
        spy_move = log(sn.open[ib] / sp.close[ip])
        for t in sort(collect(String, tickers))
            (haskey(sets[f-1], t) && haskey(sets[f], t)) || continue
            p, n = sets[f-1][t], sets[f][t]
            (nrow(p) > 0 && nrow(n) > 0) || continue
            tp, tn = Date.(p.timestamp), Date.(n.timestamp)
            jp, jb = argmax(tp), argmin(tn)
            (tp[jp] == dp[ip] && tn[jb] == dn[ib]) || continue
            k = boundary_split_factor(p.close[jp], n.open[jb], p.volume[jp], n.volume[jb], spy_move)
            k == 1.0 || push!(out, (ticker=t, date=dn[ib], k=k))
        end
    end
    return sort!(out; by=a -> (a.date, a.ticker))
end

"""
    _risk_free(dir::String, dates::Vector{Date})::Vector{Float64}

Risk-free growth rate g_f (yr⁻¹) on `dates` from FRED DTB3, the 3-month bill's bank-discount rate d
(percent, ACT/360). A bill of `DTB3_DAYS` = D days bought at d costs 1 − d·D/360 per dollar at
maturity, so its continuously compounded growth rate is g_f = −ln(1 − d·D/360)·365/D. Day t takes the
last observation dated before t: the Fed publishes day t's rate on day t+1, so it is not known at
t's close. Throws `ArgumentError` when a date has no earlier observation (a later one is never
borrowed). Constant 0.04 yr⁻¹ with a warning if the file is absent.
"""
function _risk_free(dir::String, dates::Vector{Date})::Vector{Float64}
    path = joinpath(dir, DTB3_FILE)
    if !isfile(path)
        @warn "DTB3.csv not found; using constant risk-free rate $(DEFAULT_G_F) yr⁻¹"
        return fill(DEFAULT_G_F, length(dates))
    end
    df = CSV.read(path, DataFrame; missingstring=[".", "", "NA"])
    obs = Date.(df[!, 1])
    rate = df[!, 2]
    ok = findall(!ismissing, rate)
    obs, d = obs[ok], Float64.(rate[ok]) ./ 100
    D = DTB3_DAYS
    g_f = Vector{Float64}(undef, length(dates))
    for (k, t) in enumerate(dates)
        i = searchsortedlast(obs, t - Day(1))
        i == 0 && throw(ArgumentError("$(DTB3_FILE) has no observation before $(t)"))
        g_f[k] = -log(1 - d[i] * D / 360) * 365 / D
    end
    return g_f
end

"""
    load_market_data(dir::String; start::Date, stop::Date)::MyMarketData

Load the three price files and the sector CSV from `dir`, over dates in [start, stop].
Trading days are SPY's. The universe is the tickers present in all three files, with a row on
every trading day, all opens and closes > 0, and a sector in the CSV (sorted, SPY excluded).
Prices are USD/share, volume is shares/day, g_f is yr⁻¹.

Split basis: each file is split-adjusted only as of its own creation, so a split between two files'
creation dates shows up as a jump at their boundary. `split_adjustments` finds these for the universe
(on the full files, whatever [start, stop]); every earlier row of that ticker is rescaled, prices ÷ k and
volume × k, compounding across boundaries, so the whole history is on the newest file's basis (growth
rates within a file and dollar volume are unchanged). Each adjustment is logged with `@info`. Within
[start, stop], a remaining boundary jump |log(open_b/close_{b−1})| > $(SPLIT_GATE) and any one-day
|log close move| > $(LARGE_MOVE_WARN) (likely a spin-off or ticker reuse) are logged with `@warn` and not adjusted.
"""
function load_market_data(dir::String; start::Date, stop::Date)::MyMarketData
    sets = [JLD2.load(joinpath(dir, f))["dataset"] for f in DATA_FILES]
    spy = merge((_slice(s["SPY"], start, stop) for s in sets)...)
    dates = sort!(collect(keys(spy)))
    isempty(dates) && throw(ArgumentError("no SPY trading days in [$(start), $(stop)]"))

    sectors = CSV.read(joinpath(dir, SECTORS_FILE), DataFrame)
    sector_of = Dict(String(r.Symbol) => String(r."GICS Sector") for r in eachrow(sectors))

    candidates = sort!(collect(intersect((Set(keys(s)) for s in sets)...)))
    series = Dict{String,Dict{Date,NTuple{3,Float64}}}()
    for t in candidates
        (t == "SPY" || !haskey(sector_of, t)) && continue
        rows = merge((_slice(s[t], start, stop) for s in sets)...)
        all(d -> haskey(rows, d) && rows[d][1] > 0 && rows[d][2] > 0, dates) && (series[t] = rows)
    end
    tickers = sort!(collect(keys(series)))

    # Put every universe ticker on the newest file's split basis: file f's rows ÷ ∏ k over later boundaries.
    adj = split_adjustments(sets, tickers)
    last_day = [maximum(Date.(s["SPY"].timestamp)) for s in sets]
    for t in unique(a.ticker for a in adj)
        K = [prod((a.k for a in adj if a.ticker == t && a.date > last_day[f]); init=1.0) for f in eachindex(sets)]
        series[t] = merge((_slice(s[t], start, stop, K[f]) for (f, s) in enumerate(sets))...)
    end
    for a in adj
        @info "split basis reconciled at a price-file boundary: $(a.ticker) at $(a.date), k = $(a.k) (earlier prices ÷ k, volume × k)"
    end

    pick(k) = [series[t][d][k] for d in dates, t in tickers]
    md = build(MyMarketData, (
        dates = dates,
        tickers = tickers,
        open = pick(1), close = pick(2), volume = pick(3),
        spy_open = [spy[d][1] for d in dates],
        spy_close = [spy[d][2] for d in dates],
        sector = [sector_of[t] for t in tickers],
        g_f = _risk_free(dir, dates)))
    _warn_jumps(md, [minimum(Date.(s["SPY"].timestamp)) for s in sets[2:end]])
    return md
end

# Warn (do not adjust) about boundary jumps left after the split reconciliation and about large one-day
# close moves, within the loaded dates. `boundaries` are the first SPY days of the later files.
function _warn_jumps(md::MyMarketData, boundaries::Vector{Date})
    for b in boundaries
        i = searchsortedfirst(md.dates, b)
        (1 < i <= length(md.dates) && md.dates[i] == b) || continue
        for j in eachindex(md.tickers)
            g = log(md.open[i, j] / md.close[i-1, j])
            abs(g) > SPLIT_GATE && @warn "unreconciled price-file boundary jump, not adjusted: " *
                "$(md.tickers[j]) at $(b), log(open/previous close) = $(round(g; digits=3))"
        end
    end
    for j in eachindex(md.tickers), i in 2:length(md.dates)
        g = log(md.close[i, j] / md.close[i-1, j])
        abs(g) > LARGE_MOVE_WARN && @warn "large one-day close move, not adjusted (possible spin-off or ticker reuse): " *
            "$(md.tickers[j]) on $(md.dates[i]), log move $(round(g; digits=3))"
    end
    return nothing
end
