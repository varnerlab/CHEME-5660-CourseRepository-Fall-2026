# Ticker screens (N names per GICS sector at each re-pick date) and 130/30 short candidates.
# The bandit is a port of the eCornell S4 per-sector ε-greedy bandit (`train_sector_bandit`),
# changed to single-ticker arms and a continuous reward: the ticker's 21-day growth rate minus SPY's
# (yr⁻¹). All growth rates are g = ln(S_end/S_start)/(k·Δt) with Δt = 1/252.

"""
    AbstractScreen

Supertype of the ticker screens: `MyBanditScreen`, `MyGammaScreen`, `MyRandomScreen`.
"""
abstract type AbstractScreen end

"""
    MyBanditScreen <: AbstractScreen

Per-sector ε-greedy bandit over single-ticker arms. Fields: `lookback` (trading days; reward windows
must end within the trailing `lookback` days), `horizon` (trading days of one reward window),
`ε_floor` (dimensionless), `iters_per_arm`, `min_iters`, `max_iters` (pulls). Inner defaults
252, 21, 0.05, 50, 500, 5000 **(plan decision)**.
"""
mutable struct MyBanditScreen <: AbstractScreen
    lookback::Int
    horizon::Int
    ε_floor::Float64
    iters_per_arm::Int
    min_iters::Int
    max_iters::Int
    function MyBanditScreen()
        return new(252, 21, 0.05, 50, 500, 5000)
    end
end

"""
    MyGammaScreen <: AbstractScreen

Keeps the N highest-γ names per sector. No fields.
"""
mutable struct MyGammaScreen <: AbstractScreen
    MyGammaScreen() = new()
end

"""
    MyRandomScreen <: AbstractScreen

Draws N names per sector from a seeded stream. No fields.
"""
mutable struct MyRandomScreen <: AbstractScreen
    MyRandomScreen() = new()
end

"""
    build(::Type{MyBanditScreen}, data::NamedTuple)::MyBanditScreen

Start from the defaults and override any of the fields named in `data`.
"""
function build(::Type{MyBanditScreen}, data::NamedTuple)::MyBanditScreen
    m = MyBanditScreen()
    for f in fieldnames(MyBanditScreen)
        haskey(data, f) && setfield!(m, f, getfield(data, f))
    end
    return m
end

"""
    build(::Type{MyGammaScreen}, data::NamedTuple=NamedTuple())::MyGammaScreen

The γ screen has no fields; `data` is ignored.
"""
build(::Type{MyGammaScreen}, data::NamedTuple=NamedTuple())::MyGammaScreen = MyGammaScreen()

"""
    build(::Type{MyRandomScreen}, data::NamedTuple=NamedTuple())::MyRandomScreen

The random screen has no fields; `data` is ignored.
"""
build(::Type{MyRandomScreen}, data::NamedTuple=NamedTuple())::MyRandomScreen = MyRandomScreen()

"""
    excess_growth_windows(md::MyMarketData; horizon::Int=21, Δt::Float64=1/252)::Matrix{Float64}

Excess growth rate (yr⁻¹) of every ticker over SPY on every `horizon`-day window. Size
`(length(md.dates) - horizon) × length(md.tickers)`; row `d` is the window from the close of day `d`
to the close of day `d + horizon`:
`X[d, j] = (ln(close[d+h, j]/close[d, j]) - ln(spy[d+h]/spy[d])) / (h·Δt)`.
"""
function excess_growth_windows(md::MyMarketData; horizon::Int=21, Δt::Float64=1/252)::Matrix{Float64}
    n = length(md.dates) - horizon
    n >= 1 || throw(ArgumentError("need more than $horizon days, got $(length(md.dates))"))
    num = log.(md.close[(1 + horizon):end, :] ./ md.close[1:n, :]) .-
          log.(md.spy_close[(1 + horizon):end] ./ md.spy_close[1:n])
    return num ./ (horizon * Δt)
end

