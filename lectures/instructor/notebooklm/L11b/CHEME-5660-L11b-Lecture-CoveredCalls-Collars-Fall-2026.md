# L11b: Covered Calls and Protective Collars
In this lecture, we analyze two strategies that combine shares with options: covered calls, which sell a call on the shares to collect its premium, and protective collars, which add a put to protect the shares. What can each trade earn and lose, and how does its value change with the share price?

> __Learning Objectives:__
> 
> By the end of this lecture, you should be able to:
> * __Analyze a covered call:__ Derive the profit at expiration of shares plus a short call, identify the two regimes based on whether the call is exercised or expires worthless, and compute the breakeven, maximum profit, and maximum loss.
> * __Analyze a protective collar:__ Derive the profit at expiration of shares plus a long put and a short call, identify the three regimes based on which option, if any, is exercised, and compute the breakeven, maximum profit, and maximum loss.
> * __Calculate the net Delta of a covered call and a collar:__ Compute the net Delta of each position from the Deltas of its option legs, and explain why the short call and the long put lower it from that of the shares alone.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
> * A covered call owns $m$ shares for each call it sells. Its profit at expiration is $\min(S(T),K)-\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)-\mathcal{P}_{c}\right)$ per share: the premium lowers the breakeven, and the call caps the profit at the strike.
> * A protective collar adds a long put at $K_{1}$ to a covered call with its call at $K_{2}>K_{1}$. Its profit at expiration is $S(T)+(K_{1}-S(T))^{+}-(S(T)-K_{2})^{+}-\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)$ per share: the put sets a floor, and the call a cap.
> * The net Delta of a covered call is $mn\left(1-\Delta_{c}\right)$ and that of a collar is $mn\left(1+\Delta_{p}-\Delta_{c}\right)$. A covered call's net Delta is never negative, and a collar's put and call can only lower its net Delta from that of the shares.
>
> __For understanding__ (you will not need to reproduce or memorize these):
> * The derivation of the net Delta of a portfolio, delta-neutral positions, and the composite Delta table, in the [derivation notebook](CHEME-5660-L11b-Derivation-NetDelta-Fall-2026.ipynb).

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L11b) lists this lecture's symbols with their meanings and units.

Let's get started!
___

## Examples
__We will work through these examples in lecture:__

> [▶ Analyze a covered call position on `AMD`](CHEME-5660-L11b-Example-AnalysisCoveredCall-Fall-2026.ipynb). In this example, we buy shares of `AMD` and sell a call on them using recent options chain data. We compute the breakeven, maximum profit, and maximum loss, and plot the profit at expiration. We then estimate the probability of a loss, of the maximum profit, and of giving up gains above the strike price, under our belief about the share price and under the risk-neutral probabilities.

> [▶ Analyze a protective collar on `SPY`](CHEME-5660-L11b-Example-StandardListed-SPY-ProtectiveCollar-Fall-2026.ipynb). In this example, we buy `SPY` shares, buy a put, and sell a call using the `SPY` options chain on the quote date. We compute the collar's maximum profit, breakeven, and maximum loss, compare its profit at expiration with holding the shares, and estimate the probabilities of a loss and of ending at the floor or at the cap.

__Review these notebooks on your own:__

> [▶ Simulate a covered call fund on a hypothetical stock](CHEME-5660-L11b-Example-CoveredCallFund-SPY-Fall-2026.ipynb). In this example, we simulate a fund that owns shares of `XYZ`, a hypothetical stock with the drift and volatility of `SPY`, and sells one-month out-of-the-money calls on them every month, in the style of covered call funds such as FEPI. We compare its one-year growth rate with that of a benchmark that holds the same shares and opens with the same cash but sells no calls, and see how the premiums cushion losses while the sold calls give up gains.

> [▶ Derive the net Delta of shares and options](CHEME-5660-L11b-Derivation-NetDelta-Fall-2026.ipynb). In this notebook, we derive the net Delta of a portfolio of cash, shares, and options, find the number of shares that makes a position delta-neutral, and apply the result to covered calls, collars, and the composite contracts from L11a.
___

