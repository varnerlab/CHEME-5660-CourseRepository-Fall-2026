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
