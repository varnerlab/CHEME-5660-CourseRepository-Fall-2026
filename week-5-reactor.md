# Week 5 refactor plan

Recorded September 18, 2026. This document preserves the agreed teaching pivot and
the implementation plan. Implementation is complete; see the
[refactor handoff](lectures/instructor/WEEK-5-REFACTOR-HANDOFF.md) for delivered
files, reuse, and verification. The requested
filename is `week-5-reactor.md`.

**Latest notation correction — use growth rates throughout EMA.** The observed
quantity is `g_k=log(S_k/S_(k-1))/Delta_t`, in inverse years. Update its mean
and variance directly: initialize `m_s=mu_g,0`, `v_s=sigma_0^2/Delta_t`, and
recover `mu_g,k=m_k`, `sigma_k=sqrt(v_k*Delta_t)`. Apply this convention in the
lecture proposition, derivation, worked example, helper code, and documentation.
Keep the lecture concise. This replaces the earlier log-increment formulation.

**Prior organization revision — concise proposition and linked derivation.**
The instructor approved the EMA content but found the lecture treatment too long.
Keep one theorem-style statement of the assumptions, centered update equations,
and GBM parameter conversion, followed by a brief half-life and forecast-window
interpretation. Preserve the detailed algebra in the linked
[EMA derivation notebook](lectures/week-5/L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb).
The lecture section is reduced from 1,019 to 283 whitespace-delimited words.
The three computational examples remain unchanged. This supersedes the longer
lecture development described in the prior follow-up below.

**Prior follow-up — EMA theory in the lecture notebook.** The instructor now
requests the parameter-updating theory in L5a. Develop initialization, exponential
weights and half-life, the centered variance derivation, conversion to GBM
parameters, and the use of fixed estimates within each forecast window. Reuse the
EMA example's equations and conventions. Keep its simulations, rolling trade
calculations, and empirical score comparison in the example. This supersedes
the earlier restriction that all EMA theory appear only in the example. This
follow-up changes the lecture notebook; the existing slide deck still contains
the brief EMA example introduction.

**Prior instructor revision — three separate examples.** Move the reviewed
L4b NPV trade-rule notebook into L5a, restore the original reviewed L5a OoS
notebook, and narrow the generated combined notebook to a separate EMA example.
This replaces the earlier combined-example design and its initial January-trade
reveal. The existing NPV and OoS content is reused without a new editorial rewrite.
The causal EMA conventions and adjustable 21-day forecast window remain in the
EMA example. This revision supersedes the earlier interactive planning history
where it conflicts with that separation.

**Current focus: the Week 5 refactor.** The instructor requested that the Week 6
placement decisions, 2025 source findings, and proposed SIM/portfolio scope be
saved for later. Those notes remain in this document as deferred follow-up work.
They do not expand the active implementation. The interactive Week 5 plan review
is complete: teaching scope, forecast conventions, numerical defaults, and the
brief data/payoff explanation are agreed. The instructor selected
a trade-centered EMA comparison with probabilities recalculated daily over a
rolling window. Make the entry-day index and forward holding period configurable,
initially index 1 and 21 trading days, with a one-day setting supported. The
benchmark growth rate is also editable so the same trade can be assessed against
different benchmark growth assumptions. The EMA half-life is agreed at 21 trading
observations, independently adjustable from the holding period. The archive,
refactored notebooks, slides, navigation, and local bundle checks are complete.

**Earlier implementation correction (theory placement superseded above):** EMA belongs in the computational
example, not as a developed topic in the main lecture. Keep its derivation,
rolling forecast equations, simulations, plots, and score results in the example.
The lecture and slides contain only a short, question-led description linking to
that example. This supersedes earlier statements below that placed the EMA
explanation or scoring results in the lecture. Review complete artifacts for
teaching quality, mathematical correctness, and presentation before handoff.

## 1. Purpose and agreed scope

We are behind the original lecture schedule. The new Week 5 will finish the
single-asset GBM development and its application to observed 2025 prices before
moving to multiple-asset GBM.

The instructor's main constraint is to reuse the current, reviewed material and
use useful material from the 2025 course. Preserve the approved teaching voice,
explanations, mathematics, code comments, and figure conventions. The existing
reviews remain closed; review attention should go to new content and substantive
changes made for this pivot.

During the interactive discussion, the instructor emphasized that cleaning up
and reviewing newly written content has become too burdensome. Treat this as an
authoring constraint: retain reviewed 2026 passages, and use the actual 2025
passages, examples, and teaching sequence as the starting point for material
that needs assembling, especially SIM, bootstrap uncertainty, and SIM portfolios.
Identify a source for each section before drafting replacement prose. Preserve
the existing explanations and worked steps; write only missing transitions and
material required by the agreed new topics. Necessary mathematical, notation,
data, link, and compatibility corrections should be local and documented.

The agreed changes are:

- Archive the complete current Week 5 before changing its contents.
- Move the current L5a multiple-asset GBM lecture, its relevant examples, advanced
  material, and slides to the new L5b. Preserve their substantive content.
- Build a new L5a on single-asset GBM, out-of-sample prediction, NPV target
  probabilities, and updating parameter estimates through 2025.
- Open the new L5a with a Renaissance Technologies (RenTec) company profile.
- Restore the reviewed OoS example, move the reviewed L4b NPV example, and
  keep the parameter-updating work in a separate EMA example.
- Reserve bootstrap uncertainty for the future SIM lecture. Do not add a
  bootstrap section or notebook to the new L5a.
- Preserve the current minimum-variance L5b and its supporting material in the
  archive, then reuse it as the new L6a on data-driven minimum-variance allocation.
- Assign SIM to the new L6b. Combining SIM estimation and SIM portfolio allocation
  in that meeting is under discussion; the proposed scope is recorded in Section 14.
- Update both Week 5 slide decks to match the resulting lecture notebooks.

The Week 6 destinations above are agreed. Authoring and moving the Week 6 files
will be a follow-up to the Week 5 refactor; preserve the current Week 6 before
changing those files. This plan does not shift Weeks 7 onward, introduce a trading
strategy that changes positions during 2025, or authorize a release publication.
The existing buy-and-hold trade supplies the NPV outcome.

## 2. Preserve the reviewed source material

