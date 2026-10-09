# L7b lecture polish round

Notebook: `lectures/week-7/L7b/CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb`
Opened: October 3, 2026, using the notebook-polish workflow
(`.agents/skills/notebook-polish/SKILL.md`). The instructor paused the round after
the opening assessment ("save this review for L7b and we can do this later").
On October 6 the instructor asked for a polish, voice, and navigation pass if the
lecture scored below 9. It was applied in one round, and he approved it the same
day ("Agree to edits. Update"). See the October 6 section at the end.

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
