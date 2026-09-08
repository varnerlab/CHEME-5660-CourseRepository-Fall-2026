# Week 4 Notebook Issues to Clean

Reviewed 2026-09-07 and updated 2026-09-08. Cell numbers in the original audit are zero-based; later edits changed some cell positions.

Status: all tracked issues below have been addressed. The final verification record appears at the end of this file.

## Scope and verification

- Reviewed all 13 notebooks under `lectures/week-4` for narrative flow, mathematical correctness, notebook structure, and the Cornell Julia commenting style.
- Performed three independent GPT-6 review passes focused on pedagogy, correctness, and structural conventions.
- Freshly executed all 148 code cells in the 10 executable notebooks using Julia 1.12.7. All cells completed successfully.
- Rendered both lecture notebooks to HTML and inspected their heading hierarchy, blockquotes, lists, image markup, and displayed mathematics using the artifact-aware Cornell lecture rules.
- Read the canonical CHEME 5820 Hopfield-network lecture as a lecture-mode reference. Its developed prose and mathematical callouts are useful patterns; its surface formatting should not be copied mechanically.
- Checked the relevant N-ary indexing implementation in `code/src/Trees.jl`, the local lattice builder in `L4a/src/Split.jl`, the single-asset GBM sampler in `code/src/Compute.jl`, and the opening of L5a. The N-ary formulas and exact GBM transition agree with the lecture narrative, and L4b's transition to multiple correlated assets correctly anticipates L5a.
- No notebook or implementation file was changed during the review.

## Repository-wide required cleanup

### Horizontal rules

- [x] Remove the trailing `___` from the final cell of every one of the 13 notebooks. A horizontal rule may appear only at a major-section boundary immediately before a new `##` heading; it must not appear after the final section.
- [x] In `L4b/CHEME-5660-L4b-GBM-Solution-Derivation-Fall-2026.ipynb`, remove the rule at the end of cell 0 or add a genuine `##` heading to the introductory prose in cell 1. The rule currently does not immediately precede an H2.

### Objective and takeaway counts

- [x] Every lecture and example notebook contains exactly three learning objectives. Compact advanced notes are intentionally exempt from lecture/example mode.
- [x] Every lecture and example notebook contains exactly three key takeaways. Compact advanced notes are intentionally exempt from lecture/example mode.
- [x] Tighten the unusually long objectives and takeaways in the L4b lecture. The second takeaway in cell 10 is roughly 100 words and reads like another derivation rather than a concise takeaway.

### Benchmark-rate notation and semantic symbol definitions

- [x] Replace the locally introduced benchmark-rate symbol `g_b` with the established course notation `g_y`, the continuously compounded annual rate associated with the selected benchmark yield `y`. Apply the migration consistently to prose, equations, Julia code, saved outputs, and both slide decks.
- [x] Preserve the earlier L3b notation `R_f = exp(g_y*Delta t)` for the one-step risk-free accumulation factor instead of introducing a competing `R_b` symbol.
- [x] Rewrite the L4a terminal-target theorem assumptions so every symbol is assigned a mathematical role and, where relevant, units, index meaning, or probability complement; a bare list of domains is not an adequate definition.
- [x] Add the semantic-symbol requirement to the reusable Cornell notebook skill and validate the updated skill.

### Shared Julia setup files

- [x] Add compact package-purpose comments to active `using` statements in the eight week-4 `Include.jl` files. For example, use `using DataFrames # labeled tabular data` rather than leaving the import unexplained.
- [x] Remove comments that narrate obvious syntax, such as `what is this doing?`, `we get each (K,V) pair`, and similar mechanical paraphrases. Prefer intent, units, array shapes, financial sign conventions, and Julia-versus-mathematical index mappings.

## Verified mathematical and interpretive corrections

### Anderson-Darling calibration and p-value interpretation

File: `L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb`, original cells 21 and 41-43.

- [x] Replace the claim that fitting the normal distribution to the tested observations makes the standard Anderson-Darling test "slightly too eager to reject." The installed `HypothesisTests.OneSampleADTest` uses a fully specified-distribution calibration and does not adjust for parameter estimation. Fitting the same data ordinarily makes this use conservative, not eager to reject.
- [x] Explain that fitting parameters changes the null calibration and that a fitted-normal test or parametric bootstrap is needed. Dependence among the regression residuals invalidates the calibration separately.
- [x] Replace the TLDR statement that a small p-value means the null hypothesis is unlikely to be true. A small p-value is evidence against the specified null model under the test assumptions; it is not the posterior probability that the null is true.
- [x] Apply the fitted-normal parametric bootstrap to the primary one-step growth-rate check as well as correcting the residual discussion. Each bootstrap replicate refits the normal parameters before its Anderson-Darling statistic is compared with the observed statistic.