## Company Profile: J.P. Morgan Asset Management
[J.P. Morgan Asset Management](https://am.jpmorgan.com/us/en/asset-management/adv/) is the investment management business of JPMorganChase. It runs two large covered call funds: the [JPMorgan Equity Premium Income ETF (JEPI)](https://am.jpmorgan.com/us/en/asset-management/adv/products/jpmorgan-equity-premium-income-etf-etf-shares-46641q332), launched in May 2020 and benchmarked to the S&P 500, and the [JPMorgan Nasdaq Equity Premium Income ETF (JEPQ)](https://am.jpmorgan.com/us/en/asset-management/adv/products/jpmorgan-nasdaq-equity-premium-income-etf-etf-shares-46654q203), launched in May 2022 and benchmarked to the Nasdaq-100. 

> __What do JEPI and JEPQ do?__
>
> On September 30, 2026, JEPI held about 45 billion USD and JEPQ about 44 billion USD.
>
> * __Shares plus sold options:__ Each fund owns U.S. large-cap stocks and sells calls on its index, seeking monthly income from the premiums and dividends. Their 12-month dividend yields were 8.04% (JEPI) and 11.56% (JEPQ).
> * __Equity-linked notes (ELNs):__ The calls are sold through equity-linked notes (ELNs), bank-issued notes whose payments follow the index with sold calls built in. The fund collects the premiums but gives up index gains above the strikes.

This differs from today's covered call in two ways: the calls are on the index, not on the fund's own stocks, so the two can move in different directions; and each ELN is a bank's promise, so the fund can lose money if the bank fails to pay (credit risk).

__Explore further:__

* __Jobs and internships:__ The [Asset Management Summer Analyst Program](https://www.jpmorganchase.com/careers/explore-opportunities/programs/asset-management-summer-analyst) has client and investments tracks. Investments analysts "work with client portfolio managers, traders, research analysts, marketers and client advisors."
* __The funds:__ The [JEPI](https://am.jpmorgan.com/content/dam/jpm-am-aem/americas/us/en/literature/fact-sheet/etfs/FS-JEPI.PDF) and [JEPQ](https://am.jpmorgan.com/content/dam/jpm-am-aem/americas/us/en/literature/fact-sheet/etfs/FS-JEPQ.PDF) fact sheets list holdings, sectors, volatility, and yields. Compare JEPI's volatility over the past three years, computed from monthly data (7.78% per year), with that of the S&P 500 (12.42% per year).

__A closer model: REX and FEPI.__ The [REX FANG & Innovation Equity Premium Income ETF (FEPI)](https://www.rexshares.com/rex-covered-call-etfs/) runs today's covered call: it owns 15 large technology stocks, including AMD, and sells slightly out-of-the-money calls on them. According to its [annual report to the SEC](https://www.sec.gov/Archives/edgar/data/1771146/000199937126021985/fepi-ncsr_073126.htm), it held about 0.65 billion USD on July 31, 2026, and trailed its index over the prior year because its sold calls gave up gains as technology stocks rose.

__Connection to today's lecture:__ JEPI and JEPQ show the scale of the covered call business; FEPI shows the covered call itself, shares plus a sold call on those same shares. Let's explore how these funds work and how they compare with holding the shares.
___

## Covered Calls
A __covered call__ owns shares and sells a call against them, collecting the premium. Let's watch a short video from SMB Capital, a proprietary trading firm in New York: [Simple & Low Risk Investing Strategy](https://varnerlab.org/watch.html?v=Tid1rfVIc9c). SMB's YouTube channel has [many more covered call videos](https://www.youtube.com/@smbcapital/search?query=covered%20call).

> __Naked calls:__ Selling a call without owning the shares is a __naked call__, which carries unlimited risk if the share price rises. The shares in a covered call cover that obligation.

Besides the funds in the company profile, covered call ETFs such as the [Global X NASDAQ 100 Covered Call ETF (QYLD)](https://www.globalxetfs.com/funds/qyld/) run this strategy for you.

### Profit at Expiration
We buy 100 shares at $S(0)$ and sell one call per $m=100$ shares, with strike $K$, premium $\mathcal{P}_{c}$, and expiration $T$. Per share, we pay $S(0)-\mathcal{P}_{c}$ today. 

*Figure: One panel of the profit at expiration against the share price at expiration, for a covered call (black), the shares alone (gray, dashed), and the short call alone (blue). The covered call's profit rises one for one with the share price, crosses zero at the breakeven, and is flat above the strike K of the short call, where the call caps it. The shares alone lie below the covered call by the premium and keep rising above the strike. The dashed line crosses the covered call's maximum profit at the opportunity point O+, marked with an open circle just to the right of K. Above O+, a shaded wedge between the two lines, labeled opportunity loss, shows how much more the shares alone earn. The short call alone is flat at the premium grown to expiration below K and falls one for one above K; it crosses zero at an open blue circle labeled short call breakeven, directly below O+ and joined to it by a dashed line. The covered call's largest loss is at a share price of zero, and its maximum profit is the flat stretch above K. A tick labeled S(0) marks the share price when the trade opens, below K.*

At expiration, we own shares worth $S(T)$ and owe the call's payoff $(S(T)-K)^{+}$. The profit at expiration $\hat{P}(S(T))$ (USD/share) is given by:
$$
\begin{align*}
\hat{P}(S(T)) &= S(T) - \left(S(T) - K\right)^{+} - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) - \mathcal{P}_{c}\right)\\
&= \underbrace{\left(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot S(0)\right)}_{\text{shares}} + \underbrace{\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} - \left(S(T) - K\right)^{+}}_{\text{short call}}
\end{align*}
$$
We assume no dividends and no early exercise. We have two profit regimes, depending on whether the call is exercised or expires worthless:
$$
\boxed{
\hat{P}(S(T)) = \begin{cases}
\overbrace{K - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) - \mathcal{P}_{c}\right)}^{\text{realized gain}}, & \text{if } S(T) > K\;\text{(call exercised)}\\
\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} + \underbrace{\left(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot S(0)\right)}_{\text{unrealized gain (no share sale)}}, & \text{if } S(T) \leq K\;\text{(call expires worthless)}
\end{cases}}
$$
For $n$ contracts, multiply by $mn$. The maximum profit, breakeven $S^{\ddagger}$, maximum loss, and opportunity point $O^{+}$ are given by:

