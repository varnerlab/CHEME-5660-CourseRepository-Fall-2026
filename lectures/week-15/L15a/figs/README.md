# L15a figures

| Figure | Shown in |
|---|---|
| `Fig-L15a-EWLS-JPM` | Updating the Single Index Model, after the opening paragraph (width 740). The market sensitivity of `JPM` over 2025 and 2026: the fixed 2014 to 2024 estimate (1.11, dashed) and the EWLS estimate updated each trading day ($\phi = 2^{-1/63}$, $N_0 = 63$), which ends at 0.76 on November 13, 2026. Drawn from the example's Task 1 (`MPC.calibrate` and `MPC.online_sim`, run 2026-11-20); the 469 daily values are written into the `.tex` file. |
| `Fig-L15a-Gamma-Picks` | Preference Weights with Updated Estimates, after the market-state paragraph and before the preference model (width 860). One time axis: a made-up path of $\xi_t$ (red falling, blue rising), a dot for each daily update of $\alpha_i$, $\beta_i$, $\gamma_i$, and the preference baskets held between pick days. Most baskets last 21 trading days; basket 2 lasts 15, cut short by the first turn; at a market turn (orange line) the method picks a new basket and the 21-day count restarts, as in `pick_days` (`src/Helper.jl`). |
| `Fig-L15a-Market-Hedge` | The Market Hedge, after the opening paragraph (width 720). The limit $\max(1-\xi_t, -0.5)$ on $\beta_P(t)$ against $\xi_t$: limit 1 (`SPY`) at $\xi_t = 0$, limit 0 (betting against beta) at $\xi_t = 1$, the `SPY` short below zero, the floor at −0.5, and the band $|\xi_t| \leq 1$ (99% of training days). |

The three figures moved here from `week-14/L14a/figs` on 2026-11-23, with the Updating the Single Index Model section. L14a keeps its own copies of two of them: `Fig-L14a-EWLS-JPM` for its deck, and `Fig-L14a-Gamma-Picks` (copied 2026-11-24) for its "Next time" subsection. Edit the Gamma-Picks copies together.

From this folder, `make` builds each figure's PDF (deck), themed SVG (notebook), and PNG (preview) with
XeLaTeX, `pdf2svg`, and `pdftoppm`. Each figure `\input`s `schematic-style.tex`, a copy of the
L13a style, and `theme_svg.py` adds the dark screen palette; an unmapped color fails the build.
