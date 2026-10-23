#!/usr/bin/env julia

# Coordinates for Fig-L10b-Strangle-Time-Decay, the L10b figure that shows why the
# composite-contract diagrams are drawn at expiration.
# A short strangle is opened 30 days before expiration: sell a put at K1 and a call at
# K2 for their premiums. If we buy both legs back on a later day, the profit is the
# credit, grown to that day, minus what the two legs cost then. Before expiration each
# leg still carries extrinsic (time) value, so the profit sits below the profit at
# expiration; as the days pass, the extrinsic value decays and the curve rises onto it.
# Left panel: the profit against the share price on the day we close, 30 (entry), 20,
# and 10 days before expiration, and at expiration. Right panel: if the share price is
# still S(0), the credit we collected at entry (grown with interest) and the cost to
# buy both legs back, against the days to expiration. The gap between them is the
# profit if we close: zero at entry, the whole credit at expiration.
# The contracts are hypothetical (no course data): S(0) = 100 USD/share, K1 = 90 and
# K2 = 110 USD/share, σ = 0.40, g_y = 0.04, American legs priced on CRR trees with
# h = 501 steps, the same pricer as the L10a premium-versus-moneyness figure.
# Self-contained: no packages beyond the standard library.
# Writes Fig-L10b-Strangle-Time-Decay-coords.tex next to this file, which the figure
# \inputs. Run from anywhere: julia generate-strangle-time-decay.jl

using Printf

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
node takes the larger of exercising now and holding for the future. With `T = 0` the
premium is the payoff.

### Example
```julia
crr_premium(:put, 100.0, 100.0, 30/365, 0.30, 0.04, 501) # about 3.29 USD/share
```
"""
function crr_premium(type::Symbol, S::Float64, K::Float64, T::Float64, σ::Float64, g::Float64, h::Int64)::Float64

    # at expiration the contract is worth its payoff -
    if T <= 0.0
        return payoff(type, S, K); # (USD/share)
    end

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

"""
    buy_back_cost(S::Float64, days_left::Float64, K₁::Float64, K₂::Float64, σ::Float64,
        g::Float64, h::Int64) -> Float64

Cost (USD/share) to buy back both legs of a short strangle, a put with strike `K₁` and
a call with strike `K₂` (USD/share), when the share price is `S` (USD/share) and
`days_left` days remain. Each leg is priced on a CRR tree with volatility `σ`
(1/sqrt(yr)), risk-free rate `g` (1/yr), and `h` steps.

### Example
```julia
buy_back_cost(100.0, 0.0, 90.0, 110.0, 0.40, 0.04, 501) # 0.0 USD/share: both legs expire worthless
```
"""
function buy_back_cost(S::Float64, days_left::Float64, K₁::Float64, K₂::Float64, σ::Float64,
    g::Float64, h::Int64)::Float64

    τ = days_left/365; # time left to expiration (years)
    return crr_premium(:put, S, K₁, τ, σ, g, h) + crr_premium(:call, S, K₂, τ, σ, g, h); # (USD/share)
end

"""
    strangle_profit(S::Float64, days_left::Float64, credit::Float64, K₁::Float64, K₂::Float64,
        T::Float64, σ::Float64, g::Float64, h::Int64) -> Float64

Profit (USD/share) of a short strangle opened `T` years before expiration for `credit`
(USD/share), if both legs are bought back when the share price is `S` (USD/share) and
`days_left` days remain. The credit grows at `g` (1/yr) until that day. The legs are a
put with strike `K₁` and a call with strike `K₂` (USD/share), priced on CRR trees with
volatility `σ` (1/sqrt(yr)) and `h` steps.

