# Facts for the updating section and the JPM figure, on the practicum's data.
# Usage (from the repo root): julia lectures/instructor/L15a-tools/updating_facts.jl <last day, e.g. 2026-11-30> <output folder>
# Writes jpm_beta.csv (date, updated β) and jpm_fixed.txt (fixed β) into the output folder, for redraw_ewls_jpm.py.
include(joinpath(@__DIR__, "..", "..", "week-15", "L15a", "Include.jl"));
using DelimitedFiles

# the dates: the practicum's fit window, and the run from January 2, 2025, to the last day -
run_stop = Date(ARGS[1]); out = ARGS[2];
train_start = Date(2016, 1, 4); train_stop = Date(2024, 12, 31); run_start = Date(2025, 1, 2);
md = MPC.load_l15a_market(_PATH_TO_DATA; start = train_start, stop = run_stop);
calib = MPC.calibrate(md; train_start = train_start, train_stop = train_stop);
sim = MPC.online_sim(md, calib; start = run_start, stop = run_stop, half_life = 63.0, prior_weight = 63.0);

# the counts in the frozen section: growth rates in the fit (the prior's days) and the day number of the last day -
i0 = findfirst(md.dates .== train_start); i1 = findlast(md.dates .<= train_stop);
println("growth rates in the fit: ", i1 - i0, " (prior sum from k = -", i1 - i0 - 1, " to 0)");
println("run days: ", length(sim.rows), " (day ", length(sim.rows), " is ", md.dates[last(sim.rows)], ")");

# JPM: the fixed estimate and the updated estimate on each run day -
j = findfirst(md.tickers .== "JPM");
β_fixed = calib.base_sim["JPM"].β; β_updated = sim.β[:, j];
println("JPM fixed β ", round(β_fixed, digits = 4), ", last updated β ", round(β_updated[end], digits = 4));
writedlm(joinpath(out, "jpm_beta.csv"), hcat(string.(md.dates[sim.rows]), β_updated), ',');
open(joinpath(out, "jpm_fixed.txt"), "w") do io
    println(io, β_fixed);
end

# the frozen claim: most stocks moved less with the market than their fixed estimates say -
stock = md.sector .!= "ETF";
β_all_fixed = [calib.base_sim[t].β for t ∈ md.tickers]; β_last = sim.β[end, :];
println("stocks with a lower updated β: ", count((β_last .< β_all_fixed) .& stock), " of ", count(stock));
