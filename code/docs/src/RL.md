# Reinforcement Learning

The package includes compact grid-world and cellular-automaton models used to
demonstrate policies, interacting agents, and tabular Q-learning.

## Grid World
```@docs
VLQuantitativeFinancePackage.MyPeriodicRectangularGridWorldModel
VLQuantitativeFinancePackage.build(model::Type{MyPeriodicRectangularGridWorldModel}, data::NamedTuple)
```

## Wolfram policies and grids

Wolfram rule models map a cell neighborhood to its next state. The two-
dimensional world and agent models use these rules to evolve a grid over time.

```@docs
VLQuantitativeFinancePackage.MyOneDimensionalElementarWolframRuleModel
VLQuantitativeFinancePackage.build(model::Type{MyOneDimensionalElementarWolframRuleModel}, data::NamedTuple)
VLQuantitativeFinancePackage.MyOneDimensionalTotalisticWolframRuleModel
VLQuantitativeFinancePackage.MyTwoDimensionalElementaryWolframRuleModel
VLQuantitativeFinancePackage.MyTwoDimensionalTotalisticWolframRuleModel
VLQuantitativeFinancePackage.build(model::Type{MyTwoDimensionalTotalisticWolframRuleModel}, data::NamedTuple)
VLQuantitativeFinancePackage.solve(rulemodel::MyTwoDimensionalTotalisticWolframRuleModel, initialstate::Array{Int64,2}; steps::Int64 = 100)
VLQuantitativeFinancePackage.solve(rulemodel::MyOneDimensionalElementarWolframRuleModel, worldmodel::MyPeriodicRectangularGridWorldModel, initial::Array{Int64,1}; steps::Int64 = 100)
VLQuantitativeFinancePackage.MyElementaryWolframRuleModel
VLQuantitativeFinancePackage.MySimpleTwoDimensionalAgentModel
VLQuantitativeFinancePackage.MyTwoDimensionalFixedBoundaryGridWorld
VLQuantitativeFinancePackage.build(modeltype::Type{MyTwoDimensionalFixedBoundaryGridWorld}, data::NamedTuple)
VLQuantitativeFinancePackage.build(modeltype::Type{MySimpleTwoDimensionalAgentModel}, world::MyTwoDimensionalFixedBoundaryGridWorld, data::NamedTuple)
VLQuantitativeFinancePackage.solve(agents::Array{T,1}, world::AbstractWorldModel; initial::Array{Int,2}=Array{Int,2}(), steps::Int = 100, verbose::Bool = false, exclude = nothing) where T<:AbstractAgentModel
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
