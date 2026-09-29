# L6b SIM estimation example — polish round

**Status, September 28, 2026: marked reviewed by the instructor.** Polish round
on [the SIM estimation example](../week-6/L6b/CHEME-5660-L6b-Example-SVD-SIM-Estimation-Fall-2026.ipynb),
item 3 of the [L6b examples handoff](../week-6/L6b/tmp/L6b-EXAMPLES-REVIEW-HANDOFF.md).
Initial rating 6.5/10. The first round closed at 8.3, which is below the 9.0
polish threshold, and the instructor asked for its three open items to be fixed.
The second round closed at 9.0/10. No proposals remain pending. Do not restart
approved sections unless the instructor asks for another round.

**Not yet committed.** The instructor deferred the commit until all four L6b
examples are reviewed. The lecture, deck, and examples are to be committed
together. The notebook sits in the working tree on top of `9ccb147`.

## Snapshot

- Notebook SHA-256: `3515d1020f550065c8bdf7e102de985ece5791754ac982879e6b783bff513b3e`.
- 39 cells, 15 code cells. Outputs are stored from a clean nbconvert run
  (`julia-1.12` kernel, no errors).
- Parameter archive `data/SIMs-SP500-01-03-14-to-12-31-24.jld2` is byte-identical
  to the `9ccb147` commit (SHA-256 `59a9cc55…53ee`) after every re-execution.
- Prose (Disclaimer excluded): 2,197 words to 1,966 after round 1, and 1,651
  after round 2. Clause semicolons went from 13 to 0.
- Lecture: this round changed one sentence of the L6b lecture (see below). Its
  SHA-256 is now `453ebc0f962d7bf19b1f506c66eeacedc1aeb8f1bfe79e45da7507624e50fba1`.
  Before the edit it matched the slides-review snapshot (`9ce81850…3359`).

## Opening assessment (6.5/10)

| Dimension | Before | Round 1 | Round 2 |
|---|---:|---:|---:|
| Technical correctness | 7.5 | 8.5 | 9 |
| Organization | 6 | 8.5 | 9 |
| Narrative and voice | 5 | 8 | 8.5 |
| Presentation | 7 | 8 | 9 |
| Density | 4.5 | 7 | 8.5 |
| Code as a lesson | 6 | 8 | 9 |

These were the main problems at the start:
- The overview above the objectives was a 72-word itinerary, and the package list in cell 3 linked a nonexistent `src/Compute.jl`.
- No task opened with "In this task" and none had subsections.
- The lecture was re-derived: condition-number squaring, the pseudo-inverse, the `var` degrees of freedom, and the list of classical assumptions.
- Five claims were wrong or overstated:
  - a condition number of 2.15 was called "close to one";
  - INTC (1.18) was grouped with semiconductor betas "well above one";
  - bank residual correlations of 0.52 to 0.74 were described as "a few tenths";
  - dependence was said to be tested by the uncertainty example;
  - the takeaway label said "beta is not a measure of fit".
- The readings were tied to AMD, and some wording still assumed the notebook belonged to L6a.
- A nested one-line `fit` function duplicated the Task 3 loop.

## Accepted steps

1. **Opening, setup, data, constants.** The title cell opens with the lecture's
   question and puts a short "In this example" overview below the objectives.
   Setup, the documentation line, and the VWAP and data text are the standard
   L4b/L6a wording. The 13 L6a firms moved into Constants as
   `my_list_of_tickers`, and the denial about total shareholder performance was
   cut.
2. **Task 1: Fit the SIM for One Firm, Three Ways.** The task has an
   "In this task" opener and recalls the SIM from the lecture as a display. It
   has three subsections (growth-rate matrix, regression setup, three solvers).
   The solver asides were cut to one bullet per method. "Condition number is
   small" replaces "close to one". A `__What do we see?__` reading explains the
   scatter for any ticker. The code gained stage and idiom comments, and the
   legend and axis labels were fixed.