Verification: in 5,000 simulated samples of 100 iid standard-normal observations at a nominal 5% level, the known-`Normal()` test rejected 4.94%, whereas testing against `fit_mle(Normal, x)` with the same unadjusted method rejected 0%.

### Brownian regression residual variance

Files:

- `L4b/CHEME-5660-L4b-Lecture-SingleAsset-GeometricBrownianMotion-TradeRule-Fall-2026.ipynb`, cell 5.
- `L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb`, cell 23.

- [x] Replace the claim that fitted log-price regression residuals inherit Brownian variance that grows monotonically along the sample. Raw Brownian errors have covariance `C[i,j] = sigma^2 min(t_i,t_j)`, but fitting the intercept and slope projects them through `Q = I - X(X'X)^(-1)X'`. The residuals remain dependent and generally heteroskedastic, but their variance need not increase monotonically.

Verification: for 101 equally spaced points on `[0,1]` with unit volatility, the fitted-residual variances are approximately 0.12877 at both endpoints, 0.04981 at the quarter point, and 0.08416 at the midpoint.

### Strict lattice-target domain and floating-point boundary

Files:

- `L4a/CHEME-5660-L4a-Lecture-LatticeModel-TradeRule-Fall-2026.ipynb`, cell 5.
- `L4a/CHEME-5660-L4a-Example-CumulativeProbabilityLattice-Fall-2026.ipynb`, cells 36 and 42.
- Related threshold helpers in the execution-aware and lattice-limit notebooks.

- [x] State the domain `rho_star > -1` before taking `log(1 + rho_star)`.
- [x] Handle `rho_star <= -1` explicitly. For a frictionless positive-price model, the strict event is certain, but the current code attempts either `floor(Int, -Inf)` or the logarithm of a negative number.
- [x] Make the strict inequality robust at an exactly attainable lattice node. Floating-point evaluation can move an integer-valued threshold just below the integer and include the equality node incorrectly.
- [x] Preserve the domain distinction: `rho_star <= -1` makes the frictionless positive-price event certain, while execution-aware helpers require `rho_star > -1` because fees can make normalized profit fall below `-1`.

Verification: with `u=1.015`, `d=0.99`, `N=20`, `g_y=0`, and `rho_star=u^3*d^17-1`, the computed continuous threshold is `2.9999999999999996`. `floor(...) + 1` therefore gives 3, although a strict event requires 4, overcounting probability by approximately 0.000611 when `p=0.52`.

### Lattice-to-GBM convergence curve

File: `L4b/advanced/lattice-limit/CHEME-5660-L4b-Advanced-LatticeToGBM-Fall-2026.ipynb`, cells 1 and 21.

- [x] Call the plotted `C/sqrt(N)` curve an empirical reference envelope for the displayed step counts, not "a bound rather than a fit." Its coefficient is selected from those displayed observations and is not a theoretical global bound.
- [x] Do not attribute an `N^(-1/2)` error rate to the central limit theorem alone. A quantitative rate requires a Berry-Esseen-type result and qualifications about the discontinuous tail event and integer threshold.
- [x] In cell 1, clarify that the stated second-order variance error applies to the one-step log return, not to the annualized growth-rate variable.

Verification: the displayed points give `C = 0.3846129491`, but at the unplotted value `N=68`, the actual error is `0.0486286492`, exceeding `C/sqrt(68) = 0.0466411710`. There are 268 such violations for `N=4,...,10000`.

### Competing first-passage exits

File: `L4b/advanced/first-passage/CHEME-5660-L4b-Advanced-FirstPassage-GBM-Fall-2026.ipynb`, cell 17.

- [x] Qualify the statement that more frequent monitoring increases the probability of exiting through both barriers. That occurs for the displayed calibration, but only the probability of any detected exit is generally monotone under nested monitoring grids. Earlier detection at one barrier can remove paths that would otherwise later reach the competing barrier.

Verification counterexample: with `S0=100`, `L=99`, `U=110`, `mu=0.15`, `sigma=0.30`, and `T=0.25`, one terminal check gives a take-profit probability of approximately 0.322614, while the continuously monitored take-profit probability is no larger than its infinite-horizon value of approximately 0.106344 because the nearby stop absorbs many paths first.

### Monte Carlo terminology

File: `L4b/advanced/monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb`, cells 16-18.

