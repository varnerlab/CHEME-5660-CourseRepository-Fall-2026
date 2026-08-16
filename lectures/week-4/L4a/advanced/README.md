# L4a optional advanced material

These standalone notebooks extend the L4a discussion of lattice trading rules.
They are optional and are not prerequisites for L4b.

- [`first-passage/CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb`](first-passage/CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb)
  computes exact take-profit and stop-loss first-passage probabilities by
  propagating only the probability mass for positions that remain open.
- [`execution/CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb`](execution/CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb)
  adds the bid–ask spread, fees, and slippage to the terminal
  probability-of-profit calculation.

The first-passage notebook extends the probability model. The execution
notebook extends the cash-flow model. They can be completed independently, but
the suggested order is first passage followed by execution-aware probability.
