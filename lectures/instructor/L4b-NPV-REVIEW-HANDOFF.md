# L4b GBM NPV example — completed interactive review

Completed September 11, 2026.

Notebook: [GBM NPV trade rule](../week-4/L4b/CHEME-5660-L4b-Example-GBM-NPV-TradeRule-Fall-2026.ipynb).

## Status

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
