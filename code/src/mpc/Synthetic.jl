# Synthetic markets for the study, after the INFORMS 2026 synthetic-market pipeline (SyntheticCalibration.jl,
# SyntheticRunner.jl and scripts/20_synthetic_fit.jl of the study's repository). Every synthetic market is composed
# by JumpHMM.jl's SectorFactorModel; this file holds only what is specific to the method: fitting the generator's
# drift to the method's own online β, choosing stress and typical paths, and running the method on a path.
# Units: growth rates and α (yr⁻¹), variances (yr⁻²), half-lives (trading days), Δt = 1/252 yr.

"""
    SYNTH_HMM

JumpHMM settings for every name and sector model: `N` (states), `ν` (Student-t degrees of freedom), `rf` (yr⁻¹),
`dt` (yr), the tuning grids `ϵ_range` (jump probability per trading day) and `λ_range` (mean jump run length,
trading days), and `n_paths` (simulated paths per tuning grid point). The INFORMS study's values.
"""
const SYNTH_HMM = (N=50, ν=5.0, rf=0.0, dt=1/252, ϵ_range=range(1e-4, 2.5e-2, length=10),
    λ_range=range(10.0, 120.0, length=10), n_paths=100)

"""
    SYNTH_TRAIN

The real training window (first and last trading day), 2014-01-03 → 2024-12-31.
"""
const SYNTH_TRAIN = (Date(2014, 1, 3), Date(2024, 12, 31))

"""
    SYNTH_ALPHA_WINDOWS

The three windows (start, stop) of the α targets: the full training window 2014-01-03 → 2024-12-31, its first
half 2014-01-03 → 2019-12-31 and its second half 2020-01-02 → 2024-12-31.
"""
const SYNTH_ALPHA_WINDOWS = ((Date(2014, 1, 3), Date(2024, 12, 31)), (Date(2014, 1, 3), Date(2019, 12, 31)),
    (Date(2020, 1, 2), Date(2024, 12, 31)))

"""
    growth_window(dates::Vector{Date}, start::Date, stop::Date)::UnitRange{Int}

Rows of the growth-rate matrix that cover the trading days in [`start`, `stop`]. Row k is the growth from
`dates[k]` to `dates[k+1]` (yr⁻¹), so the window is `index(start):(index(stop) − 1)`.
Throws `ArgumentError` if `start` or `stop` is not in `dates`.
"""
function growth_window(dates::Vector{Date}, start::Date, stop::Date)::UnitRange{Int}
    i = findfirst(==(start), dates)
    i === nothing && throw(ArgumentError("start date $(start) is not a trading day in dates"))
    k = findfirst(==(stop), dates)
    k === nothing && throw(ArgumentError("stop date $(stop) is not a trading day in dates"))
    return i:(k - 1)
end

"""
    fit_name_model(prices::AbstractVector{<:Real}; seed::Int, N::Int=SYNTH_HMM.N, tune::Bool=true)

JumpHMM model of one price series (USD/share): `JumpHMM.fit` with `N` states and the `SYNTH_HMM` settings
(ν, rf, dt), then, if `tune` is true, `JumpHMM.tune` over the `SYNTH_HMM` grids with `n_paths` and `seed`.
The model's draws are growth rates (yr⁻¹), since rf = 0.
"""
function fit_name_model(prices::AbstractVector{<:Real}; seed::Int, N::Int=SYNTH_HMM.N, tune::Bool=true)
    x = Float64.(prices)
    model = JumpHMM.fit(JumpHMM.JumpHiddenMarkovModel, x; rf=SYNTH_HMM.rf, N=N, ν=SYNTH_HMM.ν, dt=SYNTH_HMM.dt)
    if tune
        model = JumpHMM.tune(model, x; ϵ_range=SYNTH_HMM.ϵ_range, λ_range=SYNTH_HMM.λ_range,
            n_paths=SYNTH_HMM.n_paths, seed=seed)
    end
    return model
end

"""
    model_sd_ratio(model, g_real::AbstractVector; seed::Int, n_steps::Int=100_000)::Float64

SD of one `n_steps`-day draw from the JumpHMM `model` (seeded with `seed`) divided by the SD of the real growth
rates `g_real` (both yr⁻¹). A ratio near 1 means the model reproduces the real day-to-day spread.
"""
function model_sd_ratio(model, g_real::AbstractVector; seed::Int, n_steps::Int=100_000)::Float64
    draw = JumpHMM.simulate(model, n_steps; n_paths=1, seed=seed).paths[1].observations
    return std(draw) / std(g_real)
