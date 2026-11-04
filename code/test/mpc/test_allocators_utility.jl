using Test, LinearAlgebra, JLD2, JuMP, Clarabel
include("helpers.jl")

@testset "utility rules reproduce closed forms (budget only)" begin
    γ = [0.2,0.5,0.3]; S = [10.,20.,40.]
    @test allocate(MyCobbDouglasRule(), P()).n .* S ≈ 1000 .* γ ./ sum(γ) rtol=1e-5
    @test allocate(build(MyCESRule,(η=2.0,)), P()).n ≈ 1000 .* (γ./S).^2 ./ sum(S .* (γ./S).^2) rtol=1e-5
    b = 0.01*1000 ./ S; R = 1000 - sum(b .* S)                         # fractional baselines
    # rtol 1e-4: with every baseline > 0 Clarabel stops at ALMOST_OPTIMAL (utility gap 2e-9, shares off by 5e-5)
    @test allocate(build(MyStoneGearyRule,(baseline_frac=0.01,)), P()).n ≈ b .+ (γ ./ sum(γ)) .* R ./ S rtol=1e-4
    r = allocate(MyCobbDouglasRule(), P())
    @test r.status == :optimal && r.w ≈ r.n .* S ./ 1000 && r.s_star ≈ sum(r.w)
    @test allocate(build(MyCESRule,(η=1.0,)), P()).n ≈ allocate(MyCobbDouglasRule(), P()).n rtol=1e-8
end

@testset "non-preferred names are pinned (ε for CD/CES, bᵢ for Stone–Geary)" begin
    # The pin's cost comes out of the budget: a 5-share floor at 20 USD leaves 900 USD to split.
    # rtol 1e-4: with a pinned name Clarabel stops at ALMOST_OPTIMAL (share error ~2e-6).
    γ = [0.2,-0.5,0.3]; S = [10.,20.,40.]
    r = allocate(MyCobbDouglasRule(), P(γ=γ, ε=5.0))
    @test r.n[2] == 5.0
    @test r.n[[1,3]] .* S[[1,3]] ≈ 900 .* [0.4, 0.6] rtol=1e-4
    @test allocate(MyCobbDouglasRule(), P(γ=γ)).n[2] == 1e-3
    @test allocate(build(MyCESRule,(η=2.0,)), P(γ=γ)).n[2] == 1e-3
    b = 0.01*10_000 ./ S; R = 10_000 - sum(b .* S)
    r = allocate(build(MyStoneGearyRule,(baseline_frac=0.01,)), P(γ=γ, W=10_000.0))
    @test r.n[2] == b[2]
    @test r.n[[1,3]] ≈ b[[1,3]] .+ [0.4, 0.6] .* R ./ S[[1,3]] rtol=1e-4
end

@testset "shared constraints bind" begin
    @test maximum(allocate(MyCobbDouglasRule(), P(w_max=0.4)).w) ≤ 0.4 + 1e-6
    r = allocate(MyCobbDouglasRule(), P(Σ_g=Diagonal([9.,16.,25.]), σ_g_max=1.5)); @test sqrt(r.w' * Diagonal([9.,16.,25.]) * r.w) ≤ 1.5 + 1e-6
    @test sum(allocate(MyCobbDouglasRule(), P(sector=["A","A","B"], s_max=0.5)).w[1:2]) ≤ 0.5 + 1e-6
    # turnover: unconstrained CD trades Σ|Δn| = 27.5 shares from n_prev = 10 each; budget allows 20
    n_prev = [10.,10.,10.]
    r = allocate(MyCobbDouglasRule(), P(c̄=1.0, K_turnover=20.0, n_prev=n_prev))
    @test r.status == :optimal
    @test sum(abs.(r.n .- n_prev)) ≈ 20.0 rtol=1e-5
    # σ and sector caps also bind for CES and Stone–Geary
    r = allocate(build(MyCESRule,(η=2.0,)), P(Σ_g=Diagonal([9.,16.,25.]), σ_g_max=1.5))
    @test sqrt(r.w' * Diagonal([9.,16.,25.]) * r.w) ≈ 1.5 rtol=1e-5
    r = allocate(build(MyStoneGearyRule,(baseline_frac=0.01,)), P(sector=["A","A","B"], s_max=0.5))
    @test sum(r.w[1:2]) ≈ 0.5 rtol=1e-5
end

@testset "all non-positive γ pins at ε" begin
    r = allocate(MyCobbDouglasRule(), P(γ=[-0.1,-0.2,-0.3])); @test r.status == :no_preferred && all(r.n .== 1e-3)
    r = allocate(build(MyCESRule,(η=2.0,)), P(γ=[-0.1,0.0,-0.3])); @test r.status == :no_preferred && all(r.n .== 1e-3)
    r = allocate(build(MyStoneGearyRule,(baseline_frac=0.01,)), P(γ=[-0.1,-0.2,-0.3], W=10_000.0))
    @test r.status == :no_preferred && r.n == 100 ./ [10.,20.,40.] && r.s_star ≈ sum(r.w)   # fractional: 2.5 shares at 40
    @test r.w ≈ [0.01, 0.01, 0.01]
end

@testset "infeasible keeps previous holdings" begin
    # infeasible keeps previous holdings
    r = allocate(build(MyStoneGearyRule,(baseline_frac=0.6,)), P(n_prev=[1.,2.,3.])); @test r.status == :infeasible && r.n == [1.,2.,3.]
    # baselines fit the budget but break the per-name cap: the solver reports infeasibility
    r = allocate(build(MyStoneGearyRule,(baseline_frac=0.3,)), P(w_max=0.2, n_prev=[1.,2.,3.]))
    @test r.status == :infeasible && r.n == [1.,2.,3.] && r.w ≈ [1.,2.,3.] .* [10.,20.,40.] ./ 1000
end

@testset "add_shared_constraints! homogenized (κ) form" begin
    # max Σw over y = κ·n with κ fixed at 2: dividing by κ must give the κ = 1 optimum
    function max_weight(p)
        m = Model(Clarabel.Optimizer); set_silent(m)
        @variable(m, y[1:3] >= 0); @variable(m, κ >= 0); @constraint(m, κ == 2.0)
        add_shared_constraints!(m, y, p; κ=κ)
        @objective(m, Max, sum(y .* p.prices) / p.W); optimize!(m)
        return value.(y) .* p.prices ./ (p.W * value(κ))
    end
    w = max_weight(P(w_max=0.3))                     # per-name caps bind: 3 × 0.3
    @test sum(w) ≈ 0.9 rtol=1e-6
    w = max_weight(P(σ_g_max=1.0))                   # Σ_g = 4I: 2‖w‖ ≤ 1 binds at w = 1/(2√3) each
    @test sum(w) ≈ sqrt(3) / 2 rtol=1e-6
end

@testset "reproduces the engine after unit conversion" begin
    # reproduces the engine after unit conversion (Σ_g = Σ_annual/Δt, σ_g_max = 0.12/√Δt)
    fx = JLD2.load(joinpath(@__DIR__, "fixtures", "engine_cd_case.jld2"))
    @test allocate(MyCobbDouglasRule(), problem_from_engine(fx)).n ≈ fx["n"] rtol=1e-4
    @test fx["engine_vol"] ≈ fx["σ_max"] rtol=1e-6          # the fixture's vol cap binds
end
