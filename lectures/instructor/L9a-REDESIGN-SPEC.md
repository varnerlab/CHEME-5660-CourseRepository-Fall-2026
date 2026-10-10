# L9a redesign: derivatives, options, and European pricing — spec

Agreed with the instructor on October 9, 2026, in a brainstorming session. This file
records the design before any notebook changes are made.

> **Superseded in part (October 9, after the build).** The lecture's sections 4–6 were
> restructured interactively with the instructor. The current outline, the redrawn
> contract figure, and the decisions behind them are in `L9a-REDESIGN-HANDOFF.md`
> under "Interactive restructure". The assembler and the `new/` fragments no longer
> build the lecture.

## Why

L7b ran into trouble, so the L7b material is retaught in L8b (October 15). As a
result, options no longer start in L8b. L9a (October 20) now has to introduce
derivatives from scratch and price European options. The instructor's requirements:

- Introduce derivatives broadly: the contract families and the size of the market.
  Kalshi is the motivation. "This is not a lecture about Kalshi."
- Calls, puts, American and European exercise (and possibly other styles), and
  Black–Scholes–Merton (BSM) are required.
- Tie options to contingent claims and to the course's abstract-asset/NPV framing:
  "I have to pay for something today, that may (or may not) have value in the future."
- At most two examples. "Keep things tight, but highly rigorous."
- **The critical path comes from the instructor's own text.** He chose the 2025
  state-and-verify route to BSM for the lecture. The new replication-to-BSM
  derivation goes into an optional advanced notebook: "I like A - but ... I just
  don't trust you to generate 'critical path' content that doesn't take me inf time
  to revise." New lecture prose is limited to the items marked **NEW** below, and
  each one is flagged for his edit pass.

L9b (American contracts, CRR) is not part of this redesign.

## Lecture

New file:
`lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb`.
Working title: "L9a: Introduction to Derivatives and European Option Pricing".

Source notebooks (Fall-2025 repository):

- `[25-L9b]` = `lectures/week-9/L9b/CHEME-5660-L9b-Lecture-IntroductionToDerivativesContracts-Fall-2025.ipynb`
- `[25-L10a]` = `lectures/week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-CRR-Model-Fall-2025.ipynb`

