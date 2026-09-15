# L5a multiple-asset GBM lecture — completed notebook polish

**Status: reviewed and complete, September 14, 2026.** The instructor explicitly
confirmed the reviewed designation. All proposals were approved and saved;
no proposals remain pending. The final revision approval was “Excellent! Agree. Update.
Next.” Do not restart completed sections unless the instructor requests another
round.

Notebook: [Multiple-asset GBM lecture](../week-5/L5a/CHEME-5660-L5a-Lecture-MultipleAsset-GBM-Fall-2026.ipynb)

Initial SHA-256:
`56610370e729084d2bead960554d21653c8582ae149f8b450992bbadd4699f49`

Final SHA-256:
`2a067a14607a3184690530405d5eb080d8d0837a5c413345e553445637c0342a`

## Assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.5 | 9.5 |
| Organization | 9.0 | 9.0 |
| Narrative flow | 8.0 | 9.5 |
| Presentation | 8.5 | 9.0 |
| Cognitive density and pacing | 8.0 | 8.5 |
| Overall | 8.4 | 9.1 |

The original progression from single-asset review through correlated prices,
covariance estimation, and portfolio weights was already effective. The revision
corrects the independence claim, aligns mean-growth notation, stages definitions
and derivations, and develops the portfolio approximation before using it.
Separated equations and shorter takeaway labels improve readability.

These scores are editorial judgments, not measured learning outcomes. The lecture
still asks students to connect stochastic dynamics, covariance factorization,
estimation, Dirichlet sampling, and a portfolio approximation in one session.
Classroom feedback is needed to assess its pacing. No further substantive
rewrites are proposed in this completed round.

## Approved revisions and instructor preferences

- Single-asset review: aligned mean growth with `mu_g` and benchmark growth with
  `g_y`; clarified units, positive initial price, the terminal solution, and scaled
  NPV. Preserved the catch-up trade rule and avoided attributing all out-of-sample
  differences to constant parameters.
- Multiple-asset model: replaced the claim that independent assets never move
  together with the appropriate zero-covariance statement. Introduced `C` and
  `A` in stages, retained `A A^T = C` and its derivation, and distinguished a
  Cholesky factor from a symmetric square root. Separated the exact transition
  from its connection to observed growth. Clarified shared shocks across assets
  and independent shock vectors across time steps.
- Covariance: explicitly defined sample means `g'_i`, explained centering and the
  matrix product, and clarified covariance versus correlation in the schematic.
  Separated growth-rate covariance, covariance rate, volatility, and log-return
  covariance with explicit time scaling. Retained the positive-semidefinite
  norm argument. Distinguished singularity from sampling uncertainty: an
  eigenvalue or SVD factor can handle a singular covariance, while increasing
  its diagonal changes modeled variances.
- Portfolio weights: clarified the long-only, fully invested buy-and-hold setup,
  weight drift, fractional shares, and omitted dividends and costs. Separated
  Dirichlet moments and explained why uniform simplex sampling has nonuniform
  individual marginals except for the two-asset case. Distinguished sampling
  allocations from optimizing them.
- Portfolio growth: developed the first-order approximation from exact log
  wealth growth, using the exponential and logarithm expansions. The weighted
  growth mean and variance are explicitly properties of the linear proxy for
  fixed weights; exact wealth remains available for multiperiod calculations.
- The instructor found the growth/risk comparison confusing and specifically
  asked why it used `g'` and `mu_g`, and whether they had been defined. The accepted
  revision recalls both definitions: `mu_{g,i} = E[g_i] = mu_i - C_ii/2` is the
  model mean, and `g'_i` is the sample mean from observed intervals. It explains
  that the sample-mean vector estimates the model-mean vector, then displays
  estimated portfolio growth and variance using the sample estimates. Preserve
  this bridge rather than assuming students will recall the notation.
- Closing: used question-led descriptions matching the advanced notebooks and
  three retrospective takeaways labeled “Correlated asset prices,” “Covariance
  from data,” and “Portfolio weights.” Preserved the opening, examples overview,
  and disclaimer without changes.

## Validation and scope

- Read all nine cells and relevant companion calculations, setup, source, and
  advanced example narratives. Read the required 2025 multiple-asset lecture
  and CHEME 5820 reference passage, plus the approved L4b notation handoff.
- Final notebook passes `nbformat.validate`. Only Markdown sources in zero-based
  cells 2–7 changed. All approved sources match exactly; notebook metadata,
  cell metadata, and cells 0, 1, and 8 are preserved.
- Exactly three objectives, three takeaways, and eight major-section separators.
  Each separator immediately precedes a level-two heading; none trails the final
  section. All twelve relative link/image occurrences resolve. Obsolete mean
  and benchmark notation is absent.
- Rendered the final notebook with nbconvert and MathJax in headless Chrome.
  Visually inspected all six PNG sections at a 1280-pixel viewport. All 241 math
  elements rendered without reported errors; the covariance schematic loaded;
  there was no page-wide horizontal overflow or visible clipping.
- Independent NumPy checks passed for centered covariance, time scaling,
  covariance-factor row variances, and Dirichlet moments. A 200,000-draw check
  with seed 5660 agreed with analytical means within 0.000251 and covariances
  within 0.000072. A symbolic two-asset Taylor check reproduced the proposed
  first-order portfolio growth approximation.
- An initial auxiliary SciPy import failed because of an existing NumPy/SciPy
  binary mismatch; the replacement checks used NumPy alone. No packages changed.
  The official [Stan Dirichlet reference](https://mc-stan.org/docs/2_28/functions-reference/dirichlet-distribution.html)
  was consulted for the distribution statement.
- This lecture has no executable cells. Companion Julia notebooks were inspected,
  not executed or edited by this review. Concurrent companion-notebook, shared
  style-guide, and review-record changes were preserved. The whitespace check
  passed. No commit or push was made.

## Saved artifacts

The ignored `build/notebook-previews/` directory contains the initial assessment,
approved proposal sources and previews, and these final artifacts:

- `L5a-lecture-final.html`: full final render.
- `L5a-lecture-final-{opening,review,model,covariance,weights,closing}.png`:
  visually inspected section previews.
- `L5a-final-validation.json`: notebook and source-preservation checks.
- `L5a-lecture-final-render-metrics.json`: final rendering checks.

Preview artifacts are disposable; regenerate from the saved notebook if cleaned.
The [shared style guide](NOTEBOOK-STYLE-GUIDE.md) and
[versioned workflow](../../.agents/skills/notebook-polish/SKILL.md) remain the
maintained guidance. This record documents the completed review.
