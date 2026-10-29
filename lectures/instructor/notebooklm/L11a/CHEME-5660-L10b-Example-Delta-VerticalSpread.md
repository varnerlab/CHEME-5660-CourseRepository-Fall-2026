# Example: Analysis of Put Credit Vertical Spreads
In this example, we will analyze vertical bullish credit spreads. These are directional options strategies that involve selling a higher strike put and buying a lower strike put, the high-strike is near the money and the low-strike is out of the money.

> __Learning Objectives:__
> 
> By the end of this example, you will be able to:
> * __Compute the profit of a put credit spread:__ Combine a short put at the higher strike and a long put at the lower strike into one profit at expiration, and compute the spread's maximum profit, maximum loss, and breakeven share price.
> * __Estimate the probability of profit:__ Project the share price at expiration with geometric Brownian motion, and compute the probability that the spread finishes above its breakeven, under our belief $\mathbb{P}$ and under the risk-neutral probabilities $\mathbb{Q}$.
> * __Estimate each leg's probability of exercise:__ Compute the probability that each put finishes in the money under $\mathbb{P}$ and $\mathbb{Q}$, and explain why the short put is more likely to be exercised than the long put.

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
   9 │    45.0     0.9153   484.25   486.7    489.15   425.63       0  101     ⋯
  10 │    50.0     0.9059   479.15   481.65   484.15   558.43       0  210
  11 │    55.0     0.8965   474.2    476.7    479.2    526.5        0  51
  ⋮  │    ⋮         ⋮         ⋮        ⋮        ⋮        ⋮       ⋮        ⋮    ⋱
 293 │  1220.0     1.2953   686.4    688.88   691.35     0.0        0  0
 294 │  1230.0     1.3141   696.4    698.88   701.35     0.0        0  0       ⋯
 295 │  1240.0     1.3329   706.25   709.1    711.95     0.0        0  0
 296 │  1250.0     1.3517   716.4    719.18   721.95     0.0        0  0
 297 │  1260.0     1.3706   726.4    728.88   731.35     0.0        0  0
 298 │  1270.0     1.3894   736.4    739.18   741.95     0.0        0  0       ⋯
 299 │  1280.0     1.4082   746.4    748.88   751.35     0.0        0  0
 300 │  1290.0     1.427    756.4    759.18   761.95     0.0        0  0
 301 │  1300.0     1.4458   766.4    769.18   771.95     0.0        0  0
 302 │  1310.0     1.4646   776.4    778.88   781.35     0.0        0  0       ⋯
                                                  4 columns and 281 rows omitted
