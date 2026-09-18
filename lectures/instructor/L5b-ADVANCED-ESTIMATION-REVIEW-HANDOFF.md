# L5b advanced estimation risk — notebook polish complete

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Marked reviewed and complete by the instructor September 17, 2026. All sections
approved and saved. Final score: 9.2/10, up from 8.3/10. No proposals remain pending.**

Instructor confirmation: “Great! Mark this as reviewed.”

Notebook:
[Estimation Risk in Mean-Variance Optimization](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/estimation-risk/CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb).
Do not restart approved sections unless the instructor requests another round.
The frontier-geometry companion is also reviewed and complete.

## Final assessment

Scores are editorial judgments, not measured learning outcomes.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 8.4 | 9.3 |
| Organization and sequencing | 8.2 | 9.2 |
| Narrative and interpretation | 8.2 | 9.2 |
| Presentation | 8.6 | 9.3 |
| Cognitive density and pacing | 8.0 | 8.9 |
| **Overall** | **8.3** | **9.2** |

The final notebook follows three tasks from resampled inputs to weight
sensitivity and realized wealth. The three objectives and three retrospective
takeaways describe that same sequence. Calculations, displays, and plots are
separate, and eight documented helpers are loaded from local source.

The technical explanation now distinguishes bootstrap standard errors from
variation in daily growth rates, normalized closed-form weights from maximum-
Sharpe portfolios, a grid candidate from an exact tangent solution, and
one-input-at-a-time sensitivity from an additive decomposition. Negative
normalizers remain in the diagnostic. The median-centered weight distance is
explained without treating its center as a feasible portfolio or its value as
trading turnover. The frontier interpretation distinguishes variation in the
GMV mean from variation in its standard deviation.

The wealth section derives realized growth from continuous compounding,
explicitly substitutes W_k = W_0 R_k, cancels the fixed W_0, and applies the
log-ratio rule. The final expression and k = 1,…,K are inside one box.
Two horizontal terminal-wealth box plots answer a clear question about changing
fitted weights on the same observed prices. Baseline outcomes have their own
table instead of repeated singleton quantiles. The factual summary lead-in and
concrete L6a transition reflect the instructor's final wording preferences.

The remaining limitations are stated in the notebook: independent-day resampling
ignores dependence, B = 100 is illustrative, the long-only tangent search uses a
finite grid, and the wealth comparison uses one observed price history. These
are scope limits, not unresolved correctness failures. The notebook remains
advanced and mathematically dense; its classroom pacing still needs teaching
feedback. No further substantive revision was identified in the final pass.

## Validation and execution scope

- Final notebook: 66 cells, including 27 code cells; exactly three objectives,
  three tasks, and three takeaways. All six separators precede a new level-two
  heading. No code cell has multiple let blocks or named helper definitions.
- All 18 local links and explicit documentation anchors resolve. Include.jl
  loads the eight helpers, each with a Julia docstring describing inputs, units,
  outputs, and assumptions. No saved error outputs remain.
- Julia 1.12.7 parses all 27 final code cells and both supporting Julia files.
  The assembled notebook renders in 15 sections with 104 math expressions,
  no math errors, and no page/code overflow. All revised sections were visually
  inspected during the round; representative final sections were checked again.
- Data/setup validation reproduced G (2766 × 13), the 250 × 13 testing-price
  matrix, ticker order, constants, and baseline allocations. Both original and
  revised bootstrap workflows ran with seed 5660; all 100 means, covariances,
  and four sets of weights matched exactly. Budget/bound and covariance checks
  passed. The 26 bootstrap standard errors matched independent B−1 sums.
- All 101 frontier curves matched the original calculation, with independent
  equality-constrained KKT checks (maximum variance difference 2.49e-14).
  All 400 dispersion values matched the original; independent scalar checks
  and the non-feasible-median example passed. Fixed-input comparisons and
  all reported distance values were preserved.
- All 101 normalizer identities and signs were checked (maximum identity error
  2.60e-17). The original 15 negative and two small-positive cases were retained.
- All 204 terminal wealth ratios and sample growth-rate standard deviations
  matched the original exactly. Independent holdings/rate calculations passed
  for the 203 multi-asset paths, and SPY matched separately. Daily compounding
  reconstruction differed by at most 2.22e-16. The box plots use all 100 outcomes
  in each group, with the training-data fits marked on the common axis.

Numerical validation used Julia scripts in the course environment, including the
complete original-versus-revised bootstrap comparison. Later sections reused that
validated cache. The final prose/layout pass did not repeat the bootstrap or run
a fresh full IJulia session. Saved numerical results were preserved throughout.
Only the requested notebook, necessary local support files, and review records
were changed; unrelated slide work was left untouched. No commit was requested.

## Instructor preferences to retain

- Use simple, direct wording and tighten repetition locally without losing
  intermediate mathematical steps.
- Start the wealth-growth derivation from continuous compounding. Show the
  substitution from W to R and cancellation of the common initial wealth.
- Put the final result and its index range inside the same box.
- Give each figure a clear teaching question. Use horizontal terminal-wealth
  box plots for this comparison; identify the full-training fit with a filled
  circle. The earlier wealth-versus-variation scatter was rejected as unclear.
- In a summary, the lead-in should state what we did. Do not lead with a question
  or another motivation statement. Keep the approved three retrospective
  takeaways and the concrete transition to L6a's covariance model.

## Saved state and artifacts

Final notebook SHA-256:
`3ee9234e71c89268e2f414e5504ddfbf4147752aaa9fdbb6303c80807b010eb9`

