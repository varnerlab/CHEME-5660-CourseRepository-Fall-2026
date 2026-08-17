# eCornell AI-in-Finance Integration for Fall 2026

## Source and integration standard

The curriculum upgrades in this repository were adapted from the May 2026
short-course materials in:

/Users/jeffreyvarner/Desktop/julia_work/eCornell-AI-finance-lectures

The CHEME 5660 versions are course-native adaptations rather than dependencies
on the second repository. They use the course sequence, annualized
continuous-growth-rate convention, frozen data, local package, and independent
notebook runtime.

This document records two passes:

1. The initial integration of stress testing, adaptive utility allocation,
   online estimation, validation gates, and production operations.
2. The August 2026 content audit, which reviewed the complete primary notebook
   tree across Sessions 1--4 and corrected gaps in stylized facts, SIM theory,
   bootstrap uncertainty, and portfolio-level uncertainty propagation.

## August 2026 corrections and additions

| Course location | Change |
|---|---|
| week-3/L3a | Rebuilt the core stylized-facts example around Normal/Laplace/Student-t comparison, Anderson--Darling discrepancy ranking, a Hill stability plot, raw-versus-magnitude ACFs, and a model-adequacy handoff to L6. |
| week-3/L3a/advanced/stylized_facts | Retained the deeper theory but removed the unsupported claim that every course stress test already uses a specific JumpHMM pipeline. The module now distinguishes SIM covariance compression from optional heavy-tail and regime-aware generators. |
| week-6/L6a | Rebuilt the SIM uncertainty example to compare empirical-residual and Gaussian parametric bootstraps, empirical percentile intervals, the analytical ridge-sandwich covariance, and stylized-fact diagnostics on fitted residuals. |
| week-6/L6a lecture | Corrected the ridge covariance derivation. The middle X'X factor may be removed only for unregularized OLS, not for ridge regression. |
| week-6/L6a/advanced/sim | Reworked the eCornell deeper-dive material into one unit-consistent derivation connecting estimation, two bootstrap models, rank-one-plus-diagonal covariance, decision uncertainty, and the maximum-Sharpe SOCP. |
| week-6/L6b | Replaced ad hoc independent parameter perturbations with joint per-asset bootstrap draws estimated from course data. The example now compares residual and parametric propagation into volatility, weight distance, and variance regret. |
| code/src/AdaptivePortfolio.jl | Added tested, reusable estimate_sim, bootstrap_sim, propagate_sim_uncertainty, hill_tail_index, sample_autocorrelation, and stylized_facts_report APIs. |

## Unit convention resolved in the second pass

The eCornell source uses more than one representation of residual variance.
CHEME 5660 now states the conversion explicitly.

The core notebooks observe

$$
g_t = \frac{1}{\Delta t}\log(P_t/P_{t-1}).
$$

If sigma_g is estimated directly from these growth-rate observations, then

$$
\Sigma_g
= \sigma_{g,m}^2\beta\beta^\top
+ \operatorname{diag}(\sigma_{g,\varepsilon}^2)
$$

contains no extra Delta t. For one-step log returns
r_t = Delta t times g_t,

$$
\Sigma_r = \Delta t^2 \Sigma_g.
$$

Under a diffusion-volatility convention,
Sigma_ann = Sigma_r / Delta t = Delta t times Sigma_g.
All are valid if every market and residual term uses the same convention.

## Source review ledger

The ledger below covers the primary notebooks and deeper-dive notebooks. Jupyter
checkpoints are duplicates and old/ directories were reviewed only for unique
ideas, not treated as current source.

### Session 1: classical portfolio construction and stress testing

| Source material | CHEME 5660 disposition |
|---|---|
| Introduction / Maya's first portfolio | Narrative framing was not copied; the allocation-under-pressure decision is represented by the L6b and L7b scorecards. |
| Core risky-asset minimum-variance build | Existing L5b/L6b portfolio examples remain the numerical foundation. The useful hybrid-validation idea is represented in the bootstrap propagation and L7b stress modules without a second-repository dependency. |
| Core risky/risk-free allocation and CAL | Existing L6b risky/risk-free and tangent-portfolio examples retained; SOCP theory remains in the advanced SIM module. |
| Optional SIM parameter estimation | Newly integrated into the L6a core uncertainty example and course package API. Batch persistence was intentionally omitted so the notebook cannot silently overwrite shared calibration data. |
| Deeper-dive SIM | Fully reworked in week-6/L6a/advanced/sim, including the ridge sandwich and unit reconciliation. |
| SIM covariance derivation | Folded into the L6a lecture (vector form) and a derivation blockquote in the L6b concept review; the standalone L6b derivation notebook was retired in the Fall 2026 L6b sweep. |
| Optional and deeper stylized facts | Promoted into the L3a core example and retained in expanded theory form under advanced/stylized_facts. |
| Out-of-sample generator validation | Its diagnostic principle is integrated: distributional fit, tail behavior, and ACF checks precede stress use. The pretrained JumpHMM artifact and large caches remain excluded. |
| Core stress-test scorecard | Represented in L7b (Fall 2026 restructure of 2026-08-17) by the SIM-simulated scenario ensemble: seeded course-native futures, the same engine and costs on every future, and the distributional scorecard (`ensemble_scorecard`), labeled a scenario engine rather than a validation. |

### Session 2: utility allocation and rebalancing

