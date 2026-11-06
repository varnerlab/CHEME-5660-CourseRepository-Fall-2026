# Wolfram markets

`VLQuantitativeFinancePackage.WolframMarkets` is the simulator of the Wolfram-rule market paper, J. D. Varner,
[Wolfram-markets-abm-paper](https://github.com/varnerlab/Wolfram-markets-abm-paper) (executed snapshot, commit
33ebbaa). Traders sit on a grid and choose Buy, Hold or Sell by a two-dimensional totalistic Wolfram rule that
depends on the sum of their four neighbors. A ring of edge traders reads the price against a moving-average band
and feeds that signal into the grid, and the orders clear against a finite constant-product dealer whose
cash-to-inventory ratio is the price. The port reproduces the paper's final-grid SHA-256 fingerprints and per-run
metrics.

The submodule has its own namespace. Use it qualified:

```julia
import VLQuantitativeFinancePackage
import VLQuantitativeFinancePackage.WolframMarkets as WM

config = WM.build(WM.MyModelBConfiguration, (number_of_rows = 32, number_of_cols = 32, steps = 4000,
    seed = 1, λ = 0.02, minority_fraction = 0.25, cost_basis_rule = false, market_maker_capacity = 100.0))
result = WM.simulate_checked(config; minority_population = :interior, boundary_mode = :hold,
    rule_activation_step = 1001, verbose = false)
```

## Reference

```@docs
VLQuantitativeFinancePackage.WolframMarkets
VLQuantitativeFinancePackage.WolframMarkets.MyModelBConfiguration
VLQuantitativeFinancePackage.WolframMarkets.MyModelBSimulationResult
VLQuantitativeFinancePackage.WolframMarkets.build(::Type{VLQuantitativeFinancePackage.WolframMarkets.MyModelBConfiguration}, ::NamedTuple)
VLQuantitativeFinancePackage.WolframMarkets.simulate
VLQuantitativeFinancePackage.WolframMarkets.simulate_checked
VLQuantitativeFinancePackage.WolframMarkets.compute_max_drawdown
VLQuantitativeFinancePackage.WolframMarkets.rule_table
VLQuantitativeFinancePackage.WolframMarkets.rule_switch_config
VLQuantitativeFinancePackage.WolframMarkets.run_rule_switch
VLQuantitativeFinancePackage.WolframMarkets.rule_switch_summary
```
