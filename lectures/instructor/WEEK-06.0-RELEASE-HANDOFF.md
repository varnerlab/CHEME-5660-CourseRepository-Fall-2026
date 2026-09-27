# Week 06.0 release preparation — September 27, 2026

The instructor authorized release of `week-06.0`. Under the per-meeting cadence,
this bundle contains L6a only. L6b follows as `week-06.1`. Existing notebook
reviews and their historical scores remain closed. This is a release check, not
another editorial review.

## Release fixes

- Removed the L6a lecture's Optional Advanced Material link to
  `../L6b/advanced/estimation-risk/...`, together with its entries in the advanced
  README and the slide deck. The bundle omits L6b and the release script keeps
  same-week links relative, so the link was dead. The L6b lecture already lists
  the notebook. (Commit `d35679b`.)
- Removed the `___` after the final Disclaimer and Risks section in the lecture,
  the minimum-variance example, and the multiple-asset GBM example, following the
  runbook and the week-05.2 fix.

All notebook code cells, saved outputs, execution counts, and metadata are
preserved.

## Local verification

- All six L6a notebooks validate against the notebook schema. Each lecture,
  example, and advanced notebook has exactly three learning objectives and three
  key takeaways. Every `___` immediately precedes a level-two heading.
- All local links in the L6a notebooks and Markdown resolve inside L6a. All 50
  external links respond. The eCornell page blocks scripts but loads in a
  browser.
- The four computational notebooks (Dirichlet, minimum-variance data, multiple-
  asset GBM, frontier geometry) executed from the top in fresh Julia 1.12.7
  kernels without errors, in 51 to 127 seconds each. Their text outputs match
  the saved outputs apart from two trailing blank lines. The saved outputs were
  kept. The executions ran on scratch copies.
- The bundle was built with `scripts/release-week.sh week-06.0` from a copy of
  the tracked files only, as CI checks them out. Title "CHEME 5660 - Week 06
  (L6a)", 135 entries, one top-level directory, and `lectures/week-6/L6a` only.
  No L6b, `anaconda_projects`, or checkpoint files. The SHA-256 check passes
  (`749e0f7e17c2139da38863becfff6d3c2e04b8683e7f6e37f9eafabd491070e4` for the
  local build; CI's zip will differ by file timestamps).
- In the extracted bundle, `Pkg.instantiate()` and `using
  VLQuantitativeFinancePackage` succeed, and both `Include.jl` files (L6a and
  frontier geometry) load. No setup stream outputs, saved errors, or
  author-machine paths occur. `git diff --check` passes.

## Known, not blocking

- The Dirichlet example shows null execution counts in three cells and one
  out-of-order count. A fresh run produces identical text outputs.
- The frontier-geometry notebook's markdown and plot labels still say "efficient
  branch", while the lecture now says "efficient frontier".

## Publication

Pushing the annotated tag `week-06.0` starts the release workflow, which builds
and tests the tagged commit and creates the draft release. Verify the draft's
assets and checksum before publication (runbook step 5). `gh` was not
authenticated on the preparing machine.
