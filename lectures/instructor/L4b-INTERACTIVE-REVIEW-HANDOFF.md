# L4b review state — updated September 12, 2026

## Standard-error slide density follow-up — September 12, 2026

The instructor found slide 18 too dense after the general tightening pass.
Shortened its prose further, retaining the comparison with Brownian errors,
independent normal/common-variance assumptions, observation and parameter counts,
residual and variance formulas, degrees of freedom, standard-error formula,
and the direct uncertainty/precision/units interpretation. Restored the normal
equation spacing by removing the slide's compressed display-skip override,
and separated the assumptions from the calculation. Body font size is unchanged.
The updated 28-page PDF was rebuilt and the slide visually checked.

## Post-review tightening — September 12, 2026

After approving the slides, the instructor requested about a 5% prose reduction.
This pass removed repeated setup wording and modestly shortened explanations
across 22 slides. The reduction is approximately 4.7% of body prose, excluding
the title/disclaimer and mathematics. It preserves the approved teaching choices,
all 27 display equations, all inline mathematics and link targets, the complete
Monte Carlo pseudocode, slide order, and three objectives/three takeaways.
The disclaimer and final summary are unchanged in this tightening pass.
The 28-page PDF was rebuilt, and every edited slide was visually checked with
no clipping or overlap. The build has no overfull/underfull warnings.
No notebook, slide theme, or font-size changes were made.

## New interactive slide review — September 12, 2026

The instructor requested a new, one-issue-at-a-time slide review and reusable
evaluation rules based on approved decisions. This interactive pass is now
complete through slide 28, with all approved changes applied. No slide proposals
remain pending. The earlier completed review below is a historical checkpoint.
Agreed review rules are saved in NOTEBOOK-STYLE-GUIDE.md under **Slide review
rules agreed during interactive review**. No commit or push was made.

- Slide 3, **Objectives for Today**, is approved and updated. It uses the
  notebook's three learning outcomes in concise action statements, includes
  log-price regression, and uses the established term "target scaled NPV."
  The repeated introductory agenda and "Today's concepts" label are removed.
- The approved learning-objective rule is saved under **Slide review rules
  agreed during interactive review** in NOTEBOOK-STYLE-GUIDE.md.
- Slide 4 example-description terminology is approved and updated: "mean
  growth rate," "simulated price paths," and "target scaled NPV at a scheduled
  sale time." The terminology rule is saved in NOTEBOOK-STYLE-GUIDE.md.
- Slide 5's closing transition is approved and updated: a trade's outcome
  depends on price changes before the sale, motivating GBM and the probability
  of exceeding a target scaled NPV. The transition rule is saved in the guide.
- Slide 6's second bullet is approved and updated: shrink the up and down
  price movements and adjust their probabilities so the mean and variance of
  the holding-period log return remain approximately unchanged. The guide now
  records the rule to state what changes and what remains fixed in a limit.
- Slide 7's variable definitions are approved and updated with share-price
  units, holding period, and time units. The instructor requested "drift"
  rather than "arithmetic drift" here. The model-definition rule is saved in
  the guide; this does not authorize a global terminology replacement.
- Slide 8's Wiener-process definition needs no proposed change.
- Slide 9 retains its approved "mean log growth" underbrace. The instructor
  prefers growth terminology and rejected "mean log return" and the longer
  "mean growth rate × time." The guide records that mean log growth is the
  accumulated quantity, while mean growth rate is mu_g = mu - sigma^2/2,
  distinct from drift mu. No slide edit or PDF rebuild was needed for this
  decision.
- Slides 10–12 (price moments, exact discrete transition, and Monte Carlo
  pseudocode) need no proposed changes in this pass.
- Slide 13's opening is approved and updated to "continuously compounded
  growth rate" with units year^-1, explicitly linking to L3a. Its equation is
  unchanged. The PDF was rebuilt and slide 13 visually checked.
- Slide 14's volatility connection is approved and updated: hat(sigma) =
  sigma_g sqrt(Delta t) = sigma_ann, followed by a sentence identifying L3a's
  annualized volatility and its units. The rebuilt slide was visually checked.
