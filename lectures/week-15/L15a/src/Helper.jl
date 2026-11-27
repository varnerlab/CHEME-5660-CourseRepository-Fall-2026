# Helper.jl: helpers for the L15a examples (the pick days, the preference basket, the 60/40 benchmark, and the five
# gates of the stress test). Loaded by Include.jl.

"""
    pick_days(ξ::Vector{Float64}; repick_interval::Int)::NamedTuple

The days on which we pick a new preference basket, and the reason for each pick. The first day is always a pick day.
After that, we pick again on a day when one of two things happens:

- __Scheduled:__ `repick_interval` trading days have passed since the last pick.
- __Market turn:__ the market state is on the other side of zero from its value on the last pick day. A falling
  market has ξ > 0, and a rising market has ξ ≤ 0, so a market state of exactly zero counts as rising.

When both happen on the same day, the pick counts as a market turn.

### Arguments
- `ξ::Vector{Float64}`: the market state on each trading day of the run, in order (dimensionless).
- `repick_interval::Int`: the trading days between scheduled picks.

### Returns
- `NamedTuple` with two fields:
  - `day::Vector{Int}`: the positions in `ξ` of the pick days, in increasing order. The first entry is `1`.
  - `reason::Vector{String}`: the reason for each pick: `"first"`, `"scheduled"` or `"market turn"`.

Throws `ArgumentError` when `ξ` is empty or `repick_interval < 1`.

### Example
```julia
picks = pick_days(ξ_run; repick_interval = 21);
picks.day[2] # the position of the second pick day in ξ_run
```
"""
function pick_days(ξ::Vector{Float64}; repick_interval::Int)::NamedTuple

    # check the inputs -
    if length(ξ) == 0
        throw(ArgumentError("the market state ξ needs at least one day"));
    end
    if repick_interval < 1
        throw(ArgumentError("repick_interval must be at least 1 trading day"));
    end

    # initialize: the first day is always a pick day -
    day = Int[]; # positions of the pick days in ξ
    reason = String[]; # the reason for each pick
    push!(day, 1);
    push!(reason, "first");
    last_pick = 1; # position of the last pick day
    falling_at_last_pick = ξ[1] > 0; # true when the market was falling on the last pick day

    # walk through the remaining days, and pick when the schedule or the market state says so -
    for k ∈ 2:length(ξ)
        days_since_last_pick = k - last_pick; # trading days since the last pick
        falling_now = ξ[k] > 0; # true when the market is falling today
        if falling_now != falling_at_last_pick
            push!(day, k);
            push!(reason, "market turn"); # the market turned from rising to falling, or from falling to rising
            last_pick = k;
            falling_at_last_pick = falling_now;
        elseif days_since_last_pick >= repick_interval
            push!(day, k);
            push!(reason, "scheduled");
            last_pick = k;
            falling_at_last_pick = falling_now;
        end
    end

    # checks -
    @assert day[1] == 1 "the first day must be a pick day"
    @assert length(day) == length(reason) "one reason per pick day"
    @assert issorted(day) "the pick days must be in increasing order"

    # return -
    return (day = day, reason = reason);
end

"""
    gamma_basket(γ::Vector{Float64}, sector::Vector{String}; N::Int)::Vector{Int}

The preference basket of one pick day: the `N` stocks with the highest γ score in each sector. A sector with `N` stocks
or fewer gives all of its stocks. When two stocks in a sector have the same score, the one that comes first in
`γ` goes first. The sign of the score does not matter here: the basket holds the `N` highest scores, even if
some of them are negative.

### Arguments
- `γ::Vector{Float64}`: the γ score of each stock on the pick day (dimensionless, between `-1` and `1`).
- `sector::Vector{String}`: the GICS sector of each stock, in the same order as `γ`.
- `N::Int`: the number of stocks to pick in each sector.

### Returns
- `Vector{Int}`: the positions in `γ` of the picked stocks, in increasing order.

Throws `ArgumentError` when `γ` and `sector` have different lengths or `N < 1`.

### Example
```julia
basket = gamma_basket(γ_updated[1, :], md.sector; N = 3);
md.tickers[basket] # the tickers of the picked stocks
```
"""
function gamma_basket(γ::Vector{Float64}, sector::Vector{String}; N::Int)::Vector{Int}

    # check the inputs -
    if length(γ) != length(sector)
        throw(ArgumentError("γ and sector must have one entry per stock"));
    end
    if N < 1
        throw(ArgumentError("N must be at least 1"));
    end

    # initialize: the sectors, each listed once, in alphabetical order -
    sector_names = sort(unique(sector));
    basket = Int[]; # positions of the picked stocks

    # pick the N highest scores in each sector -
    for s ∈ sector_names
        members = findall(sector .== s); # positions of the stocks in sector s
        scores = γ[members]; # their γ scores
        order = sortperm(scores; rev = true); # highest score first; ties keep the order of γ
        number_to_pick = min(N, length(members)); # a small sector gives all of its stocks
        for k ∈ 1:number_to_pick
            push!(basket, members[order[k]]);
        end
    end
    sort!(basket); # increasing order, as the positions in γ

    # checks -
    @assert length(unique(basket)) == length(basket) "each stock can be picked once"

    # return -
    return basket;
