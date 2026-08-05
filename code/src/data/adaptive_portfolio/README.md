# Adaptive portfolio teaching data

These compact, frozen artifacts were copied on 2026-08-04 from the local
`eCornell-AI-finance-lectures` short-course repository and are now distributed
with `VLQuantitativeFinancePackage.jl`. They support the CHEME 5660 examples on
the Single Index Model, utility allocation, adaptive rebalancing, EWLS replay,
validation, and captured operations.

The large Monte Carlo stress caches, synthetic 20-year price panel, portfolio
surrogate, news corpus, and per-day operational queue/ticket archives were not
copied. They are generated outputs or optional application artifacts, not
inputs required by the course notebooks.

| File | Original location | SHA-256 |
|---|---|---|
| `sim-calibration.jld2` | `code/src/data/sim-calibration.jld2` | `10e0c8e55e0aa3798dead878044db041d1a879bd6465ef1a1be3fd9dbe002072` |
| `current-prices.jld2` | `code/src/data/current-prices.jld2` | `e2f8d0ee6a654cfcfb33d42244f2199deb332af3cf286c4d16fa6d2fdbdcd10c` |
| `engine-run-data.jld2` | `lectures/session-2/data/engine-run-data.jld2` | `2fae384cb6e3531e45ef3ad45c0b65d454d870dfd247866f0a60ec24affc7e6d` |
| `session2-scorecard.jld2` | `lectures/session-2/data/session2-scorecard.jld2` | `9b0cadf2be44e6907afb53f0ff2e9de137e1f5cf68f1d854feb2332264573afa` |
| `ewls-replay-results.jld2` | `lectures/session-3/data/ewls-replay-results.jld2` | `11c6ab06882e5d1634f8da07bdb464b79f192675030b76bc3d3250c94f1c982c` |
| `compliance-config.jld2` | `lectures/session-3/data/compliance-config.jld2` | `0bd962cc07b09c4d104e25abaee802810cea4c015ecc55e5739ed6ed02f006b2` |
| `daily-baseline-bars.jld2` | `lectures/session-4/data/daily-baseline-bars.jld2` | `c6a2ec5c97463d68330ecf35308207d73c187f13ff6444f350cd85985b55adfa` |
| `daily-baseline-tape.jld2` | `lectures/session-4/data/daily-baseline-tape.jld2` | `b207ce35a2441128bdeb9518ebd9a9d23c8e48420e9000654230a30f63b2d9ca` |

The two market snapshots retain their original source metadata internally.
Use `MySIMCalibration()`, `MyCurrentPrices()`, or
`MyAdaptivePortfolioCourseData(name)` rather than hard-coding these paths.
For `:engine_run`, the loader omits the legacy package-specific `context`
object; its inputs are duplicated in portable array and dictionary entries in
the same file.
