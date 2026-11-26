"""Write the L15a lecture notebook from the committed lecture's updating section and the new sections.

Usage: python3 make_lecture.py <old lecture.ipynb> <out.ipynb>
The updating section and the advanced-material cell come from the old lecture, word for word, except the sentence
about when the trading method picks a new basket (one list of six triggers).
"""
import json, sys

OLD = json.load(open(sys.argv[1]))
OUT = sys.argv[2]
NOTATION = "https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html#L15a"
BACKTEST = "CHEME-5660-L15a-Example-Strategy-Backtest-Fall-2026.ipynb"
STRESS = "CHEME-5660-L15a-Example-Strategy-Stress-Test-Fall-2026.ipynb"
UPDATING = "CHEME-5660-L15a-Example-Updating-SIM-Gamma-Fall-2026.ipynb"
MENU = "strategies/CHEME-5660-L15a-Strategy-Menu-Fall-2026.ipynb"

def old_cell(heading):
    for c in OLD["cells"]:
        s = "".join(c["source"])
        if s.startswith(heading):
            return s
    raise KeyError(heading)

# the figure block, as the updating section writes it -
STYLE = old_cell("## Updating the Single Index Model").split("<style>")[1].split("</style>")[0]
def figure(name, width, alt):
    return f"""<style>{STYLE}</style>
<div>
    <center>
        <img class="course-diagram" src="figs/{name}.svg" width="{width}" style="max-width:100%; height:auto;" alt="{alt}"/>
    </center>
</div>"""

ALT_BACKTEST = open(sys.argv[3]).read().strip() if len(sys.argv) > 3 else "TBD"
ALT_STRESS = open(sys.argv[4]).read().strip() if len(sys.argv) > 4 else "TBD"

cells = []
def md(s):
    cells.append(s.strip("\n"))

# ---------------------------------------------------------------------------------------------------------------
md(rf"""
# L15a: Testing a Trading Strategy
Today, we'll introduce a trading method that updates its estimates of each stock every trading day and picks a new basket of stocks when the market changes. Then we'll test strategies built on this method, first with a backtest on the real market and then with a stress test on synthetic markets.

> __Learning Objectives:__
>
> By the end of this lecture, you should be able to:
>
> * __Update the estimates of a trading method:__ Update the single index model of each stock every trading day with exponentially weighted least squares. Use the updated estimates in the preference weights and the market hedge of the trading method.
> * __Backtest a strategy on the real market:__ Describe the daily loop of a backtest and the six triggers that start a new decision. Compare a strategy from the menu with `SPY` and with the other strategies on the menu.
> * __Stress-test a strategy with the five gates:__ Run a strategy on many synthetic markets. Test its median outcome and its share of losing markets against the five gates.

Some results in this lecture are core, and some are here to build understanding:

> __What you need to know:__
>
> __Core concepts:__
>
> * Exponentially weighted least squares updates the single index model of each stock with every new trading day, and the weight of a day halves every 63 trading days. The preference weights and the market hedge then follow each stock's recent market sensitivity.
> * A backtest runs a strategy on the real market one trading day at a time. Each day, the strategy uses only the data through that day, and it makes a new decision when one of six triggers fires.
> * A stress test runs a strategy on many synthetic markets. Four of the five gates take the median over the markets, and the failure rate counts the markets that end below the starting wealth.
>
> __For understanding__ (you will not need to reproduce or memorize these):
>
> * The running sums of the daily update, and the update of the general factor model.
> * The settings of the six triggers, such as the 8% drawdown.
> * How the practicum's engine differs from the trading method.

__Notation:__ The [course notation page]({NOTATION}) lists this lecture's symbols with their meanings and units.

Let's get started!

___
""")

# ---------------------------------------------------------------------------------------------------------------
md(rf"""
## Examples

__We will work through these examples in lecture:__

> [▶ Backtest a strategy from the menu]({BACKTEST}). In this example, we backtest one strategy from the menu on the real market, from January 2, 2025, to November 24, 2026. We mark the days a trigger fired, place the strategy among the saved backtests of the whole menu, and run it again with updated estimates.

> [▶ Stress-test a strategy with the five gates]({STRESS}). In this example, we stress-test one strategy from the menu on 200 synthetic markets and plot the range of its wealth. We test the strategy with the five gates, and then test it again with the market hedge on.

__Review on your own:__

> [▶ Update the single index model and the preference weights]({UPDATING}). In this example, we update the single index model of every stock with each trading day of 2025 and 2026, starting from the 2016 to 2024 fit. We compute the preference weights from the updated estimates and pick the preference basket once a month and whenever the market turns. Then we compare the preference basket with the basket from the fixed 2016 to 2024 estimates.

___
""")

