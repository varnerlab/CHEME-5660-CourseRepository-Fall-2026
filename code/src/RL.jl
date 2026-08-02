
# -- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------------------- #
function _world(model::MyWolframGridWorldModel, t::Int, s::Int, a::Int)::Tuple{Int, Float64}

    # initialize -
    s′ = nothing
    r = nothing
    
    # grab the parameters from the model -
    dataset = model.data;
    policymap = model.policymap;

    # what is the state, action and reward?
    data = dataset[t];
    a′ = data[end]+1; # the last element is the next state (correct for zero)
    if (a′ == a)
        r = 1.0;
    else
        r = -1.0;
    end

    # get the next state -
    next_state_data = dataset[t+1];
    my_neighbors = next_state_data[1:end-1];
    s′ = round(mean(my_neighbors), digits=2) |> value -> policymap[value] + 1; # correct for zero

    # return -
    return (s′,r);
end

function _update(model::MyWolframRuleQLearningAgentModel, data::NamedTuple)::MyWolframRuleQLearningAgentModel

    # grab the s,a,reward and next state from the data tuple
    s = data[:s];
    a = data[:a];
    r = data[:r];
    s′ = data[:s′];
    
    # grab parameters from the model -
    γ, Q, α = model.γ, model.Q, model.α

    # use the update rule to update Q -
    Q[s,a] += α*(r+γ*maximum(Q[s′,:]) - Q[s,a])

    # return -
    return model;
end
# -- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------------------- #

# -- PUBLIC METHODS BELOW HERE -------------------------------------------------------------------------------------------- #
"""
    sample(agent::MyWolframRuleQLearningAgentModel, environment::MyWolframGridWorldModel; maxsteps::Int = 100, ϵ::Float64 = 0.2) -> MyWolframRuleQLearningAgentModel

The `sample` function samples the environment using the Q-learning agent model for a given number of steps using an epsilon-greedy method.
At each step, the agent selects an action based on the epsilon-greedy method and updates the Q-table using the Q-learning update rule by calling
the `world` function contained in the `environment` model.

### Arguments
- `agent::MyWolframRuleQLearningAgentModel`: An instance of the [`MyWolframRuleQLearningAgentModel`](@ref) type that defines the agent model parameters.
- `environment::MyWolframGridWorldModel`: An instance of the [`MyWolframGridWorldModel`](@ref) type that defines the world model.
- `maxsteps::Int`: The number of steps to sample. The default value is `100`.
- `ϵ::Float64`: The epsilon value for the epsilon-greedy method. The default value is `0.2`.

### Returns
- `MyWolframRuleQLearningAgentModel`: An updated instance of the [`MyWolframRuleQLearningAgentModel`](@ref) type, where the Q-table has been updated.
"""
function sample(agent::MyWolframRuleQLearningAgentModel, environment::MyWolframGridWorldModel; maxsteps::Int = 100,
    ϵ::Float64 = 0.2)::MyWolframRuleQLearningAgentModel

    # initialize -
    s = 1; # for now, we start at the first state
    actions = agent.actions;
    number_of_actions = length(actions);
    world = environment.world;

    # simulation loop -
    for t ∈ 1:maxsteps

        a = nothing;
        if rand() < ϵ

            # we generate a random action
            a = rand(1:number_of_actions);
        else

            # ok: so we are in some state s, let's use our memory to suggest a new action
            Q = agent.Q;
            a = argmax(Q[s,:]);
        end

        # initialize -
        s′, r = nothing, nothing; 
        
        # ask the world, what is my next state and reward from this (s,a)
        (s′,r) = world(environment, t, s, a)
        
        # update my model -
        agent = agent((
            s = s, a = a, r = r, s′ = s′
        ));

        # move -
        s = s′;
    end

    # return -
    return agent
end

(model::MyWolframRuleQLearningAgentModel)(data::NamedTuple) = _update(model, data);
# (model::MyWolframGridWorldModel)(t::Int, s::Int, a::Int) = _world(model, t, s, a);
# -- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------------------- #
