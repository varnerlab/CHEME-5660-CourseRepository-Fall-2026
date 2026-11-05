# L12a figures

Two TikZ schematics, added November 5, 2026 at the instructor's request (his NSF-proposal minority
game figure was the starting point), using the L11b pipeline (`theme_svg.py`, `Makefile`) with a
shared style file, `abm-diagram.tex`.

| Figure | Shown in |
|---|---|
| `Fig-L12a-MinorityGame` | The Minority Game, end of the section (A: one round with both feedback paths; B: one agent's two strategy tables, scores, and Boltzmann probabilities) |
| `Fig-L12a-FarmerJoshi` | The Farmer–Joshi Market, before the algorithm (A: one step of the market; B: the threshold rule of a value investor as three states) |

Each `.tex` header records the consistency checks (the highlighted history row, the minority action,
which score rises, the probabilities at T equal to the score gap, and the transitions against
`threshold_position`). From this folder, run `make` to build each PDF (deck; the deck crops one panel
per frame with `trim`) and themed SVG (notebook, width 1000).

The PNG files (`Fig-L12a-PhaseDiagram`, `Fig-L12a-Temperature`, `Fig-L12a-TraderMix`) are executed
outputs of the two examples (seed 5660), used only in the deck.
