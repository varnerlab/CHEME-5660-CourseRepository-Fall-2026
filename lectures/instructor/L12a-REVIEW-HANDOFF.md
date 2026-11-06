# L12a review record: agent-based markets

## November 5, 2026: new lecture, two examples, deck

New lecture for Tuesday, November 10 (freeze Sunday, November 8), built after weeks 12 and 13
were swapped. Design: `private/specs/2026-11-05-week12-L12a-minority-game-farmer-joshi-design.md`;
plan: `private/plans/2026-11-05-week12-L12a-abm-plan.md`.

### Files

- Package: `code/src/AgentBasedMarkets.jl` (`MyThermalMinorityGameModel`, `boltzmann_weights`,
  `MyFarmerJoshiMarketModel`, `threshold_position`, `build`, `solve`), docs page `code/docs/src/abm.md`,
  tests `code/test/test_agent_based_markets.jl`, hand-run acceptance script
  `code/test/acceptance/abm_acceptance.jl`.
- Lecture: `CHEME-5660-L12a-Lecture-AgentBasedMarkets-Fall-2026.ipynb` (no code cells).
- Examples: `CHEME-5660-L12a-Example-ThermalMinorityGame-Fall-2026.ipynb`,
  `CHEME-5660-L12a-Example-FarmerJoshi-Fall-2026.ipynb`.
- Deck: `slides/CHEME-5660-L12a-Slides-Fall-2026.tex` (18 pages); figures in `figs/` are the
  executed example outputs (seed 5660).
- Notation: L12a section and Context-table rows in `code/docs/faq-src/content.json`, rebuilt
  with Pandoc 3.1.11.1.

### Model conventions and deviations from the papers

- **Minority game.** The binary lookup-table model of Challet and Zhang (1997) with the score
  normalization of Challet, Marsili, and Zecchina (2000), $U_{is}(t+1)=U_{is}(t)-a_{is}^{\mu(t)}A(t)/P$,
  and the Boltzmann choice of Cavagna, Garrahan, Giardina, and Sherrington (1999). Cavagna et al. use
  a continuous strategy sphere and scores divided by $N$; our temperature is in units of
  $P$-normalized scores, so $T_{\text{Cavagna}}=\alpha T_{\text{ours}}$. Stated in the lecture and the deck.
  Temperature $0$ breaks ties uniformly at random; temperature $\infty$ is uniform choice.
- **Critical value.** $\alpha_c\approx 0.3374$ (CMZ, $S=2$, very many agents) is cited, not
  derived. The simulated minimum is reported separately from it.
- **Farmer–Joshi price noise (instructor decision, November 5).** Table 1 of the paper prints
  $\sigma_\xi=0.35$. Our faithful implementation with that value gives log-return standard
  deviations near 0.5 per step, and the price wanders tens of log units from the value (with
  value investors only, median $|p-v|$ from 2 to 49 depending on the seed; their total position is
  only about $\pm6.6$ in the units of $\lambda$, so they saturate). The paper's Figure 10 shows the
  price within about $\pm1.5$ of the value, and the text says parameters were chosen to match real
  price volatility. A scan over $\sigma_\xi$ (8 seeds per value) showed that the trend followers
  rarely trigger for $\sigma_\xi\le 0.025$, and that for $0.035\le\sigma_\xi\le 0.07$ the price
  tracks the value with large kurtosis and clustering but a seed-dependent return
  autocorrelation. The instructor chose $\sigma_\xi=0.05$, labeled as our variant everywhere.
  The package default stays at the printed 0.35.
- **Farmer–Joshi value process.** The paper drives the combined run with interpolated S&P 500
  dividends; we use a random walk with $\sigma_\eta=0.01$. Before the $\sigma_\xi$ change, the
  calibration gate showed the combined lag-1 return autocorrelation was about 0.5 for every
  $\sigma_\eta$ in 0.001–0.03 and for a smooth linear path, so the value process is not the cause
  of the gap to the paper's near-zero autocorrelation; the population mix is.
