# 130/30 long-short Cobb-Douglas.
#
# Units as in Allocators.jl: shares n (shares; negative = short), prices S (USD/share), equity W
# (USD), weights w = n·S/W (dimensionless; negative = short). Long and short sides are financed the
# standard 130/30 way: short proceeds pay for the extra longs, net exposure Σwᵢ ≤ net_cap ≤ 1, so
# cash = 1 − Σwᵢ ≥ 0.

"""
    MyLongShortCDRule

130/30 long-short Cobb-Douglas: maximize Σ_{γᵢ>0} γᵢ·log nᵢ⁺ + Σ_{γᵢ<0} |γᵢ|·log nᵢ⁻ (shares), with
n = n⁺ − n⁻, longs only on γ > 0 names and hedge names, shorts only on γ < 0 names outside the hedge
pool, and other γ = 0 names held at zero. Hedge names are never shorted.
Fields (dimensionless, defaults from `MyLongShortCDRule()`):
- `long_cap = 1.30`: Σ long weights ≤ long_cap
- `short_cap = 0.30`: Σ |short weights| ≤ short_cap
- `net_cap = 1.00`: Σwᵢ ≤ net_cap (must be ≤ 1: cash ≥ 0)
"""
mutable struct MyLongShortCDRule <: AbstractPortfolioRule
    long_cap::Float64
    short_cap::Float64
    net_cap::Float64
    MyLongShortCDRule() = new(1.30, 0.30, 1.00)
end

"""
    build(::Type{MyLongShortCDRule}, data::NamedTuple)::MyLongShortCDRule

Build a long-short CD rule from `MyLongShortCDRule()` (1.30 / 0.30 / 1.00), overriding any of
`long_cap`, `short_cap`, `net_cap` (dimensionless) that `data` has. Requires finite positive caps
and net_cap ≤ 1 (net exposure above 1 would need negative cash).
"""
function build(::Type{MyLongShortCDRule}, data::NamedTuple)::MyLongShortCDRule
    model = MyLongShortCDRule()
    for f ∈ (:long_cap, :short_cap, :net_cap)
        haskey(data, f) && setfield!(model, f, Float64(data[f]))
    end
    for f ∈ (:long_cap, :short_cap, :net_cap)
        v = getfield(model, f)
        (isfinite(v) && v > 0) || throw(ArgumentError("$(f) must be finite and positive, got $(v)"))
    end
    model.net_cap <= 1 || throw(ArgumentError("net_cap must be ≤ 1 (cash ≥ 0), got $(model.net_cap)"))
    return model
end

"""
    allocate(rule::MyLongShortCDRule, p::MyAllocationProblem)::MyAllocationResult

130/30 long-short CD via exponential cones on n⁺ ≥ 1e-8 and n⁻ ≥ 1e-8 (shares). Long set: γ > 0
names and hedge names (`p.hedge`); short set: γ < 0 names that are not hedge names; other γ = 0 names
are fixed at 0. A hedge name with γ ≤ 0 is a long variable (n⁺ ≥ 1e-8) with no utility term and the
utility rules' tie-break cost of 1e-6 per unit of weight; as in the utility rules, a second solve
with every other name's shares fixed then minimizes the hedge weight, so a hedge is bought only as
far as a binding limit (β or volatility cap) needs it.

Constraints: Σ_{long} wᵢ ≤ long_cap, Σ_{short} |wᵢ| ≤ short_cap, Σwᵢ ≤ net_cap, plus
`add_shared_constraints!(…; signed=true)`: net exposure ≤ 1 (cash ≥ 0), |wᵢ| ≤ w_capᵢ, |net sector
weight| ≤ s_max, Σβᵢwᵢ ≤ β_max and √(wᵀΣ_g w) ≤ σ_g_max (yr⁻¹) on the signed weights, and the
turnover budget on the signed share changes (USD). `s_star` is the net exposure Σwᵢ.

Special cases: no γ > 0 → `:no_preferred` with n = 0 (all cash, no solve); an empty short set →
`allocate(MyCobbDouglasRule(), p)` with status `:long_only_fallback` (a failed CD solve keeps its
status). `:infeasible` / `:solver_failed` return n = n_prev.
"""
function allocate(rule::MyLongShortCDRule, p::MyAllocationProblem)::MyAllocationResult
    _check_problem(p)
    K = length(p.γ)
    any(>(0), p.γ) || return _result(p, zeros(K), :no_preferred)
    L = findall(i -> p.γ[i] > 0 || p.hedge[i], 1:K)          # long set: γ > 0 and hedge names
    Sh = findall(i -> p.γ[i] < 0 && !p.hedge[i], 1:K)        # short set: γ < 0 outside the pool
    if isempty(Sh)
        r = allocate(MyCobbDouglasRule(), p)
        r.status == :optimal && (r.status = :long_only_fallback)
        return r
    end
    nL = length(L); nS = length(Sh)
    U = findall(k -> p.γ[L[k]] > 0, 1:nL)                    # longs with a utility term
    H = findall(k -> p.γ[L[k]] <= 0, 1:nL)                   # free hedge longs (no utility term)
    γU = p.γ[L[U]]; γS = abs.(p.γ[Sh])
    function rows!(m, w)                                     # the 130/30's own rows
        @constraint(m, sum(w[i] for i in L) <= rule.long_cap)
        @constraint(m, sum(-w[i] for i in Sh) <= rule.short_cap)
        rule.net_cap < 1 && @constraint(m, sum(w) <= rule.net_cap)   # net ≤ 1 is the budget row
        return nothing
    end
    function build_model(opt)
        m = Model(opt)
        set_silent(m)
        x⁺ = @variable(m, [1:nL], lower_bound = 1e-8)
        x⁻ = @variable(m, [1:nS], lower_bound = 1e-8)
        t⁺ = @variable(m, [1:length(U)])
        t⁻ = @variable(m, [1:nS])
        for (j, k) in enumerate(U)
            @constraint(m, [t⁺[j], 1.0, x⁺[k]] in MOI.ExponentialCone())   # t⁺ ≤ log n⁺
        end
        for k in 1:nS
            @constraint(m, [t⁻[k], 1.0, x⁻[k]] in MOI.ExponentialCone())   # t⁻ ≤ log n⁻
        end
        n = AffExpr[AffExpr(0.0) for _ in 1:K]                  # other γ = 0 names: constant 0
        for (k, i) in enumerate(L)
            n[i] = AffExpr(0.0, x⁺[k] => 1.0)
        end
        for (k, i) in enumerate(Sh)
            n[i] = AffExpr(0.0, x⁻[k] => -1.0)
        end
        w = add_shared_constraints!(m, n, p; signed=true)
        rows!(m, w)
        util = sum(γU[j] * t⁺[j] for j in eachindex(U)) + sum(γS[k] * t⁻[k] for k in 1:nS)
        @objective(m, Max, isempty(H) ? util : util - _HEDGE_TIEBREAK * sum(w[L[k]] for k in H))
        return m, vcat(x⁺, x⁻)
    end
    x, status = _solve_with_fallback(build_model)
    status == :optimal || return _result(p, copy(p.constraints.n_prev), status)
    n = zeros(K)
    n[L] .= x[1:nL]
    n[Sh] .= -x[nL+1:end]
    if !isempty(H)
        n = first(_min_hedge(p, n, vcat(L[U], Sh), L[H], fill(1e-8, length(H));
            signed=true, rows! = rows!))
    end
    return _result(p, n, :optimal)
end