end

"""
    sixty_forty_wealth(spy::Vector{Float64}, tlt::Vector{Float64}, dates::Vector{Date}; W0::Float64,
        half_spread::Float64)::Vector{Float64}

The wealth of the practicum's 60/40 benchmark at each close: 60% of the wealth in SPY and 40% in TLT. The mix starts
with `W0` in cash and buys at the first close. It trades back to its weights at the close of the first trading day of
each month. Each trade pays the half-spread on its value, so the wealth after the trades is
`W′ = W − half_spread × Σ |target − value|`, where the target of a ticker is its share of `W′`.

### Arguments
- `spy::Vector{Float64}`: the closing price of SPY on each day of `dates` (USD/share).
- `tlt::Vector{Float64}`: the closing price of TLT on each day of `dates` (USD/share).
- `dates::Vector{Date}`: the trading days, oldest first.
- `W0::Float64`: the starting wealth (USD).
- `half_spread::Float64`: the half bid-ask spread, as a fraction of the value of each trade.

### Returns
- `Vector{Float64}`: the wealth of the mix at each close (USD).

Throws `ArgumentError` when `spy`, `tlt`, and `dates` have different lengths.

### Example
```julia
W_6040 = sixty_forty_wealth(spy_closes[:, 1], tlt_closes[:, 1], synthetic_dates; W0 = 100000.0, half_spread = 0.0005);
W_6040[end] # the wealth of the mix on the last day of synthetic market 1 (USD)
```
"""
function sixty_forty_wealth(spy::Vector{Float64}, tlt::Vector{Float64}, dates::Vector{Date}; W0::Float64,
        half_spread::Float64)::Vector{Float64}

    # check the inputs -
    number_of_days = length(dates);
    if length(spy) != number_of_days || length(tlt) != number_of_days
        throw(ArgumentError("spy, tlt, and dates must have one entry per trading day"));
    end

    # initialize: the weights, the shares of SPY and TLT, and the cash (USD) -
    weights = [0.6, 0.4]; # the share of the wealth in SPY and in TLT
    shares = [0.0, 0.0]; # the shares of SPY and of TLT that the mix holds
    cash = W0;
    wealth = zeros(number_of_days);

    for t ∈ 1:number_of_days
        prices = [spy[t], tlt[t]]; # today's closes (USD/share)

        # the value of each holding at today's close, and the wealth (USD) -
        values = [shares[1] * prices[1], shares[2] * prices[2]];
        W = cash + values[1] + values[2];

        # the mix trades on the first day and on the first trading day of each month -
        rebalance = false;
        if t == 1
            rebalance = true;
        elseif month(dates[t]) != month(dates[t - 1])
            rebalance = true;
        end

        if rebalance == true
            # the wealth after the half-spread of every trade. The cost depends on the wealth after the trades, so
            # each pass uses the wealth of the pass before -
            W_after = W;
            for pass ∈ 1:10
                cost = 0.0;
                for j ∈ 1:2
                    cost = cost + half_spread * abs(weights[j] * W_after - values[j]);
                end
                W_after = W - cost;
            end

            # buy the target of each ticker, which leaves no cash -
            for j ∈ 1:2
                shares[j] = weights[j] * W_after / prices[j];
            end
            cash = 0.0;
        end

        # the wealth at today's close (USD) -
        wealth[t] = cash + shares[1] * prices[1] + shares[2] * prices[2];
    end

    # checks -
    @assert all(isfinite, wealth) "the wealth must be a number on every day"

    # return -
    return wealth;
