# Week 7 refactor — October 1, 2026

The instructor reached the theory in **Minimum-Variance Portfolios with SIM
Inputs** during L6b and requested a Week 7 pivot. This is a structural refactor,
not a completed notebook-polish round or a new review score.

## Teaching sequence

| Slot | Material |
| --- | --- |
| L7a, October 6 | Review SIM portfolio inputs and SIM-1; work the risky-assets example; BlackRock company profile; develop the risk-free asset, CAL, tangent portfolio, two-fund separation, SIM-2 and SIM-3; work the risky/risk-free example. |
| L7b, October 8 | Former L7a utility-based allocation, portfolio drift, adaptive rebalancing, and realized-path scorecard, with its three examples and CES companion. |
| Deferred, no date | Former L7b online SIM estimation, EWLS replay, scenario ensembles, and EWLS derivation. |

The [Week 7 index](WEEK-7-INDEX.md) links the active materials.
The [dated archive](../archive/week-7-before-pivot-2026-10-01/README.md)
preserves both original Week 7 folders. Its 39 tracked files match the original
SHA-256 hashes in `SHA256SUMS`; the old L7b is fully retained.

## L6b and client files

The instructor clarified that **the client interview runs in L6b and stays
there**. It is not a new L7a activity. No client-output files existed at the
time of this refactor, so none were transferred and the examples currently use
the thirteen hardcoded firms.

After the interview, copy `my-tickers.csv` and `my-client.toml` from L6b's
`data` folder into L7a's local `data` folder. The [Week 7 index](WEEK-7-INDEX.md) gives
the two commands. The existing example code reads those local files if present and
falls back to its defaults otherwise. Both copied files are Git-ignored.
Week 7 has no runtime or notebook-link dependency on Week 6.

The L6b notebooks, examples, interview, and slide deck remain in place. Only the
lecture's final schedule pointer changed. Its accepted sections and historical
review scores remain closed.

## New L7a

- New opening, three objectives, concise concept review, BlackRock profile,
  example list, and three takeaways. The risk-free development and equation
  labels are carried from the current L6b lecture.
- Local copies of the reviewed RA and RRFA examples, setup file, SIM archive,
  CAL figure, tangent derivation, and estimation-risk companion and helpers.
  Estimation examples and residual diagnostics stay in L6b.
- The BlackRock profile cites the firm's Target Allocation portfolios,
  Aladdin Risk, cash-management page, and student/career resources. The choice
  is a draft recommendation, not an instructor-approved profile review.
- A 17-page companion deck follows the new lecture and uses the existing
  course slide style. The full review/example stop precedes the risk-free work.

## Relocated L7b and references

The utility material, examples, data, CES companion, and figures moved together.
Filenames, labels, footer identifiers, and links now say L7b. Prerequisite
references distinguish L6b's estimation from L7a's portfolio allocation.
Promises to cover online estimation in the next Week 7 lecture were replaced
with unscheduled later-material references. The engine figure was rebuilt with
the corrected labels. The moved slide deck remains 24 pages.

The repository index, schedule Markdown, and the two Week 7 rows of the schedule
CSV now reflect the new sequence. L13a's CES pointer and notes link, and L15a's
online-estimation pointers, were repaired without changing their calculations.
L15a no longer assumes that EWLS was taught in Week 7. Its eventual scope and
the new placement of online estimation remain undecided. The eCornell integration
record has a dated notice distinguishing its historical mapping from the current
schedule.

## Checks

- Both new L7a portfolio examples executed from their own folder with the
  default firms: RA, 21 code cells; RRFA, 19 code cells. All existing assertions
  passed. Runs used offline package mode and left saved notebook outputs intact.
- All 124 code-cell syntax trees across the copied/moved computational notebooks
  match their source notebooks. Saved outputs, execution counts, and metadata
  are preserved. The optional estimation-risk and moved utility examples were
  checked for preservation, not re-executed in this refactor.
- All ten active Week 7 notebooks parse and validate, each with exactly three
  learning objectives and three key takeaways. Their relative notebook/figure
  links resolve inside Week 7. Major-section rules and closing rules pass.
- The new lecture rendered through Markdown and KaTeX with zero math errors;
  the review, formulas, CAL figure, profile, and closing were inspected visually.
- Both Week 7 slide decks build with zero overfull boxes. All slides were
  inspected, and the corrected company-profile/footer and engine-figure pages
  were inspected after the final rebuild.

Changes are local and uncommitted. No GitHub release or Canvas update was made.