* __Maximum profit:__ $K-\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)-\mathcal{P}_{c}\right)$, when $S(T)\geq K$.
* __Breakeven:__ $S^{\ddagger}=\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)-\mathcal{P}_{c}\right)$.
* __Maximum loss:__ $\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)-\mathcal{P}_{c}\right)$, when $S(T)=0$. Maximum losses are listed as positive amounts (USD/share).
* __Opportunity point:__ $O^{+}=K+\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c}$, the share price at which the shares alone reach the maximum profit. It is also the breakeven of the short call alone. When $S(T)>O^{+}$, holding the shares alone earns more, an __opportunity loss__.

Let's look at some examples:

> __Example:__
>
> [▶ Analyze a covered call position on `AMD`](CHEME-5660-L11b-Example-AnalysisCoveredCall-Fall-2026.ipynb). In this example, we buy shares of `AMD` and sell a call on them using recent options chain data. We compute the breakeven, maximum profit, and maximum loss, and plot the profit at expiration. We then estimate the probability of a loss, of the maximum profit, and of giving up gains above the strike price, under our belief about the share price and under the risk-neutral probabilities.

> __Review on your own:__
>
> [▶ Simulate a covered call fund on a hypothetical stock](CHEME-5660-L11b-Example-CoveredCallFund-SPY-Fall-2026.ipynb). In this example, we simulate a fund that owns shares of `XYZ`, a hypothetical stock with the drift and volatility of `SPY`, and sells one-month out-of-the-money calls on them every month, in the style of covered call funds such as FEPI. We compare its one-year growth rate with that of a benchmark that holds the same shares and opens with the same cash but sells no calls, and see how the premiums cushion losses while the sold calls give up gains.

