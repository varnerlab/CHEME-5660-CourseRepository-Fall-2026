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
Then, on October 17 (about 08:00), during his second pass, at his request
("it is always on the wrong line"), Claude's: in the three derivations that
use "the two probabilities sum to one" (cells `c9a0be70` and `ae59290f`), that
reason moved up to the line with the $=1$ underbrace, shortened at his
request to "collect the … terms, probabilities sum to 1", and the result
line lost its reason. In
the $\mathbb{Q}$ derivation, "the call pays 0 if $S(T)\leq K$" moved down to
the continuation row. His October 17 edits before this (cell 0, "the price $p$
of this bet", the "discounted payoff" underbrace, "probability of true") are his.
Then (about 08:15), at his request ("we need to make a tighter connection to the
CBOE"), Claude's: in the Cboe profile's connection paragraph (cell `a00d63aa`),
"Every listed contract trades at a premium that the buyer pays today for a
payoff that may be zero at expiration." became, after a second request to
include regular options and Cboe's lead in options, "Cboe is the largest
options exchange operator in the United States, and most contracts traded on it
are calls and puts. Its event contracts are the bet from the Concept Review,
paying 100 USD instead of 1 USD. Each contract trades at a single premium that
all buyers pay today."
He then rewrote it himself (about 08:30): "Cboe is the largest options exchange
operator in the United States. Its event contract business (binary options,
much smaller than [Kalshi]) are the bet …", split into a second paragraph
opening "Regardless of the type of contract, each contract trades …" and ending
"to explore this question." That draft is his. Claude's fixes on top, which he
approved ("apply it"): ", and most contracts traded on it are calls and puts"
restored, "Its event contracts (binary options, a much smaller business than
Kalshi) are" for the subject–verb agreement, "Whatever the type of contract,
each trades", and the link `https://kalshi.com/`.
Then (about 08:40), at his request ("Don't get the second half of this line (the
default risk)"), Claude's plain-English fix of its own `aa6dbb9` jargon: in the
OCC bullet (cell `a00d63aa`), "so if one side cannot pay, the other is still
paid" (was "so neither side carries the other's default risk"), and in the
forwards sentence (cell `57e7ebe8`), "where the two parties negotiate the terms,
and if one party cannot pay, the other takes the loss" (was "… and each bears
the other's default risk"). The deck's derivative slide got the same fix.
Then, at his request ("U.S. cash equities => U.S. equities?"), Claude's: "cash"
cut from the notional comparison in cell `57e7ebe8`. His own edit just before:
"sports, political events" in the event-contracts bullet.
Then, at his request, Claude's gloss after “triple witching” in cell `57e7ebe8`:
", the third Friday of March, June, September, and December, when stock options,
index options, and index futures all expire".
His own edit next: in the options bullet (cell `57e7ebe8`), "an asset (typically
a stock, index or ETF) at a specific price on or before a specified expiration
date". Then, at his request, Claude's three fixes on top: "index, or ETF", "Stock,
index, and ETF options are exchange-traded" (was "Options are exchange-traded"),
and "The largest U.S. options exchange". The deck's derivative slide got the
exchange-traded fix.
Then, at his request ("remove all references to replicating portfolios"),
Claude's: in cell `ae59290f`, "This is a share purchase with the premium and the
payoff in place of the purchase and sale prices, so the net present value at
$t=0$ is:" became "Discounting the payoff at the benchmark growth rate $g_{y}$
gives the net present value at $t=0$:" (the Concept Review's wording).
Then, at his request ("non-negative expected NPV, like we did in the bet?"),
Claude's, in cell `ae59290f`: "The expected NPV is non-negative when the premium
is at most … $\mathcal{P}\leq\ldots$" (was "is zero when the premium is …
$\mathcal{P}=\ldots$"), and before the market premium, "The seller's NPV is the
negative of the buyer's, so with one shared $\mathbb{Q}$, the only premium at
which neither side expects to lose is the one that sets … $=0$. This gives the
market premium of the call," (was "Setting … $=0$ gives the market premium of
the call,"). The deck's European Premium and Market Premium slides got the same
changes, plus the "sum to one" reason moved up to the underbrace line.
Then, at his request ("tighten the slides"), Claude's deck-only pass: 13 dense
slides cut by about 20% (business cases, profit, the European/Whose
Probabilities/Market/Monte Carlo premium sequence, BSM equation, the three
volatility slides, IV in practice, parity). The notebook was not touched. The
European Premium slide also dropped "A call is a bet whose payoff grows with the
share price" to match his lecture edit, and the market slide says "U.S.
equities". Before/after: `build/notebook-previews/deck-tighten-2026-10-17/`.
Lecture edits saved through 17:14 that this list does not name as Claude's are
his. Then (about 17:20), at his request ("the max(*,0) terms are hard to follow, how
do we get this?"), Claude's: in cell `ae59290f`, the one-line parity payoff
identity $V_{c}-V_{p}=(S(T)-K)^{+}-(K-S(T))^{+}=S(T)-K$ became a three-row
`align*`: the two $\max(\cdot,0)$ payoffs ("payoff definitions"), a `cases`
split ("split at the strike price $K$", with "the put pays 0" and "the call pays
0" on the branches), and $S(T)-K$ ("simplify both cases"). The prose is
unchanged. Before/after: `build/notebook-previews/L9a-final-round-2026-10-17/`.
Then (about 17:30), approved ("Agree - text is tight, well done"), Claude's
final-round fixes, shown in `2-others.png` in the same folder: cell `ecdef8a1`,
LO2 drops its last "at expiration"; cell `c9a0be70`, "If the condition
$S(T)\geq K$ is true, the NPV is …. Otherwise, it is $-p$." (was "If the
condition ($S(T)\geq K$) is true the NPV is …, otherwise it is $-p$ if it is
false."), the last underbrace reads "probability of true", and a comma after
"$\mathbb{E}[\operatorname{NPV}_{0}]\geq 0$"; cell `57e7ebe8`, "U.S. options
market" in the heading; cell `ae59290f`, "the benchmark risk-free rate" and "the
risk-free growth rate" (were "a …"), "weighted by the probability of that
outcome" (was "its"), $V_{\star}$ in the $\mathcal{P}_{\star}^{\text{EU}}$ box
and its lead-in, "__The BSM equation.__" and "the __BSM equation__" (were
spelled out), "shows that its solution is the risk-neutral premium" (was "this
expectation"), and the IV bullet ends at "a forward-looking measure of
uncertainty." (cut ", and it is the volatility that makes the BSM model's
premium equal to the market premium"). The deck carries none of these phrasings
and was not changed.
Then, at his request ("Show the step before this one"), Claude's: the parity
derivation in cell `ae59290f` now opens with the premium formula applied to each
contract, $\mathcal{D}^{-1}\mathbb{E}_{\mathbb{Q}}[V_{c}]$ ("premium formula for
the call and the put") with $-\,\mathcal{D}^{-1}\mathbb{E}_{\mathbb{Q}}[V_{p}]$ on a
continuation row, and the old first line's reason became "expectation is
linear" (was "premium formula, expectation is linear"). The deck's parity slide
got the same row ("premium formula" / "expectation is linear"), wrapped the same
way, with tighter display spacing on that frame only so it fits (32 pp, 0
overfull). Previews: `3-parity-step.png`, `deck-parity-before-29.png`, and
`deck-parity-after-29.png` in the same folder.
His 17:50 save (cut "For European contracts, parity uses only the payoff
identity …"; $\mathcal{P}_{\star}^{\text{AM}}$, $V_{\star}$, and "where
$\star\in\{c,p\}$" in the American teaser) is his. Then (about 18:20), approved
("Agree"), Claude's: the BSM premium example gained a real SPXW quotes
subsection in its Task 3, so both descriptions of that example in the lecture
(cells `90b886b6` and `ae59290f`) end "We then look at how the premium changes
with strike price, in the model and in real S&P 500 index option quotes." The
deck's Lectures and Examples blurb got the same clause. Previews:
`build/notebook-previews/L9a-spxw-example-2026-10-17/`.

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

October 20, Claude's: the advanced notebooks moved to `L9b/advanced/`, so the
lecture's five advanced links (three in the pricing section, two in Optional
Advanced Material) and the advanced-index link now point to `../L9b/advanced/`.
Exclude them from the diff.
