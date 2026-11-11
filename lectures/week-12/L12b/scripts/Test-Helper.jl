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
        quiet = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = mode, σ_S = 0.0, Δt = 1/252, t_pre = 200, t_post = 300, snapshot_steps = saved_steps);
        @test quiet.switched.prices == plain.switched.prices
        @test quiet.control.prices == plain.control.prices
        @test quiet.switched.sell_fraction == plain.switched.sell_fraction
        @test quiet.switched.frames[350] == plain.switched.frames[350]
        @test quiet.t_pre == 200
    end

    # with noise, the two markets share their history up to the switch, and the package summary works -
    Δt = 1/(252*390);
    noisy = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 300);
    plain = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, t_pre = 200, t_post = 300);
    @test noisy.control.prices != plain.control.prices
    @test noisy.switched.prices[1:202] == noisy.control.prices[1:202]
    @test length(noisy.switched.prices) == 501
    @test WM.rule_switch_summary(noisy).control_transitioned == false

    # the same inputs give the same run -
    again = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 300);
    @test again.switched.prices == noisy.switched.prices

    # the noise of one step is σ_S√Δt: with large noise, it sets the size of the one-step change in the log price -
    for step ∈ (1/252, 1/(252*390))
        loud = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 5.0, Δt = step, t_pre = 2000, t_post = 10);
        changes = diff(log.(loud.control.prices[200:end]));
        @test isapprox(std(changes), 5.0*sqrt(step); rtol = 0.1)
    end

    # bad inputs -
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = -0.1, Δt = 1/252)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = 0.0)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = -1, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19683, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt)

    # other rules: the control of any pair is the one-rule market of its baseline rule, and a switch to the baseline rule changes nothing -
    other = run_noisy_rule_switch(baseline_rule = 3720, switch_rule = 3882, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 300);
    alone = run_rule_market(rule = 3720, L = 32, h = 100.0, seed = 3, boundary_mode = :endogenous, steps = 500, σ_S = 0.20, Δt = Δt);
    @test other.control.prices == alone.prices
    @test other.switched.sell_fraction != other.control.sell_fraction
    same = run_noisy_rule_switch(baseline_rule = 3720, switch_rule = 3720, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 300);
    @test same.switched.prices == same.control.prices
end

@testset "Helper.jl: fresh players" begin

    # the run with no fresh players -
    Δt = 1/(252*390); # one minute of a 390-minute trading day
    plain = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);

    # a fraction of zero gives the run with no fresh players, whatever the other two settings are -
    none = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600,
        fresh_fraction = 0.0, t_fresh = 500, recovery_rule = 0);
    @test none.switched.prices == plain.switched.prices
    @test none.switched.sell_fraction == plain.switched.sell_fraction
    @test none.control.prices == plain.control.prices

    # fresh players who follow Rule 0 always intend to buy: the history up to step t_fresh is unchanged, and the share price ends higher -
    buyers = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600,
        fresh_fraction = 0.25, t_fresh = 500, recovery_rule = 0);
    @test buyers.switched.prices[1:501] == plain.switched.prices[1:501]
    @test buyers.switched.sell_fraction[1:500] == plain.switched.sell_fraction[1:500]
    @test all(buyers.switched.buy_fraction[501:end] .>= 0.25)
    @test buyers.switched.prices[end] > plain.switched.prices[end]
    @test buyers.control.prices[end] > plain.control.prices[end]

    # fresh players who follow Rule 19682 always intend to sell: the share price ends lower -
    sellers = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600,
        fresh_fraction = 0.25, t_fresh = 500, recovery_rule = 19682);
    @test all(sellers.switched.sell_fraction[501:end] .>= 0.25)
    @test sellers.switched.prices[end] < plain.switched.prices[end]

    # the same settings give the same run -
    again = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600,
        fresh_fraction = 0.25, t_fresh = 500, recovery_rule = 0);
    @test again.switched.prices == buyers.switched.prices

    # bad settings -
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, fresh_fraction = -0.1)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, fresh_fraction = 1.5)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, fresh_fraction = 0.25, t_fresh = -1)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, fresh_fraction = 0.25, t_fresh = 4001)
    @test_throws ArgumentError run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, fresh_fraction = 0.25, recovery_rule = 19683)
end

