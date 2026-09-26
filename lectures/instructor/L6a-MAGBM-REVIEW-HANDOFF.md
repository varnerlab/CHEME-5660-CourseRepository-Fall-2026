# L6a multiple-asset GBM portfolio example — notebook polish

September 25, 2026. **Reviewed and complete, marked by the instructor September 26, 2026. Steps 1–4 applied and saved; final score 9.0/10. No proposals remain pending.**
The instructor requested a review/polish run in his voice, style, and
organization. The L5b snapshot of this example was reviewed and closed
September 16 at 9.2/10 ([record](L5b-MAGBM-REVIEW-HANDOFF.md)); that score
predates the September 24 density guidance, the September 25 rule against
denials of unproposed misreadings, and the move to L6a. This is a new round.

Notebook: [Simulating a portfolio with multiple asset GBM](../week-6/L6a/CHEME-5660-L6a-Example-MAGBM-Portfolio-Fall-2026.ipynb).

Initial SHA-256 (working tree; cell sources identical to `HEAD`, outputs re-run):
`c745e94b8a9ab8a80a564aeb31c437abfef65f2135a7c6f22985763b54bb1b4c`

## Initial assessment

| Dimension | Initial |
| --- | ---: |
| Technical correctness and agreement | 8.8 |
| Organization and sequencing | 8.5 |
| Narrative, voice, and interpretation | 8.2 |
| Presentation | 8.6 |
| Cognitive density and pacing | 7.4 |
| Overall editorial judgment | 8.2 |

Voice reference: the instructor's September 23 hand edits to the Dirichlet
example (commit `b0fc6ee`): bold question callouts before interpretations,
`### Check:` headings, cut unit/positive-definiteness/"does not guarantee"
caveats, derivations replaced by "As derived in the lecture", plain-words
figure readings, `# initialize -` stage comments. Also the 2025 L6b MAGBM example.

Findings:

- Broken link: the OOS example moved to `week-5/L5a/`; cell 40 still points to `week-5/L5b/`.
- Cell 31 says "As in L5b" for the portfolio growth approximation and GMV
  problem; the L6a lecture now teaches both (long-only box LO-1 with growth floor).
- Prose says "observed"; figure legends say "realized".
- Nine clause semicolons (cells 15, 19, 24, 28, 38, 45, 48, 49 ×2).
- Denials of unproposed misreadings: histogram-bin independence (cell 46 and
  code comment), median curve vs. any one path (cell 38), "parameters remain
  based on the training data" (cell 24). The fixed-parameter caveat appears in
  cells 41, 45, 48, 49 and three code comments. The closing "does not establish
  predictive accuracy" was approved September 16; instructor's call. The
  pointwise-band vs. whole-path statement is a real student trap; keep it.
- Density: 3,839 prose words vs. 2,330 in the instructor-edited Dirichlet
  example. Task 1 is 1,516 words over eight subsections; its Check is 276
  words before code. Task 3 redefines the holding period already set in Task 1.

Verified: package sampler subtracts `diag(A*A')/2` (drift correction correct);
risky-only solver uses `transpose(μ)*w >= R` (redundant growth floor correct);
all prose numbers match saved outputs; figure claims (late-year crossing of the
95th percentile, right tail) hold in the saved PNGs.

Recommended sequence: (1) mechanical fixes; (2) Task 1 density/voice pass,
calibrated on "Estimate mean growth rates and covariance" first, optional
reorder (estimates → table/heatmap → factor + drift + build → start prices →
simulate → Check); (3) Task 2; (4) Task 3 and Summary.

## Step 1 — accepted and saved September 25

The instructor accepted the mechanical fixes with one correction: "this will be
in the Week-06 bundle, so links to week-5 will NOT work." All three cross-week
links became plain-words references (cell 0: "from L5b", "the L4b trade rule";
cell 40: "The out-of-sample example in L5a"). The rule is now recorded in the
shared guide for both courses. Also applied: "As in the [L6a lecture](...)" in
cell 31; "realized" → "observed" in cell 31 and both figure legends (cells 39,
47); nine clause semicolons rewritten (cells 15, 19, 24, 28, 38, 45, 48, 49 ×2),
dropping the cell-24 clause "the fitted model parameters remain based on the
training data". The instructor said semicolons in code comments are OK; they
were left unchanged.

