# Course additions for L14a: a market built from synthetic growth rates, the betting-against-beta strategy of
# Frazzini and Pedersen (2014), and the buy-and-hold references. They use the engine's market data, online single
# index estimates and cost functions, so every strategy is scored on the same days with the same costs.

"""
    market_data_from_growth(dates, tickers, sector, close0, spy0, volume, g_f, g_m, G; Δt=1/252)::MyMarketData

A market built from growth rates: one synthetic history of every stock and of `SPY` on the trading days `dates`.

The closes start at `close0` and `spy0` on `dates[1]` and compound as S(t+1) = S(t)·exp(g(t)·Δt). The opens equal
the closes, and each stock's volume is the same on every day.

### Arguments
- `dates::Vector{Date}`: the trading days (n + 1 of them).
- `tickers::Vector{String}`: the stocks' tickers (N of them).
- `sector::Vector{String}`: the GICS sector of each stock.
- `close0::Vector{Float64}`: each stock's close on `dates[1]` (USD/share).
- `spy0::Float64`: `SPY`'s close on `dates[1]` (USD/share).
- `volume::Vector{Float64}`: each stock's volume (shares/day).
- `g_f::Vector{Float64}`: the risk-free rate on each date (yr⁻¹).
- `g_m::Vector{Float64}`: `SPY`'s growth rate on each of the n days (yr⁻¹).
- `G::Matrix{Float64}`: the stocks' growth rates, n days × N stocks (yr⁻¹).
- `Δt::Float64`: the time step (yr).

### Returns
- `MyMarketData`: the market. Throws `ArgumentError` when the sizes do not match, or naming the first stock whose
  close is not finite and positive.

### Example
```julia
md_syn = market_data_from_growth(md.dates, md.tickers, md.sector, md.close[1, :], md.spy_close[1],
    volume, md.g_f, path.g_m, G);
```
"""
function market_data_from_growth(dates::Vector{Date}, tickers::Vector{String}, sector::Vector{String},
        close0::Vector{Float64}, spy0::Float64, volume::Vector{Float64}, g_f::Vector{Float64},
        g_m::Vector{Float64}, G::Matrix{Float64}; Δt::Float64=1/252)::MyMarketData

    # initialize: the sizes of the growth rates and the market -
    (n, N) = size(G);
    number_of_dates = length(dates);
    if number_of_dates != n + 1 || length(g_m) != n || length(g_f) != number_of_dates
        throw(ArgumentError("market_data_from_growth: dates ($(number_of_dates)), g_f ($(length(g_f))) and g_m " *
            "($(length(g_m))) do not fit G with $(n) days"));
    end
    if length(tickers) != N || length(sector) != N || length(close0) != N || length(volume) != N
        throw(ArgumentError("market_data_from_growth: tickers, sector, close0 and volume need one entry per column of G ($(N))"));
    end

    # compound the closes from the first day: stocks, then SPY -
    close = zeros(Float64, number_of_dates, N);
    for j in 1:N
        close[1, j] = close0[j];
        for t in 1:n
            close[t + 1, j] = close[t, j] * exp(G[t, j] * Δt);
        end
    end
    spy = zeros(Float64, number_of_dates);
    spy[1] = spy0;
    for t in 1:n
        spy[t + 1] = spy[t] * exp(g_m[t] * Δt);
    end

    # each stock's volume on every day -
    V = zeros(Float64, number_of_dates, N);
    for j in 1:N
        for t in 1:number_of_dates
            V[t, j] = volume[j];
        end
    end

    # check: every close is finite and positive -
    for j in 1:N
        for t in 1:number_of_dates
            if (isfinite(close[t, j]) && close[t, j] > 0) == false
                throw(ArgumentError("market_data_from_growth: $(tickers[j]) has close $(close[t, j]) on $(dates[t])"));
            end
        end
    end

    return build(MyMarketData, (dates=copy(dates), tickers=copy(tickers), open=copy(close), close=close,
        volume=V, spy_open=copy(spy), spy_close=spy, sector=copy(sector), g_f=copy(g_f)));
end

