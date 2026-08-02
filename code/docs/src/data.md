# Data
We have included a market dataset that we use for examples and activities in the equity domain. This dataset holds the daily open, high, low, close, and volume data for a selection of stocks between 2014 and 2024. 


```@docs
VLQuantitativeFinancePackage.MyTrainingMarketDataSet
VLQuantitativeFinancePackage.MyTestingMarketDataSet
```

## Options Data
We have also included an options chain dataset that we use for examples and activities in the options domain. This dataset holds a snapshot of options data for a selection of stocks on a specific date. Currently, we provide example options chain data for AMD, NVDA and MU option contracts with approximately 40 - 80 days to expiration. These datasets include information such as strike prices, expiration dates, bid and ask prices, and implied volatilities along with the underlying stock price on that date.

```@docs
VLQuantitativeFinancePackage.MyOptionsChainDataSet
```