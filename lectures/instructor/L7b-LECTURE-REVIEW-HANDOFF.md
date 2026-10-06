# L7b lecture polish round — paused at the opening assessment

Notebook: `lectures/week-7/L7b/CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb`
Opened: October 3, 2026, using the notebook-polish workflow
(`.agents/skills/notebook-polish/SKILL.md`). The instructor paused the round after
the opening assessment ("save this review for L7b and we can do this later"). No
polish edits have been made yet. Resume at step 1 below, with a before/after
preview.

## Snapshot reviewed

The lecture as left after the October 3 Cobb–Douglas work (see the October 3
section of [WEEK-7-REFACTOR-HANDOFF.md](WEEK-7-REFACTOR-HANDOFF.md)). The
instructor's model is restored, W_adj is derived from the budget constraint, and
the pin-and-solve floor rule is in place. About 3,050 prose words in 11 markdown
cells, all uncommitted. A rendered copy of this snapshot is in
`build/notebook-previews/L7b-polish-2026-10-03/current.png` (gitignored).

## Opening assessment: 8.2 / 10

| Dimension | Score | Evidence |
|:--|:--|:--|
| Technical correctness | 8.8 | Math and units check, including the floor fix. One sentence fudges units: the tanh argument is in inverse years, read "as a pure number at a one-year horizon" (cell 7). |
| Organization | 8.0 | Logical arc. "Utility over Holdings" (cell 6) is one cell holding an H2 and two H3s, and its general maximum-utility box and Cobb–Douglas box show nearly the same problem back to back. |
| Narrative flow | 8.5 | Good bridge questions ("Which w_f should a given investor choose?", "What if we write down … for each asset instead?", "Where do the preference weights come from?"). Pratt's small-risk result ties Arrow–Pratt to the mean-variance A. |
| Presentation | 8.0 | No KaTeX errors, compact tables. The Cobb–Douglas derivation is now nine lines, and the "Market inputs" box (cell 7) is text-heavy. |
| Density and pacing | 7.5 | About 3,050 words and six new ideas for one class with two examples: utility, risk aversion and Arrow–Pratt, the CAL optimum and its inversion, Cobb–Douglas and CES with floors, the SIM preference model, and the EMA market inputs. |

Style sweep: no em dashes and no clause semicolons. About six real sentences run 27–31
words: the CES-limits sentence under the utility table (cell 3), the expected-utility
and Pratt sentences (cell 4), the η → ∞ bullet (cell 6), and "A strong market pulls in
…" (cell 7).

Not to be reopened: the utility and risk sections (cells 3 and 4) were ported from the
instructor's CHEME 5760 Decisions Book and approved on October 2 after two revisions.
Fragile Inputs and marginal utility were removed at his request. The Cobb–Douglas
model and floor rule were decided on October 3.

October 5: the instructor reopened the risk section himself and asked for a tighter
certainty-equivalent and Arrow–Pratt passage that shows how the two connect. Approved
and applied, with the deck's Arrow–Pratt frame synced. He then asked for a less dense
frame and approved a version with about 40% fewer words: absolute and relative labels as
underbraces in the box, a one-line sign key, "For a small risk, larger r means a lower CE:"
over a centered Pratt display, and a two-line portfolio note.

