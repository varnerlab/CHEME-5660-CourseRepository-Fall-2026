# L8b build handoff — October 10, 2026

L8b (October 15) finishes the L7b story before options start in L9a. The
instructor set the order and approved the design in a brainstorming session the
same day. Nothing is committed yet.

## Design decisions (instructor, October 10)

| Question | Decision |
|---|---|
| Order | Cobb–Douglas/CES first (then the allocator example), then the capital allocation line taking CE and RP as taught (then the income-gamble survey and the CAL example), then a short derivatives closer |
| Arrow–Pratt subsection | Kept in full: it is where $A$ comes from |
| Examples | Copied into `week-8/L8b` (week bundles cannot link across weeks); L7b untouched |
| Company profile | None this time; the slot holds a Concept Review of utility functions |
| Trim of the Cobb–Douglas/CES block | Light |
| Concept Review layout | Split: utility functions at the top; a CE/RP recap opens the CAL part |
| Closer framing | A binary bet as an abstract asset with a random cash flow, priced by expected NPV under our beliefs, then the certainty-equivalent twist; ends on a question, no pointer to L9a |
| Worked numbers in the closer | None |
| Figure | TikZ timeline, approved after two changes: the payoff as a cases block ($S_T\geq K$, $S_T<K$) and "paid $T$ years from now" ($T$ in years, as in L5a) |
| L9a | Not edited; a suggested hook change is below |
| Deck | After the notebook is approved |
| Title | "L8b: Utility-Based Allocation and Bets on the Future" |

## Files

`lectures/week-8/L8b/`:

- `CHEME-5660-L8b-Lecture-Utility-Allocation-Bets-Fall-2026.ipynb`: the new
  lecture (16 markdown cells).
- `figs/Fig-L8b-Bet-CashFlows.{tex,pdf,svg}`, `Makefile`, `theme_svg.py`,
  `vnfigure.sty`, `README.md`: the L9a TikZ pipeline (light PDF for the deck,
  themed SVG for the notebook).
- Copied from L7b with "L7b" changed to "L8b" in markdown and paths only:
  both examples, the SIM reference, the tangent algorithm notebook, `Include.jl`,
  `data/SIMs-SP500-01-03-14-to-12-31-24.jld2`, `interview/` (markdown and
  script), and `advanced/` (README and the CES limits companion). The CES
  companion links the new lecture filename.
- One word-level fix in the CAL example copy (cell 24): "From the lecture's
  Concept Review," became "From the lecture," because the CAL equations now
  open the mean-variance section.

Elsewhere: `.gitignore` (L8b client and interview files), the FAQ notation
source `code/docs/faq-src/content.json` and the rebuilt
`code/docs/src/faq/notation.html` (L8b section: the four L7b tables copied, a
new "A Bet on the Future" table, the context row for $p$ extended to L8b, and
the L8b lecture link), `lectures/LECTURE-ARTIFACT-SCHEDULE.md` (row 8b), and
`AGENTS.md` (an "L8b build" section).

## Lecture outline and what changed

Previews (L7b left, L8b right, green new, red cut):
`build/notebook-previews/L8b-build-2026-10-10/1-…7-*.png`.

