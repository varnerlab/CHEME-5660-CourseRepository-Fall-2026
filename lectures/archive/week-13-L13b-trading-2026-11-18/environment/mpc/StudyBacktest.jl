# Study backtest loop (spec §5–§8): one run (allocator × screen × seed × settings) replayed day by day
# against a `MyStudyContext`, with run_backtest's fill, cost and accounting helpers. Decisions are made
# after the close on day t from data dated ≤ t; their orders fill at the open of day t+1 in fractional
# shares. The basket is re-picked inside the loop (every `repick_interval` trading days, and at a band
# exit when `repick_on_band_exit`); with `hedge` on, the hedge pool joins every problem and the
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
| `allocator::String` | `"CD"`, `"CES"`, `"CESw"`, `"SG"`, `"MinVar"`, `"Tangent"` or `"LS"` (130/30 CD) |
| `screen::Symbol` | one of `_STUDY_SCREENS` |
| `seed::Int` | screen and projection RNG seed (≥ 0) |
| `label::String` | run label (default `""`) |
"""
mutable struct MyStudyRun
    settings::MyStudySettings
    allocator::String
    screen::Symbol
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
Throws `ArgumentError` on a missing or unknown field, an allocator other than `"CD"`, `"CES"`, `"CESw"`,
`"SG"`, `"MinVar"`, `"Tangent"`, `"LS"`, a screen not in `_STUDY_SCREENS`, or
`seed < 0`.
"""
function build(::Type{MyStudyRun}, data::NamedTuple)::MyStudyRun
    for f in (:settings, :allocator, :screen, :seed)
        _require(data, MyStudyRun, f)
    end
    unknown = setdiff(keys(data), fieldnames(MyStudyRun))
    isempty(unknown) || throw(ArgumentError("Cannot build MyStudyRun: unknown field(s) $(collect(unknown))"))
    r = MyStudyRun()
    r.settings = data.settings
    r.allocator = String(data.allocator)
    r.screen = Symbol(data.screen)
    r.seed = data.seed
    haskey(data, :label) && (r.label = String(data.label))
    r.allocator in _STUDY_ALLOCATORS ||
        throw(ArgumentError("Invalid MyStudyRun: allocator must be one of $(_STUDY_ALLOCATORS), got $(repr(r.allocator))"))
    r.screen in _STUDY_SCREENS ||
        throw(ArgumentError("Invalid MyStudyRun: screen must be one of $(_STUDY_SCREENS), got :$(r.screen)"))
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
- `repicks::DataFrame`: `date`, `trigger` (`:initial`, `:timer` or `:band_exit`), `basket`, `pool`
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
    cols = sort!(union(basket, pool))
    return cols, [j in pool for j in cols]
end

function _study_problem_columns(rule::MyLongShortCDRule, basket::Vector{Int}, pool::Vector{Int},
        shorts::Vector{Int}, γ_row::AbstractVector)::Tuple{Vector{Int},Vector{Bool}}
    cols = sort!(union(filter(j -> γ_row[j] > 0, basket), pool, filter(j -> γ_row[j] < 0, shorts)))
    return cols, [j in pool for j in cols]
end

"""
    _study_beta_max(s::MyStudySettings, ξ_t::Real)::Float64

The β cap (dimensionless) at the market signal ξ_t (dimensionless): `beta_cap(ξ_t)` with the
`beta_ref`, `kappa_beta`, `beta_min` settings when `s.hedge` is on, `Inf` (no cap) when it is off.
"""
_study_beta_max(s::MyStudySettings, ξ_t::Real)::Float64 =
    s.hedge ? beta_cap(ξ_t; β_ref=s.beta_ref, κ_β=s.kappa_beta, β_min=s.beta_min) : Inf