The saved notebook matches the approved staged summary draft exactly.
Supporting files are local Include.jl, src/EstimationRisk.jl, and
 docs/estimation-risk.md. The final artifact paths below are in the ignored
build/notebook-previews/ directory and may be regenerated if cleaned:

- L5b-advanced-estimation-final.html and -offline.html: assembled notebook.
- L5b-advanced-estimation-final-<section>.png: all 15 rendered sections.
- L5b-advanced-estimation-final-metrics.json: rendering checks.
- L5b-advanced-estimation-final-checks.json: structure/link/source checks.
- check-estimation-final.py and check-estimation-final-syntax.jl: final checks.
- Earlier check-estimation-*.jl scripts and the validated bootstrap cache:
  numerical evidence recorded in the section histories below.

The historical record below retains intermediate proposals, hashes, and approval
states. References there to pending work are historical; this completed record
and the final hash above govern follow-up work.

## Historical approval and preparation record

The initial assessment is complete. The instructor approved the opening with
"Agree. Update.Next" on September 16, 2026. The setup, data, and constants were
then approved; growth observations and 2025 prices were approved conditional on
agreement with the preceding notebooks. That check passed, and all these sections
are saved. The input-estimate subsection was then approved with
"Agree. Update. Next" and saved (42 cells, 17 code cells). The approved opening and all cells following
the old setup/data section are preserved. Do not restart the approved sections.
On September 17, the instructor approved both portfolio previews: "Closed-form
weights and the normalizer => Agree" and "Long-only weights, tangent grid, and
baseline table => Agree". Both sections and their three supporting files have
been saved and match the staged draft exactly (46 cells, 18 code cells).
The instructor approved the revised standard-error section, then approved the
shorter resampling subsection with "Agree. Update. Next". All of Task 1 is now
saved exactly as reviewed (48 cells, 19 code cells), preserving all other cells.
The instructor then approved the Task 2 frontier proposal with "Agree. Update.
Next". The notebook, appended source helper, and documentation are saved exactly
as reviewed (51 cells, 20 code cells). The instructor then approved the weight
comparison and dispersion sections with "Agree. Update. Next". The staged notebook
and appended source/documentation are saved exactly (55 cells, 22 code cells).
The instructor then approved the normalizer and separate-input sections with
"Agree. Update. Next". The staged notebook is saved exactly (60 cells, 24 code
cells); supporting files are unchanged. The instructor then approved the Task 3
tables, requested a derivation from continuously compounded wealth, and found the
scatter figure unclear. The tables are saved exactly (66 cells, 27 code cells).
The instructor approved the clarified compounding derivation with “Great” and
requested a box around the final result. The boxed derivation, calculation, and
supporting source/docs are now saved exactly. The approved tables and original
figure were preserved through those edits. The instructor then approved the
horizontal box plots with “Agree. Update. Next.” All three figure cells are now
saved exactly, completing Task 3. Continue with the pending summary proposal
below. The instructor approved the revised summary with “Agree. Update. Next.”
The saved notebook matches the staged draft exactly. All sections are approved;
complete final checks and rescoring.
Use the [notebook-polish workflow](../../.agents/skills/notebook-polish/SKILL.md)
and [shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md).

Source SHA-256 after the approved complete summary:
`3ee9234e71c89268e2f414e5504ddfbf4147752aaa9fdbb6303c80807b010eb9`

Compare the source with this hash before applying further proposals; preserve any
intervening instructor changes. Historical previews were deleted at the instructor's
request. The opening preview was regenerated from the saved wording before approval.

## Summary — approved and saved September 17, 2026

The instructor approved the factual lead-in and remaining summary with
“Agree. Update. Next.” The notebook is saved exactly as reviewed. The records
below document the revision history; no summary proposal remains pending.

### Latest feedback: state what we did; conclusion approved

The instructor requested a direct account of completed work in the summary
lead-in and approved the concluding paragraph. The approved conclusion is now
saved in the target; the rest of that summary still awaits approval.

The current draft lead-in reads: “In this example, we used bootstrap resampling
to estimate uncertainty in portfolio inputs, compare GMV and tangent weights,
and evaluate the resulting long-only allocations on 2025 prices.” It replaces
the motivation-style lead-in. All three proposed takeaway items are unchanged.
The approved conclusion is identical in the target and draft. The notebooks
validate; code, outputs, and all other cells are unchanged. No numerical rerun
is needed for these prose edits. Resume with this revised summary preview.



### Lead-in and conclusion revised

The instructor found the lead-in and conclusion weak and requested revision.
Only those two paragraphs changed. The new lead-in frames the need to assess
how much the optimized portfolio depends on the data used to estimate inputs,
then connects the resampling comparison to wealth on the same 2025 prices.
The closing now describes L6a's replacement of pairwise covariance estimates
with a model driven by one market index, and checks whether shared movement
remains after removing the market effect. This is supported by the L6a lecture
sections read during preparation; it does not claim that covariance modeling
removes mean-estimation uncertainty.

All three takeaway items are unchanged, as are every other cell and supporting
file. The summary still awaits approval. The target retains the approved Task 3
hash above. The revised draft validates and the preview renders without overflow;
it was visually inspected and opened in VS Code. No numerical rerun was needed.
The previous draft is retained as
L5b-advanced-estimation-summary-before-framing-revision.ipynb.



All three tasks are approved and saved. The proposed summary replaces only cell
64. It has three retrospective takeaways aligned with the objectives and tasks:
input uncertainty, weight sensitivity, and wealth on the observed prices.
It preserves the instructor's preference for short, direct language.

