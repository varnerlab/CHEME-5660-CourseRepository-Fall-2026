# Test-Helper.jl: checks the helpers in src/Helper.jl.
# Run from the L12b folder:  julia scripts/Test-Helper.jl
include(joinpath(@__DIR__, "..", "Include.jl"));
using Test
import VLQuantitativeFinancePackage.WolframMarkets as WM

# the colors the notebook uses for Buy, Hold, and Sell -
colors = [parse(Colorant, "#0072B2"), parse(Colorant, "#AAAAAA"), parse(Colorant, "#D55E00")];

@testset "Helper.jl: grid plot" begin

    # live pairs on a small grid (L = 32) in each edge condition: the grid plot at a saved step -
    saved_steps = collect(0:5:500);
    for mode ∈ (:endogenous, :hold, :random)
        live = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = mode, t_pre = 200, t_post = 300, snapshot_steps = saved_steps);
        @test plot_grid(live.switched.frames[250]; colors = colors, title_text = "step 250") isa Plots.Plot
        @test plot_grid(live.control.frames[500]; colors = colors) isa Plots.Plot
    end
end

@testset "Helper.jl: noisy dealer" begin

    # with no noise, the run is the package's rule-switch run -
    saved_steps = [200, 350, 500];
    for mode ∈ (:endogenous, :hold)
        plain = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = mode, t_pre = 200, t_post = 300, snapshot_steps = saved_steps);
        quiet = run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = mode, σ_S = 0.0, Δt = 1/252, t_pre = 200, t_post = 300, snapshot_steps = saved_steps);
        @test quiet.switched.prices == plain.switched.prices
        @test quiet.control.prices == plain.control.prices
        @test quiet.switched.sell_fraction == plain.switched.sell_fraction
        @test quiet.switched.frames[350] == plain.switched.frames[350]
        @test quiet.t_pre == 200
    end

    # with noise, the two markets share their history up to the switch, and the package summary works -
    Δt = 1/(252*390);
    noisy = run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 300);
    plain = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, t_pre = 200, t_post = 300);
    @test noisy.control.prices != plain.control.prices
    @test noisy.switched.prices[1:202] == noisy.control.prices[1:202]
    @test length(noisy.switched.prices) == 501
    @test WM.rule_switch_summary(noisy).control_transitioned == false

    # the same inputs give the same run -
    again = run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 300);
    @test again.switched.prices == noisy.switched.prices

    # the noise of one step is σ_S√Δt: with large noise, it sets the size of the one-step change in the log price -
    for step ∈ (1/252, 1/(252*390))
        loud = run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 5.0, Δt = step, t_pre = 2000, t_post = 10);
        changes = diff(log.(loud.control.prices[200:end]));
        @test isapprox(std(changes), 5.0*sqrt(step); rtol = 0.1)
    end

    # bad inputs -
    @test_throws ArgumentError run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = -0.1, Δt = 1/252)
    @test_throws ArgumentError run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = 0.0)
end

@testset "Helper.jl: one-rule market" begin

    # Rule 19280 is the control of the rule-switch run with the same settings -
    Δt = 1/(252*390);
    for mode ∈ (:endogenous, :hold)
        market = run_rule_market(rule = 19280, L = 32, h = 100.0, seed = 2, boundary_mode = mode, steps = 400, σ_S = 0.20, Δt = Δt);
        pair = run_noisy_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 2, boundary_mode = mode, σ_S = 0.20, Δt = Δt, t_pre = 300, t_post = 100);
        @test market.prices == pair.control.prices
        @test market.sell_fraction == pair.control.sell_fraction
    end

    # the rules with one intention in every entry: all Buy, all Hold, all Sell -
    all_buy = run_rule_market(rule = 0, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 50, σ_S = 0.0, Δt = Δt, snapshot_steps = [0, 1, 50]);
    all_hold = run_rule_market(rule = 9841, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 50, σ_S = 0.0, Δt = Δt);
    all_sell = run_rule_market(rule = 19682, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 50, σ_S = 0.0, Δt = Δt);
    @test all_buy.buy_fraction[2] == 1.0
    @test all_hold.hold_fraction[2] == 1.0
    @test all_sell.sell_fraction[2] == 1.0
    @test all(all_buy.frames[1][2:(end - 1), 2:(end - 1)] .== 0)
    @test all_buy.prices[end] > 100.0 > all_sell.prices[end]
    @test all(all_hold.prices[3:end] .== all_hold.prices[3])
    @test length(all_buy.prices) == 51 && length(all_buy.buy_fraction) == 51
    @test all_buy.buy_fraction[1] ≈ 0.05 atol = 0.01

    # a rule sets the next intention: Rule 4920 has Buy at every even sum, so four Hold neighbors (sum 4) give Buy -
    @test WM.rule_table(4920)[4 + 1] == 0
    first_step = run_rule_market(rule = 4920, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 2, σ_S = 0.0, Δt = Δt, snapshot_steps = [0, 1]);
    @test first_step.buy_fraction[2] > 0.5

    # bad inputs -
    @test_throws ArgumentError run_rule_market(rule = -1, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 50, σ_S = 0.0, Δt = Δt)
    @test_throws ArgumentError run_rule_market(rule = 19683, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 50, σ_S = 0.0, Δt = Δt)
    @test_throws ArgumentError run_rule_market(rule = 19280, L = 32, h = 100.0, seed = 1, boundary_mode = :hold, steps = 1, σ_S = 0.0, Δt = Δt)

    # the rule plot -
    @test plot_rule(WM.rule_table(19280); colors = colors, names = ["Buy", "Hold", "Sell"], title_text = "Rule 19280") isa Plots.Plot
    @test_throws ArgumentError plot_rule([0, 1, 2]; colors = colors, names = ["Buy", "Hold", "Sell"])
end

@testset "Helper.jl: stylized-facts helpers" begin

    # excess kurtosis: a symmetric two-point set gives -2, and a large Normal sample gives about 0 -
    @test excess_kurtosis([-1.0, 1.0, -1.0, 1.0]) ≈ -2.0
    @test abs(excess_kurtosis(randn(MersenneTwister(1), 200_000))) < 0.05

    # a baseline market is the control arm of a rule-switch run: same seed, same prices -
    base = run_baseline(L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 500);
    pair = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = :endogenous, t_pre = 400, t_post = 100);
    @test base.prices == pair.control.prices
    @test base.sell_fraction == pair.control.sell_fraction
    @test length(base.prices) == 501
    for mode ∈ (:hold, :random)
        kw = mode == :random ? (random_edge_probabilities = (0.2, 0.5, 0.3),) : NamedTuple();
        b2 = run_baseline(; L = 32, h = 1.0, boundary_mode = mode, seed = 2, steps = 300, kw...);
        p2 = WM.run_rule_switch(; L = 32, f = 0.25, h = 1.0, seed = 2, boundary_mode = mode, t_pre = 200, t_post = 100, kw...);
        @test b2.prices == p2.control.prices
        @test b2.sell_fraction == p2.control.sell_fraction
    end
    @test_throws ArgumentError run_baseline(L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 0)
end
