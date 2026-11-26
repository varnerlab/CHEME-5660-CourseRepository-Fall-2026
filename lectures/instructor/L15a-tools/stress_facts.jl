include(joinpath(ARGS[1], "lectures", "week-15", "L15a", "Include.jl"))
saved = JLD2.load(joinpath(_PATH_TO_DATA, "L15a-Strategies-Synthetic.jld2"))
println("keys: ", keys(saved))
runs = saved["summary"]; dates = saved["dates"]; spy = Float64.(saved["spy"]); tlt = Float64.(saved["tlt"]); bands = saved["bands"]
println("rows ", nrow(runs), " cols ", names(runs))
println("dates ", dates[1], " .. ", dates[end], " n ", length(dates), "  spy size ", size(spy))
W0 = 100000.0
# the 60/40 terminal on each market
c6040 = zeros(200)
for p in 1:200
    c6040[p] = sixty_forty_wealth(spy[2:end, p], tlt[2:end, p], dates[2:end]; W0=W0, half_spread=0.0005)[end]
end
spyT = W0 .* spy[end, :] ./ spy[1, :]
println("60/40 terminal median ", median(c6040), "  SPY terminal median ", median(spyT), " SPY 5/95 ", quantile(spyT, [0.05, 0.95]))
println("SPY failure rate ", mean(spyT .< W0), "  60/40 failure ", mean(c6040 .< W0))

function pick(runs, pk, wt, h, e, s)
    r = runs[(runs.picking .== pk) .& (runs.weighting .== wt) .& (runs.hedge .== h) .& (runs.estimates .== e) .& (runs.seed .== s), :]
    sort(r, :path_id)
end
off = pick(runs, "gamma by sector", "Cobb-Douglas", false, "fixed", 5660)
on = pick(runs, "gamma by sector", "Cobb-Douglas", true, "fixed", 5660)
println("fund A rows: off ", nrow(off), " on ", nrow(on))
g_off = five_gates(off, c6040[off.path_id]; W0=W0, sharpe_limit=0.3, drawdown_limit=0.25, failure_limit=0.10)
g_on = five_gates(on, c6040[on.path_id]; W0=W0, sharpe_limit=0.3, drawdown_limit=0.25, failure_limit=0.10)
println(g_off); println(g_on)
b = Float64.(bands["gamma by sector | Cobb-Douglas | hedge off | fixed"])
bo = Float64.(bands["gamma by sector | Cobb-Douglas | hedge on | fixed"])
println("band off last day: ", b[end, :])
println("band on last day: ", bo[end, :])
sb = [quantile(W0 .* spy[end, :] ./ spy[1, :], q) for q in [0.05, 0.25, 0.5, 0.75, 0.95]]
println("SPY band last day: ", sb)
# smallest 5th percentile across days
println("off: min of 5th pct ", minimum(b[:, 1]), " on day ", argmin(b[:, 1]), "; on: ", minimum(bo[:, 1]))
println("hedge on ended higher on ", count(on.terminal .> off.terminal), " of 200 markets")
println("failures off ", count(off.terminal .< W0), "  on ", count(on.terminal .< W0))
println("off terminal extrema ", extrema(off.terminal), " on ", extrema(on.terminal))
println("cor(off terminal, SPY terminal) ", cor(off.terminal, spyT[off.path_id]), "  on ", cor(on.terminal, spyT[on.path_id]))
println("off beats 60/40 on ", count(off.terminal .> c6040[off.path_id]), " markets; on ", count(on.terminal .> c6040[on.path_id]))
# the worst 10% of SPY markets: how did each do
worst = sortperm(spyT)[1:20]
println("worst 20 SPY markets: SPY median ", median(spyT[worst]), " off median ", median(off.terminal[worst]), " on median ", median(on.terminal[worst]))
best = sortperm(spyT)[181:200]
println("best 20 SPY markets: SPY median ", median(spyT[best]), " off median ", median(off.terminal[best]), " on median ", median(on.terminal[best]))
println("median decisions off ", median(off.n_decisions), " on ", median(on.n_decisions))

# the whole menu: how many combinations pass all five gates
combos = unique(runs[:, [:picking, :weighting, :hedge, :estimates, :seed]])
println("combinations ", nrow(combos))
passed = Bool[]; failed_gates = String[]
for c in eachrow(combos)
    r = pick(runs, c.picking, c.weighting, c.hedge, c.estimates, c.seed)
    if c.estimates == "fixed"
        comp = c6040[r.path_id]
    else
        q = pick(runs, c.picking, c.weighting, c.hedge, "fixed", c.seed)
        comp = q.terminal
    end
    g = five_gates(r, comp; W0=W0, sharpe_limit=0.3, drawdown_limit=0.25, failure_limit=0.10)
    push!(passed, all(g.passed))
    push!(failed_gates, join(g.gate[.!g.passed], "; "))
end
combos.passed = passed; combos.failed = failed_gates
println("pass all five: ", count(passed), " of ", nrow(combos))
println(combine(groupby(combos, [:hedge, :estimates]), :passed => sum, nrow))
println(combine(groupby(combos, :weighting), :passed => sum, nrow))
println(combine(groupby(combos, :picking), :passed => sum, nrow))
fails = combine(groupby(combos, :failed), nrow)
sort!(fails, :nrow, rev=true); println(first(fails, 15))
println("--- each gate over the menu")
for gname in ["median Sharpe ratio", "median largest drawdown", "failure rate", "median wealth on the last day (USD)", "median NPV (USD)"]
    println(rpad(gname, 40), " fail ", count(occursin.(gname, combos.failed)))
end
println("fail only the failure rate: ", count(combos.failed .== "failure rate"))
println("SPY below W0 on ", count(spyT .< W0), " markets; 60/40 below W0 on ", count(c6040 .< W0))
println(combos[combos.passed, [:picking, :weighting, :hedge, :estimates]])
println("by estimates, fixed vs updated failing gate 4: ", count(occursin.("median wealth", combos.failed[combos.estimates .== "updated"])), " of 378 updated; fixed ", count(occursin.("median wealth", combos.failed[combos.estimates .== "fixed"])))
