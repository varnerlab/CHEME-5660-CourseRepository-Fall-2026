# L7b optional advanced material

This standalone notebook extends the L7b treatment of online single index
model estimation. It is optional and is not a prerequisite for L8b.

- [`online_learning/CHEME-5660-L7b-Advanced-EWLS-Recursion-Fall-2026.ipynb`](online_learning/CHEME-5660-L7b-Advanced-EWLS-Recursion-Fall-2026.ipynb)
  derives the exponentially weighted least squares recursion from the weighted
  normal equations: the three running moments and why they are sufficient, the
  one-step decayed-plus-rank-one update, the two-by-two solve for the intercept
  and beta, the residual scale from the same moments (with the cancellation at
  the optimum), and the prior seeding, proving that the seeded state returns
  the prior exactly and that the seeded recursion minimizes the data loss plus
  a prior-centered quadratic whose weight decays like the data.

It is a derivation notebook with no code; the L7b examples run the recursion on
course data through the package functions `ewls_init`, `ewls_update!`, and
`ewls_path`.
