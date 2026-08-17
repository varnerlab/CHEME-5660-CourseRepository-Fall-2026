# Core adaptive-portfolio teaching routines adapted from the eCornell AI Finance
# short course for use throughout CHEME 5660. The implementations here are kept
# solver-light so the lecture examples remain fast and reproducible.

"""Estimated Single Index Model parameters for one asset."""
mutable struct MySIMParameterEstimate
    ticker::String
    α::Float64
    β::Float64
    σ_ε::Float64
    r²::Float64
    MySIMParameterEstimate() = new()
end

"""Budget-constrained Cobb–Douglas portfolio choice problem."""
mutable struct MyCobbDouglasChoiceProblem
    gamma::Vector{Float64}
    prices::Vector{Float64}
    B::Float64
    epsilon::Float64
    MyCobbDouglasChoiceProblem() = new()
end

"""Budget-constrained constant-elasticity-of-substitution portfolio choice problem."""
mutable struct MyCESChoiceProblem
    gamma::Vector{Float64}
    prices::Vector{Float64}
    B::Float64
    epsilon::Float64
    eta::Float64
    MyCESChoiceProblem() = new()
end

"""Sufficient statistics and current coefficients for recursive EWLS estimation."""
mutable struct MyEWLSState
    Sw::Float64
    Swx::Float64
    Swy::Float64
    Swxx::Float64
    Swxy::Float64
    Swyy::Float64
    δ::Float64        # decay factor 2^(-1/half_life), applied once per observation
    α::Float64
    β::Float64
    σ_ε::Float64
    MyEWLSState() = new()
end

function build(::Type{MySIMParameterEstimate}, data::NamedTuple)::MySIMParameterEstimate
    model = MySIMParameterEstimate()
    model.ticker = data.ticker
    model.α = data.α
    model.β = data.β
    model.σ_ε = data.σ_ε
    model.r² = data.r²
    return model
end

"""Estimate one Single Index Model with optional ridge regularization.

Both input series must use the same sampling convention. In the course notebooks
they are annualized continuous-growth-rate observations, so `σ_ε` is the sample
standard deviation of the residual growth-rate observations in that convention.
"""
function estimate_sim(market_returns::AbstractVector, asset_returns::AbstractVector,
        ticker::AbstractString; δ::Real=0.0)
    length(market_returns) == length(asset_returns) ||
        throw(DimensionMismatch("market and asset return series must have equal length"))
    length(market_returns) > 2 || throw(ArgumentError("at least three observations are required"))
    δ >= 0 || throw(ArgumentError("δ must be nonnegative"))
    market = Float64.(market_returns)
    asset = Float64.(asset_returns)
    all(isfinite, market) && all(isfinite, asset) ||
        throw(ArgumentError("return series must contain only finite values"))
    var(market) > eps(Float64) || throw(ArgumentError("market return series must have positive variance"))

    X = hcat(ones(length(market)), market)
    penalty = Float64(δ) * Matrix{Float64}(I, 2, 2)
    θ = (X' * X + penalty) \ (X' * asset)
    residuals = asset - X * θ
    residual_variance = dot(residuals, residuals) / (length(asset) - 2)
    total_variation = sum(abs2, asset .- mean(asset))
    r² = total_variation > eps(Float64) ?
        1 - dot(residuals, residuals) / total_variation :
        (dot(residuals, residuals) <= eps(Float64) ? 1.0 : 0.0)
    return build(MySIMParameterEstimate, (ticker=String(ticker), α=θ[1], β=θ[2],
        σ_ε=sqrt(max(residual_variance, 0.0)), r²=r²))
end

