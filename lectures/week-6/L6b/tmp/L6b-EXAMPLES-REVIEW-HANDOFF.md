# L6b examples review — resume here

Saved September 27, 2026 at the instructor's request, after an initial review of
the four L6b example notebooks. No notebook, data file, or slide was changed by
this review. The instructor will resume on September 28.

This folder is `tmp/`, which `scripts/release-week.sh` excludes from student
bundles.

## Scope and question

The instructor asked for a 0–10 rating of each example and whether the 2025
course notebooks and the eCornell AI-in-Finance short course could be reused to
reduce the review burden.

| Example | File |
| --- | --- |
| Estimation (SVD) | [CHEME-5660-L6b-Example-SVD-SIM-Estimation-Fall-2026.ipynb](../CHEME-5660-L6b-Example-SVD-SIM-Estimation-Fall-2026.ipynb) |
| Bootstrap uncertainty | [CHEME-5660-L6b-Example-SIM-Parameter-Uncertainty-Fall-2026.ipynb](../CHEME-5660-L6b-Example-SIM-Parameter-Uncertainty-Fall-2026.ipynb) |
| SIM portfolio, risky assets (RA) | [CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb](../CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb) |
| Risky and risk-free (RRFA) | [CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb](../CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb) |

Older counterparts compared:

- 2025: `CHEME-5660-CourseRepository-Fall-2025/lectures/week-7/L7a/` (SVD
  estimation, parameter uncertainty) and `week-8/L8b/` (SIM-MinVar-RA and -RRFA).
  Several are duplicated across weeks 7–9 of that repository.
- eCornell: `eCornell-AI-finance-lectures/lectures/session-1/` (Build
  MinVariancePortfolio-RA, MinVariancePortfolio-RRFA, Optional
  SIMParameterEstimation).
- Approved 2026 notebooks: the L6a data example
  ([CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb](../../L6a/CHEME-5660-L6a-Example-Data-MinVar-Portfolio-Fall-2026.ipynb),
  marked complete September 26) and the optional
  [data risk-free notebook](../advanced/data-risk-free/CHEME-5660-L6b-Advanced-Data-MinVar-RiskFree-Fall-2026.ipynb)
  (from the reviewed 9.1/10 L5b example).
- Prior decisions: [WEEK-6-REUSE-INVENTORY.md](../../../instructor/WEEK-6-REUSE-INVENTORY.md).

## Provenance measured

| Example | Origin | Similarity to 2025 (code / markdown) | Prose words 2026 vs 2025 | Stored outputs |
| --- | --- | --- | --- | --- |
| Estimation | Migrated 2026-08-02, then heavily rewritten | 0.20 / 0.28 | 2,330 vs 1,590 | yes |
| Bootstrap | Near-copy of 2025 L7a, added 2026-09-24 | 0.98 / 0.89 | 1,550 vs 1,500 | none until this review |
| RA | Migrated 2026-08-02, then heavily rewritten | 0.15 / 0.28 | 2,970 vs 2,190 | yes |
| RRFA | Migrated 2026-08-02, then heavily rewritten | 0.21 / 0.28 | 2,200 vs 2,475 | yes |

The eCornell notebooks share little text with any of these (similarity 0.06–0.17).

## Summary of ratings and recommendations

| Example | Overall | Runs | Recommendation | Estimated review time saved |
| --- | ---: | --- | --- | --- |
| Estimation | 6.5 | yes, 24 s; parameter archive is stale | Keep the 2026 code; rewrite about 14 markdown cells in the 2025 register (about 2,200 to 1,450 words) | one-half to two-thirds |
| Bootstrap | 6.0 | yes, 21 s | Already the 2025 notebook; fix about 10 cells | 30–45 min of instructor review |
| RA | 6.5 | yes, 35 s; fails with other ticker lists | Hybrid on the approved L6a skeleton, porting about 10 of 22 code cells verbatim | 40–50% |
| RRFA | 5.5 | yes, 29 s | Hybrid on the data risk-free notebook and L6a wealth code, keeping the SIM-specific cells | 50–60% |

