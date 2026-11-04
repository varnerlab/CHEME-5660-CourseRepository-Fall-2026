const _PROJ_DT = 1/252   # trading-day step Δt (yr)

"""
    MyProjection

Forward-projected portfolio value moments. `μ` and `σ` (USD, length T) are the across-path mean and
standard deviation of portfolio value at steps τ = 1..T trading days ahead.
"""
mutable struct MyProjection
    μ::Vector{Float64}
    σ::Vector{Float64}
    MyProjection() = new()
end

"""
    build(::Type{MyProjection}, data::NamedTuple)::MyProjection

Build a projection from `μ` (USD) and `σ` (USD) vectors.
"""
function build(::Type{MyProjection}, data::NamedTuple)::MyProjection
    for f ∈ (:μ, :σ)
        _require(data, MyProjection, f)
    end
    model = MyProjection()
    model.μ = Float64.(collect(data.μ)); model.σ = Float64.(collect(data.σ))
    return model
end

# Lower Cholesky factor of C = Δt·Σ_g + 1e-12·I (yr⁻¹).
function _gbm_chol(Σ_g::Matrix{Float64})
    C = _PROJ_DT .* Σ_g
    C = (C .+ C') ./ 2
    for i in axes(C, 1)
        C[i, i] += 1e-12
    end
    return cholesky(Symmetric(C)).L
end

"""
    project_gbm(n, prices, cash, μ_g, Σ_g, g_f; T=21, N=1000, rng)::MyProjection

Multi-asset GBM forward projection of a portfolio (CHEME-5660 growth-rate MA-GBM):
log S_{k+1} = log S_k + Δt·μ_g + √Δt·L·Z_k, LLᵀ = Δt·Σ_g + 1e-12·I, Δt = 1/252.
Arguments: `n` shares (negative = short), `prices` USD/share, `cash` USD, `μ_g` log-growth rates in yr⁻¹
(no −σ²/2 correction), `Σ_g` in yr⁻², `g_f` risk-free rate in yr⁻¹. `T` trading days, `N` paths; all
draws come from `rng`. Value at step τ is Σ nᵢSᵢ,τ + cash·exp(g_f·τ·Δt) in USD; returns the across-path
mean and standard deviation (USD) for τ = 1..T.
"""
function project_gbm(n::Vector{Float64}, prices::Vector{Float64}, cash::Float64, μ_g::Vector{Float64},
        Σ_g::Matrix{Float64}, g_f::Float64; T::Int=21, N::Int=1000, rng::AbstractRNG)::MyProjection
    K = length(n); Δt = _PROJ_DT
    L = _gbm_chol(Σ_g)
    drift = Δt .* μ_g; sdt = sqrt(Δt)
    logS = repeat(log.(prices), 1, N)       # K×N
    Z = Matrix{Float64}(undef, K, N); X = similar(Z)
    val = Vector{Float64}(undef, N)
    μ = Vector{Float64}(undef, T); σ = Vector{Float64}(undef, T)
    for τ in 1:T
        randn!(rng, Z)
        mul!(X, L, Z)
        @inbounds for j in 1:N
            v = 0.0
            for i in 1:K
                x = logS[i, j] + drift[i] + sdt * X[i, j]
                logS[i, j] = x
                v += n[i] * exp(x)
            end
            val[j] = v
        end
        c = cash * exp(g_f * τ * Δt)
        m = mean(val)
        μ[τ] = m + c
        σ[τ] = std(val; mean=m)
    end
    return build(MyProjection, (μ=μ, σ=σ))
end
