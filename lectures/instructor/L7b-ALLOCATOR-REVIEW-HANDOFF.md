# L7b Utility Allocator example — polish round record

Notebook: [CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb](../week-7/L7b/CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb)

On October 5, 2026, the instructor asked for a voice, polish, and organization pass
if the notebook scored below 9/10. It opened at 8.0, so the pass was applied
in one round, as in the September 30 estimation-risk round 2. The baseline is
HEAD (`cef7f2c`, the file was clean). Nothing is committed, and the instructor
has not yet reviewed the result. Rendered before/after previews, with code and
outputs, are in `build/notebook-previews/L7b-allocator-2026-10-05/` (gitignored).

## Scores

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 8.5 | 9.2 |
| Organization and sequencing | 8.0 | 9.0 |
| Narrative and interpretation | 7.3 | 9.0 |
| Presentation | 8.0 | 8.8 |
| Density and pacing | 8.5 | 8.5 |
| **Overall** | **8.0** | **9.0** |

Prose went from 1,611 to 1,876 words (+265), counting from the title through
the Summary and excluding display math and link targets. Task 1 fell by 40
words. Task 3 had no readings before the round and carries most of the growth.

## Opening assessment (8.0)

- **Correctness:** cell 38 said CES share counts follow (γ_i/S_i)^η on the
  whole preferred set, which is false at η = 5, where AAPL and MSFT sit at the
  floor (item 5 of the October 3 Codex list in
  [the L7b lecture record](L7b-LECTURE-REVIEW-HANDOFF.md)). The Cobb–Douglas
  price-independence sentence lacked the no-binding-floor condition. The
  `n_min` comment still said "floor for non-preferred assets". `R²` and `S₀`
  were computed and never used. Takeaway 3 had three sentences.
- **Organization:** Task 1 built the SIM mean and covariance for Task 3 only.
  `S₀` belonged to a decision date that is never allocated. The market-on-close
  sentence sat two cells from the prices it describes. Cell 35 had two `let`
  blocks. The 60-day scan and the choice of t⋆ shared one cell.
- **Interpretation:** the 60-day table (basket 0 → 4 → 13 → 0 in four days)
  had no reading, and Task 3 had none: the L7a comparison, the CES tables, and
  the sweep figure, whose curves turn back below η ≈ 0.4.
- **Presentation:** report and plot cells had no stage comments, several
  statements per line, `println` source lines up to 359 characters, and no
  solver-status checks.

## Changes

1. **Task titles** are actions, as in the CAL example: "Compute the Market
   Inputs", "Compute the Preference Weights and Choose the Basket", "Split the
   Budget with Cobb–Douglas and CES Utility".
2. **Task 1:** pulls only α̂ and β̂ (R² dropped from the code and the Data
   prose). The `S₀` cell became a date-alignment check with the same printed
   line. The SIM inputs moved to Task 3, where they are used. The
   "That swing lets the sign..." sentence was cut, and `compute_ema` is linked.
3. **Task 2:** the scan and the allocation-date choice are separate cells. The
   scan table shows days 1–10 and every tenth day to 60, and prints the 2025
   counts: empty on 57 of 250 days, all 13 firms on 152, partial on 41. A new
   reading says the basket is usually all or nothing, because the thresholds lie
   close together while the recent market growth swings by about one per year.
   The market-on-close sentence now sits where `S_star` is set. "the sign
   belongs to" became "the sign depends only on".
