# CHEME 5660: Quantitative Finance for Engineers (Fall 2026)

This course is for engineers and scientists interested in quantitative finance.
It covers financial systems and markets; modeling and simulation of fixed-income
securities, equities, and derivatives; portfolio optimization and hedging; and
the application of artificial intelligence to financial decision-making.

## Getting the course material

There are two ways to use the course materials:

1. **Download the weekly bundle (recommended; no Git required).** On the
   [Releases page](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/releases),
   open the release for the week, expand **Assets**, and download `week-N.zip`,
   where `N` is the week number. Do not download either automatically generated
   **Source code** archive. Published bundles are versioned snapshots;
   corrections are issued as new releases rather than silently replacing files.
2. **Clone the repository (for Git users).** The complete authoring repository is
   available at
   [varnerlab/CHEME-5660-CourseRepository-Fall-2026](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026).
   Current instructional materials are organized under [`lectures/`](lectures/).

Problem sets and the practicum are distributed through separate repositories; see
[Assignments and practicum](#assignments-and-practicum) below.

## One-time setup

The supported environment is Julia 1.12 in VS Code with the Julia and Jupyter
extensions.

1. Install Julia 1.12 with
   [`juliaup`](https://github.com/JuliaLang/juliaup).
2. Install [VS Code](https://code.visualstudio.com/download). Open its Extensions
   view (`Ctrl+Shift+X` on Windows/Linux or `Cmd+Shift+X` on macOS), then find and
   install both official extensions below. Reload VS Code if it asks you to.

   | Search for | Publisher | Extension identifier |
   |---|---|---|
   | [Julia](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia) | julialang | `julialang.language-julia` |
   | [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) | Microsoft | `ms-toolsai.jupyter` |

3. From the repository root or an extracted bundle root—the directory containing
   `Project.toml`—instantiate the course environment and register its Jupyter
   kernel:

   ```bash
   julia scripts/setup.jl
   ```

   The script may spend several minutes downloading and precompiling packages the
   first time. When it finishes, it prints `SETUP-OK` and installs a
   **Julia (CHEME 5660)** kernel that continues to work after Julia updates.
4. Run the package smoke test from the same directory:

   ```bash
   julia --project=. -e 'using VLQuantitativeFinancePackage; println("SETUP-OK")'
   ```

Every lecture notebook begins by loading its meeting-local `Include*.jl`, which
activates the supplied course environment automatically. If VS Code or Jupyter
reports that the course kernel is missing, rerun `julia scripts/setup.jl`, restart
VS Code, and select **Julia (CHEME 5660)** again.

## Opening and running a weekly bundle

Follow this sequence for each new weekly release:

1. **Extract the ZIP completely.** Create a folder for the week somewhere you can
   keep and edit it, such as `Documents/CHEME-5660/week-N`, and extract the ZIP
   into that folder. Do not open or run files from inside the ZIP.
2. **Open the bundle, not an individual file.** In VS Code, choose
   **File > Open Folder** and select the extracted folder. The correct folder
   contains `Project.toml`, `Manifest.toml`, `README.md`, `code/`, and `lectures/`.
   Accept the Workspace Trust prompt for this course folder if VS Code displays it.
3. **Prepare this copy of the bundle.** Choose **Terminal > New Terminal** in VS
   Code. Its prompt should be at the bundle root. Run `julia scripts/setup.jl` and
   the package smoke test from [One-time setup](#one-time-setup). Let any package
   downloads or precompilation finish; later starts are much faster.
4. **Open the notebook.** In the Explorer sidebar, expand `lectures`, the current
   `week-N` folder, and the meeting folder (`L1a`, `L1b`, and so on), then open the
   assigned `.ipynb` file.
5. **Select Julia and run from the top.** Click **Select Kernel** in the notebook's
   upper-right corner, choose **Julia (CHEME 5660)**, and execute the cells in
   order with the cell run button or `Shift+Enter`.

Messages about downloading or precompiling packages are normal on the first run.
A tan or yellow informational notice is not a failure by itself; investigate only
if a notebook cell reports an error or a course test fails.

## Weekly materials

The links below point to the current source materials. Use the
[Releases page](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/releases)
for published student bundles.

| Week | Topic | Materials |
|---:|---|---|
| 1 | Course orientation, money flows, time value of money, and net present value | [Week 1](lectures/week-1/) |
| 2 | Treasury securities, yield, duration, convexity, and the yield curve | [Week 2](lectures/week-2/) |
| 3 | Equity-market growth rates and price lattices | [Week 3](lectures/week-3/) |
| 4 | Lattice trading rules and geometric Brownian motion | [Week 4](lectures/week-4/) |
| 5 | Multivariate GBM, portfolio weights, and mean-variance allocation | [Week 5](lectures/week-5/) |
| 6 | Single-index models and risky/risk-free allocation | [Week 6](lectures/week-6/) |
| 7 | Utility-based allocation and adaptive portfolio rebalancing | [Week 7](lectures/week-7/) |
| 8 | Option contracts: call and put payoff and profit | [Week 8](lectures/week-8/) |
| 9 | European and American option pricing | [Week 9](lectures/week-9/) |
| 10 | Option sensitivities, probability of profit, composite contracts, and delta hedging | [Week 10](lectures/week-10/) |
| 11 | Covered calls, cash-secured puts, protective collars, and defined-outcome ETFs | [Week 11](lectures/week-11/) |
| 12 | Stochastic multi-armed bandits and binary ticker selection | [Week 12](lectures/week-12/) |
| 13 | Maximum-utility allocation, adaptive rebalancing, and market crashes | [Week 13](lectures/week-13/) |
| 14 | Building and testing the course Autotrader | [Week 14](lectures/week-14/) |
| 15 | Autotrader laboratory, final trading challenge, and course synthesis | [Week 15](lectures/week-15/) |

## Course environment and library

The course uses one Julia 1.12 environment at the repository or extracted-bundle
root. `Project.toml` and `Manifest.toml` pin the dependencies, including the
semester snapshot of `VLQuantitativeFinancePackage` vendored under
[`code/`](code/). No remote course package or Julia registry is needed during
class.

Every notebook loads its meeting-local `Include*.jl`, which activates the supplied
root environment and imports the code needed for that meeting. After the one-time
setup, notebooks can be run directly. The
[course library documentation](https://varnerlab.github.io/CHEME-5660-CourseRepository-Fall-2026/)
describes the reusable types and quantitative-finance routines. The semester
snapshot is developed in the
[upstream package repository](https://github.com/varnerlab/VLQuantitativeFinancePackage.jl).

## Assignments and practicum

Problem sets, the practicum, and their solutions are managed in separate
repositories rather than this course-content repository. Assignment links and
release instructions will be distributed through the course communication
channels. GitHub Desktop is the supported way to obtain those repositories without
using Git from a terminal.

## License and disclaimer

Course materials are provided under the [MIT License](LICENSE).

This material is offered solely for training and informational purposes. No
investment advice is given or implied. See the full disclaimer in each lecture.
