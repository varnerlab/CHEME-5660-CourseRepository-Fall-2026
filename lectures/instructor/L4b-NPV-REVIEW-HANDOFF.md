# L4b GBM NPV example — completed interactive review

Completed September 11, 2026; follow-up polish round completed September 13, 2026.

> **September 18 move:** The instructor moved this example to L5a because it was not reached in L4b. The reviewed narrative, calculations, defaults, and saved outputs are preserved. Only the parameter-file path and prerequisite link changed. Its exact L4b parameter snapshot is retained under L5a's `data/npv/` directory. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md).

Notebook: [GBM NPV trade rule](../week-5/L5a/CHEME-5660-L5a-Example-GBM-NPV-TradeRule-Fall-2026.ipynb).

## September 13 polish round — complete

All accepted changes are saved. No proposals remain pending.

- Task 1 recalls the scaled-NPV definition, explains its discounted
  fractional-return meaning, and connects it to the scheduled sale.
- The probability formula explicitly requires a positive holding period and
  positive volatility. The original sentence about using parameter estimates
  is retained; the proposed clause about treating estimates as fixed model
  parameters was rejected and was not applied.
- A new paragraph after the Task 1 output interprets `p`, its complement
  `1-p`, and the possibility of a discounted loss when exceeding a negative
  target. Keep this prose independent of the selected ticker and numerical
  inputs: the instructor changes tickers during lectures. The proposed
  AAPL-specific paragraph was rejected and was not applied. The code already
  prints the current ticker, target, horizon, and probability dynamically.

The final overall editorial rating is **9.0/10**, compared with **8.8/10**
at the start of this round:

| Dimension | Initial | Final |
| --- | --- | --- |
| Technical correctness | 9 | 9 |
| Organization | 9 | 9 |
| Narrative flow | 8 | 9 |
| Presentation | 9 | 9 |
| Cognitive density and pacing | 9 | 9 |

Task 1 now connects the financial quantity, probability formula, computation,
and interpretation. The existing introduction, standard setup, median task,
target sweep, and summary remain effective. Pacing is still an editorial
judgment that can be assessed further during teaching.

Validation: notebook schema, three objectives/tasks/takeaways, local links,
separator placement, whole-notebook narrative, and rendered layout checked.
The initial default probability and median were independently reproduced in
Python; the target sweep was finite, bounded, and decreasing. All nine Julia
code cells, saved outputs, and notebook metadata are preserved. Julia was not
rerun in this prose-only round; external documentation URLs were not retested.

Final notebook SHA-256:
`b94b5536ac8a8ba6335120be1fbab1256c065db2a3efb717e2be3818209d3873`.
Current HTML previews are in `build/notebook-previews/l4b-npv-polish-final-`
`{opening,calculations,closing}.html`; the final calculations PNG uses the same
prefix. Initial scores and working review artifacts are also saved in that
ignored directory. No commit or push was made by this round.

## September 11 status

The interactive review is complete through the Summary. All approved passages
are applied; no proposal remains pending. Do not restart completed sections.
The older L4b lecture handoff predates this review and is not the current status
record for this example.

## Applied changes

- Opening question, three objectives, then the overview paragraph before
  “Let's get started!”; setup matches the parameter-estimation example.
- Load the saved parameter table directly; remove unused historical-price
  loading/filtering. Match the selected ticker against the table's ticker column
  in all three calculations, avoiding an independent row-order assumption.
- Exactly three tasks: target probability, median check, and target sweep.
- Mean growth uses μ_g in mathematics and μ̂_g for the estimated value in code;
  σ̂ denotes estimated volatility and ρ_star is the target. The CSV's legacy
  drift column still stores estimated mean growth.
- Holding period and benchmark comments state units. Target range and number
  of targets are configurable in Constants.
- Explain z as the required log-price change measured in standard deviations
  from its model mean; explain why normal probabilities apply under GBM.
- Explain what probability calculation the median check verifies and why the
  median is exceeded with probability one half.
- Short plot introduction, followed by the approved interpretation after the
  figure. Do not reinsert the rejected zero-target sentence into that passage.
- Three retrospective takeaways, with approved leading and closing sentences.

## Verification

