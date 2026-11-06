# Simulate.jl — Model A and Model B simulation loops
include(joinpath(@__DIR__, "ReserveClearing.jl"))

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

"""
    _build_ca_components(sim_model; rng, minority_population)
        → (world, agents, rule_major)

Build the CA machinery needed for a simulation run.

- Homogeneous case (minority_fraction ≈ 0): returns (nothing, nothing, rule_major).
  The fast path `solve(rule_major, grid, steps=1)` is used.

- Heterogeneous case: builds MyTwoDimensionalFixedBoundaryGridWorld and assigns
  rule_major to (1 - f) of the selected population and rule_minor to the
  remaining f, placed uniformly at random using `rng`.  The default
  `minority_population = :all_sites` preserves the historical implementation
  and its RNG stream.  `:interior` assigns the requested fraction exactly
  among cells that the fixed-boundary solver actually updates.

`rng` defaults to the global RNG, so Model A call sites (which pass no rng)
are bit-for-bit unchanged. Model B passes its seeded Xoshiro so minority
placement is reproducible from config.seed alone.
"""
function _build_ca_components(
    sim_model::AbstractSimulationModel;
    rng::AbstractRNG = Random.default_rng(),
    minority_population::Symbol = :all_sites,
)
    nrows   = sim_model.number_of_rows
    ncols   = sim_model.number_of_cols
    ncolors = sim_model.number_of_colors
    radius  = sim_model.radius
    f       = sim_model.minority_fraction

    rule_major = build(MyTwoDimensionalTotalisticWolframRuleModel, (
        index  = sim_model.rule_major_index,
        colors = ncolors,
        radius = radius,
    ))

    minority_population in (:all_sites, :interior) ||
        throw(ArgumentError("minority_population must be :all_sites or :interior"))
    f ≈ 0.0 && return (nothing, nothing, rule_major)

    rule_minor = build(MyTwoDimensionalTotalisticWolframRuleModel, (
        index  = sim_model.rule_minor_index,
        colors = ncolors,
        radius = radius,
    ))

    world = build(MyTwoDimensionalFixedBoundaryGridWorld, (
        width  = ncols,
        height = nrows,
    ))

    N      = nrows * ncols
    agents = Array{MySimpleTwoDimensionalAgentModel,1}(undef, N)
    for i in 1:N
        agents[i] = build(MySimpleTwoDimensionalAgentModel, world, (rule = rule_major, index = i))
    end

    if minority_population == :all_sites
        # Keep this rejection-sampling path unchanged: all existing Model A
        # and Model B results depend on its seeded draw sequence.
        n_minor = round(Int, f * N)
        visited = Set{Int64}()
        while length(visited) < n_minor
            j = rand(rng, 1:N)
            if j ∉ visited
                agents[j].rule = rule_minor
                push!(visited, j)
            end
        end
    else
        candidates = Int64[
            world.coordinates[(r, c)]
            for r in 2:nrows-1 for c in 2:ncols-1
        ]
        n_minor = round(Int, f * length(candidates))
        for j in candidates[randperm(rng, length(candidates))[1:n_minor]]
            agents[j].rule = rule_minor
        end
    end

    return (world, agents, rule_major)
end

"""
    _ca_step(grid, world, agents, rule_major) → Array{Int64,2}

Apply one Wolfram CA update step.

Edge agent coordinates are set before calling this function and may be
overwritten by the CA solver; the caller resets them at the top of each
time-step loop iteration (same pattern as the course notebooks).
"""
function _ca_step(
    grid::Array{Int64,2},
    world,
    agents,
    rule_major,
)::Array{Int64,2}
    # Every model in this repository uses the four-site von Neumann
    # neighborhood with uniform totalistic weights.  Its configuration index
    # is exactly the integer sum of the four neighbor states.  Evaluating that
    # identity directly avoids allocating a temporary vector per site and a
    # one-step Dict of frames per market step.  The general-purpose `solve`
    # methods remain available to the archival notebooks.
    rule_major.radius == 4 ||
        error("the direct CA step requires a four-neighbor totalistic rule")
    nrows, ncols = size(grid)
    next = copy(grid)

    if isnothing(world)
        decision = rule_major.rule
        @inbounds for r in 2:nrows-1, c in 2:ncols-1
            configuration = grid[r, c - 1] + grid[r, c + 1] +
                            grid[r - 1, c] + grid[r + 1, c]
            next[r, c] = decision[configuration]
        end
    else
        @inbounds for r in 2:nrows-1, c in 2:ncols-1
            agent_index = (r - 1) * ncols + c
            decision = agents[agent_index].rule.rule
            configuration = grid[r, c - 1] + grid[r, c + 1] +
                            grid[r - 1, c] + grid[r + 1, c]
            next[r, c] = decision[configuration]
        end
    end
    return next