"""
    _study_problem(ctx, run, t::Int, cols::Vector{Int}, hedge::Vector{Bool}, held::AbstractVector{<:Real},
        V::Float64; basket::Vector{Int}=Int[])::MyAllocationProblem

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
        held::AbstractVector{<:Real}, V::Float64; basket::Vector{Int}=Int[])::MyAllocationProblem
    st = run.settings; md = ctx.md
    s = t - first(ctx.rows) + 1
    S = md.close[t, cols]
    α = ctx.sim.α[s, cols]; β = ctx.sim.β[s, cols]
    μ_g = expected_growth(make_rule(run.allocator, st), α, β, ctx.g̃[t])
    Ω = st.omega_window
    E = residual_matrix(growth_rates(md.close[t-Ω:t, cols]), growth_rates(md.spy_close[t-Ω:t]), α, β)
    λ = isnan(st.lambda) ? ctx.calib.λ : st.lambda
    Σ_g = growth_covariance(build(MyShrunkResidualCovariance, (λ=λ, window=Ω)), β, std.(eachcol(E)),
        ctx.sim.σ_m[s]; residuals=E)
    σ_g_max = isnan(st.vol_cap_annual) ? ctx.calib.σ_m : st.vol_cap_annual / sqrt(_BT_DT)
    cap_pick = isempty(basket) ? st.w_max : max(st.w_max, st.w_max_scale / length(basket))
    # a column the 130/30 rule shorts (γ < 0, not a hedge name) keeps w_max even when the screen picked it
    is_short(i) = run.allocator == "LS" && ctx.γ[s, cols[i]] < 0 && !hedge[i]
    w_cap = [(cols[i] in basket && !is_short(i)) ? cap_pick : st.w_max for i in eachindex(cols)]
    cs = build(MyConstraintSet, (w_max=st.w_max, w_cap=w_cap, s_max=st.s_max, σ_g_max=σ_g_max,
        K_turnover=st.turnover_frac * V, c̄=st.half_spread_bps * 1e-4 * mean(S),     # bps → fraction
        sector=md.sector[cols], n_prev=Float64.(held[cols]), ε=_BT_ε, β=β,
        β_max=_study_beta_max(st, ctx.ξ[t])))
    return build(MyAllocationProblem, (γ=ctx.γ[s, cols], μ_g=μ_g, Σ_g=Σ_g, prices=S, W=V, g_f=md.g_f[t],
        constraints=cs, hedge=hedge))
end

"""
    _study_decision(ctx, run, rule, t::Int, basket, pool, shorts, held::AbstractVector{<:Real}, V::Float64)::NamedTuple

One decision after the close of market-data row `t` (holdings `held` in shares, equity `V` in USD).
Returns the book it leaves, `(status, solver, cols, n, S, μ_g, Σ_g, β, β_max, hedge, trade)`: `solver` is the
worst outcome of the decision's solves (`:none`, `:clarabel`, `:clarabel_almost`, `:scs` or `:failed`, `:none` when
nothing was solved), then ticker columns,
shares n (shares), close prices S (USD/share), μ_g (yr⁻¹), Σ_g (yr⁻²), online β (dimensionless) and
hedge flags of those columns, the β cap (dimensionless) and whether to queue orders.

- **Solved** (any status but `:infeasible`/`:solver_failed`): the `_study_problem` on
  `_study_problem_columns` and the allocator's shares; non-finite shares count as `:solver_failed`
  (R29). `trade = true`.
- **Failed** (`:infeasible`, `:solver_failed`): keep every holding (spec §6): the columns are the
  names with nonzero holdings (the problem columns at zero shares when there are none), with μ_g, Σ_g
  and β from `_study_problem` on them, and n = the held shares. `trade = false`.
- **Empty problem** (a 130/30 whose basket names all have γ ≤ 0, with an empty pool and no short
  candidate at γ < 0): `:no_preferred` with no columns, so every holding targets 0 and the book is
  all cash. `trade = true`.