end

"""
    five_gates(runs::DataFrame, comparison::Vector{Float64}; W0::Float64, sharpe_limit::Float64,
        drawdown_limit::Float64, failure_limit::Float64)::DataFrame

Test a strategy with the five gates of the stress test, as the practicum does. A gate passes at its limit.

1. __Median Sharpe ratio:__ at least `sharpe_limit`. A `NaN` Sharpe ratio counts as the lowest one.
2. __Median largest drawdown:__ at most `drawdown_limit`.
3. __Failure rate:__ the share of markets on which the wealth ends below `W0`, at most `failure_limit`.
4. __Median wealth on the last day:__ at least the median of `comparison`.
5. __Median NPV:__ at least `0`.

### Arguments
- `runs::DataFrame`: one row per synthetic market, with the strategy's `sharpe` (dimensionless), `max_drawdown`
  (fraction of the peak wealth), `terminal` (the wealth on the last day, USD), and `npv` (USD).
- `comparison::Vector{Float64}`: the comparison's wealth on the last day of each market (USD), in the order of `runs`.
- `W0::Float64`: the starting wealth (USD).
- `sharpe_limit::Float64`, `drawdown_limit::Float64`, `failure_limit::Float64`: the limits of the first three gates.

### Returns
- `DataFrame`: one row per gate, with the columns `gate`, `value`, `limit`, and `passed`.

Throws `ArgumentError` when `runs` is empty or `comparison` does not have one entry per row of `runs`.

### Example
```julia
gates = five_gates(our_runs, W_6040_last; W0 = 100000.0, sharpe_limit = 0.3, drawdown_limit = 0.25, failure_limit = 0.10);
all(gates.passed) # true when the strategy passes every gate
```
"""
function five_gates(runs::DataFrame, comparison::Vector{Float64}; W0::Float64, sharpe_limit::Float64,
        drawdown_limit::Float64, failure_limit::Float64)::DataFrame

    # check the inputs -
    number_of_markets = nrow(runs);
    if number_of_markets == 0
        throw(ArgumentError("runs must have one row per synthetic market"));
    end
    if length(comparison) != number_of_markets
        throw(ArgumentError("comparison must have one entry per row of runs"));
    end

    # gate 1: the median Sharpe ratio. A NaN Sharpe ratio counts as the lowest one -
    sharpe = zeros(number_of_markets);
    for k ∈ 1:number_of_markets
        sharpe[k] = runs.sharpe[k];
        if isnan(sharpe[k]) == true
            sharpe[k] = -Inf;
        end
    end
    median_sharpe = median(sharpe);

    # gate 2: the median of the largest drawdowns (fraction of the peak wealth) -
    median_drawdown = median(runs.max_drawdown);

    # gate 3: the share of markets on which the wealth ends below W0 -
    failures = 0;
    for k ∈ 1:number_of_markets
        if runs.terminal[k] < W0
            failures = failures + 1;
        end
    end
    failure_rate = failures / number_of_markets;

    # gate 4: the median wealth on the last day, and that of the comparison (USD) -
    median_terminal = median(runs.terminal);
    comparison_median = median(comparison);

    # gate 5: the median NPV (USD) -
    median_npv = median(runs.npv);

    # the table of the five gates -
    gates = DataFrame(gate = String[], value = Float64[], limit = Float64[], passed = Bool[]);
    push!(gates, ("median Sharpe ratio", median_sharpe, sharpe_limit, median_sharpe >= sharpe_limit));
    push!(gates, ("median largest drawdown", median_drawdown, drawdown_limit, median_drawdown <= drawdown_limit));
    push!(gates, ("failure rate", failure_rate, failure_limit, failure_rate <= failure_limit));
    push!(gates, ("median wealth on the last day (USD)", median_terminal, comparison_median,
        median_terminal >= comparison_median));
    push!(gates, ("median NPV (USD)", median_npv, 0.0, median_npv >= 0.0));

    # return -
    return gates;
