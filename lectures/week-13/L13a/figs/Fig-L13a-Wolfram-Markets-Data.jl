# Reproduce the Wolfram-market review panels with the L12b simulator and helpers.
# From the repository root:
# julia --project=. lectures/week-13/L13a/figs/Fig-L13a-Wolfram-Markets-Data.jl
using VLQuantitativeFinancePackage
using Random, Statistics, JSON
import VLQuantitativeFinancePackage.WolframMarkets as WM
include(joinpath(@__DIR__, "..", "..", "..", "week-12", "L12b", "src", "Helper.jl"))

# Delay the existing viewport observer without duplicating its refresh or rule logic.
# Until start_step is finished, only its dealer noise operates. The R0 population
# starts empty and grows through the continuing stream of new players afterward.
struct DelayedViewport <: WM.AbstractMarketObserver
    viewport::MyViewportMarket
    start_step::Int64
    buyer_counts::Vector{Int64}
end

function WM.market_before_step!(market::DelayedViewport, t, grid, books, price, mu, sigma, dealer)
    observer = t > market.start_step ? market.viewport : market.viewport.noise
    WM.market_before_step!(observer, t, grid, books, price, mu, sigma, dealer)
    return nothing
end

function WM.market_ca_step(market::DelayedViewport, t, grid, world, agents, major)
    return WM.market_ca_step(market.viewport, t, grid, world, agents, major)
end

function WM.market_after_execution!(market::DelayedViewport, t, grid, books, price, counts, dealer)
    market.buyer_counts[t + 1] = count(market.viewport.is_contrarian)
    return nothing
end

function run_delayed_viewport(settings, open_settings, steps)
    config = WM.rule_switch_config(; L = settings.L, f = settings.f, h = settings.h,
        seed = settings.seed, t_pre = settings.t_pre, t_post = settings.t_post)
    config.rule_major_index = settings.baseline_rule
    config.rule_minor_index = settings.switch_rule
    viewport = MyViewportMarket(
        MyNoisyDealer(Xoshiro(settings.seed + 10_000), settings.σ_S*sqrt(settings.Δt)),
        Xoshiro(settings.seed + 30_000), open_settings.refresh_rate,
        open_settings.contrarian_fraction, WM.rule_table(open_settings.contrarian_rule),
        fill(false, settings.L, settings.L), config.initial_cash, config.initial_shares)
    observer = DelayedViewport(viewport, open_settings.start_step,
        zeros(Int64, settings.t_pre + settings.t_post + 1))
    market = WM.simulate(config; clearing = :reserve, snapshot_steps = steps,
        minority_population = :interior, rule_activation_step = settings.t_pre + 1,
        boundary_mode = settings.boundary_mode, activation_action = :rule,
        fixed_band_step = nothing, intervention = nothing, initial_grid = nothing,
        observer = observer, verbose = false)
    return (switched = market, buyer_counts = observer.buyer_counts)
end

function write_review_data()
    # Match the rule-switch example's market, seed, switch, and price noise.
    settings = (baseline_rule = 19280, switch_rule = 19286, L = 64, f = 0.25,
        h = 100.0, seed = 1, boundary_mode = :endogenous, σ_S = 0.40,
        Δt = 1/(252*390), t_pre = 1000, t_post = 3000)
    steps = [1000, 1250, 1500, 1600, 2000, 4000]
    closed = run_noisy_rule_switch(; settings..., snapshot_steps = steps)
    println("Computed R19280 control and closed switch.")
    flush(stdout)

    # Let the Sell majority form before starting continuous refresh after step 1500.
    # Each trader then leaves with probability 0.001 per step; 25% of arrivals use R0.
    open_settings = (refresh_rate = 0.001, contrarian_fraction = 0.25,
        contrarian_rule = 0, start_step = 1500)
    opened = run_delayed_viewport(settings, open_settings, steps)
    println("Computed open switch with refresh and R0 entry after step 1500.")

    markets = [closed.control, closed.switched, opened.switched]
    labels = ["R19280 alone", "Switch, closed market", "Switch, open market with R0 buyers"]
    rows = [Dict("label" => label,
        "panels" => [Dict("step" => t, "price" => market.prices[t + 1],
            "buy_fraction" => market.buy_fraction[t + 1],
            "sell_fraction" => market.sell_fraction[t + 1],
            "r0_fraction" => row_index == 3 ? opened.buyer_counts[t + 1]/(settings.L - 2)^2 : 0.0,
            # Save row-major arrays, dropping the edge as in L12b's plot_grid.
            "grid" => [collect(market.frames[t][r, 2:end-1]) for r in 2:settings.L-1])
            for t in steps]) for (row_index, (label, market)) in enumerate(zip(labels, markets))]

    # Verify the matched histories and the decoded all-buy rule before exporting.
    @assert all(WM.rule_table(0) .== 0)
    @assert closed.switched.prices[1:1002] == closed.control.prices[1:1002]
    @assert opened.switched.prices[1:1501] == closed.switched.prices[1:1501]
    @assert opened.switched.sell_fraction[1:1501] == closed.switched.sell_fraction[1:1501]
    @assert all(opened.switched.frames[t] == closed.switched.frames[t] for t in steps if t <= 1500)
    @assert closed.switched.sell_fraction[1501] > 0.5
    @assert all(opened.buyer_counts[1:1501] .== 0)
    @assert opened.buyer_counts[2001] > 0
    @assert opened.switched.frames[0] == closed.switched.frames[0]
    @assert opened.switched.prices != closed.switched.prices
    @assert all(closed.control.frames[1000] .== closed.switched.frames[1000])
    @assert all(all(z in 0:2 for gridrow in p["grid"] for z in gridrow)
        for row in rows for p in row["panels"])

    output = joinpath(@__DIR__, "Fig-L13a-Wolfram-Markets-Data.json")
    open(output, "w") do io
        JSON.print(io, Dict("settings" => settings, "steps" => steps,
            "open_market" => open_settings,
            "rows" => rows))
    end
    println("Saved ", output)
    for row in rows
        println(row["label"], ": ",
            join(["t=$(p["step"]): S=$(round(p["price"]; digits=2)), Sell=$(round(100*p["sell_fraction"]; digits=1))%, R0=$(round(100*p["r0_fraction"]; digits=1))%" for p in row["panels"]], "; "))
    end
end

write_review_data()