# ---------------------------------------------------------------------------------------------------------------
# the updating section, word for word, except the sentence about when the method picks a new basket -
updating = old_cell("## Updating the Single Index Model")
old_pick = ("> * __Picks at market turns:__ The __preference basket__ holds the stocks with the highest preference weights "
    "in each sector. We choose how many stocks to keep from each sector. The method picks a new basket every 21 trading "
    "days and whenever the market turns, but other triggers are also possible.")
new_pick = ("> * __Picks when a trigger fires:__ The __preference basket__ holds the stocks with the highest preference "
    "weights in each sector. We choose how many stocks to keep from each sector. The method picks a new basket whenever "
    "one of six triggers fires, for example after 21 trading days or at a market turn.")
assert updating.count(old_pick) == 1, "the pick sentence must appear once in the updating section"
updating = updating.replace(old_pick, new_pick)

# the numbers of the practicum's data: the 2016 to 2024 fit (2,263 daily growth rates) and data to November 24, 2026.
# The opening sentence says "the training data", because the earlier lectures fit on 2014 to 2024 -
data_edits = [
    ("Previously, we fit the single index model of each stock once, on the 2014 to 2024 data, and held its estimates fixed.",
     "Previously, we fit the single index model of each stock once, on the training data, and held its estimates fixed."),
    ("than their 2014 to 2024 estimates say.", "than their 2016 to 2024 estimates say."),
    ("A dashed line marks the fixed estimate from the 2014 to 2024 fit, 1.11. The blue updated estimate, with one update per trading day, starts at 1.11,",
     "A dashed line marks the fixed estimate from the 2016 to 2024 fit, 1.12. The blue updated estimate, with one update per trading day, starts at 1.12,"),
    ("\\frac{N_{0}}{2766}\\sum_{k=-2765}^{0}", "\\frac{N_{0}}{2263}\\sum_{k=-2262}^{0}"),
    ("the last day of the 2014 to 2024 fit, day $1$ is January 2, 2025, and day $469$ is November 13, 2026, the last day of our data.",
     "the last day of the 2016 to 2024 fit, day $1$ is January 2, 2025, and day $476$ is November 24, 2026, the last day of our data."),
    ("Each of the 2,766 days of 2014 to 2024 gets the weight $N_{0}/2766$, with $N_{0}=63$. On day $0$, the prior alone gives the 2014 to 2024 fit.",
     "Each of the 2,263 days of 2016 to 2024 gets the weight $N_{0}/2263$, with $N_{0}=63$. On day $0$, the prior alone gives the 2016 to 2024 fit."),
    ("including the prior from the 2014 to 2024 fit.", "including the prior from the 2016 to 2024 fit."),
    ("each trading day of 2025 and 2026, starting from the 2014 to 2024 fit. We pick the preference basket",
     "each trading day of 2025 and 2026, starting from the 2016 to 2024 fit. We pick the preference basket"),
]
for (a, b) in data_edits:
    assert updating.count(a) == 1, "each data edit must match once: " + a[:60]
    updating = updating.replace(a, b)
assert "2014 to" not in updating and "2766" not in updating and "469" not in updating, "no old number may remain"
md(updating)

