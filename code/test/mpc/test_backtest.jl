using Test, Dates, Statistics, DataFrames, Random, LinearAlgebra
include("helpers.jl")

# The initial decision rebuilt by hand from the package's parts: EWLS seeded from base_sim and
# updated k times with the start day's growth (σ_m likewise under :ewls), market state at the start
# close, C2 residuals over the trailing `window` growth days, the trial's constraint inputs (no
# holdings yet), and the projection of the targets. Returns (w = target weights, proj).
function hand_initial(md::MyMarketData, cfg::MyRunConfig, k::Int)
    i = index_of(md, cfg.start); names = last(first(cfg.basket_schedule))
    cols = [findfirst(==(t), md.tickers) for t in names]
    g = growth_rates(md.close[i-1:i, cols])[1, :]; g_m = growth_rates(md.spy_close[i-1:i])[1]
    ew = [ewls_init(cfg.base_sim[t].α, cfg.base_sim[t].β, cfg.base_sim[t].σ_ε) for t in names]
    v = ewvar_init(cfg.σ_m); σ_m = cfg.σ_m
    for _ in 1:k
        foreach(j -> ewls_update!(ew[j], g[j], g_m), eachindex(ew))
        σ_m_ewls = ewvar_update!(v, g_m)
        cfg.σ_m_mode == :ewls && (σ_m = σ_m_ewls)
    end
    ms = market_state(md.spy_close, md.dates, cfg.start)
    α = [s.α for s in ew]; β = [s.β for s in ew]; σε = [s.σ_ε for s in ew]
    S = md.close[i, cols]
    E = nothing
    if cfg.covariance isa MyShrunkResidualCovariance
        rows = max(1, i - cfg.covariance.window):i
        E = residual_matrix(growth_rates(md.close[rows, cols]), growth_rates(md.spy_close[rows]), α, β)
    end
    Σ_g = growth_covariance(cfg.covariance, β, σε, σ_m; residuals=E)
    cs = build(MyConstraintSet, (w_max=cfg.w_max, s_max=cfg.s_max, σ_g_max=cfg.σ_g_max,
        K_turnover=cfg.K_turnover_frac * cfg.W0, c̄=5e-4 * mean(S), sector=md.sector[cols],
        n_prev=zeros(length(cols)), ε=1e-3))
    p = build(MyAllocationProblem, (γ=preference_weights(α, β, ms.g_m, ms.λ),
        μ_g=expected_growth(cfg.rule, α, β, ms.ḡ_M), Σ_g=Σ_g, prices=S, W=cfg.W0, g_f=md.g_f[i], constraints=cs))
    r = allocate(cfg.rule, p)
    proj = project_gbm(r.n, S, cfg.W0 - dot(r.n, S), p.μ_g, Σ_g, md.g_f[i]; T=cfg.mpc.T, N=cfg.mpc.N,
        rng=MersenneTwister(cfg.seed * 1_000_003 + Dates.value(cfg.start)))   # R28
    return (w=Dict(names .=> r.w), proj=proj)
end
hand_initial_weights(md, cfg, k) = hand_initial(md, cfg, k).w

# Test rule: Cobb-Douglas on its first call, then a result with non-finite shares (R29).
mutable struct MyFlakyRule <: AbstractPortfolioRule
    calls::Int
    MyFlakyRule() = new(0)
end
function MPCPortfolio.allocate(rule::MyFlakyRule, p::MyAllocationProblem)
    rule.calls += 1
    rule.calls == 1 && return allocate(MyCobbDouglasRule(), p)
    K = length(p.γ)
    return build(MyAllocationResult, (n=fill(NaN, K), w=fill(NaN, K), status=:optimal, s_star=NaN))
end

# Target shares nᵢ = wᵢ·W/Sᵢ of decision d, rebuilt from its stored weights, equity and closes.
function target_shares(res, md::MyMarketData, d::Date)
    t = index_of(md, d); W = res.equity[findfirst(==(d), res.dates)]
    return Dict(n => w * W / md.close[t, findfirst(==(n), md.tickers)] for (n, w) in res.targets[d])
