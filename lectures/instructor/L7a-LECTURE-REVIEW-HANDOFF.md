# L7a SIM portfolios and risk-free asset lecture — polish round record

Notebook: [CHEME-5660-L7a-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb](../week-7/L7a/CHEME-5660-L7a-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb)

Polish, voice, and organization round on October 1–2, 2026, run section by
section with rendered before/after previews. This was the first review of the
lecture created by the [Week 7 refactor](WEEK-7-REFACTOR-HANDOFF.md). The
instructor accepted all five proposals and the closing fix ("Agree! Nicely
done"), then marked the lecture reviewed on October 2. The changes are
uncommitted.

## Scores

| Dimension | Before | After |
| --- | ---: | ---: |
| Technical correctness | 9.0 | 9.5 |
| Organization | 8.0 | 9.0 |
| Narrative flow | 8.0 | 9.0 |
| Presentation | 8.5 | 9.0 |
| Density | 8.0 | 8.5 |
| Company profile | 7.0 | 9.0 |
| **Overall** | **8.2** | **9.0** |

Codex scored the notebook 8.5 before the closing fix and named Takeaway 3 as
the weakest passage. Prose went from 1,929 to about 2,020 words (Disclaimer,
display math, and link targets excluded). About 70 of the added words are the
company profile, which lacked the elements the style guide requires. The
lecture went from 10 to 13 markdown cells because the risk-free section was
split by subsection.

## Accepted proposals

1. **Concept Review (cells 2–3).**
   - The SIM equation $g_i=\alpha_i+\beta_i g_M+\varepsilon_i$ is displayed,
     and $\mathcal{P}$ is defined in its lead-in.
   - $g'_i$ is defined where it is used. The mean-vector statement appears
     once, and the SIM-1 Solution no longer repeats it with an undefined
     $\mathbf{g}'$.
   - "Off the diagonal, the SIM covariance is the sample covariance with the
     residual covariances set to zero" replaced "differ mainly through". The
     $(N-1)/(N-2)$ sentence was cut. The RA example still explains it.
   - The standalone variance-split box was removed. SIM-1's labeled objective
     shows the same split, and a two-sentence reading follows the box.
   - Codex follow-ups, approved with step 2: a dangling modifier was fixed,
     and the residual-risk sentence now reads "Spreading the weights evenly
     over many assets whose residuals are uncorrelated and of similar size
     drives residual risk toward zero."
2. **Company profile (cell 4).**
   - Added Larry Fink and seven partners (1988, New York, fixed income), the
     2009 Barclays Global Investors acquisition that brought iShares, an Index
     funds bullet (iShares Core S&P 500 ETF), and Aladdin's origin.
   - Explore further is two labeled bullets, as in the MSCI profile. The
     internship line is dated: "In October 2026, the Americas summer
     internship was open to students graduating between September 2027 and
     July 2028." The videos bullet links the BlackRock YouTube channel.
   - Cut the forced second intro sentence and the lecture sentence in the cash
     bullet.
   - Codex follow-ups, approved with step 4: "sells risky funds, such as
     iShares, and short-term cash investments" replaced "offers both parts of
     a complete portfolio", because cash funds are not risk-free, and "with
     different risk tolerances" replaced a promotional phrase.
   - Sources: BlackRock's history page, the FY2009 10-K, the Target
     Allocation page, the Aladdin Risk page, and the 2027 Americas internship
     posting. All 12 links returned HTTP 200 on October 2.
3. **Opening and Examples (cells 0–1).**
   - The lead-in dropped its "We begin by… Then we…" schedule. The question
     moved beside "Let's get started!", as in L6b.
   - Objective 2 has two sentences: derive the line, identify the Sharpe
     ratio as its slope, and find the portfolio that maximizes it.
   - The client-files note is written for students: "Both examples run on the
     firms chosen in the L6b client interview, or on thirteen default firms
     when the interview files are absent." The copy commands stay in the
     Week 7 README.
4. **Risk-free section (cells 5–8).**
   - The CAL display is one step per line with a reason column: linearity,
     $w_f=1-(1-w_f)$, the variance line, the square root.
   - The section's single cell became four, one per subsection, with no
     wording change. Two-fund separation is untouched.
5. **Summary (cell 11).**
   - The opener names both input sets.
   - Takeaway 1 states the result: under the sample covariance, which the
     data-driven weights minimize, the SIM weights carry at least as much risk
     at every growth floor. This holds for any firm list because both problems
     share the mean vector.
   - Takeaway 3 has two sentences.
   - Closing fix from the final Codex check: "Investors with the same inputs
     who can lend and borrow freely at the risk-free rate hold the same risky
     fund, choosing only the risk-free fraction." The earlier "same financing
     terms" contradicted the lecture's No borrowing bullet.

## Checks

- Four Codex passes (after steps 1, 2, 3–4, and on the whole notebook). They
  verified the OLS mean identity, the exact off-diagonal decomposition, the
  SIM-1 objective, the CAL steps (SymPy), Takeaway 1 on a random five-firm
  problem at five floors, every BlackRock fact, all links, objectives and
  takeaways (three each, two sentences, no math), and rule placement.
- Every render through VS Code's KaTeX plugin had zero errors. Codex parsed all
  11 displays and 71 inline expressions with KaTeX.
- The notebook validates with nbformat. Metadata is unchanged. Joining cells
  5–8 reproduces the old cell 5 except for the CAL display.
- Starting SHA-256 prefix `433e1419c9f373ce`. Final SHA-256
  `748892ad3dfb33147ba90a586261bd49c5ba6008fad1de341a4ae0e66b5d3c8c`.

## Declined or left as is

- Three sentences run 26–29 words: the approved "Recall that…" lead-in, the
  risk-free definition carried from L6b, and the RRFA example stop.
- Codex's gerund-subject note on "Sweeping $g_\star$ upward…" (instructor
  text).
