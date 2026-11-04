# Shared constraint set and the utility rules (Cobb-Douglas, CES, Stone–Geary).
#
# Units: shares n (shares), prices S (USD/share), equity W (USD), weights w = n·S/W (dimensionless),
# Σ_g (yr⁻²), σ_g_max (yr⁻¹). The engine's annualized cap √(wᵀCw) ≤ σ_max with C = Δt·Σ_g is the
# same constraint as √(wᵀΣ_g w) ≤ σ_g_max with σ_g_max = σ_max/√Δt.

"""
    AbstractPortfolioRule

Supertype of portfolio rules. Each rule implements `allocate(rule, p::MyAllocationProblem)`.
"""
abstract type AbstractPortfolioRule end

"""
    MyCobbDouglasRule

Cobb-Douglas (the trial's rule): maximize Σ_{γᵢ>0} γᵢ·log nᵢ; names with γᵢ ≤ 0 sit at the floor ε,
except hedge names (`MyAllocationProblem.hedge`), which are free above it. No parameters.
"""
mutable struct MyCobbDouglasRule <: AbstractPortfolioRule
    MyCobbDouglasRule() = new()
end

"""
    MyCESRule

CES utility (Σ_{γᵢ>0} γᵢ nᵢ^ρ)^(1/ρ) with ρ = 1 − 1/η (CHEME-5660 `allocate_ces`: nᵢ ∝ (γᵢ/Sᵢ)^η
under a budget alone). Field `η` (elasticity of substitution, dimensionless, > 0): η > 1 (0 < ρ < 1)
maximizes Σ γᵢ nᵢ^ρ; 0 < η < 1 (ρ < 0) minimizes Σ γᵢ nᵢ^ρ; η = 1 is Cobb-Douglas. Names with
γᵢ ≤ 0 sit at the floor ε, except hedge names, which are free above it.
"""
mutable struct MyCESRule <: AbstractPortfolioRule
    η::Float64
    MyCESRule() = new()
end

"""
    MyCESWeightRule

Weight-based CES (CESw): U = (Σ_{γᵢ>0} γᵢ·wᵢ^ρ)^(1/ρ) with ρ = 1 − 1/η and dollar weights
wᵢ = nᵢ·Sᵢ/W (dimensionless). Under a budget alone wᵢ ∝ γᵢ^η, so a split (Sᵢ down, nᵢ up, γᵢ
unchanged) leaves the book unchanged; every other rule (shared limits, ε pins, hedge names,
η = 1 as Cobb-Douglas) is that of `MyCESRule`. Field `η` (elasticity of substitution,
dimensionless, > 0).
"""
mutable struct MyCESWeightRule <: AbstractPortfolioRule
    η::Float64
    MyCESWeightRule() = new()
end

"""
    MyStoneGearyRule

Stone–Geary utility: maximize Σ_{γᵢ>0} γᵢ·log(nᵢ − bᵢ) with nᵢ ≥ bᵢ for every name, where the
baseline bᵢ = `baseline_frac`·W/Sᵢ shares (`baseline_frac` dimensionless, e.g. 0.01 = a 1% core
position). Names with γᵢ ≤ 0 are held at bᵢ, except hedge names, which are free above it.
"""
mutable struct MyStoneGearyRule <: AbstractPortfolioRule
    baseline_frac::Float64
    MyStoneGearyRule() = new()
end

"""
    MyConstraintSet

The constraint set shared by every portfolio rule:
- `w_max`: per-name weight cap (dimensionless; applies to |wᵢ| for signed rules); the scalar default of `w_cap`
- `w_cap`: per-name weight cap on |wᵢ| (dimensionless, one per name; default `fill(w_max, K)`)
- `s_max`: per-sector weight cap (dimensionless; `s_max ≥ 1` means no sector cap)
- `σ_g_max`: cap on the portfolio growth-rate SD √(wᵀΣ_g w) (yr⁻¹)
- `K_turnover`: spread-cost budget (USD), c̄·Σ|nᵢ − n_prevᵢ| ≤ K_turnover
- `c̄`: turnover cost per share (USD/share)
- `sector`: GICS sector per name
- `n_prev`: holdings before the solve (shares)
- `ε`: floor for names with γ ≤ 0 under the log/CES utilities (shares, default 1e-3)
- `β`: each name's signed β on the market (dimensionless, default 0)
- `β_max`: cap on the portfolio β Σ βᵢwᵢ (dimensionless; cash has β = 0; default `Inf` = no cap)
"""
mutable struct MyConstraintSet
    w_max::Float64
    s_max::Float64
    σ_g_max::Float64
    K_turnover::Float64
    c̄::Float64
    sector::Vector{String}
    n_prev::Vector{Float64}
    ε::Float64
    β::Vector{Float64}
    β_max::Float64
    w_cap::Vector{Float64}
    MyConstraintSet() = new()
end

"""
    MyAllocationProblem

One allocation decision: `γ` (preference weights, dimensionless), `μ_g` (expected growth, yr⁻¹),
`Σ_g` (growth covariance, yr⁻²), `prices` (USD/share), `W` (equity, USD), `g_f` (risk-free growth,
yr⁻¹), the shared `constraints::MyConstraintSet` and `hedge` (one flag per name: a hedge-pool name).
In the γ-based rules a hedge name with γᵢ ≤ 0 is a free variable above its floor with no utility
term, so it is bought only when the β or volatility cap makes it worth its budget; in the 130/30 it
is long-only.
"""
mutable struct MyAllocationProblem
    γ::Vector{Float64}
    μ_g::Vector{Float64}
    Σ_g::Matrix{Float64}
    prices::Vector{Float64}
    W::Float64
    g_f::Float64
    constraints::MyConstraintSet
    hedge::Vector{Bool}
    MyAllocationProblem() = new()