@testset "Helper.jl: viewport market" begin

    # with no players coming and going and no contrarians, the viewport market is the plain rule-switch market -
    Δt = 1/(252*390); # one minute of a 390-minute trading day
    plain = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);
    closed = run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 0.0, refresh_rate = 0.0,
        L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);
    @test closed.switched.prices == plain.switched.prices
    @test closed.switched.sell_fraction == plain.switched.sell_fraction
    @test closed.control.prices == plain.control.prices

    # players come and go: the switched market and its control share their history up to the switch, and the same settings give the same run -
    open_market = run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 0.25, refresh_rate = 0.01,
        L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);
    again = run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 0.25, refresh_rate = 0.01,
        L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);
    @test open_market.switched.prices[1:201] == open_market.control.prices[1:201]
    @test open_market.switched.prices == again.switched.prices
    @test open_market.switched.prices != plain.switched.prices
    @test length(open_market.switched.prices) == 801

    # when every player is a contrarian, the rule of the seats does not matter: the switch changes nothing -
    all_contrarian = run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 1.0, refresh_rate = 0.01,
        L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);
    @test all_contrarian.switched.prices == all_contrarian.control.prices
    @test all_contrarian.switched.sell_fraction == all_contrarian.control.sell_fraction

    # contrarians who follow Rule 0 always intend to buy -
    buyers = run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 0, contrarian_fraction = 0.25, refresh_rate = 0.0,
        L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :endogenous, σ_S = 0.20, Δt = Δt, t_pre = 200, t_post = 600);
    @test all(buyers.switched.buy_fraction[2:end] .>= 0.25)

    # bad settings -
    @test_throws ArgumentError run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 19683, contrarian_fraction = 0.25, refresh_rate = 0.01, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, t_pre = 20, t_post = 20)
    @test_throws ArgumentError run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 1.5, refresh_rate = 0.01, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, t_pre = 20, t_post = 20)
    @test_throws ArgumentError run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 0.25, refresh_rate = -0.01, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = 0.2, Δt = Δt, t_pre = 20, t_post = 20)
    @test_throws ArgumentError run_viewport_rule_switch(baseline_rule = 19280, switch_rule = 19286, contrarian_rule = 377, contrarian_fraction = 0.25, refresh_rate = 0.01, L = 32, f = 0.25, h = 100.0, seed = 3, boundary_mode = :hold, σ_S = -0.2, Δt = Δt, t_pre = 20, t_post = 20)
end

@testset "Helper.jl: one-rule market" begin

    # Rule 19280 is the control of the rule-switch run with the same settings -
    Δt = 1/(252*390);
    for mode ∈ (:endogenous, :hold)
        market = run_rule_market(rule = 19280, L = 32, h = 100.0, seed = 2, boundary_mode = mode, steps = 400, σ_S = 0.20, Δt = Δt);
        pair = run_noisy_rule_switch(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, h = 100.0, seed = 2, boundary_mode = mode, σ_S = 0.20, Δt = Δt, t_pre = 300, t_post = 100);
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
    base = run_baseline(rule = 19280, L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 500);
    pair = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = :endogenous, t_pre = 400, t_post = 100);
    @test base.prices == pair.control.prices
    @test base.sell_fraction == pair.control.sell_fraction
    @test length(base.prices) == 501
    for mode ∈ (:hold, :random)
        kw = mode == :random ? (random_edge_probabilities = (0.2, 0.5, 0.3),) : NamedTuple();
        b2 = run_baseline(; rule = 19280, L = 32, h = 1.0, boundary_mode = mode, seed = 2, steps = 300, kw...);
        p2 = WM.run_rule_switch(; L = 32, f = 0.25, h = 1.0, seed = 2, boundary_mode = mode, t_pre = 200, t_post = 100, kw...);
        @test b2.prices == p2.control.prices
        @test b2.sell_fraction == p2.control.sell_fraction
    end
    @test_throws ArgumentError run_baseline(rule = 19280, L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 0)
    @test_throws ArgumentError run_baseline(rule = 19683, L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 500)

    # with no noise, a baseline market of any rule is the one-rule market of that rule -
    b3 = run_baseline(rule = 3720, L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 300);
    m3 = run_rule_market(rule = 3720, L = 32, h = 100.0, seed = 1, boundary_mode = :endogenous, steps = 300, σ_S = 0.0, Δt = 1/252);
    @test b3.prices == m3.prices
end
