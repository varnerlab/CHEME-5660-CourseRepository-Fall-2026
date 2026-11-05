# Agent-based market models for CHEME 5660 L12a: the thermal minority game and the
# Farmer–Joshi market. Each model has a `build(...)` method that takes a NamedTuple and a
# `solve(...)` method that runs the simulation.

# ---------------------------------------------------------------------------------------- #
# Thermal minority game
# ---------------------------------------------------------------------------------------- #

"""
    mutable struct MyThermalMinorityGameModel <: AbstractAgentModel

A minority game with `N` agents in which each agent chooses among its strategies with
Boltzmann (softmax) probabilities set by a temperature.

Each round, every agent chooses buy (``+1``) or sell (``-1``). The attendance is
``A(t)=\\sum_{i}a_{i}(t)``, and agents on the minority side, ``-\\text{sign}(A)``, win. Every
agent sees the same information ``\\mu(t)\\in\\{1,\\dots,P\\}``, with ``P=2^{m}``, and holds
``S`` strategies; a strategy is a lookup table that maps each ``\\mu`` to an action.

### Fields
- `N::Int`: number of agents (odd, so ``A(t)`` is never zero).
- `m::Int`: memory, the number of past minority actions in the information; ``P=2^{m}``.
- `S::Int`: number of strategies per agent.
- `temperature::Float64`: the temperature of the Boltzmann choice rule (dimensionless,
  in units of the score). `0.0` gives the best-scoring strategy, `Inf` a uniform choice.
- `information::Symbol`: `:history` (the last `m` minority actions) or `:random`
  (``\\mu`` drawn uniformly each round).
- `strategies::Array{Int8,3}`: actions ``a_{is}^{\\mu}\\in\\{-1,+1\\}``, sized `N`×`S`×`P`.

Scores use the binary-model normalization of Challet, Marsili, and Zecchina (2000),
``U_{is}(t+1)=U_{is}(t)-a_{is}^{\\mu(t)}A(t)/P``, so the temperature here is measured in
those units.
"""
mutable struct MyThermalMinorityGameModel <: AbstractAgentModel
    N::Int
    m::Int
    S::Int
    temperature::Float64
    information::Symbol
    strategies::Array{Int8,3}
end

"""
    boltzmann_weights(scores::AbstractVector{<:Real}, temperature::Real) -> Vector{Float64}

Return the Boltzmann (softmax) probabilities
``p_{s}=\\exp(U_{s}/T)/\\sum_{k}\\exp(U_{k}/T)`` for the scores ``U_{s}`` at temperature ``T``.
These maximize the entropy ``-\\sum_{s}p_{s}\\ln p_{s}`` for a fixed expected score.

At `temperature = 0` the probability is shared equally among the highest scores; at
`temperature = Inf` it is uniform. Throws an `ArgumentError` for a negative or `NaN`
temperature.
"""
function boltzmann_weights(scores::AbstractVector{<:Real}, temperature::Real)::Vector{Float64}
    isempty(scores) && throw(ArgumentError("scores must not be empty"))
    (isnan(temperature) || temperature < 0) &&
        throw(ArgumentError("temperature must be nonnegative and not NaN"))
    U = Float64.(scores)
    all(isfinite, U) || throw(ArgumentError("scores must be finite"))
    n = length(U)
    if isinf(temperature)
        return fill(1.0 / n, n)
    elseif temperature == 0
        best = maximum(U)
        w = Float64.(U .== best)
        return w ./ sum(w)
    end
    z = U ./ temperature
    z .-= maximum(z)            # log-sum-exp shift: the largest exponent is zero
    w = exp.(z)
    return w ./ sum(w)
end

