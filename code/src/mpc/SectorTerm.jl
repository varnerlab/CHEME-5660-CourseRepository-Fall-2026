# Course addition (CHEME 5660 L15a, 2026-11-27): the sector term of the sector factor estimates.
#
# With `estimates = "sector_factor"`, every stock keeps its fixed single index fit (α, β, σ_ε from the training
# window), and its expected growth rate gains a sector term:
#
#     expected growth of stock i = α̂ᵢ + β̂ᵢ·g̃_M(t) + δ̂ᵢ·f̃ₛ,₋ᵢ(t)
#
# fₛ,₋ᵢ(t) is the sector factor of stock i, in the notation of the course's sector factor model: the mean single index
# residual growth into day t of the OTHER stocks in its sector s, with the training fit. f̃ₛ,₋ᵢ(t) is its moving average
# over the same window as g̃_M. δ̂ᵢ is the stock's sector loading, the least squares slope fit once on the training
# window. ETFs have no sector, so their sector term is zero. `build_context` adds
# the sector term to the fixed α of every row, so the preference weights, the expected growth of the
# mean-variance rules, and the factor forecast all use it.

"""
    sector_factor_series(md::MyMarketData, calib::MyCalibration)::Matrix{Float64}

Compute the sector factor of each ticker on each trading day (yr⁻¹). Row `t`, column `i` holds the mean single index
residual growth into day `t` of the other stocks in the sector of ticker `i`. The residual of stock `j` is
`gⱼ(t) − αⱼ − βⱼ·g_M(t)`, with the training fit in `calib.base_sim`. A stock without a price on a day is left out
of that day's mean. We leave stock `i` out of its own factor, so that its own noise does not enter the factor.

### Arguments
- `md::MyMarketData`: The market data. A ticker with the sector `"ETF"` has no sector
- `calib::MyCalibration`: The calibration, with the training fit of every ticker

### Returns
- `Matrix{Float64}`: The sector factors, days × tickers (yr⁻¹). Row 1 holds `NaN`, because day 1 has no growth.
  An ETF column holds `0.0` after row 1

Throws an `ArgumentError` when a ticker has no training fit, when a stock is the only stock in its sector, or when
no other stock of its sector has a price on a day after day 1.

### Example
```julia
F = sector_factor_series(md, calib);
```
"""
function sector_factor_series(md::MyMarketData, calib::MyCalibration)::Matrix{Float64}

    # initialize -
    n_days = length(md.dates)
    n_tickers = length(md.tickers)
    g = growth_rates(md.close)                 # row k is the growth into day k + 1 (yr⁻¹)
    g_m = growth_rates(md.spy_close)

    # the single index residuals with the training fit (NaN before a ticker's first price) -
    E = fill(NaN, n_days - 1, n_tickers)
    for j in 1:n_tickers
        if haskey(calib.base_sim, md.tickers[j]) == false
            throw(ArgumentError("ticker $(md.tickers[j]) has no training fit"))
        end
        fit = calib.base_sim[md.tickers[j]]
        for k in 1:(n_days - 1)
            E[k, j] = g[k, j] - fit.α - fit.β * g_m[k]
        end
    end

    # the stocks of each sector (the ETFs have no sector) -
    members = Dict{String,Vector{Int}}()
    for j in 1:n_tickers
        if md.sector[j] != "ETF"
            if haskey(members, md.sector[j]) == false
                members[md.sector[j]] = Int[]
            end
            push!(members[md.sector[j]], j)
        end
    end
    for (label, stocks) in members
        if length(stocks) < 2
            throw(ArgumentError("sector $(label) has one stock; its sector factor needs at least two"))
        end
    end

    # main loop: on each day, the mean residual of the other stocks of each sector -
    F = zeros(Float64, n_days, n_tickers)
    F[1, :] .= NaN
    for (label, stocks) in members
        for k in 1:(n_days - 1)

            # the sum and count of the sector's residuals on this day -
            total = 0.0
            count = 0
            for j in stocks
                if isfinite(E[k, j]) == true
                    total = total + E[k, j]
                    count = count + 1
                end
            end

            # each stock's factor leaves its own residual out -
            for i in stocks
                own_total = total
                own_count = count
                if isfinite(E[k, i]) == true
                    own_total = total - E[k, i]
                    own_count = count - 1
                end
                if own_count < 1
                    throw(ArgumentError("on $(md.dates[k + 1]), no other stock of sector $(label) has a price"))
                end
                F[k + 1, i] = own_total / own_count
            end
        end
    end

    # return -
    return F
end