end

"""
    MyAllocationResult

Allocator output: `n` (continuous shares), `w` = n·S/W (dimensionless), `status`
(`:optimal`, `:no_preferred`, `:infeasible`, `:solver_failed`, plus rule-specific statuses), and
`s_star` (invested fraction of equity, Σwᵢ for the utility rules).
"""
mutable struct MyAllocationResult
    n::Vector{Float64}
    w::Vector{Float64}
    status::Symbol
    s_star::Float64
    MyAllocationResult() = new()
end

_require(data::NamedTuple, T::Type, f::Symbol) =
    haskey(data, f) || throw(ArgumentError("Cannot build $(T): missing field $(f)"))

"""
    build(::Type{MyCobbDouglasRule}, data::NamedTuple)::MyCobbDouglasRule

Build a Cobb-Douglas rule (no fields; `data` is ignored).
"""
build(::Type{MyCobbDouglasRule}, data::NamedTuple)::MyCobbDouglasRule = MyCobbDouglasRule()

"""
    build(::Type{MyCESRule}, data::NamedTuple)::MyCESRule

Build a CES rule from `(η = …,)` (elasticity of substitution, dimensionless, finite and > 0).
"""
function build(::Type{MyCESRule}, data::NamedTuple)::MyCESRule
    _require(data, MyCESRule, :η)
    η = Float64(data.η)
    (isfinite(η) && η > 0) || throw(ArgumentError("η must be finite and positive, got $(η)"))
    model = MyCESRule(); model.η = η
    return model
end

"""
    build(::Type{MyCESWeightRule}, data::NamedTuple)::MyCESWeightRule

Build a weight-based CES rule from `(η = …,)` (elasticity of substitution, dimensionless, finite and > 0).
"""
function build(::Type{MyCESWeightRule}, data::NamedTuple)::MyCESWeightRule
    _require(data, MyCESWeightRule, :η)
    η = Float64(data.η)
    (isfinite(η) && η > 0) || throw(ArgumentError("η must be finite and positive, got $(η)"))
    model = MyCESWeightRule(); model.η = η
    return model
end

"""
    build(::Type{MyStoneGearyRule}, data::NamedTuple)::MyStoneGearyRule

Build a Stone–Geary rule from `(baseline_frac = …,)` (dollar baseline per name as a fraction of
equity, dimensionless, ≥ 0).
"""
function build(::Type{MyStoneGearyRule}, data::NamedTuple)::MyStoneGearyRule
    _require(data, MyStoneGearyRule, :baseline_frac)
    f = Float64(data.baseline_frac)
    (isfinite(f) && f >= 0) || throw(ArgumentError("baseline_frac must be finite and ≥ 0, got $(f)"))
    model = MyStoneGearyRule(); model.baseline_frac = f
    return model
end

"""
    build(::Type{MyConstraintSet}, data::NamedTuple)::MyConstraintSet

Build the shared constraint set from `w_max`, `s_max`, `σ_g_max` (yr⁻¹), `K_turnover` (USD),
`c̄` (USD/share), `sector`, `n_prev` (shares) and optional `ε` (shares, default 1e-3), `β`
(dimensionless, default zeros, one per name) and `β_max` (dimensionless, default `Inf` = no β cap;
`NaN` and `-Inf` throw) and `w_cap` (dimensionless per-name caps on |wᵢ|, default `fill(w_max, K)`;
length must be K, entries finite and > 0).
"""
function build(::Type{MyConstraintSet}, data::NamedTuple)::MyConstraintSet
    for f ∈ (:w_max, :s_max, :σ_g_max, :K_turnover, :c̄, :sector, :n_prev)
        _require(data, MyConstraintSet, f)
    end
    model = MyConstraintSet()
    model.w_max = Float64(data.w_max)
    model.s_max = Float64(data.s_max)
    model.σ_g_max = Float64(data.σ_g_max)
    model.K_turnover = Float64(data.K_turnover)
    model.c̄ = Float64(data.c̄)
    model.sector = String.(collect(data.sector))
    model.n_prev = Float64.(collect(data.n_prev))
    model.ε = Float64(get(data, :ε, 1e-3))
    model.β = Float64.(collect(get(data, :β, zeros(length(model.sector)))))
    model.β_max = Float64(get(data, :β_max, Inf))
    model.w_cap = Float64.(collect(get(data, :w_cap, fill(model.w_max, length(model.sector)))))
    model.w_max > 0 || throw(ArgumentError("w_max must be positive"))
    model.s_max > 0 || throw(ArgumentError("s_max must be positive"))
    model.σ_g_max >= 0 || throw(ArgumentError("σ_g_max must be ≥ 0"))
    (model.K_turnover >= 0 && model.c̄ >= 0) || throw(ArgumentError("K_turnover and c̄ must be ≥ 0"))
    model.ε >= 0 || throw(ArgumentError("ε must be ≥ 0"))
    (isnan(model.β_max) || model.β_max == -Inf) &&
        throw(ArgumentError("β_max must be a number or Inf, got $(model.β_max)"))
    length(model.sector) == length(model.n_prev) == length(model.β) ||
        throw(DimensionMismatch("sector, n_prev and β must have one entry per name"))
    length(model.w_cap) == length(model.sector) ||
        throw(DimensionMismatch("w_cap must have one entry per name"))
    all(x -> isfinite(x) && x > 0, model.w_cap) || throw(ArgumentError("w_cap entries must be finite and > 0"))
    return model
