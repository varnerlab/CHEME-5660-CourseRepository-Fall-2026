# L15a: check the eight picking files against the engine's built-in screens. Instructor only.
#
# Run from the repository root (a few minutes):
#
#   julia --project=. lectures/week-15/L15a/scripts/check_picking_files.jl
#
# On every day of the real backtest (2025-01-02 to 2026-11-24, updated estimates), each picking file must pick the
# same basket as the engine's built-in screen with the same settings. The random rules are checked with two seeds,
# and the hand-picked rule with both lists.

include(joinpath(@__DIR__, "setup.jl"))
using Test

md = l15a_market()
calib = l15a_calibration(md)
settings = l15a_settings(; hedge=true, estimates="updated")
ctx = MPC.build_context(md, calib, settings)
K = settings.basket_K
lists = MPC.load_study(MPC.default_study_path()).grid.fixed_lists

# each entry: a name, the file's screen, the built-in screen, the settings of the built-in screen, and a seed -
cases = NamedTuple[]
push!(cases, (name="gamma by sector", file=MyL15aGammaSectorScreen(), built_in=:gamma, settings=settings, seed=1))
push!(cases, (name="global gamma", file=MyL15aGlobalGammaScreen(K), built_in=:global_gamma, settings=settings, seed=1))
push!(cases, (name="correlation gamma", file=MyL15aCorrelationGammaScreen(K, settings.corr_max, settings.corr_window),
    built_in=:corr_gamma, settings=settings, seed=1))
push!(cases, (name="liquid gamma", file=MyL15aLiquidGammaScreen(K, settings.liquidity_shortlist,
    settings.liquidity_window), built_in=:liquid_gamma, settings=settings, seed=1))
for seed in (1, 7)
    push!(cases, (name="random by sector", file=MyL15aRandomSectorScreen(), built_in=:random, settings=settings,
        seed=seed))
    push!(cases, (name="random liquid", file=MyL15aRandomLiquidScreen(K, settings.liquidity_shortlist,
        settings.liquidity_window), built_in=:random_liquid, settings=settings, seed=seed))
    push!(cases, (name="random global", file=MyL15aRandomGlobalScreen(K), built_in=:random_global, settings=settings,
        seed=seed))
end
for (list_name, tickers) in lists
    list_settings = MPC.with_settings(settings; fixed_tickers=tickers, basket_K=length(tickers))
    push!(cases, (name="hand-picked " * list_name, file=MyL15aHandPickedScreen(tickers), built_in=:fixed,
        settings=list_settings, seed=1))
end

@testset "the picking files match the built-in screens on every backtest day" begin
    comparisons = 0
    for case in cases
        built_in = MPC.make_screen(case.built_in, case.settings)
        mismatches = 0
        for s in eachindex(ctx.rows)
            t = ctx.rows[s]
            γ_t = ctx.γ[s, :]
            from_file = MPC.pick(case.file, md, t; X=ctx.X, γ_t=γ_t, N=settings.N_per_sector, seed=case.seed)
            from_engine = MPC.pick(built_in, md, t; X=ctx.X, γ_t=γ_t, N=settings.N_per_sector, seed=case.seed)
            if sort(from_file) != sort(from_engine)
                mismatches = mismatches + 1
            end
            comparisons = comparisons + 1
        end
        println(rpad(case.name, 22), " seed ", case.seed, ": ", length(ctx.rows) - mismatches, " of ",
            length(ctx.rows), " days match")
        @test mismatches == 0
    end
    println("comparisons: ", comparisons)
end
