# L10b: The NPV and Probability of Profit of Composite Contracts
Previously, we introduced the Greeks and the probabilities of exercise and profit. Today, we work two examples with them, then combine single contracts into composite contracts. What is a composite contract worth, and when does it make money?

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
> * __Compute the POE and POP of a single contract:__ Estimate the probability of exercise (POE) and the probability of profit (POP) of a call or put from simulated share prices at expiration, under our forecast and under the risk-neutral probabilities. Compare the POE with the size of the contract's Delta.
> * __Compute the NPV and POP of a composite contract:__ Write its payoff, profit at expiration, and NPV as sums over its legs, weighted by each leg's orientation and copy number. Decide whether it opens for a debit or a credit, and estimate its POP and each leg's POE from simulated share prices.
> * __Analyze common composite contracts:__ Describe each common composite contract, from the short put to the iron condor, and read its profit diagram for the outlook, breakevens, maximum profit, and maximum loss. Explain why closing before expiration earns less: buying the legs back still pays for their extrinsic value.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
> * POE: the probability a contract finishes in the money. POP: the probability its profit at expiration is positive. Both come from simulated share prices, and the POE $\sim|\Delta_{\star}|$.
> * Profit at expiration $=$ the legs' payoffs, weighted by orientation and copy number, minus the composite premium grown to expiration. The POP is the probability that this profit is positive.
> * A profit diagram shows the breakevens, the maximum profit (the credit grown to expiration), and the maximum loss. Closing early earns less, by roughly the extrinsic value left in the legs.
>
> __For understanding__ (you will not need to reproduce or memorize these):
> * The NPV derivation and the formula tables for the eight composite contracts.

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L10b) lists this lecture's symbols with their meanings and units.

Let's get started!
___

## Examples
__We will work through these examples in lecture:__

> [▶ Let's compute the Greeks for call and put options](../L10a/CHEME-5660-L10a-Example-Greeks-PutCall-Fall-2026.ipynb). In this example, we compute the five Greeks of an American call and put on the Leisen–Reimer tree, compare them with the quoted values, and see how they change with the strike price and the time to expiration. We then convert them to short contracts and size a Delta hedge.

> [▶ Compute the POP and POE for a short call contract](../L10a/CHEME-5660-L10a-Example-POE-POP-Call-Fall-2026.ipynb). In this example, we compute the probability of profit (POP) and the probability of exercise (POE) of a short call under the risk-neutral probabilities and under our forecast, and compare the POE with Delta.

> [▶ Compute the POP and POE for a put credit spread on AMD](CHEME-5660-L10b-Example-Delta-VerticalSpread-Fall-2026.ipynb). In this example, we build a put credit spread on AMD and compute its maximum profit, maximum loss, and breakeven. We then compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities.

__Review these examples on your own.__

> [▶ Compute the POP and POE for a strangle on AMD](CHEME-5660-L10b-Example-Straddle-AMD-Earnings-Fall-2026.ipynb). In this example, we sell a strangle on AMD before an earnings release and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then buy both legs back after the release and compute the profit or loss. Setting both strikes equal turns the strangle into a straddle.
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
where $\mathcal{P}_{i}>0$ is the premium of leg $i$ (USD/share), positive whether we buy or sell it ($\theta_{i}$ sets the direction), $\mathcal{P}_{\mathcal{C}}$ is the __composite premium__, $\mathcal{D}_{T,0}(g_{y})=e^{g_{y}T}$ is the accumulation factor, and $\hat{P}_{\mathcal{C}}(S(T))$ is the __profit at expiration__ (USD/share).

As for a single contract, the NPV is the profit at expiration discounted to today. If $\mathcal{P}_{\mathcal{C}}>0$, we pay more premium than we collect, and the contract opens for a __debit__. If $\mathcal{P}_{\mathcal{C}}<0$, we collect more than we pay, and it opens for a __credit__ of $-\mathcal{P}_{\mathcal{C}}$ USD/share.

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

## Common Composite Contracts
Each contract below opens for a credit: it collects more premium than it pays. So $\mathcal{P}_{\mathcal{C}}<0$, and the first term of each profit at expiration, $-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\mathcal{C}}$, is the credit grown to expiration.

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

