# Test-Helper.jl: checks the plotting helpers in src/Helper.jl.
# Run from the L12b folder:  julia scripts/Test-Helper.jl
include(joinpath(@__DIR__, "..", "Include.jl"));
using Test
import VLQuantitativeFinancePackage.WolframMarkets as WM

# the cache and the colors the notebook uses -
cache = load(joinpath(_PATH_TO_DATA, "L12b-RuleSwitch-Cache.jld2"));
conditions = [string("h=", c.h, "/", c.boundary_mode) for c ∈ cache["settings"].conditions];
fs = sort(unique([p.f for p ∈ cache["pairs"]]));
colors = [parse(Colorant, "#0072B2"), parse(Colorant, "#AAAAAA"), parse(Colorant, "#D55E00")];
interior(frame) = frame[2:(end - 1), 2:(end - 1)];

@testset "Helper.jl" begin

    # a cached pair: lookup, the pair plot, and the final-frame heatmaps (L = 64) -
    p = pair_for(cache, first(conditions), maximum(fs));
    @test p.f == maximum(fs)
    panels = plot_pair(p.switched, p.control, p.t_pre);
    @test panels isa Tuple && all(x -> x isa Plots.Plot, panels)
    @test plot_final_frames([interior(p.switched.frames.final), interior(p.control.frames.final)], ["switched", "control"];
        colors = colors, layout = (1, 2)) isa Plots.Plot

    # a missing condition is a clear error, not a failure deep in the plotting code -
    @test_throws ArgumentError pair_for(cache, "no-such-condition", 0.25)
    @test_throws ArgumentError pair_for(cache, first(conditions), 0.123)

    # live pairs on a small grid (L = 32) in each edge condition: pair plot and final-frame heatmaps -
    for mode ∈ (:endogenous, :hold, :random)
        live = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = mode, t_pre = 200, t_post = 300);
        @test all(x -> x isa Plots.Plot, plot_pair(live.switched, live.control, live.t_pre))
        final = maximum(keys(live.switched.frames));
        @test plot_final_frames([interior(live.switched.frames[final])], ["switched"]; colors = colors, layout = (1, 1)) isa Plots.Plot
    end
end

@testset "Helper.jl: stylized-facts helpers" begin

    # excess kurtosis: 0 for a symmetric two-point set is -2; a large Normal sample is near 0 -
    @test excess_kurtosis([-1.0, 1.0, -1.0, 1.0]) ≈ -2.0
    @test abs(excess_kurtosis(randn(MersenneTwister(1), 200_000))) < 0.05

    # a baseline market is the control arm of a rule-switch run: same seed, same prices -
    base = run_baseline(L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 500);
    pair = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 1, boundary_mode = :endogenous, t_pre = 400, t_post = 100);
    @test base.prices == pair.control.prices
    @test length(base.prices) == 501
    @test_throws ArgumentError run_baseline(L = 32, h = 100.0, boundary_mode = :endogenous, seed = 1, steps = 0)
end
