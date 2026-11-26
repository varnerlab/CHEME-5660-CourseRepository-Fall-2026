# L15a QA brief (review only, do not edit any file)

You review drafts of CHEME 5660 L15a for the instructor, Jeff Varner. He asked for "simple, direct, concise
english - no AI gibberish, slogans, jargon or slop", with messaging that is "really crisp and tight" in the lecture
and the examples. Score each notebook from 0 (really bad) to 10 (really great). Below 9 is not done. Your score
must reflect how the notebook reads as a page, not only whether its sentences pass rules: a previous reviewer gave
9.0 to a lecture Jeff rated "at most a 6" for poor organization, choppy formatting, repetition, and a weak figure.

## What to read first

1. The voice and layout benchmark, which Jeff spent a long time on: the 2026 L14a lecture
   `lectures/week-14/L14a/CHEME-5660-L14a-Lecture-UpdatingSIM-PaperTrading-Fall-2026.ipynb` and example
   `lectures/week-14/L14a/CHEME-5660-L14a-Example-JumpHMM-SectorFactor-Fall-2026.ipynb`. Match their organization,
   register, sentence length, bold run-in labels, definition boxes, algorithm format (`__Initialize__`, numbered
   steps with bold labels, `__Output__`), "What do we see?" boxes, Key Takeaways, and closing sentences.
2. The rules: `CLAUDE.md` (prose density: at most 3 sentences or about 60 words per paragraph, one idea per
   sentence, no "so"/semicolon chains), `lectures/instructor/NOTEBOOK-STYLE-GUIDE.md` sections "What the rounds show
   so far", "Algorithm pseudocode formatting", "Key takeaway voice", "What you need to know box", "Example callouts
   within lectures", "Example link descriptions start with In this example".
3. The memory notes in `/Users/jdv27/.claude/projects/-Users-jdv27-Desktop-julia-work-CHEME-5660-CourseRepository-Fall-2026/memory/`:
   plain-english-not-solver-jargon, lecture-notebook-prose-style, sentence-bullets-sentence-default,
   section-lead-states-the-plan, picture-first-figure-placement, no-denials-of-unproposed-misreadings,
   never-start-sentence-with-symbol, symbols-defined-at-first-use, three-los-three-kts, example-notebook-task-structure,
   no-hardcoded-values-in-helpers (the "What do we see?" boxes of a notebook with student-set constants must hold
   for any setting), polish-fixes-cut-not-add, example-tightening-target.

## Frozen text

In the lecture, the section "Updating the Single Index Model" and its subsections (through the betting-against-beta
comparison) and the "Optional Advanced Material" cell are Jeff's own text. Do not score or propose edits to them,
except a factual conflict with the new sections. Everything else is new and in scope.

## How to review

- Render each notebook to HTML (`/opt/anaconda3/bin/jupyter nbconvert --to html`) into your own scratch folder,
  symlink `figs` next to the HTML for the lecture, screenshot it with headless Chrome
  (`"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --screenshot=... --window-size=1100,16000 --virtual-time-budget=15000 file://...`),
  and look at the images. Judge structure, repetition (the same point stated twice in a section or across lecture
  and example), the order of ideas, choppy one-line paragraphs, tables and figures.
- Check every claim against the code and saved outputs where you can (`code/src/mpc/Triggers.jl`,
  `code/src/mpc/StudyBacktest.jl`, `code/src/data/mpc/study.toml`, the practicum at
  `/Users/jdv27/Desktop/julia_work/CHEME-4660-5660-Practicum-Fall-2026` for the practicum comparison table and the
  gates). Wrong facts are the most serious finding.
- Flag: jargon a student would not know (and optimization words like bind, cap, solver, feasible), slogans,
  sentences that restate the previous one, circular "because" clauses, vague referents ("this", "that comparison"),
  undefined symbols, any sentence starting with a symbol or backticked name, em dashes, semicolons joining clauses
  (the `__Initialize__` lists of an algorithm may use semicolons, as L14a does), more than one bullet list per
  section, bullet lists that are not three items when they could be, denials nobody proposed.
- Fixes must cut or replace, not add. Prefer deleting a sentence to rewording it. Give each fix as exact
  "replace X with Y" text.

## What to report

For each notebook: the score, the three most important problems (structure first), then a numbered list of exact
fixes (cell index, the old text, the new text), and any factual errors with the evidence (file and line). Keep the
report under 1,500 words.
