# L9a redesign handoff — October 9, 2026

**Review status: reviewed and complete, October 11, 2026.** The instructor
closed the review of the lecture, both core examples, both advanced notebooks,
and companion slides. Final scores are 9.0–9.1/10. No proposals remain pending;
see the completion record at the end before follow-up work.

L9a is rebuilt as "Introduction to Derivatives and European Option Pricing". The
spec is `L9a-REDESIGN-SPEC.md` and the plan is `L9a-REDESIGN-PLAN.md`. The original
build ran in two stages:

1. **Agent build.** Parallel builder agents, each followed by an independent QA
   reviewer that rated the work 0–10 and polished anything below 9. The manager
   (the main session) handled ordering, git moves, and checks.
2. **Interactive restructure.** The QA reviewer scored the lecture 9.0, and you
   rated it "at most a 6": the contract figure was poor and the formatting was
   choppy. The reviewers had judged sentences and checker rules, not the page.
   The lecture's sections 4–6 and the contract figure were then redone with you,
   decision by decision (below). The QA scores in the next table predate this
   and are not a quality measure.

## What was built

| Artifact | Path (under `lectures/week-9/L9a/` unless noted) | Status |
| --- | --- | --- |
| Lecture | `CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb` | Restructured with you. You approved it on October 9. |
| Example 1 (moved from the L8b archive) | `CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb` | Reviewed as a page with you and switched to the end-of-day archive (below). |
| Example 2 | `CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb` | Reviewed as a page with you on October 10 (below). |
| Advanced: contingent claims (new, markdown only) | `advanced/contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb` | Reviewed as a page with you on October 10 (below). |
| Advanced index | `advanced/README.md` | Agent QA only (8.5 → 9.0). |
| Contract figure | `figs/Fig-L9a-Contract-Right-Obligation.{tex,pdf,svg}` | Redrawn as a minimal two-row figure. You approved it. |
| Cash-flow timeline (new) | `figs/Fig-L9a-Option-CashFlows.{tex,pdf,svg}` | You approved it. |
| `Include.jl` | `Include.jl` | Adds `using Dates` for the archive's quote date. |
| Figure build and theming | `figs/Makefile`, `figs/theme_svg.py`, `figs/README.md` | Works for both figures. |
| Deck (19 frames) | `slides/CHEME-5660-L9a-Slides-Fall-2026.{tex,pdf}` | Re-synced to the restructured lecture. |
| Notation FAQ | `code/docs/faq-src/content.json`, `code/docs/src/faq/notation.html` (repo root) | 17 rows, plus Context rows for `p` and `q` and the `τ` context. |
| Records | `LECTURE-ARTIFACT-SCHEDULE.md` (9a), `schedule-2026-update.md` (F40), `README.md` (week 9), `AGENTS.md`, the L9b deck comment | — |
| Archives | `lectures/archive/week-9-L9a-before-redesign-2026-10-09/` (old lecture, old deck, three unused figures) and `lectures/archive/week-8-L8b-options-2026-10-09/` | — |

## Interactive restructure (October 9)

Your decisions, in the order you made them:

- **Approach:** reorder, dedupe, and smooth the seams. Your math and key
  sentences stay.
- **Outline:** two parts. "Call and Put Options Contracts" runs through
  Example 1. "Pricing Options" has two H3s, "Options as Abstract Assets" and
  "Black–Scholes–Merton and Put–Call Parity", and ends with Example 2.
- **Displays:** each display pairs the call and the put. Only key results are
  boxed (the payoffs, the European premium, the BSM premiums, and parity), with
  no text tags inside the math.
- **Prose:** connected paragraphs instead of bold run-ins. Besides the example
  callouts, three blockquote boxes remain: your two business cases and the
  Nobel note.
- **Contract figure:** a minimal two-row schematic of the actors and cash flows.
  Solid arrows are always paid, and dotted arrows only if the buyer exercises.
- **Kept as they were:** the timeline figure, the market subsection, the Cboe
  Predicts bullet, the "may have no value" paragraph, the profit-versus-NPV
  note, and Optional Advanced Material.