"""
    sector_loadings(md::MyMarketData, calib::MyCalibration, F::Matrix{Float64}; train_start::Date,
        train_stop::Date)::Vector{Float64}

Compute the sector loading δ̂ᵢ of each ticker (dimensionless). The loading is the slope of an ordinary least squares
fit, with an intercept, of the stock's single index residual on its sector factor `F[:, i]`. The fit uses the growth
days of the training window (`train_start` to `train_stop`) on which the stock has a residual.

### Arguments
- `md::MyMarketData`: The market data
- `calib::MyCalibration`: The calibration, with the training fit of every ticker
- `F::Matrix{Float64}`: The sector factors from `sector_factor_series` (yr⁻¹)
- `train_start::Date`: The first day of the training window
- `train_stop::Date`: The last day of the training window

### Returns
- `Vector{Float64}`: The sector loading of each ticker. An ETF gets `0.0`

Throws an `ArgumentError` when `F` does not match `md`, or when a stock has fewer than two training days or a
constant sector factor over its training days.

### Example
```julia
δ = sector_loadings(md, calib, F; train_start=Date(2016, 1, 4), train_stop=Date(2024, 12, 31));
```
"""
function sector_loadings(md::MyMarketData, calib::MyCalibration, F::Matrix{Float64}; train_start::Date,
        train_stop::Date)::Vector{Float64}

    # check: one row per day and one column per ticker -
    if size(F) != size(md.close)
        throw(ArgumentError("F is $(size(F)), but the market data are $(size(md.close))"))
    end

    # the growth days of the training window: growth into the second training day through the last -
    first_day = index_of(md, train_start)
    last_day = searchsortedlast(md.dates, train_stop)
    g = growth_rates(md.close)
    g_m = growth_rates(md.spy_close)

    # main loop: one least squares slope per stock -
    δ = zeros(Float64, length(md.tickers))
    for i in eachindex(md.tickers)
        if md.sector[i] != "ETF"
            fit = calib.base_sim[md.tickers[i]]

            # the training days on which the stock has a residual -
            x = Float64[]
            y = Float64[]
            for t in (first_day + 1):last_day
                residual = g[t - 1, i] - fit.α - fit.β * g_m[t - 1]
                if isfinite(residual) == true && isfinite(F[t, i]) == true
                    push!(x, F[t, i])
                    push!(y, residual)
                end
            end
            if length(x) < 2
                throw(ArgumentError("ticker $(md.tickers[i]) has fewer than two training days"))
            end

            # the slope: the covariance of the residual and the factor over the variance of the factor -
            x̄ = mean(x)
            ȳ = mean(y)
            variance = sum((x .- x̄) .^ 2)
            if variance <= 0.0
                throw(ArgumentError("ticker $(md.tickers[i]) has a constant sector factor over the training days"))
            end
            δ[i] = sum((x .- x̄) .* (y .- ȳ)) / variance
        end
    end

    # return -
    return δ
end

"""
    smoothed_sector_factor(F::Matrix{Float64}; window::Int)::Matrix{Float64}

Compute the moving average f̃ of each column of the sector factors `F` (yr⁻¹), the same way `gtilde_series`
smooths the market growth rate. Row 1 holds `NaN`. Row `t ≥ 2` holds the span-`window` exponential moving
average of `F[2:t, i]`, seeded at `F[2, i]`. Each row uses the factors through its own day only.

### Arguments
- `F::Matrix{Float64}`: The sector factors from `sector_factor_series` (yr⁻¹)
- `window::Int`: The span of the moving average (trading days), the study's `gtilde_window`

### Returns
- `Matrix{Float64}`: The smoothed sector factors, days × tickers (yr⁻¹)

### Example
```julia
F̃ = smoothed_sector_factor(F; window=252);
```
"""
function smoothed_sector_factor(F::Matrix{Float64}; window::Int)::Matrix{Float64}

    # initialize -
    F̃ = fill(NaN, size(F))

    # main loop: one moving average per ticker -
    for i in 1:size(F, 2)
        F̃[2:end, i] = ema_series(F[2:end, i]; span=window)
    end

    # return -
    return F̃
end

"""
    add_sector_term!(sim::MyOnlineSIM, md::MyMarketData, calib::MyCalibration, s::MyStudySettings)::MyOnlineSIM

Add the sector term δ̂ᵢ·f̃ₛ,₋ᵢ(t) to the fixed α of every row of `sim`, in place. Row `k` of `sim` is the market-data
row `sim.rows[k]`, and its sector term uses the factors through that day only. The loadings come from the training
window of `s`, and the moving average uses the window `s.gtilde_window`.

### Arguments
- `sim::MyOnlineSIM`: The fixed estimates of the run, from `_fixed_sim`
- `md::MyMarketData`: The market data
- `calib::MyCalibration`: The calibration, with the training fit of every ticker
- `s::MyStudySettings`: The study settings

### Returns
- `MyOnlineSIM`: `sim`, whose `α` now holds the fixed α plus the sector term (yr⁻¹)
"""
function add_sector_term!(sim::MyOnlineSIM, md::MyMarketData, calib::MyCalibration,
        s::MyStudySettings)::MyOnlineSIM

    # the sector factors, the loadings, and the smoothed factors -
    F = sector_factor_series(md, calib)
    δ = sector_loadings(md, calib, F; train_start=s.train_start, train_stop=s.train_stop)
    F̃ = smoothed_sector_factor(F; window=s.gtilde_window)

    # main loop: add the sector term to the α of every row and ticker -
    for (k, t) in enumerate(sim.rows)
        for j in eachindex(md.tickers)
            sim.α[k, j] = sim.α[k, j] + δ[j] * F̃[t, j]
        end
    end

    # return -
    return sim
end
