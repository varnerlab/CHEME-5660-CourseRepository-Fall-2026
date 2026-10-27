## Delta as a Hedging Tool for Composite Contracts
Previously, we used Delta ($\Delta$) as a sensitivity, an estimate of the probability of exercise, and the number of shares that hedges one contract. A composite position's Delta is the sum of its legs' Deltas, so the same idea hedges the whole position.

> __What is Hedging?__ 
>
> Hedging offsets potential losses in an investment by taking an opposite position in a related __counter asset__. For options, the counter asset is often the underlying asset or other options contracts.

A perfectly hedged position is insensitive to small changes in the share price. We build one by making the overall Delta of the position zero.

### What is the Delta of a Composite Contract?
Suppose the legs of $\mathcal{C}$ are American contracts on the same underlying asset (share price $S$) with the same expiration date $T$. We hold $\theta_{i}n_{i}$ contracts of leg $i$, each for $m$ shares (the contract multiplier), and $N_{S}$ shares.

The value of the portfolio at time $t$ is:
$$
\Pi(S,t)=N_S S+m\sum_{i\in\mathcal{C}} \theta_i n_i \mathcal{P}_i(S,t)
$$
where $\mathcal{P}_{i}(S,t)$ is the premium of leg $i$ at share price $S$ and time $t$.

The net Delta is the sensitivity of the portfolio value to the share price:
$$
\begin{align*}
\Delta_{\text{net}}(S,t)&=\frac{\partial \Pi}{\partial S} \\
&= \underbrace{\frac{\partial (N_S S)}{\partial S}}_{=N_S} + m\sum_{i\in\mathcal{C}} \theta_i n_i \underbrace{\frac{\partial \mathcal{P}_i}{\partial S}}_{=\Delta_i(S,t)}\\
&= N_S + \underbrace{m\sum_{i\in\mathcal{C}} \theta_i n_i \Delta_i(S,t)}_{= \Delta_{\text{opts}}(S,t)}
\end{align*}
$$
The shares contribute $N_{S}$ to the net Delta. The options contribute $\Delta_{\text{opts}}=m\,\Delta_{\mathcal{C}}$, where $\Delta_{\mathcal{C}}(S,t)=\sum_{i\in\mathcal{C}}\theta_{i}n_{i}\Delta_{i}(S,t)$ is the __composite Delta__, the Delta of the composite contract per share. Previously, we computed each leg's Delta $\Delta_{i}(S,t)$ on a binomial tree.

> __Delta-neutral position:__ A position is delta-neutral if $\Delta_{\text{net}}(S,t)=0$. We get there by choosing $N_{S}$ to offset the Delta of the options, $\Delta_{\text{opts}}(S,t)$:
> $$
> \begin{align*}
> \Delta_{\text{net}}(S,t)&= N_S + \Delta_{\text{opts}}(S,t) = 0 \\
> \Rightarrow N_S & = - \Delta_{\text{opts}}(S,t)
> \end{align*}
> $$

Let's check this with a quick calculation.

> __Quick gut-check example:__ Short $10$ calls at $\Delta = 0.6$ with $m=100$ shares/contract $\Rightarrow$ $\Delta_{\text{opts}}=10\times(-1)\times 0.6\times 100=-600$. If you also hold $N_S=+600$ shares, then $\Delta_{\text{net}}=600-600=0$ (delta-neutral).

If leg $i$ is exercised or assigned at time $\tau\le T$, set $\Delta_{i}=0$ for $t\geq\tau$ and update the shares:
* Call leg $i$: $N_S \leftarrow N_S + \theta_i \cdot m \cdot n_i$.
* Put leg $i$: $N_S \leftarrow N_S - \theta_i \cdot m \cdot n_i$.

### Delta of the Common Composite Contracts
Without shares, $\Delta_{\mathcal{C}}$ is how much the position gains per share when the share price rises 1 USD/share. The table uses a common rule for choosing strikes:

* __Short legs:__ sell the put and the call with Deltas of $-0.25$ and $0.25$, each about a one-in-four chance of finishing in the money under the risk-neutral probabilities $\mathbb{Q}$.
* __Long legs:__ buy the protecting put and call with Deltas of $-0.10$ and $0.10$, farther from the share price.
* __Straddle:__ sell the at-the-money put and call, with Deltas near $-0.5$ and $0.5$.

For one copy of each leg, the composite Delta at entry and the shares that hedge one contract ($m=100$) are:

| Composite contract | Composite Delta, $\Delta_{\mathcal{C}}$ | Shares to hedge, $N_{S}$ |
|:--|:--|:--|
| Short put | $-(-0.25)=0.25$ | $-25$ |
| Short call | $-0.25$ | $+25$ |
| Put credit spread | $-0.10-(-0.25)=0.15$ | $-15$ |
| Call credit spread | $-0.25+0.10=-0.15$ | $+15$ |
| Short straddle | $-(-0.5)-0.5\approx0$ | $\approx0$ |
| Short strangle | $-(-0.25)-0.25=0$ | $0$ |
| Protected strangle | $-(-0.25)-0.25+0.10=0.10$ | $-10$ |
| Iron condor | $-0.10-(-0.25)-0.25+0.10=0$ | $0$ |

At these strikes, the sign of $\Delta_{\mathcal{C}}$ matches the outlook. The protected strangle's long call leaves $+0.10$, which is why it leans bullish. A Delta of zero is not zero risk: as the share price moves, Gamma pulls the Delta of a short strangle or iron condor away from zero, and a large move either way still loses money.

Let's compute the Delta of a put credit spread on AMD.

> __Example:__
>
> [▶ Compute the Delta for a vertical spread on AMD](CHEME-5660-L10b-Example-Delta-VerticalSpread-Fall-2026.ipynb). In this example, we build a put credit spread on AMD and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then compute its composite Delta on the Leisen–Reimer tree and decide whether it needs a hedge with shares.

Each leg's Delta changes as the share price and the time to expiration change, so keeping a position delta-neutral means updating $N_{S}$ as they move.
___
