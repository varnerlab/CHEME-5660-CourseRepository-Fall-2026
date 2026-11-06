# Factory.jl — Build functions for simulation types
# Pattern: build(ModelType, data::NamedTuple) → ModelType instance

# ---------------------------------------------------------------------------
# Wolfram CA types
# ---------------------------------------------------------------------------

"""
    build(MyTwoDimensionalTotalisticWolframRuleModel, data::NamedTuple)

Required keys: index (rule number), colors (number of states), radius (= 4).
Decodes the rule index in base `colors` and builds the neighborhood → state map.
"""
function build(
    modeltype::Type{MyTwoDimensionalTotalisticWolframRuleModel},
    data::NamedTuple,
)::MyTwoDimensionalTotalisticWolframRuleModel

    index  = data.index
    levels = data.colors
    radius = data.radius

    model = modeltype()

    # Decode rule index: digit i of the base-levels representation gives the
    # next state when the config index is i.
    n_configs   = length(range(0, stop = (levels - 1), step = (1 / radius)))
    rule_digits = digits(index, base = levels, pad = n_configs)
    rule        = Dict{Int64,Int64}(i => rule_digits[i + 1] for i in 0:n_configs - 1)

    # Map rounded neighborhood mean → config index
    Q      = Dict{Float64,Int64}()
    values = range(0.0, stop = (levels - 1), step = (1 / radius))
    for (i, v) in enumerate(values)
        Q[round(v, digits = 2)] = i - 1
    end

    model.index                = index
    model.radius               = radius
    model.number_of_colors     = levels
    model.rule                 = rule
    model.neighborhoodstatesmap = Q
    model.weights              = fill(1.0 / radius, radius)
    return model
end

"""
    build(MyTwoDimensionalFixedBoundaryGridWorld, data::NamedTuple)

Required keys: width, height.
"""
function build(
    modeltype::Type{MyTwoDimensionalFixedBoundaryGridWorld},
    data::NamedTuple,
)::MyTwoDimensionalFixedBoundaryGridWorld

    model  = modeltype()
    width  = data.width
    height = data.height

    states      = Dict{Int64, Tuple{Int64,Int64}}()
    coordinates = Dict{Tuple{Int64,Int64}, Int64}()
    idx = 1
    for r in 1:height, c in 1:width
        states[idx]      = (r, c)
        coordinates[(r,c)] = idx
        idx += 1
    end

    model.width       = width
    model.height      = height
    model.states      = states
    model.coordinates = coordinates
    return model
end

"""
    build(MySimpleTwoDimensionalAgentModel, world, data::NamedTuple)

Required keys: index (linear position), rule (MyTwoDimensionalTotalisticWolframRuleModel).
Connections are ordered [left, right, up, down]; -1 indicates a boundary neighbor.
"""
function build(
    modeltype::Type{MySimpleTwoDimensionalAgentModel},
    world::MyTwoDimensionalFixedBoundaryGridWorld,
    data::NamedTuple,
)::MySimpleTwoDimensionalAgentModel

    model  = modeltype()
    index  = data.index
    rule   = data.rule
    radius = rule.radius   # must be 4 for Von Neumann

    pos   = world.states[index]
    moves = [(0, -1), (0, 1), (-1, 0), (1, 0)]   # left, right, up, down

    connections = Vector{Int64}(undef, radius)
    for (i, Δ) in enumerate(moves[1:radius])
        newpos         = pos .+ Δ
        connections[i] = get(world.coordinates, newpos, -1)
    end

    model.index       = index
    model.rule        = rule
    model.connections = connections
    return model
end


# ---------------------------------------------------------------------------
# Model B configuration (closed-loop rebuild; spec 2026-07-15)
# ---------------------------------------------------------------------------

