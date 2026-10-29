# Repository Working Agreements

## Week 11 shift: composite contracts become L11a — October 29, 2026

- His decision: L10b ran behind, and the class did not reach the composite
  contract material after the Akuna Capital profile. That material becomes the
  new L11a. The covered calls and cash secured puts lecture moves from L11a to
  L11b. The old L11b (protective collars, the TJUL comparison, and the Wheel
  material in `advanced/`) is archived in
  `lectures/archive/week-11-L11b-before-shift-2026-10-29/` "until we figure
  out what to do". L10b is not cut: it stays as released in week-10.2, and the
  new L11a ships in week-11.0.
- New L11a (`CHEME-5660-L11a-Lecture-CompositeContracts-Fall-2026.ipynb`):
  the L10b cells from `## Composite Contracts` through `### Why Wait to
  Expiration?` copied verbatim, except figure paths, example links, and "at
  the risk-free rate $g_{y}$" added after "accumulation factor" (the L10b
  Review, which defined it, stays in L10b). The
  title block, Examples cell, and Summary are new. The two AMD examples (put
  credit spread, strangle) are copies of the L10b ones, and the figures are
  copies renamed `Fig-L11a-*`. The deck is the L10b composite frames with new
  objectives, What You Need to Know, examples, and summary frames.
- L11b: the files were renamed L11a to L11b and their self-references (title,
  notation anchor, example links, Notes.tex) updated. Nothing else changed.
- Notation: an L11a copy of the L10b composite NPV table; the covered call and
  Delta tables relabeled L11b; Context "Where" entries updated.

## Moneyness is K/S(0), course-wide — October 25, 2026

- His decision: moneyness is $K/S(0)$, the strike price divided by the share
  price, in every lecture, example, figure, and deck. He asked why the course
  had two definitions. There is no universal one: S/K, K/S, K/F, ln(K/F), and
  standardized forms are all in use. K/S(0) won because the L9a, L9b, and L10a
  Longstaff–Schwartz examples already used it, and it is how option chains and
  volatility smiles are read.
- `Fig-L10a-Premium-vs-Moneyness` was on S/K with K = 100. It now fixes
  S(0) = 100 USD/share and sweeps the strike from 50 to 150, so each panel stays
  within 0–60 USD/share. Point b is K/S(0) = 0.85 for the call and 1.15 for the put; c is the
  reverse. The lecture cell `l10a-03` (lead-in, alt text, and "about 3.9 USD/share
  at K = 100") and deck page 9 were updated. The deck was rebuilt with 0 overfull boxes,
  and pages 9 and 12 were rendered and checked.
- Greeks example, the Delta and Gamma sweep: x axis is K/S(0) with a dashed line
  "at the money, K/S(0) = 1". The heading is now "How do Delta and Gamma change
  with the moneyness?".
- ExtrinsicValue example (his yes, same day): the Task 3 plot is on K/S(0) with
  the at-the-money line at 1. Its table gained a K/S(0) column, and the Task 1
  moneyness box now gives the ratio (a call is in the money when K/S(0) < 1).
  Payoff and profit plots against the share price at expiration are not
  moneyness sweeps and keep their axis.
- L9b check: the lecture, deck, Hull, parity, CRR-factors, and contingent-claims
  notebooks use no moneyness ratio. The American premium example already uses
  K/S(0). The advanced SPXW skew notebook filters strikes by |ln(K/F̂)| ≤ 0.20 in
  a variable named `moneyness_band`, and plots against the strike (index
  points). It deliberately works from the forward, not the index level.

## L10a POE/POP example: probabilities under our belief — October 25, 2026

- His request: the lecture says the POE and POP are forecasts under ℙ, but the
  example computed only ℚ. He chose four drift and volatility pairs in one
  table: (μ̂, σ̂) ℙ, (μ̂, IV), (g_y, IV) ℚ, and (g_y, σ̂). The new subsection
  `### Probabilities under our belief` ends Task 3. The lecture is unchanged
  ("I really don't want to change the lecture notes").
- The CSV `drift` column is the mean growth rate μ̂_g. The GBM drift is
  μ̂ = μ̂_g + σ̂²/2. The mixed pair holds μ̂ fixed, so each pair changes one
  model input.
- The ℚ simulation, KS check, Normal-IV comparison, ℚ POP table, and Delta
  tree-sum table and checks are untouched. Their outputs were identical after
  re-execution.
- `data/SAGBM-Parameters-Fall-2025.csv` in L10a was the copy from before the split
  repair (12 tickers wrong, including GOOG, which is in the options archive). It is now
  a copy of the L4b file. IWM, META, and MRNA have no row, and the data cell
  asserts that a row exists.
- Codex pre-review and audit. Rejected: relabeling ℚ as a "no-dividend
  benchmark" everywhere, and removing "the probabilities inside the market
  price" (his lecture wording). Checked against XOM (μ̂ < g_y) and GOOG
  (σ̂ far below IV). The prose holds for both.
- 252 vs 365: he asked whether to build a 365-day parameter file for options
  work. It is not needed. The training data has 251.45 trading days per calendar
  year (2,767 days over 11.0 years). Re-estimating all 424 tickers on calendar
  time changes μ̂_g by at most 0.00096/yr and σ̂ by −0.108% (the same for every
  ticker), so the file already applies to T = DTE/365. Scaling the daily standard
  deviation by √365 would overstate σ̂ by about 20%. Weekend returns are not 3
  days of variance: their median standard deviation is 1.02 times the one-day value,
  not √3. The comment in cell `l10a-pop-11` says this.

## L10b: composite contracts rebuilt — October 23, 2026

- His request: introduce composite contracts, then their NPV (not the P/L) in
  general, and cover every PS4 structure in the lecture: short put, short call,
  put and call credit spreads, short straddle, short strangle, protected
  strangle (jade lizard), and iron condor. Composite contracts were never
  taught in 2026, so the text is adapted from his 2025 L9b. The duplicate
  Concept Review is cut because L10a already teaches POE and POP.
- Order: `## Composite Contracts` (payoff with $\theta_{i}$, $n_{i}$) →
  `### The Net Present Value of a Composite Contract` (one step per line,
  underbraces naming $\mathcal{P}_{\mathcal{C}}$, $\hat{V}_{\mathcal{C}}$, and
  $\hat{P}_{\mathcal{C}}$, so $\operatorname{NPV}_{0}=\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\hat{P}_{\mathcal{C}}$),
  credit or debit, POP, POE, and "Why expiration?" →
  `## Common Composite Contracts` → the Delta section.
- "Why expiration?" uses one short-strangle figure to show the profit if we
  close early rising to the profit at expiration as extrinsic value decays. The
  legs are priced on a CRR American tree, with no BSM. He found the first
  right panel confusing ("so right panel shows if I open the position, then
  immediately close it?"). The redraw shows the credit, the buy-back cost, and
  the gap between them, and he praised it. Do not add a decay figure for every
  structure ("I don't want to do all of them").
- Catalog: each structure is a put side plus a call side, and each side is
  empty, a naked short contract, or a credit spread. "Naked" is defined
  because PS4's margin rule uses it. The overview table links each row to its
  subsection with `[..](#Heading-Text)`, which resolves in both VS Code and
  JupyterLab. Its Outlook column follows Fidelity and tastylive: neutral to
  bullish, neutral to bearish, or neutral, with the protected strangle
  "neutral, leaning bullish". Each subsection runs figure → definitions →
  profit display → a five-row table (maximum profit, then the breakeven and
  the maximum loss on each side) → a one- to three-sentence close.
- Figures: TikZ schematics in `lectures/week-10/L10b/figs/`, copying the
  5800 L9c convexity and GD/SA style. He rejected the look of the PS4
  companion's `\profitpanel` diagrams. Labels clear every line by at least
  2 pt, checked by measurement, and the strikes carry their leg labels (short
  put, long call, and so on). The decay generator is self-contained, and its
  CRR pricer was checked against the package. `figs/README.md` has the build.
- Projection rule: "we are projecting this onto a screen so the text has to be
  concise, simple and direct". After the tables went in, the catalog prose
  was cut about 27% and the intro, NPV, and Delta prose about 21%. He agreed
  to trims of his 2025 text: the intro, "Why is this interesting?", the Delta
  opener, and the hedging blockquote.
- Delta: the sums run over $i\in\mathcal{C}$, as in the NPV derivation, not
  $i=1,\dots,|\mathcal{C}|$. Delta-neutral means $\Delta_{\text{net}}(S,t)=0$
  at the current share price and time, and the closing sentence says to update
  $N_{S}$ as they move. The "for all $t\in[0,T]$ and $S>0$" wording was dropped.
- Delta of the composite contract:
  $\Delta_{\mathcal{C}}=\sum_{i\in\mathcal{C}}\theta_{i}n_{i}\Delta_{i}$ per
  share, so $\Delta_{\text{opts}}=m\,\Delta_{\mathcal{C}}$, and
  $\Delta_{\text{net}}=N_{S}+\Delta_{\text{opts}}$ stays the portfolio with
  shares. `### Delta of the Common Composite Contracts` tabulates each
  structure's $\Delta_{\mathcal{C}}$ at the ±0.25 short and ±0.10 wing
  strikes, with the shares that hedge one contract. Its sign matches the
  outlook, and a zero Delta is not zero risk. The opener now says Delta was
  already the hedge ratio of one contract, and the new step is adding up the
  legs. The PS4 companion's exposure slide wrote this per-share sum as
  $\Delta_{\text{net}}$. It is renamed $\Delta_{\mathcal{C}}$ in the PS4 repo,
  on disk, waiting for his approval to commit.
- Notation: two L10b tables (NPV, Delta) and updated Context rows in
  `code/docs/faq-src/content.json`. `notation.html` was rebuilt with the pinned
  Pandoc 3.1.11.1.
- Open: rebuild the two AMD examples on the EOD archive (they are still 2025
  data), build an L10b deck, and finish the tightening pass on the title and
  learning objectives, Examples, and Summary cells. Replacing the PS4
  companion's diagrams with these PDFs was offered, not done.
- Same day, outside L10b: the L10a "Before we do the math" callout was removed
  and its questions folded into the intrinsic and extrinsic definitions (cell
  `l10a-03`, and the deck frame deleted). That edit sits inside another
  session's uncommitted L10a work, so that session commits it.

## L10a: Leisen–Reimer moved to an advanced notebook — October 23, 2026

- His decision: cut `### The Leisen–Reimer Tree` from the lecture and put it in
  an advanced notebook linked from the lecture, because "there is just too much
  in the L10a lecture". The subsection (CRR-vs-LR figure,
  reference, construction from $\mathbb{Q}(S_T>K)=N(d_{-})$, Peizer–Pratt
  factors, Greeks pseudocode, convergence advice) moved verbatim, about 920
  words, to
  `lectures/week-10/L10a/advanced/leisen_reimer/CHEME-5660-L10a-Advanced-LeisenReimer-Greeks-Fall-2026.ipynb`,
  a derivation notebook with no code and no BSM. It is not the archived
  numerical-Greeks notebook. The only additions are the opener, objectives,
  summary, a recap of the central differences, first-use definitions of
  $k$, $h$, $\sigma$, $g_y$, $T$, $K$, and the three-line $q^{*}=q'$ step, which
  replaces the lecture's Delta-section sentence "On the Leisen–Reimer tree,
  $q^{*}$ is the second probability $q'$." The figure stays in `figs/` and is
  linked as `../../figs/`.
- Lecture: after the central differences, one sentence in his words: "For
  technical reasons, the CRR tree does not estimate $\Gamma_{\star}$ or the
  other Greeks well, so we use the [Leisen–Reimer tree](…), a modification of
  the CRR tree that gives better estimates of the Greeks." A first draft
  explained the corners and was rejected: "a bunch of bullshit that won't make
  sense to students". Lecture pointers to advanced material give the reason in
  plain words, not the mechanism. The Taylor-expansion lead-in was also
  tightened (73 → 54 words, two paragraphs). An "Optional Advanced Material" section (cell `l10a-09`)
  precedes the Summary. The second takeaway's Leisen–Reimer sentence is cut.
  `advanced/README.md` describes the notebook.
- Greeks example: the opener says "a binomial tree", and the first prose mention
  of Leisen–Reimer links to the notebook. No code changed.
- Deck: the five Leisen–Reimer frames are removed (27 → 23 pages, 0 overfull).
  The Greeks frame carries the same one-sentence pointer and the Example 2 note,
  the $q'$ sentence and the takeaway sentence are cut, and an Optional Advanced
  Material frame precedes the Summary. The Makefile no longer lists the
  CRR-vs-LR figure.
- Same day, "Why Is Delta Close to the POE?": "Could we make this more theorem
  like, and then link to an adv notebook with the full derivation - some
  students are lost in the math". The lecture now has a plain lead sentence, a
  `> __Proposition: Delta as a Probability of Exercise__` block in the L5a EMA
  format (conditions, the boxed $\Delta_c$/$\mathbb{Q}(S_T>K)$ pair, $q^{*}>q$,
  then "Where is this coming from?" with the derivation link), one sentence on
  when the gap is small, and the unchanged ℙ/American-put note. Three displays
  became one. The derivation is
  `advanced/delta_poe/CHEME-5660-L10a-Derivation-Delta-POE-Fall-2026.ipynb`:
  premium as a sum over terminal nodes (two-step unrolling), Delta via
  $q^{*}$ and $1-q^{*}$, why $q^{*}>q$, and the gap
  $q^{*}-q\approx\tfrac12\sigma\sqrt{\Delta t}$, which shifts the up-move count
  by about $\sigma\sqrt{T}$ standard deviations. No BSM. Checked on a 1001-step
  tree: the $q^{*}$ sum matches a finite-difference Delta to 6 decimals, and the
  gap is 0.034, 0.060, 0.118 at $\sigma\sqrt{T}$ = 0.09, 0.15, 0.30. Like the L5a
  companion, it is linked from the proposition and listed in the README, not in
  Optional Advanced Material. The deck's two frames became one proposition
  frame (22 pages, 0 overfull).
- **Longstaff–Schwartz symbol:** the fitted value of holding is
  $\hat{H}_{t}(S)$, not $\hat{C}_{t}(S)$, so it matches the value of holding
  $H_{t,k}$ in the L9b lattice pseudocode (lecture, deck, LSM example prose and
  table labels, `src/Helper.jl` variable and column `Ĥ`). The helper still
  reproduces the paper's fits and the 0.1144 premium. The notation FAQ has no
  Longstaff–Schwartz rows yet.
- **Extrinsic-value figure first, then the math (his request):** the section opens
  with `figs/Fig-L10a-Premium-vs-Moneyness.svg` (generator
  `figs/generate-premium-vs-moneyness.jl`): premium against moneyness $S/K$ from
  0.5 to 1.5 (his range) for an American call (left) and put (right), K = 100
  USD/share, σ = 0.30, g_y = 0.04, CRR tree h = 501, DTE 7/30/90/180/365, his gray
  shades and red dashed intrinsic value. He wants all of a figure's source in
  `figs/`: the generator has its own CRR pricer (`payoff`, `crr_premium`) and needs
  only Plots and Colors. It matches the package's `binomial_premium` to 3e-12. Points a (ATM, S/K = 1), b (ITM: 1.15 call, 0.85 put), c (OTM: 0.85 call,
  1.15 put) sit on every DTE curve. He introduces intrinsic and extrinsic value by
  reading a, b, c live, then the definitions follow. A hypothetical contract
  replaces the example's NVDA call-premium-across-strikes figure, so the lecture no
  longer re-plots an example's data. The math text is his, plus three short ties to
  the figure (red dashed line, point c, points drop as DTE shrinks). "Let's look at
  some option contracts in the market…" was cut. The deck mirrors this (slides
  9–11). The old figure frame and its deck-only "Hmmmm" line are gone. The old
  `CHEME-5660-L10a-Example-ExtrinsicValue-Fall-2026.{svg,pdf}` files are unused but
  kept.
