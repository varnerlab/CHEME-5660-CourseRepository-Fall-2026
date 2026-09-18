# L5a Dirichlet portfolio weights example — completed notebook polish

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Status: reviewed and complete, September 14, 2026.** The instructor explicitly
confirmed the reviewed designation: “Let's mark this notebook as reviewed.” All
section proposals were approved and saved. The final Summary approval was
“Agree. Update. Next.”
No proposals remain pending; do not restart completed sections unless the
instructor requests another round.

Notebook: [Dirichlet portfolio weights example](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/CHEME-5660-L5a-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb)

Initial SHA-256:
`8ff9c753cd61f828314c277d013e2a96e85054c910bb8ac7ecc4022a48829009`

Final SHA-256:
`99406e8b8966e262ce0eacc8435185eb91075f1edc9594453699793c4e9307d4`

## Assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.7 | 9.3 |
| Organization and sequencing | 9.0 | 9.3 |
| Narrative flow and interpretation | 8.5 | 9.3 |
| Presentation | 8.5 | 9.2 |
| Cognitive density and pacing | 8.2 | 8.8 |
| Overall | 8.6 | 9.2 |

The original three-task progression was effective: visualize allocations, compare
estimated growth and risk, then examine wealth and weight drift. The revision
preserves that progression while defining quantities before using them, staging
the algebra, and separating computations from their table displays. The volatility
explanation and annotated wealth derivation directly address the instructor's
questions. The summary now reconnects the methods, results, and purposes in three
retrospective takeaways.

The initial limitations were dense geometry and moment explanations, compressed
growth-rate and volatility distinctions, an insufficiently explicit in-sample
wealth comparison, and an overstated transition from sampling to optimization.
Those points are addressed. Task 2 remains the densest section because students
must connect a linear approximation, sample covariance, time scaling, and
diversification. Some long, unchanged code lines require horizontal scrolling in
the notebook. These are remaining pacing and presentation limitations, not pending
proposals. Scores are editorial judgments; classroom feedback is still needed to
assess student pacing.

## Approved revisions and instructor preferences

- **Opening:** Introduce the allocation problem before the method. Preserve
  “nonnegative fractions (portfolio weights)” and explain that the weights sum
  to one so the full budget is invested. The instructor asked us to avoid short
  positions because that terminology had not been defined. Undefined long-only
  terminology was also removed. Keep exactly three objectives and the example
  overview below them.
- **Setup:** Use the standard Include opening and place documentation references
  after the include cell. Explain the volume-weighted average price and identify
  the actual column used in the calculations. Preserve the existing data-filtering
  narrative and code.
- **Task 1:** Derive the triangle constraints before introducing concentration
  choices. Use the compact four-row concentration table. Explain that only 1,500
  of 5,000 draws are plotted. Define the random weight and total concentration
  near the mean and variance formulas. Distinguish allocations near a boundary
  from exact zero weights and explain the fixed-budget dependence.
- **Task 2:** Explain the linear growth-rate approximation and its small-log-return
  condition. Define volatility before the asset table, including its connection
  to log-return dispersion, the square-root-time scaling, and its units. Retain
  the current L5a sample-mean notation `g′` and growth covariance notation.
  Distinguish the best sampled draw, global minimum variance under the weight
  constraints, and the frontier at specified growth levels.
- **Tables and code cells:** The instructor requested `pretty_table(...)` for
  sampled allocations and explicitly rejected two `let ... end` blocks in one
  cell. Separate calculation and display with a connective Markdown sentence
  linking the function documentation. Apply the same pattern to the wealth
  table. The allocation table shows one numeric weight column per asset. Disable
  horizontal terminal cropping for the wealth table so every portfolio is shown.
- **Comparison plot:** Reduce the red single-asset marker size from 7 to 4.
  Preserve the equal-weight and lowest-variance markers and the plot's other
  settings.
- **Task 3:** State that the historical price window is part of the training data
  used to select the lowest-variance draw. Explain fractional shares and the
  omission of transaction costs and separate dividend payments. Derive holding
  values, total wealth, and normalized wealth from the initial share counts.
  The instructor specifically requested right-hand annotations for summing
  holdings, substituting share counts, factoring out the initial budget, and
  dividing both sides by that budget.
- **Weight drift:** Use the final-weight table to show the change in allocation.
  Explain percentage price changes relative to the portfolio's percentage wealth
  change and define rebalancing through the required purchases and sales.
