# L7b CES limits companion — polish, voice, and organization record

Notebook: [CHEME-5660-L7b-Advanced-CES-Limits-Fall-2026.ipynb](../week-7/L7b/advanced/adaptive_utility/CHEME-5660-L7b-Advanced-CES-Limits-Fall-2026.ipynb)

On October 7, 2026, the instructor asked for "a polish/voice/organization pass"
on this advanced notebook if it scored below 9 out of 10. It opened at 7.7, so
the pass was applied in one round, as in the October 6 L7b lecture pass. The
baseline is HEAD `84d9177` (the notebook last changed in `cef7f2c`), SHA-256
`d2f1f41b50d11feb45ba1c78d9d132fedaeebeda8584ded08eadc3a7b1d87291`. The
notebook is a port of the eCornell S2 derivation
(`eCornell-AI-Finance-S2-Derivation-CES-Limits-May-2026.ipynb`). The model
statement still matches that source and the L7b lecture. The instructor reviewed
the before/after previews and approved the pass the same day ("Agree"). It
was released in week-07.1. The edited notebook's SHA-256 is
`e394aa6ba1a4d009e24a0024570b036afe0b851627a1842646a88be57352c2f9`. Before/after PNGs are in
`build/notebook-previews/L7b-ces-limits-polish-2026-10-07/` (gitignored).

It is a derivation notebook with no code, so it keeps the `##`/`###` outline
and has no Tasks. The reviewed L7a tangent derivation companion set its shape:
a lecture link and a question above the objectives, aligned derivations with a
reason column, and a closing link back to the lecture and example.

## Scores

| Dimension | Initial | Final |
| --- | ---: | ---: |
| Technical correctness | 8.0 | 9.4 |
| Organization | 7.5 | 9.1 |
| Narrative flow and voice | 7.3 | 9.0 |
| Presentation | 7.5 | 9.1 |
| Density and pacing | 8.0 | 9.0 |
| **Overall** | **7.7** | **9.1** |

Codex scored HEAD 8.0, the first draft 8.9, and the final version 9.2.

## Changes

1. **Opening.** The 95-word itinerary, which said "optional" twice, became a
   link to the lecture and one question (40 words, with CES spelled out). The objectives are tighter
   (the 45-word second objective is now 28) and gained the quoted blank line
   after "By the end of this notebook".
2. **The CES problem.** The problem is a box with the net budget and the share
   floor, as in the lecture. $W_{\text{adj}}$ is now defined from the floors on
   the non-preferred set instead of named as "the budget available". The
   multiplier is $\lambda$, as in the lecture's Cobb–Douglas derivation
   (it was $\mu$, the course's GBM drift).
3. **The closed-form optimum.** Five separate displays with prose between them
   became one `align*` derivation with a reason column. The concavity argument
   now comes before the boxed result, and the box matches the lecture's boxed
   CES allocation. A new sentence reads the exponent (the first objective
   promised it). The package mention became a link to the `allocate_ces(...)`
   documentation.
4. **The three limits.** They are now H3s under one "The Three Limits" H2, named
   with the lecture's bullet labels. A two-sentence H2 lead names the lecture's
   concentration dial and maps each limit of $\eta$ to a limit of $\rho$.
   - *Unit elasticity:* the scaling argument says why normalizing the weights
     is harmless ($U_{\text{CES}}$ scales by $c^{1/\rho}$). The unnormalized case
     is stated as two one-sided limits, 0 and ∞. The L'Hôpital steps are an
     `align*`, and the "marginal utility per dollar" sentence was cut,
     since the lecture's derivation already shows that condition.
   - *Large elasticity:* the zero-holdings box is labeled as the case without
     floors (October 3 Codex item 2). The tie sentence became a positive claim,
     "the limit buys equal share counts of the tied assets." The sentence that
     restated the corner box in words was cut.
   - *Small elasticity:* the limit is exactly $\min_i n_i$. The old "up to a
     constant factor" was wrong, because the factor tends to one. A two-line
     argument factors out the smallest share count. The two "not equal dollar"
     denials became "the most expensive share gets the most dollars", plus a
     comparison with the price-weighted Dow Jones Industrial Average.
5. **Log-linear utility.** The section names $U_{\text{CD}}$ (the old text used
   $U$, the CES symbol a section earlier), notes that the lecture maximized
   $\ln U$, and cuts "compared between portfolios of different sizes".
6. **Share prices.** The heading is a claim, "The CES Weights Depend on Share
   Prices". A split multiplies the asset's term by $2^{\eta-1}$, so dollars move
   in for $\eta>1$ and out for $\eta<1$. The hedge "This does not affect the
   lecture's use of CES…" was cut. The dollar-holdings fix is now a result,
   $x_i^\star\propto\gamma_i^\eta$.
7. **Summary.** A two-sentence opener and two-sentence "We…" takeaways. The
   closer links the lecture and the allocator example.
8. **Formatting.** Every display has blank lines around it, there is one cell
   per H3, and `___` appears only before an H2 and at the end of the Summary
   and Disclaimer.

Prose went from 1,277 to 1,164 words (Disclaimer, displays, and link targets
excluded). The notebook went from 10 to 11 markdown cells. The Disclaimer is
unchanged.

## Checks

- nbformat validates, cell ids are kept (one new id, `3b9e1f52`, for the
  limits H2), and the notebook metadata is unchanged.
- Every markdown cell renders through VS Code's KaTeX with zero errors.
- Both relative links resolve, and the `allocate_ces` documentation anchor
  exists on the hosted page (HTTP 200).
- Numerical checks in Python: the closed form satisfies the first-order
  conditions and beats 20,000 random budget-preserving perturbations at four
  elasticities. The checks also cover the $c^{1/\rho}$ scaling, the $0$ and
  $\infty$ one-sided limits without normalization, the Cobb–Douglas limit,
  concentration at large $\eta$ (computed after dividing by $(r^\star)^\eta$,
  since the raw power underflows), equal share counts for tied assets, the
  exact minimum at $\rho=-3000$ with and without normalized weights, the split
  direction ($\eta=0.5$: 0.369 to 0.292; $\eta=2$: 0.395 to 0.567), and
  $x_i^\star\propto\gamma_i^\eta$.

- Codex, run 1 (HEAD against the draft, 17 items): the mathematics checked
  with SymPy and NumPy, including the exact minimum and the floored winner's
  budget against `_allocate_with_floors`. Applied: the unnormalized limit is
  two one-sided limits, 0 and ∞, not "0 or ∞"; the CES expansion was restored
  in the opening; "concave for positive share counts"; the itinerary sentence
  in the limits lead and a sentence restating the corner box were cut; the
  second objective was shortened. Declined: a blank line before every `___`
  (nbconvert renders it as underscores, but VS Code renders a rule, and the
  instructor's own edits put `___` directly after text), and repeating "no
  binding floors" on the split and dollar-holdings sentences, since the problem
  cell states that assumption once for the whole notebook.
- Codex, run 2: every follow-up change was correct, and no correctness issue
  remains under the stated assumptions.

## Not changed

The lecture, its CES cell and Optional Advanced description, the advanced
README, and the deck. Their descriptions still match the notebook: the title,
the three limits, log-linear utility, and the share-price result are all kept.
The "not the correlation of L5a" clause stays, as the October 3 record
recommended, because students met $\rho$ as a correlation in L5a.

## Open for the instructor

- October 3 Codex item 4 (the package's $\eta=1000$ underflow and tolerance) is
  still open. This round did not touch `code/src`.