| Cell | Section | Source | Change |
|---|---|---|---|
| 0 | Title, LOs, Notation | **NEW** | Link sentence plus question, three LOs, `#L8b` notation link, "Let's get started!" |
| 1 | Examples | L7b | Reordered: allocator, interview, CAL example. Text unchanged |
| 2 | Concept Review: Utility Functions | L7b "Utility Functions and Rational Choice" | Heading. "later in this lecture" became "in the next section" |
| 3 | Utility over Holdings | L7b | Opens with the L7b title-cell sentence about L7a (the CAL now comes later). "Unlike the mean-variance utility," cut, since it is not introduced yet |
| 4 | Cobb–Douglas utility | L7b | Unchanged (a trimmed sentence was restored: the CES cell contrasts with "whatever the share prices") |
| 5 | CES utility | L7b | Companion link renamed only |
| 6 | Preference Weights from the SIM | L7b | Unchanged |
| 7 | Market inputs from SPY | L7b | Trims: the L5a $\omega$/half-life aside, and the 10-day vs one-year window bullets with the sentence after them. The allocator example keeps its own "Why not shorter?" paragraph on the window |
| 8 | Mean-Variance Utility on the CAL | L7b CAL Concept Review | Becomes the H2 opener, text unchanged |
| 9 | Certainty equivalent and risk premium | **RECAP** of L7b "Risk and risk aversion" | His sentences recombined: expected utility, concavity, CE and RP definitions in one display; his coin-flip block and its "Why?" reading verbatim |
| 10 | Measuring risk aversion | L7b | "next section" became "next subsection" |
| 11 | The optimal complete portfolio | L7b mean-variance section | Heading. "(Concept Review)" deleted. **NEW** transition into the closer: "The income gamble is a bet on a future salary. Let's write a bet on a future share price as an abstract asset and ask what it is worth today." |
| 12 | Derivatives: A Bet on the Future | **NEW** | Figure, payoff cases display, NPV display, expected NPV display, L5a's terminal target probability, the risk-averse buyer paragraph, the closing question |
| 13 | Optional Advanced Material | L7b | Link renamed |
| 14 | Summary | L7b + **NEW** | Opener reordered to L8b's order plus "Finally, we wrote a bet…". KT1 merges his L7b KT2 and KT3 (new wording), KT2 is his KT1 verbatim, KT3 is new. Closer: his first sentence kept; his forward pointer ("Later in the course…") replaced with a new sentence |
| 15 | Disclaimer and Risks | L7b | Unchanged |

Prose words: L7b 4,463, L8b 3,974. The Cobb–Douglas/CES block is about
10% shorter (all of it from Market inputs). The light trim landed below the 15%
estimated in the design because a cut sentence was restored.

## New prose for your review

1. The title cell: the intro, LO1 (merged), LO2 and LO3 (new).
2. The CE/RP recap paragraph (cell 9), recombined from your sentences.
3. The two seam sentences (cells 3 and 11) and the transition into the closer.
4. The closer (cell 12), about 298 words.
5. KT1 (merged), KT3 (new), the Summary's "Finally…" clause and last sentence.

## Checks

- Both examples re-executed from `week-8/L8b` with no errors. Every text
  output matched the stored L7b outputs after whitespace normalization, so the
  copies keep their stored (reviewed) outputs.
- `income-gamble.jl --dry-run` runs from the new path.
- Every relative link in the lecture resolves inside `week-8/L8b` (Codex).
- Codex math check: the expected NPV, the match with L5a's $z_\star$ (for GBM
  $S_T=K$ has probability zero, so $\ge$ and $>$ agree), and the coin-flip
  numbers (4.6052, 4.4613, 86.60, 13.40) are correct. No contradiction with
  L9a: the closer never calls a real-world price fair and states no pricing
  rule.
- Sweeps: no clause semicolons, em dashes, forward pointers, or solver jargon.
- FAQ: a build from the pre-edit `content.json` with Pandoc 3.1.11.1 reproduced
  the working-tree site exactly. After the edit, only `notation.html` changed.

## Review rounds

- Independent reviewer, round 1: 8.0. Applied: a wrong closing sentence (the
  allocator and CAL do not use NPV, and the holding utility ranks sure
  holdings), a point repeated three times in the closer, the "valued on its own"
  scope for the certainty-equivalent claim (a hedge such as insurance can be
  worth more than its expected payoff), garden-path sentences in LO3 and KT3, an
  itinerary-style intro, two splits, and the restorations noted above.