"""
function _study_decision(ctx::MyStudyContext, run::MyStudyRun, rule::AbstractPortfolioRule, t::Int,
        basket::Vector{Int}, pool::Vector{Int}, shorts::Vector{Int}, held::AbstractVector{<:Real}, V::Float64)::NamedTuple
    s = t - first(ctx.rows) + 1
    cols, hedge = _study_problem_columns(rule, basket, pool, shorts, view(ctx.γ, s, :))
    if isempty(cols)
        return (status=:no_preferred, solver=:none, cols=Int[], n=Float64[], S=Float64[], μ_g=Float64[], Σ_g=zeros(0, 0),
            β=Float64[], β_max=_study_beta_max(run.settings, ctx.ξ[t]), hedge=Bool[], trade=true)
    end
    p = _study_problem(ctx, run, t, cols, hedge, held, V; basket=basket)
    log = Symbol[]
    r = Base.ScopedValues.with(() -> allocate(rule, p), _SOLVER_LOG => log)
    all(isfinite, r.n) || (r = _result(p, copy(p.constraints.n_prev), :solver_failed))   # R29
    n = r.n; trade = true
    if r.status in _STUDY_FAILED
        kept = findall(!=(0), held)
        if !isempty(kept) && kept != cols
            cols = kept; hedge = [j in pool for j in cols]
            p = _study_problem(ctx, run, t, cols, hedge, held, V)
        end
        n = Float64.(held[cols]); trade = false
    end
    c = p.constraints
    return (status=r.status, solver=_worst_solver(log), cols=cols, n=n, S=p.prices, μ_g=p.μ_g, Σ_g=p.Σ_g, β=c.β, β_max=c.β_max,
        hedge=hedge, trade=trade)
end

# The executable shares of a book: shares n of names at close prices S (USD/share), with every name whose
# value is at most `_BT_HELD_W`·V (equity V, USD) set to 0 shares. This removes the ε pins of the log
# utilities and solver dust, which whole-share rounding used to remove **(plan decision)**.
_study_lots(n::AbstractVector{<:Real}, S::AbstractVector{<:Real}, V::Real)::Vector{Float64} =
    [abs(n[i] * S[i]) > _BT_HELD_W * V ? Float64(n[i]) : 0.0 for i in eachindex(n)]

"""
    run_study(ctx::MyStudyContext, run::MyStudyRun)::MyStudyResult

Replay `run` on the context's rows `ctx.rows`, with equity starting at `W0` (USD) in cash at the start
close. `run.settings` must share the context's `context_key`. On each trading day t (row s), in order:

1. **Fill** the orders queued on day t−1 at `open[t]` as `run_backtest` does, but in fractional
   shares (sells first, buys scaled if cash would go negative), with costs from `half_spread_bps` and
   `impact_kappa`.
2. **Accrue** positive cash by exp(g_f[t]·Δt) and charge `borrow_fee` at `borrow_rate` on the short
   notional at `close[t]` (USD). Skipped on the first day.
3. **Mark** V = cash + Σ nᵢ·close[t, i] (USD).
4. **Trigger:** `check_trigger` with τ = trading days since the last decision, V, wealth_peak = running
   max of equity (set back to V by each `:drawdown` decision when `drawdown_reset`, else never reset), `initial`
   on the first day, and the MPC spec from `T`, `z`, `n_paths`,
   `D_max`, `cash_revisit`.
5. **Re-pick** on the first day (`:initial`), when `repick_interval` trading days have passed since the
   last re-pick (`:timer`), or at a `:band_exit` when `repick_on_band_exit` (`:band_exit`): the screen's
   `pick` (N = `N_per_sector`, seed = `run.seed`), the pool `ctx.pool[s]` (empty with the hedge off)
   and, for `"LS"`, the `short_candidates` outside the pool. If the set basket ∪ pool ∪ shorts changed
   and no trigger fired, the reason becomes `:basket_change`.
6. **Decide** when the reason is not `:in_spec` (`_study_decision`): `allocate` on the problem of
   `_study_problem_columns` and `_study_problem` (non-finite shares count as `:solver_failed`, R29).
   After a solve, queue orders for t+1 at the executable shares `_study_lots` (a target worth at most
   0.1% of V trades to 0; held names outside the problem target 0; none on the last day). After `:infeasible` or `:solver_failed`, queue no orders and keep every holding (spec §6).
   An empty 130/30 problem records `:no_preferred` and targets every holding to 0. Then
   `project_gbm` of the resulting book (the targets, or the kept holdings) with cash V − n·S and
   `rng = MersenneTwister(seed·1_000_003 + Dates.value(date))` (R28), and the decision row. τ resets
   to 0 and `last_alloc_was_cash = (status == :no_preferred)`. With `drawdown_reset`, a `:drawdown` decision sets
   the drawdown peak back to V, even when its solve fails and the book is kept (user, 2026-10-25). The projection becomes the trigger's
   band, except for a book with no executable shares (every target, or every kept holding, is worth at
   most 0.1% of V): such a book has no band, so the band-exit trigger cannot fire and
   `cash_revisit` (or the horizon or drawdown trigger) governs the return from cash; its
   projection is still recorded **(plan decision)**.