Validation: re-executed with nbconvert (julia-1.12, 25 s), no errors; all printed
outputs identical to the baseline; heatmap identical; only the two legend
figures changed. `nbformat.validate` passes (51 cells, 20 code); kernelspec
unchanged; no cross-week links remain; all local links resolve.
Saved SHA-256: `582d458986dd5badb6ad39ddab57f4f129e918a99e3796a22930f678ef5b5359`.

Codex check (September 25): no clause semicolons, no cross-week links, all four
references verified against their notebooks, all sentences grammatical with
meaning preserved. Cell 20's heatmap PNG is identical; only its SVG clip IDs and
output type changed on re-execution. Codex flagged the vague referent "This
comparison" in cell 48; carried to step 4 rather than applied.

Observation outside scope: `week-6/L6b/advanced/estimation-risk/...EstimationRisk...`
cell 64 links to a nonexistent `week-6/L6a/CHEME-5660-L6a-Lecture-SIM-Fall-2026.ipynb`.

## Step 2 — Task 1, accepted and saved September 25

Calibration: the instructor asked for rendered before/after PNGs rather than
terminal text ("it's hard reading this in the terminal"), then approved the
cell 13 sample (189 → 138 prose words) with "Next". Show future proposals as
side-by-side PNGs opened in VS Code.

Accepted with "Agree. Update" after reviewing the three-part preview. Task 1
prose went from 1,508 to 1,147 words (24%). Reordered to build the pieces, then
the model: estimate → table and heatmap → "Construct the price model" (bold
run-ins **Covariance factor.** and **Drift vector.**, Cholesky cell moved here)
→ starting prices → simulate → `### Check: Simulated growth rates`. Eight
subsections became six. Added `__What do we see?__` to the heatmap reading and
types on stored results. Cut the opener's motivation sentence, the
positive-definite sentence, the √Δt preview, the "held fixed in the simulation"
sentence, the three-bullet estimates list, and the duplicate check closer.
Kept all equations, function links, the covariance-diagonal bridge, the MC
standard error, and the table-to-heatmap connective sentence. No code changed.

Validation: re-executed (25 s), no errors; every code source, printed output,
and figure identical to the step-1 save under the reorder mapping; execution
counts sequential; `nbformat.validate` passes.
Saved SHA-256: `a0b467e44739d483d967fc2af9d028863d36860025d952dd34f9b9e18f154e20`.
Previews: `step2-cell13-before-after.png`, `step2-task1-part{1,2,3}.png`.

Codex check: code sources identical under the mapping; A is defined before
use and the heatmap prose no longer mentions it; drift correction, covariance
rate, volatility, and MC standard error confirmed against the package sampler;
all stated Julia types correct; cell 30 numbers match output. Four accuracy
fixes applied to the new wording (markdown only, no re-run needed): "firm order"
in cell 11; "check that the first path has `N_2025` rows" (the assert checks
`d[1]` only); the `diff` sentence restored to "apply diff to the log prices and
divide by Δt"; "largest absolute ratio". Declined: restoring the positive-definite
sentence (approved cut), splitting the original 30-word task opener, defining M
(predates this pass). Execution-metadata and SVG clip-ID differences are rerun
artifacts. Saved SHA-256 after fixes:
`4dd0bee3f3acbea338e07a4f44d9b0138f15e44602a8d8c944461a16677230d3`.

## How to resume

1. Confirm the notebook still has SHA-256 `e80f0e47…d8ae` (step 4 save after the Codex fix). If not, the
   instructor has edited it; diff against `build/notebook-previews/L6a-magbm-polish-2026-09-25/after-step4-fixes.ipynb`
   and preserve his edits.
