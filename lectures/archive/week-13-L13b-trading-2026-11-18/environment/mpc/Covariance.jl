"""
    AbstractCovarianceModel

Supertype of growth-covariance models. Covariances are in yr⁻² (growth rates in yr⁻¹).
"""
abstract type AbstractCovarianceModel end

"C1: Single Index Model covariance, Σ_g = σ_m²ββᵀ + diag(σ_ε²)."
struct MySIMCovariance <: AbstractCovarianceModel end

"""
    MyShrunkResidualCovariance

C2: σ_m²ββᵀ + D^{1/2}·R_λ·D^{1/2}, R_λ = (1−λ)·cor(residuals over trailing `window` days) + λI.
`λ` (dimensionless, 0..1); `window` (trading days, 126).
"""
mutable struct MyShrunkResidualCovariance <: AbstractCovarianceModel
    λ::Float64
    window::Int
    MyShrunkResidualCovariance() = new()
end

function build(::Type{MyShrunkResidualCovariance}, data::NamedTuple)::MyShrunkResidualCovariance
    model = MyShrunkResidualCovariance()
    haskey(data, :λ) || throw(ArgumentError("Cannot build MyShrunkResidualCovariance: missing field λ"))
    model.λ = Float64(data.λ)
    model.window = Int(get(data, :window, 126))
    return model
end