end

"""
    ewls_beta_path(g_i, g_m, prior::MySIMParameterEstimate, m_m, v_m; half_life=63.0, prior_weight=63.0)::Vector{Float64}

β̂ (dimensionless) after each EWLS update on the growth rates `g_i` and `g_m` (yr⁻¹), the same recursion as
`online_sim`. The state starts from `prior` (α yr⁻¹, β, σ_ε yr⁻¹) with market mean `m_m` (yr⁻¹) and population
variance `v_m` (yr⁻²); `half_life` and `prior_weight` are in trading days. Entry t is β̂ after update t.
"""
function ewls_beta_path(g_i::AbstractVector, g_m::AbstractVector, prior::MySIMParameterEstimate, m_m::Real, v_m::Real;
                        half_life::Real=63.0, prior_weight::Real=63.0)::Vector{Float64}
    length(g_i) == length(g_m) || throw(ArgumentError("g_i has $(length(g_i)) days but g_m has $(length(g_m))"))
    s = ewls_init(prior.α, prior.β, prior.σ_ε; half_life=half_life, prior_weight=prior_weight,
        market_mean=m_m, market_variance=v_m)
    b = zeros(Float64, length(g_i))
    for t in 1:length(g_i)
        ewls_update!(s, g_i[t], g_m[t])
        b[t] = s.β
    end
    return b
end

"""
    beta_path_stats(b::AbstractVector)::NamedTuple{(:sd, :acf252)}

SD of the β̂ path `b` (dimensionless) and its lag-252 autocorrelation `cor(b[1:end-252], b[253:end])`.
Throws `ArgumentError` if `b` has 254 or fewer days.
"""
function beta_path_stats(b::AbstractVector)::NamedTuple{(:sd, :acf252)}
    length(b) > 254 || throw(ArgumentError("a lag-252 autocorrelation needs more than 254 days; got $(length(b))"))
    return (sd=std(b), acf252=cor(b[1:end-252], b[253:end]))
end

"""
    real_drift_targets(md::MyMarketData, calib::MyCalibration; train=SYNTH_TRAIN,
        alpha_windows=SYNTH_ALPHA_WINDOWS)::NamedTuple{(:sd_β, :acf252, :α_full, :α_h1, :α_h2, :spread, :corr)}

Drift targets from the real data, one entry per ticker of `md`:
- `sd_β`: SD of each name's β̂ path from `online_sim(md, calib)` over the training window `train` (from the
  trading day after its first day to its last), and `acf252`: the median over names of its lag-252 autocorrelation;
- `α_full`, `α_h1`, `α_h2` (yr⁻¹): each name's OLS α from `fit_base_sim` on the three `alpha_windows`;
- `spread = std(α_full)` (yr⁻¹) and `corr = cor(α_h1, α_h2)` (dimensionless).
"""
function real_drift_targets(md::MyMarketData, calib::MyCalibration; train=SYNTH_TRAIN,
        alpha_windows=SYNTH_ALPHA_WINDOWS)::NamedTuple{(:sd_β, :acf252, :α_full, :α_h1, :α_h2, :spread, :corr)}
    start = md.dates[index_of(md, train[1]) + 1]
    sim = online_sim(md, calib; start=start, stop=train[2])
    N = length(md.tickers)
    sd_β = zeros(Float64, N)
    acf = zeros(Float64, N)
    for j in 1:N
        st = beta_path_stats(sim.β[:, j])
        sd_β[j] = st.sd
        acf[j] = st.acf252
    end
    α = [zeros(Float64, N) for _ in 1:3]
    for w in 1:3
        fit = fit_base_sim(md, alpha_windows[w][1], alpha_windows[w][2])
        for j in 1:N
            α[w][j] = fit.params[md.tickers[j]].α
        end
    end
    return (sd_β=sd_β, acf252=median(acf), α_full=α[1], α_h1=α[2], α_h2=α[3], spread=std(α[1]), corr=cor(α[2], α[3]))
end

