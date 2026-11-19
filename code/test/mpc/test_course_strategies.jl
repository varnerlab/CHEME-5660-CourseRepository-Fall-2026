# The L14a course additions: a market from growth rates, betting against beta, and the buy-and-hold references.
@testset "course: market from growth rates" begin
    dates = [Date(2025, 1, 2) + Day(k) for k in 0:4]
    G = [0.5 -0.2; 0.1 0.3; -0.4 0.0; 0.2 0.2]
    g_m = [0.1, -0.1, 0.2, 0.0]
    md = market_data_from_growth(dates, ["A", "B"], ["X", "Y"], [10.0, 20.0], 400.0, [1e6, 2e6],
        fill(0.04, 5), g_m, G)
    @test md.close[1, :] == [10.0, 20.0] && md.spy_close[1] == 400.0
    @test growth_rates(md.close) ≈ G
    @test growth_rates(md.spy_close) ≈ g_m
    @test md.open == md.close && md.volume[3, 2] == 2e6
    @test_throws ArgumentError market_data_from_growth(dates[1:4], ["A", "B"], ["X", "Y"], [10.0, 20.0], 400.0,
        [1e6, 2e6], fill(0.04, 4), g_m, G)
end

@testset "course: betting against beta weights and schedule" begin
    β = [0.6, 1.4, 0.9, 1.1, 0.7]
    w = bab_weights(β)
    @test sum(w.w_low) ≈ 1 && sum(w.w_high) ≈ 1
    @test all(w.w_low .>= 0) && all(w.w_high .>= 0)
    @test w.w_low[1] > w.w_low[5] > 0 && w.w_high[2] > w.w_high[4] > 0
    @test w.w_low[3] == 0 && w.w_high[3] == 0            # the median stock is in neither portfolio
    @test sum(w.w_low .* β) < sum(w.w_high .* β)

    md, ctx = study_ctx()
    r = bab_rebalance_rows(md, ctx.rows)
    @test r[1] == first(ctx.rows)
    for k in 2:length(r)
        @test month(md.dates[r[k]]) != month(md.dates[r[k] - 1])
    end

    # the Frazzini–Pedersen β: ρ̂·σ̂ᵢ/σ̂_m, and SPY itself would get β = 1
    t = first(ctx.rows)
    β̂ = bab_betas(md, t; corr_window=750)
    @test length(β̂) == length(md.tickers) && all(isfinite, β̂)
    j = 1
    r = [log(md.close[u, j] / md.close[u - 1, j]) for u in (t - 251):t]
    r_m = [log(md.spy_close[u] / md.spy_close[u - 1]) for u in (t - 251):t]
    x = [log(md.close[u, j] / md.close[u - 3, j]) for u in (t - 749):t]
    x_m = [log(md.spy_close[u] / md.spy_close[u - 3]) for u in (t - 749):t]
    @test β̂[1] ≈ cor(x, x_m) * std(r) / std(r_m)
    @test_throws ArgumentError bab_betas(md, 100)
end

@testset "course: betting against beta on the fixture market" begin
    md, ctx = study_ctx()
    # the fixture market starts in 2014, so the correlation window is three years here, not five
    bab = run_bab(ctx; corr_window=750)
    @test length(bab.equity) == length(ctx.rows) && all(isfinite, bab.equity) && all(bab.equity .> 0)
    @test bab.equity[1] == ctx.settings.W0 && bab.ruined == false
    @test nrow(bab.rebalances) == length(bab_rebalance_rows(md, ctx.rows))
    # the book is levered: long W/β_L and short W/β_H
    row = bab.rebalances[1, :]
    @test row.long_value ≈ ctx.settings.W0 / row.beta_low
    @test row.short_value ≈ ctx.settings.W0 / row.beta_high
    @test row.beta_low < row.beta_high
    @test bab.gross[3] > 1.5
    @test bab.total_cost > 0 && sum(bab.borrow_fees) > 0

    # the buy-and-hold references start at W0
    p = buy_and_hold_equity(md, ctx.rows; W0=1e5)
    @test p.spy[1] ≈ 1e5 && p.equal_weight[1] ≈ 1e5
    @test p.spy[end] ≈ 1e5 * md.spy_close[last(ctx.rows)] / md.spy_close[first(ctx.rows)]
end
