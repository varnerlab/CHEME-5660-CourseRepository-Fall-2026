# L10b: The NPV of Composite Contracts and A New Role for Delta
Previously, we introduced the Greeks and the probabilities of exercise and profit. Today, we combine single contracts into composite contracts and use our old friend Delta in a new way. What is a composite contract worth, and when does it make money?

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
> * __Compute the net present value and the probability of profit of a composite contract:__ A composite contract combines long and short calls and puts on one underlying asset and expiration date, so its payoff, profit, and net present value are sums over its legs. Estimate the probability that its net present value is positive from simulated share prices at expiration.
> * __Analyze common composite contracts at expiration:__ Read the profit diagrams of short puts and calls, credit spreads, straddles, strangles, protected strangles, and iron condors, identify each one's outlook, and compute its breakevens, maximum profit, and maximum loss. Explain how the extrinsic value left in the legs lowers the profit of closing early.
> * __Construct delta-neutral positions using composite contracts:__ Calculate the net Delta of a portfolio of options and shares, and find the number of shares that makes it delta-neutral.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core results:__
> * Profit at expiration $=$ the sum of the legs' payoffs, weighted by orientation and copy number, minus the net premium grown to expiration. The probability of profit (POP) is the probability that this profit is positive.
> * A profit diagram shows the breakevens, the maximum profit, and the maximum loss. For the eight credit contracts in this lecture, the maximum profit is the credit grown to expiration, and the maximum loss comes from the put side or the call side.
> * Composite Delta: $\Delta_{\mathcal{C}}=\sum_{i\in\mathcal{C}}\theta_{i}n_{i}\Delta_{i}$ (per share). The net Delta of a position is the number of shares plus the Delta of the options, $\Delta_{\text{opts}}=m\,\Delta_{\mathcal{C}}$, and holding $N_{S}=-\Delta_{\text{opts}}$ shares makes it delta-neutral.
>
> __For understanding__ (you will not need to reproduce or memorize these):
> * The derivation of the net present value, and the formula tables for the eight composite contracts (for reference).

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L10b) lists this lecture's symbols with their meanings and units.

Let's get started!
___

## Examples
__We will work through these examples in lecture:__

> [▶ Compute the Delta for a vertical spread on AMD](CHEME-5660-L10b-Example-Delta-VerticalSpread-Fall-2026.ipynb). In this example, we build a put credit spread on AMD and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then compute its composite Delta on the Leisen–Reimer tree and decide whether it needs a hedge with shares.

__Review these examples on your own.__

> [▶ Compute the POP and POE for a straddle on AMD](CHEME-5660-L10b-Example-Straddle-AMD-Earnings-Fall-2026.ipynb). In this example, we sell a straddle on AMD before an earnings release and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then buy both legs back after the release and compute the profit or loss.
___

## Composite Contracts
We can combine calls and puts, and options with shares, into composite contracts. Let's look at the payoff and the net present value in general, then at specific examples.

Let $\mathcal{C}$ be a composite contract with $d$ legs, long or short puts and calls, all on the same underlying asset XYZ with the same expiration date $T$.

Its payoff per share at expiration, $\hat{V}_{\mathcal{C}}(S(T))$, is:
$$
\begin{align*}
\hat{V}_{\mathcal{C}}(S(T)) &= \sum_{i\in\mathcal{C}}\theta_{i}\;n_{i}\;\underbrace{V_{i}(K_{i},S(T))}_{\text{payoff of leg } i}
\end{align*}
$$
where $S(T)$ is the share price at expiration, $K_{i}$ is the strike price of leg $i$, and $V_{i}(K_{i},S(T))$ is its payoff, $V_{c}=(S(T)-K_{i})^{+}$ for a call or $V_{p}=(K_{i}-S(T))^{+}$ for a put. The copy number $n_{i}$ counts the contracts of leg $i$, and $\theta_{i}$ is its orientation:
$$
\theta_{i}=\begin{cases}-1 & \text{if leg } i \text{ is short (sold),}\\
1 & \text{if leg } i \text{ is long (bought).}\end{cases}
$$
The payoff of a composite contract is the sum of its legs' payoffs, weighted by orientation and copy number.

