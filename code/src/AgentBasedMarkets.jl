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