4. **Task 3:** "When no preferred floor binds" qualifies the Cobb–Douglas
   price-independence sentence. The CES proportionality sentence now covers
   "the preferred firms above their floors" and names γ_i/S_i as the bang for the
   buck (the lecture's term). The L7a cell is split into a calculation cell
   (SIM inputs, GMV, tangent, with `LOCALLY_SOLVED` checks) and a report cell.
   New readings: Cobb–Douglas and the tangent portfolio put nearly all of the
   budget in the same four firms, led by NVDA, with close Sharpe ratios (1.298
   and 1.324). GMV puts 64% in JNJ, the firm with the smallest beta and SIM variance.
   For CES, a larger η moves the budget to NVDA, and at η = 5 the other
   preferred firms sit at or near their floors. A bold question explains why the
   sweep curves turn back. Equal share counts favor the most expensive
   share, so MSFT has the largest weight at the left end of the grid (η = 0.3).
   Instructor correction after the first previews: the CES cell printed the
   weights table and the summary table back to back. They are now two cells, with
   the η reading and the effective-number definition between them, and a
   sentence on the summary before the figure. The summary's duplicate
   "Cobb–Douglas" row became the label "η = 1 (Cobb–Douglas)".
5. **Summary:** Takeaway 2 reports the comparison ("chose the same four firms as
   the L7a tangent portfolio"). Takeaway 3 is two sentences.
6. **Code:** stage comments in every report and plot cell, one statement per
   line, long `println` calls split across arguments, `n_min` and `g_f` comments
   corrected. Plot styling is unchanged.

## Checks

- Executed from its folder with nbconvert (`julia-1.12`), no errors, 24 s.
- Every text output matches HEAD except the intended scan-table rows, the
  new 2025 count line, and the CES summary table (one row fewer, relabeled) (the old line ended with "empty on 26 days" over 60 days).
  The L7a weight table and Sharpe lines match. All three figures are
  pixel-identical to HEAD.
- No cell prints two tables, and no table or figure follows another output
  without markdown between them (scripted sweep).
- `nbformat.validate` passes. All changed markdown renders through VS Code's KaTeX
  with no errors.
- Supporting numbers computed separately: CES at η = 0.3 has MSFT as the
  largest weight (0.338), and at η = 0.4 NVDA (0.302). At η = 5, AAPL and
  MSFT hold exactly 0.01 shares and AMD 0.0159. SIM total variance is lowest for
  JNJ (5.96, then MSFT 11.7 and AAPL 13.9).
- The lecture's example description and its sentence about the empty basket on
  the first trading day still hold. No lecture or deck edits.

## Codex check (final version)

Codex parsed the notebook and stored outputs, read the SIM archive with h5py,
and scored it 9.1/10. Every numeric claim checked out, including the 57/152/41
basket counts, the four-firm overlap (98.9% of Cobb–Douglas wealth), the
1.298/1.324 Sharpe ratios, JNJ's smallest beta (0.540) and SIM variance (5.958),
the η = 5 floors, and MSFT leading the sweep at η = 0.3. Applied afterward:
`t_star` is described as a trading-day index, not a date; "preferred firms
that stay above their floors" (split into two sentences), so it is not read as
share counts net of the floor; the summary reading says η runs from 0.5 to 5;
three comment lines shortened. Declined: rewording the standard disclaimer,
dropping the window symbols from the 29-word signal sentence in Task 1, and
reflowing three long lines unchanged from HEAD (L7a has longer ones).

## Not changed

- Setup, data loading, and the ticker list. On October 7 the instructor made the
  ticker cell read the L6b client list when it is present. The checks and follow-up
  edits are in the October 7 section of `L7b-LECTURE-REVIEW-HANDOFF.md`.
- The figure styles, including the trading-day-index x axes in the Task 1
  figure.
- The `cd` variable name, which shadows `Base.cd` but works.

## October 8 round, after the allocator rework

The October 8 rework (see the October 8 section of
[the week-7 handoff](WEEK-7-REFACTOR-HANDOFF.md)) rebuilt the example, so the
record above describes a superseded notebook. The same day the instructor asked
for a polish, voice, and organization pass if the reworked example scored
below 9. It opened at 8.3 (Codex 7.9), so the pass was applied in one round,
prose only: the 22 code cells and their outputs are byte-identical to the
baseline, so the notebook was not re-executed. The baseline is the uncommitted
rework (HEAD `d664fca`), SHA-256
`27ac0e0329db014c23a75f5ded72ae44a03182d2e7f3ef154c69461fc772f76b`; the edited
notebook is
`8b11d7108008ede9d3279db31dd421df467b79d5422a6d2aa949ad8d2ccbccce`. Before and
after notebooks, the proposal file, and rendered cell previews are in
`build/notebook-previews/L7b-allocator-polish-2026-10-08/` (gitignored). The
instructor has not yet reviewed the result.

### Scores

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 9.0 | 9.3 |
| Organization | 7.9 | 9.1 |
| Narrative flow and voice | 8.3 | 9.0 |
| Presentation | 8.6 | 9.0 |
| Density and pacing | 7.8 | 8.8 |
| **Overall** | **8.3** | **9.0** |

Codex scored the baseline 7.9, rejected the first draft of the edits as too
light (8.0), and scored the applied second draft 8.4. Its post-audit items
were then applied (below) without a third Codex run. The final scores above
are mine; Codex's 8.4 predates those fixes.

### What the Codex pre-review caught

- "Every path pays the same costs" (Task 3) was false: the printed costs are
  10.50, 2.32, 1.77, and 0.50 USD. The paths pay the same cost rate.
- "The GMV portfolio ... spreads the budget across them" (Task 2 reading) was
  false: the printed largest weight is 64.3% in JNJ, the most concentrated of
  the three. The reading now says minimizing variance can concentrate the
  allocation.
- "The expected growth rates and betas rank the portfolios by how much market
  risk they take" conflated alpha with market exposure. Now the beta measures
  exposure and the largest weight measures concentration.
- My first draft made the amplitude of the recent growth follow from the
  half-life. The sentence now states the half-life and rests on the printed
  2025 ranges of the one-year and 10-day windows.
- "The low-beta firms move the other way" is plural for one firm (JNJ, beta
  0.54). Now "a firm with beta below one".

Declined: cutting "not what to expect next year" as a denial (students do read
a backtest as a forecast); replacing the lecture's bearish/bullish wording
(the example now carries the lecture box's wording with the EMA
parenthetical); rewording the Constants lead-in (it matches the L7a sibling);
renaming the Data and Constants headings (standard setup).

### Changes

1. **Title cell.** Objective 2 no longer lists the package check. "Trades at
   the close of each 2025 trading day" became "on its rebalance days", here and
   in the price-matrix lead-in, since the monthly run trades twelve times.
2. **Task 1.** The market-inputs cell lost the EMA-weight formula (the lecture
   defines it) and the unprinted "few tenths per year over a quarter" claim;
   the window paragraph rests on the printed ranges; the lag paragraph is
   tighter (316 to 280 words). The instructor then called the cell "WAY TOO
   DENSE", so it was cut to 191 words: two definitions, the sign convention,
   the window choice in three short sentences, and the lag in one. The
   joined-series, warm-up, and perturbation details live in the code comments.
   The instructor then asked for three bullets on the crossover cases (short EMA
   above, equal to, below the long EMA: the sign of $\xi_t$, the regime, and
   why), added here and mirrored in the lecture's market-inputs box and in the
   deck, where "The Market Inputs" frame became two frames, "The Market-State
   Signal" (display, three cases) and "The Recent Market Growth" (gain, growth
   EMA, lag, example note). Rebuilt: 25 pages, 0 overfull.
   Also at the instructor's request, three `println` lists became tables in
   the notebook's compact `pretty_table` format: each firm's threshold and
   days non-preferred (sorted, highest threshold first), the three portfolios'
   SIM statistics, and the adaptive runs' rebalances, turnover, cost, and final
   cash. The notebook was re-executed on the default firms from a scratch copy
   without `data/my-tickers.csv` (the client file stayed in place): no errors,
   only those three cells' text output changed, every number the same. A
   second run with the client file (30 firms) also ran clean; its outputs were
   not kept. The code lead-ins and the Task 1 summary line still print single
   lines.
   The instructor then found the Task 1 figure confusing ("lagged one day" in
   the legends, and what the bottom panel shows). The legends lost the lag
   labels, each panel has a title (the middle one states the sign convention),
   the bottom panel draws one dotted line per firm threshold inside the
   shaded range, and the lead-in reads the panels: the signal is bearish while
   the short EMA sits below the long one, and the basket loses firms from the
   top of the band down as the recent growth falls through it. Re-executed on
   the default firms the same way; only the figure cell's output changed.
   The instructor still found the bottom panel unclear and asked whether it was
   needed. The threshold lines and band were removed: the panel now shows only
   the second input, the one-year EMA of SPY's daily growth rates, with the
   training mean for reference, and the lead-in says Task 2 is where the curve
   meets the thresholds (the basket-count plot there already shows the result).
   Re-executed the same way; only the figure cell changed. The legend then
   gained the growth window (`L = $(L_growth)`) so it tracks the constant.
   Further instructor requests the same day, all prose only: the preference
   weight is read in two bullets (sign through $\tilde{g}_{i,t}/\beta_i^{\xi_t}$
   with the tanh sign reminder; magnitude with the three $\xi_t$ ranges), mirrored
   in the lecture; and every markdown block over about 70 words (the figure
   lead-in, the table reading, the L7a comparison, the weights reading, the
   Task 3 engine and targets, the scorecard reading) became a lead sentence,
   labeled bullets, and a close, with the takeaways trimmed to two sentences
   each. The lecture's window paragraph got the same treatment.
3. **Task 2.** Two new H3s in the siblings' form, "Compute the preference
   weights" and "How does the basket change through the year?" (a new cell
   split from the table reading). The consecutive "As in the lecture" openers
   became "Recall from the lecture" and one "as in the lecture". The basket is
   "the set that receives the budget left after the share floors". The
   Cobb–Douglas heading is "Allocate the budget with Cobb–Douglas utility",
   its lead-in states the no-binding-floor condition, and $\mathcal{A}^{-}$ is
   defined. The L7a comparison states the ray argument with its bound
   condition and compresses the assert catalogue to one sentence; its two
   type links and the scorecard link now use the "using [the ... type](...)"
   form of the L7a examples. The clause semicolon is gone. The weights reading
   has the GMV correction.
