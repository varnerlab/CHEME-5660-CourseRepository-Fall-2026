using Dates, Random, LinearAlgebra, DataFrames, Statistics
# Synthetic market: 2014–2019 weekdays, 4 sectors × 12 names, β = 1, within-sector residual
# correlation ρ, SPY as the market factor. Growth units yr⁻¹: market SD 2.5, residual SD 4.
function synthetic_md(; ρ::Float64, seed::Int=5660)
    rng = MersenneTwister(seed)
    dates = filter(d -> dayofweek(d) <= 5, collect(Date(2014,1,1):Day(1):Date(2019,12,31)))
    n = length(dates); Δt = 1/252
    sectors = ["S$(s)" for s in 1:4 for _ in 1:12]
    gm = 2.5 .* randn(rng, n - 1)
    z = randn(rng, n - 1, 4); u = randn(rng, n - 1, 48)
    E = 4.0 .* [sqrt(ρ) * z[t, parse(Int, sectors[i][2:end])] + sqrt(1 - ρ) * u[t, i] for t in 1:n-1, i in 1:48]
    g = gm .+ E
    cl = 100 .* exp.(vcat(zeros(1, 48), cumsum(g .* Δt; dims=1)))
    spy = 100 .* exp.(vcat(0.0, cumsum(gm .* Δt)))
    return build(MyMarketData, (dates=dates, tickers=["T$(lpad(i,2,'0'))" for i in 1:48], open=cl, close=cl,
        volume=ones(n, 48), spy_open=spy, spy_close=spy, sector=sectors, g_f=zeros(n)))
end

# Double every price (tickers and SPY) strictly after date d; used as a look-ahead canary.
function perturb_after(md::MyMarketData, d::Date)
    k = md.dates .> d
    f = ifelse.(k, 2.0, 1.0)
    return build(MyMarketData, (dates=md.dates, tickers=md.tickers, open=md.open .* f, close=md.close .* f,
        volume=md.volume, spy_open=md.spy_open .* f, spy_close=md.spy_close .* f, sector=md.sector, g_f=md.g_f))
end

# Allocation problem for the allocator tests (Tasks 4 and 5). Defaults: 3 assets, γ = [0.2, 0.5, 0.3],
# prices [10, 20, 40] USD/share, W = 1000 USD, μ_g = 0.1 yr⁻¹, Σ_g = 4I yr⁻², g_f = 0, and every
# limit slack (w_max = s_max = 1, σ_g_max = 1e6 yr⁻¹, c̄ = 0, n_prev = 0), β = 0 with no β cap
# (β_max = Inf) and no hedge names. Per-asset defaults are sized from length(γ), so overriding γ
# changes the asset count; each name is its own sector.
function P(; γ=[0.2, 0.5, 0.3], prices=[10.0, 20.0, 40.0], W=1000.0, μ_g=nothing, Σ_g=nothing,
        g_f=0.0, w_max=1.0, s_max=1.0, σ_g_max=1e6, K_turnover=0.10 * W, c̄=0.0, sector=nothing,
        n_prev=nothing, ε=1e-3, β=nothing, β_max=Inf, hedge=nothing, w_cap=nothing)
    K = length(γ)
    cs = build(MyConstraintSet, (w_max=w_max, s_max=s_max, σ_g_max=σ_g_max, K_turnover=K_turnover,
        c̄=c̄, sector=something(sector, ["S$(i)" for i in 1:K]), n_prev=something(n_prev, zeros(K)), ε=ε,
        β=something(β, zeros(K)), β_max=β_max, w_cap=something(w_cap, fill(Float64(w_max), K))))
    return build(MyAllocationProblem, (γ=γ, μ_g=something(μ_g, fill(0.1, K)),
        Σ_g=something(Σ_g, 4.0 .* Matrix(I, K, K)), prices=prices, W=W, g_f=g_f, constraints=cs,
        hedge=something(hedge, fill(false, K))))
