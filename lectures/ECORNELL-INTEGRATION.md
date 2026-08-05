# eCornell AI-in-Finance Integration for Fall 2026

## Source material

The curriculum upgrades in this repository were adapted from the May 2026 short-course materials in:

`/Users/jeffreyvarner/Desktop/julia_work/eCornell-AI-finance-lectures`

The short course supplied the conceptual starting point for portfolio stress testing, adaptive utility allocation, online estimation, validation gates, and production operations. The CHEME 5660 versions were rewritten to match the course sequence, notation, notebook structure, and runtime conventions.

## Core integrations

| Course location | Integration |
|---|---|
| `week-6/L6b` | Added SIM portfolio forward validation with parameter uncertainty and optimization regret. |
| `week-7/L7b` | Refocused the lecture on stress testing and dynamic rebalancing; added a course-native stress-testing example. |
| `week-13/L13a` | Replaced the topic-mismatched Bandit/MWA core lecture with maximum-utility allocation and adaptive rebalancing; added utility-allocation and engine-scorecard examples. |
| `week-15/L15a` | Built the planned Autotrader diagnostics and validation lecture; added EWLS replay and formal validation-gate examples. |
| `week-15/L15b` | Built the final trading challenge and production-operations lecture; added a captured, credential-free decision-queue example. |

The former L13a Bandit/MWA lecture is preserved in `week-13/L13a/advanced/bandits/`.

## Advanced modules

| Course location | Module |
|---|---|
| `week-3/L3a/advanced/stylized_facts/` | Heavy tails, Hill tail-index estimation, autocorrelation, and volatility clustering. |
| `week-6/L6a/advanced/sim/` | Regularized SIM estimation, bootstrap uncertainty, SIM covariance, and maximum-Sharpe SOCP theory. |
| `week-13/L13a/advanced/adaptive_utility/` | CES utility limits and their allocation interpretations. |
| `week-13/L13a/advanced/bandits/` | Combinatorial bandits and multiplicative weights for portfolio learning. |
| `week-15/L15a/advanced/online_learning/` | EWLS recursion and policy-gradient derivations. |

## Package and data integration

The reusable short-course algorithms are now adapted into the course's vendored
`VLQuantitativeFinancePackage.jl` package under `code/src/AdaptivePortfolio.jl`.
The seven executable examples call that package API rather than carrying private
copies of the algorithms in notebook cells. The course manifest already resolves
the package to `code/`, so no second local package or repository is required.

Eight compact frozen artifacts were copied to
`code/src/data/adaptive_portfolio/`. The package exposes them through
`MySIMCalibration()`, `MyCurrentPrices()`, and
`MyAdaptivePortfolioCourseData(name)`. Their original paths and SHA-256 hashes
are recorded in the data directory's `README.md`.

The integration still avoids:

- adding hundreds of megabytes of regenerable stress caches and optional application data;
- requiring notebooks to run in a prescribed four-session order;
- depending on a second local repository;
- requiring brokerage, news, or language-model credentials;
- coupling the course to the short course's client narrative and vendor-specific documentation.

The resulting examples remain independent: each includes the local `Include.jl`,
activates the nearest course environment, and can be run from its own lecture
directory. Synthetic paths remain seeded, and the captured-operations example
remains credential-free.

## Intentionally optional or excluded material

The following short-course topics remain optional candidates rather than required Fall 2026 content:

- deep Q-network ticker selection;
- REINFORCE training code beyond the included derivation;
- live brokerage integration;
- live language-model news collection and scoring;
- the fraud-detection graph neural network;
- large pretrained surrogate models and Monte Carlo caches.

These topics can be added later as isolated advanced modules if they can be made reproducible without credentials and without introducing hidden cross-notebook state.

## Validation performed

- All added and modified notebooks parse as valid notebook JSON.
- Cell identifiers are unique within each notebook.
- Internal notebook and image links were checked.
- The seven new executable examples were run sequentially with Julia 1.12 against the course environment.
- The complete `VLQuantitativeFinancePackage.jl` test suite passes, including 19 new adaptive-portfolio assertions.
- The 2026 package documentation builds successfully with the new Adaptive portfolios page.
- All vendored adaptive-portfolio data loaders were smoke-tested.
- The integrated examples require no live external service.
