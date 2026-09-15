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