Follow the [shared notebook style guide](lectures/instructor/NOTEBOOK-STYLE-GUIDE.md)
and [repository working agreements](AGENTS.md). Read the applicable saved review
record before adapting a notebook or deck. Do not restart an interactive notebook
polish round as part of this refactor.

| Source | Planned use | Review record |
| --- | --- | --- |
| Current L5a multiple-asset lecture | Move to new L5b; retain its development | [Lecture](lectures/instructor/L5a-LECTURE-REVIEW-HANDOFF.md) |
| Current L5a slides | Renumber as L5b and update navigation | [Slides](lectures/instructor/L5a-SLIDES-REVIEW-HANDOFF.md) |
| Current L5a covariance example | Move to new L5b | [Covariance](lectures/instructor/L5a-COVARIANCE-REVIEW-HANDOFF.md) |
| Current L5a Dirichlet example | Move to new L5b | [Dirichlet](lectures/instructor/L5a-DIRICHLET-REVIEW-HANDOFF.md) |
| Current L5a advanced covariance example | Move to new L5b | [Advanced covariance](lectures/instructor/L5a-ADVANCED-COVARIANCE-REVIEW-HANDOFF.md) |
| Current L5a rolling-correlation example | Move to new L5b; use its exponential-weighting explanation as a reference | [Rolling correlation](lectures/instructor/L5a-ROLLING-CORRELATION-REVIEW-HANDOFF.md) |
| Current L5a single-asset out-of-sample example | Restore unchanged; keep EMA in a separate example | [Out-of-sample](lectures/instructor/L5a-OOS-REVIEW-HANDOFF.md) |
| L4b single-asset lecture | Reuse the GBM review, exact transition, and NPV development | [L4b lecture](lectures/instructor/L4b-INTERACTIVE-REVIEW-HANDOFF.md) |
| L4b parameter example | Preserve the training-estimate interpretation and setup conventions | [Parameter estimation](lectures/instructor/L4b-PARAMETERS-REVIEW-HANDOFF.md) |
| L4b NPV example | Move to L5a with its reviewed content and original parameter file | [NPV](lectures/instructor/L4b-NPV-REVIEW-HANDOFF.md) |
| L4b drift-uncertainty example | Reference for the difficulty of estimating mean growth; optional further reading | [Drift uncertainty](lectures/instructor/L4b-DRIFT-UNCERTAINTY-REVIEW-HANDOFF.md) |
| L4b Monte Carlo example | Reference for probability estimates and simulation error | [Monte Carlo](lectures/instructor/L4b-MONTE-CARLO-REVIEW-HANDOFF.md) |
| Current L5b lecture and slides | Archive for later teaching | [Lecture](lectures/instructor/L5b-LECTURE-REVIEW-HANDOFF.md), [slides](lectures/instructor/L5b-SLIDES-REVIEW-HANDOFF.md) |
| Current L5b examples and advanced material | Archive for later teaching | [Minimum variance](lectures/instructor/L5b-MINVAR-REVIEW-HANDOFF.md), [MAGBM portfolio](lectures/instructor/L5b-MAGBM-REVIEW-HANDOFF.md), [frontier geometry](lectures/instructor/L5b-ADVANCED-FRONTIER-REVIEW-HANDOFF.md), [estimation risk](lectures/instructor/L5b-ADVANCED-ESTIMATION-REVIEW-HANDOFF.md) |

The [Week 5 commenting record](lectures/instructor/WEEK-5-CODE-COMMENTS-HANDOFF.md)
contains the latest recorded hashes after the completed code-commenting pass.
Earlier review hashes describe earlier approved snapshots. Preserve that history
and compute fresh hashes when the archive is created.

The local 2025 course repository is
`../CHEME-5660-CourseRepository-Fall-2025/`. Use its teaching passages and examples
directly when assembling the SIM follow-up, checking notation and implementation
against the reviewed 2026 material. The current course already contains an
[L6a bootstrap-uncertainty example](lectures/week-6/L6a/CHEME-5660-L6a-Example-SIM-Parameter-Uncertainty-Fall-2026.ipynb).
Preserve that version before the Week 6 changes. The 2025 worked example is the
primary teaching source for the bootstrap portion of new L6b; its existing
three-task organization and explanation set the scope. The longer 2026 treatment
can supply a necessary correction or supporting material without expanding the
main example. Bootstrap is not part of this Week 5 work.

### Specific 2025 sources for the SIM follow-up — saved for later

| Teaching component | Source to reuse |
| --- | --- |
| SIM model, parameter interpretation, estimation, and bootstrap explanation/pseudocode | [2025 L7a SIM lecture](../CHEME-5660-CourseRepository-Fall-2025/lectures/week-7/L7a/CHEME-5660-L7a-Lecture-SIM-Fall-2025.ipynb); the L7b reprise contains the same main progression |
| Worked parameter uncertainty example | [2025 L7a SIM parameter uncertainty](../CHEME-5660-CourseRepository-Fall-2025/lectures/week-7/L7a/CHEME-5660-L7a-Example-SIM-Parameter-Uncertainty-Fall-2025.ipynb) |
| SIM reward, risk, covariance construction, and portfolio allocation | [2025 L8b SIM portfolio lecture](../CHEME-5660-CourseRepository-Fall-2025/lectures/week-8/L8b/CHEME-5660-L8b-Lecture-SIM-Portfolio-RF-Fall-2025.ipynb) |

The source notebook's bootstrap procedure is concrete: fit the SIM, fit a normal
distribution to its residuals, hold the observed market series fixed, generate
1,000 synthetic response datasets, refit alpha and beta, and compare the resulting
normal-approximation intervals with the theoretical intervals. Its three tasks
are parameter estimation, R-squared/model fit, and bootstrap uncertainty.

Retain this worked progression and its existing code-to-explanation relationship.
The current 2026 example adds empirical-residual versus Gaussian bootstrap
comparisons, tail and dependence diagnostics, and Newey-West standard errors.
Those additions are not required for the main combined lecture simply because
they are present in the newer notebook.

Keep corrections specific. Label the old procedure as a Gaussian parametric
bootstrap; its code draws from a fitted distribution rather than sampling the
observed residual values. Align the lecture's estimator with the worked example's
ordinary least squares: the old ridge-covariance simplification is only valid
when the regularization parameter is zero. If ridge remains in supporting
material, retain the correct covariance product there. Explain agreement with
theoretical intervals as a check under the fitted error assumptions, without
claiming it establishes those assumptions for the observed market data. These
are local corrections, not grounds for a new lecture-length diagnostics section.

