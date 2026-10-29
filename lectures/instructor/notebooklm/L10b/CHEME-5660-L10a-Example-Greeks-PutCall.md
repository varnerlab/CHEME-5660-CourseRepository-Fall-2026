# Example: Calculate Delta, Theta, Vega, Rho, and Gamma for Short and Long Options Contracts
In the lecture, we estimated each Greek by repricing an option on a binomial tree with one input moved up and down. How close do these estimates come to the Greeks quoted in the market?

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Compute and interpret the five key Greeks for American options:__ Calculate Delta, Theta, Vega, Rho, and Gamma for a call and a put on the Leisen–Reimer tree, and explain what each one measures.
> * __Compare Greek values between calls and puts:__ Explain how the signs and sizes of the Greeks differ between a long call and a long put, and what each sign means for the holder.
> * __Convert Greeks between long and short positions:__ Use the fact that long and short Greeks sum to zero to find the seller's Greeks. Use the Greeks of one contract to size a Delta hedge and estimate its change in price.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, and loads the functions in the local `src` directory. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/).

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Data
Let's load an end-of-day options chain from the course archive (31 tickers, captured after each close from April 13 to October 16, 2026). [The `MyOptionsEODChainDataSet(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/data/#VLQuantitativeFinancePackage.MyOptionsEODChainDataSet) returns the chain for one ticker, trading session, and expiration, with that session's share price. 

