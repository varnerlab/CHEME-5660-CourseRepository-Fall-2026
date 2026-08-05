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