> __Why is this interesting?__ Combining options with different strikes, orientations, and quantities creates __non-linear profit structures__ that no single contract can, matched to a market view and a risk tolerance.

A composite contract can fit a bullish, bearish, or neutral outlook, or hedge an existing position. Let's start with what it is worth today.

### The Net Present Value of a Composite Contract
Previously, we wrote the net present value (NPV) of a single contract. The buyer pays the premium $\mathcal{P}$ (USD/share) today and receives the payoff at expiration, so $\operatorname{NPV}_{0}=-\mathcal{P}+\mathcal{D}^{-1}_{T,0}(g_{y})\cdot V(K,S(T))$, where $\mathcal{D}^{-1}_{T,0}(g_{y})=e^{-g_{y}T}$ discounts at the benchmark growth rate $g_{y}$. The seller's NPV is the buyer's times $\theta=-1$.

A composite contract is a sum of legs, so its NPV is the sum of the legs' NPVs, weighted by $\theta_{i}n_{i}$:
$$
\begin{align*}
\operatorname{NPV}_{0}(\mathcal{C}) &= \sum_{i\in\mathcal{C}}\theta_{i}\,n_{i}\Bigl(-\mathcal{P}_{i}+\mathcal{D}^{-1}_{T,0}(g_{y})\cdot V_{i}(K_{i},S(T))\Bigr) && \text{NPV of each leg, weighted by }\theta_{i}n_{i}\\
&= -\underbrace{\sum_{i\in\mathcal{C}}\theta_{i}\,n_{i}\,\mathcal{P}_{i}}_{=\,\mathcal{P}_{\mathcal{C}}}+\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\underbrace{\sum_{i\in\mathcal{C}}\theta_{i}\,n_{i}\,V_{i}(K_{i},S(T))}_{=\,\hat{V}_{\mathcal{C}}(S(T))} && \text{split the sum: net premium and composite payoff}\\
&= -\mathcal{P}_{\mathcal{C}}+\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\hat{V}_{\mathcal{C}}(S(T)) && \\
&= \mathcal{D}^{-1}_{T,0}(g_{y})\cdot\underbrace{\Bigl(\hat{V}_{\mathcal{C}}(S(T))-\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\mathcal{C}}\Bigr)}_{=\,\hat{P}_{\mathcal{C}}(S(T))} && \text{factor out }\mathcal{D}^{-1}_{T,0}(g_{y})\text{: profit at expiration}\\
&= \mathcal{D}^{-1}_{T,0}(g_{y})\cdot\hat{P}_{\mathcal{C}}(S(T)) &&
\end{align*}
$$
where $\mathcal{P}_{i}$ is the premium of leg $i$ (USD/share), $\mathcal{P}_{\mathcal{C}}$ is the __net premium__ of the composite contract, $\mathcal{D}_{T,0}(g_{y})=e^{g_{y}T}$ is the accumulation factor, and:
$$
\boxed{
\hat{P}_{\mathcal{C}}(S(T)) = \hat{V}_{\mathcal{C}}(S(T)) - \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{\mathcal{C}}}
$$
is the __profit at expiration__ (USD/share). As for a single contract, the NPV is the profit at expiration discounted to today. If $\mathcal{P}_{\mathcal{C}}>0$, we pay more premium than we collect, and the contract opens for a __debit__. If $\mathcal{P}_{\mathcal{C}}<0$, we collect more than we pay, and it opens for a __credit__ of $-\mathcal{P}_{\mathcal{C}}$ USD/share.

