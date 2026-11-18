# Example: A Jump Hidden Markov Model of SPY
In this example, we build a synthetic market for one asset, `SPY`. We fit a hidden Markov model to the daily growth rate of `SPY` from 2014 to 2024, simulate it, and check which features of the real series it reproduces and which it misses. Then we add jump episodes and see what they change.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Fit a hidden Markov model of daily growth rates:__ Bin the daily growth rate into states, estimate the transition matrix by counting, and fit a Student-t distribution to the growth rates in each state.
> * __Check simulated growth rates against the data:__ Compare the distribution, the kurtosis, and the autocorrelations of the growth rate and the absolute growth rate of simulated paths with those of the real series.
> * __Add and tune jump episodes:__ Tune the jump probability and the mean episode length, and explain the tradeoff between volatility clustering, fat tails, and spread.

Let's get started!

___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/). 

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

> __JumpHMM.jl:__ The [JumpHMM.jl package](https://varnerlab.github.io/JumpHMM.jl/dev/) implements the jump hidden Markov model. The `Include.jl` file imports it with `import JumpHMM`, so we call its functions with the package name in front, for example `JumpHMM.fit(...)`. This keeps them apart from functions with the same names in other packages.

### Data
We load the 2014 to 2024 daily price data with [the `MyTrainingMarketDataSet()` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyTrainingMarketDataSet) and keep the `SPY` closing prices in the `prices::Array{Float64,1}` variable:

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, and permissible values:

___

## Task 1: Fit the Hidden Markov Model
In this task, we fit the hidden Markov model to the daily growth rate of `SPY`. [The `JumpHMM.fit(...)` function](https://varnerlab.github.io/JumpHMM.jl/dev/fitting/) does three things:
* __States:__ It fits a Laplace distribution to the growth rates and cuts it into $N$ bins of equal probability. Each bin is a hidden state, so state 1 holds the most negative growth rates and state $N$ the most positive.
* __Transition matrix:__ It assigns each day to its state and estimates $\hat{p}_{ij}$ by counting the moves from state $i$ to state $j$ on consecutive days, divided by the number of days in state $i$.
* __Emissions:__ In each state, it sets a Student-t distribution with location $\mu_{k}$, the mean of the growth rates in that state, scale $\sigma_{k}$, their standard deviation, and $\nu$ degrees of freedom, which we choose.

We save the fitted model in the `model::JumpHMM.JumpHiddenMarkovModel` variable:

Let's look at a few of the states. For each one, the table shows its bin of the growth rate (units: 1/yr), the number of days in the training data that fell in the bin, and the location and scale of its Student-t emission:

Output:
```
 --------- ------------------ ------------------ ------ ------------ ------------
  state k   bin lower (1/yr)   bin upper (1/yr)   days   μ_k (1/yr)   σ_k (1/yr) 
 --------- ------------------ ------------------ ------ ------------ ------------
        1               -Inf             -6.873     44      -10.130        4.574
        2             -6.873             -5.628     28       -6.191        0.320
       25             -1.167             -1.094     19       -1.131        0.020
       50              0.114              0.150     45        0.132        0.010
       75              1.324              1.395     28        1.365        0.018
       99              5.929              7.174     22        6.341        0.252
      100              7.174                Inf     20       11.307        4.349
 --------- ------------------ ------------------ ------ ------------ ------------
```

> __What do we see?__ The bins have equal probability under the fitted Laplace distribution. The number of days per bin varies because the fitted distribution approximates the data.
>
> The middle bins are narrow because most days have small moves. The first and last bins reach out to the crash and rebound days. Their emissions are much wider than those of the middle states.

___

## Task 2: Simulate Without Jumps
In this task, we simulate the fitted model and compare the simulated growth rates with the real ones. [The `JumpHMM.simulate(...)` function](https://varnerlab.github.io/JumpHMM.jl/dev/simulation/) starts each path from the stationary distribution, steps the chain with the transition matrix, and draws each day's growth rate from the Student-t emission of the day's state. 

To make sure there are no jumps, we set the episode probability to $\epsilon = 0$ with `JumpHMM.JumpParameters(...)` before we simulate. With $\epsilon = 0$, no jump episodes can start.

We compare three features of the data:
* __Distribution:__ the Kolmogorov–Smirnov test of each simulated path against the real growth rates, and the kurtosis. Consecutive days are not independent, so we read the test as a description of how close the distributions are, not as a formal test.
* __Autocorrelation:__ the autocorrelation of the growth rate $g_{t}$ at lags of 1 to 252 trading days, about one trading year. It measures whether today's growth rate helps predict tomorrow's.
* __Volatility clustering:__ the autocorrelation of the absolute growth rate $|g_{t}|$ at the same lags. Large moves follow large moves in real data, so this autocorrelation stays positive for months.

We save the simulated paths in the `paths_nojump::Array{Float64,2}` variable, one column per path:

Let's compare the simulated paths with the data. The two-sample Kolmogorov–Smirnov test compares one simulated path with the real growth rates $g$ by the largest gap between their cumulative distributions. A p-value above 0.05 means the test finds no difference between the two distributions at the 5% level.

The table shows the standard deviation and kurtosis of the real growth rates and the average over the simulated paths, and the share of paths with a p-value above 0.05:

Output:
```
 --------------------------------------- ---------- ---------------------
  statistic                               real SPY   simulated, no jumps 
 --------------------------------------- ---------- ---------------------
  standard deviation (1/yr)                  2.741                 2.793
  kurtosis (excess)                         13.768                13.137
  share of paths with KS p-value > 0.05        NaN                 0.995
 --------------------------------------- ---------- ---------------------
```

`Unhide` the code block below to see how we plotted the distribution of the growth rate on each simulated path next to the real one.

> __What do we see?__ The simulated paths match the spread and the fat tails of the real growth rates. Each path's distribution lies close to the real one, which is why almost every path has a Kolmogorov–Smirnov p-value above 0.05.

Do the simulated paths look like `SPY`?

`Unhide` the code block below to see how we plotted the autocorrelation of the growth rate for the data and for the simulated paths.

The dashed lines mark the 95% band for white noise, $\pm 1.96/\sqrt{T}$, where $T$ is the number of trading days. An autocorrelation inside the band is consistent with the approximate white-noise benchmark.

> __What do we see?__ In the first few weeks, the real autocorrelation of $g_{t}$ falls outside the band at many lags, mostly because of 2020. At longer lags, only a few bars fall outside the band, as we expect by chance. The average over the simulated paths falls inside the band after lag 1.

Does today's growth rate predict tomorrow's?

`Unhide` the code block below to see how we plotted the autocorrelation of the absolute growth rate for the data and for the simulated paths, with the same 95% band.

> __What do we see?__ The simulated paths miss volatility clustering: their autocorrelation of $|g_{t}|$ is positive at lag 1 but falls inside the noise band after a few days, while the real one stays above the band for months. The counted chain forgets a volatile day within a few steps.

How long does volatility cluster?

___

## Task 3: Add Jump Episodes
In this task, we add jump episodes to restore volatility clustering and study the tradeoff they create. On a day with no episode under way, an episode starts with probability $\epsilon$ and lasts a Poisson number of days with mean $\lambda$.

To choose $\epsilon$ and $\lambda$, we compare simulated paths with the data on two features. The autocorrelation of $|g_{t}|$ measures volatility clustering, and the kurtosis measures the fat tails.

[The `JumpHMM.tune(...)` function](https://varnerlab.github.io/JumpHMM.jl/dev/tuning/) searches a grid of $(\epsilon,\lambda)$ values. For each pair, it simulates paths and keeps the $M$ paths that contain an episode. It then computes the average error over these paths:

$$
J(\epsilon,\lambda)=\frac{1}{M}\sum_{m=1}^{M}\Bigl[\sum_{k=1}^{25}\left(\rho_{k}-\hat{\rho}_{m,k}\right)^{2}+0.2\left(\kappa-\hat{\kappa}_{m}\right)^{2}\Bigr]
$$

where $\rho_{k}$ is the autocorrelation of $|g_{t}|$ at lag $k$ in the data and $\hat{\rho}_{m,k}$ is the same on simulated path $m$. The excess kurtosis is $\kappa$ in the data and $\hat{\kappa}_{m}$ on path $m$. The weight 0.2 sets how much the kurtosis error counts against the autocorrelation errors.

`JumpHMM.tune(...)` returns a new model with the pair that has the smallest $J$. The new model keeps the bins, transition matrix, and emissions of `model` and changes only $\epsilon$ and $\lambda$. We use a small grid to keep the search short enough for class.

We save the tuned model in the `tuned_model::JumpHMM.JumpHiddenMarkovModel` variable:

Output:
```
tuned ϵ = 0.0001 per day, λ = 100.0 days, in 1.3 s
```

Let's simulate the tuned model and compare it with the data and with the model without jumps. With a small $\epsilon$, only some paths contain an episode. We report the paths with an episode separately, as the tuning does.

We also report the ratio of the simulated and real standard deviations: the jump episodes add large moves, which can raise the spread above the real one.

Output:
```
 ----------------------------------- ------------------- ------- -------- ---------- --------------
                                      ACF of |g|, lag 1   lag 5   lag 25   kurtosis   SD ÷ real SD 
 ----------------------------------- ------------------- ------- -------- ---------- --------------
  real SPY                                        0.364   0.325    0.146     13.768          1.000
  no jumps                                        0.250   0.003   -0.001     13.137          1.019
  with jumps, paths with an episode               0.334   0.135    0.102     12.018          1.123
 ----------------------------------- ------------------- ------- -------- ---------- --------------
share of simulated paths with a jump episode: 0.27
```

`Unhide` the code block below to see how we plotted the autocorrelation of $|g_{t}|$ for the data, for the paths with an episode, and for the model without jumps, with the same 95% band for white noise.

> __What do we see?__
>
> * __Volatility clustering:__ On the paths with an episode, the autocorrelation of $|g_{t}|$ stays above the noise band at longer lags, which the model without jumps cannot do. In this run, it stays below the real autocorrelation at lag 5, so the generator reproduces only part of the volatility clustering of `SPY`.
> * __A noisy tuning:__ Rerun with another `random_seed`: the tuned $\lambda$ can change a lot, because the score is computed from a modest number of simulated paths on a small grid. The tuning pins down the jump episodes only roughly.

Do jump episodes keep volatility clustered?

Jump episodes restore part of the clustering, but they also change the distribution of the growth rate. We'll explore this tradeoff with a small study. The study simulates the model with new jump settings, including the number of tail states, the extreme states on each side that an episode day draws from.

The cell below sets the study. See the comments for definitions and permissible values. Change the values and rerun the cells that follow to explore the tradeoff:

We build the model from the fitted chain and emissions, with the new jump settings in [a `JumpHMM.JumpParameters` instance](https://varnerlab.github.io/JumpHMM.jl/dev/api/#JumpHMM.JumpParameters). We save the simulated paths in the `paths_study::Array{Float64,2}` variable, one column per path, and mark the episode days with `true` in the `episodes_study::Array{Bool,2}` variable:

`Unhide` the code block below to see how we plotted the simulated paths of the study next to the real `SPY` growth rates. The left panel shows the distribution of the growth rate on each path. The right panel shows the autocorrelation of $|g_{t}|$ with the 95% band.

> __What do we see?__ The episodes add clustering on the right, but they change the distribution on the left:
>
> * __Clustering:__ The autocorrelation of $|g_{t}|$ on the simulated paths stays above the band for months, like the real one.
> * __Distribution:__ The simulated distributions grow two side bumps that the real one does not have. The bumps come from the episode days, whose growth rates come from a few extreme states. The kurtosis in the legend falls below the real one.
> * __Try other settings:__ Set `ϵ_to_study` to the tuned value, `tuned_model.jump.ϵ`, and the bumps shrink while the clustering fades. Then set `only_paths_with_episode` to `false`. Most paths now have no episode, so the average clustering fades within a few days.

Can any setting give both the clustering and the shape of the real distribution?

`Unhide` the code block below to see how we plotted the first study path with an episode next to the real `SPY` growth rates, with its episodes shaded.

What does a path with a jump episode look like?

Finally, let's save the tuned model, so the multi-asset example and later lectures can reuse it. We write it to `data/JumpHMM-SPY-2014-2024.jld2` with [the `save(...)` function exported by the JLD2.jl package](https://github.com/JuliaIO/JLD2.jl):

___

## Summary
In this example, we fit a hidden Markov model to the daily growth rate of `SPY`, simulated it, checked it against the data, and added jump episodes to restore part of the volatility clustering.

> __Key Takeaways:__
>
> * __The hidden Markov model is fit by binning and counting:__ We cut the growth rate into bins of equal probability, estimated the transition matrix by counting moves between bins on consecutive days, and fit a Student-t distribution in each bin.
> * __Without jumps, the model matches the distribution but not the clustering:__ We simulated paths and compared them with the data. They matched the spread and the fat tails of the real growth rates, but their volatility clustering faded within a few days, while the real clustering lasts for months.
> * __Jump episodes restore part of the clustering:__ We tuned the probability and the mean length of runs of extreme states. On paths with an episode, the absolute growth rate stayed correlated over longer lags. More episode days add clustering, but they thin the tails and raise the spread.

Understanding how the generator reproduces and misses features of the data lets us judge what a stress test built on it can tell us.

___
