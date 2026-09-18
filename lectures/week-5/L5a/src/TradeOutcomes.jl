"""
    eligible_gbm_data(original, parameters; reference_ticker="AAPL")

Match saved training parameters to complete, aligned testing histories.
`original` maps ticker strings to DataFrames with `timestamp` and positive
`volume_weighted_average_price` (USD/share). `parameters` contains unique
`ticker`, legacy `drift` (mean growth, year⁻¹), and `volatility` (year⁻¹ᐟ²).
Return `(dataset, tickers, dates, exclusions)` with sorted tickers and an explicit
exclusion-reason table. Dates must equal the sorted unique reference grid.
Eligibility uses full testing-history availability, not an ex-ante stock universe.
"""
function eligible_gbm_data(original, parameters; reference_ticker="AAPL")
    length(unique(parameters.ticker)) == nrow(parameters) || throw(ArgumentError("duplicate parameter tickers"))
    dates = original[reference_ticker].timestamp;
    issorted(dates) && allunique(dates) || throw(ArgumentError("reference dates must be sorted and unique"))
    rows = Dict(String(row.ticker) => row for row in eachrow(parameters));
    dataset = Dict{String,DataFrame}();
    exclusions = DataFrame(ticker=String[], reason=String[]);
    for ticker in sort!(collect(union(Set(String.(keys(original))), Set(keys(rows)))))
        reason = if !haskey(original, ticker)
            "No testing history"
        elseif !haskey(rows, ticker)
            "No training estimate"
        elseif original[ticker].timestamp != dates
            "Incomplete or unaligned testing dates"
        elseif !all(x -> !ismissing(x) && isfinite(x) && x > 0,
            original[ticker].volume_weighted_average_price)
            "Invalid testing price"
        elseif !(isfinite(rows[ticker].drift) && isfinite(rows[ticker].volatility) && rows[ticker].volatility >= 0)
            "Invalid training estimate"
        else
            ""
        end
        if isempty(reason)
            dataset[ticker] = original[ticker];
        else
            push!(exclusions, (ticker, reason));
        end
    end
    return (; dataset, tickers=sort!(collect(keys(dataset))), dates=copy(dates), exclusions)
end

"""
    gbm_trade_forecast(current_price, entry_price, mu_g, sigma;
        horizon, total_time, benchmark=0.05, target=0.0)

Return `(probability, threshold, median_price, lower, upper)` for a prospective
sale. Prices are USD/share; `horizon` is years forward from the current price,
whereas `total_time` is years from the original purchase to sale. Mean growth and
benchmark are year⁻¹, volatility year⁻¹ᐟ², and `target > -1` is dimensionless
scaled NPV. Parameters stay fixed over this forecast's horizon. The strict
event is discounted sale price / entry price - 1 > target. Bounds are pointwise
95% price quantiles. Zero horizon or volatility gives a deterministic event.
"""
function gbm_trade_forecast(current_price, entry_price, mu_g, sigma;
    horizon, total_time, benchmark=0.05, target=0.0)

    all(isfinite, (current_price, entry_price, mu_g, sigma, horizon, total_time, benchmark, target)) ||
        throw(ArgumentError("forecast inputs must be finite"))
    current_price > 0 && entry_price > 0 || throw(ArgumentError("prices must be positive"))
    sigma >= 0 && horizon >= 0 && total_time >= horizon || throw(ArgumentError("invalid volatility or time intervals"))
    target > -1 || throw(ArgumentError("scaled NPV target must exceed -1"))
    log_threshold = log(entry_price) + log1p(target) + benchmark*total_time;
    log_median = log(current_price) + mu_g*horizon;
    spread = sigma * sqrt(horizon);
    probability = spread == 0 ? Float64(log_median > log_threshold) :
        ccdf(Normal(), (log_threshold-log_median)/spread);
    z = quantile(Normal(), 0.975);
    return (; probability, threshold=exp(log_threshold), median_price=exp(log_median),
        lower=exp(log_median-z*spread), upper=exp(log_median+z*spread))
end

