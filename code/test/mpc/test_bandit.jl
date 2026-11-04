using Test, Dates, Random, Statistics
include("helpers.jl")

# Market data from closes (days × tickers, USD/share) and SPY closes, on consecutive weekdays from
# 2020-01-01; opens equal closes, tickers N01, N02, …
function mini_md(close::Matrix{Float64}, spy::Vector{Float64}; sector=fill("S1", size(close, 2)))
    n, m = size(close)
    dates = first(filter(d -> dayofweek(d) <= 5, collect(Date(2020,1,1):Day(1):Date(2035,12,31))), n)
    return build(MyMarketData, (dates=dates, tickers=["N$(lpad(j, 2, '0'))" for j in 1:m], open=close, close=close,
        volume=ones(n, m), spy_open=spy, spy_close=spy, sector=sector, g_f=zeros(n)))
end

# Geometric path over `n` days with gross return G between day 1 and day 22 (USD/share, starts at 100).
gpath(G::Real, n::Int=22) = [100.0 * G^((t - 1) / 21) for t in 1:n]

# Names of sector `s` in `basket` that are not in `next`.
swapped(basket, next, sector_of, s) = count(t -> sector_of[t] == s && t ∉ next, basket)

@testset "bandit: assign_quotas" begin
    sizes = Dict("A"=>70, "B"=>60, "C"=>50, "D"=>40, "E"=>30, "F"=>25, "G"=>22, "H"=>20, "I"=>31, "J"=>28, "tiny"=>2)
    groups = Dict(s => collect(1:n) for (s, n) in sizes)
    q = assign_quotas(groups, 33)
    @test sum(values(q)) == 33
    @test keys(q) == keys(groups)
    @test q["tiny"] == 3                       # uncapped (engine port): the basket takes all 2 names
    # Remainder goes to the largest sectors: base 10 ÷ 4 = 2, two bonus seats.
    q4 = assign_quotas(Dict("W"=>collect(1:10), "X"=>collect(1:8), "Y"=>collect(1:6), "Z"=>collect(1:4)), 10)
    @test q4 == Dict("W"=>3, "X"=>3, "Y"=>2, "Z"=>2)
    # Ties in sector size are broken by sector name (deterministic, independent of Dict order).
    @test assign_quotas(Dict("B"=>collect(1:5), "A"=>collect(1:5), "C"=>collect(1:5)), 4) == Dict("A"=>2, "B"=>1, "C"=>1)
end

@testset "bandit: random_sector_basket meets quotas" begin
    m = 22; n = 30
    sector = vcat(fill("S1", 10), fill("S2", 10), fill("S3", 2))
    md = mini_md(repeat(gpath(1.0, n), 1, m), gpath(1.0, n); sector=sector)
    sector_of = Dict(zip(md.tickers, md.sector))
    b = random_sector_basket(md, 9; seed=11)
    @test issorted(b) && allunique(b) && issubset(b, md.tickers)
    @test [count(t -> sector_of[t] == s, b) for s in ["S1", "S2", "S3"]] == [3, 3, 2]   # S3 smaller than its quota
    @test issubset(md.tickers[21:22], b)
    @test random_sector_basket(md, 9; seed=11) == b
    @test any(random_sector_basket(md, 9; seed=s) != b for s in 12:20)
end

