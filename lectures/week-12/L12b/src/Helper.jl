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
    run_baseline(; rule, L, h, boundary_mode, seed, steps, f = 0.25, kwargs...)

Run a Wolfram market that never switches rules: every interior trader keeps the rule number `rule` (from
`0` to `19682`) for all `steps` steps. With `rule = 19280`, it is the control arm of
`WM.run_rule_switch(...)` with the same `L`, `h`, `boundary_mode`, `seed`, and `f`, so it has the same
prices. `f` only marks which traders would switch. Extra `kwargs` (for example `random_edge_probabilities`)
go to the simulator. Returns the simulation result, with fields such as `prices` (length `steps + 1`) and
`sell_fraction`.

### Example
```julia
market = run_baseline(rule = 19280, L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 500);
market.prices[end] # share price that the dealer quotes at the last step
```
"""
function run_baseline(; rule::Int64, L::Int64, h::Float64, boundary_mode::Symbol, seed::Int64, steps::Int64, f::Float64 = 0.25, kwargs...)

    # check the inputs -
    if rule < 0 || rule >= 3^9
        throw(ArgumentError("the rule number must be between 0 and $(3^9 - 1)"));
    end
    if steps < 2
        throw(ArgumentError("a baseline market needs at least 2 steps"));
    end

    # initialize: the settings of the rule-switch market, with our rule in place of both of its rules -
    WM = VLQuantitativeFinancePackage.WolframMarkets
    config = WM.rule_switch_config(L = L, f = f, h = h, seed = seed, t_pre = steps - 1, t_post = 1)
    config.rule_major_index = rule;
    config.rule_minor_index = rule;

    # run the market: the switch step is after the last step, so no trader ever switches -
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
    MyFreshPlayers

Holds what we need to add noise to the dealer's share price and to bring fresh players into the market:
the noisy dealer `noise`, the matrix `is_fresh` that is `true` for each trader that a fresh player replaces,
the step `t_fresh` after which the fresh players arrive, the rule table `recovery_table` that the fresh
players follow (entry `c + 1` is the next intention when the four neighbors sum to `c`), and the `cash` (USD)
and `shares` that each fresh player starts with.
"""
struct MyFreshPlayers <: VLQuantitativeFinancePackage.WolframMarkets.AbstractMarketObserver
    noise::MyNoisyDealer
    is_fresh::Matrix{Bool}
    t_fresh::Int64
    recovery_table::Vector{Int64}
    cash::Float64
    shares::Int64
end

"""
    market_before_step!(players::MyFreshPlayers, t, grid, books, price, mu, sigma, dealer) -> Nothing

The simulator calls this function at the start of every step `t`, before the dealer fills the orders. We
first add the noise of this step to the dealer's share price. At the first step after `t_fresh`, each fresh
player replaces a trader: the trader's cash and shares are set to the cash and shares of a fresh player.
"""
function VLQuantitativeFinancePackage.WolframMarkets.market_before_step!(players::MyFreshPlayers, t, grid, books, price, mu, sigma, dealer)

    # add the noise of this step to the dealer's share price -
    VLQuantitativeFinancePackage.WolframMarkets.market_before_step!(players.noise, t, grid, books, price, mu, sigma, dealer);

    # the fresh players arrive: each one starts with the cash and shares of a new trader -
    if t == players.t_fresh + 1
        for i ∈ eachindex(players.is_fresh)
            if players.is_fresh[i] == true
                books.cash[i] = players.cash;
                books.shares[i] = players.shares;
                books.avg_cost[i] = price; # the fresh player has no earlier trades
            end
        end
    end

    # return -
    return nothing
end

