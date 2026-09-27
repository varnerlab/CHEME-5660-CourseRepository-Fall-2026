# L6a slides — review against the completed lecture

**Status, September 26, 2026: marked reviewed and complete by the instructor
(initial 8.0/10, final 9.0/10).** The instructor asked for the remaining steps in
one pass ("let's do all 5"): sync with the stabilized lecture, the reworked
GMV/frontier section, the long-only section and closing, and the final rescore.
After the previews, the instructor asked for one change on page 17 and approved
all other slides, then accepted that fix ("Agree") and asked to mark the deck
reviewed. See "Sync and close" at the end. No proposals remain pending. Do not
restart approved slides unless the instructor asks for another round.

September 24, 2026. **Slide review remains open; opening updated September 25.**
The instructor confirmed the L6a lecture as reviewed and requested review of
the slides against it. The initial assessment below describes the unmodified
baseline. The approved opening update is recorded at the end.

## Baseline

- Lecture: `../week-6/L6a/CHEME-5660-L6a-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb`
  SHA-256: `77acb7db3185ca8d8e72dcde3bfda9019090329e9319767352082e9322e45a76`.
- Slide source: `../week-6/L6a/slides/CHEME-5660-L6a-Slides-Fall-2026.tex`
  SHA-256: `a39add7d49497b6710a10d0fa07a8605a304689df443ae1d7e896a960e7868ca`.
- PDF: 24 pages; SHA-256:
  `02f7a845fb038cbd69991b6e7dc209818959f67ec65827c5811026f3cf863826`.

Initial editorial assessment: **8.0/10 as a companion to the reviewed lecture**.
The mathematical core and native Beamer presentation are sound. The principal
weakness is synchronization: the deck follows an older opening and topic order.
This is a new assessment of the active L6a deck, not the historical 9.2/10 score
for the pre-pivot L5b deck.

## Findings and proposed review order

1. **Opening, slides 3–7:** Align the three objectives with the notebook, include
   all three examples, replace the GBM/covariance recap with portfolio weights
   and Dirichlet sampling, then introduce AllianceBernstein. Move wealth/NPV to
   the performance closing. The current claim that L5b sampled allocations does
   not reflect the instructor's actual coverage.
2. **Reward and risk, slides 8–13:** Retain the growth-rate convention, weighted
   growth versus buy-and-hold distinction, diversification conditions, and units.
   Tighten only where needed for note-taking; the mathematical content is sound.
3. **Optimization, slides 14–20:** Keep the short-allowed GMV and target-growth
   development together before long-only constraints. Add the notebook's concrete
   short-position interpretation. Show frontier geometry before its algebra,
   explicitly display the target optimization problem, and consistently box key
   problems/results. Preserve the GMV derivation through a compact sketch and the
   complete companion link. Explain when the long-only floor binds, with the
   assumptions supporting that statement. Avoid another redundant floor-sweep slide.
4. **Closing, slides 21–24:** Specify that the held-out comparison evaluates the
   long-only GMV allocation, carry wealth and NPV here, explicitly place the
   estimation-risk advanced example after L6b, and align the three takeaways.
5. **Deck-wide:** Correct the hard-coded `L5b` footer in the local `vnslides.sty`.
   Preserve the existing fonts, theme, title slide, and second-slide disclaimer.

## Inspection completed

Read the full TeX source and compared its sequence/content with the final lecture.
Rendered all 24 PDF pages using Poppler and inspected four contact sheets; inspected
the dense target-frontier page separately at full resolution. The pages are
readable, with no obvious clipping in these renders. Eight repository notebook
links in the TeX resolve locally; remote publication was not checked. No numerical
notebooks were rerun and no slide rebuild was needed for this read-only assessment.

Local evidence is under
`build/notebook-previews/L6a-slides-review-2026-09-24/` (ignored build artifacts).
Next review section: opening objectives, examples, Dirichlet recap, and company.

