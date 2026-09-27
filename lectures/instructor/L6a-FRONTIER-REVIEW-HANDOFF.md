# L6a advanced frontier geometry — notebook polish

September 25, 2026. **All six proposals accepted and applied September 26; final score 9.0/10. The remaining items were resolved September 27 (section 7), and the instructor marked the notebook reviewed and complete the same day. No proposals remain pending.**
The instructor requested a polish pass conditional on an initial score below
9/10. The initial score is 8.2/10, so the round proceeds section by section.
The completed L5b review ([record](L5b-ADVANCED-FRONTIER-REVIEW-HANDOFF.md))
describes the archived pre-pivot snapshot; this is a new review of the relocated
L6a notebook under the September 24 density guidance and the September 25
no-denials rule. That record's mathematical correction (the two bounded feasible
sets are not nested; the 50% position limit binds again at 0.50) still holds.

Notebook: [Frontier Geometry and the Two-Fund Theorem](../week-6/L6a/advanced/frontier-geometry/CHEME-5660-L6a-Advanced-FrontierGeometry-Fall-2026.ipynb)

Initial SHA-256:
`d3114e4331b8da83a0ae9b294e97fdf13fcad48ad6473f9497434ca50c4a21e6`

## Initial assessment

| Dimension | Initial |
| --- | ---: |
| Technical correctness and agreement | 8.0 |
| Organization and sequencing | 8.6 |
| Narrative flow and interpretation | 8.5 |
| Presentation | 8.2 |
| Cognitive density and pacing | 7.5 |
| Overall | 8.2 |

Strengths: the derivation is correct and complete (multipliers, the
Cauchy–Schwarz argument for d > 0, completed square, mixing weight, growth of
the mixture). It is the only place the lecture's boxed frontier variance (F-3)
is derived; the GMV companion covers only the budget-constrained problem. The
solver checks cover both branches, the three figures read clearly, and the
non-nested constraint comparison is handled correctly. A fresh execution
reproduces every stored number.

Held back by:

- **Stale after the L5b to L6a move.** Both estimation-risk links (cells 64, 65)
  point to a nonexistent L6a path; the notebook is in L6b. Cell 47 links "the
  lecture's risk-free-asset assumptions" to the L6a lecture, which has no
  risk-free material (it is in L6b). The move's global `L5b`→`L6a` text
  replacement also rewrote base64 image data: the stored PNGs in cells 30 and 58
  do not decode (verified byte-for-byte against a fresh run). They display only
  where a renderer falls back to the SVG. Only this week-6 notebook is affected.
  Most code cells have null execution counts and render as `In [ ]:`.
- **Claims without displayed support.** Cell 64 states the unconstrained GMV's
  61.6% JNJ weight, the 53.9% position at 0.50, and that weights meet the cap at
  0.30 and 0.40. No cell displays any weight, and takeaway 3 says "Inspecting the
  weights showed…". The values are correct (recomputed: 0.6155, 0.5387, 0.4642,
  0.4315).
- **Density.** About 3,950 prose words, the heaviest L6a notebook (the data
  example opened at about 3,000 and was flagged). Announce/show/restate around
  each table (cells 24→26, 36→38, 40→42); setup re-derives the sample mean and
  covariance (224 words, two displays); the helper paragraph in cell 22 runs
  193 words.
- **Format rules.** Takeaways contain equations and run four sentences (the
  September 23 rule is conceptual, no equations). Twelve clause semicolons.
  Task 3 has no "In this task" opener. Lead-in colons in cells 17 and 26 point to
  another prose cell. Task 2 drops into `###` after two sentences.

Recommended sequence:

1. Correctness and integrity: links, L6b reference, display the weights behind
   the cap claims, re-execute to repair the PNGs and execution counts.
2. Density calibration on Task 1 (the representative section).
3. Setup and input estimation: compress the recall of sample mean and covariance.
4. Task 2: opening paragraph, table narration, closing.
5. Task 3: opener and interpretation (optional: direct solves instead of
   interpolation at the five comparison targets).
6. Summary: conceptual takeaways without equations; semicolon and
   code-comment denial sweep.

## Accepted sections

