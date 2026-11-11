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

"""
    MyNoisyDealer

Holds what we need to add noise to the dealer's share price: the random number generator `rng`, and
`step_volatility`, the standard deviation of the noise that one step adds to the log share price.
"""
struct MyNoisyDealer <: VLQuantitativeFinancePackage.WolframMarkets.AbstractMarketObserver
    rng::Xoshiro
    step_volatility::Float64
end

"""
    market_before_step!(noise::MyNoisyDealer, t, grid, books, price, mu, sigma, dealer) -> Nothing

The simulator calls this function at the start of every step `t`, before the dealer fills the orders. We
multiply the dealer's cash by `exp(step_volatility*Z)`, where `Z` is a standard normal draw. The dealer
quotes the share price as its cash divided by its shares, so the log share price changes by
`step_volatility*Z`. We do nothing when `step_volatility` is `0.0`.
"""
function VLQuantitativeFinancePackage.WolframMarkets.market_before_step!(noise::MyNoisyDealer, t, grid, books, price, mu, sigma, dealer)

    # add the noise of this step to the dealer's cash -
    if noise.step_volatility > 0.0
        Z = randn(noise.rng); # standard normal draw
        dealer.cash = dealer.cash*exp(noise.step_volatility*Z);
    end

    # return -
    return nothing
end

