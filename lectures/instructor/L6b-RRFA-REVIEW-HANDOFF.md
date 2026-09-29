# L6b risky and risk-free (RRFA) example — polish round record

Notebook: [CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb](../week-6/L6b/CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb)

Polish, voice, and organization round on September 28, 2026, run section by
section with rendered before/after previews. The instructor accepted all five
proposals. The changes are uncommitted. The starting findings are in the
[L6b examples review handoff](../week-6/L6b/tmp/L6b-EXAMPLES-REVIEW-HANDOFF.md).

## Scores

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 6.5 | 8.5 |
| Organization | 5 | 8.5 |
| Narrative and voice | 4.5 | 8 |
| Presentation | 5.5 | 8 |
| Density | 4 | 7 |
| **Overall** | **5.5** | **8.4** |

Prose went from 2,020 to 1,758 words by Codex's count, which excludes the
disclaimer, display math, and link targets. Paragraphs of 100 words or more
went from 8 to none outside the objective and takeaway panels. There are no
clause semicolons or em dashes.

## Accepted proposals

1. **Opening, setup, data, constants.**
   - The 69-word itinerary above the objectives became a two-sentence question.
   - The objectives are concept-level, and the second one commits to the
     common-covariance comparison.
   - A two-sentence "In this example" overview sits below the objectives.
   - Setup and data follow the approved L6a cells, with the L4b Include text.
   - Instructor correction: "the Data subsection is still a little beefy". It
     was slimmed to 110 words plus a 51-word archive paragraph, and the VWAP
     definition was dropped.
2. **Task 1, Solve the Risky and Risk-Free Problem with SIM Inputs.**
   - It opens with "In this task" and has four `###` subsections.
   - Lecture results are cited (SIM inputs, SIM-2, SIM-3), and the 210-word
     re-derivation is gone.
   - The SIM frontier is swept once, in `frontier_sim_df`, with a tangency
     check. The CAL figure uses that sweep.
   - The fixed `g_target_max = 0.60` constant was removed, and the sweep now
     ends at the largest single-firm SIM mean.
   - The ray check skips solutions with 1% or less in risky assets and
     solutions at an upper bound.
   - Added `@assert maximum(ĝ_sim) > g_f` with a message.
   - Instructor correction: "I actually prefer the fig on first version". The
     original CAL figure styling is kept (7-point labels, white solver circles,
     topleft legend). Only its data source changed. The L6a-style restyle was
     rejected.
3. **Task 2, The Tangent Portfolio.**
   - The data-driven tangent now comes from one solve of the same risky and
     risk-free problem, rescaled. It matches an independent optimum to 7e-8
     and replaces the grid search.
   - One weights table, then both portfolios scored under the sample
     covariance (β_p, E_g, σ_g, one-day and annualized Sharpe ratio,
     `σ_g_SIM`).
   - SIM 1.265 against data 1.285 annualized. The old notebook reported 1.324
     under the SIM's own covariance. The data-driven value is at least as large
     by construction.
   - Readings are generic `__What do we see?__` lists.
4. **Task 3, Complete Portfolios Out of Sample.**
   - The L6a price-matrix, wealth, and scorecard code is ported with w_f added.
     The scorecard and wealth arrays are identical to before.
   - The wealth equation has underbraces. Instructor correction: the
     risk-free label was too long, so it became `\text{risk-free}`.
   - Wealth path colors now run from mid-blue to dark, so w_f = 0.75 is
     visible.
   - Removed the cap assertion on complete portfolios. It failed for a
     single-firm list and on solver roundoff (1.00000002). The CAL formulas do
     not depend on caps.
   - Cut "exactly as the ray predicts", "it should not be expected to", and
     the unproposed denial "None of this is a recommendation…".
5. **Summary.**
   - New opener and "We…" takeaways with no default-ticker facts.
   - Takeaway 2 now describes the fair comparison.
   - The closing names next moves and links the SIM parameter uncertainty
     notebook in the same folder.

## Validation

- Executed in place after every code change, with no errors. The final run
  took 23 s.
- Alternate ticker lists ran the whole notebook without errors:
  - XOM, CVX, KO, PEP, JPM, PG, DUK
  - NVDA, INTC, F
  - KO, PEP, PG, DUK, JNJ, WMT, through Tasks 1–3 of the September 28 Task 1
    draft
- Codex checked each proposal and the whole notebook: objectives, openers,
  and takeaways agree; the structure is right; all six relative links resolve.
- Every markdown cell renders with no KaTeX errors.
- The L6b deck has no stale RRFA numbers ("1.324", "own covariance").

## Remaining for a possible later round

- Prose is about 1,760 words, above the handoff's 1,300–1,500 estimate.
  Candidates to trim: the Task 3 column bullets (L6a text), the wealth
  paragraph, and the Task 2 lead-ins.
- The SPY row shows `NaN` in the two modeled columns.
- The cell 0 lead sentence is 28 words. It was approved in proposal 1.
- The RA example was being revised in parallel. The RRFA cites it for judging
  SIM weights under the sample covariance, and for the thirteen firms. Both
  still hold as of this record.