- [x] Rename or qualify the `bias` column. It is one realized Monte Carlo error and contains both discretization bias and sampling noise.
- [x] Soften the statement that both monthly and weekly errors are two to three standard errors. In the saved deterministic run, the weekly error is about 1.6 standard errors.

The saved output showing one negative Euler terminal price for the semiannual grid is consistent with the seeded simulation and is not an error.

## Notebook-specific cleanup

### L4a cumulative-probability example

File: `L4a/CHEME-5660-L4a-Example-CumulativeProbabilityLattice-Fall-2026.ipynb`.

- [x] Cells 21-22 and 29-30 retain `TODO: Uncomment...` instructions even though the corresponding lines are active.
- [x] Replace references to a "random firm" in cells 18-30 because the example fixes `random_firm_ticker = "ADBE"` for reproducibility.
- [x] Cell 4 calls `original_dataset` a `DataFrame`; it is a ticker-to-`DataFrame` dictionary.
- [x] Cell 19 describes the matrix overload while cell 20 calls the single-firm vector overload. Describe the overload actually used.
- [x] Apply the strict-target domain and floating-point boundary corrections listed above.

### L4a N-ary lattice example and helper

Files:

- `L4a/CHEME-5660-L4a-Example-N-Ary-Lattice-Fall-2026.ipynb`.
- `L4a/src/Split.jl`.

- [x] Cell 4 calls `original_dataset` a `DataFrame`; it is a ticker-to-`DataFrame` dictionary.
- [x] Explain the zero-based flat node identifiers versus Julia's one-based array positions near the node-index calculations in cells 15, 43, and 45.
- [x] Decide how `build_nary_lattice_from_growth_rate` should handle empty equal-width bins. It currently returns `NaN` average factors with zero probabilities; increasing the advertised branch count can therefore create undefined node prices and plots.
- [x] Correct `N-Aray` to `N-Ary` in the filename and inbound notebook/slide links.

### L4b GBM-NPV example

File: `L4b/CHEME-5660-L4b-Example-GBM-NPV-TradeRule-Fall-2026.ipynb`.

- [x] Cell 4 calls `original_dataset` a `DataFrame`; it is a ticker-to-`DataFrame` dictionary.
- [x] Cell 27 says to `Unhide` the following code cell, but cell 28 has no hidden-source metadata.
- [x] Shorten the first takeaway in cell 30.

### L4b parameter-estimation example

File: `L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb`.

- [x] Cell 4 calls `original_dataset` a `DataFrame`; it is a ticker-to-`DataFrame` dictionary.
- [x] Correct the Anderson-Darling and fitted-residual explanations described above.
- [x] Consider making increment-based estimates the primary workflow and moving the long residual-normality, iid-resampling, and descriptive-regression-interval detour in cells 18-36 to advanced material. The detour delays volatility estimation and spends substantial time on methods the notebook later says are not calibrated for GBM.
- [x] Cells 28 and 62 say to `Unhide` the following code cells, but cells 29 and 63 have no hidden-source metadata.
- [x] Remove the comment `new table API. Hmmm` in cell 35 and replace it with an intent-focused comment if explanation is needed.
- [x] Phrase numerical observations that depend on unseeded firm/window selection conditionally or fix the demonstration seed and selected firm.

### L4b GBM derivation

File: `L4b/CHEME-5660-L4b-GBM-Solution-Derivation-Fall-2026.ipynb`.

- [x] Fix the extra horizontal rule after cell 0 and the trailing rule after cell 4.
- [x] Treat this as an advanced derivation/example notebook rather than forcing the full lecture-mode structure; its compact proof-oriented rhythm is appropriate.

### Advanced L4a notebooks

Files:

- `L4a/advanced/execution/CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb`.
- `L4a/advanced/first-passage/CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb`.

- [x] Add compact teaching comments around non-obvious logic. The execution notebook needs clearer units, basis-point conversion, fee timing/sign conventions, and normalization by initial outlay in cells 6, 8, and 12.
- [x] Explain surviving probability mass, absorption, and the `k+1` Julia array mapping in the first-passage recursion in cell 8.

### Drift-uncertainty advanced notebook

File: `L4b/advanced/drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb`, cell 14.

- [x] Refresh the saved output. The source prints regression half-widths of approximately `+/-0.0007` to `+/-0.013` per year, most near `+/-0.002`, while the saved stdout still says `+/-0.001` to `+/-0.005`.

## Artifact-aware lecture review