## Approved opening update — September 25, 2026

The instructor agreed to begin with the opening. Applied to the TeX source and
rebuilt the native Beamer PDF, now 25 pages:

- Aligned the three objectives with the notebook and listed all three examples
  in lecture order, using L6a links and consistent example numbering throughout.
- Replaced the GBM/covariance recap with portfolio weights and Dirichlet sampling.
  Retained the constraint underbraces, allocation-simplex interpretation, boxed
  weight moments, and concentration-parameter interpretation.
- Added AllianceBernstein after concept review, with Andrew Chin's LinkedIn,
  the AI in Finance course, student opportunities, and Cornell Keynotes links.
  The company facts are condensed from the reviewed lecture.
- Moved the existing wealth/NPV recap after estimated inputs and replaced its
  obsolete statement that L5b already sampled allocations.
- Corrected the local theme footer from L5b to L6a. Fonts and design are unchanged.

Built with XeLaTeX/latexmk. The final build has no overfull boxes or out-of-page
link annotations. Rendered and inspected all 25 pages, including detailed views
of the new opening and relocated wealth slide. Exactly three objectives and
takeaways remain, and all nine repository links resolve locally. Compared the
remaining mathematical slides and Summary with the baseline: their content is
unchanged apart from example numbers. `git diff --check` passes.

Source SHA-256:
`fc1da093dc896a73373fa77d2585c7ad90a65984c6083d87a63783f3fc2138d8`

PDF SHA-256:
`bbef4ede4d08b009a78f038a0fa35162e4818bb1cc80b6530d682cf560af0a3d`

Evidence: `build/notebook-previews/L6a-slides-opening-2026-09-25/`.
Next review section: reward and risk (slides 8–13), followed by the optimization
sequence and performance closing. No new overall score assigned.

## Reward and risk review — September 25, 2026

The instructor accepted the opening and asked to continue. Compared slides 8–13
with the reviewed notebook's complete MPT section and the rendered deck. Their
sequence, equations, diversification conditions, and units agree. In particular,
the slides retain the distinction between weighted growth and buy-and-hold log
growth, the correlation condition for outperforming both individual asset
variances, the consistent growth-target scaling, and the standard-deviation risk
axis. No restructuring or mathematical correction is needed.

Proposed small clarifications, not yet applied:

- Slide 8: explicitly identify the entries of the asset growth-rate vector and
  identify `g'` as the sample-mean vector. Removing the old opening covariance
  review also removed that vector's first definition.
- Slide 11: copy the notebook's underbrace identifying
  `rho_12 sigma_g,1 sigma_g,2 = Cov(g_1,g_2)` in the two-asset variance formula.
- Slide 13: label the displayed quantity "GBM volatility" instead of "Volatility"
  to match the notebook and preserve the distinction from growth-rate standard
  deviation.

The six-slide structure and existing boxed reward/risk results should remain.
No slides changed during this assessment. After resolving these proposals,
continue with the GMV and target-frontier development.

### Approved reward/risk clarifications

The instructor approved all three changes ("Agree. Update. Next"). Applied and
rebuilt the 25-page PDF. Inspected slides 8, 11, and 13; the definitions, covariance
underbrace, and GBM-volatility label fit at the existing font sizes. The build has
no overfull boxes or out-of-page annotations. Compared frame bodies with the
saved baseline: only the three approved frames changed. `git diff --check` passes.
Evidence: `build/notebook-previews/L6a-slides-risk-2026-09-25/`.

Source SHA-256:
`8cd8ba723e069db88677717d95ce32ae5058608fb5ad52dbd92718f48835dece`

PDF SHA-256:
`5a5747285a4becb9c15baad2dc67701754f16432244e55860be17a2718daeb51`

## GMV and target-frontier proposal — September 25, 2026

