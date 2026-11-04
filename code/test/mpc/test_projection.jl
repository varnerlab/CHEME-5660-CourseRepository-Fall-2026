using Test, Random, LinearAlgebra, Statistics
# One-step growth rates (yr⁻¹) from the GBM step: (Δt·μ + √Δt·L·Z)/Δt, LLᵀ = Δt·Σ.
function growth_step(μ, Σ, N, rng)
    Δt = 1/252; L = cholesky(Symmetric(Δt .* Σ)).L
    return (Δt .* μ .+ sqrt(Δt) .* (L * randn(rng, length(μ), N))) ./ Δt
end

# Exact lognormal moments of V_T = Σ nᵢSᵢ,T (cash = 0) under log-increment mean μ·t, covariance V.
function exact_moments(n, S, μ, Σ, T)
    Δt = 1/252; t = T*Δt; V = T*Δt^2 .* Σ; K = length(n)
    m = [S[i]*exp(μ[i]*t + V[i,i]/2) for i in 1:K]
    E2(i,j) = S[i]*S[j]*exp((μ[i]+μ[j])*t + (V[i,i]+V[j,j]+2V[i,j])/2)
    return sum(n .* m), sqrt(sum(n[i]*n[j]*(E2(i,j) - m[i]*m[j]) for i in 1:K, j in 1:K))
end

@testset "project_gbm" begin
    Δt = 1/252; Σg = [0.04/Δt;;]    # 20% annual vol
    p = project_gbm([10.0], [100.0], 0.0, [0.10], Σg, 0.0; T=21, N=200_000, rng=MersenneTwister(5660))
    m21 = 1000 * exp(0.10*21Δt + 0.5*0.04*21Δt); s21 = m21 * sqrt(exp(0.04*21Δt) - 1)
    @test length(p.μ) == 21 && length(p.σ) == 21
    @test isapprox(p.μ[21], m21; rtol=0.005) && isapprox(p.σ[21], s21; rtol=0.02)
    @test project_gbm([-10.0],[100.0],2000.0,[0.10],Σg,0.0; rng=MersenneTwister(1)).μ[21] ≈ 2000 - 1000*exp(0.10*21Δt + 0.5*0.04*21Δt) rtol=0.002
    a = project_gbm([1.,2.],[50.,60.],10.,[.1,.2],[9. 2; 2 16],.04; rng=MersenneTwister(7))
    b = project_gbm([1.,2.],[50.,60.],10.,[.1,.2],[9. 2; 2 16],.04; rng=MersenneTwister(7))
    @test a.μ == b.μ && a.σ == b.σ

    # cash-only: deterministic growth at g_f, zero spread
    c = project_gbm([0.0],[100.0],1000.0,[0.1],Σg,0.05; rng=MersenneTwister(2))
    @test c.μ[21] ≈ 1000*exp(0.05*21Δt) && c.σ[21] < 1e-6

    # growth-rate reproduction (spec 6a): one-step growth mean ≈ μ_g, covariance ≈ Σ_g
    Σ2 = [9. 2; 2 16]; μ2 = [0.1, 0.2]; N = 400_000
    g = growth_step(μ2, Σ2, N, MersenneTwister(11))
    @test vec(mean(g; dims=2)) ≈ μ2 atol=0.02
    @test cov(g; dims=2) ≈ Σ2 rtol=0.02

    # Correlated 2-asset case through project_gbm's own loop (asymmetric Σ_g, so a transposed L fails).
    # Sizing: N = 400_000 paths. Mean MC error = σ_exact/√N, so we use atol = 5·σ_exact/√N (5 SE).
    # Std MC relative error ≈ 1/√(2N) ≈ 0.11% (lognormal tails here are mild), so rtol = 0.01 is ~9 SE.
    # A transposed L changes Var(V_T) by tens of percent at this Σ_g, far outside rtol = 0.01.
    Σc = [4.0 3.0; 3.0 25.0]; S = [50.0, 120.0]; μc = [0.10, 0.25]; Nc = 400_000
    for n in ([1.0, -1.0], [1.0, 1.0]), T in (1, 21)
        pr = project_gbm(n, S, 0.0, μc, Σc, 0.0; T=T, N=Nc, rng=MersenneTwister(5660))
        m, s = exact_moments(n, S, μc, Σc, T)
        @test isapprox(pr.μ[T], m; atol=5*s/sqrt(Nc))
        @test isapprox(pr.σ[T], s; rtol=0.01)
    end
end
