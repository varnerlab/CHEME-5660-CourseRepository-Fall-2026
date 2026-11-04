using Test, Dates
include("helpers.jl")
function toy_calib(md, k)
    fit = fit_base_sim(md, md.dates[1], md.dates[k])
    build(MyCalibration, (base_sim=fit.params, σ_m=fit.σ_m, m_m=fit.m_m, v_m=fit.v_m, λ=0.5,
        train_start=md.dates[1], train_stop=md.dates[k]))
end
@testset "online SIM path" begin
    md = synthetic_md(ρ=0.3); c = toy_calib(md, 800)
    sim = online_sim(md, c; start=md.dates[801], stop=md.dates[900])
    @test sim.rows == 801:900 && size(sim.β) == (100, 48)
    j = 7; p = c.base_sim[md.tickers[j]]
    s = ewls_init(p.α, p.β, p.σ_ε; market_mean=c.m_m, market_variance=c.v_m)
    v = ewvar_init(c.σ_m); σ = 0.0
    for (k, i) in enumerate(801:900)
        g_m = log(md.spy_close[i] / md.spy_close[i-1]) / (1/252)
        ewls_update!(s, log(md.close[i, j] / md.close[i-1, j]) / (1/252), g_m); σ = ewvar_update!(v, g_m)
        k == 50 && @test (sim.α[k, j], sim.β[k, j], sim.σ_ε[k, j], sim.σ_m[k]) == (s.α, s.β, s.σ_ε, σ)
    end
    q = online_sim(perturb_after(md, md.dates[850]), c; start=md.dates[801], stop=md.dates[900])
    @test q.β[1:50, :] == sim.β[1:50, :] && q.β[51, :] != sim.β[51, :]          # canary
    @test_throws ArgumentError online_sim(md, c; start=md.dates[1], stop=md.dates[10])
end
