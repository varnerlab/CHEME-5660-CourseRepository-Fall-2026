# L5b advanced estimation risk — notebook polish in progress

**Status: review resumed September 16, 2026. Opening, setup/data, and input estimates approved and saved. Not complete.**

Next notebook:
[Estimation Risk in Mean-Variance Optimization](../week-5/L5b/advanced/estimation-risk/CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb).
The instructor requested stopping for a while and returning to this notebook.
The frontier-geometry companion is already reviewed and complete at 9.2/10;
do not reopen its approved sections.

## Resume point

The initial assessment is complete. The instructor approved the opening with
"Agree. Update.Next" on September 16, 2026. The setup, data, and constants were
then approved; growth observations and 2025 prices were approved conditional on
agreement with the preceding notebooks. That check passed, and all these sections
are saved. The input-estimate subsection was then approved with
"Agree. Update. Next" and saved (42 cells, 17 code cells). The approved opening and all cells following
the old setup/data section are preserved. Do not restart the approved sections.
Continue with the portfolio constructions and documented source helpers.
The input-estimate subsection is complete; no portfolio-construction proposal is approved.
Use the [notebook-polish workflow](../../.agents/skills/notebook-polish/SKILL.md)
and [shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md).

Source SHA-256 after the approved input-estimate subsection:
`41247fba07d644b3ffea1501de412c6494230a18c6313941ea5d50c219472af0`

Compare the source with this hash before applying further proposals; preserve any
intervening instructor changes. Historical previews were deleted at the instructor's
request. The opening preview was regenerated from the saved wording before approval.

## Approved setup/data revision — saved September 16, 2026

The accepted revision replaced original cells 1–6 with the standard setup and
fourteen cells covering setup, training/testing data loading, firms and constants,
the growth-rate equation and matrix, 2025 price arrays, and a separate reporting
cell. The point-estimate/portfolio-function section and all later cells were
preserved. The saved notebook matches the approved draft exactly.

The revision removes the tiny inline `clean` helper in favor of explicit dataset
filtering, using each dataset's AAPL history length exactly as before. Portfolio
helpers will be moved to documented local source in the subsequent proposal.
It retains the thirteen firms, ticker order, random seed, observation interval,
risk-free benchmark, and price selection.

Validation: executed the original and proposed data code in separate Julia modules
using Julia 1.12.7 with the course project and an existing writable temporary depot.
All arrays, ticker order, dimensions, and constants matched exactly: G is 2766 × 13;
the 2025 matrix is 250 × 13. Checked the proposed dictionary and array types.
The rendered section has ten mathematical expressions, no math errors, no page
overflow, and no horizontally scrolling code cells. This was focused data-setup
validation; the remaining optimization/bootstrap code was not rerun in this step.

Notation check for conditional approval: the growth equation, firm index i,
observation index k, N observations from N+1 prices, G dimensions N × M, and
inverse-year growth units match the reviewed L5a covariance example and the L5b
minimum-variance and frontier-geometry examples. The 2025 price arrays retain
prices in USD/share and the same asset order, consistent with the L5b buy-and-hold
price-ratio calculation. No notation changes were required.

Review artifacts in `build/notebook-previews/`:

- `L5b-advanced-estimation-setup-proposal.ipynb`: full draft, only the setup/data section differs.
- `L5b-advanced-estimation-setup-proposal.md`: proposed prose and code.
- `L5b-advanced-estimation-setup-proposal-setup-data.png`: setup, data, and constants.
- `L5b-advanced-estimation-setup-proposal-growth-prices.png`: growth observations and 2025 prices.
- `prepare-estimation-setup-proposal.py`: regenerates the draft and data-equality check.
- `check-estimation-setup.jl`: focused numerical comparison.
- `render-estimation-setup-proposal.cjs`: local MathJax/browser renderer.

The notebook renderer is `/opt/anaconda3/bin/python` (nbformat/nbconvert). The
browser script uses installed Chrome and local MathJax, blocking web requests;
Chrome needs execution outside the sandbox. Hosted course documentation could not
be opened by the web tool during this step; the existing function links were
retained and checked against the local package source and documentation entries.

## Approved input-estimation subsection — saved September 16, 2026

The accepted revision separates the point estimates from the portfolio-function cell.
It explains the baseline, the column sample means g_i′ and vector g′, the
population mean vector μ_g, the centered growth matrix, and the sample covariance
Σ̂_g with N−1 normalization. It retains the existing Julia names `ĝ₀` and `Σ̂₀`,
explaining that subscript 0 marks the estimates fitted to all training rows.
This follows the approved L5a/L5b sample-versus-population notation.

The calculation is unchanged apart from an explicit positive-definiteness
assertion. The full draft separates the existing point-estimate assignments
from the portfolio definitions, and removes the now-repeated sentence and
"Point estimates" heading fragment from the following paragraph. Portfolio
functions and all later calculations/outputs are preserved for their own review.
The saved source includes this accepted subsection and matches the reviewed draft.
The approved opening and setup/data cells are preserved.