# ---------------------------------------------------------------------------------------------------------------
md(rf"""
## Backtesting a Strategy
The trading method leaves four choices to us. We call one set of these choices a __strategy__:

| Choice | What it sets | On the [strategy menu]({MENU}) |
|:--|:--|:--|
| Picking rule | which tickers go into the basket | 9 entries, for example the highest preference weights in each sector, or a random draw |
| Weighting rule | how the wealth is split among the stocks of the basket | 9 rules, for example Cobb–Douglas, minimum variance, or equal weight |
| Market hedge | whether the market sensitivity of the portfolio has a limit | on or off |
| Estimates | which estimates of the single index model the method uses | fixed from the fit on the training data, or updated every trading day |


We test a strategy first on the real market. Each trading day of the test follows the same steps:

{figure("Fig-L15a-Backtest-Day", 860, ALT_BACKTEST)}

> __Definition (backtest):__ A backtest runs a strategy on past market data, one trading day at a time, as if we had traded it. On each day, the strategy uses only the data through that day, and its orders fill at the next day's opening prices.

### Backtest Algorithm
__Initialize__: Given a strategy; the prices, volumes, and Treasury bill rates of the training and backtest days; the estimates of the single index model of each stock on the day before the backtest starts; and the starting wealth $W_{{0}}$, all in cash. The first decision comes after the close of the first day.

For each trading day $t$ of the backtest __do__:

1. __Fill:__ Fill the orders queued yesterday at today's opening prices. Each trade pays half the bid-ask spread and a market impact that grows with the size of the trade.
2. __Value:__ Grow the cash at the Treasury bill rate. Compute today's wealth $W(t)$ at the closing prices: the cash plus the value of every holding.
3. __Update:__ If the strategy uses updated estimates, __then__ update the single index model of each stock with today's growth rates. Compute the market state $\xi_{{t}}$ and the preference weight $\gamma_{{i}}(t)$ of each stock.
4. __Decide:__ If no trigger fires, __then__ keep the portfolio. Otherwise, make a new decision:
   - a. __Pick:__ The picking rule chooses the stocks of the basket.
   - b. __Weight:__ The weighting rule sets the weight of each stock within the trading limits: a limit on the weight of each ticker, a volatility no higher than that of `SPY` on the training data, a limit on the trading costs of each decision, and no borrowing. With the hedge on, the market sensitivity of the portfolio must also stay at or below its limit.
   - c. __Queue:__ Turn the weights into share counts at today's closing prices, queue the orders for tomorrow's open, and forecast the wealth over the next 21 trading days with the __generator__, the general factor model of the practicum.

__Output__: The wealth $W(t)$ of each day, the decisions with the trigger that started each one, and the trades.

### The Six Triggers
After each close, the trading method checks six triggers:

| Trigger | Fires when |
|:--|:--|
| Scheduled | 21 trading days have passed since the last decision. |
| Market turn | The market state $\xi_{{t}}$ has changed sign since the last decision. With the hedge on, it also fires when $\xi_{{t}}$ crosses one, where the `SPY` short starts or stops. |
| Band exit | The wealth leaves the middle 95% of its forecast. |
| Drawdown | The wealth falls more than 8% below its peak. The peak starts over at each drawdown decision. |
| Market sensitivity over its limit | With the hedge on, the market sensitivity $\beta_{{P}}(t)$ of the portfolio is more than 0.1 above its limit. |
| Back from cash | The scheduled trigger, when the last decision put all the wealth in cash. |

Let's backtest one strategy from the menu:

> __Example:__
>
> [▶ Backtest a strategy from the menu]({BACKTEST}). In this example, we backtest one strategy from the menu on the real market, from January 2, 2025, to November 24, 2026. We mark the days a trigger fired, place the strategy among the saved backtests of the whole menu, and run it again with updated estimates.

The backtest shows how the strategy did on the one market that happened.

___
""")

# ---------------------------------------------------------------------------------------------------------------
md(rf"""
## Stress-Testing a Strategy
Next, we run the same strategy on many synthetic markets from the generator, to see the range of outcomes it could face over the next year:

{figure("Fig-L15a-Stress-Test", 860, ALT_STRESS)}

> __Definition (stress test):__ A stress test runs a strategy on $P$ synthetic markets. Each market is the real history to the start day, the last day of our data, followed by one synthetic year of 252 trading days drawn from the generator. On every market, the strategy starts with the wealth $W_{{0}}$ in cash and with its estimates on the start day.

### Stress-Test Algorithm
__Initialize__: Given a strategy; the real history to the start day; the generator; and the number of markets $P=200$.

For each market $p=1,2,\dots,P$ __do__:

1. __Draw:__ Draw the growth rates of `SPY` and of every ticker for 252 trading days from the generator. Compound each price from its last real closing price.
2. __Backtest:__ Run the backtest algorithm from the start day through the 252 synthetic days.
3. __Score:__ Compute the Sharpe ratio, the largest drawdown, the wealth on the last day, and the net present value of the run.

__Output__: The scores of the strategy on each of the $P$ markets.

### The Five Gates
We test the strategy's scores against five gates:

| Gate | Passes when | What it measures |
|:--|:--|:--|
| Median Sharpe ratio | at least 0.3 | the growth of the wealth over the Treasury bill rate, per unit of volatility |
| Median largest drawdown | at most 25% | the largest fall of the wealth below its peak |
| Failure rate | at most 10% | the share of markets on which the wealth ends below $W_{{0}}$ |
| Median wealth on the last day | at least the comparison's median | the wealth after one year |
| Median net present value | at least USD 0 | the wealth on the last day, discounted at the Treasury bill rate, minus $W_{{0}}$ |

In the fourth gate, a strategy with fixed estimates faces the 60/40 benchmark, which holds 60% of its wealth in `SPY` and 40% in the long-term Treasury bond fund `TLT`. A strategy with updated estimates faces its copy with fixed estimates on the same markets, which tests whether updating the estimates added wealth.

Let's stress-test one strategy from the menu:

> __Example:__
>
> [▶ Stress-test a strategy with the five gates]({STRESS}). In this example, we stress-test one strategy from the menu on 200 synthetic markets and plot the range of its wealth. We test the strategy with the five gates, and then test it again with the market hedge on.

___
""")

