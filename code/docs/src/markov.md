# Markov Models
Markov models and hidden Markov models are widely used in quantitative finance for modeling time series data, such as stock prices and interest rates. In this section, we introduce the `MyHiddenMarkovModel` and `MyHiddenMarkovModelWithJumps` types, which provide a framework for building and analyzing hidden Markov models with and without jump components.

```@docs
VLQuantitativeFinancePackage.MyHiddenMarkovModel
VLQuantitativeFinancePackage.MyHiddenMarkovModelWithJumps
VLQuantitativeFinancePackage.build(model::Type{MyHiddenMarkovModel}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyHiddenMarkovModelWithJumps}, data::NamedTuple)
```