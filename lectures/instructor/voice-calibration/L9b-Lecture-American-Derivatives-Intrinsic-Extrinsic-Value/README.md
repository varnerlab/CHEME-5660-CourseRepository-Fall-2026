# L9b lecture, before the instructor's hand edits

- Source: `lectures/week-9/L9b/CHEME-5660-L9b-Lecture-American-Derivatives-Intrinsic-Extrinsic-Value-Fall-2026.ipynb`
- Copied from commit `ec10c27` on October 16, 2026, after intrinsic and
  extrinsic value moved to L10a. Earlier copies: `c68c2f6` (pseudocode),
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

When the round is done, the edited notebook is compared with `before.ipynb`.