"""
    build(modeltype::Type{MyThermalMinorityGameModel}, data::NamedTuple) -> MyThermalMinorityGameModel

Build a thermal minority game and draw every agent's strategies uniformly at random.

### Arguments
- `data::NamedTuple` with keys `N::Integer` (odd, ≥ 1), `m::Integer` (1 to 20), and optional
  `S::Integer = 2` (≥ 2), `temperature::Real = 0.0` (≥ 0, `Inf` allowed),
  `information::Symbol = :history` (or `:random`), and `rng::AbstractRNG = Random.default_rng()`.

Throws an `ArgumentError` for invalid inputs.
"""
function build(modeltype::Type{MyThermalMinorityGameModel}, data::NamedTuple)::MyThermalMinorityGameModel
    N = get(data, :N, nothing)
    m = get(data, :m, nothing)
    S = get(data, :S, 2)
    temperature = get(data, :temperature, 0.0)
    information = get(data, :information, :history)
    rng = get(data, :rng, Random.default_rng())

    (N isa Integer && !(N isa Bool) && N >= 1 && isodd(N)) ||
        throw(ArgumentError("N must be a positive odd integer"))
    (m isa Integer && !(m isa Bool) && 1 <= m <= 20) ||
        throw(ArgumentError("m must be an integer from 1 to 20"))
    (S isa Integer && !(S isa Bool) && S >= 2) ||
        throw(ArgumentError("S must be an integer of at least 2"))
    (temperature isa Real && !isnan(temperature) && temperature >= 0) ||
        throw(ArgumentError("temperature must be a nonnegative real number"))
    information in (:history, :random) ||
        throw(ArgumentError("information must be :history or :random"))

    P = 2^m
    strategies = Int8.(rand(rng, (-1, 1), N, S, P))
    return MyThermalMinorityGameModel(Int(N), Int(m), Int(S), Float64(temperature), information, strategies)
end

# draw one strategy index for an agent from its scores at the model temperature
function _mg_choose(rng::AbstractRNG, scores::AbstractVector{Float64}, temperature::Float64)::Int
    S = length(scores)
    if isinf(temperature)
        return rand(rng, 1:S)
    elseif temperature == 0
        best = maximum(scores)
        candidates = findall(==(best), scores)
        return length(candidates) == 1 ? candidates[1] : rand(rng, candidates)
    end
    w = boltzmann_weights(scores, temperature)
    u = rand(rng)
    acc = 0.0
    for s in 1:S
        acc += w[s]
        u <= acc && return s
    end
    return S
end

"""
    solve(model::MyThermalMinorityGameModel; number_of_rounds::Int, burn_in::Int = 0,
        rng::AbstractRNG = Random.default_rng(), initial_information = nothing) -> NamedTuple

Play the minority game for `burn_in + number_of_rounds` rounds and return the last
`number_of_rounds`.

Each round: every agent draws a strategy with [`boltzmann_weights`](@ref) of its scores,
plays that strategy's action for the current information ``\\mu(t)``, the attendance
``A(t)=\\sum_{i}a_{i}(t)`` is formed, and every strategy's score is updated as
``U_{is}(t+1)=U_{is}(t)-a_{is}^{\\mu(t)}A(t)/P``. With `information = :history`, the new
minority action ``-\\text{sign}(A)`` becomes the lowest bit of the next ``\\mu``.

### Arguments
- `number_of_rounds::Int`: rounds to return (≥ 1).
- `burn_in::Int = 0`: rounds played first and discarded (≥ 0).
- `rng`: random number generator.
- `initial_information`: ``\\mu`` for the first round (1 to ``P``); drawn at random if `nothing`.

### Returns
A `NamedTuple` with `attendance::Vector{Int}` and `information::Vector{Int}` for the returned
rounds, `volatility_per_agent::Float64` ``=\\langle A^{2}\\rangle/N`` over those rounds (1 for
independent coin-flipping agents), `alpha::Float64` ``=P/N``, and
`final_scores::Matrix{Float64}` (`N`×`S`).
"""
function solve(model::MyThermalMinorityGameModel; number_of_rounds::Int, burn_in::Int = 0,
        rng::AbstractRNG = Random.default_rng(), initial_information::Union{Nothing,Integer} = nothing)
    number_of_rounds >= 1 || throw(ArgumentError("number_of_rounds must be at least 1"))
    burn_in >= 0 || throw(ArgumentError("burn_in must be nonnegative"))
    N, S, P = model.N, model.S, 2^model.m
    size(model.strategies) == (N, S, P) || throw(ArgumentError("strategies must be sized N×S×2^m"))

    μ = isnothing(initial_information) ? rand(rng, 1:P) : Int(initial_information)
    1 <= μ <= P || throw(ArgumentError("initial_information must be in 1:P"))

    scores = zeros(Float64, N, S)
    choice = zeros(Int, N)
    total = burn_in + number_of_rounds
    attendance = Vector{Int}(undef, number_of_rounds)
    information = Vector{Int}(undef, number_of_rounds)
    strategies = model.strategies

    for t in 1:total
        # each agent chooses a strategy and plays its action for μ
        A = 0
        for i in 1:N
            s = _mg_choose(rng, view(scores, i, :), model.temperature)
            choice[i] = s
            A += strategies[i, s, μ]
        end
        if t > burn_in
            attendance[t - burn_in] = A
            information[t - burn_in] = μ
        end
        # virtual scoring of every strategy
        for s in 1:S, i in 1:N
            scores[i, s] -= strategies[i, s, μ] * A / P
        end
        # next information
        if model.information == :history
            bit = A < 0 ? 1 : 0          # minority action -sign(A): +1 → 1, -1 → 0
            μ = ((((μ - 1) << 1) & (P - 1)) | bit) + 1
        else
            μ = rand(rng, 1:P)
        end
    end

    return (attendance = attendance, information = information,
        volatility_per_agent = mean(abs2, attendance) / N, alpha = P / N, final_scores = scores)
