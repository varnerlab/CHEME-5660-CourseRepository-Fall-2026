# Course-facing helpers for the rule-switch experiment (course addition, not part of the paper snapshot).

"""
    rule_table(R::Int64)::Vector{Int64}

The nine actions ``a_0,\\dots,a_8`` of the two-dimensional totalistic Wolfram rule number `R`: the base-3 digits of
`R`, least significant first, so index `k + 1` is the action for neighbor sum `k` (0 = Hold, 1 = Buy, 2 = Sell).
Throws an `ArgumentError` unless `0 ≤ R < 3^9`.
"""
function rule_table(R::Int64)::Vector{Int64}
    (0 <= R < 3^9) || throw(ArgumentError("rule number must satisfy 0 <= R < 3^9 = $(3^9), got $(R)"))
    return Int64.(digits(R; base = 3, pad = 9))
end

"""
    rule_switch_config(; L, f, h, seed, t_pre = 1000, t_post = 3000)::MyModelBConfiguration

The configuration of the rule-switch experiment on an `L × L` grid (including the edge ring): minority fraction
`f`, dealer depth `h` (the `market_maker_capacity`), `steps = t_pre + t_post`. Every field is set explicitly to the
paper's value (baseline Rule 19280, switch Rule 19286).
"""
function rule_switch_config(; L::Int64, f::Float64, h::Float64, seed::Int64, t_pre::Int64 = 1000,
        t_post::Int64 = 3000)::MyModelBConfiguration
    return build(MyModelBConfiguration, (
        number_of_rows = L,
        number_of_cols = L,
        number_of_colors = 3,
        radius = 4,
        steps = t_pre + t_post,
        seed = seed,
        initial_condition = :balanced_perturbation,
        initial_buy_fraction = 0.05,
        initial_sell_fraction = 0.05,
        edge_fraction = 0.25,
        α = 1 / 60,
        λ = 0.02,
        k = 1.0,
        minority_fraction = f,
        edge_band_spread = 0.5,
        cost_basis_rule = false,
        initial_cash = 1000.0,
        initial_shares = 10,
        P0 = 100.0,
        market_maker_capacity = h,
        rule_major_index = 19280,
        rule_minor_index = 19286,
    ))
end

"""
    run_rule_switch(; L, f, h, seed, boundary_mode, t_pre = 1000, t_post = 3000, f_control = f, kwargs...)

Run the switched arm (minority fraction `f`, the rule switches at step `t_pre + 1`) and the control arm (minority
fraction `f_control`, no switch within the horizon) through [`simulate_checked`](@ref), both with `:interior`
minority placement, the rule activation action, and frames stored at `t_pre` and `t_pre + t_post`. Extra `kwargs`
(for example `random_edge_probabilities` with `boundary_mode = :random`) go to both arms. Asserts that the two arms
share their history up to the switch. Returns `(switched, control, t_pre)`.
"""
function run_rule_switch(; L::Int64, f::Float64, h::Float64, seed::Int64, boundary_mode::Symbol,
        t_pre::Int64 = 1000, t_post::Int64 = 3000, f_control::Float64 = f, kwargs...)
    steps = t_pre + t_post
    arm(fraction, activation) = simulate_checked(
        rule_switch_config(L = L, f = fraction, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
        snapshot_steps = [t_pre, steps],
        minority_population = :interior,
        rule_activation_step = activation,
        boundary_mode = boundary_mode,
        activation_action = :rule,
        fixed_band_step = nothing,
        intervention = nothing,
        initial_grid = nothing,
        observer = nothing,
        verbose = false,
        kwargs...,
    )
    control = arm(f_control, steps + 1)
    switched = arm(f, t_pre + 1)

    # the arms must share their history up to the switch -
    @assert switched.frames[t_pre] == control.frames[t_pre]
    @assert switched.sell_fraction[1:(t_pre + 1)] == control.sell_fraction[1:(t_pre + 1)]
    @assert switched.prices[1:(t_pre + 2)] == control.prices[1:(t_pre + 2)]
    @assert switched.edge_coordinates == control.edge_coordinates
    @assert switched.edge_k == control.edge_k
    return (switched = switched, control = control, t_pre = t_pre)
end

# first post-switch step with sell fraction ≥ 0.5 (0 if none), as in the paper's _first_crossing -
function _first_crossing(sell_fraction::Vector{Float64}, t_pre::Int64)::Int64
    i = findfirst(≥(0.5), @view sell_fraction[(t_pre + 2):end])
    return isnothing(i) ? 0 : i
end

function summarize_arm(r::MyModelBSimulationResult, t_pre::Int64, w::Int64)
    onset = _first_crossing(r.sell_fraction, t_pre)
    return (transitioned = onset > 0, onset = onset,
            final_sell_mean = mean(@view r.sell_fraction[(end - w + 1):end]),
            max_drawdown = compute_max_drawdown(collect(@view r.prices[(t_pre + 1):end])))
end

"""
    rule_switch_summary(pair; window = 500)::NamedTuple

Summarize the output of [`run_rule_switch`](@ref) with the paper's per-run definitions. `final_sell_mean` is the
mean sell fraction over the last `min(t_post, window)` steps; `onset` is the number of steps after the switch to the
first sell fraction ≥ 0.5 (0 if none) and `transitioned` is `onset > 0`; `max_drawdown` is
[`compute_max_drawdown`](@ref) of the post-switch prices. The `control_*` fields are the same quantities for the
control arm.
"""
function rule_switch_summary(pair; window::Int64 = 500)::NamedTuple
    t_pre = pair.t_pre
    t_post = length(pair.switched.sell_fraction) - 1 - t_pre
    w = min(t_post, window)
    s = summarize_arm(pair.switched, t_pre, w)
    c = summarize_arm(pair.control, t_pre, w)
    return (transitioned = s.transitioned, onset = s.onset, final_sell_mean = s.final_sell_mean,
            max_drawdown = s.max_drawdown, control_transitioned = c.transitioned,
            control_final_sell_mean = c.final_sell_mean, control_max_drawdown = c.max_drawdown)
end