## Round 2, September 28, 2026

The instructor asked for "another polish/narrative/voice pass to get to a score
of 9 or above". The round ran as three proposals with rendered before/after
previews, all accepted. The last was accepted with two corrections. The
instructor then marked the example reviewed ("Great! Mark this as reviewed").
It is uncommitted, like the rest of L6b.

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 8.5 | 9 |
| Organization | 8.5 | 9 |
| Narrative and voice | 8 | 9 |
| Presentation | 8 | 9 |
| Density | 7.5 | 8 |
| **Overall** | **8.4** | **9.0** |

Prose is word-neutral for the round (2,012 to 2,009 by the preview counter). The
Summary opener and the new SPY reading added about 40 words, and the other edits
cut about the same.

1. **Data and Task 1.**
   - The Data text is the approved RA wording (89 to 50 words).
   - The archive paragraph's code lead-in has its own paragraph.
   - The JLD2 link now points to `basic_usage/#FileIO-interface`. The old
     `#save-and-load` anchor no longer exists.
   - In "Choose the firms", the sentence that names `my_list_of_tickers` comes
     last, directly above the code.
   - The sweep and ray-check printouts no longer use semicolons, and the
     spread prints as `3.3e-6`. These are the round's only code changes.
     The notebook re-executed with no errors.
   - The ray-check skip sentence was joined to the paragraph above it.
   - The tangency lead-in ends "and compare the Sharpe ratios", not "and check".
   - `cal_df` and `frontier_sim_df` name their `DataFrame` type.
2. **Task 2.**
   - Retitled "Compare the SIM and Data-Driven Tangent Portfolios", because
     Task 1 already finds the SIM tangent portfolio.
   - The explanation of missing residual covariances now appears once, in the
     holdings reading. The Sharpe reading says "The gap comes from the residual
     covariances among the held firms."
3. **Task 3 and Summary.**
   - `the $k$th trading time`, which VS Code rendered literally, became "the
     time of trading day $k$".
   - `prices_2025` names its type.
   - A new "Index fund" bullet delivers the comparison Objective 3 promised:
     "Higher final wealth can come from taking more risk. Find the complete
     portfolio whose `σ_g_2025` is closest to SPY's and compare their growth."
     It replaced the Growth bullet's "Borrowing magnifies..." sentence. For the
     default firms, w_f = 0.5 (σ 2.292, growth 0.1543) has about SPY's risk
     (2.206) and grew slightly less (0.1581).
   - Instructor correction: "line break in the in this task line". The Task 3
     opener sentence now has its own paragraph.
   - Instructor correction: "tighten lead and closing sentence up a little". The
     Summary opener has two sentences, about 40 words. The closing reads "the
     tickers", "the tangent and complete portfolios", and "the tangent weights".

### Concurrent edit, recovered

While proposal 1 was in flight, the session that cut L6b's advanced notebooks
repointed this notebook's closing link from the archived SIM parameter
uncertainty notebook to the estimation-risk notebook. Saving the executed
proposal-1 draft over the file reverted that change. The other session
re-applied it within minutes, and a cell-by-cell diff confirmed that the file
held both sets of changes. Later saves applied guarded replacements to the live
file after a hash check.

### Checks

- Codex checked each proposal draft. It confirmed every correctness item. It
  flagged that "the row" could mean SPY's own row and that "every growth target"
  overstated the check, and both were fixed before saving. Declined:
  - same-sentence antecedents for "It", "these", "this list" and "that
    frontier", which point back to the sentence before;
  - splitting the cell 13 and 19 lead-ins, which match the approved RA cells;
  - a one-line Summary opener.
- All markdown renders with VS Code's KaTeX plugin, with no errors and no
  literal `$`.
- All six relative links resolve inside the L6b folder.
- No clause semicolons or em dashes.
- Only the two print lines changed in code. Outputs are otherwise unchanged
  from the executed proposal-1 run.
- The lecture's callout and example description, and the deck's two RRFA
  references, still match.

### Still open

- Codex scored the final notebook 9.1/10 on its own. It confirmed the
  objectives, openers, takeaways, numbers, lecture labels, and links. It still
  sees the residual-covariance point in three places: the holdings reading, the
  one-clause Sharpe pointer, and takeaway 2. Cutting the pointer and the second
  sentence of takeaway 2 is the candidate for a later round.
- The 28-word opening sentence was approved in round 1 and kept. Codex's
  rewording of "Small differences remain..." and of the standard disclaimer
  was declined.
- The notation `W_T` (final time) sits near `w_{\mathcal{T},i}` (tangent
  weights) in Task 3. The sibling examples use the same `W_T`, so it was left.
- The MSFT label overlaps the AAPL marker in the CAL figure. The instructor
  chose to keep the original figure look.
- The SPY row shows `NaN` in the two modeled columns, as the code comment
  explains.