**Main conclusion on reuse.** The 2025 code cannot be the base for the
estimation, RA, or RRFA examples, because each 2025 version had real errors that
the 2026 rewrites fixed: SIM market moments taken from the 2025 test window,
the time step applied twice to residual variance, different mean vectors for the
two frontiers (the 2025 "rotated and shifted" frontier was largely an artifact),
and residual variance scaled by 252. Reuse from 2025 is its register (short
paragraphs, one idea per cell, "Let's" lead-ins), its lean three-task shape, its
bold question callouts, and the tangent composition table. The eCornell material
runs on its own package and synthetic market generator and has the unit error
the inventory flags, so reuse is limited to a few callout patterns. The largest
saving comes from the notebooks already approved this fall: about half of the RA
and RRFA code is a copy of approved L6a or data risk-free code with the approved
comments stripped out. Porting those cells back verbatim turns them into a
diff-only review.

## Fix first, whatever route is chosen

1. **Stale SIM parameter archive.** The committed
   `data/SIMs-SP500-01-03-14-to-12-31-24.jld2` (commit `5974933`, August 16)
   predates the split repair in `5f41ede` (September 20). A fresh run differs in
   120 fields across 12 tickers (MA R² 0.029 to 0.560 and s² 248.7 to 5.67; also
   GOOG, UNP, PPG, CHD, HBI, TECH, BF.B, UA). Metadata, market mean and
   variance, and the 13 portfolio firms are unchanged, so RA and RRFA outputs are
   unaffected. Re-execute the estimation example in the repository, commit the
   regenerated archive, then re-run RA and RRFA as a check. Stale copies also sit
   in `week-7/L7a/data` and `week-7/L7b/data`; the instructor decides whether to
   refresh or delete them.
2. **RRFA tangent comparison is not like-for-like** (cells 22–24, takeaway 2).
   Each tangent portfolio is scored under its own covariance, and the SIM one
   uses the exact ray while the data one uses a grid. Under the common sample
   covariance the SIM tangent's annualized Sharpe ratio is 1.265 against the data
   tangent's 1.285, so the ranking flips, and the SIM covariance understates the
   SIM tangent's standard deviation (4.24 versus 4.44). The lecture and the
   inventory require a common covariance. Takeaway 2 was rewritten on
   September 27 and says "under each model's own covariance", which is accurate
   but describes the unfair comparison.
3. **RA fails when students change tickers** (cells 11, 13, 39, 44). With XOM,
   CVX, KO, PEP, JPM, PG, and DUK, the fixed `g_target = 0.20` is infeasible and
   cells 39 and 44 raise AssertionError, cascading to 46 and 48. Cell 13 claims
   "every cell below adapts".

## Issues common to all four

- No task opens with "In this task, …".
- The opening overview is an itinerary placed above the learning objectives.
- Cell 3 is a composed package list, not the standard documentation line of the
  L4b parameter example (the estimation example's cell 3 also links a
  nonexistent `src/Compute.jl`).
