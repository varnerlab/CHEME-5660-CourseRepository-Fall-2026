# L14a optional advanced material

This folder holds one notebook.

- [`ewls/CHEME-5660-L14a-Derivation-EWLS-Update-Fall-2026.ipynb`](ewls/CHEME-5660-L14a-Derivation-EWLS-Update-Fall-2026.ipynb)
  is the derivation companion to the lecture's section on updating the single index model. It derives the three
  running sums that the exponentially weighted least squares update carries from one trading day to the next,
  solves them for the updated baseline, market sensitivity, and residual standard deviation, and shows how the
  2014 to 2024 fit seeds the sums with the prior weight. It is a derivation notebook with no code. It is adapted
  from the August 2026 draft in `lectures/week-15/L15a/advanced/online_learning/`, with the decay renamed from δ
  to φ, because δ is the sector loading of the sector factor model and η is the CES elasticity of substitution.