| # | Section | Source | Changes |
|---|---|---|---|
| 0 | Title cell, LOs, `__Notation:__` link | [25-L9b] cell 0 | **NEW** Kalshi hook: link sentence plus a question, about 30–35 words. A Kalshi contract costs `p` today and pays $1 at `T` if the event occurs, nothing otherwise. Three LOs, retargeted from composite contracts to BSM: classify derivatives, payoff and profit, price European contracts. Add the notation link `faq/notation.html#L9a`. |
| 1 | Examples | [25-L9b] cell 1 pattern | Two entries (see Examples). Group label per the L6b lesson. |
| 2 | Company Profile: Cboe Global Markets | **NEW** (~300–360 words) | Follow the L4b Jane Street pattern and the "profiles teach the idea" rule. Proposed bullets: opened 1973 as the first listed options exchange, the same year Black and Scholes published. SPX options are European-style and cash-settled, while equity and ETF options are American-style. Cboe and OCC are the source of the market-size data. Cboe Predicts (2026) lists binary S&P 500 contracts as options. The connection paragraph derives from the lecture's result: a binary contract's price is a discounted ℚ-probability. No scandals (e.g. VIX-manipulation suits). Verify every fact (see Verification). |
| 3 | What is a Derivative? | [25-L9b] cell 3, verbatim | **NEW**, one sentence: in L1b's language, a derivative is an abstract asset, a price paid today for a future cash flow that depends on the underlying and may be zero. **NEW**, one bullet: event contracts (Kalshi, Cboe Predicts) pay a fixed amount if an event occurs. |
| 3a | How big is the US options market? | [25-L9b] cell 3 | Same table shape, refreshed to 2025 full year (OCC: about 15.21B contracts, +24.4% over 2024; single-day record of 110M on Oct 10, 2025) plus the latest 2026 year-to-date figure. Replace the `utm_source=chatgpt.com` links with clean URLs. Cell 4's raster figure becomes the TikZ remake `Fig-L9a-Contract-Right-Obligation` in the same position (see Figures). |
| 4 | Call and Put Options Contracts | [25-L9b] cell 5, verbatim | Business case, call and put payoff, buyer and seller profit, Contract Styles boxes, European and American premium, arbitrage box. Apply only the fixes listed below. Add a Bermudan bullet to the Contract Styles box. **Add** one breakeven display per contract, `S_BE = K + 𝒫_c` (call) and `S_BE = K − 𝒫_p` (put), with one sentence each, because Example 1 derives and checks them (rule: an example never introduces theory the lecture has not stated). Fix 1 covers the put bound that Example 1 checks. The Example 1 stop stays where it is. |
| 5 | Options as Abstract Assets (bridge) | **NEW** (~200 words plus 3 displays) | See the next section. It sits after the Example 1 stop and before section 6, and turns "what does it pay?" into "what is it worth today?". It opens with the cash-flow figure `Fig-L9a-Option-CashFlows` (see Figures). |
| 6 | European Style Contracts | [25-L10a] cell 3, verbatim | Nobel box, European call and put, BSM formulas, Example 2 stop. `r̄ → g_y`. **Add** put–call parity (decided October 9: an example cannot check theory the lecture never stated): the model-free payoff identity `V_c − V_p = S(T) − K`, discounted under ℚ with the bridge's `𝔼_ℚ[𝒟⁻¹ S(T)] = S(0)`, gives `𝒫_c − 𝒫_p = S(0) − K·𝒟⁻¹_{T,0}(g_y)`. That is two displays and two sentences. The derivation uses only linearity and the bridge, not BSM. |
| 6a | Optional Advanced Material | **NEW** (added October 9 during the build) | The house section that L5b through L7b end with: a link to the advanced index and one "▶ title. Question? Two sentences." bullet per notebook. It links both advanced notebooks, so the SPXW skew notebook that the old lecture linked stays reachable. |
| 7 | Summary | [25-L9b] cell 7 | Three key takeaways retargeted: derivatives as contracts on an underlying; payoff vs profit; the premium is a zero-expected-NPV price under ℚ, computed by BSM. The closing line covers what this lecture did, with no forward pointer. |
| 8 | Disclaimer and Risks | [25-L9b] cell 8 | Verbatim. |

Cut from [25-L9b]: the bandit Concept Review (cell 2) and Composite contracts (cell 6),
which L10b teaches.

### Fixes to the 2025 text (phrase-level; each fixes a real error)

1. Short put, "Short put contracts have unlimited downside risk": the loss is bounded
   at `K − 𝒫_p` per share, reached when `S(T) = 0`.
2. Contract Styles boxes, "American-style ... typically have higher premiums": an
   American contract is worth at least as much as the European one (`𝒫^AM ≥ 𝒫^EU`).
3. American premium, `max_{τ∈[0,T]}`: τ ranges over exercise rules that use only the
   information available at the time (stopping times). Use `sup` over those rules.
4. `𝔼(…)` becomes `𝔼_ℚ(…)` in the premium conditions, matching L3b's ℚ.
5. Arbitrage box, "if the premium were too low relative to expected value, traders
   would buy": that describes a bet, not an arbitrage. Add one clause naming a
   replicating portfolio of shares and the risk-free asset, and link the advanced
   notebook.
6. `r̄ → g_y` throughout (the continuously compounded risk-free rate, the 2026 symbol
   from L2a). His other symbols stay: `𝒟_{T,0}`, `V_c`, `V_p`, `𝒫_c`, `𝒫_p`, `d₊`,
   `d₋`, `N(·)`.