The notebook executed successfully in a fresh Julia kernel after the final code
change (the configurable target sweep); later changes were Markdown only.
All nine code cells have sequential execution counts and no error outputs.
The median assertion passed. Notebook structure, three objectives/tasks/takeaways,
local links, notation, and horizontal-rule placement were checked.
The full notebook was rendered in three previews and visually inspected,
including equations, plot, and Summary. No commit or push was made by this review.

Preview files are /private/tmp/l4b-npv-final-{opening,calculations,closing}.{html,png}.
The external MathJax CDN stalled, so previews used the installed nbclassic
MathJax with TeX-AMS-MML_HTMLorMML-full,Safe and explicit STIX-Web fonts.
This preview configuration does not modify the notebook.

## L5a conditional reassessment — September 19, 2026

The instructor requested a new notebook polish run only if the initial score
was below 9/10 and supplied the current L5a notebook path. A fresh assessment
gives **9.0/10**, so the condition for editing was not met. The notebook is
unchanged, and no proposals remain pending from this conditional round. This
assessment concerns the current snapshot; the earlier completed reviews remain
part of its history.

| Dimension | Current score |
| --- | --- |
| Technical correctness and agreement with calculations | 9.3 |
| Organization and sequencing | 9.1 |
| Narrative, motivation, and interpretation | 9.0 |
| Presentation and rendered layout | 8.8 |
| Cognitive density and pacing | 9.0 |

Task 1 connects the discounted payoff, normal-tail formula, code, and meaning
of the result, including the distinction between exceeding a negative target
and making a discounted profit. Task 2 supplies a useful median check. Task 3
keeps the comparison focused by varying only the target, and its figure and
closing interpretation agree. Three objectives, three tasks, and three
retrospective takeaways align with this progression.

Minor presentation opportunities remain: the median-check cell combines three
parameter assignments on one line; the plot's horizontal label says “Target
return” rather than explicitly identifying discounted return or scaled NPV;
and the target-probability display lacks surrounding blank lines. All three
equations render correctly with the installed VS Code notebook math renderer,
but the alternate markdown-it-texmath renderer leaves the second Task 1 display
unprocessed. These are localized presentation issues, not mathematical errors.
The earlier rejected fixed-parameter clause, ticker-specific interpretation,
and zero-target sentence were not restored.

Validation:

- Read all 26 cells, the saved outputs, the setup file, the preserved parameter
  table, and the relevant prerequisite estimation material. The legacy `drift`
  column is correctly interpreted as mean growth.
- Independently reproduced the default probability, `0.9638209378998319`, and
  median scaled NPV, `0.04935685330528878`; the median exceedance probability
  is `0.5`. All 201 target probabilities are finite, bounded, and strictly
  decreasing, from approximately `0.989663` to `0.006973`.
- Notebook schema, local links, task introductions, and separator placement
  pass. Nine code cells retain execution counts 1–9 with no saved errors.
  All code cells and outputs match the pre-September-19-wording-pass baseline.
- Rendered the complete notebook with the installed VS Code math extension
  and inspected ten PNG captures covering the opening, setup, equations,
  median code/output, target-sweep explanation and figure, interpretation,
  summary, and disclaimer. No captured section has horizontal overflow or
  a KaTeX error. The in-app browser was unavailable; an isolated local Chrome
  profile with network requests blocked produced the captures.
- Julia documentation pages resolved. The browsing tool returned an internal
  error for the course-package documentation URL, so its availability was not
  verified; this does not establish that the link is broken.
- Julia was not rerun: no executable behavior changed, and the independent
  calculations resolve the numerical checks needed for this assessment.
- The notebook remains byte-identical to the start-of-round copy. Only this
  review record and ignored review artifacts were added or updated.

Current notebook SHA-256:
`60a147e1f9306d1e30d78ac6d986b6948ccb75269593a4aa093bedf363c77953`.

HTML, PNG captures, and checks are under
`build/notebook-previews/L5a-NPV-conditional-review-2026-09-19/`.

## Learning-objective follow-up — approved September 19

On September 19, the instructor said the learning objectives need work,
reopening that panel after the conditional assessment. The proposed wording
makes the parameter inputs and scheduled-sale outcome explicit, changes the
median objective from confirming a value to explaining and applying the check,
and identifies the financial interpretation of a negative target.

