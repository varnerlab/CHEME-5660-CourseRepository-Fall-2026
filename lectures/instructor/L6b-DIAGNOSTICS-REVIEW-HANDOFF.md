# L6b residual diagnostics advanced notebook — polish round record

Notebook: [CHEME-5660-L6b-Advanced-SIM-Diagnostics-Fall-2026.ipynb](../week-6/L6b/advanced/diagnostics/CHEME-5660-L6b-Advanced-SIM-Diagnostics-Fall-2026.ipynb)

Polish, voice, and organization round on September 28, 2026, run section by
section with rendered before/after previews. The instructor accepted all six
steps and marked the notebook reviewed the same day. The notebook is saved
and re-executed, with no errors. It is not committed, because the instructor
deferred the L6b commit. No proposals remain pending. The starting file included two uncommitted edits from the
advanced-cut session, one to the setup cell and one to the closing link.
Step 1 replaced the setup cell, and the closing link is unchanged.

## Scores

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 7.5 | 9 |
| Organization | 6 | 9 |
| Narrative and voice | 5.5 | 8.5 |
| Presentation | 5.5 | 9 |
| Density | 4.5 | 7.5 |
| **Overall** | **6.0** | **9.0** |

Codex scored the original 7.6 and the final 9.0 on its own. Body prose was
flat, going from 1,583 to 1,589 words. The notebook gained a figure, an
all-securities evidence table, two display equations, labeled readings, and a
closing answer. Other measures fell:

- Longest sentence: 85 to 34 words.
- Sentences over 35 words: 15 to 0.
- Paragraphs over 80 words: 10 to 4.
- Code lines over 100 characters: 36 to 0.

There are no clause semicolons, em dashes, or denials nobody proposed.

## Accepted steps

1. **Opening, setup, data, constants.**
   - The title changed from "Example: Bootstrap Uncertainty in a Single Index
     Model", which nearly repeated the bootstrap example's title. It is now
     "L6b Advanced: Residual Diagnostics and Two Bootstrap Methods", matching
     the lecture list and README.
   - Instructor correction: "Lead-in prose is too long". The text above the
     objectives is two sentences (about 34 words). It picks up from the
     bootstrap example and asks the notebook's question.
   - The objectives are two sentences each with no math. The unused
     diffusion-volatility conversion was dropped, and Newey-West got its own
     objective.
   - The setup follows the L6b examples, and the Include blockquote links
     `../../Include.jl`. The Data subsection names VWAP as the share price,
     because Task 3 depends on it.
   - The ticker comment was fixed after Codex found that choosing SPY would
     make the notebook fail with an error.
2. **Task 1, Fit the SIM and Check the Residual Distribution.**
   - The lecture model is a display equation, and `estimate_sim` links to its
     own documentation entry. The diffusion-volatility table row was cut.
   - The observed-vs-fitted scatter repeated the bootstrap example's figure.
     It became two panels: a density against a normal curve with the same
     variance, and the fraction of residuals larger than x standard
     deviations on a log scale. A log-density panel was tried first and
     rejected, because the kernel estimate broke into spikes in the tails.
   - The Hill tail index moved here from Task 3, with a Gaussian reference in
     the output. The residuals score 4.08. For 500 Gaussian samples of the
     same length, the median is 7.82 and the middle 95% runs from 6.33 to
     10.08.
3. **Task 2, Compare Two Bootstraps with the Classical Standard Errors.**
   - The bootstrap index follows the bootstrap example (k and K), and the two
     methods are short labeled items.
   - The stale "ridge case is treated in the optional advanced notebook"
     reference was cut. That material is archived.
   - The table shows blanks instead of `NaN` for the classical s_gε rows,
     using a PrettyTables formatter that turns `missing` into an empty cell.
   - The reading is `__What do we see?__` with two bullets. The alpha and beta
     bullet was corrected after Codex: each refit differs from the estimate by
     a weighted sum of the residuals, and the variances only nearly match
     (SSE/N against SSE/(N-2)).
   - The histogram gained headroom so the legend no longer covers the bars.
