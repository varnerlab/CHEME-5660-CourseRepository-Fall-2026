# L11a: Composite Contracts and Their Probability of Profit
Previously, we computed the probability of exercise (POE) and the probability of profit (POP) of a single call or put from simulated share prices at expiration, under our forecast and under the risk-neutral probabilities. Today, we combine single contracts into composite contracts. What is a composite contract worth, and when does it make money?

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
> * __Compute the NPV and POP of a composite contract:__ Write its payoff, profit at expiration, and NPV as sums over its legs, weighted by each leg's orientation and copy number. Decide whether it opens for a debit or a credit, and estimate its POP and each leg's POE from simulated share prices.
> * __Analyze common composite contracts:__ Describe each common composite contract, from the short put to the iron condor, and read its profit diagram for the outlook, breakevens, maximum profit, and maximum loss.
> * __Explain why closing before expiration earns less:__ Compare the profit if we buy the legs back before expiration with the profit at expiration, and explain the difference with the extrinsic value still left in the legs. Describe how to defend a trade when the share price moves toward a short strike.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
> * Profit at expiration $=$ the legs' payoffs, weighted by orientation and copy number, minus the composite premium grown to expiration. The POP is the probability that this profit is positive.
> * A profit diagram shows the outlook, the breakevens, the maximum profit (the credit grown to expiration), and the maximum loss.
> * Closing early earns less, by roughly the extrinsic value left in the legs. Near expiration, a small move in the share price near a strike changes the profit by more.
>
> __For understanding__ (you will not need to reproduce or memorize these):
> * The NPV derivation and the formula tables for the eight composite contracts.

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L11a) lists this lecture's symbols with their meanings and units.

Let's get started!
___

## Examples
__We will work through this example in lecture:__

> [▶ Compute the POP and POE for a put credit spread on AMD](CHEME-5660-L11a-Example-Delta-VerticalSpread-Fall-2026.ipynb). In this example, we build a put credit spread on AMD and compute its maximum profit, maximum loss, and breakeven. We then compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities.

__Review these notebooks on your own:__

> [▶ Compute the POP and POE for a strangle on AMD](CHEME-5660-L11a-Example-Straddle-AMD-Earnings-Fall-2026.ipynb). In this example, we sell a strangle on AMD before an earnings release and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then buy both legs back after the release and compute the profit or loss. Setting both strikes equal turns the strangle into a straddle.

> [▶ Derive the maximum profit, maximum loss, and breakevens of a composite contract](CHEME-5660-L11a-Derivation-ProfitLossBreakeven-Fall-2026.ipynb). In this notebook, we start from the profit at expiration of a composite contract and compute its composite premium, keeping track of the sign of each leg. We then write the profit on each interval between the strikes and derive the maximum profit, maximum loss, and breakevens of a put credit spread and a short strangle. It is a derivation notebook with no code.
___

## Composite Contracts
A composite contract $\mathcal{C}$ combines $d$ legs, long or short puts and calls, on the same underlying asset with the same expiration date $T$. Its payoff per share at expiration, $\hat{V}_{\mathcal{C}}(S(T))$, is given by:
$$
\begin{align*}
\hat{V}_{\mathcal{C}}(S(T)) &= \underbrace{\sum_{i\in\mathcal{C}}\theta_{i}\;n_{i}\;\overbrace{V_{i}(K_{i},S(T))}^{\text{payoff of leg } i}}_{\text{sum of all legs}}
\end{align*}
$$
where $S(T)$ is the share price at expiration, $K_{i}$ is the strike price of leg $i$, and $V_{i}(K_{i},S(T))$ is its payoff, $V_{c}=(S(T)-K_{i})^{+}$ for a call or $V_{p}=(K_{i}-S(T))^{+}$ for a put. The copy number $n_{i}$ counts the contracts of leg $i$, and $\theta_{i}$ is its orientation:
$$
\theta_{i}=\begin{cases}-1 & \text{if leg } i \text{ is short (sold),}\\
1 & \text{if leg } i \text{ is long (bought).}\end{cases}
$$
The payoff of a composite contract is the sum of its legs' payoffs, weighted by orientation and copy number.

> __Why is this interesting?__ Different strikes, orientations, and quantities give profit shapes that no single contract can, with bullish, bearish, or neutral outlooks.

Let's start with what a composite contract is worth today.

