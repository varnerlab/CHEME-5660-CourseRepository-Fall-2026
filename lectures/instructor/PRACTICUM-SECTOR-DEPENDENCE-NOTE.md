# Practicum idea: dependence between sectors

Recorded 2026-11-20 as a candidate for the practicum, which is released Sunday, November 29. Nothing is built yet.

## The gap

In the sector factor model in JumpHMM 0.6.0 (`MySectorFactorModel`), each sector model gets its own seed in `sample_draws` (`src/SectorFactor.jl`). Sectors are linked only through the market draw.

The real sector factors are not independent. Each sector factor is the average single index residual of the stocks in that sector, from 2014 to 2024, for the universe in the L14a SectorFactor example. The market part is already removed.

| Pair of sector factors | Real correlation |
|---|---|
| Real Estate and Utilities | 0.58 |
| Industrials and Materials | 0.57 |
| Financials and Industrials | 0.52 |
| Consumer Staples and Utilities | 0.48 |
| Energy and Materials | 0.44 |
| Information Technology and Utilities | −0.33 |
| Information Technology and Consumer Staples | −0.33 |

- The average over all 55 pairs is 0.12. Fourteen pairs are beyond ±0.3.
- Two groups stand out. Industrials, Materials, Financials, Energy, and Consumer Discretionary move together. Utilities, Real Estate, and Consumer Staples, the sectors that react to interest rates, also move together.
- Information Technology moves against the rate-sensitive group.
- The first two shared series account for 44% of the daily variation in the 11 sector factors.
- On the worst 5% of market days, the strongest pair rises to 0.75.
- On a synthetic path, every pair is within ±0.04.

The average correlation between stocks in different sectors already matches: 0.342 on the synthetic path, 0.345 in the real data. Adding dependence would fix which sectors move together, not that average.

## Why it matters

The γ basket spreads its picks across sectors. With independent sectors, the synthetic markets give that spread more protection in a sell-off than the real market does.

## Three ways to add it

1. **Second layer of factors (recommended).** Pull one or two shared series out of the 11 sector factors. Give each shared series its own jump hidden Markov model, as `SPY` has now, and let each sector load on them. The part of each sector factor that is left over keeps its own model. This copies the structure of the market layer, so it reuses the existing fit, tune, and simulate code. Linked sectors would then have their calm periods, stormy periods, and jump episodes on the same days.
2. **Correlated random numbers.** Keep the 11 sector models, but feed them correlated random numbers from a Gaussian copula. This is the smaller change. Each sector still moves between calm and stormy periods on its own, so the stormy periods don't line up, and the correlation comes out weaker than in the data. The package's existing copula option (`simulate` in `src/Portfolio.jl`) reorders each path, which erases volatility clustering, so it can't be reused as is.
3. **Interest rate factor.** Use the daily change in the 10-year Treasury yield as a second index next to `SPY`. This is the easiest to explain. It needs rate data in the course package and a model for the rate.

## What it touches

- **JumpHMM:** new fit and sampling code, tests, a new release, and a new version pin in the course.
- **L14a SectorFactor example:** refit and retune the generator (a few minutes), then a new heatmap and new text. The sentence "only the shared market draw links different sectors" changes, and so do the Key Takeaway and the matching sentence in the lecture.
- **L14a strategy cache:** its 1,000 synthetic markets come from this generator. Keeping them consistent means rerunning `lectures/week-14/L14a/scripts/run_strategies.jl`, about 75 minutes on 28 threads.

Leave the L14a generator unchanged until after the freeze on Sunday, November 22.

## How to recompute the numbers

1. Load the saved generator from `lectures/week-14/L14a/data/JumpHMM-SectorFactor-Universe-2014-2024.jld2` and take its `dependence` field, `dep`.
2. Compute the growth rates `G` of its tickers with `JumpHMM.excess_growth_rates(prices; rf = 0.0, Δt = 1/252)`.
3. Compute the single index residuals: `E = G[:, 2:end] .- dep.α' .- G[:, 1] * dep.β'`.
4. Build the sector factors with `F = JumpHMM.sector_factors(E, dep.sector).F`, then take `cor(F)`.
5. For the synthetic comparison, use `JumpHMM.sample_draws(dep, number_of_days; seed = 5660).F`.
