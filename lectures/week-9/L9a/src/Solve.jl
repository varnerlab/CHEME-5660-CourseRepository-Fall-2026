"""
    solve(problem::MySimpleCobbDouglasChoiceProblem) -> Dict{String,Any}

Solves the optimal decision problem with a budget constraint with a Cobb-Douglas utility function
This maximizes the utility function subject to the budget constraint. 

### Arguments
- `problem::MySimpleCobbDouglasChoiceProblem`: The problem that we want to solve (see `MySimpleCobbDouglasChoiceProblem`)

"""
function solve(problem::MySimpleCobbDouglasChoiceProblem)::Dict{String,Any}

    # initialize -
    results = Dict{String,Any}()
    γ = problem.γ;
    c = problem.c;
    bounds = problem.bounds;
    B = problem.B;
    nₒ = problem.initial

    # how many variables do we have?
    d = length(γ);

    # coefficient - if any gamma is negative, we have negative leading coefficient
    α = (any(γ .< 0) ? -1 : 1);


    # Setup the problem -
    model = Model(()-> MadNLP.Optimizer(
        print_level = MadNLP.ERROR, 
        max_iter = 10000,
        acceptable_tol = 1e-4
    ));
    @variable(model, bounds[i,1] <= n[i=1:d] <= bounds[i,2], start=nₒ[i]) # we have d variables
    
    # set objective function -   
    @NLobjective(model, Max, α*prod(n[i]^γ[i] for i ∈ 1:d));
    @constraints(model, 
        begin
            # my budget constraint
            transpose(c)*n ≤ B
        end
    );

    # run the optimization -
    optimize!(model)

    # check: was the optimization successful?
    # @assert is_solved_and_feasible(model)

    # populate -
    x_opt = value.(n);
    results["argmax"] = x_opt
    results["budget"] = transpose(c)*x_opt; 
    results["objective_value"] = objective_value(model);
    results["status"] = termination_status(model);

    # return -
    return results
end