end

# 5-asset version of P (prices 10..50 USD/share).
P5(; γ=[0.3, 0.25, 0.2, 0.15, 0.1], prices=[10.0, 20.0, 30.0, 40.0, 50.0], kw...) = P(; γ=γ, prices=prices, kw...)

# Engine fixture (scripts/dev/make_engine_fixture.jl) → package problem. The engine's Σ is the
# annualized covariance Δt·Σ_g and its σ_max is annualized, so Σ_g = Σ/Δt and σ_g_max = σ_max/√Δt.
function problem_from_engine(fx::AbstractDict; Δt::Float64=1/252)
    K = length(fx["γ"])
    cs = build(MyConstraintSet, (w_max=fx["w_max"], s_max=1.0, σ_g_max=fx["σ_max"] / sqrt(Δt),
        K_turnover=fx["K_turnover"], c̄=fx["c̄"], sector=["E$(i)" for i in 1:K], n_prev=fx["n_prev"], ε=1e-3))
    return build(MyAllocationProblem, (γ=fx["γ"], μ_g=zeros(K), Σ_g=fx["Σ"] ./ Δt, prices=fx["p"],
        W=fx["B"], g_f=0.0, constraints=cs))
end

# ---- Backtest fixtures (Task 9; reused by Task 12) ----

# Prices after trading day k (an index into md.dates) doubled.
perturb_after(md::MyMarketData, k::Int) = perturb_after(md, md.dates[k])

# Synthetic market for the backtest tests: `n` weekdays from 2025-01-02, three stocks AAA/BBB/CCC
# (sectors S1, S2, S2) plus SPY, on deterministic geometric paths. log S = log S₀ + drift·t (t in yr)
# + βᵢ·(SPY wiggle) + own wiggle; the wiggles are sinusoids (no RNG) so growth rates vary from day to
# day, and AAA/BBB share a wiggle frequency (correlated SIM residuals for C2). Opens are the geometric
# midpoints of consecutive closes; volume varies by day around 2e4 shares/day (so ADV and impact
# matter); g_f varies by day around 0.04 yr⁻¹.
function bt_md(; n::Int=120, drift=[0.30, 0.15, -0.10], spy_drift=0.12, logS=nothing, logspy=nothing)
    dates = first(filter(d -> dayofweek(d) <= 5, collect(Date(2025,1,2):Day(1):Date(2027,12,31))), n)
    k = collect(0:n-1); t = k ./ 252
    spy_wig = 0.02 .* sin.(0.35 .* k)
    lspy = something(logspy, log(500.0) .+ spy_drift .* t .+ spy_wig)
    β = [1.0, 0.8, 1.2]; S0 = [50.0, 120.0, 80.0]; ω = [0.5, 0.5, 0.9]; φ = [0.3, 0.4, 1.7]
    L = something(logS, hcat([log(S0[i]) .+ drift[i] .* t .+ β[i] .* spy_wig .+ 0.015 .* sin.(ω[i] .* k .+ φ[i])
        for i in 1:3]...))
    cl = exp.(L); spy = exp.(lspy)
    op = vcat(cl[1:1, :], sqrt.(cl[1:end-1, :] .* cl[2:end, :]))
    spy_op = vcat(spy[1], sqrt.(spy[1:end-1] .* spy[2:end]))
    return build(MyMarketData, (dates=dates, tickers=["AAA", "BBB", "CCC"], open=op, close=cl,
        volume=[2e4 * (1 + 0.5 * sin(0.2 * i + j)) for i in 1:n, j in 1:3], spy_open=spy_op, spy_close=spy, sector=["S1", "S2", "S2"],
        g_f=[0.04 + 0.01 * sin(0.1 * i) for i in 1:n]))
end