Record a compact source-to-destination map and a list of substantive corrections
when assembling the follow-up. The instructor should be able to inspect the
changed passages without reviewing newly composed replacements for material
already taught.

## 3. Archive and file mapping

### Archive before editing

Use `lectures/archive/week-5-before-pivot-2026-09-18/` as the proposed archive
directory. Keep it outside `lectures/week-5/` so the student Week 5 bundle does not
automatically include the superseded week.

1. Record the repository revision, working-tree status, and a recursive inventory
   of the current Week 5 files, including local files not tracked by Git.
2. Copy the complete `lectures/week-5/` tree into the archive's `week-5/`
   subdirectory. Preserve notebooks, saved outputs, code, data, figures, slide
   sources, PDFs, local style files, Makefiles, and existing auxiliary files.
3. Save copies of the relevant review handoffs, the commenting record, and the
   current style guide in a separate archive `review-records/` directory. Record
   the root `Project.toml` and `Manifest.toml` versions and external dependencies.
4. Write a SHA-256 manifest and verify every archived regular file against the
   source. Record symbolic links and their targets separately if present.
5. Add an archive README explaining the original teaching sequence, archive date,
   dependency locations, and how to restore the original layout. Keep the copied
   payload byte-for-byte unchanged, including its original relative links.

The archive preserves an original snapshot. Its notebooks and slides may require
restoring the original directory layout for links and build dependencies to work;
do not silently rewrite archived files to make them run at the deeper location.
Do not overwrite an existing archive with the same name without checking it.

### Active material after the pivot

All paths in the following table are relative to `lectures/week-5/`.

| Current artifact | Destination or disposition |
| --- | --- |
| `L5a/CHEME-5660-L5a-Lecture-MultipleAsset-GBM-Fall-2026.ipynb` | `L5b/CHEME-5660-L5b-Lecture-MultipleAsset-GBM-Fall-2026.ipynb` |
| `L5a/CHEME-5660-L5a-Example-CovarianceMatrix-Fall-2026.ipynb` | Same example under `L5b/`, with `L5b` in the filename |
| `L5a/CHEME-5660-L5a-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb` | Same example under `L5b/`, with `L5b` in the filename |
| `L5a/advanced/covariance-estimation/` | `L5b/advanced/covariance-estimation/`; renumber notebook and navigation |
| `L5a/advanced/rolling-correlation/` | `L5b/advanced/rolling-correlation/`; renumber notebook and navigation |
| `L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.{tex,pdf}` | New L5b deck, with its Makefile and figure dependencies |
| `L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb` | Restore the original reviewed notebook at this active path |
| New single-asset lecture | `L5a/CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb` |
| New L5a slides | `L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.{tex,pdf}` |
| Current `L5b/` minimum-variance lecture, examples, slides, and advanced material | Retain in the verified archive; reuse as new Week 6 L6a during the follow-up refactor |

Carry each moved notebook's required `Include.jl`, `src/`, `docs/`, `data/`, and
`figs/` resources with it. Inspect dependencies rather than renaming the complete
Week 5 tree with a global text replacement: the old and new L5b refer to different
topics, and the single-asset example stays in L5a.

Move the reviewed L4b NPV example into L5a and repair its incoming links.
Preserve its content, defaults, outputs, and exact parameter snapshot under
`L5a/data/npv/`. Other L4b notebooks remain in place. Restore the archived original
OoS example at its original L5a path. Narrow the generated notebook into
`L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb`.

## 4. New L5a lecture development

Title: **Single Asset Geometric Brownian Motion and NPV**.

The sequence is RenTec, the single-asset GBM review and restored OoS example,
the reviewed L4b NPV development and relocated NPV example, then a short
description linking to the separate EMA example. Preserve the GBM and NPV
derivations. Keep EMA equations, simulations, and scores in its example.
Lecture and slide example descriptions must match these three distinct purposes.

The three learning objectives and takeaways cover interpreting out-of-sample
price predictions, calculating an NPV target probability, and evaluating model
predictions, including the comparison of frozen and updated estimates.

## 5. Three separate L5a examples

### NPV: reuse the reviewed L4b example

Move to `L5a/CHEME-5660-L5a-Example-GBM-NPV-TradeRule-Fall-2026.ipynb`.
Preserve its three tasks: calculate the target probability, verify the median
check, and explore the probability across targets. Keep its original defaults:
AAPL, 63 trading days, benchmark 0.05, initial target −0.15, and the target sweep
from −0.20 to 0.40. Its saved parameter CSV differs slightly from the similarly
named OoS CSV, so preserve it separately under `data/npv/`. Only the input path
and prerequisite link change.

### OoS: restore the reviewed original

Restore `L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb` byte-for-byte from
the verified pre-pivot archive. Preserve its three tasks: simulate one asset,
construct pointwise prediction bands and assess coverage, and compare coverage
across the shared dataset. Keep its full 2025 window, SPY default, histogram,
coverage tables, source helpers, and saved outputs.

### EMA: narrow the generated combined example

Use `L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb` for three tasks:

1. Initialize the growth-rate mean and variance from 2014–2024 estimates,
   update using observed 2025 increments, and plot the resulting mean growth
   and volatility against the baseline.
2. Compare frozen, EMA-volatility, and EMA-mean-plus-volatility forecasts on
   identical origins and forward windows. Reuse the NPV probability as the
   application, with a link to its separate example. Show the conditional
   probabilities and simulations without repeating the original NPV reveal
   or the OoS prediction-band tutorial.
3. Measure whether updating helps using paired Brier losses, per-ticker
   comparisons, and accumulated differences. Keep the dependence and
   interpretation qualifications.

Keep the original purchase fixed, and keep the existing causal estimation and
forecast helpers. Select eligible aligned histories and report exclusions in
setup. The EMA defaults remain SPY, entry index 1, forward horizon 21 trading
observations (including support for 1), `Δt=1/252`, `g_y=0.05`, `rho_star=0`,
EMA half-life 21 observations, 100 displayed paths, and random seed 5660.
The half-life is independent of the forward window. Remove the unused
10,000-draw probability-check constant from this narrower notebook.

