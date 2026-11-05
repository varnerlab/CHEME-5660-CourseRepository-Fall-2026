# Agent-based markets

These models support CHEME 5660 L12a. Each model is built from a `NamedTuple` with
`build(...)` and simulated with `solve(...)`.

## Thermal minority game

```@docs
VLQuantitativeFinancePackage.MyThermalMinorityGameModel
VLQuantitativeFinancePackage.boltzmann_weights
VLQuantitativeFinancePackage.build(modeltype::Type{MyThermalMinorityGameModel}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::MyThermalMinorityGameModel)
```

## Farmer–Joshi market

```@docs
VLQuantitativeFinancePackage.MyFarmerJoshiMarketModel
VLQuantitativeFinancePackage.threshold_position
VLQuantitativeFinancePackage.build(modeltype::Type{MyFarmerJoshiMarketModel}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(model::MyFarmerJoshiMarketModel)
```