# bt_md's market with a crash: gentle growth to day 40, then stocks and SPY fall 40% over days 41–45
# (geometrically), then stay flat.
function crash_md(; n::Int=120)
    lvl(i) = i <= 40 ? 0.0005 * i : (i <= 45 ? 0.02 + (i - 40) / 5 * log(0.6) : 0.02 + log(0.6))
    path = [lvl(i) for i in 1:n]
    S0 = [50.0, 120.0, 80.0]
    return bt_md(; n=n, logS=hcat([log(S0[j]) .+ path for j in 1:3]...), logspy=log(500.0) .+ path)
end

# Base SIM fit for bt_md's tickers (α yr⁻¹, β, σ_ε yr⁻¹); `α` overrides the intercepts.
function bt_base_sim(; α=[0.2, 0.05, -0.1])
    return Dict(t => build(MySIMParameterEstimate, (α=α[i], β=[1.0, 0.8, 1.2][i], σ_ε=[1.5, 2.0, 2.5][i], r²=0.5))
        for (i, t) in enumerate(["AAA", "BBB", "CCC"]))
end

# Run config on bt_md: CD, C1, w_max 0.4, trial σ_g_max, default MPC, start at day 21, stop at the
# last day, whole basket; keyword arguments override any field.
function bt_cfg(md::MyMarketData; kw...)
    defaults = (rule=MyCobbDouglasRule(), covariance=MySIMCovariance(), w_max=0.4, s_max=1.0,
        σ_g_max=0.12 * sqrt(252), mpc=MyMPCSpec(), start=md.dates[21], stop=md.dates[end], W0=100_000.0,
        seed=5660, basket_schedule=[md.dates[21] => copy(md.tickers)], forced_dates=Date[],
        natural_triggers=true, ewls_calendar=nothing, base_sim=bt_base_sim(), σ_m=2.0, σ_m_mode=:ewls,
        K_turnover_frac=0.10, borrow_rate=0.0075, label="bt")
    return build(MyRunConfig, merge(defaults, NamedTuple(kw)))
end

# Copy of a run config with some fields replaced.
with(cfg::MyRunConfig; kw...) =
    build(MyRunConfig, merge((; (f => getfield(cfg, f) for f in fieldnames(MyRunConfig))...), NamedTuple(kw)))

# Share positions (ticker => shares) after every trade dated on or before each of res.dates.
function positions_by_day(res)
    tr = res.trades; T = eltype(tr.qty)                 # Int (whole shares) or Float64 (the study's)
    pos = Dict{String,T}(); out = Vector{Dict{String,T}}(undef, length(res.dates)); k = 1
    for (t, d) in enumerate(res.dates)
        while k <= length(tr.date) && tr.date[k] <= d
            pos[tr.ticker[k]] = get(pos, tr.ticker[k], zero(T)) + tr.qty[k]; k += 1
        end
        out[t] = copy(pos)
    end
    return out
end

# Value (USD) of the positions rebuilt from res.trades, at each day's close.
function held_value(res, md::MyMarketData)
    col = Dict(t => j for (j, t) in enumerate(md.tickers))
    return [sum((n * md.close[index_of(md, d), col[tk]] for (tk, n) in pos); init=0.0)
        for (d, pos) in zip(res.dates, positions_by_day(res))]
end

# ---- Study fixtures (Task 10; reused by Task 11) ----

