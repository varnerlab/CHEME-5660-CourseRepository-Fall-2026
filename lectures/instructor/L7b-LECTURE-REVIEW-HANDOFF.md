# L7b lecture polish round

Notebook: `lectures/week-7/L7b/CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb`
Opened: October 3, 2026, using the notebook-polish workflow
(`.agents/skills/notebook-polish/SKILL.md`). The instructor paused the round after
the opening assessment ("save this review for L7b and we can do this later").
On October 6 the instructor asked for a polish, voice, and navigation pass if the
lecture scored below 9. It was applied in one round, and he approved it the same
day ("Agree to edits. Update"). See the October 6 section. A second pass, after the
instructor's October 8 certainty-equivalent edits, was approved on October 9. See the
October 9 section at the end.

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

## October 6 pass: polish, voice, and navigation (approved October 6)

The instructor asked for "a polish/voice/navigation pass ... if the score is less
than 9 out of 10." The baseline is HEAD `84d9177` (the lecture last changed in
`145204b`, which holds his October 5 hand edits). It opened at 8.3, so the pass
was applied in one round, as in the allocator round. The instructor reviewed the
before/after previews and approved every change ("Agree to edits. Update"). The
notebook's SHA-256 is `5f1794c361db2073061095034c7d18e79988b143d6bf1082bd196c19058d5207`.
It is not committed yet.
Before/after PNGs are in `build/notebook-previews/L7b-lecture-polish-2026-10-06/`
(gitignored).

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.5 | 9.1 |
| Organization | 8.0 | 9.0 |
| Narrative flow | 8.7 | 9.0 |
| Presentation | 8.4 | 9.0 |
| Density and pacing | 8.0 | 8.5 |
| Navigation | 7.8 | 9.2 |
| **Overall** | **8.3** | **9.0** |

Codex scored HEAD 8.0 to 8.3 and the final version 9.0 over two runs. Prose went from
2,836 to 2,820 words (Disclaimer, displays, tables, and link targets excluded). The
lecture went from 12 to 15 markdown cells.

**Changes.**

1. **Utility over Holdings, one cell per subsection** (step 1 of the October 3
   sequence). The H2 intro, "Cobb–Douglas utility", and "CES utility" are separate
   cells. The general "Maximum-utility problem" box is gone, and the Cobb–Douglas box
   is the only problem statement. A "where" line under that box defines
   $\mathcal{P}$, $n_i$, $S_i(t)$, and $W_{\mathcal{P}}(t)$ with units. The holding-utility framing
   stays in the intro: "The investor chooses share counts that maximize a holding
   utility, a preference over the shares held today at today's prices. Unlike the
   mean-variance utility, a holding utility has no variance term." "The workhorse is"
   became "We start with".
2. **Floor qualifiers** (October 3 Codex item 1). "When no preferred floor binds, the
   dollars in each preferred asset are proportional to its preference weight,
   whatever the share prices." The CES intro's "always spends on every preferred asset
   in proportion to γ_i" was cut, and CES now "adds one parameter to Cobb–Douglas".
   "Among preferred assets above their floors, share counts are proportional to
   (γ_i/S_i(t))^η". The companion sentence's "while the Cobb–Douglas weights do not"
   was cut, because that claim needs the same condition, which the previous subsection
   now states. "the allocation is the floors plus cash" became "the allocator holds
   the floors plus cash", the wording of the basket bullet.
3. **Preference Weights.** The EMA, the Market inputs box, and the example stop moved
   under a new H3, "Market inputs from SPY", with no wording change. The units
   sentence is now "Multiplying the argument, in inverse years, by a one-year horizon
   makes it dimensionless with the same numerical value." The course code applies tanh
   to the growth-rate value directly (allocator example cells 25 and 29).
