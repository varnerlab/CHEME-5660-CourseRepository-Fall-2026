using Test, Dates, Random, LinearAlgebra, Statistics, JLD2
include("helpers.jl")

# ---- Method v2: the factor-model forecast (Task 4) ----

@testset "v2 forecast: projections carry a band" begin
    p = build(MyProjection, (μ=[1.0, 2.0], σ=[0.1, 0.2]))
    @test isempty(p.lo) && isempty(p.hi)
    q = build(MyProjection, (μ=[1.0, 2.0], σ=[0.1, 0.2], lo=[0.8, 1.6], hi=[1.2, 2.4]))
    @test q.lo == [0.8, 1.6] && q.hi == [1.2, 2.4]
    @test_throws ArgumentError build(MyProjection, (μ=[1.0, 2.0], σ=[0.1, 0.2], lo=[0.8], hi=[1.2]))
    # the trigger uses the quantile band when there is one, else μ ± z·σ
    spec = build(MyMPCSpec, (;))
    band = build(MyProjection, (μ=[100.0], σ=[1.0], lo=[90.0], hi=[95.0]))
    sigma = build(MyProjection, (μ=[100.0], σ=[1.0]))
    @test check_trigger(build(MyTriggerState, (τ=1, V_t=93.0, wealth_peak=93.0, projection=band)), spec) == :in_spec
    @test check_trigger(build(MyTriggerState, (τ=1, V_t=96.0, wealth_peak=96.0, projection=band)), spec) == :band_exit
    @test check_trigger(build(MyTriggerState, (τ=1, V_t=93.0, wealth_peak=93.0, projection=sigma)), spec) == :band_exit
    @test check_trigger(build(MyTriggerState, (τ=1, V_t=99.0, wealth_peak=99.0, projection=sigma)), spec) == :in_spec
end

@testset "v2 forecast: the Gaussian check against project_gbm" begin
    tickers = ["A", "B", "C"]; sector_index = [1, 1, 2]; ρ = [0.4, 0.2, 0.3]
    fm = stub_forecast_models(tickers, sector_index, ρ)
    n = [100.0, -50.0, 80.0]; S = [50.0, 40.0, 30.0]; n_spy = -20.0; spy = 300.0; cash = 10_000.0
    α = [0.05, -0.02, 0.1]; β = [1.2, 0.8, -0.3]; g̃ = 0.08; σ_M = 0.5; σ_res = [0.6, 0.8, 0.5]; g_f = 0.04
    N = 20_000
    f = project_factor(n, S, n_spy, spy, cash, α, β, g̃, σ_M, σ_res, tickers, fm, g_f; N=N, seed=11, band="quantile")
    # the same model as a multi-asset GBM: the names, then SPY as one more column
    K = 3
    Σ = zeros(K + 1, K + 1)
    for i in 1:K
        for j in 1:K
            Σ[i, j] = β[i] * β[j] * σ_M^2
            if sector_index[i] == sector_index[j]
                Σ[i, j] = Σ[i, j] + σ_res[i] * σ_res[j] * sqrt(ρ[i] * ρ[j])
            end
            if i == j
                Σ[i, j] = Σ[i, j] + σ_res[i]^2 * (1 - ρ[i])
            end
        end
        Σ[i, K + 1] = β[i] * σ_M^2
        Σ[K + 1, i] = β[i] * σ_M^2
    end
    Σ[K + 1, K + 1] = σ_M^2
    μ_g = vcat(α .+ β .* g̃, g̃)
    g = project_gbm(vcat(n, n_spy), vcat(S, spy), cash, μ_g, Σ, g_f; N=N, rng=MersenneTwister(12))
    # μ and σ within 3 Monte Carlo standard errors on every day
    for τ in 1:21
        @test abs(f.μ[τ] - g.μ[τ]) < 3 * sqrt(f.σ[τ]^2 + g.σ[τ]^2) / sqrt(N)
        @test abs(f.σ[τ] - g.σ[τ]) < 3 * g.σ[τ] / sqrt(N)
    end
    # the quantile band: μ ∓ 1.96σ within 3 standard errors (the quantile's and the target's)
    for τ in 1:21
        density = exp(-1.96^2 / 2) / sqrt(2π) / f.σ[τ]
        se_quantile = sqrt(0.025 * 0.975 / N) / density
        se_target = f.σ[τ] * sqrt(1 / N + 1.96^2 / (2 * N))
        tolerance = 3 * sqrt(se_quantile^2 + se_target^2)
        @test abs(f.lo[τ] - (f.μ[τ] - 1.96 * f.σ[τ])) < tolerance
        @test abs(f.hi[τ] - (f.μ[τ] + 1.96 * f.σ[τ])) < tolerance
    end
    # the sigma band keeps no quantiles; the same call twice is identical
    s = project_factor(n, S, n_spy, spy, cash, α, β, g̃, σ_M, σ_res, tickers, fm, g_f; N=N, seed=11, band="sigma")
    @test isempty(s.lo) && isempty(s.hi) && s.μ == f.μ && s.σ == f.σ
    @test_throws ArgumentError project_factor(n, S, n_spy, spy, cash, α, β, g̃, σ_M, σ_res, tickers, fm, g_f;
        N=100, seed=11, band="other")
end

