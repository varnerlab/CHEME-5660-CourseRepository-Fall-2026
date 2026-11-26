# Study backtest loop (spec §5–§8): one run (allocator × screen × seed × settings) replayed day by day
# against a `MyStudyContext`, with run_backtest's fill, cost and accounting helpers. Decisions are made
# after the close on day t from data dated ≤ t; their orders fill at the open of day t+1 in fractional
# shares. A trigger re-picks the basket and re-plans the portfolio. With `hedge` on, the hedge pool joins every problem and the
# ξ-driven β cap applies to every decision.
#
# Units: shares (shares), prices (USD/share), equity, cash, costs and fees (USD), growth rates g_f, μ_g,
# σ_m and σ_g_max (yr⁻¹), Σ_g (yr⁻²), weights, β and ξ (dimensionless).

const _STUDY_ALLOCATORS = ("CD", "CES", "CESw", "SG", "MinVar", "Tangent", "LS")
const _STUDY_SCREENS = (:bandit, :gamma, :random, :global_gamma, :liquid_gamma, :corr_gamma,
    :random_global, :random_liquid, :fixed)

# Screens whose pick does not depend on the seed: a run list needs one seed for each.
const _STUDY_DETERMINISTIC = (:gamma, :global_gamma, :liquid_gamma, :corr_gamma, :fixed)
const _STUDY_CAP_TOL = 1e-6     # beta_target within this of beta_max counts as a binding cap (dimensionless)
const _STUDY_ACCEPTED = (:optimal, :fallback_minvar, :long_only_fallback)   # solved, limits met
const _STUDY_FAILED = (:infeasible, :solver_failed)                         # keep the whole book

"""
    MyStudyRun

One study run (`run_study`). Fields:

| Field | Meaning |
|---|---|
| `settings::MyStudySettings` | every window, limit and cost (units as in `MyStudySettings`) |
| `allocator::Union{String,AbstractPortfolioRule}` | a built-in allocator name or a rule that implements `allocate` |
| `screen::Union{Symbol,AbstractScreen}` | a built-in screen name or a screen that implements `pick` |
| `seed::Int` | screen and projection RNG seed (≥ 0) |
| `label::String` | run label (default `""`) |
"""
mutable struct MyStudyRun
    settings::MyStudySettings
    allocator::Union{String,AbstractPortfolioRule}
    screen::Union{Symbol,AbstractScreen}
    seed::Int
    label::String
    function MyStudyRun()
        r = new()
        r.label = ""
        return r
    end
end

"""
    build(::Type{MyStudyRun}, data::NamedTuple)::MyStudyRun

Build a run from `settings`, `allocator`, `screen`, `seed` and optional `label` (default `""`).
Pass a strategy object or a built-in name for `allocator` and `screen`. Throws `ArgumentError` on a
missing or unknown field, an unknown strategy name, or `seed < 0`.
"""
function build(::Type{MyStudyRun}, data::NamedTuple)::MyStudyRun
    for f in (:settings, :allocator, :screen, :seed)
        _require(data, MyStudyRun, f)
    end
    unknown = setdiff(keys(data), fieldnames(MyStudyRun))
    isempty(unknown) || throw(ArgumentError("Cannot build MyStudyRun: unknown field(s) $(collect(unknown))"))
    r = MyStudyRun()
    r.settings = data.settings
    if data.allocator isa AbstractPortfolioRule
        r.allocator = data.allocator
    else
        r.allocator = String(data.allocator)
        if !(r.allocator in _STUDY_ALLOCATORS)
            throw(ArgumentError("Invalid MyStudyRun: allocator must be one of $(_STUDY_ALLOCATORS), got $(repr(r.allocator))"))
        end
    end
    if data.screen isa AbstractScreen
        r.screen = data.screen
    else
        r.screen = Symbol(data.screen)
        if !(r.screen in _STUDY_SCREENS)
            throw(ArgumentError("Invalid MyStudyRun: screen must be one of $(_STUDY_SCREENS), got :$(r.screen)"))
        end
    end
    r.seed = data.seed
    haskey(data, :label) && (r.label = String(data.label))
    r.seed >= 0 || throw(ArgumentError("Invalid MyStudyRun: seed must be ≥ 0, got $(r.seed)"))
    return r
end

"""
    MyStudyResult

Output of `run_study`, one entry per trading day of the run in `dates`, `equity` (USD, at the close),
`cash` (USD, at the close) and `borrow_fees` (USD charged that day). Also:
- `trades::DataFrame`: as `MyBacktestResult.trades` (`date`, `ticker`, `qty`, `price`, `cost`, `scale`),
  with `qty` in fractional shares (Float64).
- `decisions::DataFrame`: `date`, `reason` (trigger), `status` (allocator), `n_names` (names with
  |target weight| > 1e-3), `invested_frac` (Σ target weights, net for 130/30), `μ_T`, `σ_T`
  (projected value mean/SD at the horizon T, USD), `beta_target` (Σ wᵢβᵢ of the target weights with
  the online β, dimensionless), `beta_max` (the β cap, `Inf` with the hedge off), `cap_binds` (an
  accepted status `:optimal`/`:fallback_minvar`/`:long_only_fallback`, a finite cap and
  beta_target ≥ beta_max − 1e-6), `hedge_weight` (Σ target weight of the hedge-pool names) and
  `solver` (Symbol: the worst solver outcome among the decision's solves, in the order `:none` <
  `:clarabel` < `:clarabel_almost` < `:scs` < `:failed`; `:none` when nothing was solved, as for pins or an
  empty 130/30; `:failed` is a sub-solve, such as the hedge step, that no solver accepted). After
  an `:infeasible` or `:solver_failed` decision the target book is the whole kept book (see
  `run_study`).
- `repicks::DataFrame`: `date`, `trigger` (the reason from `check_trigger`), `basket`, `pool`
  and `shorts` (tickers; `pool` in ranked order) and `changed` (the set basket ∪ pool ∪ shorts differs
  from the previous re-pick's; `true` at the initial re-pick).
- `daily::DataFrame`: `date`, `xi` (ξ, dimensionless), `beta_max` (`Inf` with the hedge off),
  `portfolio_beta` (Σ nᵢ·closeᵢ·βᵢ/V of the holdings at the close, online β, dimensionless),
  `hedge_weight` (value of the holdings in the current pool names / V) and `pool_size` (names).
- `targets[date]`: target weight wᵢ = nᵢSᵢ/W per name of the decision's book (the problem names with
  the continuous allocator output, held names outside it at target 0; or, after a failed solve, every
  held name at its held weight).
- `projections[date]`: the `MyProjection` (μ_τ, σ_τ for τ = 1..T, USD) of each decision.
"""
mutable struct MyStudyResult
    dates::Vector{Date}
    equity::Vector{Float64}
    cash::Vector{Float64}
    borrow_fees::Vector{Float64}
    trades::DataFrame
    decisions::DataFrame
    repicks::DataFrame
    daily::DataFrame
    targets::Dict{Date,Dict{String,Float64}}
    projections::Dict{Date,MyProjection}
    MyStudyResult() = new()
end

"""
    build(::Type{MyStudyResult}, data::NamedTuple)::MyStudyResult

Build a study result from a NamedTuple holding every field (see `MyStudyResult`).
"""
function build(::Type{MyStudyResult}, data::NamedTuple)::MyStudyResult
    model = MyStudyResult()
    for f in fieldnames(MyStudyResult)
        _require(data, MyStudyResult, f)
        setproperty!(model, f, data[f])
    end
    return model
end

