# L10a advanced notebook cut on October 22

The instructor removed the L10a optional advanced notebook, Numerical Greeks on
binomial trees, on October 22, 2026. L10a now has no advanced material. His rule:
Black–Scholes–Merton (BSM) is for European contracts only, so material about
American contracts uses no BSM. The notebook could not meet that rule:

| Part | Why it was cut |
| --- | --- |
| Task 1: CRR Greeks for a European call | Measures the tree's Greek errors against the BSM formulas. |
| Task 2: The Leisen–Reimer tree | The tree's probabilities come from the BSM quantities, `q = H(d₋)` and `q′ = H(d₊)`, so BSM is part of its construction, not only a benchmark. |
| Task 3: The Greeks of an American put | Overlays BSM European Delta and Gamma on the American put. |

A BSM-free version would keep one lesson: on the CRR tree, a step `ϵ` smaller
than the spacing between the premium's corners gives a Gamma of zero.

`week-10/L10a/advanced/` is the folder as it stood at the cut, on top of source
commit `0fa5ec1`. It includes that day's uncommitted refactor: the notebook's
functions moved to `numerical_greeks/src/Compute.jl`, loaded by a local
`numerical_greeks/Include.jl`, with outputs re-executed and unchanged.
`SHA256SUMS` records every payload file, and `environment/` holds the root Julia
environment at the cut.

Relative links in the notebook assume its original location. To reuse it,
restore it to `lectures/week-10/L10a/advanced/` rather than editing it here. Do
not rewrite this archival payload.
