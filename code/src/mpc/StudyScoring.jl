# Run statistics and scoring of one study run, ported from the INFORMS 2026 study's `StudyRunner.jl` (branch
# feat/method-v2, commit 5d31b74). The study's file also writes run files and grids of runs; the course keeps
# only the statistics and the scoring.

# Effective number of names (names) of target weights w (dimensionless): 1/Σw̃ᵢ² with w̃ the entries above
# `_BT_HELD_W` rescaled to sum to 1; NaN when those weights sum to less than 0.01 (skipped decision).
function _eff_names(w::AbstractVector{<:Real})::Float64
    long = [x for x in w if x > _BT_HELD_W]
    tot = sum(long; init=0.0)
    tot < 0.01 && return NaN
    return 1 / sum(abs2, long ./ tot)
end

"""
    study_stats(res::MyStudyResult)::NamedTuple

Per-run activity statistics. `turnover` (yr⁻¹) = Σ|qty·price| over trades with qty ≠ 0 divided by the
mean equity (USD) and by the run length in years, n_days/252 with n_days = length(dates) − 1;
`total_cost` and `borrow_fees` in USD. `n_decisions` counts decisions and `n_band_exit`, `n_drawdown`,
`n_horizon`, `n_cash_revisit`, `n_basket_change` count them by `reason` (`:band_exit`, `:drawdown`,
`:horizon_elapsed`, `:cash_revisit`, `:basket_change`). `n_repicks` counts re-picks and `n_basket_changes`
those that changed the basket, both excluding the initial re-pick. `mean_names` (names) and
`mean_invested` (fraction of wealth) average over decisions. `mean_portfolio_beta` (dimensionless),
`mean_hedge_weight` (fraction of wealth) and `mean_pool_size` (names) average over days. `basket_size` (names) is the median pick count over re-picks.
`cap_bind_share` is the share of decisions with `cap_binds` (dimensionless), `NaN` when the β cap is off
(no decision has a finite cap). Reading "share of days the cap binds" as decision days, the only days the
cap is enforced, is a **(plan decision)**.

`mean_eff_names` (names) is the mean over decisions of the effective number of names 1/Σw̃ᵢ², where w̃ are
the long target weights above `_BT_HELD_W` (dimensionless) rescaled to sum to 1; a decision whose such
weights sum to less than 0.01 is skipped and counted in `n_eff_skipped` (decisions). Rescaling the long
weights and skipping near-cash decisions is a **(plan decision)**. `n_failed` (decisions) counts
decisions with status `:infeasible` or `:solver_failed`. `n_fallback` (decisions) counts decisions that did
not fail but whose `solver` is `:clarabel_almost`, `:scs` or `:failed` (a failed sub-solve such as the hedge
step), and `n_almost_optimal` (decisions) those whose `solver` is `:clarabel_almost`. Counting every
non-Clarabel-optimal outcome of an unfailed decision as a fallback is a **(plan decision)**.

Method v2: `n_market_turn` and `n_beta_over_cap` (decisions) count the decisions whose reason is `:market_turn` or
`:beta_over_cap`, and `n_spy_short` (decisions) counts the decisions that set a SPY short (`spy_share > 0`).
`n_days_over_limit` (days) counts the days whose whole-book β (`daily.book_beta`) is more than 1e-6 over the
whole-book β limit (`daily.book_beta_limit`; never with the hedge off), `mean_book_beta` (dimensionless) averages
`daily.book_beta` over days (`NaN` with no days), and `spy_gain_up_days` (USD) sums `daily.spy_gain` over the days
SPY rose (`daily.spy_rose`).

### Arguments
- `res::MyStudyResult`: a run's result.

### Returns
- `NamedTuple`: the statistics above, in the units given.
"""
function study_stats(res::MyStudyResult)::NamedTuple
    tr = res.trades; live = tr.qty .!= 0
    traded = sum(abs.(tr.qty[live] .* tr.price[live]); init=0.0)
    years = (length(res.dates) - 1) / 252
    dec = res.decisions; rp = res.repicks; dy = res.daily
    cnt(r) = count(==(r), dec.reason)
    mn(x) = isempty(x) ? NaN : mean(x)
    capped = any(isfinite, dec.beta_max)
    eff = [_eff_names(collect(values(res.targets[d]))) for d in dec.date]
    ok = .!(dec.status .∈ Ref(_STUDY_FAILED))

    # method v2: re-plans by the two new triggers, and decisions that set a SPY short
    n_market_turn = 0
    n_beta_over_cap = 0
    n_spy_short = 0
    for k in 1:nrow(dec)
        if dec.reason[k] == :market_turn
            n_market_turn = n_market_turn + 1
        elseif dec.reason[k] == :beta_over_cap
            n_beta_over_cap = n_beta_over_cap + 1
        end
        if dec.spy_share[k] > 0
            n_spy_short = n_spy_short + 1
        end
    end
    # method v2: days with the whole book's β over its limit (by more than 1e-6, so a book at its limit does not
    # count), the book's mean β, and the SPY position's gain on the days SPY rose (USD)
    n_days_over_limit = 0
    spy_gain_up_days = 0.0
    for i in 1:nrow(dy)
        if dy.book_beta[i] > dy.book_beta_limit[i] + 1e-6
            n_days_over_limit = n_days_over_limit + 1
        end
        if dy.spy_rose[i]
            spy_gain_up_days = spy_gain_up_days + dy.spy_gain[i]
        end
    end
    mean_book_beta = NaN
    if nrow(dy) > 0
        mean_book_beta = mean(dy.book_beta)
    end
    return (turnover=years > 0 ? traded / mean(res.equity) / years : NaN,
        total_cost=sum(tr.cost; init=0.0), borrow_fees=sum(res.borrow_fees),
        n_decisions=nrow(dec), n_band_exit=cnt(:band_exit), n_drawdown=cnt(:drawdown),
        n_horizon=cnt(:horizon_elapsed), n_cash_revisit=cnt(:cash_revisit), n_basket_change=cnt(:basket_change),
        n_repicks=max(nrow(rp) - 1, 0), n_basket_changes=count(rp.changed[2:end]),
        mean_names=mn(dec.n_names), mean_invested=mn(dec.invested_frac),
        mean_portfolio_beta=mn(dy.portfolio_beta),
        cap_bind_share=capped ? mean(dec.cap_binds) : NaN,
        mean_hedge_weight=mn(dy.hedge_weight), mean_pool_size=mn(dy.pool_size),
        basket_size=median(length.(rp.basket)),
        mean_eff_names=mn(filter(!isnan, eff)), n_eff_skipped=count(isnan, eff),
        n_failed=count(!, ok), n_fallback=count(ok .& (dec.solver .∈ Ref((:clarabel_almost, :scs, :failed)))),
        n_almost_optimal=count(ok .& (dec.solver .== :clarabel_almost)),
        n_market_turn=n_market_turn, n_beta_over_cap=n_beta_over_cap, n_spy_short=n_spy_short,
        n_days_over_limit=n_days_over_limit, mean_book_beta=mean_book_beta, spy_gain_up_days=spy_gain_up_days)
