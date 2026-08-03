# CHEME 5660 Quantitative Finance Package

`VLQuantitativeFinancePackage` is the version-frozen Julia package used by the
CHEME 5660 course notebooks. It provides teaching implementations for fixed
income, equity and derivative pricing, portfolio optimization, stochastic
simulation, Markov models, bandits, and reinforcement learning.

## Using the course snapshot

Clone or download the course repository, activate its root Julia environment,
and instantiate it once. Lecture notebooks activate that environment through
their setup files. The separately maintained upstream repository can evolve;
course work should use the vendored snapshot in `code/` for reproducibility.

## API families

```@docs
VLQuantitativeFinancePackage
VLQuantitativeFinancePackage.AbstractAssetModel
VLQuantitativeFinancePackage.AbstractEquityPriceTreeModel
VLQuantitativeFinancePackage.AbstractInterestRateTreeModel
VLQuantitativeFinancePackage.AbstractContractModel
VLQuantitativeFinancePackage.AbstractTreasuryDebtSecurity
VLQuantitativeFinancePackage.AbstractCompoundingModel
VLQuantitativeFinancePackage.AbstractStochasticChoiceProblem
VLQuantitativeFinancePackage.AbstractReturnModel
VLQuantitativeFinancePackage.AbstractProbabilityMeasure
VLQuantitativeFinancePackage.AbstractMarkovModel
VLQuantitativeFinancePackage.AbstractSamplingModel
VLQuantitativeFinancePackage.AbstractWorldModel
VLQuantitativeFinancePackage.AbstractPolicyModel
VLQuantitativeFinancePackage.AbstractLearningModel
VLQuantitativeFinancePackage.AbstractAgentModel
```

## Disclaimer and Risks
__This content is offered solely for training and informational purposes__. No offer or solicitation to buy or sell securities or derivative products or any investment or trading advice or strategy is made, given, or endorsed by the teaching team. 

__Trading involves risk__. Carefully review your financial situation before investing in securities, futures contracts, options, or commodity interests. Past performance, whether actual or indicated by historical tests of strategies, is no guarantee of future performance or success. Trading is generally inappropriate for someone with limited resources, investment or trading experience, or a low-risk tolerance.  Only risk capital that is not required for living expenses.

__You are fully responsible for any investment or trading decisions you make__. Such decisions should be based solely on evaluating your financial circumstances, investment or trading objectives, risk tolerance, and liquidity needs. You are responsible for conducting your own independent research and seeking the advice of a qualified professional before making any investment or trading decisions.
