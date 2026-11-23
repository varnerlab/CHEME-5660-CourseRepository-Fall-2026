# Week 14.1 release — November 23, 2026

The complete Week 14: **L14a and L14c**. The instructor asked for it on November 23
("update the README.md and ship as Week-14.1"). L14c is the "No lecture today"
note for the Thanksgiving holiday. `week-14.0` was the L14a-only release.

## Changes since week-14.0

- **Alpaca README (`L14a/alpaca-mcp/README.md`).** The setup command and the six
  prompts of Tasks 1–3 are now code blocks, so students can copy them. Each sentence
  of a prompt sits on its own line, so no prompt runs past the edge of the block.
  The prompts used to be quote blocks. There, `<paste the tickers>` was read as an
  HTML tag and vanished, so Task 1's second prompt read "basket: . What are…". The
  placeholder now shows. The instructor approved the rendered before and after
  (commit 1cdc364).
- **L14c.** The "No lecture today" note joins the bundle.

## Local verification

Built with `scripts/release-week.sh week-14.1` from a `git archive` of 1cdc364.

- **Bundle.** Title "CHEME 5660 - Week 14", `included=L14a L14c`, `complete=true`,
  188 files under one root, 106 MB. No credentials file and no author-machine paths.
  The checksum passes.
- **Compared with the tested week-14.0 bundle.** The only changes are the Alpaca
  README and the new L14c note, plus the tag name in links to other weeks. Those
  links sit in the root README and the SectorFactor example, and the build script
  writes the tag into them.
- **Extracted-bundle test.** `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed in Julia 1.12.7. Both `Include.jl`
  files load from a directory outside the bundle. The notebooks are the ones run
  from the top for week-14.0, so they were not run again.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-14.1 -m "CHEME 5660 - Week 14"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