The first takeaway connects whole-day resampling, standard errors, relative
precision, and the independent-days assumption. The second states the observed
GMV/constraint comparison, the separate-input sensitivity result, and the role of
the normalizer's sign. It avoids the original claims that GMV weights stay fixed
or that almost all dispersion can be attributed additively to the mean vector.
The third uses the approved terminal-wealth comparison and distinguishes spread
across fitted weights on 2025 prices from an interval for future wealth.

The closing sentence links to L6a's covariance model with fewer parameters and
its assumptions. The linked lecture's opening and covariance section were read
to verify this description; the sentence does not promise to remove estimation
risk. The disclaimer is unchanged, with the major-section separator retained
immediately before it in the full notebook.

The 66-cell staged notebook differs from the target only in Markdown cell 64.
All 27 code cells, outputs, approved sections, and the disclaimer are preserved
exactly. The draft validates; it has exactly three objectives, three tasks, and
three takeaways. All 18 local links and explicit documentation anchors resolve.
All separators precede level-two headings, code cells have at most one let block,
and there are no saved error outputs. The closing preview was visually checked
and opened in VS Code; there is no page/code overflow. No numerical rerun was
needed for this prose-only proposal.

Staged notebook SHA-256:
`3ee9234e71c89268e2f414e5504ddfbf4147752aaa9fdbb6303c80807b010eb9`

Artifacts in build/notebook-previews/:

- estimation-summary-proposal/: full staged notebook, no supporting-file changes.
- L5b-advanced-estimation-summary-proposal-summary.png: closing preview.
- The same proposal basename with .md, .html, -offline.html, -section.ipynb,
  and -metrics.json.
- prepare-estimation-summary-proposal.py: reproducible staging/render preparation.

If approved, save the staged notebook after checking the current target hash.
Then finish the narrative/technical consistency review and rescore against the
initial five dimensions. The initial overall score is 8.3/10. Do not silently
apply new substantive rewrites during final review or reopen approved sections.

## Task 3 horizontal box plots — approved and saved

The instructor approved the pending box-plot proposal with “Agree. Update. Next.”
Cells 61–63 now match the reviewed draft exactly. All other cells and supporting
files are unchanged. All of Task 3 is approved. Continue with the summary;
references below to pending Task 3 approval are historical.

## Boxed Task 3 derivation — approved and saved

Follow-up: the instructor requested including k = 1,…,K inside the box.
The index range is now boxed with the final equality in both the saved notebook
and the pending full draft. Only Markdown cell 53 changed; all calculations,
outputs, tables, and figures are unchanged.

The instructor said “Great - put a box around the final result,” approving the
clarified derivation and requesting a local formatting change. The final equality
for g_(W,k), including the log-ratio and log-difference forms, is now boxed with
LaTeX box notation. The boxed equation and all 19 math expressions render
without errors or overflow; the refreshed preview was visually checked.

Saved cells 53–54 exactly from the reviewed draft, along with the appended
buy_and_hold_statistics helper and local documentation. The existing Include.jl
already loads that source and is unchanged. All other target cells, including the
approved tables and still-unreviewed figure/closing, are preserved exactly.
No numerical rerun was needed for the box; the unchanged calculation already
matched all 204 outcomes and passed the compounding checks recorded below.

The current full staged notebook remains in estimation-wealth-revised-proposal/
with SHA-256 bc2e8ddae42adbff8c8bb0bbafa3acd61fe4e50db5aac972a9833a4715f2d5ed.
Its only differences from the saved notebook are the three pending figure cells
61–63. Supporting source/docs now match the target exactly. The calculation PNG
was refreshed and opened in VS Code. Continue with the horizontal box plots;
do not ask again for approval of the calculation or tables.

## Task 3 revision history — calculation approved; figure pending

### Latest clarification: connect wealth W to scaled wealth R

The instructor asked how ln R_k − ln R_(k−1) follows from the wealth equation.
The revised calculation preview now explicitly uses R_k = W_k/W_0 and therefore
W_k = W_0 R_k. It substitutes this at both dates, cancels the same fixed W_0,
and then applies ln(a/b) = ln a − ln b. The interpretation states that dividing
wealth by fixed initial wealth leaves the growth rate unchanged.

Only draft Markdown cell 53 changed. Code, outputs, tables, figures, source/docs,
and the target notebook are unchanged. The updated notebook validates, and the
calculation preview renders 19 math expressions without errors or overflow.
No numerical rerun was needed. The refreshed PNG was inspected and opened in
VS Code. The box plots still await approval; this feedback did not approve them.

The prior draft is saved as
L5b-advanced-estimation-wealth-before-ratio-clarification.ipynb. The edit is
reproducible with clarify-estimation-wealth-ratios.py; the main revision script
also contains the added steps. Current previews retain their previous names.



The instructor explicitly selected “Two horizontal box plots of terminal wealth”
in response to the figure-preference question. The revised draft is prepared;
only the previously approved tables have been saved to the target.

The calculation now introduces daily wealth through continuous compounding:
W_k = W_(k−1) exp(g_(W,k) Δt), then takes logs and solves for the realized
interval rate. The prose explains that each day has its own rate. Fixed-share
wealth and all calculation code match the earlier proposal; the new derivation
makes its connection to continuous compounding explicit. The local source
helper and documentation remain as previously proposed and are not yet saved.