## L7b trim — October 2, 2026

The instructor said class time covers two examples, at most three, and L7b had
three examples behind a 5,225-word lecture. He also proposed an example in the
style of CHEME 5760 F23 `L5b-CAL-Optimal` to tie L7a's risk-free asset to L7b's
utility. Decisions:

- L7b teaches utility-based allocation only, with two examples. The
  rebalancing engine, mechanical drift, the elasticity rule, and the
  realized-path scorecard left the lecture.
- Cut material is archived in
  [`archive/week-7-L7b-trim-2026-10-02/`](../archive/week-7-L7b-trim-2026-10-02/README.md),
  not moved into L13a. The instructor: "what we do in week-13 could change. I
  dont want for a topic on a future date." L7b has no forward pointers.

| File | Change |
| --- | --- |
| `CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb` | Renamed from `...-Utility-Allocation-Rebalancing-...`. 5,225 to about 2,600 markdown words. New CAL concept review and a mean-variance utility section with a one-step-per-line derivation of the optimal risky fraction, A_T, indifference curves, and the inverted formula for a client's A. Fragile inputs, Cobb–Douglas (derivation now one step per line), CES (limits as bullets), and SIM preference weights are trimmed from the old text. |
| `CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb` | New. Task 1 finds the SIM tangent portfolio with the L7a sweep-and-rescale method. Task 2 sweeps A and draws indifference curves. Task 3 inverts the four interview answers to A and recomputes the client's fraction from T's 2025 values. Reads `data/my-tickers.csv` and `data/my-client.toml` (default client w_f = 0.25). |
| `CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb` | Regrouped from five tasks to three. The η(ξ) rule, engine wording, and the L12b/L13a pointer are gone. Standard opening ported from L7a. |
| `advanced/adaptive_utility/...CES-Limits...` | Elasticity-rule section and the "later in the course" and L13a pointers removed. Two clause semicolons and one display lead-in fixed. |
| `Include.jl` | `_ROOT = @__DIR__` and `using TOML`, as in L7a. |

The utility in both the lecture and the example is
U = E[g_c] − (A/2) Δt σ²_{g,c}. Here Δt σ² is the squared GBM volatility (L5a),
so A is dimensionless and lands in the textbook range. For the default firms,
A_T = 4.96 and the interview answers imply A = 9.91, 6.61, 4.96, and 3.97.
Without the Δt factor, A would come out near 0.02.

Checks: both examples executed from their folder with no errors. The
allocator's text outputs match the pre-trim run except the dropped η(ξ) column.
The CAL example's tangent weights match the L7a RRFA example. It also ran with
temporary client files (seven low-beta firms, w_f = 0.1, shown as a separate
client row), and the files were removed afterward. All four notebooks render
through VS Code's KaTeX with zero errors. Previews are in
`build/notebook-previews/L7b-trim-2026-10-02/`. Codex first scored the drafts
8.5 (lecture), 8.6 (CAL), and 9.0 (allocator). Its fixes were applied: the
CES utility limit needs normalized weights, so the lecture states only the
allocation limit. Other fixes covered thresholds rather than "strongest
intercepts", the reciprocal effect of variance, squared-volatility wording in
the CAL example, and long sentences. A second Codex pass scored 9.0, 9.3, and
9.0. Its remaining precision fixes were then applied: "several times larger"
than the intercepts, held-fixed inputs, Δt defined, and the CES companion's
one-sided limits. The allocator re-ran with identical text outputs.
`.gitignore` covers the L7b client files.
The Week 7 index (moved to `instructor/WEEK-7-INDEX.md` by a concurrent
release session) gained the copy commands for `L7b/data`.

Follow-up the same day: the instructor asked for a section introducing utility,
because students may not have seen it. A first draft (bulleted properties, a
ln W coin flip, a Taylor expansion, Bernoulli and Levy–Markowitz citations) was
rejected: "not my voice or style. Very poorly done." The replacement is ported
from the instructor's own CHEME 5760 Decisions Book (varnerlab, `utilityfunctions.md`,
`risk.md`) and the CHEME-145 Module 1 Arrow–Pratt material, and was approved after
two revisions he asked for. It has two parts.

- `## Utility Functions and Rational Choice`: a labeled utility-function definition
  (agent, alternatives, utils, ≻ and ∼, ordinal), a rational-choice key idea, and
  a table of linear, logarithmic, Cobb–Douglas, Leontief, and CES utility, with the
  CES limits named.
