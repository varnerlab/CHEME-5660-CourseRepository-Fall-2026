#!/usr/bin/env python3
"""Write the seeded samples behind Fig-L5b-Covariance-Schematic (standard library only).

Each Base file holds 400 draws from a bivariate normal with covariance
[[1, rho], [rho, 1]] for rho = -0.6, 0, 0.6; the Scaled file uses four times
that covariance, so both standard deviations double and the correlation is
unchanged. Rerun with `make data`; the seed keeps the figure reproducible.
"""

import math
import random

random.seed(5660)
N = 400
for tag, rho in (("Negative", -0.6), ("Zero", 0.0), ("Positive", 0.6)):
    # Cholesky factor of [[1, rho], [rho, 1]]
    L21, L22 = rho, math.sqrt(1 - rho**2)
    for scale, suffix in ((1.0, "Base"), (2.0, "Scaled")):
        with open(f"Data-L5b-Cov-{tag}-{suffix}.csv", "w") as f:
            f.write("x1,x2\n")
            for _ in range(N):
                z1, z2 = random.gauss(0, 1), random.gauss(0, 1)
                f.write(f"{scale * z1:.4f},{scale * (L21 * z1 + L22 * z2):.4f}\n")
