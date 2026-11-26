# Model-predictive portfolios: trading and the study loop

The forecasts (the GBM projection and the JumpHMM factor model), trading costs, the re-plan triggers, the pickers and the hedge pool, the scorecards, the backtest and study loops, and the L14a strategies (betting against beta and the buy-and-hold references). See the [overview](mpc.md).

```@autodocs
Modules = [VLQuantitativeFinancePackage.MPCPortfolio]
Pages = ["Projection.jl", "ForecastFactor.jl", "Costs.jl", "Triggers.jl", "Metrics.jl", "GrowthScorecard.jl", "Backtest.jl", "StudyBacktest.jl", "StudyScoring.jl", "HedgePool.jl", "Screens.jl", "Bandit.jl", "CourseStrategies.jl", "CourseL15a.jl"]
Order = [:constant, :type, :function]
```
