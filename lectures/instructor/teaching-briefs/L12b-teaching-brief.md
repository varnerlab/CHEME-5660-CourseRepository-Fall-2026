# L12b teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Thursday, November 12, 2026. Deck: 20 frames. Lecture: Why do Markets Crash? One example: the Wolfram rule switch. The 2025 Q-learning section
is now an optional advanced notebook. Freeze: Tuesday, November 10.

## The one result

Two Wolfram rules, 19280 and 19286, differ in one table entry, at neighbor sum 1 (three Buy neighbors and one Hold neighbor): 19280 buys, 19286 sells.
Give 19286 to a fraction f of the traders after a shared history, and above a threshold fraction the market forms a Sell majority and the price falls. The control, which shares
the history and never switches, does not. It is an analogy for real crashes, not an explanation of them.

## What students must know (on the "What You Need to Know" frame and in the notebook box)

- **Core:**
  - a Wolfram rule is a policy: neighbor sum (state) to next intention (action); the two rules differ in one entry
  - a dealer sets the price from the net trade, so every switched market is read beside a control with the same history
  - a switch for a fraction of the traders can tip the market toward Sell while the control does not; an analogy, not an explanation
- **For understanding only:** the price formula, the band rule of the edge traders, the held, active, and random edge conditions, and the Q-learning notebook. Say out loud that
  students need not reproduce them.

## Timing (75 minutes)

| Minutes | Part |
|--:|:--|
| 0-5 | Objectives, what you need to know; why markets crash, the three episodes |
| 5-15 | Agents as policies; Wolfram markets: neighbor sum, rule numbers, one step |
| 15-22 | The rule switch and the figure (digit order c = 8..0 against table columns c = 0..8) |
| 22-30 | Prices and the dealer: the three points |
| 30-65 | Example: Tasks 1 and 2 (about 15 min), Task 3 (about 10), Task 4 live (about 10) |
| 65-72 | Back to real crashes (say the 1929 link aloud, see below); summary |
| 72-75 | Questions; point to the optional Q-learning notebook |

## Where the results come from

- **Cached (Tasks 2 and 3):** `scripts/Compute-L12b-RuleSwitch-Cache.jl` writes `data/L12b-RuleSwitch-Cache.jld2`. The cache is final (provisional = false, Task setup table):
  L = 64, 20 starting markets, f in 0.10, 0.14, 0.16, 0.18, 0.20, 0.25, 1000 steps before and 3000 after the switch. It was run on 2026-11-06 in about a minute on 10 threads. To rerun at a
  larger grid, edit `L_FULL` and run the script from the repo root (`scripts/README.md`); the notebook then prints the new settings, but every number below changes.
- **Live (Task 4):** L = 32, f = 0.25, seed 1, about 2 seconds a run. These runs are on a smaller grid and can differ from the cache.

## Numbers to point at

All from the example's executed outputs.

**Task 1, rule tables:** the tables agree at every neighbor sum except 1.

**Task 2, headline pairs (seed 1; sell majority table):**

| Condition | f | Sell majority | Steps to majority | Drawdown | Control drawdown |
|:--|--:|:-:|--:|--:|--:|
| deep dealer, held edge | 0.10 | no | | 0.032 | 0.014 |
| deep dealer, held edge | 0.25 | yes | 333 | 0.257 | 0.014 |
| deep dealer, active edge | 0.25 | yes | 245 | 0.256 | 0.008 |
| shallow dealer, active edge | 0.10 | no | | 0.454 | 0.397 |
| shallow dealer, active edge | 0.25 | yes | 277 | 0.996 | 0.397 |

**Task 3, 20 starting markets (summary table):** the fraction with a Sell majority is 0.00 at f = 0.10, 0.14 in all three conditions, 0.00 at 0.16 for both deep-dealer conditions
(0.05 for the shallow dealer), 0.50 / 0.65 / 0.50 at f = 0.18 (held / active / shallow), and 1.00 from f = 0.20 on. Controls: 0.00 in every row. Median control drawdown: 0.012 (held),
0.008 (active), 0.333 (shallow dealer).

**Task 4, live (L = 32, f = 0.25, seed 1, active edge):** Sell majority after 681 steps, drawdown 0.237 against 0.013 for the control. Across seeds 1 to 5 the steps to a majority range
from 443 to 2624; seed 5 (2624 steps, final Sell fraction 0.495) crossed late and barely.

## Where students will likely get stuck

- **Why does one table entry matter?** The entry is at neighbor sum 1, which a buying neighborhood with one hesitant neighbor reaches often. Switched traders there sell instead of buy,
  their neighbors read the Sell, and it spreads. The tables agree everywhere else (Task 1).
- **Why the control?** The dealer alone can move the price. The control has the same history, so a difference after the switch is the switch. Ask them for the evidence: the controls in
  Task 3 never form a Sell majority.
- **Why does the shallow-dealer control fall?** With a shallow dealer, a given net order moves the price a long way, so it falls with no switch (control drawdown 0.397 in the pair, median
  0.333 over the starting markets). The switched drawdown of 0.454 at f = 0.10 is only a little above that, so it cannot be assigned to the switch. At f = 0.25 it is 0.996.
- **Is this how real crashes work?** No claim is made. It is a toy that shows how a change in some traders' rule can tip a market. 1929, 1987, and April 2025 are loose readings. A simulation
  does not show that heterogeneity alone causes real crashes; update order, network structure, boundary rules, calibration, and common shocks also matter (Summary).
- **Why do traders act on intentions they cannot fund?** Buy and Sell are public intentions that neighbors read without checking holdings. A completed trade needs cash or a share, so
  an intention can spread even when its sender cannot trade. The paper studies the variant where holdings are visible.

## Instructor notes

- **1929 tie-back.** The lecture's 1929 bullet ties to the table (buying neighborhood, one hesitant neighbor) but does not link it to today. You planned to make that link aloud.
- **Q-learning notebook.** The advanced notebook keeps the verbatim 2025 text, which ends with "In the next section, we use pre-computed policies...". That sentence dangles in a standalone
  notebook.
- **Notation anchor.** The lecture links `faq/notation.html#L12b`; the anchor does not exist yet. The course table could not be edited while another session had uncommitted changes.

## Notation rows to add to the course table

| Symbol | Meaning | First use |
|---|---|---|
| $z_j(t)$ | Intention of trader j at step t: Buy 0, Hold 1, Sell 2 | Wolfram Markets |
| $\partial i$, $c_i(t)$ | Four neighbors of trader i; neighbor sum, the sum of their intentions, 0 to 8 (c_i also a position size in L12a) | Wolfram Markets |
| $a_c$ | Next intention a rule gives at neighbor sum c (one table entry) | Wolfram Markets |
| rule number $\sum_c a_c 3^c$ | Rule table as a base-3 number; Rule 19280 = (222110002)_3, Rule 19286 = (222110022)_3 | Wolfram Markets |
| $f$ | Fraction of interior traders who receive the switch rule | The Rule Switch |
| $P_t$, $x_t$, $Q_{t-1}$ | Dealer price after step t; net shares the dealer sells to the traders (positive = net buying); dealer shares before the trade (x_t also a position in L12a) | Prices and the Dealer |
| $h$ | Dealer depth, initial dealer shares per trader (h is a number of steps in L9b and L10a) | Prices and the Dealer |

## In-class discussion prompts

- Which table entry would you change to make a market calmer, and what would you expect the control to show?
- Why is a Sell majority at f = 0.18 a coin flip in the held condition (0.50) when f = 0.16 gives none?
