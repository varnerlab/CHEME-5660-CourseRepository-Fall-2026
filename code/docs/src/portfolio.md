# Portfolio management
Fill me in

```@docs
VLQuantitativeFinancePackage.MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem
VLQuantitativeFinancePackage.MyMarkowitzRiskyRiskFreePortfolioChoiceProblem
VLQuantitativeFinancePackage.MySingleIndexModel
VLQuantitativeFinancePackage.build(model::Type{MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyMarkowitzRiskyRiskFreePortfolioChoiceProblem}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MySingleIndexModel}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem)
VLQuantitativeFinancePackage.solve(model::MyMarkowitzRiskyRiskFreePortfolioChoiceProblem)
```

## Maximizing the Sharpe ratio
The Sharpe ratio is a widely used metric in finance to evaluate the performance of an investment by adjusting for its risk. It is defined as the ratio of the excess return of the investment over the risk-free rate to the standard deviation of the investment's returns. We've implemented some tools to help you build and solve portfolio choice problems that maximize the Sharpe ratio.

```@docs
VLQuantitativeFinancePackage.MySharpeRatioPortfolioChoiceProblem
VLQuantitativeFinancePackage.build(model::Type{MySharpeRatioPortfolioChoiceProblem}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::MySharpeRatioPortfolioChoiceProblem)
```