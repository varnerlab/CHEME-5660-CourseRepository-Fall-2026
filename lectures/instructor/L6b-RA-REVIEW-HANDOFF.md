# L6b SIM portfolio (RA) example — polish round record

Notebook: [CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb](../week-6/L6b/CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb)

Polish, voice, and organization round on September 28, 2026, run section by
section with rendered before/after previews. The instructor accepted all five
proposals, two of them after corrections. The changes are uncommitted, because
the instructor deferred L6b commits until the examples are reviewed. The
starting findings are in the
[L6b examples review handoff](../week-6/L6b/tmp/L6b-EXAMPLES-REVIEW-HANDOFF.md).

## Scores

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 8 | 9 |
| Organization | 6 | 9 |
| Narrative and voice | 5 | 8.5 |
| Presentation | 6 | 8.5 |
| Density | 5 | 8 |
| **Overall** | **6.5** | **8.6** |

Prose went from 2,830 to 2,143 words, excluding the disclaimer, display math,
and link targets. There are no clause semicolons or em dashes.

## Accepted proposals

1. **Opening, setup, data, constants.**
   - The 94-word itinerary above the objectives became a three-sentence
     motivation ending in a question. A two-sentence "In this example"
     overview sits below the objectives.
   - Setup, the data-loading code, and Constants follow the approved L6a
     cells. `Include.jl` loads no local helpers, so that phrase was dropped.
   - Instructor correction: "The data subsection is too beefy". The Data
     prose went from 295 to 148 words: one sentence on the data, one-line
     lead-ins, and a three-sentence archive paragraph. A follow-up request
     split the archive paragraph so the code lead-in has its own paragraph.
   - The `JLD2.load` link points to the FileIO section that documents `load`.
2. **Task 1, Estimate and Compare the Portfolio Inputs.**
   - "In this task" opener, four `###` subsections in L6a sentence case, and
     the `___` before a level-three heading removed.
   - Notation follows the lecture: $\mathbf{g}'$, "sample covariance".
   - The 72- and 160-word re-derivations of the two lecture facts became two
     labeled bullets. The checks stay, with two new asserts in the residual
     cell.
   - Both readings are `__What do we see?__` lists that name no ticker. After
     Codex review: "the SIM matrix has no blocks" became "no term that links
     two particular firms", and a small median now means "at least half the
     pairs".
3. **Task 2, Construct the Frontiers and Compare Allocations.**
   - The `efficient_frontier(...)` helper and three rebuilds of the problem
     were replaced by L6a-style cells: build both problems once, solve both
     GMV portfolios directly, and sweep both at the same floors. A failed
     solve leaves `NaN` in its row, so row k compares the same floor.
   - `g_target` is the middle floor of the sweep (0.3077 for the default
     firms) instead of a fixed 0.20 in Constants. The old value made cells 39
     and 44 fail for other ticker lists.
   - The frontier figure gained a right panel with the SIM-believed minus
     sample-covariance σ and the extra σ of the SIM weights. It replaces the
     six-row "regret" table and its 218-word reading. The left panel uses
     L6a's label placement, and both legends are see-through.
   - The GMV weights now match L6a (AAPL 0.0901).
4. **Task 3, How Did the Portfolios Do Out of Sample?**
   - The L6a price-matrix, wealth, plot, and scorecard cells are ported and
     extended to six portfolios, using the Task 2 weights.
   - The moved target changed the two target rows of the scorecard (data
     1.2808, SIM 1.2437). The GMV, equal-weight, and SPY rows are unchanged.
   - The reading gives two labeled comparisons, the default-firms result with
     the "results may differ" reminder, and a link to the estimation-risk
     notebook. It replaces the stale "L6a's advanced material" and "the second
     example".
   - L6a's `$k$th` does not render in VS Code, so this notebook says "the time
     of trading day $k$". The released L6a Task 3 (cell 48) still has the bug.
5. **Summary.**
   - Takeaway 1 is unchanged. Takeaway 2 states the sign rule for any
     selection, prefixed "On balance" after Codex review. Takeaway 3's label
     claimed the input sets were "nearly indistinguishable", and now reads "One
     test year cannot rank the input sets".
   - Instructor correction: "I prefer the longer form intro and conclusion
     type sentences in the Summary - meet me in the middle". The opener went
     from 62 to 43 words, as two sentences. The closer went from 31 to 27
     words, keeping the old "The … example adds …" form with a same-folder
     link.
   - Objective 3 says "sample covariance", and objective 2 says "off the
     diagonal".

## Validation

- Executed in place after every code change, with no errors (about 25 s).
- Alternate ticker lists ran the whole notebook without errors: XOM, CVX, KO,
  PEP, JPM, PG, DUK (the list that failed before the round) and AAPL, MSFT,
  JNJ (three firms, which needed the `min(5, #pairs)` fix in the pair table).
- Codex checked each proposal and the whole notebook. The notebook delivers
  the lecture's example description, every number in the prose matches the
  stored outputs, and all relative links stay in the L6b folder.
