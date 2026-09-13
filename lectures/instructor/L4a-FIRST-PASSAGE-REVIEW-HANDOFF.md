# L4a first-passage example — completed notebook review

Completed September 13, 2026. The instructor confirmed: “ok, mark this as reviewed”.

Notebook: [First-passage exit rules](../week-4/L4a/advanced/first-passage/CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb).

The instructor requested polishing only if the initial score was below 9/10.
The current notebook scored **9.0/10**, meeting that threshold. No notebook edits
were proposed or applied in this round; the closing score remains **9.0/10**.
No proposals remain pending. Do not restart completed sections unless the
instructor requests another round.

This record supersedes the September 11 paused-review handoff. Its pending
probability-update proposal and remaining-work list describe an earlier state.
The September 13 assessment found the derivation, exit sums, conservation,
helper documentation, and terminal comparison already present. The current
notebook was reviewed as found; no authorship or prior approval of those later
revisions was inferred.

## Assessment

| Dimension | Initial | Closing |
| --- | --- | --- |
| Technical correctness | 9.3 | 9.3 |
| Organization | 9.2 | 9.2 |
| Narrative and interpretation | 8.8 | 8.8 |
| Presentation | 9.0 | 9.0 |
| Cognitive density and pacing | 8.8 | 8.8 |

Task 2 is the strongest material: it develops arrival probabilities, boundary
checks, and probability conservation before introducing code. The worked price
paths motivate the calculation, and Task 3 correctly explains why the monitored
versus terminal-only comparison requires disabling the stop-loss.

The Summary remains terser and more abstract than the instructor's preferred
retrospective takeaway voice. The helper implementation is the densest reading
stretch, supported by the preceding derivation. These are observations for a
possible future round, not pending changes. Scores are editorial judgments;
classroom feedback is needed to assess student pacing.

## Preferences and prior accepted work to preserve

Follow the [shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md), preserving the
2026 notation, teaching voice, and explanatory steps. The earlier review was
motivated by theory omitted from the lecture; keep enough development here for
the example to stand on its own. Do not reopen the completed L4a lecture.

- Keep exactly three objectives, tasks, and takeaways. Keep objective bullets
  adjacent, with no blank lines or standalone `>` lines between them; the
  instructor corrected this twice in the earlier review.
- Keep the concrete missed-exit explanation in the introduction. The approved
  “In this example…” overview follows the objectives and promises the probability
  calculation before its implementation and terminal-only comparison.
- Introduce first-passage time and open/closed positions in plain language.
  The instructor found unexplained “first-passage” and “propagate surviving
  probability” difficult to follow.
- Preserve the standard setup opening, Include callout, setup cell, and
  documentation references.
- Preserve Task 1's opening: “In this task, we specify when to sell our shares:
  when the price reaches our take-profit boundary or falls to our stop-loss
  boundary.” The instructor rejected “which outcomes we want to calculate.”
- Preserve the explicit boundary-equality explanation: “We also sell when the
  price equals either boundary exactly. Once we sell, we stop monitoring that
  position.” This replaced “Equality triggers an exit.”
- Keep the two five-step paths with three up moves and two down moves. The
  up/up/up/down/down path sells at step 3; the down/down/up/up/up path remains
  open through step 5. Both stock prices finish at approximately 112.06.
  Prices after a sale describe the underlying stock after the position closes.
  This illustration does not change the default horizon of 12 steps.
- Preserve the distinction between arrival probability before the boundary check
  and open-position probability after that check. Already exited paths contribute
  nothing to later open probabilities. The probability of remaining open need
  not sum to one across the current nodes.

## Current implementation context

The reviewed notebook has 28 cells, including eight code cells. Defaults are
S0=100, u=1.06, d=0.97, p=0.55, N=12, L=90, and U=115.
Local Include.jl activates and instantiates the course project and imports
DataFrames, Distributions, Plots, and PrettyTables.

[Local helper documentation](../week-4/L4a/advanced/first-passage/docs/first-passage-functions.md)
covers `price_at`, `first_passage_binomial`, and `terminal_upper_probability`.

- The first-exit recursion carries forward only open probabilities, tests prices
  inclusively against the boundaries, and checks probability conservation at
  every step. Julia position k+1 represents mathematical up count k.
- The code sends incoming contributions separately and checks their common node
  price. This is equivalent to adding them before applying the boundary test,
  as in the notebook's derivation.
- Task 3 disables the lower exit with `lower=0.0`. In that upper-only case,
  hitting-by-N probability is at least the terminal-at-or-above-U probability.
  Do not claim that inequality when both exit boundaries are active.
- The notebook computes exit probabilities, not discounting or realized payoffs.
  Its fixed illustrative boundaries are not the lecture's discounted-NPV
  thresholds without a separate derivation of that connection.

## Verification completed September 13

- Read the whole notebook, setup file, and all three helper references.
- Executed all eight code cells sequentially in Julia 1.12.7 using the course
  project and source filenames in the notebook directory to preserve
  `@__DIR__` behavior. This was script execution; saved notebook outputs were
  preserved.
- Compared per-step first-exit probabilities and terminal open-node probabilities
  with independent full-path enumeration in six scenarios: default two barriers,
  upper only, unreachable boundaries, all-down moves, all-up moves, and exact
  equality with either boundary. Each default case enumerated 4096 paths.
- Checked probability conservation and monotonicity at every step, and terminal
  thresholds with no qualifying nodes or all nodes qualifying. All checks passed.
- Validated notebook schema, three objectives/tasks/takeaways, local helper links
  and anchors, and major-section separator placement.
- Inspected all five PNG sections of the full HTML export. All 92 math elements
  rendered without detected math errors, the figure loaded, and no page-wide
  overflow was detected at a 1280-pixel viewport.
- Verified that the notebook's SHA-256 was unchanged throughout the assessment.

Default probabilities: take-profit exit 0.7883596418871734; stop-loss exit
0.06843037015019528; still open 0.1432099879626313. With no stop-loss, the monitored
upper-exit probability is 0.7984938359844693 versus terminal-only probability
0.7393149218989794, a difference of 0.05917891408548992.

Reviewed notebook SHA-256:
`523baea586f0a1bf176256764741deea4b493a36ba4547d97521fe31435ae6a3`.

Local previews and assessment use the prefix
`build/notebook-previews/L4a-first-passage-initial`. These files are ignored by
Git and may be cleaned up; this record retains the assessment and checks.
No commit or push was made during this round.