| Source material | CHEME 5660 disposition |
|---|---|
| Cobb--Douglas allocator | Integrated in L7a (Fall 2026 restructure of 2026-08-17; formerly L13a) with the course package `allocate_cobb_douglas`/`allocate_ces`; the L7a example allocates the thirteen-firm course universe on real 2025 data. |
| Rebalancing engine scorecard | Integrated in L7a with the package `run_utility_engine` (self-financing account, next-bar execution, schedule, turnover cap, drawdown circuit breaker) and `realized_scorecard`; adaptive and buy-and-hold policies run through the same engine on 2025 data. L13a's engine material becomes a concept review pending its re-scope. |
| Monte Carlo engine evaluation | Integrated in L7b as the SIM-simulated scenario ensemble with `ensemble_scorecard` (fail rate, lower quantile, tail mean, drawdown quantiles, paired frozen-versus-online differences on common futures), replacing the previous L7b description of the excluded JumpHMM generator; common scenarios and passive comparisons remain in L13a. Large pretrained surrogate paths and source-specific 2025 deployment claims were not copied. |
| CES derivation and limits | Integrated under week-7/L7a/advanced/adaptive_utility (moved from L13a; extended with the elasticity rule, log-linear utility, and the share-denomination caveat). |
| Turnover attribution diagnostics | The core turnover and cost diagnostics are present in L7b/L13a. The detailed source attribution notebook remains a candidate for an isolated advanced operations lab. |
| Regime-aware sentiment | Conceptually useful, but tied to the excluded pretrained regime model. The current course uses observable, credential-free signals and labels regime-aware inference as an extension. |

### Session 3: online learning and validation

| Source material | CHEME 5660 disposition |
|---|---|
| EWLS engine replay | Integrated in L7b (Fall 2026 restructure of 2026-08-17): the EWLS recursion with one prior of stated weight, a walk-forward half-life chosen inside 2014 to 2024, and a chronological frozen-versus-online replay of the L7a engine on 2025 with the package `ewls_init`/`ewls_update!`/`ewls_path`; the L15a EWLS-replay example remains as a recall pending the L15a re-scope. |
| EWLS recursion derivation | Moved to week-7/L7b/advanced/online_learning (2026-08-17), rewritten in the course notation with the prior-seeding propositions (the seed returns the prior exactly; the seeded recursion minimizes the data loss plus a decaying prior-centered quadratic). |
| Ticker-picker bandit | Covered by the existing L12a/L12b bandit sequence; the eCornell combinatorial variant remains optional. |
| Validation report and compliance gates | Integrated in L15a with explicit pass/fail gates; L7b points to them without defining any gate. |
| CES-eta bandit | The concept is represented by the bandit and adaptive-utility units; the source-specific training pipeline remains optional. |
| REINFORCE eta policy and policy-gradient derivation | Derivation integrated in the L15a advanced module; full training code remains optional because it adds substantial runtime and a second policy stack. |
| DQN ticker picker | Excluded from required material; it is not needed to meet the course learning objectives and would add high runtime and dependency cost. |

### Session 4: production operations

| Source material | CHEME 5660 disposition |
|---|---|
| Production-operations lecture | Integrated across L15a and L15b as diagnostics, validation, captured decisions, and final challenge operations. |
| Ticker-picker bandit in production | The decision concept is covered by L12 and the final operations workflow; source-specific production wiring was not copied. |
| AI sentiment deep dive | Live language-model calls and news credentials remain excluded. The decision-queue pattern is credential-free. |
| Fraud-detection GNN | Remains an optional future module because it is outside the core sequence and adds a separate graph-learning dependency. |
| Old live brokerage, dashboard, ingestion, and paper-trading notebooks | Operational ideas were reviewed; live external writes, secrets, cron installation, and brokerage coupling are deliberately excluded from course notebooks. |

## Earlier core integrations retained

| Course location | Integration |
|---|---|
| week-7/L7a | Utility-based allocation and the adaptive rebalancing engine (2026-08-17 restructure): utility allocator, engine scorecard, and drift examples on course data. |
| week-7/L7b | Online SIM estimation (2026-08-17 restructure): rolling betas with bands, the EWLS recursion and prior, a walk-forward half-life, the frozen-versus-online replay of the L7a engine on 2025, and the SIM-simulated scenario ensemble with the distributional scorecard; replaces the previous stress-testing and rebalancing lecture. |
| week-13/L13a | Maximum-utility allocation and adaptive rebalancing; former Bandit/MWA lecture preserved under advanced/bandits. |
| week-15/L15a | Autotrader diagnostics, EWLS replay (recall of L7b pending re-scope), validation gates, and the policy-gradient derivation. |
| week-15/L15b | Final trading challenge and credential-free captured decision queue. |

## Package and data boundary

Reusable algorithms live in the vendored VLQuantitativeFinancePackage.jl
package under code/src/AdaptivePortfolio.jl. Course examples call that API
rather than carrying divergent private implementations.

Eight compact frozen artifacts remain under code/src/data/adaptive_portfolio/,
with sources and hashes in that directory's README.md.

The integration deliberately avoids:

- hundreds of megabytes of regenerable caches and pretrained surrogate artifacts;
- hidden cross-notebook state or a prescribed four-session execution order;
- runtime dependence on the eCornell repository;
- brokerage, news, language-model, or other live-service credentials;
- source narratives or vendor claims that are not needed for CHEME 5660;
- automatic writes from instructional notebooks into shared calibration files.

## Validation checklist

- [x] Every modified notebook parses as valid notebook JSON.
- [x] Cell identifiers are unique within each modified notebook.
- [x] Internal notebook links resolve.
- [x] The L3a stylized-facts example executes against frozen course data.
- [x] The L6a bootstrap example executes against frozen course data.
- [x] The L6b propagation example executes against frozen course data.
- [x] The complete package test suite passes.
- [x] Package documentation builds with the expanded API.
- [x] No integrated notebook requires a live external service.