# Bank-mean β̂ statistics of name i with drift half-life h and scale k, measured as real_drift_targets measures
# the real data: on each bank path, JumpHMM composes the name, the EWLS prior is fitted on `rows`, and the
# EWLS runs over `rows` with the path's market moments.
function _name_bank_beta_stats(gen::JumpHMM.SectorFactorModel, bank::Vector, i::Int, rows::UnitRange{Int},
        h::Real, k::Real)::NamedTuple{(:sd, :acf252)}
    sd = 0.0
    acf = 0.0
    for d in bank
        g = JumpHMM.compose_name(gen, d, i; β_halflife=h, β_scale=k).g
        g_i = g[rows]
        g_m = d.g_m[rows]
        prior = estimate_sim(g_m, g_i)
        b = ewls_beta_path(g_i, g_m, prior, mean(g_m), var(g_m; corrected=false))
        st = beta_path_stats(b)
        sd += st.sd / length(bank)
        acf += st.acf252 / length(bank)
    end
    return (sd=sd, acf252=acf)
end

"""
    fit_beta_drift(gen0::JumpHMM.SectorFactorModel, bank::Vector, targets, dates::Vector{Date};
        h_grid=[63.0, 126.0, 252.0, 504.0, 1008.0, 2016.0], sd_max=1.5, train=SYNTH_TRAIN)::NamedTuple{(:h_β, :k_β, :table)}

Fit one β drift half-life `h_β` (trading days) and a drift scale k per name, so that the method's own EWLS β̂ on
synthetic names reproduces `targets.sd_β` (one per name) and `targets.acf252` (from `real_drift_targets`).
`bank` holds `JumpHMM.sample_draws` outputs on the calendar `dates`; every candidate recomposes the same draws
(common random numbers) with `JumpHMM.compose_name`. α stays at `gen0.α`.

For each h in `h_grid` and each name (threaded): if the bank-mean SD of β̂ at k = 0 already reaches the name's
target, k = 0. Otherwise bisect, with 30 halvings, on the stationary drift SD σₓ ∈ [0, `sd_max`], with
k = σₓ/√(a/(2−a)) and a = 1 − 2^(−1/h). Then pick the h whose median over names of the bank-mean acf252 is
closest to `targets.acf252`. `table` has one row per h: `h`, `k_median`, `zero_share` (share of names with
k = 0) and `acf252` (median synthetic acf252).
"""
function fit_beta_drift(gen0::JumpHMM.SectorFactorModel, bank::Vector, targets, dates::Vector{Date};
        h_grid=[63.0, 126.0, 252.0, 504.0, 1008.0, 2016.0], sd_max=1.5, train=SYNTH_TRAIN)::NamedTuple{(:h_β, :k_β, :table)}
    N = length(gen0.tickers)
    length(targets.sd_β) == N ||
        throw(ArgumentError("targets.sd_β has $(length(targets.sd_β)) entries but the generator has $(N) tickers"))
    rows = growth_window(dates, train[1], train[2])
    H = length(h_grid)
    K = zeros(Float64, H, N)
    A = zeros(Float64, H, N)
    for q in 1:H
        h = h_grid[q]
        a = 1 - 2.0^(-1 / h)
        unit_sd = sqrt(a / (2 - a))
        Threads.@threads for i in 1:N
            target = targets.sd_β[i]
            st0 = _name_bank_beta_stats(gen0, bank, i, rows, h, 0.0)
            if st0.sd >= target
                # the estimation noise alone reaches the target: no drift
                K[q, i] = 0.0
                A[q, i] = st0.acf252
            else
                # bisect on the stationary drift SD
                lo = 0.0
                hi = Float64(sd_max)
                for _ in 1:30
                    mid = (lo + hi) / 2
                    st = _name_bank_beta_stats(gen0, bank, i, rows, h, mid / unit_sd)
                    if st.sd < target
                        lo = mid
                    else
                        hi = mid
                    end
                end
                k = ((lo + hi) / 2) / unit_sd
                K[q, i] = k
                A[q, i] = _name_bank_beta_stats(gen0, bank, i, rows, h, k).acf252
            end
        end
    end
    acf_median = [median(A[q, :]) for q in 1:H]
    best = argmin(abs.(acf_median .- targets.acf252))
    table = DataFrame(h=Float64.(h_grid), k_median=[median(K[q, :]) for q in 1:H],
        zero_share=[count(iszero, K[q, :]) / N for q in 1:H], acf252=acf_median)
    return (h_β=Float64(h_grid[best]), k_β=K[best, :], table=table)
end