The figure now asks how terminal wealth changes across fitted weights. Two
horizontal boxes use the same terminal-wealth axis: GMV above tangent grid.
Each box spans the middle half of its 100 wealth ratios; the median, 1.5-IQR
whiskers, and outside points are explained. Black filled circles identify the
training-data fits. The prior scatter plot is superseded. The interpretation
connects the narrower GMV spread and wider tangent spread to weight estimation,
while keeping the observed-price-history scope clear.

Validation: the saved original wealth calculation, with its mechanical label/
field changes, agrees exactly with the proposed source-helper calculation for
all 204 outcomes. Reconstructing daily wealth using the exponential relation
agrees for all 203 multi-asset paths, with maximum error 2.22e-16. Both boxes
use all 100 terminal ratios from their respective approved table groups, and
all samples and fitted points fit within the common axis. No bootstrap or
optimization rerun was needed. The 66-cell staged notebook validates, the
local helper anchor resolves, all approved cells and tables are preserved,
and source/docs only append the helper. Both previews and the standalone figure
were visually inspected. Twelve math expressions render without errors or
page/code overflow. The PNG previews were opened in VS Code.

Staged notebook SHA-256:
`bc2e8ddae42adbff8c8bb0bbafa3acd61fe4e50db5aac972a9833a4715f2d5ed`

Current artifacts in build/notebook-previews/:

- estimation-wealth-revised-proposal/: current staged notebook, appended source/
  docs, and unchanged Include.jl copy.
- L5b-advanced-estimation-wealth-revised-calculation.png: revised derivation.
- L5b-advanced-estimation-wealth-revised-figure.png: revised box-plot section.
- The revised basename with .md, .html, -offline.html, -section.ipynb,
  and -metrics.json.
- L5b-advanced-estimation-terminal-wealth-boxplots.png and .svg: figure.
- revise-estimation-wealth-proposal.py and check-estimation-wealth-revision.jl:
  reproducible preparation and checks.

If approved, save the revised staged notebook and appended source/docs together
after checking the current target hash. Include.jl is unchanged. Preserve the
six approved table cells exactly. Then review the summary and do final checks
and rescoring. Earlier wealth proposals below are historical.

## Task 3 feedback and partial approval — September 17, 2026

The instructor approved “Resampled results and baseline tables.” Saved cells
55–60 match those six staged cells exactly. Supporting source/docs are unchanged.
The original oos calculation keeps its math and has only field/label updates
needed by the approved tables; the old combined display block is removed.
The old plot receives the same field/label updates so it remains executable.
Its image and interpretation are unchanged pending a clearer replacement.

For “Calculation and assumptions,” the instructor requested starting from
W = W_0 exp(g_W Δt) and solving for g_W to align with continuous compounding.
The revision should show the interval form W_k = W_(k−1) exp(g_(W,k) Δt),
then solve for its realized rate; retain fixed-share wealth and distinguish an
interval rate from a constant rate fitted over the full holding period.

The instructor found the scatter figure unclear and subsequently selected two
horizontal terminal-wealth box plots. The revised previews are recorded above.

The original full draft is preserved as
L5b-advanced-estimation-wealth-before-feedback.ipynb in build/notebook-previews.
The following original proposal record is historical; its tables are approved,
but its calculation and figure need revision.

## Pending Task 3 wealth proposal — September 17, 2026

The instructor approved and saved the normalizer and separate-input sections.
The next proposal covers the full 2025 wealth comparison in three previews:
calculation, tables, and figure/interpretation. The target remains at the approved
hash above. The prose uses short, direct sentences and preserves the distinction
between weight uncertainty and future price uncertainty.

The heading is now Task 3, completing the promised three-task organization.
The opening develops buy-and-hold wealth from initial shares w_i W_0 / S_i(0),
uses R_t = W_t/W_0, and explains that shares stay fixed while weights change.
It states fractional-share, dividend, trading-cost, tax, and discounting assumptions.
The 250 price records give 249 growth observations; the sample standard deviation
uses denominator 248 and has units of inverse years. All portfolios use the same
observed 2025 history, with no 2025 outcomes used in fitting the weights.

A documented buy_and_hold_statistics(prices,w,Δt) helper moves the existing
wealth/statistics formulas into src/EstimationRisk.jl. It returns the full wealth
ratio path, terminal ratio, and sample growth-rate standard deviation. Its local
documentation anchor covers dimensions, units, assumptions, and outputs.
Include.jl already loads this source and is unchanged. The oos table retains
all 204 outcomes with clearer portfolio names and terminal_ratio replacing W_T.

Calculation, summaries, table displays, and plotting occupy separate cells.
The two resampled groups retain the original median, 5th-percentile,
95th-percentile, and median-standard-deviation values. The four single baseline
outcomes are displayed separately, without duplicated quantiles. The unrounded
wealth_summary remains available; rounding applies only to display copies.
Connective prose explains the two tables and introduces the figure.

All 204 plotted coordinates are unchanged. Every marker is a filled circle;
baselines use larger, opaque circles with a thin white outline. The tangent
labels identify grid candidates. The risk axis spans 1.5–7.0 with ticks every
0.5; terminal ratios span 1.1–1.65 with ticks every 0.1. All points fit within
the axes. The interpretation describes the tight GMV cluster and wider tangent
outcomes, while limiting the comparison to this observed history.

Validation: all 204 terminal ratios and sample standard deviations exactly match
the original expressions. Independent fixed-share holdings and scalar sample-
standard-deviation calculations agree for all 203 multi-asset portfolios.
SPY matches its original calculation. All 16 retained table values match the
original outputs. A small known fixed-share example and constant-price case
pass. The validated bootstrap cache was reused; no resampling or optimization
was rerun. The notebook validates; the helper anchor resolves. The three previews
render ten mathematical expressions without errors or page/code overflow.
All previews and the standalone figure were visually inspected and opened in
VS Code.

