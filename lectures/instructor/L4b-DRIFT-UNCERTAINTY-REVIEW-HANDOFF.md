# L4b drift-uncertainty example review

Notebook:
`lectures/week-4/L4b/advanced/drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb`

## Current status — reviewed September 13, 2026

The instructor confirmed: “Ok, let's mark this notebook as reviewed.” The
requested polish was conditional on an initial score below 9/10. The initial
assessment was **9.1/10**, so the notebook was left unchanged. The review is
complete; no proposals remain pending. Read this record before follow-up work
and do not restart completed sections unless the instructor requests another round.

### Assessment

| Dimension | Score |
| --- | ---: |
| Technical correctness | 9.5 |
| Organization | 9.2 |
| Narrative flow | 9.1 |
| Presentation | 9.0 |
| Cognitive density and pacing | 8.7 |

The strongest feature is the progression from Brownian error covariance to
estimation precision and then target probabilities. Task 2 distinguishes a
longer observation period from more frequent sampling. Task 3 interprets the
numerical results and distinguishes separate sensitivity ranges from a joint
confidence band. These scores are editorial judgments, not measured learning
outcomes; classroom feedback is needed to assess pacing.

Minor possible refinements were identified but are not pending edits: Task 1
is demanding, the detailed derivation of c_N could be linked where it first
appears, and the Summary lacks a closing sentence after the takeaways.

### Checks performed in this assessment

- Executed all nine code cells successfully in the course Julia environment
  and reproduced the saved numerical tables. Simulation agreement, valid and
  decreasing target probabilities, and sensitivity-range ordering checks passed.
- Independently verified the slope-variance formula against the full Brownian
  covariance matrix for six grids and checked the polynomial sum in the linked
  derivation symbolically. Recomputed the observation-period table.
- Validated the 22-cell notebook: exactly three objectives, three tasks, and
  three takeaways; all eight local-link occurrences resolve; horizontal rules
  occur only immediately before level-two sections; no saved error outputs.
- Inspected six rendered portions covering the whole notebook, including both
  plots. The corrected preview rendered 82 mathematical elements without
  reported errors and had no page-width overflow. The preview uses local
  Markdown/KaTeX modules and neutral browser styling; application themes differ.
- Confirmed that the notebook remains byte-for-byte unchanged. Its SHA-256 is
  `1d7066ffad0f22bc50c49d4dd24c1e3c52a82d89bde7dcbc078202cd607e8c1f`.

Review previews are under `build/notebook-previews/`, with the prefix
`L4b-drift-uncertainty-initial`. They are disposable; regenerate them from the
notebook if needed. No commit or push was made.

## Historical revision — September 12, 2026

The following records the earlier authorized revision and its validation.

### Direction approved by the instructor

The instructor requested an interactive review, then explicitly authorized a
complete revision around linear regression: “Agree. Update,” with organized,
careful prose in his teaching voice because he was running out of editing time.
The proposed revision of the sample-mean derivation was never applied.
The revised notebook follows the least-squares slope used in the parameter example.

- Opening: the motivating question, three learning objectives, the approved
  “In this example, we use a constant-parameter geometric Brownian motion…”
  sentence, then “Let's get started!” Preserve this arrangement.
- Setup: always use the standard opening from the L4b parameter example,
  with factual descriptions adapted to the local `Include.jl`. This reference
  is recorded in the shared notebook style guide.
- Task 1: recall the fitted line; derive Brownian error covariance and parameter
  covariance; calculate the regression-slope standard error; simulate log-price
  histories and refit the line for every replicate.
- Task 2: distinguish observation period from sampling frequency, retain only a
  brief sample-mean comparison, and derive a sufficient observation period for
  a chosen 95% interval half-width.
- Task 3: use the fitted slope and volatility from one simulated daily history,
  then vary the inputs separately in the target-probability calculation.
  The resulting ranges describe separate sensitivities, not a joint confidence band.

### Technical details and verification

For N growth intervals and N+1 equally spaced log prices, including time zero,
the slope variance is c_N σ²/T_span, where
c_N = (6/5)(N²+2N+2)/((N+1)(N+2)). The fit includes an intercept.
The scalar expression was verified against the full Brownian covariance matrix.
The detailed grid-sum derivation and three helper-function references are in
the notebook's `docs/` directory. `Include.jl` now explicitly loads `LinearAlgebra`.

All notebook code executes successfully. Additional numerical checks passed:
23 checks for regression covariance, actual least-squares fitting, simulation
agreement, and known-volatility interval coverage; 76 checks for target
probabilities and input domains. Simulated 95% coverage is 95.12%, 94.75%, and
95.25% for daily, weekly, and monthly sampling. Exactly three objectives,
three tasks, and three retrospective takeaways remain, with all 22 original cell IDs.
Local links, notebook anchors, and horizontal-rule placement were checked.
Rendered sections and plots were inspected; figure margins were adjusted to
keep axis labels visible. Outputs are refreshed. No commit or push was made.

The lecture, slides, and other companion examples were not changed by this review.
Unrelated changes remain in the working tree. Temporary review artifacts are
under `/private/tmp/l4b-drift-final-review/` and may not persist.

Final notebook SHA-256: `1d7066ffad0f22bc50c49d4dd24c1e3c52a82d89bde7dcbc078202cd607e8c1f`.
