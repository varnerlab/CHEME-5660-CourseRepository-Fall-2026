function _execute(agent::MySimpleTwoDimensionalAgentModel, frame::Array{Int,2}, 
    world::MyTwoDimensionalFixedBoundaryGridWorld)::Int64

    # get the data -
    connections = agent.connections; # what are the connections of the agent? (neighborhood)
    rulemodel = agent.rule; # what is the rule model of the agent?
    w = rulemodel.weights; # what are the weights of the rule model?
    radius = rulemodel.radius; # what is the radius of the rule model?
    number_of_colors = rulemodel.number_of_colors; # what is the number of colors in the rule model?
    states = world.states; # states of the world


    tmp = Array{Int,1}(undef, radius); # initialize the neighborhood
    for i ∈ 1:radius
        j = connections[i]; # get the connection (this is a linear index)
        position = states[j]; # get the position of the connection
        tmp[i] = frame[position[1], position[2]]; # get the value of the connection
    end

    # not clever ... but it works
    index = nothing;
    if rulemodel isa MyElementaryWolframRuleModel
        index = parse(Int, join(tmp), base = number_of_colors);
    elseif rulemodel isa MyTwoDimensionalTotalisticWolframRuleModel
        Q = rulemodel.neighborhoodstatesmap;  
        μ = dot(w, tmp);
        index = Q[round(μ, digits=2)]
    end
    
    # return the next state 
    return rulemodel.rule[index];
end

function _solve(agents::Array{MySimpleTwoDimensionalAgentModel,1}, world::MyTwoDimensionalFixedBoundaryGridWorld;
    initial::Array{Int,2} = Array{Int,2}(), steps::Int=100, verbose::Bool=false, 
    exclude::Union{Nothing, Set{Tuple{Int,Int}}} = nothing)::Dict{Int, Array{Int,2}}

    # initialize -
    frames = Dict{Int, Array{Int, 2}}(); # storage for the simulation frames
    frames[1] = copy(initial); # initial frame
    width = world.width; # width of the world
    height = world.height; # height of the world
    states = world.states; # states of the world
    coordinates = world.coordinates; # coordinates of the world

    # check: is the exclusion list defined?
    if (exclude === nothing)
        exclude = Set{Tuple{Int,Int}}(); # initialize the exclusion list to empty if not defined
    end

    # iterate over time -
    for t ∈ 2:steps
        
        # initialize -
        current_frame = copy(frames[t-1]); # get the frame from the previous step
        next_frame = copy(current_frame);
        
        for row ∈ 2:(height-1)
            for col ∈ (2:width-1)

                coordinate = (row, col);
                if (∈(coordinate, exclude) == false)
                    agent_index = coordinates[coordinate];
                    next_state = _execute(agents[agent_index], current_frame, world);
                    next_frame[row, col] = next_state;
                else
                    next_frame[row, col] = current_frame[row, col];
                end
            end
        end
        frames[t] = next_frame; # store the frame
    end

    # return -
    return frames;
end


"""
    solve(rulemodel::MyOneDimensionalElementarWolframRuleModel, worldmodel::MyPeriodicRectangularGridWorldModel, initial::Array{Int64,1}; steps::Int64 = 240) -> Dict{Int64, Array{Int64,2}}

Evolves a one-dimensional elementary Wolfram cellular automaton on a periodic grid.

### Arguments
- `rulemodel::MyOneDimensionalElementarWolframRuleModel`: The rule definition containing the neighborhood radius, number of colors, and lookup table for next states.
- `worldmodel::MyPeriodicRectangularGridWorldModel`: The periodic world (width comes from `number_of_cols`) over which the automaton is simulated.
- `initial::Array{Int64,1}`: The starting configuration of the automaton; its length must equal the grid width.
- `steps::Int64`: Number of time steps to simulate. Defaults to `240`.

### Returns
- `Dict{Int64, Array{Int64,2}}`: Dictionary keyed by time step where each value is a `steps x width` matrix capturing the state history up to that step, wrapping neighbor lookups at the boundaries.
"""
function solve(rulemodel::MyOneDimensionalElementarWolframRuleModel, worldmodel::MyPeriodicRectangularGridWorldModel, 
    initial::Array{Int64,1}; steps::Int64 = 240)::Dict{Int64, Array{Int64,2}}
    
    # get stuff from models -
    width = worldmodel.number_of_cols;
    radius = rulemodel.radius;
    number_of_colors = rulemodel.number_of_colors;

    # initialize -
    frames = Dict{Int64, Array{Int64,2}}();
    frame = Array{Int64,2}(undef, steps, width) |> X -> fill!(X, 0);

    # set the initial state -
    foreach(i -> frame[1,i] = initial[i], 1:width);    
    frames[1] = frame; # set the initial frame -
    
    # main loop -
    for time ∈ 2:steps

        # create the next frame -
        frame = copy(frames[time-1]);
        tmp = Array{Int64,1}(undef, radius);
        for i ∈ 1:width

            index = nothing;
            if (i == 1)
                
                tmp[1] = frame[time-1, width];  # left
                tmp[2] = frame[time-1, i];      # center
                tmp[3] = frame[time-1, i + 1];    # right

                # compute the index (this is binary, so we need to compute from left to right)
                index = parse(Int, join(tmp), base = number_of_colors);
            elseif (i == width)
                    
                tmp[1] = frame[time-1, i - 1];  # left
                tmp[2] = frame[time-1, i];      # center
                tmp[3] = frame[time-1, 1];      # right
    
                # compute the index (this is binary, so we need to compute from left to right)
                index = parse(Int, join(tmp), base = number_of_colors);
            else
                
                tmp[1] = frame[time-1, i - 1];  # left
                tmp[2] = frame[time-1, i];      # center
                tmp[3] = frame[time-1, i + 1];  # right

                # compute the index (this is binary, so we need to compute from left to right)
                index = parse(Int, join(tmp), base = number_of_colors);
            end
             
            # what is the next state value?
            frame[time,i] = rulemodel.rule[index];
        end

        # set the frame -
        frames[time] = frame;
    end
    
    # return
    return frames;
