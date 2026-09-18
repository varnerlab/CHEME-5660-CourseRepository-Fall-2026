# Adaptive GBM and trade-outcome functions

The [EMA parameter-updating example](../CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb)
loads these helpers through [Include.jl](../Include.jl). Full argument, unit,
return-value, and assumption descriptions are in each Julia docstring.

| Function | Source and purpose |
| --- | --- |
| `eligible_gbm_data` | [TradeOutcomes.jl](../src/TradeOutcomes.jl): match training estimates to complete aligned testing histories, returning eligible tickers and explicit exclusions |
| `ema_gbm_parameters` | [AdaptiveGBM.jl](../src/AdaptiveGBM.jl): initialize growth-rate moments from training estimates, then update using observed growth rates after the selected entry |
| `gbm_trade_forecast` | [TradeOutcomes.jl](../src/TradeOutcomes.jl): compute a strict target probability, sale threshold, median, and pointwise 95% price bounds |
| `rolling_trade_forecasts` | [TradeOutcomes.jl](../src/TradeOutcomes.jl): issue the three methods' forecasts with a common purchase, origin, and prospective sale |
| `score_trade_forecasts` | [TradeOutcomes.jl](../src/TradeOutcomes.jl): attach later outcomes and scores to saved forecasts |
| `interval_score` | [TradeOutcomes.jl](../src/TradeOutcomes.jl): quantify interval width and missed observations |

## eligible_gbm_data

`eligible_gbm_data(original, parameters; reference_ticker="AAPL")` matches the
testing-data dictionary to the saved parameter table. Prices must be positive
USD/share observations on the reference ticker's sorted, unique date grid.
The legacy `drift` column stores annual mean growth; `volatility` stores annual
volatility. The returned named tuple contains `dataset`, sorted `tickers`,
`dates`, and an `exclusions` table with a reason for each excluded ticker.

## ema_gbm_parameters

`ema_gbm_parameters(prices, mu_g, sigma; start_index=1, dt=1/252,
half_life=21, decay=2.0^(-1/half_life))` starts from the training mean growth
and volatility at the selected entry row. Prices are USD/share, `dt` is years
per observation, and `half_life` is trading observations. The returned DataFrame
contains `index`, `mu_g` (mean growth, year⁻¹), `variance_growth` (year⁻²),
`sigma` (GBM volatility, year⁻¹ᐟ²), and `mu` (arithmetic drift, year⁻¹).
The observed quantity is `g_k=log(S_k/S_(k-1))/dt`. Initialize the mean at
`mu_g` and the growth-rate variance at `sigma^2/dt`, then recover volatility
as `sqrt(variance_growth*dt)`. Only growth rates observed after entry update
the states; `decay=1` retains the initial estimates.

## gbm_trade_forecast

`gbm_trade_forecast(current_price, entry_price, mu_g, sigma; horizon,
total_time, benchmark=0.05, target=0.0)` calculates the probability of strictly
exceeding a scaled-NPV target. `horizon` is years from the current observation to
sale; `total_time` is years from the original purchase to sale. Prices are
USD/share, mean growth and benchmark are inverse years, volatility is inverse
square-root years, and `target > -1` is dimensionless. The returned named tuple
contains `probability`, target sale-price `threshold`, `median_price`, and
pointwise 95% price limits `lower` and `upper`.

## rolling_trade_forecasts

`rolling_trade_forecasts(prices, dates, mu_g, sigma; ticker="", start_index=1,
holding_days=21, dt=1/252, half_life=21, benchmark=0.05, target=0.0)` records
forecasts at each origin with a complete forward window. Dates must be sorted,
unique, and aligned with prices; `holding_days` counts future trading intervals.
Other units match the helpers above. The returned DataFrame has one row per
origin and method, with entry/origin/sale dates, parameter estimates, probability,
target price, and growth-rate interval bounds `growth_lower` and `growth_upper`
(year⁻¹) over the forward window. It does not attach sale outcomes.

## score_trade_forecasts

`score_trade_forecasts(forecasts, prices)` copies a forecast DataFrame and adds
the observed sale price, scaled NPV, strict target indicator, Brier loss, 95%
coverage, growth-rate interval width, and interval score (both year⁻¹). `prices` must be the same
USD/share series used to index the forecasts. Outcomes become available at the
recorded sale row; the saved forecast parameters and probabilities are preserved.

## interval_score

`interval_score(lower, upper, observed; alpha=0.05)` returns interval width plus
the miss penalty defined below. Bounds and observations use the same units
(growth rates in year⁻¹ in this example), and `alpha` is the probability
outside the central interval. The result has the same units as the bounds.

## Timing and units

Prices are USD/share. Mean growth and benchmark growth are inverse years;
volatility is inverse square-root years. The observed growth rate is
`log(S_k/S_(k-1))/dt`, in inverse years; its variance is in inverse years squared.
Scaled NPV is dimensionless. At origin row `k`, entry row `s`, and forward window `H`, the sale
row is `k+H`. Forecast uncertainty spans `H*dt` years, while discounting spans
`(k+H-s)*dt` years. The purchase price remains `prices[s]`.

The first forecast uses the training baseline. The first EMA update uses the
growth rate observed from `s` to `s+1`. Parameters at each origin stay fixed over that
origin's forecast window. Both updating methods use the same centered variance;
the volatility-only method retains the training mean growth in its forecast.

Zero volatility or a zero forward duration gives a deterministic target event.
The rolling wrapper requires at least one future interval and a complete observed
window. Equality with the NPV target is a failure to exceed it. No horizon is
silently shortened at the end of the dataset.

## Supporting interval diagnostics

The main example compares NPV probabilities with Brier loss `(p-y)^2`, where
`y` is one when the observed scaled NPV strictly exceeds the target and zero
otherwise. Optional interval diagnostics assess the same forward window using
the observed growth rate `x=log(S_sale/S_origin)/horizon` (year⁻¹). The
central bounds are `mu_g ± 1.96*sigma/sqrt(horizon)` (with the normal quantile
computed at 0.975):

- **Coverage:** the fraction of observed growth rates inside the central 95% predicted interval.
- **Width:** `U-L`, the interval's spread in growth-rate units (year⁻¹).
- **Interval score:** width plus a penalty for an observation outside the interval,
  calculated as `(U-L) + (2/alpha)*max(L-x,0) + (2/alpha)*max(x-U,0)` with
  `alpha=0.05`. Lower is better; width alone does not penalize missed observations.

These growth-rate interval scores do not depend on the ticker price scale.
Compare the methods over the same forecast window.
Forecast dates overlap and firms share market exposure, so neither daily scores
nor asset scores are independent observations. The notebook reports descriptive
paired comparisons, with equal ticker weights and common forecast origins.

## Reproducible checks

Run `julia --project=. scripts/check-week5-adaptive.jl` from the repository root.
The checks compare EMA states to explicit weighted moments, test forecast timing
and alternate date settings, verify the deterministic cases and median target,
and compare Monte Carlo with the analytical probability using sampling error.
