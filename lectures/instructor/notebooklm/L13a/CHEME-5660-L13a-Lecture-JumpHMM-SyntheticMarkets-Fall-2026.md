# L13a: Synthetic Markets with Jump Hidden Markov Models
In this lecture, we build synthetic markets: simulated price histories that share the features of real ones, such as fat tails, near-zero autocorrelation, and volatility clustering. 

__Why synthetic markets?__ A backtest tests a trading strategy on one historical path. How would the same method do on thousands of plausible paths, including sell-offs that never happened?

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
> * __Construct Markov chains and hidden Markov models:__ Define a state space, a transition matrix, and its stationary distribution, and describe how hidden states emit the values we observe.
> * __Build a jump hidden Markov model of one asset:__ Bin the daily growth rate into states, estimate the transition matrix by counting, fit an emission distribution in each state, and explain why runs of large daily moves (jump episodes) are needed to reproduce volatility clustering.
> * __Compare simulated and real volatility:__ Compare the tails and volatility clustering of simulated paths with `SPY` data, and describe where a simulated episode differs from a real crash.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
> * A Markov chain is a set of states $\mathcal{S}$ and a transition matrix $\mathbf{P}$ whose rows sum to one. Its stationary distribution satisfies $\bar{\pi} = \bar{\pi}\mathbf{P}$.
> * The jump hidden Markov model bins the daily growth rate into states of equal probability, estimates $\mathbf{P}$ by counting, and draws each day's growth rate from a Student-t distribution of the day's state. Jump episodes (runs of large daily moves) start with probability $\epsilon$ and last $\lambda$ days on average, allowing this approach to reproduce volatility clustering.
> * Jump episodes add volatility clustering, but more or longer episodes thin the simulated tails.
>
> __For understanding__ (you will not need to reproduce or memorize these):
> * The fitting and sampling algorithms of the jump hidden Markov model, step by step.
> * How periods of high volatility develop and fade in simulated markets compared with market data.

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L13a) lists this lecture's symbols with their meanings and units.

Let's get started!

___

## Examples
__We will work through these examples in lecture:__

> [▶ Build a jump hidden Markov model of `SPY`](CHEME-5660-L13a-Example-JumpHMM-SPY-Fall-2026.ipynb). In this example, we fit a hidden Markov model to the daily growth rate of `SPY` from 2014 to 2024. We compare simulated distributions and volatility clustering with the data, then tune jump episodes and examine what they change.

___

## Review: Wolfram Markets
Previously, we built Wolfram markets, in which each trader reads its four neighbors' intentions and uses a rule table to choose its next intention. The three rules below give the next intention for every neighbor sum:

*Figure: A trader and its four neighbors on the left feed a neighbor sum of 1 into three numeric rule tables on the right, with columns from 8 to 0. Rules 19280 and 19286 differ only at sum 1, highlighted in yellow: the output changes from 0 (Buy) to 2 (Sell). The added Rule 0 row is all zeros (Buy).*

R19280 and R19286 differ at just one neighbor sum, while R0 always buys. In the two switched markets below, 25% of traders switch to R19286 after step 1000.

In the bottom market, investors are randomly replaced at each step after step 1500, when a Sell majority has formed. On average, one quarter of the new arrivals follow R0.

*Figure: Market grids at steps 1000, 1250, 1500, 1600, 2000, and 4000. Rows show R19280 alone, the closed rule-switch market, and the switched market with continuous refresh after step 1500. The switched rows share their history through step 1500, with 65 percent Sell intentions. R0 entry then breaks up the Sell majority in the bottom row.*

In the closed market, Sell intentions spread across the grid. The price falls until the sellers run out of shares. In the open market, new buyers break up the Sell majority and the price recovers.

__Today:__ A market can change its character without warning. Our goal is a trade management system that makes money when it can and, at a minimum, preserves cash when it cannot.

To reach that goal, the system has to adapt as the market changes. To test such a system, we need many plausible paths of a changing market.

___

