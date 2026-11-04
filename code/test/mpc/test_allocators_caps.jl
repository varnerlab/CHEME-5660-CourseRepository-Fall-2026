using Test, LinearAlgebra
include("helpers.jl")
const RULES = (MyCobbDouglasRule(), build(MyCESRule, (η=0.5,)), build(MyCESRule, (η=2.0,)),
    build(MyStoneGearyRule, (baseline_frac=0.01,)), MyMinVarRule(), MyTangentRule(), MyLongShortCDRule())
@testset "default per-name caps are bit-identical" begin
    for rule in RULES
        a = allocate(rule, P(w_max=0.4, μ_g=[0.3, 0.2, 0.1]))
        b = allocate(rule, P(w_max=0.4, μ_g=[0.3, 0.2, 0.1], w_cap=[0.4, 0.4, 0.4]))
        @test a.n == b.n
        @test a.status == b.status
    end
end
@testset "a per-name cap binds on its own name" begin
    r = allocate(MyCobbDouglasRule(), P(w_max=1.0, w_cap=[1.0, 0.3, 1.0]))
    @test r.w[2] ≈ 0.3 rtol=1e-4
    @test r.w[[1, 3]] ≈ [0.28, 0.42] rtol=1e-4                   # the rest split 0.7 by γ (0.2 : 0.3)
    m = allocate(MyMinVarRule(), P(w_max=1.0, w_cap=[0.2, 1.0, 1.0]))
    @test m.w[1] <= 0.2 + 1e-6
    @test m.w[2:3] ≈ [0.4, 0.4] rtol=1e-4                       # Σ = 4I: equal weights where uncapped
    l = allocate(MyLongShortCDRule(), P5(γ=[0.5, 0.3, 0.2, -0.4, -0.1], w_max=0.6, w_cap=[0.6, 0.6, 0.6, 0.05, 0.6]))
    @test abs(l.w[4]) <= 0.05 + 1e-6
end
@testset "w_cap validation" begin
    base = (w_max=0.1, s_max=1.0, σ_g_max=1.0, K_turnover=1.0, c̄=0.0, sector=["A", "B"], n_prev=[0.0, 0.0])
    @test_throws DimensionMismatch build(MyConstraintSet, merge(base, (w_cap=[0.1],)))
    @test_throws ArgumentError build(MyConstraintSet, merge(base, (w_cap=[0.1, 0.0],)))
    @test build(MyConstraintSet, base).w_cap == [0.1, 0.1]
end