Sections 6 and 7 retain the agreed numerical conventions for the EMA example.
They do not extend the restored NPV and OoS notebooks.

## 6. NPV calculation and outcome comparison

The instructor selected daily probability updates with a rolling forward window.
The default trade starts at the first January observation, but the start index
is configurable. Keep that selected purchase price fixed. As the prospective
sale date moves, recompute its terminal-price threshold using the full elapsed
time from entry to that date. These are assessments of alternative sale dates
for one position, not a sequence of newly purchased positions.

Use the reviewed notation. Let `S_0` be the entry price, `T` the total holding
period in years, `g_y` the fixed continuously compounded annual benchmark growth
rate, and `rho_star > -1` the chosen dimensionless target. The scaled NPV is:

\[
\rho_T=\frac{S_T}{S_0}e^{-g_yT}-1.
\]

The corresponding terminal-price threshold is:

\[
K=S_0(1+\rho_\star)e^{g_yT}.
\]

With `rho_star = 0`, success means that the sale proceeds exceed
`S_0*exp(g_y*T)`. Increasing `g_y` raises this threshold, lowers the model's
success probability, and can change whether the observed trade meets the target.
For example, zero benchmark growth asks whether the price increased; a positive
rate asks whether it grew sufficiently to beat that benchmark over the holding
period. Keep `g_y` fixed within each scenario and apply it to the full elapsed
time from the original purchase to each prospective sale.

Use changes to this constant as a brief sensitivity demonstration within the
existing example, reusing the same price data, fitted parameters, and simulated
paths. Changing the benchmark changes the target and discounted payoff; it does
not change the GBM price dynamics. Recompute both the probability and observed
target indicator for each scenario. Compare frozen and EMA methods at the same
benchmark and target; a lower Brier score after changing the benchmark alone is
not evidence of improved forecasting. These are deterministic growth benchmarks,
not simulations of another risky asset's realized return.

For positive volatility and holding period, the initial forecast is:

\[
p_0=\mathbb P(S_T>K)
=1-\Phi\!\left(
\frac{\ln(1+\rho_\star)+(g_y-\widehat\mu_{g,0})T}
{\widehat\sigma_0\sqrt{T}}
\right).
\]

Use the strict event `rho_T > rho_star` consistently in the prose, formulas, code,
table headings, and Monte Carlo check. At equality, the target is not exceeded.

The all-ticker output should contain ticker, entry/sale dates and prices, fitted
parameters, predicted success probability, realized scaled NPV, target-met
indicator, and Brier loss. Show a readable subset in the notebook and retain the
complete computed table for inspection or export.

Summarize the average predicted success probability, observed success fraction,
and average Brier loss. The sum of the individual probabilities is the model's
expected number of successful trades, even when outcomes are dependent. The
assets share market exposure, so do not use an independent-binomial error bar or
claim formal calibration from one cross-sectional outcome comparison.

For a rolling forecast at row `k`, let `s = start_day_index` and
`H = holding_period_days`. The forward forecast duration is `h = H*Delta_t`;
the total time from purchase to the prospective sale is
`T_k = (k + H - s)*Delta_t`. With fixed purchase price `S_entry = S_s`, the
threshold and updated probability are:

\[
\begin{aligned}
K_k &= S_{\mathrm{entry}}(1+\rho_\star)e^{g_yT_k},\\
p_k &= 1-\Phi\!\left(
\frac{\ln(K_k/S_k)-\widehat\mu_{g,k}h}
{\widehat\sigma_k\sqrt{h}}
\right).
\end{aligned}
\]

After the prospective sale observation becomes available, the outcome to compare
with that saved forecast is:

\[
\rho_k^{\mathrm{observed}}
=\frac{S_{k+H}}{S_{\mathrm{entry}}}e^{-g_yT_k}-1.
\]

The frozen-parameter comparator uses the same `S_k`, `h`, and `K_k`, while retaining
the original parameter estimates. Keep the original purchase price for discounting
and realized NPV; the observed price at the forecast origin initializes the future
GBM transition. This distinction applies even when the forward window is one day.

Initialize the EMA states from the training baseline at the selected start row,
so the methods agree on the first forecast. Update from subsequent observations
beginning with the growth rate observed from row `s` to row `s+1`. Changing the start index resets
this experiment's EMA initialization; it does not implicitly add a different
warm-up period. Forecast differences then arise as observations arrive. For each
prospective sale date, all methods are assessed against the same realized payoff.

## 7. EMA specification and fair evaluation

### Parameter update

Explain the estimation procedure separately from the price model. A classical
constant-parameter GBM does not represent arbitrary market shifts. Here we use
its transition distribution as a local forecasting approximation, recalibrated
when new observations arrive. The same distinction applies to a recalibrated
lattice.

Use observed growth rates `g_t = log(S_t/S_(t-1))/Delta_t` in inverse years.
Let `m_t` estimate mean growth and `v_t` the growth-rate variance in inverse
years squared. A proposed centered, exponentially weighted moment update, with the
same decay `0 < lambda < 1` for both moments, is:

\[
\begin{aligned}
\delta_t &= g_t-m_{t-1},\\
m_t &= m_{t-1}+(1-\lambda)\delta_t,\\
v_t &= \lambda\left[v_{t-1}+(1-\lambda)\delta_t^2\right].
\end{aligned}
\]

Initialize `m_0 = mu_g,0` and `v_0 = sigma_0^2 / Delta_t` from the
reviewed training estimates. Describe these as initial moment states; do not
claim that the reviewed regression estimate is necessarily identical to a sample
mean of observed growth rates. The update uses a weighted-moment variance convention,
not an unbiased finite-sample variance correction.

Convert the updated moments to annualized model quantities as follows:

\[
\widehat\mu_{g,t}=m_t,\qquad
\widehat\sigma_t=\sqrt{v_t\Delta t},\qquad
\widehat\mu_t=\widehat\mu_{g,t}+\frac{1}{2}\widehat\sigma_t^2.
\]

