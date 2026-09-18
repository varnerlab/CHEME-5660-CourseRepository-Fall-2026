# L5b advanced frontier geometry — completed notebook polish

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Status: reviewed and complete, confirmed by the instructor September 16, 2026.**
After final validation and rescoring, the instructor confirmed: “Great! Mark this
as reviewed.”
The instructor approved the final Summary with “Ok, agree. revise to 50% position
limit. Update. next.” The accepted Summary is saved with that terminology.
No proposals remain pending for this notebook. Do not restart approved sections
unless the instructor requests another round. The estimation-risk companion is
being reviewed separately and is not covered by this completion record.

Notebook: [Frontier Geometry and the Two-Fund Theorem](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/frontier-geometry/CHEME-5660-L5b-Advanced-FrontierGeometry-Fall-2026.ipynb)

Initial SHA-256:
`aec558f7d03a3c1892161503cabb88fa1278c6c3e7d2756c6c135580d3df9148`

Final SHA-256:
`5be1a8d425db3820ad6ca8f9da8dc91ee4dd79a23d35ba971cc3cec9ce29e2c2`

## Assessment

The initial score was **8.4/10**; the final score is **9.2/10**.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 8.5 | 9.3 |
| Organization and sequencing | 8.8 | 9.2 |
| Narrative flow and interpretation | 8.3 | 9.2 |
| Presentation | 8.5 | 9.2 |
| Cognitive density and pacing | 8.0 | 9.0 |
| Overall | 8.4 | 9.2 |

The notebook now develops the multiplier equations, portfolio weights, variance,
GMV interpretation, and two-fund representation in explicit steps. Calculations,
tables, plotting, and interpretation have separate stopping points. The original
numerical comparisons are preserved, while the figures show their complete data
ranges and the prose correctly describes the two non-nested weight restrictions.
The final takeaways explain the mathematical results and their implications,
including the measured constraint costs, rather than merely listing activities.

These scores are editorial judgments, not measured learning outcomes. The
advanced derivation still requires sustained attention, and classroom pacing
has not been tested. Risk ratios interpolate 60-point frontier grids and are
rounded for display; the notebook now explains why a displayed ratio of 1.000
can conceal a small positive cost. The results concern the selected firms and
fixed historical estimates, not predictive performance. No additional substantive
rewrites are proposed for this completed round.

## Approved revisions

- **Opening and setup:** Three objectives aligned with three tasks. Standard
  setup explanation; separate loading, firm selection, growth construction, and
  estimation cells. The instructor requested clearer notation and explanations
  and rejected an unnecessary date-assertion loop for this already-checked dataset.
- **Notation and derivation:** Population mean vector `mu_g`, sample mean vector
  `g-prime`, and estimated growth covariance agree with the reviewed lecture.
  Typed Julia variable references connect the mathematics with implementation.
  The derivation retains stationarity, the two multiplier equations, coefficients
  a/b/c/d, positive-definiteness and nonconstant-mean assumptions, closed-form
  weights, completed-square variance, and efficient/dominated branch reasoning.
- **Task 1 checks:** Separate coefficient and GMV calculations; compact solver
  comparison table instead of printed per-target lines. The frontier plot includes
  both branches, their shared GMV endpoint, selected targets, and individual firms.
- **Two-fund construction:** Defined a fund and normalized the two directions;
  retained the condition b != 0 for the chosen second fund and the alternative
  when it fails. Derived the mixing fraction and its growth interpretation,
  including the dependence on the sign of b. Fund and asset weights are distinguished.
- **Task 2 reporting and figure:** Separate fund summary, mixture checks, coordinate
  calculation, and plotting cells. All 36 original mixtures are visible. The
  instructor requested shorter interpretation and filled-circle markers for the
  two funds. The risk-free connection refers to the lecture's stated assumptions.
- **Constraint comparison:** Defined unrestricted, 50% position-limited, and
  long-only weights without claiming the latter two are nested. Separated GMV
  calculations, frontier sweeps, and a compact starting-point/count table. The
  comparison figure uses filled-circle firm markers and, at the instructor's
  request, denser ticks: horizontal spacing 1 and vertical spacing 0.05.
- **Risk ratios:** Explicit standard-deviation ratio definition; interpolation and
  reporting in separate cells; fixed decimal table formatting. The interpretation
  corrects the original claim that the position limit remains inactive at all
  higher reported targets. It links to estimation risk without asserting future
  performance from geometry alone.
