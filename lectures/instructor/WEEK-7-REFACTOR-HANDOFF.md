# Week 7 refactor — October 1, 2026

The instructor reached the theory in **Minimum-Variance Portfolios with SIM
Inputs** during L6b and requested a Week 7 pivot. This is a structural refactor,
not a completed notebook-polish round or a new review score.

## Teaching sequence

| Slot | Material |
| --- | --- |
| L7a, October 6 | Review SIM portfolio inputs and SIM-1; work the risky-assets example; BlackRock company profile; develop the risk-free asset, CAL, tangent portfolio, two-fund separation, SIM-2 and SIM-3; work the risky/risk-free example. |
| L7b, October 8 | Former L7a utility-based allocation, portfolio drift, adaptive rebalancing, and realized-path scorecard, with its three examples and CES companion. |
| Deferred, no date | Former L7b online SIM estimation, EWLS replay, scenario ensembles, and EWLS derivation. |

The [Week 7 index](WEEK-7-INDEX.md) links the active materials.
The [dated archive](../archive/week-7-before-pivot-2026-10-01/README.md)
preserves both original Week 7 folders. Its 39 tracked files match the original
SHA-256 hashes in `SHA256SUMS`; the old L7b is fully retained.

## L6b and client files

The instructor clarified that **the client interview runs in L6b and stays
there**. It is not a new L7a activity. No client-output files existed at the
time of this refactor, so none were transferred and the examples currently use
the thirteen hardcoded firms.

After the interview, copy `my-tickers.csv` and `my-client.toml` from L6b's
`data` folder into L7a's local `data` folder. The [Week 7 index](WEEK-7-INDEX.md) gives
the two commands. The existing example code reads those local files if present and
falls back to its defaults otherwise. Both copied files are Git-ignored.
Week 7 has no runtime or notebook-link dependency on Week 6.

The L6b notebooks, examples, interview, and slide deck remain in place. Only the
lecture's final schedule pointer changed. Its accepted sections and historical
review scores remain closed.

## New L7a

- New opening, three objectives, concise concept review, BlackRock profile,
  example list, and three takeaways. The risk-free development and equation
  labels are carried from the current L6b lecture.
- Local copies of the reviewed RA and RRFA examples, setup file, SIM archive,
  CAL figure, tangent derivation, and estimation-risk companion and helpers.
  Estimation examples and residual diagnostics stay in L6b.
- The BlackRock profile cites the firm's Target Allocation portfolios,
  Aladdin Risk, cash-management page, and student/career resources. The choice
  is a draft recommendation, not an instructor-approved profile review.
- A 17-page companion deck follows the new lecture and uses the existing
  course slide style. The full review/example stop precedes the risk-free work.

## Relocated L7b and references

The utility material, examples, data, CES companion, and figures moved together.
Filenames, labels, footer identifiers, and links now say L7b. Prerequisite
references distinguish L6b's estimation from L7a's portfolio allocation.
Promises to cover online estimation in the next Week 7 lecture were replaced
with unscheduled later-material references. The engine figure was rebuilt with
the corrected labels. The moved slide deck remains 24 pages.

The repository index, schedule Markdown, and the two Week 7 rows of the schedule
CSV now reflect the new sequence. L13a's CES pointer and notes link, and L15a's
online-estimation pointers, were repaired without changing their calculations.
L15a no longer assumes that EWLS was taught in Week 7. Its eventual scope and
the new placement of online estimation remain undecided. The eCornell integration
record has a dated notice distinguishing its historical mapping from the current
schedule.

## Checks

- Both new L7a portfolio examples executed from their own folder with the
  default firms: RA, 21 code cells; RRFA, 19 code cells. All existing assertions
  passed. Runs used offline package mode and left saved notebook outputs intact.
- All 124 code-cell syntax trees across the copied/moved computational notebooks
  match their source notebooks. Saved outputs, execution counts, and metadata
  are preserved. The optional estimation-risk and moved utility examples were
  checked for preservation, not re-executed in this refactor.
- All ten active Week 7 notebooks parse and validate, each with exactly three
  learning objectives and three key takeaways. Their relative notebook/figure
  links resolve inside Week 7. Major-section rules and closing rules pass.
- The new lecture rendered through Markdown and KaTeX with zero math errors;
  the review, formulas, CAL figure, profile, and closing were inspected visually.
- Both Week 7 slide decks build with zero overfull boxes. All slides were
  inspected, and the corrected company-profile/footer and engine-figure pages
  were inspected after the final rebuild.

Changes are local and uncommitted. No GitHub release or Canvas update was made.