- **"Would you ever exercise a call early?" (his point, from the figure):** after his
  "too dense, need to trim and reorg" (139 → 92 words), it is a bold-question prose
  paragraph, not a blockquote, because it sat directly on the "Review on your own"
  blockquote. The order is claim, reason, what the figure shows, then the put
  contrast. Slide 13 matches. Then reworded in plain buy/sell terms after "pays the
  strike K seems wrong … weired jargon": exercising a call means buying the shares
  at K USD/share. Sell right away and you get the intrinsic value, but the call
  curves stay above it, so selling the contract pays more. Keep the shares and you
  paid early and lost the interest, with no dividends to make up for it. The put
  (selling at K USD/share) gets its own short paragraph, and slide 13 shows the
  two call choices as bullets. A third paragraph follows (his request): "What if the
  share pays a dividend?" Exercise the trading day before the ex-dividend date (the
  T+1 cutoff, checked), receive the dividend, then keep or sell the shares. It pays
  only when the dividend is larger than the extrinsic value given up. Linked to the
  investor.gov ex-dividend glossary. Slide 14 is a three-step timeline (25 pages, 0
  overfull). Before the early-exercise paragraph, "Why do the call curves stay above
  the red dashed line?" (his question) gives two reasons against exercising today:
  pay K at expiration and earn interest on it, or walk away if the share price falls
  below K. Even far in the money, the gap is at least the interest on K (3.9
  USD/share for 365 days at 4%). Checked on the tree: the gap is never below
  K(1−e^{−g_yT}) for any S/K in [1, 1.5] at any of the five DTEs. Slide 13 is "Why the
  Call Stays Above the Red Line" (26 pages, 0 overfull). Then tightened for
  projection ("make sure the text is *tight*"): every sentence added today, 552 → 408
  words, with short sentences and numbers in parentheses. His own sentences
  (definitions, "worthless" callout, time decay) are unchanged, and the deck matches.
  His hand reorg (saved in the session scratchpad as L10a-lecture-jeff-reorg.ipynb):
  time decay, then three bullets ("worthless", why above, call early), then a loose
  put paragraph and a bold dividend question. He said "still not quite right". Fix:
  three question bullets, each answered once: "worthless" (his text), "Would you
  ever exercise a call early?" (absorbs the why-above reasons and the ≥ interest
  floor), and "Would you ever exercise a put early?". The close is "A dividend
  changes the answer for a call…" (239 → 207 words). Deck: slide 12 puts time decay
  before "worthless", and the why-above and call frames merged into "Would You Ever
  Exercise Early?" (call and put above the figure, takeaway below). 25 pages, 0
  overfull. History:
  after the time-decay paragraph. Without dividends the call curves stay above the
  intrinsic value deep in the money (exercising pays $K$ early and gives up its
  interest, the framing of his L9b OCC paragraph), so an American call has the
  European premium. Deep ITM puts meet the intrinsic value and are exercised early.
  This also sets up the Delta proposition's "a call on a share that pays no
  dividends". Checked on the tree: American call = European call to 0.0 at all five
  DTEs, the gap at S/K = 1.5 is at least the interest on K (0.08 at 7 days, 5.0 vs
  3.9 at 365), and puts sit on the intrinsic value for S/K ≤ 0.91 (7 days) down to
  0.67 (365 days). The deck has a matching slide 12 with the figure repeated (23
  pages, 0 overfull).
- **Never start a sentence with a bare symbol (his hard rule):** "Delta $\Delta_{\star}$ and
  Gamma $\Gamma_{\star}$ play the roles…" in the lecture and deck. Two more deck
  lines followed his own lecture wording: "Delta is often used…" and "because
  $u>e^{g_{y}\Delta t}$, $q^{*}>q$". The platform-units sentence was still unclear
  ("what?"), so it now plugs the units into the expansion: one day is
  $\Delta t=1/365$ years, so the premium changes by $\Theta_{\star}/365$, and one
  percentage point is $\Delta\sigma=0.01$, so it changes by $\nu_{\star}/100$
  (or $\rho_{\star}/100$). Platforms quote these as Theta, Vega, and Rho. Acronyms count
  too: "The POE and POP are forecasts…" (lecture and deck) and "The POP reads…" (deck
  summary). A scan of the whole L10a folder
  (lecture, examples, advanced, deck) is clean. The rest of the course has 166 hits
  (not fixed).
- **Secret Lives of Delta reordered (moves only, his question):** the section now runs
  POE definition (with the $\Delta\approx$ POE conjecture) → "Why Is Delta Close to the
  POE?" → "Computing POE and POP by Simulation", which now opens with the POP
  sentence and definition → Example. Before, POP and the simulation sat between the
  conjecture and its answer. "The last example notebook" now links the Greeks example.
  The deck mirrors this: a POE frame, then Why, then a new POP frame, then the two
  pseudocode frames. The Example 3 link moved to the last one. 25 pages, 0 overfull.
  He then agreed to cut "(composite or single)" from the POE and POP definitions and
  the composite-contract POP case from pseudocode step 4 (lecture and deck). Composite
  contracts are taught in the next lecture, which defines their POP itself.
- **Key Takeaways tightened (his request):** 253 to 195 words, "We…" voice, no symbols.
  The early-exercise result (no early call exercise without dividends, deep in-the-money
  puts) was added. The volatility claim was dropped because the extrinsic section never
  shows it. Delta is now "close to the risk-neutral POE for short-dated contracts",
  matching the Proposition. The deck Summary mirrors it.
- **LSM example prose tightened (his request, after approving the step-2/step-1 lead-ins):**
  33 word-level cuts across 12 markdown cells (prose 1747 to 1635 words), code untouched.
  The step lead-ins now read "At $t=2$, paths … are in the money". The premium sentence
  now says the premium is the larger of the average and the payoff today. The early-
  exercise takeaway now uses plain buy/sell wording ("selling the shares at the strike
  price early pays").
- **POE-POP call example prose tightened (his request, after approving the LSM pass):**
  19 markdown cells, prose 2674 to 2181 words. Code, displays and links are unchanged (verified).
  The sample(...) bullets became prose, the POP callout is two one-line cases, and
  display lead-ins stand alone. A "≥ K+ε" vs "> K+ε" mismatch is fixed. The
  `d_gbm::LogNormal{Float64}`, `d_IV::Normal{Float64}`, `POE::Float64` and
  `P_OTM::Float64` types are now named. Summary closer de-jargoned.
  Second pass ("still some long text"): 2181 to 2083 words. The sample(...) cell is now 4 short
  sentences, and the Data, Scenario, Constants, build and POE/P_OTM lead-ins are trimmed.
- **Tightening pass on the remaining L10a notebooks (his request):** code, displays and links
  unchanged, verified against the backups.
  - Greeks example: 3319 to 2707 words (−18%). Put Greeks now name `name::Float64`, and
    takeaway 1 says the tree matched the archive except the American put's Rho (−0.114 vs −0.134).
  - ExtrinsicValue example: 1227 to 1056 (−14%). Takeaway 3 says deep-ITM calls keep at
    least the interest on the strike price, not "little extrinsic value".
  - Delta-POE derivation: 1079 to 961 (−11%). The reused $k$ in $\mathcal{O}(\Delta t^{k})$
    is gone.
  - Leisen–Reimer advanced: 1335 to 1261 (−6%), with $u$ and $d$ now defined before use.
  - Both advanced notebooks kept every step and its reason, so they stayed short of the
    22% target.
- **Taylor expansion, Delta and Gamma collected (his question):** the derivation align
  gains a third line, $=\bigl(\Delta_{\star}+\tfrac{1}{2}\Gamma_{\star}\Delta S\bigr)\Delta S+\nu\Delta\sigma+\Theta\Delta t+\rho\Delta g_{y}$,
  with underbraces labeling each term by its input: share price, volatility, time,
  rate. "Risk-free rate" was too wide and left a gap, so it became "rate". He wrote $\Gamma\Delta S$, and the
  ½ is required. One added sentence says the factor is about the Delta halfway
  through the move ($S+\Delta S/2$). The 0.50/0.02 example now uses the collected
  form (0.55×5 = 2.75, 0.45×(−5) = −2.25), and the deck's slides 16–17 match. The
  Greeks example's hedging cell keeps the two-term form, because its argument
  ("the hedge cancels the Delta term") needs the terms apart.
- **Think-pair-share on points a, b, c (his request):** a `> __Before we do the
  math:__` callout right after the figure: "Take a minute on your own, compare
  answers with a neighbor, and then we'll share", then three titled questions.
  Each one is answered by text that follows, so the notebook still reads alone.
  *Exercise now* leads to the intrinsic value (red dashed line). *The rest of the
  premium* leads to the extrinsic value, largest at a, and time decay. *Far from the
  strike* leads to the early-exercise callout. One new answer sentence after the
  OTM edge case: "At the money (point a), the intrinsic value is also zero, and the
  extrinsic value is the largest of the three points." The plain label replaces
  "think, pair, share". Deck: slide 10 "Before We Do the Math" holds one-line
  questions and the figure. Slide 12 folds point a into the OTM sentence to fit (24
  pages, 0 overfull). No earlier course lecture has an in-class activity format,
  so this is the first one.

## L10a: no BSM with American contracts — October 22, 2026

- The instructor's rule: Black–Scholes–Merton is for European contracts only.
  "If we are using american contracts, then BSM has no place." Material about
  American contracts uses the tree or simulation, with no $N(d_{\pm})$, BSM
  Greeks, or BSM curves for comparison.
- The L10a advanced notebook, Numerical Greeks on binomial trees, is archived in
  `lectures/archive/week-10-L10a-advanced-cut-2026-10-22/`, and L10a had no
  advanced material until October 23 (see above). Its Leisen–Reimer tree is built from $d_{\pm}$, and its
  Task 3 overlays BSM curves on an American put. The lecture's link paragraph
  and its "Optional Advanced Material" section are removed, as are the matching
  sentence and frame in the deck. Do not restore the notebook.
- Same day, at his request, the lecture gained three subsections, all without
  BSM. He accepted $d_{\pm}$ for Leisen–Reimer, introduced as the GBM
  probability $\mathbb{Q}(S_T>K)=N(d_{-})$, derived step by step:
  - `### The Leisen–Reimer Tree` (Greeks section): why repricing the CRR tree
    fails (corners in the premium), the construction, and pseudocode for the
    Greeks in his 2025 format (Initialize, loop line with __do__, Output).
  - `### Computing POE and POP by Simulation`: GBM under ℙ (our forecast),
    the sample CDF, POE at $K\pm0.01$, POP at $S^{\ddagger}$, in the same format.
    With $\mu=g_y$ and the implied volatility, the same steps give ℚ.
  - `### Why Is Delta Close to the POE?`: on the CRR tree, a call's Delta is
    exactly the POE with up probability $q^{*}=q\,u\,e^{-g_{y}\Delta t}$
    (checked to 6 decimals), and Leisen–Reimer's $q'$ equals $q^{*}$.
  The POE box is back to his 2025 wording. He asked for a figure showing why
  CRR Greeks fail and Leisen–Reimer Greeks do not, because the text alone did
  not explain it. `figs/Fig-L10a-CRR-vs-LR-Delta` (rebuilt by
  `figs/generate-crr-vs-lr-delta.jl`) now sits in "What goes wrong on the CRR
  tree?": the premium against $S_0$ (CRR straight pieces joined at corners,
  three central-difference points on one piece), and Delta below it (CRR flat
  steps). He did not understand a first version with terminal-node panels.
  The premium-and-Delta version was "Better".
