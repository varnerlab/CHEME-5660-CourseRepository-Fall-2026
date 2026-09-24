# Week 6 source inventory and proposed assembly

Recorded September 23, 2026, following publication of Week 05.3.

The instructor confirmed the new teaching sequence:

- **L6a: Data-driven minimum-variance portfolios.**
- **L6b: Single Index Model, SIM portfolio allocation, and a risk-free asset.**
- **L7a and L7b: Alternative utility-based allocation approaches.**

The instructor subsequently clarified that the minimum-variance development
must fit in Week 6. Risk-free allocation is a core topic in L6b. Both Week 7
meetings are reserved for utility-based alternatives; they are not overflow
meetings for SIM or minimum-variance theory. The particular utility models and
their split between L7a and L7b have not yet been selected.

## Compressed teaching sequence

| Meeting | Core development | Material supporting the main development |
| --- | --- | --- |
| L6a | Estimate mean growth and covariance from data; formulate minimum variance with budget, weight, and growth constraints; interpret the global minimum-variance portfolio and efficient frontier; examine allocations and held-out performance. | Archived reviewed data-driven lecture and example. Keep the detailed frontier derivation, estimation-risk experiments, and GBM portfolio simulations available as companions. Teach the risk-free extension in L6b. |
| L6b | Introduce and fit the SIM; interpret alpha, beta, and residual risk; construct portfolio mean/covariance inputs; reuse L6a's allocation problem; add the risk-free asset, tangent portfolio, and capital allocation line. | Combine selected sections from the two current SIM lectures with the reviewed risk-free development. Retain estimation, bootstrap, and portfolio examples, with full bootstrap development and extended diagnostics in the companion notebooks. |
| L7a and L7b | Alternative utility-based approaches to allocation. | The current L7a utility material and short-course utility material are candidate sources. The current L7b online-SIM lecture needs reconsideration against this new scope. |

Compression should come from teaching the allocation problem once, using its
result in L6b, and selecting which calculations belong in companion notebooks.
Preserve the reviewed source passages and full examples when moving material;
do not impose broad prose cuts or shrink slide text to fit two complete decks
into one meeting.

This record inventories the available sources and recommends how to assemble
them. No lecture, example, slide, or archived payload was changed during this
inventory. The destinations are confirmed; the detailed live-example sequence
and optional additions below remain proposals.

## Material preserved during the Week 5 pivot

The source is [the September 18 archive](../archive/week-5-before-pivot-2026-09-18/README.md),
specifically its `week-5/L5b/` directory. All 51 files in that subtree match the
archive's saved SHA-256 manifest, with no missing or mismatched files. This is
a versioned archive; `git stash list` is empty. The original Week 6 remains in
the active `lectures/week-6/` directory and has not yet been archived for this
refactor.