"""
    rolling_trade_forecasts(prices, dates, mu_g, sigma; ticker="", start_index=1,
        holding_days=21, dt=1/252, half_life=21, benchmark=0.05, target=0.0)

Issue daily forecasts from `start_index` through `length(prices)-holding_days`.
At row k, forecast sale at k+holding_days while retaining the purchase price at
start_index. `dates` supplies aligned observation labels; all other units match
`ema_gbm_parameters` and `gbm_trade_forecast`. Integer holding_days must be >=1.
Return a DataFrame for Frozen, EMA volatility, and EMA mean + volatility, with
origin/sale dates, parameters, threshold, probability and bounds for the growth
rate over the forecast window (year⁻¹). Forecast generation does not read a future sale price. Both
EMA methods use the same centered variance state. Outcomes are attached later by
`score_trade_forecasts`; overlapping windows represent alternative sale dates
for one original position.
"""
function rolling_trade_forecasts(prices, dates, mu_g, sigma; ticker="", start_index=1,
    holding_days=21, dt=1/252, half_life=21, benchmark=0.05, target=0.0)

    length(prices) == length(dates) || throw(ArgumentError("prices and dates must align"))
    issorted(dates) && allunique(dates) || throw(ArgumentError("dates must be sorted and unique"))
    holding_days isa Integer && holding_days >= 1 || throw(ArgumentError("holding_days must be a positive integer"))
    start_index isa Integer && start_index >= 1 && start_index+holding_days <= length(prices) ||
        throw(ArgumentError("entry and full holding window must lie in the data"))
    states = ema_gbm_parameters(prices, mu_g, sigma; start_index, dt, half_life);
    result = DataFrame(ticker=String[], method=String[], entry_index=Int[], origin_index=Int[], sale_index=Int[],
        entry_date=eltype(dates)[], origin_date=eltype(dates)[], sale_date=eltype(dates)[],
        entry_price=Float64[], current_price=Float64[], horizon=Float64[], total_time=Float64[],
        benchmark=Float64[], target=Float64[], mu_g=Float64[], sigma=Float64[],
        threshold=Float64[], probability=Float64[], growth_lower=Float64[], growth_upper=Float64[]);
    h = holding_days * dt;
    z = quantile(Normal(), 0.975);
    for k in start_index:(length(prices)-holding_days)
        state = states[k-start_index+1, :];
        total_time = (k+holding_days-start_index)*dt; # discount from sale all the way back to purchase
        choices = (("Frozen", mu_g, sigma), ("EMA volatility", mu_g, state.sigma),
            ("EMA mean + volatility", state.mu_g, state.sigma));
        for (method, growth, volatility) in choices
            f = gbm_trade_forecast(prices[k], prices[start_index], growth, volatility;
                horizon=h, total_time, benchmark, target);
            push!(result, (String(ticker), method, start_index, k, k+holding_days,
                dates[start_index], dates[k], dates[k+holding_days], prices[start_index], prices[k],
                h, total_time, benchmark, target, growth, volatility, f.threshold, f.probability,
                growth-z*volatility/sqrt(h), growth+z*volatility/sqrt(h)));
        end
    end
    return result
end

"""
    interval_score(lower, upper, observed; alpha=0.05)

Return the proper interval score: width plus 2/alpha times the distance outside
the interval. Bounds and observation share units; the EMA example uses growth
rates (year⁻¹) over the same forecast window for comparisons across tickers. `1-alpha` is the nominal interval probability.
"""
function interval_score(lower, upper, observed; alpha=0.05)
    0 < alpha < 1 && lower <= upper && all(isfinite, (lower, upper, observed)) ||
        throw(ArgumentError("invalid interval or alpha"))
    return upper-lower + (2/alpha)*(max(lower-observed, 0) + max(observed-upper, 0))
end

"""
    score_trade_forecasts(forecasts, prices)

Return a copy of the saved forecast table with observed sale_price (USD/share),
scaled_npv, strict target_met, brier_loss, and 95% interval diagnostics attached.
`prices` is the complete observed series used for this ticker. Brier loss is
(probability-target_met)^2. Interval width and score use growth rates
(year⁻¹) over the forecast window, so ticker price scales do not affect them. Outcomes become
available only on each sale date; they never feed the earlier parameter update.
"""
function score_trade_forecasts(forecasts, prices)
    all(x -> isfinite(x) && x > 0, prices) || throw(ArgumentError("prices must be finite and positive"))
    all(i -> 1 <= i <= length(prices), forecasts.sale_index) || throw(ArgumentError("unobserved sale date"))
    result = copy(forecasts);
    result.sale_price = Float64.(prices[result.sale_index]);
    result.scaled_npv = expm1.(log.(result.sale_price ./ result.entry_price) .- result.benchmark .* result.total_time);
    result.target_met = result.scaled_npv .> result.target;
    result.brier_loss = (result.probability .- result.target_met).^2;
    observed_growth = log.(result.sale_price ./ result.current_price) ./ result.horizon; # year⁻¹
    result.covered_95 = (result.growth_lower .<= observed_growth) .& (observed_growth .<= result.growth_upper);
    result.interval_width = result.growth_upper .- result.growth_lower; # year⁻¹
    result.interval_score = interval_score.(result.growth_lower, result.growth_upper, observed_growth);
    return result
end
