# Week 13.2 release handoff

- Tag: `week-13.2`, built on November 19, 2026. Title: CHEME 5660 - Week 13. Meetings: L13a and L13b
  (the complete week). `week-13.1` was the L13a-only update.
- New in this release: the L13b lecture (single index covariance story, sector factor model, stock-specific
  part, comparison of the two covariance matrices, sampling algorithm), its deck (24 pages, 0 overfull
  boxes, synced to the instructor's hand edits), both L13b examples on JumpHMM 0.6.0, and two optional
  advanced notebooks: `advanced/sector_factor/` (derivation, no code) and `advanced/one_minute/`
  (one-minute `SPY` model, with its 9.8 MB data file).
- Checks run: 3 learning objectives and 3 key takeaways in every lecture and example; setup output
  cleared in the three L13b computational notebooks and the L13a SPY example (merge with origin); no
  error outputs; checksum OK; extracted bundle instantiates and every `Include.jl` of week 13 loads from
  a directory outside the bundle. The bundle is 87.6 MB.
- Skipped at the instructor's request (short on time): the Codex check.
- Known, not fixed: three dead links in the L13a advanced export
  `advanced/markov/md/CHEME-5660-L13a-Lecture-MarkovModels-Fall-2025.md`. They point to example
  notebooks that sit one folder up. That file shipped the same way in week-13.0 and week-13.1.
