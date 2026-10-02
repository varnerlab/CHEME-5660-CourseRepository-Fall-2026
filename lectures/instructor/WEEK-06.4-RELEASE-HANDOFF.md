# Week 06.4 release preparation — October 2, 2026

A fix-only release of the complete week (L6a and L6b). The instructor is
re-recording the L6b lecture after a technical glitch and asked for the clearer
SIM derivations developed for L7a. Every release is cumulative.

## What changed since week-06.3

- **L6b lecture** (`CHEME-5660-L6b-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb`):
  - The risk calculation marks its zero term with an `=0` underbrace.
  - "The covariance implied by a SIM" derives the diagonal variance step by
    step and marks the dropped terms with `=0`.
  - A two-matrix split shows where $\mathbf{D}_g$ comes from.
  - "Portfolio risk under a SIM" derives $\mathrm{Var}(g_p)$ from the L6a
    double sum.
  - The closing pointer to Week 7 matches the October 1 pivot. This edit
    predated today's work.
- **L6b deck** (30 pages, previously 29, zero overfull boxes): rebuilt "The
  Covariance Implied by a SIM", new "The SIM Covariance Matrix", and rewritten
  "Portfolio Risk under a SIM".
- **Committed on `main` after week-06.3 and now included:** the instructor's
  FAQ and notation pages under `code/docs/`, and the README updates (commits
  `5943cda`, `138ea8f`, `641c5f7`).

The [slides record](L6b-SLIDES-REVIEW-HANDOFF.md) lists the frame changes.

## Scope

This release contains Week 6 only. The uncommitted Week 7 refactor, the L7a
reviews, and their `AGENTS.md` and README edits are not included, at the
instructor's choice ("Week-06.4: L6b only"). They remain in the working tree
for the Week 7 release.

## Local verification

- The bundle was built with `scripts/release-week.sh week-06.4` from an export
  of the staged tree (`git archive $(git write-tree)`).
  - Title "CHEME 5660 - Week 06". One top-level directory, with L6a and L6b.
  - SHA-256 check passes:
    `5ec21defd81b67ab4152d172057035520d094d53b2955dfaaf0a73af31a3d1c9` for the
    local build.
- In the extracted bundle:
  - `Pkg.instantiate()` and `using VLQuantitativeFinancePackage` succeed.
  - All five `Include.jl` files load.
  - No author-machine path appears under `lectures/`.
- Within `lectures/week-6`, `git diff week-06.3` shows only the L6b lecture and
  the three deck files.
  - The lecture has no code cells.
  - The example and advanced notebooks are byte-identical to week-06.3, so they
    were not rerun.
- L6b lecture: 3 objectives and 3 takeaways, `___` before every level-two
  heading and closing the Disclaimer, every relative link resolves inside
  Week 6. `git diff --check` passes.
- Codex checked the new derivations (21 SymPy checks for M = 3, and every
  display parses in KaTeX).

## Publication

Pushing the annotated tag `week-06.4` starts the release workflow, which builds
and tests the tagged commit and creates the draft release. Verify the draft's
assets and checksum, then publish it (runbook step 5).