# ---------------------------------------------------------------------------------------------------------------
md(r"""
## Testing Your Fund in the Practicum
The practicum uses the same data, the same Treasury bill rate, the same 200 synthetic markets, and the same five gates as our examples. Its engine differs from the trading method in five ways:

| | The trading method | The practicum's engine |
|:--|:--|:--|
| __Triggers__ | the six triggers | two of the six: scheduled and market turn |
| __Weights__ | the weighting rule's formula, adjusted to meet the trading limits | your formula, as you write it |
| __Fills__ | at the next day's opening price | at the closing price of the decision day |
| __Limits__ | the trading limits of the backtest | the leverage you set, from 1.0 to 2.0, with margin interest and a maintenance rule |
| __Hedge__ | the market hedge, on or off | no market hedge, but protective puts can limit the fund's losses |

The same picking and weighting rules can score differently in the practicum. You can send a fund that fails a gate to the paper test if you explain why.

___
""")

# ---------------------------------------------------------------------------------------------------------------
advanced = old_cell("## Optional Advanced Material")
assert advanced.count("the 2014 to 2024 fit") == 1, "the advanced cell names the fit once"
md(advanced.replace("the 2014 to 2024 fit", "the 2016 to 2024 fit"))

# ---------------------------------------------------------------------------------------------------------------
md(r"""
## Summary
We updated the estimates of the trading method every trading day, backtested strategies on the real market, and stress-tested them on synthetic markets with the five gates.

> __Key Takeaways:__
>
> * __Updated estimates:__ We updated the single index model of each stock every trading day with exponentially weighted least squares, starting from the fixed fit. The preference weights and the market hedge used the updated estimates. Across the menu, updating the estimates added wealth in fewer than half of the backtests.
> * __Backtests and triggers:__ We ran strategies on the real market one trading day at a time, and each decision used only the data through that day. A new decision started when one of six triggers fired, such as 21 trading days passing or a market turn. Most strategies on the menu had a lower Sharpe ratio than `SPY`.
> * __Stress tests and the five gates:__ We ran strategies on 200 synthetic markets and tested their scores against five gates. Few strategies passed the failure-rate gate. Even `SPY` ended below the starting wealth on about a quarter of the markets.

A backtest and a stress test use past and synthetic prices. Next time, we'll trade a stress-tested strategy in a paper account at live market prices.

___
""")

md(r"""
## Disclaimer and Risks
__This content is offered solely for training and informational purposes__. No offer or solicitation to buy or sell securities or derivative products or any investment or trading advice or strategy is made, given, or endorsed by the teaching team.

__Trading involves risk__. Carefully review your financial situation before investing in securities, futures contracts, options, or commodity interests. Past performance, whether actual or indicated by historical tests of strategies, is no guarantee of future performance or success. Trading is generally inappropriate for someone with limited resources, investment or trading experience, or a low-risk tolerance. Only risk capital that is not required for living expenses should be used.

__You are fully responsible for any investment or trading decisions you make__. Such decisions should be based solely on evaluating your financial circumstances, investment or trading objectives, risk tolerance, and liquidity needs.

___
""")

# write the notebook: the markdown sources are lists of lines -
nb_cells = []
for k, s in enumerate(cells):
    lines = s.split("\n")
    # keep the cell ids of the old lecture where a cell takes its place -
    ids = ["e9e4548a", "966e3daa", "9e2da0ba", "l15a-backtest", "l15a-stress", "l15a-practicum", "e9e86daa", "4389a780", "cb4785b3"]
    nb_cells.append({"cell_type": "markdown", "id": ids[k], "metadata": {},
        "source": [l + "\n" for l in lines[:-1]] + [lines[-1]]})
nb = {"cells": nb_cells, "metadata": OLD["metadata"], "nbformat": 4, "nbformat_minor": 5}
json.dump(nb, open(OUT, "w"), indent=1, ensure_ascii=False)
open(OUT, "a").write("\n")
print("wrote", OUT, len(nb_cells), "cells")