"""
    bab_weights(β::AbstractVector{<:Real})::NamedTuple

The rank weights of the betting-against-beta portfolios (Frazzini and Pedersen, 2014, equation 16). Stock i has
rank zᵢ of its β (1 is the lowest). With z̄ the mean rank and k = 2/Σ|zᵢ − z̄|, the high-β portfolio has weights
k·max(zᵢ − z̄, 0) and the low-β portfolio has weights k·max(z̄ − zᵢ, 0). Each portfolio's weights sum to `1`.

### Arguments
- `β::AbstractVector{<:Real}`: the β of each stock (dimensionless). Ties keep the order of the stocks.

### Returns
- `NamedTuple`: `w_low` and `w_high`, the weights of the low-β and the high-β portfolios (dimensionless).

### Example
```julia
w = bab_weights([0.6, 1.4, 0.9, 1.1]);
```
"""
function bab_weights(β::AbstractVector{<:Real})::NamedTuple
    n = length(β);
    if n < 2
        throw(ArgumentError("bab_weights: needs at least 2 stocks, got $(n)"));
    end

    # the rank of each stock's β: 1 is the lowest -
    order = sortperm(collect(β));
    z = zeros(Float64, n);
    for r in 1:n
        z[order[r]] = r;
    end

    # the scale k makes each portfolio's weights sum to 1 -
    z̄ = mean(z);
    total = 0.0;
    for i in 1:n
        total = total + abs(z[i] - z̄);
    end
    k = 2 / total;

    # stocks above the mean rank go in the high-β portfolio, stocks below it in the low-β portfolio -
    w_low = zeros(Float64, n);
    w_high = zeros(Float64, n);
    for i in 1:n
        if z[i] > z̄
            w_high[i] = k * (z[i] - z̄);
        elseif z[i] < z̄
            w_low[i] = k * (z̄ - z[i]);
        end
    end
    return (w_low=w_low, w_high=w_high);
end

"""
    bab_betas(md::MyMarketData, t::Int; vol_window::Int=252, corr_window::Int=1260, lag::Int=3)::Vector{Float64}

Each stock's β estimate on market-data row `t`, as Frazzini and Pedersen (2014, equation 14) estimate it:
β̂ᵢ = ρ̂ᵢ·σ̂ᵢ/σ̂_m. The volatilities σ̂ᵢ and σ̂_m are standard deviations of daily log returns over the last
`vol_window` days. The correlation ρ̂ᵢ uses overlapping `lag`-day log returns over the last `corr_window` days,
which accounts for stocks that react to the market a day or two late. Only rows up to `t` are used.

### Arguments
- `md::MyMarketData`: the market data.
- `t::Int`: the market-data row (the estimate uses rows up to `t`).
- `vol_window::Int`: the volatility window (trading days, one year in the paper).
- `corr_window::Int`: the correlation window (trading days, five years in the paper).
- `lag::Int`: the length of the overlapping returns of the correlation (trading days).

### Returns
- `Vector{Float64}`: one β estimate per stock (dimensionless). Throws `ArgumentError` when `t` leaves fewer than
  `corr_window` rows of history.

### Example
```julia
β̂ = bab_betas(md, 2800);
```
"""
function bab_betas(md::MyMarketData, t::Int; vol_window::Int=252, corr_window::Int=1260, lag::Int=3)::Vector{Float64}
    if t <= corr_window + lag || t <= vol_window
        throw(ArgumentError("bab_betas: row $(t) leaves fewer than $(corr_window + lag) rows of history"));
    end
    N = length(md.tickers);

    # the market: daily log returns over the volatility window, and lag-day log returns over the correlation window -
    r_m = zeros(Float64, vol_window);
    for k in 1:vol_window
        u = t - vol_window + k;
        r_m[k] = log(md.spy_close[u] / md.spy_close[u - 1]);
    end
    σ_m = std(r_m);
    x_m = zeros(Float64, corr_window);
    for k in 1:corr_window
        u = t - corr_window + k;
        x_m[k] = log(md.spy_close[u] / md.spy_close[u - lag]);
    end

    # each stock: the same returns, then β̂ = ρ̂·σ̂ᵢ/σ̂_m -
    β = zeros(Float64, N);
    r = zeros(Float64, vol_window);
    x = zeros(Float64, corr_window);
    for j in 1:N
        for k in 1:vol_window
            u = t - vol_window + k;
            r[k] = log(md.close[u, j] / md.close[u - 1, j]);
        end
        for k in 1:corr_window
            u = t - corr_window + k;
            x[k] = log(md.close[u, j] / md.close[u - lag, j]);
        end
        β[j] = cor(x, x_m) * std(r) / σ_m;
    end
    return β;
end

