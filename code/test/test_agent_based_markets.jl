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
            (N=101, m=25), (N=101, m=3, S=1), (N=101, m=3, temperature=-1.0),
            (N=101, m=3, temperature=NaN), (N=101, m=3, information=:other),
        ]
        for data in bad_inputs
            @test_throws ArgumentError build(MyThermalMinorityGameModel, data)
        end
        model = build(MyThermalMinorityGameModel, merge(base, (rng=MersenneTwister(1),)))
        @test size(model.strategies) == (101, 2, 8)
        @test all(x -> x == -1 || x == 1, model.strategies)
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
        # 3 agents, m = 2 (P = 4); each agent's two strategies are identical, so the
        # choice cannot matter. Columns are the actions at μ = 1, 2, 3, 4.
        table = Int8[1 1 -1 1; -1 1 -1 1; -1 -1 1 1]
        strategies = Array{Int8,3}(undef, 3, 2, 4)
        for s in 1:2
            strategies[:, s, :] = table
        end
        model = MyThermalMinorityGameModel(3, 2, 2, 0.0, :history, strategies)
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
    end

    @testset "phase behavior (statistical regression)" begin
        # At infinite temperature an agent whose two strategies agree at μ always plays that
        # action, and one whose strategies disagree flips a coin, so for uniform μ
        # ⟨A²⟩/N = mean over μ of [(sum of the agreeing actions)² + number disagreeing] / N.
        for k in 1:3
            model = build(MyThermalMinorityGameModel, (N=101, m=3, temperature=Inf, information=:random, rng=MersenneTwister(k)))
            st = model.strategies
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