- Clause-joining semicolons and paragraphs of 100+ words.
- References still describe the pre-reshuffle layout ("L6a's advanced
  material", "the second example", tangent and CAL attributed to L6a).
- Interpretations tied to the default ticker, without the "your results may
  differ" reminder.
- Code with several statements per line, few stage comments ending " -", and
  unexplained idioms.

## Estimation example — 6.5/10

Execution: 24 s, no errors, in a private sandbox copy. Outputs match except
cell 32 (median |ρ| 0.071 stored versus 0.073 fresh, 95th percentile 0.27 versus
0.273) and cell 34 (stored path `/Users/jeffreyvarner/.../week-6/L6a/data/...`
versus `data/...`), both from the stale archive. Betas run from GLD 0.018 to NCLH
2.117 with median 1.087, consistent with the lecture.

Scores: technical 7, organization 6, clarity and density 5 (seven paragraphs of
100+ words, longest 147; about 11 clause semicolons), code as a lesson 6,
figures and tables 8 (cell 30 vlines lw=2, legend covers bars).

Problems:

1. Stale producer output (cells 32, 34, archive). See "Fix first".
2. Ticker-tied interpretation (cells 17, 22, 24): "a narrow interval well away
   from one … is well supported"; "The stock has the larger beta and the far
   smaller R²". Replace with reading guidance such as a bold
   "__How do we read the table?__" and add the "results may differ" reminder.
3. Opening and structure (cells 0, 3, 9, 18, 25, 33, 36): one-sentence overview
   below the objectives; standard cell 3; "In this task, …" openers; remove
   L6a-era wording ("save the parameters for L6b", "L6b's covariance model
   inherits").
4. Lecture duplication, denials, and inaccuracies (cells 4, 13, 15, 18, 20, 29,
   33): cut condition-number squaring and pseudo-inverse theory (13), the `var`
   degrees-of-freedom check (18), and the classical-assumption list and
   t-quantile digits (20), citing the lecture instead. Cut unproposed denials
   ("an intercept is not a statement about total shareholder performance" in 4,
   "needs no time-step factor" in 18, "None of these three numbers is a
   forecast" in 22, and the takeaway label "…beta is not a measure of fit").
   Cell 20 points to "the uncertainty example" for dependence, which that
   Gaussian bootstrap does not test; point to the advanced diagnostics notebook
   or cut. Cell 15 calls condition number 2.151 "close to one". Cell 29 says the
   "semiconductor names have betas well above one" (INTC is 1.184). Cell 33's
   "a few tenths" understates bank residual correlations (0.52 to 0.74), and
   technology-bank pairs are negative (−0.20 to −0.28).
5. Code (cells 10, 14, 19, 21, 23, 26, 28, 32): cell 23 packs a nested `fit`
   onto one line and duplicates the Task 3 loop; `tickers_13` is hard-coded
   twice; `(transpose(X̂)*X̂) \ I` is computed three times. Move the tickers to
   Constants, define the fit once, and add L6a-style stage and idiom comments.

Reuse: 2025 cannot be the base (residual variance scaled by `1/Δt`, `inv()`,
hard-coded `t = 1.96`, "excess" growth with r̄ = 0, no R², no universe fit, no
archive). Restore only the register; its step-by-step X̂ and y build (2025 L7a
cells 24–29) is the prose model for Task 1. From eCornell, borrow the bold "How
to read the table" callouts (its cells 11, 15) and optionally ticker-independent
top and bottom R² tables. Keep every 2026 code cell (5, 10, 12, 14, 19, 21, 26,
30, 32, 34): growth-rate units, backslash solve, rank and three-solver asserts,
TDist critical value, CI table with `covers_zero`, R² = ρ² check, stock versus
index fund contrast, SPY-on-itself assert, residual-correlation diagnostic (the
lecture promises it), and archive metadata that consumers assert on
(`schema_version == 2`, `market_ticker`, `delta_t`,
`variance_convention == "growth_rate"`, training `market_mean` and
`market_variance`).

Recommendation: keep and polish, a prose-only hybrid. Rewrite markdown cells 0,
3, 4, 9, 13, 15, 18, 20, 22, 24, 25, 29, 33, 36 (target about 1,450 words), fix
the five problems, and re-execute to regenerate the archive.

## Bootstrap uncertainty example — 6.0/10

Execution: 21 s, no errors (after adding `code/` to the sandbox). It writes
nothing to `data/`. Fresh MSFT results: α 0.0999 per year (SE 0.045), β 1.152
(SE 0.021), R² 0.5219 (equals the squared correlation), residual variance 5.60
per year squared, bootstrap standard deviations within +1.4% (α) and −1.2% (β) of
theory. Units are 2026-correct (growth rates, no Δt in variance or SE, OLS by
backslash, no ridge, no "L7a" references).

Scores: technical 7, organization 6 (no `___` before Task 3), clarity 6 (2025
phrasing "students will explore", "Ok, wow!"; two semicolon-plus-denial
sentences; R² defined twice), code 5 (dead variables, redundant lookups, huge raw
prints, no links for `fit_mle`, `pretty_table`, or backslash), figures and
tables 5 (lw=2, "(1/y)", "R^2", seven cryptic columns with no SE column or
units).

Problems:

1. Cell 34 gives the wrong reason for the interval gap (MLE versus N−2 variance,
   a 0.04% effect; the actual gap is Monte Carlo error of about 2.2% from
   K = 1000) plus a circular semicolon denial. Replacement: "The synthetic data
   follow the fitted Gaussian model, so the intervals should agree up to the
   sampling error of 1,000 draws. Agreement checks the calculation. Residual
   diagnostics test the model."
2. Cells 35–36 compare interval endpoints only indirectly (the bootstrap
   interval is centered on the bootstrap mean). Use a table of parameter,
   estimate, SE theory, SE bootstrap, and ratio, then θ̂ ± z·SE or percentile
   intervals, with one interpretive sentence.
3. Cells 0–4 are the 2025 opening (GitHub link in cell 3, old Include wording,
   no VWAP paragraph, "students will explore" above the objectives). Copy the
   L4b opening and put a short "we" overview below the objectives.
4. Cells 16, 20, 22, 23, 25: cell 16 prints a 2766×424 matrix and cell 20 a
   424-entry Dict; cell 22 hard-codes "MSFT" before `ticker_of_interest` is set
   in cell 25; cell 23 promises to "validate that the confidence intervals make
   sense", which Task 2 never does. Suppress the prints, move the ticker to
   Constants (cell 13), show a small table, and replace cell 23 with a
   ticker-independent reading (across all firms, 373 of 423 alpha intervals
   contain zero, and beta SEs are about 3% of beta).
5. Cells 20 and 30: copy the lecture's bootstrap pseudocode (θ̂ᵢ, residuals
   **r**, "fit a normal distribution to the residuals"); drop "The market
   observations stay fixed; we do not resample the price records."; remove the
   dead `Δt = (1/252)`; use `growth_rate_array[:, i]`; rename `t = 1.96` to
   `z = quantile(Normal(), 0.975)`.

Smaller: stray `"` in cell 15; `T` defined twice and `resampled_residuals`
should be `synthetic_residuals` in cell 31; cell 26 says "firm's returns" and
repeats cell 24's R² sentence; cell 29 figure needs lw=3, "1/yr", "R²", and a
better legend than "Perfect x=y line".

Reuse: this already is the 2025 notebook. From the demoted
[diagnostics notebook](../advanced/diagnostics/CHEME-5660-L6b-Advanced-SIM-Diagnostics-Fall-2026.ipynb),
fold back the date-alignment asserts, a per-method SE table, percentile
intervals, and one β̂ bootstrap histogram with the estimate. Leave
autocorrelation-consistent SEs and the VWAP lag-1 finding there (MSFT residual
lag-1 ACF 0.085 against a 0.037 band, so the existing KT3 caveat is warranted).
From eCornell, only the SE-ratio column; its claim that a ratio near one
"confirms the Gaussian assumption" is wrong. Tasks 1–2 duplicate the estimation
example's all-firm fit and R²; loading the archive instead would shorten it.

Minimum to release: L4b opening; rewrite cells 34–36; lecture pseudocode in
cell 30; code cleanup in cells 13, 20, 22, 25, 31 with `;` on large outputs and
function links; small text and figure fixes and `___` before Task 3; re-execute
to store outputs.

## SIM portfolio example (RA) — 6.5/10

Execution: 35 s, no errors; archive unchanged. Fresh outputs match the stored
ones except cell 2's stale "Activating project" line. Every prose number
matches (BAC–C 0.86 versus 0.49, up to seven points of weight difference,
variance regret 0.01 to 1.2, the (N−1)/(N−2) factor). GMV (data), equal-weight,
and SPY scorecard rows are identical to L6a.

Scores: technical 8, organization 6, clarity and density 5 (2,830 prose words
versus 2,038 in 2025 and 3,324 in L6a, which covers more; about a dozen clause
semicolons in cells 8, 13, 20, 22, 28, 29, 33, 37, 40, 41, 49; 13 sentences over
45 words, longest 81 in cell 29), code 6 (cells 19, 23, 30 good; 36, 39, 44
pack statements up to 277 characters and rebuild the problem five times; cells
copied from L6a lost its approved comments), figures and tables 7 (the frontier
plot in cell 34 hides the dashed curve under solid ones, and 7-point ticker
labels overlap).

Problems:

1. Fixed target breaks student ticker lists. See "Fix first". Compute it in
   Task 2, for example
   `g_target = (max(frontier_data.g[1], frontier_sim.g[1]) + maximum(ĝ))/2`,
   and remove the "every cell below adapts" claim.
2. Lecture derivation repeated (cells 18, 20, 22; cell 22 is 160 words with a
   77-word sentence). Keep one recall sentence per exact fact and the checks in
   cells 21 and 23 (saves about 200 words).
3. Structure (cells 0, 13, 29, 41): "In this task, …" openers, a short overview
   below the objectives, and cut package internals in cell 29.
4. The common-covariance comparison is hard to read (cells 33–37). Give
   `efficient_frontier` a shared `targets` argument so cell 36's rebuild
   disappears; plot `σ_under_data − σ_data_opt` and `σ_believed − σ_under_data`
   against g⋆ as a second panel; cut cell 37 to two or three sentences and
   define "regret" or drop it.
5. Stale references and notation: cell 49 cites "L6a's advanced material" (link
   `L6b/advanced/estimation-risk/`); "the second example" appears twice (cells
   49, 50) though the risk-free example is the fourth; cells 15 and 29 write ĝ
   and $\bar{\mathbf{g}}$ where the lecture uses g′ and μ_g; cell 8's "no
   time-step factor" is an unproposed denial.

Reuse: 2025 does three one-idea tasks, builds `problem_data` and `problem_sim`
once and re-solves by setting `.R` (2025 cells 37, 39), runs about 2,040 words,
uses question callouts ("Are they similar? Why or why not?", "__What do you
observe?__", "__What do we expect to see?__"), and states the parameter count in
a takeaway. Its code cannot be the base: SIM market moments from the 2025 test
window (cells 5, 13, 28), data means from L4b regression drifts (cell 26), Δt
applied twice to residual variance (cell 30), so AAPL's SIM variance exceeds the
data variance by 13% where same-window estimates agree to 0.03%. From eCornell,
only its three-bullet "SIM Covariance Matrix" blockquote (cell 9) as the lead-in
for cell 18. Keep from 2026: archive schema and units asserts (9), market
moments checked against training SPY (19), the two exact-fact checks (21, 23),
heatmap pair and residual-pair table (25, 27), common-covariance evaluation
(33–36), weights table with betas (39), and the 2025 scorecard (42–48).

Recommendation: hybrid, target about 2,000–2,200 words. Replace setup, data,
constants (cells 1–11) and Task 3 (cells 41–48) with L6a cells 1–11 and 42–49
verbatim, adding the archive load and the two SIM portfolios plus L6a cell 16
for the inputs. Reuse L6a cell 32 (with comments) for the frontier sweep,
wrapped as the helper. About 10 of 22 code cells (5, 7, 11, 14, 16, 30, 42, 44,
46, 48) are already L6a code with comments stripped. New review then shrinks to
about six code cells (9, 19, 21, 23, 25/27, 36, 39) and about 1,200 words.

## Risky and risk-free example (RRFA) — 5.5/10

Execution: 29 s, no errors; archive unchanged. Fresh outputs match except cell
2's stale "Activating project" line. Prose numbers match (AMD 0.0405, β_p
1.505/1.563, annualized Sharpe about 1.3 as 1.324/1.285, realized σ ratios
0.247/0.493/0.743/1.269 against 0.25/0.50/0.75/1.25, realized growth 0.2561
against 0.3944).

Scores: technical 7, organization 4 (no "In this task", itinerary overview,
non-standard setup, no `###` subsections, cell 18 re-derives SIM-3), clarity 4
(comma-chain sentences, 8 clause semicolons, ticker-tied prose, takeaways not in
the "We…" voice), code 5 (frontier sweep copied three times, chained statements,
unexplained idioms, 3 of 12 code cells with stage comments), figures and tables
6 (CAL figure with solver points works; 7-point labels, MSFT/AAPL overlap,
faint palest `cgrad(:blues)` line; results in `println`; sum row shows `NaN`).

Problems:

1. Tangent comparison not like-for-like. See "Fix first". Obtain `w_tan_data`
   from the same `MyMarkowitzRiskyRiskFreePortfolioChoiceProblem` solve,
   normalized (matches the grid's Sharpe ratio 0.0809, deletes about 15 lines),
   and show one table of β_p, E[g], σ, and both Sharpe ratios with each
   portfolio scored under Σ̂_g.
2. Structure (cells 0, 13, 18, 27): one- or two-sentence overview below the
   objectives; "In this task, …" openers; replace cell 18's 190-word derivation
   with "As derived in the lecture (SIM-3), every solution is (1−w_f) w_T.";
   add `###` subsections.
3. Stale references and ticker-tied prose: cells 11, 14, 16, 22, 23, 27, 33
   attribute the tangent, complete-portfolio formulas, or borrowing idealization
   to L6a, which no longer has tangent or CAL content. Cells 24, 33 and
   takeaways 2–3 depend on default tickers ("three high-growth technology
   names", "about 1.3 annualized", "grew well below its estimate"). Make them
   generic, add the reminder, and use the "We solved… We compared…" voice. Cut
   the denial "None of this is a recommendation for any w_f" (cell 33).
4. Code (cells 19, 21, 23, 25): build `frontier_sim_df` once by porting approved
   L6a cell 32 with SIM inputs; one statement per line; explain
   `err isa AssertionError || rethrow()`, `SR > best.SR && (…)`, and `.+ 0.0`.
5. Setup, links, tables (cells 1, 3, 16, 21–25): cell 3 omits Random,
   Distributions, CSV, StatsPlots, which Include.jl loads (use the L4b line);
   link `log_growth_matrix`, `MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem`,
   and `JLD2.load`; replace `println` outputs in cells 19, 21, 23 with tables.

Reuse: 2025 (L8b) is not a usable base (market moments from the 2025 test data,
inconsistent Δt in the covariance and residual variance, off-by-one indexing in
the θ≈1 search in cells 49, 53). Restore its tangent composition table with α,
β, g, w and a total row (cell 51), its question lead-ins ("What's in the tangent
portfolio?", "What's the Sharpe ratio…?", cells 50, 52, 54), and a condensed
try/catch explanation (cell 37). From eCornell, its "Sharpe Ratio Units"
callout and θ table (cell 19) as models, no code. The target largely duplicates
the advanced data risk-free notebook, rewritten denser with comments stripped
(data cells 5 and 7 identical; same grid tangent 0.2013/0.1254/0.6733; cell 32
is its cell 60 plus two columns). Reuse that notebook's frontier sweep, argmax
(43), comparison tables (47/49), and CAL plot (51, without the label-dodging
loop) with SIM inputs, and the wealth and realized-return code in the approved
L6a versions (cells 43, 45, 49). Keep from 2026: archive load and asserts (9),
SIM inputs (16), risky and risk-free sweep (19), ray check (first half of 21),
CAL figure with solver points (25), w_f wealth formula and code (27–28),
modeled-versus-realized scorecard (32), risk-scaling reading (33, made generic).

Recommendation: hybrid with tasks (1) SIM and data inputs; (2) sweep, ray
check, what is in the tangent portfolio, CAL plot; (3) complete-portfolio
wealth, modeled versus realized. About 110–120 lines become reviewed code with
variable swaps, leaving about 60 new lines; prose drops to about 1,300 words.

## Suggested order for September 28

1. Regenerate the SIM parameter archive from the estimation example and commit
   it; decide on the week-7 copies.
2. Bootstrap example (cheapest; about 10 cells; target about 8.5).
3. Estimation example prose rewrite.
4. RA and RRFA hybrids together, since both port the same L6a code.

Working agreement from the style guide and saved preferences: exactly three
tasks with "In this task, …" openers; three objectives and three takeaways
without equations or semicolons; derivations stay in the lecture; keep bold
question callouts; figure interpretations simple or absent; fixes should not
grow the prose; show proposals as rendered before/after PNGs; Codex-check every
edit; re-execute after code edits; back up before the instructor hand-edits.

## Notes for rerunning

To execute an example outside the repository (the estimation example rewrites
the archive), copy `Project.toml`, `Manifest.toml`, **and `code/`** (the
Manifest resolves the course package at `path = "code"`) next to a copy of
`lectures/week-6/L6b/`, then run nbconvert with
`--ExecutePreprocessor.kernel_name=julia-1.12`. The September 27 executed
copies were written to a session scratch directory and may not persist.