- **Three imprecisions in your text, fixed in your wording:** "by a future
  date (expiration)" for the definitions, "risk-free discount factor … exercise
  time τ" for the American premium, and "the *expected* share price grows at
  the risk-free rate".
- **Market numbers:** 2025 and 2026 now compare on the same basis. Both years
  have a total row and a daily-average row. The 2026 figures run through
  September (OCC): about 70.6 million contracts per day, up 20.6% on January to
  September 2025, and about 13.2 billion contracts in total. The total is the
  daily average times 187 trading days, because OCC does not publish
  year-to-date totals. OCC's August headline of 70.8 million included futures.

Result: sections 4–6 went from about 2,330 words to 1,870, the lecture went
from 16 headings to 11, and from 6 blockquote boxes to 3.

## Example 1 pass (October 9)

Your decisions:

- **Data:** the example loads the end-of-day options archive
  (`MyOptionsEODChainDataSet`) instead of the 2025 AMD chain. The ticker is a
  variable in the data cell (default `NVDA`) and the prose never names it. The
  quote date is October 8, 2026, the archive's last session, and the expiration
  is the one matched to `target_dte = 45` (November 20, 43 days). Both contracts
  use the at-the-money strike, the listed strike nearest the share price. The
  same code runs for all 31 tickers in the archive.
- **Deleted:** the moneyness consistency check (its two markdown cells and its
  code cell). It concluded that nothing in the notebook depended on it, and the
  archive has no `Moneyness` column.
- **Kept:** both breakeven derivations, with `S_T` changed to `S(T)` to match
  the lecture.
- **Code:** the repeated print lines are gone, each check cell keeps four
  asserts, and the chain display shows only the six columns the example uses.
- **Text:** a link-plus-question opener with no ticker, `S(T)` throughout, no
  sign-convention box, no teaser line, and a closer that invites changing the
  ticker or the expiration.

NVDA results: share price 230.57, strike 230, call premium 12.15, put premium
10.64, breakevens 242.15 and 219.36. The builder is `edit_ex1_eod.py` (input in
`before-ex1-eod/`), and the previews are in `previews-ex1/`. The function's docs
link resolves once the documentation site is redeployed with the archive
loaders.

### Example 1 pass 2 (October 10)

Your decisions:

- **Plot background:** `bg = "gray95"`, the course standard. The tan
  `floralwhite` came from the 2025 L8b notebook.
- **Breakeven marker:** an open circle (white fill, black outline) in both
  plots, so it stands apart from the filled markers.
- **Tables instead of printlns:** the two premium cells print quantity, value,
  and units. The two check cells print quantity, value (USD/share), and the
  lecture formula it should equal. The asserts are unchanged.
- **100 shares per contract:** this wording replaces "deliverable multiplier"
  and "the deliverable $q$" in the objectives, the constants, both premium
  lead-ins, Task 3, and the Summary.
- **Task 3 in USD for one contract:** premium, maximum profit, and maximum loss
  are in USD for one contract, and the breakeven stays a share price. The `K`
  column is gone. Tasks 1 and 2 stay per share, like the lecture formulas.

The builder is `edit_ex1_tables.py` (input in `before-ex1-tables/`), and the
previews are in `previews-ex1-tables/`.

## Example 2 pass (October 10)

Your decisions:

- **Task 2 check:** trimmed to put–call parity only. That is one lead-in
  sentence with the parity equation, a 3-row table (`C₀ - P₀`, `Sₒ - K·𝒟⁻¹`,
  difference), and one assert. The sign check, the Monte Carlo z-scores, and the
  repeated premium rows are gone.
- **Task 3 table:** five strikes near the money (50 to 70) instead of the
  81-row display. The plot shows the full sweep.

Clear calls, shown in the previews:

- `S(T)` in both pricing displays, with no text tags inside the math. Your
  2025 text had `S(T)`, and an agent introduced `S_T`.
- One name, "Black–Scholes–Merton", throughout.
- The link-plus-question opener, as in Example 1.
- A Summary closer that states what the notebook computed. The old closer
  claimed a Monte Carlo expected-NPV result that the notebook never computes.
  The checker's rule requiring "expected NPV" is now a rule against `S_{T}`.