- Slide 15's Method 2 bullet is approved and shortened to fitting log price
  as a line in time whose slope estimates mu_g. Slide 16 retains its full
  explanation of shared shocks, correlation, time-dependent variance, and
  relevance to uncertainty, and needs no proposed changes in this pass.
  The explanatory-sequence rule is saved in the guide.
- Slide 17's full-column-rank condition is approved and updated with the
  parenthetical "at least two distinct observation times." The rule to
  explain mathematical conditions concretely is saved in the guide. The
  rebuilt slide was visually checked.
- Slide 18's closing explanation is approved and updated: standard error
  measures estimated uncertainty in the fitted intercept or mean growth rate;
  smaller SE indicates greater precision; units match the parameter. The
  instructor found "repeated datasets" unclear, so the final prose avoids
  that formulation. The guide records the approved direct explanation instead
  of the earlier proposed uncertainty rule. Local equation spacing was reduced
  to preserve the full wording and body font size without footer overlap. The
  final build has no overfull/underfull warnings; slide 18 was visually checked.
- Slide 19's 95% confidence-interval example is approved and updated:
  alpha = 0.05 gives the multiplier t_(0.975, nu). The rebuilt slide was
  visually checked. Slide 20's heavy-tail comparison needs no proposed change.
- Slide 21's lag k and its observation-interval definition are approved and
  updated, preserving rho_g(k). The PDF was rebuilt and the slide visually
  checked. Slide 22's volatility-clustering explanation needs no proposed edit.
- Slide 23's g_y definition is approved and updated as a constant,
  continuously compounded benchmark growth rate corresponding to yield y.
  The instructor explicitly chose to keep the benchmark broad: it could be
  risk-free or an alternative such as SPY, using an assumed constant rate for
  the comparison. This decision is recorded in the guide. Do not narrow it to
  risk-free for consistency with L4a. The rebuilt slide was visually checked.
- Slide 24's explanation is approved and updated: discounting subtracts
  benchmark growth rate g_y from mean growth rate mu_g, leaving the random
  shock unchanged. The opening also says "mean growth rate." The rebuilt
  slide was visually checked.
- Slide 25's standardization instruction is approved and updated with the
  exact subtraction and divisor. The instructor requested "standard normal
  random variable Z" rather than "shock." Slide 26's CDF explanation now
  likewise names the events Z <= z_star and Z > z_star. The guide records this
  probability-threshold language. Both rebuilt slides were visually checked.
- Slide 27's Monte Carlo description is approved and updated to compare exact
  GBM and Euler–Maruyama simulation, quantify sampling uncertainty, and
  introduce variance reduction techniques. The instructor requested a general
  overview instead of Z/-Z details. The optional-example slide-description
  rule is saved in the guide, and the rebuilt slide was visually checked.
- Slide 28's final takeaway is approved and updated: "We used the GBM price
  distribution to calculate the probability of exceeding a target scaled NPV
  at the scheduled sale time, accounting for the holding period and benchmark
  growth rate." The guide records the retrospective method/result/purpose
  approach to slide takeaways.
- Final validation: the PDF has 28 pages, ending with Summary; exactly three
  objectives and three takeaways remain. Every edited slide was rendered and
  visually checked during the interactive pass, including the final summary.
  The final build has no overfull or underfull warnings, and the edited text
  files pass git diff --check. The extra closing slide remains commented out.
- The earlier nomenclature audit remains a set of proposals. Do not apply all
  of its recommendations without the instructor's approval during this review.

## Current status — lecture and slides complete September 12, 2026

This entry supersedes the historical checkpoint below. Jeffrey resumed the
review, approved the slide revisions and notebook alignment, and requested the
final check. The current notebook and companion deck are complete for this review.
No sections are awaiting approval. No commit or push was made.

- The notebook has 13 Markdown cells, including the added **Company Profile:
  Jane Street** after Examples and before From Lattices to Continuous Prices.
  It retains exactly three objectives and three takeaways. The profile addition
  preserved all twelve original cells and notebook metadata.
- The slides follow the notebook's core topic and worked-example sequence.
  The lattice introduction now matches the notebook, the parameter-example stop
  follows regression intervals, and the stylized-fact comparisons follow heavy
  tails, little linear autocorrelation, then volatility clustering.
