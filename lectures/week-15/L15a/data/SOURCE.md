# L15a market data sources

L15a uses the practicum's data. The files below are byte-for-byte copies from commit
`9a72d7399bd61fe9b9b1333505e972862f438912` (branch `practicum-build`) of `CHEME-4660-5660-Practicum-Fall-2026`.

| File | From | SHA-1 |
| --- | --- | --- |
| `prices.jld2` | `data/prices.jld2` | `7736c841073f398bfdfc930aa101aed376af1aa1` |
| `generator.jld2` | `data/generator.jld2` | `671fba00af75fac81560cccb07455ac727793f35` |
| `universe.csv` | `data/universe.csv` | `3b2eb5c2e205babbe16cb97636ee1d4621baa7e3` |
| `tbill.csv` | `data/tbill.csv` | `5a6a1b05b69e39623232a3b02c3df5767c882e2c` |
| `nyse-holidays.csv` | `data/nyse-holidays.csv` | `8390ac3b4740c4c6caeed4feb0020e5fcda765b3` |
| `../scripts/practicum/src/Generator.jl` | `src/Generator.jl` | `9fd3779ec1932a8f5f9ee6261417a7b20dd3c6d6` |
| `../scripts/practicum/data/beta-drift.csv` | `data/beta-drift.csv` | `bf4247bc6220e537badfdb10d87d78aee6fac7ff` |

`prices.jld2` holds the daily closes, opens, highs, and lows (USD/share) and volumes (shares/day) of every ticker
from 2016-01-04 to 2026-11-24, from Alpaca SIP daily bars (`adjustment=all`). The practicum's
`instructor/universe/pull_prices.jl` writes it. A ticker that began trading after 2016-01-04 holds `NaN` before
its first trading day.

The stress test draws its synthetic markets with the practicum's generator, `Generator.jl` with `generator.jld2`.
`Generator.jl` and `beta-drift.csv` sit in [`scripts/practicum`](../scripts/practicum), because `Generator.jl`
reads `beta-drift.csv` from `../data` next to itself.
