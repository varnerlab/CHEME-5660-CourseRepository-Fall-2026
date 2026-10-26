# Week 10.0 release — October 25, 2026

The first Week 10 release: **L10a only**, for October 27. Under the per-meeting
rule, `week-10.1` will add L10b for October 29. The instructor asked whether any
L10a materials scored below 9, approved applying every fix ("yes apply the
fixes"), and gave the go-ahead for the release ("Happy").

## Contents

- **L10a lecture.** American derivatives: Monte Carlo pricing with
  Longstaff–Schwartz, intrinsic and extrinsic value, the Greeks by central
  differences, Delta as a hedge ratio and as an approximate probability of
  exercise (the Proposition), and the POE and POP by simulation. It carries his
  October 25 hand edits (`e7263d5`, `f212463`, `cb0b925`) and the moneyness
  convention K/S(0).
- **L10a deck.** 27 pages, 0 overfull boxes.
- **Examples.** Longstaff–Schwartz premium, Greeks for a call and a put, and the
  POE and POP for a short call are worked in lecture. Extrinsic value is "review
  on your own".
- **Advanced.** The Leisen–Reimer tree and the Greeks, the Delta-as-POE
  derivation, and `advanced/README.md`.

## Scoring round (October 25)

Six fresh reviewers scored every artifact against
`build/notebook-previews/L10a-score-2026-10-25/score-brief.md`.

| Artifact | Score | Predicted after fixes |
| --- | --- | --- |
| Lecture | 8.8 | 9.3 |
| Deck | 8.4 | 9.2 |
| Greeks example | 8.7 | 9.2 |
| POE/POP example | 8.6 | 9.2 |
| Extrinsic value example | 8.6 | 9.1 |
| LSM example | 9.1 | 9.3 |
| Leisen–Reimer advanced | 8.8 | 9.3 |
| Delta–POE derivation | 8.9 | 9.4 |

- **Applied:** every proposed fix. These are word-level corrections, function
  links at first use, symbols defined at first use, ≈ kept to the end of the
  Taylor and σ√T chains, and the rule breaches (sentences that started with a
  symbol or acronym on deck slides 18–19, a link into week 9 in the Delta–POE
  notebook). The edits touched cell sources only. Nothing was re-executed, and
  none of his October 25 wording was undone. The reviewers' reports, each with
  an "Applied" section, and the before/after previews are in
  `build/notebook-previews/L10a-score-2026-10-25/`.
- **Also changed:** the saved "Activating project at `~/Desktop/...`" stderr was
  removed from each example's setup cell (an author-machine path). The LSM
  strike-sweep cell `l9b-lsm-28` is no longer hidden, because the prose describes
  its code.
- **Left as his call:**
  - The lecture's "about 3.9 USD/share at K = 100". It is still true as a floor,
    but K = 100 is now the at-the-money point.
  - The extrinsic value plot's y axis, which runs to 115.
  - POE/POP's ≤ → < for the seller's profit, which needs a code edit and a re-run.
- The after-fix scores are the reviewers' predictions. No fresh re-score was run.

## Local verification

- **Structure.** Every lecture and example has three objectives and three
  takeaways. The `___` rules hold, every `[▶ ...]` link opens with "In this
  example," or "In this notebook,", and no sentence starts with a symbol or
  acronym. All relative links resolve inside `lectures/week-10/L10a/`, with no
  links into L10b.
- **Bundle.** `scripts/release-week.sh week-10.0` was built from a `git archive`
  of the staged release tree.
  - Title "CHEME 5660 - Week 10 (L10a)", `included=L10a`, 102 files under one root.
  - The checksum passes. The local SHA-256 is
    `6fccb2d5c2640ee4557ac2d9d190d60cf4436fda682336c6575b3d67466d4dc7`. The CI
    build is separate, and its digest is the one students verify.
- **Extracted-bundle test.**
  - `Pkg.instantiate()` and `using VLQuantitativeFinancePackage` succeed in
    Julia 1.12.7, and `Include.jl` loads.
  - All four examples ran from the top inside the bundle with the `julia-1.12`
    kernel, with 0 errors.
  - Saved text outputs match the runs, apart from the setup cells (their stderr
    was cleared on purpose) and whitespace.
- **Sweep.** No setup, download, or author-path output remains in any bundled
  notebook.

## Release steps

1. Commit the scoring-round fixes, then commit `Release week-10.0: finalize
   student bundle` with this record. Push `main`.
2. Push an annotated tag: `git tag -a week-10.0 -m "CHEME 5660 - Week 10"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.

## Open for week-10.1 (L10b)

- Both L10b examples say "We reject" the KS null hypothesis while every run prints
  "fail to reject". The test also compares the samples with a LogNormal fitted to
  the same samples.
- No L10b deck yet.
- Legacy `L10b/docs/Notes.pdf` (August 19) would ship. Nothing links to it.
- Both L10b examples use the 2025 AMD chain, not the end-of-day archive.
- Both L10b examples save the "Activating project" setup output.
- The L10b lecture lacks a `___` before `## Common Composite Contracts`, and both
  L10b examples lack the closing `___` after the Disclaimer.

## Re-release after the midterm feedback — October 26, 2026

The midterm reviews asked what students must know and called the materials dense.
The instructor approved, for L10a and all later lectures:
- a "What you need to know" box under the learning objectives, with a matching deck frame;
- decks at 60–80 words per slide;
- closing sentences only when they state a result.

- **Lecture.**
  - The box sits under the learning objectives. **Core:**
    - premium = intrinsic + extrinsic value
    - reading the Greeks per day and per point
    - Delta close to a short-dated call's in-the-money probability under ℚ
    - POE and POP from simulated prices

    **For understanding**, which students won't have to reproduce: the Longstaff–Schwartz regression, the Taylor expansion, and the Delta–POE proposition.
  - The Greeks paragraph ends "…using the implied volatility under ℚ."
- **Deck.**
  - 28 pages (27 before), 0 overfull boxes.
  - The new frame 4 is "What You Need to Know".
  - Prose fell from 75 to 52 words per slide on average. This counts words of two or more letters, so math does not count. Counting every pdftotext token, it fell from 116 to 91.
- **Codex audit.**
  - The before/after comparison is in `build/notebook-previews/L10a-tighten-2026-10-26/`.
  - All 11 findings were verified and applied. Among them: the restored definitions of Y_i(t), P^EU, and calendar time t; "by at least the interest on K"; "the probabilities inside the market price, not our forecast"; the call qualifier on Δ = 0.7; and the short-dated, no-dividend qualifier.
- The examples are unchanged.
