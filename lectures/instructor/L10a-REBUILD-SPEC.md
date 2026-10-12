# L10a rebuild: option sensitivities (the Greeks) — spec

Approved by the instructor on October 12, 2026 ("Approve"). L10a is taught on
October 27. The build follows the L9b pattern (`L9b-REBUILD-SPEC.md`,
`L9b-REBUILD-HANDOFF.md`).

## Why

The instructor: "This doesn't seem to be well structured … it just doesn't seem to be
well organized, or at the same level of rigor of the other notebooks. Also: no
company profile". The October 11 Codex update (uncommitted, archived in
`lectures/archive/week-10-L10a-before-rebuild-2026-10-12/`) was rated 5/10:

- **Little of his text kept.** It keeps 32 of 125 lecture sentences from his Fall-2025 L11a
  text. The committed version kept 62 of 83. It grew from 1,752 to 2,327 words.
- **New theory in the middle.** A new H2 (central differences, the Leisen–Reimer
  Peizer–Pratt construction, ten BSM Greek formulas, and changelog prose about "the existing
  example functions") splits the thread.
- **Notation drift.** It uses $r$, κ, $p$, $d_1/d_2$, and τ for remaining time. L9a/L9b use $g_y$,
  $q$, $d_\pm$, and τ for the exercise time.
- **POE renamed.** Calling it "terminal ITM probability" breaks L10b and the example filename,
  and a dangling "probability of exercise" sentence is left behind.
- **Repetition and defects.** "Delta is not a probability" appears about six times. Two boxed
  displays inside blockquotes break in HTML. There are three clause semicolons and an em-dash
  pair.
- **Missing house pieces.** No hook, no notation link, no company profile, and no Optional
  Advanced section. The Concept Review figure is still the 2025 NVDA plot.

## Decisions (October 12)

1. **Rebuild the lecture from his 2025 text.** The source is Fall-2025
   `lectures/week-11/L11a/CHEME-5660-L11a-Lecture-American-Derivatives-Greeks-Fall-2025.ipynb`
   (`[25-L11a]`).
   - Changes are limited to notation, word-level fixes of real errors, and the items marked
     **NEW** below, each flagged for his edit pass.
   - The retained 2026 legacy notes `docs/Notes.tex` are NOT a source. The instructor called
     them stale on October 12.
2. **Leisen–Reimer and the convergence study move to an advanced notebook.** The package code
   stays (`code/src/BinomialSensitivities.jl`).
3. **The company profile is Susquehanna International Group (SIG),** an options market maker.
   Its daily business is the lecture: it sells options, hedges Delta with shares, and manages
   Gamma and Vega.
4. **Both examples move to the end-of-day options archive** in this build. The ticker is a
   variable, contracts are chosen by rule, and the quote date is October 8, 2026.

## Lecture

The file keeps its name. It is markdown only. It is built by
`build/notebook-previews/L10a-rebuild-2026-10-12/build_lecture.py` from the 2025 cells, with
exact-match substitutions.

| # | Section | Source | Changes |
|---|---|---|---|
| 0 | Title, hook, LOs, notation link | [25-L11a] 0 | **Title:** kept ("L10a: Sensitivity Analysis of American Options Premium"). **NEW hook** replaces the generic two-sentence opener: the L2b duration/convexity link, the L9b link, and the question. **LO1:** "total differential" → "a local Taylor expansion". **LO2:** "hedge ratio and probability measure" → "hedge ratio and a probability estimate", and "use Delta to estimate the probability" → "compare Delta with the probability". **LO3:** "compute the probability of exercise using Delta to estimate the likelihood of finishing in-the-money at the strike price" → "compute the probability of exercise from the same distributions at the strike price". **Notation:** add the `#L10a` link. |
| 1 | Examples | [25-L11a] 1 | Use the house label "__We will work through these examples in lecture:__". Use his descriptions, with the ticker names removed and the new filenames. |
| 2 | Concept Review | [25-L11a] 2–4 | Verbatim, except "an NVDA call option contract" → "a call option contract" and the "Hmmmm" callout loses "in this case NVDA". The figure is regenerated from the 2026 L9b extrinsic-value example (the archive, default ticker) and saved as `figs/CHEME-5660-L9b-Example-ExtrinsicValue-Fall-2026.svg`. |
| 3 | Company Profile: Susquehanna | **NEW** | House format, as in L7b Wealthfront and L9a Cboe: an intro paragraph, a "What does the firm do?" blockquote, "Explore further:", and "Connection to today's lecture:" derived from the lecture's result (a short call hedged with $-100\cdot n\cdot\Delta$ shares). Facts are verified, with no controversies. About 300–360 words. |
| 4 | Options Premiums and Market Conditions | [25-L11a] 6 | Greek bullets as his, except the Delta bullet: "and the probability that" → "and is often used to estimate the probability that". The factor list drops "and dividends" (never treated). **Derivation:** his expansion, with type $\star\in\{c,p\}$ (his 2024 symbol, replacing $\tau$), calendar time $t$, $g_y$ in place of $r$, finite changes $\Delta S$, and "≈ second-order Taylor expansion" in place of "total differential". **NEW:** one units sentence pair (platform quotes $\Theta/365$, $\nu/100$, $\rho/100$); one sentence that $\Delta$ and $\Gamma$ play duration and convexity's roles; and a worked example in L2b style ($\Delta=0.50$, $\Gamma=0.02$, ±5 USD/share). His "Let's walk through the major Greeks…" is cut (no walkthrough follows). |
| 4a | Computing the Greeks of American Options | **NEW** H3 | One sentence (no formula to differentiate, so reprice the CRR tree with one input moved by $\pm\epsilon$), the central-difference display for $x\in\{S,\sigma,t,g_y\}$ and $\Gamma$, and one sentence on the European check ($\Delta_c=N(d_+)$; a call's American and European premiums are equal, L9b), with his "click me" link to the advanced notebook. Then his "Let's look at an example…" line and the Example stop. |
| 5 | The Secret Lives of Delta | [25-L11a] 7 | **Hedge bullet:** "for every $n$ contracts held ($n<0$ if the contracts are sold) … hold $-100\cdot n\cdot\Delta$ shares". **Probability bullet:** "Delta can also be interpreted as the probability" → "Delta is also often used as an estimate of the probability". "we can use $\Delta$ to estimate the probability of exercise" → "we can compare $\Delta$ with the probability of exercise". **NEW**, one sentence before his conjecture line: in the L9a BSM model, $\Delta_c=N(d_+)$, while the risk-neutral probability of finishing in the money is $N(d_-)$, which is smaller. POE keeps its name. The `>` is added on every line of the two boxed displays (HTML fix). The `TSLA` mention is removed. |
| 6 | Optional Advanced Material | **NEW**, house pattern | Link the advanced index, with one bullet (▶ title. Question? Two to four sentences). |
| 7 | Summary | [25-L11a] 8 | Opener and closer verbatim. **KT1:** the second sentence becomes the Taylor-expansion and CRR-repricing statement. **KT2:** the probability clause is reframed as an approximation we checked. **KT3:** "uses Delta to estimate" → "uses projected distributions at the strike price to estimate". |
| 8 | Disclaimer | L9a | Full text. |

**NEW prose budget:** about 300 words plus the company profile. Every NEW item is listed in the
handoff for his edit pass.

## Examples (EOD archive)

The data cell copies the L9b examples:
- `ticker` (a variable), `quote_date = Date(2026, 10, 8)`, and `target_dte = 45`
- `MyOptionsEODChainDataSet`
- $g_y = 0.0413$: the continuously compounded 13-week T-bill rate on October 8, 2026, as in L9b

Rules for both examples:
- Run every example for all 31 archive tickers to confirm the selection rules work.
- Never hardcode a strike or a price in prose.
- Follow the 2026 example house rules:
  - three `## Task N:` sections, each opening with "In this task, …"
  - `pretty_table` with `column_labels`, not `println`
  - `bg = "gray95"`
  - "100 shares per contract"
  - one-contract USD in summary tables
  - asserts in a final checks block
  - the full disclaimer

### `CHEME-5660-L10a-Example-Greeks-PutCall-Fall-2026.ipynb` (renamed from `…-NVDA-…`)

Voice and structure source: Fall-2025 `L11a/CHEME-5660-L11a-Example-Greeks-PutCall-NVDA-Fall-2025.ipynb`.

- **Data:**
  - Ticker default `"NVDA"`.
  - One call and one put at the listed strike nearest `metadata["underlying_close"]` that has a non-missing implied volatility.
  - The premium is the mid quote.
  - The archive's Alpaca `delta`, `gamma`, `theta` (per calendar day), `vega`, and `rho` (per percentage point) are the quotes to compare with.
- **Method:**
  - Each Greek is a central difference of repriced CRR premiums, computed in the open as in the lecture display (`binomial_premium(...; method=:crr)` from the package).
  - Each one is checked against `binomial_greeks` and the scaled archive quote.
  - For the call, the BSM Greeks give a check, because American and European calls agree with no dividend.
- **Task 1:** the long call's five Greeks, each with his "Check: how close…" comparison.
- **Task 2:** the long put's five Greeks, with the same checks. It also shows how the Greeks change with strike: CRR versus archive Delta and Gamma across the chain's strikes. If cheap, it also covers time to expiration, with the at-the-money Greeks across the archive's expiration ladder. If time to expiration is not shown, report it, so the lecture's link description can be edited.
- **Task 3:** his long-to-short conversion. Then the one-contract position (100 shares per contract), the Delta hedge in shares, and Delta-only versus Delta–Gamma estimates against full repricing for a few share-price moves.
- **Moved out:** the CRR/LR convergence material goes to the advanced notebook.

### `CHEME-5660-L10a-Example-POE-POP-Call-Fall-2026.ipynb` (renamed from `…-TSLA-…`)

Voice and structure source: Fall-2025 `L11a/CHEME-5660-L11a-Example-POE-POP-TSLA-Call-Fall-2025.ipynb`.

- **Data:**
  - Ticker default `"NVDA"`. His 2025 choice was TSLA, but TSLA is not one of the archive's 31 tickers (found during the build).
  - The short call is the listed call strike nearest $1.03\,S_0$ with a non-missing implied volatility. His 2025 contract was about 3% out of the money.
  - The premium is the mid quote.
  - The historical screenshot is removed.
- **Task 1:** breakevens for long and short.
- **Task 2:** a seeded GBM projection at the risk-neutral drift $g_y$ with $\sigma$ = implied volatility, his log-normal check, and his implied-volatility Normal alternative.
- **Task 3:** his POP table, then POE versus the archive Delta and versus $N(d_-)$ / $N(d_+)$.
- **Name:** "probability of exercise (POE)" stays.
- **Rules:** keep his three-task structure and bold question callouts.

## Advanced notebook

The notebook is `advanced/numerical_greeks/CHEME-5660-L10a-Advanced-Numerical-Greeks-Fall-2026.ipynb`. The folder also gets `advanced/README.md`, and the notebook includes `../../Include.jl`.

It meets the advanced standard: an opening question, three LOs, three Tasks, three KTs, and the disclaimer.

The sources are the archived Codex lecture (its LR, central-difference, and BSM-benchmark text) and the archived Codex NVDA example (its convergence code). The notation changes to course symbols: $g_y$, $q$ and $q'$ for the LR probabilities, and $d_\pm$.

- **Task 1:** CRR central differences for a European call against the BSM Greeks, as the step $\epsilon$ and the number of tree steps change. This shows the CRR oscillation.
- **Task 2:** the Leisen–Reimer tree, from the Peizer–Pratt construction to the factors, with CRR versus LR price and Greek convergence.
- **Task 3:** the American put, which has no closed form. It refines the LR tree and plots Delta and Gamma against the share price near the exercise boundary.
- **Contract:** the same archive contract rule as the Greeks example.

## Records

- **Notation:** the FAQ `content.json` gets a `L10a` table and context rows (Δ the Greek vs ΔS the change; ε step). Rebuild `notation.html` with Pandoc 3.1.11.1.
- **Schedule and AGENTS.md:** schedule row 10a, and the AGENTS.md top entry.
- **Handoffs:** this spec, plus `L10a-REBUILD-HANDOFF.md`. The Codex handoff gets a "superseded" note.
- **Voice calibration:** back up the lecture after his approval.
- **Deck:** after the lecture is approved.

## Checks

- **Checker:** `check_l10a.py` (adapted from `check_l9b.py`) must end at 0 failed.
- **Execution:** each notebook runs with `--ExecutePreprocessor.kernel_name=julia-1.12` and has no error outputs.
- **Pages:** every notebook is rendered as a page and read.
- **Reuse:** the lecture keeps at least 60% of its sentences from [25-L11a].
- **QA:** fresh QA reviewers score each artifact, polishing until each reaches 9 or above.
