# Helper.jl: helpers for the L12b examples (grid plot, stylized facts). Loaded by Include.jl.

"""
    plot_grid(frame::Matrix{Int64}; colors::Vector, title_text::String = "") -> Plots.Plot

Draw the interior traders of one saved grid as colored tiles. `frame` is a matrix of intentions coded
0 = Buy, 1 = Hold, 2 = Sell, with the edge traders in its outer ring. We drop the outer ring and draw
the interior. `colors` holds the three tile colors in the order Buy, Hold, Sell. Works for any grid size.

### Example
```julia
pair = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = :endogenous);
plot_grid(pair.switched.frames[4000]; colors = [:blue, :gray, :orange], title_text = "step 4000")
```
"""
function plot_grid(frame::Matrix{Int64}; colors::Vector, title_text::String = "")

    # initialize: the interior traders, and one color for each code 0, 1, 2 -
    interior = frame[2:(end - 1), 2:(end - 1)];
    (number_of_rows, number_of_cols) = size(interior);
    color_map = cgrad(colors, 3, categorical = true);

    # draw: one tile for each interior trader, row 1 at the top -
    p = heatmap(interior, color = color_map, clims = (-0.5, 2.5), colorbar = false, aspect_ratio = :equal, framestyle = :box,
        xticks = false, yticks = false, yflip = true, xlims = (0.5, number_of_cols + 0.5), ylims = (0.5, number_of_rows + 0.5),
        title = title_text, titlefontsize = 10, background_color_outside = "white");

    # return -
    return p
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
