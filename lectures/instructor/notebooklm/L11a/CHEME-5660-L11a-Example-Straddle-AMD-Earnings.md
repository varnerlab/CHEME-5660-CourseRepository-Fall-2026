# Example: Analysis of a Strangle Position in AMD
In this example, we analyze a strangle on Advanced Micro Devices, Inc. (AMD) using historical options data. A short strangle sells a put at strike $K_{1}$ and a call at a higher strike $K_{2}$, with the same expiration date. If we set $K_{1}=K_{2}$, the strangle becomes a straddle.

We sell a strangle on AMD before its earnings release, so we make money if the share price stays between the two breakevens.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Construct profit diagrams for strangle positions:__ Build the profit and loss profile of a short strangle by selling a put at $K_{1}$ and a call at $K_{2}\geq K_{1}$ with the same expiration date, and compute breakeven points where the position transitions from profit to loss.
> * __Calculate the probability of profit and the probability of exercise for a strangle:__ Use cumulative distribution functions of projected share price distributions to determine the likelihood that a strangle will be profitable at expiration, accounting for the two breakeven boundaries, and each leg's probability of exercise, under our belief $\mathbb{P}$ and the risk-neutral probabilities $\mathbb{Q}$.
> * __Evaluate the strangle after the earnings release:__ Buy both legs back at their premiums after the release and compute the profit or loss, which includes the extrinsic value still left in the legs.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/). 

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Data
To start, load the options data using [the `MyOptionsChainDataSet(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyOptionsChainDataSet) and store the metadata in the `metadata::Dict{String,Any}` variable and the options chain data in the `optionschain::DataFrame` variable.

What's in the `metadata::Dict{String,Any}` dictionary?

Output:
```
KeySet for a Dict{String, Any} with 10 entries. Keys:
  "DTE"
  "purchase_date"
  "historical_volatility"
  "underlying_share_price_ask"
  "source"
  "underlying_share_price_bid"
  "is_weekly"
  "atm_IV"
  "expiration_date"
  "underlying_share_price_mid"
```

What about the `optionschain::DataFrame` variable?

Output:
```
302×11 DataFrame
 Row │ Strike   Moneyness  Bid      Mid      Ask      Last     Volume  Open In ⋯
     │ Float64  Float64    Float64  Float64  Float64  Float64  Int64   String7 ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │     5.0     0.9906   524.2    526.53   528.85   517.3        0  1,074   ⋯
   2 │    10.0     0.9812   518.9    521.4    523.9    479.51       0  4
   3 │    15.0     0.9718   514.3    516.63   518.95     0.0        0  0
   4 │    20.0     0.9624   509.3    511.63   513.95   466.97       0  956
   5 │    25.0     0.953    504.1    506.55   509.0    427.94       0  212     ⋯
   6 │    30.0     0.9436   499.6    501.83   504.05   457.14       0  208
   7 │    35.0     0.9342   494.65   496.85   499.05   479.33       0  9
   8 │    40.0     0.9247   488.4    491.17   493.95   483.4        1  13
  ⋮  │    ⋮         ⋮         ⋮        ⋮        ⋮        ⋮       ⋮        ⋮    ⋱
 296 │  1250.0     1.3517   716.4    719.18   721.95     0.0        0  0       ⋯
 297 │  1260.0     1.3706   726.4    728.88   731.35     0.0        0  0
 298 │  1270.0     1.3894   736.4    739.18   741.95     0.0        0  0
 299 │  1280.0     1.4082   746.4    748.88   751.35     0.0        0  0
 300 │  1290.0     1.427    756.4    759.18   761.95     0.0        0  0       ⋯
 301 │  1300.0     1.4458   766.4    769.18   771.95     0.0        0  0
 302 │  1310.0     1.4646   776.4    778.88   781.35     0.0        0  0
                                                  4 columns and 287 rows omitted
```

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, permissible values, etc. 

Output:
```
Sₒ = 531.26 USD/share, DTE = 53.0 days, put at K₁ = 470.0 and call at K₂ = 630.0 USD/share, θ = -1 (short strangle)
```

In this example, we'll need to do a projection of the future share price distribution at the contract's expiration date. We'll use a Geometric Brownian Motion (GBM) model to project the future share price distribution at expiration.

Let's load the single asset geometric Brownian motion (SAGBM) parameters which we estimated a few lectures ago, which include the drift and diffusion coefficients for each ticker. We'll store this data in the `parameters_df::DataFrame` variable:

We are looking at `AMD`, so let's see what the parameters for this ticker are:

Output:
```
1×6 DataFrame
 Row │ ticker   drift     t        lower_bound_drift  upper_bound_drift  volat ⋯
     │ String7  Float64   Float64  Float64            Float64            Float ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ AMD      0.439658  1.96082            0.43459           0.444725    0.4 ⋯
                                                                1 column omitted
```

### Contract models
Next, we construct contract models for the options in this example. We begin by building an instance of the [MyAmericanCallContractModel type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyAmericanCallContractModel) using the [custom build(...) method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.build-Tuple{Type{MyAmericanCallContractModel},%20NamedTuple}). 

The [build(...) method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.build-Tuple{Type{MyAmericanCallContractModel},%20NamedTuple}) takes two arguments: the type to build, and a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple) containing the strike price `K`, the `premium` paid for the option, the days to expiration `DTE` (units: years), the `sense` parameter for position direction, the number of contracts in the `copy` field and the implied volatility in the `IV` field.

We save the call option contract model in the `call_option_model::MyAmericanCallContractModel` variable:

Output:
```
MyAmericanCallContractModel(630.0, -1, 0.1452054794520548, 0.5569, 15.3, nothing, 1)
```

The put contract, which is an instance of the [MyAmericanPutContractModel type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyAmericanPutContractModel), is constructed in a similar way to the call option. We save the put option contract model in the `put_option_model::MyAmericanPutContractModel` variable:

Output:
```
MyAmericanPutContractModel(470.0, -1, 0.1452054794520548, 0.5755, 18.9, nothing, 1)
```

___

## Task 1: Compute Profit, Loss and Breakeven Points
In this task, we compute the profit and loss (P&L) profile of our short strangle at expiration, as well as its breakeven points. 

A [short strangle](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/short-strangle) sells a put at strike $K_{1}$ and a call at strike $K_{2}$, with the _same expiration_ and $K_{1}<S(0)<K_{2}$. A [short straddle](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/short-straddle) uses one strike, $K_{1}=K_{2}\approx{S(0)}$.

> __Short strangle__
> 
> We sell both legs ($\theta = -1$). We set the strikes $K_{1}$ and $K_{2}$ in the constants cell above, which prints them along with the share price $S(0)$ and the days to expiration.

### Profit and Breakeven Analysis
Let $\mathcal{P}_{p}$ and $\mathcal{P}_{c}$ denote the premiums of the put and the call (USD/share), and let $\mathcal{D}_{T,0}(g_{y})$ be the accumulation factor from today to expiration. The premiums are collected today and the payoffs arrive at expiration, so the profit of a single strangle at expiration $\hat{P}_{\mathcal{C}}$ compares the payoffs with the premiums grown to expiration:

$$\hat{P}_{\mathcal{C}} = \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})-(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+}$$

The first term is the credit grown to expiration. The two payoff functions are:
* Put: $V_{p}(K_{1},S(T)) = (K_{1}-S(T))^{+}=\max(K_{1}-S(T),0)$
* Call: $V_{c}(K_{2},S(T)) = (S(T)-K_{2})^{+} = \max(S(T)-K_{2},0)$

> __Connection to the lecture:__ This is the lecture's composite profit $\hat{P}_{\mathcal{C}}=\hat{V}_{\mathcal{C}}-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\mathcal{C}}$ with $\theta_{i}=-1$ and $n_{i}=1$ for both legs. The composite premium is $\mathcal{P}_{\mathcal{C}}=-(\mathcal{P}_{p}+\mathcal{P}_{c})$, a credit of $\mathcal{P}_{p}+\mathcal{P}_{c}$. The lecture writes $\mathcal{P}_{1}$ and $\mathcal{P}_{2}$ for the put and call premiums.

The profit (or loss) of a strangle has three regimes given by:

$$
\hat{P}_{\mathcal{C}} = \begin{cases}
  \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{p}+\mathcal{P}_{c}\right)-(S(T)-K_{2})  & S(T)>K_{2} \\
  \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{p}+\mathcal{P}_{c}\right) & K_{1}\leq S(T)\leq K_{2} \\
    \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{p}+\mathcal{P}_{c}\right)-(K_{1}-S(T)) & S(T)<K_{1}
\end{cases}
$$

Finally, a strangle has _two_ possible breakeven points denoted as $S^{\ddagger}_{-}$ and $S^{\ddagger}_{+}$:
* If $S(T)>K_{2}$: a strangle will breakeven at $S^{\ddagger}_{+} = K_{2} + \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{p}+\mathcal{P}_{c}\right)$
* If $S(T)<K_{1}$: a strangle will breakeven at $S^{\ddagger}_{-} = K_{1} - \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{p}+\mathcal{P}_{c}\right)$.

For our short strangle, the maximum profit and maximum losses are the lecture's table entries, with maximum losses listed as positive amounts (USD/share):
* The maximum profit of $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ occurs when $K_{1}\leq S(T)\leq K_{2}$.
* The maximum loss below $S^{\ddagger}_{-}$ of $K_{1}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ occurs at $S(T)=0$.
* The maximum loss above $S^{\ddagger}_{+}$ is unlimited, because the share price can rise without limit.

With $K_{1}=K_{2}=K$, these are the profit, breakevens, and maximum losses of a straddle. A short strangle profits when the share price finishes between the breakevens.

So what do we see?

What are the breakeven points?

Output:
```
2-element Vector{Float64}:
 664.405647088967
 435.594352911033
```

___

## Task 2: Compute the Probability of Profit (POP) and the Probability of Exercise (POE)
In this task, we compute the Probability of Profit (POP) of our short strangle and the Probability of Exercise (POE) of each leg at expiration.

To start, we simulate share prices at expiration under the risk-neutral probabilities $\mathbb{Q}$: geometric Brownian motion with drift $g_{y}$ and the at-the-money implied volatility. Later, we compare the probabilities with our belief $\mathbb{P}$, built from the SAGBM parameters we loaded earlier.

We'll save the GBM model in the `model::MyGeometricBrownianMotionEquityModel` variable:

Output:
```
MyGeometricBrownianMotionEquityModel(0.04128677804517802, 0.5617)
```

Now that we have a populated [MyGeometricBrownianMotionEquityModel instance](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.MyGeometricBrownianMotionEquityModel) holding the `AMD` data, let's generate `number_of_samples` possible future share price values using the [sample(...) function exported by the VLQuantitativeFinancePackage.jl package](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.sample-Tuple{MyMultipleAssetGeometricBrownianMotionEquityModel,%20NamedTuple}).
* The [sample method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.sample-Tuple{MyMultipleAssetGeometricBrownianMotionEquityModel,%20NamedTuple}) takes a `model::MyGeometricBrownianMotionEquityModel` instance as the first argument, along with the time values that we wish to sample: `T₁::Float64` is the start time, `T₂::Float64` is the stop time (in units of `years`), `Δt::Float64` is the time step (in units of `years`), and `Sₒ::Float64` denotes the initial share price (in units of `USD/share`). Finally, we pass in the number of samples we want to generate in the `number_of_paths` argument.
* The [sample method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.sample-Tuple{MyMultipleAssetGeometricBrownianMotionEquityModel,%20NamedTuple}) generates `number_of_paths` sample paths from $T_{1}\rightarrow{T}_{2}$ in steps of $\Delta{t}$. However, we only want the share prices corresponding to the duration of the contract, i.e., $T_{2} = \text{DTE}$. Thus, we pass the full `samples` array [using the Julia pipe operator](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping) to a slicing operation where we select columns `2:end` of the last row (col 1 holds the time). We store the `number_of_paths` samples of the share price at $T_{2}$ in the `endpoint_samples::Array{Float64,1}` variable.

So what do we get?

Output:
```
The mean projected price for GBM: 534.7787839167826
```

#### Check: Are future GBM share prices log-normally distributed?
We expect geometric Brownian motion to generate __log-normally distributed__ share prices. We can check this expectation by performing an [exact one-sample Kolmogorov-Smirnov test](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Kolmogorov-Smirnov-test) on the samples and the log-normal distribution that geometric Brownian motion predicts.
> __Hypothesis:__ The `H0:null hypothesis` for the test is the data (endpoint samples generated using geometric Brownian motion) comes from the LogNormal distribution `d_gbm`. The alternative hypothesis `H1:alternative` is the samples are not drawn from `d_gbm`.

Under geometric Brownian motion, $\ln S(T)$ is normal with mean $\ln S_{0}+(\mu-\sigma^{2}/2)T$ and standard deviation $\sigma\sqrt{T}$. Let's build this [LogNormal distribution exported by the Distributions.jl package](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.LogNormal) and save it in the `d_gbm::LogNormal` variable:

Next, execute [the exact one-sample Kolmogorov–Smirnov test](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#HypothesisTests.ExactOneSampleKSTest) and check the [pvalue](https://en.wikipedia.org/wiki/P-value). A large p-value means we fail to reject the `H0:null hypothesis`: the `endpoint_samples` are consistent with `d_gbm`.

Output:
```
Exact one sample Kolmogorov-Smirnov test
----------------------------------------
Population details:
    parameter of interest:   Supremum of CDF differences
    value under h_0:         0.0
    point estimate:          0.00342404

Test summary:
    outcome with 95% confidence: fail to reject h_0
    two-sided p-value:           0.6009

Details:
    number of observations:   50000
```

`Unhide` the code block below to see how we plotted the future share price of `AMD` generated using a risk-neutral single asset geometric Brownian motion model parameterized using the implied volatility.
> __What do we see?__ The geometric Brownian motion generates future share prices that are [log-normally distributed](https://en.wikipedia.org/wiki/Log-normal_distribution) (blue line), and the log-normal distribution `d_gbm` (red line) describes them, consistent with the check above.

What do the simulated share prices at expiration look like?

### Alternative: Future share price projection using implied volatility
Alternatively, we could use the __implied volatility__ to estimate the expected share price move over the time to expiration $T$ (years).
Suppose we construct a [Normal distribution](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Normal) $\mathcal{N}(\mu_{IV},\sigma_{IV})$ whose mean $\mu_{IV} = S_{0}\exp(g_{y}T)$ is the share price grown at the risk-free rate, or just $\mu_{IV}\approx{S}_{0}$ for short duration contracts, and whose standard deviation $\sigma_{IV}$ is:
$$
\sigma_{IV} = S_{0}\cdot\text{IV}\cdot\sqrt{T}
$$
where IV is the at-the-money implied volatility (decimal). We use the [Normal type exported by the Distributions.jl package](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Normal). This is only an approximate model of the future share price; it has a couple of issues: 
> __Watch out!__ This model assumes a [Normal distribution](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Normal), which is problematic because it can emit negative share prices. One way to fix this issue is to use a [Truncated Normal distribution](https://juliastats.org/Distributions.jl/stable/truncate/#Truncated-Distributions) instead.

However, despite the potential issues, this model is __widely__ used to generate quick estimates of future share price ranges using the forward-looking implied volatility. Let's save the Normal IV distribution $\mathcal{N}(\mu_{IV},\sigma_{IV})$ in the `d_IV::Normal` variable:

Output:
```
Normal{Float64}(μ=534.4545050434095, σ=113.71114807827765)
```

`Unhide` the code block below to see how we plotted the `d_gbm::LogNormal` and `d_IV::Normal` future share price densities at expiration.  

> __What do we see?__ Both distributions have the same mean (black dashed line), the share price grown at the risk-free rate. The Normal IV distribution (red line) is symmetric and can admit negative share prices, albeit with a small probability. The log-normal GBM distribution (blue line) is right-skewed, so it peaks at a lower share price (blue dotted line) and cannot admit negative share prices.

How do the two distributions compare?

### Probability of Profit (POP)
> __Probability of Profit (POP) for Short Strangle__ 
> 
> The POP for a short strangle position is the probability that the future share price at expiration $S(T)$ is between the lower breakeven point $S^{\ddagger}_{-}$ and the upper breakeven point $S^{\ddagger}_{+}$:
> $$
\begin{align*}
\text{POP} &= \mathbb{P}(S^{\ddagger}_{-} < S(T) < S^{\ddagger}_{+}) \\
& = F_{S}(S^{\ddagger}_{+}) - F_{S}(S^{\ddagger}_{-})
\end{align*}
$$
> where $F_{S}(x)$ is the cumulative distribution function (CDF) of the future share price at expiration, i.e., $F_{S}(x) = \mathbb{P}(S(T) \leq x)$.

### Probability of Exercise (POE) and Our Belief
Each leg has its own probability of exercise. The put is exercised if $S(T)<K_{1}-0.01$ and the call if $S(T)>K_{2}+0.01$, so $\text{POE}_{p}=F_{S}(K_{1}-0.01)$ and $\text{POE}_{c}=1-F_{S}(K_{2}+0.01)$.

So far, we used the risk-neutral probabilities $\mathbb{Q}$, the probabilities inside the market price. Our belief $\mathbb{P}$ uses the SAGBM parameters instead: geometric Brownian motion with drift $\hat{\mu}=\hat{\mu}_{g}+\hat{\sigma}^{2}/2$ and volatility $\hat{\sigma}$, where $\hat{\mu}_{g}$ (the `drift` column) and $\hat{\sigma}$ (the `volatility` column) are the AMD estimates we loaded earlier. Let's compute the POP of our position and each leg's POE for five distributions of the share price at expiration:
* __Our belief $\mathbb{P}$:__ log-normal, with drift $\hat{\mu}$ and volatility $\hat{\sigma}$.
* __Risk-neutral $\mathbb{Q}$:__ log-normal, with drift $g_{y}$ and the at-the-money implied volatility, the distribution `d_gbm` above.
* __Two mixed cases:__ the historical drift $\hat{\mu}$ with the implied volatility, and the risk-free rate $g_{y}$ with the historical volatility $\hat{\sigma}$. Each changes one input of $\mathbb{Q}$, so we can see which input moves the probabilities.
* __Normal IV:__ the quick approximation `d_IV` above, close to $\mathbb{Q}$ but not log-normal.

So what do we get?

Output:
```
 ---------------------------------------- ---------------------- --------- ----------
  distribution of S(T)                     POP (short strangle)   POE put   POE call 
 ---------------------------------------- ---------------------- --------- ----------
  our belief ℙ                                           0.7384    0.1512     0.2776
  historical drift, implied volatility                   0.6655    0.2004     0.2984
  risk-neutral ℚ                                         0.6714    0.3108     0.1906
  risk-free drift, historical volatility                 0.7534    0.2674     0.1585
  Normal IV (approximates ℚ)                             0.6811    0.2854     0.2004
 ---------------------------------------- ---------------------- --------- ----------
our belief ℙ: μ̂_g = 0.4397, σ̂ = 0.4743, μ̂ = 0.5521 (1/yr)
risk-neutral ℚ: gᵧ = 0.0413 (1/yr), ATM IV = 0.5617
```

> __What do we see?__
>
> * __The POP:__ Our belief $\mathbb{P}$ gives the short strangle a higher POP than $\mathbb{Q}$. The two mixed rows show why: the lower historical volatility alone raises the POP, and the larger historical drift alone lowers it. Here the volatility wins.
> * __The POE:__ The rows with the historical drift $\hat{\mu}$ shift the share price up. Compared with $\mathbb{Q}$, they make the call more likely, and the put less likely, to be exercised.
> * __The Normal IV approximation:__ It gives nearly the same POP as $\mathbb{Q}$, but it tilts the POE toward the call. A Normal distribution is symmetric about its mean, while the log-normal distribution puts its median below its mean.

`Unhide` the code block below to see how we plotted the cumulative distribution function $F_{S}(x)$ of each distribution in the table. 

The POP of the short strangle is the rise of a curve between the breakevens $S^{\ddagger}_{-}$ and $S^{\ddagger}_{+}$, the put's POE is the height of a curve at $K_{1}$, and the call's POE is one minus the height at $K_{2}$. The dashed lines read the heights of $\mathbb{P}$ and $\mathbb{Q}$ across to the probability axis.

> __What do we see?__ The curves with the historical drift $\hat{\mu}$ (navy and orange lines) sit to the right of $\mathbb{Q}$ (blue line), so they are lower at both strikes (purple lines): the put is less likely, and the call more likely, to be exercised. The curves with the historical volatility $\hat{\sigma}$ (navy and gray lines) are steeper between the breakevens (green lines), so they give a higher POP.

How do the cumulative distributions compare?

___

## Task 3: Did we make money on the strangle?
In this task, we close our short strangle after AMD's earnings release and compute the profit or loss.

> __Earnings Release:__ [AMD reports its third-quarter 2026 results](https://ir.amd.com/news-events/press-releases/detail/1300/amd-to-report-fiscal-third-quarter-2026-financial-results) on `2026-11-03` after market close, after we priced the contracts on `2026-10-26`. Earnings releases can move the share price sharply in either direction. A short strangle profits if the share price stays between the breakevens.

The release comes weeks before expiration, so both legs still carry extrinsic value, and the breakevens alone cannot tell us whether we made money. To close a short strangle, we buy both legs back at that day's premiums, $\mathcal{P}^{\prime}_{p}$ and $\mathcal{P}^{\prime}_{c}$. If we close $\tau$ years after we opened, the profit per share is:
$$
\hat{P}_{\mathcal{C}}(\tau) = \mathcal{D}_{\tau,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})-(\mathcal{P}^{\prime}_{p}+\mathcal{P}^{\prime}_{c})
$$
where $\mathcal{D}_{\tau,0}(g_{y})=e^{g_{y}\tau}$. The profit is the premiums we collected, grown to the closing day, minus the cost to buy both legs back.

Until the release, `post_release_ticker` is `missing` and the cells below print a pending message. After the release, download the AMD chain for the same expiration, save it as a new dataset, set `post_release_ticker` to its name, and rerun this task.

What is our profit or loss if we close the strangle after the release?

Output:
```
Pending: set post_release_ticker after the 2026-11-03 earnings release and rerun this task.
```

___

## Summary
In this example, we sold a strangle on AMD before its earnings release, computed its profit at expiration and its breakevens, and computed its probability of profit and each leg's probability of exercise under our belief and under the risk-neutral probabilities.

> __Key Takeaways:__
>
> * __Strangles have two breakeven points:__ We computed the profit at expiration of the short strangle as the credit grown to expiration minus the payoffs of both legs. It breaks even at the put strike minus, and the call strike plus, the premiums grown to expiration, and the short strangle profits only when the share price finishes between these two points. Setting $K_{1}=K_{2}$ gives the straddle.
> * __The probability of profit depends on whose probabilities we use:__ We computed the POP of the short strangle and each leg's POE from log-normal share prices under our belief $\mathbb{P}$ and under the risk-neutral probabilities $\mathbb{Q}$. Changing one input at a time showed that the lower historical volatility raised the POP under $\mathbb{P}$, while the larger historical drift made the call more likely, and the put less likely, to be exercised than under $\mathbb{Q}$.
> * __Closing early costs the extrinsic value left in the legs:__ We wrote the profit from closing after the earnings release as the credit grown to that day minus the cost to buy both legs back. Before expiration, those premiums still include extrinsic value, so the profit depends on the premiums when we close, not only on where the share price is relative to the breakevens.

Selling a strangle collects less credit than selling a straddle near the share price, but it keeps that credit over a wider range of share prices.
___