### Short Puts and Short Calls

<style>
  .course-diagram { color-scheme: light dark; }
  :host-context(body[data-vscode-theme-kind="vscode-light"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast-light"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-light"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast-light"] .course-diagram { color-scheme: light; }
  :host-context(body[data-vscode-theme-kind="vscode-dark"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-dark"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast"] .course-diagram { color-scheme: dark; }
  @media print { .course-diagram { color-scheme: only light !important; } }
</style>
*Figure: Two panels of the payoff (blue) and the profit (black) at expiration against the share price at expiration. Left, a short put at strike K: the profit is the credit above K and falls one for one below K, crossing zero at the breakeven, with the largest loss at a share price of zero. Right, a short call at K: the profit is the credit below K and falls without limit above K, crossing zero at the breakeven. A tick labeled S(0) marks the share price when the trade opens: above K for the put and below K for the call, so each starts out of the money. The note in each panel's upper-right corner gives its outlook: neutral to bullish for the short put, neutral to bearish for the short call.*

Selling [a put](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/shortput-uncovered), or [a call](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/shortcall-uncovered), is the building block of every structure below. With premiums $\mathcal{P}_{p}$ (put) and $\mathcal{P}_{c}$ (call) at strike $K$, the profits at expiration are, with $\theta=-1$ (a short contract) and $n=1$ (one contract):
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}-(K-S(T))^{+} && \text{short put}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}-(S(T)-K)^{+} && \text{short call}
\end{align*}
$$

Their maximum profit, breakevens $S^{\ddagger}$, and maximum losses are given by:

| | Short put | Short call |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}$ for $S(T)\geq K$ | $\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$ for $S(T)\leq K$ |
| Breakeven | $S^{\ddagger}=K-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}$ | $S^{\ddagger}=K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$ |
| Maximum loss | $K-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{p}$ at $S(T)=0$ | unlimited |

Each keeps the whole premium if it expires out of the money. The share price cannot fall below zero, so the short put's loss is bounded, but the short call's loss is not (share price could rise without limit).

### Credit Spreads

