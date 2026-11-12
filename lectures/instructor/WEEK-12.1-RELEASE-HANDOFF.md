# Week 12.1 release — November 11, 2026

The complete Week 12 release: **L12a and L12b**. The instructor asked for it on
November 11 ("Let's do the Week-12.1 release (so the L12a, and the L12b materials)").

## Contents

- **L12b lecture.** Wolfram markets: traders on a grid who follow a rule table, a
  dealer who sets the share price from the net trade, technical traders on the
  edge, and the rule switch with its control.
- **L12b examples.** Four examples, all run live from their Constants cells:
  - Rules: one market under one rule, then a second rule. The defaults are the
    rules of the lecture, 19280 and 19286.
  - Stylized facts: a Wolfram market and the Farmer–Joshi market against a real
    ticker.
  - Rule switch: a switched market and its control, then fresh players. The
    default is the bubble pair, 19287 and 19341.
  - Closed and open markets: turnover and contrarian players.
- **L12b advanced.** The Q-learning notebook, with the corrected algorithm loop.
- **L12b deck.** 24 pages, 0 overfull boxes, synced with the lecture on
  November 11.
- **L12a.** Three changes since `week-12.0`, all from November 10:
  - The Farmer–Joshi figure has a signal axis with example thresholds.
  - The lecture has an example table that traces one value investor through ten
    steps.
  - The Farmer–Joshi example plots the market with both groups by default.

  The deck crops the signal axis out of its copy of the figure, as recorded in
  `lectures/week-12/L12a/figs/README.md`. The deck does not carry the example table.

## Changes made for this release

- The six rule-switch cache files in `lectures/week-12/L12b/data/` were deleted at
  the instructor's request. No notebook loaded them. The `.gitignore` line that
  kept them tracked, a comment in `Include.jl`, the scripts README, and the
  teaching brief no longer refer to them.
  `scripts/Compute-L12b-RuleSwitch-Cache.jl` stays and ships in the bundle.
- The saved setup output was cleared from all six example notebooks.
- One stale output was cleared in the Farmer–Joshi example (a bare `"both groups"`
  under the plot-selector cell, which a fresh run does not print).
- The plain-text copy of the animation output in the rule-switch example held a
  temporary-folder path. It now reads `Plots.AnimatedGif(...)`. The animation
  itself is unchanged.

## Local verification

Built with `scripts/release-week.sh week-12.1` from a `git archive` of the tree
that this commit records.

- **Structure.** All eleven notebooks have three objectives and three takeaways, no
  unexecuted code cells, no error outputs, and a `___` before every `##` and at
  the end. Every lecture `[▶ ...]` description opens with "In this example," or "In
  this notebook," and has no math. All relative links and images resolve.
- **Bundle.** Title "CHEME 5660 - Week 12", `included=L12a L12b`, `complete=true`,
  201 files under one root. No instructor, NotebookLM, or LaTeX build files, and no
  author-machine paths. The checksum passes. The local SHA-256 is
  `75e42254a96fbd6c5d0d113e6e014f1a84f6044ffa20412d57d46d8ea1fd95f2`. The CI build
  is separate, and its digest is the one students verify.
- **Extracted-bundle test.** `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed in Julia 1.12.7, both `Include.jl`
  files load, and `scripts/Test-Helper.jl` passes. All six examples ran from the
  top inside the bundle with the `julia-1.12` kernel, with 0 errors (23 s to 60 s
  each). All 35 saved figures match the runs byte for byte. The saved text matches
  except for the run-time lines and the two outputs cleared above.
- **Not re-checked.** The L12a deck numbers were verified against the example for
  `week-12.0` and were not re-derived here. The L12a deck source changed by one
  line since then (the figure crop).

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-12.1 -m "CHEME 5660 - Week 12"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.

## CI build — November 11, 2026: failed, no release

Tagged `week-12.1` at 926a464. Release workflow run 43132396408 failed at **Test
extracted bundle**, so no draft release was created. The tag stays where it is and
has no release.

`lectures/week-12/L12b/Include.jl` set `_ROOT = pwd()`. The workflow loads each
`Include.jl` from the runner's working directory, so `src/Helper.jl` was not found.
The local test for this release had changed into the L12b folder first, which hid the
problem. The fix and the release are in `WEEK-12.2-RELEASE-HANDOFF.md`.