- The current source disables the extra closing statement slide. The final PDF
  was rebuilt from that source and has **28 slides, ending with Summary**.
  The disclaimer remains slide 2 by the established slide convention.
- The mean/variance slide uses the approved **Properties:** lead-in and two
  bullets explaining expected price and variance, followed by the volatility
  comparison. Do not restore the rejected median/half-variance discussion there.
  The GBM introduction retains the Samuelson reference and BSM connection.
- The notebook is the live teaching document. Slides are students' concise
  note-taking companion, following the same topics and example stops. This
  confirmed workflow is saved in NOTEBOOK-STYLE-GUIDE.md.
- Validation: notebook schema, objective/takeaway counts, local links, topic
  sequence, and example placement checked. All 28 final slides were rendered and
  visually inspected; the build reports no overfull or underfull boxes. This was
  a prose/layout review; there was no numerical code to execute.

Notebook SHA-256: `97f8775a7116ee6060797549514d5f01074f936990b18a24b6eabf48b87225cd`.
Final PDF SHA-256: `a41b89ae7b380f4354bba85bdfee53b30e11e1bdff722f1a3bac3ae12b733170`.

Earlier references below to companion notebooks as unreviewed describe only the
September 11 checkpoint. Several companion reviews subsequently occurred; consult
the conversation and their own current review records before assigning status.

## Historical checkpoint — September 11, 2026

## Latest pause — September 11, 2026

Jeffrey has left and explicitly requested that state be saved. Stop work here.
The lecture review is finished; there is no pending approval or incomplete
lecture edit. On resumption, report this status and continue with the next task
he selects. The natural next review is the main parameter-estimation example,
then the trade-rule example, but that follow-up has not yet been requested.

Notebook SHA-256 at this checkpoint: `cfdbaa80b30bf792b4efbfec2941f5aea40ee448dab210abb8e8f65647509438`.
Re-read the notebook and working-tree status before editing if the hash differs.
The checkpoint has 12 Markdown cells, three learning objectives, three key
takeaways, and no code cells. All edits are saved locally; no commit or push.

Potential follow-up notebooks (not edited by this lecture review):

- `lectures/week-4/L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb`
- `lectures/week-4/L4b/CHEME-5660-L4b-Example-GBM-NPV-TradeRule-Fall-2026.ipynb`
- `lectures/week-4/L4b/CHEME-5660-L4b-GBM-Solution-Derivation-Fall-2026.ipynb`
- The four linked notebooks under `lectures/week-4/L4b/advanced/`.

Align mean-growth notation with $\mu_g$ during their own review; preserve
$\bar g$ for excess growth and $\mu$ for arithmetic drift. Their contents were
read for lecture-description accuracy, but their code was not executed.
Continue to distinguish mathematics/pseudocode in lectures from implementation
details in computational examples. Preserve the approved blockquote formatting,
including adjacent takeaway bullets without extra blank lines.

Other L4a work is happening in the same working tree, including a separate
`lectures/instructor/L4a-EXECUTION-REVIEW-HANDOFF.md`. Treat it as unrelated;
do not overwrite it, change its status, or stage its files with this work.

## Current status — complete September 11, 2026

The interactive review of the L4b lecture is complete. All approved changes,
including the final two wording cleanups, are saved in the working tree.
No commit or push was made. There are no pending lecture proposals.

Active notebook:
`lectures/week-4/L4b/CHEME-5660-L4b-Lecture-SingleAsset-GeometricBrownianMotion-TradeRule-Fall-2026.ipynb`

Read `NOTEBOOK-STYLE-GUIDE.md` and the decisions below before future work.
Do not restart or rewrite approved lecture sections without a new task.
The original pause was September 10; review resumed and finished September 11.

The final edits removed a repeated substitution transition and changed the
benchmark explanation to: “Discounting replaces $\mu_g$ with $\mu_g-g_y$ in
the growth term, while the uncertainty comes from the normally distributed
shock $Z$.” The Summary has exactly three adjacent takeaway bullets, with no
blank lines between them.

The companion examples and four advanced notebooks have not been edited in
this review. They retain the old mean-growth notation and should be aligned
with $\mu_g$ when their own review is requested. This is follow-up work outside
the completed lecture task, not a pending lecture edit.