@testset "bandit: beat_spy_reward" begin
    up = gpath(1.05); flat1 = gpath(1.01)
    one2 = ones(2); z = zeros(22)
    # Arm gains 5%, SPY 1% → 1; reversed → 0.
    @test beat_spy_reward([1, 2], 1, mini_md(hcat(up, up), flat1), one2, one2, z, z) == 1
    @test beat_spy_reward([1, 2], 1, mini_md(hcat(flat1, flat1), up), one2, one2, z, z) == 0
    @test beat_spy_reward([1, 2], 1, mini_md(hcat(up, up), flat1), one2, one2, z, z) isa Int
    # A γ ≤ 0 name gets no shares: the −50% name does not drag the γ > 0 name below SPY.
    md = mini_md(hcat(up, gpath(0.5)), flat1)
    @test beat_spy_reward([1, 2], 1, md, [1.0, -1.0], one2, z, z) == 1
    # No γ > 0 → cash (log return 0): wins only when SPY falls.
    @test beat_spy_reward([1, 2], 1, mini_md(hcat(up, up), gpath(0.99)), [-1.0, -1.0], one2, z, z) == 1
    @test beat_spy_reward([1, 2], 1, mini_md(hcat(up, up), gpath(1.01)), [-1.0, -1.0], one2, z, z) == 0
    # Closed-form CD weights γᵢ/Σγ on gross returns (β = 1, λ = 0, g_m = 0 → γ = tanh α):
    # (tanh 0.5·1.10 + tanh 1.5·0.95)/(tanh 0.5 + tanh 1.5) ≈ 1.0007. Equal weights would give 1.025,
    # and γ-weighted log returns would give ≈ 0.9983.
    α = [0.5, 1.5]; closes = hcat(gpath(1.10), gpath(0.95))
    @test beat_spy_reward([1, 2], 1, mini_md(closes, gpath(1.003)), α, one2, z, z) == 0
    @test beat_spy_reward([1, 2], 1, mini_md(closes, gpath(0.999)), α, one2, z, z) == 1
    # γ uses g_m and λ at `day`: λ = 1, g_m = −10 yr⁻¹ turns tanh(1/1 + 1·(−10)) negative → cash.
    @test beat_spy_reward([1, 2], 1, mini_md(hcat(up, up), gpath(1.01)), one2, one2, fill(-10.0, 22), ones(22)) == 0
    # horizon keyword: the name is flat to day 11 and doubles after, SPY is flat.
    jump = mini_md(reshape(vcat(fill(100.0, 11), fill(200.0, 11)), :, 1), gpath(1.0))
    @test beat_spy_reward([1], 1, jump, [1.0], [1.0], z, z; horizon=10) == 0
    @test beat_spy_reward([1], 1, jump, [1.0], [1.0], z, z) == 1
end

@testset "bandit: train_sector_bandit" begin
    rng = MersenneTwister(5660); n = 400
    # Two names drift +60%/yr and four −60%/yr around a flat SPY; daily noise 1%.
    drift = [0.6, -0.6, 0.6, -0.6, -0.6, -0.6]
    L = hcat([log(100.0) .+ drift[j] .* (0:n-1) ./ 252 .+ cumsum(0.01 .* randn(rng, n)) for j in 1:6]...)
    spy = 100.0 .* exp.(cumsum(0.005 .* randn(rng, n)))
    md = mini_md(exp.(L), spy)
    one6 = ones(6); z = zeros(n)
    for s in 1:5
        r = train_sector_bandit(collect(1:6), 2, 1:(n - 22), md, one6, one6, z, z; seed=s)
        @test r.best_arm == [1, 3]                  # the subset that beats SPY most often
        @test r.wins + r.losses >= 1
        @test 1 <= r.n_unique <= 15                  # binomial(6, 2) arms
    end
    # The returned arm is the best of the pull record by Beta(1+w, 1+l) mean (ties: more pulls), and
    # the record holds clamp(50·n_arms, 500, 5000) pulls: 750 here, 5,000 for 48 names.
    # A third case, three coin-flip names (each tracks SPY plus noise), keeps the incumbent contested.
    bmean(x) = (1 + x[1]) // (2 + x[1] + x[2])
    coin = mini_md(spy .* exp.(0.02 .* randn(MersenneTwister(1), n, 3)), spy)
    for (cols, q, mdx, iters) in ((collect(1:6), 2, md, 750), (collect(1:48), 3, nothing, 5000), (collect(1:3), 1, coin, 500)), s in 1:3
        mdx === nothing && (mdx = mini_md(repeat(exp.(L[:, 1:1]), 1, 48) .* exp.(0.02 .* randn(MersenneTwister(s), n, 48)), spy))
        best, rec = MPCPortfolio._run_sector_bandit(cols, q, 1:(n - 22), mdx, ones(length(cols)), ones(length(cols)), z, z; seed=s)
        top = maximum(bmean, values(rec))
        @test bmean(rec[best]) == top
        @test rec[best][1] + rec[best][2] == maximum(x[1] + x[2] for x in values(rec) if bmean(x) == top)
        @test sum(x[1] + x[2] for x in values(rec)) == iters
        r = train_sector_bandit(cols, q, 1:(n - 22), mdx, ones(length(cols)), ones(length(cols)), z, z; seed=s)
        @test (r.best_arm, r.wins, r.losses, r.n_unique) == (best, rec[best][1], rec[best][2], length(rec))
    end
    # Arm order: Beta mean (10/12 beats 2/3 although the raw win rate 0.9 < 1), then pulls, then first pull.
    key = MPCPortfolio._arm_key
    @test key((9, 1, 5)) > key((1, 0, 1))
    @test key((3, 1, 9)) > key((1, 0, 1))        # both 2/3: more pulls wins
    @test key((1, 0, 2)) > key((1, 0, 7))        # same record: earlier first pull wins
    r1 = train_sector_bandit(collect(1:6), 2, 1:(n - 22), md, one6, one6, z, z; seed=9)
    @test r1 == train_sector_bandit(collect(1:6), 2, 1:(n - 22), md, one6, one6, z, z; seed=9)
    # Quota ≥ sector size: the only arm is the whole sector, pulled clamp(50·1, 500, 5000) = 500 times.
    r2 = train_sector_bandit([2, 5], 3, 1:(n - 22), md, one6, one6, z, z; seed=1)
    @test r2.best_arm == [2, 5] && r2.wins + r2.losses == 500 && r2.n_unique == 1
    # 48 names, q = 3: binomial(48, 3) = 17,296 arms → 5,000 pulls, ε = 1 throughout → ≈ 4,343 distinct arms.
    big = mini_md(repeat(exp.(L[:, 1:1]), 1, 48), spy)
    r3 = train_sector_bandit(collect(1:48), 3, 1:(n - 22), big, ones(48), ones(48), z, z; seed=2)
    @test 4_000 < r3.n_unique <= 5_000
    @test issorted(r3.best_arm) && length(r3.best_arm) == 3
