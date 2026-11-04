# Course additions to the INFORMS engine: the default settings file, a sector-balanced subset of the
# universe for faster runs, and the market data of that subset.

"""
    default_study_path()::String

Path of the study's default settings, `data/mpc/study.toml` in the course package: a copy of the INFORMS
study's `config/study.toml` (windows, limits, costs, triggers, hedge, pickers). Read it with `load_study`
and change single values with `with_settings`.
"""
default_study_path()::String = joinpath(@__DIR__, "..", "data", "mpc", "study.toml")

"""
    select_universe(md::MyMarketData, n_tickers::Int; stop::Date=Date(2024, 12, 31))::Vector{String}

A sector-balanced subset of `md.tickers` with `n_tickers` names, for runs faster than the full universe.

- `n_tickers ≥ length(md.tickers)` returns every ticker.
- Otherwise each sector gets at least one name and the rest are shared in proportion to sector size
  (largest remainders, ties to the larger sector, then the sector label).
- Within a sector, names are ranked by their median daily dollar volume (close × volume, USD/day) on the
  dates up to `stop` (the 2014–2024 calibration window by default), largest first, ties by ticker.

The result is in the order of `md.tickers`, and the same inputs always give the same names. Throws
`ArgumentError` when `n_tickers` is smaller than the number of sectors.
"""
function select_universe(md::MyMarketData, n_tickers::Int; stop::Date=Date(2024, 12, 31))::Vector{String}

    # every name, when the request covers the universe -
    n = length(md.tickers)
    n_tickers >= n && return copy(md.tickers)
    sectors = sort(unique(md.sector))
    n_tickers >= length(sectors) ||
        throw(ArgumentError("n_tickers = $(n_tickers) is smaller than the number of sectors ($(length(sectors)))"))

    # names per sector: one each, the rest in proportion to sector size by largest remainder -
    size_of = Dict(s => count(==(s), md.sector) for s in sectors)
    quota = Dict(s => 1 for s in sectors)
    extra = n_tickers - length(sectors)
    share = Dict(s => extra * (size_of[s] - 1) / (n - length(sectors)) for s in sectors)
    for s in sectors
        quota[s] += floor(Int, share[s])
    end
    left = n_tickers - sum(values(quota))
    order = sort(sectors; by = s -> (-(share[s] - floor(share[s])), -size_of[s], s))
    for s in order[1:left]
        quota[s] += 1
    end

    # within each sector, the largest median dollar volume up to `stop` -
    rows = findall(<=(stop), md.dates)
    rows = isempty(rows) ? collect(eachindex(md.dates)) : rows
    dollar = [median(md.close[rows, j] .* md.volume[rows, j]) for j in 1:n]
    picked = Int[]
    for s in sectors
        members = findall(==(s), md.sector)
        ranked = sort(members; by = j -> (-dollar[j], md.tickers[j]))
        append!(picked, ranked[1:min(quota[s], length(ranked))])
    end
    return md.tickers[sort(picked)]
end

"""
    subset_universe(md::MyMarketData, tickers::Vector{String})::MyMarketData

The market data of `tickers` only: the same dates, SPY prices and risk-free rates, and the columns of the
named tickers in the order given. Throws `ArgumentError` naming a ticker that is not in `md`.
"""
function subset_universe(md::MyMarketData, tickers::Vector{String})::MyMarketData
    cols = Int[]
    for t in tickers
        j = findfirst(==(t), md.tickers)
        j === nothing && throw(ArgumentError("ticker $(t) is not in the market data"))
        push!(cols, j)
    end
    return build(MyMarketData, (dates = md.dates, tickers = md.tickers[cols], open = md.open[:, cols],
        close = md.close[:, cols], volume = md.volume[:, cols], spy_open = md.spy_open,
        spy_close = md.spy_close, sector = md.sector[cols], g_f = md.g_f))
end
