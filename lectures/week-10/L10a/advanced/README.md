# L10a optional advanced material

This folder holds two notebooks. Both are derivations with no code.

- [`leisen_reimer/CHEME-5660-L10a-Advanced-LeisenReimer-Greeks-Fall-2026.ipynb`](leisen_reimer/CHEME-5660-L10a-Advanced-LeisenReimer-Greeks-Fall-2026.ipynb)
  asks when repricing the Cox, Ross, Rubinstein (CRR) tree can give a Gamma of
  zero, and how the Leisen–Reimer tree avoids it. The CRR factors do not depend
  on the share price today, so the premium is straight pieces joined at corners
  where a terminal node crosses the strike. A central difference with a step
  smaller than the spacing between corners can give a Gamma of zero, although
  Delta stays accurate on a tree with enough steps. The
  notebook then derives the probability that the share price finishes
  above the strike under the risk-neutral pricing rule, and uses the
  Peizer–Pratt inversion to give the tree an up probability that matches it.
  Its factors depend on the share price today, so the strike stays between the
  middle terminal nodes and the premium has no corners. It closes with
  pseudocode that computes the Greeks by rebuilding the tree for each moved
  input. The Greeks example uses this tree.
- [`delta_poe/CHEME-5660-L10a-Derivation-Delta-POE-Fall-2026.ipynb`](delta_poe/CHEME-5660-L10a-Derivation-Delta-POE-Fall-2026.ipynb)
  is the derivation companion to the lecture's proposition that a call's Delta
  on the CRR tree is a probability of exercise. It unrolls the European backward
  induction to write the premium of a call on a share with no dividends as a
  sum over terminal nodes, and differentiates it with respect to the share
  price. Splitting the discount factor over the steps turns Delta into a
  probability of finishing in the money, computed with a slightly larger up
  probability than the risk-neutral one. It then shows that each step adds about
  half the volatility times the square root of the time step to the up
  probability, so the two distributions of up moves sit about the volatility
  times the square root of the time to expiration apart, in standard
  deviations. The lecture links it from the proposition and lists it in its
  Optional Advanced Material section.