"""
    fit_alpha_pull(gen1::JumpHMM.SectorFactorModel, bank::Vector, targets, dates::Vector{Date};
        φ_grid=0.0:0.01:1.5, alpha_windows=SYNTH_ALPHA_WINDOWS)::NamedTuple{(:φ, :spread, :corr, :loss)}

Grid fit of the α center pull φ (dimensionless), with no α drift (the INFORMS study's decision of 2026-10-27:
the real 2014–2024 data leave no room for it). Name i's intercept is cᵢ(φ) = ā + φ(α̂ᵢ − ā), with
α̂ᵢ = `targets.α_full[i]` and ā their mean. On each bank path, name i composed with α = 0 (β drift as in `gen1`)
gives an OLS intercept restᵢ,w in each of the three `alpha_windows`; OLS is linear in the growth and α does not
enter the clipping, so the synthetic α̂ᵢ,w = cᵢ(φ) + restᵢ,w. Per path, `spread` is the std across names of the
full-window α̂ (yr⁻¹) and `corr` the correlation of the two half-window α̂; both are averaged over the bank. The
loss is ((spread − targets.spread)/0.01)² + ((corr − targets.corr)/0.05)²; returns the grid minimizer.
"""
function fit_alpha_pull(gen1::JumpHMM.SectorFactorModel, bank::Vector, targets, dates::Vector{Date};
        φ_grid=0.0:0.01:1.5, alpha_windows=SYNTH_ALPHA_WINDOWS)::NamedTuple{(:φ, :spread, :corr, :loss)}
    N = length(gen1.tickers)
    P = length(bank)
    length(targets.α_full) == N ||
        throw(ArgumentError("targets.α_full has $(length(targets.α_full)) entries but the generator has $(N) tickers"))
    ā = mean(targets.α_full)
    windows = [growth_window(dates, w[1], w[2]) for w in alpha_windows]
    R = [zeros(Float64, N, 3) for _ in 1:P]
    for p in 1:P
        d = bank[p]
        Threads.@threads for i in 1:N
            g = JumpHMM.compose_name(gen1, d, i; α=0.0).g
            for w in 1:3
                R[p][i, w] = estimate_sim(d.g_m[windows[w]], g[windows[w]]).α
            end
        end
    end
    α̂ = zeros(Float64, N, 3)
    best = (φ=NaN, spread=NaN, corr=NaN, loss=Inf)
    for φ in φ_grid
        spread = 0.0
        corr = 0.0
        for p in 1:P
            for w in 1:3, i in 1:N
                α̂[i, w] = ā + φ * (targets.α_full[i] - ā) + R[p][i, w]
            end
            spread += std(view(α̂, :, 1)) / P
            corr += cor(view(α̂, :, 2), view(α̂, :, 3)) / P
        end
        loss = ((spread - targets.spread) / 0.01)^2 + ((corr - targets.corr) / 0.05)^2
        if loss < best.loss
            best = (φ=Float64(φ), spread=spread, corr=corr, loss=loss)
        end
    end
    return best
end