2. Present each proposal as side-by-side before/after PNGs opened in VS Code
   (`render-rows.cjs` in the artifacts folder; copy the step-2 row-building
   code from `step2.py`/this session's pattern). Keep terminal text to a short
   change list plus PNG links. The instructor found terminal markdown unreadable.
3. Match the accepted Task 1 density (about 25% fewer prose words, voice per
   the Sept 23 Dirichlet edits). After "Agree. Update", apply, re-execute only if
   code changed, compare outputs, run the Codex check, record here.

## Step 3 — Task 2, accepted and saved September 26

Accepted with "Agree. Update. Next" after reviewing `step3-task2-part{1,2}.png`.
Markdown only (cells 31, 33, 35, 36, 38, 40), prose 870 → 687 words (21%).
GMV problem now recalled from the L6a lecture (LO-1) with the redundant-floor
explanation kept; duplicate MinVar link, weight-change restatement, repeated
"omit dividends and costs", heading-repeating transition, and the median-path
sentence cut. Types added to `w`, `shares`, and the three wealth outputs.
`__What do we see?__` added to the allocation table and wealth figure readings;
the allocation reading now ties JNJ's weight to its Task 1 volatility and
correlations. The whole-path trap is stated positively. The vague "This
comparison" in cell 40 is gone. Declined option: printing the 32% whole-year
outer-band coverage (would need a code line and re-run); not requested.

Validation: code sources and outputs unchanged, so no re-run; `nbformat.validate`
passes. A scratch run (not saved) confirmed the stated types, five weights at
about −7e-9, observed wealth above the 95th percentile on trading days 223 and
225–250, and 32% of paths inside the outer band all year.

Codex check: items 1–5, 7, 10 correct (only the six markdown cells changed;
types; solver enforces `transpose(μ)*w >= R`, sum, bounds; LO-1 match; Task 1
cell 14 checks all firms' 2025 dates against AAPL, so the SPY–AAPL check is
portfolio-wide; prose clean). Two accuracy fixes applied: cell 38 "at most
90% ..., and typically far fewer," (the intersection bound is ≤, not <) and
cell 40 "at most 5%" (exceeding an interpolated q95 guarantees ≤ 5%). Item 6
(full-precision zero weights) needed no change.
Saved SHA-256: `cd7a28864ea5f52ef528d5e07d4d8d51da13621865c612b019889400f50e142b`.

## Step 4 — Task 3 and Summary, accepted and saved September 26

Accepted with "Agree. Update. Next" after reviewing `step4-task3-part{1,2}.png`,
including the optional code comments and the Summary cut. Task 3 prose
600 → 442 words (26%); Summary 202 → 195.
Cell 41 recalls the portfolio NPV from the L6a lecture, reuses the Task 1
holding period instead of redefining it, states the fixed-parameter point once
and positively, and types `ρ_T::Vector{Float64}` and `ρ_T_actual::Float64`.
Cell 43 drops the dimensionless note. Cell 45 gets `__What do we see?__` and
the 90% range as numbers, cutting the repeated fixed-parameter sentence and
"These results depend on the selected settings." Cell 46 drops the
bin-independence denial and ties the area right of the target to p̂. Cell 48
gets `__What do we see?__` and replaces "This comparison" with the Task 1
check. Summary: the instructor accepted cutting "Reproducing its inputs does
not establish predictive accuracy" (approved September 16, cut under the
September 25 denial rule). Code comments in cells 29, 44, 47 dropped the
repeated fixed-input and bin-independence asides.

Validation: re-executed with nbconvert (25 s), no errors; every text output and
figure identical to the saved outputs after normalizing SVG clip IDs; execution
counts 1–20. The saved file keeps its existing outputs to avoid rerun churn.
`nbformat.validate` passes.
Saved SHA-256: `637de5dda1e5dc5a0d3601ac85254ac0702b7bb83a21981eaa99ff7907492e1a`.

Codex check: all eleven items correct except one: "would give a slightly
different estimate" in cell 41 overstated what is guaranteed, so it was restored
to "may give a different estimate" (markdown only). Confirmed: only the nine
listed cells changed and code changes are comments only; re-execution matches;
P-2 formula and the lecture's "extends the single-asset NPV trade rule to a
portfolio"; strict `>` and SE formula; stated types; cell 45 numbers; density
normalization; right tail (median-to-percentile distances 0.255 > 0.212);
Summary change limited to the one sentence.
Saved SHA-256 after the fix: `e80f0e47f25e0091a4f08eca31542b78899255daab215faaab7f2f86b0fdd8ae`.