"""
    run_noisy_rule_switch(; L, f, h, seed, boundary_mode, σ_S, Δt, t_pre = 1000, t_post = 3000,
        f_control = f, snapshot_steps = [t_pre, t_pre + t_post], kwargs...) -> NamedTuple

Run a switched Wolfram market and its control, with noise in the dealer's share price. This function
does what `WM.run_rule_switch(...)` does, and adds a random change to the log share price at each step.

The noise has annualized volatility `σ_S` (1/√yr), and one step lasts `Δt` years, so the noise added in
one step has standard deviation `σ_S*sqrt(Δt)`. Changing `Δt` changes the noise of each step. The
switched market and its control get the same noise. `σ_S = 0.0` gives the market with no noise.

The other arguments are those of `WM.run_rule_switch(...)`: grid size `L`, fraction `f` of interior traders
that switch, dealer depth `h`, starting market `seed`, edge traders `boundary_mode`, `t_pre` steps before
the switch and `t_post` steps after it. We save the grid at the steps in `snapshot_steps`. Extra `kwargs`
(for example `random_edge_probabilities`) go to the simulator.

Returns the named tuple `(switched, control, t_pre)`. Each market has fields such as `prices` (length
`t_pre + t_post + 1`), `sell_fraction`, and `frames`.

### Example
```julia
Δt = 1/(252*390); # one step is one minute of a 390-minute trading day
pair = run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt);
pair.switched.prices[end] < pair.control.prices[end] # true: the switched share price ends below the control
```
"""
function run_noisy_rule_switch(; L::Int64, f::Float64, h::Float64, seed::Int64, boundary_mode::Symbol, σ_S::Float64, Δt::Float64,
        t_pre::Int64 = 1000, t_post::Int64 = 3000, f_control::Float64 = f,
        snapshot_steps::Vector{Int64} = [t_pre, t_pre + t_post], kwargs...)

    # check the inputs -
    if σ_S < 0.0
        throw(ArgumentError("the volatility σ_S of the noise must be zero or positive"));
    end
    if Δt <= 0.0
        throw(ArgumentError("the time step Δt must be positive"));
    end

    # initialize: the number of steps, and the noise that one step adds to the log share price -
    WM = VLQuantitativeFinancePackage.WolframMarkets;
    steps = t_pre + t_post;
    step_volatility = σ_S*sqrt(Δt);

    # run the control: its switch step is after the last step, so it never switches -
    control_noise = MyNoisyDealer(Xoshiro(seed + 10_000), step_volatility);
    control_config = WM.rule_switch_config(L = L, f = f_control, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
    control = WM.simulate(control_config; clearing = :reserve, snapshot_steps = snapshot_steps, minority_population = :interior,
        rule_activation_step = steps + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = control_noise, verbose = false, kwargs...);

    # run the switched market: the same starting market and the same noise, with the switch after step t_pre -
    switched_noise = MyNoisyDealer(Xoshiro(seed + 10_000), step_volatility);
    switched_config = WM.rule_switch_config(L = L, f = f, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
    switched = WM.simulate(switched_config; clearing = :reserve, snapshot_steps = snapshot_steps, minority_population = :interior,
        rule_activation_step = t_pre + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = switched_noise, verbose = false, kwargs...);

    # checks: the two markets share their history up to the switch, and every price is positive -
    @assert switched.sell_fraction[1:(t_pre + 1)] == control.sell_fraction[1:(t_pre + 1)] "switched and control must share their history"
    @assert switched.prices[1:(t_pre + 2)] == control.prices[1:(t_pre + 2)] "switched and control must share their prices up to the switch"
    @assert all(isfinite, switched.prices) && all(switched.prices .> 0.0) "every switched price must be positive"
    @assert all(isfinite, control.prices) && all(control.prices .> 0.0) "every control price must be positive"

    # return -
    return (switched = switched, control = control, t_pre = t_pre)
end

"""
    run_rule_market(; rule, L, h, seed, boundary_mode, steps, σ_S, Δt, snapshot_steps = [0, steps], kwargs...)

Run a Wolfram market in which every interior trader follows the rule number `rule` at every step. No
trader switches rules. With `rule = 19280`, this market is the control of `run_noisy_rule_switch(...)`
with the same `L`, `h`, `seed`, `boundary_mode`, `σ_S`, and `Δt`.

The arguments are the rule number `rule` (from `0` to `19682`), the grid size `L`, the dealer depth `h`,
the starting market `seed`, the edge traders `boundary_mode`, and the number of `steps`. The dealer's
share price gets noise with annualized volatility `σ_S` (1/√yr), and one step lasts `Δt` years, as in
`run_noisy_rule_switch(...)`. We save the grid at the steps in `snapshot_steps`. Extra `kwargs` (for
example `random_edge_probabilities`) go to the simulator.

Returns the simulation result, with fields such as `frames`, `prices`, `buy_fraction`, `hold_fraction`,
and `sell_fraction`. Each of the last four has length `steps + 1`, and index `t + 1` holds step `t`.

### Example
```julia
market = run_rule_market(rule = 19280, L = 32, h = 100.0, seed = 1, boundary_mode = :endogenous, steps = 200,
    σ_S = 0.20, Δt = 1/(252*390));
market.buy_fraction[end] # fraction of the interior traders who intend to buy at the last step
```
"""
function run_rule_market(; rule::Int64, L::Int64, h::Float64, seed::Int64, boundary_mode::Symbol, steps::Int64, σ_S::Float64, Δt::Float64,
        snapshot_steps::Vector{Int64} = [0, steps], kwargs...)

    # check the inputs -
    if rule < 0 || rule >= 3^9
        throw(ArgumentError("the rule number must be between 0 and $(3^9 - 1)"));
    end
    if steps < 2
        throw(ArgumentError("a market needs at least 2 steps"));
    end
    if σ_S < 0.0
        throw(ArgumentError("the volatility σ_S of the noise must be zero or positive"));
    end
    if Δt <= 0.0
        throw(ArgumentError("the time step Δt must be positive"));
    end

    # initialize: the settings of the rule-switch market, with our rule in place of both of its rules -
    WM = VLQuantitativeFinancePackage.WolframMarkets;
    config = WM.rule_switch_config(L = L, f = 0.25, h = h, seed = seed, t_pre = steps - 1, t_post = 1);
    config.rule_major_index = rule;
    config.rule_minor_index = rule;
    noise = MyNoisyDealer(Xoshiro(seed + 10_000), σ_S*sqrt(Δt));

    # run the market: the switch step is after the last step, so no trader ever switches -
    market = WM.simulate(config; clearing = :reserve, snapshot_steps = snapshot_steps, minority_population = :interior,
        rule_activation_step = steps + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = noise, verbose = false, kwargs...);

    # checks -
    @assert length(market.prices) == steps + 1 "one price for each step, including step 0"
    @assert all(isfinite, market.prices) && all(market.prices .> 0.0) "every price must be positive"

    # return -
    return market
end

"""
    plot_rule(entries::Vector{Int64}; colors::Vector, names::Vector{String}, title_text::String = "") -> Plots.Plot

Draw a rule table as nine colored tiles. `entries` holds the nine entries of the rule, coded 0 = Buy,
1 = Hold, 2 = Sell, where `entries[c + 1]` is the next intention of a trader whose four neighbors' intentions
add up to `c`. We draw sum 8 on the left and sum 0 on the right, the order of the digits of the rule number
in base 3. `colors` and `names` hold the tile colors and the names in the order Buy, Hold, Sell.

### Example
```julia
entries = WM.rule_table(19280);
plot_rule(entries; colors = [:blue, :gray, :orange], names = ["Buy", "Hold", "Sell"], title_text = "Rule 19280")
```
"""
function plot_rule(entries::Vector{Int64}; colors::Vector, names::Vector{String}, title_text::String = "")

    # check the inputs -
    if length(entries) != 9
        throw(ArgumentError("a rule table has nine entries"));
    end

    # initialize: one tile for each neighbor sum, from sum 8 on the left to sum 0 on the right -
    sums = collect(8:-1:0);
    tiles = zeros(Int64, 1, 9);
    for k ∈ 1:9
        tiles[1, k] = entries[sums[k] + 1];
    end
    color_map = cgrad(colors, 3, categorical = true);

    # draw the nine tiles -
    p = heatmap(tiles, color = color_map, clims = (-0.5, 2.5), colorbar = false, framestyle = :box, yticks = false,
        xticks = (1:9, string.(sums)), xlims = (0.5, 9.5), ylims = (0.5, 1.5), title = title_text, titlefontsize = 11,
        xlabel = "Sum of the four neighbors' intentions (Buy = 0, Hold = 1, Sell = 2)", size = (900, 190),
        bottom_margin = 8Plots.mm, background_color_outside = "white");

    # write the next intention on each tile, and draw a line between neighboring tiles -
    for k ∈ 1:9
        text_color = :white;
        if tiles[1, k] == 1
            text_color = :black; # black reads better on the gray Hold tile
        end
        annotate!(p, k, 1.0, text(names[tiles[1, k] + 1], 11, text_color));
    end
    vline!(p, 1.5:1.0:8.5, lw = 1.5, c = :white, label = "");

    # return -
    return p
end