## Linear-regression opening — approved and applied September 11

The old opening introduced regression diagnostics before developing the fitted
line. The approved replacement below was applied from
`### Linear Regression` through the paragraph preceding the matrix formulation:

### Linear Regression

Suppose we observe share prices $\{S_{t_0},S_{t_1},\ldots,S_{t_N}\}$ on the grid
$t_j=j\Delta t$. Taking the logarithm of the GBM solution gives:

$$
\ln(S_{t_j})=\ln(S_0)+\mu_g t_j+\sigma W(t_j),
\qquad j=0,1,\ldots,N.
$$

The Wiener process has mean zero, so the expected log price is:

$$
\mathbb E[\ln(S_{t_j})]=\ln(S_0)+\mu_g t_j.
$$

This is a straight line in time, with intercept $\ln(S_0)$ and slope $\mu_g$.
We therefore estimate mean growth by fitting a line to the observed log prices.

> __Interpreting the regression:__ The term $\sigma W(t_j)$ describes deviations
> from the expected log price. These errors are correlated across observation
> times, and their variance grows with time. We can estimate the slope using
> least squares, but the usual uncertainty formulas that assume independent
> errors with constant variance do not apply to this model.

Let's write the regression as a system of equations and solve for the intercept
and slope.

## Completed and approved

- Introduction and exactly three learning objectives. The paragraph beginning
  “The GBM model has an exact solution…” follows the objectives, outside their
  blockquote, immediately before “Let's get started!”
- Main Examples descriptions: motivating question, then what we calculate and
  learn. Both linked notebooks were read. Entries use separate blockquotes,
  matching L4a, rather than bullets.
- “From Lattices to Continuous Prices” was rebuilt after two rejected formatting
  attempts. It now has introductory prose, one `Idea:` blockquote, explicit
  normal log-return versus lognormal price distinction, and a transition into
  the SDE. No optional-example reference remains in this section. The optional
  lattice-limit notebook stays in Optional Advanced Material at the bottom.
- GBM opening: SDE, positive initial price, drift and volatility units, labeled
  interpretation blockquote, and transition to the Wiener definition.
- Wiener definition: existing single blockquote and three-bullet structure
  retained; descriptive labels added. The short paragraph after it reads:
  “Over an interval $\Delta t$, the Wiener increment has standard deviation
  $\sqrt{\Delta t}$. The volatility parameter scales this to
  $\sigma\sqrt{\Delta t}$, the noise scale that appears in the GBM solution and
  simulations.”
- Analytical solution: terminal solution, log transformation, mean and variance,
  `Drift and mean growth:` blockquote. The Itô-derivation link remains attached
  to the explanation of Itô's lemma. A connective sentence follows the
  blockquote and leads into the discrete-time grid.
- Discrete-time model: time grid, exact one-step transition, independent standard
  normal shocks, then a transition into simulation. The cumulative-shock formula,
  correlation discussion, and proposed “Building a price path” blockquote were
  explicitly rejected as unnecessary and removed. Do not reintroduce them.
- Monte Carlo: shorter purpose-driven opening; approved initialization,
  pseudocode, update equation, and independent-shock explanation retained.
  Closing transition leads into parameter estimation. The package `sample(...)`
  reference was subsequently removed under the no-implementation-details rule.
- Estimation opening: annotated growth-rate equation, compact `Parameters:`
  blockquote with a blank line after its label but adjacent bullets, then
  transition to volatility.
- Volatility: sample mean and standard deviation, correct degrees of freedom,
  L3a volatility conventions, daily scaling, and transition to drift. No `std`
  function reference or code expression remains.
- `### Mean Growth and Drift`: approved and applied most recently. Own heading
  parallel to Volatility, boxed drift recovery, two-method blockquote, and
  closing transition to linear regression. Jeffrey said “really like this.”

## Confirmed notation and technical decisions

- $g_j$ is observed continuously compounded growth per year;
  $r_j=\Delta t\,g_j$ is dimensionless interval log return.
