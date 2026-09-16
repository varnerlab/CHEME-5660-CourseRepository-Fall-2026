# L5b multiple-asset GBM portfolio example — completed notebook polish

**Status: reviewed and complete, September 16, 2026, confirmed by the instructor.**
The instructor explicitly requested “Great. Mark this as reviwed”.
The instructor approved the final three takeaways with “Agree. Update. Next.”
All approved sections are saved, and the final consistency check and rescoring
are complete. No proposals remain pending. Do not restart completed sections
unless the instructor requests another round.

Notebook: [Simulating a portfolio with multiple asset geometric Brownian motion](../week-5/L5b/CHEME-5660-L5b-Example-MAGBM-Portfolio-Fall-2026.ipynb)

Initial SHA-256:
`6f5a5e0d291a8f45861804b6df4b7cb89896e312e137f1828e69a15744e73262`

Final SHA-256:
`8c23618bc70ad66a79b9a01e0b8d1fce9ae39cf4afdd0f8b1faea7be1cbafafc`

## Assessment

The initial score was **8.4/10**; the final score is **9.2/10**.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 9.0 | 9.2 |
| Organization and sequencing | 8.0 | 9.3 |
| Narrative flow and interpretation | 8.5 | 9.2 |
| Presentation | 8.5 | 9.2 |
| Cognitive density and pacing | 8.0 | 9.0 |
| Overall | 8.4 | 9.2 |

The example now follows three coherent tasks: fit and check a correlated price
simulation, value fixed share holdings, and apply the scheduled-sale trade rule.
The notation explicitly connects the estimated mean growth to arithmetic drift
and the covariance diagonal to the familiar squared volatility. Separate tables,
figures, and interpretation paragraphs give the computations readable stopping
points. The final takeaways summarize the work in the instructor's retrospective
voice and agree with the objectives and calculations.

Task 1 remains the longest task because it includes estimation, factorization,
model construction, simulation, and diagnostic checks. Its subsections make the
sequence easier to follow, but classroom pacing has not been measured. Simulation
agreement with fitted inputs is an implementation check; the notebook explicitly
distinguishes it from predictive accuracy. Scores are editorial judgments. No
further substantive changes are proposed in this round.

## Approved revisions

- **Opening and organization:** Introduced the holding-period scenario and three
  learning objectives. Combined estimation and simulation into Task 1, followed
  by wealth and trade-rule tasks. Preserved the separation of 2014–2024 training
  data from the observed 2025 comparison.
- **Setup and constants:** At the instructor's request, replaced the Include
  blockquote with an ordinary prose link to `src/Compute.jl`. Retained the approved
  training/testing panel. Explained time units, allocation choices, the random
  seed, and the constant benchmark assumption using `g_y`.
- **Estimation and factorization:** Defined sample means, growth-rate covariance,
  covariance rate, their units, and the mapping to Julia variables. Explained the
  Cholesky factor and covariance recovery check. Separated the estimates table
  from the correlation heatmap with interpretation and connective prose.
- **Model and simulation:** Explicitly connected `C_ii = sigma_i^2` to the
  single-asset half-variance correction. Explained why arithmetic drift supplied
  to the sampler adds half the diagonal covariance rate to sample mean growth.
  Defined initial prices, the `N-1` holding intervals, the exact one-step update,
  shared within-step normal vector, and independent draws across steps and paths.
- **Diagnostic checks:** Explained covariance error, correlation error, mean
  discrepancies, and the Monte Carlo standard errors used to interpret them.
  The reported finite-sample differences are consistent with the fitted model.
- **Allocation and wealth:** Developed the long-only GMV problem, the redundant
  growth floor, and the conversion from weights to fixed share counts. Explained
  wealth by adding holding values. Interpreted the allocation table and the
  observed portfolio/SPY comparison. Pointwise bands are distinguished from
  whole-path coverage and from any individual simulated path.
- **Source helper:** Moved the wealth-quantile calculation to
  `scaled_wealth_quantiles` in the local `src/Compute.jl`, with a Julia docstring
  describing inputs, dimensions, units, returned values, and pointwise meaning.
  Its results were checked against the original calculation before saving.
- **NPV and probabilities:** Developed the discounted fractional gain, strict
  target event, empirical probability, and Monte Carlo standard error in separate
  steps. Replaced printed result lines with a compact table. Added prose between
  the table and histogram, explained density, and shortened the post-histogram
  interpretation while preserving the observed-versus-simulated comparison.
