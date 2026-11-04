# Archive: L12b bandit material (Fall 2026, archived 2026-11-04)

Week 12 was redesigned on 2026-11-03 (see the week-12 section of AGENTS.md): bandits left the main path, and
L12b became the INFORMS 2026 model-predictive portfolio lecture. This folder keeps the L12b material it replaced,
unchanged, as it stood in `lectures/week-12/L12b/`:

- `CHEME-5660-L12b-Lecture-BinaryBanditProblems-Fall-2026.ipynb`: the binary bandit lecture.
- `CHEME-5660-L12b-Example-BBBP-Ticker-Picker-Fall-2026.ipynb`: the Bernoulli bandit ticker-picker example.
- `CHEME-5660-L12b-Example-HMM-SPY-OoS-Fall-2026-Project.ipynb` and `data/HMM-WJ-SPY-daily-aggregate.jld2`: the
  out-of-sample HMM example for SPY. The instructor decides whether it returns as optional material in
  `lectures/week-12/L12a/advanced/`, next to the 2025 Markov material.
- `md/`: the Fall 2025 Markdown exports of these notebooks.
- `figs/`: the bandit and reinforcement-learning figures the lecture used.
- `Include.jl`: a copy of the L12b setup file at the time of archiving, so the notebooks can be opened from here.

The L12b Notes (`docs/`) were deleted, not archived: per-lecture Notes were retired in favor of slides on
2026-11-03. `data/JumpHMM-SectorFactor-Universe-2014-2024.jld2` was removed from L12b; the original stays in
`lectures/week-12/L12a/data/`, and L12b now uses the full-universe generator.