```

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, permissible values, etc. 

In this example, we'll need to do a projection of the future share price distribution at the contract's expiration date. We'll use a Geometric Brownian Motion (GBM) model to project the future share price distribution at expiration.

Let's load the single asset geometric Brownian motion (SAGBM) parameters which we estimated a few lectures ago, which include the drift and diffusion coefficients for each ticker. We'll store this data in the `parameters_df::DataFrame` variable:

We are looking at `AMD`, so let's see what the parameters for this ticker are:

### Contract models
Next, we construct contract models for the options in this example. We begin by building an instance of the [MyAmericanPutContractModel type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyAmericanPutContractModel) using the [custom build(...) method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.build-Tuple{Type{MyAmericanPutContractModel},%20NamedTuple}). 

The [build(...) method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.build-Tuple{Type{MyAmericanPutContractModel},%20NamedTuple}) takes two arguments: the type to build, and a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple) containing the strike price `K`, the `premium` paid for the option, the days to expiration `DTE` (units: years), the `sense` parameter (1 for long, -1 for short), the number of contracts in the `copy` field and the implied volatility in the `IV` field.

We save the __short__ put option contract model, at the higher strike price $K_{2}$, in the `put_contract_model_short::MyAmericanPutContractModel` variable:

Output:
```
MyAmericanPutContractModel(520.0, -1, 0.1452054794520548, 0.5619, 38.1, nothing, 1)
```

Next, let's build the __long__ put option contract model for the lower strike price $K_{1}$ in the vertical spread. Let's save the long put option contract model in the `put_contract_model_long::MyAmericanPutContractModel` variable:

Output:
```
MyAmericanPutContractModel(500.0, 1, 0.1452054794520548, 0.5669, 29.35, nothing, 1)
```

___

## Task 1: Compute Profit, Loss and Breakeven Points
In this task, we compute the profit and loss (P&L) profile for the vertical credit spread position at expiration, as well as the breakeven point.

A put vertical spread is constructed by combining 2 $\times$ put contracts, a short put contract generates income while the long put contract controls downside risk. This trade has a bullish outlook on the underlying asset.

> __Bullish put credit spread:__
>
> Let's build a bullish put credit spread for AMD whose current share price is $S(0) = 531.26$ USD/share. This trade structure is constructed by buying (long) a put with strike $K_{1}$ and selling (short) a put with the higher strike $K_{2}$.
>
> * Leg 1: The strike price for the long put leg is given by $K_{1}$ = 500 USD/share with DTE = 53 days
> * Leg 2: The strike price for the short put leg is given by $K_{2}$ = 520 USD/share with DTE = 53 days
>
> This trade will generate a net credit when opened. Depending on the share price at expiration, the trade can result in a profit or loss. The maximum profit occurs when the share price at expiration is above the higher strike price $K_{2}$. The maximum loss occurs when the share price at expiration is below the lower strike price $K_{1}$.


### Profit and Breakeven Analysis for Put Vertical Spread
Let contract $i$ have a strike price of $K_{i}$ and premium $\mathcal{P}_{i}$, numbered from low to high: contract 1 is the long leg ($\theta_{1} = 1$) and contract 2 the short leg ($\theta_{2} = -1$), where $K_{1} < K_{2} < S_{0}$. The share price at expiration is given by $S(T)$, and $\mathcal{D}_{T,0}(g_{y})$ is the accumulation factor from today to expiration. Then, the profit for a single put vertical spread at expiration is given by:

$$
\hat{P}_{\mathcal{C}} = \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{2} - \mathcal{P}_{1}\right) - \left(K_{2} - S(T)\right)^{+} + \left(K_{1} - S(T)\right)^{+}
$$

where $V_{p}(K,S(T)) = (K-S(T))^{+}=\max(K-S(T),0)$ is the payoff function for a put contract. The first term is the credit received, grown to expiration, and the others are the leg payoffs. The maximum possible profit, loss, and breakeven conditions are given by:

* The maximum possible profit of $\mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{2} - \mathcal{P}_{1}\right)$ will occur when $S(T)\geq{K_{2}}$.
* The maximum possible loss of $\left(K_{2} - K_{1}\right) - \mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{2} - \mathcal{P}_{1}\right)$ will occur when $S(T)\leq{K_{1}}$.
* The put credit spread will breakeven when $S(T) = S^{\ddagger} = K_{2}-\mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{2} - \mathcal{P}_{1}\right)$.

Let's visualize the profit at expiration:

The breakeven point can be calculated by setting the profit function equal to zero and solving for $S(T)$. Let's show it with the maximum profit and the maximum loss:

Output:
```
 --------------------------- -------- -----------
  quantity                     value   units     
 --------------------------- -------- -----------
  maximum profit, S(T) ≥ K₂     8.80   USD/share
  breakeven S‡                511.20   USD/share
  maximum loss, S(T) ≤ K₁      11.20   USD/share
 --------------------------- -------- -----------