Update growth-rate variance and recover GBM volatility as `sqrt(v_t*Delta_t)`; do not describe an EMA of raw prices as
an EMA estimate of volatility. Preserve the distinction between mean growth and
arithmetic drift in all three methods. In the volatility-only comparison, keep
the forecast mean growth fixed but use the common updated variance state; the
arithmetic drift then changes through the half-variance conversion. Keeping the
variance trajectory identical in the two updating methods isolates the effect of
changing the forecast mean.

The existing rolling-correlation helper uses an explicitly uncentered, zero-mean
second-moment approximation. Reuse its teaching explanation where appropriate,
but do not silently substitute that estimator for the centered update above.

Express the decay using a half-life in trading observations when explaining it:
`lambda = 2^(-1/H_half)`, where `H_half` is the EMA half-life and is distinct from
`holding_period_days`. Faster forgetting follows recent changes more quickly while
using less effective historical information. It cannot anticipate an unobserved
shock, and it can make mean-growth estimates especially noisy.

Agreed default: expose
`ema_half_life_days = 21` and compute `lambda = 2^(-1/ema_half_life_days)`.
An observation's weight halves after 21 further trading observations. Keep
this setting independent of `holding_period_days`, even if their initial values
match. The initial half-life is an illustrative teaching choice fixed before
scoring 2025, not a setting selected for its performance on the evaluation data.
Use the same decay for the mean and variance updates described above.

### Forecasts and information timing

After observing the growth rate ending on date `t`, update the state for forecasts of
later observations. At each forecast origin, the model assumes:

\[
\log(S_{t+h}/S_t)\mid\mathcal F_t
\sim\mathcal N(\widehat\mu_{g,t}h,\widehat\sigma_t^2h),
\]

where `h` is in years and `F_t` contains observations available through date `t`.
For a multi-step forecast, hold that origin's estimates fixed over its horizon.
Refresh the forecast when the next real observation becomes available. Do not
insert subsequently observed 2025 parameter estimates into an earlier forecast.
This is a sequence of conditional forecasts, not an entry-date forecast with future
information supplied along the path.

Use a consistent boundary convention: initialize at `start_day_index` and update
with successive observed growth rates after that row. The default start of 1 matches the
reviewed example's initialization. Do not count the initial price as a predicted outcome.
Verify timestamps rather than assuming array indices identify the same day.

### Measures of help

The equations below specify the companion example's calculations. The EMA
development and the interpretation of its scores remain in that example. The
lecture and slides link to the example without reproducing this treatment.

Use the selected trade and its NPV target as the primary comparison. The instructor
selected an adjustable rolling window, initially 21 trading days, with one trading day
available as a special case. Do not introduce a separate next-day forecast-scoring
exercise as the main demonstration. Use `start_day_index` and
`holding_period_days` as the editable constants, keeping the forward window
distinct from the total time since purchase and from the EMA half-life. Label
entry dates, forecast origins, and prospective sale dates explicitly.

Show the forecast target probability, the subsequent realized scaled NPV, and
whether the target was exceeded. Use Brier loss to compare the target-probability
forecasts. Bands and interval diagnostics can support that same trade/window
example; they need not become a separate classroom comparison.

| Measure | Computation and interpretation |
| --- | --- |
| 95% coverage | Fraction of observations in the predicted interval; compare with 0.95, not with an objective of 100% |
| Average interval width | Quantify how broad the forecasts are; interpret together with coverage |
| Interval score | Penalize width and misses; lower is better |
| NPV Brier score | Average squared difference between a predicted target probability and the observed binary outcome; lower is better |

For an interval `[L,U]` with nominal probability `1-alpha`, and observed value
`x`, use the proper interval score:

\[
\mathrm{IS}_\alpha(L,U;x)=(U-L)
+\frac{2}{\alpha}(L-x)\mathbf 1\{x<L\}
+\frac{2}{\alpha}(x-U)\mathbf 1\{x>U\}.
\]

If reporting interval widths and scores, use the growth rate over the forecast
window, `log(S_sale/S_origin)/horizon` in inverse years, so ticker price scales
do not drive the comparison.
Price bands remain useful for the selected-ticker figures. Use the same nominal
interval level, forecast origins, and eligible outcomes for all methods.

For NPV probabilities, use `Brier = mean((p-y)^2)` with `y` equal to the strict
target-exceedance indicator. In the separate EMA example, Task 2 constructs the
rolling forecasts and Task 3 compares their scores across tickers at the same
forecast origins and target dates. Overlapping forward windows and the
shared initial position create dependence. Do not count these forecasts as
independent trades or combine
different horizons into an unexplained score. Evaluate only fully observed
windows in the 2025 data; do not silently shorten the window near the dataset's end.

Report per-ticker paired score differences, an aggregate comparison with explicit
weights/counts, and the fraction of tickers improved. Label these as descriptive
2025 results. Avoid treating tickers or forecast dates as independent samples for
significance claims. Distinguish better probability forecasts from greater trading
profit: the example does not change the position based on the forecast.

Choose the EMA half-life before using the 2025 scores. If tuning is needed, use
chronological validation within 2014–2024 and then freeze the setting. Do not add
a broad hyperparameter search to the live lecture. A lack of improvement, or an
improvement confined to volatility, is a valid teaching result.

## 8. New L5b and slides

The new L5b retains the reviewed multiple-asset progression: correlated GBM,
exact transitions, empirical covariance and its scaling, portfolio weights,
Dirichlet sampling, and the approved portfolio-growth discussion. Preserve the
covariance and Dirichlet examples and both optional advanced examples.

Make only the edits required by the new placement: lecture identifiers, titles,
dates where present, file references, and short references to material already
covered in L5a. The single-asset review and NPV catch-up content may be labeled as
review; do not use the move as a reason to rewrite the accepted derivations.
Link the out-of-sample example in the neighboring L5a directory.

For the slides:

- Build the new L5a deck from reusable L4b GBM/NPV slides, applicable current L5a
  review slides, a new RenTec profile, and concise worked-example descriptions.
- Add the profile to the lecture notebook before adding it to the deck. Verify
  company claims during authoring and do not attribute the example's EMA method
  to RenTec without evidence.
- Follow the notebook's topic order and worked-example stops. Retain the title,
  disclaimer, typography, and established `vnslides` design.
- Keep EMA derivations, plots, and score results in the computational example.
  The deck includes a concise description at the matching example stop.
- Renumber the reviewed current L5a deck as L5b, updating its title, internal
  references, source filename, Makefile, and output PDF.
