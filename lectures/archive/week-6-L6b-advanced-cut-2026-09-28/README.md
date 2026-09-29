# L6b advanced notebooks cut on September 28

The instructor cut the L6b optional advanced material from five notebooks to
two on September 28, 2026. The two kept notebooks are the residual diagnostics
and estimation-risk notebooks in `lectures/week-6/L6b/advanced/`. This snapshot
preserves the three that were removed, byte for byte as of source commit
`9ccb147`:

| Notebook | Why it was cut |
| --- | --- |
| `data-risk-free/` Data-driven portfolios with a risk-free asset | Tasks 1 and 3 repeat the L6a data-driven example. The RRFA example already finds the data-driven tangent portfolio. |
| `sim/` SIM estimation theory (markdown only) | The lecture and the kept notebooks cover the bootstraps, propagation, and SIM covariance. No L6b notebook uses the ridge estimator or the cone program. |
| `uncertainty/` SIM parameter uncertainty in portfolios | Its GMV result is a modest spread. The estimation-risk notebook shows the larger tangent-weight sensitivity. |

`week-6/L6b/advanced/README.md` is the five-notebook index as it stood before
the cut. `SHA256SUMS` records every payload file, and `environment/` holds the
root Julia environment at the source commit.

Relative links in the notebooks assume their original location. To reuse one,
restore it to `lectures/week-6/L6b/advanced/` rather than editing it here. Do
not rewrite this archival payload.
