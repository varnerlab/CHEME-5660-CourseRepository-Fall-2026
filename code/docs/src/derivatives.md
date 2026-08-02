# Derivative Securities
Derivatives are financial instruments based on the value of other assets like commodities, stocks, or market indexes. Options are a type of derivative that uses stock as its underlying asset. They are contractual agreements giving the buyer the right, but not the obligation, to execute a transaction at a later date. 

## Options contracts
Options contracts are financial instruments that give the holder the right to buy or sell an asset at a predetermined price on or before a specific date. The two main types of options are call options and put options. 

* Call options give the holder the right to buy an asset at a predetermined price on or before the expiration date.
* Put options give the holder the right to sell an asset at a predetermined price on or before the expiration date.

### European option contracts
European options are contracts that give the holder the right to buy or sell an asset at a predetermined price on the expiration date. 
```@docs
VLQuantitativeFinancePackage.MyEuropeanCallContractModel
VLQuantitativeFinancePackage.MyEuropeanPutContractModel
VLQuantitativeFinancePackage.build(model::Type{MyEuropeanCallContractModel}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyEuropeanPutContractModel}, data::NamedTuple)
```

### American option contracts
American options are contracts that give the holder the right to buy or sell an asset at a predetermined price at any time before the expiration date.
```@docs
VLQuantitativeFinancePackage.MyAmericanCallContractModel
VLQuantitativeFinancePackage.MyAmericanPutContractModel
VLQuantitativeFinancePackage.build(model::Type{MyAmericanCallContractModel}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyAmericanPutContractModel}, data::NamedTuple)
```

## Contracts at expiration
```@docs
VLQuantitativeFinancePackage.payoff
VLQuantitativeFinancePackage.profit
```

## European contract premiums
European options are the simplest type of options to price because they can only be exercised on the expiration date. There are many methods to compute the premium of an options contract, but the most widely used method (by far) is the Black-Scholes-Merton (BSM) model (and its extensions). The BSM model has a closed-form solution, i.e., a mathematical expression that can be evaluated directly. Thus, it is computationally efficient. Alternatively, the premium of an options contract can be computed using numerical methods, such as binomial trees or Monte Carlo simulation.

