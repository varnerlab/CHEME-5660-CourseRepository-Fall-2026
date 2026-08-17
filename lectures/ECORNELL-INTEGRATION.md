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
| Core stress-test scorecard | Adapted in L7b with reproducible course-native scenarios, costs, drawdown, and scorecard comparisons. |

### Session 2: utility allocation and rebalancing

| Source material | CHEME 5660 disposition |
|---|---|
| Cobb--Douglas allocator | Integrated in L13a and the local package API. |
| Rebalancing engine scorecard | Integrated in L13a with trigger-based rebalancing and a course-native scorecard. |
| Monte Carlo engine evaluation | Distributional evaluation, common scenarios, costs, and passive comparisons are split across L7b and L13a. Large pretrained surrogate paths and source-specific 2025 deployment claims were not copied. |
| CES derivation and limits | Integrated under week-13/L13a/advanced/adaptive_utility. |
| Turnover attribution diagnostics | The core turnover and cost diagnostics are present in L7b/L13a. The detailed source attribution notebook remains a candidate for an isolated advanced operations lab. |
| Regime-aware sentiment | Conceptually useful, but tied to the excluded pretrained regime model. The current course uses observable, credential-free signals and labels regime-aware inference as an extension. |

### Session 3: online learning and validation

| Source material | CHEME 5660 disposition |
|---|---|
| EWLS engine replay | Integrated in L15a and supported by package-level EWLS routines. |
| EWLS recursion derivation | Integrated under week-15/L15a/advanced/online_learning. |
| Ticker-picker bandit | Covered by the existing L12a/L12b bandit sequence; the eCornell combinatorial variant remains optional. |
| Validation report and compliance gates | Integrated in L15a with explicit pass/fail gates. |
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
| week-7/L7b | Stress testing and dynamic rebalancing with a course-native stress example. |
| week-13/L13a | Maximum-utility allocation and adaptive rebalancing; former Bandit/MWA lecture preserved under advanced/bandits. |
| week-15/L15a | Autotrader diagnostics, EWLS replay, validation gates, and online-learning derivations. |
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
