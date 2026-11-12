# Week 12.3 release — November 12, 2026

A fix-only release of the complete Week 12: **L12a and L12b**. It replaces `week-12.2`.
The contents and checks of that release are in `WEEK-12.2-RELEASE-HANDOFF.md`. This
record lists what changed after it.

## The changes (L12b lecture and deck only)

- **Generic rules.** The lecture text, the pseudocode, and the deck now write the
  baseline rule $R$ and the switch rule $\bar R$. Earlier they hardcoded Rules 19280
  and 19286. The figures keep 19280 and 19286 as the concrete pair. The notation
  page lists $\bar R$.
- **Prose pass.**
  - The lecture now defines cellular automata, the market maker, margin calls,
    portfolio insurance, index arbitrage, and circuit breakers.
  - The 1929, 1987, and April 2025 summaries were corrected.
  - Filler and trading shorthand were removed.
- **Dealer derivation.**
  - The price update is now derived from the dealer's constant-product rule,
    $W_tQ_t=W_{t-1}Q_{t-1}$ (Angeris et al., 2022).
  - The execution price follows from that rule as the change in the dealer's cash
    per share of the net trade, $F_t=W_{t-1}/(Q_{t-1}-x_t)=\sqrt{S_{t-1}S_t}$.
  - Every step has a label that says what it does.
  - The deck's Dealer frame says the same.

No code, data, or example notebook changed.

## Local verification

Built with `scripts/release-week.sh week-12.3` from a `git archive` of the tree that
this commit records.

- **Bundle.** Title "CHEME 5660 - Week 12", `included=L12a L12b`, `complete=true`,
  201 files. The checksum passes.
- **Comparison with week-12.2.** A local `week-12.2` bundle was built from its tag.
  Only four files differ:
  - the L12b lecture notebook;
  - the L12b deck `.tex` and PDF;
  - `README.md`, whose links carry the tag.
- **Code and examples.** No code or example notebook changed, so the week-12.2
  extracted-bundle test and notebook runs still apply. CI repeats the
  extracted-bundle test on the tag.
- **Deck.** It builds with no overfull boxes. The changed frames were inspected as
  rendered pages.
- **Review.** Codex reviewed the generic-rule and prose edits before they were made. The instructor
  waived the final audit of the dealer derivation for time. Every line of the derivation was
  checked numerically ($W_{t-1}=100$, $Q_{t-1}=10$, $x_t=2$ give $W_t=125$, $S_t=15.625$,
  $F_t=12.5$) and against `ReserveClearing.jl`.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-12.3 -m "CHEME 5660 - Week 12"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
