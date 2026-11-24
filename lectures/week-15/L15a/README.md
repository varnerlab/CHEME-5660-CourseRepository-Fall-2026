# L15a — Autotrader diagnostics, risk controls, and validation

The lecture opens with updating the single index model, moved here from L14a on 2026-11-23:
- the daily EWLS update;
- a short extension on updating the general factor model;
- the preference weights with updated estimates;
- the market hedge;
- the comparison with betting against beta.

The validation sections have not been reviewed since the move.

- [`CHEME-5660-L15a-Lecture-Autotrader-Validation-Fall-2026.ipynb`](CHEME-5660-L15a-Lecture-Autotrader-Validation-Fall-2026.ipynb)
- [`CHEME-5660-L15a-Example-Updating-SIM-Gamma-Fall-2026.ipynb`](CHEME-5660-L15a-Example-Updating-SIM-Gamma-Fall-2026.ipynb)
  updates the single index model of every stock with each trading day of 2025 and 2026, and picks the
  preference basket. It uses `src/Helper.jl` (`pick_days`, `gamma_basket`).
- [`CHEME-5660-L15a-Example-Validation-Gates-Fall-2026.ipynb`](CHEME-5660-L15a-Example-Validation-Gates-Fall-2026.ipynb)
- [`advanced/`](advanced/) holds the EWLS derivation and the policy-gradient derivation.
- [`figs/`](figs/) holds the three figures of the updating section, with their sources.
- `slides/frames-from-L14a.tex` holds the deck frames removed from L14a, staged for the L15a deck. It is
  not built.

The old EWLS replay example and EWLS recursion notebook are in
`lectures/archive/week-15-L15a-before-move-2026-11-23/`.
