# Week 05.3 slide correction — September 23, 2026

The instructor authorized correcting the clipped text on L5b slide 4 and
updating the GitHub release. Per the weekly release runbook, `week-05.3` is a
new cumulative revision containing both L5a and L5b; `week-05.2` remains intact.

## Correction

The “Lectures and Examples” frame now uses top alignment, a local `\small`
body font, and shorter gaps between examples. The rebuilt PDF displays the
title and complete descriptions. All wording and hyperlink targets are
preserved. Existing editorial reviews and their historical scores remain closed.

## Verification

- Rebuilt the 32-page L5b deck with its native XeLaTeX toolchain. There are no
  overfull or underfull box warnings.
- Visually inspected slide 4 at 1500-pixel resolution. Rendered all pages
  before and after at 1000-pixel resolution: only page 4 changes; the other
  31 pages are pixel-identical.
- Confirmed that text on every page and all 25 external PDF hyperlinks are
  preserved, including all four hyperlinks on slide 4.
- Built the cumulative 144-file bundle and verified ZIP integrity and its
  SHA-256 checksum. Compared it with the published Week 05.2 asset: the only
  changes are the corrected L5b slide source/PDF and the bundler's automatic
  update of tagged navigation links from `week-05.2` to `week-05.3`.
- All notebook code cells, saved outputs, environments, data, and helper code
  are identical to the published Week 05.2 bundle, whose nine computational
  notebooks were executed successfully earlier today. Those execution checks
  carry forward for this slide-only correction; GitHub Actions will also test
  setup and Include files from the newly extracted bundle before publication.
- No author-machine paths occur in the bundle. `git diff --check` passes.

Local evidence is in ignored `artifacts/qa-week-05.3/`. The tag-triggered GitHub
Actions workflow builds the draft assets, which must be compared with the
locally checked bundle and have their checksum verified before publication.
