# L12b teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Thursday, November 12, 2026. Deck: 24 pages (title and 23 frames). Lecture: Why do Markets Crash? Four examples: what one rule does (in lecture, three tasks), the Wolfram rule switch (in lecture, three tasks), closed and open markets (in lecture, three tasks), and the stylized facts of a Wolfram market's price (review on your own). The 2025
Q-learning section is now an optional advanced notebook. Freeze: Tuesday, November 10. Reworked November 6 on the L11b pattern: one concept per section, boxed
results, and both algorithms (market step and dealer clearing, after Algorithms S1 and S2 of the paper) in the lecture.

## The one result

Rules 19280 and 19286 differ in one table entry, at neighbor sum 1 (three Buy neighbors, one Hold): 19280 buys, 19286 sells. Give the changed rule to a fraction f of the traders after a
shared history, and the Sell intention spreads from neighbor to neighbor. The price falls until the sellers run out of shares, and then it levels off. The control, which shares the history and never switches, forms no Sell majority. This is an
analogy for real crashes, not an explanation of them.

The rule-switch example starts from a second pair, Rules 19287 and 19341, which differ at neighbor sum 3 (the bubble that pops). The lecture figures, the one-rule example, and the closed and open market example use 19280 and 19286.

## What students must know (on the "What You Need to Know" frame and in the notebook box)

- **Core:**
  - a Wolfram rule is a policy: neighbor sum (state) to next intention (action); the two rules differ in one entry
  - a dealer sets the price from the net trade, and we compare every switched market with a no-switch control that shares its history
  - after the switch the Sell intention can spread from neighbor to neighbor, and the price then falls until the sellers run out of shares; an analogy, not an explanation
- **For understanding only:** the price formula, the band rule, the two algorithms, the edge conditions, and the Q-learning notebook. Say out loud that students need not reproduce them.

## Timing (75 minutes)

| Minutes | Part |
|--:|:--|
| 0-5 | Objectives, what you need to know; why markets crash (timeline, three episodes) |
| 5-17 | Agent-based markets; Wolfram markets: grid and intentions, the rule number, the dealer, technical traders |
| 17-27 | The two algorithms (walk the market step; the clearing search only in outline); the rule switch and its figure (digit order c = 8..0, table columns c = 0..8; make the 1929 link aloud here) |
| 27-65 | Examples: one rule (about 5 min), the rule switch (Tasks 1 to 3), closed and open markets (Tasks 1 to 3). The split of these 38 minutes is not set yet |
| 65-75 | Summary (read the caution aloud); questions |

## Where the results come from

Every example runs live from its Constants cell. No example loads a cache. Helpers are in `src/Helper.jl`, loaded by `Include.jl`; `scripts/Test-Helper.jl` tests them (91 tests).

**One rule (in lecture):** `CHEME-5660-L12b-Example-Wolfram-Rules-Fall-2026.ipynb`, about 20 seconds for the whole notebook. Defaults: `baseline_rule = 19280`, `switch_rule = 19286`, `σ_S = 0.2`. Task 1 draws the rule table. Task 2 runs the market for 5,000 steps. Task 3 runs the second rule from the same start. Other rules to show: 0, 9841, 19682 (Buy, Hold, or Sell in every entry), and the commented bubble case (19287, 19341). Helpers: `run_rule_market` and `plot_rule`.

**Rule switch (in lecture):** `CHEME-5660-L12b-Example-Wolfram-RuleSwitch-Fall-2026.ipynb`, about 40 seconds for the whole notebook. Defaults: `baseline_rule = 19287`, `switch_rule = 19341` (the bubble that pops), `f = 0.25`, `L = 64`, `σ_S = 0.40`, and `first_step_to_plot = 0`, which shows the rise from the starting share price. Task 1 shows the grids and the animation. Task 2 follows the share price, the filled and unfilled orders, and 20 starting markets at `L_small = 32`. Task 3 brings in fresh players (`recovery_rule = 0`, `fresh_fraction = 0.25`, `t_fresh = 2000`). The lecture rules are a commented case in the Constants cell. Helper: `run_noisy_rule_switch`.

**Closed and open markets (in lecture):** `CHEME-5660-L12b-Example-Wolfram-Viewport-Fall-2026.ipynb`, about 35 seconds for the whole notebook. Defaults: 19280 and 19286, `refresh_rate = 0.001`, `contrarian_rule = 377`, `contrarian_fraction = 0.25`, `σ_S = 0.40`. Task 1 compares the closed market with the open market. Task 2 adds contrarian players. Task 3 sweeps the fraction of contrarian players over 10 starting markets at `L_small = 32` (about 15 seconds). Helper: `run_viewport_rule_switch`.

Time step and dealer noise: the three in-lecture examples set `Δt = 1/(252*390)` (one minute per step). The noise added to the log share price in one step has standard deviation `σ_S*sqrt(Δt)`, about 0.064% at `σ_S = 0.2` and 0.128% at `σ_S = 0.40`. `σ_S = 0.0` gives the market with no noise. With `Δt = 1/252` (one trading day per step) the noise at `σ_S = 0.2` is 1.26% per step, and the switched price can no longer be told from the control price by eye.