end

"""
    tail_losses(terminal::Vector{Float64}; W0::Float64, level::Float64)::NamedTuple

The value at risk (VaR) and the conditional value at risk (CVaR) of a strategy's loss over the synthetic markets.
The loss on market `p` is `W0 - terminal[p]`, so a negative loss is a gain.

- __VaR:__ the `level` quantile of the losses. Only a share `1 - level` of the markets lose more.
- __CVaR:__ the average loss on the markets whose loss is at least the VaR.

### Arguments
- `terminal::Vector{Float64}`: the strategy's wealth on the last day of each market (USD).
- `W0::Float64`: the starting wealth (USD).
- `level::Float64`: the level of both numbers, between `0` and `1`, for example `0.95`.

### Returns
- `NamedTuple`: the `VaR` and the `CVaR` of the loss (USD).

Throws `ArgumentError` when `terminal` is empty or `level` is not between `0` and `1`.

### Example
```julia
tail = tail_losses(our_runs.terminal; W0 = 100000.0, level = 0.95);
tail.CVaR # the average loss on the worst 5% of the markets (USD)
```
"""
function tail_losses(terminal::Vector{Float64}; W0::Float64, level::Float64)::NamedTuple

    # check the inputs -
    number_of_markets = length(terminal);
    if number_of_markets == 0
        throw(ArgumentError("terminal must have one entry per synthetic market"));
    end
    if level <= 0.0 || level >= 1.0
        throw(ArgumentError("level must be between 0 and 1"));
    end

    # the loss on each market: the starting wealth minus the wealth on the last day (USD) -
    losses = zeros(number_of_markets);
    for p ∈ 1:number_of_markets
        losses[p] = W0 - terminal[p];
    end

    # the VaR: the level quantile of the losses (USD) -
    VaR = quantile(losses, level);

    # the CVaR: the average loss on the markets whose loss is at least the VaR (USD) -
    total_loss = 0.0;
    number_in_tail = 0;
    for p ∈ 1:number_of_markets
        if losses[p] >= VaR
            total_loss = total_loss + losses[p];
            number_in_tail = number_in_tail + 1;
        end
    end
    CVaR = total_loss / number_in_tail;

    # return -
    return (VaR = VaR, CVaR = CVaR);
end

"""
    find_runs(stress_runs::DataFrame; picking::String, weighting::String, hedge::Bool, estimates::String,
        seed::Int)::DataFrame

The saved stress-test runs of one strategy, one row for each synthetic market, in the order of the markets.

### Arguments
- `stress_runs::DataFrame`: the saved runs, one row for each strategy and market, with the columns `picking`,
  `weighting`, `hedge`, `estimates`, `seed`, and `path_id` (the market's number).
- `picking::String`: the name of the picking rule on the menu.
- `weighting::String`: the name of the weighting rule on the menu.
- `hedge::Bool`: `true` for the runs with the market hedge on, and `false` for the runs without it.
- `estimates::String`: `"fixed"`, `"updated"`, or `"sector_factor"`.
- `seed::Int`: the seed of the strategy's random draws.

### Returns
- `DataFrame`: the rows of the strategy, sorted by `path_id`. It has no rows when the strategy was not saved, for
  example with a seed the stress test did not run.

### Example
```julia
our_runs = find_runs(stress_runs; picking = "gamma by sector", weighting = "Cobb-Douglas", hedge = false,
    estimates = "fixed", seed = 5660);
our_runs.terminal # the wealth on the last day of each market (USD)
```
"""
function find_runs(stress_runs::DataFrame; picking::String, weighting::String, hedge::Bool, estimates::String,
        seed::Int)::DataFrame

    # initialize -
    runs = DataFrame();

    # keep the rows of our strategy -
    for i ∈ 1:nrow(stress_runs)
        if stress_runs.picking[i] == picking && stress_runs.weighting[i] == weighting &&
                stress_runs.hedge[i] == hedge && stress_runs.estimates[i] == estimates && stress_runs.seed[i] == seed
            push!(runs, stress_runs[i, :]);
        end
    end

    # sort the rows in the order of the markets -
    if nrow(runs) > 0
        sort!(runs, :path_id);
    end

    # return -
    return runs;
end
