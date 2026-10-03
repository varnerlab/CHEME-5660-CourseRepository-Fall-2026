# Week 06.7 release preparation — October 3, 2026

The instructor requested another Week 6 release after correcting the L6b
lecture. This cumulative release contains both L6a and L6b.

## Changes since week-06.6

Only the Concept Review cell in the L6b lecture changed:

- The buy-and-hold wealth formula P-1 explicitly uses the initial weights,
  `w_i(0)`, in the price-ratio sum.
- The following sentence emphasizes that the weights specify the initial
  allocation.

These are the instructor's saved edits. Release preparation preserved them
without further notebook changes. Example notebooks, saved results, slides,
and shared package code are unchanged from week-06.6.

## Local verification

- Built with `scripts/release-week.sh week-06.7` and verified the SHA-256
  checksum and ZIP integrity.
- Verified one bundle root, required environment/setup files, and only
  `lectures/week-6/`, containing L6a and L6b.
- All 15 bundled notebooks parse as JSON, with no saved error outputs.
- No author-machine paths appear in the bundle.
- The bundled L6b lecture matches the working copy byte for byte; only its
  Concept Review cell differs from week-06.6.
- Extracted-bundle `Pkg.instantiate()` and package import succeeded under
  Julia 1.12.7; all five `Include*.jl` files loaded successfully.
- `git diff --check` passes.
- Computational notebooks and package code are unchanged, so computations
  were not rerun for this notation and prose correction.

## Publication procedure

Push the release commit and its annotated `week-06.7` tag. Wait for the weekly
release workflow to pass, verify the uploaded ZIP and checksum, then publish
the draft with notes describing these corrections.
