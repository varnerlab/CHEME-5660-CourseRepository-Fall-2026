# L9b rebuild: American options, CRR pricing, intrinsic and extrinsic value — spec

Agreed with the instructor on October 11, 2026. This file records the design before
any notebook changes are made. L9b is taught on October 22. The build follows the L9a
pattern (`L9a-REDESIGN-SPEC.md`, `L9a-REDESIGN-HANDOFF.md`).

## Why

The 2026 L9b drafts were rated about 5/10 on October 11 (lecture 4, Hull example 6.5,
CRR chain example 4.5, extrinsic example 5, advanced CRR factors 5.5, deck 5). The
instructor: "I don't think they are as good as 2025 (which is another example of us
not using the previous materials effectively)."

- **The lecture is a rewrite.** Of its 71 prose sentences, 2 come from the 2025 L10a
  and L10b lectures. The 2025 American/CRR half is gone: the decision-rule schematic,
  the Hull figure, the CRR citation, the "worthless" box, and time decay. The Hull PNG
  sits in `figs/` and the lecture never shows it.
- **It is out of date.** It says L3b writes the rate as `g_f`, though L3b now uses
  `g_y` with `R_f = e^{g_y Δt}`. It ends with a forward pointer to L10a. Its notation
  clashes with L9a, which the instructor approved: `h` for the payoff, and `V` for the
  lattice value.
- **The examples load the October 2025 snapshots** (`MyOptionsChainDataSet`, AMD and
  NVDA) instead of the end-of-day archive. All three cut the disclaimer off
  mid-sentence.

## Decisions (October 11)

1. **Rebuild the lecture from the 2025 text.** The sources are Fall-2025
   `lectures/week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-CRR-Model-Fall-2025.ipynb`
   (`[25-L10a]`) and
   `lectures/week-10/L10b/CHEME-5660-L10b-Lecture-American-Derivatives-Intrinsic-Extrinsic-Value-Fall-2025.ipynb`
   (`[25-L10b]`). Changes are limited to notation, word-level fixes, and the items
   marked **NEW** below. Each one is flagged for his edit pass.
2. **The Hull example is taught in the lecture from the figure.** In class, we work
   through the CRR chain example and the extrinsic-value example. The Hull notebook
   becomes "review on your own".
3. **The decision-rule schematic is redrawn in TikZ**, light and dark, with `q` and
   the 2026 notation, and previewed before it is embedded.
4. **New theory is Option A** (preview `build/notebook-previews/L9b-rebuild-2026-10-11/decision4.png`).
   About 180 new words go inside his 2025 sections: the backward-induction display
   with his figure's labels, and the call/put early-exercise statement. Not taken: the
   draft's "Three Value Differences" and "When Is the American Premium Strictly
   Higher?" sections, with their `C`, `X`, `A`, `h` symbols and the bullet on
   dividends, negative rates, and funding spreads.
5. **The market section is sentence, three bullets, sentence** (preview
   `market-section.png`, text `proposed-market-section.md`). This is now his general
   default for long passages.

## Lecture

The file keeps its name, so the links in the deck, README, and schedule stay valid:
`lectures/week-9/L9b/CHEME-5660-L9b-Lecture-American-Derivatives-Intrinsic-Extrinsic-Value-Fall-2026.ipynb`.
It is markdown only.