end

weights_close(a::Dict, b::Dict; rtol=1e-6) = keys(a) == keys(b) && all(isapprox(a[t], b[t]; rtol=rtol) for t in keys(a))

# Cash (USD) rebuilt from W0 and the trade log: each day pays Σ(qty·price + cost) for its fills, then
# positive cash accrues exp(g_f·Δt), then the day's borrow fee is charged.
function cash_ledger(res, md::MyMarketData)
    c = zeros(length(res.dates)); c[1] = res.cash[1]
    for t in 2:length(res.dates)
        rows = res.trades.date .== res.dates[t]
        x = c[t-1] - sum(res.trades.qty[rows] .* res.trades.price[rows] .+ res.trades.cost[rows]; init=0.0)
        x > 0 && (x *= exp(md.g_f[index_of(md, res.dates[t])] / 252))
        c[t] = x - res.borrow_fees[t]
    end
    return c
end

@testset "backtest engine" begin
    md = bt_md(); cfg = bt_cfg(md)
    res = run_backtest(md, cfg)
    @test all(res.equity .> 0) && res.dates[1] == cfg.start
    @test res.dates == md.dates[21:end] && res.equity[1] == cfg.W0
    @test all(isapprox.(res.equity, res.cash .+ held_value(res, md); rtol=1e-10))   # accounting identity
    @test all(res.cash .>= 0)                                                         # long-only: never negative
    d0 = first(res.decisions.date); @test first(res.trades.date) == md.dates[index_of(md, d0) + 1]   # next-open fills
    @test res.trades.price[1] == md.open[index_of(md, d0) + 1, findfirst(==(res.trades.ticker[1]), md.tickers)]
    @test res.decisions.reason[1] == :initial && d0 == cfg.start
    @test names(res.trades)[1:5] == ["date", "ticker", "qty", "price", "cost"]
    @test names(res.decisions) == ["date", "reason", "status", "n_names", "invested_frac", "μ_T", "σ_T"]
    @test keys(res.targets) == keys(res.projections) == Set(res.decisions.date)
    @test res.decisions.μ_T == [res.projections[d].μ[end] for d in res.decisions.date]
    @test all(length(p.μ) == cfg.mpc.T for p in values(res.projections))
    # every trade fills at its own day's open
    @test all(res.trades.price[r] == md.open[index_of(md, res.trades.date[r]), findfirst(==(res.trades.ticker[r]), md.tickers)]
        for r in 1:nrow(res.trades))
    k = 60; md2 = perturb_after(md, k)   # prices after day k doubled
    @test filter(r -> index_of(md, r.date) ≤ k, run_backtest(md2, cfg).decisions) == filter(r -> index_of(md, r.date) ≤ k, res.decisions)
    # the same canary cut at every decision day, so a one-day look-ahead cannot hide between decisions
    for k in index_of.(Ref(md), res.decisions.date)[1:end-1]
        @test filter(r -> index_of(md, r.date) ≤ k, run_backtest(perturb_after(md, k), cfg).decisions) ==
            filter(r -> index_of(md, r.date) ≤ k, res.decisions)
    end
    @test :forced ∈ run_backtest(md, with(cfg; forced_dates=[md.dates[50]], natural_triggers=false)).decisions.reason
    # persistent drawdown completes
    r = run_backtest(crash_md(), cfg); @test count(==(:drawdown), r.decisions.reason) ≥ 5 && sum(r.trades.cost) > 0
    @test all(isapprox.(r.equity, r.cash .+ held_value(r, crash_md()); rtol=1e-10))
end

