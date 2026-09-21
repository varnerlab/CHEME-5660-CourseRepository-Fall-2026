# Daily market data snapshots

The daily market files are Polygon.io snapshots from the instructor's
`portfolio-F23` repository. Each JLD2 file contains a `"dataset"` dictionary
mapping ticker symbols to DataFrames. The source download configuration requests
adjusted daily bars in ascending time order. No rows are filled, filtered, or
modified when these files are copied into the course package.

## September 13, 2026 update

The 2025 source file was already identical to the bundled copy. The latest 2026
source file was added unchanged. The earlier 2026 snapshot ending April 22 was
superseded by the September 4 snapshot and was not imported.

| File | Date range | Tickers | Complete histories | SHA-256 |
| --- | --- | ---: | --- | --- |
| `SP500-Daily-OHLC-1-2-2025-to-12-31-2025.jld2` | 2025-01-02–2025-12-31 | 483 | 473 with 250 observations | `5526d1cb7eb458697723b756b98fcab2655bb8bfd6686d0e5ea0c65bf9938579` |
| `SP500-Daily-OHLC-1-2-2026-to-09-04-2026.jld2` | 2026-01-02–2026-09-04 | 475 | 465 with 170 observations | `805936bd2ea505020c8f30b860cddbe063a6430dc42189d4c81bb5b05b4e9492` |

Both snapshots have the same eight columns: `volume`,
`volume_weighted_average_price`, `open`, `close`, `high`, `low`, `timestamp`, and
`number_of_transactions`. Timestamps are stored as Julia `DateTime` values.
The import check found no empty histories, missing values, duplicate dates,
unsorted timestamps, or nonpositive/nonfinite VWAP values. Complete histories
share a common observation-date grid within each year.

`MyTestingMarketDataSet()` loads 2025;
`MyTestingMarketDataSet(year = 2026)` loads the partial-year 2026 snapshot.
`MyTrainingMarketDataSet()` loads the separate 2014–2024 training file.
Ticker membership and history lengths vary, so match datasets by ticker and
verify date alignment when using them together.

## September 20, 2026 correction to the 2014–2024 training file

The Polygon snapshot of `SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2` was not
consistently split-adjusted. A scan for single-day VWAP log returns larger than
0.5 in magnitude found two kinds of error among tickers with complete histories:
stock splits with no adjustment of the earlier rows (ALK, BF.B, CTSH, EOG, GOOG,
UA twice, UNP), and short runs of unadjusted rows immediately before a split
(MA, HBI, PPG, TECH, CHD). MA's ten unadjusted rows in January 2014 gave it a
fitted GBM volatility of 1.01 per square-root year instead of 0.23.

The affected rows were divided by the split ratio in `open`, `close`, `high`,
`low`, and `volume_weighted_average_price`, and `volume` was multiplied by the
same ratio. No rows were added or removed. The remaining large single-day moves
are real market events (APA, FANG, OXY, PENN in March 2020) or non-split
corporate actions that a split adjustment does not cover (BAX and NI spin-offs
in 2015, the HPQ separation in 2015, the CZR and IR ticker reassignments in
2020). Those were left unchanged. Tickers with incomplete histories (for example
INFO, LIN, DD) were not repaired because the course notebooks filter them out.

| Ticker | Unadjusted rows | Ratio |
| --- | --- | ---: |
| MA | 2014-01-07 to 2014-01-21 | 10 |
| HBI | 2015-02-05 to 2015-03-03 | 4 |
| PPG | 2015-05-07 to 2015-06-12 | 2 |
| TECH | 2022-11-10 to 2022-11-29 | 4 |
| CHD | 2016-08-11 to 2016-09-01 | 2 |
| ALK | file start to 2014-07-09 | 2 |
| BF.B | file start to 2016-08-18 | 2 |
| CTSH | file start to 2014-03-07 | 2 |
| EOG | file start to 2014-03-31 | 2 |
| GOOG | file start to 2014-04-02 | 2 |
| UA | file start to 2014-04-14, and file start to 2016-04-07 | 2 and 2 |
| UNP | file start to 2014-06-06 | 2 |
