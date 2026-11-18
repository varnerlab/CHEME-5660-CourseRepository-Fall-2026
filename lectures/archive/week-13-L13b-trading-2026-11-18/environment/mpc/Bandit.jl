# Ticker step (spec §7): a per-sector ε-greedy bandit whose reward is "the closed-form Cobb-Douglas
# sub-basket beats SPY over the next 21 trading days", retrained walk-forward each quarter, plus the
# matched-churn random baseline. Semantics ported from the engine's `Bandit.jl`
# (modified_cobb_douglas_example/code/src/Bandit.jl: assign_quotas, sample_without_replacement,
# cd_basket_return, train_sector_bandit).

const BANDIT_FIT_START = Date(2014, 1, 3)   # first day of the walk-forward SIM fit window
const BANDIT_HORIZON = 21                   # reward horizon (trading days)

"""
    assign_quotas(sector_groups::Dict{String,Vector{Int}}, K::Int)::Dict{String,Int}

Per-sector basket quotas (names) summing to `K`: every sector gets K ÷ S, and the `K mod S` largest
sectors (by name count) get one more. Port of the engine's `assign_quotas`; ties in sector size are
broken by sector name so the result does not depend on `Dict` order. Quotas are not capped at the
sector size: a sector with fewer names than its quota contributes all of them to the basket.
"""
function assign_quotas(sector_groups::Dict{String,Vector{Int}}, K::Int)::Dict{String,Int}
    sectors = sort(collect(keys(sector_groups)); by = s -> (-length(sector_groups[s]), s))
    S = length(sectors)
    S > 0 || throw(ArgumentError("assign_quotas needs at least one sector"))
    base = K ÷ S
    remainder = K - base * S
    return Dict(s => base + (rank <= remainder ? 1 : 0) for (rank, s) in enumerate(sectors))
end

# Sector name → sorted column indices of `md.tickers`.
function _sector_groups(md::MyMarketData)::Dict{String,Vector{Int}}
    groups = Dict{String,Vector{Int}}()
    for (j, s) in enumerate(md.sector)
        push!(get!(groups, s, Int[]), j)
    end
    return groups
end

# `k` distinct draws from `pool` (all of `pool` when k ≥ length(pool), without using the RNG).
# Port of the engine's `sample_without_replacement`.
function _sample_without_replacement(rng::AbstractRNG, pool::Vector{Int}, k::Int)::Vector{Int}
    k >= length(pool) && return copy(pool)
    return shuffle(rng, pool)[1:k]
end

# Integer RNG seed for stream `s` (0 = random baseline, 1… = sector rank) on date `d` (R28 style:
# integers only, injective for 0 ≤ s < 64 and dates before year ~2740).
_stream_seed(seed::Int, d::Date, s::Int)::Int = (seed * 1_000_003 + Dates.value(d)) * 64 + s

"""
    beat_spy_reward(arm::Vector{Int}, day::Int, md::MyMarketData, α::Vector, β::Vector, g_m::Vector,
                    λ::Vector; horizon=21)::Int

Binary reward of one pull: 1 if the closed-form Cobb-Douglas buy-and-hold log return of `arm`
(column indices of `md.tickers`) from the close of `day` to the close of `day + horizon` (trading
days) is greater than SPY's, log(SPY_{day+h}/SPY_day), else 0.

γ = `preference_weights(α[arm], β[arm], g_m[day], λ[day])`, with `α` (yr⁻¹) and `β` indexed by column
and `g_m` (yr⁻¹) and `λ` indexed by day. Closed form (R9): nᵢ = B·(γᵢ/Σ_{γ>0}γ)/Sᵢ for γᵢ > 0 and 0
otherwise, so the arm's gross return is Σ_{γᵢ>0}(γᵢ/Σγ)·S_{day+h,i}/S_{day,i} (B cancels). If no γ is
positive the arm holds cash (log return 0).
"""
function beat_spy_reward(arm::Vector{Int}, day::Int, md::MyMarketData, α::AbstractVector, β::AbstractVector,
        g_m::AbstractVector, λ::AbstractVector; horizon::Int = BANDIT_HORIZON)::Int
    γ = preference_weights(collect(Float64, α[arm]), collect(Float64, β[arm]), Float64(g_m[day]), Float64(λ[day]))
    Γ = 0.0; gross = 0.0
    for (k, j) in enumerate(arm)
        γ[k] > 0 || continue
        Γ += γ[k]
        gross += γ[k] * md.close[day + horizon, j] / md.close[day, j]
    end
    r_arm = Γ > 0 ? log(gross / Γ) : 0.0
    r_spy = log(md.spy_close[day + horizon] / md.spy_close[day])
    return r_arm > r_spy ? 1 : 0
