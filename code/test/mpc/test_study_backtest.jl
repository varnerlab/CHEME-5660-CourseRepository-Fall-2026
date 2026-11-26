using Test, Dates, Statistics, LinearAlgebra, DataFrames, Random, JLD2
include("helpers.jl")
@testset "study loop: accounting and first day" begin
    md, ctx = study_ctx()
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    @test res.dates == md.dates[ctx.rows] && res.equity[1] == 100_000.0
    @test all(isapprox.(res.equity, res.cash .+ held_value(res, md); rtol=1e-10)) && all(res.cash .>= 0)
    @test res.decisions.reason[1] == :initial && res.repicks.trigger[1] == :initial && res.repicks.date[1] == res.dates[1]
    @test minimum(res.trades.date) == res.dates[2]
    @test run_study(ctx, study_run(ctx, "CD", :gamma)).equity == res.equity                     # deterministic
end
@testset "study loop: fractional fills reach the target; targets under 0.1% of equity are zero" begin
    md, ctx = study_ctx(); res = run_study(ctx, study_run(ctx, "CD", :gamma))
    d = res.dates[1]; t = index_of(md, d); V = res.equity[1]; col = Dict(tk => j for (j, tk) in enumerate(md.tickers))
    fill = res.trades[res.trades.date .== res.dates[2], :]
    @test any(!isinteger, fill.qty) && allequal(fill.scale)            # from cash: buys only, one scale factor
    f = fill.scale[1]; qty = Dict(zip(fill.ticker, fill.qty))
    big = [tk for (tk, w) in res.targets[d] if abs(w) > 1e-3]; dust = [tk for (tk, w) in res.targets[d] if abs(w) <= 1e-3]
    @test !isempty(big) && !isempty(dust)                              # CD pins γ ≤ 0 names at ε shares
    @test all(isapprox(qty[tk], f * res.targets[d][tk] * V / md.close[t, col[tk]]; rtol=1e-10) for tk in big)
    @test !any(tk in keys(qty) for tk in dust)