- A code comment on the risk-neutral drift (`μ = gᵧ`), and `T` and `K` set as
  math in the parameter lines.

The builder is `edit_ex2.py` (input in `before-ex2/`), and the previews are in
`previews-ex2/`. The Monte Carlo tables are unchanged (seeded).

## Contingent-claims advanced pass (October 10)

Your decision:

- **Three H2s, one per objective:** "Replication on a One-Step Lattice" (the
  old Law of One Price and One-Step Replication sections), "State Prices and
  Event Contracts", and "The Black–Scholes–Merton Formulas". The lattice-limit
  text opens the last one, and Digital, Asset-or-Nothing, Call and Put, and
  Reading N(d±) are `###` steps under it. Headings only. The cells stay
  separate.

Clear calls, shown in the previews:

- The link-plus-question opener.
- The third statement of the law of one price is cut.
- The d₋ definition left the reason column (now "solve for Z") for its own
  line, and `S_T` became `S(T)` in the L5a sentence.
- "Reading N(d±)" lost the Kalshi bullet (the digital price, already shown)
  and the re-derivation of the exercise probability.

Not taken from the review: the notation sentence stays, because it defines
g_y before its first use. The L5a sentence was accurate apart from notation,
because L5a itself writes the event as S_T > K.

Prose went from 1,428 to 1,380 words, and no math changed. The builder is
`edit_adv.py` (input in `before-adv/`), and the previews are in
`previews-adv/`.

The lecture is now built by `restructure_lecture.py` from the pre-restructure
backup in `before-restructure/`. After your hand edits start, the notebook
becomes the source.

## Checks

- `check_l9a.py` (all groups, updated for the new outline): 0 failed.
- `verify_contingent_claims.py`: all checks passed. Call 4.0830 against package
  4.083, put 1.1567 against 1.157, q = 0.6000. This also covers replication,
  CRR convergence, the digital and asset-or-nothing claims by Monte Carlo, and
  the bridge identities.
- Both examples were re-executed with nbconvert, with no error outputs.
  Example 1 now reads the archive (NVDA breakevens 242.15 and 219.36). Example 2's
  premiums are unchanged at 4.083 and 1.157.
- Offline bundle: all 11 relative links in the L9a notebooks resolve inside a
  copy of `L9a/` alone.
- Figures: the light and dark renders were checked, and every TikZ color is
  mapped (an unmapped color fails the build).
- Deck: builds with no overfull boxes, and every page was rendered and checked.

## Where to look

All paths are under `build/notebook-previews/L9a-redesign-2026-10-09/`
(gitignored):

- `previews-restructure/`: before/after PNGs of the restructure. Added text is
  green, removed text is red, and moved text is unhighlighted.
- `deck-resync/`: page PNGs of the re-synced deck.
- `previews/`, `figures/`, `deck/`: renders from the agent build (superseded
  for the lecture, the contract figure, and the deck).
- `facts.md`: every dated fact with its source and access date, and what did
  not verify.
- `restructure_lecture.py`, `before-restructure/`: the current lecture builder
  and its input.
- `new/`, `assemble_lecture.py`: the agent build's assembler. It no longer
  builds the lecture.
- `qa-backups/`: the examples as they were before QA.

## Flags for you

1. **Example 2's** one-sentence LOs are your 2025 text and were left alone.
   The opener now follows the question-led pattern (October 10).
2. **Facts that did not verify:**
   - "Founded by Chicago Board of Trade members" was dropped.
   - Your December 2024 figure of 6.6 trillion USD was kept, because the
     December 2025 number has only syndicated sources.
   - "$3 trillion" became "3 trillion USD", because a bare `$` starts math.
3. **Pending elsewhere:**
   - The FAQ Context row for `V` (L9a payoff, L9b lattice value) waits until
     L9b's notation is added.
   - Out-of-scope L9b items from the spec: the stale `g_f` text and three
     examples, over the cap.
   - L10a mentions L8b.
   - `README.md` line 141 (week 8) is left for your L8b work.
   - The manifest's 8b unit is set to 2.

## Next steps

