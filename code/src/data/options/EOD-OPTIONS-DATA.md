# End-of-day options archive, April 13 to October 8, 2026

End-of-day option chains for 31 underlyings over 115 trading sessions, captured
from the [Alpaca Markets](https://alpaca.markets/) options snapshot endpoint by
the daily DTE-ladder pull in
[varnerlab/alpaca-markets-sdk](https://github.com/varnerlab/alpaca-markets-sdk).
Each row is one contract on one session: the closing bid and ask, the last
trade, Alpaca's implied volatility and Greeks, and the contract terms. The
archive is frozen through October 8, 2026.

The archive is too large to vendor in git (112 MB compressed, 4,529,860 rows), so
the package ships it as the lazy artifact `options_eod`, declared in
`code/Artifacts.toml`. The first call to an archive loader downloads the tarball
from the GitHub release `data-options-eod-2026-10-08` into the Julia depot. Later
calls, and every weekly bundle on the same machine, reuse that copy.

```julia
spy = MyOptionsEODDataSet(ticker = "SPY")                    # every SPY contract, every session
und = MyOptionsEODUnderlyingDataSet()                       # one row per ticker per session
chain = MyOptionsEODChainDataSet(ticker = "NVDA", date = Date(2026, 10, 8),
    expiration = Date(2026, 11, 20))                        # one chain, with the share price in metadata
```

## Coverage

| Group | Tickers |
| --- | --- |
| Technology | AAPL, AMD, AVGO, GOOG, INTC, META, MSFT, MU, NVDA, QCOM |
| Healthcare | ABBV, AMGN, BMY, JNJ, LLY, MRNA, PFE, UNH |
| Financials | BAC, GS, JPM, WFC |
| Energy | CVX, OXY, XOM |
| Retail and transport | TGT, UPS, WMT |
| Exchange-traded funds | IWM, QQQ, SPY |

The pull keeps contracts whose expiration lies within three calendar days of a
target on the ladder 2, 7, 14, 30, 45, 60, 90 days, and `target_dte` records the
matched target. A session holds 3 to 12 expirations per stock and 12 to 17 for
the three funds, which list daily expirations, with `dte` from 0 to 93 days. The
first capture (April 13) used the ladder 4, 8, 12, 16, 24, 32, 40, 44, 64, 76
days. Strikes span the whole listed chain, from deep in the money to far out
of the money.

The 115 sessions are 115 of the 125 trading days from April 13 to October 8,
2026. There are no captures for April 14, April 29, May 4, May 5, May 7, June 5,
June 8, June 9, August 3, and August 20. AMGN, AVGO, BMY, GOOG, META, PFE, QCOM,
and UNH are also missing on April 13 and April 20, so they have 113 sessions.
The June 5 to June 9 gap was later backfilled from Alpaca's historical endpoints,
but the backfill has no quotes, IV, or Greeks, so it is not part of this archive.

## Files

The artifact holds one gzipped CSV per ticker (`<TICKER>.csv.gz`), the table
`underlying.csv`, and this README.

Chain columns, one row per contract per session, sorted by date, expiration,
type, and strike:

| Column | Meaning |
| --- | --- |
| `date` | Trading session of the capture |
| `expiration` | Contract expiration date |
| `dte` | Calendar days from `date` to `expiration` |
| `target_dte` | Ladder target this expiration was matched to |
| `type` | `call` or `put` |
| `strike` | Strike price (USD/share) |
| `bid`, `ask`, `mid` | Closing quote and its midpoint (USD/share) |
| `bid_size`, `ask_size` | Contracts displayed at the bid and ask |
| `last_price`, `last_size` | Most recent trade (USD/share, contracts); it can predate `date` |
| `implied_vol` | Alpaca's implied volatility (annualized, decimal) |
| `delta`, `gamma` | Alpaca's Greeks with respect to the share price |
| `theta` | Alpaca's theta, USD/share per calendar day |
| `vega`, `rho` | Alpaca's vega and rho, USD/share per one-percentage-point change |

Each row is a single contract, and prices are per share (multiply by 100 for the
standard contract). `underlying.csv` has one row per ticker per session: `ticker`,
`date`, `capture_ts` (UTC), and the session's `open`, `high`, `low`, `close`,
`iex_volume`, and `iex_vwap`.

## Caveats

- **Missing IV and Greeks.** Alpaca returns no implied volatility or Greeks for
  44% of rows. They are mostly away from the money. The share missing is 11% for
  strikes within 5% of the share price, about 30% for strikes 5 to 20% away, and
  65 to 80% beyond that. Quotes are present on every row.
- **Zero bids.** 18% of rows have a zero bid, mostly far out-of-the-money
  contracts with no buyer.
- **Underlying bars come from the IEX feed.** The open, high, low, and close are
  within 0.02% (median) of the consolidated Polygon closes in
  `MyTestingMarketDataSet(year = 2026)`, with the largest gap below 1%. Volume
  and VWAP count IEX trades only, about 3% of consolidated volume, so they are
  labeled `iex_volume` and `iex_vwap`. Use the testing market data for share
  volume.
- **Capture times.** Every capture ran after the 16:00 ET close and before the
  next open, so the quotes are end-of-session quotes. From May 12 on, the pull
  ran at 16:30 ET. Earlier captures ran by hand between 16:08 and 22:07 ET,
  except the April 23 and May 1 sessions, which were captured the next trading
  morning before the open. `capture_ts` in `underlying.csv` records each one.
- **April 23 and May 1.** Because these two sessions were captured the next
  trading morning, Alpaca computed their IV and Greeks with 1 and 3 fewer days to
  expiration than the session close implies, and matched expirations to the
  ladder from the capture day. `dte` is recounted from the session date.
- **Option snapshot feed.** The snapshot request set no data feed, so Alpaca's
  account default applied (the indicative feed on the free plan, OPRA with a
  subscription).

## Rebuild

`scripts/build-options-eod-data.jl` builds the archive from the
alpaca-markets-sdk `data/` folder and an end date:

```sh
julia --project=. scripts/build-options-eod-data.jl ../alpaca-markets-sdk/data 2026-10-08
```

It reads only the live `options-MM-DD-YY/` folders, keys each capture by its
session date rather than the folder name, and keeps the end-of-day pull when a
folder holds two (August 21 also has a 14:43 UTC intraday pull). It recounts
`dte` from the session date and modifies no quote, IV, or Greek value. It then writes `artifacts/options-eod-<date>.tar.gz`
and rebinds `options_eod` in `code/Artifacts.toml`. Upload the tarball to the
release `data-options-eod-<date>` and publish the release before students load
the data.