- **Closing:** The instructor approved a lead identifying a basket of assets and
  the closing distinction between model checks and prediction. The last approved
  revision replaced only the three takeaways: correlated simulation, fixed-share
  wealth, and NPV target probabilities. The companion minimum-variance example
  link remains and its description agrees with that completed notebook.

## Instructor preferences to preserve

- For this notebook, keep the explicit setup exception: use the ordinary prose
  `src/Compute.jl` link instead of restoring the Include blockquote. Display the
  visible source link without inline-code formatting that hides its link color.
- Explain portfolio wealth by adding the values of holdings and probabilities by
  counting outcomes. Do not replace these teaching steps with unexplained phrases
  such as a weighted sum of correlated lognormals.
- Retain the explicit bridge from covariance diagonal to squared volatility.
- Put the NPV question “How do we estimate the probability of exceeding a target?”
  in bold in its own paragraph.
- Keep connective prose between a table and a figure. Keep the NPV results in
  their compact table and the interpretation after the histogram brief.
- Put each preview link in its own paragraph; adjacent inline links were hard
  for the instructor to open.

## Validation and scope

- The original assessment read the whole notebook, saved outputs, local setup and
  helper code, and the package's growth-matrix, model factory, sampler, and solver
  implementations. It also read the original 2025 MAGBM portfolio example and a
  5820 reference passage. The resumption read all 51 current cells, saved outputs,
  local quantile helper, and review records; the target matched the saved pending
  checkpoint exactly.
- Earlier in the round, all original code cells ran successfully with Julia
  1.12.7 and the installed course environment. Independent checks covered growth
  calculations, drift correction, matching dates, initial wealth, positive finite
  wealth, and equivalent strict NPV/terminal-wealth target events. Subsequent
  execution checked the revised diagnostics, quantile helper and figure, and NPV
  reporting table. The final takeaways edit changed no numerical computation and
  did not require another simulation run.
- Recorded data counts: 2,767 training prices, 2,766 growth observations, 250
  testing prices, and a holding period of `249/252` years. The 2,000 simulated
  paths supplied 498,000 growth vectors. Relative covariance error was `0.00213`,
  maximum correlation error `0.00282`, and the largest standardized mean error
  about `1.56` Monte Carlo standard errors.
- Recorded default probability above zero scaled NPV was `0.6765`, with Monte
  Carlo standard error about `0.01046`. Observed scaled NPV was `0.3223533622`.
  These checks concern the fixed fitted model and allocation. The quantile helper
  reproduced the original percentiles, and the revised table reproduced the
  original numerical report.
- Final `nbformat.validate` passes: 51 cells, including 20 code cells, with no
  saved error outputs. Exactly three objectives, three tasks, three takeaways,
  and six correctly placed major-section separators. All nine local link
  occurrences resolve. Code cells contain at most one `let` block; there are no
  function definitions in notebook cells.
- Only the three takeaways in zero-based cell 49 changed in the resumed final
  revision. The approved summary lead and closing, all other cells, executable
  code, outputs, and metadata were preserved. The saved notebook matches the
  approved full draft exactly.
- The full final render uses nbconvert, local MathJax, and isolated headless
  Chrome. All 112 math expressions rendered without reported errors, all three
  images loaded, and no page-wide horizontal overflow occurred. Visually inspected
  the final summary, model-construction passage, NPV equations, result table,
  wealth figure, and NPV histogram.
- Final validation did not refetch the 26 external link occurrences. Earlier
  reviews checked relevant official references. Where hosted course documentation
  could not be retrieved, the corresponding local source and documentation were
  inspected; no claim is made that every hosted anchor was verified.
- The completed minimum-variance example and lecture, and the accepted helper
  source, retain their saved checksums. No source, package, slide, commit, or push
  changes were made during the resumed closing review. Existing concurrent edits
  were preserved.

## Saved artifacts

The ignored `build/notebook-previews/` directory contains the initial assessment,
approved drafts, execution logs, and final artifacts:

- `L5b-magbm-review-state.json`: accepted sections, preferences, completion, scores.
- `L5b-magbm-final.html`: full final render.
- `L5b-magbm-final-*.png`: final section and figure screenshots.
- `L5b-magbm-final-validation.json`: preservation and structure checks.
- `L5b-magbm-final-render-metrics.json`: math, image, and layout checks.

Previews are disposable; this record preserves the completed review if they are
cleaned. The [shared style guide](NOTEBOOK-STYLE-GUIDE.md) and
[versioned workflow](../../.agents/skills/notebook-polish/SKILL.md) remain the
maintained instructions.