4. **Task 3.** The 436-word intro is now "Set up the engine" and "Choose the
   targets and schedules", with the fixed-versus-adaptive paragraph
   compressed, "same costs" corrected to "same cost rate", and the post-cost
   scaling conditioned on a positive cost rate. The accounting-check lead-in
   no longer repeats the self-financing definition and defines cost as the
   rate times the gross notional. "Wealth through the year" is "Compare the
   wealth paths"; its lead-in says buy-and-hold wealth moves only with prices
   after the first day's purchase and its cost. The wealth-figure reading is a
   lead sentence, three labeled bullets (Holdings, Schedules, Comparisons),
   and the results-may-differ closer, the shape of the L6a minimum-variance
   example; a basket exit is described as a cut to the floor. The scorecard
   lead-in dropped the repeated Sharpe contrast; the scorecard reading dropped
   the restated column definitions and says what the drawdown column measures.
5. **Summary.** Takeaway 3 says the adaptive runs cut the firms below their
   thresholds to the floor on their rebalance days and split the rest among
   the preferred firms.

Prose went from 3,497 to 3,445 words. Length was not the lever; the order,
the headings, the bulleted reading, and the factual corrections were.

### Checks

- Code cells and outputs identical to the baseline (Python comparison of the
  22 code cells, after each round).
