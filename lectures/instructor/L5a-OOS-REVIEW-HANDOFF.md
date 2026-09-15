# L5a out-of-sample GBM example — completed notebook polish

**Status: reviewed and complete, September 14, 2026.** The instructor explicitly
confirmed: “Ok, great! Let's mark this notebook as reviewed.” All proposals were
approved and saved; no proposals remain pending. The final revision approval was
“Agree! Update. Next,” following the expanded learning-objective preview.
Do not restart completed sections unless the instructor requests another round.

Notebook: [Out-of-sample single-asset GBM example](../week-5/L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb)

Initial SHA-256:
`acabdb2dae9bf96e5cb434b21384961088d012c3c57986aa88964c39c3bf8e35`

Final SHA-256:
`c4e7183d64d2b6dca80f8154af831b174c5118ecc626940153dd44f59bc26dfb`

## Assessment

The instructor requested polishing only if the initial score was below 9/10.
The initial assessment was 8.1/10, so the interactive revision proceeded.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 7.8 | 9.5 |
| Organization | 8.3 | 9.3 |
| Narrative flow | 8.5 | 9.2 |
| Presentation | 7.8 | 9.0 |
| Cognitive density and pacing | 8.0 | 8.9 |
| Overall | 8.1 | 9.2 |

The original exact transition, arithmetic-drift conversion, and lognormal
quantiles were sound. The most consequential error was the histogram's omission
of 219 assets with exactly 100% coverage. The selectable ticker list also included
56 assets without fitted parameters. Both issues are corrected. Three tasks now
connect simulation, pointwise bands, and comparisons across assets; the opening
and retrospective takeaways follow the same progression. Displayed equations,
documented source helpers, and prose between result tables improve readability.

These scores are editorial judgments, not measured learning outcomes. The
lognormal-band and standardized-deviation explanations still require deliberate
classroom pacing. Several long code and reporting lines require horizontal
scrolling inside their cells. No further substantive changes are proposed in
this completed round.

## Approved changes

- Corrected the histogram by extending its final edge to `nextfloat(1.0)`.
  All 417 scored assets now contribute to the normalized distribution, including
  coverage equal to one. Replaced the stored histogram with the corrected figure
  and removed stale alternative representations of that output.
- Restored the standard setup opening and documentation references. Loaded the
  training parameter table before forming the sorted intersection of fitted
  tickers and complete testing histories. The selectable and scored populations
  now both contain 417 assets.
- Organized the example into three tasks: simulate one asset, construct bands
  and measure its coverage, and compare coverage across the shared dataset.
  Aligned mean growth with L4b's `mu_g` notation and explained the conversion to
  arithmetic drift. The legacy CSV column name `drift` remains documented.
- Developed the expected price, log-price distribution, and prediction-band
  limits in separate displays. Explained fixed fitted parameters, initialization
  from the first testing VWAP, exclusion of that observation from scoring, and
  pointwise probabilities versus the probability of remaining inside a band
  over an entire path.
- Developed standardized log-price deviations and their maximum separately.
  Explained sign, scale, the 1.96 threshold, and dependence across forecast dates.
  The maximum remains a descriptive diagnostic, not a p-value.
- Interpreted the histogram and highest/lowest coverage tables without equating
  high coverage with precise prediction or investment performance. Distinguished
  endpoint price changes from deviations during the year. Explained that the
  diagnostics alone cannot distinguish parameter uncertainty, parameter changes,
  or omitted dynamics such as jumps.
- Extracted `gbm_prediction_band`, `band_coverage`, and `max_abs_z` into
  [src/OutOfSample.jl](../week-5/L5a/src/OutOfSample.jl), with Julia docstrings
  covering arguments, units, returns, and assumptions. Added one include line to
  [Include.jl](../week-5/L5a/Include.jl) and function-specific notebook links to
  [the local reference](../week-5/L5a/docs/oos-functions.md).
- Aligned the introduction, three learning objectives, summary, and three
  retrospective takeaways with the developed work. Expanded each objective to
  two sentences after instructor feedback, retaining both computation and
  interpretation.

## Instructor preferences

- Include connective prose between consecutive result tables. The accepted
  paragraph interprets the highest-coverage table's price ratios and introduces
  the lowest-coverage comparison.
- Put each constant or parameter assignment on its own line, with a trailing
  comment explaining meaning and units where applicable. Do not combine
  separate assignments on one line with semicolons.
- Give each learning objective enough substance to explain what students will
  calculate and what they should learn from the result. The first closing draft
  was too terse; preserve the approved expanded objectives.

The table-transition and parameter-comment preferences are recorded in the
[shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md).

## Validation and limits

- Executed the actual `Include.jl` and all 18 code cells in a fresh Julia 1.12.7
  process using the course project. Execution used `include_string` with the
  notebook path, including both figures and the two separate result tables.
  This was not a Jupyter-kernel execution. The final approved revision changed
  only Markdown cells 0 and 39, preserving all executable content and outputs.
- Verified 417 selectable and scored assets, 250 aligned observations per asset,
  the 250-by-101 simulation array, matching time axes, and the analytical
  expectation. Default SPY coverage rounds to 0.976 for the 95% band and 0.996
  for the 99% band; median 95% coverage across assets is 1.0.
- Compared the extracted helpers with their original implementations for all
  417 assets: exact agreement for both coverage fractions, maximum absolute
  standardized deviations, and all three prediction-band arrays. Checked
  inclusion at both band boundaries, collapse at time zero, and Julia help
  availability for all three source docstrings.
- Verified that the corrected histogram retains all 417 observations, accepts
  both endpoints, and has probabilities summing to one. Its final bin contains
  316 assets, or approximately 0.757794 of the scored population.
- Validated the final notebook schema. Exactly three objectives, three tasks,
  three takeaways, and six major-section separators; each separator precedes a
  level-two heading and none trails the final section. The summary includes a
  concluding sentence. Six relative notebook-link occurrences and the local
  helper-documentation links and anchors resolve.
- Rendered the complete final notebook and visually inspected eight section
  PNGs. All 41 math elements rendered without reported errors; both figures
  loaded; no page-wide horizontal overflow. Long code lines scroll within cells.
  The final saved notebook exactly matches the approved draft.
- The initial audit verified aligned, sorted, unique 2025 timestamps and checked
  the fitted parameters against the L4b training calculation. The default
  testing dataset remains 2025; the package's separate 2026 snapshot was not
  substituted during this review.
- Course documentation pages could not be freshly verified on September 14
  because the web and local DNS checks were unavailable. Historical successful
  checks are not a current availability guarantee. Local package source and
  function behavior were inspected and executed.
- Focused whitespace checks passed. Existing `src/Compute.jl`, unrelated
  notebooks, and concurrent review changes were preserved. No commit or push
  was made.

## Saved artifacts

The ignored `build/notebook-previews/` directory contains the assessment,
approved proposals, review state, and final artifacts:

- `L5a-oos-review-state.json`: initial assessment and accepted revisions.
- `L5a-oos-final.html`: complete final render.
- `L5a-oos-final-{opening,setup,simulation,bands,coverage,histogram,tables,closing}.png`:
  inspected section previews.
- `L5a-oos-final-validation.json`: final consistency and preservation checks.
- `L5a-oos-final-render-metrics.json`: rendering checks.

Preview artifacts are disposable and may be regenerated from the saved notebook.
The [versioned workflow](../../.agents/skills/notebook-polish/SKILL.md) and shared
style guide remain the maintained instructions.