The staged notebook has 66 cells and 27 code cells. It replaces saved cells
53–57 with eleven proposal cells. Approved cells 0–52 and the closing summary
and disclaimer are preserved exactly. The source/docs changes only append the
new helper. The summary still contains unreviewed claims and is the next section.

Staged notebook SHA-256:
`b9f78a4a81bf4028c68de5d7323427b19f4014df7a34fa791543551152989fd9`

Artifacts in build/notebook-previews/:

- estimation-wealth-proposal/: staged notebook, appended source/docs, unchanged
  Include.jl copy.
- L5b-advanced-estimation-wealth-proposal-calculation.png: first preview.
- L5b-advanced-estimation-wealth-proposal-tables.png: second preview.
- L5b-advanced-estimation-wealth-proposal-figure.png: third preview.
- The same proposal basename with .md, .html, -offline.html, -section.ipynb,
  and -metrics.json.
- L5b-advanced-estimation-wealth-plot.png and .svg: standalone figure.
- L5b-advanced-estimation-wealth-resampled-table.txt and
  L5b-advanced-estimation-wealth-baseline-table.txt: regenerated tables.
- prepare-estimation-wealth-proposal.py, estimation-wealth-helper.jl, and
  check-estimation-wealth.jl: reproducible staging/source/validation.
- inspect-estimation-wealth.jl and L5b-advanced-estimation-wealth-before.png:
  range inspection and original-figure comparison.

If approved, save the staged notebook and appended source/docs together after
checking the current hash. Include.jl is unchanged. Then review the summary,
retain exactly three retrospective takeaways, and complete consistency checks
and final rescoring. Do not restart approved sections.

## Approved normalizer and separate-input sections — saved September 17, 2026

The instructor approved both previews with "Agree. Update. Next". The staged
notebook is saved exactly; supporting files are unchanged. The preparation
record below is historical. Continue with the 2025 wealth comparison.

The instructor approved and saved the preceding weight-comparison and dispersion
sections. The next two previews cover the normalizer diagnostic and the comparison
with one estimated input held fixed. The target remains at the approved hash above.

The first subsection connects the normalizer to the frontier coefficients:
κ = b − a g_f = a(g′_GMV − g_f). Because a > 0, its sign matches the estimated
GMV excess growth. The normalizer has units of years. The full-data value is
0.009100935625051623 years. A compact table groups all 100 resamples into 15
nonpositive, two small positive, and 83 other positive values. The small-positive
cutoff remains κ₀/10 and is described as a chosen reference, not the condition for
a maximum-Sharpe portfolio. All 15 nonpositive values are negative; there are no
zero normalizers. The interpretation identifies the negative cases as minimum-
Sharpe allocations retained for sensitivity analysis. The calculation is saved
in normalizers::NamedTuple, with a separate reporting cell.

The second subsection is now part of Task 2 under “Vary one input at a time.”
It explains what stays fixed, reuses the same 100 resamples, retains normalized
weights with negative normalizers, and uses each experiment's own median vector.
The unrounded input_dispersion::DataFrame is separate from its display copy.
All six reported values remain unchanged: mean distances 48.497, 37.507, 1.730
and median distances 7.102, 7.273, 1.507 for both inputs, means only, and covariance
only. The conclusion states the observed sensitivity without claiming additive
contributions or drawing conclusions about untested covariance shrinkage.

The staged notebook has 60 cells and 24 code cells. It replaces current cells
43–47 with ten proposal cells. Approved cells 0–42 and later cells 48 onward
are preserved exactly. Supporting files are unchanged. The old wealth heading
still says section 4; rename it Task 3 during that section's own review.

Validation: all 101 normalizers satisfy the GMV identity and sign check; maximum
absolute identity error is 2.60e-17. The diagnostic counts and both fixed-input
weight matrices agree with the original calculations. All six rounded distances
are unchanged. The validated bootstrap cache was reused without rerunning any
portfolio optimization. Both notebooks validate, the local function anchor
resolves, and the previews render nine mathematical expressions without errors
or page/code overflow. Both PNGs were visually inspected and opened in VS Code.

Artifacts in build/notebook-previews/:

- estimation-normalizer-proposal/: staged notebook only.
- L5b-advanced-estimation-normalizer-proposal-normalizer.png: first preview.
- L5b-advanced-estimation-normalizer-proposal-inputs.png: second preview.
- The same proposal basename with .md, .html, -offline.html, -section.ipynb,
  and -metrics.json.
- L5b-advanced-estimation-normalizer-table.txt and
  L5b-advanced-estimation-input-dispersion-table.txt: regenerated output.
- prepare-estimation-normalizer-proposal.py and check-estimation-normalizer.jl:
  reproducible staging and numerical checks.

If approved, copy only the staged notebook after checking the current hash.
Then review Task 3, the 2025 wealth comparison, followed by the summary and final
consistency checks/rescoring. Do not restart approved sections.

## Approved weight comparison and dispersion — saved September 17, 2026

The instructor approved both previews with "Agree. Update. Next". The notebook,
appended source helpers, and documentation are saved exactly as reviewed.
Include.jl is unchanged. The following preparation record is historical;
resume with the normalizer diagnostic and separate-input comparison.

