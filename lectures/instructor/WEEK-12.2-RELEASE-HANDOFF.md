# Week 12.2 release — November 11, 2026

The complete Week 12 release: **L12a and L12b**. It replaces `week-12.1`, whose CI
build failed and which has no release. The contents and the checks are in
`WEEK-12.1-RELEASE-HANDOFF.md`. This record lists what changed after it.

## The one change

`lectures/week-12/L12b/Include.jl` now sets `_ROOT = @__DIR__`, as every other
lecture does. It used `pwd()`, which works only when Julia starts in the L12b folder.

## Local verification

Built with `scripts/release-week.sh week-12.2` from a `git archive` of the tree
that this commit records.

- **Bundle.** Title "CHEME 5660 - Week 12", `included=L12a L12b`, `complete=true`,
  201 files. Against the `week-12.1` local bundle, only `L12b/Include.jl` and the tag
  in the README links differ. The checksum passes. The local SHA-256 is
  `2ffefbd5ec89926d490096883a6e0d81c32a731be83ce9a5c5382d47f4558720`.
- **Extracted-bundle test.** Run with the runbook's commands, from a directory
  outside the bundle, as the workflow does. `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed, and both `Include.jl` files load.
- **Notebooks.** The four L12b examples ran from the top inside the bundle with 0
  errors, and all 24 saved figures match the runs byte for byte. The two L12a
  examples were run for `week-12.1` and their files are unchanged.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-12.2 -m "CHEME 5660 - Week 12"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