end

"""
    _set_edge_states!(grid, edge_coords, state)

Write `state` into every edge-agent position in-place.
"""
function _set_edge_states!(
    grid::Array{Int64,2},
    edge_coords::Set{Tuple{Int64,Int64}},
    state::Int64,
)
    for (r, c) in edge_coords
        grid[r, c] = state
    end
end

"""
    _set_edge_states!(grid, edge_coordinates, states)

Per-agent variant: write states[i] into edge_coordinates[i] in-place.
(The scalar Set method above is Model A's homogeneous edge write.)
"""
function _set_edge_states!(
    grid::Array{Int64,2},
    edge_coordinates::Vector{Tuple{Int64,Int64}},
    states::Vector{Int64},
)
    for (i, (r, c)) in enumerate(edge_coordinates)
        grid[r, c] = states[i]
    end
end

"""
    _try_execute!(books, r, c, order, P, cost_basis_rule) → Bool

Attempt a ±1 order for the cell at (r, c) at price P; settle the books and
return true iff filled (spec 2026-07-16 §1–2). A buy fills iff cash ≥ P; a
sell fills iff shares ≥ 1 and, when cost_basis_rule is set, P > avg_cost
(strict — the disposition effect). Buys update the running average cost;
sells leave it unchanged.
"""
function _try_execute!(
    books::MyAgentBooks, r::Int64, c::Int64,
    order::Int64, P::Float64, cost_basis_rule::Bool,
)::Bool
    if order == 1
        books.cash[r, c] ≥ P || return false
        s_old = books.shares[r, c]
        books.avg_cost[r, c] = (books.avg_cost[r, c] * s_old + P) / (s_old + 1)
        books.shares[r, c]   = s_old + 1
        books.cash[r, c]    -= P
        return true
    elseif order == -1
        books.shares[r, c] ≥ 1 || return false
        (!cost_basis_rule || P > books.avg_cost[r, c]) || return false
        books.shares[r, c] -= 1
        books.cash[r, c]   += P
        return true
    end
    return false
end

"""Return whether one desired unit order passes the submitting agent's book."""
@inline function _agent_order_is_eligible(
    books::MyAgentBooks, r::Int64, c::Int64,
    order::Int64, P::Float64, cost_basis_rule::Bool,
)::Bool
    if order == 1
        return books.cash[r, c] ≥ P
    elseif order == -1
        return books.shares[r, c] ≥ 1 &&
               (!cost_basis_rule || P > books.avg_cost[r, c])
    end
    return false
end

"""Settle an already-eligible unit order against the agent's book."""
@inline function _settle_agent_order!(
    books::MyAgentBooks, r::Int64, c::Int64,
    order::Int64, P::Float64,
)::Nothing
    if order == 1
        s_old = books.shares[r, c]
        books.avg_cost[r, c] = (books.avg_cost[r, c] * s_old + P) / (s_old + 1)
        books.shares[r, c] = s_old + 1
        books.cash[r, c] -= P
    elseif order == -1
        books.shares[r, c] -= 1
        books.cash[r, c] += P
    else
        throw(ArgumentError("cannot settle Hold order"))
    end
    return nothing
end

# Stable SplitMix64 finalizer. Rationing uses a counter-based score rather
# than consuming the simulation RNG, so paired arms see the same priority
# tape at the same (step, agent, side) even after their eligible sets diverge.
@inline function _splitmix64(x::UInt64)::UInt64
    z = x + 0x9e3779b97f4a7c15
    z = (z ⊻ (z >> 30)) * 0xbf58476d1ce4e5b9
    z = (z ⊻ (z >> 27)) * 0x94d049bb133111eb
    return z ⊻ (z >> 31)
end

