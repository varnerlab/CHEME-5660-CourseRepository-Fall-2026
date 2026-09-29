# L6b advanced estimation risk — polish round record

Notebook: [CHEME-5660-L6b-Advanced-EstimationRisk-Fall-2026.ipynb](../week-6/L6b/advanced/estimation-risk/CHEME-5660-L6b-Advanced-EstimationRisk-Fall-2026.ipynb)

Polish, voice, and organization round on September 28, 2026. It ran section
by section with rendered before/after previews. The instructor accepted all six
steps, two after corrections, and marked the notebook reviewed the same day.
The changes are uncommitted, part of the deferred L6b commit.

This notebook was reviewed as an L5b advanced example on September 17, 2026
(9.2/10, [record](L5b-ADVANCED-ESTIMATION-REVIEW-HANDOFF.md)) and moved to
L6b when the advanced material was cut to two notebooks. That review predates
the density, no-denial, and no-semicolon rules and the L6b lecture's SIM-3
result. The opening assessment here judged it against the current standard.

## Scores

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 8.5 | 9.2 |
| Organization and sequencing | 6.5 | 9.0 |
| Narrative and interpretation | 7.5 | 9.0 |
| Presentation | 8.0 | 9.0 |
| Density and pacing | 5.5 | 8.5 |
| **Overall** | **7.0** | **9.0** |

Prose went from 3,830 to 2,669 words, counting the disclaimer and excluding
display math and link targets. The reviewed L6b siblings run 1,740 to 2,290.
The remaining excess is mostly Task 2, which carries five results.

## Decisions taken at the opening assessment

The instructor accepted all three recommendations:

- **Move the methods into the tasks.** The input estimation, four weight rules,
  and a results table had sat in "Setup, Data, and Prerequisites", about 1,500
  words before Task 1.
- **Use the lecture's exact long-only tangent method.** One solve of the
  risky and risk-free problem, rescaled to sum to one (SIM-3), as in the RRFA
  example, replaced a 31-point frontier grid. Measured first: the grid's
  largest weight difference was 0.022 at baseline, with a median of 0.009 and a
  maximum of 0.05 across the 100 resamples. The exact Sharpe ratio was never lower.
- **Target the sibling range.** The target was 2,000 to 2,300 words, about a
  45% cut.

## Accepted steps

1. **Opening, setup, data.** The introduction now starts from the L6b examples
   and asks which input moves the weights, since the SIM keeps the sample means.
   The objectives are in the RRFA register, the overview moved below them,
   and the task itinerary was cut. Data follows the lean RA/RRFA shape. The two
   growth and 2025-price subsections merged. Instructor correction: "Intro to
   the LOs can be tightened up a bit." The accepted version is 63 → 47 words, with
   the portfolio names left to the objectives and GMV spelled out in objective 2.
2. **Task 1, Estimate the Inputs and Their Uncertainty.** The point estimates
   moved in from Setup. The bootstrap loop stores only resampled means and
   covariances. The σ_g versus se_σ_g distinction moved into the table lead-in.
   The reading is a `__What do we see?__`, and the Merton citation now states
   its point: mean precision depends on history length, not sampling frequency.
   Instructor correction: "The estimate standard errors section needs a
   linebreak to break up the text block." The standard-error definition became
   its own paragraph.
3. **Task 2, Compare the Frontiers and Portfolio Weights.**
   - The two weight-rule subsections became "Four portfolio rules". The
     long-only problem display, Sharpe display, and grid paragraph were
     replaced by references to L6a's long-only problem and L6b's SIM-3.
   - The unused baseline mean/σ table (three cells) was cut.
   - The frontier reading gives the mechanism: 1/a depends only on the
     covariance, while b and c bring in the means.
   - Box plots and the D_b table share "How much do the weights move?".
   - The κ check and one-input experiment merged under "Why do the
     closed-form tangent weights move so much?". The section ends with the L6b
     answer: the SIM keeps the sample means, so the main source of instability remains.
4. **Task 3, Compare Wealth on the 2025 Prices.**
   - All five displays and the boxed compounding result are unchanged, as
     requested on September 17.
   - "Not a forecast interval" is now said once, in the figure reading.
   - The baseline table gained its first reading: equal weights finished above
     the 95th percentile of both rules, with more risk than GMV.
   - A DeMiguel, Garlappi, and Uppal (2009) citation was drafted, then
     dropped for length. The DOI 10.1093/rfs/hhm075 is verified if wanted later.
