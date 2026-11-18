# Market-state inputs for the screened utility-panel study: ξ, g̃_M and the signed γ.

"""
    xi_gain(spy_close::AbstractVector; short::Int=21, long::Int=63, q::Float64=0.99)::Float64

CHEME-5660 L8b gain (dimensionless): `G = 1/quantile(|EMA_short/EMA_long − 1|[t₀:end], q)` with
`t₀ = short + long`, both EMAs seeded at the first close. Pass training closes (USD/share) only.
"""
function xi_gain(spy_close::AbstractVector; short::Int=21, long::Int=63, q::Float64=0.99)::Float64
    t₀ = short + long
    length(spy_close) >= t₀ || throw(ArgumentError("need at least short + long = $(t₀) closes"))
    s = ema_series(spy_close; span=short)
    l = ema_series(spy_close; span=long)
    return 1.0 / quantile(abs.(s[t₀:end] ./ l[t₀:end] .- 1.0), q)
end

"""
    xi_series(spy_close::AbstractVector; short::Int=21, long::Int=63, G::Float64)::Vector{Float64}

Market-state signal (dimensionless) `ξ[t] = −G·(EMA_short[t]/EMA_long[t] − 1)` for every day of
`spy_close` (USD/share). Causal: `ξ[t]` uses closes through day `t` only.
"""
function xi_series(spy_close::AbstractVector; short::Int=21, long::Int=63, G::Float64)::Vector{Float64}
    s = ema_series(spy_close; span=short)
    l = ema_series(spy_close; span=long)
    return -G .* (s ./ l .- 1.0)
end

"""
    gtilde_series(spy_close::AbstractVector; window::Int=252, Δt::Float64=1/252)::Vector{Float64}

Smoothed market growth rate g̃_M (yr⁻¹): element 1 is `NaN`; element `k ≥ 2` is the span-`window`
EMA, seeded at the first growth, of daily growth `log(S_k/S_{k−1})/Δt` through day `k`. Causal.
"""
function gtilde_series(spy_close::AbstractVector; window::Int=252, Δt::Float64=1 / 252)::Vector{Float64}
    g = growth_rates(spy_close; Δt=Δt)
    return vcat(NaN, ema_series(g; span=window))
end

"""
    gamma_weights(α, β, g̃_M, ξ; β_floor=0.1)::Vector{Float64}

Signed preference weights (dimensionless) `γᵢ = tanh((αᵢ + βᵢ·g̃_M) / max(|βᵢ|, β_floor)^ξ)`.
`α` and `g̃_M` are in yr⁻¹, `β` and `ξ` dimensionless. The numerator keeps the sign of `βᵢ`, so a
negative-β name is charged rather than credited for market growth.
"""
function gamma_weights(α::AbstractVector, β::AbstractVector, g̃_M::Real, ξ::Real;
    β_floor::Real=0.1)::Vector{Float64}
    length(α) == length(β) || throw(ArgumentError("α and β must have the same length"))
    return [tanh((a + b * g̃_M) / max(abs(b), β_floor)^ξ) for (a, b) ∈ zip(α, β)]
end