"""
    make_rule(allocator::String, s::MyStudySettings)::AbstractPortfolioRule

The portfolio rule of `allocator`: `"CD"` Cobb-Douglas, `"CES"` (share-count) and `"CESw"` (weight-based) with η = `ces_eta`, `"SG"` Stone–Geary
with baseline fraction `sg_baseline`, `"MinVar"`, `"Tangent"`, `"LS"` 130/30 CD with caps `ls_long`,
`ls_short`, `ls_net` (all dimensionless). Throws `ArgumentError` on another name.
"""
function make_rule(allocator::String, s::MyStudySettings)::AbstractPortfolioRule
    allocator == "CD" && return MyCobbDouglasRule()
    allocator == "CES" && return build(MyCESRule, (η=s.ces_eta,))
    allocator == "CESw" && return build(MyCESWeightRule, (η=s.ces_eta,))
    allocator == "SG" && return build(MyStoneGearyRule, (baseline_frac=s.sg_baseline,))
    allocator == "MinVar" && return MyMinVarRule()
    allocator == "Tangent" && return MyTangentRule()
    allocator == "LS" && return build(MyLongShortCDRule, (long_cap=s.ls_long, short_cap=s.ls_short, net_cap=s.ls_net))
    throw(ArgumentError("unknown allocator $(repr(allocator)); expected one of $(_STUDY_ALLOCATORS)"))
end

make_rule(rule::AbstractPortfolioRule, ::MyStudySettings) = rule

"""
    make_screen(screen::Symbol, s::MyStudySettings)::AbstractScreen

The ticker screen of `screen`: `:bandit` (`MyBanditScreen` with `bandit_lookback`, `bandit_horizon`
in trading days, `bandit_eps_floor`, `bandit_iters_per_arm`, `bandit_min_iters`, `bandit_max_iters`),
`:gamma`, `:random`, and the universe-wide `:global_gamma`, `:liquid_gamma`, `:corr_gamma`, `:random_global`,
`:random_liquid` (from `basket_K`, `liquidity_shortlist`, `liquidity_window` in trading days, `corr_max`,
`corr_window` in trading days) and `:fixed` (`fixed_tickers`). Throws `ArgumentError` on another symbol.
"""
function make_screen(screen::Symbol, s::MyStudySettings)::AbstractScreen
    screen == :bandit && return build(MyBanditScreen, (lookback=s.bandit_lookback, horizon=s.bandit_horizon,
        ε_floor=s.bandit_eps_floor, iters_per_arm=s.bandit_iters_per_arm, min_iters=s.bandit_min_iters,
        max_iters=s.bandit_max_iters))
    screen == :gamma && return MyGammaScreen()
    screen == :random && return MyRandomScreen()
    screen == :global_gamma && return MyGlobalGammaScreen(s.basket_K)
    screen == :liquid_gamma && return MyLiquidGammaScreen(s.basket_K, s.liquidity_shortlist, s.liquidity_window)
    screen == :corr_gamma && return MyCorrGammaScreen(s.basket_K, s.corr_max, s.corr_window)
    screen == :random_global && return MyGlobalRandomScreen(s.basket_K)
    screen == :random_liquid && return MyLiquidRandomScreen(s.basket_K, s.liquidity_shortlist, s.liquidity_window)
    screen == :fixed && return MyFixedScreen(copy(s.fixed_tickers))
    throw(ArgumentError("unknown screen :$(screen); expected one of $(_STUDY_SCREENS)"))
end

make_screen(screen::AbstractScreen, ::MyStudySettings) = screen

"""
    uses_short_candidates(rule::AbstractPortfolioRule)::Bool

Whether the study loop builds a separate list of short candidates, ranked by γ, for `rule`. Only the 130/30 CD
rule does. A strategy file that hands its problem to `MyLongShortCDRule` returns `true` as well.
"""
function uses_short_candidates(rule::AbstractPortfolioRule)::Bool
    return false
end

function uses_short_candidates(rule::MyLongShortCDRule)::Bool
    return true
end

"""
    rule_preferences(rule::AbstractPortfolioRule, γ::Vector{Float64}, picked::Vector{Bool})::Vector{Float64}

The preference weights that one decision's allocation problem gives `rule`. `γ` holds the day's preference
weights (dimensionless) of the problem's columns. `picked[i]` is `true` when column `i` is in the screen's
basket. The built-in rules keep `γ`. A strategy file can return other weights, for example the weight `1` on
every picked column, so that its rule treats the picked stocks the same.
"""
function rule_preferences(rule::AbstractPortfolioRule, γ::Vector{Float64}, picked::Vector{Bool})::Vector{Float64}
    return γ
end

"""
    _study_problem_columns(rule, basket, pool, shorts, γ_row)::Tuple{Vector{Int},Vector{Bool}}

Ticker columns of one decision's allocation problem, sorted and unique, and their hedge flags (`true`
for a pool name). `γ_row` holds the day's γ (dimensionless) for every ticker. Long-only rules:
basket ∪ pool. `MyLongShortCDRule`: the basket names with γ > 0, the pool, and the short candidates
with γ < 0, so a candidate whose γ is no longer negative is left out (target 0). A pool name the screen
also picked appears once, flagged as a hedge.
"""
function _study_problem_columns(rule::AbstractPortfolioRule, basket::Vector{Int}, pool::Vector{Int},
        shorts::Vector{Int}, γ_row::AbstractVector)::Tuple{Vector{Int},Vector{Bool}}
    if uses_short_candidates(rule) == false
        cols = sort!(union(basket, pool))
        return cols, [j in pool for j in cols]
    end
    cols = sort!(union(filter(j -> γ_row[j] > 0, basket), pool, filter(j -> γ_row[j] < 0, shorts)))
    return cols, [j in pool for j in cols]
end

"""
    study_beta_limit(s::MyStudySettings, ξ_t::Real)::Float64

The full β limit of the whole book on a day with market state `ξ_t`: the largest β the book (stocks and the SPY
short together) may hold.

### Arguments
- `s::MyStudySettings`: the study settings (`hedge`, `beta_ref`, `kappa_beta`, `beta_min`).
- `ξ_t::Real`: the market state on that day (dimensionless).

### Returns
- `Float64`: `Inf` with the hedge off. With the hedge on, `beta_cap(ξ_t)` = max(`beta_min`, `beta_ref` −
  `kappa_beta`·ξ_t). With the v2 floor `beta_min = -0.5` the limit can be below `0`.

### Example
`study_beta_limit(build(MyStudySettings, (beta_min=-0.5, spy_short=true)), 1.3)` returns `-0.3` (to rounding).
"""
function study_beta_limit(s::MyStudySettings, ξ_t::Real)::Float64

    # with the hedge off there is no β limit
    if s.hedge == false
        return Inf;
    end

    # the β limit falls as the market state ξ rises, down to the floor beta_min
    return beta_cap(ξ_t; β_ref=s.beta_ref, κ_β=s.kappa_beta, β_min=s.beta_min);
end

"""
    spy_overlay_share(s::MyStudySettings, ξ_t::Real)::Float64

The SPY short of the v2 method, as a fraction of equity. When the β limit is below `0`, the stocks alone cannot
reach it, so the book sells SPY short to bring its β down to the limit.

### Arguments
- `s::MyStudySettings`: the study settings (`hedge`, `spy_short` and the β limit settings).
- `ξ_t::Real`: the market state on the decision day (dimensionless).

### Returns
- `Float64`: `0.0` unless both `hedge` and `spy_short` are on. Otherwise the part of the β limit below zero,
  max(0, −`study_beta_limit(s, ξ_t)`), which is at most −`beta_min` (`0.5` in v2).

### Example
With the β limit −0.3 on a 100,000 USD book, the share is `0.3`: the book sells 30,000 USD of SPY short.
"""
function spy_overlay_share(s::MyStudySettings, ξ_t::Real)::Float64

    # without the hedge or the SPY short switch there is no SPY short
    if s.hedge == false || s.spy_short == false
        return 0.0;
    end

    # the part of the β limit below zero is the SPY short's share of equity
    limit = study_beta_limit(s, ξ_t);
    return max(0.0, -limit);