"""
    market_ca_step(players::MyFreshPlayers, t, grid, world, agents, major) -> Matrix{Int64}

The simulator calls this function at the end of every step `t` to get the next intention of every interior
trader. Each trader takes its next intention from its own rule. From step `t_fresh` on, each fresh player
takes its next intention from the recovery rule: we sum the intentions of its four neighbors (Buy is `0`,
Hold is `1`, Sell is `2`), and look up that sum in `recovery_table`.
"""
function VLQuantitativeFinancePackage.WolframMarkets.market_ca_step(players::MyFreshPlayers, t, grid, world, agents, major)

    # every trader takes its next intention from its own rule -
    next = VLQuantitativeFinancePackage.WolframMarkets._ca_step(grid, world, agents, major);

    # each fresh player takes its next intention from the recovery rule -
    if t >= players.t_fresh
        (number_of_rows, number_of_columns) = size(grid);
        for row ∈ 2:(number_of_rows - 1)
            for column ∈ 2:(number_of_columns - 1)
                if players.is_fresh[row, column] == true
                    c = grid[row, column - 1] + grid[row, column + 1] + grid[row - 1, column] + grid[row + 1, column]; # sum of the four neighbors
                    next[row, column] = players.recovery_table[c + 1];
                end
            end
        end
    end

    # return -
    return next
end