1. Done: every L9a notebook has been reviewed with you as a page.
2. Committed on October 10, L9a files only. Left out: the end-of-day options
   archive code (`code/src`, `code/test`, `Project.toml`, `Manifest.toml`,
   `Artifacts.toml`, the docs data page, the build script) and the L8b build
   (`week-8/L8b`, its handoff, its AGENTS.md block, the schedule's 8b row, its
   FAQ tables and `p` row, `.gitignore`). The archive code followed in
   b67862b, and the docs site redeployed with the three loaders, so Example 1
   and its docs link work for students.
3. The lecture is backed up in `voice-calibration/` for your hand edits.

## Focused pricing and SPXW updates (October 11)

The October 11 review rated the materials 8.7/10 overall, with the lecture at
8.6 and the SPXW example at 8.0. You authorized the two recommended changes
after clarifying their scope:

- Keep Kalshi as the hook. Explain why replication fixes the stock-option
  premium, why a general event contract needs an additional pricing assumption,
  and state the BSM assumptions before the formulas.
- Preserve the SPXW content and calculations, including the Yahoo and
  realized-volatility comparison. Regroup the notebook into three tasks and
  move applicable price checks before implied-volatility inversion.
- Synchronize the companion slides and this handoff.

### Lecture and deck

The lecture's Pricing Options section now makes the zero-expected-NPV pricing
condition conditional on replication. Its arbitrage explanation states that
the necessary trades must be available without transaction costs. The event
contract paragraph distinguishes the pricing probability determined by the
replicating stock model from the additional assumption needed for a general
Kalshi event. Before the BSM formulas, the lecture states the non-dividend
GBM, constant volatility and continuously compounded rate, and continuous,
frictionless trading assumptions, including fractional holdings, short sales,
and borrowing and lending. The Monte Carlo lead-in specifies risk-neutral
drift. The existing equations, figures, examples, and Kalshi opener remain.

The corresponding three deck frames were synchronized. The rebuilt PDF has
19 pages, with no overfull or underfull boxes. All pages were rendered and
inspected, with the three edited frames also checked at full size.

### SPXW example

The new task sequence is:

1. **Validate quotes and estimate financing inputs.** Pair calls and puts,
   estimate the discount factor and forward from parity, then check quote
   ordering, European quote bounds, midpoint bounds for inversion, parity
   within spreads, midpoint monotonicity, and discrete convexity.
2. **Recover and verify implied volatility.** Run the existing forward-form
   BSM inversion, check repricing, then show the existing skew plot and table.
3. **Interpret the skew and contract settlement.** Retain the skew explanation,
   Yahoo/history subsection and realized-volatility comparison, settlement
   example, and real-data schema.

The midpoint guard is new: each solver input must be strictly between the
European lower and upper price bounds to admit a finite positive implied
volatility. The original price diagnostics now run before inversion; the
implementation check runs afterward. The prose distinguishes midpoint
diagnostics from an executable arbitrage. The BSM and inversion functions are
unchanged. The notebook now has exactly three learning objectives and three
key takeaways, and its major-section rules match the course style.

### Verification and saved results

- Executed all 14 revised SPXW code cells with the installed Julia kernel and
  the actual `Include.jl`; no error outputs. Saved the fresh execution outputs.
- All six pre-inversion diagnostics passed. The fitted discount factor is
  0.995979838709678, the forward is 6500, and the continuously compounded rate
  is 0.04200903741565946 per year. Maximum repricing error is
  9.094947017729282e-13 index points.
- Executed the original and revised notebooks with Yahoo disabled. Financing
  inputs, the entire paired-price/IV table, repricing error, offline index
  history, and realized-volatility series were exactly identical.
- Negative checks confirmed that failed quote ordering and an out-of-bounds
  midpoint stop execution before the inversion function is defined or called.
- The saved fixture tables and skew plot agree with the preceding notebook.
  The Yahoo response refreshed from 249 to 252 observations for the same
  August 14, 2025–August 14, 2026 range. Its latest close remains 7785.76;
  the refreshed 20-day and 60-day realized volatilities are 13.30% and 13.65%.
  The history-loading and volatility calculations are unchanged.