"""
    bab_rebalance_rows(md::MyMarketData, rows::UnitRange{Int})::Vector{Int}

The market-data rows where betting against beta rebalances: the first row of `rows`, then the first trading day
of every later month.

### Arguments
- `md::MyMarketData`: the market data.
- `rows::UnitRange{Int}`: the run's rows.

### Returns
- `Vector{Int}`: the rebalance rows, in order.

### Example
```julia
rebalance = bab_rebalance_rows(ctx.md, ctx.rows);
```
"""
function bab_rebalance_rows(md::MyMarketData, rows::UnitRange{Int})::Vector{Int}
    out = Int[];
    push!(out, first(rows));
    for t in (first(rows) + 1):last(rows)
        if month(md.dates[t]) != month(md.dates[t - 1])
            push!(out, t);
        end
    end
    return out;
end

"""
    run_bab(ctx::MyStudyContext; shrink::Float64=0.6, min_beta::Float64=0.1, vol_window::Int=252,
        corr_window::Int=1260, W0::Float64=ctx.settings.W0, half_spread_bps::Float64=ctx.settings.half_spread_bps,
        κ::Float64=ctx.settings.impact_kappa, borrow_rate::Float64=ctx.settings.borrow_rate)::NamedTuple

Betting against beta (Frazzini and Pedersen, 2014) on every stock of the context's market, on the run's days.

At the close of each rebalance day (`bab_rebalance_rows`: the first run day and the first trading day of each
month), the strategy:
1. estimates each stock's β as the paper does (`bab_betas`: one-year volatilities and a five-year correlation of
   3-day returns), and shrinks it toward `1`: β̃ᵢ = `shrink`·β̂ᵢ + (1 − `shrink`);
2. builds the low-β and high-β rank portfolios (`bab_weights`), with betas β_L and β_H (each at least `min_beta`);
3. sets the target book: W/β_L dollars long in the low-β portfolio and W/β_H dollars short in the high-β
   portfolio, with W the equity. The book's β is then 1 − 1 = 0, and its cash is W − W/β_L + W/β_H.

The orders fill at the next day's open, with `trade_cost` (half spread and impact). Cash earns the risk-free rate
when positive and pays it when negative (the long side borrows at the bill rate, as in the paper). Shorts pay the
borrow fee each day. Equity is marked at each close. A book whose equity falls to zero or below is closed: its
equity stays at `1e-6` USD from that day on, and `ruined` is `true`.

### Arguments
- `ctx::MyStudyContext`: the study context (market data and run rows).
- `shrink::Float64`: the weight on β̂ᵢ in β̃ᵢ (dimensionless, 0.6 in the paper).
- `min_beta::Float64`: the smallest β_L and β_H used to size the book (dimensionless).
- `vol_window::Int`, `corr_window::Int`: the windows of `bab_betas` (trading days).
- `W0::Float64`: the starting equity (USD).
- `half_spread_bps::Float64`, `κ::Float64`: the trading-cost settings (`trade_cost`).
- `borrow_rate::Float64`: the borrow fee on shorts (yr⁻¹).

### Returns
- `NamedTuple`: `dates`, `equity` (USD), `cash` (USD), `borrow_fees` (USD per day), `gross` (long plus short
  value over equity at each close, dimensionless), `rebalances` (a `DataFrame` with one row per rebalance:
  `date`, `beta_low`, `beta_high`, `long_value`, `short_value` in USD, and `cost` in USD), `turnover` (traded
  value over mean equity per year, yr⁻¹), `total_cost` (USD) and `ruined` (`Bool`).

### Example
```julia
bab = run_bab(ctx);
```
"""
function run_bab(ctx::MyStudyContext; shrink::Float64=0.6, min_beta::Float64=0.1, vol_window::Int=252,
        corr_window::Int=1260, W0::Float64=ctx.settings.W0, half_spread_bps::Float64=ctx.settings.half_spread_bps,
        κ::Float64=ctx.settings.impact_kappa, borrow_rate::Float64=ctx.settings.borrow_rate)::NamedTuple

    # initialize -
    md = ctx.md;
    rows = ctx.rows;
    i0 = first(rows);
    nd = length(rows);
    N = length(md.tickers);
    Δt = 1 / 252;
    rebalance = Set(bab_rebalance_rows(md, rows));
    held = zeros(Float64, N); # shares, negative for a short
    target = zeros(Float64, N); # the shares the last rebalance asked for
    pending = false; # true when orders wait for the next open
    cash = W0;
    ruined = false;
    equity = zeros(Float64, nd);
    cash_path = zeros(Float64, nd);
    fees = zeros(Float64, nd);
    gross = zeros(Float64, nd);
    traded = 0.0; # traded value (USD)
    total_cost = 0.0; # trading costs (USD)
    reb = DataFrame(date=Date[], beta_low=Float64[], beta_high=Float64[], long_value=Float64[],
        short_value=Float64[], cost=Float64[]);

    for t in rows
        s = t - i0 + 1;

        # 1. fill the pending orders at the open -
        if pending == true && ruined == false
            day_cost = 0.0;
            for j in 1:N
                q = target[j] - held[j];
                if q != 0.0
                    price = md.open[t, j];
                    c = trade_cost(q, price, _bt_adv(md, t - 1, j); half_spread_bps=half_spread_bps, κ=κ);
                    cash = cash - q * price - c;
                    held[j] = target[j];
                    traded = traded + abs(q * price);
                    day_cost = day_cost + c;
                end
            end
            total_cost = total_cost + day_cost;
            reb.cost[end] = day_cost;
            pending = false;
        end

        # 2. cash earns or pays the risk-free rate, and shorts pay the borrow fee -
        if t > i0 && ruined == false
            cash = cash * exp(md.g_f[t] * Δt);
            short = 0.0;
            for j in 1:N
                if held[j] < 0
                    short = short - held[j] * md.close[t, j];
                end
            end
            if short > 0
                fees[s] = borrow_fee(short; rate=borrow_rate, Δt=Δt);
                cash = cash - fees[s];
            end
        end

        # 3. mark the book at the close -
        long_value = 0.0;
        short_value = 0.0;
        for j in 1:N
            if held[j] > 0
                long_value = long_value + held[j] * md.close[t, j];
            elseif held[j] < 0
                short_value = short_value - held[j] * md.close[t, j];
            end
        end
        V = cash + long_value - short_value;
        if ruined == false && V <= 0
            # the book is closed: no positions, and the equity stays at a token value
            ruined = true;
            for j in 1:N
                held[j] = 0.0;
            end
            pending = false;
        end
        if ruined == true
            equity[s] = 1e-6;
            cash_path[s] = 1e-6;
            gross[s] = 0.0;
            continue;
        end
        equity[s] = V;
        cash_path[s] = cash;
        gross[s] = (long_value + short_value) / V;

        # 4. rebalance at the close of a rebalance day (the orders fill at the next open) -
        if (t in rebalance) && t < last(rows)
            β̂ = bab_betas(md, t; vol_window=vol_window, corr_window=corr_window);
            β̃ = zeros(Float64, N);
            for j in 1:N
                β̃[j] = shrink * β̂[j] + (1 - shrink);
            end
            w = bab_weights(β̃);
            β_L = max(sum(w.w_low .* β̃), min_beta);
            β_H = max(sum(w.w_high .* β̃), min_beta);
            long_target = V / β_L; # USD in the low-β portfolio
            short_target = V / β_H; # USD short in the high-β portfolio
            for j in 1:N
                target[j] = (long_target * w.w_low[j] - short_target * w.w_high[j]) / md.close[t, j];
            end
            pending = true;
            push!(reb, (md.dates[t], β_L, β_H, long_target, short_target, 0.0));
        end
    end

    # turnover: traded value over mean equity, per year -
    years = (nd - 1) / 252;
    turnover = NaN;
    if years > 0
        turnover = traded / mean(equity) / years;
    end

    return (dates=md.dates[rows], equity=equity, cash=cash_path, borrow_fees=fees, gross=gross, rebalances=reb,
        turnover=turnover, total_cost=total_cost, ruined=ruined);
