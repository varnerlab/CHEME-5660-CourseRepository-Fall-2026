# Example: Analysis of Covered Call Positions on AMD
In this example, we analyze a covered call position on Advanced Micro Devices, Inc. (AMD) using our `AMD` options chain. A covered call is a strategy in which equity is purchased and call contracts are sold on a share-for-share basis against the equity.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Compute the profit of a covered call:__ Combine long shares with a short call into one profit at expiration, and compute the breakeven, maximum profit, and maximum loss.
> * __Estimate the probabilities of the outcomes:__ Simulate the share price at expiration with geometric Brownian motion under the risk-neutral probabilities $\mathbb{Q}$, and compute the probabilities of a loss, of the maximum profit, and of an opportunity loss under $\mathbb{Q}$ and under our belief $\mathbb{P}$.
> * __Evaluate the opportunity loss:__ Find the share price above which holding the shares alone earns more than the covered call, and compare the probability of passing it with the probability of the maximum profit.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/). 

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Data
To start, load the options data using [the `MyOptionsChainDataSet(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyOptionsChainDataSet) and store the metadata in the `metadata::Dict{String,Any}` variable and the options chain data in the `optionschain::DataFrame` variable.

Output:
```
Dict{String, Any} with 10 entries:
  "DTE"                        => "53"
  "purchase_date"              => "2026-10-26"
  "historical_volatility"      => "0.5659"
  "underlying_share_price_ask" => "532.00"
  "source"                     => "barchart.com"
  "underlying_share_price_bid" => "531.30"
  "is_weekly"                  => false
  "atm_IV"                     => "0.5617"
  "expiration_date"            => "2026-12-18"
  "underlying_share_price_mid" => "531.26"
```

What's in the `metadata::Dict{String,Any}` dictionary? 

Output:
```
 ---------------------------- --------------
  field                        value        
  String                       String       
 ---------------------------- --------------
  DTE                          53
  atm_IV                       0.5617
  expiration_date              2026-12-18
  historical_volatility        0.5659
  is_weekly                    false
  purchase_date                2026-10-26
  source                       barchart.com
  underlying_share_price_ask   532.00
  underlying_share_price_bid   531.30
  underlying_share_price_mid   531.26
 ---------------------------- --------------
```

What about the `optionschain::DataFrame` variable? The `Moneyness` column comes from Barchart and measures how far each option is in the money (positive) or out of the money (negative); in this course, moneyness is $K/S(0)$.

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

To compare the risk-neutral probabilities with our belief about the share price, let's load the single-asset geometric Brownian motion (SAGBM) parameters we estimated a few lectures ago, which include the drift and volatility for each ticker. We'll store this data in the `parameters_df::DataFrame` variable:

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

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, and permissible values. 

___

## Task 1: Select a Random Call Option from the Dataset
In this task, we'll select call option contracts such that $S(0)<K\leq\left(1+w\right)\cdot{S(0)}$ where $w>0$, and we purchase the counter asset, in this case shares, from the market at $S(0)$. Let's begin by filtering the contracts in the `optionschain::DataFrame` to include only `call` contracts that obey the strike price constraint.

> __Assumption:__ We assume that we are purchasing shares at the current share price $S(0)$, stored in `Sₒ::Float64`, from the market, and then immediately selling call contracts with strike prices `K::Float64` that are out-of-the-money (OTM), i.e., $S(0)<K\leq\left(1+w\right)\cdot{S(0)}$ where $w>0$ is a small width parameter.
> 
> __Note:__ If we already owned the shares, say at $S^{\dagger} \leq S(0)$, then the analysis would be slightly different since our cost basis would be $S^{\dagger}$ instead of $S(0)$.

Save the filtered selection of `call` contracts in the `call_contracts::DataFrame` variable:

Output:
```
16×11 DataFrame
 Row │ Strike   Moneyness  Bid      Mid      Ask      Last     Volume  Open In ⋯
     │ Float64  Float64    Float64  Float64  Float64  Float64  Int64   String7 ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │   540.0    -0.016     42.3     42.93    43.55    42.95     373  880     ⋯
   2 │   550.0    -0.0348    38.0     38.65    39.3     38.65     309  2,625
   3 │   560.0    -0.0536    34.0     34.65    35.3     35.35     358  1,120
   4 │   570.0    -0.0724    30.9     31.25    31.6     32.08     116  1,091
   5 │   580.0    -0.0912    26.95    27.63    28.3     28.1      192  1,440   ⋯
   6 │   590.0    -0.11      24.55    24.85    25.15    25.3      155  714
   7 │   600.0    -0.1288    21.8     21.98    22.15    21.9      296  6,242
   8 │   610.0    -0.1477    19.3     19.55    19.8     19.97      97  2,594
   9 │   620.0    -0.1665    17.1     17.33    17.55    17.37     153  2,118   ⋯
  10 │   630.0    -0.1853    15.1     15.3     15.5     15.3      330  3,384
  11 │   640.0    -0.2041    13.3     13.5     13.7     13.53     126  2,780
  12 │   650.0    -0.2229    11.65    11.85    12.05    11.69     254  2,946
  13 │   660.0    -0.2417    10.25    10.4     10.55    10.85     145  1,927   ⋯
  14 │   670.0    -0.2605     9.0      9.18     9.35     9.3       38  1,135
  15 │   680.0    -0.2793     7.9      8.05     8.2      8.15     156  1,893
  16 │   690.0    -0.2982     6.85     7.05     7.25     7.15      51  957
                                                               4 columns omitted
```

Select a random contract from the `call_contracts::DataFrame` collection. We fix the random seed, so every run picks the same call; change `5660` to pick another. Save the data for this contract in the `call_leg_data::DataFrameRow` variable:

Output:
```
DataFrameRow
 Row │ Strike   Moneyness  Bid      Mid      Ask      Last     Volume  Open In ⋯
     │ Float64  Float64    Float64  Float64  Float64  Float64  Int64   String7 ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   4 │   570.0    -0.0724     30.9    31.25     31.6    32.08     116  1,091   ⋯
                                                               4 columns omitted
```

Next, build a [`MyAmericanCallContractModel` instance](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyAmericanCallContractModel) using the call contract data and store this contract model in the `call_contract_model::MyAmericanCallContractModel` variable. 

To access data from the `DataFrameRow`, pass in the column name. For example, to get the strike price, you would say: `call_leg_data[:Strike]`. For the premium value, use the midpoint value.

Finally, let's build a model of the equity counter asset, i.e., the shares for our covered call. One call contract covers `100` shares, so we own `100` shares of `AMD` for each contract we sell. We compute the profit per share, so the equity model holds one share.

We'll store this equity model in the `my_equity_model::MyEquityModel` variable, which is an instance of [the `MyEquityModel` type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyEquityModel):

Output:
```
MyEquityModel("AMD", 531.26, 531.26, 1, 1)
```

___

## Task 2: Analysis of the Profit and Loss of the Covered Call at Expiration
In this task, let's compute the breakeven point on this position and the profit and loss diagram for the covered call position at expiration. The covered call consists of long shares and a short-call contract. The profit expression (per share for a single covered call instance) is given by:
$$
\begin{align*}
\hat{P}(S(T)) &= S(T) - \left(S(T) - K\right)^{+} - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) - \mathcal{P}_{c}\right)\\
&= \underbrace{\left(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot S(0)\right)}_{\text{shares}} + \underbrace{\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} - \left(S(T) - K\right)^{+}}_{\text{short call}}
\end{align*}
$$
where $(S(T) - K)^{+} \equiv \max(S(T) - K,0)$ is the call payoff. The deal flow for different share prices at expiration (assuming no cash position, no extra shares owned, and no extrinsic value at expiration) can be written (on a per share basis) as:
$$
\boxed{
\begin{align*}
\hat{P}(S(T)) &= \begin{cases}
\overbrace{K - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) - \mathcal{P}_{c}\right)}^{\text{realized gain}}, & \text{if } S(T) > K\;\text{(call exercised)}\\
\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} + \underbrace{\left(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot S(0)\right)}_{\text{unrealized gain (no share sale)}}, & \text{if } S(T) \leq K\;\text{(call expires worthless)}
\end{cases}
\end{align*}}
$$
If we already owned the shares at a cost basis $S^{\dagger}$, the realized gain on the shares when the call is exercised is $K-S^{\dagger}$. The max profit, max loss, and breakeven point are given by (maximum losses are listed as positive amounts):

Let's make a pretty table:

Output:
```
 -------------------------- -------- -----------
  quantity                    value   units     
 -------------------------- -------- -----------
  maximum profit, S(T) ≥ K    66.98   USD/share
  breakeven S‡               503.02   USD/share
  maximum loss, S(T) = 0     503.02   USD/share
 -------------------------- -------- -----------
```

### Visualize
Now that we have analytically computed the maximum profit, maximum loss, and breakeven values, let's visualize the profit diagram at expiration for the covered call. To do this, build an array of share prices at expiration and save this in the `share_price_array::Array{Float64,1}` variable. 

We'll look at share prices at expiration from `range_width*Sₒ` to `(2 - range_width)*K`, where `0 < range_width < 1` sets how far the range extends below $S(0)$ and above $K$.

Finally, compute the profit for the covered call. We compute the profit by [calling the `profit(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.profit) and save the profit values in the `profit_array` variable. The [`profit(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.profit) takes the contract models as an array, the equity model, the share price array, and the accumulation factor `𝒟` as a keyword argument.

The `profit_array` will be a `1001`$\times$`4` array, in which each row is a possible value for the share price at expiration $S(T)$. Column `1` holds the possible $S(T)$ values, column `2` holds the profit for the short call, column `3` holds the profit for the shares, and column `4` holds the overall profit for the composite trade. The shares alone break even at $\mathcal{D}_{T,0}(g_{y})\cdot S(0)$, the purchase price grown to expiration, not at $S(0)$; the navy dot marks this point.

Output:
```
1001×4 Matrix{Float64}:
 425.008   31.4379  -109.447  -78.0086
 425.267   31.4379  -109.188  -77.7496
 425.526   31.4379  -108.929  -77.4906
 425.785   31.4379  -108.67   -77.2316
 426.044   31.4379  -108.411  -76.9726
 426.303   31.4379  -108.152  -76.7136
 426.562   31.4379  -107.893  -76.4546
 426.821   31.4379  -107.634  -76.1957
 427.08    31.4379  -107.375  -75.9367
 427.339   31.4379  -107.116  -75.6777
   ⋮                          
 681.928  -80.4902   147.474   66.9834
 682.187  -80.7491   147.733   66.9834
 682.446  -81.0081   147.992   66.9834
 682.705  -81.2671   148.251   66.9834
 682.964  -81.5261   148.51    66.9834
 683.223  -81.7851   148.769   66.9834
 683.482  -82.0441   149.028   66.9834
 683.741  -82.3031   149.287   66.9834
 684.0    -82.5621   149.545   66.9834
```

___

## Task 3: Probability of Outcomes
In this task, let's compute the probability of observing exit scenarios for our covered call position on `AMD`. We'll consider three scenarios:

> __Scenarios:__
>
> * __Scenario 1: Loss__. In this scenario, the share price at expiration $S(T)$ is below the breakeven $S^{\ddagger}$ (stored as `B` in the code). The probability of this scenario occurring is given by $\mathbb{P}(S(T)<S^{\ddagger}) = F_{S}\left(S^{\ddagger}\right)$.
> * __Scenario 2: Maximum profit__. In this scenario, the share price at expiration $S(T)$ is at or above the strike price $K$, so the call caps the profit. The probability of this scenario occurring is given by $\mathbb{P}(S(T)\geq K) = \mathbb{P}(S(T)>K) = 1 - F_{S}\left(K\right)$.
> * __Scenario 3: Upside opportunity loss__. In this scenario, the share price at expiration $S(T)$ is above the alternative opportunity point $O^{+}=K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$ (stored as `OP` in the code), the share price above which holding the shares alone earns more than the covered call. The probability of this scenario occurring is given by $\mathbb{P}(S(T)>O^{+}) = 1 - F_{S}\left(O^{+}\right)$.

To start, let's build a model of the future underlying share price at expiration $S(T)$. Build an instance of the [MyGeometricBrownianMotionEquityModel type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.MyGeometricBrownianMotionEquityModel) which holds values for the drift `μ` and volatility `σ` parameters using a [custom build(...) method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.build-Tuple{Type{MyGeometricBrownianMotionEquityModel},%20NamedTuple}). 

We'll save the model in the `model::MyGeometricBrownianMotionEquityModel` variable, and the implied volatility value in the `IV::Float64` variable.

Now that we have a populated [MyGeometricBrownianMotionEquityModel instance](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.MyGeometricBrownianMotionEquityModel) holding the `AMD` data, let's generate `number_of_samples` possible future share price values using the [sample(...) function exported by the VLQuantitativeFinancePackage.jl package](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.sample-Tuple{MyGeometricBrownianMotionEquityModel,%20NamedTuple}).
* The [sample method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.sample-Tuple{MyGeometricBrownianMotionEquityModel,%20NamedTuple}) takes a `model::MyGeometricBrownianMotionEquityModel` instance as the first argument, along with the time values that we wish to sample: `T₁::Float64` is the start time, `T₂::Float64` is the stop time (in units of `years`), `Δt::Float64` is the time step (in units of `years`), and `Sₒ::Float64` denotes the initial share price (in units of `USD/share`). Finally, we pass in the number of samples we want to generate in the `number_of_paths` argument.
* The [sample method](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/equity/#VLQuantitativeFinancePackage.sample-Tuple{MyGeometricBrownianMotionEquityModel,%20NamedTuple}) generates `number_of_paths` sample paths from $T_{1}\rightarrow{T}_{2}$ in steps of $\Delta{t}$. However, we only want the share prices corresponding to the duration of the contract, i.e., $T_{2} = \text{DTE}\cdot\Delta{t}$ (years). Thus, we pass the full `samples` array [using the Julia pipe operator](https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping) to a slicing operation where we select columns `2:end` of the last row (col 1 holds the time). We store the `number_of_paths` samples of the share price at $T_{2}$ in the `endpoint::Array{Float64,1}` variable.

So what do we get?

We've previously shown that sampling a GBM model produces a LogNormal share price distribution. Fit a [LogNormal distribution exported by the Distributions.jl package](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.LogNormal) using the [fit_mle(...) function exported by Distributions.jl](https://juliastats.org/Distributions.jl/stable/fit/#Distributions.fit_mle-Tuple{Any,%20Any}), and save this in the `d_gbm::LogNormal` variable.

### Risk-neutral probabilities $\mathbb{Q}$
Next, estimate [the cumulative distribution function (CDF)](https://en.wikipedia.org/wiki/Cumulative_distribution_function) for the risk-neutral share price distribution. 
We can query the cumulative distribution function $F_{S}(\star)$ for the risk-neutral distribution `d_gbm` using [the `cdf(...)` function exported by the Distributions.jl package](https://github.com/JuliaStats/Distributions.jl?tab=readme-ov-file).

Now that we have the cumulative distribution function for the risk-neutral share price distribution, let's compute the probability of observing each of the three scenarios outlined above.

> __Scenario 1: Loss__. In this scenario, the share price at expiration $S(T)$ is below the breakeven $S^{\ddagger}$. The probability of this scenario occurring is given by $\mathbb{P}(S(T)<S^{\ddagger}) = F_{S}\left(S^{\ddagger}\right)$.

Let's save the probability of this scenario occurring in the `p_downside_loss_gbm::Float64` variable.

Output:
```
Scenario 1: Probability of loss under ℚ = 0.4279590930164055
```

Next, let's compute the probability of maximum profit.

> __Scenario 2: Maximum profit__. In this scenario, the share price at expiration $S(T)$ is at or above the short call strike price $K$. The probability of this scenario occurring is given by $\mathbb{P}(S(T)\geq K) = \mathbb{P}(S(T)>K) = 1 - F_{S}\left(K\right)$.

We'll save the probability of this scenario occurring in the `p_max_profit_gbm::Float64` variable.

Output:
```
Scenario 2: Probability of max profit under ℚ = 0.3448357342620687
```

Would we be better off holding the shares instead of selling the call? Let's compute the probability of opportunity loss.

> __Scenario 3: Upside opportunity loss__. In this scenario, the share price at expiration $S(T)$ is above the alternative opportunity point $O^{+}=K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$. The probability of this scenario occurring is given by $\mathbb{P}(S(T)>O^{+}) = 1 - F_{S}\left(O^{+}\right)$.

We'll save the probability of this scenario occurring in the `p_upside_opp_loss::Float64` variable.

Output:
```
Scenario 3: Probability of upside opportunity loss under ℚ = 0.2582476664320539
```

Let's summarize our probability results in a table.

Output:
```
 ---------- --------- --------- ---------------- --------- ------------ ------------- --------- --------------------- ------------------ -------------------
    ticker        Sₒ       DTE   strike_price_K   premium   max_profit   breakeven_B        IV   p_downside_loss_gbm   p_max_profit_gbm   p_upside_opp_loss 
    String   Float64   Float64          Float64   Float64      Float64       Float64   Float64               Float64            Float64             Float64 
 ---------- --------- --------- ---------------- --------- ------------ ------------- --------- --------------------- ------------------ -------------------
  amd-2026    531.26      53.0            570.0     31.25      66.9834       503.017    0.5626              0.427959           0.344836            0.258248
 ---------- --------- --------- ---------------- --------- ------------ ------------- --------- --------------------- ------------------ -------------------
```

### Our belief $\mathbb{P}$
So far, we used the risk-neutral probabilities $\mathbb{Q}$, the probabilities inside the market price. Our belief $\mathbb{P}$ uses the SAGBM parameters instead: geometric Brownian motion with drift $\hat{\mu}=\hat{\mu}_{g}+\hat{\sigma}^{2}/2$ and volatility $\hat{\sigma}$, where $\hat{\mu}_{g}$ (the `drift` column) and $\hat{\sigma}$ (the `volatility` column) are the AMD estimates we loaded earlier. 

Let's compute the probabilities of the three scenarios for two distributions of the share price at expiration:
* __Our belief $\mathbb{P}$:__ log-normal, with drift $\hat{\mu}$ and volatility $\hat{\sigma}$.
* __Risk-neutral $\mathbb{Q}$:__ log-normal, with drift $g_{y}$ and the call's implied volatility, the distribution `d_gbm` above.

So what do we get?

Output:
```
 ---------------------- --------- --------------- ---------------------
  distribution of S(T)   P(loss)   P(max profit)   P(opportunity loss) 
 ---------------------- --------- --------------- ---------------------
  our belief ℙ            0.2561          0.4856                0.3695
  risk-neutral ℚ          0.4280          0.3448                0.2582
 ---------------------- --------- --------------- ---------------------
our belief ℙ: μ̂_g = 0.4397, σ̂ = 0.4743, μ̂ = 0.5521 (1/yr)
risk-neutral ℚ: gᵧ = 0.0413 (1/yr), IV = 0.5626
```

> __What do we see?__
>
> * __Loss:__ Our belief $\mathbb{P}$ gives a lower probability of a loss compared to $\mathbb{Q}$. The estimated drift $\hat{\mu}$ is much larger than $g_{y}$, and its volatility $\hat{\sigma}$ is lower than the implied volatility, so a share price below the breakeven is less likely under $\mathbb{P}$.
> * __Maximum profit and opportunity loss:__ The larger drift also makes a share price above the strike price more likely. Under $\mathbb{P}$, the covered call is more likely to earn its maximum profit, and the share price is more likely to finish above $O^{+}$, where the shares alone would have earned more.

`Unhide` the code block below to see how we plotted the cumulative distribution function $F_{S}(x)=\mathbb{P}(S(T)\leq x)$ of each distribution in the table (solid lines), and one minus it, $1-F_{S}(x)=\mathbb{P}(S(T)>x)$ (dashed lines, same color).

> __What do we see?__ The navy curves ($\mathbb{P}$) sit to the right of the blue curves ($\mathbb{Q}$). At the breakeven $S^{\ddagger}$ (green line), the solid navy curve is lower than the solid blue curve, so a loss is less likely under $\mathbb{P}$. At $K$ (purple line) and $O^{+}$ (gray line), the dashed navy curve is higher than the dashed blue curve, so the maximum profit and an opportunity loss are more likely under $\mathbb{P}$.

How do the two distributions compare?

___

## Summary
In this example, we bought `AMD` shares and sold a call on them, computed the covered call's breakeven, maximum profit, and maximum loss, and estimated the probabilities of a loss, of the maximum profit, and of an opportunity loss under the risk-neutral probabilities and under our belief.

> __Key Takeaways:__
>
> * __The premium lowers the breakeven and the call caps the profit:__ We combined long shares and a short call into one profit at expiration. The premium lowers the breakeven, and the call caps the profit at the strike price. The maximum loss equals the breakeven, reached if the share price falls to zero.
> * __Our belief and the risk-neutral probabilities give different answers:__ We simulated the share price at expiration under the risk-neutral probabilities, described it under our belief with a log-normal distribution, and read the probability of each outcome from each cumulative distribution. Under our belief, built from AMD's estimated drift and volatility, a loss was less likely and the maximum profit more likely than under the risk-neutral probabilities.
> * __Selling the call gives up the gains above the opportunity point:__ We found the share price above which the shares alone earn more than the covered call. It sits above the strike price, so an opportunity loss is less likely than the maximum profit.

Understanding covered call positions enables traders to generate income from equity holdings while accepting limited upside potential.
___