The artifact-aware CHEME 4/5800 lecture rules are suitable for both week-4 lecture notebooks. They are lecture artifacts whose primary job is to build a connected conceptual model. The rules should therefore govern their prose rhythm, heading hierarchy, developed mathematical callouts, transitions, and rendered presentation. They should not be applied mechanically to the code-forward examples or to the short GBM derivation notebook.

### L4a lecture: Trading Rules Using Binomial Lattice Models

File: `L4a/CHEME-5660-L4a-Lecture-LatticeModel-TradeRule-Fall-2026.ipynb`.

What already works:

- [x] The lecture has a cumulative conceptual arc: market/lattice review, NPV formulation, strict terminal target, terminal-versus-first-passage distinction, N-ary generalization, and synthesis.
- [x] The three objectives align with the developed sections and the three takeaways.
- [x] The short/long-horizon distinction motivates the benchmark discount factor, and the strict-target derivation defines most notation near first use.
- [x] The N-ary node-count and flat-array offset formulas agree with the implementation in `code/src/Trees.jl`.
- [x] The links to the examples and advanced notebooks form a sensible path through the material.

Artifact-aware cleanup:

- [x] Convert the example links in cell 1 from blockquotes to a normal list or short prose. These are navigation items, not conceptual callouts.
- [x] Tighten cell 2. The stock/exchange/ETF/mutual-fund/order survey is broader than the machinery needed for the trade-rule lecture. Preserve only the market facts that motivate prices, execution, and the later execution-aware extension.
- [x] Convert the one-paragraph `### Company Profile: Citadel Securities` microsection into a run-in label or a brief motivating paragraph. Add an explicit transition from market making and executable prices to the idealized lattice price used next.
- [x] Consolidate the short `Binomial Lattice Model` and `Key assumptions` blockquotes in cell 3 into one developed callout containing the object, assumptions, terminal distribution, notation, and modeling implication. The central distribution equations should sit with the definition they organize.
- [x] Reduce repetition in cell 4. The full NPV identity is derived before the short/long subsections and then repeated in the long-horizon subsection. Derive the exact identity once, then present the short-horizon approximation as a clearly qualified consequence.
- [x] Put the ordinary scenario and transitional prose in normal paragraphs. Reserve a developed blockquote for the exact scaled-NPV result and its interpretation.
- [x] In cell 5, develop the strict-target result as one coherent mathematical callout: define `rho_star > -1`, derive `tau`, define the strict integer threshold, give the binomial tail, state feasible edge cases, and end with the decision implication. The current definition, equations, edge-case quote, and example quote fragment one central idea.
- [x] Keep `## Terminal Rules and First-Passage Rules Are Different` because it serves the second learning objective, but strengthen it into a developed comparison. Define the monitored event/state explicitly and link the first-passage advanced notebook here rather than waiting until the optional-material index.
- [x] Replace the generic `Idea` and `Example` blockquotes in the N-ary section with one concrete developed callout explaining branch counts, stars-and-bars storage, node probability, and the computational implication. Keep the example link in normal prose.
- [x] Add alternative text to the exchange schematic in cell 2. HTML rendering reported exactly one missing image description, and this is the image without an `alt` attribute.
- [x] Remove the trailing rule from the disclaimer cell.

Rendered impression: the heading hierarchy is understandable, but 14 blockquotes produce a repeated callout cadence. Consolidating the central mathematical ideas and returning navigation/scenarios to normal prose will make the lecture read more like a connected explanation and less like a sequence of cards.

### L4b lecture: Single Asset Geometric Brownian Motion Models

File: `L4b/CHEME-5660-L4b-Lecture-SingleAsset-GeometricBrownianMotion-TradeRule-Fall-2026.ipynb`.

What already works:

- [x] Once the GBM section begins, the conceptual progression is strong: continuous model, Wiener process, exact solution, grid transition, Monte Carlo, parameter estimation, model criticism, and target probability.
- [x] The exact GBM transition, drift/growth distinction, volatility scaling, lognormal moments, and target standardization agree with the implementation and the freshly executed examples.
- [x] The stylized-facts section makes model criticism part of the modeling workflow rather than presenting GBM as ground truth.
- [x] The final transition to correlated multiple-asset GBM accurately anticipates L5a.

Artifact-aware cleanup:

