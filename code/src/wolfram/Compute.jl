# Compute.jl — Price, signal, and grid computations

# ---------------------------------------------------------------------------
# Price series helpers
# ---------------------------------------------------------------------------

"""
    compute_typical_price(df) → Vector{Float64}

Typical price = (High + Low + Close) / 3.
Expects DataFrame columns :High, :Low, :Close.
"""
function compute_typical_price(df::DataFrame)::Vector{Float64}
    # Accept both capitalised (:High) and lowercase (:high) column names
    H = hasproperty(df, :High)  ? df[!, :High]  : df[!, :high]
    L = hasproperty(df, :Low)   ? df[!, :Low]   : df[!, :low]
    C = hasproperty(df, :Close) ? df[!, :Close] : df[!, :close]
    return (H .+ L .+ C) ./ 3.0
end

"""
    compute_ema(x; α) → Vector{Float64}

Exponential moving average: μₜ = μₜ₋₁ + α·(xₜ - μₜ₋₁)
Initialized at x[1].
"""
function compute_ema(x::Vector{Float64}; α::Float64)::Vector{Float64}
    μ    = similar(x)
    μ[1] = x[1]
    for t in 2:length(x)
        μ[t] = μ[t-1] + α * (x[t] - μ[t-1])
    end
    return μ
end

"""
    compute_ema_volatility(x, μ; α) → Vector{Float64}

EMA of absolute deviations: σₜ = σₜ₋₁ + α·(|xₜ - μₜ| - σₜ₋₁)
Initialized at 0.
"""
function compute_ema_volatility(x::Vector{Float64}, μ::Vector{Float64}; α::Float64)::Vector{Float64}
    σ    = similar(x)
    σ[1] = 0.0
    for t in 2:length(x)
        σ[t] = σ[t-1] + α * (abs(x[t] - μ[t]) - σ[t-1])
    end
    return σ
end

"""
    compute_band_state(P, μ, σ, k) → Int64

Classify price relative to band:
    0 (Buy)  if P < μ - k·σ
    1 (Hold) if μ - k·σ ≤ P ≤ μ + k·σ
    2 (Sell) if P > μ + k·σ
"""
function compute_band_state(P::Float64, μ::Float64, σ::Float64, k::Float64)::Int64
    lb = μ - k * σ
    ub = μ + k * σ
    return P < lb ? 0 : (P > ub ? 2 : 1)
end

# ---------------------------------------------------------------------------
# Grid computations
# ---------------------------------------------------------------------------

"""
    compute_net_imbalance(grid, edge_coords) → Float64

Net order imbalance fraction over interior agents (edge agents excluded):
    φ = (N_buy - N_sell) / N_interior
"""
function compute_net_imbalance(
    grid::Array{Int64,2},
    edge_coords::Set{Tuple{Int64,Int64}},
)::Float64
    N_buy = 0; N_sell = 0; N_total = 0
    nrows, ncols = size(grid)
    for r in 1:nrows, c in 1:ncols
        (r, c) ∈ edge_coords && continue
        s       = grid[r, c]
        N_buy   += (s == 0)
        N_sell  += (s == 2)
        N_total += 1
    end
    return N_total > 0 ? (N_buy - N_sell) / N_total : 0.0
end

# ---------------------------------------------------------------------------
# Price model (Model B)
# ---------------------------------------------------------------------------

"""
    compute_price_update(P_prev, φ, λ) → Float64

Exponential price impact update: Pₜ = Pₜ₋₁ · exp(λ · φₜ)
"""
function compute_price_update(P_prev::Float64, φ::Float64, λ::Float64)::Float64
    return P_prev * exp(λ * φ)
end

# ---------------------------------------------------------------------------
# Return series and stylized-fact statistics
# ---------------------------------------------------------------------------

"""
    compute_log_returns(prices) → Vector{Float64}

Log returns: rₜ = ln(Pₜ / Pₜ₋₁)
"""
function compute_log_returns(prices::Vector{Float64})::Vector{Float64}
    return diff(log.(prices))
end

"""
    compute_session_log_returns(prices, sessions) -> Vector{Float64}

Log returns between consecutive observations that belong to the same session.
The session labels may be dates, strings, or any values supporting equality.
This excludes artificial overnight joins when regular-session intraday bars are
stored as one contiguous table.
"""
function compute_session_log_returns(
    prices::Vector{Float64},
    sessions::AbstractVector,
)::Vector{Float64}
    length(prices) == length(sessions) ||
        throw(DimensionMismatch("prices and sessions must have the same length"))
    length(prices) < 2 && return Float64[]
    returns = compute_log_returns(prices)
    same_session = sessions[2:end] .== sessions[1:end-1]
    return returns[same_session]