### Section 5: Options as Abstract Assets (bridge content)

The mathematics is agreed. The prose is new, so draft it tightly and flag it.

- **The cash flows:** premium `𝒫` paid at 0, payoff `V(K,S(T)) ≥ 0` received at `T`.
  This is the L4a/L5a stock trade with the sale proceeds replaced by the payoff:
  `NPV₀ = −𝒫 + 𝒟⁻¹_{T,0}(g_y)·V(K,S(T))`.
- **Pricing condition:** a Treasury's cash flows are known, so NPV = 0 gives the price
  (L1b, L2a). An option's payoff is random, so the condition becomes
  `𝔼_ℚ[NPV₀] = 0`, which gives `𝒫 = 𝔼_ℚ[𝒟⁻¹_{T,0}(g_y)·V(K,S(T))]`. This is the
  premium condition of section 4.
- **What ℚ means:** under ℚ, the L5a share also has zero expected NPV, because
  `𝔼_ℚ[𝒟⁻¹_{T,0}(g_y) S(T)] = S(0)` when the price grows at `g_y` (no dividends). ℚ is
  the measure under which every traded abstract asset is a zero-expected-NPV
  investment at the risk-free rate.
- **"May not have value":** the scaled NPV is `ρ_T = 𝒟⁻¹_{T,0}(g_y)·V/𝒫 − 1 ≥ −1`, with
  equality whenever the option finishes out of the money. Under ℙ (GBM),
  `ℙ(ρ_T = −1) = ℙ(S(T) ≤ K) > 0` for a call, which L5a's terminal-target formula
  computes. For the share, `ρ_T > −1` always (L5a).
- **Kalshi closes the loop:** `V = 1{event}` gives `p = 𝒟⁻¹_{T,0}(g_y)·ℚ(event)`. The
  price is a discounted ℚ-probability, not a forecast.
- **Profit vs NPV, one sentence:** the profit `V − 𝒫` of section 4 is undiscounted.
  The NPV breakeven is `K + 𝒫·𝒟_{T,0}(g_y)` rather than `K + 𝒫`.

## Figures (decided October 9: TikZ, light and dark)

The instructor: "remake all schematic figs using tikz, in the figs folder (pdf,svg) -
write into lecture so dark or light themes work." Every schematic in the lecture is a
TikZ standalone in `lectures/week-9/L9a/figs/`. Each one builds to a PDF (light
palette, used by the deck) and an SVG (used by the notebook) that follows the reader's
theme. There are two:

| Figure | Where | Source | Content |
|---|---|---|---|
| `Fig-L9a-Contract-Right-Obligation` | Section 4, top (his cell 4 position) | Remake of his `Fig-Options-Contracts-Fall-2024.png`, reusing the layout of the archived L8b TikZ remake | His definition sentence as the heading. A call row and a put row. In each, the buyer holds the right and the seller the obligation. The premium arrow is solid (always paid), and the shares-at-`K` transfer is dotted (only if exercised). Labels use his 2025 terms and symbols: buyer and seller (not long/short or holder/writer), `𝒫_c`, `𝒫_p`, `K`, `T`, `S(T)`, and no multiplier `q`. One label changes: his legend "probability p" becomes "only if exercised", because `p` is the Kalshi price in this lecture. |
| `Fig-L9a-Option-CashFlows` | Section 5, top | **NEW**, modeled on L2a's `Fig-L2a-TBill-CashFlows.tex` (same timeline, time-point units, and paid/received arrow styles) | Premium `𝒫` paid at `t = 0`. Payoff `V(K,S(T)) ≥ 0` received at `t = T`, drawn dashed and labeled "may be zero". Structural only, with no equations beyond the two labels. Previewed for approval before it goes in, and dropped if he prefers text alone. |

**Theme pipeline (the L5b covariance schematic is the precedent):**

