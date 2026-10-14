# L8b optional advanced material

These standalone derivation notebooks extend the L8b treatment of utility-based
allocation. They are optional.

- [Cobb–Douglas allocation with share floors](cobb-douglas-derivation/CHEME-5660-L8b-Derivation-CobbDouglas-Fall-2026.ipynb)
  derives the Cobb–Douglas allocation from the full problem over shares and
  cash, gives the optimality conditions with share floors, and proves why
  pinning a violating holding and solving again gives the optimum. A
  three-asset example needs two floor adjustments before all conditions hold.

- [`adaptive_utility/CHEME-5660-L8b-Advanced-CES-Limits-Fall-2026.ipynb`](adaptive_utility/CHEME-5660-L8b-Advanced-CES-Limits-Fall-2026.ipynb)
  derives the closed-form CES optimum in share counts from the budget-constrained
  Lagrangian, proves its three limits (Cobb–Douglas at unit elasticity,
  concentration on the best bang for the buck as the elasticity grows, equal
  share counts as it vanishes), shows that log-linear utility has the
  Cobb–Douglas optimizer, and records the share-denomination caveat of the CES
  weights.

Both notebooks develop the mathematics without code. The utility allocator example
exercises the same allocators on course data.
