#!/usr/bin/env julia

# Rebuild Fig-L10a-CRR-vs-LR-Delta, the L10a Leisen–Reimer advanced notebook figure that shows why Greeks
# computed by repricing the CRR tree jump, and why the Leisen–Reimer tree's do not.
# Top: the call premium against today's share price. The CRR premium is made of
# straight pieces joined at corners; the Leisen–Reimer premium is smooth.
# Bottom: Delta, the slope of the top curve. Straight pieces give flat steps.
# The contract is hypothetical (no course data): a call with K = 100 USD/share,
# σ = 0.30, T = 0.25 years, g_y = 0.04, on trees with h = 9 steps.

using Pkg

const REPO_ROOT = normpath(joinpath(@__DIR__, "../../../.."))
Pkg.activate(REPO_ROOT)

using VLQuantitativeFinancePackage
using Plots

# contract and tree -
K = 100.0; # strike price (USD/share)
σ = 0.30; # volatility (1/sqrt(yr))
T = 0.25; # time to expiration (years)
g = 0.04; # risk-free rate (1/yr)
h = 9; # number of tree steps (odd, as Leisen–Reimer needs); few steps make the corners visible
Δt = T/h; # time step (years)
S_range = collect(range(90.0, 110.0, length = 1601)); # share prices today, zoomed to two corners (USD/share)
call = build(MyAmericanCallContractModel, (K = K, IV = σ, DTE = T, sense = 1, copy = 1));
premium(method, S) = binomial_premium(call; method = method, h = h, T = T, σ = σ, Sₒ = S, μ = g);

# CRR corners: the share prices today at which a terminal node S₀ u^k d^(h-k) crosses the strike -
u = exp(σ*sqrt(Δt));
d = 1/u;
corners = [K/(u^k*d^(h - k)) for k ∈ 0:h];
corners = sort(filter(S -> first(S_range) < S < last(S_range), corners));

# premium and Delta (slope of the premium, from a tiny central difference) on each tree -
ϵ = 1e-6; # relative step, far smaller than the spacing between corners
P_crr = [premium(:crr, S) for S ∈ S_range];
P_lr = [premium(:leisen_reimer, S) for S ∈ S_range];
Δ_crr = [(premium(:crr, S*(1 + ϵ)) - premium(:crr, S*(1 - ϵ)))/(2*ϵ*S) for S ∈ S_range];
Δ_lr = [(premium(:leisen_reimer, S*(1 + ϵ)) - premium(:leisen_reimer, S*(1 - ϵ)))/(2*ϵ*S) for S ∈ S_range];

# a central difference whose three points sit on one straight CRR piece -
S_mid = (corners[1] + corners[2])/2; # middle of the straight piece between the two corners (USD/share)
ϵ_demo = 0.3*(corners[2] - corners[1]); # step that stays inside the piece (USD/share)
S_demo = [S_mid - ϵ_demo, S_mid, S_mid + ϵ_demo];

# that piece, extended as a straight line past both corners -
slope = (premium(:crr, S_demo[3]) - premium(:crr, S_demo[1]))/(S_demo[3] - S_demo[1]);
line = premium(:crr, S_mid) .+ slope .* (S_range .- S_mid);

# shared style -
style = (bg = "gray95", background_color_outside = "white", framestyle = :box, fg_legend = :transparent,
    xminorticks = true, yminorticks = true, titlefontsize = 12, guidefontsize = 11, tickfontsize = 9,
    legendfontsize = 9, xlims = (first(S_range), last(S_range)));

# top: premium -
pa = plot(; style..., legend = :topleft, title = "Premium of a call with K = $(Int(K)) USD/share ($(h) tree steps)",
    ylabel = "Premium (USD/share)");
vline!(pa, corners, c = :gray50, lw = 1, ls = :dot, label = "");
plot!(pa, S_range, P_lr, c = :red, lw = 3, label = "Leisen–Reimer tree: a smooth curve");
plot!(pa, S_range, P_crr, c = :navy, lw = 3, label = "CRR tree: straight pieces joined at corners");
plot!(pa, S_range, line, c = :navy, lw = 1.5, ls = :dash, label = "one CRR piece, extended");
scatter!(pa, corners, [premium(:crr, S) for S ∈ corners], c = :orange, ms = 7, msw = 0,
    label = "corner: a terminal node crosses the strike");
scatter!(pa, S_demo, [premium(:crr, S) for S ∈ S_demo], c = :white, msc = :black, msw = 2, ms = 6, label = "");
annotate!(pa, corners[1] + 0.5, 1.9, # below the piece, between the two corners
    text("open circles: S₀ − ϵ, S₀, S₀ + ϵ lie on one line,\nso the central difference gives Gamma = 0", 9, :left, :black));

# bottom: Delta -
pb = plot(; style..., ylims = (0.0, 1.0), legend = :topleft, title = "Delta: the slope of the premium",
    xlabel = "Share price today S₀ (USD/share)", ylabel = "Delta (share/share)");
vline!(pb, corners, c = :gray50, lw = 1, ls = :dot, label = "");
plot!(pb, S_range, Δ_lr, c = :red, lw = 3, label = "Leisen–Reimer tree: changes smoothly");
plot!(pb, S_range, Δ_crr, c = :navy, lw = 3, label = "CRR tree: flat on each piece, jumps at each corner");

fig = plot(pa, pb, layout = (2, 1), size = (1000, 860), left_margin = 6Plots.mm, bottom_margin = 4Plots.mm);
for ext ∈ ("svg", "pdf")
    savefig(fig, joinpath(@__DIR__, "Fig-L10a-CRR-vs-LR-Delta.$(ext)"));
end
println("corners (USD/share): ", round.(corners, digits = 2));
