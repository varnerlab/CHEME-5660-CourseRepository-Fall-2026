# Example: The Thermal Minority Game
In this example, we simulate the minority game, an agent-based model in which an odd number of agents decide to buy or sell each round and the agents on the minority side win. Each agent chooses among a few fixed policies, and in the thermal version it makes that choice with Boltzmann probabilities set by a temperature.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Simulate one minority game:__ We simulate one minority game, plot the attendance, compute the volatility of the attendance per agent, and let the attendance move a price whose growth rates we check for the stylized facts.
> * __Measure how the memory changes the price volatility:__ We hold the number of agents and the liquidity fixed, vary the memory, and measure the annualized volatility of the growth rates. We compare it with a market of agents who flip coins.
> * __Measure how the temperature changes the price volatility:__ The temperature sets how strongly an agent favors its best-scoring policy. We vary the temperature in the crowded game and compare the price volatility with that of the greedy game and of random policy choice.

We compare every volatility with the value for agents who flip fair coins, which is one per agent.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/).

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Constants
Next, let's set the constants. See the comments next to the constants for definitions, units, and permissible values.

___

## Task 1: Simulate One Minority Game
In this task, we simulate one greedy minority game with `N_crowded` agents, where every agent uses its best-scoring policy. We measure how far the attendance moves from zero, and then we let the attendance move a price.

