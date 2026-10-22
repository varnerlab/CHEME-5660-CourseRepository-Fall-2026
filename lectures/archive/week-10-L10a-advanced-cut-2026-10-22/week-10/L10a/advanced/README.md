# L10a optional advanced material

This folder holds one optional notebook, with code. It uses the L10a `Include.jl`
two folders up and the course's end-of-day options archive.

- [`numerical_greeks/CHEME-5660-L10a-Advanced-Numerical-Greeks-Fall-2026.ipynb`](numerical_greeks/CHEME-5660-L10a-Advanced-Numerical-Greeks-Fall-2026.ipynb)
  asks how accurate Greeks computed by repricing a binomial tree are, and when a
  different tree helps. For an at-the-money European call, it compares
  central-difference Greeks on the Cox, Ross, Rubinstein (CRR) tree with the
  Black–Scholes–Merton values. The CRR premium is a straight line in the share
  price between corners, so a step $\epsilon$ that stays between two corners gives a
  Gamma of zero, and the errors change between even and odd numbers of tree
  steps. It then builds the Leisen–Reimer tree by hand from the Peizer–Pratt
  inversion, checks the risk-neutral condition $qu+(1-q)d=e^{g_{y}\Delta t}$, and
  shows that its Greeks match the formulas at every number of tree steps. Finally,
  it refines the Leisen–Reimer tree for an American put, finds the early-exercise
  boundary by bisection, and plots Delta and Gamma against the share price.