end
@testset "study loop: the first decision is the documented problem" begin
    md, ctx = study_ctx(); run = study_run(ctx, "CD", :gamma); res = run_study(ctx, run)
    t = first(ctx.rows); basket = [findfirst(==(x), md.tickers) for x in res.repicks.basket[1]]
    cols, hedge = MPCPortfolio._study_problem_columns(MyCobbDouglasRule(), basket, ctx.pool[1], Int[], ctx.γ[1, :])
    p = MPCPortfolio._study_problem(ctx, run, t, cols, hedge, zeros(Int, length(md.tickers)), 100_000.0; basket=basket)
    @test p.γ == ctx.γ[1, cols] && p.μ_g ≈ ctx.sim.α[1, cols] .+ ctx.sim.β[1, cols] .* ctx.g̃[t]
    @test p.constraints.β == ctx.sim.β[1, cols] && p.constraints.β_max == beta_cap(ctx.ξ[t])
    @test p.constraints.σ_g_max == ctx.calib.σ_m && p.constraints.c̄ ≈ 5e-4 * mean(md.close[t, cols])
    E = residual_matrix(growth_rates(md.close[t-126:t, cols]), growth_rates(md.spy_close[t-126:t]), ctx.sim.α[1, cols], ctx.sim.β[1, cols])
    @test p.Σ_g ≈ ctx.sim.σ_m[1]^2 .* (ctx.sim.β[1, cols] * ctx.sim.β[1, cols]') .+ 0.5 .* cov(E) .+ 0.5 .* Diagonal(var.(eachcol(E)))
    w = allocate(MyCobbDouglasRule(), p).w
    @test all(isapprox(res.targets[res.dates[1]][md.tickers[c]], w[k]; rtol=1e-6) for (k, c) in enumerate(cols))
end
@testset "study loop: problem columns" begin                         # Review Focus 3 and 4
    γ = [0.3, -0.2, 0.1, -0.4, 0.2, -0.1]
    @test MPCPortfolio._study_problem_columns(MyCobbDouglasRule(), [1, 2, 3], [3, 4], Int[], γ) == ([1, 2, 3, 4], [false, false, true, true])
    @test MPCPortfolio._study_problem_columns(MyLongShortCDRule(), [1, 2, 3], [4], [5, 6], γ) == ([1, 3, 4, 6], [false, false, true, false])
end
@testset "study loop: the horizon re-picks the basket" begin
    md, ctx = study_ctx(z=Inf, T=21, D_max=1.0, cash_revisit=10_000)
    res = run_study(ctx, study_run(ctx, "CD", :random))
    @test res.repicks.date == res.dates[1:21:end]
    @test res.repicks.date == res.decisions.date
    @test res.repicks.trigger == res.decisions.reason
    @test all(res.repicks.trigger[2:end] .== :horizon_elapsed)
    md, ctx = study_ctx(z=Inf, T=10_000, D_max=1.0, cash_revisit=10_000)
    res = run_study(ctx, study_run(ctx, "CD", :random))
    @test res.repicks.date == res.decisions.date == res.dates[1:1]
end
@testset "study loop: the drawdown peak resets at each drawdown decision" begin
    # Reference walk of the equity path: the peak is the running maximum, set back to that day's equity
    # by each :drawdown decision (by default) or never (drawdown_reset = false, the trial's rule). The
    # trigger must fire on exactly the days more than D_max under that peak, except the first day and
    # cash revisits, which outrank it. A year and a half at two limits, so a reset at the wrong decisions
    # or to the wrong value is caught, not just a missing one.
    for D in (0.01, 0.02)
        n = Dict{Bool,Int}()
        for reset in (true, false)
            # the reset arm sets nothing, so it runs on the default
            md, ctx = study_ctx(; D_max=D, stop=Date(2019, 12, 31), (reset ? (;) : (drawdown_reset=false,))...)
            res = run_study(ctx, study_run(ctx, "CD", :gamma))
            why = Dict(zip(res.decisions.date, res.decisions.reason))
            peak = ctx.settings.W0; wrong = Date[]
            for (s, d) in enumerate(res.dates)
                V = res.equity[s]; peak = max(peak, V); r = get(why, d, :in_spec)
                r in (:initial, :cash_revisit) || ((peak - V) / peak > D) == (r == :drawdown) || push!(wrong, d)
                reset && r == :drawdown && (peak = V)
            end
            @test isempty(wrong)
            n[reset] = count(==(:drawdown), res.decisions.reason)
        end
        @test 2 <= n[true] < n[false]                                # a reset peak fires less often
    end
end
@testset "study loop: band exits re-pick the basket" begin
    md, ctx = study_ctx(z=0.0)
    res = run_study(ctx, study_run(ctx, "CD", :random))
    @test res.repicks.date == res.decisions.date
    @test res.repicks.trigger == res.decisions.reason
    @test any(res.repicks.trigger .== :band_exit)
end
@testset "study loop: hedge on and off" begin
    for allocator in ("CD", "CES", "SG", "MinVar", "Tangent", "LS")
        md, ctx = study_ctx()
        res = run_study(ctx, study_run(ctx, allocator, :gamma))
        ok = in.(res.decisions.status, Ref((:optimal, :fallback_minvar, :long_only_fallback)))
        @test all(res.decisions.beta_target[ok] .<= res.decisions.beta_max[ok] .+ 1e-6)
        allocator == "LS" || @test all(res.cash .>= 0)
        md, ctx = study_ctx(hedge=false)
        r0 = run_study(ctx, study_run(ctx, allocator, :gamma))
        @test all(isinf, r0.decisions.beta_max) && all(r0.daily.pool_size .== 0)
    end
end
@testset "study loop: 130/30 shorts" begin                           # Review Focus 4
    md, ctx = study_ctx(); res = run_study(ctx, study_run(ctx, "LS", :gamma))
    pos = positions_by_day(res)
    allowed = Set(vcat(res.repicks.shorts...)); pool = Set(vcat(res.repicks.pool...))
    @test all(n >= 0 || t in allowed for p in pos for (t, n) in p)
    @test all(n >= 0 for p in pos for (t, n) in p if t in pool)
end
@testset "study loop: costs come from settings" begin
    md, ctx = study_ctx(half_spread_bps=0.0, impact_kappa=0.0)
    @test sum(run_study(ctx, study_run(ctx, "CD", :gamma)).trades.cost) == 0.0
    mdv = study_md()                                                 # volume varies, so the ADV window matters
    mdv.volume .= [1e5 * (1 + 0.5 * sin(0.1 * i + j)) for i in axes(mdv.volume, 1), j in axes(mdv.volume, 2)]
    md, ctx = study_ctx(; md=mdv, half_spread_bps=7.0, impact_kappa=0.003)   # distinct, non-default
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    col = Dict(t => j for (j, t) in enumerate(md.tickers))
    adv(r) = (t = index_of(md, r.date) - 1; max(mean(md.volume[max(1, t - 62):t, col[r.ticker]]), 1.0))  # decision day
    @test any(res.trades.cost .> 0)
    @test all(r.cost == trade_cost(r.qty, r.price, adv(r); half_spread_bps=7.0, κ=0.003) for r in eachrow(res.trades))
end
@testset "study loop: look-ahead canary" begin
    md, ctx = study_ctx(); res = run_study(ctx, study_run(ctx, "CD", :bandit))
    d = res.decisions.date[cld(nrow(res.decisions), 2)]              # a mid-run decision
    i = findfirst(==(d), res.dates)
    @test 1 < i < length(res.dates)
    _, ctxp = study_ctx(; md=perturb_after(md, d))
    rp = run_study(ctxp, study_run(ctxp, "CD", :bandit))
    @test rp.equity[1:i] == res.equity[1:i]
    k = res.decisions.date .<= d
    @test rp.decisions.date[rp.decisions.date .<= d] == res.decisions.date[k]
    @test rp.repicks.basket[rp.repicks.date .<= d] == res.repicks.basket[res.repicks.date .<= d]
    @test rp.targets[d] == res.targets[d]
    @test rp.projections[d].μ == res.projections[d].μ
end
@testset "study loop: a binding β cap holds; run validation" begin   # added: the default fixture's cap never binds
    md, ctx = study_ctx(beta_ref=0.0)                                # β_max = max(0, −ξ)
    for allocator in ("CD", "MinVar")
        res = run_study(ctx, study_run(ctx, allocator, :random))
        ok = in.(res.decisions.status, Ref((:optimal, :fallback_minvar, :long_only_fallback)))
        @test any(res.decisions.cap_binds[ok])
        @test all(res.decisions.beta_target[ok] .<= res.decisions.beta_max[ok] .+ 1e-6)
    end
    s = ctx.settings
    @test_throws ArgumentError build(MyStudyRun, (settings=s, allocator="XX", screen=:gamma, seed=1))
    @test_throws ArgumentError build(MyStudyRun, (settings=s, allocator="CD", screen=:other, seed=1))
    @test_throws ArgumentError build(MyStudyRun, (settings=s, allocator="CD", screen=:gamma, seed=-1))
    @test_throws ArgumentError build(MyStudyRun, (settings=s, allocator="CD", screen=:gamma))
    @test build(MyStudyRun, (settings=s, allocator="CD", screen=:gamma, seed=1)).label == ""
    @test_throws ArgumentError run_study(ctx, build(MyStudyRun, (settings=with_settings(s; pool_H=3),
        allocator="CD", screen=:gamma, seed=1)))                     # settings of another context
end
@testset "study loop: a failed solve keeps the whole book" begin     # spec §6, Review Focus 1
    md, ctx = study_ctx(sg_baseline=0.07)                            # baselines that break the limits on some days
    run = study_run(ctx, "SG", :gamma); res = run_study(ctx, run)
    failed = findall(in((:infeasible, :solver_failed)), res.decisions.status)
    @test !isempty(failed) && !any(res.decisions.cap_binds[failed])
    pos = positions_by_day(res); col = Dict(t => j for (j, t) in enumerate(md.tickers))
    day(f) = findfirst(==(res.decisions.date[f]), res.dates)        # run-day index of decision f
    for f in failed                                                  # no orders: nothing fills the next day
        day(f) < length(res.dates) && @test !any(res.trades.date .== res.dates[day(f)+1])
    end
    repick(f) = findlast(<=(res.decisions.date[f]), res.repicks.date)
    in_problem(f) = Set(vcat(res.repicks.basket[repick(f)], res.repicks.pool[repick(f)]))
    outside(f) = any(n != 0 && !(tk in in_problem(f)) for (tk, n) in pos[day(f)])
    k = findfirst(outside, failed)                                   # a failed decision after a basket change
    @test k !== nothing
    f = failed[k]; d = res.decisions.date[f]; i = day(f); t = index_of(md, d)
    V = res.equity[i]; book = Dict(tk => n for (tk, n) in pos[i] if n != 0)
    @test keys(res.targets[d]) == keys(book)                         # targets = the held book
    @test all(isapprox(res.targets[d][tk], n * md.close[t, col[tk]] / V; rtol=1e-12) for (tk, n) in book)
    @test res.decisions.invested_frac[f] ≈ sum(values(res.targets[d]))
    cols = sort([col[tk] for tk in keys(book)]); held = zeros(length(md.tickers))
    for (tk, n) in book
        held[col[tk]] = n
    end
    pool = Set(res.repicks.pool[repick(f)])
    p = MPCPortfolio._study_problem(ctx, run, t, cols, [md.tickers[j] in pool for j in cols], held, V)
    n = held[cols]; S = md.close[t, cols]
    proj = project_gbm(n, S, V - dot(n, S), p.μ_g, p.Σ_g, md.g_f[t]; T=ctx.settings.T, N=ctx.settings.n_paths,
        rng=MersenneTwister(MPCPortfolio._bt_projection_seed(run.seed, d)))
    @test res.projections[d].μ == proj.μ && res.projections[d].σ == proj.σ   # the band projects the held book
end
@testset "study loop: an empty 130/30 problem goes to cash" begin
    md, ctx = study_ctx(z=0.0, hedge=false)                           # a decision every day, no pool
    ctx.γ[5, :] .= 0.0                                               # day 5: no γ > 0 basket name, no γ < 0 short
    res = run_study(ctx, study_run(ctx, "LS", :gamma))
    d = res.dates[5]; k = findfirst(==(d), res.decisions.date)
    @test k !== nothing && res.decisions.status[k] == :no_preferred
    @test isempty(res.targets[d]) && res.decisions.invested_frac[k] == 0.0 && res.decisions.n_names[k] == 0
    @test all(iszero, res.projections[d].σ)
    @test res.projections[d].μ ≈ res.equity[5] .* exp.(md.g_f[index_of(md, d)] .* (1:ctx.settings.T) ./ 252)
    pos = positions_by_day(res)
    @test any(<(0), values(pos[5])) && any(>(0), values(pos[5]))    # longs and shorts held at d …
    @test all(==(0), values(pos[6]))                                 # … all closed at the next open
end
@testset "study loop: an all-cash book has no band" begin            # cash_revisit governs the return from cash
    md, ctx = study_ctx(hedge=false)
    base = run_study(ctx, study_run(ctx, "CD", :gamma))
    d2 = base.decisions.date[2]; s2 = findfirst(==(d2), base.dates)
    ctx.γ[s2, :] .= -0.1                                             # no γ > 0 at the second decision: ε pins only
    res = run_study(ctx, study_run(ctx, "CD", :gamma)); dd = res.decisions
    k = findfirst(==(d2), dd.date)
    @test dd.status[k] == :no_preferred && haskey(res.projections, d2)
    @test all(==(0), values(positions_by_day(res)[s2 + 1]))          # sold out to cash at the next open
    j = findnext(in((:cash_revisit, :horizon_elapsed, :drawdown)), dd.reason, k + 1)
    @test j !== nothing && dd.reason[j] == :cash_revisit && dd.date[j] == res.dates[s2 + ctx.settings.cash_revisit]
    @test !any(dd.reason[k+1:j-1] .== :band_exit)
    @test !any(res.repicks.trigger[d2 .< res.repicks.date .< dd.date[j]] .== :band_exit)
end

@testset "scaled cap for screen picks only" begin                     # Review Focus 4
    md, ctx = study_ctx(); run = study_run(ctx, "CD", :gamma); t = first(ctx.rows)
    cols = [1, 2, 3, 4, 5, 6]; hedge = [false, false, false, true, true, false]
    p = MPCPortfolio._study_problem(ctx, run, t, cols, hedge, zeros(Int, length(md.tickers)), 1e5; basket=[1, 2, 3, 4, 6])
    @test p.constraints.w_cap ≈ [0.3, 0.3, 0.3, 0.3, 0.10, 0.3]        # K = 5 picks; pick 4 is also pooled; 5 is pool-only
    q = MPCPortfolio._study_problem(ctx, run, t, cols, hedge, zeros(Int, length(md.tickers)), 1e5; basket=collect(1:33))
    @test all(==(0.10), q.constraints.w_cap)                         # 1.5/33 < 0.10
end
@testset "130/30 short columns keep w_max even when picked" begin
    md, ctx = study_ctx(); run = study_run(ctx, "LS", :gamma); t = first(ctx.rows); s = 1
    neg = findfirst(<(0), ctx.γ[s, :]); pos = findfirst(>(0), ctx.γ[s, :])
    @test neg !== nothing && pos !== nothing
    cols = [pos, neg]; hedge = [false, false]
    p = MPCPortfolio._study_problem(ctx, run, t, cols, hedge, zeros(Int, length(md.tickers)), 1e5; basket=[pos, neg])
    @test p.constraints.w_cap ≈ [0.75, 0.10]                 # 1.5/2 for the long pick; w_max for the short
    q = MPCPortfolio._study_problem(ctx, study_run(ctx, "CD", :gamma), t, cols, hedge, zeros(Int, length(md.tickers)), 1e5; basket=[pos, neg])
    @test q.constraints.w_cap ≈ [0.75, 0.75]                          # a long-only rule gives no short
end
@testset "new screens and the fixed list run end to end" begin
    md, ctx = study_ctx(basket_K=8, fixed_tickers=md_tickers_13())
    # `changed` also tracks the hedge pool, which moves, so the fixed list is checked on its basket
    for scr in (:global_gamma, :liquid_gamma, :corr_gamma, :random_global, :random_liquid, :fixed)
        res = run_study(ctx, study_run(ctx, "CD", scr))
        @test all(res.cash .>= 0) && all(isfinite, res.equity)
        scr == :fixed ? (@test allequal(res.repicks.basket) && res.repicks.basket[1] == sort(md_tickers_13())) : (@test all(length.(res.repicks.basket) .== 8))
    end
end

@testset "study loop: omega_window is checked per run on a shared context" begin   # a context ignores omega_window
    md, ctx = study_ctx()
    r = build(MyStudyRun, (settings=with_settings(ctx.settings; omega_window=first(ctx.rows)), allocator="CD",
        screen=:gamma, seed=5660))
    @test context_key(r.settings) == context_key(ctx.settings)
    @test_throws ArgumentError run_study(ctx, r)
end

@testset "CESw in the study" begin
    @test make_rule("CESw", with_settings(MyStudySettings(); ces_eta=2.0)) isa MyCESWeightRule
    @test make_rule("CESw", with_settings(MyStudySettings(); ces_eta=2.0)).η == 2.0
    md, ctx = study_ctx(); res = run_study(ctx, study_run(ctx, "CESw", :gamma))
    @test res.decisions.reason[1] == :initial && minimum(res.cash) ≥ -1e-6
    @test res.equity ≈ res.cash .+ held_value(res, md) rtol=1e-9
    @test all(in((:none, :clarabel, :clarabel_almost, :scs, :failed)), res.decisions.solver)
    @test all(res.decisions.solver[res.decisions.status .== :optimal] .!= :none)
end

# ---- Method v2: the SPY short (Task 2) ----

@testset "study loop: initial decision with v1 forecast and hedge settings" begin
    fx = JLD2.load(joinpath(@__DIR__, "fixtures", "v1_run_study.jld2"), "tables")
    for case in v1_fixture_cases()
        md, ctx = study_ctx(; case.settings...)
        res = run_study(ctx, study_run(ctx, case.allocator, case.screen))
        old = fx[case.label]
        # The initial decision precedes any of the six triggers.
        for table in ("decisions", "daily", "repicks")
            new_table = getproperty(res, Symbol(table))
            for name in names(old[table])
                @test isequal(new_table[1, name], old[table][1, name])
            end
        end
        d = first(res.dates)
        @test res.equity[1:2] == old["equity"][1:2] && res.cash[1:2] == old["cash"][1:2]
        @test res.borrow_fees[1:2] == old["borrow_fees"][1:2]
        @test res.targets[d] == old["targets"][d]
        @test res.projections[d].μ == old["proj_mu"][d] && res.projections[d].σ == old["proj_sigma"][d]
        # the new columns hold no SPY short
        @test all(res.decisions.spy_share .== 0.0) && !any(res.decisions.limit_below_zero)
        @test all(res.daily.spy_weight .== 0.0) && res.daily.book_beta == res.daily.portfolio_beta
    end
end

@testset "v2: the SPY share of equity" begin
    s = build(MyStudySettings, (beta_min=-0.5, spy_short=true))
    @test spy_overlay_share(s, -0.7) == 0.0
    @test spy_overlay_share(s, 0.0) == 0.0
    @test spy_overlay_share(s, 1.0) == 0.0
    @test spy_overlay_share(s, 1.3) ≈ 0.3
    @test spy_overlay_share(s, 2.0) == 0.5                           # the floor −0.5 holds
    hedge_off = build(MyStudySettings, (beta_min=-0.5, spy_short=true, hedge=false))
    @test spy_overlay_share(hedge_off, 2.0) == 0.0
    @test spy_overlay_share(MyStudySettings(), 2.0) == 0.0           # v1: no SPY short
end

@testset "v2: the stock book at a β limit below zero" begin
    md, ctx = spy_short_ctx(ξ=1.3)
    run = study_run(ctx, "CD", :gamma); res = run_study(ctx, run)
    t1 = first(ctx.rows); d1 = res.dates[1]; V1 = res.equity[1]
    share = res.decisions.spy_share[1]
    @test share ≈ 0.3 && res.decisions.limit_below_zero[1] == true
    @test res.decisions.beta_max[1] == 0.0                           # the allocators see the limit cut at 0
    # the stock book is the decision on 70% of equity at a β limit of 0
    col = ticker_columns(md)
    basket = Int[]
    for tk in res.repicks.basket[1]
        push!(basket, col[tk])
    end
    b = MPCPortfolio._study_decision(ctx, run, make_rule("CD", ctx.settings), t1, basket, ctx.pool[1], Int[],
        zeros(length(md.tickers)), (1 - share) * V1)
    @test b.β_max == 0.0 && length(res.targets[d1]) == length(b.cols)
    for k in eachindex(b.cols)
        @test isapprox(res.targets[d1][md.tickers[b.cols[k]]], b.n[k] * b.S[k] / V1; rtol=1e-12)
    end
    # the SPY order: a short sale worth 30% of equity, filled at the next open
    spy = res.trades[res.trades.ticker .== "SPY", :]
    @test nrow(spy) == 1 && spy.date[1] == res.dates[2]
    @test isapprox(spy.qty[1], -share * V1 / md.spy_close[t1]; rtol=1e-12)
end

@testset "v2: a 3-day hand calculation of the SPY short" begin       # Review Focus 5
    md, ctx = spy_short_ctx(ξ=1.3); st = ctx.settings
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    @test nrow(res.decisions) == 1                                   # only the first day decides
    t1 = first(ctx.rows); t2 = t1 + 1; t3 = t1 + 2
    col = ticker_columns(md); Δt = 1 / 252
    # day 1: the decision on an all-cash book
    V1 = res.equity[1]
    @test V1 == st.W0 && res.cash[1] == st.W0 && res.daily.book_vol[1] == 0.0
    q = -res.decisions.spy_share[1] * V1 / md.spy_close[t1]          # SPY shares sold short at the day-2 open
    # day 2: the short sale fills first at the SPY open, with the half spread and no impact term
    px = md.spy_open[t2]
    cash = V1 - (q * px + st.half_spread_bps * 1e-4 * px * abs(q))
    # then the stock buys, in the order of the trade log
    held = zeros(length(md.tickers))
    for r in eachrow(res.trades)
        if r.date == res.dates[2] && r.ticker != "SPY"
            cash = cash - (r.qty * r.price + r.cost)
            held[col[r.ticker]] = held[col[r.ticker]] + r.qty
        end
    end
    # interest on cash, then the borrow fee on the SPY short at the close
    cash = cash * exp(md.g_f[t2] * Δt)
    fee2 = st.borrow_rate * abs(q) * md.spy_close[t2] * Δt
    cash = cash - fee2
    stocks2 = 0.0
    for j in eachindex(held)
        stocks2 = stocks2 + held[j] * md.close[t2, j]
    end
    V2 = cash + stocks2 + q * md.spy_close[t2]
    @test isapprox(res.borrow_fees[2], fee2; atol=1e-9)
    @test isapprox(res.cash[2], cash; atol=1e-9)
    @test isapprox(res.equity[2], V2; atol=1e-9)
    # day 3: no trades; interest, the borrow fee, and the mark with SPY at its close
    @test !any(res.trades.date .== res.dates[3])
    fee3 = st.borrow_rate * abs(q) * md.spy_close[t3] * Δt
    cash = cash * exp(md.g_f[t3] * Δt) - fee3
    stocks3 = 0.0
    for j in eachindex(held)
        stocks3 = stocks3 + held[j] * md.close[t3, j]
    end
    V3 = cash + stocks3 + q * md.spy_close[t3]
    @test isapprox(res.borrow_fees[3], fee3; atol=1e-9)
    @test isapprox(res.cash[3], cash; atol=1e-9)
    @test isapprox(res.equity[3], V3; atol=1e-9)
    # the daily row: the SPY weight, the whole book's β and its volatility
    w_spy = q * md.spy_close[t3] / V3
    @test isapprox(res.daily.spy_weight[3], w_spy; rtol=1e-12)
    @test isapprox(res.daily.book_beta[3], res.daily.portfolio_beta[3] + w_spy; rtol=1e-12)
    s3 = 3; cols = Int[]
    for j in eachindex(held)
        if held[j] != 0
            push!(cols, j)
        end
    end
    w = held[cols] .* md.close[t3, cols] ./ V3
    β = ctx.sim.β[s3, cols]; σ_M = ctx.sim.σ_m[s3]
    Σ_g = MPCPortfolio._study_covariance(ctx, st, t3, cols, ctx.sim.α[s3, cols], β, σ_M)
    variance = dot(w, Σ_g * w) + w_spy^2 * σ_M^2 + 2 * w_spy * σ_M^2 * dot(w, β)
    @test isapprox(res.daily.book_vol[3], sqrt(variance * Δt); rtol=1e-9)
end

"""
    xi_up_then_down!(ctx::MyStudyContext)::Vector{Int}

Set ξ to 1.3 on run days 4 to 6 of `ctx` (it is 0.8 on every other day), so that ξ crosses 1 upward on day 4 and
back down on day 7.

### Arguments
- `ctx::MyStudyContext`: a context from `spy_short_ctx(; ξ=0.8, ...)` (ξ is changed in place).

### Returns
- `Vector{Int}`: the market-data rows of the run days.
"""
function xi_up_then_down!(ctx::MyStudyContext)::Vector{Int}
    rows = collect(ctx.rows);
    for k in 4:6
        ctx.ξ[rows[k]] = 1.3;
    end
    return rows;
end

@testset "v2: the SPY short opens when ξ crosses 1 and is covered in full when ξ falls back" begin    # Codex review, item 9
    md, ctx = spy_short_ctx(; ξ=0.8, market_turn=true)
    st = ctx.settings
    rows = xi_up_then_down!(ctx)
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    dd = res.decisions
    # decisions on day 1, on day 4 (ξ crosses 1 upward) and on day 7 (ξ falls back below 1)
    @test dd.reason == [:initial, :market_turn, :market_turn]
    @test dd.date == [res.dates[1], res.dates[4], res.dates[7]]
    @test dd.spy_share[1] == 0.0
    @test dd.spy_share[2] > 0.0
    @test dd.spy_share[3] == 0.0
    # the short sale fills at the day-5 open with the half spread; the cover buys back every share at the day-8 open
    spy = res.trades[res.trades.ticker .== "SPY", :]
    q = -dd.spy_share[2] * res.equity[4] / md.spy_close[rows[4]]
    @test spy.date == [res.dates[5], res.dates[8]]
    @test isapprox(spy.qty[1], q; rtol=1e-12)
    @test spy.qty[2] == -spy.qty[1]
    @test spy.price == [md.spy_open[rows[5]], md.spy_open[rows[8]]]
    @test isapprox(spy.cost[1], st.half_spread_bps * 1e-4 * spy.price[1] * abs(q); rtol=1e-12)
    # the borrow fee is paid only while the short is open (days 5 to 7), and the SPY weight is zero outside them
    for i in eachindex(res.dates)
        if i >= 5 && i <= 7
            @test isapprox(res.borrow_fees[i], st.borrow_rate * abs(q) * md.spy_close[rows[i]] / 252; rtol=1e-12)
            @test res.daily.spy_weight[i] < 0.0
        else
            @test res.borrow_fees[i] == 0.0
            @test res.daily.spy_weight[i] == 0.0
        end
    end

    # with the hedge off, or with the SPY short off, ξ crossing 1 brings no decision and no short
    md, off = spy_short_ctx(; ξ=0.8, market_turn=true, hedge=false)
    xi_up_then_down!(off)
    res_off = run_study(off, study_run(off, "CD", :gamma))
    @test res_off.decisions.reason == [:initial]
    @test count(res_off.trades.ticker .== "SPY") == 0
    md, no_short = spy_short_ctx(; ξ=0.8, market_turn=true, spy_short=false, beta_min=0.0)
    xi_up_then_down!(no_short)
    res_no_short = run_study(no_short, study_run(no_short, "CD", :gamma))
    @test res_no_short.decisions.reason == [:initial]
    @test count(res_no_short.trades.ticker .== "SPY") == 0
end

@testset "v2: the daily rows carry the whole-book β limit and the SPY position's gain" begin    # Codex review, item 10
    md, ctx = spy_short_ctx(; ξ=0.8, market_turn=true)
    st = ctx.settings
    rows = xi_up_then_down!(ctx)
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    q = -res.decisions.spy_share[2] * res.equity[4] / md.spy_close[rows[4]]
    for i in eachindex(res.dates)
        t = rows[i]
        # the whole book's limit (below zero while ξ is above 1), not the allocator's
        @test res.daily.book_beta_limit[i] == study_beta_limit(st, ctx.ξ[t])
        # SPY rose: its close is above the previous close (never on the first day)
        if i == 1
            @test res.daily.spy_rose[i] == false
        else
            @test res.daily.spy_rose[i] == (md.spy_close[t] > md.spy_close[t - 1])
        end
    end
    @test res.daily.book_beta_limit[5] < 0.0
    # the SPY position's gain (USD): sold at the day-5 open, held over days 6 and 7, covered at the day-8 open
    expected = zeros(length(res.dates))
    expected[5] = q * (md.spy_close[rows[5]] - md.spy_open[rows[5]])
    expected[6] = q * (md.spy_close[rows[6]] - md.spy_close[rows[5]])
    expected[7] = q * (md.spy_close[rows[7]] - md.spy_close[rows[6]])
    expected[8] = q * (md.spy_open[rows[8]] - md.spy_close[rows[7]])
    for i in eachindex(res.dates)
        @test isapprox(res.daily.spy_gain[i], expected[i]; atol=1e-9)
    end
    # the run's statistic sums the gain over the days SPY rose
    up = 0.0
    for i in eachindex(res.dates)
        if res.daily.spy_rose[i]
            up = up + expected[i]
        end
    end
    @test isapprox(study_stats(res).spy_gain_up_days, up; atol=1e-9)
end

@testset "v2: a SPY cover is paid in full, and stock buys still scale" begin
    md = study_md(); t = 2
    px = md.spy_open[t]; buy = 2000.0 / md.open[t, 1]               # a stock buy worth 2,000 USD
    # 50 SPY shares short; cash pays the cover and 1,000 USD of the stock buy
    tr = MPCPortfolio._BTTrades{Float64}(); held = zeros(length(md.tickers))
    cash = 50 * px + 5e-4 * px * 50 + 1000.0
    filled = MPCPortfolio._study_fill_orders!(held, cash, -50.0, 0.0, (cols=[1], n=[buy], adv=[1e6]), md, t, tr;
        half_spread_bps=5.0, κ=0.001)
    @test filled.n_spy == 0.0
    @test tr.ticker[1] == "SPY" && tr.qty[1] == 50.0 && tr.scale[1] == 1.0     # the cover fills first, in full
    @test tr.ticker[2] == md.tickers[1] && 0 < tr.scale[2] < 1                 # the stock buy is scaled
    @test held[1] == tr.qty[2] && filled.cash >= 0
    # a short sale's proceeds pay for the stock buys
    tr = MPCPortfolio._BTTrades{Float64}(); held = zeros(length(md.tickers))
    filled = MPCPortfolio._study_fill_orders!(held, 0.0, 0.0, -50.0, (cols=[1], n=[buy], adv=[1e6]), md, t, tr;
        half_spread_bps=5.0, κ=0.001)
    @test filled.n_spy == -50.0 && tr.ticker[1] == "SPY" && tr.qty[1] == -50.0
    @test tr.scale[2] == 1.0 && held[1] == buy
    # a SPY order with no stock orders
    tr = MPCPortfolio._BTTrades{Float64}(); held = zeros(length(md.tickers))
    filled = MPCPortfolio._study_fill_orders!(held, 1000.0, 0.0, -10.0, nothing, md, t, tr; half_spread_bps=5.0, κ=0.001)
    @test filled.n_spy == -10.0 && length(tr.qty) == 1 && filled.cash ≈ 1000.0 + 10 * px - 5e-4 * px * 10
end

@testset "v2: short-sale proceeds earn interest and pay the borrow fee like a 130/30 short" begin
    md = study_md(); rate = 0.0075; j = 5; k = 40.0                 # 40 SPY shares short, or a stock short of equal value
    cash_spy = 10_000.0; cash_stock = 10_000.0
    for t in 301:303
        spy_case = MPCPortfolio._study_accrue(cash_spy, zeros(length(md.tickers)), -k, md, t, rate)
        held = zeros(length(md.tickers)); held[j] = -k * md.spy_close[t] / md.close[t, j]
        stock_case = MPCPortfolio._study_accrue(cash_stock, held, 0.0, md, t, rate)
        @test isapprox(spy_case.fee, stock_case.fee; rtol=1e-12) && isapprox(spy_case.cash, stock_case.cash; rtol=1e-12)
        @test isapprox(spy_case.fee, rate * k * md.spy_close[t] / 252; rtol=1e-12)
        cash_spy = spy_case.cash; cash_stock = stock_case.cash
    end
end

@testset "v2: a failed solve over the β limit scales the stock book down" begin    # Review Focus 4
    # the scale factor
    scale = MPCPortfolio._study_scale_failed_book
    n = [10.0, 20.0]; S = [100.0, 50.0]; β = [1.2, 0.8]; V = 10_000.0        # book β = 0.2
    @test scale(n, S, β, V, 0.5) == n                                         # under the limit: kept
    @test scale(n, S, β, V, 0.1) ≈ n .* 0.5                                   # scaled to the limit
    @test scale(n, S, β, V, 0.0) == [0.0, 0.0]                                # a limit of 0: all cash
    @test scale(n, S, β, V, -0.3) == [0.0, 0.0]                               # below 0: the SPY short covers it
    @test scale(n, S, β, V, Inf) == n                                         # hedge off
    # in a run: the fixture's failed solves keep books under their limits, so one limit is lowered.
    # β_floor = 0.5 changes the γ weights, so that a failed book holds a positive β (0.19 on 2018-11-30).
    md, ctx = study_ctx(sg_baseline=0.07, beta_floor=0.5, beta_over_cap=0.1)
    base = run_study(ctx, study_run(ctx, "SG", :gamma)); dd = base.decisions
    f = 0
    for k in eachindex(dd.status)
        if f == 0 && dd.status[k] in (:infeasible, :solver_failed) && dd.beta_target[k] > 0.05
            f = k
        end
    end
    @test f > 0
    d = dd.date[f]; t = index_of(md, d); limit = dd.beta_target[f] / 2
    ctx.ξ[t] = 1.0 - limit                                           # β limit = 1 − ξ = half the kept book's β
    res = run_study(ctx, study_run(ctx, "SG", :gamma))
    k = findfirst(isequal(d), res.decisions.date)
    @test res.decisions.status[k] in (:infeasible, :solver_failed)
    @test isapprox(res.decisions.beta_target[k], limit; rtol=1e-9)
    for tk in keys(base.targets[d])
        @test isapprox(res.targets[d][tk], base.targets[d][tk] / 2; rtol=1e-9)
    end
    i = findfirst(isequal(d), res.dates)
    sells = res.trades[res.trades.date .== res.dates[i + 1], :]
    @test nrow(sells) > 0 && all(sells.qty .< 0)                    # the scaled book trades at the next open
    # with the SPY short and a limit below 0: the stocks go to cash and SPY is sold short as usual
    md, ctx = study_ctx(sg_baseline=0.07, beta_floor=0.5, beta_over_cap=0.1, beta_min=-0.5, spy_short=true)
    ctx.ξ[t] = 1.3
    res = run_study(ctx, study_run(ctx, "SG", :gamma))
    k = findfirst(isequal(d), res.decisions.date)
    @test res.decisions.status[k] in (:infeasible, :solver_failed)
    @test res.decisions.invested_frac[k] == 0.0 && res.decisions.spy_share[k] ≈ 0.3
    i = findfirst(isequal(d), res.dates)
    next = res.trades[res.trades.date .== res.dates[i + 1], :]
    spy = next[next.ticker .== "SPY", :]
    @test nrow(spy) == 1 && isapprox(spy.qty[1], -0.3 * res.equity[i] / md.spy_close[t]; rtol=1e-9)
    @test all(next.qty[next.ticker .!= "SPY"] .< 0)
end

@testset "v2: the 130/30 gross with a SPY short" begin
    md, ctx = spy_short_ctx(ξ=1.3)
    res = run_study(ctx, study_run(ctx, "LS", :gamma))
    gross = res.decisions.spy_share[1]
    for w in values(res.targets[res.dates[1]])
        gross = gross + abs(w)
    end
    @test isapprox(gross, 1.6 * 0.7 + 0.3; atol=1e-6)               # 1.42 of equity
end

# ---- Method v2: the market-turn and β triggers in the study loop (Task 3) ----

@testset "v2: market-turn decisions follow ξ and re-pick" begin
    md, ctx = study_ctx(market_turn=true)
    res = run_study(ctx, study_run(ctx, "CD", :gamma)); dd = res.decisions
    @test any(dd.reason .== :market_turn)
    # walk the days: ξ at the last decision is the reference, and a sign change of ξ must bring a decision
    decided = Dict{Date,Symbol}()
    for k in eachindex(dd.date)
        decided[dd.date[k]] = dd.reason[k]
    end
    ξ_last = res.daily.xi[1]
    for i in 2:length(res.dates)
        turned = (res.daily.xi[i] > 0) != (ξ_last > 0)
        reason = get(decided, res.dates[i], :in_spec)
        if turned
            # a turned market decides that day; only the cash revisit and the drawdown outrank the turn
            @test reason in (:cash_revisit, :drawdown, :market_turn)
        else
            @test reason != :market_turn
        end
        if reason != :in_spec
            ξ_last = res.daily.xi[i]
        end
    end
    @test res.repicks.date == dd.date
    @test res.repicks.trigger == dd.reason
    # elapsed: trading days since the last decision
    @test dd.elapsed[1] == 0
    for k in 2:length(dd.date)
        @test dd.elapsed[k] == findfirst(isequal(dd.date[k]), res.dates) - findfirst(isequal(dd.date[k - 1]), res.dates)
    end
end

@testset "v2: a drawdown on a market-turn day still re-picks" begin
    md, ctx = study_ctx(market_turn=true, D_max=0.01)
    base = run_study(ctx, study_run(ctx, "CD", :gamma)); dd = base.decisions
    f = findfirst(==(:drawdown), dd.reason)
    @test f !== nothing
    # flip ξ on that day to the other side of 0 from ξ at the decision before it
    d = dd.date[f]; t = index_of(md, d)
    ξ_before = base.daily.xi[findfirst(isequal(dd.date[f - 1]), base.dates)]
    if ξ_before > 0
        ctx.ξ[t] = -0.5
    else
        ctx.ξ[t] = 0.5
    end
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    k = findfirst(isequal(d), res.decisions.date)
    @test res.decisions.reason[k] == :drawdown
    j = findfirst(isequal(d), res.repicks.date)
    @test j !== nothing && res.repicks.trigger[j] == :drawdown
end

@testset "v2: the β trigger reads the whole book's β each day" begin
    # the fixture's ξ moves slowly and every book stays within 0.01 of its limit, so one day's limit is lowered
    md, ctx = study_ctx(beta_over_cap=0.1, beta_ref=0.3)
    st = ctx.settings
    base = run_study(ctx, study_run(ctx, "CD", :gamma))
    i = 0
    for k in 2:length(base.dates)
        if i == 0 && !(base.dates[k] in base.decisions.date) && base.daily.book_beta[k] > 0.25
            i = k
        end
    end
    @test i > 0
    t = index_of(md, base.dates[i])
    limit = base.daily.book_beta[i] - 0.2                            # 0.2 under the book's β: past the 0.1 margin
    ctx.ξ[t] = (st.beta_ref - limit) / st.kappa_beta
    res = run_study(ctx, study_run(ctx, "CD", :gamma)); dd = res.decisions
    k = findfirst(isequal(base.dates[i]), dd.date)
    @test k !== nothing && dd.reason[k] == :beta_over_cap
    # walk the days: a book over its limit by more than the margin re-plans that day, and only then
    decided = Dict{Date,Symbol}()
    for k in eachindex(dd.date)
        decided[dd.date[k]] = dd.reason[k]
    end
    n_over = 0
    for i in 2:length(res.dates)
        over = res.daily.book_beta[i] > study_beta_limit(st, res.daily.xi[i]) + 0.1
        reason = get(decided, res.dates[i], :in_spec)
        if over
            n_over = n_over + 1
            @test reason != :in_spec                                 # a book over its limit re-plans that day
        end
        if reason == :beta_over_cap
            @test over
        end
    end
    @test n_over > 0 && any(dd.reason .== :beta_over_cap)
end

# ---- Method v2: the factor forecast in the study loop (Task 5) ----

@testset "v2: the decision returns the forecast's inputs" begin
    md, ctx = study_ctx()
    run = study_run(ctx, "CD", :gamma)
    rule = make_rule("CD", ctx.settings)
    t = first(ctx.rows)
    basket = MPCPortfolio.pick(make_screen(:gamma, ctx.settings), md, t; X=ctx.X, γ_t=ctx.γ[1, :],
        N=ctx.settings.N_per_sector, seed=run.seed)
    b = MPCPortfolio._study_decision(ctx, run, rule, t, basket, ctx.pool[1], Int[], zeros(length(md.tickers)),
        ctx.settings.W0)
    @test length(b.cols) > 0
    # the online SIM levels of the decision's columns, and the market's
    @test b.α == ctx.sim.α[1, b.cols]
    @test b.β == ctx.sim.β[1, b.cols]
    @test b.g̃_M == ctx.g̃[t]
    @test b.σ_M == ctx.sim.σ_m[1]
    # Σ_g's diagonal is β²σ_M² + σ_res², because the shrinkage keeps the diagonal
    @test isapprox(diag(b.Σ_g), b.β .^ 2 .* b.σ_M^2 .+ b.σ_res .^ 2; rtol=1e-10)
end

@testset "v2: the factor forecast records a quantile band at each decision" begin
    md, ctx = study_ctx()
    fm = fixture_forecast_models(md)
    md, ctx = study_ctx(; fm=fm, forecast_model="factor", forecast_band="quantile")
    run = study_run(ctx, "CD", :gamma)
    res = run_study(ctx, run)
    @test nrow(res.decisions) >= 2
    for d in res.decisions.date
        p = res.projections[d]
        @test length(p.lo) == ctx.settings.T
        @test length(p.hi) == ctx.settings.T
        @test all(p.lo .< p.hi)
    end
    # the first decision's forecast is project_factor of the book it leaves, with the run's forecast seed
    t = first(ctx.rows)
    d = md.dates[t]
    basket = MPCPortfolio.pick(make_screen(:gamma, ctx.settings), md, t; X=ctx.X, γ_t=ctx.γ[1, :],
        N=ctx.settings.N_per_sector, seed=run.seed)
    b = MPCPortfolio._study_decision(ctx, run, make_rule("CD", ctx.settings), t, basket, ctx.pool[1], Int[],
        zeros(length(md.tickers)), ctx.settings.W0)
    cash = ctx.settings.W0 - dot(b.n, b.S)
    p = project_factor(b.n, b.S, 0.0, md.spy_close[t], cash, b.α, b.β, b.g̃_M, b.σ_M, b.σ_res, md.tickers[b.cols], fm,
        md.g_f[t]; T=ctx.settings.T, N=ctx.settings.n_paths, seed=MPCPortfolio._bt_projection_seed(run.seed, d),
        band="quantile")
    @test res.projections[d].μ == p.μ
    @test res.projections[d].lo == p.lo
    @test res.projections[d].hi == p.hi
    # the factor forecast with the σ band keeps no quantiles
    md, ctx_sigma = study_ctx(; fm=fm, forecast_model="factor", forecast_band="sigma")
    res_sigma = run_study(ctx_sigma, study_run(ctx_sigma, "CD", :gamma))
    for d in res_sigma.decisions.date
        @test isempty(res_sigma.projections[d].lo)
    end
end

@testset "v2: the factor forecast with the SPY short" begin
    md, ctx = study_ctx()
    fm = fixture_forecast_models(md)
    md, ctx = spy_short_ctx(; ξ=1.3, fm=fm, forecast_model="factor", forecast_band="quantile")
    res = run_study(ctx, study_run(ctx, "CD", :gamma))
    d = res.decisions.date[1]
    @test res.decisions.spy_share[1] > 0
    @test length(res.projections[d].lo) == ctx.settings.T
end

@testset "v2: the factor forecast needs forecast models, and the quantile band needs the factor forecast" begin
    md, ctx = study_ctx(; forecast_model="factor", forecast_band="quantile")
    @test_throws ArgumentError run_study(ctx, study_run(ctx, "CD", :gamma))
    @test_throws ArgumentError study_ctx(; forecast_band="quantile")
end

@testset "v2: factor runs give the same tables on any task and in any order" begin    # Review Focus 1
    md, ctx = study_ctx()
    fm = fixture_forecast_models(md)
    md, ctx = study_ctx(; fm=fm, v2_settings()...)
    run_a = study_run(ctx, "CD", :gamma)
    run_b = study_run(ctx, "MinVar", :random; seed=5661)
    ref_a = run_study(ctx, run_a)
    ref_b = run_study(ctx, run_b)
    # the other order, then both at once on spawned tasks
    again_b = run_study(ctx, run_b)
    again_a = run_study(ctx, run_a)
    task_a = Threads.@spawn run_study(ctx, run_a)
    task_b = Threads.@spawn run_study(ctx, run_b)
    spawned_a = fetch(task_a)
    spawned_b = fetch(task_b)
    pairs = [(again_a, ref_a), (spawned_a, ref_a), (again_b, ref_b), (spawned_b, ref_b)]
    for k in eachindex(pairs)
        x = pairs[k][1]
        ref = pairs[k][2]
        @test x.equity == ref.equity
        @test isequal(x.decisions, ref.decisions)
        @test isequal(x.trades, ref.trades)
        for d in keys(ref.projections)
            @test x.projections[d].μ == ref.projections[d].μ
            @test x.projections[d].lo == ref.projections[d].lo
        end
    end
end

@testset "v2: the method version of the settings" begin
    md, ctx = study_ctx()
    @test uses_v1_method(ctx.settings)
    v2 = v2_settings()
    for f in keys(v2)
        # beta_min below 0 needs the SPY short, and the quantile band needs the factor forecast
        if f == :beta_min
            s = with_settings(ctx.settings; beta_min=-0.5, spy_short=true)
        elseif f == :forecast_band
            s = with_settings(ctx.settings; forecast_model="factor", forecast_band="quantile")
        else
            s = with_settings(ctx.settings; NamedTuple{(f,)}((v2[f],))...)
        end
        @test uses_v1_method(s) == false
    end
end
