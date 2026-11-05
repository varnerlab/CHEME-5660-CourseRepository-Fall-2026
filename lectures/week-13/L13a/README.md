# L13a — Synthetic Markets with Jump Hidden Markov Models

L13a builds synthetic markets for stress tests. It reviews Markov chains and hidden Markov
models, builds the JumpHMM generator for one asset (SPY), and extends it to many assets with
the sector factor model (market + sector + own draws, no copula). The generator comes from
`JumpHMM.jl` (version 0.2.0, pinned in the root environment); notebooks import it as
`import JumpHMM` and call it qualified (`JumpHMM.fit`, `JumpHMM.tune`, `JumpHMM.simulate`).

The slides in `slides/` are the student companion to the lecture notebook. The 2025 Markov and
hidden Markov lecture and its examples remain in `advanced/markov/` as optional background.
