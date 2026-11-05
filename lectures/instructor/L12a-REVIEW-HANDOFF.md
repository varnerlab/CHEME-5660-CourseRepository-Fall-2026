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
