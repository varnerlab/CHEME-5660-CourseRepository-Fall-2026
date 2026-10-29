## Review: The Greeks, POE, and POP

__The Greeks.__ For small changes $\Delta S$, $\Delta\sigma$, $\Delta t$, and $\Delta g_{y}$ in the share price, the volatility, the calendar time (years), and the risk-free rate, the premium $\mathcal{P}_{\star}$ (USD/share) of a call ($\star=c$) or a put ($\star=p$) changes by:
$$
\begin{align*}
\Delta\mathcal{P}_{\star} &\approx \Delta_{\star}\,\Delta S + \frac{1}{2}\,\Gamma_{\star}\,(\Delta S)^{2} + \nu_{\star}\,\Delta\sigma + \Theta_{\star}\,\Delta t + \rho_{\star}\,\Delta g_{y}\\
&= \underbrace{\left(\Delta_{\star} + \frac{1}{2}\,\Gamma_{\star}\,\Delta S\right)\Delta S}_{\text{share price}} + \underbrace{\nu_{\star}\,\Delta\sigma}_{\text{volatility}} + \underbrace{\Theta_{\star}\,\Delta t}_{\text{time}} + \underbrace{\rho_{\star}\,\Delta g_{y}}_{\text{rate}}
\end{align*}
$$
Delta $\Delta_{\star}$ and Gamma $\Gamma_{\star}$ are the slope and the curvature of the premium in the share price. Vega $\nu_{\star}$, Theta $\Theta_{\star}$, and Rho $\rho_{\star}$ are its sensitivities to the volatility, the calendar time, and the rate. Trading platforms quote $\Theta_{\star}/365$ per day, and $\nu_{\star}/100$ and $\rho_{\star}/100$ per percentage point. One contract covers 100 shares, so it is equivalent to $100\cdot\Delta_{\star}$ shares.

__POE and POP.__ The probability of exercise (POE) is the probability that a contract finishes in the money [by more than 0.01 USD/share, the threshold for automatic exercise](https://www.optionseducation.org/referencelibrary/faq/options-exercise). The probability of profit (POP) is the probability that its profit at expiration is positive. 

For a contract with strike price $K$, the profit is positive beyond the breakeven share price $S^{\ddagger}=K\pm\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\star}$ ($+$ for a call, $-$ for a put), where $\mathcal{D}_{T,0}(g_{y})=e^{g_{y}T}$ grows the premium to the expiration $T$:
$$
\text{POE}=\begin{cases}
\mathbb{P}\left(S(T)>K+0.01\right) & \text{call}\\
\mathbb{P}\left(S(T)<K-0.01\right) & \text{put}
\end{cases}
\qquad
\text{POP}=\begin{cases}
\mathbb{P}\left(S(T)>S^{\ddagger}\right) & \text{bought a call or sold a put}\\
\mathbb{P}\left(S(T)<S^{\ddagger}\right) & \text{sold a call or bought a put}
\end{cases}
$$
We compute both from simulated share prices at expiration $S(T)$, under our belief $\mathbb{P}$. However, the POE $\sim|\Delta_{\star}|$, where $\Delta_{\star}$ is the call's or put's Delta, which is quoted by trading platforms under the risk-neutral probabilities $\mathbb{Q}$.

Let's outline pseudocode that simulates share prices at expiration and reads the POE and POP from the sample cumulative distribution function.

__Initialize__: Given the share price $S(0)$, the strike price $K$, the premium $\mathcal{P}_{\star}$ of the call or put, the time to expiration $T$ (units: years), the drift $\mu = \mu_{g}+\sigma^{2}/2$ (units: $\mathrm{yr}^{-1}$) and the volatility $\sigma$ (units: $\mathrm{yr}^{-1/2}$) under $\mathbb{P}$, the risk-free rate $g_{y}$, and the number of samples $M$. Compute the breakeven share price $S^{\ddagger}$.

1. For each sample $j = 1,2,\dots,M$ __do__:
   - a. Draw a sample from the standard normal distribution: $Z_{j}\sim\mathcal{N}(0,1)$.
   - b. Compute the share price at expiration: $S_{j}(T) \gets S(0)\exp\left[\left(\mu-\sigma^{2}/2\right)T+\sigma\sqrt{T}\,Z_{j}\right]$.
