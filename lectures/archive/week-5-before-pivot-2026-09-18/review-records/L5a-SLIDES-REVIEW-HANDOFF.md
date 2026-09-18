# L5a lecture slides — completed interactive polish

**Status: reviewed and complete September 16, 2026.** The instructor approved
the final revisions with “Agree. Update. Done?” All approved changes are saved;
no slide proposals remain pending. Final editorial score: **9.2/10**, from
**8.3/10**. Do not restart completed sections unless another round is requested.

- [Final slide PDF](../week-5/L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.pdf)
- [Beamer source](../week-5/L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.tex)
- [Reviewed lecture notebook](../week-5/L5a/CHEME-5660-L5a-Lecture-MultipleAsset-GBM-Fall-2026.ipynb)
- [Lecture review record](L5a-LECTURE-REVIEW-HANDOFF.md)

The native Beamer/XeLaTeX workflow and course theme were preserved. The deck
expanded from 24 to 37 pages to separate definitions, derivations, interpretation,
and example stops. It remains a companion to the lecture notebook. The title
and disclaimer retain their opening positions. The lecture notebook was unchanged.

## Assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and lecture alignment | 8.5 | 9.3 |
| Organization and sequence | 9.0 | 9.3 |
| Narrative and interpretation | 8.0 | 9.2 |
| Presentation | 8.5 | 9.3 |
| Density and note-taking | 7.5 | 9.0 |
| Overall | 8.3 | 9.2 |

These are editorial judgments. The main improvement is the separation of dense
mathematical passages into readable steps, with the notation and explanations
aligned to the reviewed notebook. The covariance and portfolio-growth derivations
still benefit from spoken explanation and deliberate classroom pacing.

## Approved changes

- Used the [L4a slides](../week-4/L4a/slides/CHEME-5660-L4a-Slides-Fall-2026.tex)
  as the standard for objectives, example links, formatting, and the summary.
  Retained exactly three conceptual objectives and three retrospective takeaways.
- Spelled out geometric Brownian motion in the objectives and at the model review.
  Used L4b as the single-asset notation reference, including mean growth rate
  `mu_g` and the “mean log growth” annotation on the transition equation.
- Separated the single-asset model, growth/volatility relationship, exact
  transition, out-of-sample example, trade setup, and target probability.
  Stated that terminal prices can be sampled directly. Identified 2014–2024 as
  the fitting period and 2025 as the out-of-sample comparison period.
- Explained covariance and the loading matrix through a two-asset construction
  before the general price model. Defined Wiener increments beside the model,
  separated the covariance-factor proof from factor choices, and retained the
  exact correlated transition.
- Distinguished growth-rate covariance, the covariance rate, and log-return
  covariance, with the observation-interval scaling and units. Staged empirical
  covariance definition, interpretation, correlation, centering, covariance-rate
  estimation, and the positive-semidefinite proof. Preserved the covariance
  schematic and clarified its scale comparison.
- Separated singular covariance estimates from estimation uncertainty. Explained
  the centered rank bound, factorization choices, effects of changing the diagonal,
  sampling error, and changing relationships between firms.
- Separated initial portfolio weights and their constraints from buy-and-hold
  wealth. Stated fractional-share, no-dividend, and no-trading-cost assumptions;
  distinguished fixed share counts from changing investment weights.
- Separated the Dirichlet moments from concentration examples. Used the companion
  three-firm cases `(1,1,1)`, `(0.5,0.5,0.5)`, `(5,5,5)`, and `(5,1,1)` to explain
  investment mixes. Distinguished average weights across many draws from weights
  within an individual portfolio.
- Restored the first-order portfolio-growth approximation from exact one-period
  buy-and-hold wealth. Organized estimation into historical inputs followed by
  evaluating each fixed allocation. Connected sample means `g-prime` to model
  means `mu_g` and the empirical growth-rate covariance to the model covariance.
- Explained why the lowest-variance sampled draw need not solve the optimization
  problem. Used descriptive example links and investment-focused explanations,
  including the two optional advanced notebooks.
- Revised the summary lead to past tense and made the L5b transition explicitly
  describe the optimization problem that finds optimal weights.

## Instructor preferences to preserve

- Keep the course default of growth rates; distinguish them from log returns and
  apply the time scaling explicitly. Do not treat a covariance rate as the
  covariance matrix of observed growth rates.
- Introduce bullet lists with an explanatory lead-in. Use concrete descriptions
  of what is invested in each firm and what is compared; avoid procedural
  objectives and abstract descriptions without their investment meaning.
- Explain Dirichlet choices through the investment problem. Do not restore the
  “with probability one” phrase, abstract volume/density discussion, or the Beta
  marginal aside in these slides.
- The 70/30 budget explanation did not clarify the negative weight-covariance
  formula and was removed. The approved closing instead distinguishes moments of
  sampled investment weights from firms' growth-rate covariance used for risk.
- In the concentration slide, `(1,1,1)` can give uneven individual portfolios
  while averaging one third per firm across many draws. `(5,5,5)` has the same
  average and draws individual portfolios closer to that split.
- Do not imply that estimated growth rates and covariance alone choose portfolio
  weights. Optimal weights come from solving the stated optimization problem
  with its objective and constraints.
- Summary lead: “We modeled correlated asset prices and examined how the fraction
  invested in each firm affected portfolio growth and risk.”
- Closing transition: “Next time: we will use minimum-variance optimization to
  find optimal portfolio weights—the weights that minimize estimated variance
  under the chosen constraints.”
- Present review-preview links separately and open PNG previews in VS Code.
  Completed slide sections should not be reopened without a new request.

## Final validation

- Fresh two-pass XeLaTeX build from the canonical source succeeded: 37 pages,
  no overfull or underfull boxes, and no unresolved cross-reference warnings.
- Text extracted from every page of the fresh build matched the approved PDF.
  The canonical source exactly matches the approved final draft.
- The revised slides were rendered and visually inspected throughout the review;
  final closing renders had no clipping or overlap. The course font sizing was
  preserved instead of shrinking text to fit dense passages.
- Verified three learning objectives, three key takeaways, and the title/disclaimer
  order. No legacy `gbar` macro is used in slide content.
- All 11 notebook-link occurrences resolve to eight existing local notebook
  targets. This checks repository destinations, not remote HTTP availability.
- The reviewed lecture notebook hash stayed unchanged. No notebook computation
  was rerun for this slide-only polish.
- Scoped whitespace checks passed. No commit or push was made.

Final source SHA-256:
`1604eda6447150c7bd2b90d64220708892b1eb1d2dd55c47a64aae0813fba308`.

Final PDF SHA-256:
`489a6df20f815c7a3dface73e9d632477bf5274b581f093959ddbeb774db1b56`.

Unchanged reviewed lecture notebook SHA-256:
`2a067a14607a3184690530405d5eb080d8d0837a5c413345e553445637c0342a`.

Detailed approval state, previews, compile logs, and validation results are in
`build/notebook-previews/L5a-slides-review/`. That directory is ignored and may be
cleaned; this handoff is the durable record. No further slide review is pending.
