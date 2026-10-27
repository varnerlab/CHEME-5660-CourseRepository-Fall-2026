# Week 10.1 release — October 27, 2026

The complete Week 10 release: **L10a and L10b**, for October 29. It follows
`week-10.0` (L10a only, re-released October 27 from 35caefd). The instructor
asked for it on October 27 ("we need to make the Week-10.1 release with L10a and
L10b materials").

## Contents

- **L10a.** Unchanged in the lecture and deck since week-10.0. Changed examples:
  - Greeks example: the ticker is in the inputs table, the hedge-table headers
    are clearer, and the short Greeks are written as θ times the long Greek
    (c5329f8, d04d284).
  - LSM example: re-run in "updates" (db3052b).
- **L10b lecture.** POE and POP of a single contract (POE ∼ |Δ|), then the NPV
  and the profit at expiration of composite contracts. It covers eight credit
  contracts by put side and call side, and "Why Wait to Expiration?". It has a
  must-know box (three core results and the NPV derivation and formula tables
  "for understanding"). The tastytrade company profile is included. Delta
  hedging moved to L11a on October 27.
- **L10b deck.** 28 pages, 0 overfull boxes.
- **L10b examples.**
  - The AMD put credit spread is worked in lecture.
  - The AMD short straddle before the November 3 earnings release is "review on
    your own". Its Task 3 waits on the post-release chain (`post_release_ticker =
    missing`) and prints a pending message until then.
  - Both are on the 2026-10-26 AMD chain. Both now end with a plot of the
    cumulative distribution of each share-price distribution, with the strikes
    and breakevens marked and the ℙ and ℚ heights read across to the
    probability axis (f08024d).
  - The straddle's early-close paragraph names the premiums collected and no
    longer claims that implied volatility falls after earnings.

## Items left open by week-10.0, now closed

- The KS test text now says "fail to reject" and tests against the analytic
  LogNormal, not one fitted to the samples.
- The L10b deck exists. The legacy `L10b/docs/Notes.pdf` is gone.
- Both examples use the 2026 AMD chain.
- Every L10b notebook ends with `___` after the Disclaimer (AGENTS.md, September 29 rule).

## Local verification

- **Structure.** All eight week-10 notebooks have three objectives and three
  takeaways, no unexecuted code cells, no error outputs, and a closing `___`. Every
  lecture `[▶ ...]` description opens with "In this example," or "In this
  notebook,". All relative links resolve, and L10a has no links into L10b.
- **Setup output.** The "Activating project at `~/Desktop/...`" line was cleared
  from the L10a LSM example and both L10b examples (fd439b6).
- **Bundle.** `scripts/release-week.sh week-10.1` was built from a `git archive` of
  fd439b6.
  - Title "CHEME 5660 - Week 10", `included=L10a L10b`, `complete=true`, 165 files
    under one root.
  - There are no instructor, NotebookLM, LaTeX build, or `docs/` files.
  - The checksum passes. The local SHA-256 is
    `1017c396392755e98257a79c184d7902016060443a9c8cf95f7522752de4cf03`. The CI build is
    separate, and its digest is the one students verify.
- **Extracted-bundle test.**
  - `Pkg.instantiate()` and `using VLQuantitativeFinancePackage` succeed in Julia
    1.12.7, and both `Include.jl` files load.
  - All six examples ran from the top inside the bundle with the `julia-1.12`
    kernel, with 0 errors (24–28 s each).
  - Saved text outputs match the runs. The exceptions are the setup cell, which
    prints the bundle's own path in a fresh run, and the two L10a option-chain
    displays, where the headless run shows more rows of the same 194-row table.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-10.1 -m "CHEME 5660 - Week 10"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.

## Not in the bundle

The L10b NotebookLM sources, prompts, and checked self-check quiz (Canvas QTI) are
in `lectures/instructor/notebooklm/L10b/`. They are tracked in the repository and
not shipped to students.

## CI build — October 27, 2026

Tagged `week-10.1` at 983e426. Release workflow run 40587108645 passed and opened
a draft release. The downloaded zip matches its `.sha256` file (GitHub digest
`6e28a9942d4d5b7923e6a9c46003877649d86c78f6572b671a5496c020f166d7`). Its 165
entries match the local bundle file for file. The only listing difference is how
the two unzip tools print the narrow no-break space in one MU screenshot filename
under `code/src/data/options/original/`.