5. **Summary.** The opener has two full sentences. The key takeaways are
   short claims of two sentences each. The closer is "We can now change…" plus
   the L6b payoff.
6. **Closing Codex fixes, word count +18.**
   - Takeaway 2 had said a "small or negative normalizer magnified" the moves.
     It now says "normalizers near zero".
   - The κ ≤ 0 rows are now κ < 0 in the lead-in, table, and reading. κ = 0
     raises an error, so all 15 of those resamples are negative.
   - S_k^(i) is now defined as a price, and "every rule's weights sum to one" is back.
   - The x/κ display has κ ≠ 0 again, and the Merton sentence starts
     "Under GBM,".
   - The standard error is compared with the absolute value of the mean,
     and "a small |κ| can give" replaces "gives".
   - Sixteen code comments lost their clause semicolons.

## Code and support-file changes

- `src/EstimationRisk.jl`: `tangent_long_only(g, Σ, g_f)` builds
  `MyMarkowitzRiskyRiskFreePortfolioChoiceProblem` at the target
  `(g_f + maximum(g))/2`, asserts that no weight reaches its upper bound, and
  returns `w / sum(w)`. The `number_of_points` keyword is gone. The docstring
  and `docs/estimation-risk.md` describe it. The docs page's back-link now
  points to the L6b filename instead of the old L5b one.
- The notebook has a new `weights` cell at the start of Task 2, with fields
  `gmv_closed`, `tan_closed`, `gmv_long_only`, and `tan_long_only`. Later cells
  read these instead of the `boot` fields. The "grid" labels are gone from
  tables and figures, and the κ table counts `κ .< 0`.

## Verification

- The restructured notebook reproduced every stored output except the
  long-only tangent rows. Standard errors, frontiers, closed-form and GMV
  dispersion, normalizer counts, the one-input table, and GMV, equal-weight,
  and SPY wealth all matched. So the resampled draws are unchanged. The tangent
  changes were: baseline mean 0.4272 → 0.4339, distances 0.572/0.533 →
  0.573/0.537, resampled terminal ratios [1.213, 1.440] → [1.215, 1.437], and
  the training fit 1.288 → 1.293. Every written claim held.
- The terminal-wealth figure still fits its fixed 1.1 to 1.6 axis, with ratios
  of about 1.14 to 1.50.
- The final saved notebook came from a clean nbconvert run: no errors,
  execution counts 1–27, and outputs identical to the verified run except the
  κ label. The dimension check now prints 2,766, 13, and 250. Its output had been
  missing before.
- Structure checks passed: 3 objectives, 3 tasks, 3 takeaways, `___` only
  before `##`, and none after the Disclaimer. All local links and docs
  anchors resolve. There are no clause semicolons, em dashes, or "grid"
  wording in the notebook, source, or docs.
- Codex checked every rewritten cell against the code and stored outputs, with
  SymPy and NumPy. It covered the frontier identity, the κ sign, SE = σ/√T under
  GBM, and the exactness of the new tangent helper, checked against active-set
  and brute-force searches. Its correctness findings are step 6. Its
  sentence-splitting suggestions, and its requests to restore VWAP, whisker, and
  median-feasibility text, were declined.

## Remaining limitations

- The notebook is about 370 words above the sibling range, mostly in Task 2.
  Cutting further would reopen approved sections.
- Objective 2 says "tangent portfolios for every resample", although 15
  closed-form allocations are minimum-Sharpe. Task 2 explains this.
- Independent-day resampling, B = 100, and one 2025 price history remain as
  stated in the notebook. Classroom pacing through Task 2 is untested.
- The lecture description, `advanced/README.md`, the RRFA closing link, and
  the diagnostics closing link still describe the notebook accurately. The
  slide frame was not touched.

## Saved state

Notebook SHA-256 at marking:
`f3a58749c0ba7deb89ba7936d06447749f94075cf31b29d7e0b05fecdbfd76ef`

Previews and the `p1.py`–`p6.py` patch scripts are in the ignored
`build/notebook-previews/estrisk/` folder. The rendered steps are
`build/notebook-previews/estrisk-p*.png`.