- Codex: confirmed the math and links. Applied: "the preferred budget" in KT1.
- Declined (with reasons):
  - The figure title wording and the cases block in the figure: you chose them.
  - A new seam sentence before the CAL recap: your "which $w_f$ should a given
    investor choose?" already motivates it.
  - Codex's "background wealth" rewrites: too academic for your voice.
  - Codex flags on approved L7b text ("Investors think in returns, not
    dollars.", "Then:", "How should an investor's preferences pick a
    portfolio?"): your approved text, left alone.
- Independent reviewer, round 2: 8.8. Applied: the Summary's last sentence
  (the certainty equivalent "gave the most a risk-averse buyer would pay", so
  it does not answer "What sets the price?"), the intro question back to your
  L7b wording ("How should an investor's preferences pick a portfolio…"),
  shorter LO3 and KT3 ("a risk-averse buyer of the bet alone"), and "On its
  own, the payoff is a gamble".
- Independent reviewer, round 3: **9.2**. Nothing below the bar. The rendered
  page was checked after the round. One note left for you: your Summary
  sentence "…but it takes the intercepts and betas as fixed…" now states a
  limitation that nothing follows up, since its forward pointer is gone.

## For L9a (not edited)

L9a's hook now partly repeats the L8b closer. A suggested one-sentence change
for your L9a pass:

> In L8b, we wrote a bet that pays one dollar if a future condition is true as
> an abstract asset and asked what sets its market price. A Kalshi contract is
> such a bet. What is a payment that may never arrive worth today?

## Instructor approval and the deck (October 10)

The instructor approved the notebook ("Approved"). The two decisions offered
with it kept the approved design: the window-bullet cut stays, and his Summary
sentence "…but it takes the intercepts and betas as fixed…" stays as written.

Deck: `lectures/week-8/L8b/slides/CHEME-5660-L8b-Slides-Fall-2026.tex`
(28 pages, zero overfull boxes, every page rendered and checked). It was
assembled from the L7b deck, with frames sliced verbatim and each edit applied
as a checked replacement, in the notebook's order:

- Title, objectives (the L8b LOs), and Lectures and Examples (Example 1
  allocator, the interview, Example 2 CAL).
- Concept Review: Utility Functions and Common Utility Functions ("later today"
  became "next").
- Utility over Holdings (the opener matches the notebook seam), the three
  Cobb–Douglas frames, and CES, all verbatim apart from the link.
- Preference weights, EMA (the L5a aside cut), the market-state signal, and the
  recent market growth (the window bullet cut). The Example 1 stop follows.
- Mean-Variance Utility on the CAL (the L7b CAL review frame, title shortened so
  it fits on one line).
- Certainty Equivalent and Risk Premium (a recap lead plus the L7b coin-flip
  frame), Arrow–Pratt, Mean-Variance Utility, the Optimal Complete Portfolio,
  and Indifference Curves.
- **New** "Measuring $A$ with Income Gambles": mirrors the notebook's BJKS
  paragraph, with the interview and Example 2 stops. This closes the L7b deck's
  missing interview frame for L8b. The L7b deck itself is unchanged.
- **New** bet frames: the figure (PDF), "A Bet as an Abstract Asset" (payoff,
  NPV, expected NPV, L5a probability), and "What Would a Risk-Averse Buyer
  Pay?" ending on "What sets the price?".
- Optional Advanced Material, the Summary (the L8b takeaways), and the closing
  line.

## Deck trim (October 10)

At the instructor's request ("several very dense text passages ... make the
text shorter"), the prose in 18 frames was cut by about a quarter (2,067 to
about 1,690 prose words for the whole deck). Every equation, box, table, link,
and example stop was kept. The Disclaimer and the light frames are unchanged.
Previews: `build/notebook-previews/L8b-build-2026-10-10/deck-trim-1..3.png`
(before on the left, after on the right). The deck still has 28 pages and zero
overfull boxes. Three layout fixes followed: a formula that wrapped onto its own
line now reads "the discounted expected payoff", and two last-line orphans were
removed. The notebook is unchanged. The instructor approved the trimmed deck ("Ok - looks good").

## CE/RP term labels (October 11)

