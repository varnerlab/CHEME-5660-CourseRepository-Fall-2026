# L12b teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Thursday, November 12, 2026. Deck: 21 pages (title and 20 frames). Lecture: Why do Markets Crash? Three examples: what one rule does (in lecture, three tasks), the Wolfram rule switch (in lecture, three tasks), and the stylized facts of a Wolfram market's price (review on your own). The 2025
Q-learning section is now an optional advanced notebook. Freeze: Tuesday, November 10. Reworked November 6 on the L11b pattern: one concept per section, boxed
results, and both algorithms (market step and dealer clearing, after Algorithms S1 and S2 of the paper) in the lecture.

## The one result

Rules 19280 and 19286 differ in one table entry, at neighbor sum 1 (three Buy neighbors, one Hold): 19280 buys, 19286 sells. Give 19286 to a fraction f of the traders after a
shared history, and at the larger fractions in the example the market forms a Sell majority and the price falls. The control, which shares the history and never switches, forms no Sell majority. This is an
analogy for real crashes, not an explanation of them.

## What students must know (on the "What You Need to Know" frame and in the notebook box)

- **Core:**
  - a Wolfram rule is a policy: neighbor sum (state) to next intention (action); the two rules differ in one entry
  - a dealer sets the price from the net trade, and a shallow dealer can crash the price with no switch, so we compare every switched market with a no-switch control that shares its history
  - a switch for a fraction of the traders can tip the market toward Sell while the control does not; an analogy, not an explanation
- **For understanding only:** the price formula, the band rule, the two algorithms, the edge conditions, and the Q-learning notebook. Say out loud that students need not reproduce them.

## Timing (75 minutes)

| Minutes | Part |
|--:|:--|
| 0-5 | Objectives, what you need to know; why markets crash (timeline, three episodes) |
| 5-17 | Agent-based markets; Wolfram markets: grid and intentions, the rule number, the dealer, technical traders |
| 17-27 | The two algorithms (walk the market step; the clearing search only in outline); the rule switch and its figure (digit order c = 8..0, table columns c = 0..8; make the 1929 link aloud here) |
| 27-65 | Example: Task 1 live (15 min), Task 2 (13), Task 3 (10) |
| 65-75 | Summary (read the caution aloud); questions |

## Where the results come from

**Example 0 (in lecture, added November 10):** `CHEME-5660-L12b-Example-Wolfram-Rules-Fall-2026.ipynb` runs live in about 1 second. Set `rule` and `rule_to_compare` in the Constants cell and rerun. Task 1 draws the rule table. Task 2 runs the market (5,000 steps, about 2 seconds): the grid settles into a steady mix within about 10 steps, and the price rises from 100 to about 114 USD/share in 50 steps. Task 3 runs Rule 19286, which differs at sum 1: Sell regions cover most of the grid by step 20, and the price falls to about 85 USD/share within 50 steps. The closing line sets up the rule switch (only a fraction of the traders change, partway through). Other rules to show: 0, 9841, 19682 (Buy, Hold, or Sell in every entry). It is not in the timing table above yet; it takes about 5 minutes after the algorithms. Helpers: `run_rule_market` and `plot_rule` in `src/Helper.jl`.

Redesigned November 10: the grid leads, and the example prints no tables. Tasks 1 and 2 run live at L = 64 (about 2 seconds for the switched market and its control, with the grid saved every 5 steps; about 3 seconds for the 20 starting markets at L = 32). Task 3 loads the `sweep` table of the cache built by
`scripts/Compute-L12b-RuleSwitch-Cache.jl` (L = 64, 20 starting markets, final, not provisional). Rerunning it is described in `scripts/README.md`. The `plot_grid` and `run_noisy_rule_switch` helpers are in `src/Helper.jl`, loaded by `Include.jl`; `scripts/Test-Helper.jl` tests them.

Time step and dealer noise (added November 10): the Constants cell sets `Δt = 1/(252*390)` (one minute per step) and `σ_S = 0.20`. The noise added to the log share price in one step has standard deviation `σ_S*sqrt(Δt)`, about 0.064% at the defaults. `σ_S = 0.0` gives the market with no noise. With `Δt = 1/252` (one trading day per step) the noise is 1.26% per step, and the switched price can no longer be told from the control price by eye. The cache uses the defaults, whatever the Constants cell says.

