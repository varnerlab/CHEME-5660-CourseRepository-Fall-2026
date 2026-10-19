# L9b optional advanced material

This folder holds one optional notebook, a derivation with no code.

- [`crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb`](crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb)
  asks where the Cox, Ross, Rubinstein (CRR) up and down factors come from. It
  writes the one-step growth rate of a binomial lattice as a two-point random
  variable and matches its mean and variance to those of geometric Brownian
  motion. With the symmetric condition $ud=1$, keeping the leading term gives
  $u=e^{\sigma\sqrt{\Delta t}}$ and $d=e^{-\sigma\sqrt{\Delta t}}$, and an up
  probability that approaches one half as the time step shrinks. The notebook
  then expands the risk-neutral probability $q$ and shows that, for a small time
  step, the lattice matches the mean growth rate $g_{y}-\sigma^{2}/2$ and the
  variance under the pricing rule. It closes with the step-size condition
  $\lvert g_{y}\rvert\sqrt{\Delta t}<\sigma$ that keeps $0<q<1$.
