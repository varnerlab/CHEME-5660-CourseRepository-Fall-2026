# Week 14.0 release — November 23, 2026

The first Week 14 release: **L14a only**. The instructor asked for it on
November 23 ("make the Week-14.0 release (L14a materials)"). L14c is the
Thanksgiving "no lecture" folder and arrives as `week-14.1`.

## Contents

- **Lecture.** Updating the single index model and paper trading. It opens with
  the review of the sector factor example that L13b did not reach in class.
- **Examples.** The sector factor example, moved from L13b, and the example that
  updates the single index model and picks the preference basket.
- **Alpaca server.** `alpaca-mcp/` with its README, the server code, and the
  credentials template. The private `conf/apidata.toml` is excluded by the build
  script and is not in the bundle.
- **Advanced.** The EWLS update derivation (`advanced/ewls/`, no code).
- **Deck.** 31 pages, 0 overfull boxes.

## Local verification

Built with `scripts/release-week.sh week-14.0` from a `git archive` of 67c3691.

- **Structure.** All four notebooks have three objectives and three takeaways, no
  unexecuted code cells, no error outputs, and a `___` before every `##` and at
  the end. Every lecture `[▶ ...]` description opens with "In this example," or "In
  this notebook," and has no math. All relative links and images resolve in the
  notebooks and the three READMEs. There are no links into L14c and no raw YouTube
  links. The linked PS6 repository is public.
- **Setup output.** Cleared from both examples (67c3691).
- **Bundle.** Title "CHEME 5660 - Week 14 (L14a)", `included=L14a`,
  `complete=false`, 187 files under one root, 106 MB. No instructor, NotebookLM,
  LaTeX build, Notes, L14c, or credentials files, and no author-machine paths. The
  checksum passes. The CI build is separate, and its digest is the one students
  verify.
- **Extracted-bundle test.** `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed in Julia 1.12.7. Both `Include.jl`
  files (`L14a/` and `L14a/alpaca-mcp/`) load from a directory outside the bundle.
  Both examples ran from the top inside the bundle with the `julia-1.12` kernel,
  with 0 errors (SectorFactor 85 s, Gamma 35 s). Every saved text, table, and HTML
  output matches the runs, and the figures sit in the same cells. The exception is
  the setup cell, which prints in a fresh run.

## Not run

- The Codex check: this release makes no content changes. The only edit is the
  cleared setup output.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-14.0 -m "CHEME 5660 - Week 14"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.

## CI build — November 23, 2026

Tagged `week-14.0` at ff81472. Release workflow run 45240360098 passed and opened
a draft release titled "CHEME 5660 - Week 14 (L14a)". The downloaded zip matches its
`.sha256` file (GitHub digest
`1f7256e180d8b2c4ed66f99f0b5bfcbc28dd7d64d675b11dcf8a3d01d6c7f939`). Its files have
the same bytes as the tested local bundle. The only listing difference is how the two
unzip tools print the narrow no-break space in three screenshot filenames under
`code/src/data/options/original/`.