@testset "fills: costs with trailing ADV, sells before buys, cash ledger" begin
    md = bt_md(); res = run_backtest(md, bt_cfg(md))
    # R26: cost = trade_cost(qty, open, ADV) with ADV = mean volume over the 63 trading days ending
    # at the decision day (the day before the fill)
    adv(r) = (td = index_of(md, res.trades.date[r]) - 1; j = findfirst(==(res.trades.ticker[r]), md.tickers);
        max(mean(md.volume[max(1, td - 62):td, j]), 1.0))
    @test all(res.trades.cost[r] ≈ trade_cost(res.trades.qty[r], res.trades.price[r], adv(r)) for r in 1:nrow(res.trades))
    @test any(res.trades.qty .< 0) && any(res.trades.qty .> 0)
    # R25: on each fill day every sell row precedes every buy row
    @test all(issorted(res.trades.qty[res.trades.date .== d] .> 0) for d in unique(res.trades.date))
    # fills, accrual and fees each hit cash exactly once
    @test isapprox(cash_ledger(res, md), res.cash; atol=1e-6)
end

@testset "initial decision = hand-assembled problem; ewls_calendar semantics" begin
    md = bt_md(); cfg = bt_cfg(md); i0 = index_of(md, cfg.start)
    base = run_backtest(md, cfg)
    h = hand_initial(md, cfg, 1)
    @test weights_close(base.targets[cfg.start], h.w)
    @test base.projections[cfg.start].μ ≈ h.proj.μ rtol=1e-8
    @test base.projections[cfg.start].σ ≈ h.proj.σ rtol=1e-8
    fixed = with(cfg; σ_m_mode=:fixed)
    w_fixed = run_backtest(md, fixed).targets[cfg.start]
    @test weights_close(w_fixed, hand_initial_weights(md, fixed, 1))
    @test !weights_close(w_fixed, base.targets[cfg.start]; rtol=1e-4)    # the vol cap binds: σ_m matters
    # C2 residual window: the trailing `window` growth days ending at the decision day
    c2 = with(cfg; covariance=build(MyShrunkResidualCovariance, (λ=0.0, window=10)))
    r2 = run_backtest(md, c2); h2 = hand_initial(md, c2, 1)
    @test weights_close(r2.targets[cfg.start], h2.w)
    @test r2.projections[cfg.start].σ ≈ h2.proj.σ rtol=1e-8
    @test !isapprox(h2.proj.σ, hand_initial(md, with(c2; covariance=build(MyShrunkResidualCovariance, (λ=0.0, window=11))), 1).proj.σ; rtol=1e-4)
    # one calendar entry per trading day reproduces the daily mode exactly
    @test run_backtest(md, with(cfg; ewls_calendar=md.dates[i0:end])).decisions == base.decisions
    # k entries on the start day = k updates with the start day's growth; none = base_sim values
    w = [run_backtest(md, with(cfg; ewls_calendar=vcat(fill(cfg.start, k), md.dates[i0+1:end]))).targets[cfg.start]
        for k in 0:2]
    for k in 0:2
        @test weights_close(w[k+1], hand_initial_weights(md, cfg, k))
    end
    @test !weights_close(w[2], w[3]; rtol=1e-3)
    @test_throws ArgumentError run_backtest(md, with(cfg; ewls_calendar=[md.dates[i0-1]]))       # before start
    @test_throws ArgumentError run_backtest(md, with(cfg; ewls_calendar=[Date(2025,1,4)]))      # Saturday
end

