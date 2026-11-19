# One-minute SPY data for the L13b advanced notebook

These two scripts made `lectures/week-13/L13b/advanced/one_minute/data/SPY-OHLCV-1-min-2025-2026.jld2` on
November 18, 2026.

1. `pull_spy_1min.jl` downloads the one-minute bars of `SPY` from Alpaca, one CSV file per month, with the
   `alpaca-markets-sdk` package (version 0.4.0) and the keys in its `conf/apidata.toml`. Run it from the SDK
   repository: `julia --project=. pull_spy_1min.jl <folder for the CSV files>`. It requests the SIP feed with
   split-adjusted prices, from January 1, 2025 to November 14, 2026 (UTC).
2. `convert_spy_1min.jl` converts the time stamps from UTC to New York time, keeps the regular session (9:30 to
   16:00, or to 13:00 on the three early closes), and saves the JLD2 file. Run it in the course environment:
   `julia --project=. convert_spy_1min.jl <folder for the CSV files> <output file>`.

The SDK has no time-zone package, so the conversion applies the US daylight-saving rule itself (second Sunday of
March to first Sunday of November). As a check, the 15:59 close of each day of 2025 matched the daily close of
the course data to a median of 0.007%.
