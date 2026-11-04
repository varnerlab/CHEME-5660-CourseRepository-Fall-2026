using Test, Statistics
const ema = MPCPortfolio.ema_series
@testset "market inputs" begin
    k = 1:600
    spy = 100 .* exp.(cumsum(0.01 .* sin.(0.05 .* k) .+ 0.0004))
    G = xi_gain(spy; short=21, long=63, q=0.99)
    r = abs.(ema(spy; span=21) ./ ema(spy; span=63) .- 1)[84:end]
    @test G ≈ 1 / quantile(r, 0.99)
    ξ = xi_series(spy; short=21, long=63, G=G)
    @test ξ ≈ -G .* (ema(spy; span=21) ./ ema(spy; span=63) .- 1)
    @test mean(abs.(ξ[84:end]) .<= 1 + 1e-12) >= 0.98   # q-quantile interpolates: 511 of 517 days, not 0.99 exactly
    g̃ = gtilde_series(spy; window=252)
    @test isnan(g̃[1]) && g̃[2:end] ≈ ema(growth_rates(spy); span=252)
    c = 100 .* exp.(0.15 .* (0:299) ./ 252)                         # constant growth 0.15 yr⁻¹
    @test all(isapprox.(gtilde_series(c)[2:end], 0.15; rtol=1e-9))
    # causal: a price change at day 400 leaves days 1..399 untouched
    p = copy(spy); p[400] *= 1.1
    @test xi_series(p; G=G)[1:399] == ξ[1:399] && xi_series(p; G=G)[400] != ξ[400]
    @test gtilde_series(p)[2:399] == g̃[2:399] && gtilde_series(p)[400] != g̃[400]
end

@testset "signed γ" begin
    α = [0.10, 0.05, 0.02, 0.03]; β = [1.3, 0.6, -0.5, 0.01]; g̃ = 0.15; ξ = 0.3
    γ = gamma_weights(α, β, g̃, ξ; β_floor=0.1)
    @test γ[1:2] ≈ tanh.(α[1:2] ./ β[1:2] .^ ξ .+ β[1:2] .^ (1 - ξ) .* g̃)   # L8b for β ≥ β_floor
    @test γ[3] ≈ tanh((0.02 - 0.5 * 0.15) / 0.5^0.3) && γ[3] < 0           # charged, not credited
    @test tanh(0.02 / 0.5^0.3 + 0.5^0.7 * 0.15) > 0                         # the trial's |β| form would prefer it
    @test γ[4] ≈ tanh((0.03 + 0.01 * 0.15) / 0.1^0.3)                       # β_floor
    @test all(isfinite, gamma_weights([0.1], [0.0], g̃, -0.7))
end