end

"""
    allocator_beta_max(s::MyStudySettings, ξ_t::Real)::Float64

The β limit the allocators see: the largest β the stock book may hold at a re-plan.

### Arguments
- `s::MyStudySettings`: the study settings (`hedge`, `beta_ref`, `kappa_beta`, `beta_min`).
- `ξ_t::Real`: the market state on the decision day (dimensionless).

### Returns
- `Float64`: `Inf` with the hedge off. With the hedge on, `max(0, study_beta_limit(s, ξ_t))`, the full β limit
  cut at `0`.
  With the v1 floor `beta_min = 0` this is the v1 cap. With a negative floor (v2), the part of the limit below
  zero is covered by the SPY short (`spy_overlay_share`), so the allocators never see a negative limit.

### Example
`allocator_beta_max(build(MyStudySettings, (beta_min=-0.5, spy_short=true)), 1.3)` returns `0.0`.
"""
function allocator_beta_max(s::MyStudySettings, ξ_t::Real)::Float64

    # the full β limit: Inf with the hedge off, and below zero in v2 when ξ is past 1
    limit = study_beta_limit(s, ξ_t);

    # the allocators see the limit cut at zero (max(0, Inf) stays Inf)
    return max(0.0, limit);
end

"""
    _study_residuals(ctx, st, t, cols, α, β)::Matrix{Float64}

The SIM residual growth rates of the ticker columns `cols` over the Ω growth days into rows t−Ω+1..t.

### Arguments
- `ctx::MyStudyContext`: the study context (market data).
- `st::MyStudySettings`: the run's settings (`omega_window` Ω in trading days).
- `t::Int`: the market-data row.
- `cols::Vector{Int}`: the ticker columns.
- `α::AbstractVector{<:Real}`: the online SIM α of `cols` (yr⁻¹).
- `β::AbstractVector{<:Real}`: the online SIM β of `cols` (dimensionless).

### Returns
- `Matrix{Float64}`: the residual growth rates E (yr⁻¹), one row per growth day and one column per ticker.
"""
function _study_residuals(ctx::MyStudyContext, st::MyStudySettings, t::Int, cols::Vector{Int},
        α::AbstractVector{<:Real}, β::AbstractVector{<:Real})::Matrix{Float64}
    md = ctx.md;
    Ω = st.omega_window;
    return residual_matrix(growth_rates(md.close[t-Ω:t, cols]), growth_rates(md.spy_close[t-Ω:t]), α, β);
end

"""
    _study_covariance(ctx, st, t, cols, α, β, σ_M)::Matrix{Float64}

The growth covariance (§7) of the ticker columns `cols` after the close of market-data row `t`:
Σ_g = σ²_M·ββᵀ + (1−λ)·Ω̂_ε + λ·diag(Ω̂_ε).

### Arguments
- `ctx::MyStudyContext`: the study context (market data and calibration).
- `st::MyStudySettings`: the run's settings (`omega_window` Ω in trading days, and `lambda`).
- `t::Int`: the market-data row.
- `cols::Vector{Int}`: the ticker columns.
- `α::AbstractVector{<:Real}`: the online SIM α of `cols` (yr⁻¹).
- `β::AbstractVector{<:Real}`: the online SIM β of `cols` (dimensionless).
- `σ_M::Float64`: the market volatility (yr⁻¹).

### Returns
- `Matrix{Float64}`: Σ_g (yr⁻²). The residuals E are the SIM residual growth rates (yr⁻¹) over the Ω growth days
  into rows t−Ω+1..t, Ω̂_ε comes from the standard deviation and correlation of each column of E, and λ is the
  `lambda` setting (`calib.λ` when the setting is NaN). With `covariance_model = "sector_factor"` (course
  addition), Σ_g is `sector_factor_covariance` of the same β, σ_M and residual standard deviations.
"""
function _study_covariance(ctx::MyStudyContext, st::MyStudySettings, t::Int, cols::Vector{Int},
        α::AbstractVector{<:Real}, β::AbstractVector{<:Real}, σ_M::Float64)::Matrix{Float64}
    Ω = st.omega_window;

    # the SIM residual growth rates (yr⁻¹) over the Ω growth days into rows t−Ω+1..t
    E = _study_residuals(ctx, st, t, cols, α, β);

    # the shrinkage weight λ: the setting, or the calibrated value when the setting is NaN
    λ = st.lambda;
    if isnan(λ)
        λ = ctx.calib.λ;
    end

    # Σ_g from the market part and the shrunk residual covariance
    σ_res = std.(eachcol(E));
    if st.covariance_model == "sector_factor"
        # course addition: the market part and the sector blocks of the factor forecast's models
        return sector_factor_covariance(β, σ_res, σ_M, ctx.md.tickers[cols], ctx.fm);
    end
    model = build(MyShrunkResidualCovariance, (λ=λ, window=Ω));
    return growth_covariance(model, β, σ_res, σ_M; residuals=E);
end