- **Source helpers:** Four documented functions in local `src/FrontierGeometry.jl`,
  loaded through `Include.jl`: `frontier_weights`, `frontier_variance`,
  `solve_frontier_point`, and `interpolate_frontier_risk`. The local reference page
  documents inputs, units, assumptions, and outputs. Interpolation returns NaN
  outside the sampled range; it does not extrapolate.
- **Closing:** The first proposed takeaways were rejected as weak. The approved
  revision explains the GMV and branch result, one changing fund fraction with
  fixed holdings within each fund, and quantified constraint costs. The instructor
  then requested the explicit phrase “50% position limit” in place of “the cap”
  throughout the Summary. The body retains the already-defined position-cap label.

## Mathematical correction to preserve

The two bounded feasible sets are not nested: the 50% position limit permits
shorts but excludes larger individual long positions; long-only permits a
100% long position but excludes shorts. Their costs depend on the target and inputs.

At growth targets 0.10, 0.20, 0.30, 0.40, and 0.50 per year, the largest absolute
unconstrained weights are respectively 0.6040664, 0.5341275, 0.4641887, 0.4315474,
and 0.5386748. The 50% position limit is satisfied at 0.30 and 0.40, but excludes
the optimum again at 0.50. Its interpolated standard-deviation ratio at 0.50 is
1.0003227613, which rounds to 1.000 and corresponds to approximately 0.03% extra
standard deviation. Long-only gives 1.3313042238 there, or about 33.1% extra.
The unconstrained GMV's JNJ weight is 0.6155361. Do not restore the incorrect
claim that the position limit matters only near the GMV portfolio.

## Instructor preferences

- Preserve developed mathematical steps and explain why each calculation is needed.
- Use typed variable references where they connect notation with stored results.
- Split combined cells into calculations, reporting, and plotting with prose between.
- Prefer compact tables to streams of printed comparisons.
- Keep figure interpretation concise; use filled circles for points of interest
  and sufficient axis ticks. Preserve the separately approved Task 1 figure.
- Use descriptive terminology in the Summary: “50% position limit,” not unexplained
  shorthand. Three takeaways should state results, reasoning, and purpose in a
  retrospective teaching voice.
- Do not reintroduce the rejected date-check loop or restart accepted derivations.

## Final validation

- Read the full final narrative and checked it against the approved objectives,
  calculations, figures, and takeaways. Exactly three objectives, three tasks,
  three takeaways, and six correctly placed major-section separators.
- `nbformat.validate` passes: 67 cells, including 25 code cells, no error outputs.
  Each code cell contains at most one `let` block; named helper definitions are
  in local source. All 15 local link occurrences resolve, including local anchors.
- Executed every code cell in order in a fresh Julia 1.12.7 process, including the
  actual `Include.jl`. Used `include_string` with the original notebook path so
  `@__DIR__` resolves correctly. This was not an IJulia kernel run. A temporary
  writable depot and offline package mode were used; the final run passed.
- Independently compared the closed-form weights at 31 targets with an equality-
  constrained block-system solution. Maximum weight difference: 3.33e-16;
  budget residual: 2.22e-16; growth residual: 1.11e-16.
- All 180 frontier points and 36 fund mixtures passed. GMV expected growth:
  0.08360039285 per year; standard deviation: 2.16353428050 per year. Mixture
  weights satisfy the budget and reproduce the closed-form risks.
- Earlier section checks compared old/new computations, verified all interpolation
  nodes and adjacent midpoints, outside-range behavior, the fund budgets and targets,
  constraint weights, rounded table values, and complete figure-axis coverage.
- The final full render uses nbconvert and local MathJax SVG. All 151 expressions
  rendered without errors, all three 900-pixel figures loaded, and no page or
  code-cell horizontal overflow was detected. Inspected the final Summary,
  verification table, constraint table, and the figures throughout the round.
- `git diff --check` passes for the requested notebook/supporting files and record.
  The estimation-risk source remained unchanged when this review closed. No
  package, slide, commit, or push changes were made; unrelated edits were preserved.

## Records and artifacts

Supporting files:

- [Include.jl](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/frontier-geometry/Include.jl)
- [FrontierGeometry.jl](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/frontier-geometry/src/FrontierGeometry.jl)
- [Function reference](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/frontier-geometry/docs/frontier-geometry.md)

The ignored `build/notebook-previews/` directory contains the detailed approval
history in `L5b-advanced-review-state.json`, the initial assessment, accepted drafts,
execution checks, and `L5b-advanced-frontier-final*` render/validation artifacts.
Previews are disposable; this record preserves the completed review if they are
cleaned. The shared style guide and versioned notebook-polish workflow remain the
maintained instructions.
