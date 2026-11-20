# L14a figures

| Figure | Shown in |
|---|---|
| `Fig-L13b-JumpHMM-Schematic` | The review, copied from `week-13/L13b/figs` so the week-14 bundle carries it. One simulated day of the jump hidden Markov model. |
| `Fig-L14a-PaperTrading-Schematic` | Paper Trading with Alpaca, after the MCP server paragraph (width 1000). Top: the AI assistant on a laptop sends a tool call to the MCP server (three of its eleven tools), which holds the key and secret and sends an API request to the Alpaca paper account; the paper account fills orders against the latest quotes (IEX), and the order status and result come back. Bottom: the life of an order (`new`, `partially_filled`, `filled`, `canceled`, `rejected`). |

From this folder, `make` builds the PDF (deck), themed SVG (notebook), and PNG (preview) with
XeLaTeX, `pdf2svg`, and `pdftoppm`. The figure `\input`s `schematic-style.tex`, a copy of the
L13a style, and `theme_svg.py` adds the dark screen palette; an unmapped color fails the build.
