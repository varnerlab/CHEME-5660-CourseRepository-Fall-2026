# Delta hedging carried over from L10b to L11a

Cut from L10b on 2026-10-27 (time: the two L10a examples moved into L10b). Fold into
L11a's "Delta of Covered Calls and Cash Secured Puts" section before the L11a freeze
(Sunday, November 1). L11a's third objective already asks for the net Delta of shares
plus weighted option Deltas, so this is the general form of what L11a does.

Files:
- `L10b-lecture-delta-section.md`: the full lecture section (net Delta derivation,
  delta-neutral box, exercise/assignment update, composite-Delta table for the eight
  contracts, "zero is not zero risk").
- `L10b-example-task3-with-setup.ipynb`: the put credit spread example's setup cells
  plus Task 3 (Leisen-Reimer leg Deltas, composite Delta +0.069, sell about 7 shares),
  with outputs.
- `L10b-deck-delta-frames.tex`: the five deck frames.

Removed L10b text, for reference:
> * __Construct delta-neutral positions using composite contracts:__ Calculate the net Delta of a portfolio of options and shares, and find the number of shares that makes it delta-neutral.
> * Composite Delta: $\Delta_{\mathcal{C}}=\sum_{i\in\mathcal{C}}\theta_{i}n_{i}\Delta_{i}$ (per share). The options' Delta is $\Delta_{\text{opts}}=m\,\Delta_{\mathcal{C}}$, and holding $N_{S}=-\Delta_{\text{opts}}$ shares makes the net Delta, $N_{S}+\Delta_{\text{opts}}$, zero.
> * __Delta enables construction of hedged positions:__ We wrote the net Delta of a portfolio as the number of shares held plus the weighted Deltas of the legs, and found that holding shares equal to minus the options Delta makes the position delta-neutral. At entry, the sign of the composite contract's Delta matches the outlook, and a zero Delta is not zero risk because Deltas change as the share price moves.

Also to do with the L11a move:
- Course notation page (`code/docs/faq-src/content.json`, rebuilt into
  `code/docs/src/faq/notation.html`): the L10b table still lists Pi(S,t), P_i(S,t), m,
  N_S, Delta_i, Delta_C, Delta_opts, Delta_net, and tau. Move those rows to the L11a
  table, and build the docs locally before pushing (the docs build gates every push).
- Write short Greeks as theta times the long Greek (see the L10a Greeks example, Task 3),
  so the composite Delta sum_i theta_i n_i Delta_i reads as a sum of signed Deltas.