__Probability of profit:__ Because $\mathcal{D}^{-1}_{T,0}(g_{y})>0$, the NPV and the profit at expiration always have the same sign, so the probability of profit of a composite contract is:
$$
\boxed{
\text{POP}_{\mathcal{C}} = \mathbb{P}\Bigl(\operatorname{NPV}_{0}(\mathcal{C})>0\Bigr) = \mathbb{P}\Bigl(\hat{P}_{\mathcal{C}}(S(T))>0\Bigr)}
$$
where $\mathbb{P}$ is our belief about the share price at expiration. Previously, we counted the samples on the profitable side of the breakeven. Counting the samples with a positive profit gives the same answer for one contract and also works with two breakevens.

__Probability of exercise:__ Each leg has its own probability of exercise, the probability that it finishes in the money:
$$
\text{POE}_{i} = \begin{cases}
\mathbb{P}\left(S(T)>K_{i}+0.01\right) & \text{if leg } i \text{ is a call}\\
\mathbb{P}\left(S(T)<K_{i}-0.01\right) & \text{if leg } i \text{ is a put}
\end{cases}
$$

__Why expiration?__ Our profit diagrams are drawn at expiration. What if we close earlier? Closing a short leg means buying it back at its current premium, its intrinsic value plus its extrinsic value $E_{V}(t)$. Consider a short strangle on a share at $S(0)=100$ USD/share, a put sold at $K_{1}=90$ USD/share and a call sold at $K_{2}=110$ USD/share, opened 30 days before expiration:

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

* __Before expiration (left):__ Closing early earns the credit, grown to that day, minus the cost to buy both legs back. The legs still carry extrinsic value, so every earlier curve lies below the profit at expiration.
* __At the entry share price (right):__ If the share price stays at $S(0)$, buying both legs back right away costs exactly the credit, so closing at once earns nothing. Both legs are out of the money, so that cost is all extrinsic value.
* __Time decay:__ As the days pass, the extrinsic value decays and the profit if we close rises. At expiration, both legs expire worthless, and we keep the whole credit.

So the profit at expiration is the most the strangle can earn at each share price, and an early exit falls short by roughly the extrinsic value left in its legs. From here on, every diagram is the profit at expiration.
___

## Common Composite Contracts
Each contract below collects more premium than it pays, so it opens for a credit. Each has a __put side__ and a __call side__. A side is empty, a __naked__ short contract (no protection), or a __credit spread__ (a short contract protected by a long one farther from the share price). The __outlook__ follows from which side can lose. A contract that loses only if the share price falls is __neutral to bullish__. One that loses only if it rises is __neutral to bearish__, and one that loses either way is __neutral__:

