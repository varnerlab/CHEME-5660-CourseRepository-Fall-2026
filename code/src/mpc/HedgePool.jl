# Down-day β, the standing hedge pool and the ξ-driven β cap.

"""
    down_day_beta(md::MyMarketData, t::Int; lookback::Int=252)::Vector{Float64}

Down-day β (dimensionless), one per ticker: the OLS slope, with intercept, of the ticker's daily
growth (yr⁻¹) on SPY's daily growth (yr⁻¹) over the days k ∈ max(2, t−lookback+1):t on which SPY's
growth into k is negative. Daily growth is `log(a / b) / Δt` with Δt = 1/252 yr, from closes.
`NaN` when fewer than 3 such days or SPY growth has no variation. Uses data dated ≤ t only.
"""
function down_day_beta(md::MyMarketData, t::Int; lookback::Int=252)::Vector{Float64}
    Δt = 1.0 / 252.0
    ks = collect(max(2, t - lookback + 1):t)
    gm = [log(md.spy_close[k] / md.spy_close[k-1]) / Δt for k ∈ ks]
    down = findall(<(0.0), gm)
    m = length(md.tickers)
    β = fill(NaN, m)
    length(down) < 3 && return β
    x = gm[down]
    x̄ = mean(x)
    sxx = sum((x .- x̄) .^ 2)
    sxx > 0 || return β
    for j ∈ 1:m
        y = [log(md.close[ks[i], j] / md.close[ks[i]-1, j]) / Δt for i ∈ down]
        β[j] = sum((x .- x̄) .* (y .- mean(y))) / sxx
    end
    return β
end

"""
    hedge_pool(β_t::AbstractVector, βdown_t::AbstractVector; H::Int=5)::Vector{Int}

Standing hedge pool: column indices with online β ≤ 0 and down-day β ≤ 0 (both dimensionless;
`NaN` is not eligible), ranked by `βdown_t` ascending with ties by column index, first `H`.
"""
function hedge_pool(β_t::AbstractVector, βdown_t::AbstractVector; H::Int=5)::Vector{Int}
    elig = [j for j ∈ eachindex(β_t) if β_t[j] <= 0 && βdown_t[j] <= 0]
    sort!(elig; by=j -> (βdown_t[j], j))
    return elig[1:min(H, length(elig))]
end

"""
    beta_cap(ξ::Real; β_ref::Real=1.0, κ_β::Real=1.0, β_min::Real=0.0)::Float64

ξ-driven cap on the portfolio β (dimensionless): `max(β_min, β_ref − κ_β·ξ)`, with the market
signal ξ dimensionless.
"""
beta_cap(ξ::Real; β_ref::Real=1.0, κ_β::Real=1.0, β_min::Real=0.0)::Float64 =
    max(Float64(β_min), Float64(β_ref - κ_β * ξ))
