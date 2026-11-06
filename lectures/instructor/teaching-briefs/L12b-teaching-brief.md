# L12b teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Thursday, November 12, 2026. Deck: 19 pages (title and 18 frames). Lecture: Why do Markets Crash? Two examples: the Wolfram rule switch (in lecture, three tasks) and the stylized facts of a Wolfram market's price (review on your own). The 2025
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

Tasks 2 and 3 load a cache built by `scripts/Compute-L12b-RuleSwitch-Cache.jl` (final, not provisional; the setup cell prints its settings). Rerunning at a larger grid is described
in `scripts/README.md`; every number below would then change. The cache is L = 64 with 20 starting markets (setup cell 4). Task 1 runs live at a default L = 32 (parameter cell 11),
about 2 seconds a run, so its numbers can differ from the cache. The plotting helpers are in `src/Helper.jl`, loaded by `Include.jl`; `scripts/Test-Helper.jl` tests them.

**Example 2 (review on your own):** `CHEME-5660-L12b-Example-Wolfram-StylizedFacts-Fall-2026.ipynb` runs everything live, about 10 seconds in total. Its markets
never switch (`run_baseline` in `src/Helper.jl`). It compares the Wolfram market with SPY and the L12a Farmer–Joshi market. The headline is a model-scope
lesson: the Wolfram price has no fat tails (excess kurtosis 0.016, against 13.768 for SPY) and no volatility clustering. Price feedback (active edge traders)
damps the lag-1 autocorrelation of g, from 0.336 held to 0.115 active. No edge condition or dealer depth creates fat tails. The Farmer–Joshi numbers differ
from the L12a table because its traders are a different random draw.

## Numbers to say aloud

- Rule tables agree except at neighbor sum 1 (Task 1, rule table cell).
- Live run, f = 0.25, seed 1: majority after 681 steps, drawdown 0.237 against 0.013 (Task 1 summary table).
- Seed 1, deep dealer, held edge, f = 0.25: Sell majority after 333 steps, drawdown 0.257 against 0.014 for the control (Task 2 table).
- Shallow dealer, f = 0.10: switched drawdown 0.454 against 0.397 for the control (Task 2 table).
- Over 20 starting markets, the fraction with a Sell majority at f = 0.18 is 0.50 (deep dealer, held edge), 0.65 (deep dealer, active edge), and 0.50 (shallow dealer). It is 0.00 at f = 0.16 with a deep dealer (0.05 with a shallow dealer) and 1.00 from f = 0.20; every control is 0.00 (Task 3 summary table).

## Likely student questions

- **Why does one table entry matter?** Neighbor sum 1 is a buying neighborhood with one hesitant neighbor. Switched traders there sell, neighbors read the Sell, and it spreads.
- **Why the control?** The price can fall with no rule switch at all, most of all with a shallow dealer. The control has the same history, so a difference after the switch is the switch.
- **Why does the shallow-dealer control fall?** A given net order moves a shallow dealer's price a long way, so it falls with no switch (control drawdown 0.397). The switched 0.454 at f = 0.10 is only a little above that.
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