The next proposal covers the long-only box plots and the distance summary table.
It retains short, direct prose. The first preview explains boxes, medians,
whiskers, and dots. Both panels now use the notebook's ticker order and the same
weight scale, with labels identifying the tangent selection as a grid candidate.
All weight samples are unchanged. The box-plot reference now points to the
actual StatsPlots boxplot/dotplot/violin section; its whisker convention was
checked against the installed package source.

The second preview defines each asset's median weight and the sum of absolute
deviations D_b. Each method uses its own median vector. The prose distinguishes
dispersion from trading turnover because a componentwise median need not sum
to one. It explains that tangent selection depends on both means and covariance,
replacing the original attribution to whichever firm has the largest mean.

The `distances(W)` and `dispersion(W)` helpers move to documented local source;
their calculations are unchanged. The proposed `weight_dispersion::DataFrame`
retains unrounded results, with a separate display cell. The normalized
closed-form row is labeled "Normalized excess-growth weights" and explicitly
includes negative normalizers. All 12 numeric table entries are unchanged.

The normalizer code is split out of the old combined table cell, with its
original calculation and printed output preserved. Its explanatory paragraph
and all later sections remain for their own review. In particular, that pending
paragraph still needs the distinction between normalized weights and maximum-
Sharpe portfolios. Do not mistake it for approved wording.

The full staged draft has 55 cells and 22 code cells. Current cells 36–39 are
replaced by seven proposal cells and one preserved normalizer code cell.
Approved cells 0–35 and original cells 40 onward are preserved. The source
notebook remains at the approved frontier hash above. Existing source/doc
content is preserved, with the two new helpers and anchors appended; Include.jl
is unchanged.

Validation: all 400 distances exactly match the original expression, and an
independent scalar calculation agrees at 1e-14 tolerance. All 12 rounded table
entries match the saved values. A three-asset example verifies that individually
feasible portfolios can have a median vector summing to zero; the reported
distances are one. All 26 ticker groups retain their original samples. The
preserved normalizer calculation still gives 15 nonpositive and two small
positive normalizers. The validated bootstrap cache was reused; no resampling
or portfolio optimization was rerun. The notebook validates and both local
function anchors resolve. Both previews and the standalone figure were visually
inspected; eight mathematical expressions render without errors and there is
no page/code overflow.

Artifacts in `build/notebook-previews/`:

- `estimation-weights-proposal/`: staged notebook, appended source/docs, and
  unchanged Include.jl copy.
- `L5b-advanced-estimation-weights-proposal-boxplots.png`: first preview.
- `L5b-advanced-estimation-weights-proposal-dispersion.png`: second preview.
- The same proposal basename with `.md`, `.html`, `-offline.html`,
  `-section.ipynb`, and `-metrics.json`.
- `L5b-advanced-estimation-weights-plot.png` and `.svg`: figure.
- `L5b-advanced-estimation-dispersion-table.txt`: regenerated numeric table.
- `prepare-estimation-weights-proposal.py` and `estimation-dispersion-helpers.jl`:
  reproducible draft/source preparation.
- `check-estimation-weights.jl`: numerical/grouping checks and figure generation.
- `L5b-advanced-estimation-weights-before.png`: original figure for comparison.

If approved, save the staged notebook and appended source/documentation together
after checking the current hash. Next review the normalizer diagnostic and the
separate-input experiment, combining the latter into Task 2. Task 3 remains the
2025 wealth comparison, followed by takeaways and final checks/rescoring.

## Approved Task 2 frontier comparison — saved September 17, 2026

The instructor approved both previews with "Agree. Update. Next". The staged
notebook, src/EstimationRisk.jl, and docs/estimation-risk.md are saved exactly.
Include.jl is unchanged. The following preparation record is historical;
resume at the weight comparison and dispersion measure.

The next proposal covers the Task 2 opening and efficient-frontier comparison.
It does not yet revise the weight box plots, dispersion/normalizer diagnostics,
or separate-input experiment. The instructor's recent preference is tight prose
with simple, direct words; retain the approved Task 1 sections.

The proposal introduces the estimated frontier coefficients a, b, c, d and
minimum-variance formula, then identifies the GMV point and efficient branch.
It uses the reviewed lecture/geometry notation g′ and Σ̂_g. A documented
`hyperbola(g, Σ; maximum_growth = 0.6, number_of_points = 80)` helper moves the
existing local function to src/EstimationRisk.jl. It infers the asset count,
exposes the target limit and grid size, and returns named vectors σ and g.
The existing Include.jl already loads this source, so no setup change is needed.
A new local documentation anchor describes arguments, units, return values,
and assumptions. Existing source/doc content is preserved.

The calculation and plotting cells are separate. The figure retains the same
101 curves and 80 targets per curve, marks all GMV points with filled circles,
uses estimated mean growth on the vertical axis, and extends the risk axis to
7.5 so all endpoints at g = 0.6 are visible. The largest endpoint risk is 7.15794.
The revised interpretation explains that GMV standard deviation is relatively
stable while estimated mean growth changes visibly; it avoids the original
claim that the vertex barely moves. Across the 100 resamples, GMV standard
deviation spans 2.02735–2.29058 and estimated mean spans 0.0006803–0.168931,
both in inverse years. Both estimated inputs change in this experiment.

The staged notebook has 51 cells and 20 code cells. It replaces current cells
31–32 with five cells and removes only the obsolete frontier interpretation
and "Now the weights" lead-in from the following paragraph. The remaining
weight-comparison introduction is preserved for its own review. Approved cells
0–30 and all later code/results remain unchanged. The target notebook remains
at the approved Task 1 hash above.

