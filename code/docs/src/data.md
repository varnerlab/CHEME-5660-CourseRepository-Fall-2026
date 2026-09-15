# Data
The package includes daily open, high, low, close, volume, and volume-weighted
average prices for stocks and exchange-traded funds. The training dataset covers
2014 through 2024. Two frozen testing snapshots are available:

| Testing year | Available dates | Tickers | Tickers with a complete history |
| --- | --- | ---: | ---: |
| 2025 | January 2–December 31, 2025 | 483 | 473 with 250 observations |
| 2026 | January 2–September 4, 2026 | 475 | 465 with 170 observations |

Select the testing year when loading the data:

```julia
training = MyTrainingMarketDataSet()["dataset"]
testing_2025 = MyTestingMarketDataSet()["dataset"] # default testing year
testing_2026 = MyTestingMarketDataSet(year = 2026)["dataset"]
spy_2026 = testing_2026["SPY"] # daily observations for one ticker
```

The loaders return the bundled observations without filling missing dates or
filtering tickers. Match parameters and prices by ticker and inspect each price
series' dates before an out-of-sample comparison. The 2026 snapshot ends on
September 4; loading it does not download more recent observations.

```@docs
VLQuantitativeFinancePackage.MyTrainingMarketDataSet
VLQuantitativeFinancePackage.MyTestingMarketDataSet
VLQuantitativeFinancePackage.MySP500SectorDataSet
```

## Options Data
We have also included an options chain dataset that we use for examples and activities in the options domain. This dataset holds a snapshot of options data for a selection of stocks on a specific date. Currently, we provide example options chain data for AMD, NVDA and MU option contracts with approximately 40 - 80 days to expiration. These datasets include information such as strike prices, expiration dates, bid and ask prices, and implied volatilities along with the underlying stock price on that date.

```@docs
VLQuantitativeFinancePackage.MyOptionsChainDataSet
```

## Adaptive portfolio data

The package also contains compact, frozen artifacts used by the SIM,
rebalancing, EWLS, validation, and captured-operations examples. The loaders
keep notebooks independent of the source repository's directory layout.

```@docs
VLQuantitativeFinancePackage.MySIMCalibration
VLQuantitativeFinancePackage.MyCurrentPrices
VLQuantitativeFinancePackage.MyAdaptivePortfolioCourseData
```

## U.S. Treasury data

The package vendors the Treasury auction records and rate series used by the
fixed-income material, so the notebooks do not depend on the source repository's
directory layout. The auction data was downloaded from
[TreasuryDirect](https://www.treasurydirect.gov/) and covers October 2022 to the
present; the daily rate series come from the
[U.S. Treasury](https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics).

Two of the loaders filter by default. `MyTreasuryBillDataSet` drops
cash-management bills, which are irregular one-off issues quoted in days rather
than weeks, and `MyTreasuryNotesAndBondsDataSet` drops reopenings, which carry an
existing security's coupon and therefore clear well away from par. Pass
`cmb = true` or `reopenings = true` to recover them.

```@docs
VLQuantitativeFinancePackage.MyTreasuryBillDataSet
VLQuantitativeFinancePackage.MyTreasuryNotesAndBondsDataSet
VLQuantitativeFinancePackage.MyTreasurySTRIPSDataSet
VLQuantitativeFinancePackage.MyTreasuryParYieldCurveDataSet
VLQuantitativeFinancePackage.MyTreasuryBillRatesDataSet
```
