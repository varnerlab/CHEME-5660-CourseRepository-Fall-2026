# L15a optional advanced material

- [`ewls/CHEME-5660-L15a-Derivation-EWLS-Update-Fall-2026.ipynb`](ewls/CHEME-5660-L15a-Derivation-EWLS-Update-Fall-2026.ipynb)
  is the derivation companion to the lecture's section on updating the single index model. It writes the
  lecture's EWLS problem as one weighted sum, solves its normal equations for the updated baseline, market
  sensitivity, and residual standard deviation, updates the weighted sums in those equations from one
  trading day to the next, and shows how the 2016 to 2024 fit sets their starting values. It is a
  derivation notebook with no code. It moved here from L14a on 2026-11-23. It was adapted from the August
  2026 draft, now in `lectures/archive/week-15-L15a-before-move-2026-11-23/advanced/online_learning/`, with
  the decay renamed from δ to φ, because δ is the sector loading of the sector factor model and η is the CES
  elasticity of substitution.
- [`online_learning/`](online_learning/) contains the policy-gradient (REINFORCE) derivation.
