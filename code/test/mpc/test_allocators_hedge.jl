using Test, LinearAlgebra
include("helpers.jl")
const RULES_LONG = (MyCobbDouglasRule(), build(MyCESRule, (η=0.5,)), build(MyCESRule, (η=2.0,)),
    build(MyCESWeightRule, (η=0.5,)), build(MyCESWeightRule, (η=2.0,)),
    build(MyStoneGearyRule, (baseline_frac=0.01,)))

@testset "CES below one and at one" begin
    γ = [0.2, 0.5, 0.3]; S = [10.0, 20.0, 40.0]
    @test allocate(build(MyCESRule, (η=0.5,)), P()).n ≈ 1000 .* (γ ./ S) .^ 0.5 ./ sum(S .* (γ ./ S) .^ 0.5) rtol=1e-5
    @test allocate(build(MyCESRule, (η=1.0,)), P()).n ≈ allocate(MyCobbDouglasRule(), P()).n rtol=1e-8
end

@testset "β cap binds in every rule" begin
    β = [1.5, 1.0, 0.5]
    for rule in (RULES_LONG..., MyMinVarRule(), MyTangentRule(), MyLongShortCDRule())
        r = allocate(rule, P(β=β, β_max=0.8, μ_g=[0.3, 0.2, 0.1]))
        @test r.status in (:optimal, :fallback_minvar, :long_only_fallback)
        @test dot(r.w, β) <= 0.8 + 1e-6
    end
    @test dot(allocate(MyCobbDouglasRule(), P(β=β, β_max=0.8)).w, β) ≈ 0.8 rtol=1e-5   # uncapped: 0.95
    @test allocate(MyCobbDouglasRule(), P(β=β, β_max=Inf)).n ≈ allocate(MyCobbDouglasRule(), P()).n
    r = allocate(MyCobbDouglasRule(), P(β=[1.0, 1.0, 1.0], β_max=0.1))     # Review Focus 2: cash, not infeasible
    @test r.status == :optimal && r.s_star <= 0.1 + 1e-6
end

@testset "hedge names: bought to meet the cap, at the floor otherwise" begin
    γ = [0.5, 0.4, -0.2, -0.1]; β = [1.2, 1.0, -0.5, -0.5]; S = [10.0, 20.0, 40.0, 25.0]
    hedge = [false, false, true, false]
    for rule in RULES_LONG
        sg = rule isa MyStoneGearyRule
        r = allocate(rule, P(γ=γ, prices=S, β=β, β_max=0.4, hedge=hedge, w_max=0.5))
        @test r.status == :optimal
        @test r.w[3] > 0.05                                       # the hedge leaves its floor
        @test r.n[4] == (sg ? 0.01 * 1000 / S[4] : 1e-3)           # a non-pool γ ≤ 0 name stays pinned (SG: at its baseline)
        @test dot(r.w, β) <= 0.4 + 1e-6
        r0 = allocate(rule, P(γ=γ, prices=S, β=β, β_max=Inf, hedge=hedge, w_max=0.2))   # budget slack
        @test r0.n[3] <= (sg ? 0.01 * 1000 / S[3] : 1e-3) + 1e-2   # tie-break keeps it at the floor
    end
end

@testset "hedges hold the least the binding cap needs (W = 1e5)" begin
    # The preferred names sit at w_max, so hedges alone meet the β cap: a flat direction that the 1e-6
    # tie-break cannot resolve at this scale (alone it leaves 12–17% of equity in name 4). The second
    # stage puts all the relief in the more efficient hedge (β = −0.5) and leaves name 4 at its floor.
    γ = [0.5, 0.4, -0.2, -0.2]; β = [1.2, 1.0, -0.5, -0.25]; S = [50.0, 120.0, 80.0, 40.0]; W = 1e5
    p = P(γ=γ, prices=S, W=W, β=β, β_max=0.56, hedge=[false, false, true, true], w_max=0.3, σ_g_max=Inf)
    for rule in RULES_LONG
        r = allocate(rule, p)
        floor4 = rule isa MyStoneGearyRule ? floor(0.01 * W / S[4]) : 1e-3      # shares
        @test r.status == :optimal
        @test r.w[1:2] ≈ [0.3, 0.3] atol=1e-6
        @test dot(r.w, β) ≈ 0.56 atol=1e-6
        @test (r.n[4] - floor4) * S[4] / W <= 1e-6
    end
    # 130/30: the short (name 5, β = 1) sits at the short cap; the hedges cover the rest
    r = allocate(MyLongShortCDRule(), P(γ=[γ; -0.3], prices=[S; 60.0], W=W, β=[β; 1.0], β_max=0.26,
        hedge=[false, false, true, true, false], w_max=0.3, σ_g_max=Inf))
    @test r.status == :optimal
    @test r.w[[1, 2, 5]] ≈ [0.3, 0.3, -0.3] atol=1e-6
    @test dot(r.w, [β; 1.0]) ≈ 0.26 atol=1e-6
    @test abs(r.w[4]) <= 1e-6
