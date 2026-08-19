# L9b optional advanced material

This standalone notebook extends the L9b treatment of the Cox-Ross-Rubinstein lattice.
It is optional and is not required for the main American-versus-European comparison.

- [`crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb`](crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb)
  derives the CRR up and down factors that the lecture quotes. It writes the
  one-step log return as a two-point random variable, uses an equally weighted
  auxiliary proxy to match its variance to the diffusion variance
  `sigma^2 dt`, and shows that the reciprocal choice `ud = 1` yields
  `u = exp(sigma sqrt(dt))`. It is explicit about what the derivation costs:
  `ud = 1` is a normalization convention rather than a consequence of the
  diffusion, the auxiliary weight is not the pricing probability `q`, and the
  pricing variance agrees with the diffusion only to leading order in `dt`, so
  the moment match drops a term of order `dt^2`. It closes
  with the domain of validity, `d < exp(g_y dt) < u`, that the lattice needs for
  `0 < q < 1`.

It is a derivation notebook with no code. L9a supplies the European BSM benchmark;
L9b runs the CRR lattice and measures the value added by American exercise.
