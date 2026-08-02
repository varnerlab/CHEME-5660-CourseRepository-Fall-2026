"""
    function solve(problem::MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem) -> Dict{String,Any}

The `solve` function solves the Markowitz risky asset-only portfolio choice problem for a given instance of the [`MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem`](@ref) problem type.
The `solve` method checks for the optimization's status using an assertion. Thus, the optimization must be successful for the function to return.
Wrap the function call in a `try` block to handle exceptions.


### Arguments
- `problem::MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem`: An instance of the [`MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem`](@ref) that defines the problem parameters.

### Returns
- `Dict{String, Any}`: A dictionary with optimization results.

The results dictionary has the following keys:
- `"reward"`: The reward associated with the optimal portfolio.
- `"argmax"`: The optimal portfolio weights.
- `"objective_value"`: The value of the objective function at the optimal solution.
- `"status"`: The status of the optimization.
"""
function solve(problem::MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem)::Dict{String,Any}

    # initialize -
    results = Dict{String,Any}()
    Σ = problem.Σ;
    μ = problem.μ;
    R = problem.R;
    bounds = problem.bounds;
    wₒ = problem.initial

    # setup the problem -
    d = length(μ)
    model = Model(()->MadNLP.Optimizer(print_level=MadNLP.ERROR, max_iter=500))
    @variable(model, bounds[i,1] <= w[i=1:d] <= bounds[i,2], start=wₒ[i])

    # set objective function -
    @objective(model, Min, transpose(w)*Σ*w);

    # setup the constraints -
    @constraints(model, 
        begin
            # my turn constraint
            transpose(μ)*w >= R
            sum(w) == 1.0
        end
    );

    # run the optimization -
    optimize!(model)

    # check: was the optimization successful?
    @assert is_solved_and_feasible(model)

    # populate -
    w_opt = value.(w);
    results["argmax"] = w_opt
    results["reward"] = transpose(μ)*w_opt; 
    results["objective_value"] = objective_value(model);
    results["status"] = termination_status(model);

    # return -
    return results
end

"""
    function solve(problem::MyMarkowitzRiskyRiskFreePortfolioChoiceProblem) -> Dict{String,Any}

The `solve` function solves the Markowitz risky and risk-free portfolio choice problem for a given instance of the [`MyMarkowitzRiskyRiskFreePortfolioChoiceProblem`](@ref) problem type.
The `solve` method checks for the optimization's status using an assertion. Thus, the optimization must be successful for the function to return.
Wrap the function call in a `try` block to handle exceptions.

### Arguments
- `problem::MyMarkowitzRiskyRiskFreePortfolioChoiceProblem`: An instance of the [`MyMarkowitzRiskyRiskFreePortfolioChoiceProblem`](@ref) that defines the problem parameters.

### Returns
- `Dict{String, Any}`: A dictionary with optimization results. 

The results dictionary has the following keys:
- `"reward"`: The reward associated with the optimal portfolio.
- `"argmax"`: The optimal portfolio weights.
- `"objective_value"`: The value of the objective function at the optimal solution.
- `"status"`: The status of the optimization.
"""
function solve(problem::MyMarkowitzRiskyRiskFreePortfolioChoiceProblem)::Dict{String,Any}

    # initialize -
    results = Dict{String,Any}()
    Σ = problem.Σ;
    μ = problem.μ;
    R = problem.R;
    bounds = problem.bounds;
    initial = problem.initial
    rfr = problem.risk_free_rate

    # setup the problem -
    d = length(μ)
    model = Model(()->MadNLP.Optimizer(print_level=MadNLP.ERROR, max_iter=500))
    @variable(model, bounds[i,1] <= w[i=1:d] <= bounds[i,2], start=initial[i])

    # set objective function -
    @objective(model, Min, transpose(w)*Σ*w);

    # setup the constraints -
    @constraints(model, 
        begin
            # my return constraint
            transpose(μ)*w + (1.0 - sum(w))*rfr >= R
        end
    );

    # run the optimization -
    optimize!(model)

    # check: was the optimization successful?
    @assert is_solved_and_feasible(model)

    # populate -
    w_opt = value.(w);
    results["reward"] = transpose(μ)*w_opt + (1.0 - sum(w_opt))*rfr;
    results["argmax"] = w_opt;
    results["objective_value"] = objective_value(model);
    results["status"] = termination_status(model);

    # return -
    return results
end

# --- Markov models --------------------------------------------------------------------------- #
function _simulate(m::MyHiddenMarkovModel, start::Int64, steps::Int64)::Array{Int64,2}

    # initialize -
    chain = Array{Int64,2}(undef, steps, 2);
    chain[1,1] = start;
    chain[1,2] = 0; # no jump indicator

    # main loop -
    for i ∈ 2:steps
        chain[i,1] = rand(m.transition[chain[i-1]]);
        chain[i,2] = 0; # no jump indicator
    end

    return chain;
end


function _simulate(m::MyHiddenMarkovModelWithJumps, start::Int64, steps::Int64)::Array{Int64,2}

    # initialize -
    chain = Array{Int64,2}(undef, steps, 2); # two columns: state, jump indicator
    tmp_chain = Dict{Int64,Int64}();
    tmp_jump = Dict{Int64,Int64}();
    tmp_chain[1] = start;
    tmp_jump[1] = 0; # no jump indicator
    counter = 2;

    # main -
    jump_state = start;
    while (counter ≤ steps)
        
        if (rand() < m.ϵ) # small probability of jump

            # # jump: find the next state. It is lowest probability state from here
            number_of_jumps = rand(m.jump_distribution); # Possion: how many steps to take in jump state 
            number_of_states = length(m.states);
            bottom_states = [1,2,3,4,5]; # super bad
            top_states = [number_of_states-4, number_of_states-3, number_of_states-2, number_of_states-1, number_of_states]; # super good


            for _ ∈ 1:number_of_jumps
                if (rand() < 0.52)
                    tmp_chain[counter] = rand(bottom_states) # a jump transition to bottom states
                    tmp_jump[counter] = 1; # indicate a jump occurred
                else
                    tmp_chain[counter] = rand(top_states) # a jump transition to top states
                    tmp_jump[counter] = 1; # indicate a jump occurred
                end
                counter += 1;
            end
        else
            tmp_chain[counter] = rand(m.transition[jump_state]); # a normal transition
            tmp_jump[counter] = 0; # indicate no jump occurred
            counter += 1; # increment counter
        end

        jump_state = tmp_chain[counter-1]; # get the last state
    end

    # populate the chain from tmp_chain -
    for i ∈ 1:steps
        chain[i,1] = tmp_chain[i];
        chain[i,2] = tmp_jump[i];
    end

    # return -
    return chain;
end

(m::MyHiddenMarkovModel)(start::Int64, steps::Int64) = _simulate(m, start, steps); 
(m::MyHiddenMarkovModelWithJumps)(start::Int64, steps::Int64) = _simulate(m, start, steps); 
# --------------------------------------------------------------------------------------------- #