| # | Section | Source | Changes |
|---|---|---|---|
| 0 | Title, hook, LOs, `__Notation:__` link | [25-L10a] cell 0 title; LOs from [25-L10a] 0 and [25-L10b] 0 | Title: "L9b: Pricing American Style Options Contracts using the Cox, Ross, Rubinstein (CRR) Binomial Model" ([25-L10a], verbatim). **NEW** hook, about 35 words: "In L9a, we priced European options, which can be exercised only at expiration. Standard options on stocks and ETFs are American-style and can be exercised at any time. What is the right to exercise early worth?" There are three LOs. The first is [25-L10a] LO1, verbatim. The second is [25-L10a] LO3, with the vague tail "to determine optimal pricing strategies" cut, so it ends at "incorporating the decision rule for early exercise". The third is [25-L10b] LO2, verbatim. Add the notation link `faq/notation.html#L9b`. |
| 1 | Examples | [25-L10b] cell 1 | Use the L6b group labels: "__We will work through these examples in lecture:__" (the CRR chain, then extrinsic value) and "__Review this example on your own.__" (Hull). Keep his descriptions. Remove "AMD" and "NVDA" (the ticker is a variable). Fix the broken `lectures/week-10/L10b/...` paths to relative links. |
| 2 | Concept Review: CRR Binomial Pricing Model | [25-L10b] cell 2 (up to the decision rule); L9a's American premium paragraph | Open with L9a's approved American-premium text and its `sup` display, `𝒫^AM ≥ 𝒫^EU`. Then come his CRR paragraph, the CRR (1979) reference, the boxed `q`, and the boxed `u`, `d`. Notation: `r̄ → g_y` and `𝒟_{1,0}(g_y)`. **NEW**, one sentence: this is L3b's `q = (R_f − d)/(u − d)` with `R_f = 𝒟_{1,0}(g_y) = e^{g_y Δt}`. The link to the advanced CRR-factors notebook follows the `u`, `d` box, as in [25-L10a] cell 5. |
| 3 | Decision-Rule for American Options | [25-L10a] cell 6, verbatim, then the redrawn figure | **NEW** (Option A): one lead-in sentence and the boxed two-line recursion. The American line takes the max of "exercise now", `V(K,S_{t,k})`, and "hold for the future", `𝒟⁻¹_{t+1,t}(g_y)·(q V̂_{t+1,k+1} + (1−q) V̂_{t+1,k})`. The European line holds only. One sentence follows: `S_{t,k} = S₀uᵏd^{t−k}` (L3b), the premium is `V̂_{0,0}`, and `𝒫^AM − 𝒫^EU ≥ 0` is the **early-exercise premium**. |
| 3a | Hull example (in the lecture) | [25-L10b] cell 2's Hull callout and question, then the Hull figure | Callout fixes: "probability of an up move is p" → "risk-neutral probability of an up move is q", and "risk-free interest rate be 5%" → "continuously compounded risk-free rate be g_y = 5%". **NEW**, two sentences reading the figure: at the down node at t = 1, exercising pays 12 while holding is worth 9.46, so the American holder exercises. That one decision raises the premium from 4.19 to 5.09 USD/share, an early-exercise premium of about 0.90 USD/share. Then an **Example:** stop pointing to the Hull notebook, to reproduce the tree node by node. |
| 4 | Compute the Price of an American Call and Put Option Contract | [25-L10b] cell 5 | The approved reshape (`proposed-market-section.md`): his lead sentence; bullets for model versus market (his two sentences, with the options archive in place of AMD), calls, and puts (**NEW**); then a closing sentence and the **Example:** stop. His handoff, "Having seen how the CRR model performs…", stays after it. |
| 5 | Extrinsic versus Intrinsic Value of American Options | [25-L10b] cell 6 | Reshape his sentences into sentence, three bullets, sentence: Intrinsic Value and Extrinsic Value (his two bullets), plus **Time decay** (his later paragraph, moved up). The `E_V(t)` displays, the out-of-the-money edge case, and the "Why do people pay money for something that is 'worthless'?" box stay verbatim. Fix: the expanded `E_V(t)` uses `𝒫(K,S(t))`, not `𝒫(K,S(0))`, because the intrinsic term is at `S(t)`. Remove "NVDA". Add the **Example:** label to the stop. A preview goes to him before the build embeds it. |
| 6 | Optional Advanced Material | **NEW**, house pattern | Link the advanced index and one bullet, "▶ title. Question? Two to four sentences.", for the rebuilt CRR-factors notebook. |
| 7 | Summary | [25-L10b] cell 7 | Keep his opener, three takeaways, and closer (there is no forward pointer). **NEW**, one sentence added to takeaway 1: the American premium exceeds the European premium only when early exercise pays, as for deep in-the-money puts. |
| 8 | Disclaimer and Risks | L9a cell 8 | Verbatim. This is the full text, including "should be used". |

Cut from the sources:
- From [25-L10a]: the Examples entries and Concept Review of single and composite
  contracts (composites are taught in L10b), European Style Contracts (now L9a), the
  lattice schematic, and the Binomial Lattice Model, Price Distribution, and
  Risk-Neutral Probability subsections. L3b teaches the lattice and `q`, and L9a's
  contingent-claims notebook derives `q` by replication.
- From [25-L10b]: the duplicate decision rule in cell 2, which section 3 now carries.
- The entire 2026 draft lecture, which is archived.

## Notation

The lecture keeps his 2025 symbols and L9a's: `V_c`, `V_p` (payoff), `𝒫_c`, `𝒫_p`,
`𝒫^AM`, `𝒫^EU`, `S(t)`, `𝒟`, and `g_y`. The only new symbol is `V̂_{t,k}` for the
value at lattice node `(t,k)`, taken from his 2025 decision-rule figure (`V̂⋆`). Using
it keeps `V` meaning the payoff, as in L9a, and resolves the FAQ Context row for `V`
that L9a left pending. Extrinsic value stays `E_V(t)`, his symbol. The examples adopt
the lecture's symbols in their markdown. Code variable names do not change.

## Examples

The ticker rule from `options-examples-eod-archive` applies to both market examples:
- The data cell sets `ticker = "NVDA"`, `quote_date = Date(2026, 10, 8)`, and
  `target_dte = 45`, as in L9a Example 1.