"""Bootstrap SIM parameter uncertainty with residual or Gaussian innovations.

`method=:residual` resamples centered fitted residuals and preserves their
empirical heavy-tailed shape. `method=:parametric` draws Gaussian innovations
with the fitted residual standard deviation. Confidence intervals are empirical
percentile intervals. The analytical covariance uses the full ridge sandwich,
which reduces to the familiar OLS expression when `δ == 0`.
"""
function bootstrap_sim(market_returns::AbstractVector, asset_returns::AbstractVector,
        ticker::AbstractString; δ::Real=0.0, n_bootstrap::Integer=1000,
        seed::Integer=5660, method::Symbol=:residual, confidence::Real=0.95)
    n_bootstrap > 1 || throw(ArgumentError("n_bootstrap must exceed one"))
    method in (:residual, :parametric) ||
        throw(ArgumentError("method must be :residual or :parametric"))
    0 < confidence < 1 || throw(ArgumentError("confidence must lie between zero and one"))

    market = Float64.(market_returns)
    asset = Float64.(asset_returns)
    point = estimate_sim(market, asset, ticker; δ)
    X = hcat(ones(length(market)), market)
    XtX = X' * X
    Kinv = inv(XtX + Float64(δ) * Matrix{Float64}(I, 2, 2))
    θ = [point.α, point.β]
    fitted = X * θ
    residuals = asset - fitted
    centered_residuals = residuals .- mean(residuals)
    residual_variance = dot(residuals, residuals) / (length(asset) - 2)
    theoretical_covariance = residual_variance .* (Kinv * XtX * Kinv')

    rng = MersenneTwister(seed)
    samples = Matrix{Float64}(undef, n_bootstrap, 3)
    for b in 1:n_bootstrap
        innovations = method == :residual ?
            rand(rng, centered_residuals, length(residuals)) :
            sqrt(residual_variance) .* randn(rng, length(residuals))
        synthetic = fitted + innovations
        θb = Kinv * (X' * synthetic)
        rb = synthetic - X * θb
        samples[b, 1] = θb[1]
        samples[b, 2] = θb[2]
        samples[b, 3] = sqrt(max(dot(rb, rb) / (length(asset) - 2), 0.0))
    end

    tail_probability = (1 - confidence) / 2
    interval(column) = let q = quantile(view(samples, :, column),
            [tail_probability, 1 - tail_probability]); (q[1], q[2]) end
    return (
        point_estimate=point,
        samples=samples,
        alpha_samples=view(samples, :, 1),
        beta_samples=view(samples, :, 2),
        sigma_epsilon_samples=view(samples, :, 3),
        confidence_intervals=(alpha=interval(1), beta=interval(2), sigma_epsilon=interval(3)),
        bootstrap_standard_errors=(alpha=std(view(samples, :, 1)),
            beta=std(view(samples, :, 2)), sigma_epsilon=std(view(samples, :, 3))),
        theoretical_covariance=theoretical_covariance,
        theoretical_standard_errors=(alpha=sqrt(theoretical_covariance[1, 1]),
            beta=sqrt(theoretical_covariance[2, 2])),
        method=method,
        confidence=Float64(confidence),
        seed=Int(seed),
    )
end

"""Propagate fitted SIM bootstrap draws into portfolio risk and weight uncertainty."""
function propagate_sim_uncertainty(bootstrap_results::AbstractVector,
        μ_m::Real, σ_m::Real; n_scenarios::Integer=1000, seed::Integer=5660)
    isempty(bootstrap_results) && throw(ArgumentError("at least one bootstrap result is required"))
    n_scenarios > 1 || throw(ArgumentError("n_scenarios must exceed one"))
    σ_m > 0 || throw(ArgumentError("σ_m must be positive"))
    points = getproperty.(bootstrap_results, :point_estimate)
    α = getproperty.(points, :α)
    β = getproperty.(points, :β)
    σ_ε = getproperty.(points, :σ_ε)
    μ̂, Σ̂ = sim_portfolio_inputs(α, β, σ_ε, μ_m, σ_m)
    ŵ = minimum_variance_weights(Σ̂)

    fixed_variance = Vector{Float64}(undef, n_scenarios)
    optimal_variance = similar(fixed_variance)
    fixed_growth = similar(fixed_variance)
    weight_distance = similar(fixed_variance)
    rng = MersenneTwister(seed)
    for s in 1:n_scenarios
        scenario = [result.samples[rand(rng, axes(result.samples, 1)), :] for result in bootstrap_results]
        αs = first.(scenario)
        βs = getindex.(scenario, 2)
        σ_εs = getindex.(scenario, 3)
        μs, Σs = sim_portfolio_inputs(αs, βs, σ_εs, μ_m, σ_m)
        ws = minimum_variance_weights(Σs)
        fixed_variance[s] = dot(ŵ, Σs * ŵ)
        optimal_variance[s] = dot(ws, Σs * ws)
        fixed_growth[s] = dot(ŵ, μs)
        weight_distance[s] = 0.5 * sum(abs.(ws .- ŵ))
    end
    return (point_expected_growth=μ̂, point_covariance=Σ̂, point_weights=ŵ,
        fixed_variance=fixed_variance, optimal_variance=optimal_variance,
        variance_regret=fixed_variance .- optimal_variance,
        fixed_growth=fixed_growth, weight_distance=weight_distance)
end

"""Estimate a Hill tail index from positive, negative, or absolute observations."""
function hill_tail_index(x::AbstractVector; k::Union{Nothing,Integer}=nothing,
        tail::Symbol=:absolute)
    tail in (:right, :left, :absolute) ||
        throw(ArgumentError("tail must be :right, :left, or :absolute"))
    values = Float64.(filter(isfinite, x))
    length(values) > 3 || throw(ArgumentError("at least four finite observations are required"))
    exceedances = tail == :right ? filter(>(0), values) :
        tail == :left ? abs.(filter(<(0), values)) : filter(>(0), abs.(values))
    length(exceedances) > 2 || throw(ArgumentError("the selected tail has too few observations"))
    ordered = sort(exceedances; rev=true)
    number_used = isnothing(k) ? floor(Int, sqrt(length(ordered))) : Int(k)
    1 <= number_used < length(ordered) ||
        throw(ArgumentError("k must satisfy 1 <= k < the number of tail observations"))
    threshold = ordered[number_used + 1]
    threshold > 0 || throw(ArgumentError("the Hill threshold must be positive"))
    hill_gamma = mean(log.(view(ordered, 1:number_used) ./ threshold))
    hill_gamma > 0 || throw(ArgumentError("the selected observations do not define a positive tail index"))
    return 1 / hill_gamma
end

"""Compute the biased sample autocorrelation at selected nonnegative lags."""
function sample_autocorrelation(x::AbstractVector, lags::AbstractVector{<:Integer})
    values = Float64.(x)
    all(isfinite, values) || throw(ArgumentError("series must contain only finite values"))
    isempty(values) && throw(ArgumentError("series must not be empty"))
    all(lag -> 0 <= lag < length(values), lags) ||
        throw(ArgumentError("lags must be in 0:(length(x)-1)"))
    centered = values .- mean(values)
    denominator = dot(centered, centered)
    denominator > eps(Float64) || throw(ArgumentError("series must have positive variance"))
    return [lag == 0 ? 1.0 : dot(view(centered, 1:length(values)-lag),
        view(centered, 1+lag:length(values))) / denominator for lag in lags]
end

"""Return a compact heavy-tail and dependence diagnostic for a growth-rate series."""
function stylized_facts_report(x::AbstractVector; lags::AbstractVector{<:Integer}=[1, 5, 20],
        hill_k::Union{Nothing,Integer}=nothing)
    values = Float64.(x)
    return (tail_index=hill_tail_index(values; k=hill_k, tail=:absolute),
        lags=collect(lags), raw_acf=sample_autocorrelation(values, lags),
        absolute_acf=sample_autocorrelation(abs.(values), lags),
        squared_acf=sample_autocorrelation(values .^ 2, lags),
        white_noise_95_band=1.96 / sqrt(length(values)))
end

function build(::Type{MyCobbDouglasChoiceProblem}, data::NamedTuple)::MyCobbDouglasChoiceProblem
    model = MyCobbDouglasChoiceProblem()
    model.gamma = Float64.(data.gamma)
    model.prices = Float64.(data.prices)
    model.B = Float64(data.B)
    model.epsilon = Float64(data.epsilon)
    return model
end

function build(::Type{MyCESChoiceProblem}, data::NamedTuple)::MyCESChoiceProblem
    model = MyCESChoiceProblem()
    model.gamma = Float64.(data.gamma)
    model.prices = Float64.(data.prices)
    model.B = Float64(data.B)
    model.epsilon = Float64(data.epsilon)
    model.eta = Float64(data.eta)
    return model
end

"""Construct expected growth and covariance from vector-form SIM parameters."""
function sim_portfolio_inputs(α::AbstractVector, β::AbstractVector, σ_ε::AbstractVector,
        μ_m::Real, σ_m::Real)
    length(α) == length(β) == length(σ_ε) || throw(DimensionMismatch("SIM vectors must have equal length"))
    μ = Float64.(α) .+ Float64.(β) .* μ_m
    Σ = σ_m^2 .* (Float64.(β) * Float64.(β)') + Diagonal(Float64.(σ_ε).^2)
    return μ, Matrix(Σ)
end

"""Construct a SIM covariance matrix from parameter-estimate objects."""
function build_sim_covariance(estimates::AbstractVector{<:MySIMParameterEstimate}, σ_m::Real)
    β = getproperty.(estimates, :β)
    σ_ε = getproperty.(estimates, :σ_ε)
    return sim_portfolio_inputs(zeros(length(estimates)), β, σ_ε, 0.0, σ_m)[2]
end

"""Return the fully invested, unconstrained global minimum-variance weights."""
function minimum_variance_weights(Σ::AbstractMatrix)
    size(Σ, 1) == size(Σ, 2) || throw(DimensionMismatch("covariance matrix must be square"))
    one = ones(size(Σ, 1))
    raw = Symmetric(Matrix{Float64}(Σ)) \ one
    return raw / sum(raw)
end

"""Construct an equicorrelation covariance matrix from marginal volatilities."""
function covariance_from_volatility(σ::AbstractVector, ρ::Real)
    -1 / max(length(σ) - 1, 1) < ρ < 1 || throw(ArgumentError("ρ must define a positive-definite equicorrelation matrix"))
    C = fill(Float64(ρ), length(σ), length(σ))
    C[diagind(C)] .= 1.0
    return Matrix(Diagonal(Float64.(σ)) * C * Diagonal(Float64.(σ)))
end

"""Simulate one periodically rebalanced portfolio path with proportional trading costs."""
function simulate_rebalanced_path(rng::AbstractRNG, μannual::AbstractVector,
        Σannual::AbstractMatrix, wtarget::AbstractVector; trading_days::Int=252,
        rebalance_every::Int=21, cost_rate::Real=0.001)
    distribution = MvNormal(Float64.(μannual) / 252, Symmetric(Matrix{Float64}(Σannual) / 252))
    holdings = Float64.(wtarget)
    wealth_series = ones(trading_days + 1)
    cumulative_turnover = 0.0
    for t in 1:trading_days
        holdings .*= exp.(rand(rng, distribution))
        wealth_before_trade = sum(holdings)
        if t % rebalance_every == 0
            pretrade_weights = holdings / wealth_before_trade
            turnover = 0.5 * sum(abs.(wtarget - pretrade_weights))
            cumulative_turnover += turnover
            holdings .= wealth_before_trade * (1 - cost_rate * turnover) .* wtarget
        end
        wealth_series[t + 1] = sum(holdings)
    end
    peak = accumulate(max, wealth_series)
    return (terminal=wealth_series[end], drawdown=maximum(1 .- wealth_series ./ peak),
        turnover=cumulative_turnover)
end

"""Evaluate a rebalancing scenario over common, reproducible Monte Carlo paths."""
function evaluate_rebalancing_scenario(seed::Integer, μannual::AbstractVector,
        Σannual::AbstractMatrix, wtarget::AbstractVector; number_of_paths::Int=750,
        cost_rate::Real=0.001, trading_days::Int=252, rebalance_every::Int=21)
    rng = MersenneTwister(seed)
    results = [simulate_rebalanced_path(rng, μannual, Σannual, wtarget;
        trading_days, rebalance_every, cost_rate) for _ in 1:number_of_paths]
    terminal = getproperty.(results, :terminal)
    drawdown = getproperty.(results, :drawdown)
    turnover = getproperty.(results, :turnover)
    return (median_terminal=median(terminal), fifth_percentile=quantile(terminal, 0.05),
        failure_probability=mean(terminal .< 1.0), mean_drawdown=mean(drawdown),
        mean_turnover=mean(turnover))
end

"""Convert SIM quality and a market-state signal into normalized positive preferences."""
function adaptive_preference_weights(α::AbstractVector, β::AbstractVector,
        σ_ε::AbstractVector, λ::Real; alpha_gain::Real=25.0,
        beta_penalty::Real=0.8, risk_penalty::Real=1.5, signal_gain::Real=0.4)
    scores = alpha_gain .* α .- beta_penalty .* abs.(β .- 1) .-
        risk_penalty .* σ_ε .+ signal_gain .* λ .* β
    gamma = exp.(scores .- maximum(scores))
    return gamma / sum(gamma)
end

function _validate_choice_inputs(prices, gamma, B, epsilon)
    length(prices) == length(gamma) || throw(DimensionMismatch("prices and gamma must have equal length"))
    all(prices .> 0) || throw(ArgumentError("prices must be positive"))
    B >= 0 || throw(ArgumentError("budget must be nonnegative"))
    epsilon >= 0 || throw(ArgumentError("epsilon must be nonnegative"))
end

"""Solve a budget-constrained Cobb–Douglas choice problem analytically."""
function allocate_cobb_douglas(problem::MyCobbDouglasChoiceProblem)
    gamma, prices, B, epsilon = problem.gamma, problem.prices, problem.B, problem.epsilon
    _validate_choice_inputs(prices, gamma, B, epsilon)
    preferred = findall(>(0), gamma)
    nonpreferred = findall(<=(0), gamma)
    shares = zeros(length(gamma))
    shares[nonpreferred] .= epsilon
    remaining = B - dot(prices, shares)
    remaining >= -sqrt(eps(Float64)) || throw(ArgumentError("minimum-share floor exceeds budget"))
    cash = max(remaining, 0.0)
    if !isempty(preferred) && remaining > 0
        shares[preferred] .= (gamma[preferred] ./ sum(gamma[preferred])) .* remaining ./ prices[preferred]
        cash = 0.0
    end
    return shares, cash
end

"""Convenience Cobb–Douglas allocator returning shares, dollars, weights, and cash."""
function allocate_cobb_douglas(prices::AbstractVector, gamma::AbstractVector, B::Real; epsilon::Real=0.0)
    problem = build(MyCobbDouglasChoiceProblem,
        (gamma=Float64.(gamma), prices=Float64.(prices), B=Float64(B), epsilon=Float64(epsilon)))
    shares, cash = allocate_cobb_douglas(problem)
    dollars = prices .* shares
    invested = sum(dollars)
    weights = invested > 0 ? dollars / invested : zeros(length(dollars))
    return (shares=shares, dollars=dollars, weights=weights, cash=cash)
end

"""Solve a budget-constrained constant-elasticity-of-substitution choice problem."""
function allocate_ces(problem::MyCESChoiceProblem)
    gamma, prices, B, epsilon, eta = problem.gamma, problem.prices, problem.B, problem.epsilon, problem.eta
    _validate_choice_inputs(prices, gamma, B, epsilon)
    eta > 0 || throw(ArgumentError("eta must be positive"))
    preferred = findall(>(0), gamma)
    nonpreferred = findall(<=(0), gamma)
    shares = zeros(length(gamma))
    shares[nonpreferred] .= epsilon
    remaining = B - dot(prices, shares)
    remaining >= -sqrt(eps(Float64)) || throw(ArgumentError("minimum-share floor exceeds budget"))
    cash = max(remaining, 0.0)
    if !isempty(preferred) && remaining > 0
        raw = (gamma[preferred] ./ prices[preferred]).^eta
        shares[preferred] .= remaining .* raw ./ dot(prices[preferred], raw)
        cash = 0.0
    end
    return shares, cash
end

"""Convenience CES allocator returning shares, dollars, weights, and cash."""
function allocate_ces(prices::AbstractVector, gamma::AbstractVector, B::Real, eta::Real; epsilon::Real=0.0)
    problem = build(MyCESChoiceProblem, (gamma=Float64.(gamma), prices=Float64.(prices),
        B=Float64(B), epsilon=Float64(epsilon), eta=Float64(eta)))
    shares, cash = allocate_ces(problem)
    dollars = prices .* shares
    invested = sum(dollars)
    weights = invested > 0 ? dollars / invested : zeros(length(dollars))
    return (shares=shares, dollars=dollars, weights=weights, cash=cash)
end

"""Compute an exponentially weighted moving average."""
function compute_ema(x::AbstractVector, window::Integer)
    window > 0 || throw(ArgumentError("window must be positive"))
    isempty(x) && return Float64[]
    a = 2 / (window + 1)
    out = Float64.(x)
    for t in 2:length(out)
        out[t] = a * x[t] + (1 - a) * out[t - 1]
    end
    return out
end

"""Map a scalar regime signal and beta vector to fully invested target weights."""
function adaptive_target_weights(signal::Real, β::AbstractVector;
        beta_penalty::Real=0.7, signal_gain::Real=0.9)
    scores = exp.(-beta_penalty .* abs.(β .- 1) .+ signal_gain .* signal .* β)
    return scores / sum(scores)
end

"""Run the course's trigger-based adaptive rebalancing engine."""
function run_rebalancing_engine(asset_returns::AbstractMatrix, signal::AbstractVector,
        β::AbstractVector; adaptive::Bool=true, cost_rate::Real=0.001,
        scheduled_days::Int=21, drift_limit::Real=0.08, drawdown_limit::Real=0.10)
    size(asset_returns, 1) == length(signal) || throw(DimensionMismatch("signal length must match return rows"))
    target0 = adaptive_target_weights(0.0, β)
    holdings = copy(target0)
    wealth = ones(size(asset_returns, 1) + 1)
    peak, turnover, costs, interventions = 1.0, 0.0, 0.0, 0
    for t in axes(asset_returns, 1)
        holdings .*= exp.(asset_returns[t, :])
        before = sum(holdings)
        current = holdings / before
        peak = max(peak, before)
        drawdown = 1 - before / peak
        target = adaptive ? adaptive_target_weights(signal[t], β) : target0
        drift = maximum(abs.(target - current))
        fires = adaptive && (t % scheduled_days == 0 || drift > drift_limit || drawdown > drawdown_limit)
        if fires
            traded = 0.5 * sum(abs.(target - current))
            cost = cost_rate * traded * before
            holdings .= (before - cost) .* target
            turnover += traded
            costs += cost
            interventions += 1
        end
        wealth[t + 1] = sum(holdings)
    end
    peak_path = accumulate(max, wealth)
    return (wealth=wealth, turnover=turnover, costs=costs, interventions=interventions,
        max_drawdown=maximum(1 .- wealth ./ peak_path))
end

"""
    run_utility_engine(prices, target; W0=1000.0, rebalance_days=1:T, cost_rate=5e-4,
        turnover_cap=Inf, drawdown_limit=1.0, reentry_days=21, g_f=0.0, Δt=1/252)

Backtest a self-financing rebalancing engine on a `T × K` matrix of daily close prices (USD/share).
`target(t, state)` returns the desired risky weights `w⋆` (`w⋆ ≥ 0`, `sum(w⋆) ≤ 1`, remainder cash)
and is called only on `t ∈ rebalance_days` when the engine is not locked in cash;
`state = (day, wealth, weights, shares, cash, prices)` where `prices` is a COPY of today's execution
prices `S_t` (known at the close, when the trade executes) and `wealth`, `weights` are marked at `S_t`.
Any SIGNAL the callback uses must be built from information through day `t-1` (next-bar execution);
the engine cannot enforce that, so the notebooks assert it.

Each day: cash accrues `exp(g_f Δt)`; the book is marked to market at `S_t` (wealth `W⁻`); the
drawdown circuit breaker is checked (`1 - W⁻/peak > drawdown_limit` liquidates to cash, bypassing the
turnover cap, and locks the engine for `reentry_days` more days; on the first trade after the lock the
peak is rebased to the current wealth so the breaker does not refire on the old peak); on rebalance
days the change toward `w⋆` is capped at one-way turnover `turnover_cap` and executed at `S_t`, paying
`cost_rate` per unit of gross traded notional, with the risky targets sized on the post-cost budget so
that `cash = (W⁻ - C)(1 - Σ w_target) ≥ 0` and `cash + Σ nᵢ Sᵢ = W⁻ - C` exactly (targets summing to
more than one are rejected; roundoff up to `1e-9` is renormalized, never converted into cash).

Returns `(wealth, cash, shares, weights, turnover, cost, traded, rebalanced, locked, interventions)`;
`wealth`, `cash`, `shares`, `weights` have `T+1` rows (row 1 = day 0). Growth-rate inputs never enter
this function; the price contract removes the Δt ambiguity.
"""
function run_utility_engine(prices::AbstractMatrix, target; W0::Real=1000.0,
        rebalance_days::AbstractVector{<:Integer}=1:size(prices, 1), cost_rate::Real=5e-4,
        turnover_cap::Real=Inf, drawdown_limit::Real=1.0, reentry_days::Integer=21,
        g_f::Real=0.0, Δt::Real=1/252)
    T, K = size(prices)
    T >= 1 && K >= 1 || throw(ArgumentError("prices must have at least one row and one column"))
    all(isfinite, prices) && all(>(0), prices) || throw(ArgumentError("prices must be finite and positive"))
    isfinite(W0) && W0 > 0 || throw(ArgumentError("W0 must be finite and positive"))
    0 <= cost_rate < 0.05 || throw(ArgumentError("cost_rate must lie in [0, 0.05)"))
    turnover_cap > 0 || throw(ArgumentError("turnover_cap must be positive"))
    0 < drawdown_limit <= 1 || throw(ArgumentError("drawdown_limit must lie in (0, 1]"))
    reentry_days >= 0 || throw(ArgumentError("reentry_days must be nonnegative"))
    isfinite(g_f) || throw(ArgumentError("g_f must be finite"))
    isfinite(Δt) && Δt > 0 || throw(ArgumentError("Δt must be finite and positive"))
    rset = Set(Int.(rebalance_days))
    growth = exp(g_f * Δt)
    rebase_peak = false                               # set after a circuit-breaker exit; peak is rebased on the next trade

    wealth = zeros(T + 1); cash = zeros(T + 1)
    shares = zeros(T + 1, K); weights = zeros(T + 1, K)
    turnover = zeros(T); cost = zeros(T); traded = zeros(T)
    rebalanced = falses(T); locked = falses(T)
    wealth[1] = W0; cash[1] = W0
    n = zeros(K); c = Float64(W0); peak = Float64(W0)
    interventions = 0; locked_until = 0

    for t in 1:T
        S = view(prices, t, :)
        c *= growth                                   # cash accrues the risk-free growth
        x⁻ = n .* S                                    # current exposures
        W⁻ = c + sum(x⁻)                               # mark to market
        peak = max(peak, W⁻)
        w⁻ = x⁻ ./ W⁻
        C_t = 0.0; G_t = 0.0; τ_t = 0.0

        # circuit breaker, checked every day
        if t <= locked_until
            locked[t] = true
        elseif 1 - W⁻ / peak > drawdown_limit && sum(x⁻) > 0
            G_t = sum(x⁻); C_t = cost_rate * G_t       # emergency liquidation bypasses the turnover cap
            τ_t = sum(w⁻)                              # risky legs to zero and the cash leg up: one-way
            n .= 0.0; c = W⁻ - C_t
            interventions += 1; locked_until = t + reentry_days; locked[t] = true; rebase_peak = true
        elseif t in rset
            if rebase_peak
                peak = W⁻; rebase_peak = false          # re-entry: the breaker measures drawdown from here
            end
            raw = target(t, (day=t, wealth=W⁻, weights=copy(w⁻), shares=copy(n), cash=c, prices=Vector{Float64}(S)))
            raw isa AbstractVector || throw(ArgumentError("target must return a vector of $K weights"))
            wstar = Vector{Float64}(raw)
            length(wstar) == K || throw(ArgumentError("target must return $K weights"))
            all(isfinite, wstar) && all(>=(0), wstar) || throw(ArgumentError("target weights must be finite and nonnegative"))
            swstar = sum(wstar)
            swstar <= 1 + 1e-9 || throw(ArgumentError("target weights must sum to at most one (got $swstar)"))
            swstar > 1 && (wstar ./= swstar)           # roundoff above one: renormalize, never create cash
            Δw = wstar .- w⁻
            τ_t = 0.5 * sum(abs, Δw) + 0.5 * abs(sum(Δw))       # risky legs + cash leg, one-way
            if τ_t > turnover_cap
                Δw .*= turnover_cap / τ_t; τ_t = turnover_cap
            end
            w_target = w⁻ .+ Δw
            # size on the post-cost budget: x = w_target (W⁻ - C), C = cost_rate Σ|x - x⁻|
            C_t = cost_rate * sum(abs, w_target .* W⁻ .- x⁻)
            converged = cost_rate == 0
            for _ in 1:50
                C_new = cost_rate * sum(abs, w_target .* (W⁻ - C_t) .- x⁻)
                converged = abs(C_new - C_t) <= 1e-13 * max(W⁻, 1.0)
                C_t = C_new
                converged && break
            end
            converged || error("engine cost sizing did not converge on day $t")
            x = w_target .* (W⁻ - C_t)
            G_t = sum(abs, x .- x⁻)
            abs(C_t - cost_rate * G_t) <= 1e-9 * max(W⁻, 1.0) || error("engine cost mismatch on day $t")
            n .= x ./ S
            c = (W⁻ - C_t) * (1 - sum(w_target))      # exact self-financing residual, ≥ 0 by construction
            c >= -1e-12 * W⁻ || error("engine invariant violated: negative cash on day $t")
            c = max(c, 0.0)                            # only roundoff of order 1e-16 W is ever clamped
            rebalanced[t] = true
        end
        wealth[t + 1] = c + dot(n, S); cash[t + 1] = c
        shares[t + 1, :] .= n; weights[t + 1, :] .= (n .* S) ./ wealth[t + 1]
        turnover[t] = τ_t; cost[t] = C_t; traded[t] = G_t
    end
    return (wealth=wealth, cash=cash, shares=shares, weights=weights, turnover=turnover, cost=cost,
        traded=traded, rebalanced=rebalanced, locked=locked, interventions=interventions)
end

"""
    realized_scorecard(wealth; g_f, Δt=1/252, turnover=nothing, cost=nothing, interventions=0)

Score one realized wealth path `W_0, …, W_T` (USD) against a risk-free baseline growing at `g_f`
(1/yr): portfolio NPV `-W_0 + W_T e^{-g_f T}` with `T = (length(wealth)-1) Δt` years, scaled NPV,
maximum drawdown, annualized realized growth `log(W_T/W_0)/T`, annualized realized Sharpe ratio of
the daily log growth in excess of `g_f Δt`, and the totals of the optional per-day `turnover` and
`cost` vectors plus the intervention count.
"""
function realized_scorecard(wealth::AbstractVector; g_f::Real, Δt::Real=1/252,
        turnover=nothing, cost=nothing, interventions::Integer=0)
    length(wealth) >= 2 || throw(ArgumentError("wealth must hold at least two points"))
    all(w -> isfinite(w) && w > 0, wealth) || throw(ArgumentError("wealth must be finite and positive"))
    isfinite(g_f) || throw(ArgumentError("g_f must be finite"))
    isfinite(Δt) && Δt > 0 || throw(ArgumentError("Δt must be finite and positive"))
    turnover === nothing || (length(turnover) == length(wealth) - 1 && all(v -> isfinite(v) && v >= 0, turnover)) ||
        throw(ArgumentError("turnover must have one finite nonnegative entry per day"))
    cost === nothing || (length(cost) == length(wealth) - 1 && all(v -> isfinite(v) && v >= 0, cost)) ||
        throw(ArgumentError("cost must have one finite nonnegative entry per day"))
    W0, WT = Float64(wealth[1]), Float64(wealth[end])
    horizon = (length(wealth) - 1) * Δt
    npv = -W0 + WT * exp(-g_f * horizon)
    peaks = accumulate(max, wealth)
    max_drawdown = maximum(1 .- wealth ./ peaks)
    daily = diff(log.(Float64.(wealth)))
    excess = daily .- g_f * Δt
    sharpe = length(excess) > 1 && std(excess) > 0 ? mean(excess) / std(excess) * sqrt(1 / Δt) : NaN
    return (initial=W0, terminal=WT, horizon_years=horizon, npv=npv, scaled_npv=npv / W0,
        max_drawdown=max_drawdown, realized_growth=log(WT / W0) / horizon, realized_sharpe=sharpe,
        total_turnover=turnover === nothing ? 0.0 : sum(turnover),
        total_cost=cost === nothing ? 0.0 : sum(cost), interventions=Int(interventions))
end

"""
    ensemble_scorecard(terminal, drawdown; W0, g_f, horizon, level=0.05)

Score an ensemble of simulated paths from their terminal wealths and maximum drawdowns: median
terminal wealth and median NPV against `W0 e^{g_f horizon}`, the NPV-fail rate
`P(W_T < W0 e^{g_f horizon})`, the lower terminal-wealth quantile at `level` taken as the order
statistic `k = max(1, ceil(level N))` (so that `P(W_T ≤ q) ≥ level`), the mean of the `k` smallest
terminal wealths (`tail_mean`), the median drawdown and the `k`-th largest drawdown (the upper
order statistic at `level`, so that `P(D ≥ q) ≥ level`).
"""
function ensemble_scorecard(terminal::AbstractVector, drawdown::AbstractVector; W0::Real, g_f::Real,
        horizon::Real, level::Real=0.05)
    N = length(terminal)
    N == length(drawdown) || throw(DimensionMismatch("terminal and drawdown must have equal length"))
    N >= 1 || throw(ArgumentError("the ensemble is empty"))
    0 < level < 1 || throw(ArgumentError("level must lie in (0, 1)"))
    all(isfinite, terminal) && all(isfinite, drawdown) || throw(ArgumentError("terminal and drawdown must be finite"))
    isfinite(W0) && W0 > 0 && isfinite(g_f) && isfinite(horizon) && horizon > 0 ||
        throw(ArgumentError("W0 and horizon must be finite and positive, g_f finite"))
    baseline = W0 * exp(g_f * horizon)
    sorted = sort(Float64.(terminal))
    k = max(1, ceil(Int, prevfloat(Float64(level * N))))   # prevfloat guards 0.07*100 = 7.000000000000001
    sdd = sort(Float64.(drawdown))
    return (median_terminal=median(sorted), median_npv=median(sorted .* exp(-g_f * horizon)) - W0,
        fail_rate=mean(sorted .< baseline), lower_quantile=sorted[k], tail_mean=mean(view(sorted, 1:k)),
        median_drawdown=median(sdd), drawdown_quantile=sdd[N - k + 1], level=Float64(level), k=k)
end

"""
    ewls_init(α₀, β₀, σ_ε₀; half_life=63.0, prior_weight=63.0, market_mean=0.0, market_variance=1.0)

Seed the EWLS sufficient statistics with a calibrated SIM prior `(α₀, β₀, σ_ε₀)` worth
`prior_weight = N₀` pseudo-observations. The prior second-moment matrix is
`A₀ = N₀ E[x xᵀ]` with `x = [1, g_M]`, so `market_mean = m` and `market_variance = v` must be the
TRAINING-period sample mean and variance of the market growth rate (units 1/yr and 1/yr²);
the defaults `(0, 1)` reproduce the legacy standardized-regressor assumption and should not be used
with raw course growth rates. `market_variance` is read as the population variance about the mean;
passing the corrected sample variance instead scales only the variance part of `A₀` (by `N/(N-1)`,
not the whole prior weight), which is immaterial for the course's training sample (2,766 growth observations from 2,767 closes). Before any update the state returns `(α₀, β₀, σ_ε₀)`
exactly, and the same values are recovered from the sufficient statistics. The prior decays like the
data: after `t` updates its weight is `δᵗ N₀`.
"""
function ewls_init(α₀::Real, β₀::Real, σ_ε₀::Real; half_life::Real=63.0, prior_weight::Real=63.0,
        market_mean::Real=0.0, market_variance::Real=1.0)
    half_life > 0 || throw(ArgumentError("half_life must be positive"))
    isfinite(prior_weight) && prior_weight > 0 || throw(ArgumentError("prior_weight must be finite and positive"))
    isfinite(market_variance) && market_variance > 0 || throw(ArgumentError("market_variance must be finite and positive"))
    isfinite(market_mean) || throw(ArgumentError("market_mean must be finite"))
    all(isfinite, (α₀, β₀, σ_ε₀)) && σ_ε₀ >= 0 || throw(ArgumentError("the prior (α₀, β₀, σ_ε₀) must be finite with σ_ε₀ ≥ 0"))
    m, v, N₀ = Float64(market_mean), Float64(market_variance), Float64(prior_weight)
    Exx = v + m^2
    state = MyEWLSState()
    state.Sw = N₀
    state.Swx = N₀ * m
    state.Swxx = N₀ * Exx
    state.Swy = N₀ * (α₀ + β₀ * m)
    state.Swxy = N₀ * (α₀ * m + β₀ * Exx)
    state.Swyy = N₀ * (α₀^2 + 2α₀ * β₀ * m + β₀^2 * Exx + σ_ε₀^2)
    state.δ = 2.0^(-1 / half_life)
    state.α, state.β, state.σ_ε = Float64(α₀), Float64(β₀), Float64(σ_ε₀)
    return state
end

"""Update an EWLS state with one asset/market growth-rate observation."""
function ewls_update!(state::MyEWLSState, g_i::Real, g_m::Real)
    δ = state.δ
    state.Sw = δ * state.Sw + 1
    state.Swx = δ * state.Swx + g_m
    state.Swy = δ * state.Swy + g_i
    state.Swxx = δ * state.Swxx + g_m^2
    state.Swxy = δ * state.Swxy + g_i * g_m
    state.Swyy = δ * state.Swyy + g_i^2
    denom = state.Sw * state.Swxx - state.Swx^2      # ≥ 0 by Cauchy-Schwarz; cancellation can make it tiny or negative
    if denom > 1e-10 * state.Sw * state.Swxx           # relative guard: skip the solve while the regressor is unidentified
        state.β = (state.Sw * state.Swxy - state.Swx * state.Swy) / denom
        state.α = (state.Swy - state.β * state.Swx) / state.Sw
        mse = (state.Swyy - 2state.β * state.Swxy - 2state.α * state.Swy +
            state.β^2 * state.Swxx + 2state.α * state.β * state.Swx + state.α^2 * state.Sw) / state.Sw
        state.σ_ε = sqrt(max(mse, 0.0))
    end
    return state.α, state.β, state.σ_ε
end

"""
    ewls_path(x, y; half_life=60.0, prior=nothing, prior_weight=nothing, warmup=63)

Run the EWLS recursion (`ewls_init` + `ewls_update!`) over paired observations `x` (market growth
rate) and `y` (asset growth rate) and return an `n × 3` matrix whose row `t` holds `(α, β, σ_ε)`
after observation `t`. `prior` is a NamedTuple `(α, β, σ_ε, market_mean, market_variance)` and
`prior_weight` its weight in pseudo-observations `N₀` (defaults to `warmup`). When `prior === nothing`
the prior is a batch OLS on the first `k = min(warmup, n)` observations, the recursion starts at
observation `k+1`, and rows `1:k` are `NaN` (no estimate is reported for a day whose value would use
later data). The warm-up seed reproduces the expanding-window OLS coefficients exactly (the seeded
`A₀`, `b₀` are the warm-up sample's `Σxxᵀ`, `Σxy`); its `c₀` uses the dof-corrected residual
variance, so the seeded residual variance exceeds the raw warm-up RSS/k by a factor `k/(k-2)`. The L7b
examples use the warm-up seed for the walk-forward half-life search and an explicit archive prior
for the 2025 replay. Units follow the inputs (annualized growth rates in the course notebooks).
"""
function ewls_path(x::AbstractVector, y::AbstractVector; half_life::Real=60.0,
        prior::Union{Nothing,NamedTuple}=nothing, prior_weight::Union{Nothing,Real}=nothing,
        warmup::Integer=63)
    length(x) == length(y) || throw(DimensionMismatch("x and y must have equal length"))
    half_life > 0 || throw(ArgumentError("half_life must be positive"))
    n = length(y)
    n >= 3 || throw(ArgumentError("at least three observations are required"))
    first = 1
    if prior === nothing
        k = min(Int(warmup), n)
        3 <= k < n || throw(ArgumentError("warmup must cover at least three observations and leave data to update on"))
        fit = estimate_sim(view(x, 1:k), view(y, 1:k), "warmup")
        prior = (α=fit.α, β=fit.β, σ_ε=fit.σ_ε, market_mean=mean(view(x, 1:k)),
            market_variance=var(view(x, 1:k); corrected=false))
        prior_weight === nothing && (prior_weight = k)
        first = k + 1
    end
    prior_weight === nothing && (prior_weight = warmup)
    state = ewls_init(prior.α, prior.β, prior.σ_ε; half_life=half_life, prior_weight=prior_weight,
        market_mean=prior.market_mean, market_variance=prior.market_variance)
    estimates = fill(NaN, n, 3)
    for t in first:n
        α, β, σ = ewls_update!(state, y[t], x[t])
        estimates[t, 1], estimates[t, 2], estimates[t, 3] = α, β, σ
    end
    return estimates
end

"""Evaluate named minimum/maximum validation rules and return a reproducible gate report."""
function evaluate_validation_gates(metrics::AbstractDict, limits::AbstractDict)
    keys(metrics) == keys(limits) || Set(keys(metrics)) == Set(keys(limits)) ||
        throw(ArgumentError("metrics and limits must use the same gate names"))
    report = NamedTuple[]
    for gate in sort!(collect(keys(metrics)))
        observed, rule = Float64(metrics[gate]), limits[gate]
        rule.operator in (:minimum, :maximum) || throw(ArgumentError("unsupported operator $(rule.operator)"))
        passed = rule.operator == :minimum ? observed >= rule.value : observed <= rule.value
        push!(report, (gate=String(gate), observed=observed, operator=String(rule.operator),
            limit=Float64(rule.value), result=passed ? "PASS" : "FAIL"))
    end
    return (report=report, overall=all(row.result == "PASS" for row in report) ? "PASS" : "FAIL")
end

"""Route a proposed portfolio event to APPROVE, REVIEW, or BLOCK."""
function route_portfolio_event(event, portfolio_drawdown::Real, limits, turnover_review::Bool)
    if event.proposed_weight > limits.max_position_weight
        return (route="BLOCK", reason="position limit")
    end
    reasons = String[]
    event.news_severity > limits.news_severity_escalation && push!(reasons, "news severity")
    portfolio_drawdown > limits.drawdown_escalation && push!(reasons, "portfolio drawdown")
    turnover_review && push!(reasons, "portfolio turnover")
    return isempty(reasons) ? (route="APPROVE", reason="within limits") :
        (route="REVIEW", reason=join(reasons, "; "))
end