"""
    growth_covariance(model, β, σ_ε, σ_m; residuals=nothing)::Matrix{Float64}

Growth covariance (yr⁻²). `β` dimensionless, `σ_ε` and `σ_m` in yr⁻¹. For C2, `residuals`
(days × names, yr⁻¹) supplies the residual correlation; the caller passes the trailing window.
"""
function growth_covariance(::MySIMCovariance, β::AbstractVector, σ_ε::AbstractVector, σ_m::Real;
        residuals::Union{Nothing,AbstractMatrix}=nothing)::Matrix{Float64}
    return Matrix{Float64}(σ_m^2 .* (β * β') .+ Diagonal(σ_ε .^ 2))
end

function growth_covariance(model::MyShrunkResidualCovariance, β::AbstractVector, σ_ε::AbstractVector, σ_m::Real;
        residuals::Union{Nothing,AbstractMatrix}=nothing)::Matrix{Float64}
    residuals === nothing && throw(ArgumentError("MyShrunkResidualCovariance requires `residuals`"))
    size(residuals, 2) == length(σ_ε) || throw(DimensionMismatch("residuals must be days × names"))
    n = length(σ_ε)
    R = (1 - model.λ) .* cor(residuals) .+ model.λ .* Matrix(I, n, n)
    R[isnan.(R)] .= 0.0                    # constant residual series: no correlation information
    R[diagind(R)] .= 1.0
    D = Diagonal(Float64.(σ_ε))
    Σ = σ_m^2 .* (β * β') .+ D * R * D
    return Matrix{Float64}((Σ + Σ') / 2)
end

"""
    residual_matrix(g, g_m, α, β)::Matrix{Float64}

εᵢₜ = gᵢₜ − αᵢ − βᵢ·g_mₜ for `g` days × names (yr⁻¹).
"""
function residual_matrix(g::AbstractMatrix, g_m::AbstractVector, α::AbstractVector, β::AbstractVector)::Matrix{Float64}
    return Matrix{Float64}(g .- α' .- g_m * β')
end

# Basket of up to `n` names, drawn round-robin across sectors (without replacement) so sectors
# are balanced: 3 per sector when there are 11 sectors.
function _draw_basket(rng, sector_idx::Vector{Vector{Int}}, n::Int)::Vector{Int}
    pools = [shuffle(rng, s) for s in sector_idx if !isempty(s)]
    basket = Int[]
    while length(basket) < n && any(!isempty, pools)
        for p in pools
            (isempty(p) || length(basket) >= n) && continue
            push!(basket, pop!(p))
        end
    end
    return basket
end

# Anchor rows of the shrinkage calibration: each last trading day of a month (row a with
# month(dates[a+1]) ≠ month(dates[a])) that has 252 growth days behind it from row i0 and 21 ahead
# through row i1.
_shrinkage_anchors(dates::AbstractVector{Date}, i0::Int, i1::Int)::Vector{Int} =
    [a for a in (i0 + 252):(i1 - 21) if month(dates[a + 1]) != month(dates[a])]

# The calibration's forecast at anchor row a, for growth rates g (growth days × names, g[k] into row
# k+1) and g_m: α, β from OLS on the trailing 252 growth days, and per λ the residual part of the
# study's Σ_g (`growth_covariance` with σ_M = 0): residuals of that α, β over the trailing `window`
# growth days, each scaled by its own SD over the window. Returns (α, β, Σs).
function _shrinkage_covariances(g::AbstractMatrix, g_m::AbstractVector, a::Int, λs::AbstractVector;
        window::Int=126)
    tr = (a - 252):(a - 1); tw = (a - window):(a - 1)
    fits = [estimate_sim(g_m[tr], g[tr, j]) for j in axes(g, 2)]
    α = [f.α for f in fits]; β = [f.β for f in fits]
    E = residual_matrix(g[tw, :], g_m[tw], α, β)
    σ̂ = std.(eachcol(E))
    Σs = [growth_covariance(build(MyShrunkResidualCovariance, (λ=λ, window=window)), β, σ̂, 0.0; residuals=E)
        for λ in λs]
    return (α=α, β=β, Σs=Σs)
end

"""
    shrinkage_loss(md, start, stop; grid=0:0.1:1, n_portfolios=200, seed=5660, window=126)::Vector{Float64}

Mean QLIKE (r/p − log(r/p) − 1) per λ ∈ `grid` of the RESIDUAL-portfolio variance: predicted
p = wᵀ[(1−λ)·Ω̂_ε + λ·diag(Ω̂_ε)]w, the study's residual covariance (`_study_problem`), with Ω̂_ε the
sample covariance of the SIM residuals over the trailing `window` trading days; realized r = sample
variance over the next 21 trading days of wᵀε_t. At each anchor α, β come from OLS on the trailing
252 days (the study's online EWLS estimates have no run-up inside the training window). Anchors are
the month-ends from `start` + 252 trading days through `stop` − 21. Baskets: up to 33 names
(round-robin across sectors), Dirichlet(1) weights. Portfolios with non-finite or non-positive r
are skipped. Uses data through `stop` only.
"""
function shrinkage_loss(md::MyMarketData, start::Date, stop::Date;
        grid=0:0.1:1, n_portfolios::Int=200, seed::Int=5660, window::Int=126)::Vector{Float64}
    rng = MersenneTwister(seed)
    g = growth_rates(md.close); g_m = growth_rates(md.spy_close)    # g[k] is the return into dates[k+1]
    i0 = searchsortedfirst(md.dates, start); i1 = searchsortedlast(md.dates, stop)
    anchors = _shrinkage_anchors(md.dates, i0, i1)
    isempty(anchors) && throw(ArgumentError("window too short: need a month-end with 252 trading days before it and 21 after"))
    sector_idx = [findall(==(s), md.sector) for s in unique(md.sector)]
    λs = collect(Float64, grid)
    loss = zeros(length(λs)); count = 0
    for a in anchors
        (; α, β, Σs) = _shrinkage_covariances(g, g_m, a, λs; window=window)
        fw = a:(a + 20)
        Ef = residual_matrix(g[fw, :], g_m[fw], α, β)
        for _ in 1:n_portfolios
            idx = _draw_basket(rng, sector_idx, 33)
            w = randexp(rng, length(idx)); w ./= sum(w)       # Dirichlet(1)
            r = var(Ef[:, idx] * w)
            (isfinite(r) && r > 0) || continue
            count += 1
            for (k, Σ) in enumerate(Σs)
                q = r / dot(w, Σ[idx, idx] * w)
                loss[k] += q - log(q) - 1
            end
        end
    end
    count > 0 || throw(ArgumentError("no valid portfolios"))
    loss ./= count
    all(isfinite, loss) || error("non-finite shrinkage loss")
    return loss
end

"""
    choose_shrinkage(md, start, stop; grid=0:0.1:1, n_portfolios=200, seed=5660, window=126)::Float64

The λ ∈ `grid` with the lowest `shrinkage_loss`; ties go to the larger λ.
"""
function choose_shrinkage(md::MyMarketData, start::Date, stop::Date;
        grid=0:0.1:1, n_portfolios::Int=200, seed::Int=5660, window::Int=126)::Float64
    L = shrinkage_loss(md, start, stop; grid=grid, n_portfolios=n_portfolios, seed=seed, window=window)
    λs = collect(Float64, grid)
    return λs[findlast(l -> l <= minimum(L), L)]
end
