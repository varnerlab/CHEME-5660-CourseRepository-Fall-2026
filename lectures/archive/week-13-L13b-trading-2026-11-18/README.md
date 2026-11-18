# L13b trading material parked on November 18

On November 18, 2026, the instructor made L13b a lecture on the multi-asset synthetic market only. The
trading material left L13b and is parked here for later reuse: the model-predictive controller, its two
examples, and its code.

| Item | Came from |
| --- | --- |
| `CHEME-5660-L13b-Lecture-MPC-Allocation-Fall-2026.ipynb` | A copy of `lectures/week-13/L13b/`, taken before the split. It keeps the controller sections, including the re-plan restructure of November 17. The original stays in place and is edited separately. |
| `CHEME-5660-L13b-Example-MPC-RealData-Fall-2026.ipynb` | `lectures/week-13/L13b/` (moved). |
| `CHEME-5660-L13b-Example-MPC-SyntheticData-Fall-2026.ipynb` | `lectures/week-13/L13b/` (moved). |
| `scripts/fit_generator.jl` | `lectures/week-13/L13b/scripts/` (moved). It fits the synthetic-market generator that the synthetic-data example loads. |
| `data/MPC-SyntheticGenerator-2014-2024.jld2` and `data/MPC-SyntheticGenerator-2014-2024-summary.toml` | `lectures/week-13/L13b/data/` (moved). They are the fitted generator and its summary. |
| `data/pretrained-jumphmm-market-surrogate.jld2` | `lectures/week-13/L13b/data/` (moved). It is the SPY model that `fit_generator.jl` reads. |
| `environment/mpc/Synthetic.jl` | `code/src/mpc/Synthetic.jl` (removed from the course package). It holds the generator fit, the stress and typical path sets, and the runner for one synthetic path. |
| `environment/mpc/test_synthetic.jl` | `code/test/mpc/test_synthetic.jl` (removed from the package tests). |

The rest of `code/src/mpc` stays in the course package. `environment/mpc/` is a copy of that folder
from before the change.

The figures, the figure data, and the two JumpHMM data files in `lectures/week-13/L13b/` stay in place,
because the lecture, the deck, or the sector factor example still uses them.

## Running the parked material

Everything here runs on JumpHMM.jl 0.4.1 (commit `e5821a8`). The course package is switching to JumpHMM.jl
0.5.0, which renames every type and has no compatibility layer, so the parked code does not run on it.
`environment/Project.toml` and `environment/Manifest.toml` are the root course environment from before the
switch. To reuse the material, restore the files to their original folders and use that environment
together with `environment/mpc/Synthetic.jl` and the `include` and `export` lines for it in
`code/src/mpc/MPCPortfolio.jl`, or port the code to JumpHMM.jl 0.5.0.

Relative links in the notebooks assume their original location.