"""
    _study_problem(ctx, run, t::Int, cols::Vector{Int}, hedge::Vector{Bool}, held::AbstractVector{<:Real},
        V::Float64; basket::Vector{Int}=Int[], rule=make_rule(run.allocator, run.settings))::MyAllocationProblem

The allocation problem after the close of market-data row `t` for the ticker columns `cols` (hedge
flags `hedge`), with holdings `held` (shares, one per ticker) and equity `V` (USD). With
s = t − first(ctx.rows) + 1, S = close[t, cols] (USD/share) and Ω = `omega_window` (trading days):

- γ = ctx.γ[s, cols]; α (yr⁻¹), β from `ctx.sim` at row s; μ_g = `expected_growth(rule, α, β, g̃[t])` (yr⁻¹).
- E = SIM residual growth rates (yr⁻¹) over the Ω growth days into rows t−Ω+1..t with that α, β;
  Σ_g = σ²_M·ββᵀ + (1−λ)·Ω̂_ε + λ·diag(Ω̂_ε) (yr⁻², §7) via `growth_covariance` with σ̂ = std of each
  column of E, σ_M = ctx.sim.σ_m[s] and λ = `lambda` (`calib.λ` when NaN).
- Limits: `w_max`, `s_max`, σ_g_max = `vol_cap_annual`/√Δt (`calib.σ_m` when NaN, yr⁻¹),
  spread-cost budget K_turnover = `turnover_frac`·V (USD), c̄ = `half_spread_bps`·1e-4·mean(S) (USD/share),
  n_prev = held[cols], ε = 1e-3 shares, the online β, and β_max = `beta_cap(ξ[t])` with the
  `beta_ref`, `kappa_beta`, `beta_min` settings when `hedge` is on (else Inf).
- Per-name caps: `w_cap[i] = max(w_max, w_max_scale/length(basket))` when `cols[i] ∈ basket` (the screen
  picks, a pick that is also pooled included), else `w_max`; a 130/30 short column (γ < 0, not a hedge name)
  keeps `w_max` even if picked; the default empty `basket` gives `w_max` everywhere.
- prices = S, W = V, g_f = g_f[t] (yr⁻¹).
"""
function _study_problem(ctx::MyStudyContext, run::MyStudyRun, t::Int, cols::Vector{Int}, hedge::Vector{Bool},
        held::AbstractVector{<:Real}, V::Float64; basket::Vector{Int}=Int[],
        rule::AbstractPortfolioRule=make_rule(run.allocator, run.settings))::MyAllocationProblem
    st = run.settings; md = ctx.md
    s = t - first(ctx.rows) + 1
    S = md.close[t, cols]
    α = ctx.sim.α[s, cols]; β = ctx.sim.β[s, cols]
    μ_g = expected_growth(rule, α, β, ctx.g̃[t])
    Σ_g = _study_covariance(ctx, st, t, cols, α, β, ctx.sim.σ_m[s])
    σ_g_max = isnan(st.vol_cap_annual) ? ctx.calib.σ_m : st.vol_cap_annual / sqrt(_BT_DT)
    cap_pick = isempty(basket) ? st.w_max : max(st.w_max, st.w_max_scale / length(basket))
    # a column the 130/30 rule shorts (γ < 0, not a hedge name) keeps w_max even when the screen picked it
    w_cap = fill(st.w_max, length(cols))
    short_candidates_on = uses_short_candidates(rule)
    for i in eachindex(cols)
        is_short = short_candidates_on && ctx.γ[s, cols[i]] < 0 && !hedge[i]
        if cols[i] in basket && !is_short
            w_cap[i] = cap_pick
        end
    end
    cs = build(MyConstraintSet, (w_max=st.w_max, w_cap=w_cap, s_max=st.s_max, σ_g_max=σ_g_max,
        K_turnover=st.turnover_frac * V, c̄=st.half_spread_bps * 1e-4 * mean(S),     # bps → fraction
        sector=md.sector[cols], n_prev=Float64.(held[cols]), ε=_BT_ε, β=β,
        β_max=allocator_beta_max(st, ctx.ξ[t])))
    # the rule's preference weights: the day's γ for the built-in rules -
    picked = Bool[j in basket for j in cols]
    γ = rule_preferences(rule, ctx.γ[s, cols], picked)
    return build(MyAllocationProblem, (γ=γ, μ_g=μ_g, Σ_g=Σ_g, prices=S, W=V, g_f=md.g_f[t],
        constraints=cs, hedge=hedge))
end

"""
    _study_decision(ctx, run, rule, t::Int, basket, pool, shorts, held::AbstractVector{<:Real}, V::Float64)::NamedTuple

One decision after the close of market-data row `t` (holdings `held` in shares, equity `V` in USD).
Returns the book it leaves, `(status, solver, cols, n, S, μ_g, Σ_g, β, β_max, hedge, trade, α, g̃_M, σ_M, σ_res)`:
`solver` is the worst outcome of the decision's solves (`:none`, `:clarabel`, `:clarabel_almost`, `:scs` or `:failed`,
`:none` when nothing was solved), then ticker columns,
shares n (shares), close prices S (USD/share), μ_g (yr⁻¹), Σ_g (yr⁻²), online β (dimensionless) and
hedge flags of those columns, the β cap (dimensionless) and whether to queue orders. The last four are the factor
forecast's inputs, the same online levels the allocation used (method v2): the columns' online α (yr⁻¹), the
market growth average g̃[t] and the online market volatility σ_M (yr⁻¹), and the columns' residual volatility
σ_res (yr⁻¹, the standard deviation of each column of the residuals behind Σ_g).

- **Solved** (any status but `:infeasible`/`:solver_failed`): the `_study_problem` on
  `_study_problem_columns` and the allocator's shares; non-finite shares count as `:solver_failed`
  (R29). `trade = true`.
- **Failed** (`:infeasible`, `:solver_failed`): keep every holding (spec §6): the columns are the
  names with nonzero holdings (the problem columns at zero shares when there are none), with μ_g, Σ_g
  and β from `_study_problem` on them, and n = the held shares. `trade = false`.
- **Empty problem** (a 130/30 whose basket names all have γ ≤ 0, with an empty pool and no short
  candidate at γ < 0): `:no_preferred` with no columns, so every holding targets 0 and the book is
  all cash. `trade = true`.

### Arguments
- `ctx::MyStudyContext`: the study context.
- `run::MyStudyRun`: the run (its settings and allocator).
- `rule::AbstractPortfolioRule`: the allocator's rule.
- `t::Int`: the market-data row of the decision.
- `basket::Vector{Int}`: the screen's picks (ticker columns).
- `pool::Vector{Int}`: the hedge pool (ticker columns).
- `shorts::Vector{Int}`: the 130/30 short candidates (ticker columns).
- `held::AbstractVector{<:Real}`: the holdings of every ticker (shares).
- `V::Float64`: the equity (USD).

### Returns
- `NamedTuple`: the book described above.
"""
function _study_decision(ctx::MyStudyContext, run::MyStudyRun, rule::AbstractPortfolioRule, t::Int,
        basket::Vector{Int}, pool::Vector{Int}, shorts::Vector{Int}, held::AbstractVector{<:Real}, V::Float64)::NamedTuple
    s = t - first(ctx.rows) + 1
    cols, hedge = _study_problem_columns(rule, basket, pool, shorts, view(ctx.γ, s, :))
    if isempty(cols)
        return (status=:no_preferred, solver=:none, cols=Int[], n=Float64[], S=Float64[], μ_g=Float64[], Σ_g=zeros(0, 0),
            β=Float64[], β_max=allocator_beta_max(run.settings, ctx.ξ[t]), hedge=Bool[], trade=true,
            α=Float64[], g̃_M=ctx.g̃[t], σ_M=ctx.sim.σ_m[s], σ_res=Float64[])
    end
    p = _study_problem(ctx, run, t, cols, hedge, held, V; basket=basket, rule=rule)
    log = Symbol[]
    r = Base.ScopedValues.with(() -> allocate(rule, p), _SOLVER_LOG => log)
    all(isfinite, r.n) || (r = _result(p, copy(p.constraints.n_prev), :solver_failed))   # R29
    n = r.n; trade = true
    if r.status in _STUDY_FAILED
        kept = findall(!=(0), held)
        if !isempty(kept) && kept != cols
            cols = kept; hedge = [j in pool for j in cols]
            p = _study_problem(ctx, run, t, cols, hedge, held, V; rule=rule)
        end
        n = Float64.(held[cols]); trade = false
    end
    c = p.constraints

    # the factor forecast's inputs for the final columns: the online α, and each column's residual volatility
    α = ctx.sim.α[s, cols];
    E = _study_residuals(ctx, run.settings, t, cols, α, c.β);
    σ_res = std.(eachcol(E));
    return (status=r.status, solver=_worst_solver(log), cols=cols, n=n, S=p.prices, μ_g=p.μ_g, Σ_g=p.Σ_g, β=c.β, β_max=c.β_max,
        hedge=hedge, trade=trade, α=α, g̃_M=ctx.g̃[t], σ_M=ctx.sim.σ_m[s], σ_res=σ_res)
end

# The executable shares of a book: shares n of names at close prices S (USD/share), with every name whose
# value is at most `_BT_HELD_W`·V (equity V, USD) set to 0 shares. This removes the ε pins of the log
# utilities and solver dust, which whole-share rounding used to remove **(plan decision)**.
_study_lots(n::AbstractVector{<:Real}, S::AbstractVector{<:Real}, V::Real)::Vector{Float64} =
    [abs(n[i] * S[i]) > _BT_HELD_W * V ? Float64(n[i]) : 0.0 for i in eachindex(n)]

