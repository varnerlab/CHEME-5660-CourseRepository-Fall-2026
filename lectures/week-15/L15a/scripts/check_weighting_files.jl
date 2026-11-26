# L15a: check the nine weighting files against the engine. Instructor only.
#
# Run from the repository root (a few minutes):
#
#   julia --project=. lectures/week-15/L15a/scripts/check_weighting_files.jl
#
# The checks:
#   1. With no trading limit in the way, the engine's version of each rule gives the weights of the file's plain
#      function (within 1e-5).
#   2. On the real market (2025-01-02 to 2025-03-31, γ per sector, hedge on, updated estimates, the GBM forecast),
#      a backtest of each of the seven INFORMS rules from its file gives the same equity, day by day, as the engine's
#      built-in rule.
#   3. Equal weight and BAB run on the real market, and their first decisions follow the rule: equal weights on the
#      picked stocks, and a BAB book inside the 130/30 caps with longs on the low-β half and shorts on the high-β
#      half.

include(joinpath(@__DIR__, "setup.jl"))
using Test

"""
    open_problem(γ, prices; μ_g, Σ_g, β, g_f, W)::MPC.MyAllocationProblem

An allocation problem with no trading limit in the way: a single-name cap of `1`, no sector, β, or volatility cap,
no spread-cost budget, and a wealth of `W` (USD).
"""
function open_problem(γ::Vector{Float64}, prices::Vector{Float64}; μ_g::Vector{Float64}=fill(0.1, length(γ)),
        Σ_g::Matrix{Float64}=Matrix(4.0 * I, length(γ), length(γ)), β::Vector{Float64}=zeros(length(γ)),
        g_f::Float64=0.0, W::Float64=1e5)::MPC.MyAllocationProblem
    K = length(γ)
    cs = MPC.build(MPC.MyConstraintSet, (w_max=1.0, w_cap=ones(K), s_max=1.0, σ_g_max=Inf, K_turnover=1e12,
        c̄=0.0, sector=["S$(i)" for i in 1:K], n_prev=zeros(K), ε=1e-3, β=β, β_max=Inf))
    return MPC.build(MPC.MyAllocationProblem, (γ=γ, μ_g=μ_g, Σ_g=Σ_g, prices=prices, W=W, g_f=g_f,
        constraints=cs, hedge=fill(false, K)))
end

