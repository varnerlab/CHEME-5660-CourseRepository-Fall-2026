# Method v2 forecast: the book's value over T trading days from the JumpHMM factor model.
#
# Ported to the course package from the INFORMS 2026 study (varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab, branch
# feat/method-v2, commit 5d31b74). The study's generator ran on an early JumpHMM; the course fits its models with
# JumpHMM 0.6.0 (the sector factor example of L14a). The draws below read the fields of a JumpHMM 0.6.0
# `MyJumpHiddenMarkovModel` directly, so the course package does not depend on JumpHMM itself.
#
# Each model's draws are standardized by its long-run mean and standard deviation, then scaled to the re-plan day's
# online levels: the market drift g̃_M and volatility σ_M, each name's α and β, and each name's residual volatility
# σ_res. The JumpHMM models give the forecast its shape (fat tails, jumps and regime switches); the online estimates
# give its levels, as in the v1 GBM forecast.

"""
    forecast_draws(model, T::Int, N::Int, seed::Int)::Matrix{Float64}

The raw draws of one forecast model: `T` days on each of `N` paths (yr⁻¹).

For a JumpHMM 0.6.0 model these are exactly the `growth_rates` of
`JumpHMM.simulate(model, T; number_of_paths=N, seed=seed)`, with each path started from the model's stationary
distribution. This function runs the same chain with the same random calls in the same order, on its own stream
`Xoshiro(seed)`, which gives the same numbers as the task's default stream reseeded with `seed`. It leaves the task's
default stream alone, so the draws depend only on `seed`, not on the thread or on earlier draws.

### Arguments
- `model`: a JumpHMM 0.6.0 model (`JumpHMM.MyJumpHiddenMarkovModel`), or any object with its fields
  `number_of_states`, `transition`, `stationary`, `emission_μ`, `emission_σ` (yr⁻¹), `ν`, `ϵ`, `λ`, `p_neg` and
  `N_tail`.
- `T::Int`: the number of days (at least 1).
- `N::Int`: the number of paths.
- `seed::Int`: the seed of this stream.

### Returns
- `Matrix{Float64}`: T × N draws (yr⁻¹); column p is path p.

### Example
```julia
X = forecast_draws(market_model, 21, 1000, 5660);
```
"""
function forecast_draws(model, T::Int, N::Int, seed::Int)::Matrix{Float64}
    if T < 1
        throw(ArgumentError("forecast_draws: T must be at least 1, got $(T)"));
    end
    rng = Xoshiro(seed);
    n_states = model.number_of_states;

    # the samplers JumpHMM.simulate builds: the next state from each state, the first state, the Student-t draw,
    # the length of a jump episode, and the states of the two tails
    next_state = Vector{Distributions.Categorical{Float64,Vector{Float64}}}();
    for s in 1:n_states
        push!(next_state, Distributions.Categorical(model.transition[s, :]));
    end
    first_state = Distributions.Categorical(model.stationary);
    t_dist = Distributions.TDist(model.ν);
    episode_length = Distributions.Poisson(model.λ);
    bottom_states = collect(1:min(model.N_tail, n_states));
    top_states = collect(max(1, n_states - model.N_tail + 1):n_states);

    # each path: a state from the stationary distribution on the first day, then the chain
    X = zeros(Float64, T, N);
    for p in 1:N
        s = rand(rng, first_state);
        X[1, p] = _emission_draw(rng, model, s, t_dist);
        τ = 2;
        while τ <= T
            # does a jump episode start today? A model with ϵ = 0 draws no random number here
            episode_starts = false;
            if model.ϵ > 0.0
                if rand(rng) < model.ϵ
                    episode_starts = true;
                end
            end
            if episode_starts == true
                # a jump episode of K days in a tail state; K = 0 is an ordinary step
                K = rand(rng, episode_length);
                if K == 0
                    s = rand(rng, next_state[s]);
                    X[τ, p] = _emission_draw(rng, model, s, t_dist);
                    τ = τ + 1;
                else
                    k = 1;
                    while k <= K && τ <= T
                        if rand(rng) < model.p_neg
                            s = rand(rng, bottom_states);
                        else
                            s = rand(rng, top_states);
                        end
                        X[τ, p] = _emission_draw(rng, model, s, t_dist);
                        τ = τ + 1;
                        k = k + 1;
                    end
                end
            else
                # an ordinary step of the Markov chain
                s = rand(rng, next_state[s]);
                X[τ, p] = _emission_draw(rng, model, s, t_dist);
                τ = τ + 1;
            end
        end
    end
    return X;
end

