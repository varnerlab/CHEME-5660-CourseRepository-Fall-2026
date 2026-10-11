# L9b optional advanced material

This folder holds one optional notebook, a derivation with no code.

- [`crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb`](crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb)
  asks where the Cox, Ross, Rubinstein (CRR) up and down factors come from. It
  writes the one-step log return of a binomial lattice as a two-point random
  variable and matches its variance to the variance of geometric Brownian motion.
  The symmetric condition $ud=1$ and equally likely up and down moves then give
  $u=e^{\sigma\sqrt{\Delta t}}$ and $d=e^{-\sigma\sqrt{\Delta t}}$. The notebook
  closes with how well the match holds when the lattice is priced with the
  risk-neutral probability $q$, and with the step-size condition
  $\lvert g_{y}\rvert\sqrt{\Delta t}<\sigma$ that keeps $0<q<1$.