"""
    sim_covariance(β, σ_ε, σ_m)::Matrix{Float64}

The single-index covariance matrix `σ_m² β βᵀ + diag(σ_ε²)` (1/yr²).
"""
function sim_covariance(β::Vector{Float64}, σ_ε::Vector{Float64}, σ_m::Float64)::Matrix{Float64}
    return σ_m^2 .* (β * β') .+ Diagonal(σ_ε .^ 2)
end

# check 1: the plain functions against the engine with no limit in the way -
γ = [0.40, 0.25, 0.20, -0.10, 0.15]
γ_long = [0.40, 0.25, 0.20, 0.10, 0.15]
prices = [20.0, 55.0, 110.0, 35.0, 80.0]
β = [0.8, 0.9, 1.0, 1.1, 1.2]
σ_ε = [0.25, 0.30, 0.20, 0.35, 0.28]
σ_m = 0.18
α = [0.04, 0.02, 0.03, 0.01, 0.05]
g_m = 0.08
g_f = 0.04
Σ = sim_covariance(β, σ_ε, σ_m)
@testset "check 1: plain functions match the engine without limits" begin
    p = open_problem(γ, prices)
    @test MPC.allocate(MyL15aCobbDouglasRule(), p).w ≈ weigh_cobb_douglas(γ) atol=1e-5
    @test MPC.allocate(MyL15aCESSharesRule(0.5), p).w ≈ weigh_ces_shares(γ, prices; eta=0.5) atol=1e-5
    @test MPC.allocate(MyL15aCESWeightsRule(0.5), p).w ≈ weigh_ces_weights(γ; eta=0.5) atol=1e-5
    @test MPC.allocate(MyL15aStoneGearyRule(0.01), p).w ≈ weigh_stone_geary(γ; baseline=0.01) atol=1e-5
    @test MPC.allocate(MyL15aLongShortRule(1.30, 0.30, 1.00), p).w ≈ weigh_long_short(γ) atol=1e-5
    @test MPC.allocate(MyL15aLongShortRule(1.30, 0.30, 1.00), open_problem(γ_long, prices)).w ≈
        weigh_long_short(γ_long) atol=1e-5
    # The mean-variance solves work in shares. At USD 100,000 their weights are accurate to about 0.01 (the
    # variance is within 0.01% of the least variance), so these two checks use a wealth of USD 1,000 -
    p_var = open_problem(γ_long, prices; Σ_g=Σ, W=1e3)
    @test MPC.allocate(MyL15aMinimumVarianceRule(), p_var).w ≈ weigh_minimum_variance(β, σ_ε, σ_m) atol=1e-5
    p_sharpe = open_problem(γ_long, prices; Σ_g=Σ, μ_g=α .+ β .* g_m, g_f=g_f, W=1e3)
    @test MPC.allocate(MyL15aMaximumSharpeRule(), p_sharpe).w ≈ weigh_maximum_sharpe(α, β, σ_ε, σ_m, g_m, g_f) atol=1e-5
    picked = [true, true, false, true, true]
    p_equal = open_problem(MPC.rule_preferences(MyL15aEqualWeightRule(), γ, picked), prices)
    @test MPC.allocate(MyL15aEqualWeightRule(), p_equal).w[picked] ≈ weigh_equal(4) atol=1e-5
    @test MPC.allocate(MyL15aEqualWeightRule(), p_equal).w[3] == 0.0
    p_bab = open_problem(MPC.rule_preferences(MyL15aBABRule(10.0, 10.0, 0.1), γ, fill(true, 5)), prices; β=β)
    @test MPC.allocate(MyL15aBABRule(10.0, 10.0, 0.1), p_bab).w ≈ weigh_bab(β; beta_floor=0.1) atol=1e-5
end

# checks 2 and 3 run on the real market -
md = l15a_market()
calib = l15a_calibration(md)
settings = l15a_settings(; hedge=true, estimates="updated", stop=Date(2025, 3, 31), forecast_model="gbm",
    forecast_band="sigma")
ctx = MPC.build_context(md, calib, settings)
println("real-market context: ", length(md.tickers), " tickers, ", length(ctx.rows), " backtest days")

"""
    run_rule(rule)::MPC.MyStudyResult

A backtest of `rule` (a built-in name or a strategy-file rule) with γ per sector and seed 1.
"""
function run_rule(rule)::MPC.MyStudyResult
    run = MPC.build(MPC.MyStudyRun, (settings=settings, allocator=rule, screen=:gamma, seed=1))
    return MPC.run_study(ctx, run)
end

@testset "check 2: the seven INFORMS files match the built-in rules on the real market" begin
    pairs = [("CD", MyL15aCobbDouglasRule()), ("CES", MyL15aCESSharesRule(settings.ces_eta)),
        ("CESw", MyL15aCESWeightsRule(settings.ces_eta)), ("SG", MyL15aStoneGearyRule(settings.sg_baseline)),
        ("MinVar", MyL15aMinimumVarianceRule()), ("Tangent", MyL15aMaximumSharpeRule()),
        ("LS", MyL15aLongShortRule(settings.ls_long, settings.ls_short, settings.ls_net))]
    for (name, file_rule) in pairs
        seconds = @elapsed begin
            built_in = run_rule(name)
            from_file = run_rule(file_rule)
        end
        println(rpad(name, 8), " decisions: ", size(built_in.decisions, 1), ", final equity USD ",
            round(last(built_in.equity); digits=2), ", two runs in ", round(seconds; digits=1), " s")
        @test from_file.equity == built_in.equity
        @test from_file.trades == built_in.trades
    end
end

@testset "check 3: equal weight and BAB on the real market" begin
    t = first(ctx.rows)
    s = 1
    basket = MPC.pick(MyL15aGammaSectorScreen(), md, t; X=ctx.X, γ_t=ctx.γ[s, :], N=settings.N_per_sector, seed=1)

    # equal weight: the same weight on every picked stock -
    rule = MyL15aEqualWeightRule()
    run = MPC.build(MPC.MyStudyRun, (settings=settings, allocator=rule, screen=:gamma, seed=1))
    cols, hedge = MPC._study_problem_columns(rule, basket, ctx.pool[s], Int[], ctx.γ[s, :])
    p = MPC._study_problem(ctx, run, t, cols, hedge, zeros(length(md.tickers)), settings.W0; basket=basket, rule=rule)
    r = MPC.allocate(rule, p)
    picked = Bool[j in basket for j in cols]
    println("equal weight: ", count(picked), " picked, weights ", round(minimum(r.w[picked]); digits=5), " to ",
        round(maximum(r.w[picked]); digits=5), ", invested ", round(sum(r.w); digits=4), ", status ", r.status)
    @test r.status == :optimal
    @test maximum(r.w[picked]) - minimum(r.w[picked]) < 1e-6
    result = run_rule(rule)
    @test all(isfinite, result.equity)

    # BAB: inside the 130/30 caps, long the low-β half and short the high-β half -
    rule = MyL15aBABRule(settings.ls_long, settings.ls_short, settings.beta_floor)
    run = MPC.build(MPC.MyStudyRun, (settings=settings, allocator=rule, screen=:gamma, seed=1))
    p = MPC._study_problem(ctx, run, t, cols, hedge, zeros(length(md.tickers)), settings.W0; basket=basket, rule=rule)
    r = MPC.allocate(rule, p)
    target = weigh_bab(p.constraints.β[picked]; beta_floor=settings.beta_floor)
    w = r.w[picked]
    long_sum = sum(max.(r.w, 0.0))
    short_sum = sum(max.(-r.w, 0.0))
    println("BAB: long ", round(long_sum; digits=4), ", short ", round(short_sum; digits=4), ", book β ",
        round(sum(p.constraints.β .* r.w); digits=4), ", β limit ", p.constraints.β_max, ", status ", r.status)
    @test r.status == :optimal
    @test long_sum ≤ settings.ls_long + 1e-6
    @test short_sum ≤ settings.ls_short + 1e-6
    @test all(w[target .< 0] .≤ 1e-8)
    @test all(w[target .> 0] .≥ -1e-8)
    result = run_rule(rule)
    @test all(isfinite, result.equity)
    @test any(result.trades.qty .< 0)
end
