# L14a figures

| Figure | Shown in |
|---|---|
| `Fig-L13b-JumpHMM-Schematic` | The review, after its opening sentence, copied from `week-13/L13b/figs` so the week-14 bundle carries it. One simulated day of the jump hidden Markov model. |
| `Fig-L14a-EWLS-JPM` | Paper Trading with Alpaca, at the end of the section, in the closing question (width 740). The market sensitivity of `JPM` over 2025 and 2026: the fixed 2014 to 2024 estimate (1.11, dashed) and the EWLS estimate updated each trading day ($\phi = 2^{-1/63}$, $N_0 = 63$), which ends at 0.76 on November 13, 2026. Drawn from the example's Task 1 (`MPC.calibrate` and `MPC.online_sim`, run 2026-11-20); the 469 daily values are written into the `.tex` file. |
| `Fig-L14a-PaperTrading-Schematic` | Paper Trading with Alpaca, after the opening paragraph (width 1000). Top: the AI assistant on a laptop sends a tool call to the MCP server (three of its tools), which holds the key and secret and sends an API request to the Alpaca paper account; the paper account fills orders against the latest quotes (IEX), and the order status and result come back. |

From this folder, `make` builds each figure's PDF (deck), themed SVG (notebook), and PNG (preview) with
XeLaTeX, `pdf2svg`, and `pdftoppm`. Each figure `\input`s `schematic-style.tex`, a copy of the
L13a style, and `theme_svg.py` adds the dark screen palette; an unmapped color fails the build.
