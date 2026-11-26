# L15a validation-gates example, archived November 26, 2026

The instructor replaced the "Validation and Compliance" section of the L15a lecture with the five gates of the
stress test. The new stress-test example applies the five gates to the saved runs of the strategy menu, so the old
example, which drew its paired results from normal distributions with chosen parameters, is retired.

| File | Came from |
| --- | --- |
| `CHEME-5660-L15a-Example-Validation-Gates-Fall-2026.ipynb` | `lectures/week-15/L15a/` (moved). It built a validation report with five gates and a risk-control configuration from simulated paired results. |

The example calls `evaluate_validation_gates`, which stays in the course package (`code/src/AdaptivePortfolio.jl`).
Relative links assume the notebook's original location in `lectures/week-15/L15a/`. To reuse it, move it back and
run it from that folder, which holds the `Include.jl` it loads.