| Composite contract | Put side | Call side | Outlook |
|:--|:--|:--|:--|
| [Short put](#Short-Puts-and-Short-Calls) | naked short put | none | neutral to bullish |
| [Short call](#Short-Puts-and-Short-Calls) | none | naked short call | neutral to bearish |
| [Put credit spread](#Credit-Spreads) | put credit spread | none | neutral to bullish |
| [Call credit spread](#Credit-Spreads) | none | call credit spread | neutral to bearish |
| [Short straddle](#Short-Straddles-and-Strangles) | naked short put | naked short call at the same strike | neutral |
| [Short strangle](#Short-Straddles-and-Strangles) | naked short put | naked short call at a higher strike | neutral |
| [Protected strangle](#Protected-Strangles-and-Iron-Condors) | naked short put | call credit spread | neutral, leaning bullish |
| [Iron condor](#Protected-Strangles-and-Iron-Condors) | put credit spread | call credit spread | neutral |

The sides also set the maximum loss. Only the put side can lose when the share price falls, and only the call side when it rises. An empty side loses nothing, a credit spread at most its strike width minus the credit, a naked put at most its strike minus the credit, and a naked call without limit.

Each figure shows the payoff (blue) and the profit (black) at expiration, per share, with the strikes numbered from low to high. The profit is the payoff shifted up by the credit grown to expiration, so the maximum profit is the credit grown to expiration. In each formula, $\mathcal{P}_{i}$ is the premium of the leg at strike $K_{i}$, a put on the put side and a call on the call side. We write $\mathcal{D}$ for the accumulation factor $\mathcal{D}_{T,0}(g_{y})$, which is close to one for contracts that expire within weeks.

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
*Figure: Two panels of the payoff (blue) and the profit (black) at expiration against the share price at expiration. Left, a short put at strike K: the profit is the credit above K and falls one for one below K, crossing zero at the breakeven, with the largest loss at a share price of zero. Right, a short call at K: the profit is the credit below K and falls without limit above K, crossing zero at the breakeven.*

Selling one put, a [short put](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/shortput-uncovered), or one call, a [short call](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/shortcall-uncovered), is the building block of every structure below. With premiums $\mathcal{P}_{p}$ (put) and $\mathcal{P}_{c}$ (call) at strike $K$, the profits at expiration are:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot\mathcal{P}_{p}-(K-S(T))^{+} && \text{short put}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot\mathcal{P}_{c}-(S(T)-K)^{+} && \text{short call}
\end{align*}
$$

Their maximum profit, breakevens $S^{\ddagger}$, and maximum losses are:

| | Short put | Short call |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}\cdot\mathcal{P}_{p}$ for $S(T)\geq K$ | $\mathcal{D}\cdot\mathcal{P}_{c}$ for $S(T)\leq K$ |
| Breakeven, put side | $S^{\ddagger}=K-\mathcal{D}\cdot\mathcal{P}_{p}$ | none |
| Maximum loss, put side | $K-\mathcal{D}\cdot\mathcal{P}_{p}$ at $S(T)=0$ | none |
| Breakeven, call side | none | $S^{\ddagger}=K+\mathcal{D}\cdot\mathcal{P}_{c}$ |
| Maximum loss, call side | none | unlimited |

Each keeps the whole premium if it expires out of the money. The share price cannot fall below zero, so the short put's loss is bounded, but the short call's loss is not.

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
*Figure: Two panels of the payoff (blue) and the profit (black) at expiration. Left, a put credit spread: a long put at K1 and a short put at K2. The profit is the credit above K2, falls between the strikes, crosses zero at the breakeven, and stays at the maximum loss below K1. Right, a call credit spread, its mirror image: a short call at K1 and a long call at K2, with the credit below K1 and the maximum loss above K2.*

A __vertical spread__ pairs two contracts of the same type and expiration at different strikes. A __credit spread__ sells the one closer to the share price and buys the one farther away. The short leg collects the credit, and the long leg caps the loss. The two are also called a [bull put spread](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/bull-put-spread) and a [bear call spread](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/bear-call-spread).

With $\mathcal{P}_{i}$ the premium of the leg at strike $K_{i}$, their profits at expiration are:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})-(K_{2}-S(T))^{+}+(K_{1}-S(T))^{+} && \text{put credit spread}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})-(S(T)-K_{1})^{+}+(S(T)-K_{2})^{+} && \text{call credit spread}
\end{align*}
$$
The first term is the credit grown to expiration, and the others are the leg payoffs.

Their maximum profit, breakevens, and maximum losses are:

| | Put credit spread | Call credit spread |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$ for $S(T)\geq K_{2}$ | $\mathcal{D}\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})$ for $S(T)\leq K_{1}$ |
| Breakeven, put side | $S^{\ddagger}=K_{2}-\mathcal{D}\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$ | none |
| Maximum loss, put side | $(K_{2}-K_{1})-\mathcal{D}\cdot(\mathcal{P}_{2}-\mathcal{P}_{1})$ for $S(T)\leq K_{1}$ | none |
| Breakeven, call side | none | $S^{\ddagger}=K_{1}+\mathcal{D}\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})$ |
| Maximum loss, call side | none | $(K_{2}-K_{1})-\mathcal{D}\cdot(\mathcal{P}_{1}-\mathcal{P}_{2})$ for $S(T)\geq K_{2}$ |