- Follow-up the same afternoon, committed and pushed the same day in four
  commits (deck, examples, notation, notes deletion). The record is in `build/notebook-previews/L10a-open-items-2026-10-22/`, which holds
  the score brief, the reviewer reports, and the page renders.
  - Deck: 27 pages, 0 overfull. The BSM sentence is gone. New frames cover the
    figure (stacked PDF), the Leisen–Reimer construction (two frames), the Greeks
    pseudocode (two), the POE/POP pseudocode (two), and Delta as a POE (two). The
    POE and POP frames are merged. Example 2 and Example 3 now sit where the
    lecture stops for them.
  - Greeks example: `method = :leisen_reimer` with odd $h=20\cdot\text{DTE}+1$
    and $\epsilon_S=0.01S_o$. The BSM check is now "Check: Do the Greeks stop
    changing?" ($2h+1$ levels, steps halved, 0.5%). Types and library links are
    added.
  - POE/POP example: the tree sums with $q^{*}$ and $q$ (CRR, $h=10{,}000$)
    replace $N(d_{\pm})$. At $h=1000$ the sums swing by about 0.012 with the
    parity of $h$. At $h=10{,}000$ the swing is about 0.003. The breakeven is now
    $S^{\ddagger}$ with $\mathcal{D}$.
  - Longstaff–Schwartz example: the European premium comes from the same CRR
    lattice instead of BSM.
  - Notation: L10a gains $d_{\pm}/N$ (with no BSM), $H(z;h)$, $q'$, $\hat F$,
    $S^{\ddagger}$, $q^{*}$, and $\epsilon_x$. A context row covers the
    meanings of $H$. Built with Pandoc 3.1.11.1.
  - Fresh-reviewer scores, before → predicted after the applied fixes (the
    predictions were not re-scored):
    - deck: 8.3 → 8.8
    - Greeks: 8.7 → 9.2
    - POE/POP: 8.6 → 9.2
    - Longstaff–Schwartz: 9.1 → 9.4
- His decisions on the follow-up (same day):
  - Slide 16 keeps the stacked figure and its three labeled items. He was shown
    the side-by-side deck copy, which moved the text into one paragraph under
    the figure, and said "I actually like the before => the prose is bad on the
    proposed slide". Do not re-propose it.
  - Helper functions: "If 𝒫 and backward_step! are more than one line, they need
    to go into a ..../src/Helper.jl file." `lectures/week-10/L10a/src/Helper.jl`
    now holds `𝒫`, `show_value`, and `compare_greek` (Greeks example) and
    `backward_step!` (Longstaff–Schwartz example). They are written in beginner
    syntax, with docstrings and with every input passed explicitly (the old
    versions read notebook globals). `Include.jl` loads the file. One-line
    definitions such as `𝒟`, `V`, `exposure`, and the `hold` rule stay in the
    notebooks.
  - The legacy `docs/` notes (`Notes.tex`, `Notes.pdf`, `Makefile`,
    `varnernotes.sty`) are deleted: "Delete notes => yes".

## L9a carryover into L9b — October 20, 2026

- L9a class (October 20) stopped at the Monte Carlo premium. At the
  instructor's request, L9b (October 22) opens with the Monte Carlo material as
  a Concept Review, then teaches the Black–Scholes–Merton material, then the
  existing American-options lecture. As in the earlier carryovers (L6a into
  L6b, L8b into L9a), L9a's text is ported nearly verbatim, and L9a itself is
  unchanged apart from links.
- Lecture, in order:
  - The BSM example stays in L9a. L9b links it as `../L9a/...` first in the
    Examples list, in the Concept Review, and at the end of the BSM section.
  - `## Concept Review: A Monte Carlo Premium` (cell `l9b-cr`, before the OCC
    profile): a new opener question and two sentences, L9a's boxed European
    premium with a where-clause, the Monte Carlo paragraph, pseudocode, and
    contingent-claims pointer verbatim, the example stop, and the L9a deck's
    "estimate" sentence as the closer.
  - `## Black–Scholes–Merton (BSM) Premiums` (cell `l9b-bsm`, after the
    profile): L9a's BSM, implied-volatility, bisection, and SPXW callout text
    verbatim, with the H3 promoted to H2. The second
    example stop reads "Let's return to the example of European option
    pricing." L9a's American teaser blockquote is not ported, so the American
    section now says "We write the premium of an American-style contract as:"
    instead of "Previously, we wrote".
  - Put–call parity is not taught in the lecture (his call, the same day: the
    lecture is pressed for time, and parity holds only for European contracts,
    which the class will not trade). L9a's parity text moved verbatim to
    `CHEME-5660-L9b-InterestingFact-PutCallParity-Fall-2026.ipynb` in the L9b
    folder, a two-cell notebook in the shape of his 2025 OriginStory notebook
    (question cell, then `## Derivation`). It is not in the Examples list. The
    lecture links it in one "__Interesting fact:__" sentence that states the
    relation, and he points it out in class. The contingent-claims and SPXW
    notebooks now link it instead of "the lecture's put–call parity". It was
    not folded into the contingent-claims notebook, which is already long.
  - Three objectives and takeaways: LO1 ("Distinguish between European and
    American options") is replaced by "Price European options with the
    Black–Scholes–Merton model". The BSM takeaway is new, and the old lattice
    and Hull-decision takeaways are merged. The title gains "Black–Scholes–Merton
    Premiums and" and shortens "Cox, Ross, Rubinstein (CRR)" to "CRR". The text
    above the objectives is unchanged.
- Advanced: `contingent_claims/` and `spxw_volatility_skew/` moved from
  `L9a/advanced/` to `L9b/advanced/`, and the notebooks were renamed
  `CHEME-5660-L9b-Advanced-*`. Their lecture links point to L9b. In the
  contingent-claims notebook, "The bet in the lecture's Concept Review" became
  "Previously, we priced a bet that pays one dollar", and "(the Concept Review
  bet)" became "(the bet above)". The SPXW notebook re-runs from its new folder
  with the same outputs. `L9a/advanced/` is gone. L9a's lecture, BSM example,
  `Include.jl` comment, and deck now link to `../L9b/advanced/`.
