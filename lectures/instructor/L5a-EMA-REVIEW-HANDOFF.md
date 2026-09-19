# L5a EMA example polish review

Marked reviewed and complete by the instructor on September 18, 2026:
“Great! Let's mark this as reviewed.” All accepted revisions are saved;
no proposals remain pending. This record concerns the
[EMA parameter-updating example](../week-5/L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb).
The separate L5a lecture review remains closed. Do not restart accepted sections
unless the instructor requests another round.

## Assessment

The instructor requested polishing only if the initial score was below 9/10.
The initial editorial score was **8.8/10**; the final score is **9.1/10**.

| Dimension | Initial | Final |
| --- | --- | --- |
| Technical correctness and agreement | 9.3 | 9.3 |
| Organization and sequencing | 9.0 | 9.1 |
| Narrative and interpretation | 8.2 | 9.1 |
| Presentation | 9.0 | 9.1 |
| Cognitive density and pacing | 8.3 | 9.0 |

The original computations were sound and the three-task sequence worked.
The main weaknesses were a terse explanation of the moment updates, missing
interpretation after the simulation panels, and insufficient guidance for reading
the score outputs. The final version explains these points while shortening
Tasks 2 and 3. All mathematical displays and computations remain unchanged.

These are editorial judgments, not measured learning outcomes. The instructor
confirmed completion after receiving the final assessment. The material still assumes the
GBM and NPV prerequisites; classroom pacing has not been measured. No substantive
unresolved issue was identified in the final consistency check.

## Accepted revisions and preferences

- **Task 1:** Explained the deviation from the previous mean, the direction of
  the mean update, the 96.75%/3.25% weights for the default 21-observation half-life,
  and the variance contributions. Added a link to the existing EMA derivation.
  Retained growth-rate units, variance initialization, and GBM conversion.
- **Task 2:** The instructor rejected the expanded timing proposal as much too
  long and explicitly requested a 50–60% cut. The accepted preview cell was
  reduced from 401 to 186 whitespace-delimited words (53.6%), including the
  unchanged preceding Task 1 transition. This comparison is with the rejected
  draft, not the original notebook cell. Retained both displays, the three-method
  comparison, time definitions, target and volatility conditions, and helper
  links. Removed the numerical timeline and repeated instructions. Do not
  restore the expanded version as a routine clarification.
- **Simulation interpretation:** Added 40 words explaining forecast spread,
  median shifts, the scheduled-sale target, and why one observed path cannot
  establish comparative forecast accuracy.
- **Task 3:** Shortened its introduction from 148 to 97 words, preserving the
  Brier equation and averaging convention. Added the concrete example that a
  probability of 0.8 gives loss 0.04 when the target is exceeded and 0.64 otherwise.
- **Score interpretation:** The instructor rejected the first 62-word proposal
  as unclear. The accepted 63-word replacement refers directly to the table's
  `Change vs frozen` and `Fraction improved` columns and explains the cumulative
  plot relative to zero. Do not restore the rejected average-versus-majority
  discussion or the conversion from the cumulative endpoint to a mean here.

Keep follow-up proposals compact and concrete. The requested percentage cut
applied to the Task 2 proposal; it is not a general compression rule for other
notebooks. The introduction, setup, limitations, three objectives, and three
takeaways required no rewrite. Keep the existing distinction between probability
accuracy and trading profit, and the descriptive interpretation of dependent,
overlapping outcomes.

## Validation and scope

- Read all 26 cells, local setup, parameter and forecast helpers, their reference
  documentation, and the EMA derivation. Used the shared style guide, Week 5
  refactor handoff, and original CHEME 5820 power-iteration example as references.
- During the opening assessment, executed the exact source of all 11 code cells
  in sequence in Julia using an isolated review directory, a copied `Include.jl`,
  links to the original data/helpers, and a separate figure directory. This was
  script execution, not an IJulia notebook-kernel run. All cells completed.
- Reproduced 417 eligible tickers, 250 observations, 229 origins per ticker,
  and 95,493 forecasts per method. Mean Brier losses reproduced the saved values:
  frozen 0.1167827312, EMA volatility 0.1162232496, and EMA mean plus volatility
  0.1222736840. Execution was not repeated after subsequent prose-only edits.
- The final notebook matches the last approved draft. Only Markdown cells
  12, 14, 20, and 22 changed (zero-based indices). All code cells, saved outputs,
  execution counts, cell IDs, metadata, and six displayed equations are preserved.
- Notebook schema, exactly three objectives/tasks/takeaways, all 13 local link
  occurrences and local Markdown anchors, and section separators pass. The
  introduction, developed material, and retrospective closing agree.
- All six displays render without errors using both the installed VS Code
  notebook math renderer and markdown-it-texmath, without extracting equations
  before Markdown parsing. Final screenshots cover all 26 cells and show no
  horizontal overflow at the 1140-pixel viewport. The four saved figures and key
  sections were inspected during the opening assessment; all four changed cells
  were visually inspected in the final render.
- No shared helper, dataset, companion notebook, figure file, or slide changed
  during this example's polish round. Earlier lecture/style-guide edits in the
  working tree belong to the completed lecture review and were preserved.

Review evidence is under `build/notebook-previews/L5a-EMA-review-2026-09-18/`.
Its `final/` directory contains the final HTML, PNGs, validation report, render
report, and layout metrics. These are ignored generated artifacts; regenerate
them if they are later removed. `execution.log` and
`execution/score-summary.csv` record the numerical verification.

Initial notebook SHA-256:
`f1a77070d654b8843c809cbc4d3426f41e922baf0bd1d9c098f51cb9bfd26994`.

Notebook SHA-256 at completion of the polish round:
`65153cf491aec86b9c20a26c9f2cb44970c80a42cfd55a7579121fdfebe5127b`.

## Instructor-requested Task 2 tightening — September 18, 2026

After marking the notebook reviewed, the instructor requested another focused
edit of Task 2: trim the wording and keep the language simple and direct.
Applied that request across the forecast introduction, plot instructions,
simulation explanation, and short interpretation after the simulations.
Repeated setup and forecast assumptions were consolidated.

Task 2's Markdown text decreased from 346 to 213 whitespace-delimited words
(38.4%), excluding display equations and adjacent Task 1/Task 3 text. Only
Markdown cells 14, 16, 18, and the Task 2 portion of cell 20 changed in this
follow-up. The equations, three-method comparison, timing definitions, parameter
conditions, and function links remain. Code, saved outputs, metadata, cell IDs,
and the text of Tasks 1 and 3 are unchanged.

Notebook schema, all six equation displays in both renderers, all 13 local link
occurrences, the three objectives/tasks/takeaways, separators, and diff checks
pass. All four changed cells were visually inspected; no overflow was found.
The numerical code was not rerun for this prose-only change. This was a targeted
follow-up, not a new scoring round; the 9.1/10 score above refers to its reviewed
snapshot. No proposals remain pending.

Evidence: `build/notebook-previews/L5a-EMA-task2-tighten-2026-09-18/`.

Current notebook SHA-256:
`503d55bc749832f3d9d1482056aca13be410e18fd8bc5966ab4c0d8f1c418e92`.
