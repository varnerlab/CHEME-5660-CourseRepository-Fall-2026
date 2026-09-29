# Week 06.1 release preparation — September 29, 2026

The instructor authorized release of `week-06.1`. Under the per-meeting cadence,
this bundle completes Week 6: it contains the updated L6a and the reviewed L6b
materials. `week-06.0` (L6a only) remains intact. Existing notebook reviews and
their historical scores remain closed. This is a release check, not another
editorial review.

## Release fixes

- **Closing rule after the Disclaimer.** The instructor's manual L6b pass ended the
  Disclaimer and Risks section of the L6b lecture and four examples with `___`. The
  instructor chose to keep that as the convention and apply it everywhere, so the same rule now
  closes the seven L6a notebooks (lecture, three examples, frontier geometry, two
  derivations) and the two L6b advanced notebooks. The runbook, `AGENTS.md`, and
  the notebook style guide now state the rule. This reverses the week-06.0 removal.
- Cleared the saved setup output of the estimation-risk advanced notebook's
  `Include.jl` cell, which showed the author's project path. The bundler strips it
  as well.
- Added the missing cell `id` to the closing reading (cell 40) of the parameter-
  uncertainty example, which the notebook schema requires.
- Removed the tracked `lectures/week-6/L6b/tmp/L6b-EXAMPLES-REVIEW-HANDOFF.md` at
  the instructor's request. The L6b reviews are closed, and the per-notebook
  handoffs in `lectures/instructor/` keep the record.

All notebook code cells, other saved outputs, execution counts, and metadata are
preserved.

## Local verification

- All 14 Week 6 notebooks validate against the notebook schema. Every lecture,
  example, advanced, and derivation notebook has exactly three learning objectives
  and three key takeaways. Every `___` precedes a level-two heading or closes the
  final Disclaimer and Risks section.
- All local links resolve inside L6a and L6b. L6b's links into L6a now work,
  since both meetings ship together. All 85 external links respond. The five DOI
  links return 403 to scripts from the publishers but resolve through doi.org.
- The bundle was built with `scripts/release-week.sh week-06.1` from the tracked
  files only, as CI checks them out. Title "CHEME 5660 - Week 06", 137 files, one
  top-level directory, and `lectures/week-6/L6a` plus `lectures/week-6/L6b`. No
  `tmp/`, `anaconda_projects`, checkpoint, or LaTeX build files. The SHA-256 check
  passes (`084404d4265e34384d010f2251465fa5bdb3e73fc931fec1210e32f6fa823ac6` for
  the local build. CI's zip will differ by file timestamps).
- In the extracted bundle, `Pkg.instantiate()` and `using
  VLQuantitativeFinancePackage` succeed, and all five `Include.jl` files (L6a,
  L6b, frontier geometry, diagnostics, estimation risk) load. No author-machine
  paths occur.
- The ten computational notebooks (L6a: data minimum variance, Dirichlet,
  multiple-asset GBM, frontier geometry. L6b: SIM estimation, parameter
  uncertainty, SIM portfolio, tangent portfolio, diagnostics, estimation risk)
  executed from the top inside the extracted bundle in fresh Julia 1.12.7 kernels
  without errors, in 19 to 31 seconds each. Their text outputs match the saved
  outputs exactly once stream chunks are joined. The saved outputs were kept.
- The slide PDFs for L6a and L6b were rebuilt in the same commits as their
  sources. The L6b deck does not repeat the Summary sentence the manual pass
  changed, so no deck sync was needed. `git diff --check` passes.

## Known, not blocking

- The frontier-geometry notebook's markdown and plot labels still say "efficient
  branch", while the lecture says "efficient frontier" (carried from week-06.0).
- Fresh runs print "Activating project at …" under the `Include.jl` cell of the
  frontier-geometry and estimation-risk notebooks. This is expected. The saved
  notebooks carry no setup output.

## Publication

Pushing the annotated tag `week-06.1` starts the release workflow, which builds
and tests the tagged commit and creates the draft release. Verify the draft's
assets and checksum before publication (runbook step 5).
