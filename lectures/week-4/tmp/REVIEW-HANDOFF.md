# L4a N-ary example review — resume here

Saved September 10, 2026 at the instructor's request. Updated September 11,
2026 when he returned and approved deleting the obsolete issue record.

## Active file and working agreement

Notebook: [L4a N-ary lattice example](../L4a/CHEME-5660-L4a-Example-N-Ary-Lattice-Fall-2026.ipynb).

Continue **interactively, one issue at a time**: propose concrete wording or a
change, wait for approval, apply it, and present the next issue. The instructor
prefers this to an autonomous rewriting pass. Preserve his hand edits and the
approved teaching voice. Read the shared [notebook style guide](../../instructor/NOTEBOOK-STYLE-GUIDE.md).
Keep exactly three learning objectives and three retrospective key takeaways.
The L4a lecture and completed cumulative-probability example are closed; do not
reopen them. L4a slide updates were completed earlier.

## Completed and approved

- Revised the introduction, learning objectives, setup, data explanation,
  historical growth calculation, parameter estimation, and lattice construction.
  Task sections explicitly begin with “In this task, …”.
- Use `m` for the branch count. Package interfaces retain their existing keyword
  or field `n`, passed as `n=m`. Local helper documentation is under `L4a/docs/`.
- Explain that calibration uses the full historical sample, including data after
  the selected starting day. This is an illustration, not an out-of-sample forecast.
- Compare equal-width and quantile calibration with branch tables, historical
  histograms showing boundaries and representative branch growth, and mean,
  standard deviation, and variance-retention calculations.
- Follow the instructor's growth convention: historical one-step log growth is
  `r=g*Δt`; branch log growth is `log(f)`. Factors are averages of `exp(r)` within
  bins. This preserves the empirical mean factor, but generally not mean log
  growth or its variance. Do not revert to simple-return diagnostics.
- `print_lattice` in `L4a/src/Split.jl` now uses the standard DataFrame/PrettyTables
  compact format. **Keep the later raw field-name and dictionary displays**:
  the instructor explicitly rejected replacing that lattice inspection with a
  compact table and said he likes seeing the raw structures.
- Added `binning_method` to the constants and connected it to the estimator.
  The comparison evaluates both methods; `result` and the downstream lattice
  use the selected method.
- Clarified the connection between the multinomial formula, `Multinomial(TSIM,p)`,
  node counts, and the price/probability columns. Function references in prose
  link to local helper docs or verified hosted package/Julia documentation.
- Replaced the terminal share-price stems/markers and large annotation with
  **interval probability bars**, approved after a visual comparison. Sum node
  probabilities in each interval; do not count nodes or normalize to density.
  Keep the simple blue bars, gray plot background, and restrained labels.
- Converted the annualized growth-rate plot to the same interval-bar style.
  Both plots retain all underlying node probabilities; bar heights can differ
  because equal-width price intervals are not equal-width growth-rate intervals.
- Added the approved class experiment: vary `TSIM` among 8, 20, and 60 while
  holding the other settings fixed and rerunning the notebook. The instructor
  will do this live; **do not add a separate multi-horizon computation or figure**
  without a new request. More steps spread probability across more outcomes but
  do not guarantee a smooth curve.
- Added the approved explanation that annualized log-growth variability decreases
  with more independent steps even while terminal prices can spread out:
  annualization averages the log-growth contributions over the holding period.
- Updated the first and third key takeaways to summarize the binning comparison
  and interval plots/holding-period exploration. The second takeaway was retained.

## Current defaults and validation

`TSIM=8`, `Δt=1/252`, `m=3`, `binning_method=:equalwidth`,
`price_interval_width=2.0` USD/share, `growth_interval_width=0.5` inverse years.
Selected ticker is AAPL; `start_index=1465`. Defaults were not changed for the
longer-horizon previews.

- The notebook executed successfully after each figure change. Rendered figures
  were inspected; their saved outputs were refreshed in the live notebook.
- Independently summed probabilities by interval and checked the rendered bar
  heights against those sums; each plot's total probability is one.
- Checked that switching `binning_method` to `:quantile` selects its estimates.
- Notebook structure was validated. Subsequent approved prose changes preserved
  code and outputs. Exactly three objectives and takeaways remain.
- A prior independent ordered-path audit found no implementation error for the
  default 8-step configuration; audit artifacts are listed below.
- The 20- and 60-step previews were independent Python multinomial calculations,
  **not full Julia notebook executions at those horizons**. If final classroom
  readiness checks are requested, testing the actual notebook at those settings
  is a useful remaining check. Do not report that this has already been done.

Current default calibration retains about **42.8%** of historical one-day
log-growth variance; quantile calibration retains about **66.5%**. These are
coarse approximations. Better-looking plots do not establish calibration quality.
The all-middle 8-step path has probability about 0.6133; this is distinct from the
probability of the containing price interval, which also includes other states.

## Exact stopping point / next item

The narrative review and final key-takeaway updates are complete. On September
11, the instructor approved deleting the obsolete `issue-to-fix.md` rather than
rewriting it. That deletion is complete; do not recreate the file. The calibration
limitations remain documented in this handoff and the notebook.

The optional remaining check is to execute the actual Julia notebook at 20 and
60 steps, as distinguished from the Python previews above. No further notebook
edits or execution checks were requested with the deletion. Continue from the
instructor's next instruction; do not restart the completed narrative review.

## Temporary artifacts, if still available

- `/private/tmp/nary-growth-bars-j7chgm8n/`: latest executed QA copy and
  `growth-bars.png`; final QA cell verifies rendered growth bar probabilities.
- `/private/tmp/nary-price-bars-lfyygk_d/`: executed price-bar QA and `price-bars.png`.
- `/private/tmp/nary-binning-setting-drji187i/`: default/switching-method check.
- `/private/tmp/nary-growth-comparison-mg99ey7l/`: log-growth moment comparison QA.
- `/private/tmp/nary-horizon-comparison.png`: 8/20/60-step preview; the panels use
  different vertical scales and a common central price window.
- `/private/tmp/nary-independent-audit-f3_6ou34/`: original independent audit data
  and scripts. Preserve the durable findings even if these temporary files vanish.

Temporary executed notebooks use an absolute setup include and may contain extra
QA cells. Never copy them wholesale over the course notebook. Preserve its local
setup and refresh only specifically changed outputs when needed.
