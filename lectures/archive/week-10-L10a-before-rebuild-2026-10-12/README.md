# L10a before the October 2026 rebuild

On October 11, 2026, a Codex session updated the L10a lecture and both examples. That work was
never committed. On October 12, the instructor found the lecture poorly organized and below the
rigor of the other notebooks, with no company profile. It was rated 5/10: it kept 32 of its 125
prose sentences from his Fall-2025 L11a lecture. L10a was rebuilt from that 2025 text. The design
is in `lectures/instructor/L10a-REBUILD-SPEC.md`. This snapshot holds the files the rebuild
replaced, and `SHA256SUMS` records them. The hashes match the Codex handoff.

| File | Status |
| --- | --- |
| `week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-Greeks-Fall-2026.ipynb` | Retired. The rebuilt lecture keeps this file name. Its Leisen–Reimer, central-difference, and BSM-Greek material moved to `week-10/L10a/advanced/numerical_greeks/`. |
| `week-10/L10a/CHEME-5660-L10a-Example-Greeks-PutCall-NVDA-Fall-2026.ipynb` | Retired. Rebuilt on the end-of-day options archive as `…-Example-Greeks-PutCall-Fall-2026.ipynb`. Its CRR/Leisen–Reimer convergence study moved to the advanced notebook. |
| `week-10/L10a/CHEME-5660-L10a-Example-POE-POP-TSLA-Call-Fall-2026.ipynb` | Retired. Rebuilt on the archive as `…-Example-POE-POP-Call-Fall-2026.ipynb`. |
| `L10a-GREEKS-REVIEW-HANDOFF.md` | The Codex handoff for these files, copied here. The original stays in `lectures/instructor/`. |

The package code from the same session (`code/src/BinomialSensitivities.jl`, `binomial_premium`
and `binomial_greeks`) is kept and used by the rebuilt notebooks. The instructor asked that cut
material not move into a later week. To reuse a file, move it out with `git mv` rather than
editing it here.

The two figures the rebuild no longer uses are kept here too:
`week-10/L10a/figs/CHEME-5660-L9b-Example-NVDA-ExtrinsicValue-Fall-2025.svg` (the 2025 Concept
Review plot, replaced by the 2026 L9b example's figure) and
`week-10/L10a/figs/Fig-TSLA-Option-Data-11-3-2025.png` (the 2025 TSLA quote screenshot; the
POE/POP example now reads the archive).