- Deck: L9b has two Concept Review frames and the eight BSM, implied-volatility,
  and parity frames from the L9a deck. The parity frame's deck-only σ sentence
  and the advanced material is split over two frames. The two parity frames
  became one "Interesting Fact: Put–Call Parity" frame. At his request ("put a
  little bit more meat there") it carries the payoff identity, the parity
  derivation, the boxed result, and the European-only line: 29 pages, 0 overfull. The
  L9a deck changed only in its links (35 pages).
- Longstaff–Schwartz moved to L10a (same day, his "Agree" after he asked whether
  L9b was excellent and the answer was "not yet": L9b had 3,859 words, four
  pseudocode blocks, and five example stops, against L9a's 4,056 words, which
  did not fit in one class). The section, its example (now
  `CHEME-5660-L10a-Example-LSM-Premium-Fall-2026.ipynb`), and its three slides
  now open L10a, right after the Susquehanna profile, as
  `## Monte Carlo Pricing of American Options`. In L10a, `Distributions` also
  exports `sample`, so the example calls `VLQuantitativeFinancePackage.sample`,
  as the POE/POP example does. It re-runs from L10a with identical outputs.
  - L9b: objectives are BSM, his "Distinguish between European and American
    options", and CRR. Takeaways are BSM and his original lattice and
    decision-rule takeaways. The opener now says European options were priced
    by Monte Carlo simulation and are priced today with the BSM formulas. The
    title drops "Style" and "Contracts". The second BSM-example stop is one
    sentence with a plain link, and the American where-clause no longer
    re-defines $K$, $T$, and $g_y$. L9b deck: 26 pages, 0 overfull.
  - L10a: the first objective and takeaway merge Longstaff–Schwartz with
    intrinsic and extrinsic value. The title gains "Monte Carlo Pricing and".
    The opener and three body sentences lose their lecture-number references
    ("In L2b", "In L9b", "(L9b)", "the L9a ... formulas"). Deck: three
    slides added, examples renumbered (and "Example 2 checks it" now points to
    the POE/POP example, Example 4), 20 pages, 0 overfull.
  - L10a timing (reviewers estimated about 80 minutes): at his request, the
    extrinsic-value example is "review on your own" in the Examples list, its
    in-lecture stop, and the deck (Examples 1–3 are now Longstaff–Schwartz,
    Greeks, and POE/POP). Its figure stays in the lecture.
  - FAQ: the Longstaff–Schwartz rows moved to a new L10a table, "Monte Carlo
    Pricing of American Options". $M$ moved to the L9b European table.
- Scoring (fresh reviewers, reports in
  `build/notebook-previews/L9b-carryover-2026-10-20/score/` and `score2/`). Round 1:
  L9b lecture 8.8, L9b deck 8.8, L10a lecture 8.8, L10a deck 8.6, with fixes applied.
  One fix was declined: cutting the Concept Review's "alternative way"
  contingent-claims pointer, which he kept on purpose in L9a. His timing
  decisions came next. L9b opens the BSM example once (Approach 1 in class,
  Approach 2 and Task 3 review-on-your-own), and L10a's extrinsic example is
  review-on-your-own. Round 2:
  - L9b lecture with the parity notebook: 9.1, about 75 minutes.
  - L9b deck: 8.9. Slide 7 wrongly dated the 0.01 USD auto-exercise threshold to
    1977, and that is fixed, along with the Approach labels on the example notes.
  - L10a lecture and deck: 8.9 each, about 70 minutes. The fixes were the review
    box above its lead-in, the opener split into two questions, a shorter slide
    title, and $S_T$ defined on the POE slide.
  The round-2 fixes are applied and were not scored again (predicted 9.2).
- After going through the L9b slides, he called slide 5 (the Concept Review lead)
  "too dense". It is now a bold question, two labeled one-line items
  ("Previously", "Under ℚ"), a one-line lead, the box, and a where-line. He
  approved it ("Agree") and said the rest of the deck "looks pretty good". The
  BSM example stays in L9a and runs from there.
- FAQ: L9b has a second notation table, "European Premiums by Monte Carlo and
  Black–Scholes–Merton". The American table gains $\tau$, and its $M$ row
  covers both Monte Carlo methods. Built with the pinned Pandoc 3.1.11.1.

## L10a rebuild — October 12, 2026

- On October 12, the instructor found the uncommitted October 11 Codex update of
  L10a (October 27) poorly organized and below the rigor of the other lectures,
  with no company profile. It was rated 5/10: it kept 32 of 125 sentences from
  his Fall-2025 L11a lecture. At his request, L10a is rebuilt from that text,
  following [the L10a rebuild spec](lectures/instructor/L10a-REBUILD-SPEC.md).
  The Codex files are archived in
  `lectures/archive/week-10-L10a-before-rebuild-2026-10-12/`.
- Do not use the retained `docs/Notes.tex` legacy notes as a source. The
  instructor called them stale; the source is the Fall-2025 repo (2026 L10a is
  2025 L11a).
- His decisions: Leisen–Reimer, the central-difference convergence study, and
  the BSM Greek formulas move to
  `week-10/L10a/advanced/numerical_greeks/`. The lecture states only the
  central-difference repricing rule. The company profile is Susquehanna
  International Group. Both examples move to the end-of-day options archive and
  drop the ticker from their file names. The probability of exercise (POE)
  keeps its name, so the link to L10b holds.
- The package code from the Codex session (`binomial_premium`,
  `binomial_greeks` in `code/src/BinomialSensitivities.jl`) is kept.
- October 16: at his request, L9b's intrinsic and extrinsic value section moved
  here. It replaces the Concept Review and now follows the company profile, so
  L10a teaches the section instead of reviewing it. The example is now
  `CHEME-5660-L10a-Example-ExtrinsicValue-Fall-2026.ipynb` (its figure was
  renamed to match, and its outputs are unchanged). To keep three objectives and three
  takeaways, the Delta and POP/POE items were merged, since both come from the
  Delta section. The $E_V(t)$ notation row moved to the L10a table.

## Completed L8b review — October 12, 2026

- The instructor marked the week-8 material reviewed on October 12, 2026.
  This covers the L8b lecture, deck, bet figure, both examples, the tangent
  algorithm notebook, the SIM reference, the CES companion, and the interview.
  L8a is the Fall Break and has no lecture.
- A Claude and Codex re-score of every artifact found two L7b copy defects
  ("the next example" in the CAL example, "week 7 examples" in the SIM
  reference) and one wording fix in the lecture ("its discounted expected
  payoff"). After the fixes every artifact scores at least 9. The
  [L8b build handoff](lectures/instructor/L8b-BUILD-HANDOFF.md) records the
  scores, the deductions set aside, and three small items left for his manual
  pass (deck frame 18, "halve" in the interview, the algorithm heading).
- He will do a manual pass on October 13 and then make the week-08 release.
  The lecture is backed up in
  `lectures/instructor/voice-calibration/L8b-Lecture-Utility-Allocation-Bets/`
  for the comparison afterward. Do not restart the review unless he asks.

## Completed L9a materials review — October 11, 2026

- The instructor marked all L9a materials reviewed and complete on October 11,
  2026: the lecture, both core examples, the contingent-claims derivation,
  the SPXW volatility-skew example, and the companion slides. Final Codex
  scores are 9.1 for the lecture, payoff/profit example, and slides, and 9.0
  for the BSM example and both advanced notebooks.
- The approved updates clarify replication and event-contract pricing, state
  BSM assumptions before the formulas, and organize the SPXW example into
  three tasks with price checks before inversion and repricing afterward.
  The SPXW content and calculations, including the Yahoo comparison, are kept.
- The [saved review record](lectures/instructor/L9a-REDESIGN-HANDOFF.md)
  records the changes, verification, final scores, and reviewed snapshot.
  No proposals remain pending. Read it before follow-up work; do not restart
  the review unless the instructor requests another round.

## L9b rebuild — October 11, 2026

- The August–September L9b drafts were rated about 5/10. The lecture had kept 2
  of its 71 prose sentences from the instructor's Fall-2025 L10a and L10b text.
  At his request, L9b (October 22) is rebuilt from that text, following
  [the L9b rebuild spec](lectures/instructor/L9b-REBUILD-SPEC.md). The drafts
  are archived in `lectures/archive/week-9-L9b-before-rebuild-2026-10-11/`.
- His decisions: rebuild from 2025, and teach the Hull tree in the lecture from
  the figure (the Hull notebook is review-on-your-own). The decision-rule
  schematic is redrawn in TikZ. Option A adds about 180 new words inside his
  sections. The market section is written as sentence, three bullets, sentence.
- Standing preference, set the same day: write sentence, {bullets}, sentence
  instead of a long text passage whenever the content allows.
- The lattice node value is `V̂_{t,k}`, from his 2025 figure, so `V` keeps its
  L9a meaning (the payoff). The market examples use the end-of-day options
  archive, and the ticker is a variable. The extrinsic-value example is renamed
  without "NVDA".
- Later the same day, at his request, a Longstaff–Schwartz section was added
  after the Hull example. It mirrors L9a's Monte Carlo and comes with an
  in-class example, `CHEME-5660-L9b-Example-LSM-Premium-Fall-2026.ipynb`. He
  approved the section text from a preview. The package pricer
  `premium(contract, ::MyLongstaffSchwartzContractPricingModel)` was wrong and
  is rewritten in `code/src/Longstaff.jl`. `code/test/test_longstaff.jl` pins
  the paper's 0.1144 and its GBM benchmark of 4.478. He kept the Hull example
  as the hand way into CRR.
- October 16 voice pass, approved ("This looks great! Agree"). He had rated the
  lecture 4: CRR was framed as a Concept Review although this lecture first
  teaches it, there was no company profile, the risk-neutral probability came
  from nowhere, and the text was choppy with too many bullet-only sections.
  The fix follows his 2025 L10a outline: one H2, "American Style Options
  Contracts", with H3s for the CRR lattice (q derived from the risk-neutral
  expectation and tied to the no-arbitrage q of the lattice lecture), the
  decision rule and Hull, the market chain, then Longstaff–Schwartz. The
  market section now precedes Monte Carlo. The calls/puts bullets became prose,
  and the company profile is the Options Clearing Corporation. A Concept Review
  is only for material a previous lecture actually taught.
- Later on October 16, he asked whether the CRR $\sigma$ should be $\sigma_g$.
  It stays $\sigma$: the GBM diffusion volatility (units yr^-1/2), the same
  $\sigma$ as in BSM, with $\hat\sigma=\sigma_{\mathrm{ann}}=\sqrt{\Delta t}\,\sigma_g$.
  The 2025 wording "implied volatility of the growth rate" pointed students
  to $\sigma_g$ and is gone from the lecture, the deck, the advanced CRR-factors
  notebook, and the FAQ. At his request, a "Historical or implied volatility?"
  blockquote follows the u/d box. It is built on his 2025 L6a covariance-example
  text, and it closes with the back-of-the-envelope range
  $S_{\pm}\approx S_0(1\pm\text{IV}\sqrt{T})$. The deck has two matching
  frames, for 22 pages.
- Same day, at his request ("super picky about formatting"), the lecture gained
  pseudocode for CRR (after the boxed recursion, before Hull) and
  Longstaff–Schwartz (in place of the Simulate/Regress/Decide bullets, whose
  labels moved into steps 1, 3b, and 3c). The format copies the 5800 Fall-2025
  Jacobi notebook, 5820 K-means/Perceptron/Hopfield, and L3b/L4b:
  `__Initialize__: Given ... Compute ...`, numbered steps, explicit
  `For ... __do__:` lines, `- a.` sub-steps, `If ..., __then__:`, and `\gets`.
  The LSM steps discount cash flows one date at a time, like the example and the
  package. The deck has a CRR pseudocode frame and a Longstaff–Schwartz frame
  (Initialize on the intro frame), for 24 pages. In vnslides, a `{\small ...}`
  group around an enumerate blanks the frame body, so split the frame instead.
- Later on October 16, at his request ("just move this"), the intrinsic and
  extrinsic value section, its example, and its deck frames moved to L10a. L10a
  had repeated the section as a Concept Review. L9b keeps three learning
  objectives (CRR and Longstaff–Schwartz are now separate) and three takeaways
  (the first one was split into three). The new closer answers the opening question: "The
  early-exercise premium is what the right to exercise before expiration is
  worth, and the lattice and simulation give two ways to compute it." The cut
  handoff was "With both methods in hand, let's now explore what drives the
  value of American options." The file name still says
  Intrinsic-Extrinsic-Value. The Hull example still defines $E_V$ at the root
  on its own.
- Same day, a polish pass he approved ("Agree") from previews in
  `build/notebook-previews/L9b-polish-2026-10-16/`. The fresh reviewer scored
  8.6, then 8.9, then 9.4. The changes:
  - The payoff, $K$, $T$, $g_y$ and $\mathbb{Q}$ ("the risk-neutral pricing
    rule", from L9a) are now defined at first use.
  - The $q$ derivation shows one step per line.
  - $\hat\sigma$ is dropped from the historical-volatility formula, because L9a
    uses $\hat\sigma$ for implied volatility.
  - A connective sentence now follows each closing blockquote. Two sentences
    moved instead of new ones being added.
  - The Longstaff–Schwartz lead says why a regression is needed ("each path
    has only one future"), and $\hat C$ is "the value of holding", no longer
    "the continuation value".
  - Takeaways 2 and 3 no longer repeat their labels, and the example
    descriptions mention the early-exercise comparison.
  The pass adds a net 30 words, mostly the definitions. The reviewer's other
  suggestions were declined: IV becomes $\hat\sigma$ (he asked for IV), the
  Simulate/Regress/Decide labels and the "How can we use it?" bullet go (both
  approved), $\Delta t$ in $\sigma_{\mathrm{ann}}$ is renamed (he asked for
  it), and the title changes.
- Later on October 16, at his request, the "Historical or implied volatility?"
  blockquote, its two deck frames, and its FAQ notation rows moved to L9a,
  which defines implied volatility. In L9a it sits between "Which volatility
  $\sigma$ should we use?" and the bisection pseudocode, with $S(0)$ for
  $S_{0}$. The sentence naming CRR is cut. L9b keeps "$\sigma$ is the same
  volatility as in geometric Brownian motion and the Black–Scholes–Merton
  formula". The L9a deck is now 32 pages and the L9b deck 20.
- October 19: he rated the advanced CRR-factors notebook 2 or 3. Its 2025
  derivation set the up probability to one half and credited that choice to
  CRR. In fact, CRR (1979, Section 5) keep $ud=1$, choose the up probability to
  match the mean, and accept a variance shortfall that vanishes as the step
  shrinks. The $q$ section stated its expansions without deriving them. The
  rebuild, approved from the previews in
  `build/notebook-previews/L9b-crr-factors-rebuild-2026-10-19/` ("Looks
  correct"; he will work through the math himself), matches both the mean and
  the variance. It keeps the leading term to get $u$, $d$, and
  $p=\tfrac12(1+(\mu_g/\sigma)\sqrt{\Delta t})$, the formula in the L4b
  lattice-limit notebook. It derives the $q$ expansion and the moments under
  $\mathbb{Q}$ one step per line. At his request, it works with the one-step
  growth rate $g$ of L3b and L4b instead of the log return, with
  $\mathrm{Var}(g)=\sigma_g^2=\sigma^2/\Delta t$. The lecture's advanced
  bullet, the advanced README, and the deck frame match. Codex scored the
  rebuild 9/10, against 6 for the old version.
- October 19, later: he asked for every L9b artifact below 9 to be fixed.
  Six fresh reviewers scored rendered pages:
  - lecture 8.8, deck 8.6, advanced notebook 8.7
  - AmericanContractsPremium 8.4, Hull 8.8, LSM 8.7
  - advanced README 9.2, figures 9.2

  He approved the fixes from the previews in
  `build/notebook-previews/L9b-score-2026-10-19/previews/` ("Agree"). The
  reports, the fix script (`apply_fixes.py`), and the updated checker are in
  the same folder. The fixes:
  - **Lecture:** "on binomial lattices" replaces "on the CRR lattice" in his
    Oct 19 handoff, since Hull's tree has $ud=0.96$. Both Longstaff–Schwartz
    descriptions now mention the strike sweep. At his request, a short summary
    of how CRR get $u$ and $d$ sits before the box: the two-point growth rate
    $\pm a/\Delta t$, the mean and variance matched to GBM,
    $a^2=\sigma^2\Delta t+\mu_g^2\Delta t^2$, and the first term kept.
  - **Notation page:** the Longstaff–Schwartz rows now use his renames ($h$,
    $Y_i(t)$, $\hat C_t(S)$). New rows for $a$, $g$, $p$, $\mu_g$.
  - **AmericanContractsPremium:**
    - one name, `early_ex`, for the unrounded early-exercise premium (calls
      used to say `raw_gap`)
    - the `println` removed
    - near-the-money results as `pretty_table`
    - the archive date is October 16
    - the rounding bullet under "Why allow a 15% gap?" is replaced by the
      rate and dividend assumptions (rounding moves a premium at most 0.05%)
    - takeaway 2 no longer says "most puts" (the table shows 57 of 57)
    - sibling LO and Summary format, and $\mathcal{P}^{\text{EU}}$ defined
  - **Hull:**
    - `μ` and `T` explained, the `u`/`d` names corrected, and $e^{g_y\Delta t}$
    - the node fields named, and the node decision as a `pretty_table`
    - the closer warns that the Hull checks must go before parameters change
  - **LSM:**
    - the convergence table is read: European and early-exercise columns move
      by about one SE
    - two doc links, the Task 3 bullets turned into prose, $\sigma$ defined
    - the lecture's $\hat C_t$, $Y_i(t)$, and $M$
    - "log return" removed from a comment, and a closer that no longer claims
      an unmeasured error
  - **Advanced:**
    - "We" takeaways, the duplicate sentence cut, and the source of the mean
      under $\mathbb{Q}$
    - the "divide the top and bottom by $2a$" step and "through order $\Delta t$"
  - **Deck:**
    - synced with his Oct 18 edits; the deck-only "same volatility as GBM and
      BSM" clause is gone
    - slides 6–8 redesigned at his direction ("way too dense", "too dense",
      "not dense enough"; then "cut text, not math", "show the q expression in
      a box", and borrow the $u$, $d$ derivation from the advanced notebook)
    - slide 6 has three one-line items, slide 7 is the $q$ derivation ending in
      the boxed $q$, and slide 8 is the $u$, $d$ summary ending in the boxed
      factors

  Fresh reviewers then re-scored the applied versions (round 1):
  - lecture 9.2, deck 8.8, AmericanContractsPremium 9.1
  - Hull 9.2, LSM 8.9, advanced 9.2, README 9.2

  The remaining items were fixed in the same round, and their reviewers
  predict 9.2–9.4. These fixes were not scored again.
  - **Deck:** the redesign had dropped the only definitions of $\sigma$ and
    $g_y$. Slide 8 now has a where-clause, and slide 7's first reason names
    $g_y$.
  - **Lecture and deck:** the reason label is "solve for $a^2$", and the CRR
    sentence reads "so $a=\sigma\sqrt{\Delta t}$".
  - **LSM:** the closer now warns that changing $\sigma$ or the rate trips the
    checks, the leftover $\hat C(X)$ is $\hat C_t(X)$, and the early-exercise
    column "moves the opposite way".
  - **Advanced:** the drift $\mu=\mu_g+\sigma^2/2$ is defined.
  - **AmericanContractsPremium:** the table label is "beyond 15%".

  He then asked for the deck changes that would reach 9. A fresh reviewer
  scored it 8.8, with design, density and legibility at 8.4. He approved
  ("Agree") from `previews/deck-9plus-{1,2}.png`, which predict about 9.2:
  - **Slides 14 and 17**, his density rule applied:
    - slide 14 shows exercise versus hold as math, then the boxed
      $\mathcal{P}^{\text{AM}}-\mathcal{P}^{\text{EU}}=5.09-4.19$
    - slide 17 has a two-rule table on the same paths and a boxed relation
  - **Slides 8, 10, 15:**
    - slide 8 has a one-line lead, with $p$ in the where-line
    - slide 10 ends on a labeled early-exercise line
    - slide 15's lead is three lines
  - **Small fixes:**
    - slide 11's decision steps are at 10 pt
    - slide 5's title fits on one line ("Options Clearing Corporation")
    - slide 16 says "fit the value of holding"
    - slide 6 has a tie
  - **Unchanged:** the reviewer's optional "Example 1:" label on slide 14.
    The notebook's "We'll work through in lecture" stays.

  The three examples held another session's uncommitted code-comment pass
  (re-run at 12:54, session closed). It was committed as found in 5c64318,
  before the fixes. The Hull and LSM notebooks declare the uninstalled
  `julia-cheme5660` kernel, so re-run them with
  `--ExecutePreprocessor.kernel_name=julia-1.12`.

## L8b build — October 10, 2026

- At the instructor's request, L8b (October 15) finishes the L7b story before
  options. Order: a Concept Review of utility functions, Cobb–Douglas/CES
  holdings and the SIM preference weights (light trim), then the allocator
  example. Next comes the capital allocation line: a CE/RP recap, Arrow–Pratt
  in full, the optimal complete portfolio, and income gambles, followed by the
  interview and the CAL example. The lecture closes with "Derivatives: A Bet on
  the Future". There is no company profile this time.
- The critical path is the instructor's reviewed L7b text. Every edit is listed
  in [the L8b build handoff](lectures/instructor/L8b-BUILD-HANDOFF.md), and
  each new passage is flagged there for his review. The closer prices nothing
  with a real-world probability as "fair", and it ends on the question "What
  sets the price?". This keeps it consistent with L9a, which is not edited.
  The handoff suggests a one-sentence change to the L9a hook.
- The L8b examples, interview, SIM reference, tangent algorithm notebook, and
  CES companion are copies of the L7b files, with "L7b" changed to "L8b" in
  their markdown and paths only. Week bundles cannot link across weeks. L7b is
  unchanged. Both examples were re-run from week-8/L8b, and every output
  matched L7b.
- The figure `figs/Fig-L8b-Bet-CashFlows` (TikZ, light/dark) was approved after
  two revisions: the payoff as a cases block (S_T ≥ K, S_T < K), and "T years
  from now".
- The independent reviewer scored the notebook 8.0, then 8.8, then 9.2. The
  instructor approved the notebook the same day. The deck (28 pages, zero
  overfull boxes) mirrors the notebook. It adds an income-gamble frame and
  three bet frames. At the instructor's request, the deck's dense text was then
  cut by about a quarter in 18 frames, with every equation, box, and link kept.
  He approved the result ("looks good"). On October 11 the CE/RP display got
  term labels (underbraces) and the explicit CE = U⁻¹(𝔼[U(W)]) in the notebook
  and the deck, at his request. Committed and pushed October 11. The week-08
  release waits for his go-ahead.

## Weeks 8–9 options redesign — October 9, 2026

- The instructor is reteaching the L7b material in L8b (October 15), so options no
  longer start in L8b. The L8b options folder (lecture, both examples, static
  replication, deck) is archived in
  `lectures/archive/week-8-L8b-options-2026-10-09/`.
- L9a (October 20) now introduces derivatives and prices European options. The
  agreed design is in
  [the L9a redesign spec](lectures/instructor/L9a-REDESIGN-SPEC.md). The lecture
  is assembled from the instructor's Fall-2025 text with a listed set of
  phrase-level fixes. The only new critical-path prose is the five items flagged
  in the spec. The new replication-to-BSM derivation goes in an optional advanced
  notebook, because the instructor does not want Claude-drafted theory on the
  critical path.
- Any theory an example uses must appear in the lecture first (instructor,
  October 9: "we can't spring theory in an example").
- The L9a build follows lectures/instructor/L9a-REDESIGN-PLAN.md. Its handoff is
  lectures/instructor/L9a-REDESIGN-HANDOFF.md.

## Week 7 pivot — October 1, 2026

- The former L7a utility-allocation and rebalancing material now teaches as
  L7b. The former L7b online-SIM and scenario-ensemble material is deferred in
  `lectures/archive/week-7-before-pivot-2026-10-01/`, with no new date assigned.
- New L7a resumes L6b at minimum-variance portfolios with SIM inputs: a concise
  theory review and the risky-assets example, followed by the risk-free asset,
  tangent portfolio, capital allocation line, and risky/risk-free example.
  BlackRock is the draft company profile.
- The client interview stays in L6b. Copy its `data/my-tickers.csv` and
  `data/my-client.toml` into L7a's local `data` folder after the interview, or use
  the examples' existing hardcoded defaults. Do not relocate the interview to
  L7a or make the Week 7 bundle depend on a Week 6 relative path.
- Read [the refactor handoff](lectures/instructor/WEEK-7-REFACTOR-HANDOFF.md)
  before follow-up work. Existing L6b review scores belong to their recorded
  snapshots; this structural refactor does not constitute a new polish review.
- October 2 L7b trim: class time covers two examples, at most three, so L7b is
  utility-based allocation only. A new example chooses the optimal point on the
  capital allocation line with mean-variance utility and infers the client's
  risk aversion from the L6b interview answer. The utility allocator is
  regrouped into three tasks. The drift and rebalancing-scorecard examples, the
  engine figure, and the engine, elasticity-rule, and scorecard lecture
  sections are in `lectures/archive/week-7-L7b-trim-2026-10-02/`. The
  instructor asked that cut material not move into a later week and that
  lectures not point to topics on future dates. The handoff's October 2
  section lists the checks.
- October 3 Cobb–Douglas fix: L7b, its deck, and the L13a lecture and advanced
  bandit notebook again state the instructor's 2025/eCornell model. The product
  runs over every asset, subject to the budget and an n_min > 0 floor. W_adj is
  derived from the budget constraint, and κ = ±1 signs only the bandit's
  utility reward. Before rewriting a derivation, compare its model statement
  with the 2025 and eCornell versions. The handoff's October 3 section records
  the details. L13a is paused (the material may not stay there). Do not edit
  week-13 files. Open items are in `lectures/instructor/L13a-PINNED-ISSUES.md`.
- L7b lecture polish round: opened October 3 (8.2/10) and paused. On October 6 a
  polish, voice, and navigation pass was applied in one round (8.3 to 9.0), and
  the instructor approved it that day. The deck was synced the same day. Both
  were released in week-07.1. On October 9, after the instructor's
  certainty-equivalent edits, a second pass took it from 8.2 to 9.0. The
  preference box now carries an explicit horizon, tanh(h[…]) with h = 1 year,
  in the lecture, the allocator example, the notation page, and the deck. Do
  not use Δt for it, because Δt = 1/252 is the daily step. The Concept
  Review's SIM-2/SIM-3 paragraph was deleted at the instructor's request, and
  the deck gained two certainty-equivalent frames (27 pages). Not yet
  released. See
  [the review record](lectures/instructor/L7b-LECTURE-REVIEW-HANDOFF.md) for the
  changes and the open items (the deck's interview frame, companion and
  package). The empty-basket question was resolved on October 9 with a cash term.
- October 7 L7b income-gamble interview: `lectures/week-7/L7b/interview/` runs
  the published Barsky–Juster–Kimball–Shapiro (1997) income gambles in student
  wording. The instructor chose them because they are published. Two refinement
  questions in the same form, labeled as our extension, follow the six published
  categories, and `income-gamble.jl` brackets r̄ (= A) into the gitignored
  `data/my-risk-aversion.toml`, which the CAL example's Task 3 reads. The cut is δ,
  because λ is the Cobb–Douglas multiplier. Do not swap in an unpublished
  questionnaire, and keep the inflation sentence on every screen. The handoff's
  October 7 section has the details. The deck frame is still to do.
- October 7 CES limits companion pass: the instructor asked for a polish,
  voice, and organization pass if the notebook scored below 9. It opened at 7.7
  (Codex 8.0), so the pass was applied in one round, closing at 9.1 (Codex 9.2).
  The pass makes the limit at small elasticity exactly the minimum, labels the
  no-floor box for large elasticity, and changes μ to the lecture's λ. The three
  limits are now H3s under one H2. The instructor approved it the same day, and it
  was released in week-07.1. See
  [the review record](lectures/instructor/L7b-CES-LIMITS-REVIEW-HANDOFF.md).
- October 8 L7b allocator rework: the live demo failed (every firm non-preferred)
  because the preference input was a 10-day EMA of annualized SPY growth. The
  example now uses a 252-day EMA, re-solves the allocation daily and monthly
  through 2025 with the package engine, and plots wealth against GMV, tangent,
  and SPY buy-and-hold. Before changing any example, open last year's version
  (Fall 2025 repository) and reproduce its behavior on the demo date. Note that
  `lectures/week-7/L7b/data/my-tickers.csv` (gitignored) replaces the default
  firms when present; execute with and without it. The handoff's October 8
  section has the details and the open lecture-summary sentence.
- October 8 allocator example polish: the instructor asked for a polish,
  voice, and organization pass if the reworked example scored below 9. It
  opened at 8.3 (Codex 7.9), so the pass was applied in one round, prose only,
  with the code cells and outputs untouched. The Codex pre-review caught three
  statements the printed outputs contradict ("same costs", GMV "spreads the
  budget", growth-and-beta "rank market risk"), all fixed. Task 2 and Task 3
  gained H3s in the siblings' imperative or question form, and the wealth
  reading is a labeled-bullet "What do we see?". See
  [the review record](lectures/instructor/L7b-ALLOCATOR-REVIEW-HANDOFF.md)
  for the scores, changes, declined Codex items, and checks. On October 9 the
  instructor froze this notebook: "I like this content, and when you cut stuff
  - you make it shitty". Change only mathematical mistakes, technical errors,
  and awkward phrasing, and reword rather than cut. Its length is not a to-do.
- October 8 tangent-continuation algorithm notebook: the October 6 L7a lecture
  edit replaced the boxed common-risky-direction result (SIM-3) with the
  continuation pseudocode, while the L7a tangent example and both L7b examples
  still cite SIM-3 and find the tangent portfolio by one solve of SIM-2
  rescaled to sum to one. The instructor chose a separate algorithm notebook
  on the CHEME 5800 L6c Jacobi pattern (markdown only: title and three
  objectives, derivation, pseudocode and convergence, summary), placed in L7b
  where the comparison runs:
  `lectures/week-7/L7b/CHEME-5660-L7b-Algorithm-TangentContinuation-Fall-2026.ipynb`.
  The L7a lecture keeps SIM-2 and its continuation pseudocode and has SIM-3
  back as its Solution paragraph, with no link into L7b (instructor rule); the
  L7b lecture and deck linked it from the Concept Review until October 9,
  when both links were deleted (both examples still link it); the allocator example
  runs the continuation as a check against the single solve (new cells 35 and
  36); both decks are synced. Not yet released (needs a week-07.2 fix release). The
  [allocator review record](lectures/instructor/L7b-ALLOCATOR-REVIEW-HANDOFF.md)
  has the checks. On October 9 the instructor, who had "never understood the
  single step shortcut", had the notebook rewritten as "The Tangent Portfolio:
  One Solve or a Search?". It splits the risky holdings into amount times mix,
  so the variance is s²/SR², and every target picks the maximum-Sharpe mix. The
  same solve gives the tangent target, ĝᵀw_T. The search keeps his pseudocode,
  and a table compares the two methods. Write "no holding hits the 100% limit",
  never "no cap binds" ("speak English"). See the October 9, later section of
  [the lecture review record](lectures/instructor/L7b-LECTURE-REVIEW-HANDOFF.md).
- October 8 SIM problem reference: the instructor found bare "SIM-1", "SIM-2",
  "SIM-3" tag references in the L7b notebooks hard to resolve, so
  `lectures/week-7/L7b/CHEME-5660-L7b-Reference-SIM-Portfolio-Problems-Fall-2026.ipynb`
  (markdown only) states the three problems as the L7a lecture boxes them, with a
  where-used table. Rule: every mention of a SIM tag in L7b markdown is a link,
  `[SIM-2](CHEME-5660-L7b-Reference-SIM-Portfolio-Problems-Fall-2026.ipynb)`,
  never a bare tag. The reference links only to L7b files so it can move with the
  tangent material. The L6b lecture keeps its own copies of the tags; the instructor
  decided to leave L6b alone. Not yet released (needs the week-07.2 fix release).
- October 7 release: `week-07.1` ships the complete week (L7a and L7b). The
  [release record](lectures/instructor/WEEK-07.1-RELEASE-HANDOFF.md) lists the
  checks and the items still open, including the deck's interview frame.

## Lecture and Example Notebooks

- Before authoring, editing, or reviewing course notebooks, read [the shared notebook style guide](lectures/instructor/NOTEBOOK-STYLE-GUIDE.md). It records the September 10, 2026 reset and the reference passages from CHEME 5660 Fall 2025 and CHEME 5820 Spring 2026.
- Preserve the instructor's teaching voice, explanatory steps, and mathematical rigor. This guide supersedes conflicting older notebook-style skills and review prescriptions; do not run legacy style auto-fixes against it. Slide production is outside this reset.
- Use the three-underscore horizontal rule at major-section boundaries immediately before a new level-two heading, and always end the final Summary and the closing Disclaimer and Risks section with it (instructor decision, September 29, 2026). Do not use it between level-three subsections.
- Include exactly three learning objectives in every lecture and example notebook.
- Include exactly three key takeaways in every lecture and example notebook.
- In code cells, put every `@assert` in one `# checks -` block immediately before the `# return` line, after the printout, never scattered through the computation (instructor decision, October 8, 2026). The style guide's "Writing and mathematical exposition" section gives the branch and table-loop cases.

## Week 5 refactor — September 18, 2026

- The original Week 5 is preserved in `lectures/archive/week-5-before-pivot-2026-09-18/`.
- The reviewed multiple-asset L5a material now teaches as L5b. The original minimum-variance L5b material is archived for the planned Week 6 refactor.
- New L5a covers single-asset GBM and NPV. Keep its **EMA theory as a concise theorem-style proposition** with the assumptions, update equations, and brief interpretation. The instructor liked the theory but requested a much shorter lecture section; the detailed development is preserved in the linked [EMA derivation notebook](lectures/week-5/L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb). Simulations, rolling trade calculations, and empirical scores remain in the separate worked example.
- Write all EMA estimates in terms of the course growth rate `g_k = log(S_k/S_(k-1))/Delta_t`, in inverse years. Initialize growth-rate variance as `sigma_0^2/Delta_t` and recover GBM volatility as `sqrt(v_k*Delta_t)`. Keep equations, code, labels, and units aligned; do not recast this material in terms of returns.
- L5a uses three separate examples: the NPV trade-rule notebook moved from L4b, the restored reviewed OoS notebook from the original L5a, and an EMA example narrowed from the generated combined notebook. Preserve the restored notebooks' reviewed content. Keep the lecture theory consistent with the EMA example and its local helpers.
- Read [the refactor handoff](lectures/instructor/WEEK-5-REFACTOR-HANDOFF.md) before follow-up work. Historical review scores refer to their saved snapshots, not to newly authored content.

## Completed L4a first-passage example review

- The L4a first-passage example review was completed September 13, 2026, with
  a score of 9.0/10. The [saved review record](lectures/instructor/L4a-FIRST-PASSAGE-REVIEW-HANDOFF.md)
  records the assessment, checks, and preferences. No proposals remain pending;
  read it before follow-up work and do not restart completed sections unless
  the instructor requests another round.

## Completed L4a N-ary example review

- The L4a N-ary example polish round was completed September 13, 2026, with a
  final score of 9.1/10. The [saved review record](lectures/instructor/L4a-NARY-REVIEW-HANDOFF.md)
  records accepted revisions and preferences. No proposals remain pending;
  read it before follow-up work and do not restart completed sections unless
  the instructor requests another round.

## Completed L4a execution-aware example review

- The L4a execution-aware example was reviewed September 13, 2026, with a
  score of 9.2/10. The requested polish was conditional on an initial score
  below 9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4a-EXECUTION-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b lecture review

- The L4b GBM lecture interactive review was completed September 11, 2026.
  [The saved review record](lectures/instructor/L4b-INTERACTIVE-REVIEW-HANDOFF.md)
  records approved edits, notation, and preferences. Read it before follow-up
  work; do not restart completed lecture sections. Companion examples still
  need the mean-growth notation aligned when their own review is requested.

## Completed L4b parameter example review

- The L4b parameter-estimation example polish round was completed September 13,
  2026, with a final score of 9.0/10. The
  [saved review record](lectures/instructor/L4b-PARAMETERS-REVIEW-HANDOFF.md)
  records the approved engineering assumption, wording preferences and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  completed sections unless the instructor requests another round.

## Completed L4b lattice-limit example review

- The L4b lattice-to-GBM example was reviewed September 13, 2026, with a score
  of 9.0/10. The requested polish was conditional on an initial score below
  9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4b-LATTICE-LIMIT-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b drift-uncertainty example review

- The L4b drift-uncertainty example was reviewed September 13, 2026, with a
  score of 9.1/10. The requested polish was conditional on an initial score
  below 9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4b-DRIFT-UNCERTAINTY-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b Monte Carlo example review

- The L4b Monte Carlo target-probability example was reviewed September 13,
  2026, with a score of 9.1/10. The requested polish was conditional on an
  initial score below 9/10, so the notebook was left unchanged. The
  [saved review record](lectures/instructor/L4b-MONTE-CARLO-REVIEW-HANDOFF.md)
  records the assessment and checks. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L4b first-passage example review

- The L4b GBM first-passage example was reviewed September 13, 2026, with a
  final score of 9.2/10. The
  [saved review record](lectures/instructor/L4b-FIRST-PASSAGE-REVIEW-HANDOFF.md)
  records the shorter Task 2, documented source functions, figure corrections,
  code-commenting pass, and validation. No proposals remain pending; read it
  before follow-up work and do not restart completed sections unless the
  instructor requests another round.

## Completed L5a covariance example review

- The L5a covariance example was marked reviewed and complete September 14,
  2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-COVARIANCE-REVIEW-HANDOFF.md)
  records the approved sections, figure revisions, and validation. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5a single-asset GBM and NPV lecture review

- The new single-asset GBM and NPV L5a lecture was marked reviewed and complete
  by the instructor September 18, 2026, with a final editorial score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-SAGBM-NPV-REVIEW-HANDOFF.md)
  records the approved company profile, example callouts, prediction-band
  explanation, concise EMA wording, instructor preferences, and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  accepted sections unless the instructor requests another round. This review
  is separate from the earlier multiple-asset lecture review below.

## L5a single-asset GBM and NPV slides synchronization

- The current 22-page single-asset L5a deck was synchronized with the reviewed
  lecture and polished September 19, 2026, at the instructor's request, with
  a final editorial score of 9.2/10. The
  [saved record](lectures/instructor/L5a-SAGBM-NPV-SLIDES-REVIEW-HANDOFF.md)
  records the company resources, concise EMA theory, and rendered-slide checks.
  The instructor subsequently requested removal of the standalone “Pointwise
  Prediction Bands” slide; do not restore it. The 9.2/10 score describes the
  preceding 23-page snapshot. Read it before follow-up work. The instructor has
  not yet separately marked this slide review complete. The September 16
  slides review below covers the former multiple-asset deck, now taught as L5b.

## Completed L5a NPV trade-rule example polish review

- The GBM NPV trade-rule example, moved from L4b to L5a, was marked reviewed
  and complete by the instructor September 19, 2026, with a final editorial
  score of 9.1/10 (initial 9.0/10). The
  [saved review record](lectures/instructor/L4b-NPV-REVIEW-HANDOFF.md) records
  the approved objectives, explicit GBM-to-price-distribution explanation,
  equation formatting, parameter comments, figure label, and final checks.
  No proposals remain pending; read it before follow-up work and do not restart
  accepted sections unless the instructor requests another round.

## Completed L5a EMA example polish review

- The single-asset EMA example was marked reviewed and complete by the instructor
  September 18, 2026, with a final editorial score of 9.1/10 (initial 8.8/10). The
  [saved review record](lectures/instructor/L5a-EMA-REVIEW-HANDOFF.md)
  records the approved update explanations, shortened forecast section,
  simulation interpretation, Brier example, score interpretation, instructor
  feedback, and validation. No proposals remain pending; read it before
  follow-up work and do not restart accepted sections unless another round
  is requested.

## Completed L5a lecture review

- The L5a multiple-asset GBM lecture was marked reviewed and complete September 14,
  2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5a-LECTURE-REVIEW-HANDOFF.md)
  records the approved notation, derivations, instructor feedback, and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  completed sections unless the instructor requests another round.

## Completed L5a lecture slides review

- The L5a lecture slides were reviewed and completed September 16, 2026, with
  a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-SLIDES-REVIEW-HANDOFF.md) records
  the approved 37-page deck, L4a style reference, notation, practical Dirichlet
  explanations, portfolio-growth approximation, instructor preferences, and
  final checks. No slide proposals remain pending; read it before follow-up
  work and do not restart approved sections unless another round is requested.

## Completed L5a out-of-sample example review

- The L5a out-of-sample single-asset GBM example was marked reviewed and complete
  September 14, 2026, with instructor confirmation and a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-OOS-REVIEW-HANDOFF.md) records
  the histogram correction, shared ticker selection, three-task organization,
  documented helpers, instructor preferences, and validation. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5a Dirichlet example review

- The L5a Dirichlet portfolio weights example was marked reviewed and complete
  by the instructor on September 14, 2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5a-DIRICHLET-REVIEW-HANDOFF.md)
  records the approved terminology, table and figure revisions, annotated wealth
  derivation, and validation. No proposals remain pending; read it before
  follow-up work and do not restart completed sections unless the instructor
  requests another round.