- Compile both decks with their existing LaTeX workflow and inspect the rendered
  PDFs, especially new equations, tables, and figures. Preserve the approved
  distinction between mean growth, arithmetic drift, and benchmark growth.

## 9. Code, navigation, and packaging

Reuse the current `L5a/src/OutOfSample.jl` and `docs/oos-functions.md` where their
definitions still apply. Place new documented helpers in the notebook's local
`src/` directory, loaded through `Include.jl`; proposed files are
`AdaptiveGBM.jl` and `TradeOutcomes.jl`. Add concise function references under
`docs/`. Keep definitions out of notebook code cells.

Separate parameter updating, analytical forecasting, Monte Carlo simulation,
trade-outcome calculation, and scoring so their data timing is inspectable.
Return tables containing ticker, forecast origin, target date, horizon,
method, parameters, forecast quantities, and observed outcome as appropriate.
Document units and assumptions in Julia docstrings. Use deterministic random
seeds for the displayed simulations and numerical checks.

Preserve shared training files and the reviewed baseline estimator. Do not
overwrite the 2014–2024 parameter CSV with EMA estimates or relabel its legacy
columns without coordinating their consumers. Carry the required supporting
files to both active lecture directories without an unrelated package refactor.

Update active navigation after the notebooks are in place:

- The Week 5 topic description in [README.md](README.md).
- The 5a and 5b topic entries in the
  [course schedule](lectures/instructor/schedule/CHEME-5660-CourseSchedule-Fall-2026.csv),
  retaining the scheduled September 22 and September 24 dates and unrelated rows.
- Example lists, advanced-material READMEs, lecture cross-references, slide
  navigation, figure paths, documentation links, and build dependencies.
- Active references to the old minimum-variance L5b: distinguish its planned L6a
  placement from the new multiple-asset L5b, and direct historical references to
  the preserved archive where appropriate. Do not create links to future L6a
  files before those files exist.
- Review-record navigation and the completed-review notes in `AGENTS.md`: add
  clear relocation/provenance notes, preserve recorded approvals and scores, and
  prevent old L5a/L5b labels from being mistaken for new review assessments.

Write a refactor handoff mapping original paths to archive paths and active
destinations. Retain the original handoffs unchanged inside the archive. In live
records, limit changes to relocation notes and necessary links; do not rewrite
the historical assessments or claim their scores apply to newly authored sections.

Follow the [weekly release runbook](WEEKLY-RELEASE-CHECKLIST.md) for local bundle
preparation and extracted-bundle checks. Ensure the new Week 5 is self-contained
for its required examples; links to earlier lectures should be identified as
external reading if the earlier week is absent from the bundle. Keep the archive
out of the student bundle. Any later published update must use a new available
release revision, preserving existing tags and assets.

## 10. Implementation sequence

1. **Inventory and archive.** Read the source notebooks and applicable handoffs,
   capture hashes and dependencies, make the archive, and verify the copy.
2. **Prepare new L5b.** Copy the reviewed multiple-asset material into its new
   location; update identifiers, links, and slide build targets. Verify content
   preservation against the archive after accounting for the intended renaming.
3. **Separate the examples.** Restore the reviewed OoS notebook, move the
   reviewed NPV notebook with its input data, and retain the parameter updating,
   sequential forecasts, and scoring in the EMA example. Verify preservation
   and execute all three before reviewing their descriptions.
4. **Assemble new L5a.** Reuse approved GBM/NPV passages, add the profile and worked-example
   descriptions, and keep the EMA development in the three-task example. Keep
   data-dependent conclusions tied to the actual computed results.
5. **Synchronize slides and navigation.** Build the companion decks, update
   schedule topics and links, and record which passages were reused or changed.
6. **Execute and render.** Run the changed computational notebook, check moved
   notebooks' setup and dependencies, inspect rendered notebooks and decks,
   and complete the applicable local bundle checks.
7. **Record completion.** Save the source/destination map, validation evidence,
   final artifact paths, and a concise account of new or substantively changed
   content. Record the agreed follow-up placement: data-driven minimum variance
   in L6a and SIM in L6b, with the combined SIM/portfolio scope resolved through
   the interactive discussion before the Week 6 authoring work.

These are implementation milestones, not new mandatory approval gates. Preserve
the instructor's accepted decisions and avoid asking for repeated approval of
reused sections. If a substantive teaching choice changes, identify that change
specifically instead of reopening the completed review.

## 11. Validation and acceptance criteria

### Preservation and structure

- [x] The complete original Week 5 archive matches its recorded inventory and hashes.
- [x] The original minimum-variance material and review records remain recoverable.
- [x] New L5b preserves reviewed substantive content; differences are limited to
      the intended placement, naming, navigation, and necessary transitions.
- [x] The new L5a lecture contains RenTec, the single-asset review, NPV development,
      and question-led descriptions of the NPV, OoS, and EMA examples. The latest
      follow-up adds EMA parameter theory to the lecture notebook; simulations,
      rolling trade calculations, and empirical results remain in the example.
- [x] The lecture derives the same EMA updates as the example implementation.
      Empirical score results remain in the example; the current slide deck
      retains its brief example introduction.
- [x] Bootstrap is reserved for the future SIM lecture.
- [x] Every lecture/example has exactly three objectives and three takeaways;
      each computational example has exactly three tasks.
- [x] The standard setup, teaching comments, documented source helpers, equation
      notation, figure conventions, and major-section separator rules are retained.

### Data timing and numerical behavior

- [x] Training observations end in 2024; 2025 is used only as the evaluation
      stream and for updates after the corresponding observation becomes available.
- [x] Ticker eligibility, dates, price validity, exclusions, and observation
      counts are reported; all compared methods use the same eligible outcomes.
- [x] The brief setup note explains selection using complete 2025 histories and
      labels the VWAP-based payoff as price-based NPV without dividend cash flows.
- [x] The original frozen forecast agrees with the reviewed model for unchanged
      inputs, including the `mu_g` to arithmetic-drift conversion.
- [x] The NPV formula, terminal-price threshold, strict success indicator, and
      realized discounted return agree; the median target gives probability 0.5.
- [x] Monte Carlo target probabilities agree with analytical probabilities within
      their documented sampling error; do not compare with an arbitrary tolerance.
