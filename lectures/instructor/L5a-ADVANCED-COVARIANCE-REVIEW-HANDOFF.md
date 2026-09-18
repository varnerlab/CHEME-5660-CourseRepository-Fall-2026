# L5a advanced covariance estimation — completed notebook polish

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Status: reviewed and complete, confirmed by the instructor September 14, 2026.**
The instructor explicitly confirmed: “Great! Mark this notebook as reviewed.”
All agreed revisions are saved; no proposals remain pending.
The instructor approved the revised Summary with
“Agree. Update. Next,” after correcting the explanation of covariance's role in
portfolio optimization. Final editorial score: **9.1/10**, from **8.4/10**.
Do not restart completed sections unless the instructor requests another round.

Notebook:
[Sampling Error and Shrinkage in Covariance Estimation](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/covariance-estimation/CHEME-5660-L5a-Advanced-CovarianceEstimation-Fall-2026.ipynb).

This is the advanced example, distinct from the completed L5a covariance-matrix
example recorded in [its own handoff](L5a-COVARIANCE-REVIEW-HANDOFF.md).

Final notebook SHA-256:
`2c5937bf57d09871d0abcd30de61cef302dd8182b129e25eff954a286e8a816b`.

## Assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.5 | 9.3 |
| Organization | 8.7 | 9.3 |
| Narrative flow | 8.4 | 9.1 |
| Presentation | 8.3 | 9.1 |
| Cognitive density and pacing | 8.1 | 8.8 |
| Overall | 8.4 | 9.1 |

The three-task sequence now makes the purpose of each calculation explicit:
diagnose the sample spectrum, measure sampling error with a known covariance,
and compare shrinkage targets in a portfolio optimization problem. The narrative
distinguishes a noise-reference comparison from identifying individual factors,
and a later-window illustration from a validated estimator-selection rule.
Figure labels, task openings, source documentation, and the separate calculation
and reporting cells make the notebook easier to follow.

These scores are editorial judgments, not measured learning outcomes. The
rescaled Marchenko-Pastur comparison remains the densest conceptual passage and
needs deliberate classroom pacing. It is explicitly a one-pass diagnostic;
the notebook does not estimate a definitive factor count or validate a rule for
choosing the shrinkage weight. These are stated limits of the example's scope,
not pending proposals.

## Accepted revisions and preferences

- Revised the opening, three learning objectives, standard setup, and data
  explanation. Preserved the course growth-rate convention and aligned daily
  observation histories.
- Organized the material into exactly three tasks, each beginning with an
  explicit “In this task” sentence. Kept the instructor's shorter Task 1 draft
  after the first proposal was judged too long.
- Explained the independent-observation reference and its large-matrix limit,
  and distinguished spectral diagnostics from a classification of signal and
  noise. Described the residual-variance rescaling as an illustrative adaptation.
- Explained the centered-covariance rank bound in the sampling experiment:
  250 observations and 424 assets force at least 175 zero eigenvalues.
  Scoped the inverse-square-root error rate to the fixed-covariance Gaussian
  simulation and interpreted numerical negative zero as roundoff.
- Corrected Task 2 figure margins and used actual sample counts and ordinary
  decimal error labels while retaining logarithmic axes.
- Distinguished the linear growth-rate proxy from exact portfolio log growth.
  Explained the three shrinkage targets, gross weight, the training minimum,
  and hindsight selection of the best test-window result.
- Used “weight on the target” in place of “shrinkage intensity,” with a concrete
  80% sample/20% target example. Placed the Task 3 legend above the plot and
  corrected axis margins and ticks.
- Saved `mp`, `minvar`, and `realized_std` with Julia docstrings in the local
  [src/CovarianceEstimation.jl](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/covariance-estimation/src/CovarianceEstimation.jl).
  [Include.jl](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/covariance-estimation/Include.jl) loads that
  file. Notebook prose links directly to source beside the function uses.
  The source-documentation pattern follows the L4b first-passage example.
- The instructor explicitly required functions and docstrings in `src/`, loaded
  with `include`, rather than notebook definition cells. Show actual source files
  when reviewing these functions; earlier source previews looked like notebook
  cells and caused confusion. No standalone helper-summary Markdown page was
  added to the example.
- The instructor also explicitly rejected two `let` blocks in one code cell.
  The comparison and report now occupy separate code cells with explanatory
  prose between them. All notebook code cells have at most one `let` block.
- Wrapped long code, separated combined assignments, and retained compact block
  and inline comments. The density helper receives `q` explicitly; the weight
  helper obtains the number of assets from its covariance argument.
- Saved three retrospective takeaways and the corrected closing: covariance is
  an important input to the optimization problem; weights come from solving the
  problem with its chosen objective and constraints. Do not replace this with a
  claim that covariance alone determines portfolio weights.
- Put preview links on separate lines, as the instructor requested.

## Validation and limits

- Validated the final 26-cell notebook, including 11 code cells, unique IDs,
  three objectives, three tasks, three takeaways, six correctly placed major
  separators, a closing sentence, and no saved error outputs.
- The initial review executed all ten original code cells through Julia
  `include_string`. The first code revision also executed all ten draft cells
  and checked data, covariance, density, portfolio results, and figure series
  against the original. The simulation matched the initial recorded results.
- After splitting the comparison and reporting cells, parsed every code cell
  and verified identical executable syntax to that validated code revision.
  Executed the data, covariance, target construction, comparison, and reporting
  calculations. The comparison table and report matched exactly before and
  after the split. This was direct Julia execution, not a fresh IJulia run.
- Executed the saved notebook's actual `Include.jl` path in a fresh Julia
  process. All three documented functions resolved to the example's `src` file.
  Checked density values, a three-asset minimum-variance solution, and the
  identity between proxy variance and the covariance quadratic form. A Julia
  syntax check confirmed no named function definitions in notebook code cells
  and at most one `let` block per cell.
- The final Summary edit changed only its Markdown cell. Final code, outputs,
  execution counts, source functions, and setup match the validated code draft.
  Unchanged simulations were not rerun for the closing prose edit.
- Rendered the complete final notebook and visually inspected nine section
  screenshots. All 76 mathematical elements rendered without reported errors,
  all three figures loaded, and neither the page nor code inputs overflowed
  horizontally. The notebook exactly matches the approved Summary draft.
- All seven relative notebook-link occurrences resolve. External documentation
  URLs were not rechecked in the closing pass; the initial review inspected
  local implementations and docstrings where hosted pages were unavailable.
- Focused whitespace checks passed. No commit or push was made. Other notebooks
  and existing unrelated edits were preserved.

## Recovery artifacts

The ignored `build/notebook-previews/` directory contains the detailed approval
history, validation, and disposable previews:

- `L5a-advanced-covariance-review-state.json` — assessment, feedback, approvals,
  hashes, and completed status.
- `L5a-advanced-covariance-final-validation.json` — final preservation and
  structural checks.
- `L5a-advanced-covariance-final.html` and
  `L5a-advanced-covariance-final-*.png` — complete render and nine section views.
- `L5a-advanced-covariance-code-validation.json` and
  `L5a-advanced-covariance-code-revised-validation.json` — computational checks.

The shared [notebook style guide](NOTEBOOK-STYLE-GUIDE.md) and versioned
[notebook-polish workflow](../../.agents/skills/notebook-polish/SKILL.md) remain
the maintained guidance. Regenerate previews from the saved notebook if the
preview directory is cleaned.
