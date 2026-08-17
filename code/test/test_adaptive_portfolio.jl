using Test
using Random
using LinearAlgebra
using Statistics
using VLQuantitativeFinancePackage

@testset "adaptive portfolio" begin
    α = [0.01, 0.02, 0.00]
    β = [0.8, 1.0, 1.2]
    σ_ε = [0.10, 0.12, 0.15]
    μ, Σ = sim_portfolio_inputs(α, β, σ_ε, 0.08, 0.18)
    @test μ ≈ α .+ β .* 0.08
    @test isposdef(Symmetric(Σ))
    w = minimum_variance_weights(Σ)
    @test sum(w) ≈ 1.0

    rng = MersenneTwister(5660)
    market = 0.01 .+ 0.20 .* randn(rng, 600)
    asset = 0.02 .+ 1.25 .* market .+ 0.08 .* randn(rng, 600)
    estimate = estimate_sim(market, asset, "TEST")
    @test estimate.α ≈ 0.02 atol=0.015
    @test estimate.β ≈ 1.25 atol=0.05
    @test estimate.σ_ε ≈ 0.08 atol=0.01
    residual_bootstrap = bootstrap_sim(market, asset, "TEST";
        n_bootstrap=300, seed=44, method=:residual)
    gaussian_bootstrap = bootstrap_sim(market, asset, "TEST";
        n_bootstrap=300, seed=44, method=:parametric)
    @test size(residual_bootstrap.samples) == (300, 3)
    @test residual_bootstrap.confidence_intervals.beta[1] < estimate.β <
        residual_bootstrap.confidence_intervals.beta[2]
    @test residual_bootstrap.bootstrap_standard_errors.beta ≈
        residual_bootstrap.theoretical_standard_errors.beta rtol=0.25
    @test gaussian_bootstrap.method == :parametric

    second_asset = -0.01 .+ 0.75 .* market .+ 0.12 .* randn(rng, 600)
    second_bootstrap = bootstrap_sim(market, second_asset, "TEST2";
        n_bootstrap=300, seed=45)
    propagation = propagate_sim_uncertainty([residual_bootstrap, second_bootstrap],
        mean(market), std(market); n_scenarios=200, seed=46)
    @test length(propagation.variance_regret) == 200
    @test minimum(propagation.variance_regret) > -1e-10

    pareto = (1 .- rand(rng, 20_000)) .^ (-1 / 3.0)
    @test hill_tail_index(pareto; k=500, tail=:right) ≈ 3.0 atol=0.35
    acf = sample_autocorrelation([1.0, -1.0, 1.0, -1.0], [0, 1])
    @test acf[1] == 1.0
    @test acf[2] < 0
    facts = stylized_facts_report(asset; lags=[1, 5], hill_k=50)
    @test length(facts.raw_acf) == 2

    Σρ = covariance_from_volatility([0.1, 0.2, 0.3], 0.25)
    @test diag(Σρ) ≈ [0.01, 0.04, 0.09]

    gamma = adaptive_preference_weights(α, β, σ_ε, -0.2)
    @test sum(gamma) ≈ 1.0
    cd = allocate_cobb_douglas([10.0, 20.0, 40.0], gamma, 1_000.0)
    @test sum(cd.dollars) + cd.cash ≈ 1_000.0
    ces = allocate_ces([10.0, 20.0, 40.0], gamma, 1_000.0, 2.0)
    @test sum(ces.dollars) + ces.cash ≈ 1_000.0

    @test compute_ema([1.0, 2.0, 3.0], 3) ≈ [1.0, 1.5, 2.25]
    @test sum(adaptive_target_weights(0.2, β)) ≈ 1.0

    path = ewls_path(collect(range(-0.1, 0.1; length=100)),
        0.01 .+ 1.3 .* collect(range(-0.1, 0.1; length=100)); half_life=30.0)
    @test path[end, 1] ≈ 0.01 atol=1e-3
    @test path[end, 2] ≈ 1.3 atol=1e-3

    state = ewls_init(0.0, 1.0, 0.1; half_life=20.0, prior_weight=10.0)
    @test length(ewls_update!(state, 0.02, 0.01)) == 3

    # EWLS prior seeding: the seeded state reproduces the prior exactly (week-7 phase 1, Task 1)
    m, v = 0.10, 8.0                                # training market mean (1/yr) and variance (1/yr²)
    st = ewls_init(0.05, 1.2, 1.5; half_life=30.0, prior_weight=40.0, market_mean=m, market_variance=v)
    @test st.δ ≈ 2.0^(-1/30)
    @test st.Sw ≈ 40.0
    @test st.Swx ≈ 40.0 * m
    @test st.Swxx ≈ 40.0 * (v + m^2)
    @test st.α ≈ 0.05 && st.β ≈ 1.2 && st.σ_ε ≈ 1.5
    # one no-information update (y exactly on the prior line) leaves α, β unchanged
    α1, β1, σ1 = ewls_update!(st, 0.05 + 1.2 * 0.3, 0.3)
    @test α1 ≈ 0.05 atol=1e-10
    @test β1 ≈ 1.2 atol=1e-10
    @test σ1 < 1.5                                   # a zero-residual observation lowers the RMS residual

    # ewls_path == batch weighted least squares once the prior has decayed away (Task 2)
    rngp = MersenneTwister(7)
    xw = 0.1 .+ 2.5 .* randn(rngp, 400)             # market growth rates, 1/yr scale
    yw = 0.02 .+ 1.1 .* xw .+ 0.9 .* randn(rngp, 400)
    hl = 20.0; δw = 2.0^(-1/hl)
    pathw = ewls_path(xw, yw; half_life=hl,
        prior=(α=0.0, β=1.0, σ_ε=1.0, market_mean=mean(xw), market_variance=var(xw)),
        prior_weight=1e-9)
    @test size(pathw) == (400, 3)
    t_end = 400
    wts = δw .^ (t_end .- (1:t_end))
    Xw = hcat(ones(t_end), xw)
    θ_batch = (Xw' * (wts .* Xw)) \ (Xw' * (wts .* yw))
    @test pathw[end, 1] ≈ θ_batch[1] rtol=1e-8
    @test pathw[end, 2] ≈ θ_batch[2] rtol=1e-8
    res = yw .- Xw * θ_batch
    @test pathw[end, 3] ≈ sqrt(sum(wts .* res.^2) / sum(wts)) rtol=1e-8
    # legacy call (no prior) still works and its slope converges on a noiseless line
    legacy = ewls_path(collect(range(-0.1, 0.1; length=100)),
        0.01 .+ 1.3 .* collect(range(-0.1, 0.1; length=100)); half_life=30.0)
    @test size(legacy, 2) == 3
    @test legacy[end, 2] ≈ 1.3 atol=1e-3

    # run_utility_engine (Task 3)
    Tn, Kn = 60, 3
    rnge = MersenneTwister(11)
    P = 100.0 .* exp.(cumsum(0.01 .* randn(rnge, Tn, Kn); dims=1))     # T×K prices
    wfix = [0.5, 0.3, 0.2]
    # (a) buy and hold: rebalance on day 1 only, zero cost: wealth == Σ nᵢ Sᵢ(t) with nᵢ = wᵢW0/Sᵢ(1)
    bh = run_utility_engine(P, (t, s) -> wfix; W0=1000.0, rebalance_days=[1], cost_rate=0.0)
    n1 = wfix .* 1000.0 ./ P[1, :]
    @test bh.wealth[2:end] ≈ [dot(n1, P[t, :]) for t in 1:Tn]
    @test all(bh.cash .>= -1e-9)
    @test bh.interventions == 0
    # (b) budget invariant every day, cash ≥ 0, with costs and daily rebalancing
    dr = run_utility_engine(P, (t, s) -> wfix; W0=1000.0, rebalance_days=1:Tn, cost_rate=5e-4)
    for t in 1:Tn
        @test dr.cash[t+1] + dot(dr.shares[t+1, :], P[t, :]) ≈ dr.wealth[t+1] atol=1e-8
        @test dr.cash[t+1] >= -1e-9
    end
    @test sum(dr.cost) > 0
    # (c) turnover cap binds: flipping between two corners with cap 0.10 never trades more than 0.10 one-way
    flip = (t, s) -> isodd(t) ? [1.0, 0.0, 0.0] : [0.0, 1.0, 0.0]
    cap = run_utility_engine(P, flip; rebalance_days=1:Tn, cost_rate=0.0, turnover_cap=0.10)
    @test all(cap.turnover[2:end] .<= 0.10 + 1e-9)
    # (d) drawdown circuit breaker: a collapsing price path triggers liquidation and a lock
    Pdown = hcat(100.0 .* (0.95 .^ (0:Tn-1)), fill(100.0, Tn), fill(100.0, Tn))
    cb = run_utility_engine(Pdown, (t, s) -> [1.0, 0.0, 0.0]; rebalance_days=1:Tn, cost_rate=0.0,
        drawdown_limit=0.10, reentry_days=10)
    @test cb.interventions >= 1
    @test any(cb.locked)
    firstlock = findfirst(cb.locked)
    @test cb.cash[firstlock+1] ≈ cb.wealth[firstlock+1] atol=1e-8      # fully in cash when locked
    # (e) cash earns g_f: all-cash book grows by exp(g_f Δt) per day
    cashonly = run_utility_engine(P, (t, s) -> zeros(Kn); rebalance_days=[1], g_f=0.05, Δt=1/252)
    @test cashonly.wealth[end] ≈ 1000.0 * exp(0.05 * Tn / 252)
    # (f) validation: bad target
    @test_throws ArgumentError run_utility_engine(P, (t, s) -> [0.7, 0.7, 0.0]; rebalance_days=[1])

    # scorecards (Task 4)
    wpath = [1000.0, 1100.0, 990.0, 1210.0]
    sc = realized_scorecard(wpath; g_f=0.0, Δt=1/252)
    @test sc.max_drawdown ≈ 0.10
    @test sc.npv ≈ 210.0
    @test sc.horizon_years ≈ 3/252
    @test sc.total_turnover == 0.0
    sc2 = realized_scorecard(wpath; g_f=0.041, Δt=1/252, turnover=[0.1, 0.0, 0.2], cost=[1.0, 0.0, 2.0], interventions=1)
    @test sc2.total_turnover ≈ 0.3 && sc2.total_cost ≈ 3.0 && sc2.interventions == 1
    @test sc2.npv ≈ -1000.0 + 1210.0 * exp(-0.041 * 3/252)
    term = collect(900.0:10.0:1090.0)               # 20 paths
    dd = collect(range(0.0, 0.19; length=20))
    es = ensemble_scorecard(term, dd; W0=1000.0, g_f=0.0, horizon=1.0, level=0.10)
    @test es.k == 2
    @test es.lower_quantile ≈ 910.0
    @test es.tail_mean ≈ 905.0
    @test es.fail_rate ≈ 0.5
    @test es.drawdown_quantile ≈ dd[19]

    # --- Codex post-audit additions (week-7 phase 1) ---
    # engine: cost equals cost_rate × actual traded notional; post-trade wealth == pre-trade wealth − cost
    dr2 = run_utility_engine(P, (t, s) -> wfix; W0=1000.0, rebalance_days=1:Tn, cost_rate=5e-4)
    @test all(isapprox.(dr2.cost, 5e-4 .* dr2.traded; atol=1e-9))
    for t in 2:Tn   # independent pre-trade mark: yesterday's shares at today's prices plus yesterday's cash
        pre = dot(dr2.shares[t, :], P[t, :]) + dr2.cash[t]
        @test dr2.wealth[t+1] ≈ pre - dr2.cost[t] atol=1e-8
    end
    # turnover cap actually binds (turnover strictly positive and equal to the cap on flip days)
    @test count(≈(0.10), cap.turnover[2:end]) >= Tn ÷ 2
    # circuit breaker: exact trigger day, lock length, re-entry, and no immediate re-fire on the old peak
    Pcb = hcat(vcat([100.0, 100.0, 85.0], fill(85.0, Tn - 3)), fill(100.0, Tn), fill(100.0, Tn))
    cb2 = run_utility_engine(Pcb, (t, s) -> [1.0, 0.0, 0.0]; rebalance_days=1:Tn, cost_rate=0.0,
        drawdown_limit=0.10, reentry_days=2)
    @test cb2.interventions == 1
    @test findall(cb2.locked) == [3, 4, 5]                # liquidation day + 2 cooldown days
    @test cb2.rebalanced[6] && all(cb2.weights[7:end, 1] .≈ 1.0)   # re-enters on day 6 and stays invested (peak rebased)
    @test cb2.turnover[3] ≈ 1.0                            # full liquidation is one-way turnover 1
    # K = 1 works; callback cannot corrupt the price matrix; targets summing above one are rejected
    P1 = reshape(100.0 .* exp.(cumsum(0.01 .* randn(rnge, Tn))), Tn, 1)
    one = run_utility_engine(P1, (t, s) -> [1.0]; rebalance_days=[1], cost_rate=0.0)
    @test one.wealth[end] ≈ 1000.0 * P1[end, 1] / P1[1, 1]
    Pcopy = copy(P)
    run_utility_engine(P, (t, s) -> (s.prices[1] = 1.0; wfix); rebalance_days=1:Tn)
    @test P == Pcopy
    @test_throws ArgumentError run_utility_engine(P, (t, s) -> [0.5, 0.5, 0.5]; rebalance_days=[1])
    @test_throws ArgumentError run_utility_engine(P, (t, s) -> wfix; Δt=0.0)
    # scorecards: floating-point k selection and NaN rejection
    es7 = ensemble_scorecard(collect(1.0:100.0), zeros(100); W0=1.0, g_f=0.0, horizon=1.0, level=0.07)
    @test es7.k == 7
    @test_throws ArgumentError ensemble_scorecard([NaN, 1.0], [0.0, 0.0]; W0=1.0, g_f=0.0, horizon=1.0)
    @test isnan(realized_scorecard([1.0, 1.0]; g_f=0.0).realized_sharpe)   # one return: Sharpe undefined
    # EWLS: the prior is recovered from the sufficient statistics themselves (not from the assigned fields)
    st3 = ewls_init(0.05, 1.2, 1.5; half_life=30.0, prior_weight=40.0, market_mean=m, market_variance=v)
    A0 = [st3.Sw st3.Swx; st3.Swx st3.Swxx]; b0 = [st3.Swy, st3.Swxy]
    θ0 = A0 \ b0
    @test θ0 ≈ [0.05, 1.2] atol=1e-12
    @test sqrt((st3.Swyy - dot(θ0, b0)) / st3.Sw) ≈ 1.5 atol=1e-10
    @test_throws ArgumentError ewls_init(0.0, 1.0, -0.1; market_mean=m, market_variance=v)
    @test_throws ArgumentError ewls_init(0.0, 1.0, 0.1; market_mean=m, market_variance=0.0)
    # EWLS with a NON-negligible prior equals batch WLS with the decayed prior quadratic added
    N₀p, hlp = 30.0, 25.0; δp = 2.0^(-1/hlp)
    priorp = (α=0.0, β=1.0, σ_ε=1.0, market_mean=mean(xw), market_variance=var(xw; corrected=false))
    pathp = ewls_path(xw[1:50], yw[1:50]; half_life=hlp, prior=priorp, prior_weight=N₀p)
    Exx = [1.0 priorp.market_mean; priorp.market_mean priorp.market_variance + priorp.market_mean^2]
    tp = 50; wp = δp .^ (tp .- (1:tp)); Xp = hcat(ones(tp), xw[1:tp])
    Ap = Xp' * (wp .* Xp) .+ δp^tp * N₀p .* Exx
    bp = Xp' * (wp .* yw[1:tp]) .+ δp^tp * N₀p .* (Exx * [priorp.α, priorp.β])
    @test pathp[end, 1:2] ≈ Ap \ bp rtol=1e-10
    # legacy no-prior path: warm-up rows are NaN, estimation starts after the warm-up window
    legacy2 = ewls_path(xw, yw; half_life=20.0, warmup=30)
    @test all(isnan, legacy2[1:30, :]) && all(isfinite, legacy2[31:end, :])

    gates = evaluate_validation_gates(Dict("return" => 0.1, "risk" => 0.2), Dict(
        "return" => (operator=:minimum, value=0.0),
        "risk" => (operator=:maximum, value=0.25)))
    @test gates.overall == "PASS"

    limits = (max_position_weight=0.30, max_one_way_turnover=0.20,
        drawdown_escalation=0.10, news_severity_escalation=0.75)
    @test route_portfolio_event((proposed_weight=0.31, news_severity=0.0), 0.0, limits, false).route == "BLOCK"
    @test route_portfolio_event((proposed_weight=0.20, news_severity=0.9), 0.0, limits, false).route == "REVIEW"

    calibration = MySIMCalibration()
    prices = MyCurrentPrices()
    @test length(calibration["tickers"]) == length(calibration["alpha"])
    @test length(prices["tickers"]) == length(prices["prices"])
    @test !haskey(MyAdaptivePortfolioCourseData(:engine_run), "context")
    @test_throws ArgumentError MyAdaptivePortfolioCourseData(:unknown)
end
