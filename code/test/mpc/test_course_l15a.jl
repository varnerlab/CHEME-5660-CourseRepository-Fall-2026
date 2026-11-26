# Tests of the L15a engine additions: the preference-weight hook and the closest book under the limits.

# A test rule that gives every picked column the preference weight 1 and every other column 0.
struct MyPickedPreferenceTestRule <: AbstractPortfolioRule end

function MPCPortfolio.rule_preferences(::MyPickedPreferenceTestRule, γ::Vector{Float64},
        picked::Vector{Bool})::Vector{Float64}
    return Float64.(picked)
end

@testset "L15a: rule_preferences" begin
    # the built-in rules keep the day's preference weights -
    γ = [0.4, -0.2, 0.1]
    @test MPCPortfolio.rule_preferences(MyCobbDouglasRule(), γ, [true, false, true]) == γ
    @test MPCPortfolio.rule_preferences(MyMinVarRule(), γ, [false, false, false]) == γ

    # the decision's problem uses the rule's preference weights -
    md, ctx = study_ctx()
    run = build(MyStudyRun, (settings=ctx.settings, allocator=MyPickedPreferenceTestRule(), screen=:gamma, seed=1))
    t = first(ctx.rows)
    cols = [1, 2, 3, 4]
    p = MPCPortfolio._study_problem(ctx, run, t, cols, fill(false, 4), zeros(length(md.tickers)), 100_000.0;
        basket=[1, 3], rule=MyPickedPreferenceTestRule())
    @test p.γ == [1.0, 0.0, 1.0, 0.0]
end

@testset "L15a: closest_book" begin
    # no limit binds: the book is the target -
    target = [0.5, 0.3, 0.0, -0.2, -0.1]
    r = closest_book(P5(), target; long_cap=1.30, short_cap=0.30)
    @test r.status == :optimal
    @test r.w ≈ target atol=1e-6

    # the long cap binds: each long weight drops by the same amount, and the short side is unchanged -
    r = closest_book(P5(), [0.9, 0.7, 0.0, -0.15, -0.15]; long_cap=1.30, short_cap=0.30)
    @test r.w ≈ [0.75, 0.55, 0.0, -0.15, -0.15] atol=1e-6

    # a long target never goes short, and a short target never goes long -
    r = closest_book(P5(), [0.9, 0.1, 0.0, -0.1, -0.1]; long_cap=0.50, short_cap=0.30)
    @test r.w[1] ≈ 0.5 atol=1e-6
    @test r.w[2] ≥ -1e-9
    @test all(r.w[4:5] .≤ 1e-9)

    # the single-name cap binds -
    r = closest_book(P5(w_max=0.4), [0.6, 0.2, 0.0, -0.1, -0.1]; long_cap=1.30, short_cap=0.30)
    @test r.w[1] ≈ 0.4 atol=1e-6
    @test r.w[2] ≈ 0.2 atol=1e-6

    # a hedge-pool column with a zero target is bought only when the β limit needs it -
    β = [1.0, 1.0, 1.0, 1.0, -1.0]
    hedge = [false, false, false, false, true]
    target = [0.5, 0.5, 0.0, 0.0, 0.0]
    r = closest_book(P5(β=β, hedge=hedge, β_max=1.0), target; long_cap=1.30, short_cap=0.30)
    @test r.w ≈ target atol=1e-6
    r = closest_book(P5(β=β, hedge=hedge, β_max=0.5), target; long_cap=1.30, short_cap=0.30)
    @test r.w[1:2] ≈ [1 / 3, 1 / 3] atol=1e-5
    @test r.w[5] ≈ 1 / 6 atol=1e-5
    @test sum(β .* r.w) ≤ 0.5 + 1e-6

    # a column that is neither targeted nor in the hedge pool holds no shares -
    @test r.n[3] == 0.0
    @test r.n[4] == 0.0

    # an all-zero target leaves the whole book in cash -
    r = closest_book(P5(), zeros(5); long_cap=1.30, short_cap=0.30)
    @test r.status == :no_preferred
    @test r.n == zeros(5)

    # a target with the wrong length is an error -
    @test_throws DimensionMismatch closest_book(P5(), zeros(3); long_cap=1.30, short_cap=0.30)
end