- **Trader mix (instructor decision, option 1).** Table 1's 1,200/1,200 is kept, and Example 2
  shows a sweep of the number of trend followers instead of retuning the model.

### Symbols (new or reused in L12a)

Minority game: $N$, $i$, $m$, $P=2^m$, $\alpha=P/N$, $\alpha_c$, $\mu(t)$, $S$, $s$, $a_{is}^{\mu}$,
$a_i(t)$, $A(t)$, $U_{is}(t)$, $\sigma^2/N$, $\langle\cdot\rangle$. Maximum entropy: $\pi_s$,
$\pi_{is}$, $\mathcal H(\pi)$ (new), $\bar U$, $\mathcal L$, $\phi_0$, $\phi_1$ (new), $T=1/\phi_1$,
$\mathcal Z$ (new), $\Delta$. Farmer–Joshi: $p_t$, $v_t$, $v^{(i)}$, $x_t^{(i)}$, $c_i$, $a$,
$\chi^{\text{in}}_i$ and $\chi^{\text{out}}_i$ (new; the paper's $T$, $\tau$), $\theta_i$,
$\omega_{t+1}^{(i)}$, $\lambda$, $\xi_t$, $\sigma_\xi$, $\eta_t$, $\sigma_\eta$, $r_{t+1}$,
$\sigma_r$; real ticker $S_t$, $g_t$.

Choices: $T$ is the temperature (thermal-physics standard; expiration does not appear in L12a),
so the Farmer–Joshi thresholds became $\chi$. The multipliers are $\phi_0,\phi_1$ because $\lambda$
is the Farmer–Joshi liquidity (and the package field) and $\beta$ is the SIM beta. The choice
probability is $\pi$ because $p_t$ is the Farmer–Joshi log price. Reused symbols ($\alpha$,
$\lambda$, $\mu$, $T$, $c$, $A$, $U$, $r$, $\theta$, $\omega$, $\xi$, $\eta$, $\pi$, $S$, $m$, $P$,
$a$) have Context-table entries. The package docstrings still write the thresholds as $T$, $\tau$
(the paper's symbols).

### Seed checks (every prose claim must hold for seeds 5660, 5661, 5662)

Example 1 (runs in 70–74 s):

| Quantity | 5660 | 5661 | 5662 |
|---|---|---|---|
| Task 1 $\sigma^2/N$ ($N=641$) | 2.80 | 2.84 | 2.74 |
| $\alpha$ at the simulated minimum | 0.354 | 0.374 | 0.398 |
| Smallest average $\sigma^2/N$ | 0.142 | 0.146 | 0.144 |
| Greedy ($T=0$) | 2.72 | 2.87 | 2.85 |
| Smallest at finite $T$ (all at $T=100$) | 0.462 | 0.463 | 0.453 |
| Random choice ($T=\infty$) | 1.08 | 1.03 | 0.99 |

All: crossing of the coin-flip line near $\alpha\approx0.2$; flat to $T\approx0.3$, steep drop from
$T=1$ to $10$, below both limits from $T=10$ to $1{,}000$. The high-temperature end depends on run
length (scores accumulate: at $T=1{,}000$, 0.75, 0.68, 0.61 for 5k, 10k, 20k rounds), so the prose
quotes no high-temperature values.

Example 2 (runs in 27–38 s):

| Quantity | 5660 | 5661 | 5662 | SPY |
|---|---|---|---|---|
| Value only: sd, lag-1 ACF | 0.050, −0.024 | 0.051, −0.031 | 0.052, −0.038 | |
| Trend only: sd, lag-1 ACF | 0.34, 0.91 | 0.34, 0.92 | 0.33, 0.92 | |
| Both: sd, lag-1 ACF | 0.23, 0.27 | 0.19, 0.37 | 0.27, 0.035 | −0.110 |
| Both: excess kurtosis | 45 | 57 | 89 | 13.8 |
| Both: ACF of $\lvert r\rvert$, lags 1, 5 | 0.67, 0.025 | 0.67, 0.038 | 0.69, 0.085 | 0.364, 0.325 |

Trader-mix sweep, per market: at 600 or fewer trend followers, kurtosis ≤ 1.2 and lag-1
ACF of $\lvert r\rvert$ ≤ 0.04; at 900, each seed had both quiet and bursting markets; at
1,200 and 1,500, every market had kurtosis 27–81 and lag-1 ACF of $r$ from −0.079 to 0.53, all
above SPY's −0.110.

Claims that failed the seed check and were rewritten before commit: "fat tails come with a positive
return autocorrelation" (seed 5662 at 1,200 trend followers averages −0.022); "most markets at 900
trend followers have both" (one of three for seed 5660); "the autocorrelations reach the band within
15 steps and stay slightly below zero" (seed 5661 differs).

### Codex audits and dispositions

- **Plan review (before building):** findings applied to the plan and spec (Task 0 in the plan ledger).
- **Lecture and examples audit (November 5):** verified the Lagrangian signs, the stationarity
  and second-order conditions, $-d\mathcal H/d\bar U=\phi_1=1/T$ (envelope theorem), the limits,
  $e/(e+1)=0.7311$, the code match, the temperature scaling, the four literature facts, and that
  there are no forward links. Applied after verification: the condition on $\bar U$ (strictly
  between the mean and the maximum score, scores not all equal); the entropy at $T\to0$ is zero
  only for a unique best strategy; "most score gaps" and "rises slowly" rewritten to what the
  outputs show; "no clustering" at 600 trend followers softened (0.024 vs a band of 0.014); the
  900-trend-follower claim rewritten to what the plots show; "no mix matches" restated as "every mix
  misses on at least one statistic by a wide margin"; $\chi^{\text{in}}>0\ge\chi^{\text{out}}$
  stated as a Table 1 range, not part of the rule; position size tied to the gap between the
  thresholds; "unlike the paper's figure" softened to "much farther than in the paper's figures"
  (Figure 10 is annually averaged); the standard deviation symbol $s$ replaced by $\sigma_r$;
  $\Delta$, $k$, $S_t$, $g_t$ added to the notation; the coin-flip value stated as an expectation.
  Not applied: input constants (10,000 rounds, 1,200 traders, 20,000 steps, $\sigma_\xi$) are not
  printed as outputs, but they are visible in the examples' Constants cells and are inputs, not
  results.

### Verification

- Package tests: 2,181/2,181 and MPC 1,268/1,268; docs build exit 0 with the L12a anchor in the
  notation page.
- Deck: latexmk exit 0, zero Overfull lines, every page rendered and inspected.

### Open for the instructor

- Read-through of the lecture, both examples, and the deck before the Sunday freeze.
- Package docstrings use the paper's $T$, $\tau$ for the thresholds; align with $\chi$ if wanted.
- NotebookLM materials, the self-check quiz, and the engagement quiz come after the lecture.

## November 5, 2026 (later): In the News section instead of a company profile

The instructor chose no company profile (no company uses these models in a way worth profiling)
and asked for a tie-in to the November 5 sell-off. Added a lecture section and one deck frame
(slide 6) after the Examples. Facts are from two CNBC articles of November 5: the Nasdaq fell
5.5% into correction and the S&P 500 about 4.4%, the steepest one-day declines since the April
2025 tariff shock, on worries about AI data-center spending after the midterms; the seven largest
technology companies lost more than 1 trillion USD; retail investors sold a net 338 million USD
of single stocks (Vanda Research, measured before the close), the largest one-day outflow since
March 2020, with Vanda's quote that the dip-buying bid "has effectively disappeared from
individual names." Left out on purpose: the Dow figure (CNBC's article gives two conflicting
values) and the leveraged-ETF buying (buying a falling market with leverage is not trend
following, so it would muddy the value-investor mapping). The connection is posed as a question
for the trader-mix result, not as an explanation of the sell-off.

## November 5, 2026 (later): figures and pseudocode

At the instructor's request ("we need to make some figures, and each method needs p-code"; his
NSF-proposal minority game figure was the starting point):
- `figs/Fig-L12a-MinorityGame` (end of The Minority Game): one round with both feedback paths
  (the minority action into the history, the attendance into every strategy's score), and one
  agent's two strategy tables for m = 3 with the current history row, the scores 2.4 and 0.9, and
  the Boltzmann probabilities 0.73 and 0.27 at T = 1.5 (the score gap, matching the lecture's
  0.73 at T = Δ).
- `figs/Fig-L12a-FarmerJoshi` (Farmer–Joshi section): one step of the market and the value
  investor's threshold rule as three states; transitions checked against `threshold_position`.
- Pseudocode in the course format: the thermal minority game algorithm (end of the derivation
  section) and the Farmer–Joshi algorithm (after the figure). New symbols, all added to the L12a
  notation section: the signal $\zeta_t^{(i)}$ (unused course-wide), the drawn strategy $s_i(t)$,
  the per-agent $\mathcal Z_i(t)$, and the run length $R$ (rounds or steps).
- Deck: one frame per figure panel (cropped from the PDF) and one frame per algorithm; 25 pages,
  zero Overfull lines. Both SVGs checked in light and dark mode with headless Chrome.

## November 5, 2026 (later): results as figures, one section per model

At the instructor's request ("way too much text", results belong under the minority game section,
example callout at the end of the results): the lecture now has one `##` section per model. The
minority game section holds the setup and schematic, the derivation (`###` with `####` parts), the
algorithm, and `### What the minority game shows`; the Farmer–Joshi section holds the model and
schematic, the algorithm, and `### What the Farmer–Joshi market shows`. Each results subsection is a
one-paragraph lead, a results figure, two "What do we see?" bullets, and the example callout. The
results figures (`figs/Fig-L12a-MinorityGame-Results`, `figs/Fig-L12a-FarmerJoshi-Results`) are
pgfplots charts from CSVs that `figs/generate_results_data.jl` writes by replaying the examples
with seed 5660 (values match: 2.723, 1.081, 0.142 at 0.3536; 45.25, 0.271; SPY 13.77, -0.110), so
they follow dark mode. Removed from the lecture: the paragraph-length result bullets, the water
analogy, and the "one way to read it" interpretation. The deck now uses the same figures; the three
example PNGs were removed. Every bullet claim was checked against the per-market values for seeds
5660-5662 (kurtosis above SPY's and lag-1 autocorrelation above SPY's for every market with 1,200 or
more trend followers).

