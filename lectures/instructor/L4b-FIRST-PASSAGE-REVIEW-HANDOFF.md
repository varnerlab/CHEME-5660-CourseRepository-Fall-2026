# L4b first-passage example — completed notebook polish

Reviewed September 13, 2026. The instructor confirmed: “Ok - mark this notebook
as reviewed.” Final rating: **9.2/10**, including the shorter Task 2, documented
source functions, and final code-commenting pass. All approved revisions are
saved; no proposals remain pending. Do not restart completed sections unless
the instructor requests another round.

Notebook:
`lectures/week-4/L4b/advanced/first-passage/CHEME-5660-L4b-Advanced-FirstPassage-GBM-Fall-2026.ipynb`

Final SHA-256:
`0b58c2639d09a42d09ed534886383e97a08b98becf7fd1a3aa5c1cabfa0ddba5`

## Accepted revisions and preferences

- Revised the introduction, three objectives, setup references, and task
  explanations while preserving the mathematical development and teaching voice.
- Used the current lecture's mean-growth notation, `μ_g = μ - σ²/2`, throughout.
  The instructor explicitly requested plain English in task titles.
- Developed the distinction between finishing above the take-profit price and
  reaching it during the holding period. Linked the drifted Brownian reflection
  result to its primary source and documented the single-barrier helpers.
- Explained lattice calibration, separate simulation and monitoring intervals,
  propagation of open-position probabilities, exact daily GBM simulation, and
  Monte Carlo standard errors. Added local documentation for the lattice and
  Monte Carlo functions.
- Interpreted the comparison using both lattice approximation and simulation
  uncertainty. The daily take-profit estimates differ by about 0.59 percentage
  points, or 3.7 Monte Carlo standard errors; do not describe this as agreement
  within sampling error. More frequent monitoring reduces the still-open
  probability, but either competing exit probability can decrease.
- Fixed the infinite-horizon calculation at zero mean growth. The nonzero case
  uses an algebraically equivalent expression with `expm1`; the zero case uses
  the limit `-a/(b-a)`. The three-year comparison distinguishes finite-horizon,
  monitoring, and lattice-resolution effects.
- Reorganized Task 3 around nested monitoring schedules and the shifted upper
  boundary approximation. Retained the Broadie–Glasserman–Kou citation and
  qualified the observed square-root trend and approximation accuracy using
  Monte Carlo uncertainty. Added monitoring-helper documentation.
- Printed monitoring intervals in scientific notation so the two finest time
  steps remain distinguishable. Revised exactly three retrospective takeaways
  and the closing sentence.
- Corrected both figures, including their saved PNG, SVG, and HTML outputs.
  Initial margin checks missed an overlapping legend and sparse axis labels;
  the instructor identified those defects and requested a broader quality check.
  Both legends now sit above the plotting area. The monitoring plot labels all
  seven intervals, uses trading days horizontally and percentage points
  vertically, and has larger type. PNGs are 1720 × 1040 pixels, with 860 × 520
  display metadata; SVG output remains available. Future figure reviews must
  check legend placement, useful ticks, type size, and sharpness as well as
  clipping.
- At the instructor's request to hurry, the remaining comparison, monitoring,
  numerical, and summary changes were bundled into one final proposal. The
  instructor approved that batch with “Agree. Update. Next.”

## Final assessment

Overall editorial rating: **8.2 → 9.2 / 10**. The first completed pass scored
9.1/10; the instructor-requested Task 2 trimming and source refactor brought the
final assessment to 9.2/10.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.5 | 9.2 |
| Organization | 8.5 | 9.4 |
| Narrative flow | 8.0 | 9.2 |
| Presentation | 8.5 | 9.3 |
| Cognitive density and pacing | 7.5 | 9.0 |

The gains reflect the corrected zero-growth calculation, clearer explanatory
sequence and result interpretation, consistent notation, documented helpers,
and readable figures and time-step table. Task 2 remains the densest material;
classroom feedback is needed to assess its pacing. These scores are editorial
judgments, not measured learning outcomes.