@testset "L15a: scaled_book" begin
    # no limit binds: the book is the target -
    target = [0.25, 0.25, 0.25, 0.25, 0.0]
    r = scaled_book(P5(), target)
    @test r.status == :optimal
    @test r.w ≈ target atol=1e-6

    # the volatility cap binds: the target is scaled down, and the rest is cash -
    r = scaled_book(P5(σ_g_max=0.5), target)
    @test r.w[1:4] ≈ fill(0.125, 4) atol=1e-6
    @test r.w[5] ≈ 0.0 atol=1e-9

    # the single-name cap binds: every weight stops at the cap -
    r = scaled_book(P5(w_max=0.2), target)
    @test r.w[1:4] ≈ fill(0.2, 4) atol=1e-6

    # the β limit binds: the hedge-pool column carries part of the book, and the picked weights stay equal -
    β = [1.0, 1.0, 1.0, 1.0, -1.0]
    hedge = [false, false, false, false, true]
    r = scaled_book(P5(β=β, hedge=hedge, β_max=0.5), target)
    @test r.w[1:4] ≈ fill(0.1875, 4) atol=1e-5
    @test r.w[5] ≈ 0.25 atol=1e-5
    @test sum(β .* r.w) ≤ 0.5 + 1e-6

    # with the β limit met, the hedge-pool column holds nothing -
    r = scaled_book(P5(β=β, hedge=hedge, β_max=1.0), target)
    @test r.w[5] ≈ 0.0 atol=1e-6

    # an all-zero target leaves the whole book in cash -
    r = scaled_book(P5(), zeros(5))
    @test r.status == :no_preferred
    @test r.n == zeros(5)

    # a negative target or a target with the wrong length is an error -
    @test_throws ArgumentError scaled_book(P5(), [0.5, 0.5, 0.0, 0.0, -0.1])
    @test_throws DimensionMismatch scaled_book(P5(), zeros(3))
end

@testset "L15a: the practicum's T-bill rule" begin
    # each day takes the latest DTB3 rate on or before it, divided by 100 -
    path = joinpath(mktempdir(), "tbill.csv")
    write(path, "# The 3-month T-bill rate, percent per year.\ndate,DTB3\n2026-01-02,4.00\n2026-01-05,4.10\n2026-01-07,4.20\n")
    days = [Date(2026, 1, 2), Date(2026, 1, 5), Date(2026, 1, 6), Date(2026, 1, 7)]
    @test MPCPortfolio._l15a_tbill_rates(path, days) == [4.00, 4.10, 4.10, 4.20] ./ 100
    @test_throws ArgumentError MPCPortfolio._l15a_tbill_rates(path, [Date(2026, 1, 1)])
end

@testset "L15a: a ticker that lists after the fit window starts" begin
    # ticker T05 has no close before row 301 -
    md = synthetic_md(ρ=0.3)
    start, stop = md.dates[1], md.dates[1000]
    late = copy(md.close)
    late[1:300, 5] .= NaN
    md_late = build(MyMarketData, (dates=md.dates, tickers=md.tickers, open=late, close=late, volume=md.volume,
        spy_open=md.spy_open, spy_close=md.spy_close, sector=md.sector, g_f=md.g_f))

    # the late ticker is fit on its own days, and every other ticker keeps its fit -
    full = fit_base_sim(md, start, stop)
    part = fit_base_sim(md_late, start, stop)
    g_m = growth_rates(md.spy_close[1:1000])
    g = growth_rates(md.close[1:1000, 5])
    own = estimate_sim(g_m[301:end], g[301:end])
    @test (part.params["T05"].α, part.params["T05"].β, part.params["T05"].σ_ε) == (own.α, own.β, own.σ_ε)
    for t in md.tickers
        if t != "T05"
            @test (part.params[t].α, part.params[t].β, part.params[t].σ_ε) ==
                (full.params[t].α, full.params[t].β, full.params[t].σ_ε)
        end
    end
    @test (part.σ_m, part.m_m, part.v_m) == (full.σ_m, full.m_m, full.v_m)

    # the shrinkage calibration draws its baskets from the listed tickers, so every loss is a number -
    loss = shrinkage_loss(md_late, start, stop; n_portfolios=20)
    @test all(isfinite, loss)
    @test choose_shrinkage(md_late, start, stop; n_portfolios=20) in 0:0.1:1
end