**Example 2 (review on your own):** `CHEME-5660-L12b-Example-Wolfram-StylizedFacts-Fall-2026.ipynb` runs everything live, about 10 seconds in total. Its markets
never switch (`run_baseline` in `src/Helper.jl`). It compares the Wolfram market with SPY and the L12a Farmer–Joshi market. The headline is a model-scope
lesson: the Wolfram price has no fat tails (excess kurtosis 0.016, against 13.768 for SPY) and only weak, short-lived volatility clustering (lag-1 autocorrelation
of |g| 0.035, inside the band by lag 5, against SPY's 0.194 still at lag 20). Price feedback (active edge traders)
damps the lag-1 autocorrelation of g, from 0.336 held to 0.115 active. No edge condition or dealer depth creates fat tails. The Farmer–Joshi numbers differ
from the L12a table because its traders are a different random draw.

## Numbers to say aloud

- Task 1, six grids: one solid Sell region by step 1,300, about half of the grid by step 1,500. At the last step, a band of traders near the edge has not turned to Sell, and the control is still mixed.
- Task 2, f = 0.25, seed 1: Sell majority 402 steps after the switch (about one trading day at one minute per step), Sell fraction levels off near 0.91, share price falls from about 117 to about 84 USD/share (28%). The control price stays between 112 and 119 USD/share.
- Task 2, orders: about 970 Sell orders and 970 Buy orders filled per step before the switch; about 70 of each late in the run, with about 3,400 Sell orders failing per step because the trader has no shares.
- Task 2, 20 starting markets (L = 32): 15 of 20 switched prices end between 85 and 91 USD/share. Every switched price ends 20% to 26% below its own control.
- Task 3, deep dealer, active edge: median fall 6.8% at f = 0.16, 20.4% at f = 0.18, 27.0% at f = 0.20; control 3.3% (the dealer noise). Shallow dealer (`condition_to_visualize = 3`): control 33.0%, switched 39.1% at f = 0.10.
- Over 20 starting markets, the fraction with a Sell majority at f = 0.18 is 0.50 (deep dealer, held edge), 0.70 (deep dealer, active edge), and 0.75 (shallow dealer). It is 0.00 at f = 0.16 with a deep dealer (0.10 with a shallow dealer) and 1.00 from f = 0.20; every control is 0.00 (Task 3, first figure).

## Likely student questions

- **Why does one table entry matter?** Neighbor sum 1 is a buying neighborhood with one hesitant neighbor. Switched traders there sell, neighbors read the Sell, and it spreads.
- **Why the control?** The price can fall with no rule switch at all, most of all with a shallow dealer. The control has the same history, so a difference after the switch is the switch.
- **Why does the shallow-dealer control fall?** A given net order moves a shallow dealer's price a long way, so it falls with no switch (median control fall 0.330). The switched 0.391 at f = 0.10 is only a little above that.
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
- **Notation anchor.** The lecture links `faq/notation.html#L12b`; the anchor does not exist yet, because the course table had another session's uncommitted changes.

## Notation rows to add to the course table

| Symbol | Meaning | First use |
|---|---|---|
| $z_j(t)$ | Intention of trader j at step t: Buy 0, Hold 1, Sell 2 | Wolfram Markets |
| $\partial i$, $c_i(t)$ | Four neighbors of trader i; neighbor sum, 0 to 8 (c_i also a position size in L12a) | Wolfram Markets |
| $a_c$ | Next intention a rule gives at neighbor sum c | Wolfram Markets |
| rule number $\sum_c a_c 3^c$ | Rule table as a base-3 number; 19280 = (222110002)_3, 19286 = (222110022)_3 | Wolfram Markets |
| $f$ | Fraction of interior traders who receive the switch rule | The Rule Switch |
| $P_t$, $x_t$, $Q_{t-1}$ | Dealer price after step t; net shares the dealer sells (positive = net buying); dealer shares before the trade (x_t also a position in L12a) | Wolfram Markets: the dealer |
| $h$ | Dealer depth, initial dealer shares per interior or technical trader (a number of steps in L9b, L10a) | Wolfram Markets: the dealer |
