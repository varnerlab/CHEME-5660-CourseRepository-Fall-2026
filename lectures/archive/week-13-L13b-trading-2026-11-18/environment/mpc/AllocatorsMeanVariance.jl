# Min-variance and tangent (maximum growth-Sharpe) rules, the investable fraction, and the
# expected-growth vector every rule feeds into its problem.
#
# Units as in Allocators.jl: shares n (shares), prices S (USD/share), equity W (USD), weights
# w = n·S/W (dimensionless), μ_g and g_f (yr⁻¹), Σ_g (yr⁻²). Neither rule uses γ: every name is free
# (n ≥ 0, no ε pins).
#
# Both rules follow two-fund separation (ruling R24): choose the risky MIX at Σw = s_dir, the largest
# investment the budget, per-name, sector and turnover limits allow (no volatility cone; usually 1),
# then SCALE it by c = min(1, σ_g_max/σ(mix)) and hold the rest as cash. (Forcing Σw to the largest
# investment the volatility cap allows, ruling R22, left a single feasible portfolio whenever the cap
# bound, so the two rules coincided.)

"""
    MyMinVarRule

Minimum variance, two-fund form (R24): the mix minimizes wᵀΣ_g w (yr⁻²) at Σwᵢ = s_dir
(`max_investable`) under the shared constraints without the volatility cap, then is scaled down onto
σ_g_max. No parameters; γ plays no role.
"""
mutable struct MyMinVarRule <: AbstractPortfolioRule
    MyMinVarRule() = new()
end

"""
    MyTangentRule

Tangent (maximum growth-Sharpe), two-fund form (R24): the mix maximizes (μ_g − g_f)ᵀw / √(wᵀΣ_g w)
(dimensionless) at Σwᵢ = s_dir under the shared constraints without the volatility cap, then is scaled
down onto σ_g_max. Field `zero_alpha::Bool` (default `false`): when `true`, `expected_growth` drops α
and uses μ_g = β·ḡ_M. γ plays no role.
"""
mutable struct MyTangentRule <: AbstractPortfolioRule
    zero_alpha::Bool
    MyTangentRule() = new(false)
end

"""
    build(::Type{MyMinVarRule}, data::NamedTuple)::MyMinVarRule

Build a min-variance rule (no fields; `data` is ignored).
"""
build(::Type{MyMinVarRule}, data::NamedTuple)::MyMinVarRule = MyMinVarRule()

"""
    build(::Type{MyTangentRule}, data::NamedTuple)::MyTangentRule

Build a tangent rule from `MyTangentRule()` (zero_alpha = false), overriding `zero_alpha::Bool` when
`data` has it.
"""
function build(::Type{MyTangentRule}, data::NamedTuple)::MyTangentRule
    model = MyTangentRule()
    if haskey(data, :zero_alpha)
        data.zero_alpha isa Bool ||
            throw(ArgumentError("zero_alpha must be a Bool, got $(repr(data.zero_alpha))"))
        model.zero_alpha = data.zero_alpha
    end
    return model
end

"""
    expected_growth(rule::AbstractPortfolioRule, α::AbstractVector, β::AbstractVector, ḡ_M::Real)::Vector{Float64}

Expected growth μ_g,i = αᵢ + βᵢ·ḡ_M (yr⁻¹), with α the SIM intercepts (yr⁻¹), β the SIM betas
(dimensionless) and ḡ_M the trailing 252-day mean SPY growth rate (yr⁻¹). `MyTangentRule` with
`zero_alpha = true` returns βᵢ·ḡ_M.
"""
function expected_growth(rule::AbstractPortfolioRule, α::AbstractVector, β::AbstractVector,
        ḡ_M::Real)::Vector{Float64}
    _check_sim_lengths(α, β)
    return Float64.(α .+ β .* ḡ_M)
end

function expected_growth(rule::MyTangentRule, α::AbstractVector, β::AbstractVector,
        ḡ_M::Real)::Vector{Float64}
    _check_sim_lengths(α, β)
    return rule.zero_alpha ? Float64.(β .* ḡ_M) : Float64.(α .+ β .* ḡ_M)
end

_check_sim_lengths(α, β) = length(α) == length(β) ||
    throw(DimensionMismatch("α and β must have the same length, got $(length(α)) and $(length(β))"))

# Tolerance on Σw = s_dir (dimensionless): the mix solves impose s_dir − _S_TOL ≤ Σw, and the shared
# constraints already cap Σw at s_dir, so the solver never meets a marginally infeasible equality.
const _S_TOL = 1e-7

# Below this fraction of the largest attainable excess growth s_dir·max|eᵢ| (yr⁻¹), the best feasible
# excess growth counts as zero (solver tolerance): the tangent rule then falls back to min-variance.
const _MIN_EXCESS_REL = 1e-6