Next, we add a put to the covered call to protect the shares: this is called a __protective collar__.
___

## Protective Collars
A __protective collar__ adds a long put to a covered call: we own the shares, buy a put with a strike $K_{1}$ below the share price, and sell a call with a strike $K_{2}>K_{1}$, all with the same expiration. 

### Profit at Expiration
We buy shares at $S(0)$, and for every $m = 100$ shares we buy one put at $K_{1}<S(0)$ with premium $\mathcal{P}_{1}$ and sell one call at $K_{2}>S(0)$ with premium $\mathcal{P}_{2}$. Per share, we pay $S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}$ today. 

*Figure: Three panels of the profit at expiration against the share price at expiration, for a protective collar (black), the shares alone (gray, dashed), and the long put at K1 and short call at K2 together (blue), named in one legend below the panels. Left, a net credit: between the strikes the collar lies above the shares, and the shares reach the collar's maximum profit at the opportunity point O+, an open circle to the right of K2. Middle, a zero-cost collar: the collar and the shares coincide between the strikes, and O+ is at K2. Right, a net debit: the collar lies below the shares between the strikes, and no O+ is marked. In each panel, a shaded region labeled opportunity loss marks where the shares alone earn more than the collar: above O+ for the credit and the zero-cost collar, and above the point where the shares cross the floor for the debit. The options together are flat at the net premium grown to expiration between the strikes, rise to the left of K1, and fall to the right of K2; the shading begins where they drop below zero. For the credit, they cross zero at an open blue circle directly below O+, joined to it by a dashed line; for the zero-cost collar, they lie along the zero line between the strikes; for the debit, they cross zero at an open blue circle left of K1, joined by a dashed line to where the shares cross the floor and the shading starts. The breakeven is a red circle, and a tick labeled S(0) marks the share price when the trade opens, between the strikes.*

We own shares worth $S(T)$, the put pays $(K_{1}-S(T))^{+}$, and we owe the call's payoff $(S(T)-K_{2})^{+}$ at expiration. Thus, the profit at expiration $\hat{P}(S(T))$ (USD/share) is given by:
$$
\hat{P}(S(T)) = S(T) + \left(K_{1} - S(T)\right)^{+} - \left(S(T) - K_{2}\right)^{+} - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) + \mathcal{P}_{1} - \mathcal{P}_{2}\right)
$$
We again assume no dividends and no early exercise. At most one of the two options pays at expiration, so the profit (per share) at expiration has three regimes, depending on which option, if any, is exercised:
$$
\boxed{
\hat{P}(S(T)) = \begin{cases}
K_{1} - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) + \mathcal{P}_{1} - \mathcal{P}_{2}\right), & \text{if } S(T) < K_{1}\;\text{(put exercised)}\\
S(T) - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) + \mathcal{P}_{1} - \mathcal{P}_{2}\right), & \text{if } K_{1} \leq S(T) \leq K_{2}\;\text{(both expire worthless)}\\
K_{2} - \mathcal{D}_{T,0}(g_{y})\cdot\left(S(0) + \mathcal{P}_{1} - \mathcal{P}_{2}\right), & \text{if } S(T) > K_{2}\;\text{(call exercised)}
\end{cases}}
$$
For $n$ contracts, multiply the profit by $mn$ to get the absolute profit.

The maximum profit, breakeven $S^{\ddagger}$, maximum loss, and opportunity point $O^{+}$ (USD/share) are given by:

* __Maximum profit:__ $K_{2}-\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)$, when $S(T)\geq K_{2}$.
* __Breakeven:__ $S^{\ddagger}=\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)$, when it lies between $K_{1}$ and $K_{2}$.
* __Maximum loss:__ $\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)-K_{1}$, when $S(T)\leq K_{1}$. Maximum losses are listed as positive amounts (USD/share). If $\mathcal{D}_{T,0}(g_{y})\cdot\left(S(0)+\mathcal{P}_{1}-\mathcal{P}_{2}\right)\leq K_{1}$, the collar cannot lose, and there is no maximum loss.
* __Opportunity point:__ $O^{+}=K_{2}+\mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{2}-\mathcal{P}_{1}\right)$, the share price at which the shares alone reach the maximum profit. It lies above $K_{2}$ for a net credit, at $K_{2}$ for a zero-cost collar, and below $K_{2}$ for a net debit. When $S(T)>O^{+}$, holding the shares alone earns more, an __opportunity loss__. For a net debit, the shares alone earn more than the collar for any $S(T)>K_{1}-\mathcal{D}_{T,0}(g_{y})\cdot\left(\mathcal{P}_{1}-\mathcal{P}_{2}\right)$, the share price at which the shares alone reach the collar's floor.

In the special case where $\mathcal{P}_{1}=\mathcal{P}_{2}$, the call premium pays for the entire put: a __zero-cost collar__. Thus, we have shares with a defined risk and reward, and the two options cost nothing up front! 

