# L5a covariance example — completed notebook polish

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Status: reviewed and complete.** The instructor confirmed this designation
September 14, 2026. Final editorial rating: **9.2/10**. Every proposed section
was approved; all accepted revisions are saved and no proposals remain pending.
Do not restart completed sections unless the instructor requests another round.

Notebook:
[Covariance matrix example](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/CHEME-5660-L5a-Example-CovarianceMatrix-Fall-2026.ipynb)

Final SHA-256:
`339602365c8b9da633904f6d5025f8974a91518e6f57b72495115e985d298a2e`

## Assessment and review history

The September 13 opening assessment was 8.5/10. The introduction and setup were
approved that day. On September 14, the resumed assessment of that partially
polished notebook was 8.7/10. The instructor's threshold was to polish only below
9/10; the resumed assessment met that condition. This round preserved the
accepted opening and setup and completed Tasks 1–3 and the Summary.

| Dimension | September 13 | September 14 resumed | Final |
| --- | ---: | ---: | ---: |
| Technical correctness | 9.0 | 9.1 | 9.3 |
| Organization | 8.2 | 8.4 | 9.3 |
| Narrative flow | 8.3 | 8.6 | 9.2 |
| Presentation | 8.7 | 8.7 | 9.1 |
| Cognitive density and pacing | 8.2 | 8.5 | 9.0 |
| Overall | 8.5 | 8.7 | 9.2 |

The improvement reflects a clearer computation–verification–interpretation
sequence, equations placed beside their calculations, explicit output
interpretation, readable figure labels, and retrospective takeaways aligned
with the objectives. These are editorial judgments, not measured learning
outcomes. The 40-firm heatmap still requires close reading; classroom feedback
is needed to judge pacing through pair analysis and portfolio variance.

## Approved revisions

- Preserved the previously approved introduction, three learning objectives,
  standard setup, data explanation, and legacy parameter-table notation.
- Task 1 now introduces growth rates from successive volume-weighted prices,
  explains aligned intervals and matrix dimensions, develops centering and the
  outer product beside the code, and interprets the diagonal and off-diagonal
  entries. It preserves the current lecture's sample-mean notation.
- Passed `Δt` explicitly to `log_growth_matrix`. At the configured value of
  `1/252` years this reproduces the previous default calculation exactly.
- Created a separate Task 2 for the library covariance comparison, the L4b
  volatility comparison, and the informal implied-volatility discussion.
  Distinguished implementation and scaling checks from model validation.
  Wrapped the long print statements and explained their outputs.
- Moved the heatmap into Task 3 with pair analysis. Labeled all 40 displayed
  tickers, retained the alphabetical subset and common correlation color scale,
  and explained the colors, diagonal and symmetry.
- Explained the fitted slope and intercept, deviations from each firm's mean,
  linear association, and why correlation does not determine absolute scatter
  or establish independence. Preserved the AMD/NVDA selection and kept prose
  independent of its default numerical values.
- Connected pair covariance to the two-firm variance expression using the
  lecture's weighted-growth approximation. Explained the effects of weight
  signs and sizes without treating weighted asset log growth as exact portfolio
  log growth.
- Retained exactly three retrospective takeaways. Their labels are empirical
  covariance, covariance-rate scaling and checks, and correlation and portfolio
  variance. The closing sentence distinguishes the uses of the two covariance
  matrices.
## Mathematical conventions retained

- Growth rate: `g = log(S_k/S_(k-1))/Δt`, in inverse years.
- Sample growth-rate covariance: `Σ̂_g = G_centered' * G_centered/(N-1)`,
  in inverse years squared.
- Covariance rate: `Ĉ = Δt*Σ̂_g`, in inverse years; volatility is `sqrt(Ĉ[i,i])`.
- Correlation is invariant under the common time-step scaling and is defined
  here for positive sample variances.
- The saved parameter table's legacy `drift` column contains the fitted mean
  growth rate `μ̂_g`, not arithmetic GBM drift.
- Library and L4b comparisons check construction and scaling using the same
  historical data. Implied volatility is only an informal comparison of units
  and scale; no live option quotes were obtained during review.

## Validation

- Validated the final 47-cell notebook: 18 code cells, unique IDs, exactly three
  objectives, three tasks and three takeaways, correct separator placement,
  and no saved error outputs.
- Executed all 18 code cells, including `Include.jl`, through Julia
  `include_string` with the original notebook path. The final code is identical
  to the executed Task 3 draft. The subsequent Summary change was prose only,
  so execution was not repeated. This was direct Julia execution, not a fresh
  IJulia kernel execution of the saved notebook.
- Verified the 2,766 × 424 growth-rate matrix and 424 × 424 covariance matrix.
  Retained timestamps align and are sorted and unique; growth data are finite.
- The explicit time-step call equals the original default call. The maximum
  difference between the constructed covariance and `cov(G, dims=1)` is zero.
- Across all 424 firms, the maximum difference from the saved L4b volatility
  estimates is `2.220446049250313e-16`. The minimum covariance-rate eigenvalue
  is `0.00020091649390668545` for this dataset.
- Heatmap correlations agree with `cor` within `2.220446049250313e-16`.
  Fitted-line coefficients agree with a direct least-squares solve within
  `7.216449660063518e-16`. The selected pair's covariance and correlation remain
  `27.28628535819214` inverse years squared and `0.5874600048498015`.
- Inspected all sections through their rendered previews. The final saved
  notebook is identical to the last rendered draft: 61 mathematical elements,
  no MathJax errors, both figures loaded, and no page-wide horizontal overflow.
  Plot labels, code wrapping and the closing panel were inspected visually.
- Relative notebook/data/setup links resolve. The Julia include and covariance
  pages and both course function documentation pages returned HTTP 200; their
  exact linked fragments are present.
- Preserved existing cell IDs, metadata and execution counts. Only the two
  revised figure outputs were regenerated; all other stored outputs remain
  unchanged. No helper functions were added to the notebook.
- The focused whitespace check passed. No commit or push was made. Concurrent
  edits to the lecture, other examples and the shared style guide were preserved.

## Saved previews and records

The preview directory is ignored and disposable; regenerate from the notebook
if it is cleaned. Paths are relative to the repository root:

- `build/notebook-previews/L5a-covariance-final.html`: complete rendered notebook.
- `build/notebook-previews/L5a-covariance-final-{opening,data,task1,task2,heatmap,pair,summary}.png`:
  inspected section previews matching the approved text.
- `build/notebook-previews/L5a-covariance-final-validation.json`: final checks.
- `build/notebook-previews/L5a-covariance-review-state.json`: approval history,
  original and resumed assessments, and final state.

The shared [notebook style guide](NOTEBOOK-STYLE-GUIDE.md) and versioned
[notebook-polish workflow](../../.agents/skills/notebook-polish/SKILL.md) remain
the maintained guidance. This handoff records the completed review rather than
introducing new general style requirements.
