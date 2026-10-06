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

- Setup, data loading, and the ticker list (the allocator still uses the
  thirteen default firms, as the lecture's Examples section says).
- The figure styles, including the trading-day-index x axes in the Task 1
  figure.
- The `cd` variable name, which shadows `Base.cd` but works.
