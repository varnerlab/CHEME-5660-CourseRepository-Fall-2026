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

## Follow-up: BlackRock profile rewrite (October 4)

The instructor asked whether this was the best BlackRock profile possible. It
was not. The October 2 version (228 words) met the checklist but read as a
product list, and its connection opened with "BlackRock sells…". The
instructor approved a rewrite ("Agree"), and the Codex fixes below were
applied with it. The profile is now 321 words, between MSCI (296) and
Bridgewater (360).

- **Opening.** "The world's largest investment manager, with more than $13
  trillion in client assets" (history page), plus the founders.
- **Panel.** Four bullets:
  - Index funds: the 2009 BGI purchase, with BGI's indexing traced to John
    McQuown's 1971 Wells Fargo fund ("one of the first index funds").
  - Allocation funds: AOK to AOA, 30% to 80% stocks in target proportions.
  - Capital market assumptions: the BlackRock Investment Institute's
    expected returns, volatilities, and correlations, read as the mean
    vector and covariance matrix.
  - Aladdin: built to manage portfolios and risk, sold since 1999.
  The Model portfolios bullet, the Cash management bullet, and the Aladdin
  Risk link were cut.
- **Connection.** Two-fund separation for investors who can lend and borrow
  freely at the risk-free rate, then the market-clearing step to the market
  portfolio (defined as every risky asset in proportion to its market
  value), approximated by a broad index fund.
- **Codex fixes applied.** "The first index fund" became "one of the first"
  because the source says "arguably". "Every stock in the S&P 500" became
  "the whole S&P 500" because IVV's prospectus allows sampling. "Fixed"
  became "target" proportions. The lending and borrowing scope was added to
  match Takeaway 3. "Bonds in place of the risk-free asset" was cut because
  bonds are risky and covary with stocks. "That business" became "BGI's
  indexing".
- **Left out on purpose.** Fink's 1986 First Boston loss (Vanity Fair, April
  2010) is for the instructor to tell in class.
- **Checks.** All 15 links returned HTTP 200 (Codex). There are no sentences
  over 25 words, semicolons, or em dashes. Only cell 4 changed, and nbformat
  validates. The deck's profile frame has not been synced yet.

## Follow-up: risk-free section polish (October 4)

The instructor asked whether "## Adding a Risk-Free Asset" (cells 5–9) was
as good as it could be. My estimate was about 8.5. The instructor approved six
fixes ("Agree"), and Codex then scored the section 9.3. Three Codex precision
fixes were applied as well. Section prose went from 671 to about 711 words,
and cells 6 and 7 each gained one display line.

- **Cell 6, CAL variance.** The variance line is now expanded with
  $\underbrace{\mathrm{Var}(g_f)}_{=0}$ and
  $\underbrace{\mathrm{Cov}(g_f,g_p)}_{=0}$, followed by a line with the
  reason "$g_f$ is constant". This matches the Concept Review.
- **Cell 6, Sharpe note.** It now explains the one-day ratio: "Each growth
  rate is a one-day log return divided by $\Delta t$. That division scales
  the excess mean and the standard deviation alike, so the slope is the
  one-day Sharpe ratio." Codex flagged the earlier "which" clause as
  ambiguous.
- **Cell 7, Setup.** $\boldsymbol{\mu}_g$ is now defined. The GMV condition
  reads "the GMV portfolio with short positions allowed" (Codex), because
  cell 3's GMV is long-only.
- **Cell 7, Derivation sketch.** Scale invariance means the gradient can be
  set to zero and the scale fixed afterward. Two display lines follow: the
  gradient (quotient rule) and T-2 (solve for $\mathbf{\Sigma}_g\mathbf{w}$).
- **Cell 7, closing.** "When T-3 has negative weights, the long-only tangent
  portfolio has no closed form" (Codex). The earlier "no closed form" was too
  absolute.
- **Cell 8.** The two-fund separation box now reads "who can lend and borrow
  freely at $g_f$". Nothing else in the subsection changed.
- **Cell 9.** "The solution at any target, rescaled to sum to one" replaced
  "any solution". The estimation-risk pointer was cut because cell 10
  repeats it.
- **Declined.**
  - Two sentences of 26–28 words (the risk-free definition and the RRFA
    stop). These were declined in the October 2 round.
  - Rewording the costlier-borrowing bullet. The instructor kept the
    financing bullets as they are in L6b.
  - Renaming SIM-3's $\mathbf{w}_{\mathcal{T}}$ to a long-only symbol, which
    would ripple into the RRFA example.
  - "Assume PD", "feasible target", the SIM-2 cap annotation, and the "linear
    growth model" qualifier. These add words for little gain.
- **Checks.**
  - SymPy confirmed the gradient, the T-2 rearrangement, T-3 satisfying T-2,
    and the $\Delta t$ invariance of the Sharpe ratio.
  - Codex parsed all 65 expressions with strict KaTeX.
  - Only cells 6–9 changed, and nbformat validates.

