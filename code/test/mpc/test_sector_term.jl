using Test, Dates, Statistics
include("helpers.jl")

# Course addition (CHEME 5660 L15a, 2026-11-27): the sector factor estimates. The fixed single index fit, plus the
# sector term δ̂ᵢ·f̃ₛ,₋ᵢ(t) in each stock's expected growth rate.

# the synthetic market with its last ticker relabeled as an ETF -
function sector_test_market(md0::MyMarketData, sector::Vector{String})::MyMarketData
    return build(MyMarketData, (dates=md0.dates, tickers=md0.tickers, open=md0.open, close=md0.close,
        volume=md0.volume, spy_open=md0.spy_open, spy_close=md0.spy_close, sector=sector, g_f=md0.g_f))
end

@testset "sector factor estimates" begin
    md0 = synthetic_md(ρ=0.3)
    sector = copy(md0.sector)
    sector[48] = "ETF"
    md = sector_test_market(md0, sector)
    train_start, train_stop = md.dates[[1, 800]]
    fit = fit_base_sim(md, train_start, train_stop)
    c = build(MyCalibration, (base_sim=fit.params, σ_m=fit.σ_m, m_m=fit.m_m, v_m=fit.v_m, λ=0.5,
        train_start=train_start, train_stop=train_stop))

    # the single index residual of ticker j on day t, by hand -
    g = growth_rates(md.close)
    g_m = growth_rates(md.spy_close)
    residual(t, j) = g[t-1, j] - c.base_sim[md.tickers[j]].α - c.base_sim[md.tickers[j]].β * g_m[t-1]

    # the sector factor: the mean residual of the other stocks of the sector; the ETF has none -
    F = sector_factor_series(md, c)
    @test size(F) == size(md.close)
    @test all(isnan, F[1, :])
    @test F[10, 1] ≈ mean(residual(10, j) for j in 2:12)
    @test F[900, 40] ≈ mean(residual(900, j) for j in [37, 38, 39, 41, 42, 43, 44, 45, 46, 47])
    @test all(==(0.0), F[2:end, 48])

    # the loading: the least squares slope, with an intercept, over the training days -
    δ = sector_loadings(md, c, F; train_start=train_start, train_stop=train_stop)
    x = F[2:800, 1]
    y = [residual(t, 1) for t in 2:800]
    @test δ[1] ≈ sum((x .- mean(x)) .* (y .- mean(y))) / sum((x .- mean(x)) .^ 2)
    @test δ[48] == 0.0
    @test 0.6 < median(δ[1:47]) < 1.0      # the fixture's loading is 0.3/(0.3 + 0.7/11) ≈ 0.83

    # the smoothed factor: the same moving average as g̃_M -
    F̃ = smoothed_sector_factor(F; window=252)
    @test all(isnan, F̃[1, :])
    @test F̃[2:end, 1] ≈ VLQuantitativeFinancePackage.MPCPortfolio.ema_series(F[2:end, 1]; span=252)
    @test all(==(0.0), F̃[2:end, 48])

    # the context: the fixed fit, with the sector term added to α on every row -
    s = build(MyStudySettings, (train_start=train_start, train_stop=train_stop, start=md.dates[801],
        stop=md.dates[900], estimates="sector_factor"))
    sf = build_context(md, c, s)
    fixed = build_context(md, c, with_settings(s; estimates="fixed"))
    @test sf.rows == fixed.rows
    for (k, t) in enumerate(sf.rows)
        for j in (1, 40, 48)
            @test sf.sim.α[k, j] ≈ fixed.sim.α[k, j] + δ[j] * F̃[t, j]
        end
    end
    @test sf.sim.β == fixed.sim.β && sf.sim.σ_ε == fixed.sim.σ_ε && sf.sim.σ_m == fixed.sim.σ_m
    @test sf.γ[10, :] == gamma_weights(sf.sim.α[10, :], sf.sim.β[10, :], sf.g̃[810], sf.ξ[810]; β_floor=0.1)
    @test sf.γ[:, 48] == fixed.γ[:, 48]
    @test sf.γ != fixed.γ
    @test context_key(sf.settings) != context_key(fixed.settings)

    # causal: prices after day 850 leave the first 50 rows alone -
    q = build_context(perturb_after(md, md.dates[850]), c, s)
    @test q.sim.α[1:50, :] == sf.sim.α[1:50, :] && q.γ[1:50, :] == sf.γ[1:50, :]

    # bad settings and a stock alone in its sector -
    @test_throws ArgumentError with_settings(s; estimates="sector")
    solo = copy(sector)
    solo[1] = "Solo"
    @test_throws ArgumentError sector_factor_series(sector_test_market(md0, solo), c)
end