@testset "τ bookkeeping, last-day decision, basket change, validation" begin
    md = bt_md(); cfg = bt_cfg(md)
    # with the band and drawdown switched off, decisions come every T trading days
    r = run_backtest(md, with(cfg; mpc=build(MyMPCSpec, (z=1e6, D_max=10.0, T=10))))
    idx = index_of.(Ref(md), r.decisions.date)
    @test all(diff(idx) .== 10) && all(==(:horizon_elapsed), r.decisions.reason[2:end]) && length(idx) == 10
    # a decision on the last day is recorded; it has no fill
    r = run_backtest(md, with(cfg; forced_dates=[md.dates[end]], natural_triggers=false))
    @test r.decisions.reason == [:initial, :forced] && r.decisions.date[end] == md.dates[end]
    @test haskey(r.projections, md.dates[end]) && all(r.trades.date .== md.dates[22])
    # basket change on day 72 (CCC has γ > 0 there): the leaving name is sold out at the next open,
    # the new one bought
    c = 72; sched = [md.dates[21] => ["AAA", "BBB"], md.dates[c] => ["BBB", "CCC"]]
    r = run_backtest(md, with(cfg; basket_schedule=sched, natural_triggers=false))
    @test r.decisions.reason == [:initial, :basket_change] && r.decisions.date[2] == md.dates[c]
    @test keys(r.targets[md.dates[c]]) == Set(["BBB", "CCC"]) && r.targets[md.dates[c]]["CCC"] > 0.1
    pos = positions_by_day(r)
    @test pos[c-20]["AAA"] > 0 && !haskey(pos[c-20], "CCC")
    @test pos[c+1-20]["AAA"] == 0 && pos[c+1-20]["CCC"] > 0
    @test r.trades.qty[(r.trades.date .== md.dates[c+1]) .& (r.trades.ticker .== "AAA")] == [-pos[c-20]["AAA"]]
    # all γ ≤ 0 (α = −20): :no_preferred sets last_alloc_was_cash, so :cash_revisit fires every 21
    # days ahead of the horizon (T = 63); min-variance ignores γ and never sets it (R19)
    quiet = build(MyMPCSpec, (z=1e6, D_max=10.0, T=63))
    r = run_backtest(md, with(cfg; base_sim=bt_base_sim(α=fill(-20.0, 3)), mpc=quiet))
    @test all(==(:no_preferred), r.decisions.status)
    @test r.decisions.reason[2:end] == fill(:cash_revisit, 4) && all(diff(index_of.(Ref(md), r.decisions.date)) .== 21)
    r = run_backtest(md, with(cfg; base_sim=bt_base_sim(α=fill(-20.0, 3)), mpc=quiet, rule=MyMinVarRule()))
    @test r.decisions.reason == [:initial, :horizon_elapsed]
    # drawdown against the running peak of equity: it fires on exactly the days that sit more than
    # D_max below the peak (no other natural trigger can fire here before τ = 200)
    D = 0.01
    r = run_backtest(md, with(cfg; mpc=build(MyMPCSpec, (z=1e6, D_max=D, T=200, cash_revisit_interval=500))))
    below = [(maximum(r.equity[1:s]) - r.equity[s]) / maximum(r.equity[1:s]) > D for s in eachindex(r.dates)]
    @test count(==(:drawdown), r.decisions.reason) ≥ 2
    @test r.dates[2:end][below[2:end]] == filter(!=(cfg.start), r.decisions.date)
    # turnover budget against the held shares (n_prev): each rebalance moves the free names by at most
    # K_turnover_frac·W/c̄ shares, yet holdings build up past one step's worth over several decisions
    frac = 2e-4
    r = run_backtest(md, with(cfg; K_turnover_frac=frac, mpc=build(MyMPCSpec, (z=1e6, D_max=10.0, T=5))))
    for (k, d) in enumerate(r.decisions.date[1:end-1])
        t = index_of(md, d); s = t - 20
        free = [n for (n, w) in r.targets[d] if w > 1e-5]
        fills = (r.trades.date .== md.dates[t+1]) .& in.(r.trades.ticker, Ref(Set(free)))
        @test 5e-4 * mean(md.close[t, :]) * sum(abs, r.trades.qty[fills]; init=0) ≤ frac * r.equity[s] * (1 + 1e-6)
    end
    step = frac * cfg.W0 / (5e-4 * mean(md.close[21, :]))
    @test maximum(sum(values(p); init=0) for p in positions_by_day(r)) > 1.5 * step
    # every basket name must have a base SIM fit
    @test_throws ArgumentError run_backtest(md, with(cfg; base_sim=delete!(bt_base_sim(), "CCC")))
    @test_throws ArgumentError run_backtest(md, with(cfg; forced_dates=[Date(2025,1,4)]))
    @test_throws ArgumentError with(cfg; basket_schedule=[md.dates[22] => copy(md.tickers)])
    @test_throws ArgumentError with(cfg; σ_m_mode=:other)
    @test_throws ArgumentError with(cfg; seed=-1)
