# Week 12.0 release — November 10, 2026

The first Week 12 release: **L12a only**. L12b arrives as `week-12.1`. The
instructor asked for it on November 10 ("Run the Week-12.0 release (contains the
L12a materials). Please make sure the slides are in sync").

## Contents

- **Lecture.** Agent-based models, the Farmer–Joshi market, and the thermal
  minority game.
  - The Farmer–Joshi section now introduces the traders and their rules first:
    the diagram, what each group watches, the threshold rule, positions, orders
    and the price rule, the growth rate, the comparison with geometric Brownian
    motion, and the algorithm.
  - The GBM derivation shows $\mu=\mu_{g}+\frac{1}{2}\sigma^{2}$ and
    $\sigma=\sigma_{g}\sqrt{\Delta t}$ in its side notes, because we estimate
    $\mu_{g}$ and $\sigma_{g}$ from data.
  - The minority game bullets use three cases for $J=2$: crowded below about
    $\alpha=0.2$, smallest volatility near $\alpha=0.34$, and rising toward the
    coin-flip value from below above that. The earlier cut at $\alpha=1$ was wrong.
    The numbers come from simulations with $J=2$ and from Challet, Marsili, and
    Zecchina (2000), who report the transition at $\alpha\approx 0.34$.
- **Examples.** Farmer–Joshi and thermal minority game, both worked in lecture.
  The Farmer–Joshi threshold ranges are now constants passed to `build(...)`.
- **Advanced.** The maximum-entropy and biased-policies derivations.
- **Deck.** 27 pages, 0 overfull boxes.
- **Notation page.** The L12a table lists $\sigma_{g}$.

## Slide sync

- The Farmer–Joshi frames follow the lecture order. Two frames were retitled:
  "The Farmer–Joshi Market: One Step" and "The Market Maker Sets the Price". The
  growth-rate frame is now "Growth Rate: Farmer–Joshi and GBM", so that it fits.
- The growth-rate frame states both relations and the tie to the data. The Volatility
  per Agent and Phase Diagram frames give the $\alpha$ ranges.
- The threshold-rule figure carries words on the exit arrows, in the notebook SVG
  and on the slide.
- `figs/generate_results_data.jl`, rerun from a scratch copy, reproduced all eight
  data files byte for byte. A cell appended to a scratch copy of the Farmer–Joshi
  example reproduced every entry of the Stylized Facts table.

## Local verification

Built with `scripts/release-week.sh week-12.0` from a `git archive` of 29e226d.

- **Structure.** All five notebooks have three objectives and three takeaways, no
  unexecuted code cells, no error outputs, and a `___` before every `##` and at
  the end. Every lecture `[▶ ...]` description opens with "In this example," or "In
  this notebook," and has no math. All relative links and images resolve, and there
  are no links into L12b.
- **Setup output.** Cleared from both examples.
- **Bundle.** Title "CHEME 5660 - Week 12 (L12a)", `included=L12a`,
  `complete=false`, 187 entries under one root. No instructor, NotebookLM, LaTeX
  build, or L12b files, and no author-machine paths. The checksum passes. The local
  SHA-256 is `7a2c010d43e3d0f768be4b30b36f6af61a5c60b2a1f9e5707a63a3baa31adb4c`.
  The CI build is separate, and its digest is the one students verify.
- **Extracted-bundle test.** `Pkg.instantiate()` and
  `using VLQuantitativeFinancePackage` succeed in Julia 1.12.7, and `Include.jl`
  loads. Both examples ran from the top inside the bundle with the `julia-1.12`
  kernel, with 0 errors (20 s and 52 s). Saved text outputs and figures match the
  runs. The exceptions are the setup cell, which prints in a fresh run, and one
  table in the minority game example that arrives as two stream chunks with the
  same text.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-12.0 -m "CHEME 5660 - Week 12"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.

## CI build — November 10, 2026

Tagged `week-12.0` at 1f3c6ab. Release workflow run 42831799853 passed and opened
a draft release titled "CHEME 5660 - Week 12 (L12a)". The downloaded zip matches its
`.sha256` file (GitHub digest
`cfc32a91be48a576ecaf0a121d0f05302fd5ee92c7e6aa8f1fc62de0c2f3dae6`). Its 161 files
have the same bytes as the local bundle. The only listing difference is how the two
unzip tools print the narrow no-break space in three screenshot filenames under
`code/src/data/options/original/`.
