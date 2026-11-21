# L14a figures

| Figure | Shown in |
|---|---|
| `Fig-L13b-JumpHMM-Schematic` | The review, copied from `week-13/L13b/figs` so the week-14 bundle carries it. One simulated day of the jump hidden Markov model. |
| `Fig-L14a-EWLS-JPM` | Updating the Single Index Model, after the opening paragraph (width 740). The market sensitivity of `JPM` over 2025 and 2026: the fixed 2014 to 2024 estimate (1.11, dashed) and the EWLS estimate updated each trading day ($\phi = 2^{-1/63}$, $N_0 = 63$), which ends at 0.76 on November 13, 2026. Drawn from the example's Task 1 (`MPC.calibrate` and `MPC.online_sim`, run 2026-11-20); the 469 daily values are written into the `.tex` file. |
| `Fig-L14a-Gamma-Picks` | Preference Weights with Updated Estimates, after the opening paragraph (width 860). One time axis: a made-up path of $\xi_t$ (red falling, blue rising), a dot for each daily update of $\alpha_i$, $\beta_i$, $\gamma_i$, and the γ baskets held between pick days. Most baskets last 21 trading days; basket 2 lasts 15, cut short by the first turn; at a market turn (orange line) the method picks a new basket and the 21-day count restarts, as in `pick_days` (`src/Helper.jl`). |
| `Fig-L14a-Market-Hedge` | The Market Hedge, after the opening paragraph (width 720). The limit $\max(1-\xi_t, -0.5)$ on $\beta_P(t)$ against $\xi_t$: limit 1 (`SPY`) at $\xi_t = 0$, limit 0 (betting against beta) at $\xi_t = 1$, the `SPY` short below zero, the floor at −0.5, and the band $|\xi_t| \leq 1$ (99% of training days). |
| `Fig-L14a-PaperTrading-Schematic` | Paper Trading with Alpaca, after the MCP server paragraph (width 1000). Top: the AI assistant on a laptop sends a tool call to the MCP server (three of its tools), which holds the key and secret and sends an API request to the Alpaca paper account; the paper account fills orders against the latest quotes (IEX), and the order status and result come back. Bottom: the life of an order (`new`, `partially_filled`, `filled`, `canceled`, `rejected`). |

From this folder, `make` builds each figure's PDF (deck), themed SVG (notebook), and PNG (preview) with
XeLaTeX, `pdf2svg`, and `pdftoppm`. Each figure `\input`s `schematic-style.tex`, a copy of the
L13a style, and `theme_svg.py` adds the dark screen palette; an unmapped color fails the build.