end

"""
    compute_crash_sizes(frames, threshold) → Vector{Int64}

Identify crash events as contiguous time windows where the fraction of
Sell agents exceeds `threshold`, and return the duration (in steps) of
each such window. Used for power-law / SOC analysis.
"""
function compute_crash_sizes(
    frames::Dict{Int64, Array{Int64,2}};
    threshold::Float64 = 0.5,
)::Vector{Int64}
    steps     = sort(collect(keys(frames)))
    N         = prod(size(frames[steps[1]]))
    in_crash  = false
    duration  = 0
    sizes     = Int64[]

    for t in steps
        f_sell = count(==(2), frames[t]) / N
        if f_sell >= threshold
            in_crash = true
            duration += 1
        else
            if in_crash
                push!(sizes, duration)
                duration = 0
            end
            in_crash = false
        end
    end
    in_crash && push!(sizes, duration)   # close any open crash window
    return sizes
end

# ---------------------------------------------------------------------------
# Model B trajectory helpers (strictly interior; boundary excluded)
# ---------------------------------------------------------------------------

"""
    compute_interior_imbalance(grid) → Float64

Net order imbalance over strictly interior cells (rows 2:end-1, cols 2:end-1):

    φ = (N_buy − N_sell) / N_interior

The entire boundary — active edge cells and passive Hold cells — is excluded,
matching φ = D/N_interior in the paper's supply–demand form (spec §1).
"""
function compute_interior_imbalance(grid::Array{Int64,2})::Float64
    nrows, ncols = size(grid)
    N_buy = 0; N_sell = 0
    for r in 2:nrows-1, c in 2:ncols-1
        s = grid[r, c]
        N_buy  += (s == 0)
        N_sell += (s == 2)
    end
    N_int = (nrows - 2) * (ncols - 2)
    return N_int > 0 ? (N_buy - N_sell) / N_int : 0.0
end

"""
    compute_interior_fractions(grid) → (buy, hold, sell)

Population fractions over strictly interior cells (same region as
compute_interior_imbalance).
"""
function compute_interior_fractions(grid::Array{Int64,2})::Tuple{Float64,Float64,Float64}
    nrows, ncols = size(grid)
    n = zeros(Int64, 3)
    for r in 2:nrows-1, c in 2:ncols-1
        n[grid[r, c] + 1] += 1
    end
    N_int = (nrows - 2) * (ncols - 2)
    return N_int > 0 ? (n[1] / N_int, n[2] / N_int, n[3] / N_int) : (0.0, 0.0, 0.0)
end

"""
    compute_desired_order(state) → Int64

Map a cell state to its desired unit order: Buy(0) → +1, Sell(2) → −1,
Hold(1) → 0. Flow semantics (spec 2026-07-16 decision 2): a cell submits
this order EVERY step it remains in the state.
"""
function compute_desired_order(state::Int64)::Int64
    return state == 0 ? 1 : (state == 2 ? -1 : 0)
end

"""
    compute_book_totals(books, edge_coordinates) → (cash, shares)

Aggregate cash and share holdings over the trading population: strictly
interior cells plus the active edge cells. Passive boundary cells are
excluded (they never trade). Used for the per-step accounting identity.
"""
function compute_book_totals(
    books::MyAgentBooks,
    edge_coordinates::Vector{Tuple{Int64,Int64}},
)::Tuple{Float64,Int64}
    nrows, ncols = size(books.cash)
    cash = 0.0; shares = 0
    for r in 2:nrows-1, c in 2:ncols-1
        cash   += books.cash[r, c]
        shares += books.shares[r, c]
    end
    for (r, c) in edge_coordinates
        cash   += books.cash[r, c]
        shares += books.shares[r, c]
    end
    return (cash, shares)
end

