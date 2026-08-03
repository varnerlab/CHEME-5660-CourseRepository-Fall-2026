# Portfolio management

The package formulates long-only minimum-variance problems with either risky
assets alone or a mix of risky assets and a risk-free position. Inputs include
expected returns, a return covariance matrix, allocation bounds, and a target
portfolio return.

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

## Sharpe-constrained excess return

The Sharpe ratio is excess expected return divided by return standard
deviation. `MySharpeRatioPortfolioChoiceProblem` maximizes expected excess
return for a long-only, fully invested portfolio while requiring its Sharpe
ratio to be at least `τ`. It does not directly maximize the ratio itself.

```@docs
VLQuantitativeFinancePackage.MySharpeRatioPortfolioChoiceProblem
VLQuantitativeFinancePackage.build(model::Type{MySharpeRatioPortfolioChoiceProblem}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::MySharpeRatioPortfolioChoiceProblem)
```
