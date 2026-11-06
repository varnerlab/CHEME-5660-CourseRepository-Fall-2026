using Random
using Statistics

@testset "Thermal minority game" begin

    @testset "boltzmann_weights" begin
        e = exp(1.0)
        cases = [
            (boltzmann_weights([1.0, 0.0], 1.0), [e / (e + 1), 1 / (e + 1)]),
            (boltzmann_weights([1.0, 1.0, 0.0], 0.0), [0.5, 0.5, 0.0]),
            (boltzmann_weights([5.0, -3.0], Inf), [0.5, 0.5]),
            (boltzmann_weights([1000.0, 0.0], 0.01), [1.0, 0.0]),
        ]
        for (w, expected) in cases
            @test all(isfinite, w)
            @test all(>=(0.0), w)
            @test isapprox(sum(w), 1.0)
            @test isapprox(w, expected; atol=1e-12)
        end
        @test_throws ArgumentError boltzmann_weights([1.0, 0.0], -1.0)
        @test_throws ArgumentError boltzmann_weights([1.0, 0.0], NaN)
    end

    @testset "build validation" begin
        base = (N=101, m=3)
        bad_inputs = [
            (N=100, m=3), (N=0, m=3), (N=101, m=0), (N=101, m=3.5), (N=101, m="3"),
            (N=101, m=25), (N=101, m=3, J=1), (N=101, m=3, S=2), (N=101, m=3, temperature=-1.0),
            (N=101, m=3, temperature=NaN), (N=101, m=3, information=:other),
            (N=101, m=3, buy_probability=-0.1), (N=101, m=3, buy_probability=1.5), (N=101, m=3, buy_probability=true),
        ]
        for data in bad_inputs
            @test_throws ArgumentError build(MyThermalMinorityGameModel, data)
        end
        model = build(MyThermalMinorityGameModel, merge(base, (rng=MersenneTwister(1),)))
        @test size(model.policies) == (101, 2, 8)
        @test all(x -> x == -1 || x == 1, model.policies)
        @test all(==(1), build(MyThermalMinorityGameModel, (N=11, m=2, buy_probability=1.0, rng=MersenneTwister(1))).policies)
        @test all(==(-1), build(MyThermalMinorityGameModel, (N=11, m=2, buy_probability=0.0, rng=MersenneTwister(1))).policies)
        biased = build(MyThermalMinorityGameModel, (N=2001, m=4, buy_probability=0.7, rng=MersenneTwister(7))).policies
        @test abs(mean(biased .== 1) - 0.7) < 0.01    # 2001 × 2 × 16 entries, standard error about 0.0026
        @test_throws ArgumentError solve(model; number_of_rounds=0)
        @test_throws ArgumentError solve(model; number_of_rounds=10, burn_in=-1)
    end

    @testset "solve output" begin
        model = build(MyThermalMinorityGameModel, (N=101, m=3, rng=MersenneTwister(2)))
        result = solve(model; number_of_rounds=2_000, burn_in=100, rng=MersenneTwister(3))
        @test length(result.attendance) == 2_000
        @test length(result.information) == 2_000
        @test all(isodd, result.attendance)
        @test all(a -> abs(a) <= 101, result.attendance)
        @test result.alpha ≈ 8 / 101
        @test size(result.final_scores) == (101, 2)
        @test result.volatility_per_agent ≈ mean(abs2, result.attendance) / 101
        for info in (:history, :random)
            m2 = build(MyThermalMinorityGameModel, (N=51, m=2, information=info, rng=MersenneTwister(4)))
            @test length(solve(m2; number_of_rounds=100, rng=MersenneTwister(5)).attendance) == 100
        end
    end

    @testset "history encoding (hand computed)" begin
        # 3 agents, m = 2 (P = 4); each agent's two policies are identical, so the
        # choice cannot matter. Columns are the actions at μ = 1, 2, 3, 4.
        table = Int8[1 1 -1 1; -1 1 -1 1; -1 -1 1 1]
        policies = Array{Int8,3}(undef, 3, 2, 4)
        for j in 1:2
            policies[:, j, :] = table
        end
        model = MyThermalMinorityGameModel(3, 2, 2, 0.0, :history, policies)
        result = solve(model; number_of_rounds=4, initial_information=1, rng=MersenneTwister(6))
        # μ=1: A=-1, minority +1 (bit 1) → μ=2; μ=2: A=+1, minority -1 (bit 0) → μ=3;
        # μ=3: A=-1, minority +1 → μ=2; μ=2: A=+1.
        @test result.information == [1, 2, 3, 2]
        @test result.attendance == [-1, 1, -1, 1]
    end

    @testset "reproducibility" begin
        run() = solve(build(MyThermalMinorityGameModel, (N=101, m=3, temperature=0.5, rng=MersenneTwister(5660)));
            number_of_rounds=1_000, rng=MersenneTwister(5660)).attendance
        @test run() == run()
        # golden baseline recorded before the S → J, strategies → policies rename (2026-11-06)
        golden = solve(build(MyThermalMinorityGameModel, (N=21, m=3, temperature=0.5, rng=MersenneTwister(5660)));
            number_of_rounds=40, burn_in=10, rng=MersenneTwister(5661))
        @test golden.attendance == [7, 3, -1, -1, -1, 1, 1, -1, 7, -1, 5, -1, -3, -1, -7, 5, 1, -3, -1, -3,
            -3, 1, -3, -1, -3, -3, 3, 1, -5, 3, -3, -1, -1, -3, 5, -1, 1, -3, -1, 1]
        @test golden.information == [7, 5, 1, 2, 4, 8, 7, 5, 2, 3, 6, 3, 6, 4, 8, 8, 7, 5, 2, 4,
            8, 8, 7, 6, 4, 8, 8, 7, 5, 2, 3, 6, 4, 8, 8, 7, 6, 3, 6, 4]
    end

    @testset "phase behavior (statistical regression)" begin
        # At infinite temperature an agent whose two policies agree at μ always plays that
        # action, and one whose policies disagree flips a coin, so for uniform μ
        # ⟨A²⟩/N = mean over μ of [(sum of the agreeing actions)² + number disagreeing] / N.
        for k in 1:3
            model = build(MyThermalMinorityGameModel, (N=101, m=3, temperature=Inf, information=:random, rng=MersenneTwister(k)))
            st = model.policies
            theory = mean(1:8) do μ
                agree = st[:, 1, μ] .== st[:, 2, μ]
                (sum(Int.(st[agree, 1, μ])))^2 + count(!, agree)
            end / 101
            simulated = solve(model; number_of_rounds=50_000, rng=MersenneTwister(100 + k)).volatility_per_agent
            @test isapprox(simulated, theory; rtol=0.05)
        end
        # averaged over many information states, the quenched sums average out toward 1
        wide = solve(build(MyThermalMinorityGameModel, (N=101, m=8, temperature=Inf, rng=MersenneTwister(11)));
            number_of_rounds=20_000, burn_in=1_000, rng=MersenneTwister(12)).volatility_per_agent
        @test 0.85 < wide < 1.15
        crowded = solve(build(MyThermalMinorityGameModel, (N=301, m=2, rng=MersenneTwister(7)));
            number_of_rounds=20_000, burn_in=2_000, rng=MersenneTwister(8))
        @test crowded.volatility_per_agent > 1.5
        near_critical = solve(build(MyThermalMinorityGameModel, (N=101, m=5, rng=MersenneTwister(9)));
            number_of_rounds=20_000, burn_in=5_000, rng=MersenneTwister(10))
        @test near_critical.volatility_per_agent < 1.0
    end