## November 5, 2026 (later): schematics revised for less text

The instructor asked whether the schematics were the best they could be ("the minority game has a
lot of text"). Minority game: the rotated score formula and the brace sentence became short labels
("update every score", "append to the history", "history μ(t)", "minority"); panel B's paragraph
became three table rows under the strategy columns (score, π at T = 1.5, and ↓/↑ after the round).
Farmer–Joshi: panel A lost its two repeated threshold notes and the net-order equation (a Σ node
with "orders" labels instead); panel B is now the position-against-signal loop of Farmer and
Joshi's Fig. 4 (enter at ±χ^in, hold, exit at ±χ^out) in place of the state machine and its three
lines of text. Alt texts, the lecture lead sentence, and the deck crops (split at the blank gap
between panels) were updated; both SVGs checked in dark mode.
- Same day: the instructor did not find the position-signal loop clear and preferred the state
  machine, so panel B of `Fig-L12a-FarmerJoshi` is the state machine again (with its three text
  lines); the simplified panel A stays. Alt text, lead sentence, and deck crop restored to match.

## November 5, 2026 (later): paper references

The instructor asked to download the four papers into `docs/` and link to the local PDFs. All four
carry arXiv's default "assumed 1991–2003" license (no third-party redistribution) and the repository
is public, so, with his OK, the lecture instead has CRR-style `__Reference:__` entries (citations
checked against Crossref) that link to the free arXiv PDFs, and the inline author links now point
there too: Challet–Zhang and Challet–Marsili–Zecchina in The Minority Game, Cavagna et al. in the
derivation, Farmer–Joshi in The Farmer–Joshi Market. The examples and the deck link the same arXiv PDFs.

## November 6, 2026: connection paragraph, policy notation, and a minority-game price

Instructor requests, in order:

- **Connection paragraph** (In the News): rewritten around individual decisions, with the
  Financial Crisis Inquiry Commission's 2011 conclusion quoted from the report PDF ("the result of
  human action and inaction"; "To paraphrase Shakespeare, the fault lies not in the stars, but in
  us"). Both phrases were checked word for word in the govinfo PDF. The value-investor/trend-follower
  sentences and closing question were removed at the instructor's request. The deck's Connection
  line and source note follow.
- **Definition of the minority game**: less game jargon, traders buying or selling one asset, the
  attendance as buyers minus sellers, and $\alpha$ defined in words before the display. A first draft
  that gave the game a price and called actions "orders" was rejected in Codex pre-review (the game
  had no price, and "order" is the Farmer–Joshi $\omega$).
- **Notation (decided by the instructor)**: strategy → policy $\pi_{ij}$, with $\pi_{ij}(\mu)$
  replacing $a_{is}^{\mu}$; $J$ policies per agent (index $j$); scores $U_{ij}$; Boltzmann choice
  probabilities $p_{ij}$ / $p_j$ (kept despite L13a's Markov $p_{ij}$; a Context-table row separates
  them, and another separates $J$ from L13a's $J(\epsilon,\lambda)$); price $S$, so the Farmer–Joshi
  log price $p_t$ is now $\ln S_t$ everywhere (lecture, example, deck, figure, package docstrings).
- **Instructor's extension: a minority-game price**, from his VLMinorityGameKit.jl
  (`r = A/liquidity + Normal(0, σ)`, `S ← S·exp(r)`): $\ln S(t+1)=\ln S(t)+A(t)/\lambda+\xi(t+1)$,
  $S(1)=1$, the Farmer–Joshi market-maker rule with the attendance as excess demand. Challet,
  Chessa, Marsili, and Zhang (arXiv cond-mat/0011042, eq. A4) define a related price with the
  opposite sign and no noise; the lecture says so. The lecture states the mean-square identity
  $\langle(\Delta\ln S)^2\rangle\approx\sigma^2/\lambda^2+\sigma_\xi^2$ (a second moment, not a
  variance; Codex caught the variance version) and that the volatility per agent sets the size of
  price moves only at fixed $N$ and $\lambda$. The Farmer–Joshi section no longer says the
  minority game has no price; it says the minority-game price never feeds back into decisions.
- **Thermal example, Task 1**: new subsection "From the attendance to a price" (objective 1 and
  takeaway 1 absorb it; still three of each). Fixed $N=641$, memory 6 ($\alpha\approx0.10$) against
  memory 8 ($\alpha\approx0.40$), $\lambda=1000$, $\sigma_\xi=0.002$, one shared noise path from a
  separate RNG (seed 5661) so the games' own draws are untouched. Output: measured mean square
  matches $\sigma^2/\lambda^2+\sigma_\xi^2$ to three digits in both markets; root mean square
  0.0425 vs 0.0119. The crowded price peaks at 2.53 × its start (round 365) and falls to 1.18 within
  30 rounds; the near-critical price stays in [0.92, 1.29] (checked numerically, not read off the plot).
- **Package**: `MyThermalMinorityGameModel` field `S` → `J`, `strategies` → `policies`, build key
  `J` (the retired key `S` now throws, so a stale call cannot silently build `J = 2`); Farmer–Joshi
  `solve` keyword `p₀` → `initial_log_price` (no caller used it). Golden attendance/history test
  recorded before the rename passes after it; all pre-existing example outputs are unchanged except
  the renamed column header, and the results CSVs regenerate byte for byte.
- **Notation page**: `content.json` (the source) updated and `notation.html` rebuilt with Pandoc
  3.1.11.1; only `notation.html` changed.
- **Growth rates and stylized facts** (instructor request, same day): the lecture's extension
  subsection derives $g(t)=\frac{1}{\Delta t}\ln\frac{S(t+1)}{S(t)}=\frac{1}{\Delta t}(A(t)/\lambda+\xi(t+1))$
  and says fat-tailed noise gives fat tails by construction, while independent noise cannot give
  volatility clustering. The thermal example adds `noise_model` (`:normal`/`:studentt`, rescaled to
  `σ_ξ`), `ν = 3`, `Δt = 1/252`, `lags`, and a stylized-facts table (`stylized_facts_report`, as in
  the Farmer–Joshi example). Normal noise: crowded excess kurtosis 1.08, near-critical 0.11; every
  ACF of $g$ inside the ±0.020 band; ACF of $|g|$ above the band only near $\alpha_c$ at lag 1
  (0.040). The "Try" line (Student-t, `σ_ξ = 0.02`) was run before it was written: kurtosis 2.54 and
  21.72, every ACF of $|g|$ inside the band.
- **Codex post-change audit, fixes applied**: leftover "random strategy choice" and a "strategies"
  code comment; the Context-table $U$ row ($U_{ij}$); the FJ docstring volume index
  ($\omega_{t+1}$); the mean-square statement now says the noise is independent of the attendance
  and that the size claim needs fixed $N$, $\lambda$, and $\sigma_\xi$ (lecture and deck); "same
  agents" → "same number of agents" in the price comparison, whose conclusion is now that the two
  paths differ because their attendances differ (the second game is separately built).
- **Codex findings left for the instructor (pre-existing, not changed)**: the example takeaway
  "The same agents and rules behave differently…" (Task 2 builds new agents at every $N$); the
  Farmer–Joshi example is described differently in the Examples list and at the stop; the Boltzmann
  table cell has a checks block but no return block. Its deck-style findings (topic-style objectives
  and takeaways) were dismissed: the slide workflow is outside the notebook style reset.
- **`buy_probability` (instructor request, same day)**: new optional `build` key for
  `MyThermalMinorityGameModel` (default 0.5 keeps the original draw, so the golden test and every
  output are unchanged; 98 package tests pass). Scratch experiment (N = 641, T = 0, three games):
  with J = 2, agents whose two policies agree are frozen, leaving a built-in bias 2p − 1 that the
  switchers (fraction 2p(1 − p)) can cancel only for p ≤ 1/√2 ≈ 0.707. Measured: 91–97% of the
  bias removed for p ≤ 0.7; above, the attendance locks at the predicted (2p − 1) − 2p(1 − p)
  (0.13, 0.29, 0.65 measured vs 0.125, 0.28, 0.62), Var(A) = 0, and the drift is all of ⟨g²⟩.
  The thermal example has a `buy_probability` constant (0.5) passed to both Task 1 games, and a Try
  line for 0.8, verified by executing a scratch copy: attendance constant at 169 in both games, price
  up about 18% per round (λ = 1000). The Try line points at the attendance plot, because the price
  reaches about 1e36 by round 500. Package docs not yet rebuilt after the docstring change.
- **Biased-policies derivation moved to `advanced/biased_policies/`** (instructor: "too much for
  lecture"). The lecture keeps one pointer sentence after the symmetry paragraph, an Optional
  Advanced Material section before the Summary, and the Examples pointer line; the deck has the
  matching frame; `advanced/README.md` added. Symbol $b$ (buy probability; $p$ is the Boltzmann
  choice probability), $b_c=2^{-1/J}$. Codex check of the derivation, all verified and applied: the
  threshold is necessary, not sufficient; the lock holds with high probability for large $N$ and
  history information; the locked attendance is $2X-N\approx N(2b^J-1)$ (not an equality); "at
  $T>0$ more bias survives" was wrong above $b_c$ (score gaps grow without bound, so any finite $T$
  locks too; only $T=\infty$ keeps $2b-1$); "scores per policy" reworded (one score ties an agent's
  choices across histories). Context table gains a $b$ row.
- **Minority game schematic** (instructor, same day): panel letters removed, then the right-hand
  panel (one agent's policy tables, scores, Boltzmann probabilities, score change) dropped: it
  tried to show three ideas at once and the instructor was not sure what it taught. The figure is
  now the one-round loop only (width 520 in the lecture); the lecture lead sentence and alt text
  were rewritten, the deck's "One Agent's Policies" frame was removed, and the "One Round" frame
  shows the whole figure. Volatility-per-agent wording in the definition was cut back to the
  definition; the explanation (why divide by N, link to the growth rate) moved into the coin-flip
  bullet of "Three things to notice".

## November 6, 2026 (later): prose density pass and one notation for both price rules

- **Prose density** (instructor's hard rule, CLAUDE.md): nine lecture paragraphs or bullets over
  ~60 words or 3 sentences were split, and every semicolon was removed. Example-link descriptions
  follow the October 14 rule (three sentences, no itinerary). Codex reviewed before and audited
  after. Still over: both algorithm Initialize steps (pseudocode, ~71 and ~75 words), the
  phase-diagram "What do we see?" bullet (two paragraphs, ~70 words), and the in-lecture
  Farmer–Joshi example stop (one long itinerary sentence, unchanged).
- **Notation** (instructor chose subscripts for the whole minority game, matching Farmer–Joshi
  and the discrete-time price lectures L3a, L3b, L4b, L13a): $\mu_t$, $a_{i,t}$, $A_t$,
  $U_{ij,t}$ ($U_{ij,0}=0$), $p_{ij,t}$, $\mathcal Z_{i,t}$, $j_{i,t}$, $S_t$ ($S_0=1$),
  $\xi_{t+1}$. Rounds and steps both run $t=0,\dots,R-1$. Both price rules read
  $\ln S_{t+1}=\ln S_t+(\cdot)/\lambda+\xi_{t+1}$. The growth rate of either simulated price is
  $g_{t+1}=\frac{1}{\Delta t}\ln(S_{t+1}/S_t)$, indexed by the end of the interval as in L3a.
  The examples number recorded rounds from $t=0$ after the burn-in; the lecture algorithm is the
  whole game. $\pi_{ij}(\mu)$ is unchanged.
- **Farmer–Joshi growth rates** (instructor: $\Delta t=1/252$, as in the minority-game example):
  the log return $r_{t+1}$ became $g_{t+1}$. Note: L3a defines both $g$ and the log return
  $r=\Delta t\,g$, so $r$ was not wrong; the change makes the two models consistent. Standard
  deviations in the FJ example scale by 252 (1/yr); every scale-free statistic (kurtosis,
  autocorrelations, Hill index, bands) is unchanged after the re-run. The calibration caveat now
  says $\Delta t$ sets the units but the noise is not calibrated to the ticker.
- Updated: lecture, both examples (re-executed), biased-policies derivation, deck, MG and FJ
  results figures (labels), READMEs, package docstrings, FAQ notation (rebuilt). The package
  field `returns` keeps its name (code identifier).
- **Noise in the GBM form** (instructor, same day): $\xi_{t+1}$ and $\eta_{t+1}$ are replaced by
  $\sigma_S\sqrt{\Delta t}\,Z_{t+1}$ and $\sigma_v\sqrt{\Delta t}\,Z'_{t+1}$, $Z,Z'\sim\mathcal N(0,1)$
  i.i.d. and independent, with ANNUALIZED $\sigma_S,\sigma_v$ ($\mathrm{yr}^{-1/2}$) as in L4b/L5a.
  Name $\sigma_S$ because bare $\sigma$ is taken ($\sigma^2=\langle A^2\rangle$). The instructor
  required the code to run the lecture's equations: the package `MyFarmerJoshiMarketModel` now has
  fields `σ_S, σ_v, μ_v, Δt` (defaults `Δt = 1/252`, `σ_S = 0.35√252`, `σ_v = 0.16`); tests pass.
  Example constants: minority game $\sigma_S=0.03$; Farmer–Joshi $\sigma_S=0.8$, $\sigma_v=0.16$
  (paper's Table 1: 0.35 per step, $\sigma_S\approx5.6$). Both examples and the FJ results data
  were re-run. Moved numbers: FJ both-groups excess kurtosis 45.3 → 38.8, lag-1 autocorrelation of
  $g$ 0.27 → 0.31, of $|g|$ 0.67 → 0.65 (deck table, lecture alt text); panel B 900 trend
  followers ~100 → ~93, 1,200–1,500 range 27–60 → 26–55. Lecture-quoted −0.024 and 0.91 hold.
  New lecture sentence: the noise contributes $\sigma_S^2/\Delta t$ to $\langle g^2\rangle$, the
  growth-rate variance of GBM with volatility $\sigma_S$ (for a later GBM comparison).
- **Late additions, same day:** the coin-flip bullet now derives the baseline from a Bernoulli
  trial ($a_{i,t}=2X_{i,t}-1$, variance 1; attendance variance $N$), mirrored in the deck's
  "Volatility per Agent" frame. The volatility-per-agent definition no longer claims to show the
  $\alpha$ dependence in its display; it says simulations show the dependence on $N,m$ only through
  $\alpha$ (fixed $J$), and the crowding bullet explains the herding. The attendance mean square is
  renamed $\sigma_A^2$ (instructor: two $\sigma$s were confusing next to $\sigma_S$), with
  underbraces "agents" / "price noise" on $g_{t+1}$ and $\langle g^2\rangle$ and "attendance /
  cross / noise term" on $g_{t+1}^2$. Lecture, MG example (re-run, numbers identical), deck, MG
  results figure, and FAQ updated.
- **Farmer–Joshi schematic** (instructor, same day): notation already matched the lecture. Panel
  letters and titles removed; the text under the state diagram (otherwise unchanged, position size,
  trend-follower reversal) dropped because the lecture states all three; the state diagram is
  centered vertically and moved closer to the market loop. Lecture lead-in and alt text say
  left/right; lecture width 910 (same scale as before). Deck crops recomputed from the rendered
  gap (A: trim right 227bp; B: trim 308bp left, 92bp bottom, 72bp top, width 0.75\textwidth).
  Instructor kept the right panel after asking whether it was needed.
- **Boltzmann rule as a stated theorem** (instructor, same day): the lecture states the
  maximum-entropy result as "Theorem (Boltzmann choice rule)" without the search framing or the
  Lagrange proof. The proof, the expected-score derivative $d\bar U/dT=-\operatorname{Var}_p(U)/T^2$,
  and the thermodynamics remark ($-d\mathcal H/d\bar U=1/T$) moved to a new optional notebook,
  `advanced/max_entropy/CHEME-5660-L12a-Derivation-MaxEntropyChoice-Fall-2026.ipynb` (both formulas
  checked numerically). Learning objective and takeaway changed from "derive" to "use". Deck: the
  "Maximum Entropy" and "Boltzmann Rule" frames merged into one theorem frame; Physics line moved
  out; advanced frame lists both notebooks (26 pages). Advanced README updated and its
  "not a prerequisite for L12b" line removed (October 15 rule).
