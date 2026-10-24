#!/usr/bin/env julia

# Rebuild Fig-L10a-Premium-vs-Moneyness, the L10a lecture figure that opens the intrinsic
# and extrinsic value section.
# Left: an American call. Right: an American put. Each panel plots the premium against
# the moneyness S/K for five days to expiration (DTE), with the intrinsic value as a red
# dashed line. Points a (at the money), b (in the money), and c (out of the money) are
# marked on every DTE curve, so the gap above the intrinsic value can be read at each.
# The contracts are hypothetical (no course data): K = 100 USD/share, σ = 0.30,
# g_y = 0.04, priced on CRR trees with h = 501 steps.
# Self-contained: the CRR pricing is below, so the figure needs only Plots and Colors.
# Run from anywhere: julia generate-premium-vs-moneyness.jl

using Pkg

const REPO_ROOT = normpath(joinpath(@__DIR__, "../../../.."))
Pkg.activate(REPO_ROOT)

using Plots
using Colors

"""
    payoff(type::Symbol, S::Float64, K::Float64) -> Float64

Payoff of exercising a call (`type = :call`) or a put (`type = :put`) with strike price
`K` (USD/share) when the share price is `S` (USD/share). This is the intrinsic value.

### Example
```julia
payoff(:call, 115.0, 100.0) # 15.0 USD/share
```
"""
function payoff(type::Symbol, S::Float64, K::Float64)::Float64
    if type == :call
        return max(S - K, 0.0); # (USD/share)
    else
        return max(K - S, 0.0); # (USD/share)
    end
end

"""
    crr_premium(type::Symbol, S::Float64, K::Float64, T::Float64, σ::Float64, g::Float64, h::Int64) -> Float64

Premium (USD/share) of an American call (`type = :call`) or put (`type = :put`) with
strike price `K` (USD/share), when today's share price is `S` (USD/share), priced on a
CRR tree with `h` steps. `T` is the time to expiration (years), `σ` the volatility
(1/sqrt(yr)), and `g` the risk-free rate (1/yr). Working backward from expiration, each
node takes the larger of exercising now and holding for the future.

### Example
```julia
crr_premium(:put, 100.0, 100.0, 30/365, 0.30, 0.04, 501) # about 3.29 USD/share
```
"""
function crr_premium(type::Symbol, S::Float64, K::Float64, T::Float64, σ::Float64, g::Float64, h::Int64)::Float64

    # tree factors -
    Δt = T/h; # time step (years)
    u = exp(σ*sqrt(Δt)); # up factor
    d = 1/u; # down factor
    q = (exp(g*Δt) - d)/(u - d); # risk-neutral up probability
    discount = exp(-g*Δt); # one-step discount factor

    # at expiration, each node's value is the payoff. Node k has k up moves -
    V = zeros(h + 1); # V[k + 1] is the value at node k (USD/share)
    for k ∈ 0:h
        V[k + 1] = payoff(type, S*u^k*d^(h - k), K);
    end

    # work backward: exercise now, or hold for the future -
    for t ∈ (h - 1):-1:0
        for k ∈ 0:t
            hold = discount*(q*V[k + 2] + (1 - q)*V[k + 1]); # value of holding (USD/share)
            exercise = payoff(type, S*u^k*d^(t - k), K); # value of exercising now (USD/share)
            V[k + 1] = max(exercise, hold);
        end
    end

    return V[1]; # the value at the root is the premium (USD/share)
end

# contracts and trees -
K = 100.0; # strike price (USD/share)
σ = 0.30; # volatility (1/sqrt(yr))
g = 0.04; # risk-free rate (1/yr)
h = 501; # number of tree steps
DTE = [7, 30, 90, 180, 365]; # days to expiration (days)
S_range = collect(range(50.0, 150.0, length = 401)); # share prices today (USD/share)

# points a (at the money), b (in the money), c (out of the money), as moneyness S/K -
points = Dict(
    :call => [("a", 1.00), ("b", 1.15), ("c", 0.85)],
    :put => [("a", 1.00), ("b", 0.85), ("c", 1.15)],
);

# shades of gray: the shortest DTE is darkest, as in the earlier figure -
shades = [RGB(v, v, v) for v ∈ range(0.2, 0.8, length = length(DTE))];

# shared style -
style = (bg = "gray95", background_color_outside = "white", framestyle = :box, fg_legend = :transparent,
    xminorticks = true, yminorticks = true, grid = :both, gridstyle = :dash, titlefontsize = 15,
    guidefontsize = 14, tickfontsize = 12, legendfontsize = 12, xlims = (0.5, 1.5), ylims = (0.0, 60.0),
    xlabel = "Moneyness S/K", ylabel = "Premium (USD/share)");

function panel(type::Symbol, title::String, legend_position::Symbol)
    p = plot(; style..., title = title, legend = legend_position);

    # premium for each DTE -
    for i ∈ eachindex(DTE)
        T = DTE[i]/365; # time to expiration (years)
        P = [crr_premium(type, S, K, T, σ, g, h) for S ∈ S_range];
        plot!(p, S_range ./ K, P, c = shades[i], lw = 2, label = "DTE = $(DTE[i]) days");
    end

    # intrinsic value -
    intrinsic = [payoff(type, S, K) for S ∈ S_range];
    plot!(p, S_range ./ K, intrinsic, c = :red, lw = 2, ls = :dash, label = "Intrinsic value");

    # points a, b, c on every DTE curve, with the letter above the longest-dated one -
    for (letter, m) ∈ points[type]
        P = [crr_premium(type, m*K, K, days/365, σ, g, h) for days ∈ DTE];
        scatter!(p, fill(m, length(DTE)), P, c = shades, msc = :black, msw = 0.75, ms = 4, label = "");
        annotate!(p, m, maximum(P) + 3.5, text(letter, 18, :black, :center));
    end
    return p
end

pc = panel(:call, "American call, K = $(Int(K)) USD/share", :topleft);
pp = panel(:put, "American put, K = $(Int(K)) USD/share", :topright);

fig = plot(pc, pp, layout = (1, 2), size = (1200, 480), left_margin = 6Plots.mm, right_margin = 4Plots.mm,
    bottom_margin = 6Plots.mm);
for ext ∈ ("svg", "pdf")
    savefig(fig, joinpath(@__DIR__, "Fig-L10a-Premium-vs-Moneyness.$(ext)"));
end

# the values at the points, for the lecture text -
for type ∈ (:call, :put)
    for (letter, m) ∈ points[type]
        S = m*K; # share price at the point (USD/share)
        P = [crr_premium(type, S, K, days/365, σ, g, h) for days ∈ DTE];
        println(type, " ", letter, " (S/K = ", m, "): intrinsic = ", payoff(type, S, K), ", premium = ",
            round.(P, digits = 2), ", extrinsic = ", round.(P .- payoff(type, S, K), digits = 2));
    end
end