The [pivot handoff](WEEK-5-REFACTOR-HANDOFF.md) explicitly reserved this old L5b
for the new L6a. [Section 14 of the saved plan](../../week-5-reactor.md#14-interactive-review-decisions)
also records the SIM/portfolio combination and the instructor's direction to
reuse the 2025 bootstrap development.

| Archived source | Contents and proposed use |
| --- | --- |
| [Minimum-variance lecture](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb) | Primary source for L6a's reward/risk, global minimum variance, long-only constraints, target-growth frontier, and input estimation. Its reviewed risk-free, tangent-portfolio, and capital-allocation-line sections supply L6b. |
| [Data-driven portfolio example](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Example-Data-MinVar-Portfolio-Fall-2026.ipynb) | Three existing tasks: estimate inputs and allocations; frontier and risk-free asset; evaluate frozen buy-and-hold allocations on 2025 prices. Reuse the data-driven calculations for L6a and relocate the risk-free development to the L6b sequence, preserving the reviewed source. |
| [Multiple-asset GBM portfolio example](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/CHEME-5660-L5b-Example-MAGBM-Portfolio-Fall-2026.ipynb) | Correlated price simulation, fixed-share wealth, and portfolio NPV probabilities. Companion application connecting Week 5 to portfolio allocation. |
| [Advanced material](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/advanced/README.md) | Frontier geometry/two-fund construction and estimation risk; retain as optional supporting material. |
| [30-page slide deck](../archive/week-5-before-pivot-2026-09-18/week-5/L5b/slides/CHEME-5660-L5b-Slides-Fall-2026.pdf) | Source frames for L6a, with risk-free/CAL frames reserved for L6b. The archive includes TeX, figures, setup files, and helper code. |

These are reviewed artifacts. Their saved assessments are 9.1/10 for the lecture
and data example, and 9.2/10 for the slides, GBM example, and two advanced
examples. Those scores describe the recorded historical snapshots; relocation
does not require reopening their approved sections.

## What is currently in Week 6

The active week contains eight notebooks and two decks. It still follows the
earlier two-meeting SIM sequence:

| Current location | Available material |
| --- | --- |
| [L6a SIM lecture](../week-6/L6a/CHEME-5660-L6a-Lecture-SIM-Fall-2026.ipynb) | Factor models, alpha/beta/residual interpretation, covariance structure, least squares, uncertainty, and diagnostics; 20-page companion deck. |
| [L6a estimation example](../week-6/L6a/CHEME-5660-L6a-Example-SVD-SIM-Estimation-Fall-2026.ipynb) | Fit one firm three ways, evaluate fit/uncertainty, fit the universe, check residual correlations, and save the parameter archive. |
| [L6a uncertainty example](../week-6/L6a/CHEME-5660-L6a-Example-SIM-Parameter-Uncertainty-Fall-2026.ipynb) | Empirical-residual and Gaussian bootstraps plus residual diagnostics. Broader than the 2025 example. |
| [L6a advanced theory](../week-6/L6a/advanced/sim/CHEME-5660-L6a-Advanced-SIM-Theory-Fall-2026.ipynb) | Unit conventions, ridge covariance, bootstrap theory, covariance structure, and maximum-Sharpe optimization. |
| [L6b portfolio lecture](../week-6/L6b/CHEME-5660-L6b-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb) | SIM portfolio inputs, risky and risky/risk-free optimization, and comparison with empirical covariance; 22-page companion deck. |
| [L6b risky-asset example](../week-6/L6b/CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb) | Compare data and SIM inputs, frontiers, allocations, and 2025 performance for the same 13 firms. Currently organized into five tasks. |
| [L6b risky/risk-free example](../week-6/L6b/CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb) | Tangent portfolio, capital allocation line, and complete-portfolio performance. |
| [L6b advanced uncertainty](../week-6/L6b/advanced/uncertainty/CHEME-5660-L6b-Advanced-SIM-Portfolio-Uncertainty-Fall-2026.ipynb) | Propagate fitted-parameter uncertainty into portfolio quantities. |

The current estimation notebook writes a SIM parameter file under L6a and copies
it into L6b. The portfolio examples load that file. Relocating estimation into
L6b must preserve this producer/consumer connection and remove the obsolete
cross-meeting copy. Both current parameter-file copies are present.

## Sources from the 2025 course

Paths below refer to the local sibling 2025 repository supplied by the instructor.

| Source | Recommended reuse |
| --- | --- |
| [2025 L6b portfolio lecture](../../../CHEME-5660-CourseRepository-Fall-2025/lectures/week-6/L6b/CHEME-5660-L6b-Lecture-MAGBM-Data-Portfolios-Fall-2025.ipynb) and its data-minimum-variance example | Teaching provenance and a shorter historical sequence. The reviewed 2026 archive is the primary L6a source. |
| [2025 L7a SIM lecture](../../../CHEME-5660-CourseRepository-Fall-2025/lectures/week-7/L7a/CHEME-5660-L7a-Lecture-SIM-Fall-2025.ipynb) | Parameter interpretation, regression, R-squared, theoretical uncertainty, and bootstrap explanation/pseudocode. A Goldman Sachs profile is also available if a company introduction is wanted. |
| [2025 L7a uncertainty example](../../../CHEME-5660-CourseRepository-Fall-2025/lectures/week-7/L7a/CHEME-5660-L7a-Example-SIM-Parameter-Uncertainty-Fall-2025.ipynb) | The previously selected main bootstrap source: fit the firms, assess R-squared, generate/refit 1,000 synthetic datasets, and compare intervals. Preserve this three-task progression. |
| [2025 L8b SIM portfolio lecture](../../../CHEME-5660-CourseRepository-Fall-2025/lectures/week-8/L8b/CHEME-5660-L8b-Lecture-SIM-Portfolio-RF-Fall-2025.ipynb) | Mean/covariance construction leading directly into minimum-variance allocation. Its risky-asset example has a useful three-task comparison of inputs, frontiers, and holdings. |
| [2025 covariance derivation](../../../CHEME-5660-CourseRepository-Fall-2025/lectures/week-8/L8b/CHEME-5660-L8b-Derivation-SIM-Covariance-Fall-2025.ipynb) | Stepwise covariance calculation and a small three-asset example for optional supporting development. |

The old bootstrap code draws from a fitted Normal distribution while holding
the observed market series fixed: call it a **Gaussian parametric bootstrap**.
Its executable fit is ordinary least squares. Align the old ridge notation and
uncertainty formula with that fit, and explain agreement with theoretical
intervals as a check under the fitted assumptions. Preserve the corrected 2026
growth-rate units and computational helpers when adapting the older narrative.

## Sources from the AI finance short course

The directly relevant collection is
[Session 1](../../../eCornell-AI-finance-lectures/lectures/session-1/).

| Source | Recommended reuse |
| --- | --- |
| [Session 1 lecture](../../../eCornell-AI-finance-lectures/lectures/session-1/eCornell-AI-Finance-S1-Lecture-StressTestingMinVariancePortfolios-May-2026.ipynb) | Selected explanations of optimization inputs, concentration, and evaluating a fixed allocation; optional NPV and drawdown comparisons. |
| [Covariance derivation](../../../eCornell-AI-finance-lectures/lectures/session-1/deeper/eCornell-AI-Finance-S1-Derivation-SIM-Covariance-May-2026.ipynb) | Developed pairwise covariance derivation and worked three-asset matrix. Useful supporting explanation for L6b after unit corrections. |
| [SIM estimation example](../../../eCornell-AI-finance-lectures/lectures/session-1/eCornell-AI-Finance-S1-Example-Optional-SIMParameterEstimation-May-2026.ipynb) | A compact single-firm fit, bootstrap, and all-firm archive sequence. Secondary reference; the recorded decision favors the 2025 bootstrap source. |
| [Maya introduction](../../../eCornell-AI-finance-lectures/lectures/session-1/eCornell-AI-Finance-S1-Introduction-MayasFirstPortfolio-May-2026.ipynb) | Optional motivating scenario: assess an allocation's concentration and uncertain inputs. It is a fictional client/portfolio-manager case. |
| [Stress-test example](../../../eCornell-AI-finance-lectures/lectures/session-1/eCornell-AI-Finance-S1-Example-Core-StressTestMinVariancePortfolio-May-2026.ipynb) | Optional extension comparing terminal wealth, NPV failure, and drawdowns across fixed allocations. Its executable pipeline needs adaptation. |

The short-course portfolio examples use their own package, configuration, ticker
files, cached results, and a hybrid market generator. Importing that pipeline
would add regime switching, jumps, and copula dependence to the Week 6 scope.
The existing reviewed GBM portfolio example already supplies simulation and NPV
using the course's established model.

Do not copy the short-course covariance notebook's units unchanged: its worked
example labels the stored residual variance in inverse years and claims that
multiplying by a time step produces inverse years squared, which is dimensionally
inconsistent. Use the current course convention of residual growth-rate variance
directly in inverse years squared. The derivation's instructional sequence is
reusable independently of those labels and numerical choices.

## Recommended assembly

1. Preserve the current Week 6 in a separate verified archive before editing.
2. Restore the reviewed archived data-driven minimum-variance development as
   L6a, carrying its resources. Place the risk-free extension in L6b and retain
   the fuller derivations and simulations as companions. Update identifiers,
   prerequisites, navigation, and slides for the new placement.
3. Assemble L6b from the existing SIM and SIM-portfolio lectures: model and
   interpretation, estimation, covariance construction, the allocation problem
   introduced in L6a, and the risk-free extension with tangency and the capital
   allocation line. Reuse the 2025 teaching passages where selected in the
   earlier plan; remove duplicated concept reviews and repeated optimization
   derivations. This entire core sequence belongs in L6b.
4. Keep the same asset universe, training/test windows, constraints, and targets
   for the data/SIM comparison. Reuse a common covariance when comparing the
   estimated risk of candidate allocations, and show realized performance
   separately. Preserve the current OLS mean-identity qualification and the
   distinction between residual-variance denominators.
5. Use the 2025 three-task bootstrap development in the companion example and
   retain the broader current diagnostics as supporting material. In the main
   lecture, explain the purpose of parameter uncertainty and link to that
   example. Preserve parameter-file production for the portfolio examples.
6. Keep risk-free allocation in L6b's core lecture and slides, supported by the
   full risky/risk-free example. The two existing SIM decks total 42 pages, so
   build a selected combined deck around the compressed sequence rather than
   concatenating them. Keep advanced derivations as companions. Reserve both
   L7a and L7b for utility-based alternatives.
7. Regroup the current five-task risky-asset example into three tasks while
   preserving its calculations; synchronize slides, Week 6 navigation,
   schedule references, and bundle links. Run the relocated examples and check
   rendered notebooks/slides before any later release.

This inventory inspected notebook structure, selected relevant narrative and
code, dependency paths, handoffs, archive hashes, and PDF page counts. It did not
execute the candidate notebooks or perform a new editorial review. No release
or publication is part of this inventory.