- **Summary:** Preserve three retrospective takeaways covering sampling,
  growth/risk comparison, and wealth/weight drift. Remove ambiguous sparse
  terminology and the claim that numerical optimization in L5b is exact.

The final check separated two existing pairs of assignments onto individual lines
and added short explanatory comments, following the shared guide. This affected
only the concentration/total-concentration assignments in `t1c-code` and the
distribution/random-draw assignments in `t3-code`. Julia parsing confirmed that
both cells have the same executable expressions as their approved versions.
No further prose or mathematical revisions were introduced after approval.

## Validation and execution scope

- Read the complete notebook, the shared style guide, the relevant notebook
  skills, the original 2025 multiple-asset material, and the CHEME 5820
  power-iteration example reference. Inspected setup, local helpers, the actual
  course package implementation of `log_growth_matrix`, and current L5a/L5b
  context. At closure, read the completed L5a lecture handoff and confirmed that
  this example's sample-mean and time-scaling notation remains consistent.
- All original 16 code cells executed successfully in a separate Julia process
  on September 13, without replacing the notebook's outputs. The recorded
  checks reproduced the baseline moment, risk, selected-weight, and drift tables.
- On September 14, executed the required dependencies and changed Task 2
  allocation display/plot. Verified 5,000 valid allocations, the first allocation's
  statistics against the formulas and saved values, and marker size 4. Saved the
  actual new table and PNG/SVG plot outputs.
- Executed the Task 3 wealth calculation, separate display, and final-weight
  calculation with their dependencies. Verified 252 wealth rows, initial
  normalized wealth equal to one within numerical tolerance, final weights
  summing to one, and agreement with saved values. Verified matching timestamps
  across all five selected assets. The actual window is January 2–December 31,
  2024: 252 price observations spanning 251 intervals.
- The wealth table's first execution cropped columns at the terminal width.
  After adding `fit_table_in_display_horizontally = false`, reran the changed
  display with its dependencies and confirmed that all five portfolio columns
  appear. The normalized wealth and weight checks passed again.
- Final `nbformat.validate` passed: 43 cells, including 18 code cells, exactly
  three objectives, three tasks, three takeaways, and six separators immediately
  before level-two headings. No saved error outputs. All four relative link
  occurrences resolve. All eight displayed equation blocks have explanatory
  lead-ins; their mathematics was read and checked against the calculations.
- All approved cell content is preserved except the two final assignment
  formatting changes described above. Existing execution counts, cell metadata,
  notebook metadata, and the disclaimer are preserved. The two new table cells
  have null execution counts and actual outputs from the separate Julia checks;
  the notebook does not claim a fresh complete execution sequence.
- Rendered the final notebook with nbconvert and MathJax in headless Chrome.
  Visually inspected all ten section PNGs at a 1280-pixel viewport. All 75 math
  elements rendered without reported errors, all three figures loaded, and
  there was no page-wide horizontal overflow. Tables and derivation annotations
  are readable. Long source lines retain notebook code-cell scrolling.
- Verified official Distributions.jl and PrettyTables documentation during the
  round. The web tool could not retrieve the hosted course equity documentation;
  its function anchor was checked in archived course HTML and the actual local
  implementation was inspected. No package changes were made.
- No final full Julia rerun was performed for prose and formatting changes.
  The concurrently added OutOfSample helper in the shared Include file belongs
  to the companion example's work and was not executed by this final check.
  Concurrent lecture, covariance example, out-of-sample example, setup, source,
  documentation, and shared-guide edits were preserved. No commit or push was
  made.

## Saved artifacts

The ignored `build/notebook-previews/` directory contains the initial notebook,
accepted proposal sources and previews, chronological review state, generated
table/plot outputs, and final artifacts:

- `L5a-dirichlet-final.html` and `L5a-dirichlet-final.md`.
- `L5a-dirichlet-final-{opening,setup,geometry,moments,estimates,allocations,comparison,wealth,drift,closing}.png`.
- `L5a-dirichlet-final-validation.json` and
  `L5a-dirichlet-final-render-metrics.json`.

Preview artifacts are disposable; regenerate from the saved notebook if cleaned.
The [shared style guide](NOTEBOOK-STYLE-GUIDE.md) and
[versioned polish workflow](../../.agents/skills/notebook-polish/SKILL.md) remain
the maintained guidance. This handoff records the completed review and the
instructor's decisions.
