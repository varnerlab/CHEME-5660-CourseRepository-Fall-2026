# CHEME 5660: Quantitative Finance for Engineers (Fall 2026)

This course is for engineers and scientists interested in quantitative finance.
It covers financial systems and markets; modeling and simulation of fixed-income
securities, equities, and derivatives; portfolio optimization and hedging; and
the application of artificial intelligence to financial decision-making.

## Course essentials

Start here for the course expectations and semester plan. Then continue below
for materials, installation, and weekly notebooks.

| Document | What you will find |
|---|---|
| **[Course syllabus](https://cornell.box.com/s/boxou8voal3ctaecouzwue8f4dfqq39b)** | Policies, grading, expectations, and course logistics |
| **[Fall 2026 schedule](https://cornell.box.com/s/oztxiu2cc7oh4gos9snt2wbqdt7kk885)** | Lecture sequence, weekly topics, and important dates |
| **[Course FAQ](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/)** | Search worked answers by theme, with links to lecture notes |
| **[Notation reference](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html)** | Living lecture-by-lecture index of symbols, meanings, and units, updated as each lecture is finalized |

## Getting the course material

There are two ways to use the course materials:

1. **Download the weekly bundle (recommended; no Git required).** On the
   [Releases page](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/releases),
   open the release for the week, expand **Assets**, and download the versioned
   `CHEME-5660-Fall-2026-Week-NN.R.zip` asset (`NN` is the zero-padded week and
   `R` is the revision). Do not download either automatically generated **Source
   code** archive. Published bundles are versioned snapshots; corrections are
   issued as new revisions rather than silently replacing files.
   Starting with week 5, a week's materials are released one class meeting at a
   time, and the revision tells you how many meetings the bundle contains: `.0`
   is Tuesday's meeting only, and `.1` is the complete week. Every release
   contains everything in the earlier ones, so always download the most recent
   release for the week. Corrections ship with the next release.
2. **Clone the repository (for Git users).** The complete authoring repository is
   available at
   [varnerlab/CHEME-5660-CourseRepository-Fall-2026](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026).
   Current instructional materials are organized under [`lectures/`](lectures/).

Problem sets and the practicum are distributed through separate repositories; see
[Problem sets and practicum](#problem-sets-and-practicum) below.

## Running course reference

The [course FAQ](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/)
groups conceptual questions by theme and gives a short answer before each worked
explanation. It grows as the course develops new conceptual questions.

The [notation reference](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/notation.html)
is the living lecture-by-lecture index of symbols, meanings, units, and reused
notation. We update it as each lecture is finalized.

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
| 5 | Single-asset GBM, out-of-sample NPV predictions, and multiple-asset GBM with portfolio weights | [Week 5](lectures/week-5/) |
| 6 | Single-index models and risky/risk-free allocation | [Week 6](lectures/week-6/) |
| 7 | SIM portfolios with a risk-free asset and utility-based allocation | [Week 7](lectures/week-7/) |
| 8 | Option contracts: call and put payoff and profit | [Week 8](lectures/week-8/) |
| 9 | Derivatives, options, and European and American pricing | [Week 9](lectures/week-9/) |
| 10 | Option sensitivities, probability of profit, composite contracts, and delta hedging | [Week 10](lectures/week-10/) |
| 11 | Composite contracts, covered calls, protective collars, and defined-outcome ETFs | [Week 11](lectures/week-11/) |
| 12 | Agent-based markets: the minority game, the Farmer–Joshi model, and market crashes in Wolfram markets | [Week 12](lectures/week-12/) |
| 13 | Synthetic markets with jump hidden Markov models; interpretable allocation and model-predictive rebalancing | [Week 13](lectures/week-13/) |
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

## Problem sets and practicum

The problem sets ask students to build, test, and interpret quantitative-finance
models using supplied data and reproducible computational workflows. Each problem
set offers Standard and Advanced tracks and is maintained in its own public
repository.

| Problem set | Question and scope |
|---:|---|
| [PS1](https://github.com/varnerlab/PS1-CHEME-5660-Fall-2026) | Value Treasury securities, measure interest-rate risk, and compare strategies for funding a future obligation. |
| [PS2](https://github.com/varnerlab/PS2-CHEME-5660-Fall-2026) | Use binomial lattices and geometric Brownian motion to estimate the probability that an equity investment beats a benchmark, then compare the forecast with out-of-sample outcomes. |
| [PS3](https://github.com/varnerlab/PS3-CHEME-4660-5660-Fall-2026) | Build minimum-variance portfolios, test the effects of estimation windows and short positions, and compare model predictions with forward performance. |
| [PS4](https://github.com/varnerlab/PS4-CHEME-4660-5660-Fall-2026) | Replay historical option trades to test whether selling premium pays, what protection costs, and how modeled probabilities compare with realized outcomes. |
| [PS5](https://github.com/varnerlab/PS5-CHEME-4660-5660-Fall-2026) | Simulate and replay covered-call and collar funds to determine whether they beat holding their shares and what upside or downside protection they exchange. |

The course culminates in practicum projects in which students build live,
real-time paper-trading systems. In the Fall 2026 offering, students use Alpaca
Markets to forward-test equity or derivative strategies with live market data.

## License and disclaimer

Course materials are provided under the [MIT License](LICENSE).

This material is offered solely for training and informational purposes. No
investment advice is given or implied. See the full disclaimer in each lecture.