- `### Risk and Risk Aversion`: expected utility, a curvature/risk-attitude table,
  certainty equivalent and risk premium, and an Arrow–Pratt box (r and r-bar, the
  Decisions Book notation, so the mean-variance A is not reused). It ends with
  Pratt's small-risk risk premium as the bridge to mean-variance utility.

The instructor had marginal utility removed ("we don't do anything with it"). The
Cobb–Douglas consumer-choice sentence that used it was removed too. A
correctness-only Codex pass led to three precision fixes: ln U for positive U,
η ≠ 1, and "for small returns". All six blockquoted displays in the lecture now
quote every line, as in the reviewed L4a–L5b lectures. The lecture is about 3,300
words.

The instructor then deleted `## Fragile Inputs` ("no idea what this is even saying"). The
mean-variance section now ends: "...every investor holds the same risky fund. What if
we write down the investor's preferences for each asset instead?" The lecture is about
3,140 words.

Open items:

- Done the same day: the L7b deck was rebuilt to mirror the lecture, going from 24
  to 21 pages with zero overfull boxes. Every page was rendered and inspected. It
  follows the approved L7a deck style (`\href` example links, `\symbfit` vectors,
  literal en dashes in titles) and drops the drift, fragile-inputs, engine, and
  scorecard frames. New frames cover utility functions, the utility table,
  risk and risk aversion, Arrow–Pratt, mean-variance utility, the optimal
  complete portfolio, and indifference curves. The pre-trim deck is in the
  archive's `slides/` folder, and the Makefile no longer needs the engine figure.
- `week-13/L13a/docs/Notes.tex` links the old L7b filename and says that L7b
  introduces the rebalancing engine. L13a was left untouched, as the
  instructor asked.
- `lectures/LECTURE-ARTIFACT-SCHEDULE.md` rows 7a and 7b predate the October 1
  pivot.
- The allocator still uses the thirteen default firms, not the client's list.

## Cobb–Douglas model restored — October 3, 2026

The instructor found that the L7b Cobb–Douglas derivation did not match the 2025
L9a/L14a lectures or eCornell Session 2. An August 17 rewrite (`a25ab33`) had
restricted the product to the preferred set, dropped κ, and turned the ε > 0
share floor into an assumed n_min ≥ 0. The instructor's model, now restored:

- maximize ∏ over every asset of n_i^γ_i, subject to the budget constraint
  Σ n_i S_i(t) = W_P(t) and the share floor n_i ≥ n_min > 0, boxed with labels;
- the derivation shows that the floor binds on 𝒜⁻ (γ_k/n_k ≤ 0), substitutes
  the floors into the budget, and derives W_adj as the net budget for 𝒜⁺
  before the Lagrangian. The instructor rejected a draft that defined W_adj in
  prose ("where is the budget constraint????").

The symbol stays n_min. The Utility Allocator example already uses ε for the SIM
residual, and the example's code and outputs are unchanged.

Why κ = ±1 exists: the instructor's 2025 INFORMS `world` function and eCornell's
`evaluate_cobb_douglas` compute the shares from the closed form and apply κ only
to the utility value, which is the combinatorial bandit's reward. An asset with
γ < 0 at a floor ε < 1 contributes ε^γ > 1, so without κ = −1 the bandit would
favor baskets that hold non-preferred assets. No written material had stated
this reason. L7b has no bandit, so it states the problem without κ.

Changes, approved from rendered previews in
`build/notebook-previews/cobb-douglas-2026-10-02/`:

- L7b lecture cell 6: the Cobb–Douglas subsection (173 → 172 prose words).
- L7b deck: the two Cobb–Douglas frames became three (problem; floors and net
  budget; allocation). 21 → 22 pages, zero overfull boxes.
- L13a lecture cell 5: two sentences giving the reason for κ.
- L13a advanced bandit notebook cell 4: an August 3 commit (`04ae0fc`) had
  removed the floors and κ and replaced the tanh SIM preference model with an
  always-positive softplus model. The 2025 L14a text is restored, with the κ
  reason, the β_i > 0 assumption that L7b states, and its three clause semicolons
  removed.

When the closed form holds (decided October 3). The closed form assumes every
preferred share count stays above n_min. On the example's 2025 data with
W = 1,000 USD, 3 of 193 nonempty-basket days break it (GS, γ ≈ 0.001–0.004). It
breaks routinely in CES at high η. The instructor chose Option 2: a floor on every
asset, and when a preferred count falls below n_min, pin it at the floor and solve
again. Option 3 (floor on 𝒜⁻ only) keeps the closed forms exact but lets a
preferred asset hold fewer shares than a non-preferred one, which he rejected.
Codex confirmed that pin-and-solve is the exact optimum for Cobb–Douglas and for CES
at any η, with n_i* = max{n_min, (γ_i/(λS_i))^η}. Changes:

