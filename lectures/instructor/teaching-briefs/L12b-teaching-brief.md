# L12b teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Thursday, November 12, 2026. Deck: 20 frames. Lecture: Why do Markets Crash? One example: the Wolfram rule switch. The 2025 Q-learning section
is now an optional advanced notebook. Freeze: Tuesday, November 10.

## The one result

Rules 19280 and 19286 differ in one table entry, at neighbor sum 1 (three Buy neighbors, one Hold): 19280 buys, 19286 sells. Give 19286 to a fraction f of the traders after a
shared history, and above a threshold fraction the market forms a Sell majority and the price falls. The control, which shares the history and never switches, does not. This is an
analogy for real crashes, not an explanation of them.

## What students must know (on the "What You Need to Know" frame and in the notebook box)

- **Core:**
  - a Wolfram rule is a policy: neighbor sum (state) to next intention (action); the two rules differ in one entry
  - a dealer sets the price from the net trade, so every switched market is read beside a control with the same history
  - a switch for a fraction of the traders can tip the market toward Sell while the control does not; an analogy, not an explanation
- **For understanding only:** the price formula, the band rule, the edge conditions, and the Q-learning notebook. Say out loud that students need not reproduce them.

## Timing (75 minutes)

| Minutes | Part |
|--:|:--|
| 0-5 | Objectives, what you need to know; why markets crash |
| 5-22 | Agents as policies; Wolfram markets; the rule switch and its figure (digit order c = 8..0, table columns c = 0..8) |
| 22-30 | Prices and the dealer: the three points |
| 30-65 | Example: Tasks 1 and 2 (15 min), Task 3 (10), Task 4 live (10) |
| 65-75 | Back to real crashes (make the 1929 link aloud); summary; questions |

## Where the results come from

Tasks 2 and 3 load a cache built by `scripts/Compute-L12b-RuleSwitch-Cache.jl` (final, not provisional; the setup cell prints its settings). Rerunning at a larger grid is described
in `scripts/README.md`; every number below would then change. Task 4 runs live on a smaller grid, about 2 seconds a run, and can differ from the cache.

## Numbers to say aloud

- Rule tables agree except at neighbor sum 1 (Task 1, rule table cell).
- Seed 1, deep dealer, held edge, f = 0.25: Sell majority after 333 steps, drawdown 0.257 against 0.014 for the control (Task 2 table).
- Shallow dealer, f = 0.10: switched drawdown 0.454 against 0.397 for the control (Task 2 table).
- Over 20 starting markets, the fraction with a Sell majority is 0.00 at f = 0.16 (deep dealer), about one half at f = 0.18, and 1.00 from f = 0.20; every control is 0.00 (Task 3 summary table).
- Live run, f = 0.25, seed 1: majority after 681 steps, drawdown 0.237 against 0.013 (Task 4 summary table).

## Likely student questions

- **Why does one table entry matter?** Neighbor sum 1 is a buying neighborhood with one hesitant neighbor, which occurs often. Switched traders there sell, neighbors read the Sell, and it spreads.
- **Why the control?** The dealer alone can move the price. The control has the same history, so a difference after the switch is the switch.
- **Why does the shallow-dealer control fall?** A given net order moves a shallow dealer's price a long way, so it falls with no switch (control drawdown 0.397). The switched 0.454 at f = 0.10 is only a little above that.
- **Is this how real crashes work?** No claim is made. It shows how a change in some traders' rule can tip a toy market; the three episodes are loose readings.
- **Why do traders act on intentions they cannot fund?** Intentions are public and neighbors read them without checking holdings. A completed trade needs cash or a share, so an intention can spread when its sender cannot trade.

## Instructor notes

- **1929 tie-back.** The lecture ties 1929 to the table but not to today. You planned to make that link aloud.
- **Q-learning notebook.** It keeps the verbatim 2025 text, which ends with "In the next section, we use pre-computed policies...". That sentence dangles in a standalone notebook.
- **Notation anchor.** The lecture links `faq/notation.html#L12b`; the anchor does not exist yet, because the course table had another session's uncommitted changes.

## Notation rows to add to the course table

| Symbol | Meaning | First use |
|---|---|---|
| $z_j(t)$ | Intention of trader j at step t: Buy 0, Hold 1, Sell 2 | Wolfram Markets |
| $\partial i$, $c_i(t)$ | Four neighbors of trader i; neighbor sum, 0 to 8 (c_i also a position size in L12a) | Wolfram Markets |
| $a_c$ | Next intention a rule gives at neighbor sum c | Wolfram Markets |
| rule number $\sum_c a_c 3^c$ | Rule table as a base-3 number; 19280 = (222110002)_3, 19286 = (222110022)_3 | Wolfram Markets |
| $f$ | Fraction of interior traders who receive the switch rule | The Rule Switch |
| $P_t$, $x_t$, $Q_{t-1}$ | Dealer price after step t; net shares the dealer sells (positive = net buying); dealer shares before the trade (x_t also a position in L12a) | Prices and the Dealer |
| $h$ | Dealer depth, initial dealer shares per trader (a number of steps in L9b, L10a) | Prices and the Dealer |