```

___

## Task 2: Compute the Probability of Profit (POP) and the Probability of Exercise (POE)
In this task, we compute the Probability of Profit (POP) of the put credit spread and the Probability of Exercise (POE) of each leg at expiration.

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

`Unhide` the code block below to see how we plotted the `d_gbm::LogNormal` and `d_IV::Normal` future share price densities at `T = 53 days`.  

> __What do we see?__ The log-normal GBM share price distribution (blue line) is right-skewed and cannot admit negative share prices. However, the Normal IV distribution (red line) is symmetric around the mean future share price and can admit negative share prices, albeit with a small probability.

How do the two distributions compare?

### Probability of Profit (POP)
The POP for a put credit spread is the probability that the future share price at expiration $S(T)$ is larger than the breakeven point $S^{\ddagger}$:
$$
\begin{align*}
\text{POP} &= \mathbb{P}(S(T) > S^{\ddagger}) \\
& = 1 - F_{S}(S^{\ddagger})
\end{align*}
$$
where $F_{S}(x)$ is the cumulative distribution function (CDF) of the future share price at expiration, i.e., $F_{S}(x) = \mathbb{P}(S(T) \leq x)$.

### Probability of Exercise (POE)
The long put is exercised if the share price at expiration is below its strike price, $S(T)<K_{1}-0.01$, and the short put if $S(T)<K_{2}-0.01$. Since $K_{1}<K_{2}$, if the long put finishes in the money, so does the short put:
$$
\text{POE}_{1} = F_{S}(K_{1}-0.01) \qquad \text{POE}_{2} = F_{S}(K_{2}-0.01)
$$

Let's compute the POP and each leg's POE for three distributions of the share price at expiration:
* __Our belief $\mathbb{P}$:__ log-normal, with drift $\hat{\mu}=\hat{\mu}_{g}+\hat{\sigma}^{2}/2$ and volatility $\hat{\sigma}$, where $\hat{\mu}_{g}$ (the `drift` column) and $\hat{\sigma}$ (the `volatility` column) are the AMD estimates we loaded earlier.
* __Risk-neutral $\mathbb{Q}$:__ log-normal, with drift $g_{y}$ and the at-the-money implied volatility, the distribution `d_gbm` above.
* __Normal IV:__ the quick approximation `d_IV` above, close to $\mathbb{Q}$ but not log-normal.

So what do we get?

Output:
```
 ---------------------------- -------- ------------------- ------------------
  distribution of S(T)            POP   POE short put, K₂   POE long put, K₁ 
 ---------------------------- -------- ------------------- ------------------
  our belief ℙ                 0.7144              0.3185             0.2454
  risk-neutral ℚ               0.5402              0.4916             0.4190
  Normal IV (approximates ℚ)   0.5810              0.4494             0.3809
 ---------------------------- -------- ------------------- ------------------
our belief ℙ: μ̂_g = 0.4397, σ̂ = 0.4743, μ̂ = 0.5521 (1/yr)
risk-neutral ℚ: gᵧ = 0.0413 (1/yr), ATM IV = 0.5617
```

> __What do we see?__
>
> * __The POP:__ Our belief $\mathbb{P}$ gives the spread a much higher POP than $\mathbb{Q}$. Its drift $\hat{\mu}$ is much larger than $g_{y}$, and its volatility $\hat{\sigma}$ is lower than the implied volatility, so $\mathbb{P}$ puts less probability below the breakeven.
> * __The POE:__ In every row, the short put is more likely to be exercised than the long put, because its strike price is higher. Under $\mathbb{Q}$, the short put finishes in the money about half the time.
> * __POP and POE:__ In every row, the POP is larger than one minus the short put's POE. The breakeven sits below $K_{2}$, so the spread still makes money when the share price finishes just below $K_{2}$.

`Unhide` the code block below to see how we plotted the cumulative distribution function $F_{S}(x)$ of each distribution in the table. The POP is one minus the height of a curve at the breakeven $S^{\ddagger}$, and each leg's POE is the height of a curve at its strike price. The dashed lines read the heights of $\mathbb{P}$ and $\mathbb{Q}$ across to the probability axis.

> __What do we see?__ Around the strikes (purple lines), our belief $\mathbb{P}$ (navy line) lies to the right of the other two curves, so it puts less probability below the breakeven $S^{\ddagger}$ (green line) and gives the higher POP in the table. The risk-neutral $\mathbb{Q}$ (blue line) and Normal IV (red line) curves stay close, and the Normal IV curve is higher at the lowest share prices because a Normal distribution is symmetric about its mean.

How do the cumulative distributions compare?

___

## Summary
In this example, we built a put credit spread on AMD and computed its profit at expiration and breakeven, its probability of profit, and each leg's probability of exercise, under our belief and under the risk-neutral probabilities.

> __Key Takeaways:__
>
> * __Put vertical spreads have defined risk and reward boundaries:__ We computed the maximum profit as the credit grown to expiration, earned when the share price stays above the higher strike, and the maximum loss as the difference between the strike prices minus that credit, reached when the share price falls below the lower strike.
> * __Our belief gives a higher probability of profit than $\mathbb{Q}$:__ We computed the probability of profit above the breakeven under our belief $\mathbb{P}$ and under the risk-neutral probabilities $\mathbb{Q}$. Our belief's large drift and lower volatility gave a much higher probability of profit.
> * __The short put is more likely to be exercised:__ We computed each leg's probability of exercise under $\mathbb{P}$ and $\mathbb{Q}$. In every case, the short put, with the higher strike, was more likely to be exercised than the long put.

Understanding put vertical spreads enables traders to generate income while limiting downside risk in bullish market conditions.
___