- `S₀` is `metadata["underlying_close"]`, and `T = DTE/365`.
- Only the columns used are shown.
- The prose never names the ticker or hardcodes a price or strike.

### CRR chain example (in lecture) — `CHEME-5660-L9b-Example-AmericanContractsPremium-Fall-2026.ipynb`

- **Data:** use `MyOptionsEODChainDataSet`. The volatility is `implied_vol`, which is
  `missing` on about 44% of archive rows, mostly far from the money. Skip a contract
  when its `implied_vol` is missing or below `σ_min`, and count the skipped contracts
  in the summary table.
- **Three Tasks** (regrouped, nothing deleted):
  - Task 1 prices the calls against the market.
  - Task 2 prices the puts against the market.
  - Task 3 compares the American and European premiums by strike: the call difference
    is zero, and the put difference is positive and largest deep in the money. The
    `european`, `raw_gap`, and `early_ex` columns and their checks move here, with
    one plot of `𝒫^AM − 𝒫^EU` against strike.
- **Text:**
  - The opener is a link plus a question.
  - The title becomes "Compute the Price of American Call and Put Option Contracts
    using CRR".
  - The two boxes, "Why δ is 15% and not something tight" and "Missing volatility",
    become one sentence, three bullets, sentence block about the widened band. It
    gives the reasons: the quotes and the share price are not simultaneous, the
    premiums are rounded to four significant digits, and each contract uses its own
    quoted implied volatility. A plain sentence covers the skipped contracts.
  - The Discussion questions lose the hardcoded `225.78`, `140`, and `400`.
  - The takeaways lose "diagnostics, not opportunities" and the hardcoded 2.30 USD/share.
- **Code:** the 12 `println` lines become one `pretty_table` (quantity | value |
  units), and the asserts stay. Plots keep `bg = "gray95"`.
- **Risk-free rate:** the drafts use `gᵧ = 0.040`, and L9a's BSM example uses 0.05.
  Look up the 3-month Treasury bill rate for October 8, 2026, and use it with a
  source comment.

### Extrinsic-value example (in lecture) — renamed `CHEME-5660-L9b-Example-ExtrinsicValue-Fall-2026.ipynb`

- **Rename:** `git mv` drops `NVDA` from the filename, because the ticker is a
  variable. Update the links in the lecture, the deck, the README, and the schedule.
- **Data:** the same archive cell. Task 1's contract is the out-of-the-money edge of
  the band within 5% of the share price, as in the draft. Add a filter for a
  non-missing `implied_vol`.
- **Three Tasks** (regrouped):
  - Task 1 decomposes one contract.
  - Task 2 prices the sweep across strike and time to expiration.
  - Task 3 plots the sweep and reads extrinsic value from it.
  - The raw 25×2 intrinsic matrix is no longer printed.
- **Text:**
  - The box "These are hypothetical contracts, not the NVDA chain" becomes a positive
    sentence: every contract in the sweep uses the Task 1 implied volatility, so
    only the strike and the time to expiration change.
  - Cut "That costs time, not accuracy", "It is computed, not quoted", and the hedge in
    takeaway 2.
  - Keep the deep-in-the-money Discussion question.

### Hull example (review on your own) — `CHEME-5660-L9b-Example-Hull-American-Put-Fall-2026.ipynb`

- **Keep:** the 2026 code. It fixes three 2025 bugs: the root cell printed node 2,
  `.extrinsic` was used as the continuation, and there was no European comparison. It
  already has three Tasks and the asserts against 5.0896 and 4.1927.
- **Text:**
  - The opener is a link plus a question.
  - Cut "Read the field names carefully", "so the three quantities are not confused
    with one another", and the semicolon sentence about CRR factors.
  - Keep one plain sentence: Hull's factors give `ud = 0.96`, so this tree is a
    binomial lattice but not a CRR lattice.
  - Use the lecture's symbols: `V(K,S)`, `V̂`, `E_V`, `𝒫^AM − 𝒫^EU`.
  - Make the Task-title case consistent.
- **Code:** the four `println` lines become a `pretty_table`.

### All three examples

