"""
    pass_rate(model::JumpHMM.MyJumpHiddenMarkovModel, growth_rates::Array{Float64,1};
        number_of_paths::Int64, α::Float64, seed::Int64) -> Float64

Score one trading day against the model. We simulate `number_of_paths` paths from the model, each as long as the
day, and compare each path with the real growth rates of the day by the two-sample Kolmogorov–Smirnov test. A path
passes when its p-value is above the significance level `α`. The pass rate is the share of paths that pass.

### Arguments
- `model::JumpHMM.MyJumpHiddenMarkovModel`: the fitted hidden Markov model that we score.
- `growth_rates::Array{Float64,1}`: the one-minute growth rates of one trading day (units: 1/yr).

### Optional Arguments
- `number_of_paths::Int64`: the number of simulated days we compare with the real day. Must be at least 1.
- `α::Float64`: the significance level of the test, between 0 and 1.
- `seed::Int64`: the seed of the random numbers, so the same day gets the same simulated paths in every run.

### Returns
- `Float64`: the share of the simulated paths that pass the test, between 0 and 1.

### Example
```julia
rate = pass_rate(model, growth_rates[1]; number_of_paths = 200, α = 0.05, seed = 5660); # the first trading day
```
"""
function pass_rate(model::JumpHMM.MyJumpHiddenMarkovModel, growth_rates::Array{Float64,1};
    number_of_paths::Int64, α::Float64, seed::Int64)::Float64

    # simulate: number_of_paths paths, each as long as the day -
    number_of_minutes = length(growth_rates); # number of growth rates in the day
    result = JumpHMM.simulate(model, number_of_minutes;
        number_of_paths = number_of_paths, # number of simulated days
        seed = seed # reproduce the simulated days
    );

    # count the paths that pass the Kolmogorov–Smirnov test against the real day -
    number_passed = 0;
    for j ∈ 1:number_of_paths
        path = result.growth_rates[:, j]; # growth rates of simulated day j (1/yr)
        p = pvalue(ApproximateTwoSampleKSTest(growth_rates, path));
        if (p > α)
            number_passed += 1; # this path passes: the test finds no difference at the level α
        end
    end
    rate = number_passed / number_of_paths;

    # checks: the pass rate is a share -
    @assert 0.0 <= rate <= 1.0 "the pass rate must be between 0 and 1"

    # return -
    return rate;
end

"""
    growth_rate_density(growth_rates::Array{Float64,1}, edges::AbstractRange{Float64}) -> Array{Float64,1}

Estimate the probability density of the growth rate from a histogram. We count the growth rates in each bin between
two neighboring `edges`, and divide each count by the number of growth rates times the bin width. Growth rates
outside the first and last edge count toward the total but fall in no bin.

### Arguments
- `growth_rates::Array{Float64,1}`: the growth rates, for example one simulated path of minutes (units: 1/yr).
- `edges::AbstractRange{Float64}`: the evenly spaced bin edges, from the lowest to the highest (units: 1/yr).

### Returns
- `Array{Float64,1}`: the probability density in each bin, one entry per bin (units: yr).

### Example
```julia
edges = -202.5:5.0:202.5; # bins of width 5 (1/yr), one centered on zero
density = growth_rate_density(g_fit, edges); # 81 bins
```
"""
function growth_rate_density(growth_rates::Array{Float64,1}, edges::AbstractRange{Float64})::Array{Float64,1}

    # initialize: one count per bin -
    number_of_bins = length(edges) - 1; # bins between neighboring edges
    width = step(edges); # bin width (1/yr)
    counts = zeros(Float64, number_of_bins);

    # count the growth rates in each bin -
    for g ∈ growth_rates
        k = floor(Int64, (g - first(edges)) / width) + 1; # the bin that holds g
        if (1 <= k <= number_of_bins)
            counts[k] += 1;
        end
    end

    # the density: the share of growth rates in each bin, divided by the bin width -
    density = counts ./ (length(growth_rates) * width);

    # checks: the densities are not negative, and their total area is at most one -
    @assert all(density .>= 0.0) "densities must not be negative"
    @assert sum(density) * width <= 1.0 + 1e-12 "the area under the density cannot exceed one"

    # return -
    return density;
end
