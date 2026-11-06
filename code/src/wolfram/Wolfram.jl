# Wolfram.jl — CA rule application and solvers

# ---------------------------------------------------------------------------
# Homogeneous solver
# ---------------------------------------------------------------------------

"""
    solve(rule, grid; steps) → Dict{Int64, Array{Int64,2}}

Apply a single totalistic CA rule uniformly to all interior cells for
`steps` time steps. Boundary rows and columns (row 1, row end, col 1,
col end) are never modified; they hold edge agent states.

Returns a Dict mapping step index → grid state (step 0 = initial state).
"""
function solve(
    rule::MyTwoDimensionalTotalisticWolframRuleModel,
    grid::Array{Int64,2};
    steps::Int64 = 1,
)::Dict{Int64, Array{Int64,2}}

    frames  = Dict{Int64, Array{Int64,2}}()
    frames[0] = grid
    Q       = rule.neighborhoodstatesmap
    decision = rule.rule
    w       = rule.weights
    radius  = rule.radius
    nrows, ncols = size(grid)
    tmp     = Vector{Float64}(undef, radius)

    for step in 1:steps
        current = frames[step - 1]
        next    = copy(current)
        for r in 2:nrows - 1, c in 2:ncols - 1
            tmp[1] = current[r, c - 1]   # left
            tmp[2] = current[r, c + 1]   # right
            tmp[3] = current[r - 1, c]   # up
            tmp[4] = current[r + 1, c]   # down
            μ      = dot(w, tmp)
            next[r, c] = decision[Q[round(μ, digits = 2)]]
        end
        frames[step] = next
    end

    return frames
end

# ---------------------------------------------------------------------------
# Heterogeneous solver (agent array)
# ---------------------------------------------------------------------------

"""
    solve(agents, world; initial, steps, exclude) → Dict{Int64, Array{Int64,2}}

Apply per-agent CA rules for `steps` time steps. Agents whose (row, col)
position lies on the grid boundary (row 1, row end, col 1, col end) are
skipped automatically, preserving injected edge agent states. Additional
positions can be excluded via the `exclude` set.

Returns a Dict mapping step index → grid state (step 0 = initial state).
"""
function solve(
    agents::Vector{MySimpleTwoDimensionalAgentModel},
    world::MyTwoDimensionalFixedBoundaryGridWorld;
    initial::Array{Int64,2},
    steps::Int64 = 1,
    exclude::Set{Tuple{Int64,Int64}} = Set{Tuple{Int64,Int64}}(),
)::Dict{Int64, Array{Int64,2}}

    frames   = Dict{Int64, Array{Int64,2}}()
    frames[0] = copy(initial)
    nrows    = world.height
    ncols    = world.width

    for step in 1:steps
        current = frames[step - 1]
        next    = copy(current)

        for agent in agents
            pos = world.states[agent.index]
            r, c = pos

            # skip boundary rows/cols and any explicitly excluded positions
            (r == 1 || r == nrows || c == 1 || c == ncols) && continue
            pos ∈ exclude && continue

            rule     = agent.rule
            w        = rule.weights
            Q        = rule.neighborhoodstatesmap
            decision = rule.rule
            radius   = rule.radius

            tmp = Vector{Float64}(undef, radius)
            for i in 1:radius
                j = agent.connections[i]
                tmp[i] = j == -1 ? 1.0 : Float64(current[world.states[j]...])
            end

            μ        = dot(w, tmp)
            next[r, c] = decision[Q[round(μ, digits = 2)]]
        end

        frames[step] = next
    end

    return frames
end
