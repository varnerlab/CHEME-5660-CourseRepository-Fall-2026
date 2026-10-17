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

**Exclude from the diff (October 16, during his pass).** His pass began at
11:03 with the new heading "Pricing Put and Call Options Contracts" and "There
are three common exercise styles". Those are his. Claude then turned the
section's four short bullet lists into prose at his request ("I hate small
choppy bullets"), applied from a preview he approved. That edit is Claude's:
the exercise-style paragraph, the "If the premium were lower…" sentences, the
"What does ℚ mean?" paragraph and the event-contract paragraph with its
displayed price, and the hedge paragraph with "Solving the equation backward…".
The preview is in `build/notebook-previews/L9a-pricing-bullets-2026-10-16/`.
Also Claude's, at his request: "European" in "For a European call and put
with the same strike and expiration" (put–call parity).
Then, at his request ("needs to be super explicit"), Claude's: the heading
"Put–Call Parity for European Contracts" and the paragraph opening
"__Put–call parity holds only for European contracts.__", which absorbed the
old "Parity uses only the payoff identity…" sentence.
Then, at his request, Claude's rewrite of `### The European Premium` and the
BSM part of cell `ae59290f`, applied at 13:15 from a preview he approved
(`build/notebook-previews/L9a-mc-premium-2026-10-16/`): his replicating-portfolio
paragraphs replaced by the call-as-a-bet expected-NPV derivation, "Whose
probabilities?" (ℙ ours, ℚ the market's), the Monte Carlo pseudocode and example,
the deleted "What does ℚ mean?" paragraph and "Why is the bet so cheap?" callout,
the "alternative way to think about the premium" pointer, the BSM equation
paragraph without the hedge, "Which σ?" with the bisection pseudocode, the SPXW
link and the Sun et al. reference, the paragraph naming SPX, XSP, NDX, and RUT,
and "share price" wording fixes. In cell `35eb5c02`, the contingent-claims
sentences without replication and the rewritten SPXW description are Claude's.
Then, at his request (a polish pass, approved from a preview, applied about
14:00; `build/notebook-previews/L9a-polish-2026-10-16/`), Claude's word-level
edits: "risk-neutral pricing rule" and "by Monte Carlo simulation" in LO 3 and
"pricing rule" and "Monte Carlo simulation or" in takeaway 3; the Example 2
description "In this example, we compute European call and put premiums by
Monte Carlo simulation and with the Black–Scholes–Merton formulas." in both
places; "(Cboe)"; "market price" without "$S$" in the long-put bullet. In cell
`ae59290f`: the period replacing his semicolon after "only at expiration"; the
cut "Here, denote the payoff for a call contract by…"; "if $S(T)>K$ and
$-\mathcal{P}$ otherwise"; the path count $M$ (was $N$) in the Monte Carlo
pseudocode and the bisection paragraph; "the average payoff over all paths is
the fraction that finish above the strike times the average payoff of those
paths"; "0.4934\times29.01"; "If we replace $g_{y}-\sigma^{2}/2$ in step b
with…"; en dashes in "Black–Scholes–Merton"; "Subtracting the put premium from
the call premium gives:"; "Let's look at an example of European option
pricing."; and paragraph breaks before "Under $\mathbb{Q}$, the expected share
price", "If we replace", and "The [SPXW volatility skew notebook]".
His 14:29 edits after that pass (cutting "For the bet, $\bar{V}=1$ USD.", the
lattice-$q$ clause, and the numeric Monte Carlo example) are his. Then, at his
request ("Why are we not making an expression for $\mathbb{E}_{Q}[NPV_{0}]$ …
and then we set … = 0"), applied about 15:00 from previews he approved
(`build/notebook-previews/L9a-npv-under-q-2026-10-16/`), Claude's: in cell
`ae59290f`, "For geometric Brownian motion with no dividends, $\mathbb{Q}$
replaces the drift with $g_{y}$. Repeating the expected NPV calculation with
$\mathbb{Q}$ in place of $\mathbb{P}$ gives:", the $\mathbb{E}_{\mathbb{Q}}$
derivation (the $\mathbb{P}$ lines with $\mathbb{Q}$, the second bracket
underbraced as $\mathbb{E}_{\mathbb{Q}}[V_{c}(K,S(T))]$), the paragraph "where
$\bar{V}$ is now … market premium of the call", the paragraph "Repeating these
steps for a put …", and the box $\mathcal{P}^{\text{EU}}=\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\mathbb{E}_{\mathbb{Q}}[V(K,S(T))]$.
These replace the $\mathbb{E}_{\mathbb{Q}}(\mathcal{D}^{-1}S(T))=S(0)$ display,
the "In general, the premium…" box after the pseudocode, and the call sentence
there. Also Claude's: "estimate the market premium"; the event-contract
display $p=\mathcal{D}^{-1}\cdot\mathbb{E}_{\mathbb{Q}}[\mathbb{1}\{\text{event}\}]$;
the four-line put–call parity derivation from the box (reason column "premium
formula, expectation is linear", "payoff identity", "expected share price grows
at $g_{y}$ under $\mathbb{Q}$", "$\mathcal{D}^{-1}_{T,0}(g_{y})=e^{-g_{y}T}$"); and
"the rule that the expected share price grows at $g_{y}$ under $\mathbb{Q}$" in
the paragraph after parity.
Then, after a re-score of 8.9 and at his request (preview approved, applied about
16:00; `build/notebook-previews/L9a-rescore-2026-10-16/`), Claude's: the event
contract block moved from after the Monte Carlo pseudocode to directly under the
$\mathcal{P}^{\text{EU}}$ box (wording unchanged); "This is a share purchase
with the premium and the payoff in place of the purchase and sale prices";
"the call pays $S(T)-K$ instead of 1 USD when $S(T)>K$"; "the most we would
pay. A buyer with different beliefs computes a different premium."; "although
the BSM model assumes one constant $\sigma$"; and square brackets in the
American teaser's $\mathbb{E}_{\mathbb{Q}}[\cdot]$.
Then, at his request (about 16:45), Claude's: "we can compute this premium with
the [Black–Scholes pricing formula]" (was "the expectation"), and the market
table labels "U.S. equities average daily notional value, ADNV (USD/day)" and
"Options average daily volume, ADV (contracts/day)".
Then, at his request (about 17:15, his choice of symbol), Claude's: the
breakeven symbol $S^{\ddagger}$ replaces $S_{\text{BE}}$ in the breakeven
display, and "gives the __breakeven__ share price $S^{\ddagger}$ at
expiration:".
Then, at his request (about 17:10), Claude's: $\max_{\tau\leq T}$ replaces
$\sup_{\tau\leq T}$ in the American premium, and the sentence "Many texts
write $\sup$, the least upper bound, in place of $\max$ to cover contracts
with no best exercise time."
Then, at his request (about 17:25, preview approved,
`build/notebook-previews/L9a-event-contract-2026-10-16/`), Claude's: the
event-contract paragraph now opens "The bet in the Concept Review is an
__event contract__ on $S(T)\geq K$, which pays …" and "Its market price is:",
and the later sentence "The bet in the Concept Review is the event contract on
$S(T)\geq K$." is cut.
Then, at his request (about 17:35, "should we move the IV blockquote to L9a?"),
Claude's: the "Historical or implied volatility?" blockquote moved in from L9b,
between the "Which volatility $\sigma$ should we use?" paragraph and the
bisection pseudocode. Its wording is the approved L9b text, with $S(0)$ in place
of $S_{0}$ and the sentence "In other words, it is the volatility "implied" by
the market price of an option … such as Black–Scholes–Merton or CRR." cut.
Then (about 18:30), Claude's, after the SPXW advanced notebook was rebuilt on a
real Alpaca snapshot: in cell `35eb5c02`, the SPXW bullet now reads "an
end-of-day chain", drops "check the quotes," and the settlement and "synthetic"
sentences, and ends "We then compare the resulting skew with the realized
volatility of SPY, the exchange-traded fund that tracks the index."

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
