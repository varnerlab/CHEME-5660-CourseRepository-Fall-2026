# L9a lecture, before the instructor's hand edits

- Source: `lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb`
- Copied from commit `aa6dbb9` on October 16, 2026, after he approved the
  Pricing Options pass and said he would make manual edits. Every change up to
  that commit is either Claude's, approved from a preview, or one of his early
  hand edits listed below. Diffing against this copy counts only his new pass.
- Earlier copies: `84b8818`, then `26ffe5d` and the October 12 reorganization
  (`4cb3b2a`). That October 12 copy is the baseline for his first, partial
  pass. Recover it with `git show 4cb3b2a:<this folder>/before.ipynb`.

When the round is done, the edited notebook is compared with `before.ipynb`.

## Before the October 16 refresh

His first hand edits are already inside this copy: `de73d36` (cells 0 and
2–4), plus "Here, denote the payoff for a call contract by $V_c$…" and "for a
single contract" in the profit lead-in. To study them, diff the lecture at
`aa6dbb9` against the `4cb3b2a` copy and skip the Claude edits listed next.

**Exclude from the diff (October 15).** The backup was not refreshed this time,
because the instructor's hand edits had already started (`de73d36`, cells 0 and
2–4). Two changes made after that are Claude's, applied from a preview he
approved, and do not count as his edits:

- The new cell `c9a0be70`, "Concept Review: A Bet on the Future". It is L8b's
  bet section ported with $S_T$ written as $S(T)$ and "the L5a" cut.
- In cell `ae59290f`, the phrase ", such as the bet in the Concept Review," in
  the sentence after the "What does ℚ mean?" bullets.
- Later on October 15, also Claude's, added at his request: the "__Why is the
  bet so cheap?__" callout and its contingent-claims link in cell `ae59290f`,
  and the sentence "Finally, we compare a client's certainty equivalent…" in
  the Optional Advanced Material cell `35eb5c02`.

**Exclude from the diff (October 15–16 polish session).** Claude made these
edits one passage at a time, each from a preview the instructor approved. They
are not his hand edits:

- Cell `a00d63aa` (Cboe profile): the "Index options and volatility" bullet
  merge and "Previously, we estimated volatility…".
- Cell `57e7ebe8`: the merged "Futures, forwards, and swaps" bullet, the deleted
  derivatives video, the 2025 notional sentence, and the two 2025 table cells.
- Cell `148d3931`:
  - the call and put definitions moved above each business case
  - the payoff lead-in, with the $(\cdot)^{+}$ shorthand in the box
  - "a premium per share"
  - the time-value profit and breakeven with $\mathcal{D}_{T,0}(g_y)$, and the
    "about 1.003" sentence
  - the θ orientation sentence
  - the zero-sum sentence (he wrote a first version, and Claude rewrote it)
  - "the premium's future value" in the short-put bullet
- Cell `ae59290f`, the whole `## Pricing Options` section, October 16:
  - the exercise styles moved to the top
  - the new `### The European Premium` and `### Put–Call Parity` headings
  - the replication, ℚ, and "What does ℚ mean?" rewrite
  - the BSM equation paragraph and its three bullets
  - the American teaser blockquote
  - the callout values 0.557 and 0.474

  He cut his own 2025 sentence "European options can only be exercised at
  expiration, which simplifies their pricing." by decision, not by hand.
- Cell `35eb5c02`: the sentence on the BSM equation.

His own hand edits in this window are "Here, denote the payoff for a call
contract by $V_c$…" and "for a single contract" in the profit lead-in.
