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
    η::Float64
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

"""Initialize EWLS sufficient statistics from a calibrated SIM prior."""
function ewls_init(α₀::Real, β₀::Real, σ_ε₀::Real; half_life::Real=63.0, prior_weight::Real=63.0)
    half_life > 0 || throw(ArgumentError("half_life must be positive"))
    prior_weight > 0 || throw(ArgumentError("prior_weight must be positive"))
    state = MyEWLSState()
    state.Sw, state.Swx = prior_weight, 0.0
    state.Swy, state.Swxx = prior_weight * α₀, prior_weight
    state.Swxy = prior_weight * β₀
    state.Swyy = prior_weight * (α₀^2 + β₀^2 + σ_ε₀^2)
    state.η = 2.0^(-1 / half_life)
    state.α, state.β, state.σ_ε = α₀, β₀, σ_ε₀
    return state
end

"""Update an EWLS state with one asset/market growth-rate observation."""
function ewls_update!(state::MyEWLSState, g_i::Real, g_m::Real)
    η = state.η
    state.Sw = η * state.Sw + 1
    state.Swx = η * state.Swx + g_m
    state.Swy = η * state.Swy + g_i
    state.Swxx = η * state.Swxx + g_m^2
    state.Swxy = η * state.Swxy + g_i * g_m
    state.Swyy = η * state.Swyy + g_i^2
    denom = state.Sw * state.Swxx - state.Swx^2
    if abs(denom) > 1e-12
        state.β = (state.Sw * state.Swxy - state.Swx * state.Swy) / denom
        state.α = (state.Swy - state.β * state.Swx) / state.Sw
        mse = (state.Swyy - 2state.β * state.Swxy - 2state.α * state.Swy +
            state.β^2 * state.Swxx + 2state.α * state.β * state.Swx + state.α^2 * state.Sw) / state.Sw
        state.σ_ε = sqrt(max(mse, 0.0))
    end
    return state.α, state.β, state.σ_ε
end

"""Return the recursive ridge-EWLS intercept and slope path used in lecture replay."""
function ewls_path(x::AbstractVector, y::AbstractVector; half_life::Real=60.0, ridge::Real=1e-6)
    length(x) == length(y) || throw(DimensionMismatch("x and y must have equal length"))
    half_life > 0 || throw(ArgumentError("half_life must be positive"))
    λ = 2.0^(-1 / half_life)
    A = ridge * Matrix{Float64}(I, 2, 2)
    b = zeros(2)
    estimates = Matrix{Float64}(undef, length(y), 2)
    for t in eachindex(y)
        row = [1.0, x[t]]
        A .= λ .* A .+ row * row'
        b .= λ .* b .+ row .* y[t]
        estimates[t, :] .= A \ b
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
