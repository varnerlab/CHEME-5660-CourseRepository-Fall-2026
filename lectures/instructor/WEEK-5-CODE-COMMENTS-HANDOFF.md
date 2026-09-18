# Week 5 notebook code-commenting pass — complete

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

Completed September 17, 2026, following the instructor’s request for thorough
comments in every code cell of every week-5 notebook, for student reading and
future problem-set use. This was a commenting pass, not another interactive
narrative review. The previously approved sections and review scores remain closed.

## Scope

All 11 notebooks under `lectures/week-5` were inventoried. Comments were added
or improved in all **175 code cells across nine computational notebooks**.
The two lecture notebooks contain no code cells and were unchanged by this pass.

The shared notebook style guide and Cornell Julia commenting style governed the
work. Comments combine short block labels, statement-specific explanations, and
brief mathematical rationale. They explain units, array dimensions, asset order,
indexing, helper behavior, assumptions, and interpretation without commenting
every mechanical statement. Existing calculations and cell organization were preserved.

## Teaching details covered

- **Covariance and growth:** Price rows versus growth intervals, sample centering
  and the N−1 correction, covariance versus covariance rate, volatility scaling,
  correlation normalization, and matching saved estimates by ticker.
- **Dirichlet portfolios and wealth:** Assets versus draws in array dimensions,
  simplex coordinates, empirical moment checks, sampled versus optimized weights,
  fractional shares, and fixed-share wealth with drifting portfolio weights.
- **GBM and prediction:** The legacy drift field, the arithmetic-drift correction,
  time columns versus simulated prices, independent increments with correlated
  assets, pointwise bands, coverage conventions, and Monte Carlo standard errors.
- **Advanced covariance and rolling estimates:** Spectral diagnostics, sample-rank
  limits, shrinkage targets and hindsight selection, trailing-window endpoints,
  undefined initial estimates, EWMA zero-mean assumptions, and overlapping windows.
- **Optimization and frontier geometry:** Budget and weight constraints, redundant
  growth floors, equality targets, the legacy solver result key, linear solves,
  tangent-grid approximation, normalizer signs, two-fund weights, and interpolated
  risk ratios at common targets.
- **Estimation risk:** Complete-day bootstrap resampling, the loss of serial
  dependence, standard errors across refits, median-centered weight dispersion,
  one-input-at-a-time sensitivity, and different allocations on one price history.
- **Reporting:** Display-only rounding, table and plot alignment, quantile axes,
  and the distinction between normalized wealth and discounted scaled NPV.

## Validation

- All 11 notebooks parse as JSON and pass `nbformat.validate`.
- Julia 1.12.7 parses all 175 final code cells. Their executable syntax trees
  match the saved pre-pass versions after removing source-line annotations.
- Every Markdown cell, stored output, execution count, cell ID, cell metadata
  value, notebook metadata value, and cell count matches the pre-pass snapshot.
- All nine computational notebooks were exported with nbconvert and rendered
  locally with MathJax. All 777 math expressions rendered without errors.
  At the 1060-pixel notebook preview width, no page, code-cell, or comment
  horizontal overflow was detected. Representative dense code cells from each
  notebook were visually inspected. The final comment refinements were rechecked.
- A separate reading pass checked the comments for clarity and agreement with
  the notebook calculations and local helper implementations.
- Numerical simulations and optimizations were not rerun: this pass changed
  comments only and preserved executable syntax and saved results. Previous
  numerical validation remains documented in the individual review handoffs.
- No helper, package, slide, or data files were changed by this pass. Preexisting
  edits from the completed slide and estimation-risk reviews were preserved.

## Notebook inventory and final fingerprints

Earlier review handoff hashes identify the snapshots at those reviews. The
fingerprints below identify the subsequent commented versions; they do not
replace the earlier narrative assessments or reopen their approved sections.

**Subsequent September 17 scope correction:** The instructor then requested removal
of the minimum-variance example's stale market-portfolio transition. Only its
Summary paragraph changed; all code comments and executable code remain as checked
here. Its current hash is
`cdd7c2dad7a1a0c863b33406be9603d1dc19dce23d7c05ae360002cbfe1823e4`;
the table retains the original commenting-pass hash. See the
[scope amendment](L5b-MINVAR-REVIEW-HANDOFF.md#september-17-release-alignment).

| Notebook | Code cells | SHA-256 after commenting |
| --- | ---: | --- |
| [L5a covariance](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/CHEME-5660-L5a-Example-CovarianceMatrix-Fall-2026.ipynb) | 18 | `3bdd890153976922013722ef7f72111db00bd73362b908e15950f8f6311ff8eb` |
| [L5a Dirichlet weights](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/CHEME-5660-L5a-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb) | 18 | `d50e17c79a5a692d0479964e474a94365cd3c80055248696efa963fb7c157898` |
| [L5a out-of-sample GBM](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb) | 18 | `639b0a8715690d8c0af40d2bdd3ffdd61f7c4196caea4bf1bb47a0f7b8c1189f` |
| [L5a lecture](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/CHEME-5660-L5a-Lecture-MultipleAsset-GBM-Fall-2026.ipynb) | 0 | `2a067a14607a3184690530405d5eb080d8d0837a5c413345e553445637c0342a` |
| [L5a advanced covariance estimation](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/covariance-estimation/CHEME-5660-L5a-Advanced-CovarianceEstimation-Fall-2026.ipynb) | 11 | `ce5de4c68cdfc8d690e6d4b1ae57204699c7aae72e42a8124acd96c136bf6d95` |
| [L5a rolling correlation](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/rolling-correlation/CHEME-5660-L5a-Advanced-RollingCorrelation-Fall-2026.ipynb) | 11 | `b9443a9626a6f0f1d65294ad00c88dffe6784dadf2d73dfae596124972d88cab` |
| [L5b minimum-variance portfolios](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Example-Data-MinVar-Portfolio-Fall-2026.ipynb) | 27 | `2616dd916e65c32cccb20313305607623b37daef31f1d48e481f5a9ebc640241` |
| [L5b multiple-asset GBM](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Example-MAGBM-Portfolio-Fall-2026.ipynb) | 20 | `f7078a41f86e2c8dbd4cf967df571b8ca667d75c2f4f71ec9793611d44911db2` |
| [L5b lecture](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb) | 0 | `d0fb3ae529194f004f9da166f2dcb05ab65b4ecafeecceb1ee2f50777f7913a5` |
| [L5b estimation risk](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/estimation-risk/CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb) | 27 | `ad6539f7d032c7f90fd859a58197defc806c7913081677bb0d9c08e0c04d7862` |
| [L5b frontier geometry](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/frontier-geometry/CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb) | 25 | `543a9a241bcb78282e48e55808c5511adbacfd2a9b4b65f495ea81c2e545dc2f` |

## Reproducible working evidence

The ignored `build/notebook-previews/week-5-code-comments/` directory contains
pre-pass notebook snapshots, the cell inventory, source comparisons, Julia
syntax checks, the validation report, HTML exports, layout metrics, and code
preview images. These artifacts can be regenerated or cleaned; this record
preserves the scope and results. No commit or push was requested.