- `figs/Makefile`: `xelatex` builds the PDF, `pdf2svg` converts it to SVG, and
  `theme_svg.py` adds a `prefers-color-scheme: dark` palette keyed to the light
  colors. `.DELETE_ON_ERROR` keeps a failed theme step from leaving an unthemed SVG.
- `figs/theme_svg.py`: copied from L5b, with the color map extended to the colors
  these figures use (card tints, panel fills). An unmapped color fails the build on
  purpose. The figures draw no full-page white background, so the notebook's own
  background shows through.
- Palette: `vnfigure.sty` and `vnflow.sty` from `lectures/templates/`.
- `figs/README.md`, as in L5b: what each figure shows, how to build it, and how the
  theming works.
- Notebook HTML: L5b's embed. That means the `<div><center><img …></center></div>`
  wrapper with `class="course-diagram"` and alt text, preceded in the same cell by
  L5b's `<style>` block, which passes VS Code's theme to the SVG. The contract figure
  is 780 wide (his 2025 width) and the timeline is 680 (the L1b and L2a timeline
  width). The style guide's `<p align="center">` rule is a 5800 lesson and is not
  used here. Outside VS Code the figure follows the viewer's color scheme, and print
  uses the light palette.
- The deck includes the PDFs.
- Plots that example code generates are not schematics and are out of scope.

## Examples (two, moved rather than rewritten)

1. **Single-contract payoff and profit.**
   `git mv` from `lectures/archive/week-8-L8b-options-2026-10-09/week-8/L8b/CHEME-5660-L8b-Example-SingleContractPayoffProfit-Fall-2026.ipynb`
   (archived October 9, see below)
   to `lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb`.
   Mechanical changes only:
   - Fix the two in-text lecture mentions written from L8b's point of view. Cell 14,
     "which is what L9a does", becomes "which is what the BSM premium example does".
     Cell 15, "L9a and L9b take up the difference", becomes "The lecture takes up the
     difference" (no forward pointer). The Summary's last sentence ("Understanding
     single contracts prepares us for composite strategies...") is a soft forward
     pointer. Leave it and flag it for him.
   - Make the example meet the three-task rule by retitling "## The Four Positions
     Side by Side" as `## Task 3: …` (regroup, never delete).
   - Align symbols to the lecture (see the decision below).
   - Move every `@assert` into one `# checks -` block (October 8 rule) if it is not
     there already.
   - The AMD chain comes from the package (`MyOptionsChainDataSet`), so no data moves.
2. **BSM premium** (`CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb`, already in
   place). The only code changes are the October 8 checks-block rule in cells 27 and
   30, where the asserts are scattered. The Summary's last sentence ("Next, L9b
   adds the American exercise right...") is a forward pointer. Replace it with one
   sentence reading the Monte Carlo vs BSM agreement as "the expected NPV under ℚ at
   the BSM premium is zero within standard error." Align symbols to the lecture,
   including `S_{0}` → `S(0)` in the Discussion.

**`Include.jl`:** merge the two. L9a's file gains `using Colors` from L8b's, and the
header comment is updated.

**Notation (decided October 9: least disruptive).** The lecture keeps the
instructor's 2025 symbols: `𝒫_c`, `𝒫_p` for premiums, `V_c`, `V_p` for payoffs,
`P_c^buyer` and `P_c^seller` for profit, `S(T)`, `S(0)`, `𝒟_{T,0}`, `d₊`, `d₋`, `N(·)`.
The only lecture swap is `r̄ → g_y`. Why this is least disruptive:

| Option | Edits to his sentences | Other edits | Consistent with |
|---|---|---|---|
| Keep 2025 symbols in the lecture (chosen) | none (only `r̄ → g_y`, 14 places) | about 28 symbol swaps in the two examples' markdown (`C₀`/`P₀` → `𝒫`, `h` → `V`, and Example 1's `Π` → `P`) | Weeks 10a and 10b, which already use `𝒫_c`, `V_c`, `S(T)` |
| Adopt the 2026 example symbols | about 32 swaps inside his text | none | L9b only |