Validation: all 101 curves exactly match the original 80-point computation.
Independent equality-constrained KKT solves at three points per curve confirm
budgets, target growth, and variance; maximum variance difference is
2.49e-14. GMV endpoints agree with the separate GMV helper. A two-asset case,
custom target/grid arguments, and invalid-argument guards were checked. The
validated bootstrap cache was reused; the bootstrap was not rerun. The notebook
validates, both local references resolve, and the ten mathematical expressions
render without errors. The figure and both section previews were visually
inspected; there is no page or code overflow.

Artifacts in `build/notebook-previews/`:

- `estimation-frontier-proposal/`: staged notebook and appended
  src/EstimationRisk.jl and docs/estimation-risk.md; Include.jl is an unchanged copy.
- `L5b-advanced-estimation-frontier-proposal-calculation.png`: task opening,
  frontier formula, and calculation preview.
- `L5b-advanced-estimation-frontier-proposal-figure.png`: plot and interpretation.
- The same proposal basename with `.md`, `.html`, `-offline.html`,
  `-section.ipynb`, and `-metrics.json`.
- `L5b-advanced-estimation-frontier-plot.png` and `.svg`: standalone figure.
- `prepare-estimation-frontier-proposal.py` and `estimation-frontier-helper.jl`:
  reproducible staged draft/source preparation.
- `check-estimation-frontier.jl`: numerical validation and plot generation.
- `inspect-estimation-frontiers.jl`: endpoint range check.
- `L5b-advanced-estimation-frontier-before.png`: original figure for comparison.

If approved, save the staged notebook and the appended source/documentation
files together after checking the target hash. Include.jl needs no change.
Next review the long-only weight comparison and dispersion measure, then the
normalizer diagnostic and separate-input experiment within Task 2.

## Task 1 — approved and saved September 17, 2026

The standard-error section and final shorter resampling subsection are both
approved and saved. The current source hash is at the resume point above.
The preparation history below records the separate approvals and validation;
references to pending Task 1 approval are historical.

### Latest feedback and saved/pending split — September 17

The instructor said "Revised resampling section => Tighten" and "Revised
standard-error section => Agree". The approved standard-error cells from the
draft replaced the old table/introduction/interpretation cells in the target.
The target now has 48 cells and 19 code cells. Cells 26–30 contain the approved
standard-error section; cells 24–25 still contain the original resampling
prose and loop. All other cells and support files are preserved.

The new resampling draft removes the repeated introductory paragraph, merges
the whole-row explanation, and shortens the assumption and result-storage
paragraphs. It retains independent equal-probability row draws, replacement,
same-day firm pairing, the common-distribution assumption, temporal-dependence
limitation, block-bootstrap comparison, array dimensions, B = 100, and the
negative-normalizer diagnostic. Its prose is 239 words versus 299 in the
previous preview; this was a localized revision following the repeated request,
not a notebook-wide reduction target.

The current full draft differs from the target only in cells 24–25. The proposed
bootstrap code matches the previously validated code exactly. Approved standard-
error cells are copied directly from the saved notebook by the preparation
script; do not revise them again. The current draft and source both validate.
No numerical rerun was needed for this prose-only change. The refreshed
resampling PNG renders seven math expressions without math errors or page/code
overflow. The prior full draft is retained as
`L5b-advanced-estimation-bootstrap-before-second-tightening.ipynb`.

Review only `L5b-advanced-estimation-bootstrap-proposal-resampling.png` now.
If approved, save the full draft after checking the current source hash above;
the approved standard-error section and all later cells already match exactly.

### Earlier wording feedback and revised previews

The instructor requested: "Resampling complete days and its assumptions =>
tighten the language, use on simple, direct words and phrases" and "Standard
errors, results table, and interpretation => Looks great content wide, just make
sure the lamguage is tight". The standard-error content is endorsed; retain its
explanation, equations, table, and interpretation.

Both preview sections now use simpler wording and localized cuts. Examples:
"row numbers" instead of "row indices", "links between nearby days" instead
of "serial dependence", and "too small or too large" instead of "understate
or overstate". The independence assumption explicitly concerns different days;
whole-row sampling still keeps firms' same-day observations together. The
standard-error explanation removes repetition and uses shorter sentences while
retaining the distinction from daily growth variation.

Only draft Markdown changed. Equations, all code cells, outputs, and other
sections match the preceding draft; the target retains the approved portfolio
hash above. No Julia rerun was needed for this prose-only revision. Both PNGs
were regenerated with the same names, and both render without math errors or
page/code overflow. The earlier draft is retained under the
`L5b-advanced-estimation-bootstrap-before-tightening` basename for comparison.

### Initial Task 1 proposal and numerical validation

The initial Task 1 proposal replaced then-current cells 24–28. All earlier
approved cells and later sections/outputs were preserved. The full draft had
48 cells and 19 code cells. Its standard-error portion has since been saved;
use the current saved/pending split and source hash above.

Two previews cover the proposal:

- `L5b-advanced-estimation-bootstrap-proposal-resampling.png`: explicit task
  opening, whole-row resampling with replacement, independence and common-
  distribution assumption, comparison with block resampling, result dimensions,
  and the existing bootstrap loop with one assignment per line and clearer comments.
- `L5b-advanced-estimation-bootstrap-proposal-standard-errors.png`: standard
  error as precision of a fitted quantity, the bootstrap B−1 formula, distinction
  from daily growth-rate variation, separate calculation/reporting cells, the
  unchanged table, and interpretation of N versus B.

