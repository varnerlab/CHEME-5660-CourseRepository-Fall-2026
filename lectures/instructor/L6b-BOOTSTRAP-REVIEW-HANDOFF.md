# L6b bootstrap uncertainty example — polish round

**Status, September 28, 2026: marked reviewed by the instructor.** Polish round
on [the bootstrap uncertainty example](../week-6/L6b/CHEME-5660-L6b-Example-SIM-Parameter-Uncertainty-Fall-2026.ipynb),
item 2 of the [L6b examples handoff](../week-6/L6b/tmp/L6b-EXAMPLES-REVIEW-HANDOFF.md).
Initial rating 6.0/10, final 9.1/10 (Codex 9.0 before the last reading was
added). No proposals remain pending. Do not restart approved sections unless
the instructor asks for another round.

**Not yet committed.** The instructor deferred the commit until all four L6b
examples are reviewed; the lecture, deck, and examples are to be committed
together. The notebook sits in the working tree on top of `9ccb147`.

## Snapshot

- Notebook SHA-256: `d556644ae74cbc38ccd90fccd593f8cd210f756f3679cd82f56bce79bb48df82`.
- 44 cells, 17 code cells, outputs stored from a clean nbconvert run
  (`julia-1.12` kernel, no errors). HEAD had no stored outputs.
- Prose (Disclaimer excluded): 1,398 to 1,493 words. The additions are the
  standard L4b opening, two-sentence objectives, the Task 3 section, and the
  closing reading; Task 2 lost about 60 words.

## Opening assessment (6.0/10)

| Dimension | Before | After |
|---|---:|---|
| Technical correctness | 7 | 9 |
| Organization | 5.5 | 9 |
| Narrative and voice | 6 | 9.5 |
| Presentation | 5 | 8.5 |
| Density | 7 | 7.5 |

Main problems at the start: cell 34 attributed the gap between the bootstrap
and classical intervals to the MLE versus N−2 variance (a 0.04% effect; the
real cause is Monte Carlo error, about 2.2% for 1,000 draws); the comparison
table centered the bootstrap interval on the bootstrap mean and had no
standard-error column; Task 2 was thin and Task 3 carried everything; the 2025
opening; four huge raw printouts; `"MSFT"` hard-coded before the ticker was
set; "__Ok, wow!__" and a promise to "validate that the confidence intervals
make sense" that the notebook never kept; the pseudocode differed from the
lecture's.

## Accepted steps

1. **Opening, setup, data, constants.** Title cell opens with the lecture's
   question ("How much might alpha and beta change if we had another
   dataset?"); objectives are two sentences each; one-sentence "In this
   example" overview below them. Standard L4b setup, documentation line, VWAP
   paragraph, and record-count filter. Constants gain `market_ticker`,
   `ticker_of_interest`, and `number_of_bootstrap_samples`, with L4b's
   Constants wording.
2. **Task 1: Fit Single Index Models for All Firms** (old Tasks 1 and 2
   merged). A date-alignment assert before `log_growth_matrix`; `X̂` built once
   next to `Gₘ`; the fit loop uses `enumerate`, a single `(X̂ᵀX̂)⁻¹`, and
   `z = quantile(Normal(), 0.975)`; a five-column table for the selected firm;
   a new across-firm count table (373 of 423 alpha intervals and 1 of 423 beta
   intervals contain zero, SPY excluded) with a two-sentence
   `__What do we see?__`; R² as a `###` subsection under the lecture formula,
   with an assert that R² equals the squared correlation; the fit figure at
   `lw=3` with "(1/yr)", "R²", and "observed = fitted".
3. **Task 2: Generate Bootstrap Estimates.** A three-sentence
   "__What is a Gaussian bootstrap?__" callout; the lecture's pseudocode copied
   verbatim; the unproposed denial about price records cut; generation reuses
   `y_firm`, `ŷ_firm`, and the constants; the refit cell keeps its small 2×1000
   printout and a student prompt about `X̂ \ synthetic_datasets`. Draws are
   identical to the old notebook (same seed, same fitted normal).
4. **Task 3: Compare Bootstrap and Classical Uncertainty.** A corrected
   "__What do we expect to see?__" (Monte Carlo error, about 2% for K = 1000;
   "Agreement checks the calculation. Residual diagnostics test the model's
   assumptions."); a table of SE_classical, SE_bootstrap, ratio (1.014, 0.988),
   and the fraction of refits inside the classical interval (0.945, 0.953); a
   two-panel figure of the refit histograms with the classical normal curve and
   dashed 95% interval.
5. **Summary.** Parallel-verb opener; takeaways "Parameter estimates and
   intervals", "Goodness of fit", "Uncertainty by simulation", each with a
   finding the notebook shows; the diagnostics link described in plain words.
6. **Closing reading (the instructor asked for "one thing" to reach 9).** After
   the Task 3 figure: "__So how much might alpha and beta change with another
   dataset?__ About two standard errors either way, since 95% of the refits stay
   inside the classical interval. Across all firms (Task 1), that means another
   dataset could flip the sign of most alphas, but almost never the sign of
   beta." It answers the question the title cell poses.

## Checks

- Codex checked every step against the notebook JSON, the lecture (cells 4–6),
  `code/src/Base.jl`, and the executed outputs; it independently reproduced
  373/423, 1/423, and R² = 0.5219 from the price data, and confirmed the
  pseudocode matches the lecture character for character.
- Full re-execution with no errors; also re-run with `ticker_of_interest` set to
  XOM and GLD, both clean. GLD is the one firm whose beta interval contains zero.
- With a fixed seed, the Task 3 ratios and coverage fractions are identical for
  every ticker, because each draw scales with the firm's residual standard
  deviation. The readings are written to hold for any ticker for that reason.

## Declined or deferred

- Codex's rewording of the closing reading ("most alpha intervals allow either
  sign. Almost all beta intervals exclude zero.") was not taken; the instructor
  approved the previewed wording.
- Takeaway 3 keeps "which checks the calculation but not the model's
  assumptions": students do read bootstrap agreement as validating the Gaussian
  model, so the denial names a real trap.
- Optional, not pending: state the classical assumptions (uncorrelated,
  constant-variance errors) in cell 19; say "other than `market_ticker`" in the
  Constants instruction, since SPY fitted against itself is degenerate; add
  units to the vector comments in cells 32 and 39; a "__Why?__" prompt on the
  ticker-invariant ratios.

## Previews

Before/after PNGs for each step are in `build/notebook-previews/`
(`bootstrap-p1-opening.png` through `bootstrap-p6-answer.png`), built with
`build/notebook-previews/bootstrap/preview_out.py`, which shows executed outputs
beside the source. That folder is gitignored and may be cleaned.