"""
    _emission_draw(rng, model, s::Int, t_dist)::Float64

One draw from the Student-t emission of state `s`, as `JumpHMM.sample_emission` draws it: μ_s + σ_s·x with x from
`t_dist`.

### Arguments
- `rng::Xoshiro`: the stream.
- `model`: the JumpHMM model (its `emission_μ` and `emission_σ` are in yr⁻¹).
- `s::Int`: the state.
- `t_dist::Distributions.TDist{Float64}`: the Student-t distribution with the model's ν.

### Returns
- `Float64`: the draw (yr⁻¹).
"""
function _emission_draw(rng::Xoshiro, model, s::Int, t_dist::Distributions.TDist{Float64})::Float64
    return model.emission_μ[s] + model.emission_σ[s] * rand(rng, t_dist);
end

"""
    _standard_draws(model, m::Float64, s::Float64, T::Int, N::Int, seed::Int)::Matrix{Float64}

The standardized draws of one forecast model: (x − m) / s for each raw draw x of `forecast_draws`, so they have
long-run mean 0 and standard deviation 1.

### Arguments
- `model`: the forecast model.
- `m::Float64`, `s::Float64`: the model's long-run mean and standard deviation (yr⁻¹).
- `T::Int`, `N::Int`: the number of days and paths.
- `seed::Int`: the seed of this stream.

### Returns
- `Matrix{Float64}`: T × N standardized draws (dimensionless).
"""
function _standard_draws(model, m::Float64, s::Float64, T::Int, N::Int, seed::Int)::Matrix{Float64}
    # standardize the raw draws in place, so no second matrix is allocated
    Z = forecast_draws(model, T, N, seed);
    for p in 1:N
        for τ in 1:T
            Z[τ, p] = (Z[τ, p] - m) / s;
        end
    end
    return Z;
end

"""
    _forecast_seed(seed::Int, k::Int)::Int

The seed of random stream `k` of the forecast with seed `seed`: 1000·seed + k, with k = 0 for the market,
k = s for sector s, and k = 100 + i for the name model i. The factor 1000 keeps the streams of forecasts on
consecutive days apart (the forecast seed rises by 1 per day).

### Arguments
- `seed::Int`: the forecast seed (`_bt_projection_seed(run.seed, date)`).
- `k::Int`: the stream, 0 ≤ k < 1000.

### Returns
- `Int`: the stream's seed.
"""
function _forecast_seed(seed::Int, k::Int)::Int
    if k < 0 || k >= 1000
        throw(ArgumentError("forecast stream k = $(k) must lie in [0, 1000)"));
    end
    return 1000 * seed + k;
end

# The smallest standard deviation (yr⁻¹) a forecast model may have. The fitted models have about 1 to 3 yr⁻¹; a
# constant model's computed standard deviation is rounding noise near 1e-16, which would blow up its standardized draws.
const _FORECAST_MIN_SD = 1e-9

"""
    _model_moments(model, n_steps::Int, seed::Int, label::String)::NamedTuple

The long-run mean and standard deviation (yr⁻¹) of a forecast model: the mean and standard deviation of one
`n_steps`-day draw with `seed`.

### Arguments
- `model`: the forecast model.
- `n_steps::Int`: the length of the draw (days).
- `seed::Int`: the seed of the draw.
- `label::String`: the model's name, for the error message.

### Returns
- `NamedTuple` `(m, s)`. Throws `ArgumentError` naming the model when s is not finite or is at most
  `_FORECAST_MIN_SD`: a model with no spread cannot be standardized.
"""
function _model_moments(model, n_steps::Int, seed::Int, label::String)::NamedTuple
    x = forecast_draws(model, n_steps, 1, seed);
    m = mean(x);
    s = std(x);
    if !(isfinite(s) && s > _FORECAST_MIN_SD)
        throw(ArgumentError("forecast model $(label): standard deviation $(s) must be finite and above $(_FORECAST_MIN_SD)"));
    end
    return (m=m, s=s);
end

"""
    sector_factor_variances(model; Δt::Float64=1/252)::Vector{Float64}

The variance (yr⁻²) of each sector factor's growth rate over the fit window of a JumpHMM 0.6.0 sector factor model,
recovered from the model's compounded sector-factor levels: f_s(t) = ln(L_s(t+1)/L_s(t))/Δt.

### Arguments
- `model`: a JumpHMM 0.6.0 `MySectorFactorModel` (its `sector_levels` field, one column per sector).
- `Δt::Float64`: the time step of the levels (yr).

### Returns
- `Vector{Float64}`: one variance per sector, in the order of `model.sectors`.

### Example
```julia
σ²_s = sector_factor_variances(generator);
```
"""
function sector_factor_variances(model; Δt::Float64=1/252)::Vector{Float64}
    L = model.sector_levels;
    (n_rows, n_sectors) = size(L);
    σ² = zeros(Float64, n_sectors);
    for s in 1:n_sectors
        f = zeros(Float64, n_rows - 1);
        for t in 1:(n_rows - 1)
            f[t] = log(L[t + 1, s] / L[t, s]) / Δt;
        end
        σ²[s] = var(f);
    end
    return σ²;