Codex scores after the six approved fixes, before the three precision fixes:
correctness 9.3, organization 9.6, flow 9.3, presentation 9.5, density 9.3,
overall 9.3.

## Follow-up: deck sync for the October 4 changes

At the instructor's request, five frames were synced to the profile rewrite
and the risk-free polish. The deck still has 18 pages and builds with zero
overfull boxes.

- **Company Profile.** Same opening and four bullets as the lecture. The
  connection line ends "a broad index fund approximates that fund." The
  Explore slidenote is unchanged.
- **The Capital Allocation Line.**
  - The variance line is expanded with the two `=0` underbraces and the
    reason "$g_f$ is constant".
  - "Write $w_f=1-(1-w_f)$" is shortened to "regroup", and the Sharpe ratio in
    the box is written inline, so the frame fits.
  - The Daily-data slidenote is unchanged. The lecture carries the reason.
- **The Tangent Portfolio.**
  - $\boldsymbol{\mu}_g$ is defined, and the GMV condition reads "(shorts
    allowed)".
  - The scale-invariance sentence names T-2 and links the derivation
    companion inline. A Derivation slidenote did not fit.
  - The closing line reads "When T-3 has negative weights…".
- **Two-Fund Separation.** "Who can lend and borrow freely at $g_f$".
- **The Solutions Lie on a Ray.** "The solution at any target, rescaled to sum
  to one." The estimation-risk sentence was cut.
- **Not synced.** The Objectives frame and the Concept Review's "Same means /
  Different covariance" bullets. These depend on the instructor's
  uncommitted edits to lecture cells 0 and 2.

## Release status (October 4)

The instructor chose to commit and push these changes, along with his own
edits to lecture cells 0, 2, and 3 and to both L7a examples, without tagging.
Students keep `week-07.0` for the October 6 class. The changes ship in
`week-07.1` (L7a and L7b) once the paused L7b polish round reaches 9. The
pre-commit checks passed for all five L7a notebooks: 3 objectives and 3
takeaways each, the rule placement, no dead local links, no saved errors, and
no author-machine paths.

## Follow-up: BlackRock AUM and notation link (October 5)

The profile's "more than $13 trillion" came from BlackRock's history page,
which dates it to March 2026. The instructor asked for a check. BlackRock
reported $15.3 trillion in AUM at June 30, 2026 (Q2 2026 earnings release,
SEC 8-K Exhibit 99.1). The notebook and deck now read "with $15.3 trillion in
client assets at the end of June 2026", linked to that release, and the deck
PDF was recompiled (18 pages, profile slide fits). The lecture also gained the
`__Notation:__` link to the FAQ notation page under its objectives. Both
changes postdate the week-07.0 bundle and ship with week-07.1.

## Follow-up: in-class edits merged and deck sync (October 6)

The instructor edited the lecture and both examples in his `week-07.0` bundle
copy around the October 6 class, then asked for those edits to be merged into
the repository and for the deck to be synced.

- **Merge.** A cell-level three-way merge against `ea2561b` kept the October 5
  notation link and AUM update. The profile now reads "15.3 trillion USD in
  client assets at the end of June 2026" (his "USD" form, the SEC figure).
- **Lecture changes.** The tangent section is now "What is in the tangent
  portfolio?" with shorts-allowed (T-1 to T-3, $\mathbf{w}_{\mathcal{T}}^{\mathrm{short}}$)
  and long-only (T-LO) subsections. SIM-2 is stated in excess-growth form with
  fund weights, wealth weights, and the risky fraction $\theta$. A continuation
  algorithm replaces the ray argument, so SIM-3 is no longer in the lecture.
- **Examples.** Both now use the 13 default firms unless the client-file lines
  are uncommented. The bundle's RA ticker cell had the defaults commented out,
  which fails without `my-tickers.csv`, so it was set to match the RRFA cell.
  Saved outputs come from a run without client files. Both examples were
  re-executed top to bottom with no errors and matching text outputs.
- **Deck.** Objective 1 mirrors the lecture. The tangent frame became two
  frames (shorts allowed, long-only with T-LO). The SIM-2 frame became two
  frames (the two sets of weights with the numeric example, then SIM-2 with its
  constraints). "Continuation: Finding the Tangent Portfolio" replaces "The
  Solutions Lie on a Ray". The deck has 20 pages and zero overfull boxes.
- **Not synced.** The Concept Review's "Same means / Different covariance"
  bullets stay in the deck, although lecture cell 2 no longer states them. The
  Adding a Risk-Free Asset frame keeps its shorter bullets.
- **Open.** SIM-3 is still cited in the RRFA example (cell 21 and two code
  comments), the estimation-risk notebook and its `src`/`docs` files, both L7b
  examples, and the FAQ notation source. The examples' prose still says the
  client list is used automatically when the interview files are present.
