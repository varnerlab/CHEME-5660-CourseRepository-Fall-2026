# L5b data-driven minimum-variance example — completed notebook polish

**Status: reviewed and complete, September 16, 2026, confirmed by the instructor.**
The instructor explicitly requested “Great. Mark this notebook as reviewed.”
The instructor approved the final closing with “Agree. Update. Next.” All
approved sections are saved, and the final consistency check and rescoring are
complete. No proposals remain pending. Do not restart completed sections unless
the instructor requests another round.

Notebook: [Data-driven minimum-variance portfolios, the efficient frontier, and the capital allocation line](../week-5/L5b/CHEME-5660-L5b-Example-Data-MinVar-Portfolio-Fall-2026.ipynb)

Initial SHA-256:
`038739e9470a86388fb578c45f594c020775efae7be18bde6b229289b750d2cb`

Final SHA-256:
`85578325bc41a971b4ce651d7dceab7526769c831e01ddda19c1b4d2ceaa80da`

## Assessment

The initial score was **8.4/10**; the final score is **9.1/10**.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and agreement | 8.7 | 9.2 |
| Organization and sequence | 8.4 | 9.2 |
| Narrative, motivation, and interpretation | 8.5 | 9.2 |
| Presentation and rendered layout | 8.3 | 9.2 |
| Cognitive density and pacing | 8.1 | 8.8 |
| Overall | 8.4 | 9.1 |

The revised notebook connects estimation, optimization, and evaluation in three
tasks. The equations define the inputs before mapping them to code, the constraint
comparisons explain what the calculations actually establish, and the figures and
tables have readable labels and connective prose. The closing now explicitly
states that the estimates are inputs to optimization problems whose solutions
determine the allocation weights.

Task 2 remains the longest and most demanding part: it develops the target sweep,
closed-form frontier, allocation changes, risk-free asset, tangent portfolios,
Sharpe scaling, and CAL. Its subsections provide teaching stops, but classroom
pacing has not been measured. These scores are editorial judgments. No further
substantive revisions are proposed in this round.

## Approved revisions

- **Opening and setup:** Three objectives follow the three-task sequence. Training
  data estimate inputs and choose weights; 2025 prices support the separate
  evaluation. Setup and dataset descriptions explain VWAP, complete histories,
  and the distinction between equal record counts and aligned dates. The
  risk-free-rate explanation is retained as a code comment, as requested.
- **Inputs and notation:** Individual observations use `g_k^(i)`, the data matrix
  uses bold `G`, sample means use `g_i′`, and the population means use `μ_g,i`.
  The Julia mean vector remains `ĝ`. The explanation separates sample covariance,
  covariance rate, correlation, and their units. The L4b comparison distinguishes
  sample-mean and regression estimates without relabeling the stored CSV columns.
- **GMV:** The closed form explains the covariance solve and normalization.
  The long-only problem defines its budget, bounds, and growth floor. Choosing
  the smallest individual mean makes that floor redundant for long-only GMV.
  The comparison ends with two short paragraphs explaining shorts and why
  removing allocation choices cannot lower the minimum standard deviation.
- **Frontier:** The numerical growth-floor sweep is distinguished from the
  equality-target closed form. The coefficient calculation checks the GMV
  identities. Grid spacing is reported as sweep resolution, not an error bound.
  Revised figures separate ticker labels, move legends out of the plot region,
  distinguish nearby GMV markers, and explain the allocation bands and table.
- **Risk-free asset and tangency:** Complete-portfolio equations lead into the
  CAL and sampled maximum-Sharpe selection. The closed-form comparison states
  the covariance and growth conditions. Sharpe scaling uses the established
  independent-increment assumption and explicit units. Weights and statistics
  appear in separate tables with explanatory prose between them. The CAL figure
  shows the full risk-free marker and explains lending, borrowing, and the
  approximation introduced by sampled tangency.
- **Out-of-sample evaluation:** Fixed shares are distinguished from weights that
  move with prices. The instructor requested an explanation of why wealth is
  undiscounted; the accepted passage gives the related discounted NPV formula.
  Realized growth and risk are defined before the table. Interpretation reports
  the observed rankings without attributing them to an untested cause.