end

"""
    solve(rulemodel::MyTwoDimensionalTotalisticWolframRuleModel, initialstate::Array{Int64,2}; steps::Int64 = 100) -> Dict{Int64, Array{Int64,2}}

The `solve` function solves the two-dimensional totalistic Wolfram rule model for a given initial state.

### Arguments
- `rulemodel::MyTwoDimensionalTotalisticWolframRuleModel`: An instance of the [`MyTwoDimensionalTotalisticWolframRuleModel`](@ref) type that defines the rule model parameters. 
- `initialstate::Array{Int64,2}`: A two-dimensional array that represents the initial state of the world.
- `steps::Int64`: The number of steps to simulate. The default value is `100`.

### Returns
- `Dict{Int64, Array{Int64,2}}`: A dictionary where the keys are integers (time steps) and the values are two-dimensional arrays that represent the state of the world at each time step.
"""
function solve(rulemodel::MyTwoDimensionalTotalisticWolframRuleModel, initialstate::Array{Int64,2};
    steps::Int64 = 100)::Dict{Int64, Array{Int64,2}}
    
    # initialize -
    frames = Dict{Int64, Array{Int64,2}}();
    decision = rulemodel.rule;
    radius = rulemodel.radius;
    number_of_rows, number_of_columns = size(initialstate);
    Q = rulemodel.neighborhoodstatesmap;

    # capture the initial state of the world -
    frames[0] = initialstate # capture the initial state of the world
  
    # iterate -
    for i ∈ 1:steps
        
        # grab the previous frames -
        current_frame = frames[i-1];
        next_frame = deepcopy(current_frame);

        tmp = Array{Int64,1}(undef, radius);
        for row ∈ 2:(number_of_rows-1)
            for column ∈ 2:(number_of_columns - 1)

                tmp[1] = current_frame[row, column-1];  # 1: left
                tmp[2] = current_frame[row, column+1];  # 2: right
                tmp[3] = current_frame[row-1, column];  # 3: up
                tmp[4] = current_frame[row+1, column];  # 4: down

                # use the decision rule to update the frame -
                next_frame[row, column] = Q[round(mean(tmp), digits=2)] |> index -> decision[index];
            end
        end

        # store the frame -
        frames[i] = next_frame;
    end

    # return -
    return frames;
end

"""
    solve(agents::Array{T,1}, world::AbstractWorldModel; initial::Array{Int,2}=Array{Int,2}(), steps::Int = 100, verbose::Bool = false, exclude = nothing) where T<:AbstractAgentModel -> Dict{Int, Array{Int,2}}

Runs a multi-agent Wolfram-style simulation on the provided world, delegating to the appropriate `_solve` implementation for the specific agent and world types.

### Arguments
- `agents::Array{T,1}`: Collection of agent models participating in the simulation (`T` must subtype `AbstractAgentModel`).
- `world::AbstractWorldModel`: World description the agents interact with (e.g., a grid world).
- `initial::Array{Int,2}=Array{Int,2}()`: Optional initial state matrix; if empty, the underlying `_solve` will initialize as needed.
- `steps::Int=100`: Number of time steps to simulate.
- `verbose::Bool=false`: When `true`, enables additional logging/printing during simulation.
- `exclude`: Optional filter to omit certain agents or states; passed through to `_solve`.

### Returns
- `Dict{Int, Array{Int,2}}`: A dictionary keyed by time step containing the world state history produced by the delegated solver.
"""
function solve(agents::Array{T,1}, 
    world::AbstractWorldModel; initial::Array{Int,2}=Array{Int,2}(),
    steps::Int = 100, verbose::Bool = false, exclude = nothing)::Dict{Int, Array{Int,2}} where T<:AbstractAgentModel

    # call the appropriate function -
    return _solve(agents, world, initial = initial, steps = steps, 
        verbose = verbose, exclude = exclude);
end
