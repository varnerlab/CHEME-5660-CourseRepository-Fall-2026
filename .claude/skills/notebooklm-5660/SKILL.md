---
name: notebooklm-5660
description: Prepare a CHEME 5660 lecture for NotebookLM (podcast-style Audio Overview, quiz, flashcards). Exports the lecture and its in-class examples to Markdown and writes the Customize prompts into lectures/instructor/notebooklm/<id>/ (tracked, public, not in the release zip). Invoke when the user asks for NotebookLM materials, a podcast, or a quiz for a CHEME 5660 lecture (L10a onward). For CHEME 5820 use notebooklm-instructions instead.
---

# NotebookLM materials for CHEME 5660

Started October 26, 2026 (L10a) in answer to the midterm feedback, which asked for
self-test material and clearer core-versus-enrichment signals. The reference output
is `lectures/instructor/notebooklm/L10a/notebooklm-instructions.md`; match its structure.
Everything lives in the repo because the instructor works on several machines.

## Steps

1. **Resolve the lecture** to `lectures/week-*/<id>/`. Ask if the user did not name one.
2. **Pick the sources.** The lecture notebook, the examples listed under "We will work
   through these examples in lecture", and the deck PDF in `slides/`. Leave out
   "Review these examples on your own" examples and everything in `advanced/`.
3. **Export** each notebook into `lectures/instructor/notebooklm/<id>/` (tracked, and not in
   the release zip, which bundles only the week folder):
   `python3 scripts/notebooklm-export.py <notebook.ipynb> lectures/instructor/notebooklm/<id>/<stem>.md`.
   Do not copy the deck; the instructions point at `slides/`. Skim each export: no raw
   sample vectors, no setup noise. Re-export after any notebook edit.
4. **Read the sources** and the lecture's "What you need to know" box. The box's three
   core points are the outline for every prompt.
5. **Write `notebooklm-instructions.md`** in that folder with four sections:
   sources to upload; the Audio Overview prompt; the quiz and flashcards prompt;
   before sharing. End with a short "What was emphasized" list.
6. **Report** the folder path and what the user does next in NotebookLM.

## The Audio Overview prompt

In this order, in one fenced block, about 2,000 characters:

- **Audience:** engineering students in a quantitative finance course; say what they
  already know from earlier lectures (without lecture numbers) and what is new.
- **Framing:** one concrete contract or case from the in-class examples.
- **The three must-know results**, in words, one bullet each.
- **Accuracy rules** (always include):
  - say whether each probability is under P (our forecast) or Q (the market price's);
  - explain Q only as the probabilities under which the expected discounted payoff equals
    the price, and never mention replicating or hedging portfolios;
  - treat the box's "for understanding" items as background, not walkthroughs;
  - do not preview other lectures.
  - Add lecture-specific traps, such as units (Theta per year).
- **Tradeoffs:** two or three, each traceable to the sources, with a number from an
  example output where one exists. Do not use a number you have not seen in an output.
- **Tone, last:** "Keep the tone conversational, not lecture-y. Prefer analogies over
  formulas read aloud."

## The quiz and flashcards prompt

Questions only on the three core results; concept questions plus short calculations
from the example numbers; exclude the "for understanding" items; P or Q stated in
every question and answer.

## Guardrails

- Do not invent content; every claim must trace to the sources.
- No em dashes inside the prompts. Plain, literal wording (no trading-desk metaphors).
- NotebookLM gets details wrong. The user listens to the audio; when the user pastes
  the quiz or flashcards as text, check every item against the lecture and report errors.
- Audio and video go on Canvas, never into git or the release zip.
- The repository is public: no private notes, grades, or student names in these files.
- Commit the exports and instructions with `git commit -o` so unrelated work stays out.