# Relative slack (dimensionless) on the turnover budget when re-checking a scaled-down mix: the mix
# itself meets the budget only to solver tolerance.
const _TURNOVER_RTOL = 1e-7

# Copy of p with the volatility cap switched off (σ_g_max = Inf: add_shared_constraints! then adds no
# cone). Every other limit (the β cap included), n_prev and the hedge flags are unchanged.
function _without_vol_cap(p::MyAllocationProblem)::MyAllocationProblem
    c = p.constraints
    cs = build(MyConstraintSet, (w_max=c.w_max, s_max=c.s_max, σ_g_max=Inf, K_turnover=c.K_turnover,
        c̄=c.c̄, sector=c.sector, n_prev=c.n_prev, ε=c.ε, β=c.β, β_max=c.β_max, w_cap=c.w_cap))
    return build(MyAllocationProblem, (γ=p.γ, μ_g=p.μ_g, Σ_g=p.Σ_g, prices=p.prices, W=p.W, g_f=p.g_f,
        constraints=cs, hedge=p.hedge))
end

# Model over free shares n ≥ 0 (no pins) under the shared constraints of p; returns (m, n, w). With
# `s` given, also Σw ≥ s − _S_TOL.
function _free_model(opt, p::MyAllocationProblem; s::Union{Nothing,Float64}=nothing)
    m = Model(opt)
    set_silent(m)
    n = @variable(m, [1:length(p.γ)], lower_bound = 0.0)
    w = add_shared_constraints!(m, n, p)
    s === nothing || @constraint(m, sum(w) >= s - _S_TOL)
    return m, n, w
end

# max Σw under p's shared constraints, clamped to [0, 1], and the solve status (:optimal, or
# :infeasible / :solver_failed with NaN).
function _max_investable(p::MyAllocationProblem)::Tuple{Float64,Symbol}
    x, status = _solve_with_fallback(function (opt)
        m, n, w = _free_model(opt, p)
        @objective(m, Max, sum(w))
        return m, n
    end)
    status == :optimal || return (NaN, status)
    return (clamp(sum(x .* p.prices) / p.W, 0.0, 1.0), :optimal)
end

"""
    max_investable(p::MyAllocationProblem; vol_cap::Bool=false)::Float64

Largest investable fraction of equity (dimensionless) over long-only shares n ≥ 0 (no ε pins):
s_dir = min(1, max Σwᵢ) subject to the budget, per-name cap, sector cap, β cap and turnover budget
of `add_shared_constraints!`. With `vol_cap=true` the volatility cone √(wᵀΣ_g w) ≤ σ_g_max (yr⁻¹) is
included as well. s_dir sets the size of the min-variance and tangent mixes (R24). Returns `NaN`
when the limits have no feasible point (or both solvers fail); the rules then report `:infeasible` /
`:solver_failed` and keep the previous holdings.
"""
function max_investable(p::MyAllocationProblem; vol_cap::Bool=false)::Float64
    _check_problem(p)
    return first(_max_investable(vol_cap ? p : _without_vol_cap(p)))
end

# R24 scale: w = c·w_mix with c = min(1, σ_g_max/√(w_mixᵀΣ_g w_mix)), the rest cash. Down-scaling keeps
# the budget, per-name and sector rows, and the β row when β_max ≥ 0 (the study settings require
# beta_min ≥ 0); turnover can change, so a scaled n (c < 1) that breaks the budget keeps n_prev with
# :infeasible. s_star = Σw of the returned portfolio.
function _scale_to_vol_cap(p::MyAllocationProblem, n_mix::AbstractVector, status::Symbol)::MyAllocationResult
    cs = p.constraints
    w_mix = n_mix .* p.prices ./ p.W
    σ_mix = sqrt(max(dot(w_mix, p.Σ_g * w_mix), 0.0))                  # yr⁻¹
    c = σ_mix > cs.σ_g_max ? cs.σ_g_max / σ_mix : 1.0
    n = c .* n_mix
    if c < 1 && cs.c̄ > 0
        turnover = cs.c̄ * sum(abs.(n .- cs.n_prev))                    # USD
        turnover > cs.K_turnover * (1 + _TURNOVER_RTOL) + 1e-9 &&
            return _result(p, copy(cs.n_prev), :infeasible)
    end
    return _result(p, n, status)
end