**Stylized facts (review on your own):** `CHEME-5660-L12b-Example-Wolfram-StylizedFacts-Fall-2026.ipynb` runs everything live, about 25 seconds for the whole notebook. Its markets
never switch (`run_baseline` in `src/Helper.jl`), use one trading day per step, and have no dealer noise; the notebook says so in its Constants section. It compares the Wolfram market with SPY and the Farmer–Joshi market. The headline is a model-scope
lesson: the Wolfram price has no fat tails (excess kurtosis 0.016, against 13.768 for SPY) and only weak, short-lived volatility clustering (lag-1 autocorrelation
of |g| 0.035, inside the band by lag 5, against SPY's 0.194 still at lag 20). Price feedback (active edge traders)
damps the lag-1 autocorrelation of g, from 0.336 held to 0.115 active. No edge condition or dealer depth creates fat tails. The Farmer–Joshi numbers differ
from the Farmer–Joshi example because its traders are a different random draw. The notebook's prose no longer quotes these numbers or the ticker name; they are here to say aloud.

The rule-switch cache (`scripts/Compute-L12b-RuleSwitch-Cache.jl`, six files in `data/`) is no longer loaded by any notebook. It holds the old sweep over the fraction f.

## Numbers to say aloud

All at the default constants, seed 1 unless stated.

- One rule, Task 2 (Rule 19280): the share price rises from 100 to about 114 USD/share in 50 steps and then levels off. The grid keeps about half Buy, a quarter Hold, and a quarter Sell.
- One rule, Task 3 (Rule 19286): Sell covers two thirds of the grid by step 20 and nearly all of it later. The share price falls to about 85 USD/share within 50 steps.
- Rule switch, before the switch: up to about 2,700 Buy orders fill per step in the first steps, and the share price rises from 100 to about 122 USD/share in 100 steps. Then the buyers are out of cash, and fewer than 10 orders fill per step.
- Rule switch, Task 2: a Sell majority forms 235 steps after the switch, and every interior trader intends to sell by step 1,480. The share price falls from about 125 to about 85 USD/share by step 1,500 (its low is 79, 37% below the switch price) and ends at 82. The control ends at 119.
- Rule switch, orders: filled Sell orders peak near 790 per step at step 1,268. Late in the run about 3,850 Sell orders fail per step because the trader has no shares, and about 6 fill.
- Rule switch, 20 starting markets (L = 32): switched prices end between 70 and 96 USD/share, and every one ends 30% below its own control.
- Rule switch, Task 3 (fresh players with Rule 0): the share price jumps from 82 to about 108 USD/share within 50 steps and ends at 114, against 119 for the control. With `recovery_rule = baseline_rule` the fresh players turn to Sell, and the share price ends at 79.
- Closed and open markets, filled orders per step: about 1,920 before the switch. Late in the run: about 130 in the closed market, about 180 in the open market, and about 1,070 in the open market with 25% contrarian players.
- Closed and open markets, last share price (switched against control): closed 85 against 114, open 66 against 173, open with contrarian players 117 against 127. The open control drifts up because new players keep bringing cash.
- Closed and open markets, Task 3 (median of 10 starting markets, share price as a percentage of its control): 44% with no contrarian players, 82% at a fraction of 0.15, 93% at 0.25, and 98% or more from 0.35.

## Likely student questions

- **Why does one table entry matter?** Neighbor sum 1 is a buying neighborhood with one hesitant neighbor. Switched traders there sell, neighbors read the Sell, and it spreads.
- **Why the control?** The price moves with no rule switch at all, from the dealer noise and the traders' own orders. The control has the same history, so a difference after the switch is the switch.
- **Why does the price stop falling?** A trader sells one share per step and started with 10 shares. Once the sellers have no shares, their Sell orders fail, and only the noise moves the price.
- **Why does the open market keep falling?** The new players take over the rule and the intention of the traders they replace, so they sell too. Only a few arrive per step, so few orders fill, but every one of them is a sale.
- **Is this how real crashes work?** No claim is made. It shows how a change in some traders' rule can tip a toy market. The crash episodes at the top motivate the question; the model does not explain them.
- **Why do traders act on intentions they cannot fund?** Intentions are public and neighbors read them without checking holdings. A completed trade needs cash to buy and a share to sell, so an intention can spread when its sender cannot trade.

## Instructor notes

- **1929 link.** The "Back to Real Crashes" section was removed on November 6 (the 1987 and April 2025 readings were too loose). Make the 1929 link aloud at the rule switch: c = 1 is a buying neighborhood with one hesitant neighbor, and the switched entry sells, an analog of confidence turning.
- **Q-learning notebook.** It keeps the 2025 text with small fixes, approved November 6:
  - "In the next section" now reads "In the lecture."
  - The update uses the chosen action $a_t$.
  - Each state-action pair has its own decaying learning rate. The old geometric decay had a finite sum, which breaks the first convergence condition.
  - The `converged` flag resets for each state.
  - Not changed: the convergence check still tests one entry of $Q$.
- **Notation.** The lecture links `faq/notation.html#L12b`, and the course notation page has the L12b table (`code/docs/faq-src/content.json`).
