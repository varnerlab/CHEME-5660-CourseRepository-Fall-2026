# L9b lecture, before the instructor's hand edits

- Source: `lectures/week-9/L9b/CHEME-5660-L9b-Lecture-American-Derivatives-Intrinsic-Extrinsic-Value-Fall-2026.ipynb`
- Copied from commit `5568311` on October 16, 2026, after the polish pass.
  Earlier copies: `ec10c27` (intrinsic and extrinsic value moved to L10a),
  `c68c2f6` (pseudocode),
  `8fc45b3` (implied-volatility blockquote), `91262bb` (voice pass), and `13be3a1`, the version the instructor
  rated 4/10.
- One hand edit of his is already in this copy, so the diff will not show it:
  he joined the $R_f$ sentence to the next paragraph with "However, unlike the
  data-driven binomial model we discussed earlier, ...". Count it as his.
- State: the voice pass approved by the instructor on October 16 ("This looks
  great! Agree"). CRR is taught as new material under "American Style Options
  Contracts", the market section precedes Monte Carlo, and the company profile is
  the Options Clearing Corporation. AGENTS.md (L9b entry) lists the changes.
- Sentences new in this pass, not from his 2025 or earlier approved text: the
  OCC profile; "The hold term is the European premium formula applied over one
  step."; the implied-volatility gloss; "We compute every node of this lattice in
  the following example:"; the two handoffs around the Monte Carlo section; the
  q formula in the Hull callout; and the Longstaff–Schwartz sentence in
  Takeaway 1.
- New with the implied-volatility blockquote (8fc45b3): the "where $\sigma$ is
  the same volatility as in geometric Brownian motion..." sentence; the
  blockquote lead; the historical-volatility bullet and "This estimate looks
  backward."; "Over a horizon of $T$ years, the size of that move scales with
  $\sqrt{T}$."; the derivation lead, the four-line derivation, the symbol
  definitions, the 100 USD/share example, and the 68% sentence. These come from
  his 2025 L6a covariance example: the IV definition, "In other words, ...
  implied ...", "represents a one-standard-deviation movement ... over the next
  year", and "often equal to or larger than the historical volatility".
  The "implied-volatility gloss" listed above is gone.
- New with the pseudocode (c68c2f6): both pseudocode blocks and the lead "Let's
  outline some pseudocode for pricing an option contract on the CRR lattice."
  The Longstaff–Schwartz bullets became steps 1, 3b, and 3c, keeping their
  labels and some of their wording. "The premium is the average discounted cash
  flow." was cut, since step 4 now does it.
- New with the move to L10a (ec10c27): the Longstaff–Schwartz learning
  objective ("Estimate the premium of American options by simulation: ..."),
  the takeaway labels "Binomial trees price American options", "Early exercise
  adds value only when it can pay", and "Simulation estimates the same
  premium" (each takeaway is his sentence), and the closer "The early-exercise premium is
  what the right to exercise before expiration is worth, and the lattice and
  simulation give two ways to compute it."
- New with the polish pass (5568311): "of a contract with strike price $K$
  and expiration $T$ ... back to today at the risk-free rate $g_{y}$" in the
  first where-clause; "the risk-neutral pricing rule" before $\mathbb{Q}$;
  the "factor out $S_0$" and "expand $(1-q)d$" lines; "Let's use this lattice
  to price American contracts."; "but each path has only one future" and
  "across paths"; "The fitted curve estimates the value of holding."; "The
  following example computes every node of this lattice:"; "and measure each
  contract's early-exercise premium." in both CRR example descriptions; "the
  archived contracts"; the takeaway label "Early exercise can pay for puts",
  "That never happens for a call on a share with no dividend.", "works
  backward along simulated paths," and "Holding on every path gives the
  European premium." These changes reuse his words: his Hull handoff and the
  Longstaff–Schwartz holding sentence moved after the example links, his two
  market-data sentences were merged, and "Models compute" now starts a new
  sentence.
- After the backup, at his request (October 16, about 17:10), Claude's:
  $\max_{\tau\leq T}$ replaces $\sup_{\tau\leq T}$ in the American premium
  display. Exclude it from the diff.
- Then, at his request (about 17:35), Claude's: the "Historical or implied
  volatility?" blockquote after the $u$/$d$ box moved to L9a. Exclude its
  removal from the diff.

- After his October 18–19 edits, at his request (October 19 scoring round,
  approved "Agree"), Claude's: "on binomial lattices" in place of "on the CRR
  lattice" in the handoff before the Monte Carlo section (Hull's tree has
  $ud=0.96$); "across strike prices" at the end of both Longstaff–Schwartz
  example descriptions; and the summary of how CRR get $u$ and $d$ before the
  $u$/$d$ box (the sentences defining $a$, $g$, and $p$, the four-row display,
  the $\mu_{g}$ where-clause, and "Cox, Ross, and Rubinstein keep only the
  first term, so $a=\sigma\sqrt{\Delta t}$ and:"), plus a paragraph break
  before "However, unlike". Exclude them from the diff.

- October 20, at his request (L9a class stopped at the Monte Carlo premium),
  Claude's: the title, objective 1, the BSM example in the Examples list, the
  new cells `l9b-cr` (Concept Review: A Monte Carlo Premium) and `l9b-bsm`
  (ported from L9a), "We write" for "Previously, we wrote" in the American
  section, the two advanced bullets and "notebooks", the Summary opener, and
  the first two takeaways. Exclude them from the diff. The ported L9a text is
  his, so compare it with the L9a calibration copy instead. Same day: the
  put–call parity subsection moved to the InterestingFact notebook, leaving one
  "__Interesting fact:__" sentence, and "put–call parity" left objective 1
  and takeaway 1. These are Claude's too.

When the round is done, the edited notebook is compared with `before.ipynb`.
