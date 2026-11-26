# Cross-check the L15a 60/40 helper with the practicum's view_benchmarks on stress paths 1 and 2.
using CodecZlib
include(joinpath(ARGS[1], "lectures/week-15/L15a/scripts/setup.jl"))
include(joinpath(ARGS[1], "lectures/week-15/L15a/scripts/synthetic.jl"))
include(joinpath(ARGS[1], "lectures/week-15/L15a/src/Helper.jl"))
md = l15a_market()
generator = load_generator(_GENERATOR_FILE)
sessions = nyse_sessions_after(md.dates[end], _SYNTHETIC_DAYS)
columns = generator_columns(generator, md)
volume = training_volume(md)
j_tlt = findfirst(==("TLT"), md.tickers)
practicum = Dict(1 => 95405.54947344837, 2 => 127247.86495917269)
for p in (1, 2)
    G = synthetic_growth(generator, _SYNTHETIC_DAYS, 5660 + p)
    smd = synthetic_market(md, G, columns, sessions, volume)
    spy = smd.spy_close[(end - _SYNTHETIC_DAYS + 1):end]
    tlt = smd.close[(end - _SYNTHETIC_DAYS + 1):end, j_tlt]
    W64 = sixty_forty_wealth(spy, tlt, sessions; W0 = 100000.0, half_spread = 0.0005)
    W32 = sixty_forty_wealth(Float64.(Float32.(spy)), Float64.(Float32.(tlt)), sessions; W0 = 100000.0, half_spread = 0.0005)
    println("path $p: SPY $(spy[1]) → $(spy[end]), TLT $(tlt[1]) → $(tlt[end])")
    println("   60/40 Float64 $(W64[end]), Float32 closes $(W32[end]), practicum $(practicum[p]); diff $(W64[end] - practicum[p]), $(W32[end] - practicum[p])")
end
