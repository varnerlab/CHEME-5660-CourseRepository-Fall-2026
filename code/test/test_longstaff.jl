using Random, Statistics

@testset "Longstaff–Schwartz least-squares Monte Carlo" begin

    # Longstaff & Schwartz (2001), Section 1: eight paths, K = 1.10, r = 0.06, Δt = 1; American put 0.1144
    S = [1.00 1.09 1.08 1.34; 1.00 1.16 1.26 1.54; 1.00 1.22 1.07 1.03; 1.00 0.93 0.97 0.92;
         1.00 1.11 1.56 1.52; 1.00 0.76 0.77 0.90; 1.00 0.92 0.84 1.01; 1.00 0.88 1.22 1.34]
    put = build(MyAmericanPutContractModel, (K = 1.10, sense = 1))
    m = build(MyLongstaffSchwartzContractPricingModel, (S = S, r̄ = 0.06, Δt = 1.0))
    @test isapprox(premium(put, m), 0.1144; atol = 5e-5)

    # holding at every date gives the European Monte Carlo premium on the same paths
    hold = (intrinsic, continuation) -> continuation
    european = exp(-0.06*3) * mean(max.(1.10 .- S[:, end], 0.0))
    @test isapprox(premium(put, m; choice = hold), european; atol = 1e-12)

    # Table 1 of the paper: S₀ = 36, K = 40, r = 0.06, σ = 0.2, T = 1, 50 dates; finite difference 4.478
    rng = MersenneTwister(1234)
    S₀, K, r, σ, T, N, n = 36.0, 40.0, 0.06, 0.2, 1.0, 50, 50_000
    Δt = T/N
    Z = randn(rng, n ÷ 2, N); Z = vcat(Z, -Z)
    paths = hcat(fill(S₀, n), S₀ .* exp.(cumsum((r - σ^2/2)*Δt .+ σ*sqrt(Δt) .* Z, dims = 2)))
    mc = build(MyLongstaffSchwartzContractPricingModel, (S = paths, r̄ = r, Δt = Δt))
    american = premium(build(MyAmericanPutContractModel, (K = K, sense = 1)), mc)
    @test isapprox(american, 4.478; atol = 0.03)
    @test american > premium(build(MyAmericanPutContractModel, (K = K, sense = 1)), mc; choice = hold)

    # calls on a non-dividend share are never exercised early
    call = build(MyAmericanCallContractModel, (K = K, sense = 1))
    @test isapprox(premium(call, mc), premium(call, mc; choice = hold); atol = 1e-12)
end
