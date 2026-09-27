# L6a minimum-variance data example — notebook polish

**Status, September 26, 2026: marked reviewed and complete by the instructor.**
The only edit after the opening assessment added the shorts-allowed GMV
portfolio to the Task 3 out-of-sample comparison (see the section at the end).
The density and tightening suggestions below were not taken up. No proposals
remain pending. Do not restart the review unless the instructor asks for another
round.

September 24, 2026. **Opening assessment complete; example unchanged.**
The instructor marked the L6a lecture reviewed and requested moving to this
example. The lecture review remains closed. This is a new review of the relocated
and narrowed L6a example under the September 24 voice/density guidance; the older
L5b example's completed review remains a record of its archived snapshot.

Notebook: [Data-driven minimum-variance portfolios](../week-6/L6a/CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb).

Initial SHA-256:
`dac11691669dfca5203c2a750bcc091bd27f7be049d6021a20399e0a38c3dce3`

## Initial assessment

| Dimension | Initial |
| --- | ---: |
| Technical correctness and agreement | 9.0 |
| Organization and sequence | 8.8 |
| Narrative and interpretation | 8.4 |
| Presentation | 8.8 |
| Cognitive density and pacing | 8.0 |
| Overall editorial judgment | 8.6 |

Strengths: the three tasks connect estimated inputs, GMV/frontier calculations,
and a separate year of buy-and-hold evaluation. Code comments explain units,
linear solves, solver fields, and fixed shares. All four saved figures are clear,
with readable axes/legends, visible GMV markers, and aligned output interpretation.
The long-only growth floor and short-allowed equality target are distinguished.
The wealth-versus-NPV explanation is useful and should be preserved.

The main concern is cumulative prose density. The current example has about 2,996
prose words excluding math/disclaimer, versus 1,537 in the 2025 reference, but it
also adds substantial material (closed-form GMV/frontier comparisons and the
separate-year evaluation). This is not a word-count target. Task 1 alone has about
1,270 prose words. Formula explanations, code narration, and comments sometimes
repeat the same work. The opening has about 265 prose words before setup.

Specific corrections/opportunities:

- The title is awkwardly joined by a comma; tighten it with the opening.
- Objective 3 says "optimized portfolios," but Task 3 evaluates only the long-only
  GMV allocation against equal weights and SPY. Align the stated scope with code.
- Tighten setup/data prose and Task 1 while retaining date alignment, units,
  the sample-mean/regression distinction, and the covariance solve/normalization.
- Use the reviewed lecture as the reference for compact mathematical recalls,
  preserving definitions and useful equation annotations. Do not impose a large
  lecture-style theorem box on every computation.
- The transition into Task 3 says to keep the weights fixed; clarify that these
  are the initial weights and the buy-and-hold calculation fixes share counts.
- Results/summaries should remain valid when students change the ticker list;
  the displayed-selection qualification is already present and should be retained
  or replaced with an interpretation prompt tied to the current output.
- If reviewing solver robustness, the selected-weights table labels the first
  successfully solved sweep row as GMV; this requires the first target to solve.
  All 101 targets solved in saved outputs. This is not a failure of the default
  run and does not justify a broad solver refactor.

Recommended sequence: opening/objectives; setup and Task 1; Task 2 comparison;
Task 3 and Summary. Await instructor acceptance of the starting point before edits.

## Checks performed

Read all 53 cells (22 code), all saved text outputs, local setup/helpers, the
package growth-matrix and risky-only solver implementations, the current lecture,
and the older L5b review/refactor records. Inspected all four saved PNG plots.
The saved solver summary reports 101/101 targets and no error outputs are present.
The notebook schema passes. The complete Markdown/code/output render uses the
installed VS Code math renderer and reports no math errors. The dense estimation
section was inspected in Chrome. No Julia computation was rerun during this
opening assessment, and external documentation links were not revalidated.

Artifacts are under `build/notebook-previews/L6a-minvar-polish-2026-09-24/`:
`before.ipynb`, `notebook-text.txt`, `initial.html`, `initial-estimation.png`, and
four extracted saved figures. The active example, source code, outputs, and
metadata remain unchanged.

## Shorts-allowed GMV in the out-of-sample comparison — September 26, 2026

The instructor asked to simulate the short case in the Task 3 comparison. The
buy-and-hold rule is linear in the weights, so `w_GMV_closed` runs through it
unchanged: a negative weight is the negative value of the borrowed shares owed,
and `W_t` is net wealth. The instructor framed this first implementation as a
"blue sky" test and chose a dashed navy line for the new path.

Edits (cells 42–51):

- Cell 42: the Task 3 opener tests the two GMV portfolios from Task 1 ("All four").
  This also closes the Objective 3 scope note above ("optimized portfolios").
- Cell 44: new `**What does a negative weight mean?**` paragraph (borrow and sell
  shares worth |w_i|W_0, the term is the value owed, a rising shorted price pulls
  W_t down) ending with the blue-sky assumptions: no borrowing fee, no cash set
  aside as collateral, no dividends owed on borrowed shares. "three" became
  "four"/"the portfolios".
- Cell 45: adds `("GMV (shorts allowed)", w_GMV_closed)` and
  `@assert all(wealth[name] .> 0)` (the table takes logs). Cell 46: "four paths".
- Cell 47: `("GMV (shorts allowed)", :navy, :dash)`. Cell 49: the new table row.
- Cell 50: at the instructor's request, the reading became a lead sentence, three
  bold-labeled bullets (lowest realized risk, largest year-end wealth, short
  positions), and one closing sentence.
- Cell 51: the third takeaway adds the shorts-allowed weights and "Allowing short
  positions lowered the estimated risk but not the realized risk in 2025."

Result for the default 13 firms (2025): long-only GMV 1.377 / 0.3238 / 1.996;
shorts-allowed GMV 1.3302 / 0.2888 / 2.027 (W_T/W_0, growth, σ_g). The
shorts-allowed portfolio is about 11.5% gross short (C −9.3%, MU, AMD, NVDA),
and all four shorted firms rose in 2025.

Checks: the draft was executed from the L6a folder with no errors, and the
long-only row reproduced the stored output exactly. Codex recomputed every
number and ranking in the new prose, including 2025 VWAP ratios for the shorted
firms. Its accepted fixes were a split of two long sentences in cell 44, "pulls
W_t down", "the cash we must set aside as collateral", and cell 45 comments
without semicolons. Declined: a positivity check for SPY (a long-only holding)
and cutting the Summary's recap. The applied notebook differs from HEAD only in
cells 42–51 sources and the cell 49 table output. Figures were re-rendered, and
notebook metadata and cell IDs are unchanged. Remaining semicolons in cells 44
and 46 predate this edit.

Final SHA-256:
`90d67ddfcdc9bdcd416e5f2c700f548a6dbe6d67e4e5c449dcba7f4dc31d9f6e`

Artifacts: `build/notebook-previews/L6a-minvar-shorts-2026-09-26/` (ignored by
git): `before.ipynb`, `edit.py`, `executed.ipynb`, and the PNG previews.