end

# ---------------------------------------------------------------------------------------- #
# Farmer–Joshi market
# ---------------------------------------------------------------------------------------- #

"""
    mutable struct MyFarmerJoshiMarketModel <: AbstractAgentModel

The agent-based market of Farmer and Joshi (2002), "The price dynamics of common trading
strategies", J. Econ. Behav. Organ. 49, 149–171. Value investors and trend followers trade
through a market maker who moves the log price in proportion to the net order.

Each trader uses a state-dependent threshold strategy (the paper's Section 3.2.4): a position
of size ``c=a(T-\\tau)`` is entered when a signal crosses the entry threshold ``T`` and
held until it crosses the exit threshold ``\\tau`` (see [`threshold_position`](@ref)).

### Fields
- `a::Float64`, `λ::Float64`: capital scale and liquidity (shared).
- `σ_ξ::Float64`: standard deviation of the price noise ``\\xi``.
- `σ_η::Float64`, `μ_η::Float64`: standard deviation and mean of the reference-value steps ``\\eta``.
- `value_entry`, `value_exit`, `value_capital`, `value_offset::Vector{Float64}`: each value
  investor's entry threshold ``T``, exit threshold ``\\tau``, position size ``c``, and
  offset ``v^{(i)}`` of its perceived log value from the reference ``v_{t}``.
- `trend_entry`, `trend_exit`, `trend_capital::Vector{Float64}` and `trend_lag::Vector{Int}`:
  each trend follower's thresholds, position size, and lag ``\\theta`` (time steps).
"""
mutable struct MyFarmerJoshiMarketModel <: AbstractAgentModel
    a::Float64
    λ::Float64
    σ_ξ::Float64
    σ_η::Float64
    μ_η::Float64
    value_entry::Vector{Float64}
    value_exit::Vector{Float64}
    value_capital::Vector{Float64}
    value_offset::Vector{Float64}
    trend_entry::Vector{Float64}
    trend_exit::Vector{Float64}
    trend_capital::Vector{Float64}
    trend_lag::Vector{Int}
end

"""
    threshold_position(current::Float64, signal::Float64, entry::Float64, exit::Float64,
        capital::Float64, direction::Int) -> Float64

Return a trader's next position under the threshold strategy of Farmer and Joshi (2002),
Section 3.2.4. The position is ``-c``, ``0``, or ``+c`` with ``c=`` `capital`.

- Value investor (`direction = -1`), `signal` = mispricing ``m=p_{t}-v_{t}^{(i)}``: from zero,
  go short if ``m>T`` and long if ``m<-T``; exit a short when ``m<\\tau`` and a long when ``m>-\\tau``.
- Trend follower (`direction = +1`), `signal` = ``p_{t}-p_{t-\\theta}``: from zero, go long if
  the signal is above ``T`` and short if below ``-T``; exit a long when it falls below ``\\tau``
  and a short when it rises above ``-\\tau``.

All comparisons are strict. Here ``T=`` `entry` and ``\\tau=`` `exit`.
"""
function threshold_position(current::Float64, signal::Float64, entry::Float64, exit::Float64,
        capital::Float64, direction::Int)::Float64
    direction in (-1, 1) || throw(ArgumentError("direction must be -1 (value) or +1 (trend)"))
    z = direction * signal          # positive z favors a long position
    if current == 0.0
        z > entry && return capital
        z < -entry && return -capital
        return 0.0
    elseif current > 0.0
        return z < exit ? 0.0 : current
    else
        return z > -exit ? 0.0 : current
    end
end

