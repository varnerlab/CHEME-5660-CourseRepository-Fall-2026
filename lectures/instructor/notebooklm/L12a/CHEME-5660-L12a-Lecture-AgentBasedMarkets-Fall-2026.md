# L12a: How Do Micro Decisions Lead to Emergent Macro Trends?
In this lecture, we study agent-based models. We work through two classical models: the Farmer–Joshi market, where value investors and trend followers trade through a market maker, and the thermal minority game, where we describe how agents choose among their policies.

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
> * __Describe the structure of an agent-based model:__ Name the five parts that agent-based models share and identify each one in the Farmer–Joshi market and the minority game.
> * __Use the Boltzmann choice rule:__ Explain the Boltzmann rule as the maximum-entropy choice for a given expected score, and describe its low- and high-temperature limits.
> * __Connect agent rules to market behavior:__ Explain how value investors and trend followers together produce fat tails and volatility clustering, and how the minority game's volatility depends on the number of histories per agent and the temperature.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
> * An agent-based model has five parts: agents, the information each agent sees, a decision rule, an aggregate of the agents' decisions (the net order, the price, the attendance), and feedback from the aggregate to the next decisions.
> * Maximizing the entropy of the choice probabilities for a fixed expected score gives the Boltzmann rule $p_{j}=\exp(U_{j}/T)/\mathcal{Z}$. As $T\to 0$, the agent always uses its best policy. As $T\to\infty$, it chooses uniformly at random.
> * Market-wide behavior comes from the rules, not from assumptions about prices. In the Farmer–Joshi market, value investors and trend followers together produce fat tails and volatility clustering. In the minority game, the volatility per agent depends on the number of histories per agent, $\alpha$, and on the temperature.
>
> __For understanding__ (you will not need to reproduce or memorize these):
> * The threshold rules of the Farmer–Joshi traders and the parameter values of our simulation.
> * The price we add to the minority game, an extension of the original model.

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L12a) lists this lecture's symbols with their meanings and units.

Let's get started!
___

## Examples
__We will work through these examples in lecture:__

> [▶ Simulate the Farmer–Joshi market](CHEME-5660-L12a-Example-FarmerJoshi-Fall-2026.ipynb). In this example, we simulate markets with value investors only, trend followers only, and both groups. We measure the excess kurtosis and the autocorrelations of the growth rates, their absolute values, and the volume. By varying the number of trend followers and comparing these statistics with those of a real ticker's daily growth rates, we see which stylized facts the model can match at the same time.

> [▶ Simulate the thermal minority game](CHEME-5660-L12a-Example-ThermalMinorityGame-Fall-2026.ipynb). In this example, we simulate a minority game in which agents choose to buy or sell each round with one of several fixed policies. We measure how the volatility per agent depends on the number of histories per agent, and how the temperature changes it in the crowded phase. We also turn the attendance into a price and check the stylized facts of its growth rates.

Optional advanced notebooks that extend today's material are listed in the Optional Advanced Material section at the end of this lecture.
___

## In the News: The November 5 Sell-Off
On Thursday, November 5, 2026, U.S. stocks had their steepest one-day declines since the April 2025 tariff shock (liberation day). The Nasdaq Composite fell 5.5%, into correction territory, and the S&P 500 fell about 4.4%, as investors worried that spending on AI data centers could slow after the midterm election results. 