[The `filter(...)` function](https://dataframes.juliadata.org/stable/lib/functions/#Base.filter) keeps the expiration matched to `target_dte`, and we store the results in the `metadata::Dict{String,Any}` and `optionschain::DataFrame` variables.

Output:
```
194×19 DataFrame
 Row │ date        expiration  dte    target_dte  type    strike   bid      as ⋯
     │ Date        Date        Int64  Int64       String  Float64  Float64  Fl ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 2026-10-08  2026-11-20     43          45  call        2.5   223.85   2 ⋯
   2 │ 2026-10-08  2026-11-20     43          45  call        5.0   221.32   2
   3 │ 2026-10-08  2026-11-20     43          45  call        7.5   220.34   2
   4 │ 2026-10-08  2026-11-20     43          45  call       10.0   219.59   2
   5 │ 2026-10-08  2026-11-20     43          45  call       12.5   211.46   2 ⋯
   6 │ 2026-10-08  2026-11-20     43          45  call       15.0   211.59   2
   7 │ 2026-10-08  2026-11-20     43          45  call       17.5   212.29   2
   8 │ 2026-10-08  2026-11-20     43          45  call       20.0   206.22   2
  ⋮  │     ⋮           ⋮         ⋮        ⋮         ⋮        ⋮        ⋮        ⋱
 188 │ 2026-10-08  2026-11-20     43          45  put       430.0   194.12   2 ⋯
 189 │ 2026-10-08  2026-11-20     43          45  put       440.0   203.22   2
 190 │ 2026-10-08  2026-11-20     43          45  put       450.0   219.14   2
 191 │ 2026-10-08  2026-11-20     43          45  put       455.0   220.04   2
 192 │ 2026-10-08  2026-11-20     43          45  put       460.0   224.54   2 ⋯
 193 │ 2026-10-08  2026-11-20     43          45  put       470.0   238.01   2
 194 │ 2026-10-08  2026-11-20     43          45  put       480.0   243.1    2
                                                 12 columns and 179 rows omitted
```

What about the `optionschain` variable? [The `select(...)` function](https://dataframes.juliadata.org/stable/lib/functions/#DataFrames.select) keeps the columns we use. Contracts with an implied volatility have quoted Greeks: `theta` is per calendar day, and `vega` and `rho` are per percentage point.

Output:
```
194×11 DataFrame
 Row │ type    strike   bid      ask      mid      implied_vol   delta         ⋯
     │ String  Float64  Float64  Float64  Float64  Float64?      Float64?      ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ call        2.5   223.85   234.5   229.175  missing       missing       ⋯
   2 │ call        5.0   221.32   225.24  223.28   missing       missing      
   3 │ call        7.5   220.34   227.43  223.885  missing       missing      
   4 │ call       10.0   219.59   226.54  223.065  missing       missing      
   5 │ call       12.5   211.46   223.19  217.325  missing       missing       ⋯
   6 │ call       15.0   211.59   219.98  215.785  missing       missing      
   7 │ call       17.5   212.29   215.81  214.05   missing       missing      
   8 │ call       20.0   206.22   216.42  211.32   missing       missing      
  ⋮  │   ⋮        ⋮        ⋮        ⋮        ⋮          ⋮             ⋮        ⋱
 188 │ put       430.0   194.12   202.75  198.435  missing       missing       ⋯
 189 │ put       440.0   203.22   210.9   207.06         0.7096       -0.9939
 190 │ put       450.0   219.14   224.13  221.635  missing       missing      
 191 │ put       455.0   220.04   227.08  223.56   missing       missing      
 192 │ put       460.0   224.54   231.48  228.01   missing       missing       ⋯
 193 │ put       470.0   238.01   240.57  239.29   missing       missing      
 194 │ put       480.0   243.1    250.71  246.905  missing       missing      
                                                  4 columns and 179 rows omitted
```

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, permissible values, etc. 

Let's collect (and display) these inputs in one table with [the `pretty_table(...)` function](https://ronisbr.github.io/PrettyTables.jl/stable/lib/library/#PrettyTables.pretty_table):

Output:
```
 ---------------------- ------------ --------------
  quantity                    value   units        
 ---------------------- ------------ --------------
  ticker                       NVDA
  quote date             2026-10-08
  expiration             2026-11-20
  days to expiration             43   days
  share price Sₒ             230.57   USD/share
  time to expiration T       0.1178   years
  risk-free rate gᵧ          0.0413   1/year
  tree levels h                 861   levels
  volatility step ε_σ          0.01   1/sqrt(year)
  rate step ε_g                0.01   1/year
  time step ε_t             0.00274   years
  share price step ε_S       2.3057   USD/share
 ---------------------- ------------ --------------
```

### Contract models
Next, we select the call and the put whose strike price is nearest the share price, among contracts with an implied volatility and quoted Greeks. [The `argmin(...)` function](https://docs.julialang.org/en/v1/base/collections/#Base.argmin) finds that strike, and the mid price is the premium. We store the two rows in the `call_row::DataFrameRow` and `put_row::DataFrameRow` variables:

Output:
```
2×11 DataFrame
 Row │ type    strike   bid      ask      mid      implied_vol  delta    gamma ⋯
     │ String  Float64  Float64  Float64  Float64  Float64      Float64  Float ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ call      230.0    12.02    12.28   12.15        0.3521   0.5538   0.01 ⋯
   2 │ put       230.0    10.56    10.71   10.635       0.37    -0.4464   0.01
                                                               4 columns omitted
```

We build the call's contract model, an instance of [the `MyAmericanCallContractModel` type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyAmericanCallContractModel), with [the `build(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.build-Tuple{Type{MyAmericanCallContractModel},%20NamedTuple}). 

Its [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple) argument sets the strike price, the premium, the time to expiration in years (the `DTE` field), the position (`sense = 1`, long), the number of contracts (`copy`), and the implied volatility. We save the model in the `call_option_model::MyAmericanCallContractModel` variable:

We build the put the same way, as an instance of [the `MyAmericanPutContractModel` type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyAmericanPutContractModel), and save it in the `put_option_model::MyAmericanPutContractModel` variable:

### Repricing on the Leisen–Reimer tree
Every Greek in this example is a central difference of repriced premiums. [The `binomial_premium(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.binomial_premium) prices a call or put on a tree with `h` levels, without rounding, and `method = :leisen_reimer` selects [the Leisen–Reimer tree](advanced/leisen_reimer/CHEME-5660-L10a-Advanced-LeisenReimer-Greeks-Fall-2026.ipynb). [The `𝒫(...)` function](src/Helper.jl) wraps it and takes all five inputs, so we can move one and hold the others fixed.

[The `show_value(...)` function](src/Helper.jl) shows a computed value with its units, and [the `compare_greek(...)` function](src/Helper.jl) shows a computed Greek next to the archive's quote.

___

## Task 1: Compute the Greeks for a Long Call Option
In this task, we'll compute the five Greeks of the long call on the Leisen–Reimer tree and compare each one with the archive's quote. Let's start with Delta.

### Delta Long Call
Delta measures the change in the premium $\mathcal{P}_{c}$ for a `+1 USD/share` change in the share price. We move the share price up and down by the step $\epsilon_{S}$ and reprice the call:
$$
\Delta_{c}\approx\frac{\mathcal{P}_{c}(S_{o}+\epsilon_{S})-\mathcal{P}_{c}(S_{o}-\epsilon_{S})}{2\epsilon_{S}}
$$
We store the estimate in the `delta_long_call::Float64` variable. So what do we get?

Output:
```
0.5481063229085609
```

__Summary__: For a long call, $\Delta_{c}\geq{0}$, so the premium $\mathcal{P}_{c}$ rises with the share price. That is why a long call can stand in for owning shares.

> __Hedging Interpretation:__
>
> Delta gives the number of shares one contract is equivalent to, $n_{c}$ shares per contract:
> $$
> \begin{align*}
> n_{c} &= 100\cdot\Delta_{c}
> \end{align*}
> $$
> where $\Delta_{c}$ is the Delta of a long call contract.

Thus, this long call contract is equivalent to:

Output:
```
 ---------------------------------- ------- ---------------------
  quantity                           value   units               
 ---------------------------------- ------- ---------------------
  share equivalents, one long call   54.81   shares per contract
 ---------------------------------- ------- ---------------------
```

#### Check: How good is our delta estimate?
The archive quotes a Delta for this contract, computed by the data provider with its own model and inputs. Let's compare it with ours using [the `@assert` macro](https://docs.julialang.org/en/v1/base/base/#Base.@assert) and [the `isapprox(...)` function](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).

> __Test:__ [The `isapprox(...)` function](https://docs.julialang.org/en/v1/base/math/#Base.isapprox) returns `true` when two values agree within the relative tolerance `rtol`. If it returns `false`, an [AssertionError](https://docs.julialang.org/en/v1/base/base/#Core.AssertionError) is thrown. We ask for agreement within 10% of the quoted value, which also requires the same sign.

So what do we find?

Output:
```
 ---------------------- --------- -------
  quantity                 value   units 
 ---------------------- --------- -------
  Delta, Leisen–Reimer    0.5481   1
  Delta, archive quote    0.5538   1
  difference             -0.0057   1
 ---------------------- --------- -------
```

### Theta Long Call
Theta measures the change in the premium $\mathcal{P}_{c}$ as calendar time passes. Moving the calendar time forward by $\epsilon_{t}$ shortens the time to expiration $T$ by $\epsilon_{t}$, so we reprice the call with $T$ moved down and up:
$$
\Theta_{c}\approx\frac{\mathcal{P}_{c}(T-\epsilon_{t})-\mathcal{P}_{c}(T+\epsilon_{t})}{2\epsilon_{t}}
$$
We store the estimate, in USD/share per year, in the `theta_long_call::Float64` variable. What is our time decay estimate?

Output:
```
-51.56461742497356
```

__Summary__: For a long call, $\Theta_{c}<0$, so with all else fixed, the premium falls as expiration approaches. This loss is the time decay. For one call contract, the time decay is:

Output:
```
 --------------------------- -------- --------------------------
  quantity                     value   units                    
 --------------------------- -------- --------------------------
  time decay, one long call   -14.13   USD per day per contract
 --------------------------- -------- --------------------------
```

#### Check: How good is our theta estimate?
The archive quotes Theta per day, so we compare our estimate divided by 365. So what happens?

Output:
```
 ---------------------- --------- -------------------
  quantity                 value   units             
 ---------------------- --------- -------------------
  Theta, Leisen–Reimer   -0.1413   USD/share per day
  Theta, archive quote   -0.1407   USD/share per day
  difference             -0.0006   USD/share per day
 ---------------------- --------- -------------------
```

### Vega Long Call
Vega measures the change in the premium $\mathcal{P}_{c}$ for a change in the implied volatility $\sigma$. We move the volatility up and down by $\epsilon_{\sigma}$, one percentage point, and reprice the call:
$$
\nu_{c}\approx\frac{\mathcal{P}_{c}(\sigma+\epsilon_{\sigma})-\mathcal{P}_{c}(\sigma-\epsilon_{\sigma})}{2\epsilon_{\sigma}}
$$
We store the estimate in the `vega_long_call::Float64` variable. So what is our volatility sensitivity estimate?

Output:
```
31.340968538902203
```

__Summary__: For the long call, $\nu_{c}>0$, so the premium rises with the implied volatility. More uncertainty in the future share price makes the option more expensive, because the seller demands more compensation for the added risk.

#### Check: How good is our vega estimate?
The archive quotes Vega per percentage point, so we compare our estimate divided by 100. So did we pass the test?

Output:
```
 --------------------- --------- ---------------------
  quantity                value   units               
 --------------------- --------- ---------------------
  Vega, Leisen–Reimer    0.3134   USD/share per point
  Vega, archive quote    0.3135   USD/share per point
  difference            -0.0001   USD/share per point
 --------------------- --------- ---------------------
```

### Rho Long Call
Rho measures the change in the premium $\mathcal{P}_{c}$ for a change in the risk-free rate $g_{y}$. We move the rate up and down by $\epsilon_{g}$, one percentage point, and reprice the call:
$$
\rho_{c}\approx\frac{\mathcal{P}_{c}(g_{y}+\epsilon_{g})-\mathcal{P}_{c}(g_{y}-\epsilon_{g})}{2\epsilon_{g}}
$$
We store the estimate in the `rho_long_call::Float64` variable. So what is our interest rate sensitivity estimate?

Output:
```
13.485421374463513
```

__Summary__: For a long call, $\rho_{c}>0$, so the premium rises with the risk-free rate. The rate usually changes little, but when rates rise, for example in inflationary periods, call premiums rise, all else being equal. For one call contract, a one-percentage-point rise in $g_{y}$ changes its premium by:

Output:
```
 ------------------------------------------------ ------- ------------------
  quantity                                         value   units            
 ------------------------------------------------ ------- ------------------
  change for a 1 point rise in gᵧ, one long call   13.49   USD per contract
 ------------------------------------------------ ------- ------------------
```

#### Check: How good is our rho estimate?
The archive quotes Rho per percentage point, so we compare our estimate divided by 100. So what happens?

Output:
```
 -------------------- --------- ---------------------
  quantity               value   units               
 -------------------- --------- ---------------------
  Rho, Leisen–Reimer    0.1349   USD/share per point
  Rho, archive quote    0.1364   USD/share per point
  difference           -0.0015   USD/share per point
 -------------------- --------- ---------------------
```

### Gamma Long Call
Gamma, the last Greek we'll explore, measures the change in Delta for a `+1 USD/share` change in the share price. We reprice the call at the two share prices we used for Delta, and at $S_{o}$:
$$
\Gamma_{c}\approx\frac{\mathcal{P}_{c}(S_{o}+\epsilon_{S})-2\,\mathcal{P}_{c}(S_{o})+\mathcal{P}_{c}(S_{o}-\epsilon_{S})}{\epsilon_{S}^{2}}
$$
We store the estimate in the `gamma_long_call::Float64` variable. What is our curvature estimate?

Output:
```
0.014204966269353093
```

__Summary__: The long call has $\Gamma_{c}>0$, so its Delta rises as the share price rises. A larger Gamma means Delta changes faster.

#### Check: How good is our gamma estimate?
So do we pass the test?

Output:
```
 ---------------------- -------- ---------------
  quantity                value   units         
 ---------------------- -------- ---------------
  Gamma, Leisen–Reimer   0.0142   1/(USD/share)
  Gamma, archive quote   0.0142   1/(USD/share)
  difference             0.0000   1/(USD/share)
 ---------------------- -------- ---------------
```

### Check: Do the Greeks stop changing?
Before we use these Greeks, we recompute them with $2h+1$ levels, still odd, and every step $\epsilon$ halved. [The `binomial_greeks(...)` function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.binomial_greeks) repeats our five central differences with the levels and steps we pass. Let's compare the two sets in the archive's units and ask that each change by less than 0.5%:

Output:
```
 ------- --------- ------------------------ --------------- ---------------------
  greek   h = 861   h = 1723, steps halved   archive quote   units               
 ------- --------- ------------------------ --------------- ---------------------
  Delta    0.5481                   0.5482          0.5538   1
  Gamma    0.0142                   0.0142          0.0142   1/(USD/share)
  Theta   -0.1413                  -0.1413         -0.1407   USD/share per day
  Vega     0.3134                   0.3134          0.3135   USD/share per point
  Rho      0.1349                   0.1349          0.1364   USD/share per point
 ------- --------- ------------------------ --------------- ---------------------
```

___

## Task 2: Compute the Greeks for a Long Put Option
In this task, we'll compute the five Greeks of the long put and compare them with the archive's quotes and the long call. Then we'll look at how the Greeks change with the moneyness and the time to expiration. Let's begin with Delta.

### Delta Long Put
We estimate Delta as for the call, now with the `put_option_model` instance, and store it in the `delta_long_put::Float64` variable:

Output:
```
-0.45599403101185254
```

__Summary__: For the long put, $\Delta_{p}<0$, the opposite sign of the call, so the put's value falls as the share price rises. A buyer purchases a put when they expect the share price to fall.

> __What about the number of share equivalents?__
> For a long put, the number of share equivalents $n_{p}$ is negative, because the put acts like a short position in the shares.
>
> The number of share equivalents is:
> $$
> n_{p} = 100\cdot\Delta_{p}
> $$
> where $\Delta_{p}$ is the Delta of a long put contract.

Thus, this long put contract is equivalent to:

Output:
```
 --------------------------------- -------- ---------------------
  quantity                           value   units               
 --------------------------------- -------- ---------------------
  share equivalents, one long put   -45.60   shares per contract
 --------------------------------- -------- ---------------------
```

#### Check: How good is our delta estimate?
Is our estimate accurate?

Output:
```
 ---------------------- --------- -------
  quantity                 value   units 
 ---------------------- --------- -------
  Delta, Leisen–Reimer   -0.4560   1
  Delta, archive quote   -0.4464   1
  difference             -0.0096   1
 ---------------------- --------- -------
```

### Theta Long Put
We estimate Theta as for the call, now with the `put_option_model` instance, and store it in the `theta_long_put::Float64` variable:

Output:
```
-45.19793930104185
```

__Summary__: For the long put, $\Theta_{p}<0$, the same sign as the call. With all else fixed, both lose value as expiration approaches. For one put contract, the time decay is:

Output:
```
 -------------------------- -------- --------------------------
  quantity                    value   units                    
 -------------------------- -------- --------------------------
  time decay, one long put   -12.38   USD per day per contract
 -------------------------- -------- --------------------------
```

#### Check: How good is our theta estimate?
So are we good?

Output:
```
 ---------------------- --------- -------------------
  quantity                 value   units             
 ---------------------- --------- -------------------
  Theta, Leisen–Reimer   -0.1238   USD/share per day
  Theta, archive quote   -0.1227   USD/share per day
  difference             -0.0011   USD/share per day
 ---------------------- --------- -------------------
```

### Vega Long Put
We estimate Vega as for the call, now with the `put_option_model` instance, and store it in the `vega_long_put::Float64` variable:

Output:
```
31.323297360345137
```

__Summary__: For the long put, $\nu_{p}>0$, so like the call, its premium rises with the implied volatility. More uncertainty makes both calls and puts more expensive.

#### Check: How good is our vega estimate?
What do we find?

Output:
```
 --------------------- --------- ---------------------
  quantity                value   units               
 --------------------- --------- ---------------------
  Vega, Leisen–Reimer    0.3132   USD/share per point
  Vega, archive quote    0.3135   USD/share per point
  difference            -0.0003   USD/share per point
 --------------------- --------- ---------------------
```

### Rho Long Put
We estimate Rho as for the call, now with the `put_option_model` instance, and store it in the `rho_long_put::Float64` variable:

Output:
```
-11.400436034529271
```

__Summary__: For a long put, $\rho_{p}<0$, so the premium falls as the risk-free rate rises. When rates rise, for example in inflationary periods, put premiums fall, all else being equal. For one put contract, a one-percentage-point rise in $g_{y}$ changes its premium by:

Output:
```
 ----------------------------------------------- -------- ------------------
  quantity                                         value   units            
 ----------------------------------------------- -------- ------------------
  change for a 1 point rise in gᵧ, one long put   -11.40   USD per contract
 ----------------------------------------------- -------- ------------------
```

#### Check: How good is our rho estimate?
Let's compare our American put's Rho with the quote and with the Rho of a European put on the same tree, an instance of [the `MyEuropeanPutContractModel` type](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/derivatives/#VLQuantitativeFinancePackage.MyEuropeanPutContractModel):

Output:
```
 ----------------------------------- --------- ---------------------
  quantity                              value   units               
 ----------------------------------- --------- ---------------------
  Rho, American put (Leisen–Reimer)   -0.1140   USD/share per point
  Rho, European put (Leisen–Reimer)   -0.1354   USD/share per point
  Rho, archive quote                  -0.1340   USD/share per point
 ----------------------------------- --------- ---------------------
```

__Why is the American put's Rho smaller in size?__ A put holder who exercises sells the shares at the strike price. A higher risk-free rate lowers the present value of that cash, which is why $\rho_{p}<0$. The American holder can exercise early and collect the cash sooner, so the rate matters less. The quoted Rho is close to the European put's Rho.

### Gamma Long Put
Finally, we estimate Gamma as for the call, now with the `put_option_model` instance, and store it in the `gamma_long_put::Float64` variable:

Output:
```
0.013728257494219553
```

__Summary__: The long put also has $\Gamma_{p}>0$, so its Delta rises toward zero as the share price rises. A larger Gamma means Delta changes faster.

#### Check: How good is our gamma estimate?
So do we pass the test?

Output:
```
 ---------------------- -------- ---------------
  quantity                value   units         
 ---------------------- -------- ---------------
  Gamma, Leisen–Reimer   0.0137   1/(USD/share)
  Gamma, archive quote   0.0135   1/(USD/share)
  difference             0.0002   1/(USD/share)
 ---------------------- -------- ---------------
```

### How do Delta and Gamma change with the moneyness?
Before we sweep the strike price with `binomial_greeks(...)`, let's confirm it reproduces our values with the same `h` and steps:

Now let's compute Delta and Gamma for every contract with an implied volatility and quoted Greeks, each at its own implied volatility, and store them in the `greeks_by_strike_df::DataFrame` variable:

Let's plot the computed Delta and Gamma, with the archive's quotes as points, against the moneyness $K/S(0)$, the strike price divided by the share price $S_{o}$, using [the `plot(...)` function](https://docs.juliaplots.org/stable/api/#RecipesBase.plot), [the `scatter!(...)` function](https://docs.juliaplots.org/stable/api/#Plots.scatter!-Tuple), and [the `vline!(...)` function](https://docs.juliaplots.org/stable/api/#Plots.vline!-Tuple):

### How do the Greeks change with time to expiration?
For each expiration listed on the quote date, let's take the call whose strike price is nearest the share price and compute its Gamma, Theta, and Vega. Each tree has an odd number of levels, about twenty per day and at least 201, and the step $\epsilon_{t}$ is at most a quarter of the time to expiration:

Output:
```
 ------------ --------------- -------- ------------- ----------- ------------- ------------ ------------
  DTE (days)   K (USD/share)    Gamma   Gamma quote   Theta/day   Theta quote   Vega/point   Vega quote 
 ------------ --------------- -------- ------------- ----------- ------------- ------------ ------------
           1           230.0   0.0990        0.0991     -0.7813       -0.7580       0.0475       0.0464
           4           230.0   0.0657        0.0655     -0.3110       -0.3055       0.0955       0.0946
           6           230.0   0.0482        0.0480     -0.2853       -0.2826       0.1173       0.1167
           8           230.0   0.0378        0.0377     -0.2739       -0.2722       0.1355       0.1351
          11           230.0   0.0362        0.0361     -0.2109       -0.2097       0.1589       0.1584
          13           230.0   0.0313        0.0312     -0.2068       -0.2058       0.1727       0.1724
          15           230.0   0.0280        0.0279     -0.2006       -0.1997       0.1856       0.1853
          29           230.0   0.0200        0.0199     -0.1489       -0.1483       0.2577       0.2576
          43           230.0   0.0142        0.0142     -0.1413       -0.1407       0.3134       0.3135
 ------------ --------------- -------- ------------- ----------- ------------- ------------ ------------
```

### Discussion
* Gamma is largest near $K/S(0)=1$. Why does it fall as the strike moves away from the share price?
* As the expiration date approaches, how do the Gamma, Theta, and Vega of the call nearest the money change?
___

## Task 3: Convert the Greeks to Short Contracts and Positions
In this task, we'll convert the long Greeks to short contracts, then use them to describe one contract's exposure, size its Delta hedge, and estimate its change in price. The long and short Greeks of the same contract sum to zero.

> __Greeks for Short Contracts__
>
> Denote a short Greek by an overbar, so $\bar{\Delta}_{c}$ is the Delta of a short call. With the orientation $\theta$ of the contract ($\theta=1$ if long, $\theta=-1$ if short; `sense` in the code), in every market state:
> $$
> \begin{align*}
> \bar{\Delta}_{c} = \theta\cdot\Delta_{c} = -\Delta_{c}
> \end{align*}
> $$

The same holds for every Greek. Let's build a table of the long and short call's Greeks, in the units of the archive's quotes:

Output:
```
 ------------------ ----------- ------------ -------------- ----------------------
  greek              long call   short call   long + short   archive quote (long) 
 ------------------ ----------- ------------ -------------- ----------------------
  Delta                 0.5481      -0.5481         0.0000                 0.5538
  Gamma                 0.0142      -0.0142         0.0000                 0.0142
  Theta (per day)      -0.1413       0.1413         0.0000                -0.1407
  Vega (per point)      0.3134      -0.3134         0.0000                 0.3135
  Rho (per point)       0.1349      -0.1349         0.0000                 0.1364
 ------------------ ----------- ------------ -------------- ----------------------
```

and the put contract:

Output:
```
 ------------------ ---------- ----------- -------------- ----------------------
  greek              long put   short put   long + short   archive quote (long) 
 ------------------ ---------- ----------- -------------- ----------------------
  Delta               -0.4560      0.4560         0.0000                -0.4464
  Gamma                0.0137     -0.0137         0.0000                 0.0135
  Theta (per day)     -0.1238      0.1238         0.0000                -0.1227
  Vega (per point)     0.3132     -0.3132         0.0000                 0.3135
  Rho (per point)     -0.1140      0.1140         0.0000                -0.1340
 ------------------ ---------- ----------- -------------- ----------------------
```

### What does one contract expose us to?
Each contract covers 100 shares. For a signed number of contracts $n$, with $n<0$ for a short position, the lecture's Delta hedge is $-100\cdot n\cdot\Delta$ shares. Let's compute the exposure of one contract for each of the four positions:

Output:
```
 ------------------- ----------- ------------ ---------- ----------- ----------------------
  quantity            long call   short call   long put   short put   units                
 ------------------- ----------- ------------ ---------- ----------- ----------------------
  share equivalents       54.81       -54.81     -45.60       45.60   shares
  Delta hedge            -54.81        54.81      45.60      -45.60   shares
  Gamma                    1.42        -1.42       1.37       -1.37   shares per USD/share
  Theta                  -14.13        14.13     -12.38       12.38   USD per day
  Vega                    31.34       -31.34      31.32      -31.32   USD per point
  Rho                     13.49       -13.49     -11.40       11.40   USD per point
 ------------------- ----------- ------------ ---------- ----------- ----------------------
```

### How good is the local price-change estimate?
When only the share price moves, the lecture's expansion estimates the change in the call premium from Delta and Gamma:
$$
\Delta\mathcal{P}_{c}\approx\Delta_{c}\,\Delta S+\frac{1}{2}\,\Gamma_{c}\,(\Delta S)^{2}
$$
Let's move the share price by 2.5% and 5% each way and compare the Delta-only and Delta–Gamma estimates with full repricing on the tree, for one long call contract. The last column adds the Delta hedge of $-100\cdot\Delta_{c}$ shares:

Output:
```
 ---------------- -------------------------- --------------------------- ---------------------- -----------------------------------
  ΔS (USD/share)   change, Delta only (USD)   change, Delta–Gamma (USD)   change, actual (USD)   change, call + short shares (USD) 
 ---------------- -------------------------- --------------------------- ---------------------- -----------------------------------
          -11.53                    -631.88                     -537.49                -535.74                               96.14
           -5.76                    -315.94                     -292.34                -292.08                               23.86
            5.76                     315.94                      339.54                 339.15                               23.21
           11.53                     631.88                      726.28                 722.20                               90.32
 ---------------- -------------------------- --------------------------- ---------------------- -----------------------------------
```

__Why does the hedged position gain in both directions?__ The hedge cancels the Delta term, so the change that remains is close to the Gamma term $\frac{1}{2}\Gamma_{c}(\Delta S)^{2}$. For a long call, that term is positive whichever way the share price moves. The hedged position still loses value to Theta as time passes.

___

## Summary
In this example, we computed and interpreted the five Greeks of an American call and put on the Leisen–Reimer tree and converted them between long and short positions. We also compared the Greeks with the archive's quotes across strikes and expirations, then sized a Delta hedge and estimated a contract's price change.

> __Key Takeaways:__
>
> * __Greeks quantify option price sensitivity:__ Delta, Theta, Vega, and Rho measure how the premium responds to the share price, time, volatility, and the risk-free rate, and Gamma measures how fast Delta changes. Our tree estimates agreed closely with the archive's quotes, except the American put's Rho, which early exercise makes smaller in size.
> * __Call and put Greeks have different signs:__ A long call has a positive Delta and Rho, and a long put has a negative Delta and Rho. Both lose value as time passes and gain when the implied volatility rises.
> * __Long and short Greeks sum to zero:__ The seller's Greeks are the buyer's with the sign flipped. Multiplied by 100 shares per contract, Delta sizes the hedge, and Delta and Gamma together estimate a contract's price change for small share price moves.

Together, the Greeks tell us how a position's value moves with the share price, time, volatility, and rates, and how many shares hedge it.
___