end

"""
    build_forecast_models(model; n_steps::Int=1_000_000, seed::Int=5660)::MyForecastModels

The forecast models from a JumpHMM 0.6.0 sector factor model (the generator saved by the L14a sector factor
example): its models of SPY, the sector factors and each stock's own residual, each model's long-run moments, and
each stock's sector share ρ.

### Arguments
- `model`: a JumpHMM 0.6.0 `MySectorFactorModel`, or any object with its fields `tickers`, `sectors`,
  `sector_index`, `δ`, `σ²_own`, `sector_levels`, `market_model`, `sector_models` and `own_models`.
- `n_steps::Int`: the length of the one long draw per model that gives its moments (days).
- `seed::Int`: the moment draws use `seed` for the market, `seed + s` for sector s and `seed + 100 + i` for
  stock i. A forecast stream's seed is 1000 times a forecast seed that is at least the decision date's day number
  (over 7·10⁵), so the forecasts never repeat these draws.

### Returns
- `MyForecastModels`. The sector share of stock i is the sector term's part of its single index residual variance,
  ρᵢ = δᵢ²·σ²_s / (δᵢ²·σ²_s + σ²_own,i), with σ²_s the variance of its sector factor (`sector_factor_variances`)
  and σ²_own,i the residual variance the sector term leaves to the own term. Throws `ArgumentError` when a model's
  standard deviation is not finite or is at most `_FORECAST_MIN_SD`, or when there are 100 or more sectors (the
  seeds of sectors and stocks would overlap).

### Example
```julia
fm = build_forecast_models(generator);
```
"""
function build_forecast_models(model; n_steps::Int=1_000_000, seed::Int=5660)::MyForecastModels
    n_names = length(model.tickers);
    n_sectors = length(model.sector_models);
    if n_sectors >= 100
        throw(ArgumentError("build_forecast_models: $(n_sectors) sectors; at most 99 are supported"));
    end

    # the market model's moments
    market = _model_moments(model.market_model, n_steps, seed, "market");

    # each sector factor's moments, and the variance of each sector factor in the fit window
    m_factor = zeros(Float64, n_sectors);
    s_factor = zeros(Float64, n_sectors);
    for s in 1:n_sectors
        moments = _model_moments(model.sector_models[s], n_steps, seed + s, "sector $(model.sectors[s])");
        m_factor[s] = moments.m;
        s_factor[s] = moments.s;
    end
    σ²_s = sector_factor_variances(model; Δt=model.market_model.Δt);

    # each stock's moments and its sector share ρ of the single index residual variance
    m_name = zeros(Float64, n_names);
    s_name = zeros(Float64, n_names);
    ρ = zeros(Float64, n_names);
    for i in 1:n_names
        moments = _model_moments(model.own_models[i], n_steps, seed + 100 + i, "stock $(model.tickers[i])");
        m_name[i] = moments.m;
        s_name[i] = moments.s;
        sector_part = model.δ[i]^2 * σ²_s[model.sector_index[i]];
        denominator = sector_part + model.σ²_own[i];
        if denominator > 0
            ρ[i] = clamp(sector_part / denominator, 0.0, 1.0);
        end
    end

    return build(MyForecastModels, (tickers=copy(model.tickers), market=model.market_model,
        factors=model.sector_models, names=model.own_models, sector_index=copy(model.sector_index),
        δ=copy(model.δ), ρ=ρ, m_market=market.m, s_market=market.s, m_factor=m_factor, s_factor=s_factor,
        m_name=m_name, s_name=s_name));
end