# trend signal p_t - p_{t-θ} at array index k (log_price[k] holds p_{k-1}); nothing while t < θ
function _fj_trend_signal(log_price::AbstractVector{Float64}, k::Int, θ::Int)::Union{Nothing,Float64}
    t = k - 1
    t < θ && return nothing
    return log_price[k] - log_price[k - θ]
end

"""
    build(modeltype::Type{MyFarmerJoshiMarketModel}, data::NamedTuple) -> MyFarmerJoshiMarketModel

Build a Farmer–Joshi market and draw each trader's thresholds, offset, and lag. Defaults
are the paper's Table 1.

### Arguments (all optional)
- Per group, with prefix `value_` or `trend_`: `number = 1200`, `T_min = 0.2`, `T_max = 4.0`,
  `τ_min = -0.2`, `τ_max = 0.0`, `a = 2.5e-3`. Entry thresholds ``T`` are uniform on
  `[T_min, T_max]`, exit thresholds ``\\tau`` uniform on `[τ_min, τ_max]`, and ``c=a(T-\\tau)``.
- `value_v_min = -2.0`, `value_v_max = 2.0`: range of the perceived-value offsets.
- `trend_θ_min = 1`, `trend_θ_max = 100`: range of the integer lags.
- Shared: `σ_ξ = 0.35`, `λ = 1.0`, `σ_η = 0.01`, `μ_η = 0.0`, `rng = Random.default_rng()`.
  The paper drives the reference value with a data path in its Table 1 run; `σ_η` and `μ_η`
  are used only when `solve` is not given `log_value_path`.
"""
function build(modeltype::Type{MyFarmerJoshiMarketModel}, data::NamedTuple)::MyFarmerJoshiMarketModel
    rng = get(data, :rng, Random.default_rng())
    σ_ξ = Float64(get(data, :σ_ξ, 0.35)); λ = Float64(get(data, :λ, 1.0))
    σ_η = Float64(get(data, :σ_η, 0.01)); μ_η = Float64(get(data, :μ_η, 0.0))
    (σ_ξ >= 0 && σ_η >= 0 && isfinite(μ_η)) || throw(ArgumentError("σ_ξ and σ_η must be nonnegative"))
    λ > 0 || throw(ArgumentError("λ must be positive"))

    function group(prefix::String)
        key(s) = Symbol(prefix * s)
        n = get(data, key("number"), 1200)
        T_min = Float64(get(data, key("T_min"), 0.2)); T_max = Float64(get(data, key("T_max"), 4.0))
        τ_min = Float64(get(data, key("τ_min"), -0.2)); τ_max = Float64(get(data, key("τ_max"), 0.0))
        a = Float64(get(data, key("a"), 2.5e-3))
        (n isa Integer && n >= 0) || throw(ArgumentError("$(prefix)number must be a nonnegative integer"))
        (0 < T_min <= T_max) || throw(ArgumentError("$(prefix)T_min must be positive and at most T_max"))
        (τ_min <= τ_max < T_min) || throw(ArgumentError("$(prefix)τ_min ≤ τ_max < T_min is required"))
        a > 0 || throw(ArgumentError("$(prefix)a must be positive"))
        entry = T_min .+ (T_max - T_min) .* rand(rng, n)
        exit = τ_min .+ (τ_max - τ_min) .* rand(rng, n)
        return entry, exit, a .* (entry .- exit), a, n
    end

    value_entry, value_exit, value_capital, a, n_value = group("value_")
    trend_entry, trend_exit, trend_capital, _, n_trend = group("trend_")
    v_min = Float64(get(data, :value_v_min, -2.0)); v_max = Float64(get(data, :value_v_max, 2.0))
    v_min <= v_max || throw(ArgumentError("value_v_min must be at most value_v_max"))
    θ_min = get(data, :trend_θ_min, 1); θ_max = get(data, :trend_θ_max, 100)
    (θ_min isa Integer && θ_max isa Integer && 1 <= θ_min <= θ_max) ||
        throw(ArgumentError("trend lags must be integers with 1 ≤ θ_min ≤ θ_max"))
    value_offset = v_min .+ (v_max - v_min) .* rand(rng, n_value)
    trend_lag = rand(rng, Int(θ_min):Int(θ_max), n_trend)

    return MyFarmerJoshiMarketModel(a, λ, σ_ξ, σ_η, μ_η, value_entry, value_exit, value_capital,
        value_offset, trend_entry, trend_exit, trend_capital, trend_lag)
