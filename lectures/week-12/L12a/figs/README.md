# L12a figures

Two TikZ schematics, added November 5, 2026 at the instructor's request (his NSF-proposal minority
game figure was the starting point), using the L11b pipeline (`theme_svg.py`, `Makefile`) with a
shared style file, `abm-diagram.tex`.

| Figure | Shown in |
|---|---|
| `Fig-L12a-ABM-Structure` | The Structure of an Agent-Based Model (the five parts as one loop; replaces the bullet list, width 800) |
| `Fig-L12a-MinorityGame` | The Minority Game, end of the section (one round with both feedback paths; the panel with one agent's policy tables was removed November 6; one small table for a single policy, without scores or probabilities, was added November 9, width 740) |
| `Fig-L12a-FarmerJoshi` | The Farmer–Joshi Market, at the start of the section (left: one step of the market; right: the threshold rule of a value investor as three states; panel letters, titles, and the text under the states removed November 6; words added on the exit arrows November 10; a signal axis with example thresholds added below the states November 10, cropped out of the deck; width 910) |
| `Fig-L12a-MinorityGame-Results` | Deck only, The Phase Diagram and The Effect of Temperature frames; removed from the lecture notebook November 9 (A: phase diagram of the greedy game; B: volatility per agent against the temperature) |
| `Fig-L12a-FarmerJoshi-Results` | Deck only; removed from the lecture notebook November 9 (A: autocorrelation of absolute growth rates vs SPY; B, C: excess kurtosis and lag-1 autocorrelation against the number of trend followers) |

Each `.tex` header records the consistency checks (the highlighted history row, the minority action,
which score rises, the probabilities at T equal to the score gap, and the transitions against
`threshold_position`). From this folder, run `make` to build each PDF (deck; the deck crops the minority game
results into one panel per frame with `trim`) and themed SVG (notebook, width 1000; the notebook no
longer shows the two results figures).

The two results figures are pgfplots charts (shared style `results-plots.tex`) drawn from CSVs
written by `generate_results_data.jl`, which replays the examples' code with seed 5660, so every
point matches the executed notebooks. Rerun it (`julia --project=../../../.. generate_results_data.jl`)
after any change to the examples, then `make`.