- [x] Remove or radically shorten `## Company Profile: Jane Street` in cell 2. A standalone employer comparison is not a major conceptual stage in the GBM teaching flow. The dated market-share/headcount claims add maintenance burden, and the broad culture comparisons are subjective.
- [x] Remove the `Which should I choose (GPT-5 Thinking)` blockquote. It is an AI-attributed career-opinion box, not a definition, theorem, mathematical comparison, or substantive synthesis, and it interrupts the lecture's authority and flow.
- [x] Either fold `## Concept Review: N-Ary Tree Models` into the GBM motivation or develop it into the actual limiting bridge. Its current generic `Idea`, linked-example quote, and repeated `Wow!` prose make a short standalone H2 feel disconnected from the mathematical development.
- [x] Convert the example links in cell 1 and the later `Example` boxes to normal prose or lists.
- [x] Preserve the Wiener-process blockquote as a central definition, but consolidate other short callouts. The rendered notebook contains 18 blockquotes, including generic `Idea`, `Scenario`, `Parameters`, and three separate stylized-fact conclusions.
- [x] Turn the three stylized-fact verdicts into one developed comparison callout. State the empirical feature, the GBM implication, the supporting distribution/autocovariance result, and the modeling consequence together.
- [x] Promote `#### Linear Regression` in cell 5 to a `###` peer within parameter estimation, or integrate it as a run-in topic under drift. A fourth heading level is unnecessary for this lecture and weakens scanability.
- [x] Correct the fitted-residual variance claim in cell 5 as specified above.
- [x] Tighten the three learning objectives. They satisfy the count rule but bundle many separate outcomes into each bullet.
- [x] Shorten the key takeaways, especially the second takeaway in cell 10. Retain the central distinctions without re-deriving the full estimator chain.
- [x] Evaluate the long GBM and estimation cells at rendered-artifact level. Keep the mathematical sequences intact where splitting would fragment a derivation; use the sharpened H2/H3 hierarchy and consolidated callouts to supply the needed scan points.
- [x] Remove the trailing rule from the disclaimer cell.

Rendered impression: the mathematical hierarchy is clear and the equations render correctly, but the lecture opens with two detours before reaching GBM and then presents long uninterrupted prose/equation stretches. Removing the employer comparison, reducing generic blockquotes, and sharpening the estimator/stylized-fact callouts would make the lecture substantially more focused without changing its technical scope.

## Suggested cleanup order

1. Correct the mathematical statements: Anderson-Darling calibration, p-value interpretation, fitted-residual variance, strict lattice thresholds, the empirical convergence envelope, and the competing-barrier monitoring claim.
2. Fix repository invariants: trailing horizontal rules, the extra GBM-derivation rule, stale output, stale `TODO`/`Unhide` instructions, and incorrect dataset types.
3. Reshape the two lecture notebooks using the artifact-aware rules, preserving their current conceptual scope and exactly three objectives/takeaways.
4. Improve code comments and helper robustness, especially the L4a advanced recursions, `Include.jl` imports, and empty N-ary bins.
5. Re-run all executable notebooks, render both lectures to HTML, and verify JSON validity, headings, blockquotes, equations, links, outputs, execution counts, and metadata.

## Final verification record

- Two independent GPT-6 pre-fix audits verified the mathematical, computational, and artifact findings and refined the edge cases before editing.
- All 10 executable notebooks were run in fresh Julia 1.12 processes and then executed in Jupyter to refresh their saved artifacts: 148 code cells have sequential execution counts and no saved errors.
- Targeted Julia regression checks passed for exact-node and adjacent-target strict inequalities, frictionless and execution-aware target domains, fee-aware threshold agreement, fitted-normal bootstrap reproducibility, projected Brownian residual covariance, and empty equal-width/tied-quantile N-ary bins.
- All 13 notebooks parse as JSON, have one H1, exactly three learning objectives and three key takeaways, and no H4 headings. Every `___` has the required blank-line spacing, renders as an HTML horizontal rule, immediately precedes a new H2, and is absent after the final section.
- All 13 notebooks were rendered to HTML. Both lecture notebooks have valid H2/H3 hierarchies, intact mathematical callouts, purposeful blockquotes, valid local links, and complete descriptions for their authored images.
- The N-ary notebook and every inbound notebook/slide reference now use `N-Ary`. Both slide decks rebuilt successfully, and their PDFs were text-checked for the corrected filename.
- The benchmark-rate migration was checked across all week-4 notebook and slide sources: no active `g_b`, `g_{b}`, or `R_b` references remain. The six affected executable notebooks ran successfully, both slide decks rebuilt, and all slide pages were visually inspected after rendering.
- The reusable Cornell skill passes its validator after adding the semantic-symbol audit rule.
- Two independent GPT-6 post-fix audits re-ran the mathematical/code and artifact/style checks after the final corrections. Both returned clean verdicts with no remaining issues.
- `git diff --check` passes.
