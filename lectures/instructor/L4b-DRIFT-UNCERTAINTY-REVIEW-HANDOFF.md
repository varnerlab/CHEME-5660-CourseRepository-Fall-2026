# L4b drift-uncertainty example review — September 12, 2026

Notebook:
`lectures/week-4/L4b/advanced/drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb`

## Direction approved by the instructor

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

## Technical details and verification

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
