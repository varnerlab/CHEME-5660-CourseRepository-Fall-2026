# L5b rolling correlations — completed notebook polish

**Status: reviewed and complete, confirmed by the instructor September 23, 2026**
("ok, mark this as reviewed"). Final editorial score: **9.1/10** (initial 8.3/10,
recalibrated for concision; Codex 7.8 → 8.8 before the last three fixes). No
proposals remain pending. Do not restart completed sections unless the
instructor requests another round.

**Round history.** The instructor requested a polish
round conditional on an initial score below 9/10. The first assessment gave
9.0/10. The instructor then pointed out long, sometimes confusing passages.
Reassessed with that weighting, the notebook scored **8.8/10**, and a prose
round began. One batch of edits was approved ("Agree. Update") and saved.

Notebook:
[L5b Advanced: Rolling Correlations](../week-5/L5b/advanced/rolling-correlation/CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb).

- SHA-256 at review start: `c9417f0f122162db6541a4cccb2d23e888b6bd1d546d006543aac7604f9f2bbb`
- SHA-256 after approved edits: `d8f86691ce06480c45c3e82fd61ae70fbf4077e00996182aafc2d384362f6da5`

The starting notebook was the September 14 reviewed L5a snapshot
([earlier record](L5a-ROLLING-CORRELATION-REVIEW-HANDOFF.md), 9.1/10),
relocated to L5b with only title/cross-reference and one objective wording change.

## Initial assessment

| Dimension | First pass | Reassessed |
| --- | ---: | ---: |
| Technical correctness | 9.3 | 9.3 |
| Organization | 9.2 | 9.2 |
| Narrative flow | 8.8 | 8.4 |
| Presentation | 8.9 | 8.9 |
| Cognitive density and pacing | 8.7 | 8.7 |
| Overall | 9.0 | 8.8 |

The main problem was a recurring pattern: a clear idea followed by a defensive
caveat packed into the same sentence ("it is not…", "does not, by itself…",
"Also, …; both … affect"). Thirteen clause-joining semicolons came with it.

## Approved and saved edits

Prose only, in cells 11, 16, 17, 21, 22, and 25:

- Task 1 sampling-noise paragraph: states the constant-ρ, independent bivariate
  normal assumptions first, then the standard error, then "a rough sense of
  scale rather than an error bar for our data."
- Task 2 zero-mean sentence: "This simplifies the calculation. It is not a claim
  that the assets have zero long-run growth."
- Task 2 equivalent observation count: the question is split into steps. The
  paragraph after the table explains decay time and equivalent count in plain
  terms, with the λ = 0.94 ≈ 32-day-average example.
- Task 2 comparison: names the two differences between the estimators
  (weighting, and centering only in the rolling estimate).
- Task 3 subset and summary sentences split into plain statements.

Instructor's approved Task 3 interpretation (cell 29) was deliberately left alone.

## Concision round (approved September 23, 2026)

After "Still *way, way, way** too wordy," the instructor approved a Task 2 cut
(807 → 389 words), then a scored list and "do the first 7":

1. Cell 17 equivalent-count qualifier restored (Codex caught the overstatement).
2. Standard error corrected to 0.094 ($0.75/\sqrt{63}=0.0945$).
3. Task 1 cut (730 → about 450 words), with "independent bivariate normal" and
   "opposite signs" wording restored per Codex.
4. Task 3 cut, subheadings in title case. Cell 29 (instructor's wording) untouched.
5. Opening: objectives are two sentences each, and the overview is two sentences.
6. Data and growth-rate matrix sections tightened. The redundant cell after the
   matrix code was deleted (notebook now 31 cells).
7. Summary takeaways tightened. The approved closing sentence was kept.

Prose went from 3,050 to 1,927 words, with no clause semicolons left. The 11 code
cells (source, outputs, IDs) and the metadata are byte-identical to the start of the round.
Three tasks, objectives, and takeaways each. The whole notebook was rendered and inspected.
SHA-256 after this round: `09dbe750a849a71f753c172deba1cb4e5a40682f6b4674e5868e4b6f7139aa5a`.

Scores before this round: mine 8.3, Codex 7.8 (independent run, 0–10 scale).

## Rescore after the concision round

| Dimension | Mine before → after | Codex before → after |
| --- | ---: | ---: |
| Technical correctness | 9.0 → 9.2 | 8.6 → 9.0 |
| Organization | 9.2 → 9.2 | 8.5 → 9.3 |
| Narrative flow and concision | 7.9 → 8.8 | 6.7 → 8.8 |
| Presentation | 9.0 → 9.1 | 8.5 → 8.8 |
| Cognitive density and pacing | 8.3 → 8.8 | 7.0 → 8.2 |
| Overall | 8.3 → 9.0 | 7.8 → 8.8 |

Codex found no numerical errors (it recomputed 0.094, 17/100 days, 32/199, 4,950 pairs,
62/58 overlaps, and 54 of 541 windows above the cutoff). Small open candidates from its review:
the "each needs the same 63" wording (it's a chosen initialization, not a requirement);
"can move by about 0.1" should refer to error around the true correlation; and one sentence
restoring why volatility uses √Δt. Rejected: "terminal divider" (it precedes the level-two
Disclaimer heading, which is allowed), code-comment semicolons (outside the prose rule),
and restoring the edge-case conditions for the −1 to 1 range.

## Final fixes (approved "Ok, make the three fixes")

- Task 2 figure lead-in: "because they all use the same 63-observation start."
- Task 1 standard error: "can differ from the true correlation by about 0.1."
- Task 3 volatility: added one sentence explaining the √Δt factor.

Only cells 10, 18, and 22 changed. Code is identical, the notebook validates, and the edited cells were rendered.
Final SHA-256: `fe4d950ffb103d1afd4908190e0a95c64e7aef12e1414f508bbf52f050e979cf`. Final score after the fixes: 9.1/10 (mine). Codex was not re-run after these three fixes.

## Earlier candidates (superseded by the concision round)

- Seven clause-joining semicolons remain (cells 5, 10, 15, 16, 22, 23, and the
  second takeaway).
- Task 3 subheadings use sentence case, while Tasks 1–2 use title case.
- Cell 29: "Those weights and volatilities also affect portfolio risk." reads oddly
  (instructor's wording; change only if requested).
- The L5b advanced README still describes this notebook as covering "the whole
  universe"; the notebook uses a fixed 100-asset subset. That file is outside this notebook's scope.

## Checks performed

- Recomputed quoted numbers: standard error ≈ 0.095 at ρ = 0.5, L = 63; decay
  times ≈ 17 and 100 days; equivalent counts 32 and 199; 4,950 distinct pairs;
  58 shared observations for a five-day step.
- Confirmed the L4b volatility-clustering claim and the L5b covariance-rate notation.
- After the edits: only the six target cells' `source` fields changed; code, outputs,
  cell IDs, and notebook metadata are byte-identical; nbformat validation passes.
- The edited cells were exported with nbconvert and rendered in headless Chrome
  (`build/notebook-previews/L5b-rolling-correlation-prose-edits.png`). All math renders.
- No re-execution, since the edits were prose only.