end

"""
    buy_and_hold_equity(md::MyMarketData, rows::UnitRange{Int}; W0::Float64=100_000.0)::NamedTuple

The equity of the two buy-and-hold references on the run's rows: `W0` USD in `SPY` at the first close, and `W0/N`
USD in each of the N stocks at the first close (no rebalancing).

### Arguments
- `md::MyMarketData`: the market data.
- `rows::UnitRange{Int}`: the run's rows.
- `W0::Float64`: the starting equity (USD).

### Returns
- `NamedTuple`: `spy` and `equal_weight`, the equity on each row (USD).

### Example
```julia
passive = buy_and_hold_equity(ctx.md, ctx.rows);
```
"""
function buy_and_hold_equity(md::MyMarketData, rows::UnitRange{Int}; W0::Float64=100_000.0)::NamedTuple
    i0 = first(rows);
    N = length(md.tickers);
    nd = length(rows);
    spy = zeros(Float64, nd);
    equal_weight = zeros(Float64, nd);
    for k in 1:nd
        t = i0 + k - 1;
        spy[k] = W0 * md.spy_close[t] / md.spy_close[i0];
        value = 0.0;
        for j in 1:N
            value = value + (W0 / N) * md.close[t, j] / md.close[i0, j];
        end
        equal_weight[k] = value;
    end
    return (spy=spy, equal_weight=equal_weight);
end