"""
    build(MyModelBConfiguration, data::NamedTuple) → MyModelBConfiguration

Required keys: number_of_rows, number_of_cols.
Optional keys (defaults): number_of_colors (3), radius (4), steps (200),
seed (42), initial_condition (:balanced_perturbation),
initial_buy_fraction (0.05), initial_sell_fraction (0.05),
edge_fraction (0.25), α (1/60), k (1.0), λ (0.01), P0 (100.0),
minority_fraction (0.20), rule_major_index (19280), rule_minor_index (19286),
initial_cash (1000.0), initial_shares (10), cost_basis_rule (true), edge_band_spread (0.5).
market_maker_capacity (Inf), measured as symmetric net units per trading
agent. `Inf` is the historical fill-all execution limit; a finite nonnegative
value constructs an explicit capacity-constrained dealer.

Validates: steps > 0; grid at least 3×3 (interior must be non-empty); all
fractions in [0, 1]; initial_buy_fraction + initial_sell_fraction ≤ 1;
known initial_condition; P0 > 0. Throws ArgumentError on violation.
"""
function build(modeltype::Type{MyModelBConfiguration}, data::NamedTuple)::MyModelBConfiguration
    model = modeltype()
    model.number_of_rows        = data.number_of_rows
    model.number_of_cols        = data.number_of_cols
    model.number_of_colors      = get(data, :number_of_colors, 3)
    model.radius                = get(data, :radius, 4)
    model.steps                 = get(data, :steps, 200)
    model.seed                  = get(data, :seed, 42)
    model.initial_condition     = get(data, :initial_condition, :balanced_perturbation)
    model.initial_buy_fraction  = get(data, :initial_buy_fraction, 0.05)
    model.initial_sell_fraction = get(data, :initial_sell_fraction, 0.05)
    model.edge_fraction         = get(data, :edge_fraction, 0.25)
    model.α                     = get(data, :α, 1 / 60)
    model.k                     = get(data, :k, 1.0)
    model.λ                     = get(data, :λ, 0.01)
    model.P0                    = get(data, :P0, 100.0)
    model.minority_fraction     = get(data, :minority_fraction, 0.20)
    model.rule_major_index      = get(data, :rule_major_index, 19280)
    model.rule_minor_index      = get(data, :rule_minor_index, 19286)
    model.initial_cash          = get(data, :initial_cash, 1000.0)
    model.initial_shares        = get(data, :initial_shares, 10)
    model.cost_basis_rule       = get(data, :cost_basis_rule, true)
    model.edge_band_spread      = get(data, :edge_band_spread, 0.5)
    model.market_maker_capacity = get(data, :market_maker_capacity, Inf)

    model.steps > 0 ||
        throw(ArgumentError("steps must be positive (got $(model.steps))"))
    (model.number_of_rows ≥ 3 && model.number_of_cols ≥ 3) ||
        throw(ArgumentError("grid must be at least 3×3 to have interior cells"))
    for (name, value) in (
        (:initial_buy_fraction,  model.initial_buy_fraction),
        (:initial_sell_fraction, model.initial_sell_fraction),
        (:edge_fraction,         model.edge_fraction),
        (:minority_fraction,     model.minority_fraction),
    )
        (0.0 ≤ value ≤ 1.0) ||
            throw(ArgumentError("$(name) must be in [0, 1] (got $(value))"))
    end
    (model.initial_buy_fraction + model.initial_sell_fraction ≤ 1.0) ||
        throw(ArgumentError("initial_buy_fraction + initial_sell_fraction must be ≤ 1"))
    model.initial_condition in (:all_hold, :balanced_perturbation, :custom) ||
        throw(ArgumentError("unknown initial_condition $(model.initial_condition); " *
                            "use :all_hold, :balanced_perturbation, or :custom"))
    model.P0 > 0.0 ||
        throw(ArgumentError("P0 must be positive (got $(model.P0))"))
    model.initial_cash ≥ 0.0 ||
        throw(ArgumentError("initial_cash must be ≥ 0 (got $(model.initial_cash))"))
    model.initial_shares ≥ 0 ||
        throw(ArgumentError("initial_shares must be ≥ 0 (got $(model.initial_shares))"))
    (0.0 ≤ model.edge_band_spread < 1.0) ||
        throw(ArgumentError("edge_band_spread must be in [0, 1) (got $(model.edge_band_spread))"))
    (!isnan(model.market_maker_capacity) && model.market_maker_capacity ≥ 0.0) ||
        throw(ArgumentError("market_maker_capacity must be nonnegative or Inf " *
                            "(got $(model.market_maker_capacity))"))
    return model
end

"""
    build_edge_coordinates(nrows, ncols, edge_fraction, rng)
        → Vector{Tuple{Int64,Int64}}

Enumerate the boundary cells of an nrows×ncols grid in deterministic order and
sample round(edge_fraction · n_boundary) of them without replacement using
rng. Returns the ACTIVE edge coordinates, sorted for reproducible storage.
Non-sampled boundary cells are passive and remain Hold (the CA solvers never
write boundary cells).
"""
function build_edge_coordinates(
    nrows::Int64, ncols::Int64, edge_fraction::Float64, rng::AbstractRNG,
)::Vector{Tuple{Int64,Int64}}
    boundary = Tuple{Int64,Int64}[]
    for c in 1:ncols
        push!(boundary, (1, c))
        push!(boundary, (nrows, c))
    end
    for r in 2:nrows-1
        push!(boundary, (r, 1))
        push!(boundary, (r, ncols))
    end
    n_edge = round(Int, edge_fraction * length(boundary))
    return sort(boundary[randperm(rng, length(boundary))[1:n_edge]])
end