Compared current slides 14–19 with the reviewed notebook. The existing algebra
is correct, but long-only material interrupts the short-allowed development and
the figure follows the frontier formula. The short-position dollar example and
the full GMV companion link are missing. The exact-target optimization is stated
in prose rather than shown as a complete constrained problem.

Propose this six-slide sequence, followed by the existing long-only section:

1. GMV problem and solution: box the optimization problem, retain definitions,
   positive-definiteness assumption, and boxed weights/minimum variance.
2. GMV derivation: retain the compact stationarity/budget/variance argument and
   link the complete derivation companion.
3. Meaning of a short position: the notebook's 1,000 USD example with weights
   1.2 and -0.2, repurchase obligation, covariance interpretation, and financing
   assumptions.
4. Frontier geometry: move the existing figure and efficient-branch interpretation
   ahead of the algebra; identify the curve as allowing short positions.
5. Exact target-growth problem: display the boxed variance objective, equality
   growth target, and full-investment constraint, with concise labels and assumptions.
6. Frontier formula: retain defined coefficients and boxed minimum variance,
   annotating the GMV variance and extra variance required by the target.

This adds two slides (27 total) and preserves the existing mathematical content.
No GMV/frontier edits applied yet. After approval and implementation, review the
long-only problem and growth-floor interpretation separately.

## Lecture changed after the slide baseline — September 25, 2026

A lecture density and flow round changed the source this deck mirrors (new
lecture SHA-256 `a36dac5b1b51b69bd204034a388b206f77f3369b787d28c2a9bff008d98419a2`;
see the lecture review record). No slides were edited. Sync when the review
reaches these slides: Objective 3 now reads “Identify which estimated inputs
each allocation depends on…”; the Estimated Inputs opening now names L4b's
log-price regression, drops the 12.8-point bullet, adds optimizer bias toward
overestimated mean growth, and motivates evaluation on unseen prices; the
negative-weight example now precedes the GMV result; the buy-and-hold
log-growth paragraph is commented out of the lecture, and the log-return box
and GBM-volatility display became a short note on conventions (see the
“Weighted Growth and Buy-and-Hold Wealth” and “Growth Rates and Log Returns”
slides). The frontier bullet now matches the deck's existing “feasible
portfolios” wording.

## Sync and close — September 26, 2026

The lecture was unchanged since its final September 25 round (SHA-256
`579199f9…`), and the deck was unchanged since the reward/risk fixes (`8cd8ba72…`).
The instructor asked to finish the review in one pass. The deck went from 25 to
23 pages and now follows the lecture's section order.

**Step 1: lecture.** The L6a data example now tests both GMV portfolios
out of sample (see the minimum-variance example record). Two lecture sentences
that said "the long-only GMV portfolio" became "both global minimum-variance
portfolios" (Examples) and "both GMV portfolios" (the data-example callout).
Two-line diff, no other lecture change.

**Step 2: sync items from the lecture rounds.**

- Objective 3 now reads "identify which estimated inputs each allocation depends
  on, and evaluate the resulting investment using wealth and NPV on prices
  reserved for testing." Example 2 now reads "Compare both GMV portfolios…".
- Dirichlet link: Distributions.jl docs replaced with the lecture's Wikipedia link.
- Removed "Weighted Growth and Buy-and-Hold Wealth" (the lecture passage is
  commented out) and the "Growth Rates and Log Returns" and "Standard Deviation
  and Volatility" slides (the lecture condensed them into a note). A one-line
  `\slidenote{Conventions:}` on the two-asset slide carries the note: log returns
  with target Δt·g⋆ give the same optimal weights, and GBM volatility is √Δt·σ_g,p.
- "Estimating Portfolio Inputs" became "Estimated Inputs": GMV uses only the
  covariance estimate, AMD sample mean 0.3120 vs L4b log-price regression 0.4397,
  the optimizer's bias toward underestimated variance or overestimated mean, and
  evaluation on unseen prices. The 12.8-point bullet was dropped, as in the lecture.

