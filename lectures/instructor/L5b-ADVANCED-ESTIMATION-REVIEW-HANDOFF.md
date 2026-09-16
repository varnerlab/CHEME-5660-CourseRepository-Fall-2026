# L5b advanced estimation risk — paused notebook polish

**Status: paused at the instructor's request, September 16, 2026. Not complete.**

Next notebook:
[Estimation Risk in Mean-Variance Optimization](../week-5/L5b/advanced/estimation-risk/CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb).
The instructor requested stopping for a while and returning to this notebook.
The frontier-geometry companion is already reviewed and complete at 9.2/10;
do not reopen its approved sections.

## Resume point

The initial assessment is complete. No estimation-risk sections have been approved
or saved. The source notebook remains unchanged: 32 cells, 12 code cells.
An opening proposal replacing only cell 0 was presented and remains pending.
On return, show that opening again for feedback, then continue section by section.
Do not interpret the pause or the frontier completion as approval of this draft.
Use the [notebook-polish workflow](../../.agents/skills/notebook-polish/SKILL.md)
and [shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md).

Source SHA-256 at pause:
`8f04a79a75faa306722e738e432aa66847729c2f12bd6025319309d073e7f57f`

Compare the source with this hash before applying the pending draft; preserve any
intervening instructor changes. Preview files are disposable and may be regenerated
from the wording saved below. All cells after cell 0 in the existing draft match
the unchanged source.

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

Opening feedback; setup/data and documented helpers; Task 1 bootstrap estimation;
Task 2 frontier and weight sensitivity (including separate-input experiments);
Task 3 wealth on the observed 2025 prices; three retrospective takeaways; final
validation and rescoring using the same five dimensions.

Preserve developed mathematical reasoning. Use typed variable references, compact
tables, separate calculation/reporting/plotting cells, concise figure explanations,
filled circles for points of interest, and sufficient axis ticks. Avoid unnecessary
date-assertion loops for this already-checked dataset. Put appropriate helper
functions in documented local source loaded by Include.jl. Retain exactly three
objectives, tasks, and takeaways, following the current separator rules.

## Pending opening wording — not yet approved

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

The ignored `build/notebook-previews/` directory contains:

- `L5b-advanced-review-state.json`: detailed state and frontier approval history.
- `L5b-advanced-initial-assessment.md`: initial assessment and numerical evidence.
- `L5b-advanced-estimation-opening-proposal.ipynb`: cell-0 draft only.
- `L5b-advanced-estimation-opening-proposal.png`: rendered opening shown in VS Code.
- `L5b-advanced-estimation-opening-proposal.html`: corresponding full draft render.

This persistent handoff is sufficient to resume if preview artifacts are removed.