__Simulate the game__: [The build(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/abm/#VLQuantitativeFinancePackage.build-Tuple{Type{MyThermalMinorityGameModel},%20NamedTuple}) draws the policies of every agent at random and returns a `MyThermalMinorityGameModel`, and [the solve(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/abm/#VLQuantitativeFinancePackage.solve-Tuple{MyThermalMinorityGameModel}) plays the game. In the code below:
* We pass the number of agents, the memory `m`, the number of policies `J`, the temperature, and a [`MersenneTwister`](https://docs.julialang.org/en/v1/stdlib/Random/#Random.MersenneTwister) random number generator `rng` to `build(...)`.
* `solve(...)` first plays `burn_in` rounds and discards them, then records `number_of_rounds` rounds. The scores start at zero, and we want to measure the game after they have moved away from that start.
* The result `game::NamedTuple` holds the attendance `attendance::Vector{Int}`, the history of each round `information::Vector{Int}`, the volatility per agent `volatility_per_agent::Float64`, the number of histories per agent `alpha::Float64` ($\alpha=P/N$), and the final scores `final_scores::Array{Float64,2}`, one row per agent and one column per policy.

Let's simulate the game:

Let's put the size of the game and its volatility per agent in a [`DataFrame`](https://dataframes.juliadata.org/stable/lib/types/#DataFrames.DataFrame) and display the table with [the `pretty_table(...)` function](https://ronisbr.github.io/PrettyTables.jl/stable/lib/library/#PrettyTables.pretty_table):

Output:
```
 ----------------------------- --------
  quantity                       value 
 ----------------------------- --------
  number of agents N               641
  memory m                           6
  number of histories P = 2^m       64
  histories per agent α = P/N   0.0998
  volatility per agent σ_A²/N    2.804
 ----------------------------- --------
```

> __What do we see?__ The volatility per agent is well above 1, the value for coin flips. With many more agents than histories, the attendance moves much farther from zero than it would if every agent flipped a coin.

`Unhide` the code block below to see how we plotted the attendance for the first 200 recorded rounds. The dashed lines at $\pm\sqrt{N}$ mark one standard deviation of the attendance for coin flips.

How does the attendance move from round to round?

> __What do we see?__ The attendance swings far from zero in both directions, and many rounds land outside the dashed lines, one coin-flip standard deviation from zero. Large majorities of buyers and large majorities of sellers both occur, often within a few rounds of each other.

### From the attendance to a price
The original minority game has no price. In the lecture, we added one as an instructor's extension: a market maker treats the attendance as the excess demand for the asset and moves the log price:

$$
\ln S_{t+1} = \ln S_{t} + \frac{A_{t}}{\lambda} + \sigma_{S}\sqrt{\Delta t}\,Z_{t+1}
$$

where the liquidity $\lambda$ is the attendance that moves the log price by one, and $\sigma_{S}$ is the annualized volatility of the price noise. The draw $Z_{t+1}$ is standard Normal unless we set `noise_model = :studentt`. Because the agents never see the price, we compute it from the attendance after the game is played, starting from $S_{0}$ at $t=0$.

__Compare two markets__: We compare the crowded game we just played ($\alpha\approx 0.1$) with a second game of `N_crowded` agents that differs only in its memory, `m_near`. That game has $\alpha\approx 0.40$. In the code below:
* A separate random number generator `price_rng` draws one noise value $Z_{t+1}$ for each recorded round. Because both prices use these draws, the two price paths differ only through their attendances.
* The result `markets::Vector{NamedTuple}` holds, for each game, its name, $\alpha$, and its log prices, starting from $\ln S_{0}$.

Let's compute the two prices:

`Unhide` the code block below to see how we plotted the price $S_{t}$ of both markets for the first `price_window` recorded rounds. Both prices start at `S₀` and share the same noise path.

How do the prices of the two markets move?

> __What do we see?__ The crowded game's price booms and busts. It climbs to about two and a half times its starting value, then loses about half of that within a few dozen rounds. The price of the longer-memory game stays within about 30% of its start.

__Growth rates and stylized facts__: If one round lasts $\Delta t$ years, the growth rate over round $t$ follows directly from the price rule:

$$
g_{t+1}=\frac{1}{\Delta t}\ln\frac{S_{t+1}}{S_{t}}=\underbrace{\frac{A_{t}}{\lambda\,\Delta t}}_{\text{agents}}+\underbrace{\frac{\sigma_{S}}{\sqrt{\Delta t}}\,Z_{t+1}}_{\text{price noise}}
$$

We measure the three stylized facts of daily growth rates for both markets: the excess kurtosis (fat tails), the autocorrelation of $g$ (little autocorrelation), and the autocorrelation of $\lvert g\rvert$ (volatility clustering). 

In the code below:
* `excess_kurtosis(...)` is the fourth moment of the standardized series minus 3, which is zero for a Normal distribution. If the series has fat tails, the excess kurtosis is positive.
* [The stylized_facts_report(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/adaptive/#VLQuantitativeFinancePackage.stylized_facts_report) returns the autocorrelations of $g$ and $\lvert g\rvert$ at each lag in `lags`, and the white-noise band $\pm 1.96/\sqrt{n}$, where $n$ is the length of the series. For a series with no autocorrelation, 95% of sample autocorrelations fall inside this band. A value outside the band is unlikely to be noise.

Let's compute the stylized facts:

Output:
```
 ---------------------- ----------------- -------------- -------------- --------------- ---------------- ---------------- ----------------- ----------
  market                 excess kurtosis   acf g, lag 1   acf g, lag 5   acf g, lag 20   acf |g|, lag 1   acf |g|, lag 5   acf |g|, lag 20   band (±) 
 ---------------------- ----------------- -------------- -------------- --------------- ---------------- ---------------- ----------------- ----------
  crowded game, m = 6              1.080         -0.001         -0.002          -0.004            0.004            0.002             0.000      0.020
  longer memory, m = 8             0.108         -0.001         -0.010          -0.013            0.040            0.018             0.000      0.020
 ---------------------- ----------------- -------------- -------------- --------------- ---------------- ---------------- ----------------- ----------
```

> __What do we see?__
>
> * __Fat tails:__ The crowded game's growth rates have an excess kurtosis of about 1, mild fat tails that come from the agents, because Normal noise has no excess kurtosis of its own. The growth rates of the longer-memory game have an excess kurtosis near zero, like a Normal distribution.
> * __Autocorrelation and clustering:__ In both markets, every autocorrelation of $g$ is inside the white-noise band. Only the longer-memory game shows volatility clustering, above the band at lag 1 and inside it by lag 5, while the clustering of the `SPY` growth rates in the Farmer–Joshi example lasts for weeks.

`Unhide` the code block below to see how we plotted the distribution of the growth rates in both markets. The dashed black curves are the Normal distributions with the same mean and variance as each market.

> __What do we see?__ The crowded game's growth rates are far more spread out, reaching beyond $\pm 50$ per year, while those of the longer-memory game stay within about $\pm 12$ per year. The longer-memory game lies on its Normal curve. The crowded game rises slightly above its Normal curve at the center, which matches its mild excess kurtosis.

Try these changes to the constants and run this task again:
* __Fat-tailed noise:__ With `noise_model = :studentt` and `σ_S = 0.3`, the excess kurtosis of the longer-memory game rises above 2, but every autocorrelation of $\lvert g\rvert$ falls inside the band. Noise drawn independently each round can add fat tails, but it cannot by itself produce volatility clustering.
* __Biased policies:__ With `buy_probability = 0.8`, every agent holding a policy that says sell switches to selling, but agents whose policies all say buy cannot switch. The attendance in Task 1 then becomes a flat line at a positive value, and the history stops changing. The price rises by the same amount every round, a trend with no volatility from the agents.
* __A weaker bias:__ Below a buy probability of $2^{-1/J}$, the agents who can sell remove most of the bias.
___

## Task 2: Measure How the Memory Changes the Price Volatility
In Task 1, two markets with `N_crowded` agents differed only in their memory, and the crowded game moved the price far more. In this task, we repeat that comparison at many memories and measure the price volatility of each market.

__Sweep the memory__: With a short memory, many agents hold similar policies and buy or sell at the same time. With a long memory, two agents' policies rarely agree. For each memory, we play `number_of_seeds` independent greedy games with `N_crowded` agents and the same liquidity and $\sigma_{S}$, and we measure the price volatility. In the code below:
* [The `annualized_volatility(...)` function](src/Helper.jl) adds the price noise to one game's attendance and returns the standard deviation of $g_{t+1}$ times $\sqrt{\Delta t}$, in percent. This annualized volatility has the same units as $\sigma_{S}$.
* The range `memories` holds the memories we try. One random number generator `rng`, seeded with `random_seed`, supplies every game, and a separate one supplies the price noise.
* The result `memory_df::DataFrame` has one row per game: the memory, $P$, $\alpha$, the seed index, and the annualized volatility.

Let's run the sweep:

For each memory, we average the annualized volatility over the games using [the `groupby(...)` function](https://dataframes.juliadata.org/stable/lib/functions/#DataAPI.groupby) and [the `combine(...)` function](https://dataframes.juliadata.org/stable/lib/functions/#DataFrames.combine):

Output:
```
 ---------- ------------- --------- --------------------------- ----------------
  memory m   histories P   α = P/N   annualized volatility (%)   coin flips (%) 
 ---------- ------------- --------- --------------------------- ----------------
         4            16     0.025                       145.0             40.3
         5            32     0.050                       104.7             40.3
         6            64     0.100                        65.0             40.3
         7           128     0.200                        41.5             40.3
         8           256     0.399                        19.1             40.3
         9           512     0.799                        22.8             40.3
        10          1024     1.598                        28.8             40.3
        11          2048     3.195                        33.1             40.3
 ---------- ------------- --------- --------------------------- ----------------
```

> __What do we see?__
>
> * __Short memory:__ At $m=6$ and below, the price is more volatile than in a market of agents who flip coins, at 65% or more. Many agents hold similar policies and trade on the same side, as in the crowded game of Task 1.
> * __Intermediate memory:__ The volatility reaches the coin-flip value at $m=7$ and its lowest value, about 19%, at $m=8$, the memory of the second market in Task 1. The agents' policies differ enough that buyers and sellers nearly balance.
> * __Long memory:__ Beyond $m=8$, the volatility rises toward the coin-flip value, but it is still below that value at $m=11$.

With the same number of agents, liquidity, and $\sigma_{S}$, we measure a price volatility of about 19% or about 145%, depending only on how much the agents' policies overlap.

___

## Task 3: Measure How the Temperature Changes the Price Volatility
In Tasks 1 and 2, every agent used its best-scoring policy in every round. In this task, we let the agents depart from their best policy and measure what happens to the price. We return to the crowded game of Task 1, with `N_crowded` agents and memory `m`, and vary the temperature $T$ of the Boltzmann choice rule.

### Choosing a policy at a finite temperature
In the thermal game, agent $i$ uses policy $\pi_{ij}$ with the Boltzmann probability:

$$
p_{ij} = \frac{\exp\left(U_{ij}/T\right)}{\displaystyle\sum_{k=1}^{J}\exp\left(U_{ik}/T\right)}
$$

where $T>0$ is the temperature, measured in the same units as the scores. The temperature sets how much a difference in scores matters.

The __best policy__ of agent $i$ is the one with the highest current score, $\arg\max_{j}U_{ij}$. Let $\Delta_{ik}=\max_{j}U_{ij}-U_{ik}\geq 0$ be the gap between the best score and the score of policy $\pi_{ik}$. Dividing the numerator and denominator of the Boltzmann rule by the exponential of the best score gives the probability of using the best policy:

$$
p_{\text{best}}=\frac{1}{1+\displaystyle\sum_{k\neq\text{best}}\exp\left(-\Delta_{ik}/T\right)}
$$

When $T$ is small compared with the gaps to all the other policies, this probability is close to 1, and the agent almost always uses its best policy. When $T$ is much larger than every gap, it is close to $1/J$, and the agent chooses almost at random.

[The boltzmann_weights(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/abm/#VLQuantitativeFinancePackage.boltzmann_weights) computes these probabilities, and each agent draws its policy from a [categorical distribution](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.Categorical) with them. Let's compute them for one agent, at temperatures that are multiples of $\Delta$, the gap between its two highest scores:

Output:
```
agent i = 1: scores U = [-1.06, -5.91], gap between the two highest scores Δ = 4.84
 ----- --------------- ------------- -------------
  T/Δ   temperature T   p(policy 1)   p(policy 2) 
 ----- --------------- ------------- -------------
    0            0.00        1.0000        0.0000
  0.1            0.48        1.0000        0.0000
    1            4.84        0.7311        0.2689
   10           48.44        0.5250        0.4750
    ∞             Inf        0.5000        0.5000
 ----- --------------- ------------- -------------
```

> __What do we see?__ In the greedy row (listed as 0) and at a tenth of $\Delta$, the agent uses its best policy with probability close to 1. As the temperature grows to ten times $\Delta$, the probabilities move toward $1/J$, the $T=\infty$ row.
>
> The probabilities depend only on the gaps $\Delta_{ik}$ compared with $T$. Two agents with the same gaps have the same probabilities.

__Sweep the temperature__: We sweep the temperature between two limits. As $T\to 0$, we approach the greedy game. As $T\to\infty$, every agent picks each of its $J$ policies with probability $1/J$, whatever the scores. For each temperature, we build and play `number_of_seeds` games with `N_crowded` agents and compute each game's annualized volatility. In the code below:
* `temperatures::Vector{Float64}` runs from 0.01 to 100,000 on a log grid with two values for every factor of ten, and we also play the two limits, the greedy game and random choice ($T=\infty$).
* As in Task 2, one random number generator `rng` supplies every game, and a separate one supplies the price noise.
* The result `temperature_df::DataFrame` has one row per game: the temperature, the seed index, and the annualized volatility.

Let's run the sweep:

`Unhide` the code block below to see how we plotted the annualized volatility against the temperature on a log axis. The horizontal lines mark the greedy game, random choice ($T=\infty$), and coin flips.

How does the price volatility change with the temperature?

> __What do we see?__
>
> * __Low temperatures:__ Up to about $T=0.3$, the price volatility stays near the greedy line. For the agent in the table above, a temperature this small compared with $\Delta$ gives its best policy a probability close to 1.
> * __Intermediate temperatures:__ Between about $T=1$ and $T=10$, the volatility drops by about half and crosses the random-choice line. From about $T=10$ to $T=1{,}000$ it stays well below both the greedy line and the random-choice line, with its smallest value near $T=100$.
> * __High temperatures:__ Above about $T=1{,}000$, the volatility rises back toward the random-choice line.

When every agent always uses its best policy, agents with the same best policy switch together, and the price is most volatile. Some randomness in the choice spreads out those switches, and the price is less volatile than at either limit.

___

## Summary
In this example, we simulated the minority game, let the attendance move a price, and measured how the memory and the temperature change the volatility of that price.

> __Key Takeaways:__
>
> * __A few rules produce a measurable aggregate:__ We simulated agents who each buy or sell with one of several fixed policies, scored every policy after each round, and recorded the attendance. The volatility of the attendance per agent let us compare the whole population with agents who flip coins.
>
>   When we let the attendance move a price, the crowded game moved it more than the longer-memory game. Its growth rates had mild fat tails but almost no volatility clustering.
> * __The overlap in the agents' policies sets the price volatility:__ We varied the memory with the same number of agents, liquidity, and $\sigma_{S}$, and measured the annualized volatility of the growth rates. With a short memory, many agents held similar policies, and the price was more volatile than in a market of agents who flip coins.
>
>   At an intermediate memory, the volatility fell well below the coin-flip value.
> * __Some randomness in the policy choice lowers the price volatility:__ We varied the temperature of the Boltzmann choice rule in the crowded game. Low temperatures gave the volatility of the greedy game, high temperatures approached random choice, and in between the price volatility fell below both limits.

The agents, the history they see, their rule for choosing a policy, the attendance, and the scores that feed the attendance back into the next choice are the five parts of an agent-based model from the lecture.
___