### The Net Present Value (NPV) of a Composite Contract
A composite contract is a sum of legs, so its NPV is the sum of the legs' NPVs, weighted by $\theta_{i}n_{i}$ (perspective: buyer):
$$
\begin{align*}
\operatorname{NPV}_{0}(\mathcal{C}) &= \sum_{i\in\mathcal{C}}\theta_{i}\,n_{i}\underbrace{\Bigl(-\mathcal{P}_{i}+\overbrace{\mathcal{D}^{-1}_{T,0}(g_{y})\cdot V_{i}(K_{i},S(T))}^{\text{discounted payoff}}\Bigr)}_{\text{NPV of buying leg } i} && \text{NPV of each leg, weighted by }\theta_{i}n_{i}\\
&= -\underbrace{\sum_{i\in\mathcal{C}}\theta_{i}\,n_{i}\,\mathcal{P}_{i}}_{=\,\mathcal{P}_{\mathcal{C}}}+\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\underbrace{\sum_{i\in\mathcal{C}}\theta_{i}\,n_{i}\,V_{i}(K_{i},S(T))}_{=\,\hat{V}_{\mathcal{C}}(S(T))} && \text{split the sum: composite premium and composite payoff}\\
&= -\mathcal{P}_{\mathcal{C}}+\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\hat{V}_{\mathcal{C}}(S(T)) && \\
&= \mathcal{D}^{-1}_{T,0}(g_{y})\cdot\underbrace{\Bigl(\hat{V}_{\mathcal{C}}(S(T))-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\mathcal{C}}\Bigr)}_{=\,\hat{P}_{\mathcal{C}}(S(T))} && \text{factor out }\mathcal{D}^{-1}_{T,0}(g_{y})\text{: profit at expiration}\\
&= \mathcal{D}^{-1}_{T,0}(g_{y})\cdot\underbrace{\hat{P}_{\mathcal{C}}(S(T))}_{\text{profit at expiration}} &&
\end{align*}
$$
where $\mathcal{P}_{i}>0$ is the premium of leg $i$ (USD/share), positive whether we buy or sell it ($\theta_{i}$ sets the direction), $\mathcal{P}_{\mathcal{C}}$ is the __composite premium__, $\hat{V}_{\mathcal{C}}(S(T))$ is the __composite payoff__ (USD/share), $\mathcal{D}_{T,0}(g_{y})=e^{g_{y}T}$ is the accumulation factor at the risk-free rate $g_{y}$, and $\hat{P}_{\mathcal{C}}(S(T))$ is the __profit at expiration__ (USD/share). 

As for a single contract, the NPV is the profit at expiration discounted to today.

__Debit or credit:__ Because $\theta_{i}=1$ for a long leg and $\theta_{i}=-1$ for a short leg, the composite premium splits into the premium we pay and the premium we collect:
$$
\mathcal{P}_{\mathcal{C}}=\underbrace{\sum_{\text{long legs}}n_{i}\,\mathcal{P}_{i}}_{\text{premium we pay}}-\underbrace{\sum_{\text{short legs}}n_{i}\,\mathcal{P}_{i}}_{\text{premium we collect}}
$$
If we pay more than we collect, $\mathcal{P}_{\mathcal{C}}>0$, and the contract opens for a __debit__. If we collect more than we pay, $\mathcal{P}_{\mathcal{C}}<0$: the contract has a negative price to a buyer, so we are paid to open it, a __credit__ of $-\mathcal{P}_{\mathcal{C}}$ USD/share. For example, selling one put with premium $\mathcal{P}_{p}$ gives $\mathcal{P}_{\mathcal{C}}=-\mathcal{P}_{p}$, a credit of $\mathcal{P}_{p}$.

__Probability of profit:__ Because $\mathcal{D}^{-1}_{T,0}(g_{y})>0$, the NPV and the profit at expiration always have the same sign, so the probability of profit of a composite contract is:
$$
\boxed{
\text{POP}_{\mathcal{C}} = \mathbb{P}\Bigl(\operatorname{NPV}_{0}(\mathcal{C})>0\Bigr) = \mathbb{P}\Bigl(\hat{P}_{\mathcal{C}}(S(T))>0\Bigr)}
$$
where $\mathbb{P}$ is our belief about the share price at expiration. We count the simulated samples whose profit is positive. This works for any number of breakevens.