7. **Daily row:** ξ[t], the β cap, the holdings' β and hedge weight, the pool size.

When the timer and a band exit fall on the same day the re-pick is logged as `:timer`
**(plan decision)**. Throws `ArgumentError` when the settings do not match the context's, when the first
run row is ≤ the run's `omega_window` (trading days; not part of `context_key`, so checked here per run),
or when a screen cannot pick (e.g. a bandit lookback longer than the data); allocator and projection
errors propagate.
"""
function run_study(ctx::MyStudyContext, run::MyStudyRun)::MyStudyResult
    st = run.settings; md = ctx.md
    isequal(context_key(st), context_key(ctx.settings)) ||
        throw(ArgumentError("run settings do not match the context's: $(context_key(st)) vs $(context_key(ctx.settings))"))
    first(ctx.rows) > st.omega_window ||
        throw(ArgumentError("run starts at row $(first(ctx.rows)), which must exceed omega_window = $(st.omega_window)"))
    rule = make_rule(run.allocator, st); screen = make_screen(run.screen, st)
    mpc = build(MyMPCSpec, (z=st.z, T=st.T, N=st.n_paths, D_max=st.D_max, cash_revisit_interval=st.cash_revisit))
    cost_kw = (half_spread_bps=st.half_spread_bps, κ=st.impact_kappa)
    i0, i1 = first(ctx.rows), last(ctx.rows)

    nd = length(ctx.rows)
    equity = Vector{Float64}(undef, nd); cash_hist = Vector{Float64}(undef, nd); fees = zeros(nd)
    held = zeros(Float64, length(md.tickers)); cash = st.W0
    tr = _BTTrades{Float64}()
    dec = (date=Date[], reason=Symbol[], status=Symbol[], n_names=Int[], invested_frac=Float64[],
        μ_T=Float64[], σ_T=Float64[], beta_target=Float64[], beta_max=Float64[], cap_binds=Bool[],
        hedge_weight=Float64[], solver=Symbol[])
    rep = (date=Date[], trigger=Symbol[], basket=Vector{String}[], pool=Vector{String}[],
        shorts=Vector{String}[], changed=Bool[])
    daily = (date=Date[], xi=Float64[], beta_max=Float64[], portfolio_beta=Float64[], hedge_weight=Float64[],
        pool_size=Int[])
    targets = Dict{Date,Dict{String,Float64}}(); projections = Dict{Date,MyProjection}()

    trig = MyTriggerState()
    trig.wealth_peak = st.W0; trig.initial = true
    basket = Int[]; pool = Int[]; shorts = Int[]; in_play = Set{Int}(); last_repick = i0
    pending = nothing

    for t in ctx.rows
        d = md.dates[t]; s = t - i0 + 1
        # 1. fills at the open
        if pending !== nothing
            cash = _bt_fill!(held, cash, pending, md, t, tr; cost_kw...)
            pending = nothing
        end
        # 2. cash accrual and borrow fee
        if t > i0
            cash > 0 && (cash *= exp(md.g_f[t] * _BT_DT))
            short = _bt_short_notional(held, md, t)
            if short > 0
                fees[s] = borrow_fee(short; rate=st.borrow_rate, Δt=_BT_DT)
                cash -= fees[s]
            end
        end
        # 3. mark at the close
        V = cash + _bt_holdings_value(held, md, t)
        equity[s] = V; cash_hist[s] = cash
        # 4. triggers (only a :drawdown decision with `drawdown_reset` sets the peak back)
        t > i0 && (trig.τ += 1)
        trig.V_t = V; trig.wealth_peak = max(trig.wealth_peak, V)
        reason = check_trigger(trig, mpc)
        # 5. re-pick
        why = t == i0 ? :initial :
            t - last_repick >= st.repick_interval ? :timer :
            (reason == :band_exit && st.repick_on_band_exit) ? :band_exit : :none
        if why != :none
            γ_t = ctx.γ[s, :]
            basket = pick(screen, md, t; X=ctx.X, γ_t=γ_t, N=st.N_per_sector, seed=run.seed)
            pool = st.hedge ? ctx.pool[s] : Int[]
            shorts = run.allocator == "LS" ? short_candidates(γ_t, md; N=st.N_per_sector, exclude=pool) : Int[]
            now = Set(vcat(basket, pool, shorts))
            changed = now != in_play
            in_play = now; last_repick = t
            changed && reason == :in_spec && (reason = :basket_change)
            push!(rep.date, d); push!(rep.trigger, why); push!(rep.basket, md.tickers[basket])
            push!(rep.pool, md.tickers[pool]); push!(rep.shorts, md.tickers[shorts]); push!(rep.changed, changed)
        end
        # 6. decide
        if reason != :in_spec
            b = _study_decision(ctx, run, rule, t, basket, pool, shorts, held, V)
            w = b.n .* b.S ./ V
            proj = project_gbm(b.n, b.S, V - dot(b.n, b.S), b.μ_g, b.Σ_g, md.g_f[t]; T=st.T, N=st.n_paths,
                rng=MersenneTwister(_bt_projection_seed(run.seed, d)))
            β_target = dot(w, b.β)
            lots = _study_lots(b.n, b.S, V)

            targets[d] = Dict(md.tickers[b.cols[i]] => w[i] for i in eachindex(b.cols))
            projections[d] = proj
            push!(dec.date, d); push!(dec.reason, reason); push!(dec.status, b.status)
            push!(dec.n_names, count(x -> abs(x) > _BT_HELD_W, w)); push!(dec.invested_frac, sum(w; init=0.0))
            push!(dec.μ_T, proj.μ[end]); push!(dec.σ_T, proj.σ[end])
            push!(dec.beta_target, β_target); push!(dec.beta_max, b.β_max)
            push!(dec.cap_binds, b.status in _STUDY_ACCEPTED && isfinite(b.β_max) &&
                β_target >= b.β_max - _STUDY_CAP_TOL)
            push!(dec.hedge_weight, sum(w[b.hedge]; init=0.0)); push!(dec.solver, b.solver)

            if b.trade && t < i1
                leaving = [j for j in eachindex(held) if held[j] != 0 && !(j in b.cols)]
                oc = vcat(b.cols, leaving)
                pending = (cols=oc, n=vcat(lots, zeros(length(leaving))), adv=[_bt_adv(md, t, j) for j in oc])
            end
            # an all-cash book (no executable shares) gets no band: cash_revisit governs the return from cash
            trig.τ = 0; trig.projection = all(iszero, lots) ? nothing : proj
            reason == :drawdown && st.drawdown_reset && (trig.wealth_peak = V)
            trig.initial = false
            trig.last_alloc_was_cash = (b.status == :no_preferred)
        end
        # 7. daily row
        held_β = 0.0
        for j in eachindex(held)
            held[j] == 0 || (held_β += held[j] * md.close[t, j] * ctx.sim.β[s, j])
        end
        pool_value = sum((held[j] * md.close[t, j] for j in pool); init=0.0)
        push!(daily.date, d); push!(daily.xi, ctx.ξ[t]); push!(daily.beta_max, _study_beta_max(st, ctx.ξ[t]))
        push!(daily.portfolio_beta, held_β / V); push!(daily.hedge_weight, pool_value / V)
        push!(daily.pool_size, length(pool))
    end

    return build(MyStudyResult, (dates=md.dates[ctx.rows], equity=equity, cash=cash_hist, borrow_fees=fees,
        trades=DataFrame(date=tr.date, ticker=tr.ticker, qty=tr.qty, price=tr.price, cost=tr.cost, scale=tr.scale),
        decisions=DataFrame(dec), repicks=DataFrame(rep), daily=DataFrame(daily),
        targets=targets, projections=projections))
end
