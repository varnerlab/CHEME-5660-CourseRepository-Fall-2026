# L9b lecture, before the instructor's hand edits

- Source: `lectures/week-9/L9b/CHEME-5660-L9b-Lecture-American-Derivatives-Intrinsic-Extrinsic-Value-Fall-2026.ipynb`
- Copied from commit `8fc45b3` on October 16, 2026, after the implied-volatility
  blockquote. That replaces the `91262bb` copy, which replaced `13be3a1`, the
  version the instructor rated 4/10.
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

When the round is done, the edited notebook is compared with `before.ipynb`.
