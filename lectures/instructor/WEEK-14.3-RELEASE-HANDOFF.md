# Week 14.3 release — November 24, 2026

A fix-only release of the complete Week 14: **L14a and L14c**. The instructor asked for it
on November 24 ("commit, push and create the Week-14.3 release"), with no Codex check. It
replaces `week-14.2`.

## Changes since week-14.2

- **L14a lecture** (394d7a2 and this commit). The review no longer ends with the Today
  sentence. The general factor model bullet moved below the synthetic market bullet in the
  core concepts. The paper-trading section now ends with a "Next time" subsection that previews
  the L15a trading method, in place of the closing `JPM` drift question.
- **New figure** `Fig-L14a-Gamma-Picks`, a copy of `week-15/L15a/figs/Fig-L15a-Gamma-Picks`,
  so the week-14 bundle carries it. `Fig-L14a-EWLS-JPM` stays for the deck. Both figure
  READMEs say to edit the Gamma-Picks copies together.
- **SectorFactor example.** Instructor edits to the text and code of Tasks 1–3 and the
  Summary, run again from the top (40 cells became 44).
- **Setup output cleared again.** The example's saved setup output printed the author's
  machine path. Only that output was cleared.

## Local verification

- **Scans.** Neither L14a notebook has a saved error, an author-machine path, or a raw
  YouTube link.
- **Not run.** No local `scripts/release-week.sh` build and no extracted-bundle
  `Pkg.instantiate()` test, at the instructor's request for speed. `Project.toml` and
  `Manifest.toml` have not changed since week-14.2.

## Release steps

1. Commit this record with the changes and push `main`.
2. Push an annotated tag: `git tag -a week-14.3 -m "CHEME 5660 - Week 14"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
