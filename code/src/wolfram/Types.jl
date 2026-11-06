# Types.jl — Abstract and concrete types for the Wolfram Market ABM
# All agent states: 0 = Buy (green), 1 = Hold (gray), 2 = Sell (red)

# ---------------------------------------------------------------------------
# Abstract type hierarchy
# ---------------------------------------------------------------------------
abstract type AbstractSimulationModel end
abstract type AbstractPriceModel end
abstract type AbstractEdgeAgentModel end
abstract type AbstractWorldModel end
abstract type AbstractPolicyModel end
abstract type AbstractAgentModel end

# ---------------------------------------------------------------------------
# Wolfram CA types (self-contained, no external package dependency)
# ---------------------------------------------------------------------------

"""
    MyTwoDimensionalTotalisticWolframRuleModel <: AbstractPolicyModel

2D totalistic Wolfram CA rule for a 3-state (buy/hold/sell) grid.

The neighborhood sum c = mean(4 cardinal neighbors) is looked up in
`neighborhoodstatesmap` to get a config index, which maps via `rule`
to the agent's next state.
"""
mutable struct MyTwoDimensionalTotalisticWolframRuleModel <: AbstractPolicyModel
    index::Int64
    radius::Int64
    number_of_colors::Int64
    neighborhoodstatesmap::Dict{Float64, Int64}   # rounded mean → config index
    rule::Dict{Int64, Int64}                       # config index → next state
    weights::Vector{Float64}                       # uniform: 1/radius each
    MyTwoDimensionalTotalisticWolframRuleModel() = new()
end

"""
    MyTwoDimensionalFixedBoundaryGridWorld <: AbstractWorldModel

Fixed-boundary rectangular grid. Stores bidirectional maps between
linear indices and (row, col) coordinates.
"""
mutable struct MyTwoDimensionalFixedBoundaryGridWorld <: AbstractWorldModel
    states::Dict{Int64, Tuple{Int64,Int64}}        # linear index → (row, col)
    coordinates::Dict{Tuple{Int64,Int64}, Int64}   # (row, col) → linear index
    width::Int64
    height::Int64
    MyTwoDimensionalFixedBoundaryGridWorld() = new()
end

"""
    MySimpleTwoDimensionalAgentModel <: AbstractAgentModel

Single CA agent. Holds its grid index, assigned rule, and the linear
indices of its 4 cardinal neighbors (-1 for out-of-bounds).
"""
mutable struct MySimpleTwoDimensionalAgentModel <: AbstractAgentModel
    index::Int64
    rule::MyTwoDimensionalTotalisticWolframRuleModel
    connections::Vector{Int64}   # [left, right, up, down]; -1 = boundary
    MySimpleTwoDimensionalAgentModel() = new()
end


# ---------------------------------------------------------------------------
# Model B configuration and result (closed-loop rebuild; spec 2026-07-15)
# ---------------------------------------------------------------------------

"""
    MyModelBConfiguration <: AbstractSimulationModel

Single source of truth for a Model B run: grid geometry, CA rules,
initialization mode, boundary population, edge-agent parameters, price
model, and the RNG seed. Build via build(MyModelBConfiguration, data),
which applies defaults and validates ranges.

Subtypes AbstractSimulationModel with the standard field names so the shared
CA machinery (_build_ca_components) works on it directly.
"""
mutable struct MyModelBConfiguration <: AbstractSimulationModel
    number_of_rows::Int64
    number_of_cols::Int64
    number_of_colors::Int64          # = 3 (buy / hold / sell)
    radius::Int64                    # = 4 (Von Neumann neighbors)
    steps::Int64
    seed::Int64                      # seeds ALL randomness for the run
    initial_condition::Symbol        # :all_hold | :balanced_perturbation | :custom
    initial_buy_fraction::Float64    # Buy seeds, fraction of interior cells
    initial_sell_fraction::Float64   # Sell seeds, fraction of interior cells
    edge_fraction::Float64           # fraction of boundary cells that are active
    α::Float64                       # EMA learning rate
    k::Float64                       # band half-width in units of σ
    λ::Float64                       # price impact (per-capita inverse depth)
    P0::Float64                      # initial price
    minority_fraction::Float64       # fraction of agents using rule_minor
    rule_major_index::Int64
    rule_minor_index::Int64
    initial_cash::Float64            # starting cash per trading cell (spec 2026-07-16)
    initial_shares::Int64            # starting share inventory per trading cell
    cost_basis_rule::Bool            # sell only above average acquisition cost (disposition effect)
    edge_band_spread::Float64        # δ: k_i ~ U(k(1−δ), k(1+δ)); 0 ⇒ homogeneous bands
    market_maker_capacity::Float64   # symmetric net capacity per trader; Inf recovers legacy execution
    MyModelBConfiguration() = new()