**Step 3: GMV and frontier section, in the lecture's order.** The September 25
proposal (27 pages, short-position slide third) was superseded. The sequence is
now: "What Does a Negative Weight Mean?" (1,000 USD, w = 1.2/−0.2, repurchase
cost, financing assumptions) → "The Global Minimum-Variance Portfolio" (boxed
annotated GMV-1 and boxed GMV-3) → "Deriving the GMV Weights" (unchanged, plus a
`Derivation:` slidenote linking the companion) → "The Minimum-Variance
Frontier" (the figure first, contrasted with the long-only samples in Example 1,
with an `Efficient:` definition note) → "The Target-Growth Problem" (boxed
annotated F-1 with its assumptions) → "Minimum Variance at a Growth Target"
(F-2 coefficients and boxed F-3 with the GMV-variance and extra-variance
underbraces).

**Step 4: long-only section and closing.** "The Long-Only Problem" has the
lecture's motivation, boxed annotated LO-1, and the Solution paragraph (strict
convexity, uniqueness, and short-allowed GMV staying optimal when feasible). The
old "positive semidefinite" wording was corrected. "Adding the Portfolio
Constraints" and "Tracing the Long-Only Frontier" merged into "The Growth Floor",
with the lecture's three bullets and the Example 2 note. The wealth/NPV slide
boxes W_t and ρ_T = NPV/W₀, states the sign reading and assumptions, and carries
the Example 3 note, moved from the inputs slide. Advanced 2 is placed "after
the risk-free extension in L6b". The Summary takeaways and L6b closer match
the lecture.

**Checks.** `make slides` succeeds with zero overfull boxes. Every page was
rendered and inspected, and all 18 PDF link annotations sit on their intended
pages. No clause semicolons remain in the deck (the one in the approved weights
slide was also fixed), and there are no em dashes. `git diff --check` is clean.
Codex verified the section order, the objectives, the example claims against the
data example's Task 3, GMV-1–3 and the F-3 identity with SymPy, LO-1, the growth
floor, the AMD numbers, P-1/P-2, and all 10 repository links. Accepted Codex
fixes: the target-scaling qualifier in the conventions note, "constant"
benchmark, a sign reading for ρ_T, and three one-word last lines. The disclaimer
wording (a fixed convention) and the minor omissions it listed (the Markowitz
reference, company history) were left as they were.

**Instructor follow-up.** After seeing the previews, the instructor said page 17
(The Long-Only Problem) had "too much text after the equation box" and that all
other slides were fine. The four-line paragraph after the LO-1 box (about 40 words)
became two lines: "Positive definiteness makes the solution unique. If the
short-allowed GMV weights are feasible, they stay optimal. Otherwise, we solve
numerically." The rebuild has zero overfull boxes and still 23 pages.

**Final assessment: 9.0/10 (initial 8.0).** The deck now mirrors the lecture's
order and boxed problems, carries the negative-weight example and the full
frontier development, and is two pages shorter. Remaining limitations: the
two-asset slide is the densest page, the 7.8 pt notes may be small when
projected, and "The Target-Growth Problem" is light next to its neighbors.
Classroom pacing is untested.

Source SHA-256:
`74320635a071dca21c1cb889d33bcd528da56df2bfc66b5ed4ae6613f3d96792`

PDF SHA-256:
`5ec0c2c72c760d193952e5a626819c31eafa561f58b39aac471bd260166d54c0`

Lecture SHA-256 after step 1:
`2e05ae5ded58a5974242cb324a2aa8d15138cf07636c1717d5c8a9776e6f144e`

Evidence: `build/notebook-previews/L6a-slides-sync-2026-09-26/` (ignored):
`before.tex`, `before.pdf`, `after.tex`, `lecture-before.ipynb`, the page
renders, and the before/after sheets `s0-lecture.png` through `s5-closing.png`.