Executed the proposed estimates in Julia: old/new means and covariances match
exactly; the covariance is positive definite with smallest eigenvalue
2.4244323181806915. An independent centered-matrix calculation agrees with the
library covariance to relative error 1.72e-17. The draft validates and its twelve
mathematical expressions render with no errors, page overflow, or code overflow.

Artifacts in `build/notebook-previews/` use the
`L5b-advanced-estimation-inputs-proposal` basename (`.ipynb`, `.md`, `.html`, `.png`,
and render metrics). The preparation and rendering scripts are
`prepare-estimation-inputs-proposal.py` and `render-estimation-inputs-proposal.cjs`;
the focused numerical check is `check-estimation-inputs.jl`.

## Pending portfolio-construction proposal — not yet approved

The input-estimate subsection is saved. The next proposal replaces the short
portfolio-functions paragraph and inline definitions with two explanatory
subsections: short positions allowed, and long-only weights. It develops the
closed-form GMV weights, the excess-growth direction and normalizer κ, the
nonbinding minimum-mean growth floor for long-only GMV, and the sampled Sharpe
selection. It preserves g′ and Σ̂_g notation. A compact baseline table replaces
the two-growth-rate print line: long-only GMV mean 0.0818, growth std 2.1749;
long-only tangent grid candidate mean 0.4272, growth std 4.7718 (all inverse years).

The draft moves four functions to `src/EstimationRisk.jl`, adds source docstrings
and `docs/estimation-risk.md`, and loads the helpers from `Include.jl`. The helper
names are preserved. Asset counts are inferred from inputs; tangent functions
receive `g_f` explicitly. Corresponding call sites in the bootstrap and separate-
input experiments are updated. The only change to the approved setup prose is
to state that Include.jl loads the local portfolio functions as well as packages.
All other approved cells and later saved outputs are preserved.

The closed-form tangent helper retains negative and small nonzero normalizers.
Its new exact-zero guard raises `DomainError`, because normalization is undefined;
no default resamples were removed. The long-only tangent helper preserves the
original 31-target grid, GMV candidate, 1e-4 endpoint offset, and treatment of
solver failures. It checks that at least two target points are requested.
The prose calls this a grid approximation. Negative-normalizer cases are explicitly
minimum-Sharpe allocations and must not be relabeled maximum-Sharpe portfolios
when reviewing the subsequent tables and conclusions.

Validation: all four extracted helpers match the original functions at the
full-data baseline and three test resamples (closed forms tolerance 1e-13,
solver weights tolerance 1e-10). Both closed forms also match across 100 test
resamples drawn with a separate MersenneTwister(5660): ten have nonpositive
normalizers, and none were discarded. This test RNG differs from the notebook's
original default RNG; the initial 15-negative-normalizer notebook result is not
being revised. Additional checks use a two-asset problem and a different benchmark,
verify negative and near-zero normalizers, reject an exactly zero normalizer, and
recover analytic two-asset GMV weights. The focused test produced the baseline
table. The complete 100-resample long-only notebook workflow has not been rerun
for this pending helper extraction.

The full draft validates (46 cells, 18 code cells). All five local reference
occurrences in the proposed section resolve, including helper anchors. Fifteen
mathematical expressions render with no errors, page overflow, or code overflow.
The two PNGs were inspected and opened in VS Code.

Pending artifacts:

- `build/notebook-previews/estimation-portfolio-proposal/`: staged notebook with
  its original filename, proposed Include.jl, src/EstimationRisk.jl, and
  docs/estimation-risk.md. None of these helper/support changes is in the target yet.
- `L5b-advanced-estimation-portfolios-proposal-closed-form.png`: first preview.
- `L5b-advanced-estimation-portfolios-proposal-long-only.png`: second preview.
- `L5b-advanced-estimation-portfolios-proposal.md` and `.html`: proposed section.
- `prepare-estimation-portfolios-proposal.py`: reproducible draft preparation.
- `check-estimation-portfolios.jl`: original/extracted-helper comparison.
- `render-section-previews.cjs`: reusable local renderer; pass the HTML basename
  and ranges such as `closed-form:0:0 long-only:1:5`.

If approved, save the staged notebook and three supporting files together after
checking the current source hash above. Preserve the approval record. Next review
Task 1 bootstrap estimation, including the row-resampling assumption and standard
errors, before proceeding to sensitivity and realized wealth.

## Initial assessment

The instructor requested polishing only below 9/10. This notebook's initial score
is **8.3/10**, so it qualifies. Scores are editorial judgments.

| Dimension | Initial |
| --- | ---: |
| Technical correctness and consistency | 8.4 |
| Organization and sequencing | 8.2 |
| Narrative and interpretation | 8.2 |
| Presentation | 8.6 |
| Cognitive density and pacing | 8.0 |
| Overall | 8.3 |

Strengths: whole-row resampling preserves same-day cross-asset relationships;
serial-dependence limitation stated; GMV/tangent and constrained/unconstrained
comparisons are informative; separate mean/covariance experiments; explicit
negative-normalizer interpretation; honest distinction between ex-ante weight
dispersion and subsequently observed wealth; all main numerical results reproduced.

Priority findings:

1. Four numbered tasks conflict with the required three. Combine the present
   frontier/weight comparison and separate-input experiments under Task 2, with
   useful subsections; keep the 2025 wealth evaluation as Task 3.
2. Standard setup and source helpers need the same work as geometry. In particular,
   move helpers from cells 6, 8, 16, 20, 26, and 28 into documented source where
   appropriate, with explicit inputs instead of hidden globals. Cell 26 has two
   let blocks; separate calculation and reporting. Five code cells scroll.
3. Explain the moment estimates, four portfolio constructions, bootstrap standard
   error, dispersion measure, and normalizer before their use. A componentwise
   median need not itself be a feasible portfolio, so the distance is a descriptive
   dispersion measure rather than actual trading turnover. Keep the coarse
   maximum-Sharpe selection labeled as a grid approximation.
4. The one-input-at-a-time experiments support greater sensitivity to means for
   this design; they are not an additive decomposition of uncertainty. Replace
   claims that covariance contributes a specific fraction or that shrinkage cannot
   help the tangent calculation by itself with conclusions actually measured.
   Tangent weights depend on both means and covariance, not just which firm has
   the largest estimated mean. The GMV vertex is stable in risk more than growth.
5. Distinguish normalized inverse-covariance allocations with negative normalizers
   from maximum-Sharpe portfolios throughout tables and prose, retaining their
   intentional diagnostic role. Do not silently discard those resamples.
6. State wealth assumptions and explain that the 2025 outcome quantiles describe
   varying estimated allocations on one realized price history. They are not
   future-price prediction intervals. The singleton baseline rows do not have
   an estimated outcome distribution. Align notation and scoped retrospective
   takeaways with the current lecture.

## Checks already performed

The whole source notebook and Include.jl were read, along with the course style
references, reviewed L5b lecture, and relevant portfolio implementation. All 12
code cells executed successfully in a Julia 1.12.7 process using include_string
with the notebook path; this was not an IJulia kernel run. A temporary writable
depot was needed. Automatic precompilation reported sandbox-related ZMQ/IJulia
extension errors, but the calculations and independent assertions passed.

All 100 bootstrap draws and tables were reproduced: 15 nonpositive tangent
normalizers and two small positive normalizers. All bootstrap covariances were
positive definite (minimum eigenvalue 2.09358), maximum budget residual 4.27e-14,
and long-only weights respected bounds within solver tolerance (minimum about
-1e-8). Independent GMV terminal wealth agreed within 2.23e-16. Training/test dates
aligned across the selected firms and SPY.

The initial notebook validates without saved error outputs. Its 13 mathematical
expressions rendered without math errors or page overflow; five code cells have
horizontal overflow. The pending opening renders cleanly. No new computation was
needed for this opening-only proposal.

## Remaining sequence and preferences

Portfolio constructions and documented helpers; Task 1 bootstrap estimation;
Task 2 frontier and weight sensitivity (including separate-input experiments);
Task 3 wealth on the observed 2025 prices; three retrospective takeaways; final
validation and rescoring using the same five dimensions.

Preserve developed mathematical reasoning. Use typed variable references, compact
tables, separate calculation/reporting/plotting cells, concise figure explanations,
filled circles for points of interest, and sufficient axis ticks. Avoid unnecessary
date-assertion loops for this already-checked dataset. Put appropriate helper
functions in documented local source loaded by Include.jl. Retain exactly three
objectives, tasks, and takeaways, following the current separator rules.

## Approved opening wording — saved September 16, 2026

```markdown
# L5b Advanced: Estimation Risk in Mean-Variance Optimization

In the [frontier-geometry example](../frontier-geometry/CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb),
we treated the estimated mean growth rates and covariance as fixed inputs. Here
we examine __estimation risk__: how uncertainty in those estimates changes the
optimized portfolio weights. We repeatedly resample the 2014–2024 daily growth
observations for the same thirteen firms, estimate the inputs again, and compare
the resulting allocations. We then apply the long-only allocations to the same
observed 2025 price history to see how their different weights affect wealth.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> - **Quantify uncertainty in the inputs:** Use bootstrap resamples of complete daily growth-rate vectors to estimate uncertainty in mean growth rates and growth-rate standard deviations. Explain the assumption introduced by resampling days independently.
> - **Measure portfolio sensitivity:** Compare global minimum-variance (GMV) and tangent allocations with and without short positions, checking the conditions for the closed-form tangent solution. Vary the mean vector and covariance separately to examine sensitivity to each input.
> - **Interpret differences in realized wealth:** Evaluate the resampled long-only allocations on 2025 prices alongside portfolios fitted to all the training data, equal weights, and SPY. Distinguish the effects of changing the estimated weights from uncertainty in future market prices.

We organize the example into three tasks: resample the inputs, compare the
frontiers and weight sensitivity, and evaluate the resulting long-only portfolios
using 2025 prices.

Let's get started!

___
```

## Working artifacts

Historical review artifacts were deleted at the instructor's request. The ignored
`build/notebook-previews/` directory now contains the regenerated opening draft,
Markdown, HTML, and PNG. The approved opening matches this preview; the draft
notebook preserves all remaining source cells and outputs.

This persistent handoff is sufficient to resume if preview artifacts are removed.
