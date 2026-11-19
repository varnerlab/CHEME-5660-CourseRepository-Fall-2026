# L13b: Synthetic Markets of Many Stocks
Previously, we built a jump hidden Markov model of the daily growth rate of one asset. How do we simulate many stocks that move together, as real stocks in the same market and sector do?

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
>
> * __Test the single-asset model out of sample:__ Compare paths simulated from the jump hidden Markov model of `SPY` with the daily growth rates that came after its fitting period. Turn the jump episodes off and compare both models, including their volatility clustering, on the same data.
> * __Compose a synthetic market of many stocks:__ Combine each stock's baseline with market, sector, and stock-specific parts to build synthetic stocks that move together like real ones. Describe the single-asset jump hidden Markov models that supply the market, sector, and stock-specific draws.
> * __Size the stock-specific draw and sample the universe:__ Choose each stock's residual scale so that its sector and stock-specific draws keep the variance of its single index residual. Draw one synthetic path of every stock.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
>
> * An out-of-sample test compares a fitted model with data from after its fitting period. We test the jump hidden Markov model of `SPY`, with and without jump episodes, on the growth rates of 2025 and 2026.
> * We model a synthetic stock's growth rate as $g_{i} = \alpha_{i} + \beta_{i}\,g_{m} + \delta_{i}\,f_{s} + \psi_{i}\,u_{i}$, where $\alpha_{i}$ is the stock's baseline. The shared market and sector parts make stocks move together. The stock-specific draw $u_{i}$ averages zero and is the growth that neither the market nor the sector explains.
> * The residual scale $\psi_{i}$ matches each stock's variance to the data.
>
> __For understanding__ (you will not need to reproduce or memorize these):
>
> * The tests that compare the `SPY` model with the out-of-sample data.
> * How we compute the sector loadings and the residual scales.
> * The sampling algorithm of the sector factor model, step by step.

__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L13b) lists this lecture's symbols with their meanings and units.

Let's get started!

___


## Examples

__We will work through these examples in lecture:__

> [▶ Test the `SPY` model out of sample](CHEME-5660-L13b-Example-JumpHMM-SPY-OutOfSample-Fall-2026.ipynb). In this example, we load the jump hidden Markov model of `SPY` fitted to daily growth rates from 2014 to 2024. We compare its simulated paths with the growth rates of 2025 and 2026, which the model has not seen. We then turn the jump episodes off, score both models on the same data, and compare the volatility clustering of simulated and real growth rates.

> [▶ Build a synthetic market of many stocks](CHEME-5660-L13b-Example-JumpHMM-SectorFactor-Fall-2026.ipynb). In this example, we use the sector factor model to build a universe of `SPY` and 375 stocks from all 11 sectors. We compare the correlations, volatilities, and market sensitivities of a synthetic path with the real data, turn off the sector part, and save the fitted model.

___


## Review: Synthetic Markets with Jump Hidden Markov Models
Previously, we built synthetic markets from jump hidden Markov models. The model bins the daily growth rate into states of equal probability and estimates the transition matrix by counting moves between states.

Each simulated day, the chain takes one step. The model then draws the day's growth rate from the Student-t distribution of the new state:

*Figure: A row of hidden states numbered 1, 2, through k, through N minus 1 and N, ordered from the most negative to the most positive daily growth rate, with double-headed arrows between neighbors. States 1 and 2 are red and braced as the most negative states S minus, and states N minus 1 and N are blue and braced as the most positive states S plus. A bell curve above each state is its emission, and state k emits mu k plus sigma k times a Student-t variable. Under state k, a note reads ordinary day: step with the estimated transition matrix. A dashed arrow from state k, marked no episode under way, leads up to a box: jump episode, starts with probability epsilon, lasts a Poisson number of days with mean lambda. From the box, a red arrow runs to the most negative states, taken on each episode day with probability p neg, and a blue arrow runs to the most positive states, taken with probability 1 minus p neg.*

