# Week 09.1 release — October 20, 2026

The second Week 9 release, and the complete week: **L9a and L9b**. Under the
per-meeting rule, `week-09.0` shipped L9a for October 20, and `week-09.1` adds
L9b for October 22. The instructor asked "Is this ready for a release, i.e.,
Week-09.1?" after the L9b carryover and scoring rounds were committed
(`f901912`, `135cd9e`).

## Contents

- **L9a.** The lecture text is unchanged since `week-09.0`. Class stopped at the
  Monte Carlo premium, and L9b picks up there. The only changes are links: the
  contingent-claims and SPXW advanced notebooks moved to `L9b/advanced/`, and
  the lecture, the BSM example, `Include.jl`, and the deck now point there.
  The L9a advanced folder is gone. The payoff example's saved output lost one
  stderr line, "Downloading artifact: options_eod", in this release commit.
- **L9b lecture.** In order:
  - Concept Review: A Monte Carlo Premium. It links the BSM example in
    `../L9a/`, and in class only Approach 1 of Tasks 1 and 2 is run.
  - The Options Clearing Corporation profile.
  - Black–Scholes–Merton (BSM) Premiums: the equation, formulas, implied
    volatility, and bisection. It ends with an "Interesting fact" sentence
    linking the parity notebook, and with "Review on your own" for Approach 2
    and Task 3.
  - The American material: CRR, the decision rule, Hull, and the market
    example. Longstaff–Schwartz moved to L10a.
  - Scores: fresh reviewer 9.1, about 75 minutes. The records are in
    `build/notebook-previews/L9b-carryover-2026-10-20/score2/` and `AGENTS.md`.
- **L9b put–call parity notebook.**
  `CHEME-5660-L9b-InterestingFact-PutCallParity-Fall-2026.ipynb` holds L9a's
  parity derivation in his 2025 "OriginStory" shape. It is not in the
  Examples list, and it has no objectives on purpose.
- **L9b deck.** 26 pages, 0 overfull. Slide 5 was reorganized and approved
  ("Agree"). Slide 7 no longer dates the 0.01 USD auto-exercise rule to 1977.
- **L9b examples.** AmericanContractsPremium (in lecture) and Hull (review on
  your own). Both are unchanged since the October 19 scoring round.
- **L9b advanced.** Contingent claims and SPXW volatility skew (both from L9a,
  renamed L9b), and CRR factors.

## Local verification

- **Structure.** Every lecture, example, and advanced notebook has three
  objectives and three takeaways, and `___` sits before every `##` and closes
  the Disclaimer. Every `[▶ ...]` link opens with "In this example," or "In this
  notebook,". All relative links resolve inside `lectures/week-9/`.
- **Bundle.** `scripts/release-week.sh week-09.1` was run from a clean tree at
  `135cd9e`.
  - Title "CHEME 5660 - Week 09", `included=L9a L9b`, `complete=true`.
  - 131 files under one root folder. Every file under `lectures/week-9/` is
    tracked.
  - The checksum passes. The local SHA-256 is
    `cd7a04856836be5ce85e55cdc1ce58f3d3059b9a5130477cc7402cfe9d07f924`, before the
    stderr cleanup. The CI build is separate, and its digest is the one
    students verify.
- **Extracted-bundle test.**
  - `Pkg.instantiate()` and `using VLQuantitativeFinancePackage` succeed in
    Julia 1.12.7, and all three `Include.jl` files load.
  - Five notebooks were executed from the top inside the bundle with the
    `julia-1.12` kernel, all with 0 errors: BSM premium, single-contract payoff,
    AmericanContractsPremium, Hull, and SPXW skew.
  - Saved outputs match the runs, apart from whitespace and the row
    truncation of one `DataFrame` display. The one real difference, the stderr
    download line, was removed from the payoff example.
- **Sweep.** No setup, precompilation, download, or author-path output remains
  in any week-9 notebook.

## Release steps (on the instructor's go-ahead)

1. Commit `Release week-09.1: finalize student bundle`: the payoff-example
   output cleanup and this record. Then push `main`.
2. Push an annotated tag:
   `git tag -a week-09.1 -m "CHEME 5660 - Week 09"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
