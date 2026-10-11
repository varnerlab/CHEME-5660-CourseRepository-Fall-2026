# L9b rebuild handoff — October 11, 2026

L9b (October 22) was rebuilt from your Fall-2025 L10a/L10b text, following
`L9b-REBUILD-SPEC.md`:

- **Who did what:** builder agents worked on separate files, each artifact got an
  independent QA reviewer (0–10, polish below 9), and the main session managed the
  build and rendered every page before reporting.
- **Scores:** every artifact closed at 9.1 or above.
- **Not committed.** The L9a files in the working tree hold another session's edits
  and are not part of this work.

## What was built

| Artifact (under `lectures/week-9/L9b/`) | QA score | Sentences from your 2025 text | Notes |
| --- | --- | --- | --- |
| Lecture | 8.5 → 9.1 | 60 of 92 (the draft had 2 of 71) | Your L10a/L10b cells, plus L9a's American-premium paragraph. Every edit is an exact-match substitution in `build_lecture.py`. |
| CRR chain example (in lecture) | 7.5 → 9.1 | 28 of 73 | End-of-day archive, `ticker = "NVDA"` variable, three Tasks. Task 3 compares American and European premiums. |
| Extrinsic-value example (in lecture), renamed `…-Example-ExtrinsicValue-…` | 8.0 → 9.1 | 42 of 64 | Same archive cell. Task 1 decomposes one contract, Task 2 runs the sweep, and Task 3 reads extrinsic value. |
| Hull example (review on your own) | 8.0 → 9.2 | 21 of 69 | The 2026 code fixes (European comparison, root node) are kept, and `pretty_table` replaces `println`. |
| Advanced CRR factors | 8.0 → 9.1 | 7 of 42 (8 of your 9 sentences, verbatim) | Your derivation is frozen. One new section, sentence/three bullets/sentence, checked with sympy. |
| Decision-rule figure (TikZ, light/dark) | page-checked | — | Your 2025 schematic, redrawn with `q` and `V̂`. At your request (October 11) it now copies the 2025 layout and colors. Positions, label sizes, and colors were measured from the PNG, the headings are regular weight, and the labels are sans. The rule inside the figure keeps your compact form, with $\mathcal{D}^{-1}\cdot\mathbb{E}_{\mathbb{Q}}(\hat V_{t+1})$, and the lecture display right below it writes out the $q$ weights. Each color has a dark-mode counterpart in `figs/theme_svg.py`. `figure/compare.png` shows the two figures side by side. |
| Deck (16 frames) | 7.5 → 9.1 | — | Mirrors the lecture. Frames 8 and 15 were re-synced after the lecture QA. 0 overfull boxes. |

The sentence counts for the examples and the advanced notebook are low because
those files carry code walkthroughs and new Tasks. In each one, the opener,
objectives, and takeaways use your 2025 wording where it fit.

## New lecture text for your edit pass

Everything else in the lecture is your 2025 or L9a text, with only the word-level
fixes listed below.

1. **Hook:** "In L9a, we priced European options, which can be exercised only at
   expiration. Standard options on stocks and ETFs are American-style and can be
   exercised at any time. What is the right to exercise early worth?"
2. **Concept Review linker:** "In L9a, we wrote the premium of an American-style
   contract as:" This is followed by L9a's `sup` display and its two sentences.
3. **L3b tie:** "This is the risk-neutral probability $q=(R_f-d)/(u-d)$ from L3b,
   with $R_f=\mathcal{D}_{1,0}(g_y)$."
4. **Recursion (Option A), after the figure:**
   - "At expiration, each node's value is the contract's payoff. Working backward,
     the American holder takes the larger of exercising now and holding for the
     future, while the European holder can only hold:"
   - The boxed AM/EU recursion.
   - "where $\hat V_{t,k}$ is the contract's value at the node with $k$ up moves in
     $t$ steps, and $S_{t,k}$ … is the share price there (L3b). The premium is the
     value at the root … The difference … is … the **early-exercise premium**."
5. **Hull reading:** "At the down node at $t=1$, exercising pays 12 USD/share,
   while holding is worth 9.46 USD/share, so the American holder exercises. That
   one decision raises the premium from 4.19 to 5.09 USD/share, an early-exercise
   premium of about 0.90 USD/share." It is followed by "The example recomputes every
   node:" and the Hull stop.
6. **Market section:** the Calls and Puts bullets you approved. The closing line
   became "Let's compute the American and European premiums of every contract in
   the chain:".
7. **Optional Advanced Material:** one bullet, "Deriving the CRR up and down
   factors".
8. **Takeaway 1, added sentence:** "The American premium exceeds the European premium
   only when early exercise pays, as for deep in-the-money puts."

The lecture QA tightened the approved Option A wording in item 4:
- It defined $\hat V_{t,k}$, which the prose had not defined.
- It cut a third restatement of "the American holder can always choose to hold",
  because the Concept Review already gives that reason.

The before/after is `previews-lecture/4-decision-rule-hull.png`.

**Word-level fixes to your 2025 text:**
- Notation: `r̄ → g_y`, and the Hull callout's `p` becomes `q`.
- "2 x time steps" → "two", "moves by" → "moves up by", and the callout's
  semicolon is split into two sentences.
