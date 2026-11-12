# Week 12.4 release — November 12, 2026

A fix-only release of the complete Week 12: **L12a and L12b**. It replaces
`week-12.3`. The earlier contents and checks are in `WEEK-12.3-RELEASE-HANDOFF.md`
and `WEEK-12.2-RELEASE-HANDOFF.md`. This record lists what changed after week-12.3.

## The changes (L12b lecture and deck only)

- **Dealer clearing pseudocode.**
  - The steps have plain names: compare buyers and sellers, bound the trade size,
    search for the trade size, set the price, fill the orders, settle the trades,
    and update the dealer.
  - Each step opens with one sentence on what it does.
  - The balanced case ($d=0$ gives $x_t=0$) is stated. It matches
    `ReserveClearing.jl`, where the search bound is then zero.
- **Price noise.**
  - The constant-product rule and the execution price hold with the
    noise-scaled cash in place of $W_{t-1}$.
  - Net buying raises the price apart from the noise.
  - The deck's Price noise bullet says the noise scales the dealer's cash just
    before the trade.
- **1987.** The index-arbitrage account is attributed to the Brady Report.
- **Examples.** The Viewport example is listed under "Review on your own" in the
  lecture and in the deck, which now agree.

No code, data, or example notebook changed.

## Local verification

Built with `scripts/release-week.sh week-12.4` from a `git archive` of commit
fb90c0d.

- **Bundle.** Title "CHEME 5660 - Week 12", `included=L12a L12b`, `complete=true`,
  201 files. The checksum passes.
- **Comparison with week-12.3.** Only four files differ:
  - the L12b lecture notebook;
  - the L12b deck `.tex` and PDF;
  - `README.md`, whose links carry the tag.
- **Deck.** It builds with no overfull boxes. The changed frames were inspected as
  rendered pages.
- **Review.** A Codex audit was started at release time, at the instructor's
  request to release before it finished. Any finding ships in a later fix release.

## Release steps

1. Commit this record and push `main`.
2. Push an annotated tag: `git tag -a week-12.4 -m "CHEME 5660 - Week 12"`.
3. The workflow opens a draft release. The instructor reviews and publishes it.
