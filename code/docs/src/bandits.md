# Bandit Problems

Multi-armed bandits demonstrate how an agent balances exploration with
exploitation. The epsilon-sampling model tracks per-action beta distributions
and chooses between random exploration and the currently preferred action.

## Episilon Greedy Sampling
```@docs
VLQuantitativeFinancePackage.MyEpsilonSamplingBanditModel
VLQuantitativeFinancePackage.build(model::Type{MyEpsilonSamplingBanditModel}, data::NamedTuple)
```

## Ticker picker problem example

Ticker-picker worlds turn an asset selection into a bandit action and compute
the resulting reward from market data. Risk-aware variants incorporate either
an explicit risk lookup or single-index-model parameters.

```@docs
VLQuantitativeFinancePackage.MyTickerPickerWorldModel
VLQuantitativeFinancePackage.build(model::Type{MyTickerPickerWorldModel}, data::NamedTuple)
VLQuantitativeFinancePackage.sample(model::MyEpsilonSamplingBanditModel, world::AbstractWorldModel)
VLQuantitativeFinancePackage.preference
VLQuantitativeFinancePackage.MyTickerPickerRiskAwareWorldModel
VLQuantitativeFinancePackage.build(model::Type{MyTickerPickerRiskAwareWorldModel}, data::NamedTuple)
VLQuantitativeFinancePackage.MyTickerPickerSIMRiskAwareWorldModel
VLQuantitativeFinancePackage.build(model::Type{MyTickerPickerSIMRiskAwareWorldModel}, data::NamedTuple)
```
