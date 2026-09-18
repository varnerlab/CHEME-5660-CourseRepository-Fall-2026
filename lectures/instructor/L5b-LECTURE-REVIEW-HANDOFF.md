# L5b lecture — completed notebook polish

> **September 18 relocation:** This record describes the pre-pivot Week 5. Its notebook and slide links now point to the archived material; its approved assessment remains closed. See the [refactor handoff](WEEK-5-REFACTOR-HANDOFF.md) for current teaching locations and the scope of subsequent changes.

**Status: reviewed and complete, September 15, 2026, confirmed by the instructor.**
The instructor explicitly requested “Great. Mark this notebook as reviewed.”
All proposed sections were approved and saved. The final revision approval, after defining systematic risk in the
closing sentence, was “Agree. Update. Next.” The final review and rescoring are
complete; no proposals remain pending. Do not restart completed sections unless
the instructor requests another round.

Notebook: [Minimum-variance portfolios, the frontier, and the CAL](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb)

Initial SHA-256:
`845c36017a5c4993fc3e90c9f17ea9a4e2228ea1ec3dc661c6981203aec4428c`

September 15 review SHA-256:
`c1eb5036fe09785aad0419544439fce597c15cbe73b1e6019ea2fd838965fdab`

## September 17 scope alignment

During the L5b slide review, the instructor clarified that the course proceeds
to SIM, not CAPM, and explicitly authorized matching changes to this notebook.
This amendment supersedes the market-portfolio revision recorded below; the
September 15 assessment and other approved material remain unchanged.

- Removed “When Is the Tangent Portfolio the Market Portfolio?” and its CAPM,
  market-clearing, and capital-market-line discussion.
- Removed the corresponding clauses from Objective 3 and Takeaway 3.
- Connected two-fund separation directly to “Estimating Portfolio Inputs.”
  Preserved the closing introduction of a model separating systematic and
  firm-specific risk.
- Validated the notebook schema, exactly three objectives and three takeaways,
  and nine major-section separators, each preceding a level-two heading.
  All unrelated cells and all retained metadata are unchanged. Rendered and
  visually checked the edited opening, transition, and summary; no math errors
  or horizontal overflow were reported. The notebook has no executable cells.

Current SHA-256:
`d0fb3ae529194f004f9da166f2dcb05ab65b4ecafeecceb1ee2f50777f7913a5`

## Assessment

The instructor requested polishing only if the initial score was below 9/10.
The initial score was 8.5/10; the final score is **9.1/10**.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 8.5 | 9.1 |
| Organization and sequence | 9.0 | 9.2 |
| Narrative and interpretation | 8.5 | 9.1 |
| Presentation | 8.5 | 9.3 |
| Cognitive density and pacing | 8.0 | 8.9 |
| Overall | 8.5 | 9.1 |

The revised sections consistently use the established mean-growth notation,
distinguish equality targets from growth floors, and compare each constrained
problem with its own GMV portfolio. The CAL calculation now develops the complete
portfolio, Sharpe-ratio scaling, tangent weights, and two-fund separation in
separate steps. Both approved vector figures appear in the lecture.

The short input-estimation section and retrospective takeaways give the lecture
a more direct ending. The main remaining teaching demand is the sequence of
matrix derivations: the frontier's full derivation is developed in the optional
example, and the tangent stationarity equation is stated rather than derived
term by term. Scores are editorial judgments; classroom pacing has not been
measured. No further substantive revisions are proposed in this round.

## Approved revisions

- **Frontier:** Preserved the GMV derivation and long-only formulation before the
  revised subsection. Introduced the equality target with `mu_g`, displayed the
  four frontier coefficients, and completed the square to identify the GMV
  growth and variance. Connected efficiency to the figure's portfolios `p1`,
  `p2`, and `p3`. The growth-floor explanation compares targets with the GMV
  portfolio under the same weight constraints. The instructor approved a
  tightened second draft.
- **Risk-free asset:** Preserved the matched-horizon definition and complete
  portfolio equations. Organized lending, full risky investment, and borrowing
  by the value of `w_f`. Related one-day and annualized Sharpe ratios to the
  independent-increment model already introduced in L5a, with units explicit.
  Added the tangent stationarity equation and retained the positive-definite
  covariance and GMV-growth conditions for the closed form. Explained the
  long-only numerical approximation directly.
- **Figures:** Retained the approved frontier SVG and replaced the old CAL PNG
  reference with `figs/capital-allocation-line/cal.svg`, both at width 760.
  The earlier figure work established matching typography, a subtle gray plot
  region, vector exports, and descriptive SVG metadata. This notebook round
  made no slide changes.
- **Market portfolio:** Used a short market-clearing argument to explain why
  the shared risky fund has market-value weights under the CAPM. Preserved the
  distinction between that model result and the selected-universe allocation
  computed in the example.
- **Input estimates:** Replaced “Estimation Risk Can Dominate Optimization” with
  “Estimating Portfolio Inputs.” The accepted section contains 174 prose words
  under the preview's count, including the example description. It identifies
  the inputs used by GMV and tangent calculations, gives the AMD comparison,
  explains the effect of underestimated variance, and leads into simulation.
