# CHEME 5660: Quantitative Finance for Engineers (Fall 2026)

This course is for engineers and scientists interested in quantitative finance. It covers financial systems and markets; modeling and simulation of fixed-income securities, equities, and derivatives; portfolio optimization and hedging; and the application of artificial intelligence to financial decision-making.

## Two ways to get the material
1. **Download this week's bundle (recommended, no git needed):** grab `week-N.zip` from the [Releases page](../../releases), unzip it, and open the notebooks inside `lectures/week-N/`.
2. **Clone the repository** (git users): everything lives here; released weeks are frozen — fixes are announced on Ed, never silently rewritten.

## One-time setup
1. Install Julia **1.12.x** via [juliaup](https://github.com/JuliaLang/juliaup), [Anaconda](https://www.anaconda.com) (for Jupyter), and [VS Code](https://code.visualstudio.com) with the Julia extension.
2. In a terminal, from this folder (repo root or unzipped bundle root):
   `julia --project=. -e 'using Pkg; Pkg.instantiate()'`  *(one time; several minutes)*
3. Smoke test: `julia --project=. -e 'using VLQuantitativeFinancePackage; println("SETUP-OK")'`

Every lecture notebook begins by including its `Include*.jl` setup file, which activates this environment automatically — after the one-time setup, notebooks just run.

## Weekly materials
| Week | Topic | Notebooks | Notes | Download |
|:----:|:------|:----------|:------|:---------|
| 1 | Time value of money, abstract assets, NPV | [`lectures/week-1`](lectures/week-1) | *coming with the week-1 release* | `week-1.zip` from [Releases](../../releases) |

*(Rows added as weeks are released.)*

## The course package
The course's Julia package, `VLQuantitativeFinancePackage`, is vendored in [`code/`](code/) and version-frozen for the semester. Its API documentation and the upstream repo: [VLQuantitativeFinancePackage.jl](https://github.com/varnerlab/VLQuantitativeFinancePackage.jl).

## Disclaimer
This material is offered solely for training and informational purposes. No investment advice is given or implied. See the full disclaimer in each lecture.