- [x] Recursive EMA moments agree with an independent weighted-moment calculation
      on a small known series, including the initialized state's weight.
- [x] Prefix checks confirm that appending or altering later observations does
      not change previously issued estimates or forecasts.
- [x] Holding moment states fixed reproduces the frozen calculation; all methods
      agree at initialization. The two EMA comparisons share the same variance state.
- [x] Annualization, positive-price/variance checks, invalid inputs, zero remaining
      horizon, and deterministic zero-volatility cases are handled explicitly.
- [x] Coverage, interval score, and Brier calculations match simple known cases,
      use the intended units, and compare identical origins and horizons.
- [x] Changing either date constant updates the model grid, forecasts, outcome
      lookup, figures, and tables consistently. Verify the one-day window, a later
      start index, the last valid forecast, and rejection of unavailable horizons.
- [x] The purchase price at the selected start row stays fixed. Sale row `k+H`
      and discount duration `(k+H-s)*Delta_t` agree across forecast probabilities
      and realized NPV. Dependent and overlapping outcomes are labeled accordingly.
- [x] Interpretations report the observed result without promising that EMA must
      help, equating coverage with profit, or treating dependent outcomes as independent.

Use focused execution checks for changed statistical behavior. Renaming or
prose-only edits do not require a new suite of tests that merely repeats the
implementation. For unchanged relocated notebooks, verify their dependencies and
run the checks required by the local release workflow rather than repeating their
editorial review.

### Rendered artifacts and delivery

- [x] Changed notebooks execute in the course environment and have current,
      meaningful outputs without saved errors or author-machine setup noise.
- [x] Rendered notebooks show readable mathematics, figures, tables, and section
      boundaries; student-visible labels agree with the code and lecture notation.
- [x] Both slide PDFs build and pass visual inspection in notebook teaching order.
- [x] Active links, source documentation, figures, and slide dependencies resolve.
- [x] Schedule descriptions, Week 5 navigation, and historical review notes agree
      with the new lecture assignments.
- [x] The local student bundle includes required resources and excludes the
      archive; extracted-bundle checks pass before any later publication.
- [x] A refactor handoff records what was reused, what changed, validation results,
      any remaining limitations, and the archived minimum-variance material
      assigned to the follow-up L6a refactor.

## 12. Implementation defaults and deferred decisions

The following defaults apply to the separate EMA example. The restored NPV
and OoS notebooks retain their reviewed defaults. The ticker, start index,
adjustable holding period, benchmark rate, NPV target, EMA half-life, and
simulation defaults are agreed. Record them in the EMA example
before inspecting the corresponding 2025 performance scores. Deferred Week 6
items retain their separate status below:

| Item | Starting approach |
| --- | --- |
| Selected ticker | Agreed editable default: SPY, retained from the reviewed out-of-sample notebook; repeat across eligible tickers. Any retrospective illustrative selection is disclosed |
| Entry-day index | Agreed editable constant: `start_day_index`, initially 1 in the aligned 2025 price rows; display the actual entry date |
| Benchmark growth rate | Agreed editable `g_y = 0.05` per year, continuously compounded, reusing L4b; fixed within each scenario. Vary it to assess the same trade against different growth benchmarks |
| NPV target | Agreed editable `rho_star = 0.0` means exceeding the selected benchmark. Choose before the reveal and distinguish positive-NPV success from exceeding a negative target |
| EMA half-life | Agreed editable `ema_half_life_days = 21`, independent of the holding period; same decay for mean and variance. Fix before scoring 2025; chronological training-period validation only if needed |
| Main forecast horizon | Agreed editable constant: `holding_period_days`, initially 21 trading intervals; 1 means the next observation |
| Daily trade updates | For each `k` from `start_day_index` through `N-holding_period_days`, compare probabilities for sale at `k+holding_period_days`; keep the selected purchase price fixed |
| Monte Carlo settings | 100 displayed paths and seed `5660`. Use analytical probabilities for rolling and all-ticker scoring. The separate EMA example omits the former 10,000-draw initial-trade check |
| Evaluation sample and payoff | Agreed: retain complete, aligned 2025 histories and observed VWAP; briefly explain selection using 2025 availability and label NPV as price-based, excluding dividend cash flows |
| Company profile | Concise, verified primary-source profile with the established course presentation |
| Old minimum-variance lecture | Agreed destination: new L6a, preserving the reviewed data-driven allocation content |
| SIM and SIM portfolio allocation | SIM is assigned to new L6b; the scope of a combined meeting remains under discussion |
| Bootstrap uncertainty | Reuse the 2025 SIM example's explanation, pseudocode, and three-task progression for new L6b; preserve the expanded 2026 version as supporting material |

## 13. References for new statistical material