end

@testset "R27: a fill ends at trunc(target): ε pins exit, reductions stop at the target" begin
    md = bt_md()
    # the day after every :no_preferred fill, nothing is held (CD pins at ε, 130/30 targets zero)
    for rule in (MyCobbDouglasRule(), MyLongShortCDRule())
        res = run_backtest(md, bt_cfg(md; rule=rule)); pos = positions_by_day(res)
        np = [findfirst(==(d), res.dates) for d in res.decisions.date[res.decisions.status .== :no_preferred]]
        np = filter(s -> s < length(res.dates), np)
        @test count(s -> any(!=(0), values(pos[s])), np) ≥ 1           # some of them start from holdings
        @test all(s -> all(==(0), values(pos[s+1])), np)
    end
    # after every fill, each position lies between 0 and its target shares (same sign, |n| ≤ |target|);
    # for 130/30 only on fill days with no scaled buy (a scaled short cover stops short of its target)
    ls_md = bt_md(drift=[0.40, 0.25, -1.5])
    runs = [(md, bt_cfg(md)), (ls_md, bt_cfg(ls_md; rule=MyLongShortCDRule(), base_sim=bt_base_sim(α=[0.2, 0.05, -1.0]),
        σ_g_max=100.0, w_max=0.5))]
    for (m, cfg) in runs
        res = run_backtest(m, cfg); pos = positions_by_day(res); checked = 0; shorts = 0
        for d in res.decisions.date
            s = findfirst(==(d), res.dates); s == length(res.dates) && continue
            fill = res.trades.date .== res.dates[s+1]
            any(res.trades.scale[fill .& (res.trades.qty .> 0)] .< 1) && continue
            for (n, x) in target_shares(res, m, d)
                p = get(pos[s+1], n, 0)
                @test p * x ≥ 0 && abs(p) ≤ abs(x) * (1 + 1e-9) + 1e-9
                shorts += p < 0
            end
            checked += 1
        end
        @test checked ≥ 5
        cfg.rule isa MyLongShortCDRule && @test shorts ≥ 1
    end
end

@testset "R6: EWLS runs daily for every base_sim name, in the basket or not" begin
    # CCC joins the basket at a swap on day 72. With no per-name or vol cap, CD's weights are γᵢ/Σγ, so
    # they match a run that held CCC in its basket from the start only if CCC's EWLS ran every day.
    # CCC's base α (1.0) is far from its data (≈ −0.24 yr⁻¹), so skipped updates move γ visibly.
    md = bt_md(); c = 72
    cfg = bt_cfg(md; w_max=1.0, σ_g_max=Inf, natural_triggers=false, base_sim=bt_base_sim(α=[0.2, 0.05, 1.0]))
    swap = run_backtest(md, with(cfg; basket_schedule=[md.dates[21] => ["AAA", "BBB"], md.dates[c] => ["BBB", "CCC"]]))
    from_start = run_backtest(md, with(cfg; basket_schedule=[md.dates[21] => ["BBB", "CCC"]], forced_dates=[md.dates[c]]))
    @test swap.decisions.reason == [:initial, :basket_change] && from_start.decisions.reason == [:initial, :forced]
    @test 0.1 < swap.targets[md.dates[c]]["CCC"] < 0.9
    # rtol 1e-4: the two solves differ in W and n_prev, so Clarabel stops at slightly different points
    # (2.6e-6 apart here); a CCC EWLS frozen until the swap moves them by 5.7e-3
    @test weights_close(swap.targets[md.dates[c]], from_start.targets[md.dates[c]]; rtol=1e-4)
end