end

"""
    MyAgentBooks

Per-cell balance sheets for Model B trading cells (interior + active edge).
Matrices are grid-shaped; passive boundary cells keep their initial entries
and never trade. avg_cost is average-cost accounting: updated on buys,
unchanged by sells, and consulted only when shares ≥ 1.
"""
struct MyAgentBooks
    cash::Matrix{Float64}
    shares::Matrix{Int64}
    avg_cost::Matrix{Float64}
end

"""Optional per-trader order records: +1 buy, -1 sell, 0 no order/fill."""
struct MyOrderTrace
    desired::Matrix{Int8}
    eligible::Matrix{Int8}
    filled::Matrix{Int8}
end

MyOrderTrace(nrows::Integer, ncols::Integer) =
    MyOrderTrace(zeros(Int8, nrows, ncols), zeros(Int8, nrows, ncols),
                 zeros(Int8, nrows, ncols))

"""An optional observer may supply decisions and collect financial diagnostics."""
abstract type AbstractMarketObserver end

"""
    MyMarketMaker

Explicit counterparty for Model B. `cash` and `inventory` are signed in the
unlimited-reservoir limit, which permits borrowing and shorting without bound
and exactly reproduces the historical execution convention. A constrained
maker starts at the midpoint of `[min_inventory, max_inventory]`, with enough
cash to absorb the same initial net number of agent sells as agent buys.

The initial fields are retained so conservation and exposure can be reported
without reconstructing the configuration that produced the ledger.
"""
mutable struct MyMarketMaker
    cash::Float64
    inventory::Int64
    initial_cash::Float64
    initial_inventory::Int64
    min_inventory::Int64
    max_inventory::Int64
    credit_limit::Float64
    unlimited::Bool
end

"""
    MyModelBSimulationResult

Immutable container for a Model B run: sparse grid snapshots plus the COMPLETE
aggregate trajectory, so all statistics are computed from every step.

State-like series (length steps+1, index 1 = t=0): prices, ema_price,
ema_volatility, band_lower, band_upper (nominal-k band, for plotting),
buy_fraction, hold_fraction, sell_fraction, total_cash, total_shares.
Transition-like series (length steps, index t = step t): log_returns
(= λ·φ_{t-1} only under legacy clearing), net_imbalance (EXECUTED imbalance φ_{t-1}, the value that
generated P_t), edge_buy_count/edge_hold_count/edge_sell_count (counts of
e_{i,t} over active edge agents), executed_buys, executed_sells,
suppressed_buys, suppressed_sells, market_maker_rejected_buys, and
market_maker_rejected_sells. Suppression means the submitting agent lacked
cash/shares (or failed the cost-basis rule); rejection means the agent was
eligible but the finite market maker lacked counterparty capacity.

market_maker_cash and market_maker_inventory are state-like series. In the
unlimited limit they are allowed to become negative and record the borrowing
or short position required to support the historical fill-all convention.

edge_switches = Σ_i Σ_t [e_{i,t} ≠ e_{i,t-1}], baseline e_{i,0} = Hold.
final_books holds the trading-cell balance sheets at t = steps. edge_k[i]
is the band half-width of the agent at edge_coordinates[i] (same order).
frames always contains t=0 and t=steps.
"""
struct MyModelBSimulationResult
    frames::Dict{Int64, Array{Int64,2}}
    prices::Vector{Float64}
    log_returns::Vector{Float64}
    net_imbalance::Vector{Float64}
    buy_fraction::Vector{Float64}
    hold_fraction::Vector{Float64}
    sell_fraction::Vector{Float64}
    edge_buy_count::Vector{Int64}
    edge_hold_count::Vector{Int64}
    edge_sell_count::Vector{Int64}
    edge_switches::Int64
    ema_price::Vector{Float64}
    ema_volatility::Vector{Float64}
    band_lower::Vector{Float64}
    band_upper::Vector{Float64}
    executed_buys::Vector{Int64}
    executed_sells::Vector{Int64}
    suppressed_buys::Vector{Int64}
    suppressed_sells::Vector{Int64}
    market_maker_rejected_buys::Vector{Int64}
    market_maker_rejected_sells::Vector{Int64}
    total_cash::Vector{Float64}
    total_shares::Vector{Int64}
    market_maker_cash::Vector{Float64}
    market_maker_inventory::Vector{Int64}
    final_books::MyAgentBooks
    final_market_maker::MyMarketMaker
    edge_coordinates::Vector{Tuple{Int64,Int64}}
    edge_k::Vector{Float64}
    config::MyModelBConfiguration
end