- [RiskMetrics Technical Document, fourth edition](https://www.msci.com/documents/10199/5915b101-4206-4ba0-aee2-3449d5c7e95a):
  background for exponentially weighted volatility estimation and the decay
  parameter. Its volatility convention should be distinguished from the centered
  moment update proposed here.
- [Gneiting and Raftery, Strictly Proper Scoring Rules, Prediction, and Estimation](https://sites.stat.washington.edu/people/raftery/Research/PDF/Gneiting2007jasa.pdf):
  reference for interval scores and probabilistic forecast evaluation.

Use these to support the new material. Preserve the reviewed course explanations
and notation wherever the existing passages already serve the revised lecture.

## 14. Interactive review decisions

### Question 1: Downstream placement — resolved; Week 6 details deferred

The instructor confirmed: "L6a should be the min-var (data), and L6b should be the
SIM." This resolves the prerequisite gap identified in the current Week 6:
minimum-variance allocation is taught before the SIM lecture applies it.

The instructor subsequently requested that we save the Week 6 discussion and
return to Week 5. Preserve the following findings for the follow-up; do not make
completion of the combined SIM scope a prerequisite for the Week 5 refactor.

The instructor also asked whether SIM and SIM portfolio allocation can share one
lecture. The following is a proposal for discussion, not an approved reduction in
scope:

- Make the combined lecture develop one sequence: model asset growth with a
  market factor, estimate its parameters, construct portfolio inputs, and apply
  the allocation problem already developed in L6a.
- Preserve the SIM equation, meanings of alpha/beta/residuals, systematic versus
  residual risk, least-squares estimation, and the mean/covariance construction.
- Retain the cross-asset residual-covariance assumption and one diagnostic that
  checks it before using the SIM covariance in a portfolio.
- Use one estimation example and one risky-asset portfolio comparison as the main
  live computations. Reuse the L6a allocation objective, constraints, asset set,
  and data periods so the portfolio example focuses on the changed inputs.
- Reuse last year's bootstrap explanation and worked example in the SIM estimation
  discussion. Walk through generating synthetic data, refitting alpha and beta,
  and comparing their intervals, using the existing pseudocode and result table.
  Preserve the 2025 example's complete three-task structure and avoid adding the
  expanded 2026 diagnostics to the main teaching sequence.
- Recall how the SIM inputs also enter the risky/risk-free problem and capital
  allocation line. Preserve the complete existing example and derivations as
  companion material, using L6a's development to avoid repeating those derivations
  during the combined meeting.
- Keep comparisons on a common basis: same constraints and targets, evaluate
  candidate weights under the same covariance when comparing estimated risk,
  and distinguish that comparison from realized 2025 performance.
- Preserve the original Week 6 material before assembling the combined lecture,
  and keep the fitting example's saved-parameter output connected to the portfolio
  examples that load it when their locations change.

The proposed combined meeting does not require moving SIM portfolio allocation
to Week 7 if this scope fits the available class time. The actual time allocation
and live-example depth still need to be settled; no meeting length has been
assumed as an established course fact.

### Bootstrap source and reuse — instructor direction recorded

The instructor directed us to examine what was taught last year and use more of
that content because reviewing newly composed material is taking too much work.
The 2025 lecture and worked bootstrap example have now been inspected, along with
the 2025 portfolio lecture and the expanded 2026 bootstrap narrative. The source
mapping and local corrections above capture the resulting approach.

This direction supersedes the earlier suggestion to choose between a newly
written short bootstrap illustration and a larger newly organized treatment.
Use the existing 2025 teaching development. Preserve reviewed 2026 work elsewhere;
this is not an instruction to revert accepted corrections or restart closed
reviews. Combining the two SIM topics should primarily involve selecting existing
sections, removing duplicated review passages, and making necessary connections.

### Question 2: Live L5a teaching scope — superseded by the example split

The instructor originally approved this sequence:

1. RenTec and the GBM review, using the existing out-of-sample example.
2. The January trade: frozen parameters, predicted NPV target probability, then
   the observed outcome.
3. The same calculation across eligible tickers, with interpretation of the results.
4. EMA updates: explain the update, show how forecasts change, and compare their
   performance with frozen parameters.

The instructor subsequently corrected the implementation scope: the EMA material
belongs in the computational example. The lecture and slides now only describe
and link to that example. Reuse reviewed explanations and retain its three-task
structure; do not recreate the EMA treatment in the main lecture. The latest
revision replaces the initial January-trade reveal with the reviewed NPV
notebook and restores the original OoS example. Section 5 records the three
separate examples that now implement the teaching sequence.

### Question 3: Trade-centered EMA comparison — rolling window agreed

The instructor prefers to keep the comparison connected to the January trade,
using the next 21 days or an adjustable window that includes the next day. This
supersedes the proposed separate next-day comparison as the main EMA exercise.
Keep NPV target probabilities and realized outcomes at the center of Task 3.

After clarification that both probability calculations update daily using the
current observed price and a moving prospective sale date, the instructor agreed
and requested constants for the start-day index and holding-period length.

Use `start_day_index = 1` and `holding_period_days = 21` as the initial configurable
values. The first selects the purchase and first forecast row; the second selects
the number of forward trading intervals from each forecast origin. Keep the
purchase price fixed and move the prospective sale date each day. Support a
one-day window and later start indices with consistent dates, discounting, and
outcome alignment. The full indexing convention is specified in Section 6 and in Tasks 1–2 of
the separate EMA notebook.

### Question 4: Numerical defaults — agreed

The instructor requested editable constants for the entry index and holding
period. These controls are settled. The instructor also agreed that increasing
`g_y` lets the example represent different benchmarks. Expose this rate as an
editable constant, holding it fixed within each scenario and retaining the same
underlying price forecasts. Keep this as a small extension of the NPV calculation within the separate
EMA example; preserve the reviewed NPV notebook itself.

The instructor agreed to the starting pair `rho_star = 0.0` and `g_y = 0.05`,
both editable; the latter reuses the illustrative benchmark in the reviewed
L4b example. The instructor also agreed to `ema_half_life_days = 21`, independently
editable from the holding period, with `lambda = 2^(-1/ema_half_life_days)`.
The instructor agreed to retain SPY as the selectable worked-example default
from the reviewed out-of-sample notebook, followed by the same calculation across
eligible tickers.

The instructor agreed to retain 100 displayed paths and the reviewed seed `5660`.
The earlier 10,000-draw initial-trade check is omitted from the separate EMA
example. Use analytical probabilities for rolling and all-ticker scoring.
The path count and seed remain editable constants.

### Question 5: Evaluation sample and payoff interpretation — agreed

The instructor agreed to retain the reviewed example's data conventions and add
a short setup note:

- Evaluate tickers with the required training estimates and complete, aligned
  2025 price histories. Report the final count and exclusions. Selection uses
  data availability through 2025, so the evaluation sample is not a reconstruction
  of the investible universe known at the entry date. Results apply to this
  selected sample; do not generalize them to every S&P 500 constituent.
- Compute price-based NPV using the observed daily VWAP as the entry/sale price
  proxy. Dividend cash flows are not included in this payoff calculation, so
  label it as price-based rather than total return.

Keep this explanation brief and reuse existing course wording where possible.
The local [market-data record](code/src/data/MARKET-DATA.md) documents the snapshot,
available columns, and aligned complete histories. This decision does not add a
new data pipeline or expand the live lecture into a data-selection discussion.

### Interactive review status — complete

All five Week 5 planning questions have been addressed. The agreed decisions are
incorporated into the task descriptions, numerical defaults, and acceptance
checks above. No Week 5 planning question remains open from this review.

Implementation completed following Section 10 and the instructor's scope
correction above. The archive, execution checks, rendered artifacts, and extracted
student bundle were verified. Week 6 remains deferred.
