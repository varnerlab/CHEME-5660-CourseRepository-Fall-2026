# L15a: the synthetic markets of the stress test and the forecast models of the band trigger. Instructor only.
#
# The run script includes this file after setup.jl. The synthetic markets come from the practicum's generator,
# copied at a pinned commit into scripts/practicum (see data/SOURCE.md). Each synthetic market is the real history
# from 2016-01-04 to 2026-11-24 followed by 252 synthetic trading days. Every strategy makes its first decision
# after the 2026-11-24 close with its 2026-11-24 estimates, as in the practicum's stress test.
#
# The synthetic days:
#   - the dates are the next 252 NYSE trading days after 2026-11-24 (data/nyse-holidays.csv)
#   - each close grows from the last real close at the synthetic growth rate, and the open equals the close
#   - each ticker's volume is its median daily volume over 2016–2024
#   - the risk-free rate stays at its last real value

import JumpHMM
include(joinpath(@__DIR__, "practicum", "src", "Generator.jl"))

const _GENERATOR_FILE = joinpath(_PATH_TO_L15A_DATA, "generator.jld2")
const _HOLIDAY_FILE = joinpath(_PATH_TO_L15A_DATA, "nyse-holidays.csv")
const _SYNTHETIC_DAYS = 252
const _Δt = 1 / 252

"""
    nyse_sessions_after(day::Date, count::Int)::Vector{Date}

The next `count` NYSE trading days after `day`: weekdays that are not full-day closures in `data/nyse-holidays.csv`.
"""
function nyse_sessions_after(day::Date, count::Int)::Vector{Date}

    # read the full-day closures -
    holidays = Set{Date}()
    table = CSV.read(_HOLIDAY_FILE, DataFrame; comment="#")
    for row in eachrow(table)
        push!(holidays, Date(row.date))
    end
    if maximum(holidays) < day + Day(round(Int, 1.5 * count))
        throw(ArgumentError("the holiday file ends before the synthetic days do"))
    end

    # step through the calendar one day at a time -
    sessions = Date[]
    d = day
    while length(sessions) < count
        d = d + Day(1)
        if dayofweek(d) <= 5 && (d in holidays) == false
            push!(sessions, d)
        end
    end
    return sessions
end

"""
    training_volume(md::MPC.MyMarketData)::Vector{Float64}

Each ticker's median daily volume (shares/day) over the fit window, 2016-01-04 to 2024-12-31, on the days the
ticker has a volume. A ticker that lists after 2016-01-04 has no volume (`NaN`) before its first trading day.
"""
function training_volume(md::MPC.MyMarketData)::Vector{Float64}
    last_row = searchsortedlast(md.dates, _TRAIN_STOP)
    volume = zeros(length(md.tickers))
    for j in eachindex(md.tickers)
        days = Float64[]
        for i in 1:last_row
            if isfinite(md.volume[i, j])
                push!(days, md.volume[i, j])
            end
        end
        volume[j] = median(days)
    end
    return volume
end

"""
    generator_columns(generator::NamedTuple, md::MPC.MyMarketData)::NamedTuple

The generator column of each market ticker (`stocks`) and of SPY (`spy`). Throws an `ArgumentError` when the
generator has no model for a market ticker.
"""
function generator_columns(generator::NamedTuple, md::MPC.MyMarketData)::NamedTuple
    column_of = Dict{String,Int}()
    for i in eachindex(generator.tickers)
        column_of[generator.tickers[i]] = i
    end
    stocks = zeros(Int, length(md.tickers))
    for j in eachindex(md.tickers)
        if haskey(column_of, md.tickers[j]) == false
            throw(ArgumentError("the generator has no model for $(md.tickers[j])"))
        end
        stocks[j] = column_of[md.tickers[j]]
    end
    return (stocks=stocks, spy=column_of["SPY"])
end