"""
    compute_crash_statistics(sell_fraction; threshold = 0.5)
        → (frequency, n_crashes, durations)

Crash statistics from the FULL per-step sell-fraction trajectory (never from
sparse snapshots): `frequency` is the fraction of entries ≥ threshold; a crash
episode is a maximal contiguous run of entries ≥ threshold; `durations` lists
episode lengths in steps (an episode still open at the end is counted).
"""
function compute_crash_statistics(
    sell_fraction::Vector{Float64};
    threshold::Float64 = 0.5,
)::NamedTuple{(:frequency, :n_crashes, :durations), Tuple{Float64, Int64, Vector{Int64}}}
    durations = Int64[]
    duration  = 0
    for s in sell_fraction
        if s ≥ threshold
            duration += 1
        elseif duration > 0
            push!(durations, duration)
            duration = 0
        end
    end
    duration > 0 && push!(durations, duration)
    frequency = isempty(sell_fraction) ? 0.0 :
        count(≥(threshold), sell_fraction) / length(sell_fraction)
    return (frequency = frequency, n_crashes = length(durations), durations = durations)
end

"""
    compute_max_drawdown(prices) → Float64

Largest peak-to-trough fractional decline: max over t of 1 − P_t / max_{s≤t} P_s.
Zero for a monotone non-decreasing series.
"""
function compute_max_drawdown(prices::Vector{Float64})::Float64
    isempty(prices) && return 0.0
    peak = prices[1]
    dd   = 0.0
    for p in prices
        peak = max(peak, p)
        dd   = max(dd, 1.0 - p / peak)
    end
    return dd
end

"""
    compute_sign_crossings(x) → Int64

Count of sign flips in a series. Zeros are skipped entirely: a crossing is
counted only when a nonzero value has the opposite sign of the previous
nonzero value (spec 2026-07-16 stage2 metrics).
"""
function compute_sign_crossings(x::Vector{Float64})::Int64
    last = 0
    n    = 0
    for v in x
        s = v > 0.0 ? 1 : (v < 0.0 ? -1 : 0)
        s == 0 && continue
        (last != 0 && s != last) && (n += 1)
        last = s
    end
    return n
end

"""
    compute_run_metrics(result) → NamedTuple

Reduce a full Model B run to the Stage 2 scalar summary row (spec 2026-07-16
stage2). Degenerate runs (return_std == 0) report NaN for kurtosis and
volatility clustering; the classifier maps them to :inert.
"""
function compute_run_metrics(result::MyModelBSimulationResult)::NamedTuple
    r  = result.log_returns
    σr = std(r)
    degenerate = (σr == 0.0)
    crash = compute_crash_statistics(result.sell_fraction)
    d     = crash.durations
    supp_b = sum(result.suppressed_buys)
    supp_s = sum(result.suppressed_sells)
    exec_b = sum(result.executed_buys)
    exec_s = sum(result.executed_sells)
    return (
        return_std               = σr,
        return_kurtosis          = degenerate ? NaN : kurtosis(r),
        volclust_ac1             = degenerate ? NaN : autocor(abs.(r), [1])[1],
        crash_frequency          = crash.frequency,
        n_crashes                = crash.n_crashes,
        crash_mean_duration      = isempty(d) ? 0.0 : mean(d),
        crash_max_duration       = isempty(d) ? 0 : maximum(d),
        max_drawdown             = compute_max_drawdown(result.prices),
        price_min                = minimum(result.prices),
        price_max                = maximum(result.prices),
        phi_zero_crossings       = compute_sign_crossings(result.net_imbalance),
        edge_switches            = result.edge_switches,
        suppressed_buy_fraction  = supp_b / max(1, exec_b + supp_b),
        suppressed_sell_fraction = supp_s / max(1, exec_s + supp_s),
        final_total_cash         = result.total_cash[end],
        final_total_shares       = result.total_shares[end],
    )
end

# Regime-classification thresholds (spec 2026-07-16 stage2): classification
# conveniences, not physics claims; revisit after the Phase A ensemble.
const _REGIME_CRASH_FREQ = 0.01   # ≥ 1% of steps in crash → :crash_prone
const _REGIME_OSC_XINGS  = 20     # ≥ this many φ sign flips → :oscillatory
const _REGIME_RANGE_FRAC = 0.10   # price range below this × P0 → :plateau

"""
    classify_regime(m, P0) → Symbol

Map a metrics NamedTuple to a discrete regime, in strict decision order:
:inert (no returns at all) → :crash_prone → :oscillatory → :plateau → :drift.
"""
function classify_regime(m::NamedTuple, P0::Float64)::Symbol
    m.return_std == 0.0                          && return :inert
    m.crash_frequency ≥ _REGIME_CRASH_FREQ       && return :crash_prone
    m.phi_zero_crossings ≥ _REGIME_OSC_XINGS     && return :oscillatory
    (m.price_max - m.price_min) / P0 < _REGIME_RANGE_FRAC && return :plateau
    return :drift
end