end

@testset "130/30: pool names long, others short" begin
    γ = [0.5, 0.4, -0.3, -0.2]; β = [1.2, 1.0, -0.6, 1.1]
    r = allocate(MyLongShortCDRule(), P(γ=γ, prices=[10.0, 20.0, 40.0, 25.0], β=β, β_max=0.3,
        hedge=[false, false, true, false], w_max=0.6))
    @test r.status == :optimal && r.n[3] > 0 && r.n[4] < 0
    @test dot(r.w, β) <= 0.3 + 1e-6
end

@testset "Stone–Geary baselines above the cap" begin                  # Review Focus 1
    r = allocate(build(MyStoneGearyRule, (baseline_frac=0.3,)), P(β=[1.0, 1.0, 1.0], β_max=0.5, n_prev=[1.0, 2.0, 3.0]))
    @test r.status == :infeasible && r.n == [1.0, 2.0, 3.0]
end

@testset "Stone–Geary with no γ > 0 keeps the β cap" begin
    sg = build(MyStoneGearyRule, (baseline_frac=0.1,))
    γ = [-0.2, -0.1, -0.3, -0.1]; β = [1.0, 1.0, 1.0, -0.8]; S = [10.0, 20.0, 40.0, 25.0]
    b = 0.1 * 1000 ./ S                                          # [10, 5, 2.5, 4] shares: Σwβ = 0.22 at b
    n_prev = [1.0, 2.0, 3.0, 4.0]
    # σ_g_max = Inf: the helper's far-slack 1e6 cone stalls Clarabel on this LP (SLOW_PROGRESS), and
    # the SCS fallback then meets the β row only to SCS's default tolerance (7e-5 over the cap)
    Q(; β_max=0.15, hedge=nothing, w_max=1.0) =
        P(γ=γ, prices=S, β=β, β_max=β_max, hedge=hedge, w_max=w_max, n_prev=n_prev, σ_g_max=Inf)
    # the hedge (name 4) is bought up to the least weight that meets the cap: 0.1 + 0.07/0.8
    r = allocate(sg, Q(hedge=[false, false, false, true]))
    @test r.status == :no_preferred && r.n[1:3] == b[1:3]
    @test dot(r.w, β) ≈ 0.15 atol=1e-6
    @test r.w[4] ≈ 0.1 + 0.07 / 0.8 atol=1e-6
    # no rescue (no hedge names, or a hedge capped below what the cap needs): previous holdings
    for q in (Q(), Q(hedge=[false, false, false, true], w_max=0.12))
        r = allocate(sg, q)
        @test r.status == :infeasible && r.n == n_prev
    end
    r = allocate(sg, Q(β_max=0.25))                               # baselines already meet the cap
    @test r.status == :no_preferred && r.n == b
end

@testset "CES η = 0.5 at W = 1e6 (budget only)" begin
    # the rescaled cone keeps CES η < 1 accurate at large share counts (unscaled: 22% share error)
    rng = MersenneTwister(5660); K = 33; W = 1e6
    γ = 0.05 .+ 0.2 .* rand(rng, K); S = 20.0 .+ 380.0 .* rand(rng, K)
    r = allocate(build(MyCESRule, (η=0.5,)), P(γ=γ, prices=S, W=W, σ_g_max=Inf))
    @test r.status == :optimal
    @test r.n ≈ W .* (γ ./ S) .^ 0.5 ./ sum(S .* (γ ./ S) .^ 0.5) rtol=1e-6
end

@testset "constraint-set validation" begin
    @test_throws DimensionMismatch build(MyConstraintSet, (w_max=0.1, s_max=1.0, σ_g_max=1.0, K_turnover=1.0,
        c̄=0.0, sector=["A", "B"], n_prev=[0.0, 0.0], β=[1.0]))
    @test_throws ArgumentError build(MyConstraintSet, (w_max=0.1, s_max=1.0, σ_g_max=1.0, K_turnover=1.0,
        c̄=0.0, sector=["A"], n_prev=[0.0], β_max=NaN))
end
