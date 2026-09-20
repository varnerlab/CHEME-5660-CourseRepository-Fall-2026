# L5a Single-Asset GBM and NPV Slides: Synchronization and Polish

Completed September 19, 2026, at the instructor's request. The current
single-asset L5a deck was synchronized with the reviewed lecture notebook,
then polished and visually checked. **Final editorial assessment: 9.2/10.**
The instructor has not yet separately marked this slide review complete.

This record covers the single-asset deck, initially reviewed at **23 pages**
and now **22 pages** after the instructor-requested deletion recorded below.
The September 16
review in `L5a-SLIDES-REVIEW-HANDOFF.md` covers the former 37-page multiple-asset
deck, which moved to L5b during the Week 5 refactor.

## Artifacts and scope

- [Updated PDF](../week-5/L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.pdf).
- [Native Beamer source](../week-5/L5a/slides/CHEME-5660-L5a-Slides-Fall-2026.tex).
- [Lecture used for alignment](../week-5/L5a/CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb).

The source, compiled PDF, and tracked Beamer navigation file were updated.
The lecture, examples, Julia helpers, shared theme, other decks, and archives
were unchanged. No commit or publication was performed.

## Synchronization changes

The previous 18-page deck omitted substantive additions to the lecture:
the company profile, pointwise-band interpretation, and EMA theory. These
gaps are now covered in the lecture's existing topic order.

| Final pages | Content |
| --- | --- |
| 1–4 | Title, disclaimer, exactly three objectives, and the three example links |
| 5–6 | Jim Simons, RenTec's research approach, Medallion, careers, interviews, and YouTube channels |
| 7–9 | Existing GBM model, growth-rate interpretation, and exact transitions |
| 10–11 | Pointwise prediction bands and the out-of-sample example |
| 12–17 | Existing NPV derivation, target probability, benchmark interpretation, and example |
| 18–20 | EMA initialization and updates, GBM conversion and units, half-life, and derivation link |
| 21–23 | EMA example, optional advanced examples, and exactly three key takeaways |

The third objective and takeaway now explicitly cover parameter updates.
The company profile distinguishes Medallion's arithmetic average annual
returns from compound growth rates and from the strategies of RenTec's
other funds. The pointwise-band slide distinguishes coverage at one future
date from the probability of an entire path staying within the band.

## EMA notation and teaching choices

- Use the course growth rate `g_k = log(S_k/S_(k-1))/Delta_t`, with positive
  prices at equal intervals measured in years.
- Initialize `m_s = mu_g,0` and `v_s = sigma_0^2/Delta_t` from training estimates.
- Use the centered update `delta_k = g_k - m_(k-1)`,
  `m_k = m_(k-1) + (1-lambda)*delta_k`, and
  `v_k = lambda*(v_(k-1) + (1-lambda)*delta_k^2)`.
- Recover volatility as `sqrt(v_k*Delta_t)` and arithmetic drift as
  `mu_g,k + sigma_k^2/2`. Mean growth has units of inverse years, growth-rate
  variance has units of inverse years squared, and volatility has units of
  inverse square-root years.
- Explain the conversion naturally: “We estimate the volatility parameter by
  multiplying the growth-rate standard deviation ... by ...”. Do not shorten
  the prose by dropping articles, verbs, or parameter names.
- The variance recursion accounts for the changing mean and has no
  finite-sample unbiased correction.
- A 21-observation half-life gives `lambda = 0.9675317785`, or approximately
  96.75% of the previous mean and 3.25% of the newest growth-rate observation.
  The half-life and forecast holding period have separate roles.
- Each forecast holds its estimates fixed. Detailed derivations, simulations,
  rolling trade calculations, and empirical scores remain in the linked
  notebooks. The instructor's deleted “Use only observations ...” paragraph
  was not restored.

## Polish and assessment

The polish pass retained the existing Beamer theme, font sizes, colors,
title/disclaimer order, and annotated mathematical development. It made the
example link labels consistent, shortened the NPV transition question,
clarified that `v_k` is the estimated variance of growth rates, tightened the
daily-forecast description, and gave “Key takeaways” its own paragraph.

The 9.2/10 assessment reflects agreement with the current lecture, correct
growth-rate scaling, concise and natural explanations, clickable resources,
and readable final layouts. It is an editorial judgment about this snapshot,
not the inherited score of the former multiple-asset deck.

## Sources and link checks

Company claims and student resources were checked on September 19, 2026:

- [RenTec overview](https://www.rentec.com/Home.action?about=true).
- [Simons Foundation obituary](https://www.simonsfoundation.org/2024/05/10/simons-foundation-co-founder-mathematician-and-investor-jim-simons-dies-at-86/).
- [Bradford Cornell's Medallion study](https://www.cornell-capital.com/uploads/papers/medallion-fund.pdf),
  including the 1988–2018 annual data and average gross/net figures.
- [Official careers page](https://www.rentec.com/Careers.action?jobs=true).
  No internship opening appeared in the checked listings; the slide dates
  this observation and points students to the same page for updates.
- [Numberphile interview](https://www.youtube.com/watch?v=QNznD9hMEh0),
  [Numberphile2 channel](https://www.youtube.com/@numberphile2), and the
  [publisher's channel directory](https://www.numberphile.com/about).
- [TED's Jim Simons talk](https://www.ted.com/talks/jim_simons_the_mathematician_who_cracked_wall_street)
  and the [TED YouTube channel](https://www.youtube.com/@TED).
  The talk uses the verified TED page because the lecture's direct YouTube
  video URL could not be fetched by the browsing tool. Both requested
  YouTube channel links remain directly available on the slide.

Visible source links and `[Sources]` blocks in Beamer notes preserve the
provenance of the new company material.

## Validation

- `make slides` succeeded with XeLaTeX/latexmk: 23 PDF pages.
- No overfull/underfull boxes, missing glyphs, or compilation errors. The
  existing unicode-math/mathtools bracket warnings remain.
- Every page was rendered and inspected individually. After the polish
  edits, all pages were rendered again; the six changed pages were inspected
  again, and the other 17 images were identical to those already inspected.
  No clipping, overlap, or unintended title wrapping was found.
- PDF text bounds lie within each page. All 14 distinct source hyperlinks
  are embedded as clickable PDF annotations. All six distinct repository
  notebook targets exist locally.
- Exactly three objectives and three takeaways; title and disclaimer remain
  first and second. Every pre-existing displayed GBM/NPV equation and the
  disclaimer text were preserved verbatim.
- EMA equations and units were compared with the lecture and
  `lectures/week-5/L5a/src/AdaptiveGBM.jl`. No executable code changed, so the
  notebooks and Julia tests were not rerun.
- The lecture hash and local theme match the pre-edit snapshots.
- Ignored QA files, before snapshots, renderings, build logs, extracted text,
  link annotations, and validation details are in
  `build/notebook-previews/L5a-slide-sync-polish-2026-09-19/`.

Snapshot SHA-256 values:

```text
slides/CHEME-5660-L5a-Slides-Fall-2026.tex
8c882c549937fcd3ea98f33f048aa7bda0050a7cccf9b6aa566b39e6b09e8441

slides/CHEME-5660-L5a-Slides-Fall-2026.pdf
0c90f77caff57e46137d088cae797ab489af00c6e318c0ec242c725cee3b7e21

CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb
5e04a16f4bfb4c0896edb755fa248dbbd5e15c60bfc0a42cc8db072fc490c3b2
```

## Conditional reassessment — September 19, 2026

The instructor subsequently requested another polish round only if the initial
score was below 9/10. A fresh review of the current source and all 23 rendered
pages gives **9.2/10**, so no slide edits were made. The source, PDF, and lecture
match the snapshot hashes above. This records the assistant's assessment;
separate instructor confirmation of completion remains unrecorded.

| Dimension | Score |
| --- | --- |
| Technical correctness and lecture alignment | 9.4 |
| Organization and sequencing | 9.3 |
| Narrative and interpretation | 9.2 |
| Rendered layout | 9.2 |
| Density and pacing | 8.9 |

The GBM-to-NPV derivation is coherent, and the EMA initialization, centered
variance update, parameter conversion, and units agree with the lecture and
`src/AdaptiveGBM.jl`. The pointwise-band and half-life explanations retain the
instructor's accepted distinctions. Slides 8, 14, and 18 are moderately dense
but readable; they are minor pacing considerations, not unresolved corrections.

Every page was rendered at 1440 pixels wide and inspected individually. No
clipping, unintended overlap, missing glyphs, or unintended title wrapping was
found. PDF text bounds remain inside the pages. All 14 distinct source links
are embedded in the PDF, and all six repository notebook targets exist locally.
The deck retains exactly three objectives and three takeaways. The company
sources linked above were reopened, including the current careers listings
and Cornell's table of arithmetic annual averages; the checked claims remain
supported. YouTube pages resolved, but video playback was not tested.

The existing PDF was reviewed without rebuilding it, and no notebook or Julia
execution was needed for this unchanged deck. Temporary renderings and the
check report are in `/private/tmp/L5a-slides-review-2026-09-19-xe97_vz3/` and may
be removed by system cleanup. No polish proposals remain pending from this
conditional assessment.

## Requested slide deletion — September 19, 2026

The instructor requested: “Delete this slide: Pointwise Prediction Bands =>
we don't need this.” Removed that standalone frame (formerly page 10) from
the Beamer source and rebuilt the PDF with `make slides`. Do not restore it
as a routine lecture-alignment correction. The deck now contains 22 pages;
the one-step transition leads directly into the out-of-sample example.

Source comparison confirms that only the requested frame was removed. All
22 pages were rendered, and their content above the footer is pixel-identical
to the corresponding pages inspected during the preceding review. The new
pages 9, 10, and 22 were also inspected visually. Page numbers are consecutive,
the deleted heading is absent, and all PDF text remains within the page bounds.
The build reports no overfull/underfull boxes, missing characters, or errors;
existing package and included-PDF-version warnings remain.

The lecture and examples remain unchanged. The earlier 9.2/10 assessment
describes the 23-page snapshot, not a new scoring round after this deletion.
Temporary before copies, rendered pages, and checks are in
`/private/tmp/L5a-remove-prediction-band-p26m4qzc/`.

Current source SHA-256:
`3daa4a8a5171453fa595e85b6e9825d5eb7636c536cd68782e5133ac13bd492e`.

Current PDF SHA-256:
`dd91c50fcd0a15fbd6174b0e3074f359999dd2dce9f0f1e1ba54494d59e53399`.
