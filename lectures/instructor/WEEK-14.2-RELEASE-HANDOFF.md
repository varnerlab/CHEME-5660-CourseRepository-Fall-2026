# Week 14.2 release — November 24, 2026

A fix-only release of the complete Week 14: **L14a and L14c**. The instructor asked for it
on November 24, before recording L14a ("commit, push and create a new release"). The
`week-14.1` draft was never published. This release replaces it.

## Changes since week-14.1

- **Updating the single index model moved to L15a** (11b09eb, 22ff9c9, c7fb99f). L14a now
  ends with the drifting-beta question. The Gamma example and `src/Helper.jl` left the week-14
  folder, so the bundle has 176 files instead of 188.
- **L14a lecture and deck** (acb2d2f, b79d658, c406ea6). Simpler answers to the four
  algorithm questions, why jump hidden Markov models, and the Cholesky step.
- **Instructor edits** (e8fd742). These change the lecture's review of the jump hidden Markov
  model and the sector factor definition. They also change the friction bullet in the
  learning objectives. In the SectorFactor example, they change the text of Tasks 1–3 and the
  Summary.
- **Setup output cleared** (e8fd742). The example's saved setup output printed the author's
  machine path, so it was cleared again. Only that output changed.

## Local verification

Built with `scripts/release-week.sh week-14.2` from a `git archive` of e8fd742.

- **Bundle.** Title "CHEME 5660 - Week 14", `included=L14a L14c`, `complete=true`,
  176 files under one root, 105 MB. The checksum passes.
- **Scans.** There is no credentials file, no author-machine path, and no raw YouTube link.
- **Notebooks.** The SectorFactor example was run from the top by the instructor with the
  current `Include.jl`. Its saved outputs have no errors. Two code cells show no execution count.
  They ran as 6 and 7, and a comment was added to each afterwards.
- **Not repeated.** The extracted-bundle `Pkg.instantiate()` test was not run again.
  `Project.toml` and `Manifest.toml` have not changed since week-14.1.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-14.2 -m "CHEME 5660 - Week 14"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
