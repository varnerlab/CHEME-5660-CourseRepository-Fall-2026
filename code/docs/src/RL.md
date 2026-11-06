# Reinforcement Learning

The package includes compact grid-world models used to
demonstrate policies, interacting agents, and tabular Q-learning.

## Grid World
```@docs
VLQuantitativeFinancePackage.MyPeriodicRectangularGridWorldModel
VLQuantitativeFinancePackage.build(model::Type{MyPeriodicRectangularGridWorldModel}, data::NamedTuple)
```

## Wolfram Q-learning

The Q-learning agent stores state-action values and samples episodes from a
Wolfram grid-world environment using an epsilon-greedy policy.

```@docs
VLQuantitativeFinancePackage.MyWolframRuleQLearningAgentModel
VLQuantitativeFinancePackage.build(model::Type{MyWolframRuleQLearningAgentModel}, data::NamedTuple)
VLQuantitativeFinancePackage.MyWolframGridWorldModel
VLQuantitativeFinancePackage.build(model::Type{MyWolframGridWorldModel}, data::NamedTuple)
VLQuantitativeFinancePackage.sample(agent::MyWolframRuleQLearningAgentModel, environment::MyWolframGridWorldModel; maxsteps::Int = 100,
    ϵ::Float64 = 0.2)
```