## Final assessment — September 26

Self-assessed after steps 1–4; the instructor then marked the review done. The instructor's own hand edits remain the real
test (voice-calibration protocol in the shared guide).

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and agreement | 8.8 | 9.3 |
| Organization and sequencing | 8.5 | 9.0 |
| Narrative, voice, and interpretation | 8.2 | 9.0 |
| Presentation | 8.6 | 9.0 |
| Cognitive density and pacing | 7.4 | 8.5 |
| Overall editorial judgment | 8.2 | 9.0 |

Prose words (displays and URLs stripped): 4,026 → 3,293 overall (18%); the
three tasks 3,008 → 2,282 (24%). The instructor-edited Dirichlet example is
2,471. Remaining headroom: Setup, Data, and Constants (419 words, untouched this
round) and Task 1 (1,149 words, the densest task). Every initial finding is
resolved; the one kept denial is the pointwise-band trap (cell 38 prose and the
cell 39 code comment).

## Original plans for steps 3 and 4

### Step 3 plan — Task 2 (cells 31–40) (done, see above)

- Cell 31 (228 words): Task opener, then the GMV problem. Recall it from the
  L6a lecture's long-only box (LO-1) rather than re-explaining constraints;
  keep the display and the `minimum(ĝ)` redundant-floor explanation (verified:
  solver uses `transpose(μ)*w >= R`). Tighten the `μ` = `ĝ` input note and the
  build/solve narration. Add types (`w::Vector{Float64}`).
- Cell 33: share counts; keep the equation and the fractional-shares/no-costs
  assumption; `shares::Vector{Float64}`.
- Cell 35: allocation interpretation (62.8% JNJ, default qualifier).
- Cell 36: keep wealth as the sum of holding values (Sept 16 preference);
  type the three wealth outputs; trim the repeated "omit dividends and costs".
- Cell 38: pointwise bands. Keep the real student trap (a 90% band is not a
  whole-path envelope), stated positively. Cut the median-path sentence
  (unproposed misreading).
- Cell 40: open with `__What do we see?__` in plain words, as in the Dirichlet
  wealth figure. Keep the default-allocation qualifier, the reference in words
  to the L5a out-of-sample example, and the prompt to change `allocation_case`.

### Step 4 plan — Task 3 and Summary (cells 41–49)

- Cell 41 (286 words): remove the second holding-period definition (already
  set in Task 1); keep the scaled NPV equation, bold question in its own
  paragraph, p̂ and SE equations. Keep the fixed-parameters point once here.
- Cell 45: cut the repeated fixed-parameters sentence.
- Cell 46: cut "so it does not depend on how the histogram groups them into
  bins" (unproposed denial); keep the density explanation.
- Cell 48: `__What do we see?__`; fix the vague referent "This comparison"
  (flagged by Codex in step 1).
- Cell 49: closing "Reproducing its inputs does not establish predictive
  accuracy" was approved Sept 16; ask the instructor whether to keep it.
- Code comments carrying the repeated fixed-parameter and bin-independence
  denials (cells 29, 44, 47) are optional; semicolons in code comments are OK
  per the instructor.
- Final: rescore on the five dimensions against the initial 8.2, update
  AGENTS.md with a completed-review entry when the instructor marks it done.

## Preferences carried from the September 16 record

Prose `src/Compute.jl` link instead of the Include blockquote; wealth explained
by adding holding values; covariance-diagonal-to-squared-volatility bridge;
bold NPV question in its own paragraph; connective prose between table and
figure; NPV results in the compact table; each preview link in its own paragraph.

## Artifacts

`build/notebook-previews/L6a-magbm-polish-2026-09-25/` (ignored by git):
`before.ipynb`, `after-step1.ipynb`, `after-step2.ipynb` (before the four Codex
fixes), the step scripts `step1.py` and `step2.py`, the renderers
`render-sbs.cjs` and `render-rows.cjs`, the step-2 PNG previews, and the
saved figures. Codex prompts and results are in the session scratchpad and are
summarized above.
