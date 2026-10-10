# L8b optional advanced material

This standalone notebook extends the L8b treatment of composite option contracts.
It is optional and is not a prerequisite for L9a.

- [`static_replication/CHEME-5660-L8b-Advanced-Static-Replication-Fall-2026.ipynb`](static_replication/CHEME-5660-L8b-Advanced-Static-Replication-Fall-2026.ipynb)
  proves the converse of the lecture's composite rule. The lecture shows that
  adding legs produces piecewise-linear payoffs; this notebook shows that every
  continuous piecewise-linear payoff with kinks at `0 < K_1 < ... < K_d` has
  exactly one representation as cash, shares, and calls struck at those kinks,
  with each call weight equal to the jump in slope at its strike. It proves
  existence by a telescoping sum of interval slopes and uniqueness by sweeping
  outward from the leftmost interval, derives the put payoff identity (put-call
  parity in payoff space, with the pricing step deferred to L9a), tabulates the
  decomposition of the vertical spread, straddle, strangle, butterfly, covered
  call, and collar, recovers a weight from three payoff evaluations by the
  normalized second difference, and delimits the reachable set: curved payoffs
  and discontinuous payoffs are out of reach for a finite static portfolio at a
  single expiration, and the hypothesis `K_1 > 0` is load-bearing because a call
  struck at zero is the share.

It is a derivation notebook with no code; the L8b examples compute the payoff and
profit of these same structures on a real options chain through the package
functions `payoff` and `profit`.
