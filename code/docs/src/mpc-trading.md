# Model-predictive portfolios: trading and the study loop

The GBM projection, trading costs, the re-plan triggers, the pickers and the hedge pool, the scorecards, and the backtest and study loops. See the [overview](mpc.md).

```@autodocs
Modules = [VLQuantitativeFinancePackage.MPCPortfolio]
Pages = ["Projection.jl", "Costs.jl", "Triggers.jl", "Metrics.jl", "GrowthScorecard.jl", "Backtest.jl", "StudyBacktest.jl", "HedgePool.jl", "Screens.jl", "Bandit.jl"]
Order = [:constant, :type, :function]
```