- Lecture cell 6: the assumption is stated before the stationarity step, the
  pin-and-solve sentence follows the Cobb–Douglas box, the CES maximizer has "the
  same floor check", and the η → ∞ bullet now says that every other asset falls to
  its floor.
- CES companion cells 1, 2, 4: the floor assumption, "when no floor binds" after
  `allocate_ces`, and the η → ∞ limit with floors.
- Course package: `allocate_cobb_douglas` and `allocate_ces` share
  `_allocate_with_floors` (pin and solve) and have full docstrings. With ε = 0 the
  results are unchanged. Infeasible floors now raise an error. New tests cover
  Codex's counterexamples, high-η CES, no floor, and infeasible floors.
  `Pkg.test()` passes 1,965 of 1,965 tests, including Aqua.
- Utility Allocator example re-executed: only the η = 5 CES column (AAPL and MSFT
  at the floor, NVDA 0.9868 to 0.9802) and the high-η end of the sweep figure
  changed. No prose quotes those numbers.
- Deck: the floors frame ends with the assumption, the allocation frame with the
  pin rule (with `\jot` set to 0 to fit), and the CES frame mirrors the lecture. It
  is 22 pages with zero overfull boxes.
- The Stone–Geary alternative is saved in
  [STONE-GEARY-UTILITY-NOTE.md](STONE-GEARY-UTILITY-NOTE.md).

L13a is paused at the instructor's request. Its changes and open items are in
[L13a-PINNED-ISSUES.md](L13a-PINNED-ISSUES.md).

## L7b allocator rework — October 8, 2026

The instructor ran the utility-allocator example live in L7b and every firm came
out non-preferred on the demo date (January 2, 2025). Cause: the preference
argument used the eCornell session-2 input, a 10-day EMA of the annualized daily
SPY growth (−0.76 per year on that date), while the firms' thresholds −α/β lie
between −0.2 and +0.13 per year. In 2025 that input emptied the basket on 57 of
250 days. Last year's course example (Fall 2025 L9a INFORMS) used the training
mean (0.106 per year) and a fixed exponent, so 17 of 20 firms were preferred. The
eCornell example re-solved the allocation every day; the 2026 example had taken
its inputs but allocated on one day and then scanned for the first nonempty day.
A second trigger: `data/my-tickers.csv` (gitignored, 30 client firms from the
October 4 interview) silently replaces the 13 default firms, and the old tangent
solve at a hardcoded target of 0.30 per year pushes MSFT to its upper bound on
that list.

Instructor decisions (same day): keep the tanh model and the daily crossover
signal; replace the 10-day window with a longer one; re-solve the share counts
through 2025 daily and monthly; one wealth plot with adaptive daily, adaptive
monthly, one CES run, GMV and tangent buy-and-hold, and SPY; fewer tables; make
the tangent estimate explicit.

| File | Change |
| --- | --- |
| `CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb` | Rebuilt, three tasks, 53 cells, executed on the default firms. Window `L_growth = 252` (EMA half-life about 87 days): basket nonempty on 249 of 250 days, 13 of 13 preferred on January 2. Task 1 computes lagged inputs for every 2025 day with the perturbation lag check. Task 2 computes the daily preference matrix, the day-one table (with bearish and bullish columns), the basket count, the Cobb–Douglas closed form against the package (floor, nonempty-basket, and CES-at-one checks), and the GMV and tangent weights (tangent from one risky/risk-free solve at a target a quarter of the way from `g_f` to the largest SIM mean, normalized, with PD, status, bound, and sign asserts). Task 3 runs `run_utility_engine` with no cap or breaker: adaptive daily, adaptive monthly, CES monthly (η = 0.5), GMV, tangent, SPY; wealth plot, weights area chart, scorecard. Three tables (day-one preferences, scorecard, plus printed stats), five figures. |
| `CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb` | Cells 1 and 11 only: window 10 → 252 with the half-life sentence, the behavior paragraph, and the example description. The instructor's uncommitted edits to the utility and profile cells are untouched. |
| `slides/...tex` | "Lectures and Examples" blurb and "The Market Inputs" bullet. Rebuilt, 24 pages, 0 overfull. |

