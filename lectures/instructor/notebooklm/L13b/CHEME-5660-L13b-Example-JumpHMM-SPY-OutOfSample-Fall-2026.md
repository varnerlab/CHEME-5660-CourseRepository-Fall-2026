# Example: Testing the SPY Model Out of Sample
Previously, we fit a jump hidden Markov model to the daily growth rate of `SPY` from 2014 to 2024. How well does the model describe the growth rates of 2025 and 2026, which came after its fitting period?

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Test a fitted model on data it has not seen:__ Simulate paths from the model and compare them with the growth rates of 2025 and 2026. Measure how often a path passes the Kolmogorov–Smirnov and Anderson–Darling tests.
> * __Turn the jump episodes off:__ Set the episode probability to zero in a copy of the model and score both models on the same data. Explain how the paths with a jump episode change the scores.
> * __Check volatility clustering out of sample:__ Compare the autocorrelation of the absolute growth rate in 2025 and 2026 with that of the simulated paths. Judge both against the 95% band for white noise.

Let's get started!

___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/).

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

__JumpHMM.jl:__ The [JumpHMM.jl package](https://varnerlab.github.io/JumpHMM.jl/dev/) implements the jump hidden Markov model. The `Include.jl` file imports it with `import JumpHMM`, so we call its functions with the package name in front, for example `JumpHMM.simulate(...)`. This keeps them apart from functions with the same names in other packages.



### Data
We load the jump hidden Markov model of `SPY`, with its tuned jump episodes, from the `data/JumpHMM-SPY-2014-2024.jld2` file with [the `load(...)` function from JLD2.jl](https://juliaio.github.io/JLD2.jl/stable/basic_usage/#FileIO-interface). [The `@assert` macro](https://docs.julialang.org/en/v1/base/base/#Base.@assert) checks that the model has the saved number of states and time step.

We keep the model in the `model::JumpHMM.MyJumpHiddenMarkovModel` variable, and the last trading day of its fitting period in the `last_fit_date::DateTime` variable:

Next, we load the test data, the daily prices of 2025 and 2026, with [the `MyTestingMarketDataSet(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyTestingMarketDataSet). We join the `SPY` closing prices of the two years with [the `append!(...)` function](https://docs.julialang.org/en/v1/base/collections/#Base.append!) and keep them in the `prices::Array{Float64,1}` variable, with their dates in the `dates::Array{DateTime,1}` variable:

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, and permissible values. We compute the daily growth rate of the test data with [the `JumpHMM.excess_growth_rates(...)` function](https://varnerlab.github.io/JumpHMM.jl/dev/api/#JumpHMM.excess_growth_rates-Tuple{Vector{Float64}}), as in the fit, and keep it in the `g::Array{Float64,1}` variable:

___

## Task 1: Compare Simulated Paths with the Test Data
In this task, we simulate paths from the model, each as long as the test data, and compare them with the growth rates of 2025 and 2026. [The `JumpHMM.simulate(...)` function](https://varnerlab.github.io/JumpHMM.jl/dev/api/#JumpHMM.simulate-Tuple{MyJumpHiddenMarkovModel,%20Int64}) starts each path from the stationary distribution, steps the chain with the transition matrix, and draws each day's growth rate from the Student-t emission of the day's state.

Few paths of the length of the test data contain an episode. To get enough for analysis, we simulate batches of `number_of_paths` paths, with a new seed for each batch, until we have `number_of_jump_paths` paths with an episode and `number_of_paths` paths without one.

We save the kept paths in the `paths_jump::Array{Float64,2}` variable, one column per path. We list the paths that contain a jump episode, by column number, in the `with_episode::Array{Int64,1}` variable, and the other paths in the `without_episode::Array{Int64,1}` variable:

__Let's score each kept path against the test data__. The two-sample Kolmogorov–Smirnov (KS) test compares one path with the test data by the largest gap between their cumulative distributions. The Anderson–Darling (AD) test compares the same two distributions with more weight on the tails. A path passes a test when its p-value is above the significance level $\alpha$, and the pass rate is the share of paths that pass. 

We run the tests with [the `ApproximateTwoSampleKSTest(...)`](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#HypothesisTests.ApproximateTwoSampleKSTest) and [the `KSampleADTest(...)`](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#HypothesisTests.KSampleADTest) functions, and read each p-value with [the `pvalue(...)` function](https://juliastats.org/HypothesisTests.jl/stable/methods/#StatsAPI.pvalue). We compute the excess kurtosis of each path with [the `kurtosis(...)` function](https://juliastats.org/StatsBase.jl/stable/scalarstats/#StatsBase.kurtosis).

We save the KS and AD p-values and the excess kurtosis of each kept path, by column number, in the `ks_jump::Array{Float64,1}`, `ad_jump::Array{Float64,1}`, and `kurtosis_jump::Array{Float64,1}` variables:

The table, made with [the `pretty_table(...)` function](https://ronisbr.github.io/PrettyTables.jl/stable/lib/library/#PrettyTables.pretty_table), shows the number of paths, the pass rates, and the mean excess kurtosis of each group, next to the excess kurtosis of the test data:

Output:
```
 ---------------------------- ------- --------------- --------------- ------------------------
                               paths   pass rate, KS   pass rate, AD   excess kurtosis (mean) 
 ---------------------------- ------- --------------- --------------- ------------------------
  simulated, no episode          200           0.955           0.985                   12.479
  simulated, with an episode     200           0.125           0.070                    6.111
  real SPY, 2025 to 2026           1               —               —                   18.962
 ---------------------------- ------- --------------- --------------- ------------------------
```

`Unhide` the code block below to see how we plotted the distribution of the growth rate on each simulated path next to the test data, with [the `density(...)` function](https://docs.juliaplots.org/stable/api/#Plots.density-Tuple). The paths with a jump episode are red.

> __What do we see?__ Most paths without an episode pass both tests. The model still describes the distribution of the daily growth rate in 2025 and 2026. The test data hold the sharp fall and rebound of April 2025, and their excess kurtosis is larger than the average over the simulated paths.
>
> Most paths with an episode fail both tests. An episode lasts many days, and each episode day is a large move from one of the most negative or most positive states. These days give the red paths two side bumps, and their excess kurtosis falls below that of the blue paths.

Do the simulated paths look like `SPY` in 2025 and 2026?

___

## Task 2: Turn the Jump Episodes Off
In this task, we turn the jump episodes off and score both models on the same test data. We set the episode probability $\epsilon$ to zero in a copy of the model, as [Changing a fitted model](https://varnerlab.github.io/JumpHMM.jl/dev/model/#Changing-a-fitted-model) in the JumpHMM.jl documentation shows.

[The `deepcopy(...)` function](https://docs.julialang.org/en/v1/base/base/#Base.deepcopy) makes the copy, so the saved model keeps its jump episodes. With $\epsilon = 0$, no episode can start, and the chain and the emissions stay the same.

We score the copy with [the `JumpHMM.validate(...)` function](https://varnerlab.github.io/JumpHMM.jl/dev/api/#JumpHMM.validate-Tuple{MyJumpHiddenMarkovModel,%20Vector{Float64}}), which simulates `number_of_paths` paths and runs the same two tests on each one. We use the same seed and save the results in the `report_nojump::JumpHMM.MyValidationReportModel` variable:

The table compares the two groups of paths of the model with jumps with the paths of the model without jumps:

Output:
```
 -------------------------------------- ------- --------------- --------------- ------------------------
                                         paths   pass rate, KS   pass rate, AD   excess kurtosis (mean) 
 -------------------------------------- ------- --------------- --------------- ------------------------
  with jumps, paths with an episode        200           0.125           0.070                    6.111
  with jumps, paths without an episode     200           0.955           0.985                   12.479
  no jumps, all paths                      200           0.950           0.975                   10.868
 -------------------------------------- ------- --------------- --------------- ------------------------
```

> __What do we see?__ The paths of the model without jumps pass about as often as the paths without an episode. The two groups come from the same chain and emissions. Turning the episodes off changes only the paths that would have had an episode.

___

## Task 3: Compare Volatility Clustering
In this task, we compare the volatility clustering of the test data with that of the simulated paths of the model with jumps. Volatility clustering means that large moves follow large moves, so the autocorrelation of the absolute growth rate $|g_{t}|$ on day $t$ is positive.

The 95% band for white noise is $\pm 1.96/\sqrt{T}$, where $T$ is the number of trading days in the test data. An autocorrelation inside the band is consistent with white noise. The test data cover far fewer days than the fitting period, so their band is wider.

We compute the autocorrelation of $|g_{t}|$ at lags of 1 to `number_of_lags` trading days with [the `StatsBase.autocor(...)` function](https://juliastats.org/StatsBase.jl/stable/signalcorr/#StatsBase.autocor). We save it in the `acf_test::Array{Float64,1}` variable for the test data, and in the `acf_jump::Array{Float64,2}` variable for the simulated paths, one column per path:

`Unhide` the code block below to see how we plotted the autocorrelation of $|g_{t}|$ for the test data and the simulated paths with [the `plot(...)` function](https://docs.juliaplots.org/stable/api/#RecipesBase.plot), the percentiles of the paths with [the `quantile(...)` function](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.quantile), and the 95% band for white noise with [the `hline!(...)` function](https://docs.juliaplots.org/stable/api/#Plots.hline!-Tuple). The paths with a jump episode are red.

> __What do we see?__
>
> * __Test data:__ The autocorrelation of $|g_{t}|$ is above the band at several short lags and mostly inside it at longer lags.
> * __Paths without an episode:__ Their mean autocorrelation falls inside the band after the first few lags. The chain forgets a volatile day within a few steps.
> * __Paths with an episode:__ Their mean autocorrelation stays above the band for months. At lags longer than the episode, it turns negative, because it then pairs the large moves of the episode with the small moves of ordinary days.

How long does volatility cluster in 2025 and 2026?

___

## Summary
In this example, we tested the jump hidden Markov model of `SPY` on the growth rates of 2025 and 2026, which came after its fitting period. We scored simulated paths against the test data, turned the jump episodes off, and compared the volatility clustering of the simulated paths with that of the data.

> __Key Takeaways:__
>
> * __The model still describes the distribution:__ We simulated paths from the model, each as long as the test data, until we had the same number of paths with and without a jump episode. We scored each path with the Kolmogorov–Smirnov and Anderson–Darling tests. Most paths without an episode passed both tests, although the test data had fatter tails than the average simulated path.
> * __Paths with a jump episode fail the tests:__ The paths with an episode failed most tests, because their episode days added side bumps to the distribution. We turned the jump episodes off in a copy of the model and scored it on the same data. Its paths scored like the paths without an episode.
> * __Neither group of paths matches the clustering of the test data:__ We compared the autocorrelation of the absolute growth rate in the test data and in the simulated paths with the 95% band for white noise. The test data clustered at short lags. The paths without an episode forgot a volatile day within a few days, and the paths with an episode stayed clustered for months.

Knowing which features of new data the model reproduces and which it misses lets us judge what a stress test built on it can tell us.

___