"""
    train_ticker_bandit(arms::Vector{Int}, days::UnitRange{Int}, X::AbstractMatrix; seed::Int,
        ε_floor=0.05, iters_per_arm=50, min_iters=500, max_iters=5000)::NamedTuple{(:mean, :count, :tiebreak)}

ε-greedy bandit with one arm per ticker. `arms` are column indices of `X`; a pull draws a day
uniformly from `days` and receives `X[day, arms[a]]` (excess growth rate, yr⁻¹). Pulls total
`clamp(iters_per_arm·length(arms), min_iters, max_iters)`. Returns the running mean reward (yr⁻¹,
0 for an unpulled arm), the pull count and the random tiebreak rank, all aligned with `arms`.
"""
function train_ticker_bandit(arms::Vector{Int}, days::UnitRange{Int}, X::AbstractMatrix; seed::Int,
        ε_floor::Real=0.05, iters_per_arm::Int=50, min_iters::Int=500, max_iters::Int=5000)
    rng = MersenneTwister(seed)
    A = length(arms)
    tiebreak = randperm(rng, A)
    iters = clamp(iters_per_arm * A, min_iters, max_iters)
    μ = zeros(A); cnt = zeros(Int, A)
    for k in 1:iters
        ε = max(ε_floor, k > 1 ? min(1.0, k^(-1 / 3) * (A * log(k))^(1 / 3)) : 1.0)
        pulled = findall(>(0), cnt)
        a = if rand(rng) < ε || isempty(pulled)
            rand(rng, 1:A)
        else
            pulled[argmax([(μ[i], -tiebreak[i]) for i in pulled])]
        end
        d = rand(rng, days)
        r = X[d, arms[a]]
        cnt[a] += 1
        μ[a] += (r - μ[a]) / cnt[a]
    end
    return (mean=μ, count=cnt, tiebreak=tiebreak)
end

"""
    rank_arms(res)::Vector{Int}

Positions (into the `arms` passed to `train_ticker_bandit`) ordered by: pulled arms first, then mean
reward descending, then `tiebreak` ascending.
"""
function rank_arms(res)::Vector{Int}
    return sortperm(collect(zip(res.count .== 0, -res.mean, res.tiebreak)))
end