Window scan (lagged EMA of annualized SPY growth, 2025, default firms): L = 10
empties the basket on 57 days, L = 63 on 33, L = 126 on 14, L = 252 on 1, L = 504
on 0. The client list with L = 252: 30 of 30 preferred on January 2, empty on 8
days. The notebook was also executed on the client list (not committed) and ran
clean; with those firms the tangent portfolio is MSFT 70%, APH 17%, V 12%.

Results on the default firms (committed outputs): adaptive daily 1767 USD, 25.5%
drawdown, turnover 10.9, cost 10.5 USD; adaptive monthly 1644 / 27.0%; CES monthly
1553 / 25.6%; GMV 1382 / 12.9%; tangent 1275 / 30.6%; SPY 1166 / 19.0%. On the
client firms the ordering differs (tangent 1283, monthly 1225, CES 1206, SPY 1166,
daily 1051, GMV 1046), so the interpretation prose describes mechanisms and does
not claim a winner.

Codex pre-review of the spec (scratchpad `codex/prereview-out.md`) accepted items:
half-life wording instead of "same horizon as the SIM rates"; the window is a
teaching choice made after looking at 2025; no named helper inside the let block;
basket versus holdings defined; bearish and bullish columns to show sign versus
magnitude; nonempty-basket and floor asserts; CES η = 1 check; PD and sign
asserts on the solves; "ray argument of L7a" instead of a SIM-3 label (the L7a
lecture had SIM-1 and SIM-2 only at the time; SIM-3 was restored on October 8
and the bullet cites it again); engine starts in cash; post-cost scaling of
the floors disclosed; monthly run holds between rebalances; what is adapted
stated; idealized close-price sizing stated; day-one weights table replaced by
printed lines and the grouped bar; growth column dropped from the scorecard;
daily-versus-monthly conflation sentence. Rejected: merging the basket count into
the Task 1 figure (the signs are explained in Task 2).

Codex post-audit (scratchpad `codex/postaudit-out.md`) accepted and applied: the
monthly run never holds cash on an empty-basket day between rebalances (prose
fixed); floors leave no cash (fixed); "larger beta, less growth" holds for a
fixed intercept (fixed); day-one reasoning is "above the largest threshold"
(fixed); Cobb–Douglas favors beta-adjusted expected growth (fixed); CES below
one moves toward equal share counts, not more even dollar weights (fixed);
GMV drawdown claim dropped; the 10-day-window range is now printed from an
executed computation; the window-selection sentence names 2025; the lecture's
"while the rest stay in" and "any bad fortnight" corrected (every default firm
left the basket at least once in April); deck footer now says both examples
use the client firms; stats print and grouped bar split into two cells with
connective prose; empty-basket and binding-floor cases on day one print a
message instead of failing; tangent target guarded by `max(ĝ) > g_f`;
scorecard vertical cropping off; area chart grows with the firm count.
Not applied: a stronger engine-conservation check (the engine already enforces
it; Codex found no accounting failure).

Resolved the same day: the instructor confirmed the lecture Summary's closing
sentence refers to the week-13 material, where the intercepts and betas are
estimated online and a bandit chooses the tickers in the basket. The sentence now
contrasts that with today's allocator (holdings re-solved daily, SIM parameters
fixed from training, basket from the signs). No date is named.

Polish round, same day: the instructor asked for a polish, voice, and
organization pass if the reworked example scored below 9. It opened at 8.3
(Codex 7.9) and the pass was applied in one round, prose only. The scores,
the three factual corrections the Codex pre-review surfaced, the heading and
reading changes, and the checks are in
[the allocator review record](L7b-ALLOCATOR-REVIEW-HANDOFF.md).

Tangent-continuation algorithm notebook, same day: the October 6 lecture edit
dropped the boxed SIM-3 result that the L7a tangent example and both L7b
examples cite, and no example runs the continuation the lecture sketches. The
instructor chose a separate algorithm notebook in L7b
(`CHEME-5660-L7b-Algorithm-TangentContinuation-Fall-2026.ipynb`, markdown
only, on the CHEME 5800 L6c Jacobi pattern). SIM-3 is restored in the L7a
lecture as the Solution of the SIM-2 box, the lecture's pseudocode stays, the
L7b lecture, example, and deck link the algorithm notebook (L7a does not), and the allocator example
runs the continuation as a check against its single solve. Details and checks are in
[the allocator review record](L7b-ALLOCATOR-REVIEW-HANDOFF.md).
