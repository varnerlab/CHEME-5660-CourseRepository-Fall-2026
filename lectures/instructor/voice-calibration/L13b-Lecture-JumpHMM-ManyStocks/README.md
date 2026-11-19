# L13b lecture, before the instructor's hand edits

- Source: `lectures/week-13/L13b/CHEME-5660-L13b-Lecture-JumpHMM-ManyStocks-Fall-2026.ipynb`
  and its deck, `lectures/week-13/L13b/slides/CHEME-5660-L13b-Slides-Fall-2026.tex`.
- Copied from the working tree on November 19, 2026. The tree was commit `d79be3b` plus
  uncommitted changes. Nothing from these rounds had been committed yet.
- State: the lecture's language pass, approved by the instructor that day. The
  approved rounds before it, all on November 19:
  - The single index covariance story.
  - The derivations of δ, c and ψ moved to
    `advanced/sector_factor/CHEME-5660-L13b-Derivation-SectorFactor-Parts-Fall-2026.ipynb`.
  - The side-by-side Σ_g comparison, with ψ shown.
  - The overbrace on the single index residual.
  - The four-stock example with colored, labeled blocks.
  - The reorder: example, then the stock-specific part, then the comparison, then Computing the Parts.
  - u_i^draw removed from the lecture.
  - The single-asset framing in the section lead and in Summary takeaway 2.
  - The derivation of the sector factor average.

When the round is done, the edited notebook is compared with `before.ipynb`, and
the edited deck with `before-slides.tex`.

## Held for the end-of-review check (11-19)

- "Why not use the single index model?" blockquote: paragraph 2 goes from the tails to the sector co-movement with no link (the cut "also" sentence carried it). The last sentence says "Simulated … in the model" and has a dangling "then". The "(or the JumpHMM trained on the individual tickers)" parenthetical is unclear, and the lecture says "fitted", not "trained".
- Deck "Why Not…" slide: sync it to his edited text.
- Deck definition slide (14): add the MSCI–GICS sentence if he keeps it in the lecture.
- Not his hand edit: "The Stock-Specific Part" was rewritten by Claude at his request (11-19). It defines u_i as the leftover, puts the data and simulation variances side by side, and sets Cov to 0 in the simulation. Leave it out of the voice diff.
- After that rewrite: the "Stock-specific residual" bullet in Computing the Parts repeats u_i = ε_i − δ_i f_s and could shrink to the ψ sentence. Slide 17 needs the new section.
- Not his hand edit: the drifting β section, the note under the algorithm, and the drift clauses in the LOs, core concepts, For understanding, and Summary takeaway 3 were cut at his request (11-19). The text is saved in lectures/instructor/L14a-DRIFTING-BETA-FROM-L13b.md.
- After the drift cut: delete deck frame 22 and the drift clauses on the deck's LO, what-you-need-to-know, and summary frames. Update the README lines 8 and 16. Check the notation rows for β(t), a, k_i, z_i. Decide on example Task 3.
- Done 11-19: the deck was synced to the hand-edited lecture. That covers the Why Not slide, the GICS definition slide, the new Stock-Specific Part (two frames now), the drift frame and drift clauses, and the removed Computing the Parts frames. The deck has 24 pages and 0 overfull boxes. It does not copy the lecture typos ("a ay", "We now off-diagonal") or the "(or the JumpHMM trained on the individual tickers)" parenthetical.