1. **Correctness and integrity** (accepted September 26, "Agree. Update. Next.").
   The September 25 draft linked into L6b (cross-week rule), and the first
   September 26 revision added about 45 words; the instructor objected: "fix
   the problems, without blowing up the word count, or organize in a better way
   (long text passages don't project onto a screen that well)." Applied version
   (`draft3.py`): new `Max |w_i|` columns in the GMV and comparison tables carry
   the weight claims (0.616, 0.628 long-only GMV; 0.604, 0.534, 0.464, 0.432,
   0.539 at the five targets); the comparison reading is a `__What do we see?__`
   list with two labeled items; the stale risk-free sentence is cut; both dead
   estimation-risk links are cut or named in words ("the estimation-risk example
   in L6b"). Affected prose 291 → 218 words. Re-executed from the notebook's
   folder: the two corrupted PNGs now pass CRC, all 25 code cells are numbered,
   and every other output is unchanged. Codex check: items 1–8 (numbers, cap
   logic, formatter indices, cell 47/65 coherence) CORRECT; no cross-week links,
   no errors, no unproposed denials. Its shorter position-cap wording ("only when
   the unconstrained `Max |w_i|` exceeds 0.5") was applied. Deferred to the
   Summary step: clause semicolons in the cell 61 and cell 63 code comments and
   the 30-word takeaway-3 sentence.

2. **Task 1 density and projection** (accepted September 26, "Agree. Update.").
   `step2.py`, prose only; code and outputs untouched. Displays unchanged; lead-ins
   tightened; the efficient-branch argument appears once, in a
   `__What do we see?__` list after the figure; helper functions as a three-item
   list; new `### Plot the frontier` heading; figure-styling narration cut (the
   legend carries it). Codex check: display equations byte-identical; the
   Cauchy–Schwarz, convexity, completed-square, helper, and figure-reading claims
   CORRECT; no Task 2/3 back-references broken; links and doc anchors resolve.
   Applied from its suggestions: the branch bullet now excludes the shared GMV
   endpoint ("Each frontier portfolio below the GMV growth rate has an
   upper-branch counterpart..."), and the table lead-in is "Let's display the
   results:". Its suggestion to cut the Task 1 closing transition was declined
   because the approved L6a examples end each task with a one-line "Next, we..."
   sentence; the transition was shortened to "Next, we show how two fixed
   portfolios generate the entire frontier." A 26-word opener sentence in cell 14
   was left. Task 1 prose 1,236 → 720 words.

3. **Task 2 density and projection** (`step3.py`, prose only; code and outputs
   untouched). Task 2 prose 928 → 587 words. Previews:
   `step3-task2-derivation.png`, `step3-task2-computation.png`. The opener flows
   into the fund choice (removes the `###` after two sentences); the sum-to-one
   display is cut (the sums are stated in words and in the fund table); the α
   cases become a three-item list; the cell 34 lead-in now matches the code it
   introduces (it had promised the mixture check); table and figure narration
   cut; the closing reading is a two-item `__What do we see?__` list. All other
   displays byte-identical. Accepted September 26 ("Agree. Update. Next.");
   applied, notebook matches the preview. Codex check: items 1–13 and 15–19
   CORRECT (displays, fund normalization, the b = 0 fallback, α cases, branch
   directions, table and figure readings, Summary back-references, link). Its one
   issue, a 29-word opener, was fixed with its 23-word rewrite: "In this task, we
   construct two frontier funds, verify their mixtures against the closed-form
   weights, and trace the mixtures on the risk-growth plot."

4. **Setup and input estimation** (`step4.py`, cells 5, 7, 9, 11; prose only).
   Setup prose 477 → 330 words. Preview: `step4-setup.png`. The record-screen
   sentence and the sample-mean/covariance display follow the approved sibling
   data example (one display for both estimates); the diagonal/off-diagonal
   recap and the N ≥ 2 condition are cut. The standard opening (cells 1, 3) is
   untouched. Accepted September 26 ("Agree. Update. Next."); applied, matches
   the preview. Codex check: cell-to-code agreement, the growth display, estimator,
   units, and links CORRECT. Applied from its notes: N defined before the display
   that uses it, "For $N\geq2$" restored and $\boldsymbol{\mu}_g$ named as the
   mean-growth vector (both as in the sibling example), "Next, we choose the
   firms." and the row/column restatement cut. Declined: rewriting the 27-word
   record-screen sentence, which is the sibling example's approved wording.
   Setup prose 477 → 320 words.

5. **Task 3 opener and narration** (`step5.py`, cells 48, 50, 52, 57, 59, 60;
   prose only). Edited-cell prose 375 → 323 words (Task 3 was already cut in
   step 1). Preview: `step5-task3.png`. Adds the "In this task" opener; function
   links in the house form; figure-color narration and the "dimensionless"
   sentence cut. Accepted September 26 ("Agree"); applied, matches the
   preview. Codex check: all 13 items CORRECT (table, non-nesting claim, cell-code
   agreement, line widths, ratios, links, sentence length, referents, lead-ins).
   Its optional cut was applied: "Let's quantify the gaps between the curves."
   repeated the next heading.

6. **Summary and code-comment sweep** (`step6.py`, accepted September 26,
   "Agree. Update. Next."). Summary prose 267 → 180 words: a short
   opener; three takeaways in words, with no equations or percentages and the
   labels unchanged. Seventeen code-comment edits in 14 cells remove every
   clause semicolon and cut the unproposed denials in cells 35 and 53; the
   real-trap comments stay. Re-executed with no errors and identical outputs.
   The closing Codex sweep found three accuracy points in the new takeaways,
   fixed the same day: the solver reproduced the *weights* (the variance was
   checked against the quadratic form); the GMV portfolio begins the efficient
   branch rather than sitting below it; the cap binds on a position's
   *magnitude*. Its 22-word Summary opener replaced a 31-word one.

7. **Remaining items** (September 27, applied as proposed, "Apply the
   proposal, with the README split"). Preview:
   `build/notebook-previews/L6a-frontier-remaining-2026-09-27/remaining.png`.
   - Cell 14's 26-word assumptions sentence is split at its comma (word-neutral).
     Cell 5's record-screen sentence stays (sibling example wording).
   - Objectives stay one sentence each, matching the L6a lecture and the GMV
     derivation companion. The sibling data example mixes one and two.
   - Task 3 now solves all three weight rules directly at the five comparison
     targets with `solve_frontier_point`, looping over `constraint_cases` as the
     sweep does. Cell 60's interpolation sentence became one sentence naming the
     solver (61 → 53 words), and the interpolation-error comment in cell 61 is
     gone. Every ratio is unchanged. The unconstrained σ at 0.10 moved 2.169 →
     2.168 (a chord between solved points overstates the convex σ(g)). Direct
     solving also removes an interpolated cap ratio of 0.99997 at 0.30, which is
     impossible (displayed as 1.000). The cell 64 reading is unchanged and still
     true. `interpolate_frontier_risk` was deleted from `src/FrontierGeometry.jl`
     and `docs/frontier-geometry.md`, and cell 2's comment no longer mentions
     interpolation helpers.
   - L6a lecture cell 7: "frontiers that limit short positions" became "frontiers
     that cap position sizes". The advanced README had the same error and said the
     cost is in variance (the notebook compares standard deviations). It now says
     "a position cap and a long-only constraint cost in risk", split into three
     sentences with Codex's word-neutral wording.
   - Correction to the earlier note: the cap does not bind only on a long JNJ
     position. The largest unconstrained positions are JNJ +0.604 at 0.10,
     JNJ +0.534 at 0.20, and C −0.539 (short) at 0.50. The unconstrained GMV
     holds JNJ +0.616. The notebook itself states the cap in magnitude and needed
     no change.
   - Codex check (before applying): all ten items CORRECT except two notes, the
     helper deletion must ship with the notebook change (done together) and the
     48-word README sentence (split as above).
   - Checks: executed from the notebook's folder twice (before and after the
     helper deletion) with no errors, all 25 code cells numbered, outputs
     identical between runs, only cell 63 differing from the September 26
     snapshot, all PNG chunks pass CRC. No other week-6 file references the
     deleted helper.

## Final assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and agreement | 8.0 | 9.3 |
| Organization and sequencing | 8.6 | 9.1 |
| Narrative flow and interpretation | 8.5 | 8.9 |
| Presentation | 8.2 | 9.1 |
| Cognitive density and pacing | 7.5 | 8.8 |
| Overall | 8.2 | 9.0 |

Prose words (same counter throughout, headings and tables excluded): 3,751 →
2,509 (a third cut). Setup 546 → 391, Task 1 1,236 → 720, Task 2 949 → 581,
Task 3 540 → 436 (Task 3 was already cut in step 1), Summary 279 → 180 (heading included).
Every displayed derivation step, figure, and code cell is kept.

Improvements: no broken or cross-week links; both corrupted figures repaired
and all code cells numbered; every weight claim points at a displayed column;
each task opens with "In this task" and a real paragraph; the efficient-branch
argument appears once; tables and figures carry the numbers and styling, with
the readings as short `__What do we see?__` lists that project well; takeaways
are conceptual; no clause semicolons remain in prose or code comments.

The four items left for a later round (long sentences, one-sentence objectives,
Task 3 interpolation, the lecture's "limit short positions") were resolved
September 27; see section 7. Density is an editorial judgment; the instructor's
classroom pacing is the real test.

Final SHA-256 (September 26):
`c9cb8d73069a69bc52be6ff82ec75d843553bcd9e2bcac31dcfa7ffcbdfa9a9a`

SHA-256 after the September 27 remaining items:
`610cfe991644f0b46c190c53d822643757ff8c386cff562c805afecfbf16e451`

## Checks performed

Read all 67 cells, the local `Include.jl`, `src/FrontierGeometry.jl`, the docs
page, the L6a lecture, the advanced README, the GMV companion outline, the
L5b record, and the sibling L6a data example's setup and takeaways. Executed
the notebook with nbconvert (kernel julia-1.12) from its own folder: no errors,
all stored numbers reproduce (table headers differ only by ANSI bold codes,
which the sibling L6a notebooks also store). Rendered with nbconvert HTML and
headless Chrome; the math renders cleanly. Artifacts are in the ignored
`build/notebook-previews/L6a-frontier-polish-2026-09-25/` folder.

Closing checks (September 26): a fresh execution of the final notebook from its
folder had no errors, and every stored output reproduced; all 42 markdown
cells render with VS Code's notebook KaTeX with no errors; the closing Codex sweep
confirmed three objectives, tasks, and takeaways align, every task opens with
"In this task", there are no clause semicolons or em dashes, all 11 relative links
resolve inside week 6, no unproposed denials remain, all 25 code cells are
numbered, and all PNG chunks pass CRC. Previews and step scripts
(`draft3.py`, `step2.py`–`step6.py`) are in
`build/notebook-previews/L6a-frontier-polish-2026-09-25/`.