__Probability of exercise:__ Each leg has its own probability of exercise, the probability that it finishes in the money:
$$
\text{POE}_{i} = \begin{cases}
\mathbb{P}\left(S(T)>K_{i}+0.01\right) & \text{if leg } i \text{ is a call}\\
\mathbb{P}\left(S(T)<K_{i}-0.01\right) & \text{if leg } i \text{ is a put}
\end{cases}
$$
___

## Common Composite Credit Contracts
Each contract below opens for a __credit__: it collects more premium than it pays. So $\mathcal{P}_{\mathcal{C}}<0$, and the first term of each profit at expiration, $-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\mathcal{C}} > 0$, is the credit grown to expiration.

By choosing which puts and calls we sell and buy, we can build trades that are __bullish__, __bearish__, or __neutral__:

| Composite contract | Put side | Call side | Outlook |
|:--|:--|:--|:--|
| [Short put](#Short-Puts-and-Short-Calls) | short put at $K$ | none | neutral to bullish |
| [Short call](#Short-Puts-and-Short-Calls) | none | short call at $K$ | neutral to bearish |
| [Put credit spread](#Credit-Spreads) | short put at $K_{2}$, long put at $K_{1}<K_{2}$ | none | neutral to bullish |
| [Call credit spread](#Credit-Spreads) | none | short call at $K_{1}$, long call at $K_{2}>K_{1}$ | neutral to bearish |
| [Short straddle](#Short-Straddles-and-Strangles) | short put at $K$ | short call at $K$ | neutral |
| [Short strangle](#Short-Straddles-and-Strangles) | short put at $K_{1}$ | short call at $K_{2}>K_{1}$ | neutral |
| [Protected strangle](#Protected-Strangles-and-Iron-Condors) | short put at $K_{1}$ | short call at $K_{2}$, long call at $K_{3}>K_{2}$ | neutral, leaning bullish |
| [Iron condor](#Protected-Strangles-and-Iron-Condors) | short put at $K_{2}$, long put at $K_{1}<K_{2}$ | short call at $K_{3}$, long call at $K_{4}>K_{3}$ | neutral |

Each figure shows the payoff (blue) and the profit (black) at expiration, per share, with the strikes numbered from low to high and a tick at $S(0)$, the share price when we open the trade.

The [derivation notebook](CHEME-5660-L11a-Derivation-ProfitLossBreakeven-Fall-2026.ipynb) works through the derivation of the max profit, loss, and breakeven points for a put credit spread and a short strangle examples. 

### Buying Shares
Before combining options, let's look at the simplest position: buying one share at $S(0)$ and holding it to expiration.

*Figure: One panel of the profit at expiration (black) against the share price at expiration, for one share bought at S(0). The profit is a 45-degree line that crosses zero at the breakeven. Dashed lines drop from the line to S(0) and to the breakeven on the share price axis, and an arrow between them, labeled time value of money, shows that the share price must rise above S(0) before we break even. The largest loss, the whole purchase price grown to expiration, is at a share price of zero, and the profit rises without limit. The note in the upper-right corner gives the outlook: bullish.*

Its profit at expiration is the share price at expiration minus the purchase price grown to expiration:
$$
\hat{P}(S(T)) = S(T)-\mathcal{D}_{T,0}(g_{y})\cdot S(0)
$$
It breaks even at $S^{\ddagger}=\mathcal{D}_{T,0}(g_{y})\cdot S(0)$, slightly above $S(0)$, because the money paid for the share could have earned the risk-free rate. The profit has no upper limit, but if the share price falls to zero, we lose the whole purchase price grown to expiration.

### Short Puts and Short Calls

*Figure: Two panels of the payoff (blue) and the profit (black) at expiration against the share price at expiration. Left, a short put at strike K: the profit is the credit above K and falls one for one below K, crossing zero at the breakeven, with the largest loss at a share price of zero. Right, a short call at K: the profit is the credit below K and falls without limit above K, crossing zero at the breakeven. A tick labeled S(0) marks the share price when the trade opens: above K for the put and below K for the call, so each starts out of the money. The note in each panel's upper-right corner gives its outlook: neutral to bullish for the short put, neutral to bearish for the short call.*

Selling [a put](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/shortput-uncovered), or [a call](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/shortcall-uncovered), is the building block of every structure below. With premiums $\mathcal{P}_{p}$ (put) and $\mathcal{P}_{c}$ (call) at strike $K$, the profits at expiration are, with $\theta=-1$ (a short contract) and $n=1$ (one contract):
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}-(K-S(T))^{+} && \text{short put}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}-(S(T)-K)^{+} && \text{short call}
\end{align*}
$$

Their maximum profit, breakevens $S^{\ddagger}$, and maximum losses, next to those of one share, are given below. Maximum losses are listed as positive amounts (USD/share):

| | Short put | Short call | One share |
|:--|:--|:--|:--|
| Maximum profit | $\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}$ for $S(T)\geq K$ | $\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$ for $S(T)\leq K$ | unlimited |
| Breakeven | $S^{\ddagger}=K-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}$ | $S^{\ddagger}=K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$ | $S^{\ddagger}=\mathcal{D}_{T,0}(g_{y})\cdot S(0)$ |
| Maximum loss | $K-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}$ at $S(T)=0$ | unlimited | $\mathcal{D}_{T,0}(g_{y})\cdot S(0)$ at $S(T)=0$ |

Each keeps the whole premium if it expires out of the money. The share price cannot fall below zero, so the short put's loss is bounded, but the short call's loss is not (share price could rise without limit). 

### Credit Spreads

*Figure: Two panels of the payoff (blue) and the profit (black) at expiration. Left, a put credit spread: a long put at K1 and a short put at K2. The profit is the credit above K2, falls between the strikes, crosses zero at the breakeven, and stays at the maximum loss below K1. Right, a call credit spread, its mirror image: a short call at K1 and a long call at K2, with the credit below K1 and the maximum loss above K2. A tick labeled S(0) marks the share price when the trade opens, between the two spreads, so both start out of the money. The note in each panel's upper-right corner gives its outlook: neutral to bullish for the put credit spread, neutral to bearish for the call credit spread.*

A __vertical spread__ pairs two contracts of the same type and expiration at different strikes. A __credit spread__ sells the one closer to the share price and buys the one farther away. The short leg collects the credit, and the long leg caps the loss. The two are also called a [bull put spread](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/bull-put-spread) and a [bear call spread](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/bear-call-spread).

With $\mathcal{P}_{i}$ the premium of the leg at strike $K_{i}$, their profits at expiration are:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})-(K_{2}-S(T))^{+}+(K_{1}-S(T))^{+} && \text{put credit spread}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})-(S(T)-K_{1})^{+}+(S(T)-K_{2})^{+} && \text{call credit spread}
\end{align*}
$$
The first term is the credit grown to expiration, and the others are the leg payoffs. Their maximum profit, breakevens, and maximum losses are:

| | Put credit spread | Call credit spread |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$ for $S(T)\geq K_{2}$ | $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})$ for $S(T)\leq K_{1}$ |
| Breakeven | $S^{\ddagger}=K_{2}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$ | $S^{\ddagger}=K_{1}+\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})$ |
| Maximum loss | $(K_{2}-K_{1})-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$ for $S(T)\leq K_{1}$ | $(K_{2}-K_{1})-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})$ for $S(T)\geq K_{2}$ |

Beyond the long strike, the long leg gains every dollar the short leg loses, so the loss stops at the strike width minus the credit. The spread gives up part of the credit for this known maximum loss. Let's compute the POP and POE for a put credit spread on AMD.

> __Example:__
>
> [▶ Compute the POP and POE for a put credit spread on AMD](CHEME-5660-L11a-Example-Delta-VerticalSpread-Fall-2026.ipynb). In this example, we build a put credit spread on AMD and compute its maximum profit, maximum loss, and breakeven. We then compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities.

### Short Straddles and Strangles

*Figure: Two panels of the payoff (blue) and the profit (black) at expiration. Left, a short straddle: a short put and a short call at one strike K. The profit peaks at the credit at K and falls on both sides, crossing zero at two breakevens, with an unlimited loss as the share price rises. Right, a short strangle: a short put at K1 and a short call at K2. The profit is the credit between the strikes, with two breakevens outside them. The straddle's strike is labeled K = S(0), at the share price when the trade opens, and a tick labeled S(0) sits between the strangle's strikes. The note in each panel's upper-right corner gives its outlook: neutral for both.*