end

"""
    build(::Type{MyAllocationProblem}, data::NamedTuple)::MyAllocationProblem

Build an allocation problem from `γ`, `μ_g` (yr⁻¹), `Σ_g` (yr⁻², any K×K matrix type), `prices`
(USD/share), `W` (USD), `g_f` (yr⁻¹), `constraints::MyConstraintSet` and optional `hedge` (Bool per
name, default all `false`). Checks that every per-name input has the same length K and that prices
and W are positive.
"""
function build(::Type{MyAllocationProblem}, data::NamedTuple)::MyAllocationProblem
    for f ∈ (:γ, :μ_g, :Σ_g, :prices, :W, :g_f, :constraints)
        _require(data, MyAllocationProblem, f)
    end
    model = MyAllocationProblem()
    model.γ = Float64.(collect(data.γ))
    model.μ_g = Float64.(collect(data.μ_g))
    model.Σ_g = Matrix{Float64}(data.Σ_g)
    model.prices = Float64.(collect(data.prices))
    model.W = Float64(data.W)
    model.g_f = Float64(data.g_f)
    model.constraints = data.constraints
    model.hedge = Bool.(collect(get(data, :hedge, fill(false, length(model.γ)))))
    _check_problem(model)
    return model
end

"""
    build(::Type{MyAllocationResult}, data::NamedTuple)::MyAllocationResult

Build a result from `n` (shares), `w` (dimensionless), `status::Symbol` and `s_star` (dimensionless).
"""
function build(::Type{MyAllocationResult}, data::NamedTuple)::MyAllocationResult
    for f ∈ (:n, :w, :status, :s_star)
        _require(data, MyAllocationResult, f)
    end
    model = MyAllocationResult()
    model.n = Float64.(collect(data.n)); model.w = Float64.(collect(data.w))
    model.status = Symbol(data.status); model.s_star = Float64(data.s_star)
    return model
end

# Every per-name input has length K; Σ_g is K×K; prices and W are positive and finite.
function _check_problem(p::MyAllocationProblem)
    K = length(p.γ)
    c = p.constraints
    all(length(v) == K for v in (p.μ_g, p.prices, c.sector, c.n_prev, c.β, p.hedge)) ||
        throw(DimensionMismatch("γ, μ_g, prices, sector, n_prev, β and hedge must all have length $(K)"))
    size(p.Σ_g) == (K, K) || throw(DimensionMismatch("Σ_g must be $(K)×$(K), got $(size(p.Σ_g))"))
    all(s -> isfinite(s) && s > 0, p.prices) || throw(ArgumentError("prices must be positive and finite"))
    (isfinite(p.W) && p.W > 0) || throw(ArgumentError("W must be positive and finite"))
    return nothing
end

# Result with w = n·S/W and s_star = Σw (the invested fraction of equity).
function _result(p::MyAllocationProblem, n::AbstractVector, status::Symbol)::MyAllocationResult
    w = n .* p.prices ./ p.W
    return build(MyAllocationResult, (n=n, w=w, status=status, s_star=sum(w)))
end

# A pinned entry of the share vector is a constant (no decision-variable terms).
_is_pinned(x::Real) = true
_is_pinned(x::JuMP.GenericAffExpr) = isempty(x.terms)
_is_pinned(x::JuMP.AbstractVariableRef) = false
_pinned_value(x::Real) = Float64(x)
_pinned_value(x::JuMP.GenericAffExpr) = Float64(x.constant)

# lhs ≤ rhs. A constant row (pinned names only) is checked here instead of being sent to the
# solver, because all-zero rows degrade Clarabel's accuracy (CD with one ε pin: share error 1.3e-5
# with them, 2e-6 without). A violated constant row is still added, so the solver certifies the
# infeasibility.
function _add_le!(m::JuMP.Model, lhs::JuMP.GenericAffExpr, rhs)
    isempty(lhs.terms) && rhs isa Real && lhs.constant <= rhs && return nothing
    @constraint(m, lhs <= rhs)
    return nothing
end