- **Closing:** Added question-led descriptions matching the two advanced
  notebooks. Retained exactly three takeaways in the retrospective teaching
  voice. The opening explicitly names the minimum-variance problem, GMV weights,
  and frontier. The diversification takeaway states the positive-weight
  two-asset case. The final sentence introduces a model generally and defines
  systematic risk as risk associated with factors shared across assets.

## Instructor preferences to preserve

- Use plain, descriptive section titles. The instructor rejected the inflated
  “Estimation Risk Can Dominate Optimization” title and the long treatment that
  accompanied it. Keep the accepted short section; do not restore its spectral
  discussion, resampling discussion, or evaluation checklist to the main lecture.
- State mathematical assumptions where they support a result. Avoid repeated
  model qualifications and generic warnings. The instructor specifically
  rejected the extra sentence announcing that the borrowing segment assumes
  the same lending and borrowing rate. Borrowing is already defined at `g_f`;
  the geometric consequences of restrictions belong in two-fund separation.
- The accepted risk-free revision removes the early-sale aside, the vague
  “requires additional care” warning, and the negative/zero-denominator detour.
  It keeps the conditions needed for the tangent formula. Do not restore the
  removed passages merely because they appeared in the initial assessment.
- The instructor asked whether GMV had been defined. It is explicitly expanded
  and defined in “The global minimum-variance portfolio,” before its first
  abbreviated use; this existing definition was preserved.
- The next lecture introduces factor models generally and uses the single-index
  model for convenient calculations. The L5b closing should say “a model,” not
  name the single-index model in advance.
- Explain newly introduced terms briefly. The instructor specifically requested
  a definition of systematic risk in the closing sentence.

## Validation and scope

- Read the entire lecture and relevant companion and advanced materials, along
  with the shared style guide, applicable agreements, the 2025 portfolio
  lecture and SIM interpretation reference, and the completed L5a lecture handoff.
- The final notebook passes `nbformat.validate`. Only Markdown sources in
  zero-based cells 4–9 changed. Cells 0–3 and 10, all notebook/cell metadata,
  and the GMV and long-only portions of cell 4 are preserved. Every approved
  source matches the saved notebook exactly.
- Exactly three objectives, three takeaways, and ten major-section separators.
  Every separator precedes a level-two heading; none follows the final section.
  All eleven relative link/image occurrences resolve. Obsolete `bar(g)` and
  `hat(g)` mean-vector notation is absent from the lecture.
- Rendered the complete final notebook with nbconvert, local MathJax SVG output,
  and isolated headless Chrome. All 166 math expressions rendered without
  reported errors; both figures loaded; no page-wide horizontal overflow.
  Inspected the six changed sections visually in the final render. The
  preserved sections had also been inspected during the opening assessment.
- Independent checks during the round verified GMV weights and variance,
  31 exact-growth frontier solutions, the completed-square identity, tangent
  stationarity and the maximum-Sharpe bound, lending/borrowing allocations,
  daily/annual scaling, and the no-borrowing boundary on both sides of tangency.
  The last check used a 200,001-point risky-fraction sweep at four risk levels;
  its largest growth discrepancy was about `5.2e-15`.
- Checked the AMD comparison against saved data-example output: `0.4397 -
  0.3120 = 0.1277` per year, rounded to 12.8 percentage points per year. Inspected
  the separate resampling experiments and the simulation's fixed inputs,
  buy-and-hold wealth, prediction bands, and scaled-NPV probability calculation.
- The lecture contains no executable cells. Companion Julia notebooks were
  inspected, not re-executed or edited by this review. Their concurrent edits
  were preserved. No packages changed. An auxiliary Anaconda SciPy binary
  incompatibility was bypassed using system Python and NumPy for the independent
  checks. The connected Browser had no available backend; final rendering used
  the isolated local browser instead.
- Consulted [Sharpe's discussion of Sharpe-ratio scaling](https://web.stanford.edu/~wfsharpe/art/sr/SR.htm)
  and [Goetzmann's market-equilibrium explanation](https://viking.som.yale.edu/an-introduction-to-investment-theory/chapter-iv-the-portfolio-approach-to-risk/).
  Whitespace checks passed. No commit or push was made.

## Saved artifacts

The ignored `build/notebook-previews/` directory contains initial assessment,
approved drafts, and these final artifacts:

- `L5b-lecture-final.html`: the full final render.
- `L5b-final-*.png`: eleven section previews.
- `L5b-final-validation.json`: preservation, notation, links, and structure checks.
- `L5b-final-render-metrics.json`: final browser rendering checks.
- `L5b-polish-state.json`: accepted sections and completed review status.

Previews are disposable; regenerate them from the notebook if cleaned. This
record preserves the completed review. The [shared style guide](NOTEBOOK-STYLE-GUIDE.md)
and [versioned workflow](../../.agents/skills/notebook-polish/SKILL.md) remain the
maintained instructions.