Also October 5: the instructor found the Mean-Variance Utility section unclear ("charges for
risk") and asked for simple, direct wording. Approved and applied, word-neutral (328 words).
It now opens "We choose w_f by maximizing the investor's utility." The reward and risk-penalty
underbraces are gone. A "sets how much the investor dislikes variance." A new "Who lends and
who borrows?" label was added, the indifference curve is a display, and the inverse formula
states w_f < 1. Codex (SymPy) confirmed the math. The three deck frames (Mean-Variance Utility,
The Optimal Complete Portfolio, Indifference Curves) were synced to match, with no overfull boxes.

Also October 5: the instructor asked whether to explain the EMA in the Preference Weights
section. The cell called its window-based EMA (omega = 2/(L+1)) "the EMA of L5a", but L5a set
lambda by a half-life with a 21-day default, while a 21-day window has a half-life of about
7.27 days. Approved and applied: a plain definition, the EMA as a display, the L5a link
(omega = 1 - lambda), the 7-day sentence, and "The short EMA responds faster to price changes
than the long EMA" in the Market inputs box. A table of the three windows was drafted and
dropped at his request, since it added nothing. Prose 121 to 181 words in that part. Codex
confirmed every claim against compute_ema and L5a. The deck's Market Inputs frame overflowed
with the addition, so it was split into "Exponential Moving Averages" and "The Market Inputs",
with no overfull boxes. The passage now opens with "The more concave U is,
the further the CE falls below E(W)." Pratt's RP ≈ ½ r(E(W)) Var(W) is now a display right after the
definition box. The two constant-relative-risk-aversion sentences are cut, and prose went from 211 to
189 words. Codex confirmed the math (numerical Pratt check on ln w and √w). It also noted that in true
log growth the mapping is A = r̄ − 1. The course treats portfolio growth as linear in the asset growth
rates, so the text keeps "the form of … with A in the role of r̄." The instructor's own
hand edits to the opening, the Concept Review, and cells 4–5 (seen at 11:31 that day) are his, not the assistant's.

## Proposed sequence (not yet started)

1. **Utility over Holdings: structure (recommended start).** Give each subsection its
   own cell (H2 intro, Cobb–Douglas, CES), as in the accepted L7a review. Fold the
   general maximum-utility box into the Cobb–Douglas box: keep the "holding utility"
   framing, and show the problem once. This removes one display and shortens the section.
2. **Preference Weights from the Single Index Model** (cell 7, about 530 words).
   Tighten the "Market inputs" box and the paragraph after it, and fix the "pure
   number at a one-year horizon" sentence. Keep both bold questions.
3. **Long sentences.** Split the six sentences listed above. This is word-neutral.
4. **Company profile: done October 5, 2026.** The instructor chose Wealthfront and
   approved the draft as shown ("Looks really well done"). The cell sits between
   the Concept Review and "Utility Functions and Rational Choice" (about 360 words):
   Risk Score questionnaire, the 2012 utility-tangency post, and Black–Litterman
   reverse optimization, with a connection that runs the optimum backward (w_f → A,
   market weights → expected returns). Codex found no factual errors. Sources: the
   March 9, 2026 methodology white paper, the September 9, 2026 SEC 8-K release, and
   the Lever board (no internships on October 5). The deck got a matching profile
   frame (slide 6, after the Concept Review) the same day, with no overfull boxes.
5. **Close.** Check the objectives, takeaways, and summary against the final text,
   then rescore. The round is not done below 9.0.

## Pending at pause: Codex check of the October 3 Option 2 edits

The check finished after the pause. The math holds: the package helper matched an
independent multiplier-bisection solver on 300 of 300 random cases, with a maximum
scaled error of 1.07 × 10⁻¹³. The tests check what their comments say, and the
example's stored values match its prose except item 5. Fix these before or alongside
step 1. Wording changes go through a preview.

1. **Lecture cell 6.** Two claims need "when no preferred floor binds": the
   Cobb–Douglas dollar weight γ_i/Σγ_j "independent of prices", and the CES intro
   "The Cobb–Douglas allocator always spends on every preferred asset in proportion
   to γ_i". Codex's wording: "When no preferred floor binds, Cobb–Douglas splits the
   preferred budget in proportion to the preference weights."
2. **CES companion cell 4.** Label the boxed zero-holdings η → ∞ limit as the case
   without floors. The floored sentence after it is correct.
3. **Deck.** The allocation frame's pin rule should say to subtract the pinned cost.
   The dollar-weight line needs the same qualifier as item 1, and the frame omits the
   empty-preferred-set cash convention. The frame also opens with a display that has
   no lead-in (the lead sentence moved to the previous frame to fit).
4. **Course package (`_allocate_with_floors`).**
   - `eta = 1000` can return NaN, because `(gamma/S)^eta` underflows. Normalize by the
     largest ratio before the power. This was already true of the original code.
   - Budget deficits below about 1.5 × 10⁻⁸ USD pass the tolerance check.
   - The docstrings say "exact" without conditions. With `epsilon = 0` (the default),
     an asset with γ < 0 has an unbounded utility term, so the problem is not
     well posed even though the code runs.
   - The loop comment should say that each nonterminal pass pins at least one asset.
5. **Utility Allocator example, cell 38.** "Its allocation on the preferred set is
   n_i ∝ (γ_i/S_i)^η" is no longer true at η = 5, where AAPL and MSFT sit at the floor.
   Codex's wording: "Among preferred assets above the floor, share counts are
   proportional to (γ_i/S_i)^η."
6. **Style.** The lecture's pin-rule sentence and η → ∞ bullet run over 25 words.
   Codex also flagged the companion's "this ρ … not the correlation of L5a" as a
   denial. Recommend keeping it: students met ρ as a correlation in L5a, so the clash
   is a real trap.