Beyond the long strike, the long leg gains every dollar the short leg loses, so the loss stops at the strike width minus the credit. The spread gives up part of the credit for this known maximum loss.

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
*Figure: Two panels of the payoff (blue) and the profit (black) at expiration. Left, a short straddle: a short put and a short call at one strike K. The profit peaks at the credit at K and falls on both sides, crossing zero at two breakevens, with an unlimited loss as the share price rises. Right, a short strangle: a short put at K1 and a short call at K2. The profit is the credit between the strikes, with two breakevens outside them.*

A [straddle](https://www.investopedia.com/terms/s/straddle.asp) buys (or sells) a put and a call with the _same expiration_ and the _same strike price_ $K$. A [strangle](https://www.investopedia.com/terms/s/strangle.asp) uses _different strike prices_, a put at $K_{1}$ below a call at $K_{2}$. Selling both legs gives the profit at expiration:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})-(K-S(T))^{+}-(S(T)-K)^{+} && \text{short straddle}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})-(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+} && \text{short strangle}
\end{align*}
$$
Their maximum profit, breakevens $S^{\ddagger}_{-}$ and $S^{\ddagger}_{+}$, and maximum losses are:

| | Short straddle | Short strangle |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ at $S(T)=K$ | $\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ for $K_{1}\leq S(T)\leq K_{2}$ |
| Breakeven, put side | $S^{\ddagger}_{-}=K-\mathcal{D}\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ | $S^{\ddagger}_{-}=K_{1}-\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ |
| Maximum loss, put side | $K-\mathcal{D}\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ at $S(T)=0$ | $K_{1}-\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ at $S(T)=0$ |
| Breakeven, call side | $S^{\ddagger}_{+}=K+\mathcal{D}\cdot(\mathcal{P}_{p}+\mathcal{P}_{c})$ | $S^{\ddagger}_{+}=K_{2}+\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2})$ |
| Maximum loss, call side | unlimited | unlimited |

Each profits only between its breakevens, so its probability of profit is $\mathbb{P}(S^{\ddagger}_{-}<S(T)<S^{\ddagger}_{+})$. The straddle collects more credit, but the strangle keeps its credit over a wider range of share prices. Buying both legs ($\theta_{i}=1$) flips the diagram about the zero line: the loss is capped at the premium paid, and the profit grows with a large move either way. Let's compute the POP and POE for a short straddle on AMD.

> __Review on your own:__
>
> [▶ Compute the POP and POE for a straddle on AMD](CHEME-5660-L10b-Example-Straddle-AMD-Earnings-Fall-2026.ipynb). In this example, we sell a straddle on AMD before an earnings release and compute its probability of profit and each leg's probability of exercise, both from our forecast and from the risk-neutral probabilities. We then buy both legs back after the release and compute the profit or loss.

Next, we buy long legs to protect the naked sides of the short strangle.

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
*Figure: Two panels of the payoff (blue) and the profit (black) at expiration. Left, a protected strangle: a short put at K1, a short call at K2, and a long call at K3. The profit is the credit between K1 and K2, stops at a maximum loss above K3, and keeps falling below K1. Right, an iron condor: a long put at K1, a short put at K2, a short call at K3, and a long call at K4. The profit is the credit between K2 and K3 and stops at a maximum loss on both sides.*

A __protected strangle__, or [jade lizard](https://www.tastylive.com/concepts-strategies/jade-lizard), adds a long call at $K_{3}$ to a short strangle, so its call side becomes a credit spread and its put side stays naked. An [iron condor](https://www.fidelity.com/learning-center/investment-products/options/options-strategy-guide/short-iron-condor-spread) also adds a long put, so both sides are credit spreads. Each long leg caps the loss on its side but lowers the credit.

The profits at expiration are:
$$
\begin{align*}
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3}) && \text{protected strangle}\\
&\qquad-(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+}+(S(T)-K_{3})^{+}\\
\hat{P}_{\mathcal{C}}(S(T)) &= \mathcal{D}\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4}) && \text{iron condor}\\
&\qquad+(K_{1}-S(T))^{+}-(K_{2}-S(T))^{+}-(S(T)-K_{3})^{+}+(S(T)-K_{4})^{+}
\end{align*}
$$

