---
name: notebook-polish
description: Interactive polishing of Jeffrey Varner's CHEME 5800 and CHEME 5660 lecture, lab, and example notebooks, with an initial rating, section-by-section proposals and approval, and final rescoring. Use for requests such as "notebook polish round," "let's polish a notebook," or "interactive notebook review." Ask for the notebook path if it was not supplied for this round. Do not activate for a single isolated correction or slide review.
---

# Notebook polish round

Make a rigorous notebook easier to teach and read while preserving the instructor's
explanatory narrative. This is an interactive editorial workflow: review first,
develop concrete proposals, apply accepted changes, and reassess the result.

## Start the round

If the user has not identified the notebook for this round, ask only:
"Which notebook would you like to polish? Please send its path."
An attached notebook or an unambiguous current target is sufficient; do not ask
again. Do not silently select the notebook from a completed previous round.

Read the target repository's applicable AGENTS.md instructions and the shared
course notebook style guide. Resolve its path from the target checkout:

- In CHEME 5660: `lectures/instructor/NOTEBOOK-STYLE-GUIDE.md`.
- In CHEME 5800: `../CHEME-5660-CourseRepository-Fall-2026/lectures/instructor/NOTEBOOK-STYLE-GUIDE.md`.

If the checkout was renamed or placed elsewhere, follow the target repository's
AGENTS.md reference or locate the guide in the available course checkouts. Never
assume a username, home folder, or original-machine absolute path. Treat absolute
paths in historical notes as provenance and resolve their repository-relative
files in the checkouts on the current machine.

That guide is the maintained source for voice, formatting, objectives, takeaways,
and distinctions between courses and notebook types. Follow its reference-reading
requirements. Do not recreate a competing style guide or invoke legacy style
auto-fixes. If the shared file is unavailable, use the repository's documented
principles and report the missing reference briefly.

Read the whole notebook before proposing edits. Inspect its rendered presentation
and enough supporting code, data, or linked material to assess its actual claims.
Inspect existing changes so instructor edits are preserved. For labs, preserve the
student implementation tasks, supplied scaffolding, and separation of instructor
solutions; do not complete the exercises as part of prose polishing.

## Opening assessment

Lead with an honest overall rating from 0 to 10, where 0 is unusable and 10 is
exceptional. Explain what makes the notebook strong and what holds it back using
specific passages or sections. Assess these same dimensions before and after:

- Technical correctness and agreement among prose, equations, examples, and code.
- Organization and sequencing of ideas.
- Narrative flow, motivation, reasoning, and interpretation.
- Presentation, including equations, figures, headings, and rendered layout.
- Cognitive density and pacing for students encountering the material.

Use a compact score table when it helps, but retain explanatory feedback. Treat
scores as editorial judgments supported by evidence, not measured learning
outcomes. Distinguish verified correctness from untested execution or unresolved
claims. Do not copy the previous notebook's score or assume every pass raises it.

Recommend a short, prioritized sequence of improvements and a place to begin.
Leave the notebook unchanged during this initial assessment and let the instructor
select or accept the starting point. Retain the initial scores and reasons for
the closing comparison.

## Section-by-section review

For the selected section, explain the concrete teaching problem, present the
proposed wording or organization, and show a rendered preview when equations or
layout matter. Prepare previews from a draft copy before changing the target.
Keep each proposal small enough to review comfortably. Wait for feedback on that
proposal rather than rewriting the entire notebook at once.

Interpret the instructor's short replies in context:

- "Agree. Update." authorizes saving the current accepted revision.
- "Agree. Update. Next." authorizes saving that revision and presenting the next
  proposal without another confirmation.
- Corrections to a proposal guide the next revision; preserve already accepted
  wording and decisions.
- A request for status or a score during the round does not cancel the review.

Save accepted changes promptly and verify that the preview and notebook agree.
Keep track of accepted sections, the pending proposal, and the remaining review
sequence. If changes were already explicitly authorized, carry them out without
repeating the approval step.

Reduce density through better sequencing, localized tightening, useful subsections,
and clearer stopping points. Preserve motivation, intermediate reasoning, analogies,
worked examples, and interpretation. Place secondary proofs or reference details
deliberately; do not move explanation needed to follow the main argument out of
the lesson. Avoid arbitrary percentage cuts or replacing teaching prose with
compressed slogans. Always lead smoothly from prose into displayed equations and
explain their meaning, following the shared guide.

## Previews and validation

Save readable HTML/PNG previews in the target repository's
`build/notebook-previews/` directory, using descriptive filenames. Check the
repository's ignore conventions before creating artifacts. For this instructor's
workflow, open PNG previews in VS Code when available, and provide an absolute
clickable file link. Do not offer only a temporary-directory link. If opening is
unavailable, report that and provide the workspace path. Respect the environment's
permissions for launching applications. Discover the Python, Julia, and rendering
tools available on this machine; do not reuse interpreter paths from another
computer. Prepare missing preview tools in a local environment when needed,
following the environment's installation permissions.

Preserve code, outputs, and unrelated existing edits during prose-only work.
Check notebook validity, relevant links, mathematical consistency, and rendered
readability. Execute appropriate validation when changing computational behavior
or when needed to resolve a correctness question; do not rerun expensive code for
every wording change. Keep changes within the requested notebook and necessary
supporting artifacts. Notebook polishing does not authorize slide edits or a
repository-wide rewrite.

## Close and rescore

When the agreed sections are complete, check the whole narrative for consistency:
the introduction, three objectives, developed material, and three retrospective
takeaways should agree. Check the concluding sentence after the takeaways and
follow the current guide's separator rules.

Give the final overall score and compare it with the initial score using the same
dimensions. Explain the concrete improvements, remaining limitations, and checks
actually performed. An unchanged score is valid. Be candid about pacing that
requires classroom feedback. Do not silently apply new substantive rewrites found
during this final assessment; identify them for a possible later round.
