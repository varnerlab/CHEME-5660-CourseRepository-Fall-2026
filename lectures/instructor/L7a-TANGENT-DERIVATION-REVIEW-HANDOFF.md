# L7a tangent derivation companion — polish round record

Notebook: [CHEME-5660-L7a-Derivation-Tangent-Fall-2026.ipynb](../week-7/L7a/advanced/tangent-derivation/CHEME-5660-L7a-Derivation-Tangent-Fall-2026.ipynb)

On October 2, 2026, the instructor asked for a polish, voice, and organization
pass if the companion scored below 9.0. It opened at 8.9, which matched
Codex's independent 8.9. A one-step, markdown-only round was approved ("Agree.
Update. Next") and closed at 9.1 (Codex 9.0). This was the instructor's first
review of the draft written on September 30. The instructor marked the
companion reviewed the same day. Changes are uncommitted.

## Scores

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 9.5 | 9.6 |
| Organization | 9.2 | 9.2 |
| Narrative and voice | 8.5 | 9.0 |
| Presentation | 8.7 | 9.0 |
| Density | 9.0 | 9.0 |
| **Overall** | **8.9** | **9.1** |

## Accepted edits (seven lines, net +12 words)

1. Cell 1 now says why the means must differ: "…not all equal, so the risky
   frontier has two branches and $\mathbf{e}\neq\mathbf{0}$." Cell 3's
   upper- and lower-branch cases depend on this.
2. Cell 2 names "the L6a GMV derivation", since that notebook is not in the
   Week 7 bundle. The first reason in the λ display now reads "substitute the
   gradient" instead of repeating its lead-in.
3. Cell 4 cut "With daily growth-rate data, it is a one-day Sharpe ratio, as
   in the lecture." The lecture's "Which Sharpe ratio?" note keeps the fact.
4. Cell 5 explains the move from the lecture's floor to an exact target: "At
   the minimum, the lecture's growth floor binds, since scaling the weights
   down lowers the variance."
5. Cell 5 merges the two "This is…" sentences: "…The target changes only the
   split between the risk-free asset and the tangent portfolio, as two-fund
   separation says."
6. Cell 5's long-only note now says "every feasible target above $g_f$". A
   target is feasible long-only only if some asset has positive excess growth.

The objectives, takeaways, and all boxed results are unchanged.

## Checks

- Numerical checks on random four-asset problems, with GMV growth above and
  below $g_f$:
  - the tangent weights attain the Cauchy–Schwarz bound;
  - the negative-denominator formula gives the minimum Sharpe ratio, and no
    fully invested portfolio reaches the bound;
  - the risky fraction and minimum variance match a direct solve.
  Codex repeated these checks with SymPy, NumPy, and an independent KKT solve.
- All 14 displays pass KaTeX. The VS Code renderer showed no errors. Links
  resolve within Week 7. The notebook validates with nbformat, and its
  metadata is unchanged.
- Final SHA-256
  `c57527d25482fece7229f5b83647bedb3da4fa98436719eee503f044573d2879`.

## Declined

- Codex's takeaway rewrite to claim labels with every sentence starting
  "We…". The approved L6a GMV and target-growth companions use noun-phrase
  labels in the same register.
- Codex's rewrite of the standard disclaimer sentence (29 words). It is shared
  boilerplate across all course notebooks.

## Note

The L6b copy, `lectures/week-6/L6b/advanced/tangent-derivation/`, shipped in
week-06.2 and still has the pre-round text. It is now behind the L7a copy.