end

@testset "bandit: quarter_starts" begin
    md = synthetic_md(ρ=0.0)
    @test quarter_starts(md, Date(2015,1,1), Date(2015,12,31)) == [Date(2015,1,1), Date(2015,4,1), Date(2015,7,1), Date(2015,10,1)]
    @test quarter_starts(md, Date(2015,2,10), Date(2015,8,1)) == [Date(2015,4,1), Date(2015,7,1)]
    @test quarter_starts(md, Date(2017,3,1), Date(2017,6,30)) == [Date(2017,4,3)]     # 2017-04-01 is a Saturday
end

@testset "bandit: bandit_basket_schedule" begin
    md = synthetic_md(ρ=0.3)
    sector_of = Dict(zip(md.tickers, md.sector))
    R = Date(2018,4,2); iR = index_of(md, R)
    s0 = bandit_basket_schedule(md, [R]; K=12, seed=7)
    @test length(s0) == 1 && first(s0[1]) == R
    b = last(s0[1])
    @test issorted(b) && allunique(b) && length(b) == 12
    @test all(count(t -> sector_of[t] == s, b) == 3 for s in ["S1", "S2", "S3", "S4"])
    @test bandit_basket_schedule(md, [R]; K=12, seed=7) == s0
    @test any(bandit_basket_schedule(md, [R]; K=12, seed=s) != s0 for s in 8:10)

    # Causality: doubling every price on or after R leaves the schedule unchanged …
    @test bandit_basket_schedule(perturb_after(md, iR - 1), [R]; K=12, seed=7) == s0
    # … as does replacing every path on or after R with fresh noise (each ticker and SPY on its own) …
    noisy(k) = begin
        rng = MersenneTwister(99); f = ones(length(md.dates), length(md.tickers) + 1)
        f[k:end, :] .= exp.(0.3 .* randn(rng, length(md.dates) - k + 1, length(md.tickers) + 1))
        build(MyMarketData, (dates=md.dates, tickers=md.tickers, open=md.open .* f[:, 1:end-1],
            close=md.close .* f[:, 1:end-1], volume=md.volume, spy_open=md.spy_open .* f[:, end],
            spy_close=md.spy_close .* f[:, end], sector=md.sector, g_f=md.g_f))
    end
    @test bandit_basket_schedule(noisy(iR), [R]; K=12, seed=7) == s0
    # … while the same noise inside the training window changes it (the test can fail).
    @test bandit_basket_schedule(noisy(iR - 200), [R]; K=12, seed=7) != s0

    # Each sector has its own RNG stream: in a market whose sector S2 is a copy of S1, the two
    # sectors' bandits pick different positions.
    twin = build(MyMarketData, (dates=md.dates, tickers=md.tickers[1:24], open=md.open[:, vcat(1:12, 1:12)],
        close=md.close[:, vcat(1:12, 1:12)], volume=md.volume[:, 1:24], spy_open=md.spy_open,
        spy_close=md.spy_close, sector=md.sector[1:24], g_f=md.g_f))
    picks(sd) = (b = last(bandit_basket_schedule(twin, [R]; K=6, seed=sd)[1]);
        pos = [findfirst(==(t), twin.tickers) for t in b]; (sort(pos[pos .<= 12]), sort(pos[pos .> 12] .- 12)))
    @test any(p[1] != p[2] for p in picks.(1:3))

    # Seeds are keyed on the retrain date, so a quarter's basket does not depend on the other dates.
    Rs = quarter_starts(md, Date(2018,1,1), Date(2019,12,31))
    sch = bandit_basket_schedule(md, Rs; K=12, seed=7)
    @test first.(sch) == Rs
    @test sch[findfirst(==(R), Rs)] == s0[1]
    @test_throws ArgumentError bandit_basket_schedule(md, [Rs[2], Rs[1]]; K=12, seed=7)
    @test bandit_basket_schedule(md, Date[]; seed=7) == Pair{Date,Vector{String}}[]
    # K below the sector count: quotas of 0 contribute no names (3 sectors get 1, one gets 0).
    @test length(last(bandit_basket_schedule(md, [R]; K=3, seed=7)[1])) == 3
    @test length(random_sector_basket(md, 3; seed=7)) == 3
    @test any(last(sch[k]) != last(sch[k + 1]) for k in 1:length(sch) - 1)
