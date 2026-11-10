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