- nbconvert's HTML export prints `___` written directly under a text line as
  underscores. VS Code and Jupyter render it as a rule, and every course
  notebook uses the pattern, so this is a repository-wide question.

## Deck sync

At the instructor's request, the L7a deck was synced to the reviewed lecture
on October 2, and the instructor approved it ("Agree with changes"). It went
from 17 to 16 pages and builds with zero overfull boxes.

- Objectives: Objective 2 matches the lecture.
- Lectures and Examples: the client-files note matches the lecture.
- Concept Review: shows the SIM equation and the market/residual labels, with
  "Same means" and "Different covariance" bullets. The $(N-1)/(N-2)$ and
  positive-definite sentences were cut.
- Portfolio Risk under a SIM: the frame was removed. Its two-line reading now
  follows the SIM-1 box. The SIM-1 sentences on the frontier sweep and on
  comparing under one covariance were dropped to keep that text to two lines,
  and the instructor approved the drop.
- Company Profile: founders, iShares, four one-line bullets, the lecture's
  connection sentence, and Explore links to student opportunities, the 2027
  Americas internship, and YouTube.
- The Capital Allocation Line: the derivation is one step per line with
  reasons. The CAL box is one line with the Sharpe ratio defined beside it.
  The daily-data note moved to the slide note
  ($\mathrm{SR}^{\text{annual}}_p=\sqrt{252}\,\mathrm{SR}_p$, Sharpe 1994).
- Summary: mirrors the three takeaways and removes the deck's one clause
  semicolon.

The other frames are unchanged apart from page numbers.

## Follow-up: where the SIM inputs come from (October 2)