The seven largest technology companies [lost more than 1 trillion USD of market value (CNBC)](https://www.cnbc.com/2026/11/05/stock-market-selloff-ai-fears.html).

> __Who did not buy the dip?__
>
> Retail investors usually buy when prices fall. "On a typical sell-off, retail buy the dip," Vanda Research wrote. "Today, that bid has effectively disappeared from individual names."
>
> Instead, retail investors sold a net 338 million USD of individual stocks, the [largest one-day outflow since March 2020](https://www.cnbc.com/2026/11/05/retail-traders-dump-the-most-stocks-in-single-day-since-covid-sell-off.html).

__Connection to today's lecture:__ When prices fell on November 5, each investor decided whether to buy, sell, or wait, and the day's price move was the sum of those individual decisions. 

The Financial Crisis Inquiry Commission drew a similar conclusion about 2008. It found that the crisis was "the result of human action and inaction" and, to paraphrase Shakespeare, that "the fault lies not in the stars, but in us" ([FCIC report](https://www.govinfo.gov/content/pkg/GPO-FCIC/pdf/GPO-FCIC.pdf)). 

Agent-based models start from the same view. We write down how individuals decide, simulate many of them together, and see what booms and busts their decisions produce.
___

## The Structure of an Agent-Based Model
Most of the models in this course describe prices directly: geometric Brownian motion, for example, assumes a distribution for the growth rate and simulates prices from it. This is a __top-down__ approach: we start with the market-wide behavior and then ask what models could produce it.

An __agent-based model (ABM)__ is a __bottom-up__ approach. Agent-based models describe individual decision makers, the __agents__, and the rules they follow, simulate many of them interacting, and then measure the prices or other market-wide quantities that come out. The question is which market-wide patterns follow from which individual rules.

Every agent-based model in this lecture has the same five parts: agents, the information each agent sees, a decision rule that turns the information into an action, an aggregate of the actions, and feedback from the aggregate to what the agents see next:

*Figure: A loop of the five parts of an agent-based model. On the left, a box labeled information, what each agent sees. An arrow labeled sees leads to a stack of cards, the agents i = 1 to N; the front card is labeled decision rule, which turns what agent i sees into an action. An arrow labeled actions leads to an orange box, the aggregate, what the actions add up to. An orange arrow runs from the aggregate back along the bottom to the information box, labeled feedback: the aggregate changes what the agents see next.*

The feedback is what makes these models interesting: each agent reacts to an aggregate that all the agents create together. Today, we'll consider two classical agent-based models, the [Farmer–Joshi market](https://arxiv.org/pdf/cond-mat/0012419) and [the minority game](https://arxiv.org/pdf/adap-org/9708006). 
___

## The Farmer–Joshi Market
[Farmer and Joshi (2002)](https://arxiv.org/pdf/cond-mat/0012419) built an agent-based market in which the traders react to the price itself, with two common trading strategies, and a market maker who sets the price from the traders' net order.

__Reference:__
* [Farmer, J. D.; Joshi, S. (2002). "The price dynamics of common trading strategies". Journal of Economic Behavior & Organization. 49 (2): 149–171. doi:10.1016/S0167-2681(02)00065-3](https://arxiv.org/pdf/cond-mat/0012419)

This model has two trader types, value investors and trend followers, who trade a single asset with share price $S_{t}$ at step $t$. Let's look at this game:

*Figure: Two panels and a signal axis. Left, one step of the Farmer–Joshi market: the log value ln V_t feeds a red box of value investors, whose signal is zeta_t^(i) = ln S_t minus (ln V_t plus v^(i)); next to it, a blue box of trend followers, whose signal is zeta_t^(i) = ln S_t minus ln S_(t minus theta_i). Arrows labeled orders omega_(t+1)^(i) from both boxes meet in a summation node; the net order goes to the market maker, ln S_(t+1) = ln S_t + (1/lambda) times the sum of the orders + sigma_S sqrt(Delta t) Z_(t+1). The market maker produces the new log price ln S_(t+1), and orange arrows carry it back up both sides to the two groups, labeled new price, new signals. Right, the threshold rule of value investor i as three states, long plus c_i on the left, flat 0 in the middle, and short minus c_i on the right. From flat, the investor sells (goes short) when zeta exceeds chi_in (overpriced) and buys (goes long) when zeta falls below minus chi_in (underpriced). From short, it buys and returns to flat when zeta falls below chi_out (no longer overpriced). From long, it sells and returns to flat when zeta rises above minus chi_out (no longer underpriced). Below the three states, a signal axis for the example thresholds chi_in = 0.5 and chi_out = -0.1, with four marks from left to right: enter long at zeta = -0.5, exit short at -0.1, exit long at +0.1, and enter short at +0.5.*

Value investors compare the price with a fundamental value, which is what the asset is believed to be worth, and make a decision based on the difference. Let $\ln V_{t}$ be the log of the fundamental value $V_{t}$ at step $t$ (random walk). On the other hand, the trend followers compare the current price with a past price and make a decision based on the change.

* __Value investors__ watch the mispricing $\ln S_{t}-\left(\ln V_{t}+v^{(i)}\right)$, where the offset $v^{(i)}$ makes each investor's estimate of the value different. They sell when the asset is overpriced by more than the entry threshold $\chi^{\text{in}}_{i}$ and buy when it is underpriced by more than $\chi^{\text{in}}_{i}$. Their trading pushes the price toward the fundamental value $V_{t}$.
* __Trend followers__ watch the price change over their own lag $\theta_{i}$, $\ln S_{t}-\ln S_{t-\theta_{i}}$. They buy when the price has risen by more than $\chi^{\text{in}}_{i}$ and sell when it has fallen by more than $\chi^{\text{in}}_{i}$. Their trading pushes the price further in the direction it has been moving.

Both groups use the same __threshold rule__ on different signals $\zeta^{(i)}_{t}$. A trader enters a position when its signal crosses an entry threshold $\pm\chi^{\text{in}}_{i}$ and exits when the signal comes back across an exit threshold $\pm\chi^{\text{out}}_{i}$, with $\chi^{\text{in}}_{i}>\chi^{\text{out}}_{i}$. With Farmer and Joshi's parameters, the exit thresholds are at or slightly below zero: a trader holds its position until the signal has moved past zero.

Trader $i$ at time $t$ holds a position $x_{t}^{(i)}$ of $-c_{i}$ (short), $0$, or $+c_{i}$ (long) shares, with size $c_{i}=a\left(\chi^{\text{in}}_{i}-\chi^{\text{out}}_{i}\right)$, where $a>0$ is a constant scale factor. Following Farmer and Joshi, any trader can hold a short position, with no margin requirement or borrowing cost.

> __Example:__
>
> Let's trace one value investor with $\chi^{\text{in}}_{i}=0.5$ and $\chi^{\text{out}}_{i}=-0.1$, the example values on the signal axis in the figure. A short position exits when $\zeta^{(i)}_{t}<\chi^{\text{out}}_{i}=-0.1$, and a long position exits when $\zeta^{(i)}_{t}>-\chi^{\text{out}}_{i}=+0.1$:
>
> | Step | Signal $\zeta^{(i)}_{t}$ | Position before | Test | Position after |
> |:---:|:---:|:---:|:---|:---:|
> | 1 | $+0.20$ | flat | $0.20$ is inside $\pm 0.5$ | flat |
> | 2 | $+0.60$ | flat | $0.60>0.5$: enter short | short |
> | 3 | $+0.30$ | short | $0.30<-0.1$? No | short |
> | 4 | $0.00$ | short | $0.00<-0.1$? No | short |
> | 5 | $-0.05$ | short | $-0.05<-0.1$? No | short |
> | 6 | $-0.15$ | short | $-0.15<-0.1$? Yes: exit | flat |
> | 7 | $-0.60$ | flat | $-0.60<-0.5$: enter long | long |
> | 8 | $-0.20$ | long | $-0.20>+0.1$? No | long |
> | 9 | $+0.05$ | long | $+0.05>+0.1$? No | long |
> | 10 | $+0.15$ | long | $+0.15>+0.1$? Yes: exit | flat |
>
> At step 5, the asset is already underpriced and the investor is still short. The investor exits at step 6, once the signal is more than 0.1 below zero.

Trader $i$'s order is the change in its position, $\omega_{t+1}^{(i)}=x_{t+1}^{(i)}-x_{t}^{(i)}$. The market maker moves the log price in proportion to the net order:

$$
\ln S_{t+1} = \ln S_{t} + \frac{1}{\lambda}\sum_{i}\omega_{t+1}^{(i)} + \sigma_{S}\sqrt{\Delta t}\,Z_{t+1}
$$

where $\lambda$ is the __liquidity__, and the last term is noise that describes everything the model leaves out. The draw $Z_{t+1}\sim\mathcal{N}(0,1)$ is independent at each step, and $\sigma_{S}$ is the annualized volatility of the price noise. Each step lasts $\Delta t$ years, such as $\Delta t=1/252$ for one trading day.

The growth rate over step $t$ follows directly from the price rule:

$$
g_{t+1}=\frac{1}{\Delta t}\ln\frac{S_{t+1}}{S_{t}}=\underbrace{\frac{1}{\lambda\,\Delta t}\sum_{i}\omega_{t+1}^{(i)}}_{\text{traders}}+\underbrace{\frac{\sigma_{S}}{\sqrt{\Delta t}}\,Z_{t+1}}_{\text{price noise}}
$$

Net buying pushes the price up, and net selling pushes it down.

Let's compare this growth rate with the growth rate of single-asset geometric Brownian motion over the same step. We start from the analytical solution for the share price:

$$
\begin{align*}
S_{t+1} & = S_{t}\exp\left[\left(\mu-\frac{\sigma^{2}}{2}\right)\Delta t+\sigma\sqrt{\Delta t}\,Z_{t+1}\right] && \text{analytical solution over one step}\\
\frac{S_{t+1}}{S_{t}} & = \exp\left[\left(\mu-\frac{\sigma^{2}}{2}\right)\Delta t+\sigma\sqrt{\Delta t}\,Z_{t+1}\right] && \text{divide by } S_{t}\\
\ln\frac{S_{t+1}}{S_{t}} & = \left(\mu-\frac{\sigma^{2}}{2}\right)\Delta t+\sigma\sqrt{\Delta t}\,Z_{t+1} && \text{take the natural log}\\
\frac{1}{\Delta t}\ln\frac{S_{t+1}}{S_{t}} & = \underbrace{\left(\mu-\frac{\sigma^{2}}{2}\right)}_{=\,\mu_{g}}+\frac{\sigma}{\sqrt{\Delta t}}\,Z_{t+1} && \text{divide by } \Delta t\text{, where } \mu=\mu_{g}+\frac{1}{2}\sigma^{2}\\
g_{t+1} & = \underbrace{\mu_{g}}_{\text{constant}}+\underbrace{\frac{\sigma}{\sqrt{\Delta t}}\,Z_{t+1}}_{\text{price noise}} && \text{definition of } g_{t+1}\text{, where } \sigma=\sigma_{g}\sqrt{\Delta t}
\end{align*}
$$

where $\mu$ is the drift, $\sigma$ is the annualized volatility, and $\mu_{g}$ and $\sigma_{g}$ are the mean and the standard deviation of the growth rate, which we estimate from data.

The two growth rates differ in the first term. In geometric Brownian motion, the first term is a constant that we estimate from data. In the Farmer–Joshi market, the first term comes from a __mechanistic__ model of how the actions of the traders change the growth rate.

If no trader places an order, the price follows geometric Brownian motion with $\mu_{g}=0$ and $\sigma=\sigma_{S}$.

### The Farmer–Joshi algorithm

__Initialize__: Given the value investors and the trend followers, each with an entry threshold $\chi^{\text{in}}_{i}$ and an exit threshold $\chi^{\text{out}}_{i}<\chi^{\text{in}}_{i}$. The value investors have offsets $v^{(i)}$, and the trend followers have lags $\theta_{i}$. The other inputs are the scale factor $a$, the liquidity $\lambda$, the annualized volatilities $\sigma_{S}$ of the price noise and $\sigma_{v}$ of the log value, the time step $\Delta t$, and the number of steps $R$. 

Set each position size $c_{i}\gets a\left(\chi^{\text{in}}_{i}-\chi^{\text{out}}_{i}\right)$, every position $x^{(i)}_{0}\gets 0$, and the starting log price $\ln S_{0}$ and log value $\ln V_{0}$.

For each step $t=0,1,\dots,R-1$ __do__:
1. __Signals:__ For each value investor, $\zeta^{(i)}_{t}\gets\ln S_{t}-\left(\ln V_{t}+v^{(i)}\right)$. For each trend follower with $t\geq\theta_{i}$, $\zeta^{(i)}_{t}\gets\ln S_{t}-\ln S_{t-\theta_{i}}$. A trend follower with $t<\theta_{i}$ has no signal yet and keeps $x^{(i)}_{t+1}\gets 0$.
2. __Positions:__ For each value investor:
    - If $x^{(i)}_{t}=0$ and $\zeta^{(i)}_{t}>\chi^{\text{in}}_{i}$, __then__ sell: $x^{(i)}_{t+1}\gets -c_{i}$. If $x^{(i)}_{t}=0$ and $\zeta^{(i)}_{t}<-\chi^{\text{in}}_{i}$, __then__ buy: $x^{(i)}_{t+1}\gets +c_{i}$.
    - If $x^{(i)}_{t}=-c_{i}$ and $\zeta^{(i)}_{t}<\chi^{\text{out}}_{i}$, __then__ exit: $x^{(i)}_{t+1}\gets 0$.
    - If $x^{(i)}_{t}=+c_{i}$ and $\zeta^{(i)}_{t}>-\chi^{\text{out}}_{i}$, __then__ exit: $x^{(i)}_{t+1}\gets 0$.
    - Otherwise, $x^{(i)}_{t+1}\gets x^{(i)}_{t}$.

    Trend followers use the same rule with the signs of the positions reversed: they buy when $\zeta^{(i)}_{t}>\chi^{\text{in}}_{i}$ and sell when $\zeta^{(i)}_{t}<-\chi^{\text{in}}_{i}$.
3. __Orders:__ For every trader, $\omega^{(i)}_{t+1}\gets x^{(i)}_{t+1}-x^{(i)}_{t}$.
4. __Price:__ Draw $Z_{t+1}$ from a standard Normal distribution, and set $\ln S_{t+1}\gets\ln S_{t}+\frac{1}{\lambda}\sum_{i}\omega^{(i)}_{t+1}+\sigma_{S}\sqrt{\Delta t}\,Z_{t+1}$.
5. __Value:__ Draw $Z'_{t+1}$ from a standard Normal distribution, independently of $Z_{t+1}$ and of earlier draws, and set $\ln V_{t+1}\gets \ln V_{t}+\sigma_{v}\sqrt{\Delta t}\,Z'_{t+1}$.

__Output__: The log prices $\ln S_{0},\dots,\ln S_{R}$, the log values $\ln V_{0},\dots,\ln V_{R}$, the growth rates $g_{t+1}=\frac{1}{\Delta t}\ln\left(S_{t+1}/S_{t}\right)$, and the volume $\sum_{i}\lvert\omega^{(i)}_{t+1}\rvert$ at each step.

Previously, we measured three stylized facts of daily growth rates: fat tails, little autocorrelation, and volatility clustering. Let's see which of them this market produces:

> __Example:__
>
> [▶ Simulate the Farmer–Joshi market](CHEME-5660-L12a-Example-FarmerJoshi-Fall-2026.ipynb). In this example, we simulate markets with value investors only, trend followers only, and both groups. We measure the excess kurtosis and the autocorrelations of the growth rates, their absolute values, and the volume. By varying the number of trend followers and comparing these statistics with those of a real ticker's daily growth rates, we see which stylized facts the model can match at the same time.

Two simple trading rules and a market maker produce fat tails and volatility clustering without either being built in, but not every stylized fact at once.

Next, we build a market in which the agents see only which side won the recent rounds, and change their policies based on that information. This is the __minority game__.
___

## The Minority Game
The minority game was introduced by [Challet and Zhang (1997)](https://arxiv.org/pdf/adap-org/9708006) as a simple model of a market in which it pays to be on the less crowded side: when most traders buy, the price rises, and the sellers get the better price (and vice versa). 

__References:__
* [Challet, D.; Zhang, Y.-C. (1997). "Emergence of cooperation and organization in an evolutionary game". Physica A. 246 (3–4): 407–418. doi:10.1016/S0378-4371(97)00419-6](https://arxiv.org/pdf/adap-org/9708006)
* [Challet, D.; Marsili, M.; Zecchina, R. (2000). "Statistical mechanics of systems with heterogeneous agents: Minority games". Physical Review Letters. 84 (8): 1824–1827. doi:10.1103/PhysRevLett.84.1824](https://arxiv.org/pdf/cond-mat/9904392)

Suppose we have an odd number $N$ of agents, each choosing, at every round $t$, to buy ($+1$) or sell ($-1$) a single asset. Let's look at this game.

*Figure: One round of the minority game with memory m = 2: a row of past minority actions, with the last two (minus one, plus one) boxed and labeled history mu_t, m = 2, and an empty dashed slot to their right. To the left of agent 1, a table shows one policy pi_1j of agent 1, with one row for each of the P = 2^m = 4 histories. The row for the history minus one, plus one is highlighted, its action is minus one, and an arrow carries it to agent 1. An arrow carries the history to agent 1, agent 2, and agent N, each a box noting that the agent draws its policy j with probability p_ij,t and takes that policy's action for the history, a_i,t = pi_ij(mu_t). Below the agents are their actions, minus one, plus one, and minus one, labeled a_1,t, a_2,t, and a_N,t. The actions drop to one collecting line that leads into a box, A_t = sum of a_i,t < 0, which leads to an orange square labeled minority, plus one. An orange arrow carries the minority action up the right side into the empty slot, labeled append to the history; a dashed blue arrow carries the attendance up the left side back to the agents, labeled update every policy score.*



> __Definition (the minority game):__ An odd number $N$ of agents (traders) decide in each round $t=0,1,2,\dots$ whether to buy or sell a single asset. In each round:
>
> * __Information:__ every agent sees the same history $\mu_{t}$, the winning actions of the last $m$ rounds. The winning action of a round, the __minority action__, is the one that fewer agents chose. Because each winning action is buy ($+1$) or sell ($-1$), there are $P=2^{m}$ possible histories.
> * __Policies:__ agent $i=1,\dots,N$ holds $J$ fixed trading rules (policies), the policies $\pi_{i1},\dots,\pi_{iJ}$, drawn at random at the start. Policy $\pi_{ij}$ is a table: for each history $\mu$, it gives the action $\pi_{ij}(\mu)\in\{-1,+1\}$ (sell or buy). In round $t$, agent $i$ chooses one of its policies, e.g., policy $j$ denoted as $\pi_{ij}$ and takes its action for the current history, $a_{i,t}=\pi_{ij}(\mu_{t})$.
> * __Aggregate:__ the collective actions of the agents are summed to give the __attendance__: $A_{t}=\sum_{i=1}^{N}a_{i,t}$, the number of buyers minus the number of sellers. Because $N$ is odd, $A_{t}$ is never zero. The less crowded side, the minority action $-\text{sign}\,A_{t}$, wins the round and becomes the newest entry of the history.
> * __Feedback:__ at the end of each round, every policy of agent $i$, used or not, gets a new score, $U_{ij,t+1}=U_{ij,t}-\pi_{ij}(\mu_{t})A_{t}/P$, where $U_{ij,t}$ is the score of policy $\pi_{ij}$ at the start of round $t$.
>
>   A policy that puts its agent in the minority has an action with the opposite sign of $A_{t}$. The opposite sign makes the policy's score rise. Dividing by $P$ follows [Challet, Marsili, and Zecchina (2000)](https://arxiv.org/pdf/cond-mat/9904392).
>
> From each game, we compute the volatility per agent:
>
> $$
> \frac{\sigma_{A}^{2}}{N}=\frac{\langle A^{2}\rangle}{N}
> $$
>
> where $\langle\cdot\rangle$ averages over the rounds and $\sigma_{A}^{2}=\langle A^{2}\rangle$ is the mean square of the attendance.
>
> In the __greedy__ game, each agent uses its highest-scoring policy. Simulations of large greedy games show that, for a fixed number of policies per agent, the volatility per agent depends on $N$ and $m$ only through the number of histories per agent, $\alpha=P/N$. The phase diagram in the example shows this dependence.

A few things to notice in this definition:
* __Let's use coin flips as a baseline:__ Suppose every agent ignores its policies and flips a fair coin. Each flip is a Bernoulli trial: $X_{i,t}=1$ (buy) with probability $1/2$ and $X_{i,t}=0$ (sell) otherwise. The action $a_{i,t}=2X_{i,t}-1$ then has mean $0$ and variance $1$.

  In each round, each of the $N$ agents flips its own coin, independently of the others. The attendance $A_{t}=\sum_{i}a_{i,t}$ adds these $N$ actions. Because the actions are independent, their variances add, just as their means do:

  $$
  \mathbb{E}[A_{t}]=\sum_{i=1}^{N}\mathbb{E}[a_{i,t}]=0\qquad\text{and}\qquad\text{Var}(A_{t})=\sum_{i=1}^{N}\text{Var}(a_{i,t})=N
  $$

  The mean square of a random variable equals its variance plus its squared mean, which gives $\mathbb{E}[A_{t}^{2}]=N$. Over many rounds, the average $\sigma_{A}^{2}=\langle A^{2}\rangle$ is close to this value. Thus, $\sigma_{A}^{2}\approx N$ and $\sigma_{A}^{2}/N\approx 1$ for any number of agents.

  Above 1, the game is __crowded__: more agents end up on the same side than with coin flips. Below 1, the numbers of buyers and sellers are closer to equal than with coin flips. Once we add a price below, the volatility per agent also sets the volatility of the growth rate.
* __The number of histories per agent, $\alpha=P/N$, controls crowding:__ Each history is one row of a policy table (of $P$ rows). Longer tables leave more room for the agents' policies to differ. For example, $m=2$ gives $P=4$ rows and only $2^{4}=16$ possible tables.

  With $J=2$ policies per agent, as in the example, there are three cases:

  * __When $\alpha$ is below about 0.2:__ there are far more agents than rows, and many of them hold identical or strongly correlated policies. Policies that give the same actions receive the same score updates, and the agents holding them switch to the same action at the same time. The game is crowded, with $\sigma_{A}^{2}/N>1$.

  * __When $\alpha$ is near 0.34:__ the agents' policies differ enough that buyers and sellers nearly balance. The volatility per agent reaches its smallest value, well below the coin-flip value of 1.

  * __When $\alpha$ is above about 0.34:__ the agents' policies overlap less and less as $\alpha$ grows. A score update that favors one agent's policy says little about another agent's policy. The agents' switches are not synchronized, and $\sigma_{A}^{2}/N$ rises toward the coin-flip value of 1 from below.

### Adding a price: my extension
The original minority game has buyers and sellers but no price. Let's add a price using the market-maker rule of the Farmer–Joshi market: we treat the attendance $A_{t}$ (buyers minus the number of sellers) as the excess demand for the asset and let it move the log price. 

Unlike in the Farmer–Joshi market, this price never feeds back into the agents' decisions, because they see only the minority actions. [Challet, Chessa, Marsili, and Zhang (2000)](https://arxiv.org/abs/cond-mat/0011042) define a related price, with the opposite sign and no noise term.

> __Extension (a price for the minority game):__ Let $S_{t}$ be the price of the asset at the start of round $t$. After round $t$, a market maker sets the new price:
>
> $$
> \ln S_{t+1} = \ln S_{t} + \frac{A_{t}}{\lambda} + \sigma_{S}\sqrt{\Delta t}\,Z_{t+1}
> $$
>
> where $\lambda$ denotes the liquidity hyperparameter, and the last term is noise that captures everything the model leaves out. The draw $Z_{t+1}\sim\mathcal{N}(0,1)$ is independent each round and independent of the attendance. The parameter $\sigma_{S}$ is the annualized volatility of the price noise.
>
> * _What is the $\Delta t$ term?_ The minority game has no calendar time: a round is one turn in which every agent acts once. To connect a round to a real market, we choose its length $\Delta t$ in years, as in geometric Brownian motion. For example, one trading day gives $\Delta t=1/252$, and one minute of a 390-minute trading day gives $\Delta t=1/(252\cdot 390)$, etc.
>
> * _What is the $A/\lambda$ term?_ The term $A_{t}/\lambda$ represents the change in the log price over one round, given the attendance. It is the contribution of the agents to the price change, scaled by the liquidity. Thus, we must choose the liquidity $\lambda$ for the same round length as $\Delta t$. 
>
> The growth rate over round $t$ follows directly from the price rule:
>
> $$
> g_{t+1}=\frac{1}{\Delta t}\ln\frac{S_{t+1}}{S_{t}}=\underbrace{\frac{A_{t}}{\lambda\,\Delta t}}_{\text{agents}}+\underbrace{\frac{\sigma_{S}}{\sqrt{\Delta t}}\,Z_{t+1}}_{\text{price noise}}
> $$
>
> More buyers than sellers push the price up, and more sellers push it down. The average of $g_{t+1}$ cannot tell us how large these moves are, because the ups and downs cancel. Squaring removes the sign, and the average of the square measures the size of the moves:
>
> $$
> g_{t+1}^{2}=\underbrace{\frac{A_{t}^{2}}{\lambda^{2}\Delta t^{2}}}_{\text{attendance term}}+\underbrace{\frac{2\sigma_{S}A_{t}Z_{t+1}}{\lambda\,\Delta t^{3/2}}}_{\text{cross term}}+\underbrace{\frac{\sigma_{S}^{2}Z_{t+1}^{2}}{\Delta t}}_{\text{noise term}}
> $$

Let's average each of the three terms in the squared growth rate over many rounds:
* __The attendance term:__ The average of $A_{t}^{2}$ is $\sigma_{A}^{2}$, which we write as $N\cdot(\sigma_{A}^{2}/N)$ to bring in the volatility per agent. In the coin-flip baseline, $\sigma_{A}^{2}/N\approx 1$. Correlations between the agents' choices move it above or below 1.
* __The cross term:__ The average of $A_{t}Z_{t+1}$ is close to zero, because $Z_{t+1}$ has mean zero and is drawn independently of the attendance.
* __The noise term:__ The average of $Z_{t+1}^{2}$ is close to 1. This term is then about $\sigma_{S}^{2}/\Delta t$, the growth-rate variance of geometric Brownian motion with volatility $\sigma_{S}$.

Adding the three averages gives the mean square of the growth rate:

$$
\left\langle g^{2}\right\rangle\approx\underbrace{\frac{N}{\lambda^{2}\Delta t^{2}}\cdot\frac{\sigma_{A}^{2}}{N}}_{\text{agents}}+\underbrace{\frac{\sigma_{S}^{2}}{\Delta t}}_{\text{price noise}}
$$

With $N$, $\lambda$, $\sigma_{S}$, and $\Delta t$ fixed, only the volatility per agent changes from game to game. A crowded game, with $\sigma_{A}^{2}/N>1$, moves the price more than a game with $\sigma_{A}^{2}/N\ll 1$. Because each policy entry is equally likely to be buy or sell, the average growth rate is close to zero, and this mean square is close to the variance of the growth rate.

The [biased policies derivation](advanced/biased_policies/CHEME-5660-L12a-Derivation-BiasedPolicies-Fall-2026.ipynb) explores the case when the policies are biased towards buying or selling. It shows that the mean growth rate is proportional to the bias. 

### Choosing a policy: from greedy to thermal
In the greedy game, each agent uses the policy with the highest score. [Cavagna, Garrahan, Giardina, and Sherrington (1999)](https://arxiv.org/pdf/cond-mat/9903415) proposed that agents choose at random instead, with probabilities that favor high scores. 

__Reference:__
* [Cavagna, A.; Garrahan, J. P.; Giardina, I.; Sherrington, D. (1999). "Thermal model for adaptive competition in a market". Physical Review Letters. 83 (21): 4429–4432. doi:10.1103/PhysRevLett.83.4429](https://arxiv.org/pdf/cond-mat/9903415)

The rule they used is the __Boltzmann choice rule__. An agent with scores $U_{1},\dots,U_{J}$ uses policy $\pi_{j}$ with probability:

$$
p_{j}=\frac{1}{\mathcal{Z}}\exp\left(\frac{U_{j}}{T}\right)\qquad\text{where}\qquad\mathcal{Z}=\sum_{k=1}^{J}\exp\left(\frac{U_{k}}{T}\right)
$$

The temperature $T>0$, in the units of the scores, sets how strongly the agent favors high scores. As $T\to 0$, the agent uses its best policy, as in the greedy game. As $T\to\infty$, it chooses each policy with probability $1/J$.

Among all choice probabilities with a given expected score, this rule has the largest __entropy__, a measure of how spread out the probabilities are. The [maximum-entropy derivation](advanced/max_entropy/CHEME-5660-L12a-Derivation-MaxEntropyChoice-Fall-2026.ipynb) proves this result with Lagrange multipliers and relates the temperature to thermodynamics. In the thermal minority game, every agent uses this rule each round with its own current scores $U_{ij,t}$.

### The thermal minority game algorithm

__Initialize__: Given the number of agents $N$ (odd), the memory $m$, the number of policies per agent $J$, the temperature $T>0$ or the greedy rule, the number of rounds $R$, the liquidity $\lambda$, the annualized noise volatility $\sigma_{S}$, and the length of a round $\Delta t$. Set $P=2^{m}$. 

For each agent $i$ and policy $\pi_{ij}$, draw the action $\pi_{ij}(\mu)\in\{-1,+1\}$ for every history $\mu$ at random, and set every score $U_{ij,0}\gets 0$. Draw the starting history $\mu_{0}$ at random, and set the starting price $S_{0}$.

For each round $t=0,1,\dots,R-1$ __do__:
1. __Choose:__ For each agent $i$, compute $p_{ij,t}\gets\exp\left(U_{ij,t}/T\right)/\mathcal{Z}_{i,t}$ for $j=1,\dots,J$, where $\mathcal{Z}_{i,t}=\sum_{k=1}^{J}\exp\left(U_{ik,t}/T\right)$, and draw the agent's policy index $j_{i,t}\sim\text{Categorical}(p_{i1,t},\dots,p_{iJ,t})$. In the greedy game, choose the policy with the highest score, breaking ties at random. If $T=\infty$, __then__ choose each policy with probability $1/J$.
2. __Act:__ Each agent takes its policy's action for the current history: $a_{i,t}\gets\pi_{i\,j_{i,t}}(\mu_{t})$.
3. __Aggregate:__ Compute the attendance $A_{t}\gets\sum_{i=1}^{N}a_{i,t}$. The minority action is $-\text{sign}\,A_{t}$.
4. __Score:__ Update every policy of every agent, used or not: $U_{ij,t+1}\gets U_{ij,t}-\pi_{ij}(\mu_{t})A_{t}/P$.
5. __Update the history:__ Drop the oldest of the $m$ minority actions in $\mu_{t}$ and append $-\text{sign}\,A_{t}$ to get $\mu_{t+1}$.
6. __Price (extension):__ Draw $Z_{t+1}$ from a standard Normal distribution, and set $\ln S_{t+1}\gets\ln S_{t}+A_{t}/\lambda+\sigma_{S}\sqrt{\Delta t}\,Z_{t+1}$.

__Output__: The attendance $A_{0},\dots,A_{R-1}$, the prices $S_{0},\dots,S_{R}$, and the volatility per agent $\sigma_{A}^{2}/N=\langle A^{2}\rangle/N$, averaged over the rounds.

Let's look at the example:

> __Example:__
>
> [▶ Simulate the thermal minority game](CHEME-5660-L12a-Example-ThermalMinorityGame-Fall-2026.ipynb). In this example, we simulate a minority game in which agents choose to buy or sell each round with one of several fixed policies. We measure how the volatility per agent depends on the number of histories per agent, and how the temperature changes it in the crowded phase. We also turn the attendance into a price and check the stylized facts of its growth rates.

The example shows that the volatility per agent reaches a minimum at an intermediate number of histories per agent. In a crowded game, a moderate temperature lowers it below both the greedy and the random limits.
___

## Optional Advanced Material

The [advanced index](advanced/README.md) describes the optional notebooks below:

* [▶ The maximum-entropy choice rule](advanced/max_entropy/CHEME-5660-L12a-Derivation-MaxEntropyChoice-Fall-2026.ipynb). In this notebook, we prove that the Boltzmann rule has the largest entropy among all choice probabilities with a given expected score. We solve the constrained maximization with Lagrange multipliers and relate the temperature to thermodynamics. It is a derivation notebook with no code.

* [▶ Biased policies in the minority game](advanced/biased_policies/CHEME-5660-L12a-Derivation-BiasedPolicies-Fall-2026.ipynb). In this notebook, we let every policy entry be buy with a probability above one half. We ask how much of that bias agents who follow their scores can remove.

  We sort the agents into those who cannot change their action and those who can. We derive the threshold above which the bias cannot be removed and the market locks into a steady trend. It is a derivation notebook with no code.
___

## Summary
This lecture introduced agent-based models, used the Boltzmann rule, the maximum-entropy choice among policies, and used the Farmer–Joshi market and the minority game to connect individual trading rules to market-wide behavior.

> __Key Takeaways:__
>
> * __Agent-based models build markets from individual rules:__ We identified five parts that agent-based models share, the agents, their information, their decision rule, the aggregate, and the feedback, in both the Farmer–Joshi market and the minority game. Simulating the rules, rather than assuming a distribution for prices, lets us ask which behaviors produce which market-wide patterns.
> * __Maximum entropy gives the Boltzmann choice rule:__ We used the Boltzmann rule, the choice probabilities with the largest entropy for a given expected score. The temperature moves the agent from always using its best policy at low temperature to choosing at random at high temperature.
> * __Simple rules produce market-wide patterns:__ In the Farmer–Joshi market, value investors and trend followers together produced fat tails and volatility clustering. The market with both groups did not match every stylized fact of real growth rates at once.
>
>   We saw that the minority game's volatility reaches a minimum near a critical number of histories per agent. We also saw that a moderate temperature lowers it below both the greedy and the random limits. When we let the attendance set a price, the crowded game moved the price more than a game near the critical value.

These models show how the behavior of a whole market can follow from the rules of the traders in it.
___
