# L5a single-asset GBM and NPV lecture review

Marked reviewed and complete by the instructor on September 18, 2026:
“Great! Mark this as reviewed.” All accepted revisions are saved; no proposals
remain pending. This record concerns the new
[single-asset L5a lecture](../week-5/L5a/CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb).
The earlier multiple-asset L5a review belongs to the material now taught as L5b.
Do not restart accepted sections unless the instructor requests another round.

## Assessment

Final editorial score: **9.2/10**. Initial reported score: **9.1/10**.

| Dimension | Initial | Final |
| --- | --- | --- |
| Technical correctness and agreement with examples | 9.4 | 9.4 |
| Organization and sequencing | 9.1 | 9.3 |
| Narrative flow, motivation, and interpretation | 9.0 | 9.2 |
| Presentation and rendered layout | 9.2 | 9.3 |
| Cognitive density and pacing | 8.9 | 9.0 |

The initial assessment was too generous about completeness. It missed the
instructor's expectations for the company profile and consistency with earlier
lectures' example callouts. The instructor explicitly requested corrections
after that assessment. Retain the original scores as the review history, not
as evidence that the original profile was satisfactory. These scores are
editorial judgments, not measured learning outcomes. The instructor confirmed
completion after receiving the final assessment.

The revised profile supplies concrete people, a defining fund, and usable
resources. Consistent example callouts provide clear application stops. The
prediction-band paragraph and numerical half-life interpretation explain two
concepts students could otherwise misread. The mathematical development remains
unchanged. EMA still introduces several ideas compactly; its linked derivation
and worked example support the lecture. Classroom pacing has not been measured.
No substantive unresolved issue was identified in the final consistency check.

## Accepted changes and instructor preferences

- Expanded Renaissance Technologies' profile to include Jim Simons, the
  Medallion Fund, sourced historical performance, official careers links,
  and Numberphile/TED interviews and channel links. Historical average annual
  performance is distinguished from compounded growth and from other funds.
  The careers page had no internship posting when checked on September 18;
  do not invent an internship program or a Renaissance YouTube channel.
- Adopted the L4a/L4b lecture callout format for the OoS, NPV, and EMA examples:
  a prose lead-in, blockquote with `__Example:__`, a quoted blank line, and a
  linked triangle action with a short description. Keep the fuller opening
  Examples overview and the separate EMA derivation link.
- Explained that a 95% pointwise prediction band applies at one future date
  with fitted parameters held fixed; it does not imply 95% whole-path coverage.
- Removed the entire paragraph beginning “Use only observations available at
  the forecast date” at the instructor's request. Do not restore it as a
  routine clarification. The forecast assumptions remain supported elsewhere.
- Saved the approved half-life sentence: “A 21-observation half-life gives
  $\lambda\approx0.9675$: the updated mean assigns about 96.75% weight to the
  previous mean and 3.25% to the newest growth-rate observation.”

Keep EMA as a concise theorem-style proposition. Estimates use the course
growth rate in inverse years, with initial variance $\sigma_0^2/\Delta t$
and GBM volatility recovered as $\sqrt{v_k\Delta t}$. The detailed derivation
and empirical calculations belong in the linked companion notebooks.

The shared notebook style guide now records the accepted company-profile
expectations and lecture example-callout convention.

## Validation and scope

- Read the full lecture, relevant companion material and helpers, the shared
  style guide, Week 5 refactor handoff, and reference lecture passages.
- Validated notebook schema, exactly three objectives, exactly three takeaways,
  three example callouts, ten resolving local link occurrences, and separator
  placement. The introduction, objectives, developed material, and closing agree.
- All original inline and display mathematics, cell IDs, and metadata are
  preserved. Only Markdown cells 2, 3, 5, and 6 changed (zero-based indices).
  The final step changed only the half-life sentence in cell 6. The saved
  notebook exactly matches the approved draft with the requested deletion.
- Rendered all 13 displays through both the installed VS Code notebook math
  renderer and markdown-it-texmath with zero errors. Inspected all ten cells
  during the review and the changed sections in the final render. Final
  screenshot metrics report no horizontal overflow at a 1140-pixel viewport.
- Earlier in this same review, ran
  `julia --project=. scripts/check-week5-adaptive.jl`: all 101 assertions passed
  (92 centered EMA/timing checks and 9 trade-probability/score checks). Later
  edits were prose only, so this numerical suite was not rerun for each edit.
  The lecture has no code cells; full companion notebooks were not reexecuted.
- Verified company-profile sources and external resources during this review;
  the source links are embedded in the notebook. Careers availability is dated.
- No companion notebook, executable code, saved output, or slide was changed.

Final HTML, section PNGs, validation results, and render metrics are in
`build/notebook-previews/L5a-SAGBM-NPV-final-2026-09-18/` (ignored generated
artifacts). The final EMA preview is `lecture-cell-6.png`. Regenerate previews
if these artifacts are later cleaned up.

Notebook SHA-256 before the round:
`02ad8901bd8041ad8c68ceb6324859a5b937c734d4d2df1b27d2d60c381bff8c`.

Notebook SHA-256 after the round:
`037cf90de5fff01394fdb08567a8b647e38bc8f5213f9108646fb029c2db85ec`.

## Instructor-requested risk wording — September 19, 2026

Revised only the Risk bullet in the single-asset concept review. The instructor
wanted the estimation rule stated directly: use the standard deviation of the
observed growth rates, adjusted for the time step,
$\hat{\sigma}=\sigma_g\sqrt{\Delta t}$. Removed the comparison with the standard
deviation of a log return. Preserve this simple explanation in follow-up work.
At the instructor's follow-up suggestion, added the units of the time step,
growth-rate standard deviation, and volatility estimate. He then requested
complete, natural wording: “We estimate the volatility parameter…” and full
“has units of” phrasing. This preference is recorded in the shared style guide.
All other existing notebook edits were preserved. Schema and both math-renderer
checks pass; all 13 displays render. This was a focused wording change, not a
new scoring round.

Current notebook SHA-256:
`8b1948c18fa573a257b106f4e2a44a5269d514b8f2ed6494cab9e42518b42153`.