"""
    fit_generator(md::MyMarketData, calib::MyCalibration; market_model, train=SYNTH_TRAIN,
        alpha_windows=SYNTH_ALPHA_WINDOWS, bank_seeds=1_000_001:1_000_020, tune=true, N=SYNTH_HMM.N,
        center_steps=1_000_000, h_grid=[63.0, 126.0, 252.0, 504.0, 1008.0, 2016.0], sd_gate=(0.5, 2.0))
        → (generator::JumpHMM.SectorFactorModel, summary::Dict{String,Any})

Fit the synthetic-market generator to the real market `md`, following the INFORMS study's generator fit, with
JumpHMM.jl doing every composition:
1. a JumpHMM model of each name on its training closes (`fit_name_model`, tuned when `tune`), checked with
   `model_sd_ratio` against `sd_gate` (a ratio outside it throws `ArgumentError` naming the names);
2. single-index residuals on the training window, the sector factors (`JumpHMM.sector_factors`), and a JumpHMM
   model of each compounded sector factor;
3. `JumpHMM.fit(SectorFactorModel, ...)` on the training closes with those models and the given `market_model`;
4. the β drift fitted to the method's own EWLS β̂ (`fit_beta_drift`) on a bank of draws (`bank_seeds`, on the
   whole calendar `md.dates`), then the α pull φ (`fit_alpha_pull`), stored with `JumpHMM.with_parameters`.
`calib` must be the study calibration on `train`. `summary` records the fits, the targets and the model SD
ratios.
"""
function fit_generator(md::MyMarketData, calib::MyCalibration; market_model, train=SYNTH_TRAIN,
        alpha_windows=SYNTH_ALPHA_WINDOWS, bank_seeds=1_000_001:1_000_020, tune::Bool=true, N::Int=SYNTH_HMM.N,
        center_steps::Int=1_000_000, h_grid=[63.0, 126.0, 252.0, 504.0, 1008.0, 2016.0], sd_gate=(0.5, 2.0))
    t0 = time()
    (calib.train_start == train[1] && calib.train_stop == train[2]) ||
        throw(ArgumentError("calibration window $(calib.train_start) → $(calib.train_stop) differs from train $(train)"))
    Δt = 1 / 252
    tickers = md.tickers
    M = length(tickers)
    i0, i1 = index_of(md, train[1]), index_of(md, train[2])
    rows = growth_window(md.dates, train[1], train[2])
    G = growth_rates(md.close)
    g_m = growth_rates(md.spy_close)

    # 1. name models on the training closes, and their SD gate
    names = Vector{JumpHMM.JumpHiddenMarkovModel}(undef, M)
    ratio = zeros(Float64, M)
    Threads.@threads for j in 1:M
        names[j] = fit_name_model(md.close[i0:i1, j]; seed=5660 + j, N=N, tune=tune)
        ratio[j] = model_sd_ratio(names[j], G[rows, j]; seed=5660 + j)
    end
    bad = [j for j in 1:M if !(sd_gate[1] <= ratio[j] <= sd_gate[2])]
    isempty(bad) || throw(ArgumentError("model SD gate: $(length(bad)) ratios outside $(sd_gate): " *
        join(["$(tickers[j]) $(round(ratio[j]; digits=4))" for j in bad], ", ")))

    # 2. single-index residuals, sector factors, and the sector models
    ols = fit_base_sim(md, train[1], train[2])
    E = zeros(Float64, length(rows), M)
    for j in 1:M
        p = ols.params[tickers[j]]
        E[:, j] = G[rows, j] .- p.α .- p.β .* g_m[rows]
    end
    sf = JumpHMM.sector_factors(E, md.sector)
    S = length(sf.sectors)
    factors = Vector{JumpHMM.JumpHiddenMarkovModel}(undef, S)
    Threads.@threads for s in 1:S
        factors[s] = fit_name_model(exp.(vcat(0.0, cumsum(sf.F[:, s] .* Δt))); seed=7000 + s, N=N, tune=tune)
    end

    # 3. the generator with no drift (β_halflife is a placeholder that the β fit replaces)
    gen0, _ = JumpHMM.fit(JumpHMM.SectorFactorModel, ["SPY"; tickers], hcat(md.spy_close[i0:i1], md.close[i0:i1, :]),
        "SPY", md.sector; N=N, ν=SYNTH_HMM.ν, rf=SYNTH_HMM.rf, dt=SYNTH_HMM.dt, center_steps=center_steps,
        β_halflife=252.0, market_model=market_model, name_models=names, sector_models=factors)

    # 4. targets, the bank of draws, the β drift, and the α pull
    targets = real_drift_targets(md, calib; train=train, alpha_windows=alpha_windows)
    n = length(md.dates) - 1
    bank = [JumpHMM.sample_draws(gen0, n; seed=p) for p in bank_seeds]
    fb = fit_beta_drift(gen0, bank, targets, md.dates; h_grid=h_grid, train=train)
    gen1 = JumpHMM.with_parameters(gen0; β_halflife=fb.h_β, β_scale=fb.k_β)
    fa = fit_alpha_pull(gen1, bank, targets, md.dates; alpha_windows=alpha_windows)
    ā = mean(targets.α_full)
    gen = JumpHMM.with_parameters(gen1; α=ā .+ fa.φ .* (targets.α_full .- ā))

    summary = Dict{String,Any}(
        "jumphmm_version" => string(pkgversion(JumpHMM)),
        "wall_seconds" => time() - t0,
        "universe_size" => M,
        "train" => [string(train[1]), string(train[2])],
        "tuned" => tune,
        "states" => N,
        "bank_paths" => length(bank_seeds),
        "beta" => Dict{String,Any}("h_beta" => fb.h_β, "k_median" => median(fb.k_β),
            "k_q25" => quantile(fb.k_β, 0.25), "k_q75" => quantile(fb.k_β, 0.75),
            "zero_share" => count(iszero, fb.k_β) / M,
            "table" => [Dict{String,Any}("h" => r.h, "k_median" => r.k_median, "zero_share" => r.zero_share,
                "acf252" => r.acf252) for r in eachrow(fb.table)]),
        "alpha" => Dict{String,Any}("phi" => fa.φ, "spread_fit" => fa.spread, "spread_target" => targets.spread,
            "corr_fit" => fa.corr, "corr_target" => targets.corr, "loss" => fa.loss, "alpha_full" => targets.α_full,
            "decision" => "no α drift (INFORMS study, 2026-10-27)"),
        "targets" => Dict{String,Any}("beta_acf252" => targets.acf252, "beta_sd_median" => median(targets.sd_β)),
        "model_sd_ratio" => Dict{String,Any}("median" => median(ratio), "min" => minimum(ratio), "max" => maximum(ratio)))
    return (generator=gen, summary=summary)