- `nbformat.validate` passes; the new cell has a unique id.
- Rendered with nbconvert and Chromium after each round: no MathJax errors,
  no horizontal overflow at 1100 px, PNGs per markdown cell.
- Codex pre-review of the proposals and post-audit of the applied notebook
  (session scratchpad `codex/prereview-out.md` and `codex/postaudit-out.md`).
  The post-audit confirmed the code cells identical, the objectives and
  takeaways at three, the task openers, the rules, and no cross-week links.
- The engine's turnover is half the absolute weight changes including the
  cash leg (`code/src/AdaptivePortfolio.jl`), so the "fraction of wealth
  moved" sentence stands; Codex's request for a more technical definition was
  not taken.
- The lecture's Examples cell still describes the example accurately (it
  omits the CES run and the scorecard, which is incomplete, not false). No
  lecture or deck edits.

## October 8, later: tangent-continuation algorithm notebook

Trigger: the instructor asked whether the allocator example's tangent bullet
used the continuation of the L7a lecture. It did not. The October 6 L7a lecture
edit had replaced the boxed common-risky-direction result SIM-3 with the
continuation pseudocode, while the L7a tangent example and both L7b examples
still cite SIM-3 and find the tangent portfolio by one solve of SIM-2 rescaled
to sum to one. The instructor chose a separate algorithm notebook on the CHEME
5800 L6c Jacobi pattern, placed in L7b where the comparison runs, and then
asked for a contrast section against the version shown in lecture.

### Files

- New: `lectures/week-7/L7b/CHEME-5660-L7b-Algorithm-TangentContinuation-Fall-2026.ipynb`,
  markdown only, five cells: title with three objectives; "One risky
  direction" (SIM-2 restated, SIM-3 as a lite theorem with setup, result, and
  derivation sketch, the one-solve and max-Sharpe consequences, the cap
  threshold); "Algorithm and convergence" (the instructor's October 6
  pseudocode with the cap rule added to steps 2 and 3, why it works, why the
  caps are checked, what the continuation adds); "How does this differ from the
  version shown in lecture?" (the added rule, the counterexample, and the
  SIM-3 secant jump as the faster variant with the single solve as its limit);
  Summary with three takeaways.
- L7a lecture cell 9: SIM-3 restored verbatim as the Solution paragraph of the
  SIM-2 box; the October 6 pseudocode stays in place. An earlier state of this
  round had replaced the pseudocode with a short paragraph and a link into
  L7b; the instructor objected on both counts (he had not asked for an L7a
  deletion, and L7a must not link forward into L7b), so the pseudocode was
  restored from HEAD and the link removed. The L7a deck `.tex` is identical to
  HEAD.
- L7b lecture cell 2 (Concept Review): one sentence and the link.
- Allocator example: cell 33 tangent bullet cites SIM-3 and the algorithm;
  new cells 35 (lead-in) and 36 (Julia) run the continuation and assert it
  matches the single-solve `w_T`. Default firms: 12 solves, tangent target
  0.3942 versus E[g_T] 0.3944, largest weight difference 4.8e-8. Codex ran the
  client list too: 16 solves, 3.4e-7.