@testset "R29: non-finite allocator output holds the current shares" begin
    md = bt_md()
    res = run_backtest(md, bt_cfg(md; rule=MyFlakyRule(), natural_triggers=false, forced_dates=[md.dates[50]]))
    @test res.decisions.status == [:optimal, :solver_failed]
    @test all(res.trades.date .== md.dates[22])                    # the failed decision trades nothing
    s = findfirst(==(md.dates[50]), res.dates); pos = positions_by_day(res)[s]
    W = res.equity[s]
    @test weights_close(res.targets[md.dates[50]],
        Dict(n => pos[n] * md.close[50, findfirst(==(n), md.tickers)] / W for n in keys(pos)); rtol=1e-12)
    @test all(isfinite, res.equity) && all(isfinite, res.projections[md.dates[50]].μ)
end

@testset "a fill that cannot afford any buy logs the dropped buys" begin
    md = bt_md(); order = (cols=[1, 2], n=[10.0, 5.0], adv=[1e4, 1e4])
    for (cash0, scale_ok) in ((-5.0, ==(0.0)), (1.0, f -> 0 < f < 1))
        held = zeros(Int, 3); tr = MPCPortfolio._BTTrades()
        @test MPCPortfolio._bt_fill!(held, cash0, order, md, 30, tr) == cash0
        @test held == [0, 0, 0] && tr.qty == [0, 0] && tr.cost == [0.0, 0.0] && tr.ticker == ["AAA", "BBB"]
        @test allequal(tr.scale) && scale_ok(tr.scale[1])
    end
end

@testset "fractional holdings fill to the exact target" begin
    md = bt_md(); order = (cols=[1, 2, 3], n=[12.345, 0.5, 0.0], adv=[1e4, 1e4, 1e4])
    held = [0.0, 0.0, 3.25]; tr = MPCPortfolio._BTTrades{Float64}()
    cash = MPCPortfolio._bt_fill!(held, 1e6, order, md, 30, tr)
    @test held == [12.345, 0.5, 0.0] && sort(tr.qty) == [-3.25, 0.5, 12.345] && all(tr.scale .== 1.0)
    @test cash ≈ 1e6 - sum(tr.qty .* tr.price) - sum(tr.cost)
    # short of cash: every buy is scaled by one factor, with no rounding
    held = zeros(3); tr = MPCPortfolio._BTTrades{Float64}()
    cash = MPCPortfolio._bt_fill!(held, 500.0, order, md, 30, tr)
    f = tr.scale[1]
    @test 0 < f < 1 && allequal(tr.scale) && held[1:2] ≈ f .* [12.345, 0.5] && abs(cash) < 1e-6
end

@testset "R25: overnight gap scales buys, cash stays ≥ 0" begin
    md = bt_md(); i = 22                       # fill day of the initial decision (start = day 21)
    md.open[i, :] .*= 1.10                     # +10% gap at the open
    cfg = bt_cfg(md; σ_g_max=100.0, w_max=0.5) # CD fully invested at the start close
    res = run_backtest(md, cfg)
    fill = res.trades[res.trades.date .== md.dates[i], :]
    @test nrow(fill) == 3 && all(fill.qty .> 0)
    @test length(unique(fill.scale)) == 1 && 0.85 < fill.scale[1] < 0.95
    @test all(res.cash .>= 0)
    @test res.cash[2] < sum(fill.price)        # one factor, then trunc: less than a share of each left over
    @test all(isapprox.(res.equity, res.cash .+ held_value(res, md); rtol=1e-10))
    @test all(res.trades.scale[res.trades.qty .< 0] .== 1.0)
end