end

"""
    NonFiniteCloseError(msg)

Thrown by `market_data_from_growth` when a synthetic close is not finite and positive. A dedicated type, so a
caller can skip such a market and count it without hiding any other error.
"""
struct NonFiniteCloseError <: Exception
    msg::String
end
Base.showerror(io::IO, e::NonFiniteCloseError) = print(io, "NonFiniteCloseError: ", e.msg)

"""
    market_data_from_growth(md::MyMarketData, g_m::AbstractVector, G::AbstractMatrix;
        volume_stop::Date=Date(2024, 12, 31))::MyMarketData

A synthetic `MyMarketData` on the calendar of the real market `md`: the market growth `g_m` (yr⁻¹, one per growth
row) and the name growth `G` (yr⁻¹, rows × `md.tickers`) compound from the real first closes as exp(g·Δt) with
Δt = 1/252 yr; opens equal closes; each name's volume is its median real daily volume on the dates up to
`volume_stop` (all dates if none); the sectors and the risk-free rates are the real ones. Throws
`NonFiniteCloseError` naming the first ticker whose close is not finite and positive, and `ArgumentError`
when the shapes do not match the market data.
"""
function market_data_from_growth(md::MyMarketData, g_m::AbstractVector, G::AbstractMatrix;
        volume_stop::Date=Date(2024, 12, 31))::MyMarketData
    Δt = 1 / 252
    n, M = size(G)
    (n == length(md.dates) - 1 && length(g_m) == n && M == length(md.tickers)) ||
        throw(ArgumentError("growth has $(n) rows and $(M) names; the market data need $(length(md.dates) - 1) and $(length(md.tickers))"))
    close = md.close[1, :]' .* exp.(vcat(zeros(1, M), cumsum(G .* Δt; dims=1)))
    spy = md.spy_close[1] .* exp.(vcat(0.0, cumsum(g_m .* Δt)))
    for j in 1:M
        for t in 1:(n + 1)
            (isfinite(close[t, j]) && close[t, j] > 0) ||
                throw(NonFiniteCloseError("ticker $(md.tickers[j]) has close $(close[t, j]) on day $(t); closes must be finite and positive"))
        end
    end
    vrows = findall(<=(volume_stop), md.dates)
    vrows = isempty(vrows) ? collect(eachindex(md.dates)) : vrows
    volume = [median(md.volume[vrows, j]) for j in 1:M]
    return build(MyMarketData, (dates=md.dates, tickers=md.tickers, open=close, close=close,
        volume=repeat(volume', n + 1), spy_open=spy, spy_close=spy, sector=md.sector, g_f=md.g_f))
end

"""
    synthetic_market_data(gen::JumpHMM.SectorFactorModel, md::MyMarketData, p::Int)::MyMarketData

Synthetic market `p` on the calendar of the real market `md`: one path of `JumpHMM.sample_dependence(gen, n;
seed=p)` over the `n = length(md.dates) − 1` growth rows, turned into market data by `market_data_from_growth`.
The same `p` gives the same market. `gen.tickers` must equal `md.tickers` (else `ArgumentError`); a non-finite
close throws `NonFiniteCloseError`.
"""
function synthetic_market_data(gen::JumpHMM.SectorFactorModel, md::MyMarketData, p::Int)::MyMarketData
    gen.tickers == md.tickers || throw(ArgumentError("the generator's tickers differ from the market data's"))
    d = JumpHMM.sample_dependence(gen, length(md.dates) - 1; seed=p)
    return market_data_from_growth(md, d.g_m, d.G)
end

"""
    market_path_stats(gen::JumpHMM.SectorFactorModel, md::MyMarketData, ids::AbstractVector{Int};
        window=(Date(2025, 1, 2), Date(2026, 9, 4)), train=SYNTH_TRAIN)::DataFrame

One row per path id in `ids`, in order, from the market draw alone (the same draw as `synthetic_market_data`
makes for that id). SPY closes compound from the real first close as exp(g_m·Δt). Columns: `path_id`;
`window_max_drawdown` (fraction, peak reset at the window start); `window_growth` and `train_growth` (yr⁻¹,
ln(S_end/S_start)/(trading days/252) over the window and over the training window); `has_burst` (true if any
jump flag falls on the window's growth rows). Threaded over ids.
"""
function market_path_stats(gen::JumpHMM.SectorFactorModel, md::MyMarketData, ids::AbstractVector{Int};
        window::Tuple{Date,Date}=(Date(2025, 1, 2), Date(2026, 9, 4)), train::Tuple{Date,Date}=SYNTH_TRAIN)::DataFrame
    Δt = 1 / 252
    dates = md.dates
    n = length(dates) - 1
    w0, w1 = findfirst(==(window[1]), dates), findfirst(==(window[2]), dates)
    t0, t1 = findfirst(==(train[1]), dates), findfirst(==(train[2]), dates)
    (w0 === nothing || w1 === nothing || t0 === nothing || t1 === nothing) &&
        throw(ArgumentError("window $(window) and train $(train) must both start and end on trading days"))
    rows = growth_window(dates, window[1], window[2])
    m = length(ids)
    drawdown = zeros(Float64, m)
    wgrowth = zeros(Float64, m)
    tgrowth = zeros(Float64, m)
    burst = fill(false, m)
    for k in 1:m   # JumpHMM.simulate reseeds the global RNG, so the draws run one at a time
        mkt = JumpHMM.simulate(gen.market_model, n; n_paths=1, seed=ids[k]).paths[1]
        S = md.spy_close[1] .* exp.(vcat(0.0, cumsum(mkt.observations .* Δt)))
        W = S[w0:w1]
        drawdown[k] = maximum(1 .- W ./ accumulate(max, W))
        wgrowth[k] = log(S[w1] / S[w0]) / ((w1 - w0) * Δt)
        tgrowth[k] = log(S[t1] / S[t0]) / ((t1 - t0) * Δt)
        burst[k] = any(mkt.jumps[rows])
    end
    return DataFrame(path_id=collect(ids), window_max_drawdown=drawdown, window_growth=wgrowth,
        train_growth=tgrowth, has_burst=burst)
end

"""
    path_sets(stats::DataFrame; n_burst=200, n_bear=200, n_typical=600, seed=5660)::DataFrame

Add the three study sets to `stats` (from `market_path_stats`). `burst_stress` marks the `n_burst` deepest
`window_max_drawdown` among `has_burst` paths, `bear_stress` the `n_bear` deepest among the others. `typical_rank` is the
position of the row in `randperm(MersenneTwister(seed), nrow(stats))` and `typical` is `typical_rank ≤ n_typical`.
`run_order` is missing for a path in no set. Otherwise it numbers the paths 1…m by (priority, path_id), where priority is
the smallest of rank-in-set / set-size over the path's sets, so stopping early leaves every set equally complete.
Throws `ArgumentError` if a stress pool is smaller than its quota. (The INFORMS study's definition.)
"""
function path_sets(stats::DataFrame; n_burst::Int=200, n_bear::Int=200, n_typical::Int=600, seed::Int=5660)::DataFrame
    out = copy(stats)
    m = nrow(out)
    burst_pool = findall(out.has_burst)
    bear_pool = findall(.!out.has_burst)
    length(burst_pool) >= n_burst ||
        throw(ArgumentError("burst pool has $(length(burst_pool)) paths, fewer than n_burst = $(n_burst)"))
    length(bear_pool) >= n_bear ||
        throw(ArgumentError("bear pool has $(length(bear_pool)) paths, fewer than n_bear = $(n_bear)"))
    n_typical <= m || throw(ArgumentError("n_typical = $(n_typical) exceeds the $(m) paths"))
    priority = fill(Inf, m)
    burst_stress = fill(false, m)
    bear_stress = fill(false, m)
    burst_top = burst_pool[sortperm(out.window_max_drawdown[burst_pool]; rev=true)[1:n_burst]]
    for (r, i) in enumerate(burst_top)
        burst_stress[i] = true
        priority[i] = min(priority[i], r / n_burst)
    end
    bear_top = bear_pool[sortperm(out.window_max_drawdown[bear_pool]; rev=true)[1:n_bear]]
    for (r, i) in enumerate(bear_top)
        bear_stress[i] = true
        priority[i] = min(priority[i], r / n_bear)
    end
    typical_rank = randperm(MersenneTwister(seed), m)
    typical = typical_rank .<= n_typical
    for i in 1:m
        if typical[i]
            priority[i] = min(priority[i], typical_rank[i] / n_typical)
        end
    end
    members = findall(isfinite, priority)
    order = sortperm(members; by=i -> (priority[i], out.path_id[i]))
    run_order = Vector{Union{Missing,Int}}(missing, m)
    for (pos, k) in enumerate(order)
        run_order[members[k]] = pos
    end
    out.burst_stress = burst_stress
    out.bear_stress = bear_stress
    out.typical_rank = typical_rank
    out.typical = typical
    out.run_order = run_order
    return out
end

"""
    run_synthetic_path(md::MyMarketData, runs::Vector{MyStudyRun}; calib=nothing)::DataFrame

Every run in `runs` on the market `md`, as the study runs a synthetic path: calibrate on the runs' training window
(`calibrate` with the runs' `omega_window`, unless `calib` is given), build one `MyStudyContext` per distinct
`context_key`, and replay each run with `run_study`. All runs must share one training window.

One row per run, in order: `label`, `allocator`, `screen`, `seed`, `hedge`, `status` (`"ok"` or `"error"`), `error`
(missing when ok), `wealth_ratio` (ending wealth ÷ `W0`), `growth` (`growth_scorecard`'s realized growth,
ln(W_end/W_1)/((N−1)Δt), yr⁻¹), `max_drawdown` (fraction), `n_decisions`, and the same run window's SPY
`spy_ratio` (last close ÷ first close) and `spy_growth` (yr⁻¹). A run that throws keeps its row with status
`"error"`, the message, and missing results; if the calibration itself fails, every run gets such a row, with
an error message that starts "calibration failed".
"""
function run_synthetic_path(md::MyMarketData, runs::Vector{MyStudyRun}; calib=nothing)::DataFrame
    isempty(runs) && throw(ArgumentError("runs is empty"))
    s1 = runs[1].settings
    all(r -> r.settings.train_start == s1.train_start && r.settings.train_stop == s1.train_stop, runs) ||
        throw(ArgumentError("every run must share one training window"))
    if calib === nothing
        calib = try
            calibrate(md; train_start=s1.train_start, train_stop=s1.train_stop, window=s1.omega_window)
        catch err
            err  # recorded below as an error row for every run
        end
    end
    if calib isa Exception
        message = "calibration failed: " * sprint(showerror, calib)
        return DataFrame([(label=r.label, allocator=r.allocator, screen=r.screen, seed=r.seed, hedge=r.settings.hedge,
            status="error", error=message, wealth_ratio=missing, growth=missing, max_drawdown=missing,
            n_decisions=missing, spy_ratio=missing, spy_growth=missing) for r in runs])
    end
    ctxs = Dict{Any,Any}()
    for r in runs
        k = context_key(r.settings)
        if !haskey(ctxs, k)
            ctxs[k] = try
                build_context(md, calib, r.settings)
            catch err
                err
            end
        end
    end
    i0, i1 = index_of(md, s1.start), index_of(md, s1.stop)
    spy = md.spy_close[i0:i1]
    spy_ratio = spy[end] / spy[1]
    spy_growth = log(spy_ratio) / ((i1 - i0) / 252)
    rows = NamedTuple[]
    for r in runs
        base = (label=r.label, allocator=r.allocator, screen=r.screen, seed=r.seed, hedge=r.settings.hedge)
        try
            c = ctxs[context_key(r.settings)]
            c isa Exception && throw(c)
            res = run_study(c, r)
            j0, j1 = index_of(md, res.dates[1]), index_of(md, res.dates[end])
            sc = growth_scorecard(res.equity, md.spy_close[j0:j1], md.g_f[j0:j1])
            push!(rows, merge(base, (status="ok", error=missing, wealth_ratio=res.equity[end] / r.settings.W0,
                growth=sc.realized_growth, max_drawdown=sc.max_drawdown, n_decisions=nrow(res.decisions),
                spy_ratio=spy_ratio, spy_growth=spy_growth)))
        catch err
            push!(rows, merge(base, (status="error", error=sprint(showerror, err), wealth_ratio=missing,
                growth=missing, max_drawdown=missing, n_decisions=missing, spy_ratio=spy_ratio, spy_growth=spy_growth)))
        end
    end
    return DataFrame(rows)
end
