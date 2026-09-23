# Week 05.2 release preparation — September 23, 2026

The instructor authorized release of `week-05.2`. This cumulative student bundle
contains both L5a and L5b. Existing notebook reviews and their historical scores
remain closed; this is a release check, not another editorial review.

## Release fixes

- Corrected the L5a advanced index to list the three included notebooks: EMA
  derivation, drift uncertainty, and Monte Carlo. Removed links to two notebooks
  that are not in that directory and corrected the lecture identifiers.
- Repaired the copied drift-uncertainty notebook's prerequisite links. Its
  parameter-estimation and regression references point to L4b; its target-
  probability reference points to the current L5a lecture.
- Corrected the L5b advanced index to describe the rolling-correlation notebook's
  fixed 100-asset subset.
- Removed six separators after the final Disclaimer and Risks section. Separators
  before that section remain in place.

All notebook code cells, saved outputs, execution counts, cell metadata, and
notebook metadata are preserved. These fixes change navigation and formatting.

## Local verification

- All 13 notebooks validate against the notebook schema, with exactly three
  learning objectives and three key takeaways each.
- All 124 local links in the source Week 5 notebooks and Markdown resolve.
  Every three-underscore separator immediately precedes a level-two heading.
- All nine computational notebooks executed successfully from an extracted
  student bundle using fresh Julia 1.12.7 Jupyter kernels. Execution evidence
  was saved separately, preserving the reviewed notebooks' outputs.
- The existing `scripts/check-week5-adaptive.jl` suite passed all 101 assertions.
- The final ZIP passes archive-integrity and SHA-256 checks. It contains both
  meetings, the root environment, setup script, and vendored package, with no
  other lecture weeks or instructor archive.
- All 115 local links in the bundled Week 5 notebooks and Markdown resolve.
  Cross-week notebook links use the tagged GitHub repository. No saved notebook
  errors or author-machine paths occur in the bundle.
- The rebuilt bundle's code cells and saved outputs are identical to those in
  the extracted bundle used for the execution checks. `git diff --check` passes.

Local evidence is in ignored `artifacts/qa-week-05.2/`. The release workflow
independently builds and tests the tagged commit and creates the draft release;
its assets and checksum must be verified before publication.