- Restore the full disclaimer ("Only risk capital that is not required for living
  expenses should be used.").
- Re-execute each one from its folder with nbconvert.
- `Include.jl` gains `using Dates`.

## Advanced: CRR factors

Rebuild
`advanced/crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb` on his 2025
`CHEME-5660-L10a-OriginStory-CRR-Factors-Fall-2025.ipynb`. The target is about 450
words, against the draft's 1,260.

- **Body:** his derivation, nearly verbatim. His `p` stays, because it is the
  real-world up probability, as in L3b. Add a link-plus-question opener and three LOs.
- **NEW, one section in sentence, three bullets, sentence form:**
  - The lattice is priced with `q`, not with `p = 1/2`.
  - As the step shrinks, `q → 1/2`, so the variance match holds to leading order in
    `Δt`.
  - The lattice is valid only when `|g_y|√Δt < σ`, which keeps `0 < q < 1`. This is
    the `σ_min` that the CRR chain example uses.
- **Remove:** "honest", "deserves scrutiny", "Read the condition the right way
  round", and "on that ray".
- **README:** rewrite `advanced/README.md` to match. One advanced notebook is under
  the cap.

## Figures

- **NEW:** `figs/Fig-L9b-American-Decision-Rule.{tex,pdf,svg}`. It redraws his 2025
  `Fig-American-Contract-Decision-Schematic`:
  - a three-step lattice labeled `(u,q)` and `(d,1−q)`
  - a zoomed single decision cell
  - the rule with "exercise now" and "hold for the future" panels, in the `V̂`
    notation
  
  Use L9a's pipeline (`Makefile`, `theme_svg.py`, `vnfigure.sty`, light and dark,
  every color mapped). Preview it before embedding.
- **Keep** the Hull PNG, `figs/Fig-HullExample-American-v-European-Schematic.png`. Its
  numbers match the lecture. A TikZ redraw is optional later.

## Slide deck

Rebuild `slides/CHEME-5660-L9b-Slides-Fall-2026.tex` to mirror the new lecture's
order and headings. It stops at the same examples, with compact frames, PDF figures,
and tight text, and it keeps the title and disclaimer convention. Expect about 15
frames. Use the decision-rule PDF, the Hull figure, the market section's three
bullets, the extrinsic-value bullets with the `E_V` box, and the advanced and summary
frames. The deck must build with zero overfull boxes, and every page is rendered and
checked.

## Records

- `code/docs/faq-src/content.json`: add an `L9b` notation table (`V̂_{t,k}`,
  `S_{t,k}`, `t`, `k`, `u`, `d`, `q`, `σ`, `Δt`, `𝒟_{t+1,t}(g_y)`, `𝒫^AM`, `𝒫^EU`,
  early-exercise premium, `E_V(t)`). Fill the pending Context row for `V` (L9a and
  L9b payoff) and `V̂` (L9b node value). Rebuild `notation.html` from a filtered
  copy, as in `l9a-redesign-status`.
- `lectures/LECTURE-ARTIFACT-SCHEDULE.md`, row 9b: the status and the renamed example.
- `README.md` (week 9) and `AGENTS.md`: add an "L9b rebuild — October 2026" entry
  pointing here.

## Archive

`lectures/archive/week-9-L9b-before-rebuild-<date>/` gets the 2026 draft lecture,
deck, and advanced notebook, with a README and `SHA256SUMS`. Nothing moves into a later
week.

## Build and QA

The working folder is `build/notebook-previews/L9b-rebuild-2026-10-11/` (gitignored).

1. **Lecture builder** `build_lecture.py`: assembles the lecture from the 2025 cells.
   Every edit is an exact-match `sub()`, so the change list can be audited. Previews
   compare each section with 2025 (green new, red removed).
2. **Example and advanced builders**, one edit script each, with before/after
   previews. Re-execute each notebook with nbconvert and check that it has no error
   outputs.
3. **Checker** `check_l9b.py`, adapted from `check_l9a.py`:
   - three LOs and takeaways, the notation link, a 30–40 word hook, the H2 order
   - no `g_f`, `L10a`, `r̄`, `AMD`, `NVDA`, `225.78`, `207.04`, or `println`
   - no semicolons or forward pointers, and no denial patterns
   - three Tasks per example, the full disclaimer, and contiguous asserts
   - relative links that resolve inside `L9b/`, and theory stated before the stop that
     uses it: the recursion before the Hull stop, and the call/put statement before
     the CRR chain stop
4. **QA:** a fresh reviewer scores each notebook 0–10 from rendered pages. The brief
   includes structure, repetition, and figure quality. The manager renders and looks
   at every page before reporting a score. Anything under 9 is polished in the same
   round.
5. **His review:** page previews and a handoff, `L9b-REBUILD-HANDOFF.md`. Back up the
   lecture for voice calibration before his hand edits.

## Verification

- Hull: `𝒫^AM = 5.0896`, `𝒫^EU = 4.1927`. At the down node at t = 1, exercising pays
  12 and holding is worth 9.4639.
- The CRR chain example on the archive: the American and European call premiums are
  equal to rounding, and every put has `𝒫^AM ≥ 𝒫^EU`. Run the same code for all 31
  tickers, as was done for L9a.
- The extrinsic example on the archive: Task 1's contract has zero intrinsic value,
  and the premium is non-decreasing in time to expiration at a fixed strike.

## Out of scope, flagged

- L3b's cell says "We will derive this rule when we study options later in the
  course". L9a's contingent-claims notebook does that. L3b is released and not
  edited.
- A TikZ redraw of the Hull figure.