- The existing `check_l9a.py` reports zero failures. All five notebooks validate
  as nbformat, and their relative links resolve. The focused SPXW checks cover
  the three objectives/tasks/takeaways, heading rules, assertion placement,
  execution outputs, and price-check/inversion/repricing order.
- The edited Markdown passed the VS Code notebook KaTeX renderer without math
  errors; the changed prose and equations were also inspected in PDF proofs.
  These proofs check the text and mathematics, not native notebook layout.

The two core examples, the contingent-claims notebook, the fixture data, and
the local helpers were not edited. No commit or push was made for this pass.
Backups, execution output, validation scripts/logs, and deck renders are in
`build/notebook-previews/L9a-updates-2026-10-11/` (gitignored).

## Review completed (October 11, 2026)

After the final reassessment, the instructor closed the review: "Ok - let's
mark this as reviewed". This covers all L9a teaching materials, including the
five notebooks, their linked figures, and the synchronized companion slides.

| Material | Final Codex score / 10 |
| --- | ---: |
| Lecture notebook | 9.1 |
| Single-contract payoff/profit example | 9.1 |
| BSM premium example | 9.0 |
| Contingent-claims derivation | 9.0 |
| SPXW volatility-skew example | 9.0 |
| Companion slides | 9.1 |

The verification recorded above applies to this reviewed snapshot. The final
ratings are Codex's editorial assessment; the instructor accepted the materials
and closed the round. No proposals remain pending. Do not restart approved
sections unless the instructor requests another review.

### Reviewed snapshot

SHA-256 hashes of the saved notebooks and slide sources/output at closure:

| Artifact (under `lectures/week-9/L9a/`) | SHA-256 |
| --- | --- |
| `CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb` | `5db7e54da7fd56df14dd9fa483b5304adac1ffbb412669c893c92e786edc95c7` |
| `CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb` | `bb971c49543867a4e971ce8740a3b0836cd0562c07a1f223f7be44e0abee4c5a` |
| `CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb` | `86e6e8d02baeeb48b9573335ed55b5222566957eebff5cf76c029bea7a2c3ccb` |
| `advanced/contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb` | `bea92d6d1d9de4cfc538b72f0784f7c81b887d9daf3335b629445b1955b5605e` |
| `advanced/spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb` | `ee9807578d9ea9bc64e180725fc2ec56e6862c4a3a80da976e7ee43788ec416f` |
| `slides/CHEME-5660-L9a-Slides-Fall-2026.tex` | `b07db863ff4cf67a4c6e2be9ec81c2b846b5d723e173804c6b11490e9620becd` |
| `slides/CHEME-5660-L9a-Slides-Fall-2026.pdf` | `53bfff0c6c104ab684499fe3952fd992ba74db4b49dbc5c191f96a60e198eae0` |

## Pricing section reorganized (October 12)

The instructor found the passage from the American premium through the event
contract "too long, organized poorly". He approved this change from a
before/after preview
(`build/notebook-previews/L9a-pricing-reorg-2026-10-12/pricing-reorg.png`):

- "What does ℚ mean?" moves up, right after the arbitrage paragraph, where the
  boxed European premium first uses ℚ. It is written as a sentence, three
  bullets (the share, the option, the event contract), and a closing sentence
  on general Kalshi events. The event-contract formula is now inline.
- The exercise-style bullets and the American premium move to the end of the
  subsection, so they lead into the BSM heading.
- Cut: "which can increase the premium", the continuous-compounding
  parenthetical, the sentence after the American display (the third statement
  of American ≥ European, with a second reason), and the repeated "ℚ gives
  zero expected NPV" sentence. The passage went from 254 to 194 words. The
  American display is unchanged, so L9b's "In L9a, we wrote…" still holds.
- The deck got the same order and cuts: "What ℚ Means" now comes before
  "Exercise Styles". Rebuilt: 19 pages, zero overfull or underfull boxes,
  pages 12–15 checked.

The lecture, slide source, and slide PDF no longer match the hashes in the
reviewed snapshot above. The voice-calibration backup was refreshed to
include this change.