Their maximum profit, breakevens, and maximum losses are:

| | Protected strangle | Iron condor |
|:--|:--|:--|
| Maximum profit | $\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ for $K_{1}\leq S(T)\leq K_{2}$ | $\mathcal{D}\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ for $K_{2}\leq S(T)\leq K_{3}$ |
| Breakeven, put side | $S^{\ddagger}_{-}=K_{1}-\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ | $S^{\ddagger}_{-}=K_{2}-\mathcal{D}\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ |
| Maximum loss, put side | $K_{1}-\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ at $S(T)=0$ | $(K_{2}-K_{1})-\mathcal{D}\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ for $S(T)\leq K_{1}$ |
| Breakeven, call side | $S^{\ddagger}_{+}=K_{2}+\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ if $\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})\leq K_{3}-K_{2}$, otherwise none | $S^{\ddagger}_{+}=K_{3}+\mathcal{D}\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ |
| Maximum loss, call side | $(K_{3}-K_{2})-\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})$ for $S(T)\geq K_{3}$ if $\mathcal{D}\cdot(\mathcal{P}_{1}+\mathcal{P}_{2}-\mathcal{P}_{3})<K_{3}-K_{2}$, otherwise none | $(K_{4}-K_{3})-\mathcal{D}\cdot(\mathcal{P}_{2}+\mathcal{P}_{3}-\mathcal{P}_{1}-\mathcal{P}_{4})$ for $S(T)\geq K_{4}$ |

The protected strangle's call-side loss is capped but its put is naked, so its outlook leans bullish. A credit, grown to expiration, of at least $K_{3}-K_{2}$ removes the call-side loss, as jade lizard guides recommend. The share price finishes beyond at most one side of the iron condor, so its maximum loss is its wider strike width minus the credit.
___

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
Without shares, $\Delta_{\mathcal{C}}$ is how much the position gains per share when the share price rises 1 USD/share. A common rule sells the put and the call with Deltas of $-0.25$ and $0.25$, each with roughly a one-in-four chance of finishing in the money under the risk-neutral probabilities $\mathbb{Q}$, and buys the legs with Deltas of $-0.10$ and $0.10$ beyond them. A straddle sells the at-the-money put and call, with Deltas near $-0.5$ and $0.5$.

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

## Summary
This lecture combines single options contracts into composite contracts and computes their net present value and profit at expiration. It then introduces Delta as a hedging tool for composite positions.

> __Key Takeaways:__
>
> * __The NPV of a composite contract is the sum of its legs' NPVs:__ We weighted each leg's NPV by its orientation and copy number, which gave the same form as a single contract: a net premium today and a composite payoff at expiration. The NPV is the profit at expiration discounted to today, so the probability of profit is the probability that the NPV is positive.
> * __Common composite contracts are built from a put side and a call side:__ We classified each side as empty, naked, or a credit spread and used the sides to read the outlook and the maximum loss. Each contract's maximum profit is its credit grown to expiration, and each long leg lowers the credit but caps the loss on its side. Closing early also pays the extrinsic value left in the legs, so the profit reaches the profit at expiration only as that value decays.
> * __Delta enables construction of hedged positions:__ We wrote the net Delta of a portfolio as the number of shares held plus the weighted Deltas of the legs, and found that holding shares equal to minus the options Delta makes the position delta-neutral. At entry, the sign of the composite contract's Delta matches the outlook, and a zero Delta is not zero risk because Deltas change as the share price moves.

Understanding the net present value of composite contracts and Delta hedging enables the construction and management of complex options strategies.
___