### Black-Scholes model
The Black-Scholes-Merton model is used to compute the premium of European-style options contracts \cite{BlackScholes1973};
Robert C. Merton, Myron S. Scholes, and Fischer Black won the [Nobel Prize in Economics in 1997](https://www.nobelprize.org/prizes/economic-sciences/1997/press-release/) for their work on this model. The model assumes that the underlying asset's price follows a geometric Brownian motion with constant drift and volatility, where the drift is the risk-free interest rate, i.e., we evaluate the option using a risk-neutral pricing paradigm. Further, the model assumes that the risk-free interest rate is constant and that the underlying stock does not pay dividends (although the model can be modified to include dividends). Under these assumptions, the price of the option can be computed using the Black-Scholes-Merton pricing formula, which is the parabolic partial differential equation:
```math
\begin{aligned}
	\frac{\partial{V}}{\partial{t}} + \frac{1}{2}\sigma^{2}S^{2}\frac{\partial^{2}V}{\partial{S}^{2}} + \bar{r}S\frac{\partial{V}}{\partial{S}}  &= \bar{r}V \\
	\frac{dS}{S} &= \bar{r}\,dt + \sigma\,{dW}\\
	V(T,S) &= K(S)
\end{aligned}
```
where $V(t, S)$ is the price of the option, $S$ is the price of the underlying asset (governed by the risk-neutral geometric Brownian motion model), 
$K(S)$ is the payoff of the option at expiration, $T$ is the expiration date, $t$ is time, 
$\bar{r}$ is the risk-free interest rate, and $\sigma$ is the volatility of the underlying asset.
$t$ is time, $r$ is the risk-free interest rate, and $\sigma$ is the volatility of the underlying asset.
While we could solve the partial differential equation directly, it is more common to use the closed-form solution of the Black-Scholes-Merton pricing formula.

We implement the Black-Scholes-Merton model in the [`MyBlackScholesContractPricingModel`](@ref) type, which is used to compute the premium of European options contracts.

```@docs
VLQuantitativeFinancePackage.MyBlackScholesContractPricingModel
```

#### European call options
The Black-Scholes-Merton pricing formula for a European call option is given by the expression:
```math
\begin{equation}
	\mathcal{P}_{c}(K,S(0)) = N(d_{+})S(0) - N(d_{-})K\mathcal{D}^{-1}_{T,0}(\bar{r})
\end{equation}
```
where $N(\dots)$ denotes the standard normal cumulative distribution function, 
$S(0)$ is the price of the underlying asset at time $t=0$ (when we are evaluating the option),
$K$ is the strike price of the contract, and $\mathcal{D}^{-1}_{T,0}(\bar{r})$ is the discount factor from time $t=0$ to time $T$ evaluated at the risk-free interest rate $\bar{r}$. The arguments of the normal cumulative distribution function are given by:
```math
\begin{aligned}
d_{+} &=  \frac{1}{\sigma\sqrt{T}}\left[\ln(\frac{S_{\circ}}{K}) + (\bar{r}+\frac{\sigma^{2}}{2})T\right] \\
d_{-} &=  d_{+} - \sigma\sqrt{T}
\end{aligned}
```
We implement the Black-Scholes-Merton pricing formula for European call using the `premium` function, which takes a 
[`MyEuropeanCallContractModel`](@ref) and a [`MyBlackScholesContractPricingModel`](@ref) instance as input arguments. The function returns the premium of the contract.
```@docs
VLQuantitativeFinancePackage.premium(contract::MyEuropeanCallContractModel, 
    model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)
```

#### European put options
The Black-Scholes-Merton pricing formula for a European put option is given by the expression:
```math
\mathcal{P}_{p}(K,S(0)) = N(-d_{-})\cdot{K}\cdot\mathcal{D}^{-1}_{T,0}(\bar{r}) - N(-d_{+})\cdot{S}(0)
```
where $N(\dots)$ denotes the standard normal cumulative distribution function, 
$S(0)$ is the price of the underlying asset at time $t=0$ (when we are evaluating the option),
$K$ is the strike price of the contract, and $\mathcal{D}^{-1}_{T,0}(\bar{r})$ is the discount factor from time $t=0$ to time $T$ evaluated at the risk-free interest rate $\bar{r}$.
The arguments of the normal cumulative distribution function are given by:
```math
\begin{aligned}
d_{+} &=  \frac{1}{\sigma\sqrt{T}}\left[\ln(\frac{S_{\circ}}{K}) + (\bar{r}+\frac{\sigma^{2}}{2})T\right] \\
d_{-} &=  d_{+} - \sigma\sqrt{T}
\end{aligned}
```
We implement the Black-Scholes-Merton pricing formula for European put using the `premium` function, which takes a 
[`MyEuropeanPutContractModel`](@ref) and a [`MyBlackScholesContractPricingModel`](@ref) instance as input arguments. The function returns the premium of the contract.
```@docs
VLQuantitativeFinancePackage.premium(contract::MyEuropeanPutContractModel, 
    model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)
```

## American contract premiums
Finding the premium for American options is more complex than for European options because the holder can exercise the option at any time before the expiration date. The premium can be calculated using the binomial pricing model, or other more complex models like the trinomial tree model or monte carlo simulation approaches.

### Binomial pricing model
The binomial pricing model is a popular method for pricing American options. It uses a binomial tree to model the price of the underlying asset over time. The tree is constructed by moving up and down at each step, representing the price of the underlying asset increasing or decreasing. The premium is calculated by working backward from the expiration date to the present date, calculating the premium at each node and discounting it back to the present date.

```@docs
VLQuantitativeFinancePackage.MyAdjacencyBasedCRREquityPriceTree
VLQuantitativeFinancePackage.MyCRRLatticeNodeModel
VLQuantitativeFinancePackage.build(model::Type{MyAdjacencyBasedCRREquityPriceTree}, data::NamedTuple)
VLQuantitativeFinancePackage.populate(model::MyAdjacencyBasedCRREquityPriceTree; 
    Sₒ::Float64 = 100.0, h::Int64 = 1)
VLQuantitativeFinancePackage.premium
```

## Implied volatility
The implied volatility of an option is the volatility value that makes the theoretical option price equal to the market price. It is a measure of the market's expectation of the future volatility of the underlying asset. The implied volatility can be calculated using the Black-Scholes model or by fitting the binomial pricing model to the market price.

```@docs
VLQuantitativeFinancePackage.estimate_implied_volatility
```

## The Greeks
[The Greeks](https://en.wikipedia.org/wiki/en:Greeks_(finance)?variant=zh-tw) quantify the sensitivity of an option's premium to various factors. `Delta`, `theta`, `vega`, `rho` and `gamma` are the most widely used Greeks, measuring an option's sensitivity to changes in the underlying asset's share price, the time decay, implied volatility, the risk-free rate and the rate of change in delta, respectively. 

```@docs
VLQuantitativeFinancePackage.delta
VLQuantitativeFinancePackage.theta
VLQuantitativeFinancePackage.vega
VLQuantitativeFinancePackage.rho
VLQuantitativeFinancePackage.gamma
```

## Hedging
We can use the Greeks to construct hedging strategies to mitigate the risk associated with holding options contracts. A common hedging strategy is delta hedging, which involves taking a position in the underlying asset to offset the delta of the options contract. By continuously adjusting the position in the underlying asset, we can maintain a delta-neutral position, reducing the risk associated with changes in the underlying asset's price.

```@docs
VLQuantitativeFinancePackage.MyEquityModel
```