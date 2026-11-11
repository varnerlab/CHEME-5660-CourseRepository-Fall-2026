# Example: The Farmer–Joshi Market
In this example, we simulate the Farmer–Joshi market, an agent-based model in which value investors and trend followers trade one asset through a market maker, and we compare the statistics of its growth rates with the stylized facts of real daily growth rates.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Simulate three markets:__ A Farmer–Joshi market has value investors, who trade on the gap between the price and their estimate of the value, and trend followers, who trade on recent price changes. A market maker turns their net order into a price change. We simulate markets with value investors only, trend followers only, and both groups, and compare their prices and growth rates.
> * __Measure the stylized facts:__ Fat tails and volatility clustering are patterns found in the growth rates of real assets. We measure the excess kurtosis and the autocorrelation of the growth rates, of their absolute values, and of the trading volume in the market with both groups.
> * __Compare with a real ticker and vary the mix of traders:__ The model has no data in it, only trading rules. We put the simulated statistics next to the same statistics for a real ticker, and vary the number of trend followers to see which statistics the model can match at the same time.

We use the trader parameters of [Farmer and Joshi (2002)](https://arxiv.org/pdf/cond-mat/0012419), Table 1, with two changes that we explain in the Constants section. Those two changes make this our variant of their simulation, not a replication.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/).

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Data
In Task 3, we compare the simulated market with the daily closing prices of one ticker from the course data set, 2014 to 2024. [The MyTrainingMarketDataSet() function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyTrainingMarketDataSet) returns a dictionary. Its `"dataset"` entry maps each ticker to a `DataFrame` of daily prices and volumes. We store it in the `dataset::Dict{String, DataFrame}` variable:

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, and permissible values. Farmer and Joshi chose their parameters to keep the price near the value and to match the volatility of real prices. 

We make two changes:
* __Price noise:__ Table 1 lists a noise of 0.35 per step in the price, which is $\sigma_{S}\approx 5.6$ in our annualized units. Because the price in our simulations then drifts much farther from the value than in the paper's figures of price and value, we use $\sigma_{S}=0.8$. Try `σ_S = 5.6` to see the difference.
* __Value:__ Farmer and Joshi drive the value with annual S&P 500 dividends, interpolated to days. We use a random walk instead.

We set the ranges of the entry and exit thresholds to the Table 1 values. [The build(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/abm/#VLQuantitativeFinancePackage.build-Tuple{Type{MyFarmerJoshiMarketModel},%20NamedTuple}) draws each trader's thresholds uniformly from these ranges. In the constants, `T` is the entry threshold $\chi^{\text{in}}_{i}$ and `τ` is the exit threshold $\chi^{\text{out}}_{i}$.

Every other trader parameter is the Table 1 value, which `build(...)` uses by default.

___

## Task 1: Simulate Three Markets
In this task, we simulate three markets, with value investors only, with trend followers only, and with both groups, and compare how their prices move.

__Simulate the markets__: [The build(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/abm/#VLQuantitativeFinancePackage.build-Tuple{Type{MyFarmerJoshiMarketModel},%20NamedTuple}) draws every trader's thresholds, offset, and lag at random and returns a `MyFarmerJoshiMarketModel`, and [the solve(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/abm/#VLQuantitativeFinancePackage.solve-Tuple{MyFarmerJoshiMarketModel}) runs the market. In the code below:
* We pass `trend_number = 0` for the market with value investors only and `value_number = 0` for the market with trend followers only. The market with both groups has 1,200 traders of each kind.
* `solve(...)` runs `burn_in` steps, discards them, and records `number_of_steps` steps.
* Each result is a `NamedTuple` with the log price `log_price::Vector{Float64}`, the log value `log_value::Vector{Float64}`, the log price changes `returns::Vector{Float64}` (we divide them by $\Delta t$ to get growth rates), and the volumes `value_volume::Vector{Float64}` and `trend_volume::Vector{Float64}`. We store the three results in the `markets::Dict{String, NamedTuple}` variable.

Let's simulate the three markets:

Output:
```
Dict{String, NamedTuple} with 3 entries:
  "trend followers only" => (log_price = [-2.91039, -3.06105, -3.2484, -3.40774…
  "value investors only" => (log_price = [-0.307722, -0.400103, -0.390384, -0.4…
  "both groups"          => (log_price = [-0.653285, -0.61853, -0.710606, -0.80…
```

Let's compare the mean growth rate of the price with the mean growth rate of the value in the three markets, because the two means show whether the price follows the value over the full run. We also compare the standard deviation of the growth rates of the price and their lag-1 autocorrelation. [The sample_autocorrelation(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/adaptive/#VLQuantitativeFinancePackage.sample_autocorrelation) computes the autocorrelation at the lags we pass.

For a series with no autocorrelation, 95% of sample autocorrelations fall within about $\pm 1.96/\sqrt{n}$ of zero, where $n$ is the length of the series. We show this white-noise band in the last column:

Output:
```
 ---------------------- -------------------------- -------------------------- ------------------------------ ----------------------- ----------------------
  market                 mean g of price S (1/yr)   mean g of value V (1/yr)   std of growth rates g (1/yr)   lag-1 autocorrelation   white-noise band (±) 
 ---------------------- -------------------------- -------------------------- ------------------------------ ----------------------- ----------------------
  value investors only                      -0.08                       0.03                          12.77                 -0.0240                 0.0139
  trend followers only                       0.22                      -0.02                          84.51                  0.9099                 0.0139
  both groups                                0.00                       0.01                          57.05                  0.3080                 0.0139
 ---------------------- -------------------------- -------------------------- ------------------------------ ----------------------- ----------------------
```

> __What do we see?__
>
> * __Value investors only:__ The standard deviation of the growth rates is close to $\sigma_{S}/\sqrt{\Delta t}$, the noise alone. The lag-1 autocorrelation is small and negative, just outside the white-noise band: value investors push the price back after a move.
> * __Trend followers only:__ The standard deviation is several times larger than $\sigma_{S}/\sqrt{\Delta t}$, and the lag-1 autocorrelation is close to 1. An autocorrelation this close to 1 means that each growth rate is almost a copy of the one before it.
> * __Both groups:__ The standard deviation falls between the other two markets, and the lag-1 autocorrelation is positive but smaller than with trend followers only. Farmer and Joshi report an autocorrelation close to zero for their simulation.

`Unhide` the second code block below to see how we plotted the log price and the log value for the first 2,000 recorded steps of one market. Set `market_to_visualize` in the first code block to any entry of `market_names`, and rerun both code blocks to see another market.

How do the prices move in the three markets?

Output:
```
"both groups"
```

> __What do we see?__
>
> * __Value investors only:__ The price wanders around the value and stays within about two log units of it in this window. Gaps of either sign last for hundreds of steps before the price comes back.
> * __Trend followers only:__ The price ignores the value and runs through repeated cycles, a long move in one direction followed by a sharp reversal, more than ten log units from peak to trough.
> * __Both groups:__ The price stays much closer to the value than with trend followers only, but it still makes sharp moves of one to several log units, separated by quieter stretches.

Your numbers will differ if you change the constants.
___

## Task 2: Measure the Stylized Facts
In this task, we measure the stylized facts of the growth rates: fat tails, the autocorrelation of the growth rates, and volatility clustering.

We measure three things:
* __Fat tails:__ the excess kurtosis, $\langle(g-\bar{g})^{4}\rangle/\sigma_{g}^{4}-3$, where $\bar{g}$ and $\sigma_{g}$ are the mean and standard deviation of the growth rates, is zero for a Normal distribution and positive when large moves are more common than a Normal distribution predicts. A q–q plot shows the same thing graphically.
* __Autocorrelation of the growth rates:__ whether a growth rate predicts the next ones.
* __Volatility clustering:__ the autocorrelation of the absolute growth rates $\lvert g_{t}\rvert$ and of the volume. Positive values mean that large moves, and heavy trading, tend to follow large moves.

First, let's write a short function for the excess kurtosis:

Next, let's compare the distribution of the growth rates in all three markets. We standardize the growth rates of each market to mean zero and standard deviation one, so that we compare the shape of the distributions.

`Unhide` the code block below to see how we plotted each histogram and the standard Normal distribution on one set of axes. The excess kurtosis of each market is in the legend, and the horizontal axis stops at $\pm 5$ standard deviations.

How do the shapes of the distributions differ in the three markets?

> __What do we see?__
>
> * __Value investors only:__ The histogram follows the standard Normal curve, and the excess kurtosis is close to zero.
> * __Trend followers only:__ The histogram rises above the standard Normal curve near the center, and the excess kurtosis is far above zero.
> * __Both groups:__ The histogram also rises above the standard Normal curve near the center, and this market has the largest excess kurtosis of the three.

`Unhide` the code block below to see how we made the q–q plot. Each curve compares the quantiles of the standardized growth rates in one market with the same quantiles of a standard Normal distribution. A Normal sample would fall on the dashed line.

Are the growth rates Normal?

> __What do we see?__
>
> * __Value investors only:__ The curve lies on the dashed line from one end to the other. These growth rates look like a Normal sample.
> * __Trend followers, near the center:__ In the two markets with trend followers, the curves lie below the dashed line on the right and above it on the left. This means that most growth rates are smaller than a Normal distribution predicts.
> * __Trend followers, at both ends:__ The same two curves bend sharply away from the dashed line. The largest standardized growth rates are far beyond the $\pm 4$ that a Normal sample of this size would reach.

`Unhide` the code block below to see how we plotted the autocorrelation of the growth rates, of their absolute values, and of the volume in the market with both groups at lags 1 to 50, with the white-noise band.

How long do the autocorrelations last?

> __What do we see?__ All three autocorrelations are largest at lag 1 and drop quickly. The autocorrelations of the absolute growth rates and of the volume fall below 0.1 within about five steps, and that of the growth rates reaches the white-noise band within about 20 steps. At longer lags, all three stay within about 0.1 of zero.

Your numbers will differ if you change the constants.
___

## Task 3: Compare with a Real Ticker and Vary the Mix of Traders
In this task, we put the market with both groups next to a real ticker, set by `ticker`, and then vary the number of trend followers.

We compare shapes, not the size of the moves, because the model's noise is not calibrated to the ticker. The excess kurtosis and the autocorrelations measure shape, because they do not change when we multiply a series by a constant.

Let's compute the ticker's daily growth rates and volume. We store them, and the statistics that the sweep below needs, in the `ticker_facts::NamedTuple` variable:

`Unhide` the code block below to see how we made the q–q plot of the standardized growth rates, as in Task 2, with the excess kurtosis in the legend.

Does the simulated market have the ticker's fat tails?

> __What do we see?__ Both curves bend away from the dashed line at both ends, which means that the simulated market and the ticker both have fat tails. The simulated excess kurtosis is about three times the ticker's.

`Unhide` the second code block below to see how we plotted the autocorrelation of one series at lags 1 to 50, with the ticker as sticks and the simulated market as a line. Set `series_to_visualize` in the first code block to `:g`, `:absolute_g`, or `:volume`, and rerun both code blocks to see another series.

How long do the autocorrelations last in the ticker and in the simulated market?

> __What do we see?__
>
> * __Growth rates:__ The ticker's lag-1 autocorrelation is small and negative, while the simulated one is positive.
> * __Absolute growth rates:__ Both autocorrelations are positive at lag 1. The ticker's stays above the white-noise band at all 50 lags, which means that its clustering lasts for weeks. The simulated one nearly vanishes by lag 5.
> * __Volume:__ The ticker's autocorrelation also stays above the white-noise band at all 50 lags, and the simulated one also nearly vanishes by lag 5.
>
> Your comparison will differ if you change `ticker`.

### Changing the mix of traders
Farmer and Joshi chose equal numbers of value investors and trend followers so that the positive autocorrelation from the trend followers would cancel the negative autocorrelation from the value investors. In our variant, the market with both groups still has a positive lag-1 autocorrelation. What happens if we change the number of trend followers?

__Sweep the number of trend followers__: We hold the value investors at 1,200 and run three markets for each number of trend followers in `trend_counts`. In the code below:
* `trend_counts::Vector{Int}` runs from 0 to 1,500 trend followers.
* As in Task 1, one random number generator `rng`, seeded with `random_seed`, supplies every market.
* The result `mix_df::DataFrame` has one row per market: the number of trend followers, the seed index, the lag-1 autocorrelation of the growth rates, the excess kurtosis, and the lag-1 autocorrelation of the absolute growth rates.

Let's run the sweep:

Output:
```
 ----------------- ---------------------------- ----------------- ------------------------------
  trend followers   lag-1 autocorrelation of g   excess kurtosis   lag-1 autocorrelation of |g| 
 ----------------- ---------------------------- ----------------- ------------------------------
                0                       -0.031             0.076                          0.014
              300                       -0.012             0.121                          0.009
              600                        0.021             0.181                          0.025
              900                        0.195            31.278                          0.253
             1200                        0.246            46.466                          0.675
             1500                        0.292            41.321                          0.700
 ----------------- ---------------------------- ----------------- ------------------------------
```

The table shows the averages over three markets. `Unhide` the second code block below to see how we plotted one statistic against the number of trend followers, for each market and for the average, with the ticker's value as a dashed line. Set `statistic_to_visualize` in the first code block to `:acf1`, `:kurtosis`, or `:absolute_acf1`, and rerun both code blocks to see another statistic.

Can one mix of traders match the ticker on all three statistics?

> __What do we see?__
>
> * __Few trend followers:__ With 600 or fewer trend followers, the excess kurtosis, the autocorrelation of the absolute growth rates, and the lag-1 autocorrelation of the growth rates all stay close to zero.
> * __Many trend followers:__ With 900 trend followers, the markets differ widely, some near zero and some far above it on each statistic. With 1,200 or more, every market has a large kurtosis and strong clustering, past the ticker's values.
>
>   * In these markets, the lag-1 autocorrelation of the growth rates differs widely from one market to the next, and it stays above the ticker's value.
> * __No single mix:__ At every number of trend followers in our sweep, the averages miss the ticker by a wide margin on at least one of the three statistics.

Your numbers will differ if you change the constants. Try `σ_S = 0.55` or `σ_S = 1.6`, or a different `ticker`, and rerun the notebook.
___

## Summary
In this example, we simulated the Farmer–Joshi market with value investors, trend followers, and both, measured the stylized facts of the market with both groups, and compared them with the growth rates of a real ticker.

> __Key Takeaways:__
>
> * __Each trading rule leaves its own mark on the price:__ We simulated markets with one group of traders at a time. Value investors bought when the price was far enough below the value and sold when the price was far enough above the value. Their trading gave the growth rates a small negative autocorrelation.
>
>   * Each trade moved the price once, in the step of the trade. After the value investors who wanted to buy had bought, there were no new buy orders. The price then stayed below the value for hundreds of steps.
>
>   * With value investors only, the mean growth rates of the price and the value differ over the full run. This means that the price drifted far from the value.
>
>   * Trend followers let the price run much farther from the value in repeated cycles. They gave the growth rates a large positive autocorrelation.
> * __The two groups together produce fat tails and volatility clustering:__ We measured the market with both groups and found a large excess kurtosis, a q–q plot that bends away from the Normal line at the extremes, and positive autocorrelation of the absolute growth rates and of the volume.
>
>   * None of these patterns was put into the model. They come from the traders' rules and the market maker.
> * __The model matches some stylized facts but not all at once:__ We compared the simulated statistics with a real ticker and varied the number of trend followers. Fat tails and volatility clustering appeared only once there were enough trend followers.
>
>   * The clustering then faded within a few steps instead of lasting for weeks as in the real growth rates. The autocorrelation of the growth rates changed widely from one set of random traders to the next.

The traders, the signals they watch, their threshold rules, the net order, and the price that feeds back into the next signals are the five parts of an agent-based model from the lecture.
___
