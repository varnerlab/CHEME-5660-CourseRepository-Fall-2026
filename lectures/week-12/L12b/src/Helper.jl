# Helper.jl: plotting and lookup helpers for the L12b rule-switch example. Loaded by Include.jl.

"""
    plot_pair(switched, control, t_pre; title_text = "", price_limits = nothing, show_legend = false,
        color_switched = Sell orange, color_control = black) -> (p_sell, p_price)

Draw one switched market and its control: the fraction of interior traders who intend to sell (top panel,
with a dotted line at one half) and the dealer's price on a log scale (bottom panel). A dashed line marks
the switch step `t_pre`. `switched` and `control` need the fields `sell_fraction` and `prices`, as in a
cached pair or a `WM.run_rule_switch(...)` result. Returns the two panels, so a caller can arrange
several pairs in one figure with shared `price_limits`.
"""
function plot_pair(switched, control, t_pre::Int; title_text::String = "", price_limits = nothing, show_legend::Bool = false,
        color_switched = parse(Colorant, "#D55E00"), color_control = colorant"black")

    # time axes: one point for each recorded step, starting at step 0 -
    t_sell = 0:(length(switched.sell_fraction) - 1);
    t_price = 0:(length(switched.prices) - 1);

    # top panel: fraction of interior traders who intend to sell -
    p_sell = plot(t_sell, control.sell_fraction, label = show_legend ? "control" : "", color = color_control, linewidth = 1.5,
        title = title_text, ylabel = "Sell fraction", ylims = (0.0, 1.0), legend = show_legend ? :topleft : false,
        bg = "gray95", background_color_outside = "white", framestyle = :box, xticks = 0:1000:4000);
    plot!(p_sell, t_sell, switched.sell_fraction, label = show_legend ? "switched" : "", color = color_switched, linewidth = 1.5);
    hline!(p_sell, [0.5], label = "", color = :gray, linestyle = :dot); # a Sell majority is above this line
    vline!(p_sell, [t_pre], label = show_legend ? "switch step" : "", color = :gray, linestyle = :dash);

    # bottom panel: the dealer's price; both panels in a figure share the same price limits -
    p_price = plot(t_price, control.prices, label = "", color = color_control, linewidth = 1.5, xlabel = "step", ylabel = "dealer price (log scale)",
        yscale = :log10, yformatter = y -> string(round(Int, y)), ylims = isnothing(price_limits) ? :auto : price_limits, legend = false,
        bg = "gray95", background_color_outside = "white", framestyle = :box, xticks = 0:1000:4000);
    plot!(p_price, t_price, switched.prices, label = "", color = color_switched, linewidth = 1.5);
    vline!(p_price, [t_pre], label = "", color = :gray, linestyle = :dash);

    # return -
    (p_sell, p_price)
end

"""
    pair_for(cache, condition::String, f::Float64)

Return the cached switched/control pair for one market `condition` (for example `"h=100.0/hold"`) and one
fraction `f` of switching traders. Throws an `ArgumentError` if the cache holds no such pair.
"""
function pair_for(cache, condition::String, f::Float64)
    hits = filter(p -> string("h=", p.h, "/", p.boundary_mode) == condition && p.f == f, cache["pairs"]);
    isempty(hits) && throw(ArgumentError("no cached pair for condition=$(condition), f=$(f)"));
    return first(hits);
end

"""
    plot_final_frames(frames::Vector, titles::Vector{String}; colors::Vector, layout) -> Plots.Plot

Draw each grid in `frames` (a matrix of intentions coded 0 = Buy, 1 = Hold, 2 = Sell) as a heatmap with the
three `colors`, one panel per grid with its title from `titles`, arranged by `layout`. Works for any grid
size, so it draws cached (large) and live (small) markets alike. Pass interior traders only, for example
`frame[2:(end - 1), 2:(end - 1)]`.
"""
function plot_final_frames(frames::Vector, titles::Vector{String}; colors::Vector, layout)

    # initialize: one categorical color for each code 0, 1, 2 -
    cmap = cgrad(colors, 3, categorical = true);

    # one heatmap for each grid -
    panels = [heatmap(fr, color = cmap, clims = (-0.5, 2.5), colorbar = false, aspect_ratio = :equal, framestyle = :box,
        xticks = false, yticks = false, title = t, titlefontsize = 8, background_color_outside = "white") for (fr, t) ∈ zip(frames, titles)];

    # return -
    return plot(panels..., layout = layout, size = (300 * layout[2], 300 * layout[1]));
end

"""
    excess_kurtosis(x::AbstractVector) -> Float64

The excess kurtosis of `x`, the fourth standardized moment minus 3 (population moments). It is 0 for a
Normal distribution and positive when outliers are more frequent than for a Normal distribution.
"""
excess_kurtosis(x::AbstractVector) = mean(((x .- mean(x)) ./ std(x, corrected = false)) .^ 4) - 3

"""
    run_baseline(; L, h, boundary_mode, seed, steps, f = 0.25, kwargs...)

Run a Wolfram market that never switches rules: every interior trader keeps Rule 19280 for all `steps`
steps. It is the control arm of `WM.run_rule_switch(...)` with the same `L`, `h`, `boundary_mode`, `seed`,
and `f`, so it has the same prices. `f` only marks which traders would switch. Extra `kwargs` (for example
`random_edge_probabilities`) go to the simulator. Returns the simulation result, with fields such as
`prices` (length `steps + 1`) and `sell_fraction`.
"""
function run_baseline(; L::Int64, h::Float64, boundary_mode::Symbol, seed::Int64, steps::Int64, f::Float64 = 0.25, kwargs...)
    steps >= 2 || throw(ArgumentError("a baseline market needs at least 2 steps"))
    WM = VLQuantitativeFinancePackage.WolframMarkets
    config = WM.rule_switch_config(L = L, f = f, h = h, seed = seed, t_pre = steps - 1, t_post = 1)
    return WM.simulate_checked(config; snapshot_steps = [steps - 1, steps], minority_population = :interior,
        rule_activation_step = steps + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = nothing, verbose = false, kwargs...)
end