## Completed L5a advanced covariance-estimation review

- The L5a advanced covariance-estimation example was marked reviewed and complete
  by the instructor September 14, 2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5a-ADVANCED-COVARIANCE-REVIEW-HANDOFF.md)
  records the approved spectral diagnostics, sampling-error explanation, figures,
  source functions, code-cell organization, and optimization closing. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5a rolling-correlation example review

- The L5a rolling-correlation example was marked reviewed and complete by the
  instructor September 14, 2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5a-ROLLING-CORRELATION-REVIEW-HANDOFF.md)
  preserves the earlier accepted sections, resumed assessment, source helpers,
  figure and mathematical checks, and preferences. No proposals remain pending;
  read it before follow-up work and do not restart completed sections unless
  the instructor requests another round.

## Completed L5b lecture review

- The L5b minimum-variance portfolio lecture was marked reviewed and complete
  by the instructor September 15, 2026, with a final score of 9.1/10. The
  [saved review record](lectures/instructor/L5b-LECTURE-REVIEW-HANDOFF.md) records
  the approved frontier and CAL sections, concise input-estimation discussion,
  closing revisions, instructor preferences, and validation. No proposals remain
  pending; read it before follow-up work and do not restart completed sections
  unless the instructor requests another round.

## Completed L5b lecture slides review