"""
    add_shared_constraints!(m::JuMP.Model, n, p::MyAllocationProblem; signed=false, κ=1.0)

Add the shared constraint set to `m` for the share vector `n` (length K, shares; entries are JuMP
variables/affine expressions, or constants for pinned names) and return the weight expressions
w = n·S/W (dimensionless, `Vector{AffExpr}`). Constraints, following engine `Allocator.jl:115-163`:

- **Budget:** Σ nᵢSᵢ ≤ W·κ (USD). With `signed=true` this is net exposure ≤ 1 (cash ≥ 0).
- **Per-name cap:** wᵢ ≤ w_capᵢ·κ for every name, pinned ones included (a pinned name's constant row
  is checked directly and only sent to the solver when violated); with `signed=true` also
  wᵢ ≥ −w_capᵢ·κ, i.e. |wᵢ| ≤ w_capᵢ·κ.
- **Sector cap** (only when `s_max < 1`): Σ_{i∈s} wᵢ ≤ s_max·κ per sector; with `signed=true` the
  net sector weight is capped on both sides, |Σ_{i∈s} wᵢ| ≤ s_max·κ.
- **β cap** (only when β_max is finite): Σ βᵢwᵢ ≤ β_max·κ (dimensionless) on the signed βᵢ, cash at
  β = 0; with `signed=true` on the signed weights. A constant row (pinned names only) is checked
  directly, like the per-name cap.
- **Volatility cap:** ‖Lᵀw‖ ≤ σ_g_max·κ (yr⁻¹) as a second-order cone, LLᵀ = Σ_g + 1e-8·I (yr⁻²);
  skipped when σ_g_max is infinite.
- **Spread-cost budget** (the trial's turnover rule): c̄·Σ_{free i} |nᵢ − κ·n_prevᵢ| ≤ K_turnover·κ (USD), on the non-pinned names
  only (engine semantics: pinned names' churn is not counted). The slack variables are skipped when
  c̄ = 0 or when no feasible point can violate the budget: c̄·max‖n − n_prev‖₁ ≤ K_turnover, with
  max‖·‖₁ ≤ B_eff/min Sᵢ + Σ n_prevᵢ (long-only; B_eff = W − pinned cost, USD) or
  Σ (w_capᵢ·W/Sᵢ + |n_prevᵢ|) (signed), both over the free names.

The sign of `n` is the caller's: long-only rules declare nᵢ ≥ 0 (or a floor) as variable bounds,
and the long-only turnover guard relies on it; signed rules pass n = n⁺ − n⁻.
`κ` (dimensionless, a number or a JuMP variable) homogenizes every right-hand side for
fractional programs (y = κ·n, e.g. the tangent rule); with a variable κ, pass no constant pins.
"""
function add_shared_constraints!(m::JuMP.Model, n::AbstractVector, p::MyAllocationProblem;
        signed::Bool=false, κ::Union{Real,JuMP.AbstractVariableRef}=1.0)
    c = p.constraints; S = p.prices; W = p.W; K = length(S)
    length(n) == K || throw(DimensionMismatch("n must have length $(K)"))

    # Weights as AffExpr: pinned entries are constants, so build the vector explicitly to keep a
    # concrete AffExpr element type (the engine's SOC typing workaround).
    w = AffExpr[AffExpr(0.0) for _ in 1:K]
    for i in 1:K
        add_to_expression!(w[i], S[i] / W, n[i])
    end

    # Budget (USD)
    budget = AffExpr(0.0)
    for i in 1:K
        add_to_expression!(budget, S[i], n[i])
    end
    @constraint(m, budget <= W * κ)

    # Per-name cap
    for i in 1:K
        _add_le!(m, w[i], c.w_cap[i] * κ)
        signed && _add_le!(m, -w[i], c.w_cap[i] * κ)
    end

    # Sector cap (net sector weight)
    if c.s_max < 1.0
        for s in unique(c.sector)
            ws = sum(w[i] for i in 1:K if c.sector[i] == s)
            _add_le!(m, ws, c.s_max * κ)
            signed && _add_le!(m, -ws, c.s_max * κ)
        end
    end

    # β cap: Σ βᵢwᵢ ≤ β_max (zero-β names add no term, so an all-pinned row stays constant)
    if isfinite(c.β_max)
        wβ = AffExpr(0.0)
        for i in 1:K
            iszero(c.β[i]) || add_to_expression!(wβ, c.β[i], w[i])
        end
        _add_le!(m, wβ, c.β_max * κ)
    end

    # Volatility cap: ‖Lᵀw‖ ≤ σ_g_max
    if isfinite(c.σ_g_max)
        Lt = Matrix(cholesky(Symmetric(p.Σ_g + 1e-8 * I)).L')
        Ltw = AffExpr[AffExpr(0.0) for _ in 1:K]
        for r in 1:K, col in r:K                     # Lᵀ is upper triangular
            add_to_expression!(Ltw[r], Lt[r, col], w[col])
        end
        @constraint(m, vcat(c.σ_g_max * κ, Ltw) in SecondOrderCone())
    end

    # Spread-cost budget (the trial's turnover rule; ℓ₁ slack on the free names), skipped when it cannot bind
    if c.c̄ > 0
        free = [i for i in 1:K if !_is_pinned(n[i])]
        if !isempty(free)
            max_l1 = if signed
                sum(c.w_cap[i] * W / S[i] + abs(c.n_prev[i]) for i in free)
            else
                B_eff = W - sum((_pinned_value(n[i]) * S[i] for i in 1:K if _is_pinned(n[i])); init=0.0)
                B_eff / minimum(S[free]) + sum(c.n_prev[free])
            end
            if c.c̄ * max_l1 > c.K_turnover
                u = @variable(m, [1:length(free)], lower_bound = 0.0)
                for (k, i) in enumerate(free)
                    @constraint(m, u[k] >= n[i] - κ * c.n_prev[i])
                    @constraint(m, u[k] >= κ * c.n_prev[i] - n[i])
                end
                @constraint(m, c.c̄ * sum(u) <= c.K_turnover * κ)
            end
        end
    end
    return w
end

# Gap tolerances are tighter than the engine's 1e-9: the utility is flat at the optimum, so share
# accuracy scales like √gap (3-asset CD closed form off by 2.5e-5 at 1e-9, by 6e-9 at 1e-12). The
# feasibility tolerance stays at the engine's 1e-9.
const _CLARABEL_ATTRIBUTES = ("tol_gap_abs" => 1e-12, "tol_gap_rel" => 1e-12, "tol_feas" => 1e-9,
    "max_iter" => 500)
const _ACCEPTED = (MOI.OPTIMAL, MOI.ALMOST_OPTIMAL)
const _INFEASIBLE = (MOI.INFEASIBLE, MOI.ALMOST_INFEASIBLE, MOI.LOCALLY_INFEASIBLE,
    MOI.INFEASIBLE_OR_UNBOUNDED)

# Scoped log of solver outcomes: inside `Base.ScopedValues.with(_SOLVER_LOG => log) do ... end` every
# `_solve_with_fallback` call pushes one outcome (see `_solver_outcome`) to `log`; outside a scope nothing
# is recorded. The study uses it to report which solver produced each decision.
const _SOLVER_LOG = Base.ScopedValues.ScopedValue{Union{Nothing,Vector{Symbol}}}(nothing)

# Outcome of one solve from the statuses of the solvers tried, in order (Clarabel, then SCS):
# :clarabel (Clarabel OPTIMAL), :clarabel_almost (Clarabel ALMOST_OPTIMAL), :scs (Clarabel not accepted,
# SCS accepted), :failed (neither accepted).
function _solver_outcome(statuses::AbstractVector{MOI.TerminationStatusCode})::Symbol
    isempty(statuses) && return :failed
    first(statuses) == MOI.OPTIMAL && return :clarabel
    first(statuses) == MOI.ALMOST_OPTIMAL && return :clarabel_almost
    return any(in(_ACCEPTED), statuses[2:end]) ? :scs : :failed
end

const _SOLVER_ORDER = (:none, :clarabel, :clarabel_almost, :scs, :failed)

# Worst outcome of a list, in the order :none < :clarabel < :clarabel_almost < :scs < :failed; :none when empty.
_worst_solver(outcomes::AbstractVector{Symbol})::Symbol =
    isempty(outcomes) ? :none : _SOLVER_ORDER[maximum(o -> findfirst(==(o), _SOLVER_ORDER), outcomes)]

# Exceptions that are faults in code rather than a failed solve **(implementation decision)**, so
# `_try_solver` rethrows them: a user interrupt, a model the solver cannot take (MOI.UnsupportedError:
# our formulation), code that cannot run (MethodError, UndefVarError, e.g. reading values on a
# non-variable), and resource exhaustion (OutOfMemoryError, StackOverflowError), which a second solver
# would not cure. They recur on every problem, so treating them as solver failures would silently turn
# every decision into SCS or a failure.
_code_fault(e) = e isa InterruptException || e isa MOI.UnsupportedError || e isa MethodError || e isa UndefVarError ||
    e isa OutOfMemoryError || e isa StackOverflowError

# One solver's attempt: `build_model(opt)` (our code, outside the `try`, so its errors propagate), then
# optimize and, when the status is accepted, read the values. Returns (status, x_value or nothing). An
# exception from the solve or the read that is not a `_code_fault` is that solver not accepting and
# returns (MOI.OTHER_ERROR, nothing). Clarabel 0.11.1 throws a DomainError in its power-cone barrier
# when an end-game trial slack lands within rounding of the cone boundary (CES at η = 0.05…0.25 and
# 4…20 on real data); the exception would otherwise abort the whole backtest run.
function _try_solver(build_model::Function, opt)
    m, x = build_model(opt)
    try
        optimize!(m)
        st = termination_status(m)
        return st in _ACCEPTED ? (st, value.(x)) : (st, nothing)
    catch e
        _code_fault(e) && rethrow()
        @debug "solver threw; treated as not accepting" opt exception = (e, catch_backtrace())
        return (MOI.OTHER_ERROR, nothing)
    end
end

# Solve with Clarabel (tight tolerances), then SCS if Clarabel does not reach (almost) optimal.
# `build_model(optimizer)` returns `(model, x)`. Returns `(x_value or nothing, status)` with status
# :optimal, :infeasible (either solver certified infeasibility) or :solver_failed. When a `_SOLVER_LOG`
# scope is active, the outcome of the solve is also pushed to it. An exception thrown while a solver
# optimizes or its values are read counts as that solver not accepting, with status MOI.OTHER_ERROR
# (`_try_solver`), and the next solver is tried: Clarabel throwing and SCS accepting logs :scs, both
# throwing logs :failed and returns :solver_failed. Exceptions from `build_model` itself and the
# `_code_fault` kinds propagate.
function _solve_with_fallback(build_model::Function)
    statuses = MOI.TerminationStatusCode[]
    for opt in (optimizer_with_attributes(Clarabel.Optimizer, _CLARABEL_ATTRIBUTES...), SCS.Optimizer)
        st, xv = _try_solver(build_model, opt)
        push!(statuses, st)
        if st in _ACCEPTED
            log = _SOLVER_LOG[]; log === nothing || push!(log, _solver_outcome(statuses))
            return (xv, :optimal)
        end
    end
    log = _SOLVER_LOG[]; log === nothing || push!(log, _solver_outcome(statuses))
    return (nothing, any(in(_INFEASIBLE), statuses) ? :infeasible : :solver_failed)
end

# Cost per unit of weight (dimensionless) on the free hedge names, subtracted from the utility
# objective **(plan decision)**. A hedge name has no utility term, so without it the objective is
# flat along the hedge weights whenever no limit binds, and an interior-point solver returns an
# arbitrary holding there. Per share the cost is 1e-6·Sᵢ/W (4e-8 for a 40 USD name at W = 1000 USD,
# 2e-9 for a 200 USD name at W = 1e5 USD), below Clarabel's dual accuracy, so on its own it leaves
# hedge holdings of several percent of equity on the flat direction; `_min_hedge` then settles them.
const _HEDGE_TIEBREAK = 1e-6

# Free hedge names of a utility rule: hedge-pool names with γ ≤ 0.
_free_hedges(p::MyAllocationProblem) = findall(i -> p.hedge[i] && p.γ[i] <= 0, eachindex(p.γ))

# Second, lexicographic stage for the free hedge names `hedge` **(implementation decision: the
# tie-break alone is below solver accuracy)**. With the names in `fixed` held at their first-stage
# shares `n1` (as fixed variables, so their turnover still counts) and every other name at the
# constant n1ᵢ, minimize Σ wᵢ over the hedge names (variables ≥ `floors`, shares) under the shared
# constraints (`signed` as in add_shared_constraints!) plus the rule's own rows `rows!(m, w)`. The
# utility depends on the fixed names only, so this keeps the first-stage utility and holds a hedge
# above its floor only as far as a binding limit (β or volatility cap) needs it. With no fixed names
# it is the least hedge that makes constant holdings n1 meet every limit (Stone–Geary without γ > 0).
# Returns (n, status): n1 with the hedge entries replaced (shares) and :optimal, or n1 unchanged with
# :infeasible / :solver_failed when this stage does not solve.
function _min_hedge(p::MyAllocationProblem, n1::Vector{Float64}, fixed::Vector{Int}, hedge::Vector{Int},
        floors::Vector{Float64}; signed::Bool=false,
        rows!::Function=(m, w) -> nothing)::Tuple{Vector{Float64},Symbol}
    x, status = _solve_with_fallback(function (opt)
        m = Model(opt)
        set_silent(m)
        y = @variable(m, [1:length(fixed)])
        fix.(y, n1[fixed])
        h = @variable(m, [k = 1:length(hedge)], lower_bound = floors[k])
        n = AffExpr[AffExpr(v) for v in n1]
        for (k, i) in enumerate(fixed)
            n[i] = AffExpr(0.0, y[k] => 1.0)
        end
        for (k, i) in enumerate(hedge)
            n[i] = AffExpr(0.0, h[k] => 1.0)
        end
        w = add_shared_constraints!(m, n, p; signed=signed)
        rows!(m, w)
        @objective(m, Min, sum(w[i] for i in hedge))
        return m, h
    end)
    status == :optimal || return (n1, status)
    n = copy(n1)
    n[hedge] .= x
    return (n, :optimal)
end

# Utility solve over the preferred names (γ > 0) and the free hedge names: `pins` gives every name's
# value when pinned and is also each free hedge name's lower bound (shares), `lb` the lower bound
# (shares) of each preferred name's variable, and `objective!(m, x, γ_p)` adds the cone constraints
# on the preferred shares x and returns the utility expression. The objective is the utility minus
# _HEDGE_TIEBREAK·Σ wᵢ over the free hedge names (which get no utility term); when there are any,
# `_min_hedge` then settles their holdings with the preferred shares fixed. Pinned names enter the
# shared constraints as constants.
function _solve_utility(p::MyAllocationProblem, pins::Vector{Float64}, lb::Vector{Float64},
        objective!::Function)::MyAllocationResult
    pref = findall(p.γ .> 0); hedge = _free_hedges(p)
    K = length(p.γ); Kp = length(pref); Kh = length(hedge)
    function build_model(opt)
        m = Model(opt)
        set_silent(m)
        x = @variable(m, [k = 1:Kp], lower_bound = lb[k])
        h = @variable(m, [k = 1:Kh], lower_bound = pins[hedge[k]])
        n = AffExpr[AffExpr(pins[i]) for i in 1:K]
        for (k, i) in enumerate(pref)
            n[i] = AffExpr(0.0, x[k] => 1.0)
        end
        for (k, i) in enumerate(hedge)
            n[i] = AffExpr(0.0, h[k] => 1.0)
        end
        U = objective!(m, x, p.γ[pref])
        w = add_shared_constraints!(m, n, p)
        @objective(m, Max, Kh == 0 ? U : U - _HEDGE_TIEBREAK * sum(w[i] for i in hedge))
        return m, vcat(x, h)
    end
    x, status = _solve_with_fallback(build_model)
    status == :optimal || return _result(p, copy(p.constraints.n_prev), status)
    n = copy(pins)
    n[pref] .= x[1:Kp]
    n[hedge] .= x[Kp+1:end]
    Kh > 0 && (n = first(_min_hedge(p, n, pref, hedge, pins[hedge])))
    return _result(p, n, :optimal)
end

"""
    allocate(rule::AbstractPortfolioRule, p::MyAllocationProblem)::MyAllocationResult

Solve one allocation under the shared constraints (`add_shared_constraints!`). Shares `n` are
continuous (shares), weights w = n·S/W. Status `:no_preferred` when no γᵢ > 0 (utility rules return
their pins without a solve, except Stone–Geary under a finite β cap); `:infeasible` or
`:solver_failed` return `n = constraints.n_prev`. In the
utility rules a hedge name (`p.hedge`) with γᵢ ≤ 0 is a free variable above its pin, with no utility
term and a cost of 1e-6 per unit of weight (the tie-break); a second solve with the other names'
shares fixed then minimizes the hedge weight, so a hedge sits above its pin only as far as a binding
β or volatility cap needs it. Every other γᵢ ≤ 0 name is pinned.
"""
function allocate end

"""
    allocate(::MyCobbDouglasRule, p::MyAllocationProblem)::MyAllocationResult

Cobb-Douglas: maximize Σ_{γ>0} γᵢ·log nᵢ (nᵢ in shares) via exponential cones, with nᵢ ≥ 1e-8 and
γ ≤ 0 names pinned at ε shares (free hedge names: nᵢ ≥ ε, no utility term).
"""
function allocate(::MyCobbDouglasRule, p::MyAllocationProblem)::MyAllocationResult
    _check_problem(p)
    pins = fill(p.constraints.ε, length(p.γ))
    any(>(0), p.γ) || return _result(p, pins, :no_preferred)
    Kp = count(>(0), p.γ)
    return _solve_utility(p, pins, fill(1e-8, Kp), function (m, x, γp)
        t = @variable(m, [1:Kp])
        for k in 1:Kp
            @constraint(m, [t[k], 1.0, x[k]] in MOI.ExponentialCone())   # t ≤ log n
        end
        return sum(γp[k] * t[k] for k in 1:Kp)
    end)
end

"""
    allocate(rule::MyCESRule, p::MyAllocationProblem)::MyAllocationResult

CES with ρ = 1 − 1/η, nᵢ in shares, γ ≤ 0 names pinned at ε shares (free hedge names: nᵢ ≥ ε, no
utility term). Under a budget alone nᵢ ∝ (γᵢ/Sᵢ)^η for every η (CHEME-5660 `allocate_ces`).
Both cones work on the scaled share count zᵢ = aᵢ·nᵢ (`_ces_objective`), with aᵢ = Σ_{γ>0} Sⱼ / W
(1/shares), so zᵢ = 1 at the book with equal share counts over the preferred names.
- η > 1 (0 < ρ < 1): maximize Σ_{γ>0} γᵢ·tᵢ with (zᵢ, 1, tᵢ) ∈ PowerCone(ρ), i.e. tᵢ ≤ zᵢ^ρ.
- 0 < η < 1 (ρ < 0): minimize Σ_{γ>0} γᵢ·tᵢ with (tᵢ, zᵢ, 1) ∈ PowerCone(η), i.e. tᵢ ≥ zᵢ^ρ.
  This maximizes (Σ γᵢ zᵢ^ρ)^(1/ρ), since 1/ρ < 0.
- **(plan decision)** The scale c = W/Σ_{γ>0} Sᵢ (shares) replaces W/mean(S), and the η > 1 branch
  is scaled too. A common factor c scales every term by c^(−ρ), which leaves the argmax unchanged
  and keeps zᵢ = O(1) at any W and K (with W/mean(S), zᵢ ≈ 1/K at the optimum and the cone held
  (1/K)^(−19) at η = 0.05).
- η = 1: `allocate(MyCobbDouglasRule(), p)`.
"""
function allocate(rule::MyCESRule, p::MyAllocationProblem)::MyAllocationResult
    rule.η == 1 && return allocate(MyCobbDouglasRule(), p)
    _check_problem(p)
    pins = fill(p.constraints.ε, length(p.γ))
    any(>(0), p.γ) || return _result(p, pins, :no_preferred)
    pref = findall(p.γ .> 0)
    a = fill(sum(p.prices[pref]) / p.W, length(pref))                    # 1/c, 1/shares
    return _solve_utility(p, pins, zeros(length(pref)), _ces_objective(Float64(rule.η), a))
end

"""
    allocate(rule::MyCESWeightRule, p::MyAllocationProblem)::MyAllocationResult

Weight-based CES: the CES of `allocate(::MyCESRule, …)` over the dollar weights wᵢ = nᵢSᵢ/W instead of
the share counts, γ ≤ 0 names pinned at ε shares (free hedge names: nᵢ ≥ ε, no utility term). The
cones work on zᵢ = Kp·wᵢ (`_ces_objective` with aᵢ = Kp·Sᵢ/W, in 1/shares), so zᵢ = 1 at equal
weights over the Kp preferred names **(plan decision)**; the common factor Kp^ρ leaves the argmax
unchanged. Under a budget alone wᵢ ∝ γᵢ^η. η = 1: `allocate(MyCobbDouglasRule(), p)`.
"""
function allocate(rule::MyCESWeightRule, p::MyAllocationProblem)::MyAllocationResult
    rule.η == 1 && return allocate(MyCobbDouglasRule(), p)
    _check_problem(p)
    pins = fill(p.constraints.ε, length(p.γ))
    any(>(0), p.γ) || return _result(p, pins, :no_preferred)
    pref = findall(p.γ .> 0); Kp = length(pref)
    a = Kp .* p.prices[pref] ./ p.W                                      # 1/shares
    return _solve_utility(p, pins, zeros(Kp), _ces_objective(Float64(rule.η), a))
end

"""
    _ces_objective(η::Float64, a::Vector{Float64})::Function

The `objective!(m, x, γp)` closure of `_solve_utility` for CES with elasticity η ≠ 1 over the
preferred holdings x, on the scaled variable zₖ = aₖ·xₖ (aₖ in 1/units of x). With ρ = 1 − 1/η it adds
- η > 1: `[z, 1, t] in PowerCone(ρ)` (t ≤ z^ρ) and returns Σ γₖ tₖ;
- η < 1: `[t, z, 1] in PowerCone(η)` (t ≥ z^ρ) and returns −Σ γₖ tₖ.
The argmax is that of (Σ γₖ xₖ^ρ)^(1/ρ) for any a > 0.
"""
function _ces_objective(η::Float64, a::Vector{Float64})::Function
    ρ = 1 - 1 / η
    return function (m, x, γp)
        Kp = length(x)
        t = @variable(m, [1:Kp])
        if η > 1
            for k in 1:Kp
                @constraint(m, [a[k] * x[k], 1.0, t[k]] in MOI.PowerCone(ρ))   # t ≤ z^ρ
            end
            return sum(γp[k] * t[k] for k in 1:Kp)
        end
        for k in 1:Kp
            @constraint(m, [t[k], a[k] * x[k], 1.0] in MOI.PowerCone(η))       # t ≥ z^ρ, ρ < 0
        end
        return -sum(γp[k] * t[k] for k in 1:Kp)
    end
end

"""
    allocate(rule::MyStoneGearyRule, p::MyAllocationProblem)::MyAllocationResult

Stone–Geary: maximize Σ_{γ>0} γᵢ·log(nᵢ − bᵢ) via exponential cones on the excess shares, with
bᵢ = baseline_frac·W/Sᵢ shares (fractional), nᵢ ≥ bᵢ, and γ ≤ 0 names held at bᵢ (free hedge names:
nᵢ ≥ bᵢ, no utility term). Returns `:infeasible` with n_prev when Σ bᵢSᵢ > W (USD), or when the
baselines break another limit (e.g. Σ βᵢbᵢSᵢ/W > β_max). With no γ > 0 (`:no_preferred`) it returns
n = b, except under a finite β_max: with free hedge names it returns the least hedge holding above b
that meets every shared limit, and without them it checks Σ βᵢbᵢSᵢ/W ≤ β_max; when neither works it
returns n_prev with `:infeasible` (`:solver_failed` if the hedge solve fails).
"""
function allocate(rule::MyStoneGearyRule, p::MyAllocationProblem)::MyAllocationResult
    _check_problem(p)
    b = rule.baseline_frac * p.W ./ p.prices                             # baseline shares (fractional)
    sum(b .* p.prices) > p.W && return _result(p, copy(p.constraints.n_prev), :infeasible)
    any(>(0), p.γ) || return _stone_geary_baselines(p, b)
    pref = findall(p.γ .> 0); Kp = length(pref)
    b_p = b[pref]
    return _solve_utility(p, b, b_p, function (m, x, γp)
        t = @variable(m, [1:Kp])
        for k in 1:Kp
            @constraint(m, [t[k], 1.0, x[k] - b_p[k]] in MOI.ExponentialCone())  # t ≤ log(n − b)
        end
        return sum(γp[k] * t[k] for k in 1:Kp)
    end)
end

# Stone–Geary with no γ > 0: the baselines b (shares), held under a finite β cap (spec §6: the cap
# applies to every allocator). Free hedge names are bought up to the least holding that meets every
# shared limit with the other names at b; without them the constant baselines must meet the cap.
# Otherwise n_prev is kept, with :infeasible (or :solver_failed from the hedge solve).
function _stone_geary_baselines(p::MyAllocationProblem, b::Vector{Float64})::MyAllocationResult
    c = p.constraints
    isfinite(c.β_max) || return _result(p, b, :no_preferred)
    hedge = _free_hedges(p)
    if isempty(hedge)
        dot(c.β, b .* p.prices) / p.W <= c.β_max && return _result(p, b, :no_preferred)
        return _result(p, copy(c.n_prev), :infeasible)
    end
    n, status = _min_hedge(p, b, Int[], hedge, b[hedge])
    status == :optimal || return _result(p, copy(c.n_prev), status)
    return _result(p, n, :no_preferred)
end

# Pin weights and the preferred names' share of the budget under the budget alone. Names with γ ≤ 0
# hold ε shares (weight ε·Sᵢ/W); B = W − Σ_{γ≤0} ε·Sᵢ (USD) is left for the names with γ > 0.
# Returns (w, pref, B/W): the pin weights (dimensionless; zero on pref), the γ > 0 indices, and B/W.
function _budget_split(γ::AbstractVector, S::AbstractVector, W::Real, ε::Real)
    pref = findall(>(0), γ)
    w = zeros(length(γ))
    for i in eachindex(γ)
        i in pref || (w[i] = ε * S[i] / W)
    end
    return w, pref, 1 - sum(w)
end

"""
    budget_only_weights(rule, γ::AbstractVector, S::AbstractVector; W::Real, ε::Real=1e-3)::Vector{Float64}

Dollar weights (dimensionless, Σ = 1) under the budget alone, in closed form. Names with γᵢ ≤ 0 hold
ε shares (weight ε·Sᵢ/W); the budget B = W − Σ_{γ≤0} ε·Sᵢ (USD) left over is split among the names with
γᵢ > 0: Cobb-Douglas in proportion to γᵢ, weight-based CES in proportion to γᵢ^η, CES in proportion to Sᵢ·(γᵢ/Sᵢ)^η (nᵢ ∝ (γᵢ/Sᵢ)^η, η = 1 is
Cobb-Douglas). With no γ > 0 it returns the pin weights only, as `allocate` does (`:no_preferred`).
The closed form assumes no free hedge names: every γ ≤ 0 name is pinned at ε. On a problem with hedge
names it is not the optimum of `allocate`.
`γ` has no units, `S` is USD/share and `W` is USD.
"""
function budget_only_weights end

function budget_only_weights(::MyCobbDouglasRule, γ::AbstractVector, S::AbstractVector;
        W::Real, ε::Real=1e-3)::Vector{Float64}
    w, pref, B = _budget_split(γ, S, W, ε)
    isempty(pref) && return w
    w[pref] .= B .* γ[pref] ./ sum(γ[pref])
    return w
end

function budget_only_weights(rule::MyCESRule, γ::AbstractVector, S::AbstractVector;
        W::Real, ε::Real=1e-3)::Vector{Float64}
    w, pref, B = _budget_split(γ, S, W, ε)
    isempty(pref) && return w
    v = S[pref] .* (γ[pref] ./ S[pref]) .^ rule.η
    w[pref] .= B .* v ./ sum(v)
    return w
end

function budget_only_weights(rule::MyCESWeightRule, γ::AbstractVector, S::AbstractVector;
        W::Real, ε::Real=1e-3)::Vector{Float64}
    w, pref, B = _budget_split(γ, S, W, ε)
    isempty(pref) && return w
    v = γ[pref] .^ rule.η
    w[pref] .= B .* v ./ sum(v)
    return w
end