# Min-variance mix on q (p without the volatility cap) at Σw = s_dir, scaled onto p's cap.
function _minvar(p::MyAllocationProblem, q::MyAllocationProblem, s_dir::Float64)::MyAllocationResult
    x, status = _solve_with_fallback(function (opt)
        m, n, w = _free_model(opt, q; s=s_dir)
        @objective(m, Min, w' * q.Σ_g * w)
        return m, n
    end)
    status == :optimal || return _result(p, copy(p.constraints.n_prev), status)
    return _scale_to_vol_cap(p, x, :optimal)
end

"""
    allocate(::MyMinVarRule, p::MyAllocationProblem)::MyAllocationResult

Minimum variance in two-fund form (R24), over long-only shares n ≥ 0 (shares, no ε pins):
1. **Mix:** minimize wᵀΣ_g w (yr⁻²) at Σwᵢ = s_dir = `max_investable(p)` (to within 1e-7) under the
   budget, per-name, sector, β and turnover limits, without the volatility cap.
2. **Scale:** w = c·w_mix with c = min(1, σ_g_max/√(w_mixᵀΣ_g w_mix)); the rest is cash.

`s_star` = Σwᵢ of the returned portfolio. Returns n = n_prev with `:infeasible` / `:solver_failed`
when the limits cannot be met, and with `:infeasible` when the scaled portfolio breaks the turnover
budget.
"""
function allocate(::MyMinVarRule, p::MyAllocationProblem)::MyAllocationResult
    _check_problem(p)
    q = _without_vol_cap(p)
    s_dir, status = _max_investable(q)
    status == :optimal || return _result(p, copy(p.constraints.n_prev), status)
    return _minvar(p, q, s_dir)
end

"""
    allocate(::MyTangentRule, p::MyAllocationProblem)::MyAllocationResult

Tangent portfolio in two-fund form (R24), with excess growth e = μ_g − g_f (yr⁻¹), over long-only
shares (no ε pins). Every solve uses the budget, per-name, sector, β and turnover limits and
Σwᵢ = s_dir = `max_investable(p)` (to within 1e-7), without the volatility cap; the cap enters only
in the final scale.

1. **Best excess growth** δ = max eᵀw (yr⁻¹) over that set (a cone LP). When δ is not positive
   (δ ≤ 1e-6·s_dir·max|eᵢ|, the solver tolerance), no feasible portfolio has positive excess growth
   and the rule returns the (R24) min-variance portfolio with status `:fallback_minvar`.
2. **Mix by Charnes–Cooper homogenization.** With y = κ·n (shares) and κ ≥ 0, and v = κ·w the weights
   `add_shared_constraints!(m, y, q; κ=κ)` returns: minimize vᵀΣ_g v subject to eᵀv = δ,
   Σv ≥ (s_dir − 1e-7)·κ, y ≥ 0, and the budget, per-name, sector and turnover rows with their
   right-hand sides scaled by κ. Then w_mix = v/κ. Fixing eᵀv to δ instead of 1 leaves the optimum
   unchanged (the Sharpe ratio is scale-free) and keeps κ = δ/eᵀw ≥ 1, so dividing by κ never
   amplifies solver error. A failed (or infeasible) solve here, after δ > 0 was found, returns
   n = n_prev with `:solver_failed`.
3. **Scale:** w = c·w_mix with c = min(1, σ_g_max/√(w_mixᵀΣ_g w_mix)); the rest is cash.

`s_star` = Σwᵢ of the returned portfolio. Returns n = n_prev with `:infeasible` / `:solver_failed`
when the limits cannot be met, and with `:infeasible` when the scaled portfolio breaks the turnover
budget.
"""
function allocate(::MyTangentRule, p::MyAllocationProblem)::MyAllocationResult
    _check_problem(p)
    K = length(p.γ)
    n_prev = p.constraints.n_prev
    q = _without_vol_cap(p)
    s_dir, status = _max_investable(q)
    status == :optimal || return _result(p, copy(n_prev), status)
    e = p.μ_g .- p.g_f

    # 1. best feasible excess growth δ
    x, status = _solve_with_fallback(function (opt)
        m, n, w = _free_model(opt, q; s=s_dir)
        @objective(m, Max, sum(e[i] * w[i] for i in 1:K))
        return m, n
    end)
    status == :optimal || return _result(p, copy(n_prev), status)
    δ = dot(e, x .* p.prices ./ p.W)
    scale = s_dir * maximum(abs, e)
    if !(scale > 0 && δ > _MIN_EXCESS_REL * scale)
        r = _minvar(p, q, s_dir)
        r.status == :optimal && (r.status = :fallback_minvar)
        return r
    end

    # 2. homogenized maximum-Sharpe mix in (y, κ), without the volatility cone
    x, status = _solve_with_fallback(function (opt)
        m = Model(opt)
        set_silent(m)
        y = @variable(m, [1:K], lower_bound = 0.0)
        κ = @variable(m, lower_bound = 0.0)
        v = add_shared_constraints!(m, y, q; κ=κ)                # v = κ·w
        @constraint(m, sum(v) >= (s_dir - _S_TOL) * κ)
        @constraint(m, sum(e[i] * v[i] for i in 1:K) == δ)
        @objective(m, Min, v' * q.Σ_g * v)
        return m, vcat(y, κ)
    end)
    status == :optimal || return _result(p, copy(n_prev), :solver_failed)

    # 3. scale onto the volatility cap
    return _scale_to_vol_cap(p, x[1:K] ./ x[end], :optimal)
end