The calculation retains B = 100, the default RNG/seed, the same order of draws
and solver calls, all four allocations, all original `boot` fields, and negative
normalizers. It adds `input_uncertainty::DataFrame` to retain unrounded estimates
and standard errors; rounding occurs on a display copy. The redundant count-only
print is omitted. No new helper/source changes are proposed for Task 1.

Validation: executed both the saved and proposed calculation, each after seed
5660, using the course environment and Julia 1.12.7. All 100 sample means,
covariances, and four weight matrices match exactly. All covariances are positive
definite and the long-only budgets/bounds hold within solver tolerance. The
15 nonpositive normalizers remain present. The two printed tables match exactly.
All 26 bootstrap standard errors agree with independent B−1 sums at relative
tolerance 1e-14. This also exercises the approved extracted helpers over the full
100-resample long-only workflow. It is a Julia script execution, not an IJulia run.

The draft validates; the source has no diff-check errors. Both previews were
visually inspected and contain 18 mathematical expressions in total, with no
math errors or page/code overflow. The Julia std function anchor was verified
against official documentation; Merton's 1980 reference was checked against its
NBER record and published-version entry. The existing DOI citation is retained.

Artifacts in `build/notebook-previews/`:

- `L5b-advanced-estimation-bootstrap-proposal.ipynb`: full draft.
- The same basename with `.md`, `.html`, `-offline.html`, `-section.ipynb`,
  `-metrics.json`, and the two PNG suffixes above.
- `prepare-estimation-bootstrap-proposal.py`: draft/HTML preparation.
- `check-estimation-bootstrap.jl`: complete saved-versus-proposed comparison.
- `L5b-advanced-estimation-bootstrap-table.txt` and `-original-table.txt`:
  matching rendered table text.
- `L5b-advanced-estimation-validated-bootstrap.jls`: validated arrays and
  baseline data, reusable for later figure/sensitivity/wealth proposals without
  rerunning the bootstrap. Load with Julia Serialization in the course environment.

If approved, apply the full bootstrap draft after checking the source hash and
preserve all approved portfolio/source files. Next review Task 2 frontier and
weight sensitivity, incorporating the separate-input experiment as a subsection.

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

## Approved portfolio constructions — saved September 17, 2026

The instructor approved both regenerated previews. The notebook, Include.jl,
src/EstimationRisk.jl, and docs/estimation-risk.md were saved together, with
byte-for-byte agreement with the staged draft. The source hash at the resume
point above is current. The following preparation history records what was
reviewed and validated; its references to pending approval are historical.

### September 17 resume and regenerated artifacts

The instructor requested finishing this notebook polish run. The notebook still
matches SHA-256 `41247fba07d644b3ffea1501de412c6494230a18c6313941ea5d50c219472af0`.
The opening, setup/data, and input estimates remain approved. The repository's
older summary that said to resume at the opening was stale and has been corrected.

The prior preview files were no longer present. The pending portfolio proposal
was reconstructed from this record in `build/notebook-previews/`, retaining the
same scope and numerical behavior. This is a regenerated proposal, not a claim
of byte-for-byte recovery of the deleted draft. The target notebook, Include.jl,
and source files have not been changed for this proposal.

The current draft has 46 cells and 18 code cells. Its two subsections explain
the GMV and normalized excess-growth weights with short positions allowed, then
the long-only optimization and tangent grid selection. It uses
`w_norm` in mathematical notation for the normalized allocation so a negative
normalizer is not labeled a maximum-Sharpe portfolio. The staged source includes
four documented helpers with explicit benchmark arguments; the staged setup file
loads them. The baseline comparison table was generated by Julia.

Repeated focused validation in Julia: the baseline and 100 closed-form resamples
match the original exactly; the baseline and three long-only resamples also match
exactly. The separate `MersenneTwister(5660)` check again has ten nonpositive
normalizers and discards none. Analytic two-asset GMV, negative and near-zero
normalizers, exact-zero rejection, and an explicit alternate benchmark were
checked. This does not replace the original notebook's 15-nonpositive-normalizer
result, and the full 100-resample long-only workflow was not rerun.

Seven local reference occurrences resolve. Approved cells are preserved except
the proposed one-sentence setup adjustment about loading local helpers. Later
prose and saved outputs are preserved; tangent call sites supply the new explicit
benchmark argument. The two previews render 20 mathematical expressions with
no math errors or page/code overflow. Julia syntax highlighting is enabled.

Current artifacts supersede the earlier renderer/preparation references below:

- `estimation-portfolio-proposal/`: staged notebook, Include.jl,
  src/EstimationRisk.jl, and docs/estimation-risk.md.
- `L5b-advanced-estimation-portfolios-proposal-closed-form.png` and
  `L5b-advanced-estimation-portfolios-proposal-long-only.png`: review previews.
- `L5b-advanced-estimation-portfolios-proposal.md`, `.html`, `-offline.html`,
  `-section.ipynb`, and `-metrics.json`: section sources and rendering checks.
- `prepare-estimation-portfolios-proposal.py`: rebuilds the draft using the
  staged source helper file; preserves the baseline output when present.
- `check-estimation-portfolios.jl` and
  `L5b-advanced-estimation-portfolios-baseline.txt`: numerical check and output.
- `render-section-previews.py`: isolated local Chrome renderer, using installed
  MathJax and blocking HTTP/HTTPS requests. Chrome requires sandbox escalation.

Resume by obtaining feedback on these two portfolio previews. If approved, save
the staged notebook and its three supporting files together after checking the
target hash. Then proceed to Task 1 bootstrap estimation.

### Original pending-proposal record — September 16

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

In the [frontier-geometry example](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/frontier-geometry/CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb),
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
