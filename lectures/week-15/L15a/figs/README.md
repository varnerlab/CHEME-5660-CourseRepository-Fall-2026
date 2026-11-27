# L15a figures

| Figure | Shown in |
|---|---|
| `Fig-L15a-EWLS-JPM` | The Trading Engine (`engine/`), under Fixed and Updated Estimates (width 740). The market sensitivity of `JPM` over 2025 and 2026, with the fixed 2016 to 2024 estimate (1.12, dashed) and the EWLS estimate updated each trading day ($\phi = 2^{-1/63}$, $N_0 = 63$), which ends at 0.73 on November 24, 2026. The example's Task 1 supplies the 476 daily values in the `.tex` file. |
| `Fig-L15a-Gamma-Picks` | The Trading Engine (`engine/`), under The Six Triggers (width 860). A schematic market state, the daily updates (the preference weights at every close, and α and β with updated estimates), and the baskets held between decisions. The figure shows the scheduled trigger and the market state's crossing of zero. |
| `Fig-L15a-Market-Hedge` | The Trading Engine (`engine/`), under The Market Hedge (width 720). The cap $\max(1-\xi_t, -0.5)$ on portfolio beta, with the `SPY` short when the cap falls below zero. |
| `Fig-L15a-BAB-Tilt` | The Trading Engine (`engine/`), under The Utility Basket and Betting Against Beta, before the Signal bullet (width 860). Left: the factor $1/\max(|\beta_i|,\beta_{\text{floor}})^{\xi_t}$ on the expected growth rate for $\xi_t = 1$, $-1$, and $0$, crossing at $\beta_i = 1$. Right: the betting-against-beta weights before the trading limits for eight made-up stocks, from `weigh_bab` in `strategies/weighting/bab.jl`. |
| `Fig-L15a-Backtest-Day` | Backtesting a Strategy in the lecture, under Backtest Algorithm (width 860). The engine fills orders at the open. At the close it values the portfolio, updates the estimates when selected, and checks the six triggers. A trigger starts a decision to pick a basket, weight it within the limits, and queue orders for the next open. |
| `Fig-L15a-Stress-Test` | Stress-Testing a Strategy, after the definition (width 860). A fan of 30 synthetic wealth paths from $W_0$ on the start day (dashed) over one synthetic year (252 trading days), darker red for a path that ends below $W_0$ and light red for the others, and a sideways histogram of the last-day wealth over the markets, with $W_0$ (dashed), the median (solid tick), and the failures below $W_0$ in darker red. The paths are made up: `stress_paths.py` (seed 5660) writes them into `Fig-L15a-Stress-Test-paths.tex`, and `make` reruns it when the script changes. No calendar date appears, because the start day moves with the data. |

The first three figures moved here from `week-14/L14a/figs` on 2026-11-23, with the Updating the Single Index Model section. L14a keeps its own copies of two of them: `Fig-L14a-EWLS-JPM` for its deck, and `Fig-L14a-Gamma-Picks` (copied 2026-11-24) for its "Next time" subsection. On 2026-11-27 the L15a copy of Gamma-Picks took the lecture's labels (basket, decision, updated estimates); the L14a copy keeps the old labels, because L14a is released.

From this folder, `make` builds each figure's PDF (deck), themed SVG (notebook), and PNG (preview) with
XeLaTeX, `pdf2svg`, and `pdftoppm`. Each figure `\input`s `schematic-style.tex`, a copy of the
L13a style, and `theme_svg.py` adds the dark screen palette; an unmapped color fails the build.

The strategy decks draw their own figures in `strategies/slides/figs`, with `make_deck_figures.py`. The deck figure
`Fig-L15a-Deck-Tilt` redraws the left panel of `Fig-L15a-BAB-Tilt` at slide size, without its title. The deck figure
`Fig-L15a-Deck-Sector-Factor` draws the made-up market of `Fig-L15a-Deck-Picks-Global` on a taller scale, with fixed
estimates and with a made-up sector term (seed 5662). The script asserts the basket counts that the deck quotes.

## Alt text: Fig-L15a-Backtest-Day

One time axis with three trading days, day t minus 1, day t, and day t plus 1, each drawn as a bar from its open to its close. A dashed gray arc from the close of day t minus 1 to the open of day t reads: fill yesterday's orders. An arrow rises from the close of day t to a box labeled after the close: compute the wealth W of t, update the estimates, and check the six triggers. A gray arrow to the left of the box reads: no trigger, keep the portfolio. An orange arrow labeled a trigger fires rises to an orange box, make a new decision, with three steps. Step 1 picks a basket with the picking rule. Step 2 weights it with the weighting rule within the trading limits, and within the market sensitivity limit if the hedge is on. Step 3 queues the orders. An arrow from step 3 runs down to the open of day t plus 1, labeled orders fill at the open.

## Alt text: Fig-L15a-Stress-Test

Thin red lines fan out from one point on a vertical dashed line labeled start day. The point is the starting wealth W 0. Each line is the wealth path on one synthetic market from the generator, over one synthetic year of 252 trading days, and the fan widens over the year. At the right edge, a sideways histogram shows the wealth on the last day over the synthetic markets. A dashed horizontal line marks the starting wealth W 0, and a solid tick above it marks the median. The bars below W 0 are a darker red, labeled failures: end below W 0. The lines that end below W 0 have the same darker red, and the other lines and bars are a light red.
