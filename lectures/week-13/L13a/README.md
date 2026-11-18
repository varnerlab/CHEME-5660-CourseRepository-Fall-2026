# L13a — Synthetic Markets with Jump Hidden Markov Models

L13a builds synthetic markets for stress tests. It reviews Markov chains and hidden Markov
models, and builds the JumpHMM generator for one asset (SPY). The extension to many assets (the sector
factor model and its example) moved to L13b on November 17, 2026. The generator comes from
`JumpHMM.jl` (version 0.5.0, pinned in the root environment); notebooks import it as
`import JumpHMM` and call it qualified (`JumpHMM.build`, `JumpHMM.tune`, `JumpHMM.simulate`).

The slides in `slides/` are the student companion to the lecture notebook. The 2025 Markov and
hidden Markov lecture and its examples remain in `advanced/markov/` as optional background.