@inline function _rationing_score(
    seed::Int64, step::Int64, agent_id::Int64, side::Int64,
)::UInt64
    x = reinterpret(UInt64, seed)
    x ⊻= UInt64(step) * 0xd2b74407b1ce6e93
    x ⊻= UInt64(agent_id) * 0xca5a826395121157
    x ⊻= side == 1 ? 0x6a09e667f3bcc909 : 0xbb67ae8584caa73b
    return _splitmix64(x)
end

"""Order eligible candidates by the shared per-step rationing tape."""
function _rank_for_rationing!(
    candidates::Vector{NTuple{3,Int64}},
    seed::Int64, step::Int64, side::Int64,
)::Vector{NTuple{3,Int64}}
    sort!(candidates; by = x -> (_rationing_score(seed, step, x[3], side), x[3]))
    return candidates
end

"""
    execute_orders!(books, grid, edge_coordinates, edge_states, P;
                    cost_basis_rule) → NamedTuple

Execution layer: first filter every desired unit order through the submitting
agent's book, then batch the eligible buys and sells at the standing quote.
Opposing eligible flow offsets without consuming net market-maker capacity.
The explicit maker fills the residual up to its cash/inventory limits; any
remaining eligible orders are counted as market-maker rejections. In the
unlimited-maker limit every eligible order fills, exactly recovering the
historical implementation.

When rationing is necessary, a new seeded priority is generated for every
agent at every step. It changes across steps but is common to paired arms,
because it is a stateless function of (seed, step, agent id, side).

Interior orders come from grid states; edge agent i's order comes from
edge_states[i], never from the boundary grid value. Hold cells submit
nothing. The grid is never modified: financial constraints bind execution,
not sentiment.
"""
function execute_orders!(
    books::MyAgentBooks,
    grid::Array{Int64,2},
    edge_coordinates::Vector{Tuple{Int64,Int64}},
    edge_states::Vector{Int64},
    P::Float64;
    cost_basis_rule::Bool = true,
    market_maker::Union{Nothing,MyMarketMaker} = nothing,
    seed::Int64 = 0,
    step::Int64 = 1,
    trace::Union{Nothing,MyOrderTrace} = nothing,
)
    nrows, ncols = size(grid)
    if !isnothing(trace)
        for buffer in (trace.desired, trace.eligible, trace.filled)
            size(buffer) == size(grid) || throw(DimensionMismatch("order trace and grid sizes differ"))
            fill!(buffer, 0)
        end
    end
    buyers = NTuple{3,Int64}[]
    sellers = NTuple{3,Int64}[]
    supp_b = 0
    supp_s = 0
    linear = LinearIndices(grid)

    for r in 2:nrows-1, c in 2:ncols-1
        order = compute_desired_order(grid[r, c])
        isnothing(trace) || (trace.desired[r, c] = order)
        order == 0 && continue
        if _agent_order_is_eligible(books, r, c, order, P, cost_basis_rule)
            isnothing(trace) || (trace.eligible[r, c] = order)
            candidate = (Int64(r), Int64(c), Int64(linear[r, c]))
            order == 1 ? push!(buyers, candidate) : push!(sellers, candidate)
        else
            order == 1 ? (supp_b += 1) : (supp_s += 1)
        end
    end
    for (i, (r, c)) in enumerate(edge_coordinates)
        order = compute_desired_order(edge_states[i])
        isnothing(trace) || (trace.desired[r, c] = order)
        order == 0 && continue
        if _agent_order_is_eligible(books, r, c, order, P, cost_basis_rule)
            isnothing(trace) || (trace.eligible[r, c] = order)
            candidate = (Int64(r), Int64(c), Int64(linear[r, c]))
            order == 1 ? push!(buyers, candidate) : push!(sellers, candidate)
        else
            order == 1 ? (supp_b += 1) : (supp_s += 1)
        end
    end

    B = length(buyers)
    S = length(sellers)
    fill_b = B
    fill_s = S
    if !isnothing(market_maker) && !market_maker.unlimited
        if B > S
            dealer_capacity = max(0, market_maker.inventory - market_maker.min_inventory)
            fill_b = S + min(B - S, dealer_capacity)
        elseif S > B
            inventory_capacity = max(0, market_maker.max_inventory - market_maker.inventory)
            available_cash = max(0.0, market_maker.cash + market_maker.credit_limit)
            cash_capacity = floor(Int64, available_cash / P + 1.0e-12)
            fill_s = B + min(S - B, inventory_capacity, cash_capacity)
        end
    end

    rejected_b = B - fill_b
    rejected_s = S - fill_s
    rejected_b > 0 && _rank_for_rationing!(buyers, seed, step, 1)
    rejected_s > 0 && _rank_for_rationing!(sellers, seed, step, -1)

    for i in 1:fill_b
        r, c, _ = buyers[i]
        _settle_agent_order!(books, r, c, 1, P)
        isnothing(trace) || (trace.filled[r, c] = 1)
    end
    for i in 1:fill_s
        r, c, _ = sellers[i]
        _settle_agent_order!(books, r, c, -1, P)
        isnothing(trace) || (trace.filled[r, c] = -1)
    end

    if !isnothing(market_maker)
        market_maker.cash += P * (fill_b - fill_s)
        market_maker.inventory += fill_s - fill_b
        if !market_maker.unlimited
            market_maker.cash ≥ -1.0e-8 - market_maker.credit_limit ||
                error("market-maker cash limit violated")
            market_maker.min_inventory ≤ market_maker.inventory ≤ market_maker.max_inventory ||
                error("market-maker inventory limit violated")
            abs(market_maker.cash) < 1.0e-10 && (market_maker.cash = 0.0)
        end
    end

    exec_b = fill_b
    exec_s = fill_s
    return (executed_buys = exec_b, executed_sells = exec_s,
            suppressed_buys = supp_b, suppressed_sells = supp_s,
            market_maker_rejected_buys = rejected_b,
            market_maker_rejected_sells = rejected_s)