@testset "130/30 long-short runs end to end with borrow fees" begin
    md = bt_md(drift=[0.40, 0.25, -1.5])
    cfg = bt_cfg(md; rule=MyLongShortCDRule(), base_sim=bt_base_sim(α=[0.2, 0.05, -1.0]), σ_g_max=100.0, w_max=0.5)
    res = run_backtest(md, cfg)
    pos = positions_by_day(res)
    short_notional = [sum((-n * md.close[index_of(md, d), findfirst(==(t), md.tickers)] for (t, n) in p if n < 0); init=0.0)
        for (d, p) in zip(res.dates, pos)]
    @test any(>(0), short_notional)
    @test sum(res.borrow_fees) > 0
    @test res.borrow_fees[2:end] ≈ 0.0075 .* short_notional[2:end] ./ 252
    @test all(isapprox.(res.equity, res.cash .+ held_value(res, md); rtol=1e-10))
    @test isapprox(cash_ledger(res, md), res.cash; atol=1e-6)
    @test minimum(res.cash) >= -sum(res.borrow_fees)
end

@testset "C2 covariance end to end" begin
    md = bt_md(); cfg = bt_cfg(md)
    c1 = run_backtest(md, cfg)
    @test run_backtest(md, with(cfg; covariance=build(MyShrunkResidualCovariance, (λ=1.0, window=126)))).decisions ==
        c1.decisions                                       # λ = 1 is C1 exactly
    c2 = run_backtest(md, with(cfg; covariance=build(MyShrunkResidualCovariance, (λ=0.0, window=126))))
    @test c2.decisions.σ_T[1] != c1.decisions.σ_T[1]
    @test all(isapprox.(c2.equity, c2.cash .+ held_value(c2, md); rtol=1e-10))
end

@testset "every rule runs end to end" begin
    md = bt_md()
    for rule in (MyCobbDouglasRule(), build(MyCESRule, (η=2.0,)), build(MyStoneGearyRule, (baseline_frac=0.01,)),
            MyMinVarRule(), MyTangentRule(), MyLongShortCDRule())
        res = run_backtest(md, bt_cfg(md; rule=rule))
        @test all(isapprox.(res.equity, res.cash .+ held_value(res, md); rtol=1e-10))
        @test nrow(res.decisions) ≥ 1 && all(isfinite, res.equity)
        rule isa MyLongShortCDRule || @test all(res.cash .>= 0)
    end
end

@testset "validation hooks: ewls_g_m, decision_market, ewls_state0" begin
    md = bt_md(); cfg = bt_cfg(md); i = index_of(md, cfg.start)
    names = last(first(cfg.basket_schedule))
    gdata = growth_rates(md.spy_close[i-1:i])[1]
    w0(c) = run_backtest(md, c).targets[cfg.start]
    one = with(cfg; ewls_calendar=[cfg.start])
    base = w0(one)
    # NaN or the data's own g_m changes nothing; another g_m changes the EWLS update
    @test weights_close(w0(with(one; ewls_g_m=[NaN])), base)
    @test weights_close(w0(with(one; ewls_g_m=[gdata])), base)
    @test !weights_close(w0(with(one; ewls_g_m=[gdata + 3.0])), base; rtol=1e-6)
    @test_throws ArgumentError with(one; ewls_g_m=[1.0, 2.0])
    # decision_market: the engine's own market_state is a no-op, another λ is not
    ms = market_state(md.spy_close, md.dates, cfg.start)
    @test weights_close(w0(with(one; decision_market=Dict(cfg.start => (g_m=ms.g_m, λ=ms.λ)))), base)
    @test !weights_close(w0(with(one; decision_market=Dict(cfg.start => (g_m=ms.g_m + 2.0, λ=ms.λ)))), base; rtol=1e-6)
    # ewls_state0: the base_sim prior as an explicit state is a no-op; a perturbed state is not
    none = with(cfg; ewls_calendar=Date[])
    st = Dict(t => ewls_init(cfg.base_sim[t].α, cfg.base_sim[t].β, cfg.base_sim[t].σ_ε) for t in names)
    @test weights_close(w0(with(none; ewls_state0=st)), w0(none))
    st[names[1]].α += 2.0
    @test !weights_close(w0(with(none; ewls_state0=st)), w0(none); rtol=1e-6)
end