"""
    project_factor(n, prices, n_spy, spy_price, cash, α, β, g̃_M, σ_M, σ_res, cols, fm, g_f; T=21, N=1000,
        seed, band, label="")::MyProjection

The factor-model forecast of a book: its value on each of `N` paths over `T` trading days.

On each path and day, with z the standardized draws of the models (`_standard_draws`):
- the market grows at g_m = g̃_M + σ_M·z_m, and SPY grows at g_m;
- name i grows at gᵢ = αᵢ + βᵢ·g_m + σ_res,i·(√ρᵢ·z_sector + √(1 − ρᵢ)·z_name,i);
- log prices step by g·Δt with Δt = 1/252, as in `project_gbm`;
- the value is Σ nᵢSᵢ,τ + n_spy·SPY_τ + cash·exp(g_f·τ·Δt).

### Arguments
- `n::Vector{Float64}`: the shares of the book's names (negative for a short).
- `prices::Vector{Float64}`: their prices on the forecast day (USD/share).
- `n_spy::Float64`: the SPY shares (negative for a short).
- `spy_price::Float64`: SPY's price on the forecast day (USD/share).
- `cash::Float64`: cash (USD).
- `α::Vector{Float64}`, `β::Vector{Float64}`: the names' online α (yr⁻¹) and β (dimensionless).
- `g̃_M::Float64`, `σ_M::Float64`: the market drift and volatility (yr⁻¹).
- `σ_res::Vector{Float64}`: the names' residual volatility (yr⁻¹).
- `cols::Vector{String}`: the names' tickers.
- `fm::MyForecastModels`: the forecast models.
- `g_f::Float64`: the risk-free rate (yr⁻¹).
- `T::Int`, `N::Int`: the number of days and paths.
- `seed::Int`: the forecast seed; stream k uses `_forecast_seed(seed, k)`, with k = 0 for the market, k = s for
  sector s and k = 100 + i for name model i.
- `band::String`: `"quantile"` keeps the 2.5% and 97.5% quantiles as `lo` and `hi`; `"sigma"` keeps none.
- `label::String`: words added to an error message, such as the run seed and date.

### Returns
- `MyProjection`: the mean `μ` and standard deviation `σ` (USD) of the paths' value on each day, and `lo` and `hi`
  (USD) for the quantile band. Throws `ArgumentError` naming a ticker with no model, for an unknown `band`, or
  when a path value is not finite.
"""
function project_factor(n::Vector{Float64}, prices::Vector{Float64}, n_spy::Float64, spy_price::Float64,
        cash::Float64, α::Vector{Float64}, β::Vector{Float64}, g̃_M::Float64, σ_M::Float64, σ_res::Vector{Float64},
        cols::Vector{String}, fm::MyForecastModels, g_f::Float64; T::Int=21, N::Int=1000, seed::Int,
        band::String, label::String="")::MyProjection
    K = length(n);
    Δt = _PROJ_DT;
    if band != "quantile" && band != "sigma"
        throw(ArgumentError("project_factor: band must be \"quantile\" or \"sigma\"; got \"$(band)\""));
    end

    # the model of each name in the book
    model_of = Dict{String,Int}();
    for i in eachindex(fm.tickers)
        model_of[fm.tickers[i]] = i;
    end
    models = zeros(Int, K);
    for i in 1:K
        if haskey(model_of, cols[i]) == false
            throw(ArgumentError("project_factor: no forecast model for ticker $(cols[i])"));
        end
        models[i] = model_of[cols[i]];
    end

    # the market growth on every day and path (yr⁻¹)
    z_market = _standard_draws(fm.market, fm.m_market, fm.s_market, T, N, _forecast_seed(seed, 0));
    g_m = zeros(Float64, T, N);
    for p in 1:N
        for τ in 1:T
            g_m[τ, p] = g̃_M + σ_M * z_market[τ, p];
        end
    end

    # the value of every path on every day (USD), starting with the SPY position
    value = zeros(Float64, T, N);
    if n_spy != 0.0
        for p in 1:N
            log_spy = log(spy_price);
            for τ in 1:T
                log_spy = log_spy + g_m[τ, p] * Δt;
                value[τ, p] = value[τ, p] + n_spy * exp(log_spy);
            end
        end
    end

    # the sector draws of the sectors the book holds, one stream per sector
    z_sector = Dict{Int,Matrix{Float64}}();
    for i in 1:K
        s = fm.sector_index[models[i]];
        if haskey(z_sector, s) == false
            z_sector[s] = _standard_draws(fm.factors[s], fm.m_factor[s], fm.s_factor[s], T, N, _forecast_seed(seed, s));
        end
    end

    # each name: the market, its sector and its own draws
    for i in 1:K
        j = models[i];
        z_s = z_sector[fm.sector_index[j]];
        z_n = _standard_draws(fm.names[j], fm.m_name[j], fm.s_name[j], T, N, _forecast_seed(seed, 100 + j));
        a = sqrt(fm.ρ[j]);
        b = sqrt(1 - fm.ρ[j]);
        for p in 1:N
            log_price = log(prices[i]);
            for τ in 1:T
                g = α[i] + β[i] * g_m[τ, p] + σ_res[i] * (a * z_s[τ, p] + b * z_n[τ, p]);
                log_price = log_price + g * Δt;
                value[τ, p] = value[τ, p] + n[i] * exp(log_price);
            end
        end
    end

    # cash grows at the risk-free rate
    for τ in 1:T
        cash_τ = cash * exp(g_f * τ * Δt);
        for p in 1:N
            value[τ, p] = value[τ, p] + cash_τ;
        end
    end

    # a path value that is not finite is an error
    for p in 1:N
        for τ in 1:T
            if isfinite(value[τ, p]) == false
                throw(ArgumentError("project_factor: path $(p) has a value that is not finite on day $(τ) " *
                    "(forecast seed $(seed), $(label))"));
            end
        end
    end

    # the mean, the standard deviation and the quantile band of each day's values
    μ = zeros(Float64, T);
    σ = zeros(Float64, T);
    lo = zeros(Float64, T);
    hi = zeros(Float64, T);
    for τ in 1:T
        row = value[τ, :];
        μ[τ] = mean(row);
        σ[τ] = std(row);
        lo[τ] = quantile(row, 0.025);
        hi[τ] = quantile(row, 0.975);
    end
    if band == "sigma"
        return build(MyProjection, (μ=μ, σ=σ));
    end
    return build(MyProjection, (μ=μ, σ=σ, lo=lo, hi=hi));