- **Closing:** The lead explicitly includes solving optimization problems for
  weights. Exactly three retrospective takeaways cover inputs/GMV, frontier/CAL,
  and buy-and-hold evaluation. The final sentences connect market-portfolio
  assumptions to L6a's model with fewer parameters, without prematurely narrowing
  the next lecture to the single-index model.

## Instructor preferences to preserve

- Explain how estimated inputs become weights through an optimization problem;
  do not imply that estimating growth rates and covariances alone determines them.
- Explain intermediate vectors in closed-form calculations and connect them to
  the linear solve and normalization in code.
- Keep the GMV comparison interpretation to the approved two short paragraphs.
  Explain the effect of long-only bounds in terms of removing allocation choices.
- Put the risk-free-rate approximation in its trailing code comment; do not
  restore the rejected standalone paragraph in setup.
- Retain the bold opening sentence of the heatmap interpretation.
- Separate tangent weights and performance statistics into two tables, with
  connective prose between them.
- Keep the wealth-versus-NPV explanation beside the wealth formula.
- Put each preview link in its own paragraph; adjacent inline links were hard
  for the instructor to open.

## Validation and scope

- The opening review read the original 2025 example and the 5820 covariance
  reference, relevant current lectures, setup/helper files, and the package's
  growth-matrix and portfolio-solver implementations. The September 16 resumption
  read the current notebook and saved review checkpoints rather than restarting
  the approved sections.
- Earlier in this round, all computational cells were executed using the existing
  Julia project through a temporary driver that reproduced setup imports and
  helper inclusion. All 101 frontier targets solved and printed results matched
  the saved values. Training and testing date alignment, positive finite wealth,
  covariance definiteness, budget constraints, and formula assertions passed.
  The largest frontier budget residual was `4.44e-16`; the largest growth-target
  shortfall was about `1e-8`, consistent with solver tolerance.
- An earlier independent continuous optimization gave daily Sharpe ratio
  `0.08093584446742105`, compared with the sampled value
  `0.08093575020927048`. This checks the default candidate without claiming a
  general accuracy bound. Subsequent targeted checks covered frontier identities,
  tangent formulas, separate reporting tables, and lending/borrowing identities.
  These logs were inspected during final review; no new full Julia execution was
  needed for the closing-only edit.
- Final `nbformat.validate` passes: 64 cells, including 27 code cells, with no saved
  error outputs. There are exactly three objectives, three tasks, three takeaways,
  and six separators. Every separator precedes a level-two heading; none follows
  the final disclaimer. Both local link occurrences resolve. No code cell contains
  more than one `let` block, and no notebook cell defines a Julia function.
- Only Markdown source in zero-based cell 62 changed during the resumed closing
  revision. All earlier approved cells, executable source, outputs, and metadata
  are preserved. The saved closing matches the approved draft exactly.
- Exported the full final notebook with nbconvert and rendered it in isolated
  headless Chrome using local MathJax. All 108 expressions rendered without
  reported errors; all five images loaded; no page-wide horizontal overflow.
  Visually inspected the final input-estimation section, risk-free development,
  CAL figure and interpretation, wealth/NPV passage, results, and summary.
- Final validation did not refetch the 25 external link occurrences. Earlier
  section reviews checked relevant official references; when hosted course docs
  were unavailable, the local implementation and documentation source were used.
- The companion GBM notebook and completed lecture retain their saved checksums.
  No source, package, slide, commit, or push changes were made during this resumed
  closing review. Existing concurrent edits were preserved.

## Saved artifacts

The ignored `build/notebook-previews/` directory contains the earlier proposals,
execution/check logs, and final artifacts:

- `L5b-minvar-initial-assessment.md`: initial scores and section approval history.
- `L5b-minvar-final.html`: full final render.
- `L5b-minvar-final-*.png`: final section screenshots, including the summary.
- `L5b-minvar-final-validation.json`: preservation and structural checks.
- `L5b-minvar-final-render-metrics.json`: math, image, and layout checks.
- `L5b-minvar-review-state.json`: completed review state and scores.

Previews are disposable. This record preserves completion and preferences if
the preview directory is cleaned. The [shared style guide](NOTEBOOK-STYLE-GUIDE.md)
and [versioned workflow](../../.agents/skills/notebook-polish/SKILL.md) remain the
maintained instructions.