- The L5b lecture slides were marked reviewed and complete by the instructor
  September 17, 2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5b-SLIDES-REVIEW-HANDOFF.md) records
  the approved 30-page deck, growth-rate notation, constraint and borrowing
  explanations, concise closing, and final checks. The instructor specified
  SIM rather than CAPM and authorized matching notebook scope edits. No slide
  proposals remain pending; read the record before follow-up work and do not
  restart approved sections unless another round is requested.

## Completed L5b minimum-variance example review

- The L5b data-driven minimum-variance example was marked reviewed and complete
  by the instructor September 16, 2026, with a final score of
  9.1/10. The [saved review record](lectures/instructor/L5b-MINVAR-REVIEW-HANDOFF.md)
  records the approved three-task organization, notation, optimization explanations,
  figures and tables, wealth/NPV distinction, closing, and validation. No proposals
  remain pending; read it before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5b multiple-asset GBM example review

- The L5b multiple-asset GBM portfolio example was marked reviewed and complete
  by the instructor September 16, 2026, with a final score of
  9.2/10. The [saved review record](lectures/instructor/L5b-MAGBM-REVIEW-HANDOFF.md)
  records the approved simulation and drift explanation, allocation and wealth
  development, pointwise bands, NPV table, source helper, preferences, and checks.
  No proposals remain pending; read it before follow-up work and do not restart
  completed sections unless the instructor requests another round.

## Completed L5b advanced frontier-geometry review

- The L5b advanced frontier-geometry example was marked reviewed and complete
  by the instructor September 16, 2026, with a final score of 9.2/10. The
  [saved review record](lectures/instructor/L5b-ADVANCED-FRONTIER-REVIEW-HANDOFF.md)
  records the derivations, two-fund construction, constraint comparison, figure
  preferences, explicit 50% position-limit terminology, and final validation.
  No proposals remain pending for this notebook; read the record before follow-up
  work and do not restart completed sections unless the instructor requests
  another round. The advanced estimation-risk review is also complete; see below.

## Completed L5b advanced estimation-risk review

- The advanced estimation-risk notebook was marked reviewed and complete by the
  instructor September 17, 2026, with a final score of 9.2/10 (initial 8.3/10).
  The [saved review record](lectures/instructor/L5b-ADVANCED-ESTIMATION-REVIEW-HANDOFF.md)
  records the three-task organization, resampling assumptions, normalizer and
  sensitivity distinctions, boxed compounding derivation, terminal-wealth box
  plots, instructor wording preferences, and validation. No proposals remain
  pending; read the record before follow-up work and do not restart completed
  sections unless the instructor requests another round.

## Completed L5b rolling-correlation example review

- The relocated L5b rolling-correlation advanced example was marked reviewed
  and complete by the instructor September 23, 2026. It was polished from
  8.3/10 (Codex 7.8) to 9.1/10 (Codex 8.8 before the last three small
  fixes). Prose was cut from about 3,050 to 1,950 words, with
  code and outputs unchanged. The [review record](lectures/instructor/L5b-ROLLING-CORRELATION-REVIEW-HANDOFF.md)
  lists the accepted edits, rejected Codex findings, and checks. No proposals
  remain pending. Do not restart the round unless the instructor requests another one.

## Completed week-5 code-commenting pass

- The instructor-requested commenting pass was completed September 17, 2026.
  All 175 code cells across nine computational notebooks now include teaching
  comments; the two lecture notebooks have no code cells. The
  [saved record](lectures/instructor/WEEK-5-CODE-COMMENTS-HANDOFF.md) records
  the scope, explanations, validation, and current notebook hashes. Executable
  syntax, Markdown, saved outputs, and metadata were preserved. Earlier review
  hashes refer to the pre-commenting snapshots; their approved sections and
  review scores remain closed.

## Completed Week 5 natural-language pass

- The instructor requested small wording changes across active Week 5 materials
  on September 19, 2026. The [saved record](lectures/instructor/WEEK-5-NATURAL-LANGUAGE-HANDOFF.md)
  records the prose edits, preserved calculations, and notebook/slide checks.
  Keep complete, natural sentences, including articles, verbs, and units phrasing.
  This was a targeted wording pass; existing section reviews and scores remain
  closed and refer to their recorded snapshots.

## Completed L6a minimum-variance lecture review

- The L6a data-driven minimum-variance lecture was marked reviewed and complete
  by the instructor September 24, 2026, with a final editorial score of 9.1/10.
  The [saved review record](lectures/instructor/L6a-LECTURE-REVIEW-HANDOFF.md)
  records the density pass, short-position development, complete GMV derivation
  companion, visual-first frontier, defined and annotated theorem-style boxes,
  long-only growth floor, wealth/NPV closing, and final checks. The instructor
  subsequently reconfirmed completion after the Dirichlet review, local sampling
  example, AllianceBernstein profile, and boxed-result follow-up edits; the saved
  record identifies that final snapshot. No proposals remain
  pending; do not restart approved lecture sections unless another round is
  requested. The minimum-variance data example has its own review.
