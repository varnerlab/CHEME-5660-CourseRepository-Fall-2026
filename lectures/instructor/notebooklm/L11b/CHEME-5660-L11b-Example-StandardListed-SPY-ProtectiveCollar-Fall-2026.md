# Example: A Protective Collar on SPY
In this example, we build a protective collar on `SPY` from ordinary listed options: we buy shares, buy a put with a strike below the share price, and sell a call with a strike above it, all with the same expiration. 

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Build a protective collar from the options chain:__ Choose a put below and a call above the share price from the listed strikes, and compute the collar's net premium.
> * __Compute the profit of the collar:__ Find the maximum profit, breakeven, and maximum loss, and compare the collar's profit at expiration with that of holding the shares.
> * __Estimate the probabilities of the outcomes:__ Describe the share price at expiration with log-normal distributions under the risk-neutral probabilities and under our belief, and compute the probabilities of a loss and of ending at the floor or at the cap.

Using an end-of-day `SPY` options chain, we compute the collar's floor, cap, and breakeven, compare it with holding the shares, and estimate how likely each outcome is.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/). 

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Data
Let's load an end-of-day options chain from the course archive, which holds the chains of 31 tickers captured after each close from April 13 to October 16, 2026.

[The `MyOptionsEODChainDataSet(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyOptionsEODChainDataSet) returns the chain for one ticker, trading session, and expiration, with that session's share price. [The `filter(...)` function](https://dataframes.juliadata.org/stable/lib/functions/#Base.filter) keeps the target expiration, and we store the results in the `metadata::Dict{String,Any}` and `optionschain::DataFrame` variables.

What's in the `metadata::Dict{String,Any}` dictionary?

Output:
```
 ------------------ -------------------------------------------------
  field              value                                           
  String             String                                          
 ------------------ -------------------------------------------------
  DTE                63
  capture_ts         2026-10-16T20:35:31.483
  expiration_date    2026-12-18
  quote_date         2026-10-16
  source             Alpaca Markets options snapshot, end of session
  ticker             SPY
  underlying_close   763.335
  underlying_high    773.18
  underlying_low     760.65
  underlying_open    773.125
 ------------------ -------------------------------------------------
```

What about the `optionschain::DataFrame` variable? Each row is one contract, with its bid, ask, and mid prices, and the implied volatility and Greeks quoted with the chain:

Output:
```
516×19 DataFrame
 Row │ date        expiration  dte    target_dte  type    strike   bid      as ⋯
     │ Date        Date        Int64  Int64       String  Float64  Float64  Fl ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 2026-10-16  2026-12-18     63          60  call      150.0   607.28  61 ⋯
   2 │ 2026-10-16  2026-12-18     63          60  call      200.0   554.29  56
   3 │ 2026-10-16  2026-12-18     63          60  call      210.0   557.78  56
   4 │ 2026-10-16  2026-12-18     63          60  call      220.0   551.32  55
   5 │ 2026-10-16  2026-12-18     63          60  call      230.0   527.04  52 ⋯
   6 │ 2026-10-16  2026-12-18     63          60  call      240.0   521.24  52
   7 │ 2026-10-16  2026-12-18     63          60  call      245.0   524.37  52
   8 │ 2026-10-16  2026-12-18     63          60  call      250.0   510.24  52
   9 │ 2026-10-16  2026-12-18     63          60  call      255.0   507.71  51 ⋯
  10 │ 2026-10-16  2026-12-18     63          60  call      260.0   495.22  50
  11 │ 2026-10-16  2026-12-18     63          60  call      265.0   489.66  50
  ⋮  │     ⋮           ⋮         ⋮        ⋮         ⋮        ⋮        ⋮        ⋱
 507 │ 2026-10-16  2026-12-18     63          60  put       955.0   193.18  19
 508 │ 2026-10-16  2026-12-18     63          60  put       960.0   199.32  20 ⋯
 509 │ 2026-10-16  2026-12-18     63          60  put       965.0   198.08  20
 510 │ 2026-10-16  2026-12-18     63          60  put       970.0   204.54  20
 511 │ 2026-10-16  2026-12-18     63          60  put       975.0   207.58  21
 512 │ 2026-10-16  2026-12-18     63          60  put       980.0   219.59  22 ⋯
 513 │ 2026-10-16  2026-12-18     63          60  put       985.0   222.68  22
 514 │ 2026-10-16  2026-12-18     63          60  put       990.0   228.6   22
 515 │ 2026-10-16  2026-12-18     63          60  put       995.0   233.78  23
 516 │ 2026-10-16  2026-12-18     63          60  put      1000.0   239.69  24 ⋯
                                                 12 columns and 495 rows omitted
```

To compare the risk-neutral probabilities with our belief about the share price, let's load the single-asset geometric Brownian motion (SAGBM) parameters we estimated a few lectures ago, which include the drift and volatility for each ticker. We'll store this data in the `parameters_df::DataFrame` variable:

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, and permissible values.

___

## Task 1: Build the Collar from the Options Chain
In this task, we choose the two option legs of the collar. We buy the listed put whose strike $K_{1}$ is closest to `put_moneyness` times $S(0)$, and sell the listed call whose strike $K_{2}$ is closest to `call_moneyness` times $S(0)$. 

As in the covered call example, the premiums $\mathcal{P}_{1}$ (put) and $\mathcal{P}_{2}$ (call) are the mid prices. We save the two contracts in the `put_leg::DataFrameRow` and `call_leg::DataFrameRow` variables:

Let's look at the two legs. For each one, the table shows the strike, the bid, ask, and mid prices, and the implied volatility and Delta quoted with the chain. 

Below it, we print the collar's net premium per share, $\mathcal{P}_{1}-\mathcal{P}_{2}$ (a debit if positive):

Output:
```
 ---------------- -------------------- ------ ------ --------------- -------------------- ---------
  leg              strike (USD/share)    bid    ask   mid (premium)   implied volatility     Delta 
 ---------------- -------------------- ------ ------ --------------- -------------------- ---------
  long put, K₁                 725.00   8.40   8.48            8.44               0.1965   -0.2251
  short call, K₂               802.00   3.86   4.04            3.95               0.1168    0.1965
 ---------------- -------------------- ------ ------ --------------- -------------------- ---------
Share price S(0) = 763.335 USD/share, 63 days to expiration
Net premium 𝒫₁ - 𝒫₂ = 4.49 USD/share (debit)
```

> __What do we see?__
>
> * __The put costs more than the call:__ With the default constants, the two strikes are about the same distance from the share price, but the put's implied volatility is higher than the call's, so its premium is larger and the collar costs a net debit. A zero-cost collar would sell a call with a lower strike, which lowers the cap.
___

## Task 2: Profit at Expiration
In this task, we compute the collar's profit at expiration and compare it with holding the shares. From the lecture, the profit at expiration per share is:
$$
\hat{P}(S(T)) = S(T) + \left(K_{1}-S(T)\right)^{+} - \left(S(T)-K_{2}\right)^{+} - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)
$$
where the last term is today's cost, the share price plus the net premium, grown to expiration. The maximum profit is $K_{2}-\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)$ when $S(T)\geq K_{2}$, the breakeven is $S^{\ddagger}=\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)$, and the maximum loss, a positive amount, is $\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)-K_{1}$ when $S(T)\leq K_{1}$.

We save the strikes, the premiums, and the breakeven in the `K₁`, `K₂`, `𝒫₁`, `𝒫₂`, and `B` variables:

Output:
```
 --------------------------- -------- -----------
  quantity                     value   units     
 --------------------------- -------- -----------
  maximum profit, S(T) ≥ K₂    28.64   USD/share
  breakeven S‡                773.36   USD/share
  maximum loss, S(T) ≤ K₁      48.36   USD/share
 --------------------------- -------- -----------
```

### Visualize
`Unhide` the code block below to see how we plotted the collar's profit at expiration next to the profit of holding the shares alone, $S(T)-\mathcal{D}_{T,0}(g_{y})\cdot S(0)$. The shares alone break even at $\mathcal{D}_{T,0}(g_{y})\cdot S(0)$, not at $S(0)$; the navy dot marks this point.

> __What do we see?__ Below $K_{1}$, the collar's profit stops falling: the put sells the shares at $K_{1}$. Above $K_{2}$, it stops rising: the call takes the shares at $K_{2}$. Between the strikes, it runs parallel to the profit of the shares, offset by the net premium grown to expiration.

How does the collar compare with holding the shares?

___

## Task 3: Probability of Outcomes
In this task, we estimate the probability of each outcome at expiration from the cumulative distribution of the share price at expiration, first under the risk-neutral probabilities and then under our belief.

We'll consider three scenarios and compare the first with holding the shares alone:

> __Scenarios:__
>
> * __Scenario 1: Loss__. The share price at expiration is below the breakeven, $S(T)<S^{\ddagger}$, with probability $F_{S}(S^{\ddagger})$. The shares alone lose money when $S(T)<\mathcal{D}_{T,0}(g_{y})\cdot S(0)$.
> * __Scenario 2: At the floor__. The share price at expiration is at or below the put's strike, $S(T)\leq K_{1}$, with probability $F_{S}(K_{1})$. The loss is then at its maximum.
> * __Scenario 3: At the cap__. The share price at expiration is at or above the call's strike, $S(T)\geq K_{2}$, with probability $\mathbb{P}(S(T)\geq K_{2})=\mathbb{P}(S(T)>K_{2})=1-F_{S}(K_{2})$. The profit is then at its maximum.

Here $F_{S}(x)=\mathbb{P}(S(T)\leq x)$ is the cumulative distribution function of the share price at expiration. We build the [LogNormal distribution exported by the Distributions.jl package](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.LogNormal), save it in the `d_gbm::LogNormal` variable, and evaluate it with [the `cdf(...)` function](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.cdf-Tuple{UnivariateDistribution,%20Real}):

Output:
```
 ----------------------------------- --------------------------
  scenario                            risk-neutral probability 
 ----------------------------------- --------------------------
  loss, collar: S(T) < S‡                               0.5504
  loss, shares alone: S(T) < 𝒟⋅S(0)                     0.5122
  at the floor: S(T) ≤ K₁                               0.1758
  at the cap: S(T) ≥ K₂                                 0.2350
 ----------------------------------- --------------------------
At-the-money implied volatility σ = 0.1469
```

> __What do we see?__
>
> * __Loss:__ The collar is a little more likely to lose money than the shares alone, because its net debit raises the breakeven. What the put buys is a limit on the size of the loss, not a lower chance of one.
> * __Floor and cap:__ The collar ends at its floor or at its cap with the probabilities in the table; between the strikes, it moves with the shares. Rerun with `put_moneyness = 0.90`: the floor drops, the put costs less, and ending at the floor becomes less likely.

So far, we used the risk-neutral probabilities $\mathbb{Q}$, the probabilities inside the market price. Now, let's use our belief, i.e., the real-world probabilities $\mathbb{P}$:
* __Our belief $\mathbb{P}$:__ log-normal, with drift $\hat{\mu}$ and volatility $\hat{\sigma}$.
* __Risk-neutral $\mathbb{Q}$:__ log-normal, with drift $g_{y}$ and the at-the-money implied volatility, the distribution `d_gbm` above.

We save the two distributions in the `share_price_distributions::Vector` variable. So what do we get?

Output:
```
 ---------------------- ----------------- ----------------------- ----------------- ---------------
  distribution of S(T)   P(loss), collar   P(loss), shares alone   P(at the floor)   P(at the cap) 
 ---------------------- ----------------- ----------------------- ----------------- ---------------
  our belief ℙ                    0.4662                  0.4249            0.1084          0.2867
  risk-neutral ℚ                  0.5504                  0.5122            0.1758          0.2350
 ---------------------- ----------------- ----------------------- ----------------- ---------------
our belief ℙ: μ̂_g = 0.1031, σ̂ = 0.1351, μ̂ = 0.1123 (1/yr)
risk-neutral ℚ: gᵧ = 0.0416 (1/yr), σ = 0.1469
```

> __What do we see?__
>
> * __Loss:__ Our belief $\mathbb{P}$ gives a lower probability of a loss than $\mathbb{Q}$, for the collar and for the shares alone. The estimated drift $\hat{\mu}$ is larger than $g_{y}$, and $\hat{\sigma}$ is a little lower than the implied volatility, so a share price below the breakeven is less likely under $\mathbb{P}$. Under both, the collar is a little more likely to lose money than the shares alone.
> * __Floor and cap:__ The larger drift also moves probability toward higher share prices. Under $\mathbb{P}$, the collar is less likely to end at its floor and more likely to end at its cap than under $\mathbb{Q}$.

`Unhide` the code block below to see how we plotted the cumulative distribution function $F_{S}(x)=\mathbb{P}(S(T)\leq x)$ of each distribution in the table (solid lines), and one minus it, $1-F_{S}(x)=\mathbb{P}(S(T)>x)$ (dashed lines, same color). 

How do the two distributions compare?

___

## Summary
In this example, we built a protective collar on `SPY` from the options chain, computed its maximum profit, breakeven, and maximum loss, and estimated the probabilities of a loss and of ending at the floor or at the cap under the risk-neutral probabilities and under our belief.

> __Key Takeaways:__
>
> * __The listed strikes and premiums set the collar:__ We chose a put below and a call above the share price from the options chain. With strikes about the same distance from the share price, the put was more expensive than the call, so the collar cost a net premium.
> * __The put sets a floor and the call a cap:__ We computed the maximum loss as today's cost grown to expiration minus the put's strike, and the maximum profit as the call's strike minus that cost. Between the strikes, the profit moves with the shares.
> * __Protection limits the size of a loss, not its chance:__ We read the cumulative distributions under the risk-neutral probabilities and under our belief at the breakeven and at the two strikes. Under both, the collar was more likely to lose money than the shares alone, but its loss stopped at the floor. Under our belief, built from SPY's estimated drift and volatility, ending at the floor was less likely and ending at the cap more likely.

Understanding protective collars enables traders to protect shares they want to keep, at the cost of capping their gains.
___
