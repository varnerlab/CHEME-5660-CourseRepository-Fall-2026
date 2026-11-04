using Test, Dates, Statistics, LinearAlgebra, DataFrames, Random
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
@testset "study loop: re-pick timer and basket changes" begin
    md, ctx = study_ctx(z=1e6, T=10_000, D_max=1.0, repick_on_band_exit=false)
    res = run_study(ctx, study_run(ctx, "CD", :random))
    @test res.repicks.date == res.dates[1:21:end]
    @test Set(res.decisions.reason) ⊆ Set([:initial, :basket_change])
    @test all(d in res.decisions.date for d in res.repicks.date[res.repicks.changed])
    @test all(res.repicks.trigger[2:end] .== :timer)
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
@testset "study loop: band exits re-pick only when enabled" begin
    md, ctx = study_ctx(z=0.0)
    on = run_study(ctx, study_run(ctx, "CD", :random))
    @test all(d in on.repicks.date for d in on.decisions.date[on.decisions.reason .== :band_exit])
    @test any(on.repicks.trigger .== :band_exit)
    md, ctx = study_ctx(z=0.0, repick_on_band_exit=false)
    off = run_study(ctx, study_run(ctx, "CD", :random))
    @test any(off.decisions.reason .== :band_exit) && off.repicks.date == off.dates[1:21:end]
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
    md, ctx = study_ctx(z=0.0, repick_on_band_exit=false, hedge=false)   # a decision every day, no pool
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