end

"""
    sector_factor_covariance(β, σ_res, σ_M, tickers, fm)::Matrix{Float64}

The growth covariance (yr⁻²) of a book under the sector factor model, at the re-plan day's online levels. It is the
covariance of the factor forecast (`project_factor`), so a book sized with it is forecast with the same model:

- the market part σ²_M·βᵢβⱼ for every pair;
- the residual variance σ²_res,i on the diagonal;
- the sector part σ_res,i·σ_res,j·√(ρᵢρⱼ) for two different stocks in the same sector, and nothing across sectors.

ρᵢ is stock i's sector share (`build_forecast_models`). The matrix is positive semidefinite for any ρ in [0, 1].

### Arguments
- `β::AbstractVector{<:Real}`: the online single index β of each stock (dimensionless).
- `σ_res::AbstractVector{<:Real}`: the online residual volatility of each stock (yr⁻¹).
- `σ_M::Real`: the market volatility (yr⁻¹).
- `tickers::AbstractVector{String}`: the stocks' tickers, which pick their sector and ρ in `fm`.
- `fm::MyForecastModels`: the forecast models.

### Returns
- `Matrix{Float64}`: Σ_g (yr⁻²). Throws `ArgumentError` naming a ticker with no model, or when the inputs differ
  in length.

### Example
```julia
Σ_g = sector_factor_covariance(β, σ_res, 0.17 / sqrt(1/252), ["XOM", "CVX"], fm);
```
"""
function sector_factor_covariance(β::AbstractVector{<:Real}, σ_res::AbstractVector{<:Real}, σ_M::Real,
        tickers::AbstractVector{String}, fm::MyForecastModels)::Matrix{Float64}
    K = length(β);
    if length(σ_res) != K || length(tickers) != K
        throw(ArgumentError("sector_factor_covariance: β, σ_res and tickers must have one length; got $(K), " *
            "$(length(σ_res)) and $(length(tickers))"));
    end

    # the model of each stock: its sector and its sector share
    model_of = Dict{String,Int}();
    for i in eachindex(fm.tickers)
        model_of[fm.tickers[i]] = i;
    end
    sector = zeros(Int, K);
    ρ = zeros(Float64, K);
    for i in 1:K
        if haskey(model_of, tickers[i]) == false
            throw(ArgumentError("sector_factor_covariance: no forecast model for ticker $(tickers[i])"));
        end
        j = model_of[tickers[i]];
        sector[i] = fm.sector_index[j];
        ρ[i] = fm.ρ[j];
    end

    # the market part, the residual variance on the diagonal, and the sector blocks
    Σ = zeros(Float64, K, K);
    for i in 1:K
        for j in 1:K
            Σ[i, j] = σ_M^2 * β[i] * β[j];
            if i == j
                Σ[i, j] = Σ[i, j] + σ_res[i]^2;
            elseif sector[i] == sector[j]
                Σ[i, j] = Σ[i, j] + σ_res[i] * σ_res[j] * sqrt(ρ[i] * ρ[j]);
            end
        end
    end
    return Σ;
end
