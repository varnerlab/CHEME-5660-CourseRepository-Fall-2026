# The submodule's namespace and the course additions (default settings, universe selection).
@testset "namespace and course additions" begin

    # build is the course package's build, extended by the submodule's constructors
    @test MPCPortfolio.build === VLQuantitativeFinancePackage.build
    @test VLQuantitativeFinancePackage.MySIMParameterEstimate !== MPCPortfolio.MySIMParameterEstimate
    c = build(MPCPortfolio.MySIMParameterEstimate, (α = 0.1, β = 1.2, σ_ε = 0.3, r² = 0.4))
    @test c isa MPCPortfolio.MySIMParameterEstimate && c.β == 1.2

    # the default settings are the study's
    s = load_study(default_study_path()).settings
    @test s.T == 21 && s.D_max == 0.08 && s.w_max == 0.10 && s.basket_K == 13

    # universe selection: a synthetic market with 4 sectors × 12 names
    md = synthetic_md(; ρ = 0.3)
    @test select_universe(md, 1000) == md.tickers
    picked = select_universe(md, 10)
    @test length(picked) == 10 && picked == select_universe(md, 10)
    @test issubset(Set(md.sector), Set(md.sector[findfirst(==(t), md.tickers)] for t in picked))
    @test issorted([findfirst(==(t), md.tickers) for t in picked])
    @test_throws ArgumentError select_universe(md, 3)        # fewer names than sectors
    sub = subset_universe(md, picked)
    @test sub.tickers == picked && size(sub.close) == (length(md.dates), 10) && sub.spy_close == md.spy_close
    @test sub.sector == md.sector[[findfirst(==(t), md.tickers) for t in picked]]
    @test_throws ArgumentError subset_universe(md, ["NOPE"])
end