Jump episodes start at random and last several days. On each episode day, the state comes from the most negative or the most positive states. These runs of large moves add the volatility clustering that the chain alone misses.

Let's test the jump hidden Markov model of `SPY` on data it has not seen:

> __Example:__
>
> [▶ Test the `SPY` model out of sample](CHEME-5660-L13b-Example-JumpHMM-SPY-OutOfSample-Fall-2026.ipynb). In this example, we load the jump hidden Markov model of `SPY` fitted to daily growth rates from 2014 to 2024. We compare its simulated paths with the growth rates of 2025 and 2026, which the model has not seen. We then turn the jump episodes off, score both models on the same data, and compare the volatility clustering of simulated and real growth rates.

__Today:__ We extend the jump hidden Markov model from one asset to many stocks that move together.

___


## Company Profile: AQR Capital Management
[AQR Capital Management](https://www.aqr.com/Our-Firm/About-Us) is a quantitative investment management firm. It was founded in New York City in 1998 and moved its headquarters to Greenwich, Connecticut, in 2004. The firm describes [its approach](https://www.aqr.com/What-We-Do/Our-Approach) as "systematic investing grounded in economic theory."

> __What does the firm do?__
>
> * __Betting against beta:__ In [Betting Against Beta](https://www.aqr.com/Insights/Research/Journal-Article/Betting-Against-Beta), published in 2014, AQR's Andrea Frazzini and Lasse H. Pedersen found that stocks with high beta tend to have low alpha. A portfolio that bought low-beta stocks with borrowed money and sold high-beta stocks short earned positive risk-adjusted returns.

__Explore further:__

* __Jobs and internships:__ AQR's [internships page](https://www.aqr.com/Our-Firm/Greenwich-Internships) describes a 10-week summer program in Greenwich. In November 2026, the [careers site](https://careers.aqr.com/) listed 2027 summer analyst roles in research, engineering, and business development.
* __Video:__ Watch [About AQR](https://www.youtube.com/embed/946GJrhyZtM) and [Internships at AQR](https://www.youtube.com/embed/Oow2UktGKcY) on the firm's YouTube channel.

__Connection to today's lecture:__ The betting-against-beta portfolio ranks stocks by their market sensitivity $\beta_{i}$, which sets the market part of our sector factor model. With a synthetic universe, we could test a betting-against-beta portfolio on many plausible market paths.

___


## Many Assets: The Sector Factor Model
The central challenge today is how to extend the single-asset jump hidden Markov model to many stocks that move together. We want to simulate a synthetic universe of stocks that captures the correlations, volatilities, and market sensitivities of the real data.

Previously, the multiple asset GBM model mixed independent Gaussian shocks through a loading matrix. Is there a way to mix independent jump hidden Markov models to produce many stocks that move together? The answer is yes, with a sector factor model.

Let's review the single index model and its covariance matrix, then add a sector factor to capture the covariance that the single index model misses. Here, we give the highlights of this approach. The [derivation notebook](advanced/sector_factor/CHEME-5660-L13b-Derivation-SectorFactor-Parts-Fall-2026.ipynb) shows how we get each result in detail.


### Review: The Single Index Model and Its Covariance
The single index model splits the growth rate of stock $i$ on day $t$ into a baseline, a market factor, and a single asset residual:

$$
g_{i}(t) = \underbrace{\alpha_{i}}_{\text{baseline}} + \underbrace{\beta_{i}\,g_{m}(t)}_{\text{market}} + \underbrace{\varepsilon_{i}(t)}_{\text{single asset residual}}
$$

Here $g_{m}(t)$ is the growth rate of `SPY`, and the single index residual $\varepsilon_{i}(t)$ is the growth that the market does not explain. The model assumes that the residuals have zero mean, are uncorrelated with the market, and are uncorrelated across stocks. On the diagonal of the covariance matrix, the variance of stock $i$ is given by:

$$
\begin{align*}
\operatorname{Var}(g_{i}) &= \operatorname{Var}\left(\alpha_{i}+\beta_{i}\,g_{m}+\varepsilon_{i}\right) && \text{substitute the single index model}\\
&= \beta_{i}^{2}\operatorname{Var}(g_{m})+2\,\beta_{i}\,\underbrace{\operatorname{Cov}(g_{m},\varepsilon_{i})}_{=0}+\operatorname{Var}(\varepsilon_{i}) && \text{expand, second assumption}\\
&= \beta_{i}^{2}\operatorname{Var}(g_{m})+\operatorname{Var}(\varepsilon_{i})
\end{align*}
$$

Off the diagonal, for two different stocks $i\neq j$, taking the covariance of their single index models gives the relationship between their market sensitivities and the covariance of their growth rates:

$$
\begin{align*}
\operatorname{Cov}(g_{i},g_{j}) &= \operatorname{Cov}\left(\alpha_{i}+\beta_{i}\,g_{m}+\varepsilon_{i},\;\alpha_{j}+\beta_{j}\,g_{m}+\varepsilon_{j}\right) && \text{substitute both single index models}\\
&= \beta_{i}\beta_{j}\operatorname{Var}(g_{m})+\beta_{i}\,\underbrace{\operatorname{Cov}(g_{m},\varepsilon_{j})}_{=0}+\beta_{j}\,\underbrace{\operatorname{Cov}(\varepsilon_{i},g_{m})}_{=0}+\underbrace{\operatorname{Cov}(\varepsilon_{i},\varepsilon_{j})}_{=0} && \text{expand, second and third assumptions}\\
&= \beta_{i}\beta_{j}\operatorname{Var}(g_{m})
\end{align*}
$$

Collecting the market sensitivities of the $n$ stocks in the vector $\boldsymbol{\beta}$ and placing these entries in a matrix gives:

$$
\begin{align*}
\mathbf{\Sigma}_{g}
&=\begin{bmatrix}
\beta_{1}^{2}\operatorname{Var}(g_{m})+\operatorname{Var}(\varepsilon_{1}) & \beta_{1}\beta_{2}\operatorname{Var}(g_{m}) & \cdots\\
\beta_{2}\beta_{1}\operatorname{Var}(g_{m}) & \beta_{2}^{2}\operatorname{Var}(g_{m})+\operatorname{Var}(\varepsilon_{2}) & \cdots\\
\vdots & \vdots & \ddots
\end{bmatrix} && \text{place the entries}\\
&=\operatorname{Var}(g_{m})\begin{bmatrix}
\beta_{1}^{2} & \beta_{1}\beta_{2} & \cdots\\
\beta_{2}\beta_{1} & \beta_{2}^{2} & \cdots\\
\vdots & \vdots & \ddots
\end{bmatrix}
+\begin{bmatrix}
\operatorname{Var}(\varepsilon_{1}) & 0 & \cdots\\
0 & \operatorname{Var}(\varepsilon_{2}) & \cdots\\
\vdots & \vdots & \ddots
\end{bmatrix} && \text{split each entry}\\
&=\underbrace{\operatorname{Var}(g_{m})\,\boldsymbol{\beta}\boldsymbol{\beta}^{\top}}_{\text{market}}+\underbrace{\mathbf{\Sigma}_{\varepsilon}}_{\text{residual}} && \text{name the two matrices}
\end{align*}
$$

The market matrix $\boldsymbol{\beta}\boldsymbol{\beta}^{\top}$ has the entry $\beta_{i}\beta_{j}$ in row $i$ and column $j$, so every entry has a market part. The residual matrix $\mathbf{\Sigma}_{\varepsilon}$ is the covariance matrix of the single index residuals. 

> __Why not use the single index model?__ The first version of the JumpHMM method used the single index model to simulate 424 stocks ([Alswaidan and Varner, 2026](https://arxiv.org/abs/2603.10202)). On the fitting data, the simulated stocks passed the Kolmogorov–Smirnov (KS) test much less often than the simulated `SPY` did (or the JumpHMM trained on the individual tickers).
>
> The paper traced this gap to the single index model and its residual draws, which did not fully capture each stock's growth rates. In the data, the single index residuals of two stocks in the same sector, such as two banks, usually move together, with $\operatorname{Cov}(\varepsilon_{i},\varepsilon_{j})>0$.
>
> However, the independent residual assumption (the third assumption of the single index model) does not hold in practice. Simulated stocks in the same sector move together less than real stocks do.

### Adding a Sector Factor
We need to capture the co-movement between stocks in the same sector. Let's build a new factor model that adds a sector factor to the single index model. The sector factor captures the covariance that the single index model misses.

Previously, we studied __factor models__, which describe the growth rate in terms of factors. For stock $i$ on day $t$, a general factor model is given by:

$$
g_{i}(t) = \underbrace{\alpha_{i}}_{\text{baseline}} + \underbrace{\beta_{i}\,g_{m}(t)}_{\text{market}} + \underbrace{\sum_{j}\delta_{ij}\,f_{j}(t)}_{\text{other factors}} + \underbrace{\varepsilon_{i}(t)}_{\text{residual}}
$$

Here $\alpha_{i}$ is the stock-specific baseline (intercept), $g_{m}(t)$ is the market growth rate, and $f_{j}(t)$ are other factors, such as interest rates or inflation. The coefficients $\beta_{i}$ and $\delta_{ij}$ measure sensitivity to these factors. 

The __residual__ $\varepsilon_{i}(t)$ is the growth rate left after subtracting the baseline and factor contributions.

> __Definition (sector factor model):__ A sector factor model adds one factor for each sector of the [Global Industry Classification Standard (GICS)](https://www.msci.com/our-solutions/indexes/gics). 
> 
> Each sector factor describes how the single index residuals of the stocks in its sector move together. Let's model the daily growth rate of stock $i$ in sector $s$ as:
>
> $$
> g_{i}(t) = \underbrace{\alpha_{i}}_{\text{baseline}} + \underbrace{\beta_{i}\,g_{m}(t)}_{\text{market}} + \overbrace{\underbrace{\delta_{i}\,f_{s}(t)}_{\text{sector}} + \underbrace{u_{i}(t)}_{\text{stock-specific}}}^{\text{single index residual }\varepsilon_{i}(t)}
> $$
>
> Here $g_{m}(t)$ is the growth rate of `SPY`, $f_{s}(t)$ is the growth rate of sector $s$ (with the market part removed), and $u_{i}(t)$ is the growth rate that neither the market nor the sector explains.

The sector factor is the average single index residual of the $n_{s}$ stocks in sector $s$. Substituting the single index model of each stock into this average gives:

  $$
  \begin{align*}
  f_{s}(t) &= \frac{1}{n_{s}}\sum_{j\in s}\varepsilon_{j}(t) && \text{average single index residual}\\
  &= \frac{1}{n_{s}}\sum_{j\in s}\left(g_{j}(t)-\alpha_{j}-\beta_{j}\,g_{m}(t)\right) && \text{single index fit of each stock } j\\
  &= \frac{1}{n_{s}}\sum_{j\in s}g_{j}(t)-\frac{1}{n_{s}}\sum_{j\in s}\alpha_{j}-\left(\frac{1}{n_{s}}\sum_{j\in s}\beta_{j}\right)g_{m}(t) && \text{split the sum, and factor out } g_{m}(t)\\
  &= \underbrace{\bar{g}_{s}(t)}_{\text{sector average}}-\underbrace{\bar{\alpha}_{s}}_{\text{baseline}}-\underbrace{\bar{\beta}_{s}\,g_{m}(t)}_{\text{market}} && \text{name the three averages}
  \end{align*}
  $$

  Each bar is an average over the $n_{s}$ stocks in the sector: $\bar{g}_{s}(t)$ of their growth rates on day $t$, $\bar{\alpha}_{s}$ of their baselines, and $\bar{\beta}_{s}$ of their market sensitivities.

  The sector factor is the sector's average growth rate with the baseline and the market part removed. A market move therefore enters the growth rate only once, through $\beta_{i}\,g_{m}(t)$.

The sector factor model splits the single index residual of stock $i$ into a sector part and a stock-specific part, $\varepsilon_{i}(t)=\delta_{i}\,f_{s}(t)+u_{i}(t)$. This gives us a way to model $\operatorname{Cov}(\varepsilon_{i},\varepsilon_{j})$ for two stocks in the same sector, which the single index model cannot do.

For stock $i$ in sector $s$ and a different stock $j$ in sector $r$, taking the covariance of their sector splits gives:

$$
\begin{align*}
\operatorname{Cov}(\varepsilon_{i},\varepsilon_{j}) &= \operatorname{Cov}\left(\delta_{i}\,f_{s}+u_{i},\;\delta_{j}\,f_{r}+u_{j}\right) && \text{substitute both sector splits}\\
&= \delta_{i}\delta_{j}\operatorname{Cov}(f_{s},f_{r})+\delta_{i}\,\underbrace{\operatorname{Cov}(f_{s},u_{j})}_{=0}+\delta_{j}\,\underbrace{\operatorname{Cov}(u_{i},f_{r})}_{=0}+\underbrace{\operatorname{Cov}(u_{i},u_{j})}_{=0} && \text{expand, independent draws}\\
&= \begin{cases}\delta_{i}\delta_{j}\operatorname{Var}(f_{s}) & \text{same sector, } r=s\\ 0 & \text{different sectors, } r\neq s\end{cases} && \text{independent sector draws}
\end{align*}
$$


> __Example:__ Suppose stocks 1 and 2 are in sector $s$, and stocks 3 and 4 are in sector $r$. The residual covariance matrix of the four stocks is given by:
>
> $$
> \mathbf{\Sigma}_{\varepsilon}=
> \left[\begin{array}{cc|cc}
> {\color{#1f6fb4} \operatorname{Var}(\varepsilon_{1})} & {\color{#1f6fb4} \delta_{1}\delta_{2}\operatorname{Var}(f_{s})} & {\color{#999999} 0} & {\color{#999999} 0}\\
> {\color{#1f6fb4} \delta_{1}\delta_{2}\operatorname{Var}(f_{s})} & {\color{#1f6fb4} \operatorname{Var}(\varepsilon_{2})} & {\color{#999999} 0} & {\color{#999999} 0}\\ \hline
> {\color{#999999} 0} & {\color{#999999} 0} & {\color{#d4720f} \operatorname{Var}(\varepsilon_{3})} & {\color{#d4720f} \delta_{3}\delta_{4}\operatorname{Var}(f_{r})}\\
> {\color{#999999} 0} & {\color{#999999} 0} & {\color{#d4720f} \delta_{3}\delta_{4}\operatorname{Var}(f_{r})} & {\color{#d4720f} \operatorname{Var}(\varepsilon_{4})}
> \end{array}\right]
> \begin{array}{l}\left.\vphantom{\begin{matrix}\operatorname{Var}(\varepsilon_{1})\\\operatorname{Var}(\varepsilon_{1})\end{matrix}}\right\}{\color{#1f6fb4} \text{ sector } s}\\ \left.\vphantom{\begin{matrix}\operatorname{Var}(\varepsilon_{1})\\\operatorname{Var}(\varepsilon_{1})\end{matrix}}\right\}{\color{#d4720f} \text{ sector } r}\end{array}
> $$
>
> The single index model has the same diagonal and zeros everywhere else. We now have off-diagonal entries $\delta_{i}\delta_{j}\operatorname{Var}(f_{s})$ for pairs of stocks in the same sector. The sector factor model therefore captures the covariance that the single index model misses.

### The Stock-Specific Part
The last part of the sector factor model is the stock-specific residual $u_{i}(t)$. This residual is what is left of the stock's daily growth rate after we remove the baseline, the market part, and the sector part:

$$
u_{i}(t) = \underbrace{g_{i}(t)-\alpha_{i}-\beta_{i}\,g_{m}(t)}_{\text{single index residual }\varepsilon_{i}(t)}-\underbrace{\delta_{i}\,f_{s}(t)}_{\text{sector}}
$$

We fit a single-asset jump hidden Markov model to the daily values of $u_{i}(t)$, the same way we fit the model of `SPY`. A path simulated from this model is the stock-specific draw. We multiply the draw by the residual scale $\psi_{i}$ and add $\psi_{i}\,u_{i}(t)$ to the growth rate of stock $i$.

The residual scale keeps the variance of the single index residual, the diagonal entry of the residual matrix. In the data, the residual is the sum $\varepsilon_{i}=\delta_{i}\,f_{s}+u_{i}$, whose two terms can be correlated. In the simulation, the sector draw and the stock-specific draw are independent:

$$
\begin{align*}
\operatorname{Var}(\varepsilon_{i}) &= \delta_{i}^{2}\operatorname{Var}(f_{s})+\operatorname{Var}(u_{i})+\underbrace{2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})}_{=\,0\text{ in the simulation}} && \text{data}\\
\operatorname{Var}(\varepsilon_{i}) &= \delta_{i}^{2}\operatorname{Var}(f_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i}) && \text{simulation, independent draws}
\end{align*}
$$

The independent draws drop the covariance term. We choose $\psi_{i}$ to put this variance back into the stock-specific draw. Solving the simulation line for $\psi_{i}^{2}$ gives:

$$
\boxed{\psi_{i}^{2} = \frac{\operatorname{Var}(\varepsilon_{i})-\delta_{i}^{2}\operatorname{Var}(f_{s})}{\operatorname{Var}(u_{i})}}
$$

The numerator is the variance that the sector part leaves to the stock-specific draw. If $f_{s}(t)$ and $u_{i}(t)$ are uncorrelated in the data, the residual scale is one.

### Comparing the Two Covariance Matrices
In general, each sector adds one block. With the residual scales chosen, the covariance matrices of the growth rates of the two models are:

$$
\begin{aligned}
\text{single index model:}\quad\mathbf{\Sigma}_{g} &= \underbrace{\operatorname{Var}(g_{m})\,\boldsymbol{\beta}\boldsymbol{\beta}^{\top}}_{\text{market}} + \underbrace{\operatorname{diag}\left(\operatorname{Var}(\varepsilon_{1}),\dotsc,\operatorname{Var}(\varepsilon_{n})\right)}_{\text{residual}}\\[6pt]
\text{sector factor model:}\quad\mathbf{\Sigma}_{g} &= \underbrace{\operatorname{Var}(g_{m})\,\boldsymbol{\beta}\boldsymbol{\beta}^{\top}}_{\text{market}} + \underbrace{\sum_{s}\operatorname{Var}(f_{s})\,\boldsymbol{\delta}_{s}\boldsymbol{\delta}_{s}^{\top}}_{\text{sector}} + \underbrace{\operatorname{diag}\left(\psi_{1}^{2}\operatorname{Var}(u_{1}),\dotsc,\psi_{n}^{2}\operatorname{Var}(u_{n})\right)}_{\text{stock-specific}}
\end{aligned}
$$

Here the vector $\boldsymbol{\delta}_{s}$ holds the sector loading $\delta_{i}$ of each stock in sector $s$ and zeros for the other stocks. Both matrices have the same market term. They also have the same diagonal, because the residual scale makes $\delta_{i}^{2}\operatorname{Var}(f_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i})=\operatorname{Var}(\varepsilon_{i})$.



### Sampling Algorithm
The algorithm below draws one synthetic path of the whole universe over $T$ days.

__Initialize__: Given the market model, the fitted sector models, and the fitted stock-specific models; each stock's baseline $\alpha_{i}$, market sensitivity $\beta_{i}$, sector loading $\delta_{i}$, and residual scale $\psi_{i}$; each stock's real starting price $S_{i}(0)$; the time step $\Delta t=1/252$ year (one trading day); and the number of days $T$.

1. __Shared draws:__ Draw one market path $g_{m}(1),\dotsc,g_{m}(T)$, shared by all stocks, from the market model. For each sector $s$ __do__: draw one factor path $f_{s}(1),\dotsc,f_{s}(T)$, shared by the stocks in that sector, from its sector model. 
2. __Stock-specific draws:__ For each stock $i$ __do__: draw a path $u_{i}(1),\dotsc,u_{i}(T)$ from the stock-specific model of stock $i$.
3. __Compose:__ For each stock $i$ in sector $s$ and each day $t = 1,2,\dots,T$ __do__: compose the growth rate $g_{i}(t) \gets \alpha_{i} + \beta_{i}\,g_{m}(t) + \delta_{i}\,f_{s}(t) + \psi_{i}\,u_{i}(t)$, and compound the price, starting from $S_{i}(0)$: $S_{i}(t) \gets S_{i}(t-1)\exp\left(g_{i}(t)\,\Delta t\right)$.

__Output__: The market path $g_{m}(t)$, and the growth rates $g_{i}(t)$ and prices $S_{i}(t)$ of every synthetic stock, for $t = 1,\dotsc,T$.

Let's look at an example:

> __Example:__
>
> [▶ Build a synthetic market of many stocks](CHEME-5660-L13b-Example-JumpHMM-SectorFactor-Fall-2026.ipynb). In this example, we use the sector factor model to build a universe of `SPY` and 375 stocks from all 11 sectors. We compare the correlations, volatilities, and market sensitivities of a synthetic path with the real data, turn off the sector part, and save the fitted model.

___

## Optional Advanced Material
> [▶ Derive the parts of the sector factor model](advanced/sector_factor/CHEME-5660-L13b-Derivation-SectorFactor-Parts-Fall-2026.ipynb). In this notebook, we show that the sector factor, the average single index residual of a sector, has no market part. We derive the least-squares sector loading with its one scale per sector, and the residual scale that sizes the stock-specific draw.

> [▶ Fit the `SPY` model to one-minute growth rates](advanced/one_minute/CHEME-5660-L13b-Advanced-JumpHMM-SPY-OneMinute-Fall-2026.ipynb). In this notebook, we fit the hidden Markov model of `SPY` to the one-minute growth rates of 2025, with and without jump episodes. We score the model one trading day at a time on 2025 and 2026, and refit it before each day of 2026 on the trading days just before it.

___

## Summary
We tested the jump hidden Markov model of `SPY` on data it had not seen. We then extended the model from one asset to a universe of stocks that move together, as real stocks in the same market and sector do.

> __Key Takeaways:__
>
> * __Testing the single-asset model out of sample:__ We compared paths simulated from the jump hidden Markov model of `SPY` with the growth rates of 2025 and 2026, which came after its fitting period. The paths with a jump episode failed the distribution tests more often, and their volatility clustering lasted longer than in the data.
> * __Many stocks from single-asset models:__ We built the synthetic universe from single-asset jump hidden Markov models: one for the market, one for each sector, and one for each stock. Every stock shares the market draw, and every stock in a sector shares the sector draw. The shared sector draw adds the residual covariance of stocks in the same sector, which the single index model sets to zero.
> * __Residual scale:__ We sized the stock-specific draw so that, together with the sector draw, it keeps the variance of each stock's single index residual.

Synthetic markets of many stocks let us test a trading method on many plausible paths, rather than on one historical path. Knowing how the synthetic universe is built also tells us its limits: stocks in different sectors move together only through the market draw.

___