A [straddle](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/short-straddle) buys (or sells) a put and a call with the _same expiration_ and the _same strike price_ $K$. A [strangle](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/short-strangle) uses _different strike prices_, a put at $K_{1}$ below a call at $K_{2}$. Selling both legs gives the profit at expiration:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})-(K-S(T))^{+}-(S(T)-K)^{+} && \text{short straddle}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})-(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+} && \text{short strangle}
\end{align*}
$$
Their maximum profit, breakevens $S^{\ddagger}_{-}$ and $S^{\ddagger}_{+}$, and maximum losses are:

| | Short straddle | Short strangle |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ at $S(T)=K$ | $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ for $K_{1}\leq S(T)\leq K_{2}$ |
| Lower breakeven | $S^{\ddagger}_{-}=K-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ | $S^{\ddagger}_{-}=K_{1}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ |
| Maximum loss below $S^{\ddagger}_{-}$ | $K-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ at $S(T)=0$ | $K_{1}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ at $S(T)=0$ |
| Upper breakeven | $S^{\ddagger}_{+}=K+\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ | $S^{\ddagger}_{+}=K_{2}+\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ |
| Maximum loss above $S^{\ddagger}_{+}$ | unlimited | unlimited |

Each profits only between its breakevens, so its probability of profit is $\mathbb{P}(S^{\ddagger}_{-}<S(T)<S^{\ddagger}_{+})$. The straddle collects more credit, but the strangle keeps its credit over a wider range of share prices. 

Let's compute the POP and POE for a short strangle on AMD.

> __Review on your own:__
>
> [▶ Compute the POP and POE for a strangle on AMD](CHEME-5660-L11a-Example-Straddle-AMD-Earnings-Fall-2026.ipynb). In this example, we sell a strangle on AMD before an earnings release and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then buy both legs back after the release and compute the profit or loss. Setting both strikes equal turns the strangle into a straddle.

Next, we buy long legs to cap the loss on each side of the short strangle.

### Protected Strangles and Iron Condors

*Figure: Two panels of the payoff (blue) and the profit (black) at expiration. Left, a protected strangle: a short put at K1, a short call at K2, and a long call at K3. The profit is the credit between K1 and K2, stops at a maximum loss above K3, and keeps falling below K1. Right, an iron condor: a long put at K1, a short put at K2, a short call at K3, and a long call at K4. The profit is the credit between K2 and K3 and stops at a maximum loss on both sides. In both panels, a tick labeled S(0) marks the share price when the trade opens, between the short put and the short call. The note in each panel's upper-right corner gives its outlook: neutral, leaning bullish for the protected strangle, neutral for the iron condor.*

A __protected strangle__, or [jade lizard](https://www.tastylive.com/concepts-strategies/jade-lizard), adds a long call at $K_{3}$ to a short strangle, so its call side becomes a credit spread and its put side has no long put to cap its loss. An [iron condor](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/short-iron-condor-spread) also adds a long put, so both sides are credit spreads. Each long leg caps the loss on its side but lowers the credit.

The profits at expiration are:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3}) && \text{protected strangle}\\
&\qquad-(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+}+(S(T)-K_{3})^{+}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4}) && \text{iron condor}\\
&\qquad+(K_{1}-S(T))^{+}-(K_{2}-S(T))^{+}-(S(T)-K_{3})^{+}+(S(T)-K_{4})^{+}
\end{align*}
$$

Their maximum profit, breakevens, and maximum losses are:

| | Protected strangle | Iron condor |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ for $K_{1}\leq S(T)\leq K_{2}$ | $\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ for $K_{2}\leq S(T)\leq K_{3}$ |
| Lower breakeven | $S^{\ddagger}_{-}=K_{1}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ | $S^{\ddagger}_{-}=K_{2}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ |
| Maximum loss below $S^{\ddagger}_{-}$ | $K_{1}-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ at $S(T)=0$ | $(K_{2}-K_{1})-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ for $S(T)\leq K_{1}$ |
| Upper breakeven | $S^{\ddagger}_{+}=\begin{cases}K_{2}+\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3}) & \text{if } \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})\leq K_{3}-K_{2}\\ \text{none} & \text{otherwise}\end{cases}$ | $S^{\ddagger}_{+}=K_{3}+\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ |
| Maximum loss above $S^{\ddagger}_{+}$ | $\begin{cases}(K_{3}-K_{2})-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})\text{ for }S(T)\geq K_{3} & \text{if } \mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})<K_{3}-K_{2}\\ \text{none} & \text{otherwise}\end{cases}$ | $(K_{4}-K_{3})-\mathcal{D}_{T,0}(g_{y})\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ for $S(T)\geq K_{4}$ |