end

"""
    solve(model::MyFarmerJoshiMarketModel; number_of_steps::Int, burn_in::Int = 0,
        rng::AbstractRNG = Random.default_rng(), p₀::Float64 = 0.0, v₀::Float64 = 0.0,
        log_value_path = nothing) -> NamedTuple

Simulate the market for `burn_in + number_of_steps` steps and return the last
`number_of_steps`. Each step, in order:

1. every trader sets its next position ``x_{t+1}^{(i)}`` from ``p_{t}`` (and ``v_{t}``) with [`threshold_position`](@ref);
2. its order is ``\\omega_{t+1}^{(i)}=x_{t+1}^{(i)}-x_{t}^{(i)}`` (Eq. 1);
3. the market maker sets ``p_{t+1}=p_{t}+\\lambda^{-1}\\sum_{i}\\omega_{t+1}^{(i)}+\\xi_{t+1}`` (Eq. 7);
4. the reference log value advances, ``v_{t+1}=v_{t}+\\eta_{t+1}`` (Eq. 13), or is read from `log_value_path`.

A value investor perceives ``v_{t}^{(i)}=v_{t}+v^{(i)}`` (Eq. 18). A trend follower holds no
position until ``t\\geq\\theta``.

### Arguments
- `log_value_path`: optional reference log values ``v_{0},v_{1},\\dots``; its length must be at
  least `burn_in + number_of_steps + 1`.

### Returns
A `NamedTuple` with `log_price` and `log_value` (`number_of_steps + 1` values),
`returns` ``=p_{t+1}-p_{t}`` (`number_of_steps` values), and `value_volume` and
`trend_volume`, the total absolute order ``\\sum_{i}|\\omega_{t}^{(i)}|`` of each group per step.
"""
function solve(model::MyFarmerJoshiMarketModel; number_of_steps::Int, burn_in::Int = 0,
        rng::AbstractRNG = Random.default_rng(), p₀::Float64 = 0.0, v₀::Float64 = 0.0,
        log_value_path::Union{Nothing,AbstractVector{<:Real}} = nothing)
    number_of_steps >= 1 || throw(ArgumentError("number_of_steps must be at least 1"))
    burn_in >= 0 || throw(ArgumentError("burn_in must be nonnegative"))
    total = burn_in + number_of_steps
    if !isnothing(log_value_path)
        length(log_value_path) >= total + 1 ||
            throw(ArgumentError("log_value_path needs at least burn_in + number_of_steps + 1 values"))
    end

    p = Vector{Float64}(undef, total + 1)
    v = Vector{Float64}(undef, total + 1)
    p[1] = p₀
    v[1] = isnothing(log_value_path) ? v₀ : Float64(log_value_path[1])
    value_volume = zeros(Float64, total)
    trend_volume = zeros(Float64, total)
    x_value = zeros(Float64, length(model.value_entry))
    x_trend = zeros(Float64, length(model.trend_entry))

    for k in 1:total                       # step from p_{k-1} (index k) to p_k (index k+1)
        net_order = 0.0
        for i in eachindex(x_value)
            m = p[k] - (v[k] + model.value_offset[i])
            x_new = threshold_position(x_value[i], m, model.value_entry[i], model.value_exit[i],
                model.value_capital[i], -1)
            ω = x_new - x_value[i]
            net_order += ω; value_volume[k] += abs(ω); x_value[i] = x_new
        end
        for j in eachindex(x_trend)
            s = _fj_trend_signal(p, k, model.trend_lag[j])
            isnothing(s) && continue
            x_new = threshold_position(x_trend[j], s, model.trend_entry[j], model.trend_exit[j],
                model.trend_capital[j], +1)
            ω = x_new - x_trend[j]
            net_order += ω; trend_volume[k] += abs(ω); x_trend[j] = x_new
        end
        p[k + 1] = p[k] + net_order / model.λ + model.σ_ξ * randn(rng)
        v[k + 1] = isnothing(log_value_path) ? v[k] + model.μ_η + model.σ_η * randn(rng) :
            Float64(log_value_path[k + 1])
    end

    kept = (burn_in + 1):(total + 1)
    log_price = p[kept]
    return (log_price = log_price, log_value = v[kept], returns = diff(log_price),
        value_volume = value_volume[(burn_in + 1):total], trend_volume = trend_volume[(burn_in + 1):total])
end
