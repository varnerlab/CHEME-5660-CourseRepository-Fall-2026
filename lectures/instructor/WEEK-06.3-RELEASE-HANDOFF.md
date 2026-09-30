# Week 06.3 release preparation — September 30, 2026

A fix-only release of the complete week (L6a and L6b), cut the same day as
`week-06.2` so that the L6b slide deck matches the lecture's Examples split
before the October 1 class. The `week-06.2` draft was never published; the
instructor can leave it unpublished or delete the draft and publish only this
one. Every release is cumulative.

## What changed since week-06.2

Only the L6b deck (`slides/*.tex` and the rebuilt PDF). The
[slides record](L6b-SLIDES-REVIEW-HANDOFF.md) describes the two changed
slides: the Lectures and Examples frame now lists the in-lecture examples
(From L6a, the client interview, the SIM portfolios, the tangent portfolio)
and a review-on-your-own line, and the in-body stops carry the lecture's
labels. 29 pages, zero overfull boxes.

## Local verification

- The bundle was built with `scripts/release-week.sh week-06.3` from an export
  of the staged tree. Its file list is identical to the week-06.2 bundle, and
  `git diff week-06.2` shows only the two slide files. Title
  "CHEME 5660 - Week 06", one top-level directory, L6a and L6b. The SHA-256
  check passes (`af9f925d5b04dd1f5ed1cc46653eaa7e0638f52efdcf6f368e69e5c055373f16` for the local build).
- In the extracted bundle, `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed, all five `Include.jl` files
  load, and there is no author-machine path. The notebooks are byte-identical
  to those verified for week-06.2 earlier today (ten notebooks run from the top
  with matching outputs, and the interview screen), so they were not rerun.
- `git diff --check` passes.

## Known, not blocking

- The frontier-geometry notebook still says "efficient branch" where the lecture
  says "efficient frontier" (carried from week-06.0).

## Publication

Pushing the annotated tag `week-06.3` starts the release workflow, which builds
and tests the tagged commit and creates the draft release. Verify the draft's
assets and checksum, then publish it (runbook step 5).