# Synthetic market for the study-loop tests: 2014–2019 weekdays, 4 sectors × 12 names with
# β = range(−0.6, 1.6; length=12) repeated per sector (names 1–3 of each sector have β < 0, name 4
# has β = 0), α = 0, residual SD 3 yr⁻¹, SPY growth N(0.1, 2.5²) yr⁻¹. Volume 1e6 shares/day,
# g_f = 0.04 yr⁻¹, opens at the geometric midpoints of consecutive closes (USD/share).
function study_md(; seed::Int=5660)
    rng = MersenneTwister(seed)
    dates = filter(d -> dayofweek(d) <= 5, collect(Date(2014,1,1):Day(1):Date(2019,12,31)))
    n = length(dates); Δt = 1/252
    sectors = ["S$(s)" for s in 1:4 for _ in 1:12]
    β = repeat(collect(range(-0.6, 1.6; length=12)), 4)
    gm = 0.1 .+ 2.5 .* randn(rng, n - 1)
    g = gm * β' .+ 3.0 .* randn(rng, n - 1, 48)
    cl = 100 .* exp.(vcat(zeros(1, 48), cumsum(g .* Δt; dims=1)))
    spy = 100 .* exp.(vcat(0.0, cumsum(gm .* Δt)))
    op = vcat(cl[1:1, :], sqrt.(cl[1:end-1, :] .* cl[2:end, :]))
    spy_op = vcat(spy[1], sqrt.(spy[1:end-1] .* spy[2:end]))
    return build(MyMarketData, (dates=dates, tickers=["T$(lpad(i,2,'0'))" for i in 1:48], open=op, close=cl,
        volume=fill(1e6, n, 48), spy_open=spy_op, spy_close=spy, sector=sectors, g_f=fill(0.04, n)))
end

# (md, ctx) for the study-loop tests: calibration from fit_base_sim on 2014-01-01 → 2017-12-29 with
# λ = 0.5; settings start = first trading day ≥ 2018-07-02, stop = 2018-12-31, that training window.
# `md` (default study_md()) is the market to build on; every other keyword overrides a setting.
function study_ctx(; md::Union{Nothing,MyMarketData}=nothing, kw...)
    md = something(md, study_md())
    tr0, tr1 = Date(2014, 1, 1), Date(2017, 12, 29)
    fit = fit_base_sim(md, tr0, tr1)
    calib = build(MyCalibration, (base_sim=fit.params, σ_m=fit.σ_m, m_m=fit.m_m, v_m=fit.v_m, λ=0.5,
        train_start=tr0, train_stop=tr1))
    start = md.dates[searchsortedfirst(md.dates, Date(2018, 7, 2))]
    s = build(MyStudySettings, merge((start=start, stop=Date(2018, 12, 31), train_start=tr0, train_stop=tr1),
        NamedTuple(kw)))
    return md, build_context(md, calib, s)
end

# One study run on ctx's settings.
study_run(ctx::MyStudyContext, allocator::String, screen::Symbol; seed::Int=5660) =
    build(MyStudyRun, (settings=ctx.settings, allocator=allocator, screen=screen, seed=seed))

# The 13 tickers of the user's fixed list stand in as the first 13 fixture tickers (deterministic).
md_tickers_13() = study_md().tickers[1:13]

# A hand-built `MyStudyResult` for the statistics tests: `dates`, `decisions` and `targets` as given,
# equity (USD) and ξ (dimensionless) per date; every other field is empty or zero, and the repicks hold
# one `:initial` row with basket ["A"].
function hand_result(; dates::Vector{Date}, equity=fill(1e5, length(dates)), xi=zeros(length(dates)),
        decisions::DataFrame, targets=Dict{Date,Dict{String,Float64}}())
    n = length(dates)
    return build(MyStudyResult, (dates=dates, equity=Float64.(equity), cash=zeros(n), borrow_fees=zeros(n),
        trades=DataFrame(date=Date[], ticker=String[], qty=Float64[], price=Float64[], cost=Float64[], scale=Float64[]),
        decisions=decisions,
        repicks=DataFrame(date=[dates[1]], trigger=[:initial], basket=[["A"]], pool=[String[]], shorts=[String[]],
            changed=[true]),
        daily=DataFrame(date=dates, xi=Float64.(xi), beta_max=fill(Inf, n), portfolio_beta=zeros(n),
            hedge_weight=zeros(n), pool_size=zeros(Int, n)),
        targets=targets, projections=Dict{Date,MyProjection}()))
end

# (The INFORMS toy_generator fixture is not ported: synthetic markets come from JumpHMM.jl; see test_synthetic.jl.)