After the review, the instructor asked whether the Concept Review should show
where the SIM inputs box comes from. He then asked to see the diagonal term
derived ("it's hard to see where the Diagonal term is going") and to mark the
dropped terms with "underbrace = 0". Version 3 was approved ("Agree. Update.
next"). Cell 2 now runs:

- the mean, "Since $\mathbb{E}[\varepsilon_i]=0$, the residual drops out of
  the mean";
- the diagonal, $\text{Var}(g_i)$ in three lines (substitute the SIM, expand
  with $\underbrace{\text{Cov}(g_M,\varepsilon_i)}_{=0}$, second
  assumption);
- the off-diagonal, the L6b derivation with three `=0` underbraces;
- the assembled matrix equal to market plus residual, with a two-sentence
  reading: the market term fills every entry, and the residual variances sit
  only on the diagonal as $\mathbf{D}_g$;
- a lead-in to the box that replaces population quantities with
  training-data estimates.

Prose for cell 2 went from 204 to 305 words, with three new displays. The
deck's Concept Review became two frames, "The SIM Covariance" (both
derivations; the off-diagonal reasons moved to the lead-in to fit) and "SIM
Portfolio Inputs" (matrix, box, bullets). The instructor approved them. The
deck is back to 17 pages with zero overfull boxes. Codex then confirmed the
derivation (SymPy, strict KaTeX) and flagged that $\boldsymbol{\beta}$ was used before it was
defined. The instructor approved the fix: "Collecting the betas in
$\boldsymbol{\beta}$ and placing these entries in a matrix shows where each term goes:". The
deck uses a one-line form, "With the betas collected in $\boldsymbol{\beta}$, the matrix shows
where each term goes:", so that it does not wrap. Lecture SHA-256 after the change: `c6c005dc5194a0ac62c1fb0ff7ef4b519e7e9ece0166eb6eed759fa0770ce2fb`.

## Follow-up: where D_g and the portfolio variance come from (October 2)

The instructor asked two more questions. First, "is [$\mathbf{D}_g$] just the
diagonal of $\mathbf{\Sigma}_g$… why is it labeled as residual?" Second,
"where does Var(g_p) come from?? I thought we did a better job with the last
year." Both answers were approved and applied.

- **Two-matrix split (cell 2).** The matrix display now has three lines:
  - place the entries;
  - split each entry into $\sigma^2_{g,M}$ times the $\beta_i\beta_j$
    matrix plus the diagonal residual matrix;
  - name them $\sigma^2_{g,M}\boldsymbol{\beta}\boldsymbol{\beta}^\top$
    (market) and $\mathbf{D}_g$ (residual).
  The reading says that $\mathbf{D}_g$ holds only the residual variances,
  and that each diagonal entry of $\mathbf{\Sigma}_g$ has a market part
  from $\sigma^2_{g,M}\boldsymbol{\beta}\boldsymbol{\beta}^\top$
  and a residual part from $\mathbf{D}_g$. The "from …" wording is Codex's
  precision fix: the unscaled first matrix has $\beta_i^2$ on its diagonal.
- **$\mathrm{Var}(g_p)$ (cell 3).** Before SIM-1, the lecture now follows the
  2025 L8b route and carries it to the end, in five lines:
  - the L6a double sum of covariances;
  - substitute the diagonal and off-diagonal entries;
  - collect the market terms;
  - recognize the square;
  - name the portfolio beta.
  The market/residual reading now follows this derivation. SIM-1's lead-in
  says the split, with estimated inputs, is SIM-1's objective.
- **Deck.** Slide 6 shows the two-matrix split. A new "Portfolio Risk under
  a SIM" slide comes before SIM-1. With space freed, SIM-1 again has its
  frontier-sweep and compare-under-one-covariance sentences. The deck has
  18 pages and zero overfull boxes. The slide reason labels are shortened to
  fit.
- **Checks.** A combined Codex pass over both lectures ran 21 SymPy checks
  for $M=3$, and all passed. All 19 displays parse in KaTeX. Codex also
  flagged the redundant L6b Diversification bullet, which was left as is.

Lecture SHA-256 after these changes: `f619703d8804341389c5d6a6e437b6118a435028cf48af572295718cdab293ec`.