## Validation

- Executed all ten post-setup computational cells using the installed course
  packages, including both Monte Carlo studies. The revised plotting cells were
  subsequently executed to regenerate both figures. `Include.jl` was inspected;
  package activation and installation were not rerun during these checks.
- Preserved the default results: terminal probability 0.3226141372 and
  continuous reach probability 0.5834861105. Verified probability conservation,
  monotonicity on the nested observation grids, and the saved simulation values.
- Checked the infinite-horizon default result 0.5185618925, zero-growth limit
  0.4666224986, symmetric zero-growth case 0.5, and growth rates near zero.
- Inspected the full rendered draft, including both tables, both figures, all
  task explanations, and the summary. All 79 mathematical elements rendered
  without MathJax errors; both figures loaded and the page had no horizontal
  overflow. Long source-code lines can still require normal cell scrolling.
- Validated the 26-cell notebook, exactly three objectives, three tasks and
  three takeaways, section separators, and local notebook/documentation links.
  There are no saved error outputs. The saved notebook equals the inspected
  final draft, with cell IDs, execution counts, and unrelated metadata preserved.
- Changes passed the focused whitespace check. No commit or push was made.

Full preview, while retained:
`build/notebook-previews/L4b-first-passage-quality-full-preview.png`.
The preview directory is disposable; regenerate from the saved notebook if this
path is later cleaned.


## Follow-up: shorter Task 2 and functions moved to source files

Requested and completed September 13, 2026, after the initial round. The instructor
explicitly requested that function definitions leave the notebook and receive
proper Julia docstrings. This is now recorded in the shared notebook style guide.

- Moved all six function definitions, with unchanged calculations, into
  `src/Probabilities.jl`, `src/Lattice.jl`, and `src/Simulation.jl`.
  `Include.jl` loads these files. Notebook function links now point to the source;
  earlier Markdown reference pages identify the updated locations.
- Each function has a Julia docstring with its signature, arguments and units,
  returned values, assumptions, and relevant monitoring or sampling behavior.
- Shortened Task 2 by removing implementation details and repeated explanations,
  while retaining every displayed equation, the probability-propagation steps,
  the daily-monitoring distinction, the numerical comparisons, and the
  infinite-horizon check. Text outside display equations decreased from about
  1,212 to 817 words; Task 2 code decreased from 90 to 25 lines.
- Executed the actual `Include.jl` setup and all ten remaining notebook code
  cells. All 65 checks passed: 34 comparisons against the original functions,
  24 docstring/source-location checks, and 7 notebook-result checks.
  This follow-up includes setup execution, unlike the earlier polish checks.
- Inspected Task 2 with its remaining code visible: all 29 math elements rendered
  without errors or page overflow. Preserved all stored outputs, both corrected
  figures, cell IDs, metadata, and execution counts. Verified source links and
  exact agreement between the saved notebook and inspected draft.
- The final rating after this follow-up is 9.2/10, up from 9.1/10 after the
  first pass. No proposal remains pending.

Follow-up preview:
`build/notebook-previews/L4b-first-passage-task2-trim-preview.png`.


## Final code-commenting pass and reviewed status

The instructor also requested a quick commenting pass on the notebook code
cells before closing the review. Added compact block and inline comments for
the model units, daily versus continuous checks, probability inclusion check,
zero-growth limit and numerical stability, table comparisons, monitoring
intervals, and plot units/reference scaling. Existing adequate comments were
retained; no function definitions were reintroduced.

A Julia parser comparison, ignoring comments and source line locations,
confirmed identical executable syntax in all 11 code cells. Notebook prose,
cell IDs, metadata, execution counts, and every saved output were preserved.
The notebook and review record have matching final hashes, and the focused
whitespace check passed. The 65 execution and equivalence checks from the source
refactor remain applicable because this last pass changed comments only.

Status: **reviewed and complete**. Final rating: **9.2/10**.
