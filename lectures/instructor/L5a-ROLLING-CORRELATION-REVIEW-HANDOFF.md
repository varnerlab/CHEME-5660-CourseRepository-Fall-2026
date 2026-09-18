# L5a rolling correlations — completed notebook polish

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Status: reviewed and complete, confirmed by the instructor September 14, 2026.**
The instructor explicitly confirmed: “Ok, great! mark this as reviewed.”
All agreed revisions are saved; no proposals remain pending.
The instructor approved the final Summary closing
with “Agree. Update. Next.” Final editorial score: **9.1/10**, from **8.9/10**
at the resumed assessment. The earlier review's original score was **8.3/10**;
that record and the approvals of earlier sections have been preserved.
Do not restart completed sections unless the instructor requests another round.

Notebook:
[L5a Advanced: Rolling Correlations](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/rolling-correlation/CHEME-5660-L5a-Advanced-RollingCorrelation-Fall-2026.ipynb).

Final notebook SHA-256:
`d3a53d58b9a0d5092b53fd61bd0532342b229289a39919450630af20fd206403`.

## Assessment

| Dimension | Original review | Resumed assessment | Final |
| --- | ---: | ---: | ---: |
| Technical correctness | 8.3 | 8.8 | 9.3 |
| Organization | 8.8 | 9.2 | 9.2 |
| Narrative flow | 8.2 | 8.7 | 9.1 |
| Presentation | 8.1 | 9.1 | 9.1 |
| Cognitive density and pacing | 8.1 | 8.7 | 8.7 |
| Overall | 8.3 | 8.9 | 9.1 |

The completed three-task sequence develops rolling correlations, exponentially
weighted estimates, and average correlation across a fixed subset compared with
SPY volatility. The final Summary agrees with those calculations: exponential
weighting is not described as inherently smoother, the subset is not described
as the entire market, and the closing connects the historical estimates to the
constant covariance assumption in multiple-asset GBM.

These scores are editorial judgments, not measured learning outcomes. Task 2's
distinction between decay time and equivalent observation count remains the
densest passage and needs deliberate classroom pacing. This is a stated teaching
limitation, not an outstanding proposal.

## Accepted revisions and preferences

- Developed the introduction and three learning objectives so the example can
  be read largely independently. Used the standard setup and explained aligned
  timestamps, fixed ticker order, growth-rate units, and interval-ending dates.
- Task 1 explains the complete trailing window, centered sample covariance,
  correlation normalization, and the responsiveness/noise tradeoff. Its
  large-sample standard-error illustration is explicitly scoped to independent
  bivariate normal observations; it is not an established uncertainty interval
  for the historical data. Figures show the full correlation range.
- Task 2 states the zero-mean approximation, uncentered moment updates,
  initialization from the first observations, and absence of future data in
  earlier estimates. It distinguishes decay time from equivalent observation
  count, and explains both centering and weighting differences from Task 1.
  The pair and rolling-window comparison follow the Task 1 selections.
- Task 3 uses one reproducible subset of 100 assets, averages its 4,950 distinct
  pair correlations, and compares matching windows with SPY volatility. The
  explanation preserves the growth-rate annualization and overlapping-window
  dependence. The figure uses aligned time axes with separate vertical scales.
- Kept the instructor's concise Task 3 interpretation. Avoid repeating caveats
  already developed; move directly from the output to its meaning. The risk
  interpretation concerns portfolios of long positions and recognizes the role
  of weights and asset volatilities.
- Saved three retrospective takeaways and the approved closing: “The constant
  covariance rate in the multiple-asset GBM model is a simplification: one
  estimate may describe some historical periods better than others.”
- Retained the full standard Disclaimer and Risks section verbatim from the
  reviewed L5a lecture, as explicitly requested.
- Helper functions and Julia docstrings are in
  [src/RollingCorrelation.jl](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/rolling-correlation/src/RollingCorrelation.jl)
  and
  [src/ExponentiallyWeightedCorrelation.jl](../archive/week-5-before-pivot-2026-09-18/week-5/L5a/advanced/rolling-correlation/src/ExponentiallyWeightedCorrelation.jl),
  loaded by the example's `Include.jl`. Local Markdown references explain the
  helper interfaces and supporting calculations. Do not move function
  definitions into notebook cells or combine separate `let` blocks in one cell.
- Put preview links on their own lines. Open rendered PNG previews in VS Code
  when available.

## Validation and limits

- The saved 32-cell notebook validates, has 11 code cells with unique IDs,
  exactly three objectives, three tasks, three takeaways, and six correctly
  placed major-section separators. No saved error outputs are present.
- Earlier accepted revisions executed the original and proposed code through
  Julia `include_string` in separate modules, including their local setup files.
  This was direct Julia execution, not a fresh IJulia run.
- Setup checks established 2,766 aligned growth observations and 424 assets,
  with unchanged matrix values, dates, tickers, and time step.
- Task 1 checks compared 18 selected windows with independent centered formulas
  within `1e-14`, checked helper boundaries, and preserved all six rolling series.
- Task 2 checks compared eight endpoints with independent weighted moment sums
  within `1e-14`, verified eight truncated-input prefixes, initialization and
  parameter boundaries, alternate pair/window selections, and time-scaling
  invariance of correlation.
- Task 3 checks compared four windows with explicit averages of all 4,950 pairs,
  an alternate 12-asset subset with its 66 pairs, and independent volatility
  scaling within `1e-14`. The 541 sampled windows include 54 above the historical
  90th-percentile volatility cutoff. Their average correlations are approximately
  0.473 versus 0.261 in the remaining windows.
- The final edit changed only the Summary Markdown source and exactly matches
  the approved draft. All code, outputs, execution counts, other cells, and
  notebook metadata were preserved. The local setup and both helper files match
  the previously executed Task 3 draft byte for byte. Computational execution
  was not repeated for the Summary-only change.
- At the resumed assessment, the whole notebook was rendered and all nine
  section screenshots inspected. The final notebook was exported again, its
  closing screenshot inspected, and its whole-page render checked: 88 math
  elements without reported errors, all three figures loaded, and no page or
  code-input horizontal overflow. The final preview was opened in VS Code.
- Relative notebook links and their local documentation anchors resolve. The
  RiskMetrics and official Julia/SciPy references were checked during the
  resumed assessment. The web reader returned internal errors for the two
  course-hosted function pages, so their online availability was not established.
- No commit or push was made. Existing unrelated edits were preserved.

## Recovery artifacts

The ignored `build/notebook-previews/` directory contains:

- `L5a-rolling-correlation-review-state.json`: original and resumed assessments,
  approvals, preferences, final scores, and completion status.
- `L5a-rolling-correlation-final-validation.json`: final preservation and
  structural checks.
- `L5a-rolling-correlation-final.html` and
  `L5a-rolling-correlation-final-closing.png`: final export and closing preview.
- `L5a-rolling-correlation-resumed-initial-*.png`: the complete pre-closing
  visual assessment; the developed sections are unchanged in the final notebook.
- `L5a-rolling-correlation-setup-validation.json` and
  `L5a-rolling-correlation-task1-validation.json` through
  `L5a-rolling-correlation-task3-validation.json`: prior computational checks.

Follow the shared [notebook style guide](NOTEBOOK-STYLE-GUIDE.md) and versioned
[notebook-polish workflow](../../.agents/skills/notebook-polish/SKILL.md).
Regenerate previews from the saved notebook if the preview directory is cleaned.