### Example
```julia
strangle_profit(100.0, 0.0, 2.3, 90.0, 110.0, 30/365, 0.40, 0.04, 501) # about 2.31 USD/share
```
"""
function strangle_profit(S::Float64, days_left::Float64, credit::Float64, K₁::Float64, K₂::Float64,
    T::Float64, σ::Float64, g::Float64, h::Int64)::Float64

    t = T - days_left/365; # time since entry (years)
    return exp(g*t)*credit - buy_back_cost(S, days_left, K₁, K₂, σ, g, h); # (USD/share)
end

# parameters -
S₀ = 100.0; # share price at entry (USD/share)
K₁ = 90.0; # strike of the short put (USD/share)
K₂ = 110.0; # strike of the short call (USD/share)
T = 30/365; # time to expiration at entry (years)
σ = 0.40; # volatility (1/sqrt(yr))
g = 0.04; # risk-free rate (1/yr)
h = 501; # number of tree steps

# the credit we collect at entry: both premiums -
credit = crr_premium(:put, S₀, K₁, T, σ, g, h) + crr_premium(:call, S₀, K₂, T, σ, g, h); # (USD/share)
@printf("credit at entry = %.4f USD/share (put %.4f, call %.4f)\n", credit,
    crr_premium(:put, S₀, K₁, T, σ, g, h), crr_premium(:call, S₀, K₂, T, σ, g, h));

# left panel: profit against the share price, one curve per day we close -
share_prices = collect(84.0:0.25:116.0); # (USD/share)
days_left_list = [30.0, 20.0, 10.0, 0.0]; # days to expiration when we close
curves = Dict{Float64, Vector{Float64}}();
for days_left ∈ days_left_list
    profits = Float64[];
    for S ∈ share_prices
        push!(profits, strangle_profit(S, days_left, credit, K₁, K₂, T, σ, g, h));
    end
    curves[days_left] = profits;
    @printf("%4.0f days left: profit at S(0) = %.4f, at 90 = %.4f, at 110 = %.4f, min = %.4f\n",
        days_left, strangle_profit(S₀, days_left, credit, K₁, K₂, T, σ, g, h),
        strangle_profit(90.0, days_left, credit, K₁, K₂, T, σ, g, h),
        strangle_profit(110.0, days_left, credit, K₁, K₂, T, σ, g, h), minimum(profits));
end

# right panel: at the entry share price, the credit grown with interest and the cost
# to buy both legs back, against the days since entry -
days_since_entry = collect(0.0:0.25:30.0);
cost = Float64[]; # (USD/share)
credit_grown = Float64[]; # (USD/share)
for day ∈ days_since_entry
    push!(cost, buy_back_cost(S₀, 30.0 - day, K₁, K₂, σ, g, h));
    push!(credit_grown, exp(g*day/365)*credit);
end

# write the coordinates as TikZ path macros -
function coords(xs::Vector{Float64}, ys::Vector{Float64})::String
    parts = String[];
    for i ∈ eachindex(xs)
        push!(parts, @sprintf("(%.3f, %.4f)", xs[i], ys[i]));
    end
    return join(parts, " -- ");
end

outfile = joinpath(@__DIR__, "Fig-L10b-Strangle-Time-Decay-coords.tex");
open(outfile, "w") do io
    println(io, "% Generated by generate-strangle-time-decay.jl; do not edit by hand.");
    @printf(io, "%% S(0) = %.1f, K1 = %.1f, K2 = %.1f, sigma = %.2f, g = %.2f, h = %d, credit = %.4f USD/share\n",
        S₀, K₁, K₂, σ, g, h, credit);
    println(io, "% Left panel paths: (share price USD/share, profit USD/share).");
    println(io, "\\def\\curveThirty{", coords(share_prices, curves[30.0]), "}");
    println(io, "\\def\\curveTwenty{", coords(share_prices, curves[20.0]), "}");
    println(io, "\\def\\curveTen{", coords(share_prices, curves[10.0]), "}");
    println(io, "\\def\\curveExpiration{", coords(share_prices, curves[0.0]), "}");
    println(io, "% Right panel paths: (days since entry, USD/share) at S(0).");
    println(io, "\\def\\curveCost{", coords(days_since_entry, cost), "}");
    println(io, "\\def\\curveCredit{", coords(days_since_entry, credit_grown), "}");
    println(io, "% Profit at S(0) on the four days, and the credit grown to expiration.");
    @printf(io, "\\def\\atThirty{%.4f}\n", strangle_profit(S₀, 30.0, credit, K₁, K₂, T, σ, g, h));
    @printf(io, "\\def\\atTwenty{%.4f}\n", strangle_profit(S₀, 20.0, credit, K₁, K₂, T, σ, g, h));
    @printf(io, "\\def\\atTen{%.4f}\n", strangle_profit(S₀, 10.0, credit, K₁, K₂, T, σ, g, h));
    @printf(io, "\\def\\atExpiration{%.4f}\n", strangle_profit(S₀, 0.0, credit, K₁, K₂, T, σ, g, h));
    println(io, "% Cost to buy back at S(0), and the grown credit, on the four days.");
    for (name, days_left) ∈ [("Thirty", 30.0), ("Twenty", 20.0), ("Ten", 10.0), ("Expiration", 0.0)]
        @printf(io, "\\def\\cost%s{%.4f}\n", name, buy_back_cost(S₀, days_left, K₁, K₂, σ, g, h));
        @printf(io, "\\def\\credit%s{%.4f}\n", name, exp(g*(30.0 - days_left)/365)*credit);
    end
end
println("wrote ", outfile);