end

@testset "Farmer-Joshi market" begin

    # apply the threshold rule to a sequence of signals, starting from a zero position
    function run_rule(signals, entry, exit, capital, direction)
        x = 0.0
        out = Float64[]
        for s in signals
            x = threshold_position(x, s, entry, exit, capital, direction)
            push!(out, x)
        end
        return out
    end

    @testset "threshold state machine" begin
        signals = [0.5, 1.2, 0.8, 0.3, -0.1, -1.5, -0.4, 0.1]
        @test run_rule(signals, 1.0, 0.0, 2.0, -1) == [0, -2, -2, -2, 0, 2, 2, 0]
        @test run_rule(signals, 1.0, 0.0, 2.0, +1) == [0, 2, 2, 2, 0, -2, -2, 0]
        # a negative exit threshold catches a wrong sign on the long or short exit
        signals = [1.1, -0.1, -0.3, -1.1, 0.1, 0.3]
        @test run_rule(signals, 1.0, -0.2, 2.0, -1) == [-2, -2, 0, 2, 2, 0]
        @test run_rule(signals, 1.0, -0.2, 2.0, +1) == [2, 2, 0, -2, -2, 0]
        # strict inequalities at the boundaries (value investor, exit τ = -0.2)
        @test threshold_position(0.0, 1.0, 1.0, -0.2, 2.0, -1) == 0.0
        @test threshold_position(0.0, -1.0, 1.0, -0.2, 2.0, -1) == 0.0
        @test threshold_position(-2.0, -0.2, 1.0, -0.2, 2.0, -1) == -2.0   # m == τ: still short
        @test threshold_position(2.0, 0.2, 1.0, -0.2, 2.0, -1) == 2.0      # m == -τ: still long
        @test_throws ArgumentError threshold_position(0.0, 0.5, 1.0, 0.0, 2.0, 0)
    end

    @testset "first trend signal at t = θ" begin
        # log_price[k] holds ln S_{k-1}; the trend signal ln S_t - ln S_{t-θ} exists once t ≥ θ
        prices = [0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0]
        θ = 5
        for k in 1:5
            @test VLQuantitativeFinancePackage._fj_trend_signal(prices, k, θ) === nothing
        end
        @test VLQuantitativeFinancePackage._fj_trend_signal(prices, 6, θ) == 1.0
        @test VLQuantitativeFinancePackage._fj_trend_signal(prices, 7, θ) == 1.0
    end

    @testset "build" begin
        model = build(MyFarmerJoshiMarketModel, (rng=MersenneTwister(1),))
        @test length(model.value_entry) == 1200 && length(model.trend_entry) == 1200
        @test all(0.2 .<= model.value_entry .<= 4.0) && all(0.2 .<= model.trend_entry .<= 4.0)
        @test all(-0.2 .<= model.value_exit .<= 0.0) && all(-0.2 .<= model.trend_exit .<= 0.0)
        @test all(-2.0 .<= model.value_offset .<= 2.0)
        @test model.value_capital ≈ 2.5e-3 .* (model.value_entry .- model.value_exit)
        @test model.trend_capital ≈ 2.5e-3 .* (model.trend_entry .- model.trend_exit)
        @test eltype(model.trend_lag) == Int && all(1 .<= model.trend_lag .<= 100)
        @test model.σ_S ≈ 0.35 * sqrt(252) && model.σ_v == 0.16 && model.μ_v == 0.0 && model.Δt == 1 / 252 && model.λ == 1.0
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (value_T_min=-0.1,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (λ=0.0,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (Δt=0.0,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (σ_S=-1.0,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (σ_v=-1.0,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (σ_S=Inf,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (σ_ξ=0.05,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (σ_η=0.01,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (μ_η=0.0,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (trend_number=-1,))
        @test_throws ArgumentError build(MyFarmerJoshiMarketModel, (trend_θ_min=0,))
    end

    @testset "solve" begin
        # no traders: returns are the price noise alone
        empty_market = build(MyFarmerJoshiMarketModel, (value_number=0, trend_number=0, rng=MersenneTwister(2)))
        r = solve(empty_market; number_of_steps=20_000, rng=MersenneTwister(3))
        @test length(r.returns) == 20_000 && length(r.log_price) == 20_001
        @test r.returns ≈ diff(r.log_price)
        @test isapprox(std(r.returns), 0.35; rtol=0.05)
        @test all(iszero, r.value_volume) && all(iszero, r.trend_volume)

        # value investors only
        value_only = build(MyFarmerJoshiMarketModel, (trend_number=0, rng=MersenneTwister(4)))
        r = solve(value_only; number_of_steps=500, burn_in=100, rng=MersenneTwister(5))
        @test length(r.returns) == 500 && all(isfinite, r.log_price)

        # a supplied value path is used unchanged
        path = collect(range(0.0, 1.0; length=651))
        r = solve(value_only; number_of_steps=500, burn_in=150, rng=MersenneTwister(6), log_value_path=path)
        @test r.log_value == path[151:651]
        @test_throws ArgumentError solve(value_only; number_of_steps=500, burn_in=150, log_value_path=path[1:600])

        # short history: trend lags up to 100 with only 50 steps
        full = build(MyFarmerJoshiMarketModel, (rng=MersenneTwister(7),))
        @test length(solve(full; number_of_steps=50, rng=MersenneTwister(8)).returns) == 50

        # reproducibility
        run() = solve(build(MyFarmerJoshiMarketModel, (rng=MersenneTwister(5660),)); number_of_steps=1_000,
            rng=MersenneTwister(5660)).log_price
        @test run() == run()

        @test_throws ArgumentError solve(full; number_of_steps=0)
        @test_throws ArgumentError solve(full; number_of_steps=10, burn_in=-1)
    end
end