At the instructor's request, the CE/RP display (notebook cell `8b0ce001`, deck
frame "Certainty Equivalent and Risk Premium") now labels each term with an
underbrace: "utility of the sure wealth", "expected utility of the risky
outcome", "expected wealth", and "sure wealth". In the coin-flip example, the
CE row now reads CE = U⁻¹(𝔼[U(W)]) = e^4.4613 ≈ 86.60, with the reason
"U⁻¹(x) = eˣ undoes ln, USD" (it was "solve ln CE = 4.4613 for CE"). He then
asked for the definition to carry the explicit form too ("super helpful"). The
notebook display is now a three-row align with a reason column, using his L7b
reasons: U(CE) = 𝔼[U(W)] ("definition of the CE"), CE = U⁻¹(𝔼[U(W)]) ("U is
increasing, so apply U⁻¹ to both sides"), and RP = 𝔼(W) − CE ("definition of
the RP"). The "CE:" prefix is gone. On the slide, the box has CE and RP side by
side with CE = U⁻¹(𝔼[U(W)]) under the CE definition, and the display skips on
that frame are 3pt so it fits. The deck is still 28 pages with zero overfull
boxes. Preview: `build/notebook-previews/L8b-build-2026-10-10/8-ce-term-labels-and-inverse.png`. He approved the result ("Looks great").

## Algorithm notebook, three dense blocks (October 11)

The instructor found "Why does this work?" and "Why check the 100% limit?" in
the tangent algorithm notebook "too dense", in organization as well as length.
Those two blocks, and "How does this differ from the version shown in lecture?",
are now each one lead sentence, three labeled bullets, and one closing sentence
(cells `93c4702d` and `0978b1ef`). The same text was applied to the L7b
original. The full record, including why the checks missed it, is the
"October 11" section of `L7b-LECTURE-REVIEW-HANDOFF.md`.

## Open

- Committed and pushed on October 11 at the instructor's request ("commit,
  push = but no release yet"). The options archive move it depended on was
  already in 84b8818.
- A week-08 release when the instructor asks for it (per the weekly release
  checklist). He said no release yet on October 11.

## Re-score of every L8b artifact (October 12)

The instructor asked whether any L8b material scores below 9, confirmed with
Codex. Three independent Claude reviewers and three Codex runs scored the
committed files (`4cb3b2a`) with one brief:
`build/notebook-previews/L8b-review-2026-10-12/qa-brief.md`. The manager read
every rendered page and the deck.

| Artifact | Claude | Codex | After fixes |
|---|---|---|---|
| Lecture | 9.2 | 8.6 | 9.2 |
| Deck | 9.1 | 9.5 | — |
| Figure | 9.3 | 10 | — |
| Allocator example | 9.0 | 8.8 | — |
| CAL example | 8.7 | 9.2 | Codex 9.1 |
| Tangent algorithm | 9.1 | 9.2 | — |
| SIM reference | 8.8 | 8.8 | Codex 9.2 |
| CES companion | 9.2 | 8.8 | — |
| Interview | 9.2 | 8.9 | — |

Fixed (markdown only, on disk, not committed). The first two are copy
defects from L7b, whose order and week differ:

- CAL example, cell 38: "The next example writes the investor's
  preferences…" became "The [allocator example](…) wrote…". In L8b the
  allocator comes before the CAL example.
- SIM reference, cell 0: "the week 7 examples solve" became "the examples
  solve".
- Lecture, cell 12 (instructor approved): "below the discounted
  probability" became "below its discounted expected payoff". The price is
  in USD, so the comparison is to a payoff, not a probability.

Codex scores set aside:

- Lecture 8.6 and CES 8.8 came from nbconvert preview artifacts: math tables
  squeezed, and `___` under a paragraph shown as text. In VS Code's renderer
  (markdown-it + KaTeX, `vscode.png`) both tables and both rules render
  correctly.
- Allocator 8.8 rested on cell 49, "That is where the two paths separate."
  A scratchpad run of the notebook's code measured the gap between the daily
  and monthly paths. It stayed at most 0.8% of W₀ while all 13 firms were
  preferred (days 1–37). It reached 8.5% by day 99 and 13.7% at its peak,
  after the basket started changing on day 38, so the sentence holds.
- The lecture's 86-word allocator stop repeats the Examples entry, as in the
  approved L7b lecture.

Previously declined items (October 9) came up again and were not deducted:

- the CAL lend/borrow rule stated more than once;
- the interview's "each halve the range of cuts" (approximate; "narrow" is
  the word-neutral fix);
- `println` after the checks in allocator cells 16, 20, and 32.

Left unchanged for the instructor's manual pass (October 13):

- Deck frame 18: "larger $r$ means a lower CE" leads into the RP formula.
  "larger RP" matches the display and the notebook (cell 10) with no added
  words. A deck edit needs a rebuild: 28 pages, zero overfull boxes.
- Interview: "each halve" to "narrow" (above), and "halve" to "narrow" in the
  `income-gamble.jl` comment, line 7.
- Algorithm notebook: the heading "How does this differ from the version
  shown in lecture?" now reads as the L8b lecture; "the L7a version" is
  shorter.

Codex's preview deductions came from the `nbconvert` HTML export, which prints
a `___` placed directly under a paragraph as underscores. VS Code draws it as
a rule, as CommonMark specifies. The same pattern appears 252 times across the
course notebooks, so it was not counted against L8b.

Closed October 12: the instructor marked the week-8 material reviewed (L8a is
the Fall Break, with no lecture). He will do a manual pass on October 13,
then make the week-08 release. The lecture was backed up for the
voice-calibration comparison before that pass.