"""
    _study_fill_orders!(held, cash, n_spy, spy_target, pending, md, t, tr; half_spread_bps, κ)::NamedTuple

Step 1 of a study day: fill the orders queued on the day before at the open of market-data row `t`.

The SPY order fills first. A short sale adds its proceeds to cash before the stock buys, and a cover is paid in
full, never scaled down for cash. SPY pays the half spread and no impact term, because the data hold no SPY
volume. Then the stock orders fill as `_bt_fill!` fills them: sells first, then the buys, scaled by one factor
when cash cannot pay for all of them.

### Arguments
- `held::Vector{Float64}`: the stock holdings (shares, one per ticker column), updated in place.
- `cash::Float64`: cash before the fills (USD).
- `n_spy::Float64`: SPY shares held (negative for a short).
- `spy_target::Float64`: the SPY shares the last decision asked for.
- `pending`: the queued stock orders `(cols, n, adv)`, or `nothing` when there are none.
- `md::MyMarketData`: the market data (`spy_open`, `open`, `volume`).
- `t::Int`: the market-data row of the fills.
- `tr::_BTTrades{Float64}`: the trade log; each fill adds a row, SPY under the ticker `"SPY"`.
- `half_spread_bps::Float64`: the half spread (bps).
- `κ::Float64`: the impact coefficient of the stock fills (dimensionless).

### Returns
- `NamedTuple` `(cash, n_spy)`: cash after the fills (USD) and the SPY shares held after the fills.
"""
function _study_fill_orders!(held::Vector{Float64}, cash::Float64, n_spy::Float64, spy_target::Float64, pending,
        md::MyMarketData, t::Int, tr::_BTTrades{Float64}; half_spread_bps::Float64, κ::Float64)::NamedTuple

    # the SPY order (shares): negative sells short, positive covers
    q = spy_target - n_spy;
    if q != 0.0

        # SPY fills at its open with the half spread and no impact term
        px = md.spy_open[t];
        cost = trade_cost(q, px, 1.0; half_spread_bps=half_spread_bps, κ=0.0);

        # receive the proceeds of a short sale, or pay for a cover, and pay the cost
        cash = cash - (q * px + cost);
        n_spy = spy_target;

        # log the SPY fill at full size
        push!(tr.date, md.dates[t]); push!(tr.ticker, "SPY"); push!(tr.qty, q);
        push!(tr.price, px); push!(tr.cost, cost); push!(tr.scale, 1.0);
    end

    # the stock orders: sells first, then the buys, scaled when cash is short
    if pending !== nothing
        cash = _bt_fill!(held, cash, pending, md, t, tr; half_spread_bps=half_spread_bps, κ=κ);
    end
    return (cash=cash, n_spy=n_spy);
end

"""
    _study_accrue(cash, held, n_spy, md, t, borrow_rate)::NamedTuple

Step 2 of a study day: interest on cash and the borrow fee on the shorts at the close of market-data row `t`.

Short-sale proceeds sit in cash, so they earn interest like any other cash. The SPY short is charged the same
borrow fee as a 130/30 stock short.

### Arguments
- `cash::Float64`: cash after the day's fills (USD).
- `held::Vector{Float64}`: the stock holdings (shares, one per ticker column).
- `n_spy::Float64`: SPY shares held (negative for a short).
- `md::MyMarketData`: the market data (`g_f`, `close`, `spy_close`).
- `t::Int`: the market-data row.
- `borrow_rate::Float64`: the borrow rate (yr⁻¹).

### Returns
- `NamedTuple` `(cash, fee)`: cash after interest and the fee (USD), and the borrow fee (USD).
"""
function _study_accrue(cash::Float64, held::Vector{Float64}, n_spy::Float64, md::MyMarketData, t::Int,
        borrow_rate::Float64)::NamedTuple

    # positive cash, short-sale proceeds included, earns the risk-free rate over one day
    if cash > 0
        cash = cash * exp(md.g_f[t] * _BT_DT);
    end

    # the short notional (USD) at the close: the stock shorts, then the SPY short
    short = _bt_short_notional(held, md, t);
    if n_spy < 0
        short = short - n_spy * md.spy_close[t];
    end

    # the borrow fee on the short notional
    fee = 0.0;
    if short > 0
        fee = borrow_fee(short; rate=borrow_rate, Δt=_BT_DT);
        cash = cash - fee;
    end
    return (cash=cash, fee=fee);
end

"""
    _study_scale_failed_book(n, S, β, V, limit)::Vector{Float64}

The stock book after a failed solve, when the β trigger is on. Keeping a book that is over its β limit would
leave the β trigger true, and the book would re-plan every day. So a book over its limit is scaled down by one
factor until its β equals the limit, and the rest of its value goes to cash.

### Arguments
- `n::Vector{Float64}`: the held shares of the book's columns.
- `S::Vector{Float64}`: the close prices of those columns (USD/share).
- `β::Vector{Float64}`: the online β of those columns (dimensionless).
- `V::Float64`: equity (USD).
- `limit::Float64`: the full β limit (`study_beta_limit`; `Inf` with the hedge off).

### Returns
- `Vector{Float64}`: the shares to hold. A book at or under its limit is kept. At a limit of `0` or below the
  stocks go to cash (the SPY short covers a limit below `0`). Otherwise every holding is scaled by
  limit / (book β), where the book β is Σ nᵢSᵢβᵢ / V.

### Example
A book with β 0.2 and a limit of 0.1 is scaled by one half.
"""
function _study_scale_failed_book(n::Vector{Float64}, S::Vector{Float64}, β::Vector{Float64}, V::Float64,
        limit::Float64)::Vector{Float64}

    # the β of the held stock book, as a fraction of equity
    book_beta = 0.0;
    for i in eachindex(n)
        book_beta = book_beta + n[i] * S[i] * β[i] / V;
    end

    # a book at or under its limit is kept
    if book_beta <= limit
        return copy(n);
    end

    # at a limit of 0 or below, the stocks go to cash
    if limit <= 0.0
        return zeros(length(n));
    end

    # otherwise scale every holding by one factor, so the book's β equals the limit
    factor = limit / book_beta;
    return n .* factor;
end