- On September 25, 2026, the instructor requested a density and flow round
  (independent rating 8.5/10, final 9.0/10). The approved edits rebuilt the
  Estimated Inputs opening and Objective 3, fixed the frontier figure's
  attainable-region wording, moved the negative-weight example ahead of the
  GMV box, tightened transitions and redefinitions, and condensed the log-return
  and GBM-volatility material into a short note. The portfolio problem stays in
  the growth-rate covariance; self-contained box Setups were kept. The same handoff records the edits, checks, deferred items, and
  needed deck changes; the instructor has not yet separately marked it complete.
- A follow-up polish round the same day (independent rating 8.9/10, final
  9.2/10) removed nine clause semicolons, replaced the lecture's package-doc
  Dirichlet link, linked the held-out 2025 wealth comparison in Estimated Inputs,
  and fixed the Concept Review closer and reward-display spacing. The same
  handoff records the edits, declined suggestions, and one deck-sync item.

## Completed L6a multiple-asset GBM example polish

- The instructor marked the L6a multiple-asset GBM portfolio example polish
  complete September 26, 2026 (initial rating 8.2/10, final 9.0/10). The
  [saved review record](lectures/instructor/L6a-MAGBM-REVIEW-HANDOFF.md)
  records the four accepted steps: links to other weeks became references in
  words; Task 1 was tightened and reordered to build the pieces, then the model;
  Tasks 2 and 3 now recall the GMV problem and portfolio NPV from the L6a lecture,
  add `__What do we see?__` readings and types, and cut denials of unproposed
  misreadings. Task prose went from 3,008 to 2,282 words. It also records the
  Codex checks and accuracy fixes, and the saved snapshot. No proposals remain
  pending; do not restart approved sections unless another round is requested.
  Setup, Data, and Constants were not part of this round. Show future proposals
  as rendered before/after PNGs; the instructor found terminal markdown hard to
  read.
- October 3 instructor request (released as week-06.8): Task 2 now displays
  the full (LO-1) problem, with the growth floor and long-only constraints,
  and the wealth figure shows the simulated mean with pointwise mean ± 1,
  1.96, and 2.57 standard-deviation bands instead of the median and
  percentiles. Do not restore the percentile bands. The
  [release record](lectures/instructor/WEEK-06.8-RELEASE-HANDOFF.md) lists
  the text changes and checked values.

## Completed L6a GMV derivation companion review

- The instructor accepted a review of the L6a
  [GMV derivation companion](lectures/week-6/L6a/advanced/gmv-derivation/CHEME-5660-L6a-Derivation-GMV-Fall-2026.ipynb)
  on September 26, 2026, and marked it complete. The derivation matched the
  lecture's GMV-1 to GMV-3 boxes and was correct. The accepted fixes: weights
  defined as fractions of the initial investment (not "dollar weights"),
  positivity of the normalizing denominator argued from the positive-definite
  inverse where λ is solved, the standard-deviation sentence placed beside the
  boxed variance, a lead sentence that no longer names the multiplier before it
  is introduced, and the minimum variance stated in the third takeaway. The kept
  "does not change the minimizing weights" note on the factor of one half matches
  the lecture and answers a real student question. The advanced README now
  recommends the GMV derivation first.

## Completed L6a minimum-variance data example review

- The instructor marked the L6a data-driven minimum-variance example reviewed
  and complete September 26, 2026 (opening assessment 8.6/10, no rescoring).
  The [saved review record](lectures/instructor/L6a-MINVAR-REVIEW-HANDOFF.md)
  records the opening assessment and the one change made after it: Task 3 now
  also tests the shorts-allowed GMV portfolio out of sample, as a "blue sky"
  first implementation with no borrowing fee, collateral, or dividends owed, and
  a dashed navy wealth path. The cell 50 reading is a lead sentence,
  three labeled bullets, and a closing sentence. The opening assessment's density
  suggestions were not taken up. No proposals remain pending; do not restart
  the review unless the instructor asks for another round.

## Completed L6a slides review

- The instructor marked the L6a slides reviewed and complete September 26,
  2026, after asking to finish the remaining steps in one pass (initial 8.0/10,
  final 9.0/10). The only change requested after the previews was shorter text
  below the long-only box on page 17. The [saved review record](lectures/instructor/L6a-SLIDES-REVIEW-HANDOFF.md)
  records the sync with the stabilized lecture. Objective 3, the Dirichlet link,
  and Estimated Inputs now match the lecture. The buy-and-hold and log-return
  slides were removed, and a one-line conventions note replaces them. The
  GMV/frontier section follows the lecture's order: negative weight, boxed GMV,
  derivation with a companion link, frontier figure, then the boxed target
  problem and formula. The long-only section is the boxed LO-1 plus one
  growth-floor slide. The deck went from 25 to 23 pages with zero overfull
  boxes. Two lecture sentences now say the data example tests both GMV
  portfolios. No proposals remain pending; do not restart unless another round
  is requested.

## Completed L6a advanced frontier-geometry review

- The instructor marked the relocated L6a frontier-geometry advanced example
  reviewed and complete September 27, 2026 (initial 8.2/10, final 9.0/10). The
  [saved review record](lectures/instructor/L6a-FRONTIER-REVIEW-HANDOFF.md)
  records the six accepted steps and the September 27 follow-up. Links into
  other weeks were cut or named in words, the corrupted figures were repaired,
  and `Max |w_i|` table columns now carry the weight claims. Prose went from
  3,751 to about 2,500 words, with readings as short `__What do we see?__` lists.
  Task 3 solves each weight rule directly at the comparison targets instead of
  interpolating, and the interpolation helper was removed. The L6a lecture and
  advanced README now describe the constraint as a position cap. No proposals
  remain pending. Do not restart unless the instructor requests another round.

## Completed L6a code-commenting pass

- On September 27, 2026 the instructor asked for good docstrings and thorough
  comments in all L6a example code and `src`, because students read it. The
  pass covers all 80 code cells in the three examples and the frontier-geometry
  notebook, plus both `src` files, both `Include.jl` files, and the frontier
  reference page. The [saved record](lectures/instructor/L6a-CODE-COMMENTS-HANDOFF.md)
  holds the conventions, the validation, and the items that need code edits.
  Syntax-tree checks confirm that only comments and docstrings changed.

## Completed L6b slides review

- The instructor marked the L6b slides reviewed September 28, 2026, after a
  same-day pass over the lecture's objectives, example and advanced
  descriptions, and key takeaways (approved "as shown") and a deck sync with the
  bullets tightened to fit. The [saved review record](lectures/instructor/L6b-SLIDES-REVIEW-HANDOFF.md)
  holds the snapshot hashes, the lecture changes, the five synced frames, and
  the deliberately shortened Summary slide (no closing line). The lecture and deck edits are not yet
  committed: the instructor deferred the commit until the L6b example notebooks
  are reviewed. No proposals remain pending; do not restart unless another round
  is requested.

## Completed L6b bootstrap uncertainty example review

- The instructor marked the L6b bootstrap uncertainty example reviewed
  September 28, 2026 (initial 6.0/10, final 9.1/10). The
  [saved review record](lectures/instructor/L6b-BOOTSTRAP-REVIEW-HANDOFF.md)
  records the regroup into fit all firms and R², generate the bootstrap, and
  compare standard errors; the corrected Monte Carlo explanation; the new
  across-firm, standard-error, and coverage tables and histogram figure; the
  closing reading that answers the opening question; and the checks. Outputs are
  stored. Not yet committed: the instructor deferred the commit until all four
  L6b examples are reviewed. No proposals remain pending; do not restart unless
  another round is requested.

## Completed L6b SIM estimation example review

- The instructor marked the L6b SIM estimation example reviewed September 28,
  2026 (initial 6.5/10). Round 1 closed at 8.3, below the 9.0 threshold, and a
  second round closed at 9.0/10. The
  [saved review record](lectures/instructor/L6b-ESTIMATION-REVIEW-HANDOFF.md)
  records the steps and checks:
  - the standard opening;
  - task openers and subsections;
  - lecture recalls in place of re-derivations;
  - readings that hold for any ticker;
  - the stock versus index-fund contrast moved after the all-security fit;
  - five corrected claims;
  - prose cut from 2,197 to 1,651 words;
  - code lines reflowed to at most 100 characters;
  - the heatmap margin fix.
  The parameter archive stayed byte-identical through every re-execution. The
  round also changed one sentence of the L6b lecture, the example callout, to
  match the new order. Not yet committed: the instructor deferred the commit
  until all four L6b examples are reviewed. No proposals remain pending; do not
  restart unless another round is requested.

## Completed L6b SIM portfolio (RA) example review

- The instructor marked the L6b SIM portfolio (risky assets) example reviewed
  September 28, 2026 (initial 6.5/10). Round 1 closed at 8.6, below the 9.0
  threshold, and a second round closed at 9.0/10. The
  [saved review record](lectures/instructor/L6b-RA-REVIEW-HANDOFF.md) records
  the steps and checks:
  - the standard opening, with the setup, data, and Task 3 code ported from L6a;
  - lecture recalls in place of re-derivations;
  - `g_target` set to the middle floor of a common sweep, so other ticker lists run;
  - a figure panel for the SIM's risk misjudgment and the extra risk of its weights;
  - the covariance split as a display labeled "SIM keeps" and "SIM drops";
  - a weight reading tied back to the Task 1 pair table;
  - a closing answer to the opening question;
  - prose cut from 2,830 to about 2,150 words.
  Every stored text output matched after the round-2 re-execution. A final
  whole-notebook Codex check passed, and the instructor's cell 25 wording
  ("directly links") was applied after it. The instructor confirmed the
  notebook complete the same day. Not yet committed: the instructor deferred
  the commit until all four L6b examples are reviewed. No proposals remain
  pending; do not restart unless another round is requested.

## Completed L6b risky and risk-free (RRFA) example review

- The instructor marked the L6b tangent portfolio and capital allocation line
  (RRFA) example reviewed September 28, 2026 (initial 5.5/10). Round 1 closed at
  8.4, below the 9.0 threshold. A second round closed at 9.0/10, and Codex
  scored it 9.1 on its own. The
  [saved review record](lectures/instructor/L6b-RRFA-REVIEW-HANDOFF.md) records
  both rounds and their checks:
  - the standard opening, with setup, data, and Task 3 code ported from L6a;
  - one SIM frontier sweep with a tangency check, keeping the original CAL
    figure style at the instructor's request;
  - both tangent portfolios scored under the sample covariance (SIM 1.265
    against data 1.285 annualized);
  - a Task 3 reading that compares each complete portfolio with SPY at similar
    realized risk, as Objective 3 promises;
  - the fuller two-sentence Summary opener;
  - fixes for a `$k$th` render bug and a dead JLD2 anchor.
  Round 2 was word-neutral, and its only code change was two print lines. With
  this review, all four L6b examples are reviewed. The lecture, deck, and
  examples are not yet committed, because the instructor deferred that commit
  until now. No proposals remain pending; do not restart unless another round
  is requested.

## L6b advanced material cut to two notebooks

- On September 28, 2026 the instructor cut the L6b optional advanced notebooks
  from five to two. The review burden was high, and it was unclear whether
  students read them. Kept: residual diagnostics (`advanced/diagnostics/`) and
  estimation risk (`advanced/estimation-risk/`). Moved unchanged to
  [the archive](lectures/archive/week-6-L6b-advanced-cut-2026-09-28/README.md):
  the data-driven risk-free notebook, the markdown-only SIM theory notebook,
  and SIM parameter uncertainty in portfolios. Do not restore them or propose
  new L6b advanced notebooks unless the instructor asks.
- Follow-on edits: the lecture's advanced list and one lecture sentence
  linking the theory notebook, `advanced/README.md`, the slides' advanced frame
  (PDF rebuilt), the RRFA example's closing link (now the estimation-risk
  notebook, matching the deck), the diagnostics closing line, and the
  estimation-risk links and closing paragraph. The estimation-risk links still
  pointed to its pre-relocation L5b paths. The estimation-risk notebook ran in
  place with no errors, and its stored outputs were left as reviewed.
- Closed in the L7b review (October 9): the L7b lecture no longer cites the
  ridge estimator.

## Completed L6b advanced estimation-risk review

- The instructor marked the L6b estimation-risk advanced notebook reviewed
  September 28, 2026 (initial 7.0/10, final 9.0/10). It had been reviewed as an
  L5b notebook on September 17. That review predates the current density rules
  and the L6b lecture's SIM-3 result. The
  [saved review record](lectures/instructor/L6b-ESTIMATION-RISK-REVIEW-HANDOFF.md)
  records the six accepted steps and their checks:
  - the input estimation and the four weight rules moved from Setup into
    Tasks 1 and 2;
  - the bootstrap loop keeps only the resampled inputs, and a Task 2
    `weights` cell computes the four rules;
  - `tangent_long_only` uses the lecture's exact SIM-3 solve and rescale
    instead of a 31-point grid (`src` and `docs` changed, tangent rows moved at
    most 0.007);
  - the introduction asks the L6b question, whether the means or the
    covariance moves the weights more, and Task 2 answers it;
  - prose went from 3,830 to 2,669 words;
  - the closing Codex fixes are applied.
  Every non-tangent output matched after re-execution. This supersedes the
  "stored outputs were left as reviewed" note above. Released as week-06.1.