The protected strangle's call side is capped but its put side is not, so it leans bullish. If the credit grown to expiration is at least $K_{3}-K_{2}$, the call side cannot lose. At any share price at expiration, at most one side of the iron condor can lose, so its maximum loss is its wider strike width minus the credit.

### Why Wait to Expiration?
Our profit diagrams are drawn at expiration. What if we choose to close the trade earlier? 

Closing a short leg means buying it back at its current premium, its intrinsic value plus its extrinsic value $E_{V}(t)$. Consider a short strangle on a share at $S(0)=100$ USD/share, a put sold at $K_{1}=90$ USD/share and a call sold at $K_{2}=110$ USD/share, opened 30 days before expiration:

*Figure: Two panels for a short strangle with a put at K1 = 90 and a call at K2 = 110 USD/share, opened 30 days before expiration with the share price at S(0) = 100 USD/share. Left: the profit if both legs are bought back with 30 (entry), 20, and 10 days left, in orange that darkens toward expiration, and at expiration in black, against the share price on that day. Every earlier curve lies below the profit at expiration and rises toward it. Right: at the share price S(0), the credit collected at entry (dashed) and the cost to buy both legs back (orange) against the days to expiration. The cost starts equal to the credit and decays to zero, so the gap between them, the profit if we close, grows from zero at entry to the whole credit at expiration.*

The legs are American contracts, priced on the CRR tree with volatility $\sigma=0.40$ and $g_{y}=4\%$.

__What do we see?__

* __Before expiration (left):__ Closing early earns the credit, grown to that day, minus the cost to buy both legs back. That cost still includes extrinsic value, so every earlier curve lies below the profit at expiration.
* __At the entry share price (right):__ Both legs are out of the money, so buying them back right away costs exactly the credit, all of it extrinsic value. Closing at once earns nothing.
* __Time decay:__ As the extrinsic value decays, the profit if we close rises, up to the whole credit at expiration.

An early exit earns less, by roughly the extrinsic value left in the legs. However, premium sellers often do not wait until expiration to close. They may close early to lock in a profit, or to defend against a move in the share price toward one of the short strikes.
* __Close early__: Tastylive, for example, [sells strangles about 45 days before expiration](https://www.tastylive.com/concepts-strategies/strangle) and buys them back at half the maximum profit, or about 21 days before expiration. The right panel shows that closing at $S(0)$ with 20 days left already earns close to half the credit. The left panel shows the cost of waiting: as expiration nears, the curves bend toward the kinks at the strikes, so a small move in the share price near a strike changes the profit by more.
* __Defend__: What if the share price moves toward a short strike, say up toward $K_{2}$? The call costs more to buy back, and closing now loses money. We can close and take the loss, or __defend__ the trade. One defense is to __roll the untested side__: buy back the put, which has lost most of its value, and sell a new put closer to the share price. The extra credit moves both breakevens up, toward the share price, but the call side's loss is still unlimited.

So whether we close early or defend the trade, we weigh the credit left to earn against what the trade can still lose.
___

## Summary
This lecture combines single contracts into composite contracts, computes their net present value and profit at expiration, and analyzes the common composite contracts that open for a credit.

> __Key Takeaways:__
>
> * __The NPV of a composite contract is a sum over its legs:__ We weighted each leg's NPV by its orientation and copy number. The NPV is the profit at expiration discounted to today, so the POP is the probability that this profit is positive.
> * __Common composite contracts can be bullish, bearish, or neutral:__ We combined short and long puts and calls into eight contracts that open for a credit, and read each profit diagram for its outlook, breakevens, and maximum loss. The maximum profit is the credit grown to expiration.
> * __Closing before expiration earns less:__ We used a short strangle, with its legs priced on the CRR tree, to compare the profit if we close early with the profit at expiration. Buying the legs back still pays for their extrinsic value, so an early exit earns less, by roughly the extrinsic value left in the legs. Whether we close early or defend the trade, we weigh the credit left to earn against what the trade can still lose.

These results let us compare composite contracts by what they can earn, what they can lose, and how likely they are to make money.
___