<style>
  .course-diagram { color-scheme: light dark; }
  :host-context(body[data-vscode-theme-kind="vscode-light"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast-light"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-light"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast-light"] .course-diagram { color-scheme: light; }
  :host-context(body[data-vscode-theme-kind="vscode-dark"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-dark"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast"] .course-diagram { color-scheme: dark; }
  @media print { .course-diagram { color-scheme: only light !important; } }
</style>
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
> [▶ Compute the POP and POE for a put credit spread on AMD](CHEME-5660-L10b-Example-Delta-VerticalSpread-Fall-2026.ipynb). In this example, we build a put credit spread on AMD and compute its maximum profit, maximum loss, and breakeven. We then compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities.

### Short Straddles and Strangles

<style>
  .course-diagram { color-scheme: light dark; }
  :host-context(body[data-vscode-theme-kind="vscode-light"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast-light"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-light"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast-light"] .course-diagram { color-scheme: light; }
  :host-context(body[data-vscode-theme-kind="vscode-dark"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-dark"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast"] .course-diagram { color-scheme: dark; }
  @media print { .course-diagram { color-scheme: only light !important; } }
</style>
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
> [▶ Compute the POP and POE for a strangle on AMD](CHEME-5660-L10b-Example-Straddle-AMD-Earnings-Fall-2026.ipynb). In this example, we sell a strangle on AMD before an earnings release and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then buy both legs back after the release and compute the profit or loss. Setting both strikes equal turns the strangle into a straddle.

Next, we buy long legs to cap the loss on each side of the short strangle.

### Protected Strangles and Iron Condors

<style>
  .course-diagram { color-scheme: light dark; }
  :host-context(body[data-vscode-theme-kind="vscode-light"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast-light"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-light"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast-light"] .course-diagram { color-scheme: light; }
  :host-context(body[data-vscode-theme-kind="vscode-dark"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-dark"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast"] .course-diagram { color-scheme: dark; }
  @media print { .course-diagram { color-scheme: only light !important; } }
</style>
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
Our profit diagrams are drawn at expiration. What if we close earlier? Closing a short leg means buying it back at its current premium, its intrinsic value plus its extrinsic value $E_{V}(t)$. Consider a short strangle on a share at $S(0)=100$ USD/share, a put sold at $K_{1}=90$ USD/share and a call sold at $K_{2}=110$ USD/share, opened 30 days before expiration:

<style>
  .course-diagram { color-scheme: light dark; }
  :host-context(body[data-vscode-theme-kind="vscode-light"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast-light"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-light"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast-light"] .course-diagram { color-scheme: light; }
  :host-context(body[data-vscode-theme-kind="vscode-dark"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-dark"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast"] .course-diagram { color-scheme: dark; }
  @media print { .course-diagram { color-scheme: only light !important; } }
</style>
*Figure: Two panels for a short strangle with a put at K1 = 90 and a call at K2 = 110 USD/share, opened 30 days before expiration with the share price at S(0) = 100 USD/share. Left: the profit if both legs are bought back with 30 (entry), 20, and 10 days left, in orange that darkens toward expiration, and at expiration in black, against the share price on that day. Every earlier curve lies below the profit at expiration and rises toward it. Right: at the share price S(0), the credit collected at entry (dashed) and the cost to buy both legs back (orange) against the days to expiration. The cost starts equal to the credit and decays to zero, so the gap between them, the profit if we close, grows from zero at entry to the whole credit at expiration.*

The legs are American contracts, priced on the CRR tree with volatility $\sigma=0.40$ and $g_{y}=4\%$.

__What do we see?__

* __Before expiration (left):__ Closing early earns the credit, grown to that day, minus the cost to buy both legs back. That cost still includes extrinsic value, so every earlier curve lies below the profit at expiration.
* __At the entry share price (right):__ Both legs are out of the money, so buying them back right away costs exactly the credit, all of it extrinsic value. Closing at once earns nothing.
* __Time decay:__ As the extrinsic value decays, the profit if we close rises, up to the whole credit at expiration.

So the diagrams above show the most each contract can earn at each share price. An early exit earns less, by roughly the extrinsic value left in the legs. However, premium sellers often do not wait.
* Tastylive, for example, [sells strangles about 45 days before expiration](https://www.tastylive.com/concepts-strategies/strangle) and buys them back at half the maximum profit, or about 21 days before expiration. The right panel shows that closing at $S(0)$ with 20 days left already earns close to half the credit. The left panel shows the cost of waiting: as expiration nears, the curves bend toward the kinks at the strikes, so a small move in the share price near a strike changes the profit by more.
* What if the share price moves toward a short strike, say up toward $K_{2}$? The call costs more to buy back, and closing now loses money. We can close and take the loss, or __defend__ the trade. One defense is to __roll the untested side__: buy back the put, which has lost most of its value, and sell a new put closer to the share price. The extra credit moves both breakevens up, toward the share price, but the call side's loss is still unlimited.

So whether we close early or defend the trade, we weigh the credit left to earn against what the trade can still lose.
___

## Summary
This lecture computes the probabilities of exercise and profit of a single contract, then combines single contracts into composite contracts and computes their net present value and profit at expiration.

> __Key Takeaways:__
>
> * __POE, POP, and Delta:__ We computed the probability of exercise and the probability of profit of a single contract from simulated share prices at expiration. The size of Delta approximates the POE under the risk-neutral probabilities $\mathbb{Q}$.
> * __The NPV of a composite contract is a sum over its legs:__ We weighted each leg's NPV by its orientation and copy number. The NPV is the profit at expiration discounted to today, so the POP is the probability that this profit is positive.
> * __Common composite contracts can be bullish, bearish, or neutral:__ We combined short and long puts and calls into eight contracts that open for a credit, and read each profit diagram for its outlook, breakevens, and maximum loss. The maximum profit is the credit grown to expiration, and closing early earns less, by roughly the extrinsic value left in the legs.

These results let us compare composite contracts by what they can earn, what they can lose, and how likely they are to make money.
___