"""
    synthetic_market(md::MPC.MyMarketData, G::Matrix{Float64}, columns::NamedTuple, sessions::Vector{Date},
        volume::Vector{Float64})::MPC.MyMarketData

The real market `md` followed by one synthetic year. `G` holds the synthetic growth rates (1/yr), days × generator
tickers, from `synthetic_growth`. `columns` maps the market tickers and SPY to the columns of `G`.
"""
function synthetic_market(md::MPC.MyMarketData, G::Matrix{Float64}, columns::NamedTuple, sessions::Vector{Date},
        volume::Vector{Float64})::MPC.MyMarketData

    # grow every close from the last real close -
    n_days = length(sessions)
    n_tickers = length(md.tickers)
    close = zeros(n_days, n_tickers)
    spy_close = zeros(n_days)
    for j in 1:n_tickers
        S = md.close[end, j]
        for τ in 1:n_days
            S = S * exp(G[τ, columns.stocks[j]] * _Δt)
            close[τ, j] = S
        end
    end
    S = md.spy_close[end]
    for τ in 1:n_days
        S = S * exp(G[τ, columns.spy] * _Δt)
        spy_close[τ] = S
    end

    # the synthetic volumes and the risk-free rate -
    synthetic_volume = zeros(n_days, n_tickers)
    for τ in 1:n_days
        synthetic_volume[τ, :] = volume
    end
    g_f = fill(md.g_f[end], n_days)

    # the real history, then the synthetic days; the open of a synthetic day equals its close -
    return MPC.build(MPC.MyMarketData, (dates=vcat(md.dates, sessions), tickers=md.tickers,
        open=vcat(md.open, close), close=vcat(md.close, close), volume=vcat(md.volume, synthetic_volume),
        spy_open=vcat(md.spy_open, spy_close), spy_close=vcat(md.spy_close, spy_close), sector=md.sector,
        g_f=vcat(md.g_f, g_f)))
end

"""
    l15a_forecast_models(generator::NamedTuple, md::MPC.MyMarketData; n_steps::Int=1_000_000,
        seed::Int=5660)::MPC.MyForecastModels

The forecast models of the band trigger from the practicum's generator, for the tickers of `md`. The engine's factor
forecast draws each ticker's residual from one sector series and the ticker's own series (`MPC.project_factor`).
The practicum's general factor model loads every ticker on all 11 sectors, so each ticker gets one sector:

- a stock gets its GICS sector, and an ETF gets the sector with its largest loading;
- the sector series is the generator's model of that sector's uncorrelated series;
- the sector share ρ of the residual variance is the variance of the ticker's sector part, given the market,
  over that variance plus the variance of its own part. The own part includes the variance that the β drift adds.

The long-run moments of each model come from one draw of `n_steps` days, as in `MPC.build_forecast_models`.
"""
function l15a_forecast_models(generator::NamedTuple, md::MPC.MyMarketData; n_steps::Int=1_000_000,
        seed::Int=5660)::MPC.MyForecastModels

    # the covariance of the factors, and the covariance of the sector factors given the market (1/yr²) -
    C = generator.chol_L * transpose(generator.chol_L)
    c_mm = C[1, 1]
    C_sector = C[2:end, 2:end] .- (C[2:end, 1] * transpose(C[1, 2:end])) ./ c_mm

    # the market and sector moments -
    market = MPC._model_moments(generator.market_model, n_steps, seed, "market")
    n_sectors = length(generator.sector_names)
    m_factor = zeros(n_sectors)
    s_factor = zeros(n_sectors)
    for s in 1:n_sectors
        moments = MPC._model_moments(generator.factor_models[s], n_steps, seed + s, "sector $(generator.sector_names[s])")
        m_factor[s] = moments.m
        s_factor[s] = moments.s
    end

    # each ticker: its sector, its own model and moments, and its sector share -
    columns = generator_columns(generator, md)
    n_tickers = length(md.tickers)
    sector_index = zeros(Int, n_tickers)
    δ = zeros(n_tickers)
    ρ = zeros(n_tickers)
    m_name = zeros(n_tickers)
    s_name = zeros(n_tickers)
    names = Vector{Any}(undef, n_tickers)
    Threads.@threads for j in 1:n_tickers
        i = columns.stocks[j]
        loadings = generator.Δ[:, i]
        if md.sector[j] == "ETF"
            sector_index[j] = argmax(abs.(loadings))
        else
            sector_index[j] = findfirst(isequal(md.sector[j]), generator.sector_names)
        end
        δ[j] = loadings[sector_index[j]]
        names[j] = generator.own_models[md.tickers[j]]
        moments = MPC._model_moments(names[j], n_steps, seed + 100 + j, "ticker $(md.tickers[j])")
        m_name[j] = moments.m
        s_name[j] = moments.s
        sector_variance = transpose(loadings) * C_sector * loadings
        own_variance = generator.ψ[i]^2 * moments.s^2
        if generator.β_scale[i] > 0.0
            own_variance = own_variance + JumpHMM.drift_variance(generator.β_halflife, generator.β_scale[i]) * c_mm
        end
        ρ[j] = clamp(sector_variance / (sector_variance + own_variance), 0.0, 1.0)
    end

    # checks -
    @assert all(sector_index .>= 1) "every ticker has a sector"
    @assert all(isfinite, ρ) "every sector share is finite"

    return MPC.build(MPC.MyForecastModels, (tickers=copy(md.tickers), market=generator.market_model,
        factors=generator.factor_models, names=names, sector_index=sector_index, δ=δ, ρ=ρ, m_market=market.m,
        s_market=market.s, m_factor=m_factor, s_factor=s_factor, m_name=m_name, s_name=s_name))
end