> __TJUL, a collar inside a exchange-traded fund__
>
> The [Innovator Equity Defined Protection ETF (TJUL)](https://www.innovatoretfs.com/etf/?ticker=TJUL) runs a collar on `SPY` for you, with a two-year expiration. The current period runs from July 1, 2025 to June 30, 2027. On July 31, 2026, the fund's latest public [holdings report](https://www.sec.gov/Archives/edgar/data/1415726/000089418926028218/0000894189-26-028218-index.htm), filed with the U.S. Securities and Exchange Commission (SEC), listed three FLEX options on `SPY` (exchange-traded options whose strike and expiration the fund picks), all expiring June 30, 2027:
>
> * __Long call, strike 11.12:__ This call is so deep in the money that it moves almost one for one with `SPY`. The fund holds it instead of the shares, so it gets no dividends.
> * __Long put, strike 617.85:__ `SPY` started the period at 617.85, so this put protects against any fall in the price of `SPY` below where it started.
> * __Short call, strike 701.94:__ This call caps the gain, as in a covered call. Its strike is 13.61% above the starting price: $617.85\times{1.1361} = 701.94$.
>
> The fund's goal: if you hold TJUL for the whole two years, its share price rises as much as the price of `SPY`, up to 13.61%, and does not fall if `SPY` falls. Both outcomes are before fees.

Where is TJUL at today?

> To see where TJUL sits on the collar diagram today, we use its holdings reports, which funds file with the SEC and anyone can read for free on [EDGAR](https://www.sec.gov/edgar/search/), the SEC's online database of company and fund filings:
>
> * __Premiums:__ TJUL's [holdings report for July 31, 2025](https://www.sec.gov/Archives/edgar/data/1415726/000089418925008511/0000894189-25-008511-index.htm) shows that the fund paid about $\mathcal{P}_{1}=45.46$ USD/share for the put and received about $\mathcal{P}_{2}=34.23$ USD/share for the call, so TJUL is a net debit collar.
> * __Today:__ On November 4, 2026, `SPY` closed at 766.81, well above $K_{2}$.
> * __At expiration:__ If `SPY` stays there until June 30, 2027, the collar ends at its maximum profit, about 77 USD/share below holding `SPY` alone.
> * __Dividends:__ The figure draws the collar on shares bought at $S(0)$, as in this lecture. TJUL holds the call at 11.12 instead and gives up the dividends, so compared with holding `SPY` and collecting its dividends, the gap is the same, about 77 USD/share.
>
> Thus, TJUL sits on the cap, in the shaded opportunity loss region of the net debit diagram:

*Figure: One panel, drawn to scale, of the profit at expiration (USD/share) against the SPY price at expiration, for TJUL's put and call drawn as a collar on shares bought at S(0) (black), SPY alone (gray, dashed), and the long put and short call together (blue), named in a legend below the panel. The long put strike K1 equals S(0), 617.85, and the short call strike K2 is 701.94. The collar is flat at a floor of about -59 below K1, rises one for one between the strikes through the breakeven (red circle) near 677, and is flat at a cap of about +25 above K2. The options together cross zero at an open blue circle near 606, joined by a dashed line to where SPY alone crosses the floor; above that point a shaded region marks where SPY alone earns more than the collar. An orange dashed line marks the SPY close on November 4, 2026, S = 766.81, with orange dots on the collar (about +25) and on SPY alone (about +102) and an arrow between them labeled opportunity loss of about 77. Premiums are from TJUL's July 31, 2025 holdings report, grown to expiration at the two-year Treasury yield on June 30, 2025.*

Let's consider an example:

> __Example:__
>
> [▶ Analyze a protective collar on `SPY`](CHEME-5660-L11b-Example-StandardListed-SPY-ProtectiveCollar-Fall-2026.ipynb). In this example, we buy `SPY` shares, buy a put, and sell a call using the `SPY` options chain on the quote date. We compute the collar's maximum profit, breakeven, and maximum loss, compare its profit at expiration with holding the shares, and estimate the probabilities of a loss and of ending at the floor or at the cap.

Next, let's look at how the value of each position changes when the share price moves.
___

## Delta of Covered Calls and Collars
Previously, we used Delta ($\Delta$) as an estimate of the probability of exercise. Delta also measures how much a position gains or loses when the share price moves. The __net Delta__ of a position is the number of shares it holds plus the weighted Deltas of its option legs.

A covered call holds $mn$ shares and is short $n$ calls, each with Delta $\Delta_{c}$. A collar holds the same shares and short calls, with the calls at the strike $K_{2}$, and adds $n$ long puts at the strike $K_{1}$, each with Delta $\Delta_{p}$. Their net Deltas are:
$$
\Delta_{\text{net}}(S,t) = mn\left(1-\Delta_{c}(S,t)\right) \quad\text{(covered call)}\qquad
\Delta_{\text{net}}(S,t) = mn\left(1+\Delta_{p}(S,t)-\Delta_{c}(S,t)\right) \quad\text{(collar)}
$$
Since $0\leq\Delta_{c}\leq 1$, the covered call's net Delta is never negative: like the shares, it does not lose value when the share price rises. Since $-1\leq\Delta_{p}\leq 0$, the collar's long put and short call can only lower its net Delta from the $mn$ of the shares alone.

The [derivation notebook](CHEME-5660-L11b-Derivation-NetDelta-Fall-2026.ipynb) derives these results from the net Delta of a portfolio of cash, shares, and options, finds the number of shares that makes a position delta-neutral, and lists the composite Delta of the common composite contracts from L11a.
___

## Summary
This lecture analyzes covered calls and protective collars, two strategies that combine shares with options, and computes the net Delta of each position.

> __Key Takeaways:__
> 
> * __Covered calls combine stock ownership with short call options:__ We derived the profit at expiration of shares plus a short call. If the call is exercised, we sell the shares at the strike price and realize the gain or loss, so the call caps the profit. If it expires worthless, we keep the premium and the shares, and the premium lowers the breakeven.
> * __Protective collars put a floor and a cap on the shares:__ We derived the profit at expiration of shares plus a long put and a short call. Below the put's strike, the put sets a floor under the loss; above the call's strike, the call caps the profit; in between, the position moves with the shares. The call premium pays for part of the put, all of it, or more than all of it (a net credit).
> * __The option legs lower the net Delta of the shares:__ We computed the net Delta of a covered call and a collar as the number of shares plus the weighted Deltas of the option legs. A covered call's net Delta is never negative, and a collar's put and call both reduce how much it gains or loses when the share price moves.

Understanding covered calls and protective collars lets us build positions that trade some of the upside of the shares for income or for protection.
___