"""
    _study_project_book(ctx, st, seed, t, n, S, μ_g, Σ_g, β, n_spy, V)::MyProjection

The `project_gbm` forecast of the book a decision leaves after the close of market-data row `t`: the stocks,
the SPY short and the rest in cash.

### Arguments
- `ctx::MyStudyContext`: the study context (market data, `g̃`, the online σ_M).
- `st::MyStudySettings`: the run's settings (`T` trading days and `n_paths`).
- `seed::Int`: the run seed; the paths use `MersenneTwister(_bt_projection_seed(seed, date))` (R28).
- `t::Int`: the market-data row of the decision.
- `n::Vector{Float64}`: the stock shares of the book's columns.
- `S::Vector{Float64}`: their close prices (USD/share).
- `μ_g::Vector{Float64}`: their expected growth rates (yr⁻¹).
- `Σ_g::Matrix{Float64}`: their growth covariance (yr⁻²).
- `β::Vector{Float64}`: their online β (dimensionless).
- `n_spy::Float64`: the SPY shares of the book (negative for a short).
- `V::Float64`: equity (USD).

### Returns
- `MyProjection`: the wealth mean and standard deviation (USD) for τ = 1..`T`. With no SPY position this is the
  v1 forecast of the stocks and cash V − n·S. With a SPY position, SPY is one more column: its growth rate has
  mean g̃[t] and variance σ²_M, and its covariance with name i is βᵢσ²_M, as in the single-index model.
"""
function _study_project_book(ctx::MyStudyContext, st::MyStudySettings, seed::Int, t::Int, n::Vector{Float64},
        S::Vector{Float64}, μ_g::Vector{Float64}, Σ_g::Matrix{Float64}, β::Vector{Float64}, n_spy::Float64,
        V::Float64)::MyProjection
    md = ctx.md;
    rng = MersenneTwister(_bt_projection_seed(seed, md.dates[t]));

    # a book without SPY: the stocks and cash, as in v1
    if n_spy == 0.0
        return project_gbm(n, S, V - dot(n, S), μ_g, Σ_g, md.g_f[t]; T=st.T, N=st.n_paths, rng=rng);
    end

    # SPY as one more column, after the K stock columns
    s = t - first(ctx.rows) + 1;
    σ_M = ctx.sim.σ_m[s];
    K = length(n);
    Σ_all = zeros(K + 1, K + 1);
    for i in 1:K
        for j in 1:K
            Σ_all[i, j] = Σ_g[i, j];
        end
        # SPY moves with the market factor, so its covariance with name i is βᵢσ²_M
        Σ_all[i, K + 1] = β[i] * σ_M^2;
        Σ_all[K + 1, i] = β[i] * σ_M^2;
    end
    Σ_all[K + 1, K + 1] = σ_M^2;

    # cash is what is left of equity after the stocks and the SPY position
    cash = V - dot(n, S) - n_spy * md.spy_close[t];
    return project_gbm(vcat(n, n_spy), vcat(S, md.spy_close[t]), cash, vcat(μ_g, ctx.g̃[t]), Σ_all, md.g_f[t];
        T=st.T, N=st.n_paths, rng=rng);
end

"""
    _study_forecast(ctx, st, seed, t, b, n, n_spy, V)::MyProjection

The forecast of the book a decision leaves after the close of market-data row `t`, with the run's forecast model.

### Arguments
- `ctx::MyStudyContext`: the study context (market data, and the forecast models `fm` for the factor forecast).
- `st::MyStudySettings`: the run's settings (`forecast_model`, `forecast_band`, `T` trading days and `n_paths`).
- `seed::Int`: the run seed.
- `t::Int`: the market-data row of the decision.
- `b::NamedTuple`: the decision (`_study_decision`): its columns, their prices S (USD/share), μ_g (yr⁻¹), Σ_g (yr⁻²),
  α (yr⁻¹) and β, and g̃_M, σ_M and σ_res (yr⁻¹).
- `n::Vector{Float64}`: the stock shares of the book's columns (the decision's shares, or the scaled-down book).
- `n_spy::Float64`: the SPY shares of the book (negative for a short).
- `V::Float64`: equity (USD).

### Returns
- `MyProjection`: with `forecast_model = "gbm"`, the GBM forecast of `_study_project_book`. With `"factor"`,
  `project_factor` of the stocks, the SPY position and cash V − n·S − n_spy·spy_close[t], with the forecast seed
  `_bt_projection_seed(seed, date)` and the `forecast_band` band.
"""
function _study_forecast(ctx::MyStudyContext, st::MyStudySettings, seed::Int, t::Int, b::NamedTuple,
        n::Vector{Float64}, n_spy::Float64, V::Float64)::MyProjection
    md = ctx.md;

    # the v1 forecast: the multi-asset GBM
    if st.forecast_model == "gbm"
        return _study_project_book(ctx, st, seed, t, n, b.S, b.μ_g, b.Σ_g, b.β, n_spy, V);
    end

    # the v2 forecast: the JumpHMM factor model; cash is what is left after the stocks and the SPY position
    d = md.dates[t];
    cash = V - dot(n, b.S) - n_spy * md.spy_close[t];
    return project_factor(n, b.S, n_spy, md.spy_close[t], cash, b.α, b.β, b.g̃_M, b.σ_M, b.σ_res, md.tickers[b.cols],
        ctx.fm, md.g_f[t]; T=st.T, N=st.n_paths, seed=_bt_projection_seed(seed, d), band=st.forecast_band,
        label="run seed $(seed), $(d)");
end

"""
    _study_book_vol(ctx, st, t, held, n_spy, V)::Float64

The model volatility of the whole book held at the close of market-data row `t`: the stocks and the SPY short.

### Arguments
- `ctx::MyStudyContext`: the study context (market data and the online SIM).
- `st::MyStudySettings`: the run's settings (for the growth covariance).
- `t::Int`: the market-data row.
- `held::Vector{Float64}`: the stock holdings (shares, one per ticker column).
- `n_spy::Float64`: SPY shares held (negative for a short).
- `V::Float64`: equity (USD).

### Returns
- `Float64`: the volatility (yr⁻¹ᐟ², the units of `vol_cap_annual`), σ·√Δt with
  σ² = wᵀΣ_g w + w²_spy·σ²_M + 2·w_spy·σ²_M·Σβᵢwᵢ (yr⁻²). The weights are wᵢ = nᵢ·closeᵢ/V and
  w_spy = n_spy·spy_close/V, and Σ_g, β and σ_M are the online values on row `t`. An all-cash book returns `0`.
"""
function _study_book_vol(ctx::MyStudyContext, st::MyStudySettings, t::Int, held::Vector{Float64}, n_spy::Float64,
        V::Float64)::Float64
    md = ctx.md;
    s = t - first(ctx.rows) + 1;
    σ_M = ctx.sim.σ_m[s];

    # the SPY weight (negative for a short) and its own variance (yr⁻²)
    w_spy = n_spy * md.spy_close[t] / V;
    variance = w_spy^2 * σ_M^2;

    # the columns of the stocks held at the close
    cols = Int[];
    for j in eachindex(held)
        if held[j] != 0
            push!(cols, j);
        end
    end

    # the stocks: wᵀΣ_g w, plus the cross term with SPY through the market factor
    if length(cols) > 0
        w = held[cols] .* md.close[t, cols] ./ V;
        β = ctx.sim.β[s, cols];
        Σ_g = _study_covariance(ctx, st, t, cols, ctx.sim.α[s, cols], β, σ_M);
        variance = variance + dot(w, Σ_g * w) + 2 * w_spy * σ_M^2 * dot(w, β);
    end

    # annual volatility σ·√Δt; rounding can leave a tiny negative variance, which counts as 0
    return sqrt(max(variance, 0.0) * _BT_DT);
end