"""
    run_noisy_rule_switch(; baseline_rule, switch_rule, L, f, h, seed, boundary_mode, σ_S, Δt, t_pre = 1000,
        t_post = 3000, f_control = f, snapshot_steps = [t_pre, t_pre + t_post], fresh_fraction = 0.0,
        t_fresh = t_pre + t_post, recovery_rule = baseline_rule, kwargs...) -> NamedTuple

Run a switched Wolfram market and its control, with noise in the dealer's share price. Every interior
trader follows the rule number `baseline_rule` until the switch. After step `t_pre`, a fraction `f` of
the interior traders follow the rule number `switch_rule`. The control never switches. Both rule numbers
run from `0` to `19682`.

With `baseline_rule = 19280` and `switch_rule = 19286`, this function does what `WM.run_rule_switch(...)`
does, and adds a random change to the log share price at each step.

The noise has annualized volatility `σ_S` (1/√yr), and one step lasts `Δt` years, so the noise added in
one step has standard deviation `σ_S*sqrt(Δt)`. Changing `Δt` changes the noise of each step. The
switched market and its control get the same noise. `σ_S = 0.0` gives the market with no noise.

The other arguments are the grid size `L`, the fraction `f` of interior traders
that switch, dealer depth `h`, starting market `seed`, edge traders `boundary_mode`, `t_pre` steps before
the switch and `t_post` steps after it. We save the grid at the steps in `snapshot_steps`. Extra `kwargs`
(for example `random_edge_probabilities`) go to the simulator.

After step `t_fresh`, fresh players replace a fraction `fresh_fraction` of the interior traders in both
markets. A fresh player starts with the cash and shares that every trader had at step `0`, and follows the
rule number `recovery_rule` (from `0` to `19682`). Rule `0` is the rule whose entries are all Buy. The `seed`
sets which traders are replaced. The default `fresh_fraction = 0.0` gives no fresh players.

Returns the named tuple `(switched, control, t_pre)`. Each market has fields such as `prices` (length
`t_pre + t_post + 1`), `sell_fraction`, and `frames`.

### Example
```julia
Δt = 1/(252*390); # one step is one minute of a 390-minute trading day
pair = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 1,
    boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt);
pair.switched.prices[end] < pair.control.prices[end] # true: the switched share price ends below the control
```
"""
function run_noisy_rule_switch(; baseline_rule::Int64, switch_rule::Int64, L::Int64, f::Float64, h::Float64, seed::Int64,
        boundary_mode::Symbol, σ_S::Float64, Δt::Float64, t_pre::Int64 = 1000, t_post::Int64 = 3000, f_control::Float64 = f,
        snapshot_steps::Vector{Int64} = [t_pre, t_pre + t_post], fresh_fraction::Float64 = 0.0, t_fresh::Int64 = t_pre + t_post,
        recovery_rule::Int64 = baseline_rule, kwargs...)

    # check the inputs -
    if fresh_fraction < 0.0 || fresh_fraction > 1.0
        throw(ArgumentError("the fraction of fresh players must be between 0 and 1"));
    end
    if t_fresh < 0 || t_fresh > t_pre + t_post
        throw(ArgumentError("the step t_fresh must be between 0 and the last step $(t_pre + t_post)"));
    end
    if recovery_rule < 0 || recovery_rule >= 3^9
        throw(ArgumentError("the recovery rule number must be between 0 and $(3^9 - 1)"));
    end
    if baseline_rule < 0 || baseline_rule >= 3^9
        throw(ArgumentError("the baseline rule number must be between 0 and $(3^9 - 1)"));
    end
    if switch_rule < 0 || switch_rule >= 3^9
        throw(ArgumentError("the switch rule number must be between 0 and $(3^9 - 1)"));
    end
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

    # choose the traders that fresh players replace: a random fraction of the interior traders, set by the seed -
    is_fresh = fill(false, L, L);
    number_of_interior_traders = (L - 2)^2;
    number_of_fresh_players = round(Int64, fresh_fraction*number_of_interior_traders);
    recovery_table = WM.rule_table(recovery_rule); # entry c + 1 is the next intention of a fresh player when its neighbors sum to c
    order = randperm(Xoshiro(seed + 20_000), number_of_interior_traders); # the interior traders in a random order
    for k ∈ 1:number_of_fresh_players
        index = order[k]; # interior traders are numbered down each column
        row = 2 + (index - 1) % (L - 2);
        column = 2 + (index - 1) ÷ (L - 2);
        is_fresh[row, column] = true;
    end

    # run the control: its switch step is after the last step, so it never switches -
    control_config = WM.rule_switch_config(L = L, f = f_control, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
    control_noise = MyFreshPlayers(MyNoisyDealer(Xoshiro(seed + 10_000), step_volatility), is_fresh, t_fresh, recovery_table,
        control_config.initial_cash, control_config.initial_shares);
    control_config.rule_major_index = baseline_rule; # the rule before the switch
    control_config.rule_minor_index = switch_rule; # the rule of the switching traders after the switch
    control = WM.simulate(control_config; clearing = :reserve, snapshot_steps = snapshot_steps, minority_population = :interior,
        rule_activation_step = steps + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = control_noise, verbose = false, kwargs...);

    # run the switched market: the same starting market, noise, and fresh players, with the switch after step t_pre -
    switched_config = WM.rule_switch_config(L = L, f = f, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
    switched_noise = MyFreshPlayers(MyNoisyDealer(Xoshiro(seed + 10_000), step_volatility), is_fresh, t_fresh, recovery_table,
        switched_config.initial_cash, switched_config.initial_shares);
    switched_config.rule_major_index = baseline_rule;
    switched_config.rule_minor_index = switch_rule;
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
    MyViewportMarket

Holds what we need to run a market in which players come and go, and some players follow a contrarian rule:
the noisy dealer `noise`, the random number generator `rng` that picks the players who leave, the fraction
`refresh_rate` of interior traders that a new player replaces at each step, the fraction
`contrarian_fraction` of players that follow the contrarian rule, the rule table `contrarian_table` (entry
`c + 1` is the next intention when the four neighbors sum to `c`), the matrix `is_contrarian` that is `true`
for each trader that follows the contrarian rule now, and the `cash` (USD) and `shares` that each new player
starts with.
"""
struct MyViewportMarket <: VLQuantitativeFinancePackage.WolframMarkets.AbstractMarketObserver
    noise::MyNoisyDealer
    rng::Xoshiro
    refresh_rate::Float64
    contrarian_fraction::Float64
    contrarian_table::Vector{Int64}
    is_contrarian::Matrix{Bool}
    cash::Float64
    shares::Int64
end

"""
    market_before_step!(market::MyViewportMarket, t, grid, books, price, mu, sigma, dealer) -> Nothing

The simulator calls this function at the start of every step `t`, before the dealer fills the orders. We
first add the noise of this step to the dealer's share price. Then each interior trader leaves with
probability `refresh_rate`. A new player takes the seat: it starts with the cash and shares of a new trader,
and keeps the intention of the trader that left. The new player follows the contrarian rule with probability
`contrarian_fraction`. Otherwise, it follows the rule of its seat.
"""
function VLQuantitativeFinancePackage.WolframMarkets.market_before_step!(market::MyViewportMarket, t, grid, books, price, mu, sigma, dealer)

    # add the noise of this step to the dealer's share price -
    VLQuantitativeFinancePackage.WolframMarkets.market_before_step!(market.noise, t, grid, books, price, mu, sigma, dealer);

    # players come and go: visit every interior trader -
    if market.refresh_rate > 0.0
        (number_of_rows, number_of_columns) = size(grid);
        for column ∈ 2:(number_of_columns - 1)
            for row ∈ 2:(number_of_rows - 1)
                if rand(market.rng) < market.refresh_rate

                    # a new player takes this seat, with the cash and shares of a new trader -
                    books.cash[row, column] = market.cash;
                    books.shares[row, column] = market.shares;
                    books.avg_cost[row, column] = price; # the new player has no earlier trades

                    # the new player is a contrarian with probability contrarian_fraction -
                    market.is_contrarian[row, column] = (rand(market.rng) < market.contrarian_fraction);
                end
            end
        end
    end

    # return -
    return nothing
end

"""
    market_ca_step(market::MyViewportMarket, t, grid, world, agents, major) -> Matrix{Int64}

The simulator calls this function at the end of every step `t` to get the next intention of every interior
trader. Each trader takes its next intention from the rule of its seat. Each contrarian player takes its
next intention from the contrarian rule: we sum the intentions of its four neighbors (Buy is `0`, Hold is
`1`, Sell is `2`), and look up that sum in `contrarian_table`.
"""
function VLQuantitativeFinancePackage.WolframMarkets.market_ca_step(market::MyViewportMarket, t, grid, world, agents, major)

    # every trader takes its next intention from the rule of its seat -
    next = VLQuantitativeFinancePackage.WolframMarkets._ca_step(grid, world, agents, major);

    # each contrarian player takes its next intention from the contrarian rule -
    (number_of_rows, number_of_columns) = size(grid);
    for row ∈ 2:(number_of_rows - 1)
        for column ∈ 2:(number_of_columns - 1)
            if market.is_contrarian[row, column] == true
                c = grid[row, column - 1] + grid[row, column + 1] + grid[row - 1, column] + grid[row + 1, column]; # sum of the four neighbors
                next[row, column] = market.contrarian_table[c + 1];
            end
        end
    end

    # return -
    return next
end

"""
    run_viewport_rule_switch(; baseline_rule, switch_rule, contrarian_rule, contrarian_fraction, refresh_rate, L, f, h,
        seed, boundary_mode, σ_S, Δt, t_pre, t_post, snapshot_steps = [t_pre, t_pre + t_post], kwargs...) -> NamedTuple

Run a switched Wolfram market and its control, in which players come and go and some players follow a
contrarian rule. The grid is a viewport on a larger market: at each step, each interior trader leaves with
probability `refresh_rate`, and a new player takes its seat with the cash and shares that every trader had
at step `0`. A fraction `contrarian_fraction` of the starting traders, and of the new players, follow the
rule number `contrarian_rule`. Every other trader follows `baseline_rule` until the switch. After step
`t_pre`, a fraction `f` of the seats follow `switch_rule`. The control never switches. Every rule number
runs from `0` to `19682`.

The switched market and its control get the same dealer noise, the same players who leave, and the same
contrarian players. With `refresh_rate = 0.0` and `contrarian_fraction = 0.0`, this function gives the
markets of `run_noisy_rule_switch(...)`.

The other arguments are the grid size `L`, the dealer depth `h`, the starting market `seed`, the edge traders
`boundary_mode`, the annualized volatility `σ_S` (1/√yr) of the dealer noise, the length `Δt` of one step
(years), `t_pre` steps before the switch, and `t_post` steps after it. We save the grid at the steps in
`snapshot_steps`. Extra `kwargs` (for example `random_edge_probabilities`) go to the simulator.

Returns the named tuple `(switched, control, t_pre)`. Each market has fields such as `prices` (length
`t_pre + t_post + 1`), `sell_fraction`, and `frames`.

### Example
```julia
Δt = 1/(252*390); # one step is one minute of a 390-minute trading day
pair = run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 0.25,
    refresh_rate = 0.001, L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt,
    t_pre = 1000, t_post = 3000);
maximum(pair.switched.sell_fraction) # largest fraction of interior traders who intend to sell
```
"""
function run_viewport_rule_switch(; baseline_rule::Int64, switch_rule::Int64, contrarian_rule::Int64, contrarian_fraction::Float64,
        refresh_rate::Float64, L::Int64, f::Float64, h::Float64, seed::Int64, boundary_mode::Symbol, σ_S::Float64, Δt::Float64,
        t_pre::Int64, t_post::Int64, snapshot_steps::Vector{Int64} = [t_pre, t_pre + t_post], kwargs...)

    # check the inputs -
    if baseline_rule < 0 || baseline_rule >= 3^9
        throw(ArgumentError("the baseline rule number must be between 0 and $(3^9 - 1)"));
    end
    if switch_rule < 0 || switch_rule >= 3^9
        throw(ArgumentError("the switch rule number must be between 0 and $(3^9 - 1)"));
    end
    if contrarian_rule < 0 || contrarian_rule >= 3^9
        throw(ArgumentError("the contrarian rule number must be between 0 and $(3^9 - 1)"));
    end
    if contrarian_fraction < 0.0 || contrarian_fraction > 1.0
        throw(ArgumentError("the fraction of contrarian players must be between 0 and 1"));
    end
    if refresh_rate < 0.0 || refresh_rate > 1.0
        throw(ArgumentError("the refresh rate must be between 0 and 1"));
    end
    if σ_S < 0.0
        throw(ArgumentError("the volatility σ_S of the noise must be zero or positive"));
    end
    if Δt <= 0.0
        throw(ArgumentError("the time step Δt must be positive"));
    end

    # initialize: the number of steps, the noise that one step adds to the log share price, and the contrarian rule table -
    WM = VLQuantitativeFinancePackage.WolframMarkets;
    steps = t_pre + t_post;
    step_volatility = σ_S*sqrt(Δt);
    contrarian_table = WM.rule_table(contrarian_rule); # entry c + 1 is the next intention of a contrarian player when its neighbors sum to c

    # choose the starting contrarian players: a random fraction of the interior traders, set by the seed -
    is_contrarian = fill(false, L, L);
    number_of_interior_traders = (L - 2)^2;
    number_of_contrarians = round(Int64, contrarian_fraction*number_of_interior_traders);
    order = randperm(Xoshiro(seed + 40_000), number_of_interior_traders); # the interior traders in a random order
    for k ∈ 1:number_of_contrarians
        index = order[k]; # interior traders are numbered down each column
        row = 2 + (index - 1) % (L - 2);
        column = 2 + (index - 1) ÷ (L - 2);
        is_contrarian[row, column] = true;
    end

    # run the control: its switch step is after the last step, so it never switches -
    control_config = WM.rule_switch_config(L = L, f = f, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
    control_config.rule_major_index = baseline_rule; # the rule before the switch
    control_config.rule_minor_index = switch_rule; # the rule of the switching seats after the switch
    control_market = MyViewportMarket(MyNoisyDealer(Xoshiro(seed + 10_000), step_volatility), Xoshiro(seed + 30_000), refresh_rate,
        contrarian_fraction, contrarian_table, copy(is_contrarian), control_config.initial_cash, control_config.initial_shares);
    control = WM.simulate(control_config; clearing = :reserve, snapshot_steps = snapshot_steps, minority_population = :interior,
        rule_activation_step = steps + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = control_market, verbose = false, kwargs...);

    # run the switched market: the same starting market, noise, and players, with the switch after step t_pre -
    switched_config = WM.rule_switch_config(L = L, f = f, h = h, seed = seed, t_pre = t_pre, t_post = t_post);
    switched_config.rule_major_index = baseline_rule;
    switched_config.rule_minor_index = switch_rule;
    switched_market = MyViewportMarket(MyNoisyDealer(Xoshiro(seed + 10_000), step_volatility), Xoshiro(seed + 30_000), refresh_rate,
        contrarian_fraction, contrarian_table, copy(is_contrarian), switched_config.initial_cash, switched_config.initial_shares);
    switched = WM.simulate(switched_config; clearing = :reserve, snapshot_steps = snapshot_steps, minority_population = :interior,
        rule_activation_step = t_pre + 1, boundary_mode = boundary_mode, activation_action = :rule, fixed_band_step = nothing,
        intervention = nothing, initial_grid = nothing, observer = switched_market, verbose = false, kwargs...);

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
trader switches rules. This market is the control of `run_noisy_rule_switch(...)` with `baseline_rule = rule`
and the same `L`, `h`, `seed`, `boundary_mode`, `σ_S`, and `Δt`.

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
