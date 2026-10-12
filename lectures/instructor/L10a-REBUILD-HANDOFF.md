# L10a rebuild handoff — October 12, 2026

L10a (October 27) was rebuilt from your Fall-2025 L11a text, following
`L10a-REBUILD-SPEC.md`:

- **Who did what:** builder agents worked on separate files. Each artifact got an
  independent QA reviewer (0–10, polish below 9). The main session managed the build
  and rendered every page before reporting.
- **Committed October 12**, after your approval, together with the package code
  from the October 11 Codex session that the examples need (package tests: 2086
  of 2086 pass).

## What was built

| Artifact (under `lectures/week-10/L10a/`) | QA score | Notes |
| --- | --- | --- |
| Lecture | 8.5 → 9.0 | 68 of 95 sentences come from your 2025 text, without counting the new company profile (68 of 117 with it). The October 11 version kept 32 of 125. Every edit is an exact-match substitution in `build_lecture.py`. |
| Greeks example, renamed `…-Example-Greeks-PutCall-Fall-2026.ipynb` | 7.4 → 9.0 | Uses the options archive, with `ticker = "NVDA"` as a variable. It keeps your per-Greek sections with "Check: How good is our … estimate?". Task 2 adds Delta and Gamma across strikes, plus the at-the-money Greeks across all 9 expirations. Task 3 keeps your long→short tables, then covers one contract's exposure, the Delta hedge, and Delta-only versus Delta–Gamma estimates against full repricing. |
| POE/POP example, renamed `…-Example-POE-POP-Call-Fall-2026.ipynb` | 8.5 → 9.1 | Uses the options archive. Your three tasks and callouts are kept. Task 3 answers the lecture's "Δ ≈ POE?" with the archive Delta, N(d₊), and N(d₋). |
| Advanced `advanced/numerical_greeks/…-Advanced-Numerical-Greeks-Fall-2026.ipynb` and `advanced/README.md` | 7.8 → 9.1 | New. It covers the Leisen–Reimer and convergence material from October 11. Task 1 shows why CRR Gamma fails for small steps, Task 2 builds the Leisen–Reimer tree, and Task 3 treats the American put near its exercise boundary. All checks pass for the 31 tickers. |
| Concept Review figure, `figs/CHEME-5660-L9b-Example-ExtrinsicValue-Fall-2026.svg` | page-checked | Regenerated from the 2026 L9b extrinsic-value example (archive, NVDA). |

## New lecture text for your edit pass

Everything else is your 2025 text or L9a's disclaimer, with the word-level fixes listed below.

1. **Hook:** "In L2b, duration and convexity told us how much a bond's price changes
   when its yield moves. In L9b, we priced American options on a CRR tree. How much
   does an option's premium change when the share price, volatility, time to
   expiration, or interest rate changes?"
2. **Company Profile: Susquehanna International Group** (about 350 words; it follows the Wealthfront and Cboe format).
   - Every fact is linked to sig.com or Cboe. Cboe's file lists Susquehanna as the
     Designated Primary Market Maker for 1,359 of 5,370 classes, the most of any firm
     (Citadel 1,326). That count is a tally of the file made on October 12.
   - The connection paragraph is two sentences (shortened at your request on
     October 12): a customer buys a call, the firm hedges with $100\,\Delta_c$ shares,
     and Gamma keeps it trading. No controversies are mentioned.
3. **After the Taylor expansion:**
   - Units: "In this expansion, Δt is in years, and Δσ and Δg_y are decimals. Trading
     platforms quote Θ/365 per day, and ν/100 and ρ/100 per percentage point."
   - "Δ and Γ play the roles of duration and convexity in L2b: they are the slope and
     the curvature of the premium as a function of the share price."
   - A worked example: Δ = 0.50 and Γ = 0.02, with ±5 USD/share giving +2.75 and −2.25.
4. **New H3, "Computing the Greeks of American Options":**
   - There is no formula to differentiate, so we reprice the CRR tree with one input
     moved by ±ε.
   - The central-difference display for $x\in\{S,\sigma,t,g_y\}$ and for Γ.
   - "With no dividends, a call's American and European premiums are equal (L9b),
     so the L9a Black–Scholes–Merton formulas give Greeks to check against, e.g.,
     Δ_c = N(d₊)."
   - Your "click me" link to the advanced notebook.
5. **Delta section, before your conjecture line:** "In the L9a Black–Scholes–Merton
   model, a European call has Δ_c = N(d₊), while the risk-neutral probability that it
   finishes in-the-money is N(d₋), which is smaller."
6. **Optional Advanced Material:** one bullet, "Numerical Greeks on binomial trees".
7. **Takeaways:**
   - KT1's second sentence is now the Taylor-expansion and CRR-repricing statement.
   - KT2 adds "We checked that approximation against the probability of exercise
     computed from a projected share price distribution."

**Word-level fixes to your 2025 text:**
- **Title:** L11a → L10a.
- **Objectives:**
  - LO1: "total differential" → "a local Taylor expansion".
  - LO2: "hedge ratio and probability measure" → "hedge ratio and a probability
    estimate", and "use Delta to estimate" → "compare Delta with".
  - LO3: POE is computed "from the same distributions at the strike price".
- **Ticker names:** NVDA and TSLA are removed, and the links point to the new file names.
- **Factor list:** "and dividends" is dropped, because the lecture never treats them.
- **Delta bullet:** "and the probability that" → "and is often used to estimate the
  probability that".