@testset "v2 forecast: SPY, missing models and non-finite values" begin
    fm = stub_forecast_models(["A", "B"], [1, 2], [0.3, 0.3])
    # a book holding only a SPY short and cash: a higher market drift lowers the mean
    μ_T = Float64[]
    for g̃ in (-0.5, 0.0, 0.5)
        p = project_factor(Float64[], Float64[], -10.0, 300.0, 5000.0, Float64[], Float64[], g̃, 0.5, Float64[],
            String[], fm, 0.04; N=2000, seed=3, band="quantile")
        push!(μ_T, p.μ[end])
    end
    @test μ_T[1] > μ_T[2] > μ_T[3]
    # a ticker with no model
    err = nothing
    try
        project_factor([1.0, 1.0], [10.0, 10.0], 0.0, 300.0, 0.0, [0.0, 0.0], [1.0, 1.0], 0.0, 0.5, [0.5, 0.5],
            ["A", "ZZZ"], fm, 0.0; N=10, seed=1, band="quantile")
    catch e
        err = e
    end
    @test err isa ArgumentError && occursin("ZZZ", err.msg)
    # a path value that is not finite names the run seed and date
    err = nothing
    try
        project_factor([1e10], [1e300], 0.0, 300.0, 0.0, [0.0], [1.0], 0.0, 0.5, [0.5], ["A"], fm, 0.0;
            N=10, seed=1, band="quantile", label="run seed 5660, 2025-03-04")
    catch e
        err = e
    end
    @test err isa ArgumentError && occursin("5660", err.msg) && occursin("2025-03-04", err.msg)
end

@testset "v2 forecast: standardized draws of the fitted models have unit spread" begin
    path = joinpath(@__DIR__, "..", "..", "results", "synthetic", "forecast_models.jld2")
    if isfile(path) == false
        @info "skipped: run scripts/25_forecast_models.jl to write $(path)"
        @test_skip false
    else
        fm = JLD2.load(path, "forecast_models")
        # the market growth: σ_M·z_m has standard deviation σ_M when z_m has unit spread. The moments come from
        # one long draw, which includes jump episodes; forecast paths start outside them, so the market's spread
        # is about 2.5% low (0.975 measured on 2026-11-13), within 3%
        z = MPCPortfolio._standard_draws(fm.market, fm.m_market, fm.s_market, 1, 200_000, 99)
        @test abs(std(z) - 1) < 0.03 && abs(mean(z)) < 0.02
        # a name's residual: σ_res·(√ρ·z_sector + √(1−ρ)·z_name) has standard deviation σ_res
        for i in (1, 50, 100, 200, 300)
            s = fm.sector_index[i]
            zs = MPCPortfolio._standard_draws(fm.factors[s], fm.m_factor[s], fm.s_factor[s], 1, 200_000, 1000 + i)
            zn = MPCPortfolio._standard_draws(fm.names[i], fm.m_name[i], fm.s_name[i], 1, 200_000, 2000 + i)
            r = sqrt(fm.ρ[i]) .* zs .+ sqrt(1 - fm.ρ[i]) .* zn
            @test abs(std(r) - 1) < 0.03
        end
    end
end


@testset "course: the sector factor covariance" begin
    # three stocks: two in sector 1, one in sector 2, with sector shares 0.4, 0.9 and 0.5
    fm = stub_forecast_models(["A", "B", "C"], [1, 1, 2], [0.4, 0.9, 0.5])
    β = [1.2, 0.8, 1.0]
    σ_res = [0.30, 0.20, 0.25]
    σ_M = 0.17
    Σ = sector_factor_covariance(β, σ_res, σ_M, ["A", "B", "C"], fm)

    # the diagonal: market part plus residual variance
    for i in 1:3
        @test Σ[i, i] ≈ σ_M^2 * β[i]^2 + σ_res[i]^2
    end
    # the same sector: market part plus the sector part; across sectors: market part only
    @test Σ[1, 2] ≈ σ_M^2 * β[1] * β[2] + σ_res[1] * σ_res[2] * sqrt(0.4 * 0.9)
    @test Σ[1, 3] ≈ σ_M^2 * β[1] * β[3]
    @test Σ[2, 3] ≈ σ_M^2 * β[2] * β[3]
    @test Σ ≈ Σ'
    @test minimum(eigvals(Symmetric(Σ))) > 0

    # the order of the tickers follows the input, and an unknown ticker or a length mismatch is an error
    Σ_swap = sector_factor_covariance(β[[3, 1, 2]], σ_res[[3, 1, 2]], σ_M, ["C", "A", "B"], fm)
    @test Σ_swap ≈ Σ[[3, 1, 2], [3, 1, 2]]
    @test_throws ArgumentError sector_factor_covariance(β, σ_res, σ_M, ["A", "B", "Z"], fm)
    @test_throws ArgumentError sector_factor_covariance(β[1:2], σ_res, σ_M, ["A", "B", "C"], fm)
end

@testset "course: covariance_model setting" begin
    # the default is the shrunk residual covariance, and an unknown model is rejected
    @test MyStudySettings().covariance_model == "shrunk"
    @test load_study(default_study_path()).settings.covariance_model == "shrunk"
    @test_throws ArgumentError build(MyStudySettings, (covariance_model="nope",))

    # the sector factor covariance needs forecast models in the context
    md, ctx = study_ctx(; covariance_model="sector_factor", z=1e6, D_max=1.0)
    @test_throws ArgumentError run_study(ctx, study_run(ctx, "MinVar", :gamma))

    # with forecast models, minimum variance runs with both covariances, and the books differ
    fm = fixture_forecast_models(md)
    md, ctx_sf = study_ctx(; fm=fm, covariance_model="sector_factor", z=1e6, D_max=1.0)
    md, ctx_sh = study_ctx(; fm=fm, covariance_model="shrunk", z=1e6, D_max=1.0)
    res_sf = run_study(ctx_sf, study_run(ctx_sf, "MinVar", :gamma))
    res_sh = run_study(ctx_sh, study_run(ctx_sh, "MinVar", :gamma))
    d = first(sort(collect(keys(res_sf.targets))))
    @test res_sf.targets[d] != res_sh.targets[d]
    @test all(isfinite, res_sf.equity)
end