"""
    pick(screen::AbstractScreen, md::MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}

Sorted column indices of the names kept after day `t`'s close: `N` per sector (all of a sector with
at most `N` names), sectors in sorted-name order.

- `MyBanditScreen`: per-sector bandit on `X` (excess growth rates, yr⁻¹, from `excess_growth_windows`
  with the screen's `horizon`). Training windows start on days `t-lookback+1-horizon … t-horizon`, so every
  window ends in `(t-lookback, t]`. Seed of sector rank `s`: `_stream_seed(seed, md.dates[t], s)`.
- `MyGammaScreen`: the `N` highest `γ_t` (yr⁻¹) per sector, ties by column index.
- `MyRandomScreen`: one `MersenneTwister(_stream_seed(seed, md.dates[t], 0))` stream, sectors in order.
"""
function pick(screen::MyBanditScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    size(X, 1) == length(md.dates) - screen.horizon ||
        throw(ArgumentError("X must have length(md.dates) - horizon = $(length(md.dates) - screen.horizon) rows, got $(size(X, 1))"))
    days = (t - screen.lookback + 1 - screen.horizon):(t - screen.horizon)
    first(days) >= 1 || throw(ArgumentError("training days start at $(first(days)) < 1 for t = $t"))
    groups = _sector_groups(md)
    keep = Int[]
    for (s, sector) in enumerate(sort(collect(keys(groups))))
        pool = groups[sector]
        if length(pool) <= N
            append!(keep, pool)
            continue
        end
        res = train_ticker_bandit(pool, days, X; seed=_stream_seed(seed, md.dates[t], s),
            ε_floor=screen.ε_floor, iters_per_arm=screen.iters_per_arm,
            min_iters=screen.min_iters, max_iters=screen.max_iters)
        append!(keep, pool[rank_arms(res)[1:N]])
    end
    return sort(keep)
end

function pick(screen::MyGammaScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    groups = _sector_groups(md)
    keep = Int[]
    for sector in sort(collect(keys(groups)))
        pool = groups[sector]
        order = sortperm(collect(zip(-γ_t[pool], pool)))
        append!(keep, pool[order[1:min(N, length(pool))]])
    end
    return sort(keep)
end

function pick(screen::MyRandomScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    groups = _sector_groups(md)
    rng = MersenneTwister(_stream_seed(seed, md.dates[t], 0))
    keep = Int[]
    for sector in sort(collect(keys(groups)))
        append!(keep, _sample_without_replacement(rng, groups[sector], N))
    end
    return sort(keep)
end

# ---------------------------------------------------------------------------------------------
# Universe-wide screens: K names from the whole universe (no sector quota). They carry K as a
# field and ignore the per-sector `N` passed to `pick`.
# ---------------------------------------------------------------------------------------------

"""
    liquid_shortlist(md::MyMarketData, t::Int; size::Int=100, window::Int=63)::Vector{Int}

The `size` columns with the largest median dollar volume (USD/day), the median of
`close[k, j]·volume[k, j]` over rows `k ∈ max(1, t-window+1):t`. Ranked by dollar volume descending,
ties by column index. Uses data dated at or before day `t` only.
"""
function liquid_shortlist(md::MyMarketData, t::Int; size::Int=100, window::Int=63)::Vector{Int}
    rows = max(1, t - window + 1):t
    dv = [median(md.close[rows, j] .* md.volume[rows, j]) for j in 1:length(md.tickers)]
    order = sortperm(collect(zip(-dv, 1:length(dv))))
    return order[1:min(size, length(order))]
end

"""
    MyGlobalGammaScreen <: AbstractScreen

The `K` highest-γ names (yr⁻¹) over the whole universe. Field: `K` (names, ≥ 1).
"""
mutable struct MyGlobalGammaScreen <: AbstractScreen
    K::Int
    MyGlobalGammaScreen(K::Int) = (K >= 1 || throw(ArgumentError("K must be ≥ 1, got $K")); new(K))
end

"""
    MyLiquidGammaScreen <: AbstractScreen

The `K` highest-γ names (yr⁻¹) within the liquid shortlist. Fields: `K` (names, ≥ 1), `shortlist`
(names kept by median dollar volume), `window` (trading days of the dollar-volume median).
"""
mutable struct MyLiquidGammaScreen <: AbstractScreen
    K::Int
    shortlist::Int
    window::Int
    MyLiquidGammaScreen(K::Int, shortlist::Int, window::Int) =
        (K >= 1 || throw(ArgumentError("K must be ≥ 1, got $K")); new(K, shortlist, window))
end

"""
    MyCorrGammaScreen <: AbstractScreen

Walks the global γ ranking and accepts a name only if its correlation with every accepted name,
on daily growth rates (yr⁻¹) over the trailing `window` days, is at most `corr_max`. Fields: `K`
(names, ≥ 1), `corr_max` (dimensionless), `window` (trading days).
"""
mutable struct MyCorrGammaScreen <: AbstractScreen
    K::Int
    corr_max::Float64
    window::Int
    MyCorrGammaScreen(K::Int, corr_max::Real, window::Int) =
        (K >= 1 || throw(ArgumentError("K must be ≥ 1, got $K")); new(K, corr_max, window))
end

"""
    MyGlobalRandomScreen <: AbstractScreen

`K` distinct names drawn at random from the whole universe. Field: `K` (names, ≥ 1).
"""
mutable struct MyGlobalRandomScreen <: AbstractScreen
    K::Int
    MyGlobalRandomScreen(K::Int) = (K >= 1 || throw(ArgumentError("K must be ≥ 1, got $K")); new(K))
end

"""
    MyLiquidRandomScreen <: AbstractScreen

`K` distinct names drawn at random from the liquid shortlist. Fields as `MyLiquidGammaScreen`.
"""
mutable struct MyLiquidRandomScreen <: AbstractScreen
    K::Int
    shortlist::Int
    window::Int
    MyLiquidRandomScreen(K::Int, shortlist::Int, window::Int) =
        (K >= 1 || throw(ArgumentError("K must be ≥ 1, got $K")); new(K, shortlist, window))
end

"""
    MyFixedScreen <: AbstractScreen

A fixed ticker list, chosen in advance and independent of the data. Field: `tickers`.
"""
mutable struct MyFixedScreen <: AbstractScreen
    tickers::Vector{String}
    MyFixedScreen(tickers::Vector{String}) = new(tickers)
end

"""
    build(::Type{T}, data::NamedTuple) where T in the universe-wide screens

Construct the screen from the fields named in `data` (`K`; plus `shortlist`, `window` or `corr_max`
where the screen has them; `tickers` for `MyFixedScreen`).
"""
build(::Type{MyGlobalGammaScreen}, d::NamedTuple)::MyGlobalGammaScreen = MyGlobalGammaScreen(d.K)
build(::Type{MyLiquidGammaScreen}, d::NamedTuple)::MyLiquidGammaScreen = MyLiquidGammaScreen(d.K, d.shortlist, d.window)
build(::Type{MyCorrGammaScreen}, d::NamedTuple)::MyCorrGammaScreen = MyCorrGammaScreen(d.K, d.corr_max, d.window)
build(::Type{MyGlobalRandomScreen}, d::NamedTuple)::MyGlobalRandomScreen = MyGlobalRandomScreen(d.K)
build(::Type{MyLiquidRandomScreen}, d::NamedTuple)::MyLiquidRandomScreen = MyLiquidRandomScreen(d.K, d.shortlist, d.window)
build(::Type{MyFixedScreen}, d::NamedTuple)::MyFixedScreen = MyFixedScreen(collect(String, d.tickers))

# The K highest γ_t (yr⁻¹) among `pool`, ties by column index; sorted columns.
function _top_gamma(pool::Vector{Int}, γ_t::AbstractVector, K::Int)::Vector{Int}
    order = sortperm(collect(zip(-γ_t[pool], pool)))
    return sort(pool[order[1:min(K, length(pool))]])
end

"""
    pick(screen, md, t; X, γ_t, N, seed)::Vector{Int}   (universe-wide screens)

Sorted column indices of `min(K, eligible)` names. `N` is ignored. All use data dated ≤ `t` only.

- `MyGlobalGammaScreen`: the `K` highest `γ_t` (yr⁻¹), ties by column index.
- `MyLiquidGammaScreen`: the same, within `liquid_shortlist(md, t; size=shortlist, window)`.
- `MyCorrGammaScreen`: walk the global γ ranking; accept j if `cor(gⱼ, gₐ) ≤ corr_max` for every
  accepted a, where g is the daily growth rate `ln(close[k]/close[k-1])/Δt` (yr⁻¹), Δt = 1/252, for
  `k ∈ (t-window+1):t`. A NaN correlation (zero variance) counts as not exceeding `corr_max`. If
  fewer than `K` are accepted, fill with the highest-γ names not yet accepted.
- `MyGlobalRandomScreen`, `MyLiquidRandomScreen`: `K` distinct columns from
  `MersenneTwister(_stream_seed(seed, md.dates[t], 0))`, over the universe or the liquid shortlist.
- `MyFixedScreen`: the sorted columns of `tickers`; `ArgumentError` naming any ticker not in
  `md.tickers`.
"""
function pick(screen::MyGlobalGammaScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    return _top_gamma(collect(1:length(md.tickers)), γ_t, screen.K)
end

function pick(screen::MyLiquidGammaScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    return _top_gamma(liquid_shortlist(md, t; size=screen.shortlist, window=screen.window), γ_t, screen.K)
end

function pick(screen::MyCorrGammaScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    Δt = 1 / 252
    m = length(md.tickers)
    ks = (t - screen.window + 1):t
    first(ks) >= 2 || throw(ArgumentError("correlation window starts at $(first(ks)) < 2 for t = $t"))
    g = log.(md.close[ks, :] ./ md.close[ks .- 1, :]) ./ Δt         # yr⁻¹
    order = sortperm(collect(zip(-γ_t, 1:m)))
    accepted = Int[]
    for j in order
        length(accepted) >= screen.K && break
        ok = all(a -> begin
                ρ = cor(view(g, :, j), view(g, :, a))
                isnan(ρ) || ρ <= screen.corr_max
            end, accepted)
        ok && push!(accepted, j)
    end
    if length(accepted) < screen.K
        for j in order
            length(accepted) >= screen.K && break
            j in accepted || push!(accepted, j)
        end
    end
    return sort(accepted)
end

function pick(screen::MyGlobalRandomScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    rng = MersenneTwister(_stream_seed(seed, md.dates[t], 0))
    return sort(_sample_without_replacement(rng, collect(1:length(md.tickers)), screen.K))
end

function pick(screen::MyLiquidRandomScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    rng = MersenneTwister(_stream_seed(seed, md.dates[t], 0))
    pool = liquid_shortlist(md, t; size=screen.shortlist, window=screen.window)
    return sort(_sample_without_replacement(rng, pool, screen.K))
end

function pick(screen::MyFixedScreen, md::MyMarketData, t::Int; X::AbstractMatrix,
        γ_t::AbstractVector, N::Int, seed::Int)::Vector{Int}
    missing_t = [s for s in screen.tickers if !(s in md.tickers)]
    isempty(missing_t) || throw(ArgumentError("fixed-list tickers not in the universe: $(join(missing_t, ", "))"))
    return sort([findfirst(==(s), md.tickers) for s in screen.tickers])
end

"""
    short_candidates(γ_t::AbstractVector, md::MyMarketData; N::Int, exclude::AbstractVector{Int}=Int[])::Vector{Int}

130/30 short candidates: per sector, the up to `N` names with `γ_t < 0` (yr⁻¹) that are not in
`exclude`, most negative first (ties by column index). Returns sorted column indices.
"""
function short_candidates(γ_t::AbstractVector, md::MyMarketData; N::Int,
        exclude::AbstractVector{Int}=Int[])::Vector{Int}
    groups = _sector_groups(md)
    out = Int[]
    for sector in sort(collect(keys(groups)))
        pool = [j for j in groups[sector] if γ_t[j] < 0 && !(j in exclude)]
        order = sortperm(collect(zip(γ_t[pool], pool)))
        append!(out, pool[order[1:min(N, length(pool))]])
    end
    return sort(out)
end