The instructor approved the revised panel with “Agree. Update. Next.” All three
objective bullets are now saved in the notebook. The accepted wording and
inspected opening PNG are saved in
`build/notebook-previews/L5a-NPV-objectives-proposal-2026-09-19/` as
`proposal.txt` and `objectives-draft-cell-0.png`. The preview has no horizontal
overflow. Only the three objective bullets changed in the active notebook.

The instructor corrected the first proposed objective: mean growth and volatility
are inputs to GBM; those estimates alone do not supply a future price. The
revised draft explicitly uses GBM to describe the distribution of the future
sale price, then uses that distribution to calculate the NPV target probability.
Its label is now “Calculate NPV target probabilities using GBM.” The other two
objectives were approved as drafted. Notebook schema validation passes, and
the saved notebook exactly matches the approved draft. All other cells, code,
outputs, and metadata are preserved.

Notebook SHA-256 after saving the objectives:
`678871efa1e638977586fbf79c79c49acabb88448016644fb186d95626236a47`.

## Opening overview — approved September 19

The instructor approved the opening overview with “Agree. Update. Next.” The
paragraph immediately below the objectives now makes the same
model-to-price-distribution-to-NPV connection explicit. The saved notebook
exactly matches the approved draft; schema validation passes, and every cell
after the opening, all code and outputs, and metadata are preserved. The
accepted wording and inspected preview are in
`build/notebook-previews/L5a-NPV-overview-proposal-2026-09-19/` as `proposal.txt`
and `overview-draft-cell-0.png`. The preview has no horizontal overflow.

Notebook SHA-256 after saving the overview:
`eb91fa6d7982d2fce4c7232aeac6dfd49ab4ec8e78fc9fd312bdbb7f4f62178e`.

## Task 1 equation formatting — approved September 19

The setup and data explanation remain consistent with the reviewed standard
opening. The instructor approved the Task 1 formatting proposal with “Agree.
Update. Next.” The saved notebook now has blank lines around the
target-probability display in cell 9 and a closing period before “Here, ...”.
No words, mathematical quantities, or executable code changed.

The notebook now renders all three displays in both the installed VS Code notebook
math renderer and markdown-it-texmath, with no errors or unprocessed display
delimiters. The inspected Task 1 PNG has no horizontal overflow. Draft wording,
render checks, and the preview are in
`build/notebook-previews/L5a-NPV-task1-proposal-2026-09-19/`. The saved notebook
exactly matches the approved draft and passes schema validation.

Notebook SHA-256 after saving Task 1:
`790aaa93c896d65dc35f559d4c7326c1fd1caf7ad7a98c2518faaf94c0c115da`.

## Median-check parameter assignments — approved September 19

The instructor approved the Task 2 proposal with “Agree. Update. Next.” The
saved notebook separates the mean-growth estimate, volatility
estimate, and holding-period assignments in cell 17 onto three lines, with
comments stating their units and the legacy meaning of the `drift` column.
This follows the shared guide's one-assignment-per-line preference.

Only comments and whitespace differ in the revised code; executable
expressions and saved outputs are preserved. The inspected code/output PNG
has no horizontal overflow. Draft, checks, and preview are in
`build/notebook-previews/L5a-NPV-median-proposal-2026-09-19/`. The saved notebook
matches the approved draft exactly and passes schema validation.

Notebook SHA-256 after saving the median-check formatting:
`92d1619adadc6d236e5c27b5e5cefb3849476b9f56e2db2888dc46b3a541e7f4`.

## Next proposal — probability-curve label

The final proposed edit changes the horizontal-axis label from “Target return
ρ*” to “Target scaled NPV ρ*”, so the figure explicitly names the discounted
quantity developed in the example. Only the label string changes in code.

The proposed figure was regenerated with the notebook's Julia data loading,
constants, target sweep, and plotting code. The median-check assertion also
passed during this focused execution. All 201 plotted probabilities agree
with the independent normal-tail calculation to within `1e-14`. The PNG was
inspected for legibility; the PNG, SVG, and HTML output representations are
refreshed together in the draft. No plot image was edited manually.

The proposal and preview are in
`build/notebook-previews/L5a-NPV-curve-proposal-2026-09-19/`, including
`curve-draft.ipynb`, `probability-curve.png`, and `checks.txt`. The active
notebook retains the existing axis label and saved figure pending feedback.
After this proposal is resolved, the remaining work is the final whole-notebook
consistency check and rescoring.