- Code variable names are unchanged.
- `S_T` (L4a–L5a, the examples) and `S(T)` (his text, week 10) both stay. The
  notation page states that they are the same terminal price.
- Example 1 keeps its own `θ` for position direction, because it defines `θ` where
  it builds the contracts.
- Cross-lecture caveat: L9b uses `V` for the lattice value and `h` for the payoff.
  Record this in the notation FAQ's "Context" table rather than editing L9b.

## Advanced notebooks (cap of 2)

1. **NEW: Contingent Claims and BSM.**
   `lectures/week-9/L9a/advanced/contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb`.
   Markdown only, a derivation companion. It follows the "Derivation companions are
   judged differently" section of the style guide, the 2025 OriginStory pattern, and
   the one-step-per-line `align*` layout with a reason column. Outline:
   1. Title, three objectives. The law of one price for abstract assets with random
      cash flows: identical cash flows in every state imply identical NPV.
   2. One-step replication: solve `Δ`, `B`, which gives
      `V₀ = [qH_u + (1−q)H_d]/R_f` and `q = (R_f − d)/(u − d)`. This keeps L3b's "we
      will derive this rule when we study options". The no-arbitrage condition is
      `d < R_f < u`.
   3. State prices `ψ_u = q/R_f`, `ψ_d = (1−q)/R_f`. NPV generalizes from L1b's
      `⟨𝒟⁻¹, c⟩` over dates to `⟨ψ, c⟩` over states. A Kalshi YES/NO pair is the two
      Arrow–Debreu claims on an event, and YES + NO is a zero-coupon bond (parity in
      miniature).
   4. From the lattice to GBM under ℚ with drift `g_y`: stated as a proposition with
      its assumptions, referring to the L4b lattice-limit example in words. Girsanov
      is not proved.
   5. Digital: `𝔼_ℚ[1{S(T) > K}] = N(d₋)`. This is L5a's terminal-target box with
      `μ_g → g_y − σ²/2` and `K = S(0)(1+ρ⋆)e^{g_y T}`. State that `N ≡` L5a's `Φ`.
   6. Asset-or-nothing: `𝔼_ℚ[S(T)·1{S(T) > K}] = S(0) e^{g_y T} N(d₊)`, by completing
      the square.
   7. The call is the asset-or-nothing claim minus `K` digitals, which gives BSM. The
      put follows from the payoff identity `V_c − V_p = S(T) − K`, then parity, then
      BSM.
   8. Reading `N(d₋)` and `N(d₊)`: `N(d₋)` is the ℚ-probability of exercise and
      `N(d₊)` is not. The BSM price of the Kalshi-style claim "S(T) > K" is
      `𝒟⁻¹ N(d₋)`.
   9. Summary of assumptions.
   His symbols plus `g_y`, no dividend yield (the package BSM has none).
2. **Keep** `advanced/spxw_volatility_skew/` (existing L9a).
3. **Archive** `lectures/week-8/L8b/advanced/static_replication/`, since the composite
   positions it builds on have left the lecture.

Rewrite `lectures/week-9/L9a/advanced/README.md` to list the two notebooks.

## Archive and moves

- **Done October 9.** The entire L8b options folder moved with `git mv` to
  `lectures/archive/week-8-L8b-options-2026-10-09/`, with its own README and
  `SHA256SUMS`. `lectures/week-8/` now holds only L8a, and the instructor is
  building the new L8b. During the build, `git mv` these out of the archive:
  - the single-contract example → L9a (Examples, item 1)

  The L8b deck, the 2024 raster `Fig-Options-Contracts-Fall-2024.png`, and the L8b
  TikZ figure stay archived as sources for the L9a deck and the L9a figure.