4. **Long sentences split** (step 3, cells 7 and 8 only): the pin rule, the η → ∞
   bullet ("The asset with the largest γ_i/S_i(t) gets the whole budget above the
   floors, when that asset is unique. Every other asset falls to its floor."), and "A
   strong market pulls in … A weak market keeps …".
5. **Small fixes in the instructor's text:** "### Risk and Risk Aversion" became
   sentence case, like every week-6 and week-7 H3. "risk free" is now "risk-free", and
   the Summary closer gained its missing subject: "Later in the course we will
   return to these ideas …".

**Checks.** nbformat validates, and the eight untouched cells, their ids, and the
notebook metadata are byte-identical to HEAD (Codex, Python diff). Every markdown cell
renders through VS Code's KaTeX with zero errors. All relative links resolve. Both Codex
runs confirmed the floor claims against `_allocate_with_floors` in
`code/src/AdaptivePortfolio.jl`, the η → ∞ limit with floors, and the threshold reading.
They found no long sentences, em dashes, clause semicolons, or vague referents in the
changed sentences.

**Not changed (approved or the instructor's).** The opening and objectives, the Concept
Review, the Wealthfront profile, the utility and risk sections, mean-variance utility,
the EMA text and Market inputs box, and the takeaways. Their remaining long sentences
are his. Steps 2 (Market inputs box) and 3 (long sentences in cells 3–4) of the
October 3 sequence were not applied, because those passages were rewritten and approved
on October 5.

**Open for the instructor.**

- *Empty basket and the budget equality.* Codex notes that floors plus cash leaves the
  boxed equality budget unmet when no asset is preferred. The lecture states it as the
  allocator's rule. Reconciling it would change the October 3 model statement, so it is
  his call.
- *Summary closer.* "Later in the course we will return to these ideas when we build a
  dynamic portfolio allocator …" points to future material. It is his sentence and has no
  date, so it was kept.
- *October 3 Codex items 2 and 4* (the CES companion label and the package's η = 1000
  underflow and tolerance) are untouched. Item 5 was fixed in the allocator round.
- *Examples sentence.* "The first example runs on the firms and risk-free fraction chosen in
  the L6b client interview, or on defaults when the interview files are absent" matches the
  CAL example today. If that example gets the October 6 L7a change (defaults unless the
  client-file lines are uncommented), update this sentence too. Both L7b examples still
  cite SIM-3, which the October 6 L7a lecture dropped. Resolved October 8: SIM-3 was
  restored in the L7a lecture, and the Concept Review now links the L7b algorithm notebook.

**Deck sync (October 6, at the instructor's request).** Five frames now match the
approved lecture. "Utility over Holdings" lost the general box and keeps the
holding-utility framing as text. "Cobb–Douglas Utility" defines $\mathcal{P}$, $n_i$, $S_i(t)$,
and $W_{\mathcal{P}}(t)$ with units under the box. "Cobb–Douglas Utility: Allocation" opens
with a lead-in ("Adding the multiplier λ for the net budget gives:"), and its pin rule
subtracts the pinned cost ("With no binding floor, dollars are proportional to γ_i"). The CES frame
says "CES adds one parameter to Cobb–Douglas", "share counts above the floors", and has the
new η → ∞ bullet. "Preference Weights" adds "made dimensionless by a one-year horizon".
This closes October 3 Codex item 3. The deck builds with zero overfull or underfull boxes
and still has 24 pages, though page 17 is tight. Codex confirmed agreement with the
notebook, the math, and lead-ins for all 19 displays. The before/after preview is
`build/notebook-previews/L7b-lecture-polish-2026-10-06/4-deck-sync.png`. The deck is not
committed and has not yet been reviewed by the instructor.

## October 7: income-gamble interview (approved October 7)

The instructor asked for an interview, run in lecture like the L6b client interview,
that identifies the certainty equivalent and relates it to $A$. A certainty-equivalent
titration was proposed first. He chose the published income gambles of Barsky, Juster,
Kimball, and Shapiro (1997) instead ("I like this because it is published"), asked for
student wording, and raised the coarseness of the published categories. Then he caught
that only the first job's salary was protected from inflation. He approved the design
and then the previews ("agree - well done").

**Design decisions.**

- *Published instrument.* The 1998 HRS frame offers two new jobs, which removes status
  quo bias. It has the six categories of Kimball, Sahm, and Shapiro (2008, JASA 103,
  1028–1038): cuts of 10%, 20%, a third, a half, and three quarters, with boundaries
  at r̄ = 7.53, 3.76, 2, 1, and 0.31. HRS 2002 shares: 44.8, 18.6, 15.3, 9.6, 6.1, and 5.6%.
- *Student wording.* A graduating student weighs two offers, $100,000 a year sure, or
  50–50 $200,000 or the cut. "All salaries are in today's dollars and rise with inflation"
  applies to both jobs and stays on every screen. An inflation clause on only the
  first job would bias answers toward it.
- *Coarseness fix (our extension, labeled as such).* On the default line, A_T = 4.96 (an
  in-sample annualized Sharpe ratio of 1.32) falls inside category 2, so three of the four
  L6b answers shared a category. After the published questions, two more questions in
  the same form halve the range of cuts. In category 2 these are 15% (r̄ = 5.08 ≈ A_T),
  then 12.5% or 17.5%. Each L6b answer then lands in its own band. Category 6 has no
  refinement. Clients answer four or five questions in total.
- *Mapping to A.* The bounds solve ½U(2) + ½U(1 − δ⋆) = U(1) for a power utility, with
  A = r̄ as the lecture's risk section states. Pratt's small-risk formula would give much
  smaller cutoffs for gambles this large (3.0 rather than 7.5 at the 10% cut), so it is
  not used.
- *Symbol.* The approved previews used λ for the cut. At apply time it became δ, because
  L7b already uses λ for the Cobb–Douglas budget multiplier, and the notation page lists
  λ with three meanings. δ is unused in L7b.

**Files.**

- New: `lectures/week-7/L7b/interview/interview.md` (Steps 1–3 published, Step 4 our
  extension, Step 5 script, Step 6 the CAL example, and an optional class poll) and
  `interview/income-gamble.jl`. The script uses only the standard library, replays
  `--answers=first,second,…`, prints the category, its HRS share, and the bounds on r̄,
  and writes `data/my-risk-aversion.toml`. It writes its own file so that it never
  overwrites the L6b `my-client.toml`. The new file is in `.gitignore`.
- Lecture, cells 0, 1, 6, and 13. Objective 1 and Takeaway 1 mention income gambles.
  The Examples list adds the interview first, and "The first example runs …" became
  "The capital allocation line example runs …", plus "It also reads the income-gamble
  range when that interview has run." Cell 6 adds "__Can we measure $A$ without asking for
  $w_{f}$?__", the indifference display, the ln w and −1/w checks (each = U(1)), and one
  shared "__Examples:__" stop for the interview and the CAL example. Reverting these four cells
  reproduces the October 6 SHA `5f1794c3…` exactly. New lecture SHA-256:
  `3b8d882063af059c7692fd3aeb54981e3f4b41c6fcb158b859184fe4984b3aef`.
- CAL example, cells 8, 9, and 31–33. Cell 9 reads `client_A_range` if the file exists. The
  Task 3 table adds "income gamble, low A" and "income gamble, high A" rows with w_f\*, and a line
  says whether the A behind the client's L6b answer falls inside, above, or below the range.
  One sentence was added to the reading. Re-executed with no interview file: every text
  output is identical to the October 6 outputs. Also run with category 2 (6.08–7.53,
  default client inside), category 6 (w_f\* = −Inf at A = 0), and category 1 with no cut
  accepted (A = Inf, w_f\* = 1), with no errors. SHA-256:
  `2050a9346bf3f285b84c6a521f95495d46041d88fd3ffb7238be5193fb520d1e`.
- Notation FAQ. One new row in the L7b mean-variance table (δ, δ⋆), and the context row for δ
  lists L7b (347 entries). The site was rebuilt with Pandoc 3.1.11.1, and only
  `notation.html` changed. The answer audit has an October 7 note.
- Script check: all 21 complete answer paths reproduce the thresholds computed
  independently in Python. Too many answers and invalid answers stop with a clear error.

**Previews.** `build/notebook-previews/L7b-income-gamble-2026-10-07/` (gitignored), with λ
in place of δ.

**Open.** The deck has no interview frame yet. The instructor agreed to add one as a
separate step. Nothing is committed. The October 6 "Examples sentence" item above still
applies if the CAL example adopts the L7a default-file change.

## October 7: client tickers in the allocator example (approved October 7)

The instructor edited allocator cell 14 so that it reads `data/my-tickers.csv` when the L6b
client interview files are present, as the CAL example does. The edit was checked on the
default firms and on the defensive (17 firms), market (22), and aggressive (17) interview
lists. All four run with no errors, and the allocation date is t⋆ = 3 for each. The default
outputs are unchanged.

Approved follow-up changes:

- Allocator cell 37: `@assert maximum(w_risky) < 1 - 1e-6` after the tangent solve, worded as
  in the L7a RRFA example. The fixed target R = 0.30 left headroom on the tested lists (the largest
  unscaled weights were 0.39, 0.59, 0.85, and 0.87), but a binding bound would have rescaled
  silently to a wrong tangent portfolio.
- Allocator cell 13: the CAL example's sentence about `data/my-tickers.csv`. Cell 32: the
  bearish-signal reading now says that preferred weights with β > 1 fall and those with β < 1
  rise. The old "every preferred weight here falls" was false for the defensive list. Cell 50:
  "thirteen firms" became "our firms".
- Lecture cells 1 and 11: "thirteen firms" became "our firms" in the allocator stop. The closing
  note in cell 1 now says that both examples read the client's firms.

The allocator was re-executed on the defaults. Text and PNG outputs are identical. Only the
SVG clip ids changed, and cell 14 now stores "M = 13 firms: …". New SHA-256 values are
allocator `9c807f2416902f527e84ee1dbc93e1e4a99a3610c0e31f970961691d17c51524` and lecture
`859a9a92da9a6a8632eb80b74023b77adfc6859b86095d8f06b5b05815209d94`. Previews are in
`build/notebook-previews/L7b-allocator-tickers-2026-10-07/`.

Left as is: the cell 35 hand check does not apply the pin rule. Among screened lists, a
preferred firm falls below its floor only when a firm such as TDG or NVR is added with `--add`,
and the assert then stops loudly. Cells 40 to 48 and Takeaway 2 describe the default run, and
cell 40 already says results may differ. The L7a examples read the client file only after it
is uncommented. Both L7b examples read it automatically.

## October 9 pass: polish, voice, and organization (approved October 9)

The instructor asked for "a polish/voice/organization pass on this lecture notebook if
it's score is less that 9 out of 10" after hand-editing it on October 8 (the
certainty-equivalent material in the risk section and the Wealthfront profile, committed in
`f9d95b5`). The baseline is HEAD `242cdd1`, where the lecture last changed in `55be3a2`.
It opened at 8.2, so the pass was applied in one round. The instructor approved the lecture,
example, and notation changes from highlighted previews ("Agree - well done"), and then the
deck sync and two small fixes ("Approve"), and finally the rounding fix below ("Agree").
Lecture SHA-256: `451e65cc7bce12697998f6b4f3bd7fc8b19239d97d6f860712c27221ebde3e74`.
Nothing is committed.
Previews with word-level highlights (green new, red removed) are in
`build/notebook-previews/L7b-lecture-polish-2026-10-09/` (gitignored).

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.5 | 9.2 |
| Organization | 7.8 | 9.0 |
| Narrative flow | 8.7 | 9.0 |
| Presentation | 8.5 | 9.1 |
| Density and pacing | 7.5 | 8.4 |
| Navigation | 8.4 | 9.1 |
| **Overall** | **8.2** | **9.0** |

Codex scored HEAD 8.3 and the applied version 8.9. The two small fixes below close its two
remaining wording items. Prose went from 4,194 to about 4,056 words. The lecture went from
15 to 16 markdown cells. Density stays the lowest score because the certainty-equivalent
material is long, and that material is the instructor's and was kept.

**Instructor decisions.**

- *Explicit horizon.* The instructor rejected "Multiplying the argument by a one-year horizon
  makes it dimensionless with the same numerical value" ("what?") and proposed writing the
  argument as Δt·(g/β) with Δt = 1. The symbol is h = 1 year, because L7b already uses
  Δt = 1/252 for the daily step (12 times in the lecture, 8 in the CAL example), τ is the
  power-utility exponent, and the subscripted h_i on the notation page is a different symbol.
  Scope: the lecture, the allocator example's display, the notation page, and the deck.
- *Concept Review paragraph deleted.* "L7a found T by solving … SIM-2 … The continuation
  algorithm derives SIM-3 …" was "Not load bearing, and is confusing". Both examples still
  link the algorithm and SIM reference notebooks (CAL cell 15, allocator cells 33 and 35), so
  the lecture no longer links the algorithm notebook. This supersedes the October 6 note that
  "the Concept Review now links the L7b algorithm notebook".
- *Risk section, all four options:* split into two H3s, state the small-return step, cut the
  restated line, and flag ordinal versus expected utility.
- *Preference reading after the box,* and the full in-lecture example stops kept.
- *Market-strength sentences.* "A strong market pulls in assets with a small negative α_i and a
  large β_i. A weak market keeps only the assets with the lowest thresholds." was "confusing".
  The replacement says what changes as the market growth moves.

**Lecture changes** (cells named by id).

1. `40320cbd` Examples. The closing sentences now say that both examples use the default firms,
   that uncommenting the ticker-file lines uses the L6b interview firms, and that the CAL example
   reads the client's risk-free fraction and income-gamble range when those files are present.
   This matches the code (the ticker-file lines are commented out in both examples) and closes
   the October 6 "Examples sentence" item.
2. `121b2d7a` Concept Review. The paragraph above is deleted, and "However, which $w_{f}$ should
   a given investor choose?" joins the two-fund paragraph. The cell now reads as on October 7.
3. `6b4e8514` Risk and risk aversion. Adds "Unlike the ranking of sure outcomes, this ranking
   survives only an increasing linear transformation $aU+b$ with $a>0$, so the shape of $U$ now
   matters." Cuts "For a risk-averse decision-maker, CE ≤ E(W) and RP ≥ 0", which the chain
   above it already shows. The cell is split at "__How risk averse is a decision-maker?__".
4. `a7c3e5d1` (new) Measuring risk aversion. The instructor's text, unchanged except that the
   certainty-equivalent return step is now two lines with reasons ("substitute, divide by
   $W_{0}$" and "small return, so $\mathbb{E}(W)\approx W_{0}$").
5. `4e515081` Preference Weights. The box is
   $\gamma_{i}(t) = \tanh(h[\alpha_{i}/\beta_{i}^{\xi_{t}} + \beta_{i}^{1-\xi_{t}}\tilde{g}_{M,t}])$.
   The where-line defines $\tilde{g}_{i,t}$, states that the argument is
   $h\,\tilde{g}_{i,t}/\beta_{i}^{\xi_{t}}$, and says that $h = 1$ year makes it dimensionless.
   The reading that was split before and after the box is now one "We read the preference
   weight in two parts:" list after it. *Sign* covers the threshold
   $-\alpha_{i}/\beta_{i}$, the basket growing as $\tilde{g}_{M,t}$ rises, only the
   lowest-threshold assets staying as it falls, and floors plus cash when the basket is empty.
   *Magnitude* covers the budget share and the tilt by $\xi_{t}$.
6. `1739f0f5` Summary. Takeaway 1 now covers the certainty equivalent and the Arrow–Pratt
   coefficient. The closer is split into two sentences, and "reads the basket from their signs"
   became "from the signs of the preference weights" (Codex: "their" pointed at the intercepts
   and betas).
7. `6b4e8514` again, the ln W coin flip (found by the Codex deck check). The display rounded
   $\mathbb{E}[U(W)]$ to 4.461 and then gave $e^{4.461}\approx 86.60$, but $e^{4.461}=86.57$.
   It now carries four decimals: 4.6052, 4.4613, and $e^{4.4613}\approx 86.60$. The CE, the RP,
   and the reading are unchanged. The exact value is $\sqrt{50\cdot 150}=86.6025$. The
   instructor chose this over replacing the line with the geometric mean, which is not a step
   in the derivation. Preview: `11-ce-rounding-fix.png`.

**Allocator example.** Markdown cell `a539b279` only. The display gains $h$, followed by "where
the horizon $h = 1$ year makes the argument dimensionless, so the code below omits it." The
sign bullet uses $h$, and its 28-word sentence is split at the colon, as in the lecture. Code
cell `0902286f` applies tanh without $h$, which is numerically identical. No code or outputs
changed. SHA-256: `89c7f472887889f130f4d0abc2695d010524ab69bbf8d27cdd3417c4d52aebfe`.

**Notation FAQ.** In the L7b preference-weights table, the γ row has $h$, and a new $h$ row was
added (348 entries). Two entries stale since the October 8 window change now say 252 days (the
EMA of $\tilde g_{M,t}$ and $L_{\mathrm{growth}}$). The site was rebuilt with Pandoc 3.1.11.1,
and only `notation.html` changed. The answer audit has an October 9 note.

**Deck sync.** The deck went from 25 to 27 pages, with 0 overfull and 0 underfull boxes. The
following frames changed:

- The Examples footer matches the lecture.
- The Concept Review loses its "Algorithm:" slidenote.
- Wealthfront now matches the instructor's October 8 profile (Black–Litterman inside the
  utility bullet, the score mapped to a risk-aversion coefficient, the indifference curve, and
  the new connection sentence).
- Risk and Risk Aversion gains the $aU+b$ sentence.
- Two new frames, "The Certainty Equivalent" and "The Certainty Equivalent: An Example" (the ln W
  coin flip), carry the instructor's material.
- Preference Weights has $h$, the new where-line, and the Sign and Magnitude bullets.
- The Recent Market Growth loses a clause semicolon.
- The Summary has the new Takeaway 1.
- Frame 11 carries the same four-decimal rounding fix as the lecture.

The PDF was rebuilt in place, and before the rounding fix its text matched the approved
preview build exactly. Deck SHA-256:
`66e1d56392e7451ee2ab1627794d3d93c950297bba28c07e911c596825053cb6`.

**Checks.**

- Both notebooks validate with nbformat. The ten untouched lecture cells, all other example
  cells, and the metadata are byte-identical to HEAD (Python diff, confirmed by Codex).
- Every markdown cell renders through VS Code's KaTeX with zero errors, and all relative links
  resolve.
- The changed text has no clause semicolons and no em dashes.
- Codex found zero SymPy residual for both certainty-equivalent return lines and confirmed the
  argument identity, the sign, threshold, and tilt rules, the client-file sentence against the
  example code, and that the example's display matches the lecture's box symbol for symbol.
- A separate Codex check of the deck against the lecture confirmed the changed displays, the
  preference box with $h$ (SymPy), the Sign and Magnitude bullets, the footer, the Concept
  Review, Takeaway 1, the style rules, and a clean build log (27 pages, 0 overfull, 0
  underfull). It found the rounding step fixed in item 7. Its only other note was the
  Disclaimer on page 2, which the deck places there on purpose.

**Left as is.**

- Long sentences in the instructor's own text (cells `40320cbd`, `6b4e8514`, `a7c3e5d1`) and
  "Investors think in returns, not dollars", which Codex called an unneeded contrast.
- The nbconvert rendering of `___` without a blank line above it, which is house style.

**Open.**

- *Empty basket and the budget equality* (from October 6). Both Codex runs flagged it again:
  floors plus cash leaves the boxed budget equality unmet. This is the instructor's model call.
- *Deck interview frame* (from October 7). It is still a separate step.
- *Release.* These changes and the October 8 changes need the week-07.2 fix release.

## October 9, later: L7b-wide review, fixes, and the algorithm notebook (approved October 9)

After the lecture round, the instructor asked: "Is there anything in the ... L7b materials that is
not at a 9 out 10? Any obvious things that we need to change?" Four read-only reviewers scored
the files. Every must-fix item was checked against the files and stored outputs before it was
reported.

| File | Score | Main problem |
| --- | ---: | --- |
| Lecture | 9.0 | the interview question count |
| CES limits (advanced) | 9.1 (Oct 7) | two stale facts |
| Interview (`interview.md` and script) | 8.5 | the question count, gaps for a live run |
| SIM reference page | 8.2 | repeated the algorithm notebook's error |
| CAL example | 8.0 | stored outputs from a run with a client file |
| Allocator example | 7.6 | length, three misleading phrases |
| Algorithm notebook | 7.2 | contradicted itself |

**Instructor decisions.**

- "Fix 1 - 6." Approved from previews 12 to 14 ("Apply all"), including the labeled extras.
- *The allocator example is frozen.* "Keep the allocator the same => I like this content, and when
  you cut stuff - you make it shitty ... If there are obvious mathematical mistakes, ok - but
  otherwise, short of awkward phrasing or technical issue - leave this alone." Its length is not a
  to-do. Change only mathematical mistakes, technical errors, and awkward phrasing, and reword
  rather than cut.
- *Algorithm notebook polish.* "we **really** need to get the single step versus multistep shit
  correct, I have never understood the single step shortcut algo, its seems like magical bullshit
  to me". The instructor chose to build the notebook on the amount-times-mix explanation, keep the
  full pseudocode as the second method and a check, and add a small made-up two-asset example.
- *Plain wording.* On the draft: "what does 'no cap binds' mean? this sounds like typical AI
  gibberish - speak ... english". The bound $w_{i}\leq1$ is now introduced as "the bounds keep
  each risky holding between zero and 100% of our initial wealth", and every "no cap binds" or
  "below the caps" became "no holding hits the 100% limit". "Left the line/ray" became "stops
  being a scaled copy of the tangent portfolio". "Holds with equality" became "we hit the target
  exactly". Approved ("Agree").

**Fixes 1 to 6 (applied).**

1. *CAL example.* Commit `f9d95b5` stored outputs from a run with the instructor's
   `data/my-client.toml` (client $w_{f}=0$, implied $A=4.96$), although the prose and code default
   say a quarter in T-bills. It was re-executed with no client files (24 s, no errors). Every output
   now matches week-07.1 (client $w_{f}=0.25$, implied $A=6.61$) except the `U` column, whose
   formatter still pointed at the old column numbers and now reads `[2, 4, 5, 6, 7]`. Text: "The
   first three printed numbers" (four are printed), "the lecture's Concept Review", "The
   client's $A$ rests on the 2014 to 2024 estimates", and one clause semicolon.
2. *Algorithm notebook and SIM reference.* Handled in the algorithm round below.
3. *Question count.* A category-6 client stops after three answers, so "four or five questions"
   became "three to five" in lecture cells `40320cbd` and `9323c463` and in `interview.md`.
4. *Interview Step 6.* The CAL example reads only the client's risk-free fraction unless its
   ticker-file lines are uncommented. The after-class note gives the full `git checkout` path and
   names the ignored file. Saving the example after a live run is how its outputs went stale.
5. *CES limits.* "which sweeps the elasticity" became "which runs CES at $\eta = 0.5$ next to
   Cobb–Douglas", and "the correlation of L5a" became L5b (L5a's $\rho$ is the scaled NPV).
6. *Allocator, seven cells, text only.*
   - "nothing pulls it out of the market during a drawdown", which contradicted the empty-basket
     rule (the basket emptied once, the day after the SPY low), became "the engine has no
     stop-loss rule".
   - "the Task 2 table" for $\sigma_{g}$ became "the expected-performance table" in two cells.
   - "a few tenths per year" became "a few tenths of a $\mathrm{year}^{-1}$".
   - The $h$ sentence now says "Since $h = 1$, the code below omits it."
   - Three clause semicolons became periods.

**Algorithm notebook (applied).** New title: "The Tangent Portfolio: One Solve or a Search?". The
cell ids are kept, and one new cell, `c7d4e2a9`, was added. The prose is about the same length as
before (about 1,980 words), so the material was reorganized, not cut.

- *How much, and which mix?* SIM-2 in excess-growth form. The split $\mathbf{w}=\theta\,\mathbf{u}$
  is followed by a one-step-per-line derivation of variance $=s^{2}/\mathrm{SR}(\mathbf{u})^{2}$:
  the target only scales the variance, so every target picks the maximum-Sharpe mix. Then come
  "What about the 100% limit?", the boxed SIM-3, and the example. The example uses uncorrelated
  assets with excess growth 0.10 and 0.05 and variances 0.04 and 0.01, giving
  $\mathbf{w}_{\mathcal{T}}=(1/3,2/3)$ at $s=0.02$, $0.04$, and $1/15$.
- *The one-solve shortcut* has three steps. Because $\theta$ is a straight line through zero, the
  same solve also gives the tangent target, $g_{\mathcal{T}}=\hat{\mathbf{g}}_{\mathrm{SIM}}^{\top}\mathbf{w}_{\mathcal{T}}$.
  This removes the false claim that the shortcut "does not give the tangent point itself".
- *The search by continuation* keeps the instructor's L7a pseudocode lines unchanged. Only the
  October 8 rule's wording changed. "Why does this work?" now uses the weighted-average argument
  ($g_{\mathcal{T}}\leq g_{U}$), and the residual halving is qualified to the range where no
  holding hits the limit.
- *How does this differ from the lecture?* keeps the counterexample. "Can we converge faster?" was
  removed, because its linear jump is the one-solve shortcut.
- *One solve or a search?* (new) is a table of solves, why each method works, how each gets
  $\mathbf{w}_{\mathcal{T}}$ and $g_{\mathcal{T}}$, and what each must check.
- *Summary.* New takeaways, with no equations.

SIM reference page, four cells:
- The opener now reads "two portfolio problems ... and the one result".
- "The derivations are in the L7a lecture" was replaced with a link to the algorithm notebook.
- SIM-3 is stated in plain words, without "proves both and locates the tangent point itself".
- The where-used table names the continuation check.
- "symbols shared by the three problems" became "symbols used on this page".

CAL cell `ee5b0baf` has the same wording, and its semicolon is gone.

**Checks.**

- All six changed notebooks validate, and only the intended cells changed.
- All 50 relative links in L7b resolve, including `#The-one-solve-shortcut`.
- All 99 markdown cells of the changed notebooks render through KaTeX with zero errors.
- `data/` holds only the archive.
- Codex verified the draft:
  - The derivation, and the example as a constrained QP.
  - The tangent-target algebra, and both examples' checks (risky fraction above 0.01, every
    weight below one).
  - That the pseudocode is unchanged, and the counterexample (true tangent $(91/171, 80/171)$,
    Sharpe 2.09 against 1.00).
  - It scored the HEAD notebook 7.5 and the draft 8.7, and its corrections were applied before
    the instructor's review.
- A final Codex check of the applied notebook scored it 8.0 at HEAD and 8.8 after the rewrite.
  By dimension: correctness 7.8 to 8.6, organization 8.0 to 9.2, flow 7.7 to 9.2, presentation
  8.5 to 9.0, density 8.0 to 9.0, navigation 9.0 to 9.2. Its two remaining items were fixed with
  the instructor's approval ("yes"):
  - The 100% test in steps 2 and 3 now has a weight tolerance $0<\epsilon_{w}<\epsilon$ in the
    Initialize line, matching the allocator code ($1-10^{-6}$ with $\epsilon=10^{-3}$). Without
    it, "below one" would accept 0.999999999.
  - A sentence covers a tangent portfolio that holds a single asset, which reaches 100% exactly
    at the tangent point.
  - "Warm-started" became "that starts from the previous solution".
- SHA-256 prefixes at the end of the round:

```
4953fb69d05f…  CHEME-5660-L7b-Algorithm-TangentContinuation-Fall-2026.ipynb
303cf8f774ba…  CHEME-5660-L7b-Reference-SIM-Portfolio-Problems-Fall-2026.ipynb
6667753909fc…  CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb
8085381187f1…  CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb
b6799584d334…  CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb
```

**Not done (declined or out of scope).**

- *Allocator.* The output reads "empty basket on 1 days". Fixing it needs a code change and a
  re-run, and the notebook is frozen.
- *CAL.* Not done:
  - The $A = 2$ row levers $\mathcal{T}$ to 1.33 of wealth in NVDA, beyond the sweep's limit.
  - The lend/borrow rule is stated four times.
  - The Task 3 title is a question.
  - $\tau$ in a code comment means the one-year horizon.
- *Interview script.* Not done:
  - The script ignores unknown flags, so a `--dryrun` typo writes the file.
  - The utility form is not stated.
  - "Halve the range of cuts" is loose.
- *SIM reference.* The where-used table is incomplete for the L7a examples.
- *L7a lecture.* The SIM-3 reason still says "Scaling $\mathbf{w}$ by $c>0$ ...". The instructor's
  rule forbids links from L7a into L7b, so L7a was not touched.

**Open.** The empty-basket budget question and the deck's interview frame, as above. Release:
week-07.2.

## October 9, last: re-score after the fixes (approved October 9)

The instructor asked: "So are at 9 or above on these assets?" The four reviewers were rerun on
the committed files (`799f53e`) with the same rubric. They were told not to re-raise declined
items and to state what any declined item still cost.

| File | Before the fixes | Re-score | Reviewer's estimate after this round |
| --- | ---: | ---: | ---: |
| Interview | 8.5 | 9.2 | about 9.4 |
| CES limits | 9.1 | 9.1 | 9.1 or above |
| Lecture | 9.0 | 9.0 (cross-file check) | 9.0 |
| SIM reference | 8.2 | 8.9 | about 9.1 |
| CAL example | 8.0 | 8.8 | about 9.0 |
| Algorithm notebook | 7.2 | 8.6 | about 9.0 |
| Allocator | 7.6 | 8.3 (8.8 without length) | about 8.6 (9.0 without length) |

Every finding was checked against the files and stored outputs. The previews are 18 to 20, and
the instructor approved them ("Apply"). Only markdown sources changed. No code or output changed.

**Errors in text written earlier on October 9.**

- *CAL `4b562687`.* "The first three printed numbers" pointed at the weight table, which prints
  first. It now names $g_{f}$, $\mathbb{E}[g_{\mathcal{T}}]$, and $\sigma_{g,\mathcal{T}}$.
- *Algorithm `93c4702d`.* "Always has $\theta\geq1$, so step 2 never accepts it" gave the wrong
  reason. $\theta=1$ passes the tolerance. The weight test rejects the allocation in step 2, and
  $\theta\geq1$ sends it to the upper end in step 3.
- *SIM reference `d2204dd6`.* "$w_{i}\leq1$" holds for every solution. It is now $w_{i}=1$.
- *`interview.md`.* The ticker lines replace the default list, so "adds" became "swaps in".

**Other fixes.**

- *Lecture `a7c3e5d1` and deck.* The Power row read $w^{\tau}$ with $\tau>0$, which reaches only
  $\bar{r}<1$. Yet the lecture's $-1/w$ ($\bar{r}=2$) and the interview's $\bar{r}$ up to 28 are
  called power utility. It now reads $w^{\tau}/\tau$ with $\tau\neq0$, and $r(w)$ and $\bar{r}$ are
  unchanged.
- *"Floor binds" in plain words.* "No preferred floor binds" became "every preferred share count
  stays above its floor", the lecture's own phrase in the same cell. This was applied in:
  - lecture `1090dc65`;
  - CES `6446f896` and `924cd712`;
  - allocator `9fec5b93` (twice);
  - the deck's Cobb–Douglas frame.

  Also: SIM reference "makes the floor inactive" and allocator "so that it never binds" became
  "a floor every long-only portfolio meets".
- *CAL.*
  - `ee5b0baf` says why the sweep runs ("One solve would do, as [the notebook] explains, so the
    sweep is a check", word-neutral).
  - `bd63a009` names the 100% skip the code already makes.
  - `7b019fdb` drops "of Task 2" inside Task 2.
- *Algorithm.*
  - The SIM-3 box is named "One risky direction", as on the reference page.
  - "If the target asks for more" became "needs a holding above 100%".
  - `c7d4e2a9` dropped "and the examples use it", because the CAL example sweeps. It also dropped
    a third "the allocator runs both" sentence.
  - `0978b1ef` replaced its restatement of the rule with "one added rule for the 100% limit".
  - LO 1 and takeaway 3 were split into two sentences each.
- *Allocator* (fixes allowed under the freeze: math, technical, phrasing).
  - $W_{\text{adj}}$ used $W_{\mathcal{P}}(0)$ with day-$t$ prices. It now uses
    $W_{\mathcal{P}}(t)$, as in the lecture.
  - "The commented-out lines" is now "The last commented-out lines", because the cell has two
    blocks.
  - "The line under the table" is now "first" and "second", because it named two lines.
  - "Drops below the thresholds of the firms whose thresholds sit closest to it" became "falls
    below another firm's threshold".
  - The repeated "For the adaptive runs" and "For the buy-and-hold runs" labels were removed.
  - "Finds the tangent point itself" became "directly".
  - "A one-solve shortcut of the tangent continuation algorithm" now links the shortcut section,
    like the CAL example.
  - "With both" became "with the adaptive runs".
- *`income-gamble.jl`.* A clause semicolon in an error message was replaced.

**Not done.**

- *CAL.* Cutting the Task 2 derivation recap (about 55 words), because it removes content and is
  not needed for 9. The "doubling the excess growth" bullet stays, because it is the instructor's
  style of describing what changes as an input moves. The LO wording "the one the 2025 data would
  have made" also stays.
- *Allocator.*
  - The printed "a preferred floor binds" and the code-comment jargon (ray, warm start, cap). Both
    need a re-run of the frozen notebook.
  - The claims that hold only for the default list. Each of those cells already says results may
    differ.
  - The allocator's length. The instructor's freeze rules it out, so 9.0 without length is the
    allocator's bar.
- *Lecture.* "The mean update of L5a with $\omega=1-\lambda$" uses L5a's $\lambda$ while this
  lecture's $\lambda$ is the Cobb–Douglas multiplier. It is the instructor's sentence.

**Checks.**

- All six notebooks validate, and only the listed markdown cells changed.
- 49 relative links resolve, including both `#The-one-solve-shortcut` anchors. One link went with
  a cut sentence.
- All 99 L7b markdown cells render through KaTeX.
- No "bind", "inactive", "warm start", or "ray" remains in L7b markdown prose.
- The deck has 27 pages, 0 overfull and 0 underfull boxes, and slides 12 and 19 were checked
  visually.

SHA-256 prefixes:

```
fc8f080fbf24…  CHEME-5660-L7b-Algorithm-TangentContinuation-Fall-2026.ipynb
d57bb90877e0…  CHEME-5660-L7b-Reference-SIM-Portfolio-Problems-Fall-2026.ipynb
cae302a03b37…  CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb
498373ca9656…  CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb
39f45d98abcf…  CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb
00e1536d80fe…  CHEME-5660-L7b-Advanced-CES-Limits-Fall-2026.ipynb
```

**Closed and marked reviewed (October 9).** The instructor ruled on the allocator: "I'm not cutting
the allocator text - you are wrong there, so we are done. Mark the L7b as reviewed". Its length is
not a deduction, so its score stands at 8.8 without length, about 9.0 after this round. The
post-round scores above are the reviewers' estimates and were not re-measured. Committed and
pushed with no release. The week-07.2 release is still to do.
