# L4b parameter example — completed notebook polish

Completed September 13, 2026. The instructor accepted the final review and
explicitly requested that it be marked done and the preview directory cleaned.
All approved edits are saved; no proposals remain pending. Do not restart
completed sections unless the instructor requests another round.

Notebook:
`lectures/week-4/L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb`

Final SHA-256:
`fe14351d87cf2481e2f1e02887e0dccc2176539a940c921c81803b4b00d0f74f`

## Accepted revisions and preferences

- Improved the opening motivation and defined VWAP in Data. The instructor
  usually prefers the "In this example" overview below the learning objectives,
  but explicitly approved its position above them in this notebook. That
  preference is also recorded in the shared notebook style guide.
- Preserved the standard Setup opening and the mathematical development.
  Tightened the Task 1 transition and explained full column rank as requiring
  at least two distinct observation times.
- Explained the difference between BK's sample-mean growth estimate and
  regression slope using the telescoping sum of consecutive log-price changes.
- Made the ordinary regression error model an explicit **Engineering assumption
  (a spherical cow)**: independent normal log-price errors with zero mean and
  common variance. The notebook retains the fact that the actual Brownian
  errors are correlated and have increasing variance. Do not imply that the
  engineering assumption follows from GBM.
- The instructor requested fewer repeated qualifications. The final assumption
  block ends: "The intervals below belong to this simplified regression model."
  He explicitly deleted the following clause about the stated confidence level
  not being guaranteed under GBM. Do not restore that clause or repeat the same
  warning throughout the example.
- Linked directly to Task 1 of the advanced mean-growth uncertainty example,
  which derives regression-slope uncertainty using Brownian error covariance
  and checks it by simulation. The main example retains the ordinary regression
  calculation under its stated engineering assumption.
- Interpreted the BK regression interval under that assumption, clarified the
  saved parameter table, and aligned the second objective and takeaway with
  the uncertainty calculation. The legacy `drift` column stores mean growth;
  arithmetic drift is recovered by adding half the estimated variance.
- Added interpretations of the EQR historical price comparison, BK growth-rate
  normality results, residual density and perturbed fitted trends. Preserved
  the distinction between pointwise price intervals and whole-path coverage.
- Replaced the phrase "optional diagnostic" in the Task 1 cross-reference
  during review; subsequent tightening removed that cross-reference. The
  existing major section titled "Optional Diagnostics" remains.
- Retained the residual Anderson–Darling statistic as descriptive, with its
  existing explanation of why the usual p-value is not reported.
- Suppressed four raw intermediate displays: the mean-growth and volatility
  dictionaries, the residual tuple and the simulation matrix. Only final
  semicolons were added to code cells 16, 21, 56 and 63 (zero-based indices),
  and their saved automatic result displays were removed. The parameter table,
  comparisons, statistics and all plots remain visible.

## Final assessment

Overall editorial rating: **8.4 → 9.0 / 10**.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 9.0 | 9.0 |
| Organization | 8.5 | 9.0 |
| Narrative flow | 8.1 | 9.2 |
| Presentation | 8.4 | 9.2 |
| Cognitive density and pacing | 8.0 | 8.8 |

The main improvements are concrete result interpretation, consistent treatment
of the engineering assumption, and fewer distracting displays. Task 2 remains
the densest section; classroom feedback is needed to assess pacing. These scores
are editorial judgments, not measured learning outcomes.

## Validation and cleanup

- Valid 71-cell notebook: 42 Markdown cells and 29 code cells; exactly three
  objectives, three tasks and three takeaways.
- All seven horizontal rules immediately precede level-two sections; no
  trailing rule follows the final section.
- All six local-link occurrences and both linked notebook anchors resolve.
- All ten final section previews were visually inspected. All four plots and
  99 mathematical elements rendered without MathJax errors. A few long code
  lines use normal horizontal scrolling.
- Cell IDs, metadata and execution counts 1–29 were preserved. There are no
  saved error outputs. Relative to the review baseline, 20 Markdown cells
  changed; computational source differs only by the four final semicolons.
- Earlier fresh checks verified positive prices and aligned, sorted, unique
  timestamps for the 424 retained firms and reproduced BK/EQR estimates. The
  full notebook was not rerun during this polish.
- The target notebook passed `git diff --check`. No commit or push was made.
- The instructor requested removal of the contents of
  `build/notebook-previews`. Preview images, HTML exports, draft notebooks and
  transient review files are disposable; this handoff preserves the completed
  review's decisions and assessment. Historical links to those previews may
  no longer resolve. Regenerate previews from the saved notebooks when needed.