- The expanded $E_V(t)$ uses $\mathcal{P}(K,S(t))$, not $\mathcal{P}(K,S(0))$,
  because the intrinsic term is at $S(t)$.
- LO2 loses "to determine optimal pricing strategies".
- "NVDA" and "AMD" are removed.
- `> __Example__` → `> __Example:__`.
- Broken `lectures/week-10/...` links now point to files in the same folder.
- Time decay moved up as the third bullet of the extrinsic-value section.

## Things found along the way

- **A rounding bug in the extrinsic sweep (fixed).** `premium(...)` rounds to four
  significant digits. That pushed deep in-the-money premiums below their intrinsic
  value, which gave negative extrinsic values for 10 of the 31 archive tickers (NVDA
  was not one of them). The sweep now prices at full precision, and an assert checks
  that every extrinsic value is at least zero.
- **A rounding artifact in the put early-exercise plot (fixed).** Rounded premiums
  moved in 0.1 USD/share steps deep in the money. Task 3 now uses full precision, so
  the largest NVDA put premium is 2.037 USD/share, not 2.0.
- **Long tables (fixed by the manager after QA).** The CRR chain example showed
  four 25-row DataFrames. Two of them were mostly rows with a `missing` implied
  volatility. Each now shows the five strikes within 5% of the share price, as in
  your L9a Example 2 decision. The plots still show every contract.
- **Risk-free rate:** $g_y = 0.0413$. This is the continuously compounded 13-week
  T-bill coupon-equivalent yield of 4.15% on October 8, 2026 (U.S. Treasury Daily
  Treasury Bill Rates). FRED's DTB3 rate of 4.05% agrees.

## NVDA results (October 8, 2026, expiration November 20, 43 days)

- **Share price:** $S_0 = 230.57$ USD/share.
- **Contracts priced:** 47 calls and 57 puts. The other 50 calls and 40 puts have
  no implied volatility in the archive.
- **Calls:** the American and European premiums are identical, both rounded and at
  full precision.
- **Puts:** all 57 have a positive early-exercise premium, the largest at the
  highest strike.
- **Market quotes:** no contract falls outside the widened quote interval.
- **All 31 tickers:** the same checks pass. The only contract outside the interval in
  the whole archive is one UNH call.

## Flags for you

1. **Takeaway 3 (your text)** says volatility affects extrinsic value. That is true,
   but neither the lecture nor the example varies volatility. I left it as is.
2. **"Discount factor" naming.** Your 2025 text and L9a call
   $\mathcal{D}_{1,0}(g_y)=e^{g_y\Delta t}$ the "discount factor". L3b, the notation
   FAQ, and the Hull example call it the "accumulation factor", whose inverse
   discounts. Nothing was changed.
3. **Advanced length:** 646 prose words without the disclaimer, against the spec's
   ~450. Your derivation alone is about 200 words, and the house objectives and
   takeaways take the rest.
4. **Decision-rule figure:** you approved everything except the figure. Its layout and colors now match the 2025 version.
5. **Outside L9b:** both L9a examples still cut the disclaimer off mid-sentence
   ("…not required for living expenses."). They are in another session's
   uncommitted L9a work, so I did not touch them.
6. **Kernel:** the `julia-cheme5660` kernelspec is not installed on this machine.
   Notebooks were executed with the `julia-1.12` override, and the declared
   kernelspec metadata is unchanged.

## Records

- **Notation FAQ:** `code/docs/faq-src/content.json` has a 13-row `L9b` table. The
  Context table gains a $V$ / $\hat V$ row, and L9b is added to the $q$ row.
  `code/docs/src/faq/notation.html` was rebuilt with Pandoc 3.1.11.1, and only that
  file changed.
- **Schedule, AGENTS.md, archive:** `LECTURE-ARTIFACT-SCHEDULE.md` (row 9b) and
  `AGENTS.md` (top entry) are updated. The drafts are archived in
  `lectures/archive/week-9-L9b-before-rebuild-2026-10-11/`, with a README and
  `SHA256SUMS`.

## Checks

- `check_l9b.py`, all groups: 186 passed, 0 failed. Two WARN lines remain, and both
  are approved: the Hull "binomial lattice but not a CRR lattice" sentence and your
  deep-in-the-money discussion question.
- All four notebooks with code were re-executed, with no error outputs.
- Every notebook was rendered as a page and read (`pages/`).

## Where to look (`build/notebook-previews/L9b-rebuild-2026-10-11/`)

- `previews-lecture/`: each lecture section against your 2025 text (green new, red
  removed).
- `pages/`: full-page renders of all five notebooks.
- `figure/compare.png`, plus the light and dark renders.
- `deck/deck-pages-01-09.png`, `deck/deck-pages-10-16.png`.
- Builders: `build_lecture.py` and the `ex-*`, `hull-*`, `adv-*` scripts. The
  checker is `check_l9b.py`, and the QA brief is `qa-brief.md`.

## Next steps

1. Review the pages. Back up the lecture for voice calibration before your hand edits.
2. Commit the L9b files through a temporary index, leaving the L9a work in the tree
   untouched.
3. Week-09 release (L9a and L9b) when you give the go-ahead.