4. **Task 3, Check the Residuals for Dependence Across Days.**
   - `### Where does the lag-one dependence come from?` states the VWAP
     averaging mechanism, cites [Working (1960)](https://doi.org/10.2307/1907574)
     (checked through Crossref), and makes two predictions before the test.
   - The test table covers every security except SPY:

     | Measure | VWAP | Close |
     | --- | ---: | ---: |
     | Median growth-rate lag-one ACF | 0.104 | −0.037 |
     | Share above the band | 0.993 | 0.031 |
     | Median residual lag-one ACF | 0.100 | −0.007 |

   - `### Standard errors that allow for dependence (Newey-West)` gives the
     covariance and the middle matrix as displays. This fixes the old
     "(and their transposes)" wording, which double-counted lag 0. The nested
     `newey_west` function became plain loops, and the outputs are unchanged.
   - Cut:
     - the false claim that clustering is weaker in residuals than in raw
       growth rates (for AMD it is not)
     - the multi-day-risk aside
     - the cross-security correlation point
   - The task closes with a bold answer to the opening question.
5. **Summary.** The opener keeps the fuller two-sentence form. The takeaways
   are claims with two "We…" sentences each, and they match the objectives.
   The closing link to the estimation-risk notebook is unchanged.
6. **Data-loading code and final fixes.**
   - Cell 5 gained stage comments and wrapped lines, with identical output.
   - After the whole-notebook Codex review, three sentences were fixed:
     - The "expect beta's standard error to grow for other firms too" line
       was cut. It was true in an external check, but the notebook computes
       Newey-West for one firm only.
     - Takeaway 1 says "mainly" instead of "only".
     - Takeaway 2 says the dependence disappeared from nearly every
       security's growth rates.

Each task's code was rewritten as a lesson in its own step. Every cell has
stage comments, one statement per line, and lines of at most 100 characters.
The inline `acf1` became the package's `sample_autocorrelation`.

## Checks

- Full re-execution from the notebook folder, with no errors. The stored cell
  22 output from before the round had gone stale: it showed 0.981 where the
  current data gives 0.993. It is now current.
- Codex checked each step and the whole notebook. It confirmed all table
  values, the Newey-West formula and its implementation, the Hill reference,
  the tail fractions (beyond 3 standard deviations: 1.5% observed against
  0.27% for a normal distribution), and all links and package anchors.
- Checks run outside the notebook: across all 423 securities, the median
  ratio of Newey-West to classical beta standard error is 1.68 at L = 5 and
  1.93 at L = 20. 98.8% of securities are above 1.1.
- The L6b lecture's Optional Advanced description, `advanced/README.md`, and
  the bootstrap and estimation examples' links still describe the notebook
  accurately.

## Round 2 — September 30, 2026 (markdown only)

The instructor asked for another polish, voice, and organization pass if the
notebook scored below 9.0, and accepted the round the same day ("Agree.
Update"). The notebook is marked reviewed as of September 30, 2026. A fresh read scored it 8.6 (correctness 9.0,
organization 8.5, voice 8.5, presentation 9.0, density 8.0), and an
independent Codex read scored it 8.5 while confirming the Newey-West display
and code, the band, and the interval widths. The round changed seven
markdown cells and no code; code cells and stored outputs are byte-identical,
so the notebook was not re-executed. Body prose is 1,596 words before and
after.

- **Objectives follow the tasks.** Objective 1 had described Task 2, and
  objective 2 straddled Tasks 1 and 3. They are now heavy tails (Task 1),
  two bootstraps (Task 2), and dependence plus Newey-West (Task 3). The
  takeaways already followed that order.
- **Task 3 opener.** The itinerary sentence ("We then trace the dependence we
  find to its source and correct the standard errors for it") was cut, and
  the 88-word paragraph is split so the function sentence leads into the code.
- **Task 2 opener.** The percentile-interval parenthetical and the blank-cells
  sentence were cut; the display formatter's comment already explains the
  blanks.
- **Tail-index lead-in.** "A smaller tail index means heavier tails" now
  links to the figure it follows: "The tail index from L3a summarizes the
  right panel: a smaller index means heavier tails."
- **Newey-West lag rule.** The lag paragraph now says a common rule of thumb
  sets L near N^(1/4), about 7 here (N = 2766 gives 7.25), so the L = 5 and
  L = 10 rows bracket it. The reading names what the L = 0 row isolates:
  "The L = 0 row adjusts only for the changing variance. Adding lags then
  raises the standard error of beta well above the classical value, while
  that of alpha changes much less."
- **Small fixes.** "raises only part of that day's average" became "moves",
  the prediction sentence got its own paragraph, and the VWAP reading claims
  the *positive* dependence, which is what the closing-price test supports.

Codex items declined, with reasons: softening "should disappear" (the
positive dependence does disappear in the table, and the claim already says
positive); a takeaway rewrite that turned a claim into a recipe; extra
caveats on the Hill reference and the white-noise band, which the September
28 round cut on purpose; ticker-neutral readings that would say nothing
(Task 3 shows the pattern holds for 99.3% of securities); deleting the
Summary opener, which the instructor keeps in its fuller form; and a
staircase tail-fraction plot, a code change with no visible benefit at
N = 2766.

Codex re-read the saved notebook and scored it 9.0 (correctness 9.2,
organization 9.3, voice 9.0, presentation 8.9, density 8.6). It confirmed the
objective order, the lag rule (2766^(1/4) = 7.25), and the L = 0 reading. Two
of its four leftover items were applied, still word-neutral: "the fraction of
residuals whose size exceeds x standard deviations" (the panel counts both
tails), "the covariance matrix's diagonal entries" (the display just before
it is the middle matrix), and paragraph breaks before the Task 2 storage
sentence and before the L = 0 sentence. Declined: display-equation
punctuation (the course convention leaves displays unpunctuated) and a break
before the Data subsection's storage sentence (the standard Data form).

Round-2 scores: correctness 9.2, organization 9.3, voice 9.0, presentation
9.0, density 8.8, overall 9.1. The lecture's Optional Advanced description and `advanced/README.md`
still describe the notebook accurately. Not yet committed: it is part of the
deferred L6b commit.

Backup, patch script (`p1.py`), and draft are in
`build/notebook-previews/diag2/`; the before/after preview is
`build/notebook-previews/diag2-p1-all.png`.

## Left for a possible later round

- A `___` directly under a text line prints literally in nbconvert HTML. It
  renders in VS Code, and it is the house pattern, so it was left.
- The tail-fraction panel draws straight segments between the largest
  residuals; a step plot would be exact there.

Round-1 drafts, patch scripts (`p1.py`–`p6.py`), and previews are in
`build/notebook-previews/diag/` and `build/notebook-previews/diag-p*.png`.