3. **Task 2: Evaluate the Fit and Its Uncertainty.** The lecture display gives s²
   and R². The standard-errors text is three short paragraphs; this was the
   instructor's one correction in round 1. The diagnostics notebook replaces
   the false claim about the uncertainty example. A
   `__How do we read the table?__` callout has Beta, Alpha, and Goodness of fit
   bullets plus the "your values will differ" reminder. The stock versus
   index-fund contrast moved to Task 3 and now reads two rows of
   `sim_parameters`, which deleted the nested `fit` function. The table is
   identical.
4. **Task 3: Fit the SIM for Every Security.** The task has subsections for
   fitting every security, the stock versus index-fund comparison, betas across
   the dataset, the residual correlations, and saving the archive. The
   residual-correlation reading is three labeled bullets with verified values:
   banks 0.5 to 0.7, the automakers about 0.6, and AAPL and MSFT negative
   against the banks. It links the SIM portfolio example for the portfolio
   effect. The histogram legends have headroom and lw 3, and the heatmap is
   sized from `my_list_of_tickers`.
5. **Summary.** The takeaways are "Three methods, one estimate", "Exposure and
   fit are different measures", and "Related firms keep correlated residuals".
   The closing line names two next steps, each linked to a notebook in this
   week's folder.
6. **Round 2, to reach 9.0.**
   - Prose was cut from 1,966 to 1,651 words: shorter objectives, one VWAP
     sentence, tighter readings, and no read-back of the archive metadata.
   - Every code line is now at most 100 characters. Printed output is
     textually identical and the archive is byte-identical.
   - The heatmap uses L6a's `right_margin = 10Plots.mm` and `size = (640, 540)`,
     so its colorbar labels no longer clip.
   - The lecture's example callout (cell 5) now reads "We fit one firm, then
     every firm in the dataset. We compare a stock with an index fund and check
     whether the residuals of different firms are uncorrelated." The deck lists
     only the example title, so it needs no change.

## Checks

- Codex checked every step against the notebook JSON, the lecture,
  `code/src/Base.jl`, the archive (read with h5py), and the RA and RRFA
  consumers. Its accuracy findings were applied, including:
  - the assert checks agreement to within 1e-10, not machine precision;
  - a residual is signed;
  - the assumptions are about errors, not residuals;
  - diversification removes "much", not "most", of the residual risk;
  - not every metadata entry is checked by the portfolio examples;
  - MU–bank residual correlations are not negative;
  - alpha intervals are wide "relative to the estimate".
- A fresh Julia run gave the residual-correlation facts:
  - banks with banks: 0.516 to 0.736;
  - F and GM: 0.617;
  - semiconductors with semiconductors: 0.084 to 0.415;
  - AAPL and MSFT against banks: −0.284 to −0.198;
  - across all pairs: median |ρ| 0.073, 95th percentile 0.273, largest 0.981 (FOXA and FOX).
- Full re-executions in a sandbox copy (Project, Manifest, and `code/` copied)
  had no errors. Each run's archive was byte-identical to the committed one.

## Declined

These Codex suggestions were not taken:
- Adding AMD and QQQ numbers to the readings and takeaways, because house style keeps readings independent of the ticker.
- A Gaussian-coverage qualification on the t intervals, which goes beyond the lecture's statement of the assumptions.
- Softening "whatever its beta" in the stock-versus-fund reading: all 418 single stocks in the data have lower R² than QQQ and SPYG.

## Previews

Before/after PNGs are in `build/notebook-previews/`: `L6b-SVD-step1-opening.png`
through `L6b-SVD-step5-summary.png`, `L6b-SVD-step3b-std-errors.png`, and
`L6b-SVD-round2-r2a.png` and `-r2b.png`. They were built with
`build/notebook-previews/tools/make_preview.py` and `render-sbs.mjs`, which use
VS Code's KaTeX and show stored outputs. The folder is gitignored and may be
cleaned.