- **Derivation symbols:**
  - Type $\tau$ → $\star\in\{c,p\}$ (your 2024 symbol), because L9a uses τ for the
    exercise time.
  - The rate $r$ → $g_y$.
  - "t days to expiration" → expiration $T$ and calendar time $t$, so Θ = ∂𝒫/∂t
    has a clear sign.
  - $dS$ → $\Delta S$, with ≈ for the second-order expansion.
- **Cut:** "Let's walk through the major Greeks…", because no walkthrough follows.
- **Hedge rule:** "for every n contracts held (n < 0 if the contracts are sold)…
  hold −100·n·Δ shares". The sign was missing.
- **POE bullet:** "Delta can also be interpreted as the probability" → "Delta is also
  often used as an estimate of the probability".
- **Display fix:** both boxed displays inside blockquotes get `>` on every line, so
  they render in HTML.
- **Takeaways and labels:**
  - KT3: POE "uses projected distributions at the strike price".
  - `> __Example__` → `> __Example:__`.
  - The examples heading uses the house label.

## Flags for you

1. **Your Delta bullets, not changed.** "the number of shares … needed to hedge one
   option contract" doesn't match the next sentence's rule, −100·n·Δ. One contract
   needs 100·Δ shares, with the opposite sign. A word-level fix would be "per share of
   the contract", but I left your wording.
2. **TSLA is not in the options archive.** The POE/POP example defaults to NVDA, and
   the ticker stays a variable.
3. **CRR Gamma needs a large enough step.** The CRR premium is a straight line between
   the share prices where a terminal node crosses the strike. A step that stays between
   two of those points gives Gamma = 0. On the default 201-step tree, the package's 1%
   step gives Gamma about a third too low.
   - The Greeks example sets the share-price step to at least two tree gaps and uses
     20 tree levels per day. CRR then matches the archive's Greeks closely (call Γ
     0.0142 against 0.0142).
   - The advanced notebook shows why. `binomial_greeks`' default `spot_bump` may be
     worth revisiting.
4. **American put Rho.** It is −0.114 per point against the quote's −0.134. A
   European put on the same tree gives −0.135, which suggests Alpaca's put Greeks are
   European. The example says so in one callout.
5. **Outside L10a, not touched.** The L10b examples (Delta-VerticalSpread, Straddle)
   and the L11b vertical-spread example still fit a LogNormal to the simulated samples,
   then test it with Kolmogorov–Smirnov (KS) against that same fit. That makes the
   p-value invalid. The L10a POE/POP example now tests against the analytic
   distribution.
6. **Symbol clash in the Greeks example.** Your $n_c = 100\cdot\Delta_c$ means share
   equivalents, while the lecture's $n$ is a signed number of contracts. Both appear in
   Task 3. I left it as is.
7. **Documentation links** to `binomial_premium`/`binomial_greeks` resolve only after
   the uncommitted `code/docs/src/derivatives.md` is published.
8. **Deck built October 12** (`slides/`, 16 pages, 0 overfull boxes), mirroring the
   lecture's order. A fresh reviewer scored it 8.6, then 9.2 after the fixes. The
   Concept Review figure is the L9b extrinsic-value SVG converted to PDF with
   `rsvg-convert` (`figs/CHEME-5660-L9b-Example-ExtrinsicValue-Fall-2026.pdf`).

## Records

- **Notation FAQ:** `code/docs/faq-src/content.json` has a 16-row `L10a` table. The
  Context table gains rows for Δ (Delta vs. a change) and ⋆, and adds L10a to its ρ,
  ν, and n rows. `notation.html` was rebuilt with Pandoc 3.1.11.1.
- **Schedule:** the 10a row and the advanced-subfolder rule.
- **AGENTS.md:** a new top entry. The October 11 Codex handoff now carries a
  "superseded" note.
- **Archive:** `lectures/archive/week-10-L10a-before-rebuild-2026-10-12/`, with a
  README and `SHA256SUMS`. It holds the three October 11 notebooks, their handoff,
  and the two retired figures (the 2025 NVDA plot and the TSLA screenshot).

## Checks

- `check_l10a.py`, all groups: 0 failed. One WARN remains, your 2025 Test
  boilerplate ("values are not equal").
- Every notebook with code was executed on `julia-1.12`, with no error outputs. The
  31-ticker runs pass for both examples and the advanced notebook.
- Every notebook was rendered as a page and read (`pages/`).

## Where to look (`build/notebook-previews/L10a-rebuild-2026-10-12/`)

- `previews-lecture/`: each lecture section against your 2025 text (green is new,
  red is removed).
- `pages/`: full-page renders. `lecture-*`, `greeks-*`, `pop-*`, and `adv-*` are
  the final versions.
- `build_lecture.py`, `profile.md`, `advanced-bullet.md`, `check_l10a.py`, `qa-brief.md`.

## Next steps

1. Done October 12: the package tests (2086 of 2086 pass), the commits (package code,
   L10a rebuild), the voice-calibration backup, and the deck.
2. Your hand edits of the lecture. When the round is done, compare with
   `lectures/instructor/voice-calibration/L10a-Lecture-American-Derivatives-Greeks/before.ipynb`.
3. The week-10 release when you give the go-ahead.