end

"""
    regime_stats(res::MyStudyResult, spy_close::AbstractVector{<:Real})::NamedTuple

Mean growth by market state (spec §7). `spy_close` (USD) has one entry per entry of `res.dates`. Each
run day k ≥ 2 has growth g_k = ln(V_k/V_{k−1})·252 (yr⁻¹) for the portfolio (V = `res.equity`, USD) and
for SPY (V = `spy_close`). Day k is bullish when ξ on day k−1 (`res.daily.xi[k−1]`, dimensionless) is
negative, bearish when it is positive, and dropped when it is 0; labeling day k by the previous day's ξ,
which was known before day k opened, is a **(plan decision)**. Returns `g_bull`, `g_bear`, `spy_g_bull`,
`spy_g_bear` (yr⁻¹; means over each label's days, `NaN` when there are none) and `n_bull`, `n_bear`
(days).
"""
function regime_stats(res::MyStudyResult, spy_close::AbstractVector{<:Real})::NamedTuple
    n = length(res.dates)
    length(spy_close) == n || throw(ArgumentError("spy_close needs one entry per run date"))
    gp = [log(res.equity[k] / res.equity[k-1]) * 252 for k in 2:n]
    gs = [log(spy_close[k] / spy_close[k-1]) * 252 for k in 2:n]
    xi = res.daily.xi[1:n-1]
    bull = xi .< 0; bear = xi .> 0
    mn(x) = isempty(x) ? NaN : mean(x)
    return (g_bull=mn(gp[bull]), g_bear=mn(gp[bear]), n_bull=count(bull), n_bear=count(bear),
        spy_g_bull=mn(gs[bull]), spy_g_bear=mn(gs[bear]))
end

"""
    score_study(ctx::MyStudyContext, run::MyStudyRun)::NamedTuple{(:result, :scorecard, :stats, :wall)}

Run `run_study(ctx, run)` and score it: `scorecard` is `growth_scorecard(equity, spy_close, g_f)` on the result's
dates (equity in USD, SPY close in USD, g_f in yr⁻¹), `stats` merges `study_stats` and `regime_stats`, and `wall`
(s) is the time taken by the run and its scoring. In the study this is `_score_study`, shared by
`run_and_save_study` and `run_synthetic_path`; the course exports it as `score_study`. Throws whatever the run
throws.
"""
function score_study(ctx::MyStudyContext, run::MyStudyRun)::NamedTuple{(:result, :scorecard, :stats, :wall)}
    t0 = time_ns()
    res = run_study(ctx, run)
    md = ctx.md
    i0 = index_of(md, res.dates[1]); i1 = index_of(md, res.dates[end])
    sc = growth_scorecard(res.equity, md.spy_close[i0:i1], md.g_f[i0:i1])
    st = merge(study_stats(res), regime_stats(res, md.spy_close[i0:i1]))
    wall = (time_ns() - t0) / 1e9
    return (result=res, scorecard=sc, stats=st, wall=wall)
end

