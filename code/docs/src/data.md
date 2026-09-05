# Data
We have included a market dataset that we use for examples and activities in the equity domain. This dataset holds the daily open, high, low, close, and volume data for a selection of stocks between 2014 and 2024. 


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