- **At build time:** archive the old L9a lecture
  `CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb`, the old L9a deck,
  and the three figures in `L9a/figs/` that nothing in week 9 references
  (`Fig-American-Contract-Decision-Schematic`, `Fig-HullExample-American-v-European-Schematic`,
  `Fig-Lattice-Schematic`. L9b keeps its own Hull PNG, L3b and L4a keep their own
  lattice SVG, and nothing references the decision schematic), in
  `lectures/archive/week-9-L9a-before-redesign-<date>/`.

Nothing moves into a later week (no-forward-pointers rule).

## Slide deck

Rebuild `lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.tex` from the L8b
deck (derivative and payoff frames) and the old L9a deck (BSM frames). It mirrors the
notebook's order and headings and stops at the same examples, with compact frames,
PDF figures, and tight text. Add a profile frame and a bridge frame. The slide
workflow is outside the voice reset.

## Records

- `code/docs/faq-src/content.json`: add an `L9a` notation entry (𝒫_c, 𝒫_p, V_c, V_p,
  K, T, S(T), 𝒟_{T,0}, g_y, σ, d₊, d₋, N, ℚ, ℙ, NPV₀, ρ_T, τ, p). Extend the
  "Context" table for V and for p (Kalshi price vs real-world up probability in L3b).
- `lectures/LECTURE-ARTIFACT-SCHEDULE.md`: update the 9a row. The 8b row follows the
  L7b-redo work.
- `schedule-2026-update.md`: update the F40 (9a) topic. F36 (8b) follows the L7b redo.
- `AGENTS.md`: add an "October 9 options redesign" entry that points to this spec.
- Same-bundle stale references: the L9b notebooks no longer mention L8b (checked
  October 9). Only the L9b deck's header comment (line 11, "Payoff functions h_c/h_p
  are L8b/L9a's") does. Update it to say L9a writes the payoffs as `V_c`, `V_p`.

## Verification

- **Facts:** every dated fact in the profile, the market table, and the hook has a
  primary or reputable source, re-checked at authoring time:
  - Cboe opening date (1973).
  - Black–Scholes publication date (JPE, 1973).
  - SPX exercise and settlement style.
  - Cboe Predicts launch date, terms, and brokers. This is reported for June 2026 and
    still needs confirmation.
  - OCC 2025 totals and the record day.
  - Jobs, internship, and YouTube links (publishers identified).
- **Rules:**
  - Exactly three LOs and three KTs.
  - `___` before each H2 and closing the Summary and Disclaimer.
  - Example callouts use the `__Example:__` + `▶` format.
  - Links only within `week-9/`. Earlier lectures (L1b, L2a, L3b, L4a, L5a) are
    referred to in words.
  - No forward pointers.
  - No semicolons as clause joiners in new prose.
  - No denials of unproposed misreadings.
  - No language or package detail in the lecture.
- **Mathematics:** check the bridge identities. In particular, under GBM with
  `μ = g_y`, `𝔼_ℚ[ρ_T] = 0` for the share, and `ℙ(S(T) ≤ K)` matches L5a's formula with
  `ρ⋆` mapped to `K`. Check every step of the advanced derivation numerically against
  the package BSM.
- **Execution:** re-execute both examples with nbconvert (stored outputs current, no
  errors), build the deck, and check that every relative link resolves inside
  `week-9/`.
- **Figures:** `make -C figs distclean all` builds both figures from scratch. Render
  each SVG in the light and dark schemes and check text and arrow contrast in both.
  Show the previews before embedding.
- **Review:** present the five NEW items (hook, profile, derivative sentence and
  bullet, bridge, summary takeaways) to the instructor as before/after previews for
  his edit pass, and back up before he edits (voice-calibration protocol).

## Out of scope, flagged

- L9b says L3b uses `g_f` (it now uses `g_y`) and describes `q` as derived in L3b. Once
  the advanced notebook exists, that text is stale.
- L9b links three examples, over the cap of two.
- The L10a lecture mentions L8b (week-10 work).
- The L7b redo in L8b is a separate workstream.
