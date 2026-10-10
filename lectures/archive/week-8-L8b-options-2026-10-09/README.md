# L8b options material, archived October 9, 2026

L7b is retaught in L8b on October 15, 2026, so options no longer start in L8b.
L9a (October 20) now introduces derivatives and prices European options. The
redesign is recorded in `lectures/instructor/L9a-REDESIGN-SPEC.md`. This snapshot
is the L8b options folder as of commit `bcfcfc5`. `SHA256SUMS` records its tracked
files.

| File | Status |
| --- | --- |
| `CHEME-5660-L8b-Lecture-IntroductionToDerivativesContracts-Fall-2026.ipynb` | Retired. The new L9a lecture is assembled from the instructor's Fall-2025 text instead. |
| `CHEME-5660-L8b-Example-SingleContractPayoffProfit-Fall-2026.ipynb` | Moved to L9a as its first example (October 2026). |
| `CHEME-5660-L8b-Example-CompositeContractsPL-Fall-2026.ipynb` | Retired. L10b teaches composite contracts. |
| `advanced/static_replication/` | Retired. The composite positions it extends left the lecture. |
| `figs/` | `Fig-Options-Contracts-Fall-2024.png` (his raster) and the L8b TikZ remake are the sources of L9a's `Fig-L9a-Contract-Right-Obligation`. Both stay here. |
| `slides/` | The L8b deck. Its derivative and payoff frames are planned as a source for the rebuilt L9a deck. |
| `Include.jl` | The setup file the archived notebooks load. |

The instructor asked that cut material not move into a later week. Relative links
in these notebooks assume their original location. To reuse a file, move it out
with `git mv` rather than editing it here. Do not rewrite this archival payload.