end

# Ordering key of an arm's record (wins, losses, first pull): the Beta(1+wins, 1+losses) mean
# (1+wins)/(2+wins+losses), then more pulls, then the earlier first pull. Exact (Rational) so equal
# means tie; the last two keys are seed-dependent and unrelated to ticker identity.
_arm_key(r::NTuple{3,Int}) = ((1 + r[1]) // (2 + r[1] + r[2]), r[1] + r[2], -r[3])

"""
    train_sector_bandit(sector_idx::Vector{Int}, q::Int, train_days::UnitRange{Int}, md::MyMarketData,
                        α::Vector, β::Vector, g_m::Vector, λ::Vector; seed::Int, ε_floor=0.05)
        ::NamedTuple{(:best_arm, :wins, :losses, :n_unique)}

ε-greedy bandit over the q-subsets ("arms") of one sector; port of the engine's
`train_sector_bandit` with the beat-SPY binary reward (`beat_spy_reward`, 21 trading days).

- Arms are sorted `Vector{Int}`s of column indices of `md.tickers`, drawn from `sector_idx`, tracked
  in a `Dict` (never enumerated). If q ≥ the sector size the only arm is the whole sector.
- iters = clamp(50·n_arms, 500, 5000), n_arms = binomial(N_s, min(q, N_s)).
- Pull t: ε = max(ε_floor, t > 1 ? min(1, t^(−1/3)·(n_arms·log t)^(1/3)) : 1); with probability ε (or
  before any pull) draw a random arm, otherwise pull the best arm; the day is uniform on `train_days`.
- Arm value = Beta(1+wins, 1+losses) mean (1+wins)/(2+wins+losses). Ties go to the arm with more
  pulls, then to the arm first pulled earlier.

`α` (yr⁻¹), `β` are per column; `g_m` (yr⁻¹), `λ` per day. Every random draw comes from
`MersenneTwister(seed)`. Returns the best arm, its wins and losses, and the number of distinct arms
pulled.
"""
function train_sector_bandit(sector_idx::Vector{Int}, q::Int, train_days::UnitRange{Int}, md::MyMarketData,
        α::AbstractVector, β::AbstractVector, g_m::AbstractVector, λ::AbstractVector;
        seed::Int, ε_floor::Float64 = 0.05)::NamedTuple{(:best_arm, :wins, :losses, :n_unique)}
    best, record = _run_sector_bandit(sector_idx, q, train_days, md, α, β, g_m, λ; seed = seed, ε_floor = ε_floor)
    w, l, _ = record[best]
    return (best_arm = best, wins = w, losses = l, n_unique = length(record))
end

# The bandit loop behind `train_sector_bandit`. Returns `(best, record)`: the best arm and every
# pulled arm's (wins, losses, first pull iteration).
function _run_sector_bandit(sector_idx::Vector{Int}, q::Int, train_days::UnitRange{Int}, md::MyMarketData,
        α::AbstractVector, β::AbstractVector, g_m::AbstractVector, λ::AbstractVector;
        seed::Int, ε_floor::Float64 = 0.05)
    isempty(sector_idx) && throw(ArgumentError("train_sector_bandit needs a non-empty sector"))
    q >= 1 || throw(ArgumentError("quota must be ≥ 1, got $(q)"))
    isempty(train_days) && throw(ArgumentError("train_sector_bandit needs at least one training day"))
    pool = sort(sector_idx)
    q_eff = min(q, length(pool))
    n_arms_big = binomial(big(length(pool)), q_eff)
    iters = Int(clamp(50 * n_arms_big, 500, 5000))
    n_arms = Float64(n_arms_big)
    rng = MersenneTwister(seed)
    record = Dict{Vector{Int},NTuple{3,Int}}()        # arm => (wins, losses, first pull)
    best = Int[]
    for t in 1:iters
        ε = max(ε_floor, t > 1 ? min(1.0, t^(-1/3) * (n_arms * log(t))^(1/3)) : 1.0)
        arm = (rand(rng) < ε || isempty(record)) ? sort(_sample_without_replacement(rng, pool, q_eff)) : best
        day = rand(rng, train_days)
        r = beat_spy_reward(arm, day, md, α, β, g_m, λ)
        w, l, f = get(record, arm, (0, 0, t))
        record[arm] = (w + r, l + 1 - r, f)
        if isempty(best)
            best = arm
        elseif arm == best
            # A loss lowers the incumbent's value: rescan. A win keeps it on top.
            r == 0 && (best = argmax(a -> _arm_key(record[a]), keys(record)))
        elseif _arm_key(record[arm]) > _arm_key(record[best])
            best = arm
        end
    end
    return best, record
end

"""
    quarter_starts(md::MyMarketData, start::Date, stop::Date)::Vector{Date}

The first trading day (in `md.dates`) of each calendar quarter, kept when it lies in [start, stop].
A quarter whose first trading day is before `start` is not included.
"""
function quarter_starts(md::MyMarketData, start::Date, stop::Date)::Vector{Date}
    out = Date[]
    for (i, d) in enumerate(md.dates)
        first_of_quarter = i == 1 || firstdayofquarter(md.dates[i-1]) != firstdayofquarter(d)
        first_of_quarter && start <= d <= stop && push!(out, d)
    end
    return out
end

"""
    bandit_basket_schedule(md::MyMarketData, retrain_dates::Vector{Date}; K=33, seed::Int,
                           fit_start=Date(2014,1,3))::Vector{Pair{Date,Vector{String}}}

Walk-forward bandit baskets: one `R => tickers` entry (sorted, `assign_quotas(…, K)` names per sector)
per retrain date R, each built from data dated before R only.

At each R (a trading day, with index iR):
- OLS SIM per ticker (`fit_base_sim`) on growth between consecutive trading days in [fit_start, R),
  giving α (yr⁻¹) and β.
- Training days: every d ≥ 2 with `md.dates[d+21] < R` (d = 1 has no previous close for g_m).
- g_m (yr⁻¹) and λ at each training day come from `market_state` at that day (computed once per call).
- One `train_sector_bandit` per sector (sectors in name order, rank s = 1, 2, …) with seed
  (seed·1_000_003 + Dates.value(R))·64 + s, so a quarter's basket does not depend on the other dates.
- The basket is the union of the sector winners (a sector with quota 0 contributes none).
"""
function bandit_basket_schedule(md::MyMarketData, retrain_dates::Vector{Date}; K::Int = 33, seed::Int,
        fit_start::Date = BANDIT_FIT_START)::Vector{Pair{Date,Vector{String}}}
    isempty(retrain_dates) && return Pair{Date,Vector{String}}[]
    all(retrain_dates[k] < retrain_dates[k+1] for k in 1:length(retrain_dates)-1) ||
        throw(ArgumentError("retrain_dates must be strictly increasing"))
    groups = _sector_groups(md)
    sectors = sort(collect(keys(groups)))
    length(sectors) < 64 || throw(ArgumentError("at most 63 sectors are supported, got $(length(sectors))"))
    quotas = assign_quotas(groups, K)
    iRs = [index_of(md, R) for R in retrain_dates]
    last_day = maximum(iRs) - BANDIT_HORIZON - 1
    last_day >= 2 || throw(ArgumentError("no training days before $(maximum(retrain_dates))"))
    # Causal market state per training day (NaN where unused).
    g_m = fill(NaN, last_day); λ = fill(NaN, last_day)
    for d in 2:last_day
        ms = market_state(md.spy_close, md.dates, md.dates[d])
        g_m[d] = ms.g_m; λ[d] = ms.λ
    end
    schedule = Pair{Date,Vector{String}}[]
    for (R, iR) in zip(retrain_dates, iRs)
        train_days = 2:(iR - BANDIT_HORIZON - 1)
        isempty(train_days) && throw(ArgumentError("no training days before $(R)"))
        fit = fit_base_sim(md, fit_start, md.dates[iR - 1])
        α = [fit.params[t].α for t in md.tickers]
        β = [fit.params[t].β for t in md.tickers]
        cols = Int[]
        for (s, sector) in enumerate(sectors)
            quotas[sector] == 0 && continue
            res = train_sector_bandit(groups[sector], quotas[sector], train_days, md, α, β, g_m, λ;
                seed = _stream_seed(seed, R, s))
            append!(cols, res.best_arm)
        end
        push!(schedule, R => sort(md.tickers[cols]))
    end
    return schedule
end

"""
    random_sector_basket(md::MyMarketData, K::Int; seed::Int)::Vector{String}

A uniformly random basket meeting the `assign_quotas(…, K)` quotas: min(q_s, N_s) names drawn without
replacement from each sector (sectors in name order, one `MersenneTwister(seed)` stream). Sorted tickers.
"""
function random_sector_basket(md::MyMarketData, K::Int; seed::Int)::Vector{String}
    groups = _sector_groups(md)
    quotas = assign_quotas(groups, K)
    rng = MersenneTwister(seed)
    cols = Int[]
    for sector in sort(collect(keys(groups)))
        quotas[sector] == 0 && continue
        append!(cols, _sample_without_replacement(rng, groups[sector], quotas[sector]))
    end
    return sort(md.tickers[cols])
end

"""
    random_matched_schedule(bandit::Vector{Pair{Date,Vector{String}}}, md::MyMarketData; seed::Int,
                            K=length(last(first(bandit))))::Vector{Pair{Date,Vector{String}}}

Random-pick baseline with the bandit's quotas and churn, on the bandit's dates.
- First entry: `random_sector_basket(md, K; seed)`; its per-sector counts must equal the bandit's.
- Entry k > 1: for each sector (name order), let m be the number of the bandit's names in that sector
  that left between entries k−1 and k. Remove m of the baseline's current names in the sector, chosen
  at random, and add m names chosen at random from the sector's names not currently held.
  Draws come from `MersenneTwister((seed·1_000_003 + Dates.value(date_k))·64)`.
"""
function random_matched_schedule(bandit::Vector{Pair{Date,Vector{String}}}, md::MyMarketData; seed::Int,
        K::Int = isempty(bandit) ? 0 : length(last(first(bandit))))::Vector{Pair{Date,Vector{String}}}
    isempty(bandit) && return Pair{Date,Vector{String}}[]
    sector_of = Dict(zip(md.tickers, md.sector))
    sectors = sort(unique(md.sector))
    in_sector(names, s) = [t for t in names if sector_of[t] == s]
    current = random_sector_basket(md, K; seed = seed)
    for s in sectors
        length(in_sector(current, s)) == length(in_sector(last(bandit[1]), s)) ||
            throw(ArgumentError("sector $(s): the bandit's first basket does not meet assign_quotas(…, $(K))"))
    end
    out = [first(bandit[1]) => current]
    for k in 2:length(bandit)
        prev_b, next_b = last(bandit[k-1]), last(bandit[k])
        rng = MersenneTwister(_stream_seed(seed, first(bandit[k]), 0))
        next = String[]
        for s in sectors
            held = sort(in_sector(current, s))
            gone = [t for t in in_sector(prev_b, s) if t ∉ next_b]
            length(in_sector(next_b, s)) == length(in_sector(prev_b, s)) ||
                throw(ArgumentError("sector $(s): the bandit basket changes size at $(first(bandit[k]))"))
            m = length(gone)
            pool = sort([t for t in md.tickers if sector_of[t] == s && t ∉ held])
            drop = Set(shuffle(rng, held)[1:m])
            add = shuffle(rng, pool)[1:m]
            append!(next, [t for t in held if t ∉ drop], add)
        end
        current = sort(next)
        push!(out, first(bandit[k]) => current)
    end
    return out
end
