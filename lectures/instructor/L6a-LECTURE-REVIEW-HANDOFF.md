# L6a minimum-variance lecture — polish review

September 24, 2026. **Reviewed and complete, confirmed by the instructor.**
The instructor requested “Make the lecture as reviewed - and let's move to the
example.” The final editorial score is 9.1/10. All agreed revisions are saved,
and no proposals remain pending. Do not restart approved lecture sections unless
the instructor requests another round. The minimum-variance example review is
separate.

## GMV subsection reorganized — September 27, 2026

The instructor liked the GMV subsection but found its organization "a little off,
and choppy". The dollar example sat between the definition and the box, a vague
sentence followed it, and the box closed on four unrelated sentences. Approved
order ("Really like this reorg"): definition, then box, then negative weights.
Prose fell from about 286 to 241 words, and every display is unchanged.

- The lead-in is the definition, "We allow short positions, so some of its
  weights can be negative," one new sentence tying back to the Diversification
  discussion ("For two assets with $\sigma_{g,1}\leq\sigma_{g,2}$, the GMV
  portfolio shorts the riskier asset when $\rho_{12}>\sigma_{g,1}/\sigma_{g,2}$."),
  and the box lead-in. The new sentence replaced "A short can reduce portfolio
  variance, depending on the covariance and position size."
- The box closes on "No mean-growth estimate is needed..." and the companion link.
  The variance units moved into the Solution line. "The weights are
  dimensionless" and the $\hat{\mathbf{\Sigma}}_g$ sentence, already stated in
  Portfolio risk, were cut.
- The negative-weight paragraph follows the box, the order approved in the
  September 24 GMV split. On projection grounds ("can't have large tracts of
  prose. Too long") it was cut to three sentences: the trade, the buy-back gain
  or loss, and "We ignore borrowing fees, collateral, and position limits."
  Short selling first appears here, so the financing assumption is shown by the
  trade itself rather than stated before the box.

Only Markdown cell 5 changed in this round. The deck was resynchronized the
same day (see the slides record). A Codex check confirmed the two-asset shorting
condition with SymPy, found all seven displays character-for-character unchanged
and on one quoted source line, and found no dangling references downstream. Its one wording flag ("we gain" could
read as the whole portfolio) was resolved in the instructor's words: "We must
repurchase the borrowed shares, so the short gains when the price of the borrowed
shares falls and loses when the price rises."
Renders are in `build/notebook-previews/L6a-gmv-organization-2026-09-27/`.

Lecture SHA-256:
`22a6429f02c5dadf4b723cb00154bb45ce0a1367cd9f708eb78c65762e0a0d81`

## Diversification discussion tightened — September 27, 2026

The instructor added the `### Discussion: Diversification` heading and asked to
tighten the subsection ("I like it, but I think we could tighten"). Prose fell from
about 180 to 90 words. Equations, the bold question, the setup sentence, and the
closing handoff are unchanged. Two cuts were his:

- The log-return conventions note was dropped rather than moved up to Portfolio
  risk. The lecture never uses log returns again, and every L6a example defines
  the covariance rate and GBM volatility itself.
- The "standard deviations of 2 and 4 per year" illustration was dropped ("what??").

The weighted-average and below-both-assets sentences were merged into one
paragraph, and the below-both condition is now written as
$\rho_{12}<\sigma_{g,1}/\sigma_{g,2}$ with $\sigma_{g,1}\leq\sigma_{g,2}$. Only
Markdown cell 4 changed. The deck was resynchronized the same day (see the
slides record). A Codex check
confirmed both inequalities with SymPy, found no dangling references, and found
the JSON diff limited to cell 4's source. Of its two optional wordings, the instructor
accepted "the variance is a perfect square" and declined merging "This is the
benefit of __diversification__" into the preceding sentence. Renders are in
`build/notebook-previews/L6a-diversification-2026-09-27/`.

Lecture SHA-256:
`115ff9ee43a45d884db11638cf6ff859dec20410893e19f5cd556f8a070d02ab`

## Mean-growth notation simplification — September 27, 2026

The instructor approved removing $\boldsymbol{\mu}_g$ from this lecture because
students reported excessive notation. The reward derivation now keeps
$\mathbb{E}[\mathbf{g}]$ and uses an approximation sign to introduce the
sample-mean estimate $\mathbf{g}^{\prime}$. The frontier constraint and coefficients
use $\mathbf{g}^{\prime}$ throughout. The frontier discussion and long-only setup
identify growth targets as estimated expected growth. Covariance notation and
the optimization algebra are unchanged.

This targeted change touches only Markdown cells 4 and 5. Notebook schema,
metadata preservation, three objectives and takeaways, and the installed VS Code
math-renderer checks pass. Before/after snapshots and rendered HTML are in
`build/notebook-previews/L6a-growth-notation-2026-09-27/`. Slides and companion
notebooks were not changed. Earlier scores describe their recorded snapshots.

## Example-description fix — September 26, 2026

The data example's Task 3 now also tests the shorts-allowed GMV portfolio, so two
sentences describing it changed. In Examples, "We compare the long-only global
minimum-variance portfolio with…" became "We compare both global
minimum-variance portfolios with…". In the data-example callout, "Evaluate the
long-only GMV portfolio against…" became "Evaluate both GMV portfolios
against…". No other change. The deck was synchronized the same day (see the
slides record). The P-1 box still states $w_i\geq0$, which is right for the
lecture's long-only wealth formula. The example applies the same linear formula
to negative weights as a blue-sky test.

Lecture SHA-256:
`2e05ae5ded58a5974242cb324a2aa8d15138cf07636c1717d5c8a9776e6f144e`

## Polish round to 9.2 — September 25, 2026

The instructor asked for a fresh 0–10 rating of the density-round snapshot
(`a36dac5b…`) and what to change. The independent rating was 8.9: the mathematics
and sequence held, and the remaining issues were rule compliance and small flow
gaps. The instructor approved the proposed path (“Ok - get me to the 9.2”), and
the edits below are saved. The overall editorial score is now 9.2.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 9.6 | 9.6 |
| Organization | 9.0 | 9.1 |
| Narrative and flow | 8.9 | 9.3 |
| Density for projection | 8.4 | 8.5 |
| Overall editorial judgment | 8.9 | 9.2 |

Accepted edits (Markdown source in cells 2, 4, 5, and 6 only):

1. **Semicolons:** all nine clause-joining semicolons became periods or a comma
   with “and”, “but”, or “which” (simplex corners, MPT reference, covariance
   diagonal, the ρ₁₂ < 0.5 example, the short-position repurchase cost, the F-1
   equal-means condition, the frontier trace after F-3, the LO-1 numerical solve,
   and the P-1 initial-allocation note). The frontier image's alt text lost its
   semicolon too. The MPT reference's bare “[here]” link became “Markowitz's
   Nobel Prize facts page summarizes the award.”
2. **Dirichlet link:** the lecture now links the Wikipedia article, as lectures do
   for the Beta distribution. It was the only package-documentation link in any
   lecture. The Dirichlet example keeps its Distributions.jl link.
3. **Estimated Inputs flow:** after the wealth/NPV box, a new sentence links the
   data example as the place where the wealth formula is applied to the held-out
   2025 prices (it computes wealth, not NPV, on those prices). The simulation lead-in
   gained “also”. The closer became “The simulation example extends the
   single-asset NPV trade rule to a portfolio.”
4. **Concept Review closer:** “The lowest-variance draw is the best among the
   sampled candidates” became “Sampling can only find the lowest variance among
   the draws we happened to make.”
5. **Display spacing:** the two visible Portfolio reward displays now have blank
   lines before and after, as in the rest of the lecture. The instructor's
   commented buy-and-hold passage is byte-identical and still hidden.

Not applied: the growth-floor lead-in does not cover its third bullet (comparison
with short-allowed portfolios). A lead-only rewording was offered as the
instructor's call because the bullets are an approved passage. The morning's
deferred items (ρ₁₂ versus ρ_T, the ½ factor only in GMV-1, Objective 2's length)
remain deliberately unchanged. Codex suggested rewriting the Concept Review closer
again and splitting the alt text's 32-word sentence. Both were declined: the first
rewrite repeats the next sentence, and the alt text is unchanged apart from its
semicolon.

Validation: the diff against the pre-round backup touches only the sources of
cells 2, 4, 5, and 6, and notebook and cell metadata are identical. The installed
VS Code KaTeX renderer reports no errors, with 18 display blocks before and after.
The clause-semicolon sweep (`(?<!\\);` outside HTML comments) and the em-dash sweep
are clean, all local links resolve, and `git diff --check` is clean. Codex verified
the diff, meaning preservation, the data-example and trade-rule claims against the
example notebooks and L4b/L5a, the ρ₁₂ cutoff with SymPy, links, spacing, and the
style sweeps. It also checked the final closer. Previews are under
`build/notebook-previews/L6a-9.2-round-2026-09-25/`.

Deck synchronization needed (not edited): slide line 120 still links the
Dirichlet distribution to the Distributions.jl documentation.

Round lecture SHA-256:
`579199f99d9424c6587f9e8b6c6de0ce87f6087c02033a72a7ef9e022b3fcb26`

## Density and flow round — September 25, 2026

The instructor requested a fresh rating with attention to narrative, flow,
projected density, organization, and correctness, then a plan for the four
issues that held the score down. All four steps were proposed with rendered
previews, approved (“Agree. Update.”), and saved. After an interim 8.8, the
instructor asked what would reach 9 and approved a fifth edit (item 5 below).
The instructor has not yet separately marked this round complete.

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 9.5 | 9.6 |
| Organization | 8.5 | 9.0 |
| Narrative and flow | 8.5 | 9.0 |
| Density for projection | 7.5 | 8.4 |
| Overall editorial judgment | 8.5 | 9.0 |

The initial 8.5 was an independent assessment of the confirmed 9.1 snapshot
(`77acb7db…`); the lower score reflected projected density and the issues below,
not mathematical errors. All algebra, units, and the AMD figures were re-verified.

Accepted edits:

1. **Estimated Inputs section:** one thread from which inputs each allocation
   uses (GMV: covariance only; targets and floors: means too), the AMD sample-mean
   versus L4b log-price-regression disagreement, and optimizer bias toward
   underestimated variance or overestimated mean growth, then out-of-sample
   evaluation leading into the wealth/NPV box. Dropped the 12.8-point restatement.
   Objective 3 now reads “Identify which estimated inputs each allocation depends
   on…”. The Minimum-Variance section closes with the question that this section
   answers. The Concept Review's forward pointer to the wealth calculation was cut.
2. **Frontier text:** the figure draws no attainable region, so the lead now names
   only the GMV portfolio and efficient branch, and the third bullet became
   “Feasible portfolios” (every fully invested portfolio lies on or to the right
   of the curve). Text-only fix; `frontier.pdf` is shared with the deck. The
   “initially allowing short positions” clause stays because the guide asks this
   sentence to contrast long-only samples with the short-allowed frontier.
3. **Transitions:** the negative-weight example and financing assumptions now
   precede the GMV box. The frontier-to-long-only transition gives the reason
   (many investors and funds cannot short; requirements are usually minimums),
   and the long-only lead flags the switch to estimated inputs. The floor-choice
   paragraph before the data example became a one-line lead-in; the example
   explains that choice itself.
4. **Density:** removed the Portfolio reward redefinition of the portfolio and
   weights, the restatement after the boxed reward result, “At this target, the
   extra variance vanishes,” and the redundant growth-floor definition.

5. **Portfolio Risk closing:** the log-return box and the separate GBM-volatility
   paragraph and display became a three-sentence note on conventions. It keeps
   $\mathbf{\Sigma}_g$ throughout and mentions $\mathbf{C}=\Delta t\,\mathbf{\Sigma}_g$ only for GBM
   volatility, because the lecture never uses log returns or $\mathbf{C}$ later. The instructor
   confirmed that the portfolio problem stays in $\mathbf{\Sigma}_g$ (all three examples pass
   $\hat{\mathbf{\Sigma}}_g$ to the solver; $\hat{\mathbf{C}}$ appears only for the simulation and the
   volatility check). The style guide's calibration entry records this change.

Outside these assistant edits, the Portfolio reward subsection's buy-and-hold
log-growth paragraph, its display, and the reward-to-risk transition sentence
were commented out in the source with an HTML comment. The commented text is preserved and hidden
in the render. The lecture now presents weighted growth as the mean-variance
model's choice; the data example's realized-growth table still shows the difference.

Declined: shortening the frontier and long-only box Setups by referring back to
(GMV-1). Measured gain was 26 words and two rendered lines; the instructor kept
the self-contained box rule.

Visible prose words (excluding display math, HTML comments, and the disclaimer):
3,251 to 3,020. Minimum-Variance section 1,031 to 994; Portfolio Theory 697 to 514.

Validation: notebook schema; exactly three objectives and takeaways; separators
before every level-two heading and after the Summary; all 12 local links/images
resolve; nine unique equation tags; every display equation unchanged; notebook
and cell metadata preserved; the commented passage stays hidden; full render through the installed VS Code KaTeX
renderer with no errors; `git diff --check` clean. Previews are under
`build/notebook-previews/L6a-density-round-2026-09-25/`.

Remaining for a possible later round (not applied): further density reduction
would reopen approved passages (the growth-floor bullets) or trim two GMV-box
sentences made redundant by the new Estimated Inputs opening. Minor items:
$\rho_{12}$ (correlation) and $\rho_T$ (scaled NPV) share a symbol; Objective 2
lists four actions; (GMV-1) carries the $1/2$ factor while (F-1) and (LO-1) do not.
Classroom pacing is untested.

Deck synchronization needed (not edited): Objective 3 wording; the “Estimating
Portfolio Inputs” slide (L4b log-price regression, optimizer bias, evaluation on
unseen prices); the negative-weight explanation before the GMV result; the
“Weighted Growth and Buy-and-Hold Wealth” and “Growth Rates and Log Returns”
slides, whose lecture passages are now commented out or condensed.

Round lecture SHA-256:
`a36dac5b1b51b69bd204034a388b206f77f3369b787d28c2a9bff008d98419a2`

## Latest instructor confirmation and follow-up snapshot

The instructor reconfirmed the lecture as reviewed on September 24, 2026,
then requested review of the L6a slides against this notebook. The accepted
follow-up edits replace the opening covariance review with Dirichlet sampling,
link the local L6a copy of the reviewed sampling example, and place the
AllianceBernstein profile after the concept review. They also add explanatory
weight annotations, tighten the frontier and growth-floor interpretations into
lead sentences, three detailed bullets, and closing sentences, clarify the role
of mean estimates versus covariance, and box the key optimization and performance
results. Andrew Chin's name links to LinkedIn and the personal course reference
links to the AI in Finance short course. The standalone MPT video was removed.

The latest editorial assessment was 9.1/10 before the final requested bullet and
boxing changes. The earlier multi-model scores describe their saved pre-fix
snapshot, not this final notebook. No lecture proposals remain pending.

Confirmed lecture SHA-256:
`77acb7db3185ca8d8e72dcde3bfda9019090329e9319767352082e9322e45a76`

The confirmed notebook has ten Markdown cells and no code cells. The assessment,
counts, hashes, and rendering evidence below describe earlier snapshots and are
retained as review history. The slides are being reviewed separately.

## Assessment after the density and presentation revisions

| Dimension | Initial | Current |
| --- | ---: | ---: |
| Technical correctness and consistency | 9.0 | 9.2 |
| Organization and sequencing | 8.5 | 9.2 |
| Narrative and interpretation | 8.5 | 9.0 |
| Presentation | 7.8 | 9.1 |
| Cognitive density and pacing | 8.2 | 8.9 |
| Overall editorial judgment | 8.5 | 9.1 |

This current 9.1 assessment describes the substantially revised snapshot below,
not the earlier premature 9.1 assessment. The lecture now leads with the frontier
figure, groups assumptions/definitions/results in annotated theorem-style boxes,
keeps the short-allowed development together, and links the complete GMV proof.
The wealth/NPV recall and the objectives/takeaways now agree. Using the same count
that excludes math and the disclaimer, lecture prose fell from 3,339 to 2,680 words.
The lecture remains longer than 2025 because it develops short positions, the
analytical frontier, growth floors, and the distinction between weighted growth
and buy-and-hold wealth. Mathematical density remains highest in the consecutive
GMV/frontier/long-only results; those definitions and conditions are deliberate,
and the instructor reviewed their concrete organization and annotations.

Validation: both lecture and GMV companion pass notebook schema checks, have exactly
three objectives and takeaways, and end their Summary with the required separator.
All 12 local lecture links/images and both companion links resolve. All nine
lecture equation tags are unique. Full lecture and companion math rendering pass
the installed VS Code renderer; the edited sections and complete companion were
visually inspected. Lecture metadata is preserved and the lecture has nine Markdown
cells, with no code to execute. No companion computational examples were rerun.
The full GMV derivation retains all seven original mathematical displays.

Current lecture SHA-256:
`8e7dba93f781bc75fa97e4263cd6b7b74705bfeedc82a4c8949eede31a6e44fa`

Current GMV companion SHA-256:
`7ba56869b92785b2d9869bd59da62fd1dd58650a7ec6c790067e1eccfdb595ba`

Full render: `build/notebook-previews/L6a-polish-2026-09-24/reviewed-lecture.html`.
Section previews and the companion screenshot are in that directory. The shared
style guide records the accepted density, precise theorem-style setup, visual-first
geometry, and varied equation-annotation preferences for both courses.

## Earlier review history

September 24, 2026. **Review reopened for prose density and presentation.** The
instructor rejected the conclusion that only classroom pacing remained to address.
The revisions below were approved and applied, but the 9.1/10 assessment was
premature and is not an instructor-accepted completion score.

The instructor finds 2025 significantly sharper: less text, clearer presentation,
and a less dense body. He likes the added 2026 material and wants it preserved,
but expects substantial tightening of the surrounding prose. This is a request
to reconsider cumulative text density, not to remove the mathematical development
or merely rearrange headings. Compare matched passages and their rendered rhythm;
do not treat each individually defensible explanatory sentence as necessary.

A fresh comparison found approximately 1,858 prose words in 2025 versus 3,339 in
the current 2026 lecture (excluding displayed/inline math, link destinations, HTML,
and the disclaimer). Different scope accounts for part of the increase. However,
the matching Portfolio Risk subsections alone have approximately 225 versus 467
prose words, independent of the new short-position material. Live Chrome views
show the 2025 section organized around displayed equations and a matrix, while
2026 interleaves more explanatory paragraphs and inline notation. The 2026 browser
also has an open assistant sidebar, narrowing its text area; the source-word
comparison establishes that the difference is not solely a viewport effect.

The instructor subsequently authorized the Portfolio Risk revision and requested
that this lesson become a general style guideline. The shared
[notebook style guide](NOTEBOOK-STYLE-GUIDE.md#prose-density-and-the-instructors-voice--september-24-2026)
now records the density preference and early comparison workflow. Its earlier
restriction to modest edits is scoped back to the specific N-ary revision that
prompted it; it is not a universal prohibition on substantial prose tightening.

The first Portfolio Risk calibration is now saved: approximately 470 to 270 prose
words, retaining all four original display equations, the two-asset diversification
argument, the numerical correlation cutoff, growth/log-return scaling, covariance-rate
conversion, units, and risk-axis convention. The standard-deviation and volatility
formulas now have their own displays instead of lengthening inline prose. Other
notebook sections and metadata are unchanged from the preceding revision. The
instructor subsequently approved this density and confirmed its applicability to
CHEME 5800. This is the first accepted calibration passage for the shared density
guideline. It does not close the remaining L6a density review.

The draft passed the installed VS Code math renderer and was inspected visually
before saving. All original risk display equations were compared after whitespace
normalization; the two added displays restate existing inline formulas. Notebook
schema and objective/takeaway checks pass. Evidence: `risk-tightened.md`,
`risk-tightened.png`, `risk-density.html`, and `before-density.ipynb` under
`build/notebook-previews/L6a-polish-2026-09-24/`.

Current notebook SHA-256 after density revision:
`24380877fcb5b24853ab23fabcf95f18e60ebd952dfaa47d8f45d1b55e1c56f8`

### Approved GMV split

The instructor approved the revised “lite theorem” and requested that the paragraph
immediately after it move inside the blockquote. Applied: the two-sentence lead-in
is followed by the assumptions, constrained problem, Lagrangian/stationarity sketch,
weights, minimum variance, estimated-input interpretation, and companion link inside
the box. The short-position dollar example follows it. Objectives and takeaways
now describe computing/using the result. Unrelated cells and metadata were preserved.

The complete derivation is saved in
`lectures/week-6/L6a/advanced/gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb`.
All seven original GMV display equations and every derivation step are retained.
Both notebook schemas and relative links pass validation; the lecture draft renders
without math errors. The advanced index now links the companion. The shared style
guide records the instructor's “lite theorem” preference.

Lecture SHA-256 after applying this split:
`e7e0318c8207770c930f7ce7183362dbbc323162f5422fafb78cab8bebc98e4a`

### Approved target-growth section and symbol-definition correction

The instructor accepted the target-growth revision with corrections to both
“lite theorem” blocks: define every symbol, state explicitly that the weights
are the unknowns, label equations, and use explanatory underbraces. He emphasized
that “lite” offloads proof details while preserving a precise, informative setup.
The GMV and frontier blocks now define the weights and their components, number
of assets, inputs and dimensions, multiplier/Lagrangian where used, outputs, and
variance units. The existing coefficients a, b, c, d are identified as scalar
abbreviations calculated from the inputs. Equation labels are GMV-1–3 and F-1–3.

The instructor then requested a visual-first presentation, recalling the random
weight plots in L5b. Applied: link to L5b, frontier figure, visual comparison and
efficiency explanation, then the annotated mathematics. The text distinguishes
L5b's long-only samples from the short-allowed curve. The long-only subsection
and all other cells were preserved. The shared guide records these preferences.

Both sections were rendered and visually inspected. Notebook schema, local links,
three objectives/takeaways, equation labels, metadata, and unrelated-content
preservation checks pass. Saved previews: `gmv-defined.png` and
`frontier-defined.png` in `build/notebook-previews/L6a-polish-2026-09-24/`.
The full GMV companion remains linked and unchanged. The next section for the
density pass is the long-only problem; no rewrite of it has been applied.
The instructor also clarified that multiline displays can use right-hand text
labels rather than underbraces for every annotation. Applied to the GMV and
frontier optimization problems: objectives and constraints now have aligned text
on the right. Term-specific underbraces remain for the budget residual, weight
normalization, and variance decomposition. The shared guide records both options.
Equations, prose, and symbols are otherwise unchanged; rendering checks pass.

No new overall review score assigned.

### Approved long-only density revision

Prepared `long-only-draft.ipynb`, `long-only-section.md`, and
`long-only-preview.png` in the preview directory. The draft defines all symbols
inside a theorem-style box and puts brief labels to the right of the optimization
rows. It retains the short-allowed solution when feasible, numerical solution
otherwise, the two floor cases, upper feasible target, frontier comparison, and
data-example sequence. Repeated equations and explanations are consolidated.
Prose falls from about 473 to 363 words, with definitions preserved. It explicitly
assumes a positive-definite covariance estimate, consistent with the preceding
closed-form development, to justify uniqueness and the binding-floor statement.
The notebook schema and installed math-renderer checks pass; the layout was
visually inspected. The instructor approved this revision ("Agree. Update. Next"); it is now saved.
The saved notebook matches the reviewed draft and passes schema validation.

### Approved estimated-inputs, wealth, and NPV closing

Prepared `closing-draft.ipynb`, `closing-section.md`, and `closing-preview.png`
in the preview directory. The draft retains the AMD sample-mean/regression
comparison and the covariance-error interpretation. It groups the existing
share-count, wealth, NPV, and scaled-NPV equations into one recall box with
explicit symbol definitions and right-hand annotations. It retains fixed shares,
changing wealth fractions, fractional-share/cost assumptions, the benchmark
interpretation, and the simulation example. Repeated performance and simulation
narration is removed. Prose falls from roughly 330 to 260 words. Schema and
math-renderer checks pass; the layout was inspected visually. The instructor approved this closing revision ("Agree. Update. Next"); it is now
saved and matches the reviewed draft, with notebook schema validation passing.

### Approved introduction, objectives, and Summary

Prepared `framing-draft.ipynb`, `framing-section.md`, and `framing-preview.png`
in the preview directory. The proposal shortens the opening and removes the
repeated out-of-sample overview after the objectives. It retains exactly three
objectives and three retrospective, equation-free takeaways, now naming the
wealth/NPV evaluation explicitly. The instructor requested revised Summary lead-in and exit sentences. The revised
draft opens with the move from sampled weights to optimized allocations with and
without shorts, and closes with L6b's single index estimates and risk-free asset. Optional
reading links and their L6b timing were checked against the current SIM/risk-free
lecture and need no correction. This proposal changes only cells 0 and 7; the
instructor approved the revised lead-in and exit ("Agree. Update. Next").
All framing changes are now saved; the notebook matches the approved draft.

Notebook: [Data-Driven Minimum-Variance Portfolios](../week-6/L6a/CHEME-5660-L6a-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb).

The instructor requested comparison with the 2025 L6b lecture, appreciating its
explanatory progression while wanting to preserve the 2026 short-position case.
This review concerns the active L6a notebook, not the earlier archived L5b score.

## Assessment

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness and consistency | 9.0 | 9.2 |
| Organization and sequencing | 8.5 | 9.2 |
| Narrative and interpretation | 8.5 | 9.1 |
| Presentation | 7.8 | 9.2 |
| Cognitive density and pacing | 8.2 | 8.8 |
| Overall editorial judgment | 8.5 | 9.1 |

The revision preserves the 2026 mathematical development while recovering the
2025 progression from choosing weights to evaluating the investment. The source
GMV and frontier algebra was already correct. The main technical improvements
are explicit financing assumptions for the short-position scenario and accurate
descriptions of which allocation the companion example evaluates out of sample.

The short-allowed GMV and target frontier now form one continuous development,
followed by long-only restrictions and growth floors. The closing connects initial
weights, fixed shares, wealth, and NPV. Equations render correctly in both checked
renderers. The main remaining teaching demand is the sequence of matrix formulas
and constraint distinctions; classroom pacing has not been measured. No further
substantive revisions are proposed.

## Approved changes and preferences

- Added a 1,000 USD example with weights 1.2 and -0.2: short-sale proceeds finance
  the additional long holding, the short is a repurchase liability, and net weights
  still sum to one. Explained covariance hedging and the idealized omission of
  borrowing fees, collateral requirements, and position limits.
- Kept the short-allowed GMV derivation and target frontier together, then developed
  long-only restrictions and the distinction between exact targets and growth floors.
- Moved the early wealth/NPV recap after optimization and developed the connection
  from initial weights to shares, buy-and-hold wealth, and discounted performance.
  The simulation remains explicitly long-only, matching its implementation.
- Shortened Objective 2 and replaced the repeated opening overview. The instructor
  explicitly confirmed that removing the objective's method-level reference to
  Lagrange multipliers must not remove the mathematical derivation. The complete
  derivation is preserved.
- Clarified both minimum-variance example descriptions: the 2025 wealth comparison
  evaluates long-only GMV against equal weights and an index fund. It does not
  evaluate the short-allowed GMV portfolio out of sample.
- Repaired the estimation-risk link in the linked L6a advanced index and placed
  that example after L6b's risk-free material. Other notebooks were not edited.

## Blockquote mathematics in JupyterLab and VS Code

The instructor noted that the original quoted multiline equations displayed
correctly in VS Code, although JupyterLab in Chrome displayed literal `>` markers
inside the mathematics. Removing blockquote markers breaks the continuous panel
formatting in VS Code, so that is not an acceptable repair.

The accepted workaround keeps the leading Markdown `>` but places each complete
display between its opening and closing `$$` on one physical source line, with
quoted blank lines before and after it. LaTeX `aligned` and `\\` still produce
multiline displayed equations. This keeps blockquote markers outside JupyterLab's
extracted math and preserves a single continuous blockquote in both renderers.
Applied to five GMV displays and the growth-rate/log-return display. Ordinary
unquoted display math remains multiline in the source.

The instructor noted the source-readability cost for large derivations. Treat this
as a compatibility workaround for affected quoted math, not a general LaTeX style.

## Validation and preservation

- Read the complete 2025 and 2026 lecture sources and the relevant course guide,
  workflow, historical handoff, and calibration material.
- Reviewed the relevant companion formulas, code, and saved results; did not rerun
  computational notebooks. The lecture itself has no code cells.
- Verified the optimization and risk display equations are unchanged up to
  whitespace and order. The existing instructor kernel-metadata edits are preserved.
- Notebook schema, all 12 direct local links across the lecture and advanced index,
  exactly three objectives, three equation-free takeaways, major-section separators,
  and final Summary separator pass. `git diff --check` passes.
- Inspected the short-position introduction, GMV panel, frontier figure, wealth/NPV
  closing, and final opening in live JupyterLab during the round. Verified the
  repaired GMV panel has no stray markers and remains a continuous blockquote.
- Rendered the complete final source through the installed VS Code notebook math
  renderer, with no KaTeX errors. Inspected its GMV output visually and verified
  all five displays remain inside one blockquote. This used the renderer's actual
  Markdown parsing, without extracting equations in advance.
- No slides, companion calculation code, saved computational outputs, or takeaways
  were changed. No commit or release was made.

Initial notebook SHA-256:
`3f1ce4c85ecc1cb3c21a5b0fe7dd67b949938be145c556651cb597cfdd24d17e`

Final notebook SHA-256:
`2b57dce8d103475afd0e7ce22654a003de4a8473d0d3890eeaa9d8d886501b5c`

Local evidence, initial assessment, final snapshot, checks, and renderer screenshots
are under `build/notebook-previews/L6a-polish-2026-09-24/` (ignored build artifacts).
