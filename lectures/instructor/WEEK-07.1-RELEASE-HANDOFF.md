# Week 07.1 release — October 7, 2026

The second Week 7 release, and the complete week: **L7a and L7b**. Under the
per-meeting rule, `week-07.0` shipped L7a for October 6, and `week-07.1` adds
L7b for October 8. The instructor asked to "commit, push and run the Week-07.1
release action" on October 7, after approving the CES limits companion pass.

## Contents

- **L7a.** Unchanged since the instructor's commits after `week-07.0`
  (`145204b`, `84d9177`). They include his L7a lecture, example, and deck
  edits, and `L7a/SIM-RESIDUAL-CORRELATION-DISCUSSION.md`. That saved record
  of his October 6 Codex discussion sits in the L7a folder, so it ships in
  the bundle.
- **L7b lecture.** Utility-based allocation, with the October 6 polish (8.3
  to 9.0, approved), the Wealthfront profile, and the October 7 income-gamble
  and client-ticker edits. See the
  [lecture record](L7b-LECTURE-REVIEW-HANDOFF.md). SHA-256 prefix
  `859a9a92da9a6a86`.
- **L7b deck.** 24 pages, synced to the October 6 lecture. It has no
  interview frame yet. The instructor agreed to add one as a separate step.
- **Examples.**
  - The income-gamble interview (`L7b/interview/`). The published
    Barsky–Juster–Kimball–Shapiro questions, plus our labeled two-question
    extension.
  - The capital allocation line example (`2050a9346bf3f285`).
  - The utility allocator example (`9c807f2416902f52`). See the
    [allocator record](L7b-ALLOCATOR-REVIEW-HANDOFF.md).
- **Advanced.** The CES limits companion, polished and approved October 7
  (7.7 to 9.1). See its [record](L7b-CES-LIMITS-REVIEW-HANDOFF.md)
  (`e394aa6ba1a4d009`).

The examples read the L6b client files, and the CAL example also reads the
interview's `data/my-risk-aversion.toml`, when they are present. All three
files are Git-ignored and do not ship, so students run the defaults.

## Committed with this release

- `lectures/week-7/L7b/`: the lecture, both examples, the CES companion, the
  deck source and PDF, and the new `interview/` folder.
- The notation FAQ: the L7b δ row, plus the rebuilt `notation.html` and its
  audit and README notes.
- The `.gitignore` entry for `my-risk-aversion.toml`.
- The L7b lecture, allocator, and CES limits records, `AGENTS.md`, and this
  record.

## Local verification

- **Bundle.** `scripts/release-week.sh week-07.1` was run on a `git archive`
  of the staged tree (`632edb3`).
  - Title "CHEME 5660 - Week 07", `included=L7a L7b`, `complete=true`.
  - 110 files under one root folder, with no client or interview output
    files.
  - Checksum passes. The local SHA-256 is
    `8089c2c3ad26eb0eaf42c69a07b972750acf4dd78413796a474e5095ade681c4`. The
    CI build is separate, and its digest is the one students verify.
- **Extracted-bundle test.**
  - `Pkg.instantiate()` and `using VLQuantitativeFinancePackage` succeed in
    Julia 1.12.7, and all three `Include.jl` files load.
  - L7a RA (21 code cells), L7a RRFA (19), L7a estimation risk (27), the L7b
    CAL example (16), and the L7b allocator (21) ran from the top in fresh
    `julia-1.12` kernels with no errors.
  - Every text output matches the saved notebooks, except the setup cell's
    "Activating project" line, which the saved notebooks correctly omit.
- **Interview script.** `income-gamble.jl` ran from the bundle.
  - A partial answer list prints the next question.
  - Too many answers stops with a clear error.
  - A complete path (category 2, 4.34 < r̄ < 5.08) writes the TOML. The test
    file was deleted afterward.
- **Notebook checks.**
  - All nine notebooks have 3 objectives and 3 takeaways.
  - `___` comes before every level-two heading and at the end of the final
    cell, never before an H3.
  - In the bundle there are no dead local links or images, no saved errors,
    no setup output, and no author-machine paths. This covers the notebooks
    and the Markdown files.
  - Both deck PDFs are present.
  - `git diff --check` passes.

## Publication

Pushing the annotated tag `week-07.1` starts the release workflow, which
creates a draft. Verify the assets and checksum, then the instructor publishes
it.

## Open after this release

- The L7b deck's income-gamble interview frame.
- The October 6 "Examples sentence" item and the empty-basket budget question
  in the lecture record.
- The package's η = 1000 underflow and tolerance check (October 3 Codex item 4).