- Decks: L7a deck unchanged; L7b Concept Review frame gained an Algorithm
  slidenote. Both rebuilt,
  0 overfull, 20 and 25 pages.
- Handoffs: AGENTS.md bullet, WEEK-7 handoff paragraph, and resolution notes on
  the three stale "SIM-3 is gone" lines in the L7a lecture, L7b lecture, and
  week-7 records.

### Codex rounds

| Round | Overall | Headline |
|---|---|---|
| Pre-review | 7.8 | Blocker: a sweep step can overshoot onto a capped allocation with a risky fraction of one that is not the tangent fund (two-asset counterexample, e = (1, −0.1), unit variances, correlation −0.9, increment = whole interval); the tolerance test alone accepts it. |
| Post-audit | 8.3 | Blocker: with the cap guard only in step 2, a single-asset fund returns a weight a hair below one, the guard rejects it, the lending branch re-solves the same target until the limit. |

Fixes: the cap test is applied in step 3 as well as step 2 (a cap-rejected
allocation becomes the upper end of the bracket), in the pseudocode and the
Julia cell; "bound on the residual halves" instead of "residual halves";
"every uncapped iterate"; the derivation sketch drops the caps and restores
them at the end; the Sharpe comparison restricted to positive excess growth
with the nonpositive case stated; the ray qualification added to the linearity
and "hold T at θ = 1" statements and takeaway 2; the solve count split into the
sweep cost and the logarithmic bisection phase, with the example reporting the
total; the two-solve secant claim carries the single-asset exception; the
counterexample states its covariance. Combined Julia assignments split.

Verified after the fixes with a standalone script against the package
(`build/exec-l7b-default/edge/edge.jl`): single asset converges with both
increments (17 and 11 solves, w_T = [1.0]); the counterexample converges to
(0.5322, 0.4678), the analytic 91/171 and 80/171, with both increments; a
three-asset diagonal case matches Σ⁻¹e normalized. The allocator example was
re-executed on the default firms after each code change (scratch copy without
`data/my-tickers.csv`); only cell 36's output differs from the previous
notebook.

Declined: Codex's nit on semicolons inside the pseudocode branches (the
instructor's October 6 text, kept verbatim apart from the cap rule). The
contrast section was added after the post-audit and has not had a Codex pass.

### Open

- Not released: the new notebook and the lecture, example, and deck edits need
  a week-07.2 fix release.
- The instructor plans to reuse this material in a new L8d, so the algorithm
  notebook carries no cross-week links: its only link is to the L7b allocator
  example. Prose still names L7a in cells 0, 1, and 3 (the lecture that showed
  the pseudocode, and the examples that use the single solve); reword those
  when the material moves.

## 2026-10-08 (evening): re-rating after the Task 3 prose pass

Claude rating: 8/10. Codex rating (default model, effort high, read-only): 7/10. Codex
output saved in the session scratchpad as `codex-rating-output.md`; every numerical claim
below was re-verified by executing a scratch copy of the notebook with a check cell.

**Confirmed errors (all four FIXED the same evening, plus the minor points below; notebook re-executed):**

1. Constants cell comment on `η_CES`: "below one spreads the budget more evenly than
   Cobb–Douglas" is wrong in dollars. CES at η = 0.5 moves toward equal *share counts*
   (0.084–0.418 vs 0.039–0.966 for CD), which puts more dollars in expensive firms: largest
   day-1 dollar weight 10.3 % (MTD) vs 6.4 % (MSFT) for CD.
2. Bar-chart and wealth-plot paragraphs: "GMV holds the five firms with betas below one".
   Those five hold 75.8 %; ITW 6.3 %, HD 5.4 %, L 4.5 % are also held.
3. Wealth-plot paragraph: "the same until just after the SPY low". Daily and monthly differ
   by ≤ 4.4 USD through day 60; the basket empties on days 65–67, 69, 73–76 (SPY low = 66),
   and daily is ahead at the low (901 vs 882) because it was already ~94 % cash.
4. Constants cell comment on `n_min`: "at least one hundredth of a share" — the engine
   sizes to the post-cost budget, so executed floors are 0.00999 shares.

**Codex points judged minor / scoped already:** EMA-cross-as-reversal wording (Task 1);
"costs explain only 8 USD" (displayed cost difference is 7.57; phrase as a fact, not an
attribution); elasticity claims are already scoped to "this year" / "this path"; the 0.46
expected Sharpe should say "first-day" weights; restore one sentence on the execution
idealization (orders sized with the close they fill at).