end

@testset "bandit: random_matched_schedule" begin
    md = synthetic_md(ρ=0.3)
    sector_of = Dict(zip(md.tickers, md.sector))
    sectors = ["S1", "S2", "S3", "S4"]
    # Hand-made bandit schedule: per-sector swaps (0, 1, 2, 3) then (3, 0, 1, 2).
    d = [Date(2018,1,2), Date(2018,4,2), Date(2018,7,2)]
    b1 = ["T01","T02","T03", "T13","T14","T15", "T25","T26","T27", "T37","T38","T39"]
    b2 = ["T01","T02","T03", "T13","T14","T16", "T25","T28","T29", "T40","T41","T42"]
    b3 = ["T04","T05","T06", "T13","T14","T16", "T25","T28","T30", "T40","T43","T44"]
    hand = [d[1] => b1, d[2] => b2, d[3] => b3]
    bsched = bandit_basket_schedule(md, quarter_starts(md, Date(2018,1,1), Date(2019,12,31)); K=12, seed=7)
    for bandit in (hand, bsched)
        rnd = random_matched_schedule(bandit, md; seed=3)
        @test first.(rnd) == first.(bandit)
        @test last(rnd[1]) == random_sector_basket(md, 12; seed=3)
        for k in eachindex(rnd)
            r = last(rnd[k])
            @test issorted(r) && allunique(r)
            @test all(count(t -> sector_of[t] == s, r) == 3 for s in sectors)
        end
        for k in 1:length(rnd) - 1, s in sectors
            @test swapped(last(rnd[k]), last(rnd[k + 1]), sector_of, s) ==
                  swapped(last(bandit[k]), last(bandit[k + 1]), sector_of, s)
        end
        @test random_matched_schedule(bandit, md; seed=3) == rnd
        @test random_matched_schedule(bandit, md; seed=4) != rnd
    end
    @test random_matched_schedule(Pair{Date,Vector{String}}[], md; seed=3) == Pair{Date,Vector{String}}[]
    @test_throws ArgumentError random_matched_schedule([d[1] => vcat(b1[1:11], "T04")], md; seed=3)   # S1 has 4, S4 has 2
    @test [swapped(b1, b2, sector_of, s) for s in sectors] == [0, 1, 2, 3]
    @test [swapped(b2, b3, sector_of, s) for s in sectors] == [3, 0, 1, 2]
end