end

market_trace(::AbstractMarketObserver) = nothing
market_initialize!(::AbstractMarketObserver, config, grid, books, edges, dealer) = nothing
market_before_step!(::AbstractMarketObserver, t, grid, books, price, mu, sigma, dealer) = nothing
market_after_execution!(::AbstractMarketObserver, t, grid, books, price, counts, dealer) = nothing
market_ca_step(::AbstractMarketObserver, t, grid, world, agents, major) =
    _ca_step(grid, world, agents, major)

# ---------------------------------------------------------------------------
# Model B — closed simulation (endogenous price → edge agents → price)
# ---------------------------------------------------------------------------

"""
    simulate(config::MyModelBConfiguration; initial_grid, snapshot_steps,
             intervention, minority_population, rule_activation_step,
             boundary_mode, verbose)
        → MyModelBSimulationResult

Run the closed-loop (Model B) simulation with per-agent budget constraints and
an explicit market maker. `config.market_maker_capacity = Inf` is the exact
historical fill-all limit; finite values constrain the maker's symmetric net
capacity per trader.

Step t (t = 1..steps) transforms X_{t-1} → X_t in this exact order:

    o_i     = desired orders (interior grid states; e_{i,t-1} for edges)
    x_i     = execution filter + settlement at the standing quote P_{t-1}:
              buy iff cash ≥ P; sell iff shares ≥ 1 and
              (¬cost_basis_rule or P > avg_cost)
    φ_{t-1} = (executed buys − executed sells) / N_traders
    P_t     = P_{t-1} · exp(λ · φ_{t-1})          (log return = λ·φ_{t-1})
    μ_t     = μ_{t-1} + α·(P_t − μ_{t-1})         (EMA sees the NEW price)
    σ_t     = σ_{t-1} + α·(|P_t − μ_t| − σ_{t-1})
    e_{i,t} = BandState(P_t, μ_t, σ_t, k_i)       → active edge cell i
    X_t     = CA step on interior of X_{t-1}      (edge neighbors see e_{i,t})

N_traders = N_interior + N_active_edge, fixed for the run. All randomness
comes from Xoshiro(config.seed), consumed in fixed order: (1) edge-cell
sampling, (2) edge band half-widths, (3) initial-grid perturbation,
(4) minority rule assignment. Same config ⇒ identical output.

Arguments
- config        : MyModelBConfiguration (single source of truth)
- initial_grid  : required iff config.initial_condition == :custom
- snapshot_steps: steps at which to store full grid frames (default: 8
                  log-spaced); t = 0 and t = steps are always stored
- intervention  : optional (t, books) -> nothing hook called at the TOP of
                  step t, before orders execute at P_{t-1}. May mutate the
                  books in place (e.g. a mid-run liquidity injection). Must
                  be deterministic in (t, books) — no RNG — or the
                  same-config ⇒ identical-output contract breaks.
- minority_population : `:all_sites` (historical behavior) or `:interior`.
                  The latter assigns exactly round(f*N_interior) minority
                  rules among updateable interior cells.
- rule_activation_step : optional delayed rule quench. When set, the sites
                  designated by `minority_fraction` initially follow the
                  major rule and switch to their preselected minor rule at
                  the top of this step. Set to `steps + 1` for the paired
                  matched no-switch control. `nothing` preserves the historical model,
                  in which minority rules are active from t = 0.
- boundary_mode : `:endogenous` (default) lets the updated price classify the
                  active edge ring. `:hold` clamps the same sampled edge sites
                  to Hold while retaining the identical RNG stream, trader
                  denominator, books, and fixed-boundary CA geometry. This is
                  the matched autonomous-CA ablation.
- activation_action : `:rule` switches target rules; `:sell_pulse` instead
                  writes Sell once at the same targets before orders, retaining
                  the baseline rule. Requires delayed activation.
- fixed_band_step : freeze the boundary decision deviation at its value just
                  before this step; the center and diagnostic deviation continue
                  updating. The pre-intervention path is unchanged.
- verbose       : show a ProgressMeter bar (default true)
- observer      : optional decision/measurement observer. It runs before orders
                  and after settlement/repricing; legacy state histories still
                  describe the end-of-step local update.
- clearing      : `:legacy` reproduces the archived standing-quote model, which
                  permits profitable round trips. `:reserve` uses a finite
                  constant-product dealer, actual-price eligibility, and the
                  final reserve ratio as price; lambda does not apply.

Returns MyModelBSimulationResult; see its docstring for the series-length
conventions (state-like: steps+1; transition-like: steps).
"""
function simulate(
    config::MyModelBConfiguration;
    initial_grid::Union{Nothing, Array{Int64,2}} = nothing,
    snapshot_steps::Union{Nothing, Vector{Int64}} = nothing,
    intervention::Union{Nothing, Function} = nothing,
    minority_population::Symbol = :all_sites,
    rule_activation_step::Union{Nothing, Int64} = nothing,
    boundary_mode::Symbol = :endogenous,
    activation_action::Symbol = :rule,
    fixed_band_step::Union{Nothing, Int64} = nothing,
    observer::Union{Nothing,AbstractMarketObserver} = nothing,
    clearing::Symbol = :reserve,
    verbose::Bool = true,
)::MyModelBSimulationResult

    clearing in (:legacy,:reserve) || throw(ArgumentError("unknown clearing mechanism"))

    boundary_mode in (:endogenous, :hold) ||
        throw(ArgumentError("boundary_mode must be :endogenous or :hold"))
    activation_action in (:rule, :sell_pulse) ||
        throw(ArgumentError("activation_action must be :rule or :sell_pulse"))
    activation_action == :sell_pulse && isnothing(rule_activation_step) &&
        throw(ArgumentError("sell_pulse requires rule_activation_step"))
    isnothing(fixed_band_step) || 1 <= fixed_band_step <= config.steps ||
        throw(ArgumentError("fixed_band_step must lie in 1:steps"))

    nrows = config.number_of_rows
    ncols = config.number_of_cols
    steps = config.steps
    α     = config.α
    k     = config.k
    λ     = config.λ
    P0    = config.P0

    # Seeded RNG — draw order below is part of the reproducibility contract
    rng = Xoshiro(config.seed)

    # (1) edge sampling, (2) band half-widths, (3) initial grid, (4) minority rules
    edge_coordinates = build_edge_coordinates(nrows, ncols, config.edge_fraction, rng)
    edge_k           = build_edge_bands(k, config.edge_band_spread,
                                        length(edge_coordinates), rng)
    grid             = build_initial_grid(config, rng; custom_grid = initial_grid)
    world, agents, rule_major = _build_ca_components(
        config; rng = rng, minority_population = minority_population,
    )

    # A delayed activation preserves one preselected quenched landscape in
    # both arms.  The treated run restores those minor rules at the quench;
    # the paired control uses steps+1 and therefore keeps them dormant for the
    # full observed horizon.  State, price, bands, books, and the RNG stream
    # are otherwise identical.
    target_minor_indices = Int64[]
    target_minor_rules = MyTwoDimensionalTotalisticWolframRuleModel[]
    if !isnothing(rule_activation_step)
        1 <= rule_activation_step <= steps + 1 ||
            throw(ArgumentError("rule_activation_step must lie in 1:(steps + 1)"))
        isnothing(agents) &&
            throw(ArgumentError("delayed rule activation requires minority_fraction > 0"))
        for (i, agent) in enumerate(agents)
            agent.rule.index == config.rule_minor_index || continue
            push!(target_minor_indices, i)
            push!(target_minor_rules, agent.rule)
            agent.rule = rule_major
        end
        isempty(target_minor_indices) &&
            throw(ArgumentError("minority_fraction selected zero delayed-activation sites"))
    end

    books     = build_agent_books(config)
    n_edge    = length(edge_coordinates)
    N_traders = (nrows - 2) * (ncols - 2) + n_edge
    market_maker = clearing==:reserve ? build_reserve_dealer(config,Int64(N_traders)) :
                                       build_market_maker(config,Int64(N_traders))
    isnothing(observer) || market_initialize!(observer, config, grid, books,
                                             edge_coordinates, market_maker)
    order_trace = isnothing(observer) ? nothing : market_trace(observer)

    # Output containers
    prices           = Vector{Float64}(undef, steps + 1)
    log_returns      = Vector{Float64}(undef, steps)
    net_imbalance    = Vector{Float64}(undef, steps)
    buy_fraction     = Vector{Float64}(undef, steps + 1)
    hold_fraction    = Vector{Float64}(undef, steps + 1)
    sell_fraction    = Vector{Float64}(undef, steps + 1)
    edge_buy_count   = Vector{Int64}(undef, steps)
    edge_hold_count  = Vector{Int64}(undef, steps)
    edge_sell_count  = Vector{Int64}(undef, steps)
    ema_price        = Vector{Float64}(undef, steps + 1)
    ema_volatility   = Vector{Float64}(undef, steps + 1)
    band_lower       = Vector{Float64}(undef, steps + 1)
    band_upper       = Vector{Float64}(undef, steps + 1)
    executed_buys    = Vector{Int64}(undef, steps)
    executed_sells   = Vector{Int64}(undef, steps)
    suppressed_buys  = Vector{Int64}(undef, steps)
    suppressed_sells = Vector{Int64}(undef, steps)
    market_maker_rejected_buys  = Vector{Int64}(undef, steps)
    market_maker_rejected_sells = Vector{Int64}(undef, steps)
    total_cash       = Vector{Float64}(undef, steps + 1)
    total_shares     = Vector{Int64}(undef, steps + 1)
    market_maker_cash      = Vector{Float64}(undef, steps + 1)
    market_maker_inventory = Vector{Int64}(undef, steps + 1)

    # t = 0 state
    prices[1]         = P0
    ema_price[1]      = P0
    ema_volatility[1] = 0.0
    band_lower[1]     = P0
    band_upper[1]     = P0
    buy_fraction[1], hold_fraction[1], sell_fraction[1] = compute_interior_fractions(grid)
    total_cash[1], total_shares[1] = compute_book_totals(books, edge_coordinates)
    market_maker_cash[1] = market_maker.cash
    market_maker_inventory[1] = market_maker.inventory

    # Per-agent edge states e_{i,t}; baseline e_{i,0} = Hold
    edge_now      = fill(1, n_edge)
    edge_switches = 0

    # Sparse frames: always t = 0 and t = steps, plus log-spaced (or supplied) steps
    snaps = isnothing(snapshot_steps) ?
        Set{Int64}(unique(round.(Int, exp.(range(log(1), log(steps), length = 8))))) :
        Set{Int64}(snapshot_steps)
    push!(snaps, steps)
    frames    = Dict{Int64, Array{Int64,2}}()
    frames[0] = copy(grid)

    μ = P0
    σ = 0.0
    frozen_deviation = 0.0

    for t in 1:steps
        if !isnothing(fixed_band_step) && t == fixed_band_step
            frozen_deviation = σ
        end
        # --- optional rule quench: activate the preselected contrarian sites
        #     without changing any dynamical state or financial variable ---
        if !isnothing(rule_activation_step) && t == rule_activation_step
            for (i, rule) in zip(target_minor_indices, target_minor_rules)
                if activation_action == :rule
                    agents[i].rule = rule
                else
                    r, c = world.states[i]
                    grid[r, c] = 2
                end
            end
        end

        # --- optional intervention mutates the books before this step trades ---
        isnothing(intervention) || intervention(t, books)
        isnothing(observer) || market_before_step!(observer, t, grid, books,
                                                   prices[t], μ, σ, market_maker)

        # --- desired orders are filtered through the books and settled
        #     at the standing quote P_{t-1} ---
        execute = clearing==:reserve ? execute_reserve_orders! : execute_orders!
        counts = execute(books, grid, edge_coordinates, edge_now, prices[t];
                                 cost_basis_rule = config.cost_basis_rule,
                                 market_maker = market_maker,
                                 seed = config.seed, step = Int64(t), trace = order_trace)
        executed_buys[t]    = counts.executed_buys
        executed_sells[t]   = counts.executed_sells
        suppressed_buys[t]  = counts.suppressed_buys
        suppressed_sells[t] = counts.suppressed_sells
        market_maker_rejected_buys[t]  = counts.market_maker_rejected_buys
        market_maker_rejected_sells[t] = counts.market_maker_rejected_sells
        total_cash[t + 1], total_shares[t + 1] =
            compute_book_totals(books, edge_coordinates)
        market_maker_cash[t + 1] = market_maker.cash
        market_maker_inventory[t + 1] = market_maker.inventory

        # --- the EXECUTED imbalance generates the next price ---
        φ                = (counts.executed_buys - counts.executed_sells) / N_traders
        net_imbalance[t] = φ
        P                = clearing==:reserve ? counts.next_price : prices[t] * exp(λ * φ)
        prices[t + 1]    = P
        log_returns[t]   = clearing==:reserve ? log(P/prices[t]) : λ * φ
        isnothing(observer) || market_after_execution!(observer, t, grid, books,
                                                       P, counts, market_maker)

        # --- online EMA / volatility observe the NEW price ---
        μ = μ + α * (P - μ)
        σ = σ + α * (abs(P - μ) - σ)
        ema_price[t + 1]      = μ
        ema_volatility[t + 1] = σ
        decision_deviation = !isnothing(fixed_band_step) && t >= fixed_band_step ?
                             frozen_deviation : σ
        band_lower[t + 1]     = μ - k * decision_deviation
        band_upper[t + 1]     = μ + k * decision_deviation

        # --- the newly generated price either drives the edge ring or is
        #     prevented from re-entering the lattice in the matched Hold
        #     boundary ablation ---
        if boundary_mode == :endogenous
            for i in 1:n_edge
                e = compute_band_state(P, μ, decision_deviation, edge_k[i])
                edge_switches += (e != edge_now[i])
                edge_now[i]    = e
            end
        else
            fill!(edge_now, 1)
        end
        edge_buy_count[t]  = count(==(0), edge_now)
        edge_hold_count[t] = count(==(1), edge_now)
        edge_sell_count[t] = count(==(2), edge_now)
        _set_edge_states!(grid, edge_coordinates, edge_now)

        # --- CA updates the interior grid ---
        grid = isnothing(observer) ? _ca_step(grid, world, agents, rule_major) :
               market_ca_step(observer, t, grid, world, agents, rule_major)
        buy_fraction[t + 1], hold_fraction[t + 1], sell_fraction[t + 1] =
            compute_interior_fractions(grid)

        t in snaps && (frames[t] = copy(grid))
    end

    return MyModelBSimulationResult(
        frames, prices, log_returns, net_imbalance,
        buy_fraction, hold_fraction, sell_fraction,
        edge_buy_count, edge_hold_count, edge_sell_count, edge_switches,
        ema_price, ema_volatility, band_lower, band_upper,
        executed_buys, executed_sells, suppressed_buys, suppressed_sells,
        market_maker_rejected_buys, market_maker_rejected_sells,
        total_cash, total_shares, market_maker_cash, market_maker_inventory,
        books, market_maker,
        edge_coordinates, edge_k, config,
    )
end