## Company Profile: State Street
[State Street Investment Management](https://www.ssga.com/us/en/about-us) is the asset management business of State Street Corporation. Established in [1978](https://www.ssga.com/us/en/about-us/who-we-are/our-history), it was known as State Street Global Advisors until 2025.

> __What does the firm do?__
>
> * __Investment management:__ The firm manages index funds and active investment strategies. Its [SPDR ETF family includes SPY](https://www.ssga.com/us/en/institutional/etfs/state-street-spdr-sp-500-etf-trust-spy), launched in 1993 to track the S&P 500.
> * __Regime modeling:__ Market regimes are periods with different patterns of risk and return. A hidden Markov model treats the regime as an unobserved state and models transitions between regimes. In a [January 2026 article](https://www.ssga.com/us/en/institutional/insights/how-ai-is-transforming-investment-management-state-street-strategic-approach), State Street describes using these models to guide trading in commodities, credit, and broader markets as regimes change.

__Explore further:__

* __Jobs and internships:__ State Street's [early careers page](https://careers.statestreet.com/global/en/state-street-early-careers) describes student internships and graduate development programs. Browse [current openings](https://careers.statestreet.com/global/en/search-results) for available roles.
* __Video:__ Watch the firm's [A Day in the Life at State Street series](https://careers.statestreet.com/global/en/state-street-early-careers) for examples of employees' work.
* __Research:__ The January 2026 article is by Alexander Rudin, State Street's Global Head of Research, and Minkyu Kim, its Head of Data and Analytics. For its use of hidden Markov models in credit, the article cites a 2023 paper by Pravesh Kumar, Rahul Sathyajit, and Rudin: [Modeling Credit Spreads Through Regime Switching with Gradual Transition](https://doi.org/10.3905/jfi.2023.1.164), published in *The Journal of Fixed Income*.

__Connection to today's lecture:__ State Street uses hidden Markov models to inform investment decisions as market conditions change. Here, we use a hidden Markov model to generate synthetic price histories with changing behavior that we can use to test trading strategies.

___


## Markov Chains and Hidden Markov Models
A Markov chain is a stochastic (random) process that moves between states. The next state depends only on the present state. For example, the states could be the moods of an investor: bullish, neutral, or bearish.

> __Definition (Markov chain):__ A Markov chain has a set of states $\mathcal{S}=\left\{s_{1},\dotsc,s_{N}\right\}$ and a transition matrix $\mathbf{P}\in\mathbb{R}^{N\times{N}}$. Let $X_{t}$ be the state on day $t$. The element $p_{ij}\in\mathbf{P}$ is the probability of moving from $s_{i}$ today to $s_{j}$ tomorrow:
>
> $$
> p_{ij} = P\left(X_{t+1}=s_{j}\mid X_{t}=s_{i}\right)
> $$
>
> Each row of $\mathbf{P}$ sums to one and is a categorical distribution over tomorrow's state. A categorical distribution gives a probability to each of a finite number of outcomes, here the $N$ states. The __stationary distribution__ $\bar{\pi}$ solves $\bar{\pi} = \bar{\pi}\mathbf{P}$ and gives the long-run share of time the chain spends in each state.

We estimate the transition matrix $\mathbf{P}$ from data:

> __Proposition (estimating the transition matrix):__ In a sequence of observed states $X_{1},\dotsc,X_{T}$, let $n_{ij}$ count the days in state $s_{i}$ followed by a day in state $s_{j}$. The maximum likelihood estimate of $p_{ij}$ is the share of the days in state $s_{i}$ that moved to state $s_{j}$:
>
> $$
> \boxed{\hat{p}_{ij} = \frac{n_{ij}}{\sum_{k=1}^{N} n_{ik}}}
> $$
>
> This estimate maximizes the log-likelihood $\sum_{i,j} n_{ij}\ln p_{ij}$, subject to each row of $\mathbf{P}$ summing to one.

A __hidden Markov model__ adds observable outputs to the chain (unobservable) states. Each day, we observe an output (emission) drawn from a distribution that depends on that day's hidden state.

The [Markov models notebook](advanced/markov/CHEME-5660-L13a-Lecture-MarkovModels-Fall-2026.ipynb) covers the Markov property, power iteration for $\bar{\pi}$, and sampling a hidden Markov model.

___

## The Jump Hidden Markov Model
Real growth rates have __near-zero autocorrelation__: past growth rates offer little help in a linear forecast of the next growth rate. They have __fat tails__: large daily moves are far more common than a normal distribution predicts. They show __volatility clustering__: large moves of either sign tend to follow large moves.

Let's build a hidden Markov model of the daily growth rate $g_{t}$ (units: 1/yr) of one asset. It has three parts:
* __States:__ We fit a Laplace distribution to the growth rates and cut its cumulative distribution function $F_{L}$ into $N$ bins of equal probability. Its density is $f_{L}(g) = \frac{1}{2b}\exp\left(-\lvert g-\mu\rvert/b\right)$, where the location $\mu$ is the peak and the scale $b>0$ sets the width. Each bin is a state, from the most negative growth rates (state 1) to the most positive (state $N$).
* __Transition matrix:__ We label each day of the data with the state that contains its growth rate. This gives a sequence of states $X_{1},\dotsc,X_{T}$. We estimate $\hat{\mathbf{P}}$ by counting the moves between the states of consecutive days.
* __Emissions:__ In state $s_{k}$, the growth rate is $g_{t} \mid X_{t} = s_{k} \sim \mu_{k} + \sigma_{k}\,T_{\nu}$. We draw a Student-t value $T_{\nu}$ centered at zero, with $\nu$ degrees of freedom, multiply it by $\sigma_{k}$, and add $\mu_{k}$. We set $\mu_{k}$ and $\sigma_{k}$ to the mean and standard deviation of that state's growth rates.

  The standard deviation of $T_{\nu}$ is $\sqrt{\nu/(\nu-2)}$, which is greater than one. With $\nu=5$, the draws have a standard deviation of about $1.3\sigma_{k}$, wider than the state's growth rates.

During fitting, we know each day's state from its growth rate. During simulation, the model draws a hidden state and reports only its emitted growth rate.

*Figure: The fit of the model in four labeled steps. On the left, a plot of the daily growth rate of a ticker on sixteen trading days, with five horizontal bands shaded behind the points. Each point is a small circle with the number of its state inside: 3, 4, 3, 2, 3, 4, 5, 1, 5, 1, 2, 3, 4, 3, 3, 2. The three moves from state 3 to state 4 on consecutive days are orange segments of the line, and a key in the corner reads a move 3 to 4. In the middle, under the heading 1. Laplace, the fitted Laplace distribution is drawn sideways on the same growth-rate axis, with its peak in the middle band. The band boundaries cut the area under the distribution into N = 5 bins of equal probability, each labeled 20 percent. A bar to the right, headed 2. States, names the state and the mood of each band: state 1, very bearish, in red at the bottom, then state 2, bearish, state 3, neutral, state 4, bullish, and state 5, very bullish, in blue at the top. An orange arrow labeled n i j leads from the bar to a table of counts headed 3. Count. The table has the state on day t in the rows and the state on day t plus 1 in the columns, and the cell in row 3 and column 4 holds 3 and is highlighted in orange. An arrow leads from the table to a box headed 4. Transitions, with the estimate of p i j, n i j divided by the sum of row i, and the example for row 3, 3 over 6.*

### Fitting algorithm

__Initialize__: Given the daily growth rates $g_{1},\dotsc,g_{T}$ of one ticker, the number of states $N$, and the degrees of freedom $\nu$ of the emissions. Set every count $n_{ij}\gets 0$.

1. __Laplace:__ Fit a Laplace distribution to the growth rates by maximum likelihood. Set its location $\mu$ to the median of the growth rates. Set its scale $b \gets \frac{1}{T}\sum_{t=1}^{T}\lvert g_{t} - \mu\rvert$, the average distance of the growth rates from $\mu$.
2. __States:__ For each day $t = 1,2,\dots,T$ __do__: compute $F_{L}(g_{t})$, the probability that a draw from the fitted Laplace distribution is below $g_{t}$. Split the interval from 0 to 1 into $N$ equal pieces. Set $X_{t}\gets s_{k}$, where the $k$-th piece holds $F_{L}(g_{t})$: $(k-1)/N \leq F_{L}(g_{t}) < k/N$.
3. __Count:__ For each day $t = 2,3,\dots,T$ __do__: if $X_{t-1} = s_{i}$ and $X_{t} = s_{j}$, __then__ $n_{ij}\gets n_{ij} + 1$.
4. __Transitions:__ Divide each count by the sum of its row: $\hat{p}_{ij}\gets n_{ij}/\sum_{k=1}^{N} n_{ik}$.
5. __Emissions:__ For each state $s_{k}$ __do__: set $\mu_{k}$ and $\sigma_{k}$ to the mean and standard deviation of the growth rates on the days in state $s_{k}$. The emission of state $s_{k}$ is $\mu_{k} + \sigma_{k}\,T_{\nu}$.
6. __Start:__ Compute the stationary distribution $\bar{\pi}$ of $\hat{\mathbf{P}}$.

__Output__: The Laplace location $\mu$ and scale $b$, the transition matrix $\hat{\mathbf{P}}$, the emission mean $\mu_{k}$ and standard deviation $\sigma_{k}$ of each state, and the stationary distribution $\bar{\pi}$.

__Notes:__
1. The Laplace cumulative distribution function is $F_{L}(g) = \frac{1}{2}\exp\left((g-\mu)/b\right)$ for $g < \mu$ and $F_{L}(g) = 1 - \frac{1}{2}\exp\left(-(g-\mu)/b\right)$ for $g \geq \mu$.
2. For example, with $N=5$ each piece has width 0.2. A day with $F_{L}(g_{t}) = 0.47$ falls in $0.4 \leq 0.47 < 0.6$, the third piece, so $X_{t}=s_{3}$.
3. In step 2, the bin edges are the values $F_{L}^{-1}(k/N)$ for $k = 1,\dots,N-1$, where $F_{L}^{-1}$ is the inverse of $F_{L}$. State $s_{k}$ holds the growth rates between the edges $F_{L}^{-1}((k-1)/N)$ and $F_{L}^{-1}(k/N)$.
4. The `JumpHMM.jl` package handles two rare cases. If row $i$ of the counts is all zeros, it sets $\hat{p}_{ij} = 1/N$ for every $j$. If fewer than two days are in state $s_{k}$, it sets $\mu_{k}$ and $\sigma_{k}$ to the mean and standard deviation of all the growth rates.

The extreme states cover the widest ranges of growth rates. The Student-t draws also produce more large values than normal draws. Together, they give the simulated growth rates fat tails.

To simulate a path, we draw the first state from $\bar{\pi}$ and each later state from the row of $\hat{\mathbf{P}}$ for the previous day's state. Each day's growth rate is a draw from the emission of that day's state.

### Why add jumps?
The counted chain forgets quickly: a few transitions usually return it from an extreme state to the middle states. The absolute growth rate of a simulated path stays correlated for only a few days, while real volatile periods last for weeks.

The model adds __jump episodes__ to keep volatile periods going. A jump episode starts with probability $\epsilon$ and lasts a Poisson number of days with mean $\lambda$. Each episode day draws its state from the most negative states with probability $p_{\text{neg}}$, slightly above one half, and from the most positive states otherwise:

*Figure: A row of hidden states numbered 1, 2, through k, through N minus 1 and N, ordered from the most negative to the most positive daily growth rate, with double-headed arrows between neighbors. States 1 and 2 are red and braced as the most negative states S minus, and states N minus 1 and N are blue and braced as the most positive states S plus. A bell curve above each state is its emission, and state k emits mu k plus sigma k times a Student-t variable. Under state k, a note reads ordinary day: step with the estimated transition matrix. A dashed arrow from state k, marked no episode under way, leads up to a box: jump episode, starts with probability epsilon, lasts a Poisson number of days with mean lambda. From the box, a red arrow runs to the most negative states, taken on each episode day with probability p neg, and a blue arrow runs to the most positive states, taken with probability 1 minus p neg.*

### Sampling algorithm

__Initialize__: Given the transition matrix $\hat{\mathbf{P}}$, the emission parameters $\mu_{k}$ and $\sigma_{k}$ of each state, the degrees of freedom $\nu$, the stationary distribution $\bar{\pi}$, the episode probability $\epsilon$, the mean episode length $\lambda$, the number of tail states $N_{\text{tail}}$, the probability $p_{\text{neg}}$ that an episode day is negative, and the number of days $T$. 

The most negative states are $\mathcal{S}_{-} = \left\{s_{1},\dotsc,s_{N_{\text{tail}}}\right\}$, and the most positive states are $\mathcal{S}_{+} = \left\{s_{N-N_{\text{tail}}+1},\dotsc,s_{N}\right\}$. Draw the first state $X_{1}\sim\text{Categorical}(\bar{\pi})$ and its growth rate $g_{1}$ from the emission of $X_{1}$. Set $t\gets 2$.

While $t \leq T$ __do__:
1. __Episode check:__ Draw $u\sim\text{Uniform}(0,1)$. If $u < \epsilon$, __then__ draw the episode length $\texttt{remaining}\sim\text{Poisson}(\lambda)$. Otherwise, set $\texttt{remaining}\gets 0$.
2. __Ordinary day:__ If $\texttt{remaining} = 0$, __then__ draw $X_{t}\sim\text{Categorical}\left(\hat{p}_{i1},\dots,\hat{p}_{iN}\right)$, where $X_{t-1}=s_{i}$, draw $g_{t}$ from the emission of $X_{t}$, and set $t\gets t+1$.
3. __Episode days:__ While $\texttt{remaining} > 0$ and $t \leq T$ __do__:
    - a. Draw $v\sim\text{Uniform}(0,1)$. If $v < p_{\text{neg}}$, __then__ draw $X_{t}$ uniformly from $\mathcal{S}_{-}$. Otherwise, draw $X_{t}$ uniformly from $\mathcal{S}_{+}$.
    - b. Draw $g_{t}$ from the emission of $X_{t}$. Set $\texttt{remaining}\gets\texttt{remaining} - 1$ and $t\gets t+1$.

__Output__: The states $\{X_{1},\dotsc,X_{T}\}$ and the growth rates $\{g_{1},\dotsc,g_{T}\}$ of one path.

__Notes:__
1. With $\epsilon = 0$ no episode starts, and the algorithm samples a hidden Markov model with no jumps.
2. A Poisson draw can be zero. In that case no episode starts, and day $t$ is an ordinary day.
3. The check in step 1 runs again on the day after an episode ends, so a new episode can follow at once.
4. The `JumpHMM.jl` package sets $N_{\text{tail}} = 5$ and $p_{\text{neg}} = 0.52$ unless we choose other values.

We tune the jump settings against the data in the SPY example. We then compare the simulated growth-rate distribution and volatility clustering with the data.

> __Example:__
>
> [▶ Build a jump hidden Markov model of `SPY`](CHEME-5660-L13a-Example-JumpHMM-SPY-Fall-2026.ipynb). In this example, we fit a hidden Markov model to the daily growth rate of `SPY` from 2014 to 2024. We compare simulated distributions and volatility clustering with the data, then tune jump episodes and examine what they change.

### What the episodes add and what they miss
Jump episodes add volatility clustering, but more or longer episodes thin the simulated tails and overstate the spread of growth rates. Each episode draws from the same tail states, keeping volatility near one level for about $\lambda$ days before switching off. In 2020, `SPY` volatility rose sharply before fading over several months.

The left panel sketches the two volatility profiles. The right shows the standard deviation of $g_{t}$ over the past 21 trading days for `SPY` from February 20, 2020, and the tuned model: six episodes and the mean over all episodes. Each period is aligned at its first day:

*Figure: Two panels with volatility on the vertical axis and trading days since the start on the horizontal axis. The left panel, a schematic: a dashed gray line marks the volatility of ordinary days. A red box, filled in light red, rises from the ordinary level to a middle level at the start, stays flat, and drops back after a red double arrow labeled about lambda days; it is labeled simulated episode, flat for about lambda days. A thick black curve labeled real crash (SPY, 2020), spikes, then fades, rises to a peak about twice as high as the box within the first few weeks, falls below the box level well before the box ends, and then fades slowly. The right panel, the data: the standard deviation of g over the past 21 trading days, in 1/yr, from 30 days before the start to 200 days after it. The black curve, real SPY from February 20, 2020, rises from about 2 to about 15 near day 30 and falls back to about 4 by day 60. The thick red curve, the mean over the episodes of the tuned model, rises to about 7 within a month, stays near 7 until about day 100, and falls to about 2.6 by day 150. Six thin red curves, single episodes, have the same flat shape at levels between about 5 and 10. A dashed line marks day 0.*

A stress test on these paths meets long, moderate volatile periods rather than sharp crashes that fade.
___

## Optional Advanced Material
> [▶ Review Markov chains and hidden Markov models](advanced/markov/CHEME-5660-L13a-Lecture-MarkovModels-Fall-2026.ipynb). In this notebook, we define the Markov property and the transition matrix, compute the stationary distribution by power iteration, and sample a hidden Markov model. Its two examples apply a hidden Markov model to a person's mood and to the daily growth rate of `SPY`.

___

## Summary
This lecture builds synthetic markets for stress tests, from Markov chains and hidden Markov models to a jump hidden Markov model of one asset.

> __Key Takeaways:__
>
> * __Markov chains and hidden states:__ We defined the state space, the transition matrix, and the stationary distribution, and we estimated the transition matrix by counting transitions. Hidden states extend the chain, and their emission distributions produce the values we observe.
> * __Jump hidden Markov models reproduce fat tails:__ We binned growth rates into states of equal probability, counted transitions, and used Student-t emissions. The Student-t draws and the wide extreme bins give the simulated growth rates fat tails.
> * __Jump episodes add volatility clustering, with limits:__ We added and tuned jump episodes to prolong volatile periods. Episodes add clustering, but thin the tails and stay flat where a real crash spikes and fades.

Synthetic markets let us test a trading method on many plausible paths, including sell-offs that never happened, rather than on one historical path.

___