- The L6b deck and lecture hold no stale RA numbers or terms.

## Declined Codex suggestions

- Rewriting takeaways 1 and 2 into the "We…" voice. The guide keeps both
  takeaway voices on record.
- Shortening the Summary opener and closer, which the instructor asked for in
  the longer form.
- Splitting the standard disclaimer.

## Remaining for a possible later round

- The frontier figure cell is about 70 lines, mostly L6a's label placement.
- `g_high = maximum(ĝ) - 1e-4` would fail if the higher GMV growth rate came
  within 1e-4 of the largest mean. No tested list does this.
- Task 2 is the densest section (about 570 words). Its readings guide the
  comparison rather than interpret a default result, which needs classroom
  feedback.

## Round 2 — September 28, 2026

The instructor asked for another polish, voice, and organization pass to reach
the 9.0 threshold. The pending round-1 density proposal (585 to 514 words) was
superseded. An independent opening score was 8.5. The instructor accepted three
proposals, and asked for one change to the third. Prose went from 2,167 to 2,151
words, counting inline math as one word and excluding the disclaimer and display
math. The saved notebook's SHA-256 begins `fc4ffa58fe3a`. The instructor marked
the notebook reviewed the same day. The changes are not committed.

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 9 | 9 |
| Organization | 8.5 | 9 |
| Narrative and voice | 8 | 9 |
| Presentation | 8.5 | 9 |
| Density | 8 | 8.5 |
| **Overall** | **8.5** | **9.0** |

1. **Task 1 (word-neutral).** Objective 2 says "whose co-movement the SIM
   misses", matching the Task 1 opener. Cell 18 no longer returns `s²_ε`, which
   no later cell used, and cell 17 says it keeps only `α̂` and `β̂`. The covariance
   split moved out of the bullet into a display, with the underbrace labels "SIM
   keeps" and "SIM drops". The display replaces "The SIM drops the second term."
2. **Task 2 (−21 words).** Three repeats were cut: the `argmax` sentence in
   cell 30, which cell 31's comment covers; the σ-column sentence in cell 32,
   which cell 34 covers; and "the data frontier minimizes this risk" in cell
   34, which cell 36 covers. The cell 39 reading replaces the `β̂` prompt, which
   led nowhere because the weight differences follow the residual correlations.
   Its first bullet explains the tendency, and its second points to the Task 1
   pair table. It names no ticker. For the default firms, the two largest
   `Δ_tgt` entries (+0.1158 and +0.0758) form a pair with residual correlation
   −0.252.
3. **Task 3 (+5 words).** Cell 48 opens with a one-paragraph `__What do we
   see?__` giving the default result and the "results may differ" reminder. It
   then answers the opening question in a bold `__So does the covariance model
   change the portfolio we choose?__` paragraph, like the bootstrap example's
   closing. Instructor correction: "add a line break on the last line". The
   estimation-risk link sentence is now its own paragraph. Cell 42 gained blank
   lines around its display.

## Round 2 validation

- Executed in place after the cell 18 change, with no errors (about 25 s). Every
  stored text output matched the pre-round outputs.
- Codex parsed the drafts and confirmed all ten correctness items:
  - the exact covariance split, with a NumPy check to 1e-15;
  - no other use of `s²_ε`;
  - the tendency claim, as a tendency;
  - the pair in the default `Δ_tgt` table;
  - the 0.3% and 3.0% wealth gaps and the lower data risk in both pairs;
  - sample-covariance optimality (101 of 101 floors solved);
  - 1.5% extra σ at `g_target`.

  Two sentences over 25 words were split, and "mainly" was added to the answer.
- Declined Codex suggestions: commas before "where" after displays, which is
  not house style; flagging SPY, which is the fixed market index; cutting "Let's
  get started!"; rewording accepted cell 17 text; and "within 3%" in place of "a
  few percent".
- The lecture's example description and callout, and the deck line, still match.
- After the instructor marked the notebook reviewed, Codex checked the whole saved
  notebook (15 items). The round-2 diff was exactly the 11 cells, and all 21 code
  cells kept identical text outputs. Every quantitative claim matched the stored
  outputs, and the structure, links, objectives, and takeaways passed. Its one
  INCORRECT was a false positive: cell 4 names `AAPL` as the code's reference
  history, in the approved L6a Data text, not in a reading. Also declined: long
  Summary bookends (instructor preference), the standard disclaimer, commas
  before "where", a looser cell 39 caveat, and a softer cell 48 wording.
  For the cell 25 denial shape Codex flagged, the instructor chose his own fix:
  "the SIM has no term that directly links two particular firms". This was a
  markdown-only edit, so the notebook was not re-executed. The instructor then
  confirmed the notebook complete. No proposals remain pending.

## Remaining after round 2

- The frontier figure cell is still about 70 lines, mostly L6a's label placement.
- The `g_high` edge case recorded after round 1 is unchanged.
- Task 2 is still the densest section, at about 550 words.