"""
    run_study(ctx::MyStudyContext, run::MyStudyRun)::MyStudyResult

Replay `run` on the context's rows `ctx.rows`, with equity starting at `W0` (USD) in cash at the start
close. `run.settings` must share the context's `context_key`. On each trading day t (row s), in order:

1. **Fill** the orders queued on day t−1 (`_study_fill_orders!`). The SPY order fills first, at
   `spy_open[t]` with the half spread and no impact term: a short sale's proceeds go to cash before the
   stock buys, and a cover is paid in full. Then the stock orders fill at `open[t]` as `run_backtest` fills
   them, but in fractional shares (sells first, buys scaled if cash would go negative), with costs from
   `half_spread_bps` and `impact_kappa`.
2. **Accrue** positive cash by exp(g_f[t]·Δt) and charge `borrow_fee` at `borrow_rate` on the short
   notional (USD): the stock shorts at `close[t]` and the SPY short at `spy_close[t]` (`_study_accrue`).
   Skipped on the first day.
3. **Mark** V = cash + Σ nᵢ·close[t, i] + n_spy·spy_close[t] (USD).
4. **Trigger:** `check_trigger` with τ = trading days since the last decision, V, wealth_peak = running
   max of equity (set back to V by each `:drawdown` decision when `drawdown_reset`, else never reset), `initial`
   on the first day, and the MPC spec from `T`, `z`, `n_paths`,
   `D_max`, `cash_revisit`. The v2 triggers come from `market_turn`, `beta_over_cap` and
   `turn_at_one = hedge && spy_short`, with ξ[t], ξ at the last decision, the whole book's β (the SPY weight
   included) and the full β limit `study_beta_limit(st, ξ[t])`.
5. **Re-pick** when `check_trigger` returns a decision reason, including `:initial` on the first day.
   Run the screen's `pick` (N = `N_per_sector`, seed = `run.seed`), take the pool `ctx.pool[s]`
   with the hedge on, and choose the `short_candidates` outside the pool for 130/30 Cobb–Douglas.
6. **Decide** on the same trigger (`_study_decision`). Call `allocate` on the problem from
   `_study_problem_columns` and `_study_problem` (non-finite shares count as `:solver_failed`, R29).
   After a solve, queue orders for t+1 at the executable shares `_study_lots` (a target worth at most
   0.1% of V trades to 0; held names outside the problem target 0; none on the last day). After `:infeasible` or `:solver_failed`, queue no orders and keep every holding (spec §6).
   An empty 130/30 problem records `:no_preferred` and targets every holding to 0. Then
   `project_gbm` of the resulting book (the targets, or the kept holdings) with cash V − n·S and
   `rng = MersenneTwister(seed·1_000_003 + Dates.value(date))` (R28), and the decision row. With
   `forecast_model = "factor"` (method v2), the forecast is `project_factor` instead, with that number as its
   forecast seed and the `forecast_band` band (`_study_forecast`). τ resets
   to 0, ξ at the decision is stored for the market-turn trigger, the decision row records `elapsed` (trading
   days since the last decision) and `last_alloc_was_cash = (status == :no_preferred)`. With `drawdown_reset`,
   a `:drawdown` decision sets
   the drawdown peak back to V, even when its solve fails and the book is kept (user, 2026-10-25). The projection becomes the trigger's
   band, except for a book with no executable shares (every target, or every kept holding, is worth at
   most 0.1% of V): such a book has no band, so the band-exit trigger cannot fire and
   `cash_revisit` (or the horizon or drawdown trigger) governs the return from cash; its
   projection is still recorded **(plan decision)**.

   The SPY short (method v2): s = `spy_overlay_share(st, ξ[t])` is the share of equity sold short in SPY
   (`0` unless `hedge` and `spy_short` are on). The stocks are solved on (1 − s)·V at the allocator limit
   `allocator_beta_max`, and the SPY order targets −s·V/spy_close[t] shares at every decision, a failed stock
   solve included. With a finite `beta_over_cap` (the β trigger), a failed solve whose kept book is over the
   full β limit `study_beta_limit` scales that book down to the limit (`_study_scale_failed_book`) and trades.
   The projection includes the SPY position (`_study_project_book`), and a book with a SPY short has a band
   even when it holds no stocks. The decision row adds `spy_share` (s) and `limit_below_zero`.
7. **Daily row:** ξ[t], the allocator's β limit `beta_max` (`allocator_beta_max`), the holdings' β and hedge
   weight, the pool size, and for the whole book the SPY weight `spy_weight`, the β with SPY included
   `book_beta`, the model volatility `book_vol` (`_study_book_vol`, yr⁻¹ᐟ²), and the whole book's β limit
   `book_beta_limit` (`study_beta_limit`, `Inf` with the hedge off). `spy_gain` (USD) is the SPY position's gain
   that day: the shares held overnight times (open − last close) plus the shares held after the day's fill times
   (close − open), `0` on the first day. `spy_rose` is whether SPY closed above its last close (`false` on the
   first day).

Throws `ArgumentError` when the settings do not match the context's, when
`forecast_model = "factor"` and the context has no forecast models (`ctx.fm === nothing`), when the first
run row is ≤ the run's `omega_window` (trading days; not part of `context_key`, so checked here per run),
or when a screen cannot pick (e.g. a bandit lookback longer than the data); allocator and projection
errors propagate.

### Arguments
- `ctx::MyStudyContext`: the study context, built for `run.settings`.
- `run::MyStudyRun`: the run: settings, allocator, screen and seed.

### Returns
- `MyStudyResult`: the run's dates, equity and cash (USD), trades, decisions, re-picks, projections and daily rows.
"""
function run_study(ctx::MyStudyContext, run::MyStudyRun)::MyStudyResult
    st = run.settings; md = ctx.md
    isequal(context_key(st), context_key(ctx.settings)) ||
        throw(ArgumentError("run settings do not match the context's: $(context_key(st)) vs $(context_key(ctx.settings))"))
    first(ctx.rows) > st.omega_window ||
        throw(ArgumentError("run starts at row $(first(ctx.rows)), which must exceed omega_window = $(st.omega_window)"))
    # the factor forecast needs the context's forecast models
    if st.forecast_model == "factor" && ctx.fm === nothing
        throw(ArgumentError("run_study: forecast_model = \"factor\" needs forecast models; build the context with fm"))
    end
    # the sector factor covariance (course addition) needs them too
    if st.covariance_model == "sector_factor" && ctx.fm === nothing
        throw(ArgumentError("run_study: covariance_model = \"sector_factor\" needs forecast models; build the context with fm"))
    end
    rule = make_rule(run.allocator, st); screen = make_screen(run.screen, st)
    # the trigger settings; the ξ = 1 turn matters only when the SPY short can start or stop
    mpc = build(MyMPCSpec, (z=st.z, T=st.T, N=st.n_paths, D_max=st.D_max, cash_revisit_interval=st.cash_revisit,
        market_turn=st.market_turn, beta_over_cap=st.beta_over_cap, turn_at_one=(st.hedge && st.spy_short)))
    cost_kw = (half_spread_bps=st.half_spread_bps, κ=st.impact_kappa)
    i0, i1 = first(ctx.rows), last(ctx.rows)

    nd = length(ctx.rows)
    equity = Vector{Float64}(undef, nd); cash_hist = Vector{Float64}(undef, nd); fees = zeros(nd)
    held = zeros(Float64, length(md.tickers)); cash = st.W0
    tr = _BTTrades{Float64}()
    dec = (date=Date[], reason=Symbol[], status=Symbol[], n_names=Int[], invested_frac=Float64[],
        μ_T=Float64[], σ_T=Float64[], beta_target=Float64[], beta_max=Float64[], cap_binds=Bool[],
        hedge_weight=Float64[], solver=Symbol[], spy_share=Float64[], limit_below_zero=Bool[], elapsed=Int[])
    rep = (date=Date[], trigger=Symbol[], basket=Vector{String}[], pool=Vector{String}[],
        shorts=Vector{String}[], changed=Bool[])
    daily = (date=Date[], xi=Float64[], beta_max=Float64[], portfolio_beta=Float64[], hedge_weight=Float64[],
        pool_size=Int[], spy_weight=Float64[], book_beta=Float64[], book_vol=Float64[], book_beta_limit=Float64[],
        spy_gain=Float64[], spy_rose=Bool[])
    targets = Dict{Date,Dict{String,Float64}}(); projections = Dict{Date,MyProjection}()

    trig = MyTriggerState()
    trig.wealth_peak = st.W0; trig.initial = true
    pool = Int[]; in_play = Set{Int}()
    pending = nothing
    # the SPY position (shares, negative for a short) and the SPY shares the last decision asked for
    n_spy = 0.0; spy_target = 0.0

    for t in ctx.rows
        d = md.dates[t]; s = t - i0 + 1
        # 1. fills at the open: the SPY order first, then the stock orders (the SPY shares held overnight are kept
        # for the day's SPY gain)
        spy_before_fill = n_spy
        if pending !== nothing || spy_target != n_spy
            filled = _study_fill_orders!(held, cash, n_spy, spy_target, pending, md, t, tr; cost_kw...)
            cash = filled.cash; n_spy = filled.n_spy
            pending = nothing
        end
        # 2. cash accrual and borrow fee (the stock shorts and the SPY short)
        if t > i0
            accrued = _study_accrue(cash, held, n_spy, md, t, st.borrow_rate)
            cash = accrued.cash; fees[s] = accrued.fee
        end
        # 3. mark at the close: cash, the stocks, and the SPY position
        V = cash + _bt_holdings_value(held, md, t)
        if n_spy != 0.0
            V = V + n_spy * md.spy_close[t]
        end
        equity[s] = V; cash_hist[s] = cash
        # the β of the held stocks (USD, Σ nᵢ·closeᵢ·βᵢ) and the SPY weight, for the β trigger and the daily row
        held_β = 0.0
        for j in eachindex(held)
            if held[j] != 0
                held_β = held_β + held[j] * md.close[t, j] * ctx.sim.β[s, j]
            end
        end
        spy_weight = n_spy * md.spy_close[t] / V
        # 4. triggers (only a :drawdown decision with `drawdown_reset` sets the peak back)
        t > i0 && (trig.τ += 1)
        trig.V_t = V; trig.wealth_peak = max(trig.wealth_peak, V)
        # the v2 trigger state: ξ today, the whole book's β (SPY included) and the full β limit
        trig.ξ_now = ctx.ξ[t]
        trig.book_beta = held_β / V + spy_weight
        trig.beta_limit = study_beta_limit(st, ctx.ξ[t])
        reason = check_trigger(trig, mpc)
        if reason != :in_spec
            # 5. Re-pick on the same trigger that starts a new plan -
            γ_t = ctx.γ[s, :]
            basket = pick(screen, md, t; X=ctx.X, γ_t=γ_t, N=st.N_per_sector, seed=run.seed)
            pool = st.hedge ? ctx.pool[s] : Int[]
            shorts = Int[]
            if uses_short_candidates(rule)
                shorts = short_candidates(γ_t, md; N=st.N_per_sector, exclude=pool)
            end
            now = Set(vcat(basket, pool, shorts))
            changed = now != in_play
            in_play = now
            push!(rep.date, d); push!(rep.trigger, reason); push!(rep.basket, md.tickers[basket])
            push!(rep.pool, md.tickers[pool]); push!(rep.shorts, md.tickers[shorts]); push!(rep.changed, changed)

            # 6. Decide and queue the trades -
            # the SPY short covers the part of the β limit below zero; the stocks are solved on the rest of equity
            limit = study_beta_limit(st, ctx.ξ[t])
            spy_share = spy_overlay_share(st, ctx.ξ[t])
            spy_new = -spy_share * V / md.spy_close[t]
            b = _study_decision(ctx, run, rule, t, basket, pool, shorts, held, (1 - spy_share) * V)
            # with the β trigger on, a failed solve over the β limit scales the stock book down to the limit
            n_book = b.n; trade = b.trade
            if trade == false && isfinite(st.beta_over_cap)
                scaled = _study_scale_failed_book(b.n, b.S, b.β, V, limit)
                if scaled != b.n
                    n_book = scaled; trade = true
                end
            end
            w = n_book .* b.S ./ V
            proj = _study_forecast(ctx, st, run.seed, t, b, n_book, spy_new, V)
            β_target = dot(w, b.β)
            lots = _study_lots(n_book, b.S, V)

            targets[d] = Dict(md.tickers[b.cols[i]] => w[i] for i in eachindex(b.cols))
            projections[d] = proj
            push!(dec.date, d); push!(dec.reason, reason); push!(dec.status, b.status)
            push!(dec.n_names, count(x -> abs(x) > _BT_HELD_W, w)); push!(dec.invested_frac, sum(w; init=0.0))
            push!(dec.μ_T, proj.μ[end]); push!(dec.σ_T, proj.σ[end])
            push!(dec.beta_target, β_target); push!(dec.beta_max, b.β_max)
            push!(dec.cap_binds, b.status in _STUDY_ACCEPTED && isfinite(b.β_max) &&
                β_target >= b.β_max - _STUDY_CAP_TOL)
            push!(dec.hedge_weight, sum(w[b.hedge]; init=0.0)); push!(dec.solver, b.solver)
            push!(dec.spy_share, spy_share); push!(dec.limit_below_zero, limit < 0); push!(dec.elapsed, trig.τ)

            if trade && t < i1
                leaving = [j for j in eachindex(held) if held[j] != 0 && !(j in b.cols)]
                oc = vcat(b.cols, leaving)
                pending = (cols=oc, n=vcat(lots, zeros(length(leaving))), adv=[_bt_adv(md, t, j) for j in oc])
            end
            # the SPY order, set at every decision (a failed stock solve included)
            if st.spy_short && t < i1
                spy_target = spy_new
            end
            # an all-cash book (no executable shares and no SPY short) gets no band: cash_revisit governs the
            # return from cash
            trig.τ = 0; trig.projection = proj; trig.ξ_decision = ctx.ξ[t]
            if all(iszero, lots) && spy_new == 0.0
                trig.projection = nothing
            end
            reason == :drawdown && st.drawdown_reset && (trig.wealth_peak = V)
            trig.initial = false
            trig.last_alloc_was_cash = (b.status == :no_preferred)
        end
        # 7. daily row
        pool_value = sum((held[j] * md.close[t, j] for j in pool); init=0.0)
        push!(daily.date, d); push!(daily.xi, ctx.ξ[t]); push!(daily.beta_max, allocator_beta_max(st, ctx.ξ[t]))
        push!(daily.portfolio_beta, held_β / V); push!(daily.hedge_weight, pool_value / V)
        push!(daily.pool_size, length(pool))
        # the whole book: the SPY weight, the β with SPY (β = 1) included, and the model volatility
        push!(daily.spy_weight, spy_weight); push!(daily.book_beta, trig.book_beta)
        push!(daily.book_vol, _study_book_vol(ctx, st, t, held, n_spy, V))
        # the whole book's β limit (Inf with the hedge off)
        push!(daily.book_beta_limit, trig.beta_limit)
        # the SPY position's gain today (USD): the shares held overnight, from the last close to today's open, and
        # the shares held after today's fill, from the open to the close; and whether SPY closed above its last close
        spy_gain = 0.0
        spy_rose = false
        if t > i0
            spy_gain = spy_before_fill * (md.spy_open[t] - md.spy_close[t - 1]) + n_spy * (md.spy_close[t] - md.spy_open[t])
            spy_rose = md.spy_close[t] > md.spy_close[t - 1]
        end
        push!(daily.spy_gain, spy_gain)
        push!(daily.spy_rose, spy_rose)
    end

    return build(MyStudyResult, (dates=md.dates[ctx.rows], equity=equity, cash=cash_hist, borrow_fees=fees,
        trades=DataFrame(date=tr.date, ticker=tr.ticker, qty=tr.qty, price=tr.price, cost=tr.cost, scale=tr.scale),
        decisions=DataFrame(dec), repicks=DataFrame(rep), daily=DataFrame(daily),
        targets=targets, projections=projections))
end