2. Compute the cumulative distribution function, the fraction of samples at or below each share price $x$: $\hat{F}(x) \gets \frac{1}{M}\cdot\#\left\{j : S_{j}(T)\leq x\right\}$.
3. Compute the probability of exercise (POE). If the contract is a call, __then__ $\text{POE} \gets 1-\hat{F}(K+0.01)$. Otherwise for a put, $\text{POE} \gets \hat{F}(K-0.01)$.
4. Compute the probability of profit (POP):
   - If we bought a call or sold a put, __then__ the profit is positive above the breakeven: $\text{POP} \gets 1-\hat{F}(S^{\ddagger})$.
   - If we sold a call or bought a put, __then__ the profit is positive below the breakeven: $\text{POP} \gets \hat{F}(S^{\ddagger})$.

__Output__: The probability of exercise $\text{POE}$ and the probability of profit $\text{POP}$.

With $\mu=g_{y}$ and $\sigma$ set to the implied volatility, the same steps give the probabilities under $\mathbb{Q}$. These are the probabilities inside the market price, not our forecast.

> __Examples:__
>
> [▶ Let's compute the Greeks for call and put options](../L10a/CHEME-5660-L10a-Example-Greeks-PutCall-Fall-2026.ipynb). In this example, we compute the five Greeks of an American call and put on the Leisen–Reimer tree, compare them with the quoted values, and see how they change with the strike price and the time to expiration. We then convert them to short contracts and size a Delta hedge.
>
> [▶ Compute the POP and POE for a short call contract](../L10a/CHEME-5660-L10a-Example-POE-POP-Call-Fall-2026.ipynb). In this example, we compute the probability of profit (POP) and the probability of exercise (POE) of a short call under the risk-neutral probabilities and under our forecast, and compare the POE with Delta.
___

## Company Profile: Akuna Capital

[Akuna Capital](https://akunacapital.com/what-we-do) is a trading firm specializing in options market making. The firm [began as an idea in Sydney](https://akunacapital.com/who-we-are/) and opened its Chicago headquarters in 2011. It now also has offices in London, Sydney, Shanghai, and Singapore. 

> __What does the firm do?__
>
> * __Options market making:__ A market maker posts prices at which it will buy and sell, and it trades with whoever accepts them. Akuna describes itself as a [proprietary trading firm](https://akunacapital.com/options-market-making/), which means it trades with its own money.
> * __Building its own models and technology:__ The firm says it designs and develops [its own trading systems, models, and infrastructure](https://akunacapital.com/what-we-do/).
> * __Teaching options:__ Akuna offers a free online [Options 101 course to "prepare you for a role in trading."](https://akunacapital.com/work-with-us/options-101/) It covers payoff diagrams, historical and implied volatility, and the Greeks. All the stuff we have been talking about!

__Explore further:__

* __Jobs and internships:__ Browse Akuna's [internships page](https://akunacapital.com/work-with-us/internships/). The Akunacademy program takes students in the second-to-last year of their degree into the technology, trading, and quant departments, and one-week Sneak Peek Weeks run at the Chicago headquarters. In October 2026, the [careers page](https://akunacapital.com/careers/) listed Summer 2027 quantitative internships in Chicago.
* __Course videos:__ The [Options 101 course](https://akunacapital.teachable.com/) includes videos that "explain what options market-makers look at while trading the markets," and its payoff diagrams are the profit diagrams we draw in this lecture!

__Connection to today's lecture:__ When we _sell a put credit spread_, a market maker such as Akuna may take the other side of one or both legs. Its premiums are set under the risk-neutral probabilities $\mathbb{Q}$, and the Delta a trading platform quotes is computed from them. So each leg's Delta approximates that leg's POE under $\mathbb{Q}$, not under our forecast $\mathbb{P}$.

The POE/POP  under our forecast $\mathbb{P}$ is __our own estimate__ of how likely the trade is to make money. In the examples, let's compute both, compare them and see what they tell us about the trade.

___
