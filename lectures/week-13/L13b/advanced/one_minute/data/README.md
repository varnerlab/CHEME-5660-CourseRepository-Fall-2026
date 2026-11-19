# One-minute bars of SPY

`SPY-OHLCV-1-min-2025-2026.jld2` holds one `DataFrame` under the key `dataset`, with one row per minute of the
regular trading session of `SPY` from January 2, 2025 to November 13, 2026: 182,370 bars on 469 trading days.

| Column | Meaning and units |
| --- | --- |
| `timestamp` | The start of the minute, New York time (`DateTime`). The first bar of a day starts at 9:30, the last at 15:59. |
| `open`, `high`, `low`, `close` | The open, high, low, and close prices of the minute, USD/share. |
| `volume` | The number of shares traded in the minute. |
| `vwap` | The volume-weighted average price of the minute, USD/share. |

A full trading day has 390 bars. The three early closes in the window (July 3, November 28, and December 24, 2025)
end at 13:00 and have 210 bars. The file has no bars from before 9:30 or after the close.

The bars come from the Alpaca market data service (the consolidated SIP feed, split-adjusted prices), pulled on
November 18, 2026. The file also stores the keys `ticker`, `feed`, `adjustment`, and `source`. The pull and
conversion scripts are in `lectures/instructor/one-minute-data/` of the course repository.