- $g^\prime$ is the sample mean, preserving L3a notation.
- **Mean growth is now $\mu_g=\mathbb E[g_j]=\mu-\sigma^2/2$; its estimate is
  $\hat{\mu}_g$.** $\mu$ remains arithmetic GBM drift. This change is applied
  throughout the active lecture, including regression, stylized facts, and
  summary. L3a reserves $\bar g$ for excess growth relative to a benchmark.
- The linked example and advanced notebooks have NOT received this symbol
  migration. Coordinate it when their own review is requested; do not silently
  expand the current lecture task into other notebooks.
- L3a consistency was checked directly in
  `lectures/week-3/L3a/CHEME-5660-L3a-Lecture-Equity-Exchanges-Return-StylizedFacts-Fall-2026.ipynb`.
  Its conventions are $\sigma_r(\Delta t)=\Delta t\,\sigma_g$ and
  $\sigma_{\mathrm{ann}}=\sigma_r(\Delta t)/\sqrt{\Delta t}
  =\sqrt{\Delta t}\,\sigma_g$. In L4b, $\hat\sigma=\sigma_{\mathrm{ann}}$.
  Units are respectively $\mathrm{yr}^{-1}$, dimensionless, and
  $\mathrm{yr}^{-1/2}$. L3a's $T-2$ denominator for $T-1$ growth observations
  agrees with L4b's $N-1$ denominator for $N$ growth observations.
- Under the model, independent increments and constant volatility justify
  square-root time scaling; L3a appropriately qualifies its use with real data.

## Preferences reinforced during this review

- No language/package implementation details in CHEME 5660 lecture notes this
  year. Keep function references and implementation discussion in companion
  examples. Mathematical pseudocode was explicitly retained and approved.
- Do not start prose sentences with an acronym. Use “The model's independent
  increments…” instead of “GBM's independent increments…”.
- Preserve existing blockquote formatting. Ordinary prose surrounds selected
  labeled blockquotes; do not put a whole section in one quotation.
- Optional examples belong in the bottom Optional Advanced Material section.
  An example needed within the main development should not be labeled optional.
- A section/subsection should not end on a blockquote: add a short natural
  connective sentence into the next topic.
- Avoid redundant explanations and unnecessary mathematical side discussions.
  Preserve the derivation and teaching purpose. Local trimming is preferred.

## Completed review sequence

1. Linear-regression opening above: approved and applied September 11.
2. Matrix formulation, least-squares solution, interpretation, companion-example
   passage, and transition into Stylized Facts: approved and applied September 11.
3. Stylized Facts: approved and applied September 11. The unnecessary
   horizon-average calculation was removed; the three comparisons with L3a
   and the covariance calculation remain.
4. GBM Trade Rule opening, scenario, and scaled-NPV recap: approved and applied
   September 11. GBM substitution and scaled-NPV distribution are also approved
   and applied. Terminal Target Probability is also approved and applied;
   its closing companion-example passage is also approved and applied.
5. Optional Advanced Material descriptions: approved and applied September 11;
   all four linked notebooks were read for scope and links verified.
6. Summary and exactly three retrospective key takeaways: approved and applied
   September 11, with adjacent bullets and no extra blank lines between them.
7. Final check: valid notebook with 12 Markdown cells, exactly three objectives
   and three takeaways, 10 working local links, consistent mean-growth notation,
   no direct function references, and correct horizontal-rule boundaries.
   All edited passages have been rendered and visually inspected individually.
   Both final trade-rule wording cleanups were approved and applied September 11.

## Verification and working-tree cautions

Edits were targeted replacements of Markdown cell source arrays, preserving
notebook JSON formatting, cell IDs, and untouched cells. No numerical code was
changed or executed. Sections were exported with `nbconvert.HTMLExporter` using
the `lab` template, screenshot with Playwright after MathJax rendered, and
visually inspected. Latest approved-section preview:
`/private/tmp/l4b-final-wording-review.png`. Full lecture HTML export:
`/private/tmp/l4b-complete-review.html`. Earlier previews use
`/private/tmp/l4b-*-review*.html` and `.png`; temporary files may not persist.

The repository has unrelated user/concurrent changes in the shared style guide,
L4a example/advanced notebooks, L4a source and slides, and untracked L4a docs and
week-4 temporary files. Do not revert, overwrite, stage, or commit those changes.
Inspect current state before any further edits. No subagents were used.