- On September 30, 2026 the instructor asked for a second polish, voice, and
  organization round (opening 8.4/10, closing 9.0/10). The round-2 section of
  the same record lists the four changes: Task 2 now opens with the frontier
  figure before the four rules and resampled weights, blank lines separate
  every display from the prose, the title is "Estimation Risk in Portfolio
  Weights" to match the lecture list and README, and nine code comments lost
  denials or repeated prose. Prose is flat (2,635 to 2,642 words). Re-executed
  with every output matching week-06.1. The instructor accepted the round
  and marked it complete the same day. No proposals remain pending; do not
  restart unless another round is requested.

## Completed L6b advanced residual-diagnostics review

- The instructor marked the L6b residual-diagnostics advanced notebook reviewed
  September 28, 2026 (initial 6.0/10, final 9.0/10; Codex 7.6 to 9.0). The
  [saved review record](lectures/instructor/L6b-DIAGNOSTICS-REVIEW-HANDOFF.md)
  records the six accepted steps and their checks:
  - retitled "L6b Advanced: Residual Diagnostics and Two Bootstrap Methods",
    with a two-sentence lead-in that follows on from the bootstrap example;
  - regrouped as heavy tails (Task 1, a density and log-scale tail figure, and
    the Hill index against a Gaussian reference), then two bootstraps (Task 2),
    then dependence (Task 3);
  - Task 3 traces the lag-one dependence to VWAP averaging with an
    all-securities VWAP-versus-close table and a Working (1960) citation, and
    gives Newey-West as display equations computed with plain loops;
  - a false volatility-clustering claim, a stale ridge reference, and an
    unsupported all-firms extrapolation were cut;
  - all code rewritten as a lesson, with no lines over 100 characters;
  - prose is flat (1,583 to 1,589 words), and the longest sentence went from
    85 to 34 words.
  Re-executed with no errors. The stale 0.981 output is now 0.993. The lecture
  description and README still match. Not yet committed: it is part of the
  deferred L6b commit.
- Round 2, September 30, 2026: the instructor asked for another pass if the
  notebook scored below 9.0. It scored 8.6 (Codex 8.5), so a markdown-only
  round closed at 9.1 (Codex 9.0). Eight cells changed and no code: objectives reordered
  to follow the tasks, the Task 3 itinerary sentence cut, the Task 2 opener
  trimmed, a Newey-West lag rule of thumb (L near N^(1/4)) and a reading of the
  L = 0 row added, all word-neutral. The
  [saved review record](lectures/instructor/L6b-DIAGNOSTICS-REVIEW-HANDOFF.md)
  lists the Codex items declined and why. The instructor accepted the round
  the same day. No proposals remain pending; do not restart unless another
  round is requested.

## L6b client interview demo — September 30, 2026

- For the October 1 lecture, the instructor asked for a live demo modeled on the
  eCornell Session 1 ticker interview. [The interview](lectures/week-6/L6b/interview/interview.md)
  runs with Claude Code's AskUserQuestion UI. Three questions set a beta band,
  exclusions, and the client's risk-free fraction, and
  [`screen-tickers.jl`](lectures/week-6/L6b/interview/screen-tickers.jl) picks
  the firms. The instructor did not like the eCornell archetype lists, which were
  hand-picked large caps (AAPL, MSFT, JPM, and AMT in all five, and mostly
  2014–2024 winners in the growth lists). The screen is therefore a fixed rule:
  the top two SIM R² per GICS sector inside the band, never mean growth. Do not
  replace it with curated lists.
- The RA and RRFA examples read `data/my-tickers.csv` if it exists and otherwise
  use the thirteen L6a firms. RRFA also reads `data/my-client.toml` and labels
  the client's w_f in the Task 3 figure and table. Both files are gitignored.
  With no client files, every stored text output matched the reviewed
  September 28 outputs except the new ticker print line. The examples ran
  without errors on all three bands, with exclusions, add/drop, and a new w_f.
  Two tables no longer crop: the Task 3 table (`fit_table_in_display_horizontally`)
  and the RA weights table (`fit_table_in_display_vertically`).
- The instructor then split the lecture's Examples section in two (approved as
  previewed). In lecture: the L6a MAGBM carryover, the client interview, RA, and
  RRFA. Review on your own: SIM estimation and parameter uncertainty. These are
  core examples, distinct from the Optional Advanced Material. Their in-lecture
  stops are labeled "Example (review on your own):". The instructor moved the
  interview stop into one "Examples:" block with the RA stop, just before RA
  runs, and the RA stop now says "the client's firms." The
  L6b slides were synced to this split on September 30 for week-06.3 (see the
  [slides record](lectures/instructor/L6b-SLIDES-REVIEW-HANDOFF.md)).

## L6b tangent derivation companion — September 30, 2026

- At the instructor's request, a markdown-only [tangent derivation companion](lectures/week-6/L6b/advanced/tangent-derivation/CHEME-5660-L6b-Derivation-Tangent-Fall-2026.ipynb)
  follows the L6a GMV and target-growth companions. It derives the Sharpe-ratio
  gradient and the zero budget multiplier (T-2), the tangent weights (T-3), and
  why the GMV growth rate must exceed g_f (the normalizing denominator factors
  into a positive term times the GMV excess growth). It then gives the
  Cauchy–Schwarz bound on the Sharpe ratio and, as the instructor asked, the
  risky and risk-free problem with short positions, which selects the same risky
  mix and traces the CAL. The lecture's tangent box links it in one sentence,
  and `advanced/README.md` lists it second. As in L6a, it is not in the
  lecture's Optional Advanced Material list, so the two-notebook cap there is
  unchanged. Codex checked it twice (8.5, then 9/10 after fixes). The fixes
  assume M ≥ 2 and unequal expected growth rates, and they correct a long-only
  sentence: long-only bounds can change the risky direction, and the common
  direction lasts only until an upper bound binds. Codex's cuts to the
  zero-multiplier and scalar-k sentences were declined, since those sentences
  fill the lecture's gaps. The instructor has not yet reviewed the draft.

## Completed L7a lecture review

- The instructor marked the L7a SIM portfolios and risk-free asset lecture
  reviewed October 2, 2026, after a polish, voice, and organization round
  (initial 8.2/10, final 9.0/10; Codex 8.5 before the closing fix). The
  [saved review record](lectures/instructor/L7a-LECTURE-REVIEW-HANDOFF.md)
  lists the accepted steps and checks:
  - the Concept Review displays the SIM equation, defines its symbols where
    used, and drops the variance box that SIM-1 repeats;
  - the BlackRock profile has its founders, iShares, Aladdin, a dated
    internship line, and videos, with every fact sourced;
  - the opening, Objective 2, and the client-files note were rewritten;
  - the CAL derivation is one step per line, and the risk-free section is
    split into one cell per subsection;
  - the takeaways state results, and Takeaway 3 gives the condition
    two-fund separation needs.
  The two-fund separation subsection is unchanged. No proposals remain
  pending; do not restart unless another round is requested. The deck was
  synced and approved the same day (17 to 16 pages, zero overfull boxes); the
  record lists the frame changes. A follow-up the same day added the SIM
  covariance derivation to the Concept Review at the instructor's request:
  the diagonal and off-diagonal entries, with `=0` underbraces on the dropped
  terms, and the assembled matrix. The deck's Concept Review became two frames
  (17 pages). Later the same day, a two-matrix split showed where D_g comes
  from, and a five-line Var(g_p) derivation (the 2025 L8b route) was added
  before SIM-1. The deck gained a Portfolio Risk slide (18 pages).

## L6b SIM derivations for re-recording — October 2, 2026

- The instructor is re-recording L6b after a technical glitch and asked for
  the clearer SIM derivations developed for L7a. In the lecture, cell 8 now:
  - derives the diagonal variance step by step;
  - marks the dropped terms with `=0` underbraces;
  - shows the two-matrix split that defines D_g;
  - derives Var(g_p) from the L6a double sum.
  Cell 5's risk calculation also marks its zero term. The deck went from 29
  to 30 pages with zero overfull boxes. The
  [slides record](lectures/instructor/L6b-SLIDES-REVIEW-HANDOFF.md) lists the
  frames. Week 6 needs a week-06.4 release before students see the update.

## L6b least-squares matrix renamed — October 4, 2026

- The L6b lecture's parameter-uncertainty derivation called
  (X̂ᵀX̂)⁻¹X̂ᵀ **A**, which clashed with the L5b/L6a MAGBM loading matrix
  (AAᵀ = C). The instructor chose the pseudoinverse **X̂⁺**, which also
  matches VΣ⁻¹Uᵀ in the SVD estimation example. **A** is reserved for the
  loading matrix. The SVD example's Σ (singular values) was left as-is by
  request. Released as week-06.9; see the
  [release record](lectures/instructor/WEEK-06.9-RELEASE-HANDOFF.md).

## Completed L7a tangent derivation review

- The instructor asked for a polish round on the L7a tangent derivation
  companion if it scored below 9.0. It opened at 8.9 (Codex 8.9). One
  markdown-only step was approved October 2, 2026, and the round closed at
  9.1 (Codex 9.0). This is the instructor's first review of the September 30
  draft. The [saved record](lectures/instructor/L7a-TANGENT-DERIVATION-REVIEW-HANDOFF.md)
  lists the seven changed lines, the checks, and the declined suggestions:
  - why the means must differ;
  - the named L6a GMV derivation;
  - why the lecture's growth floor binds;
  - "feasible target" in the long-only note.
  The objectives, takeaways, and boxes are unchanged. The instructor marked the
  companion reviewed the same day. The L6b copy shipped in week-06.2 and still
  has the earlier text. No proposals remain pending; do not restart unless
  another round is requested.

## Completed L7b review

- The instructor marked the L7b material reviewed October 9, 2026. This covers
  the lecture, both examples, the tangent portfolio notebook, the SIM reference
  page, the CES limits companion, the income-gamble interview, and the deck.
  The last round re-scored the committed files. Interview 9.2, CES limits 9.1,
  and the lecture 9.0 were at or above the bar. The SIM reference was 8.9, the
  CAL example 8.8, the tangent portfolio notebook 8.6, and the allocator 8.3
  (8.8 without length). The approved fixes were then applied. The reviewers
  estimate about 9.0 to 9.1 for the SIM reference, CAL example, and tangent
  notebook. These estimates were not re-measured, because the instructor
  closed the round.
- The allocator's length is not a deduction. The instructor: "I'm not cutting
  the allocator text - you are wrong there". Do not score it down for density
  or propose cuts. Change only mathematical mistakes, technical errors, and
  awkward phrasing.
- The October 9 sections of
  [the lecture review record](lectures/instructor/L7b-LECTURE-REVIEW-HANDOFF.md)
  list every change, the declined items, and the checks. Still open:
  - the deck's interview frame;
  - the week-07.2 release, which ships everything committed since week-07.1.
- Cobb–Douglas budget with cash (instructor, October 9). The lecture's box
  reads $\sum_i n_iS_i(t)+\text{cash}(t)=W_{\mathcal{P}}(t)$ with
  $\text{cash}(t)\ge0$. Cash does not enter the utility. One derivation line
  sets $\text{cash}^\star=0$ when the basket is not empty, and with an empty
  basket the model gives the floors plus cash. This matches what
  `allocate_cobb_douglas` returns, `(shares, cash)`. The instructor chose this
  over writing the budget as "≤", and his 2025 and eCornell versions keep the
  equality. The deck (slides 17 and 18) and the package docstring match.
  L13a is paused and still states the equality.
- No proposals remain pending. Do not restart unless another round is
  requested.

## Interactive notebook polishing

For a "notebook polish round," use the versioned
[notebook-polish workflow](.agents/skills/notebook-polish/SKILL.md).
It preserves the opening assessment, section-by-section approval, and final
rescoring. [Moving this workflow to another machine](lectures/instructor/NOTEBOOK-POLISH-WORKFLOW.md)
describes the shared CHEME 5660/CHEME 5800 setup. Keep the workflow here as the
single maintained copy; CHEME 5800 links to it.

The instructor requested cleanup of `build/notebook-previews` on September 13,
2026. Historical preview links may no longer resolve; use the saved review
handoffs and regenerate previews from the current notebooks when needed.

## Derivation companions listed in Optional Advanced Material — October 24, 2026

- The instructor reversed the L6a/L6b practice of linking derivation companions
  only from their lecture box ("that hurts discoverability"). The Optional
  Advanced Material sections of L5a (EMA), L6a (GMV, target growth), L6b
  (tangent), L7a (tangent), and L10a (Delta–POE) now list them in the L8b/L9b
  entry format, and the rule is in the shared style guide. Companions still do
  not count against the two-to-three notebook cap. The L5a–L7a edits go to main
  for readers of the repository. The released week bundles will be updated
  later. The decks were not changed, because their derivation slides already
  link the companions.
- Same day, at his request, the 15 older entries in the L4a–L7b lists that
  opened with a question now open with "In this notebook," and fold the
  question into the first sentence. L7b reuses the L8b CES description. The
  L5b Itô entry lost its math and its lecture-number reference (text-only
  rule), and the L4a, L4b, L5a, and L5b list introductions lost their
  semicolons and "not prerequisites for L…" clauses.
- Same day, the 11 L2a–L3b entries ("This example…", imperatives, "In this
  optional … notebook") were converted too. The two L2b entries that link a
  folder of notebooks (yield curves, STRIPS) open with "In these notebooks,".
  The L3b entries spell out their symbols, and the two markdown-only
  derivations end with "It is a derivation notebook with no code." Every
  Optional Advanced Material entry outside week 13 now opens this way.
