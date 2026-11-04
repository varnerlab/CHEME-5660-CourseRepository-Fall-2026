using Test, LinearAlgebra, Random
include("helpers.jl")

# Growth Sharpe ratio eᵀw/√(wᵀΣw) (yr⁻¹ over yr⁻¹, dimensionless) and the signed CD utility in
# weights (log nᵢ = log|wᵢ| + log(W/Sᵢ), so comparing in weights shifts both sides by a constant).
_sharpe(w, e, Σ) = dot(e, w) / sqrt(w' * Σ * w)
_ls_utility(w, γ) = sum(abs(γ[i]) * log(abs(w[i])) for i in eachindex(γ) if γ[i] != 0)

# Initial weights 0.9 on name 1 with w_max = 0.5: reaching the cap means selling 40 shares, and the
# turnover budget (c̄ = 1 USD/share, K = 1 USD) allows one, so the shared set has no feasible point.
_P_stuck(γ) = P(γ=γ, w_max=0.5, c̄=1.0, K_turnover=1.0, n_prev=[90.0, 0.0, 0.0])

@testset "brief: max_investable, min-variance, tangent, 130/30 long-short" begin
    Σ2 = [4.0 1.0; 1.0 9.0]
    e = [0.12, 0.20] .- 0.04
    @test max_investable(P(w_max=0.15, γ=[0.5,0.5], prices=[10.,20.], Σ_g=Σ2)) ≈ 0.30 atol=1e-6
    # R24: with the vol cap binding, tangent keeps its mix and scales down; it no longer collapses to
    # min-variance. (The plan's `@test a ≈ b atol=… && c ≈ d atol=…` lines are split: one tolerance
    # keyword per @test is all the macro accepts.)
    rt = allocate(MyTangentRule(), P(Σ_g=Σ2, μ_g=[0.12,0.20], g_f=0.04, γ=[.5,.5], prices=[10.,20.], σ_g_max=1.5))
    @test rt.w ./ sum(rt.w) ≈ (Σ2\e) ./ sum(Σ2\e) atol=1e-5
    @test sqrt(rt.w' * Σ2 * rt.w) ≈ 1.5 atol=1e-6
    rm = allocate(MyMinVarRule(), P(Σ_g=Σ2, γ=[.5,.5], prices=[10.,20.], σ_g_max=1.5))
    @test rm.w ./ sum(rm.w) ≈ (Σ2 \ ones(2)) ./ sum(Σ2 \ ones(2)) atol=1e-5
    @test maximum(abs.(rt.w .- rm.w)) > 0.05
    w = allocate(MyMinVarRule(), P(Σ_g=Σ2, γ=[.5,.5], prices=[10.,20.])).w
    @test w ≈ (Σ2 \ ones(2)) ./ sum(Σ2 \ ones(2)) atol=1e-5
    @test allocate(build(MyTangentRule,(zero_alpha=false,)), P(Σ_g=Σ2, μ_g=[0.12,0.20], g_f=0.04, γ=[.5,.5], prices=[10.,20.])).w ≈ (Σ2\e) ./ sum(Σ2\e) atol=1e-5
    @test allocate(build(MyTangentRule,(zero_alpha=false,)), P(μ_g=fill(0.0,3), g_f=0.04)).status == :fallback_minvar
    r = allocate(MyLongShortCDRule(), P5(γ=[0.5,0.3,0.2,-0.4,-0.1], w_max=0.6))
    @test sum(max.(r.w,0)) ≤ 1.30+1e-6 && sum(-min.(r.w,0)) ≤ 0.30+1e-6 && sum(r.w) ≤ 1.0+1e-6
    @test all(r.w[1:3] .≥ -1e-9) && all(r.w[4:5] .≤ 1e-9)
    @test allocate(MyLongShortCDRule(), P()).status == :long_only_fallback
end

@testset "rule types: inner default constructors and build" begin
    r = MyLongShortCDRule()
    @test (r.long_cap, r.short_cap, r.net_cap) == (1.30, 0.30, 1.00)
    r = build(MyLongShortCDRule, (short_cap=0.2,))                  # overrides only what it is given
    @test (r.long_cap, r.short_cap, r.net_cap) == (1.30, 0.20, 1.00)
    @test_throws ArgumentError build(MyLongShortCDRule, (net_cap=1.2,))  # net > 1 would mean cash < 0
    @test_throws ArgumentError build(MyLongShortCDRule, (short_cap=-0.1,))
    @test MyTangentRule().zero_alpha == false
    @test build(MyTangentRule, (zero_alpha=true,)).zero_alpha == true
    @test build(MyTangentRule, NamedTuple()).zero_alpha == false
    @test build(MyMinVarRule, NamedTuple()) isa MyMinVarRule
end

@testset "expected_growth: α + β·ḡ_M, β·ḡ_M for the zero-α tangent" begin
    α = [0.10, -0.20, 0.05]; β = [1.0, 0.8, 1.2]; ḡ_M = 0.09
    for rule in (MyCobbDouglasRule(), MyMinVarRule(), MyLongShortCDRule(), MyTangentRule())
        @test expected_growth(rule, α, β, ḡ_M) ≈ α .+ β .* ḡ_M
    end
    @test expected_growth(build(MyTangentRule, (zero_alpha=true,)), α, β, ḡ_M) ≈ β .* ḡ_M
    @test_throws DimensionMismatch expected_growth(MyMinVarRule(), α, β[1:2], ḡ_M)
end

@testset "max_investable and the two-fund scale (R24)" begin
    @test max_investable(P()) ≈ 1.0 atol=1e-7                      # budget binds
    # Σ_g = 4I with σ_g_max = 1: 2‖w‖ ≤ 1. s_dir ignores the cone; vol_cap=true caps Σw at √3/2.
    p = P(σ_g_max=1.0)
    @test max_investable(p) ≈ 1.0 atol=1e-7
    @test max_investable(p; vol_cap=true) ≈ sqrt(3) / 2 atol=1e-6
    # min-variance: mix = equal weights at Σw = 1 (σ = 2/√3), scaled by c = √3/2 onto the cap
    r = allocate(MyMinVarRule(), p)
    @test r.status == :optimal
    @test r.w ≈ fill(1 / (2 * sqrt(3)), 3) atol=1e-6
    @test sqrt(r.w' * (4I) * r.w) ≈ 1.0 atol=1e-6
    @test r.s_star ≈ sum(r.w)
    # tangent: mix ∝ Σ⁻¹e = [1, 2, 3]/6 keeps its proportions, scaled by c = 3/√14 onto the cap
    r = allocate(MyTangentRule(), P(σ_g_max=1.0, μ_g=[0.1, 0.2, 0.3]))
    @test r.status == :optimal
    @test r.w ≈ [1.0, 2.0, 3.0] ./ (2 * sqrt(14)) atol=1e-6
    @test sqrt(r.w' * (4I) * r.w) ≈ 1.0 atol=1e-6
    @test r.s_star ≈ sum(r.w) && r.s_star < 1 - 0.1                  # the rest is cash
    # a slack cap leaves the mix unscaled (c = 1): fully invested
    @test sum(allocate(MyMinVarRule(), P(σ_g_max=1.2)).w) ≈ 1.0 atol=1e-6
    @test isnan(max_investable(_P_stuck([0.2, 0.5, 0.3])))           # no feasible point
    @test isnan(max_investable(_P_stuck([0.2, 0.5, 0.3]); vol_cap=true))
end

@testset "two-fund scale that breaks turnover keeps previous holdings (R24)" begin
    # n_prev is the equal-weight mix itself (zero turnover); scaling by c = √3/2 sells 7.8 shares,
    # and the budget (c̄ = 1 USD/share, K = 1 USD) allows one
    n_prev = (1 / 3) .* 1000 ./ [10.0, 20.0, 40.0]
    for rule in (MyMinVarRule(), MyTangentRule())
        r = allocate(rule, P(n_prev=n_prev, c̄=1.0, K_turnover=1.0, σ_g_max=1.0))
        @test r.status == :infeasible && r.n == n_prev
        r = allocate(rule, P(n_prev=n_prev, c̄=1.0, K_turnover=100.0, σ_g_max=1.0))
        @test r.status == :optimal
        @test r.w ≈ fill(1 / (2 * sqrt(3)), 3) atol=1e-6
    end
end

@testset "K = 33 regression: min-variance and tangent stay distinct under the production vol cap" begin
    # The reviewer's probe: forcing Σw to the vol-capped maximum left one feasible point, so the two
    # rules agreed to 1.9e-4. SIM Σ_g with σ_m = 2.5 and σ_ε ∈ [3, 6] yr⁻¹; trial limits.
    rng = MersenneTwister(5660); K = 33; W = 100_000.0; σ_max = 0.12 * sqrt(252)
    for draw in 1:5
        β = 0.6 .+ 0.8 .* rand(rng, K); σ_ε = 3.0 .+ 3.0 .* rand(rng, K)
        Σ = 2.5^2 .* β * β' .+ Diagonal(σ_ε .^ 2)
        μ = 0.04 .+ 0.3 .* randn(rng, K)                             # excess e = 0.3·N(0,1): ~half > 0
        prices = 20.0 .+ 380.0 .* rand(rng, K)
        sector = ["S$(mod1(i, 6))" for i in 1:K]
        n_prev = 0.6 .* W ./ (K .* prices)                             # 60% invested, equal weight
        c̄ = 5e-4 * sum(prices) / K
        p = P(γ=fill(0.1, K), prices=prices, W=W, μ_g=μ, Σ_g=Σ, g_f=0.04, w_max=0.15, s_max=0.35,
              sector=sector, σ_g_max=σ_max, c̄=c̄, K_turnover=0.10 * W, n_prev=n_prev)
        rm = allocate(MyMinVarRule(), p); rt = allocate(MyTangentRule(), p)
        @test rm.status == :optimal && rt.status == :optimal
        @test maximum(abs.(rt.w .- rm.w)) > 0.01
        for r in (rm, rt)
            @test all(r.w .≥ -1e-9) && all(r.w .≤ 0.15 + 1e-6) && sum(r.w) ≤ 1 + 1e-6
            @test sqrt(r.w' * Σ * r.w) ≤ σ_max + 1e-6
            @test all(sum(r.w[sector .== s]) ≤ 0.35 + 1e-6 for s in unique(sector))
            @test c̄ * sum(abs.(r.n .- n_prev)) ≤ 0.10 * W + 1e-6
        end
    end
end

@testset "min-variance: per-name cap, no ε pins" begin
    Σ2 = [4.0 1.0; 1.0 9.0]                                          # unconstrained [8/11, 3/11]
    r = allocate(MyMinVarRule(), P(Σ_g=Σ2, γ=[.5,.5], prices=[10.,20.], w_max=0.6))
    @test r.status == :optimal
    @test r.w ≈ [0.6, 0.4] atol=1e-5
    # γ plays no role: negative-γ names are free, not pinned at ε (Σ_g = 4I → equal weights)
    r = allocate(MyMinVarRule(), P(γ=[-0.2, 0.5, -0.3]))
    @test r.w ≈ fill(1/3, 3) atol=1e-5
end

@testset "tangent with a binding per-name cap" begin
    Σ3 = [4.0 1.0 0.5; 1.0 9.0 1.0; 0.5 1.0 16.0]
    μ = [0.30, 0.18, 0.20]; g_f = 0.04; e = μ .- g_f
    w_u = (Σ3 \ e) ./ sum(Σ3 \ e)                 # unconstrained tangent ≈ [0.80, 0.10, 0.10]
    @test all(w_u .> 0) && w_u[1] > 0.5
    r = allocate(MyTangentRule(), P(Σ_g=Σ3, μ_g=μ, g_f=g_f, w_max=0.5))
    @test r.status == :optimal
    # every constraint holds
    @test all(r.w .≥ -1e-9) && maximum(r.w) ≤ 0.5 + 1e-6
    @test sum(r.w) ≈ 1.0 atol=1e-6
    @test r.s_star ≈ 1.0 atol=1e-6
    @test r.w[1] ≈ 0.5 atol=1e-6                                     # the cap binds
    @test maximum(abs.(r.w .- w_u)) > 0.1                            # ≠ the unconstrained formula
    sr = _sharpe(r.w, e, Σ3)
    # Sharpe ≥ that of every feasible equal-weight portfolio (subsets of size k with 1/k ≤ w_max)
    for idx in ([1,2], [1,3], [2,3], [1,2,3])
        w_eq = zeros(3); w_eq[idx] .= 1 / length(idx)
        @test sr ≥ _sharpe(w_eq, e, Σ3)
    end
    # … and ≥ every point of a 0.0025 grid over the feasible set (grid optimum ≈ [0.5, 0.3025, 0.1975])
    best, arg = -Inf, Float64[]
    for w1 in 0:0.0025:0.5, w2 in 0:0.0025:0.5
        w = [w1, w2, 1 - w1 - w2]
        0 ≤ w[3] ≤ 0.5 + 1e-12 || continue
        s = _sharpe(w, e, Σ3)
        s > best && ((best, arg) = (s, w))
    end
    @test sr ≥ best - 1e-12
    @test maximum(abs.(r.w .- arg)) ≤ 0.005
end

@testset "tangent falls back to min-variance when no feasible point has positive excess growth" begin
    p = P(μ_g=fill(0.0, 3), g_f=0.04)                                # e < 0 for every name
    r = allocate(MyTangentRule(), p)
    @test r.status == :fallback_minvar
    @test r.w ≈ allocate(MyMinVarRule(), p).w atol=1e-6
    @test r.s_star ≈ 1.0 atol=1e-6
    # name 1 has e > 0, but the cap forces ≥ 0.5 into name 2 (e = −0.5): every feasible eᵀw < 0
    μ = [0.05, -0.46]
    r = allocate(MyTangentRule(), P(γ=[.5,.5], prices=[10.,20.], μ_g=μ, g_f=0.04, w_max=0.5))
    @test r.status == :fallback_minvar
    r = allocate(MyTangentRule(), P(γ=[.5,.5], prices=[10.,20.], μ_g=μ, g_f=0.04))   # w = [1, 0] is feasible
    @test r.status == :optimal
    @test r.w ≈ [1.0, 0.0] atol=1e-5
end

@testset "130/30 long-short CD" begin
    γ = [0.5, 0.3, 0.2, -0.4, -0.1]
    # caps only: long side 1.30 split .5/.3/.2 with name 1 capped at 0.6; short side 0.30 split .4/.1.
    # σ_g_max = Inf drops the volatility cone: the helper's far-slack 1e6 yr⁻¹ cone leaves Clarabel
    # at ALMOST_OPTIMAL here (weight error 8e-6, vs 1.5e-7 without it).
    r = allocate(MyLongShortCDRule(), P5(γ=γ, w_max=0.6, σ_g_max=Inf))
    @test r.status == :optimal
    @test r.w ≈ [0.6, 0.42, 0.28, -0.24, -0.06] atol=1e-6
    @test r.s_star ≈ sum(r.w)
    @test r.s_star ≈ 1.0 atol=1e-6
    @test r.w ≈ r.n .* [10., 20., 30., 40., 50.] ./ 1000
    # γ = 0 names are held at exactly zero
    r = allocate(MyLongShortCDRule(), P5(γ=[0.5, 0.0, 0.2, -0.4, -0.1], w_max=0.6))
    @test r.status == :optimal && r.n[2] == 0.0
    # a net cap below 1 adds its own row
    r = allocate(build(MyLongShortCDRule, (net_cap=0.8,)), P5(γ=γ, w_max=0.6))
    @test sum(r.w) ≤ 0.8 + 1e-6
    @test sum(r.w) ≈ 0.8 atol=1e-6
    # no γ > 0: all cash
    r = allocate(MyLongShortCDRule(), P5(γ=[-0.1, -0.2, 0.0, -0.3, -0.4]))
    @test r.status == :no_preferred && r.n == zeros(5) && r.s_star == 0.0
    # no γ < 0: long-only Cobb-Douglas, relabelled
    r = allocate(MyLongShortCDRule(), P()); cd = allocate(MyCobbDouglasRule(), P())
    @test r.status == :long_only_fallback && r.n == cd.n && r.s_star == cd.s_star
end

@testset "130/30 long-short CD with σ_g_max binding" begin
    γ = [0.5, 0.3, 0.2, -0.4, -0.1]
    β = [1.0, 0.9, 1.1, 1.2, 0.8]; Σ5 = 4.0 .* β * β' .+ Diagonal(fill(9.0, 5))   # SIM, yr⁻²
    w_u = [0.6, 0.42, 0.28, -0.24, -0.06]           # caps-only optimum: √(wᵀΣw) = 3.11 yr⁻¹
    σ_max = 2.0
    r = allocate(MyLongShortCDRule(), P5(γ=γ, w_max=0.6, Σ_g=Σ5, σ_g_max=σ_max))
    @test r.status == :optimal
    @test sqrt(r.w' * Σ5 * r.w) ≈ σ_max rtol=1e-5                   # the cap binds on signed w
    @test sum(max.(r.w, 0)) ≤ 1.30 + 1e-6 && sum(-min.(r.w, 0)) ≤ 0.30 + 1e-6 && sum(r.w) ≤ 1.0 + 1e-6
    @test all(abs.(r.w) .≤ 0.6 + 1e-6) && all(r.w[1:3] .> 0) && all(r.w[4:5] .< 0)
    # beats the feasible point that shrinks the caps-only optimum onto the cap
    w_s = w_u .* (σ_max / sqrt(w_u' * Σ5 * w_u))
    @test _ls_utility(r.w, γ) > _ls_utility(w_s, γ)
end

@testset "130/30 long-short CD caps the net, not gross, sector weight" begin
    # names 1 (long) and 4 (short) share sector A; the caps-only optimum nets A at 0.6 − 0.24 = 0.36
    γ = [0.5, 0.3, 0.2, -0.4, -0.1]; sector = ["A", "B", "C", "A", "D"]
    r = allocate(MyLongShortCDRule(), P5(γ=γ, w_max=0.6, sector=sector, s_max=0.3))
    @test r.status == :optimal
    @test r.w[1] + r.w[4] ≈ 0.3 atol=1e-6                            # net sector A binds at s_max
    @test abs(r.w[1]) + abs(r.w[4]) > 0.3 + 1e-2                     # gross exceeds it: a hedged pair
    @test all(abs(sum(r.w[sector .== s])) ≤ 0.3 + 1e-6 for s in unique(sector))
end

@testset "infeasible keeps previous holdings (min-variance, tangent, long-short)" begin
    n_prev = [90.0, 0.0, 0.0]
    for (rule, γ) in ((MyMinVarRule(), [0.2, 0.5, 0.3]), (MyTangentRule(), [0.2, 0.5, 0.3]),
                      (MyLongShortCDRule(), [0.5, 0.3, -0.2]),
                      (MyLongShortCDRule(), [0.2, 0.5, 0.3]))      # long-only fallback keeps the failure
        r = allocate(rule, _P_stuck(γ))
        @test r.status == :infeasible && r.n == n_prev
    end
end