"""
    build_initial_grid(config, rng; custom_grid = nothing) → Array{Int64,2}

Build the initial grid per config.initial_condition:

- :all_hold              → every cell Hold (state 1); stationary null control
- :balanced_perturbation → all-Hold, then exactly
  round(initial_buy_fraction · N_interior) Buy cells and exactly
  round(initial_sell_fraction · N_interior) Sell cells placed on distinct
  interior positions sampled without replacement (equal fractions ⇒ equal
  counts ⇒ zero initial imbalance); the boundary stays Hold
- :custom                → validated copy of custom_grid (size must match;
  entries must be 0, 1, or 2)
"""
function build_initial_grid(
    config::MyModelBConfiguration, rng::AbstractRNG;
    custom_grid::Union{Nothing, Array{Int64,2}} = nothing,
)::Array{Int64,2}
    nrows = config.number_of_rows
    ncols = config.number_of_cols

    if config.initial_condition == :custom
        isnothing(custom_grid) &&
            throw(ArgumentError(":custom initial_condition requires an initial_grid"))
        size(custom_grid) == (nrows, ncols) ||
            throw(ArgumentError("initial_grid size $(size(custom_grid)) ≠ ($(nrows), $(ncols))"))
        all(s -> s in (0, 1, 2), custom_grid) ||
            throw(ArgumentError("initial_grid entries must be 0 (Buy), 1 (Hold), or 2 (Sell)"))
        return copy(custom_grid)
    end

    grid = fill(1, nrows, ncols)
    config.initial_condition == :all_hold && return grid

    # :balanced_perturbation — interior cells only, exact counts
    interior = vec([(r, c) for r in 2:nrows-1, c in 2:ncols-1])
    N_int    = length(interior)
    n_buy    = round(Int, config.initial_buy_fraction  * N_int)
    n_sell   = round(Int, config.initial_sell_fraction * N_int)
    (n_buy + n_sell ≤ N_int) ||
        throw(ArgumentError("initial Buy+Sell cells ($(n_buy)+$(n_sell)) exceed the " *
                            "$(N_int) interior cells; reduce the initial fractions"))
    perm     = randperm(rng, N_int)
    for i in 1:n_buy
        r, c = interior[perm[i]]
        grid[r, c] = 0
    end
    for i in (n_buy + 1):(n_buy + n_sell)
        r, c = interior[perm[i]]
        grid[r, c] = 2
    end
    return grid
end

"""
    build_agent_books(config) → MyAgentBooks

Grid-shaped balance sheets: every cell starts with config.initial_cash,
config.initial_shares, and an average cost basis of config.P0 (the endowed
shares are treated as acquired at the initial price).
"""
function build_agent_books(config::MyModelBConfiguration)::MyAgentBooks
    nrows, ncols = config.number_of_rows, config.number_of_cols
    return MyAgentBooks(
        fill(config.initial_cash, nrows, ncols),
        fill(config.initial_shares, nrows, ncols),
        fill(config.P0, nrows, ncols),
    )
end

"""
    build_market_maker(config, n_traders) → MyMarketMaker

Construct the explicit Model B counterparty. For finite per-trader capacity
`h`, let `H = round(h*n_traders)`. The maker starts with `H` shares, inventory
bounds `[0, 2H]`, and `H*P0` cash, so at the initial quote it can absorb the
same net number of agent buys or sells. Opposing agent flow does not consume
that net capacity.

`h = Inf` is the exact historical limit: the ledger starts at zero and may
borrow cash or short inventory without bound while every agent-eligible order
fills.
"""
function build_market_maker(
    config::MyModelBConfiguration,
    n_traders::Int64,
)::MyMarketMaker
    n_traders > 0 || throw(ArgumentError("n_traders must be positive"))
    if isinf(config.market_maker_capacity)
        return MyMarketMaker(
            0.0, 0, 0.0, 0,
            typemin(Int64), typemax(Int64), Inf, true,
        )
    end

    H = round(Int64, config.market_maker_capacity * n_traders)
    return MyMarketMaker(
        config.P0 * H, H,
        config.P0 * H, H,
        0, 2H, 0.0, false,
    )
end

"""
    build_edge_bands(k, spread, n_edge, rng) → Vector{Float64}

Per-agent band half-widths k_i ~ Uniform(k·(1−spread), k·(1+spread)), drawn
once at build time (spec 2026-07-16 decision 8). spread = 0 returns exactly
fill(k, n_edge) but still consumes n_edge draws, so the seeded draw ORDER is
identical for every spread value.
"""
function build_edge_bands(
    k::Float64, spread::Float64, n_edge::Int64, rng::AbstractRNG,
)::Vector{Float64}
    u = rand(rng, n_edge)
    return k .* (1.0 .- spread .+ 2.0 .* spread .* u)
end
