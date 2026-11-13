# Data for the right panel of Fig-L13a-Episode-Shape (November 12, 2026).
#
# Writes Fig-L13a-Episode-Shape-Data.csv: the one-month rolling standard deviation of the daily
# growth rate g (1/yr) around the start of a volatile period,
#  - for real SPY, starting on 2020-02-20, the first trading day after the February 19, 2020 high;
#  - for the jump episodes of the tuned SPY model that the SPY example saves in
#    data/JumpHMM-SPY-2014-2024.jld2, each episode aligned at its first day: the mean over
#    all episodes, and the first few episodes as examples.
#
# Run from this folder (about a minute):
#   julia --project=../../../.. Fig-L13a-Episode-Shape-Data.jl
include(joinpath(@__DIR__, "..", "Include.jl"))

# settings -
Δt = 1/252; # one trading day, expressed in years
window = 21; # days in the rolling window (one month)
days_before = 30; # days shown before the start
days_after = 200; # days shown after the start
number_of_paths = 2000; # simulated paths, enough for several hundred episodes
random_seed = 5660; # fix the random numbers, so every run gives the same file
number_of_examples = 6; # episodes drawn one by one in the figure (the first ones found)
real_start = Date(2020, 2, 20); # the first trading day after the February 19, 2020 high

"""
    rolling_sd(x::Array{Float64,1}, t::Int, window::Int) -> Float64

Return the standard deviation of `x` over the `window` days that end on day `t`.

### Example
```julia
rolling_sd(g, 100, 21) # standard deviation of g on days 80 to 100
```
"""
function rolling_sd(x::Array{Float64,1}, t::Int, window::Int)::Float64
    return std(x[(t - window + 1):t])
end

# real SPY: the daily growth rate and the date of each growth rate -
spy = MyTrainingMarketDataSet()["dataset"]["SPY"];
prices = Float64.(spy.close); # USD/share
g = JumpHMM.excess_growth_rates(prices; rf = 0.0, dt = Δt); # daily growth rate (1/yr)
dates = spy.timestamp[2:end]; # the date of each growth rate
number_of_days = length(g);

# real SPY: the rolling standard deviation from days_before before the start to days_after after it -
t0 = 0;
for t ∈ 1:number_of_days
    if Date(dates[t]) >= real_start
        global t0 = t;
        break
    end
end
@assert t0 > days_before + window "the real start is too close to the first day"
real_curve = [rolling_sd(g, t0 + k, window) for k ∈ -days_before:days_after];

# simulated: the tuned model saved by the SPY example -
model = load(joinpath(_PATH_TO_DATA, "JumpHMM-SPY-2014-2024.jld2"), "model");
result = JumpHMM.simulate(model, number_of_days; n_paths = number_of_paths, seed = random_seed);

# simulated: the rolling standard deviation around the first day of every episode with room on both sides -
curves = Array{Float64,1}[];
for path ∈ result.paths
    x = path.observations;
    e = path.jumps; # true on the episode days
    for t ∈ 2:number_of_days
        if e[t] == true && e[t - 1] == false && t - days_before - window + 1 >= 1 && t + days_after <= number_of_days
            push!(curves, [rolling_sd(x, t + k, window) for k ∈ -days_before:days_after]);
        end
    end
end
C = hcat(curves...); # offsets × episodes
@assert size(C, 2) >= 100 "too few episodes; raise number_of_paths"

# write: one row per day offset -
io = open(joinpath(@__DIR__, "Fig-L13a-Episode-Shape-Data.csv"), "w");
header = "day,real,sim_mean";
for j ∈ 1:number_of_examples
    global header = header * ",ep$(j)";
end
println(io, header);
offsets = collect(-days_before:days_after);
for i ∈ eachindex(offsets)
    row = C[i, :]; # the simulated episodes at this day offset
    line = string(offsets[i], ",", round(real_curve[i], digits = 3), ",", round(mean(row), digits = 3));
    for j ∈ 1:number_of_examples
        line = line * "," * string(round(C[i, j], digits = 3)); # example episode j
    end
    println(io, line);
end
close(io);

# report: the numbers the figure header and the lecture rely on -
m = vec(mean(C; dims = 2));
println("model ϵ = $(model.jump.ϵ), λ = $(model.jump.λ); episodes: $(size(C, 2)) from $(number_of_paths) paths")
println("real: start $(Date(dates[t0])), peak $(round(maximum(real_curve), digits = 1)) on day $(argmax(real_curve) - days_before - 1), ordinary days (median over 2014-2024) $(round(median([rolling_sd(g, t, window) for t ∈ window:number_of_days]), digits = 1))")
println("simulated mean: peak $(round(maximum(m), digits = 1)), at day 60 $(round(m[days_before + 61], digits = 1)), at day 100 $(round(m[days_before + 101], digits = 1)), at day 150 $(round(m[days_before + 151], digits = 1))")
println("real: at day 60 $(round(real_curve[days_before + 61], digits = 1)), at day 100 $(round(real_curve[days_before + 101], digits = 1))")
