using Test, Dates, DataFrames, CSV, JLD2
# Write a tiny three-file dataset: AAA, GAP (missing 2025-01-06) and SPY.
# Timestamps carry different hours per ticker (AAA/GAP 04:00, SPY 05:00) so alignment must be by Date.
# Closes are distinct per day: AAA = 100 + dayofyear + 1000*(year-2014), SPY = AAA + 200.
function make_fixture(dir::String; dtb3::Bool=false)::String
    days = Dict(
        DATA_FILES[1] => [Date(2014,1,3), Date(2014,1,6), Date(2014,1,7)],
        DATA_FILES[2] => [Date(2025,1,2), Date(2025,1,3), Date(2025,1,6), Date(2025,1,7), Date(2025,1,8)],
        DATA_FILES[3] => [Date(2026,1,2), Date(2026,1,5), Date(2026,1,6)])
    for (file, ds) in days
        frame(ds, hour, bump) = DataFrame(
            open=fill(10.0, length(ds)),
            close=[100.0 + dayofyear(d) + 1000 * (year(d) - 2014) + bump for d in ds],
            volume=fill(1000.0, length(ds)),
            timestamp=DateTime.(ds) .+ Hour(hour))
        gap = filter(d -> d != Date(2025,1,6), ds)
        JLD2.save(joinpath(dir, file), "dataset",
                  Dict("AAA" => frame(ds, 4, 0.0), "GAP" => frame(gap, 4, 0.0), "SPY" => frame(ds, 5, 200.0)))
    end
    CSV.write(joinpath(dir, "sp500-sectors.csv"),
              DataFrame(Symbol=["AAA","GAP"], var"GICS Sector"=["Tech","Energy"]))
    if dtb3   # real FRED format: a holiday as an empty field; Jan 2 (no FRED row) and Jan 6 (empty) are gaps
        write(joinpath(dir, "DTB3.csv"),
              "observation_date,DTB3\n2024-12-31,4.2\n2025-01-03,4.0\n2025-01-06,\n2025-01-07,5.0\n")
    end
    return dir
end

# Three files with year-end boundaries next to each other (trading days are SPY's). True closes (newest basis):
# SPY 500·e^(0.002·i), SPL 100·e^(0.01·sin i), BIG 50 with a −0.6 log crash on 2025-06-03 (5× volume) and a
# −0.7 log gap at the open of 2026-01-02 on unchanged volume (no split signature), SPN 80 with a −1.2 log drop
# on 2025-06-03 (a spin-off-like move). Opens are the previous close × e^0.001. SPL's raw files hold their own
# split basis: a 2:1 split at the 2025 boundary and a 10:1 split at the 2026 boundary, so the 2014–2024 file
# quotes 20× and the 2025 file 10× the newest prices, with volume divided by the same factor.
const SPLIT_DAYS = [[Date(2024,12,26), Date(2024,12,27), Date(2024,12,30), Date(2024,12,31)],
    [Date(2025,1,2), Date(2025,1,3), Date(2025,6,2), Date(2025,6,3), Date(2025,12,30), Date(2025,12,31)],
    [Date(2026,1,2), Date(2026,1,5), Date(2026,1,6)]]
function split_truth()
    days = vcat(SPLIT_DAYS...); n = length(days); i = collect(1:n)
    jump(d0) = [d >= d0 ? 1.0 : 0.0 for d in days]
    cl = Dict("SPY" => 500 .* exp.(0.002 .* i), "SPL" => 100 .* exp.(0.01 .* sin.(i)),
        "BIG" => 50 .* exp.(-0.6 .* jump(Date(2025,6,3)) .- 0.7 .* jump(Date(2026,1,2))),
        "SPN" => 80 .* exp.(-1.2 .* jump(Date(2025,6,3))))
    op = Dict(t => vcat(c[1], c[1:end-1] .* exp(0.001)) for (t, c) in cl)
    op["BIG"][days .== Date(2026,1,2)] .= cl["BIG"][days .== Date(2026,1,2)]        # the gap is at the open
    vol = Dict(t => fill(1e6, n) for t in keys(cl)); vol["BIG"][days .== Date(2025,6,3)] .= 5e6
    return days, op, cl, vol
end
function make_split_fixture(dir::String)::String
    days, op, cl, vol = split_truth()
    basis = Dict("SPL" => [20.0, 10.0, 1.0])
    for (f, ds) in enumerate(SPLIT_DAYS)
        r = findall(in(ds), days)
        frame(t) = (b = get(basis, t, ones(3))[f];
            DataFrame(open=op[t][r] .* b, close=cl[t][r] .* b, volume=vol[t][r] ./ b, timestamp=DateTime.(ds) .+ Hour(4)))
        JLD2.save(joinpath(dir, DATA_FILES[f]), "dataset", Dict(t => frame(t) for t in keys(cl)))
    end
    CSV.write(joinpath(dir, "sp500-sectors.csv"),
              DataFrame(Symbol=["SPL", "BIG", "SPN"], var"GICS Sector"=["Tech", "Energy", "Utilities"]))
    return dir
end
load_sets(dir) = [JLD2.load(joinpath(dir, f))["dataset"] for f in DATA_FILES]

@testset "boundary split factor" begin
    @test boundary_split_factor(1000.0, 100.5, 1e3, 1.2e4, 0.002) == 10.0     # 10:1 split, volume ×12
    @test boundary_split_factor(30.0, 2.0, 1e5, 1.6e6, -0.003) == 15.0        # 15:1
    @test boundary_split_factor(10.0, 50.5, 1e6, 3.6e5, 0.001) == 0.2         # 1-for-5 reverse split
    @test boundary_split_factor(100.0, 4.0, 1e6, 3.8e7, 0.0) == 25.0          # 25:1 (BKNG, 2026-01-02)
    @test boundary_split_factor(100.0, 50.0, 1e6, 1e6, 0.0) == 1.0            # a halving on flat volume
    @test boundary_split_factor(100.0, 50.0, 1e6, 4e5, 0.0) == 1.0            # volume falls: no split signature
    @test boundary_split_factor(100.0, 50.0, 1e6, 2e6, 0.08) == 1.0           # SPY moved 8% overnight
    @test boundary_split_factor(76.25, 32.07, 1.2e6, 5.2e6, 0.006) == 1.0     # ratio 2.38 is no split ratio (DD)
    @test boundary_split_factor(100.0, 70.0, 1e6, 3e6, 0.0) == 1.0            # |log| = 0.36 is below the gate
end
@testset "split basis reconciled at the file boundaries" begin
    dir = make_split_fixture(mktempdir())
    days, op, cl, vol = split_truth()
    adj = split_adjustments(load_sets(dir), ["BIG", "SPL", "SPN"])
    @test adj == [(ticker="SPL", date=Date(2025,1,2), k=2.0), (ticker="SPL", date=Date(2026,1,2), k=10.0)]
    md = @test_logs((:info, r"SPL.*2025-01-02.*k = 2\.0"), (:info, r"SPL.*2026-01-02.*k = 10\.0"),
        (:warn, r"boundary.*BIG.*2026-01-02"), (:warn, r"SPN.*2025-06-03"), match_mode=:any,
        load_market_data(dir; start=days[1], stop=days[end]))
    @test md.dates == days && md.tickers == ["BIG", "SPL", "SPN"]
    j = 2
    for b in (Date(2025,1,2), Date(2026,1,2))                             # no boundary jump is left
        i = index_of(md, b)
        @test log(md.open[i, j] / md.close[i-1, j]) ≈ 0.001
    end
    @test md.close[:, j] ≈ cl["SPL"] && md.open[:, j] ≈ op["SPL"] && md.volume[:, j] ≈ vol["SPL"]
    raw = load_sets(dir)[1]["SPL"].close                                     # growth before the boundary
    @test growth_rates(md.close[1:4, j]) ≈ growth_rates(raw)
    @test md.close[end-2:end, j] == cl["SPL"][end-2:end]                     # the newest file is the basis
    big = [1, 3]                                                             # BIG and SPN are not touched
    @test md.close[:, big] == hcat(cl["BIG"], cl["SPN"]) && md.open[:, big] == hcat(op["BIG"], op["SPN"])
    @test md.volume[:, big] == hcat(vol["BIG"], vol["SPN"])
end
@testset "growth_rates" begin
    @test growth_rates([100.0, 101.0, 99.0]) ≈ 252 .* [log(1.01), log(99/101)]
end
@testset "universe excludes gappy ticker" begin
    md = @test_logs (:warn, r"DTB3") load_market_data(make_fixture(mktempdir()); start=Date(2025,1,2), stop=Date(2025,1,8))
    @test md.tickers == ["AAA"]
    @test !any(isnan, md.close) && all(md.g_f .== 0.04)
    @test md.sector == ["Tech"] && size(md.close) == (5, 1)
    @test index_of(md, Date(2025,1,3)) == 2
    @test_throws ArgumentError index_of(md, Date(2025,1,4))
end
@testset "dates align across tickers despite differing timestamp hours" begin
    md = load_market_data(make_fixture(mktempdir(); dtb3=true); start=Date(2025,1,2), stop=Date(2025,1,8))
    @test md.dates == [Date(2025,1,2), Date(2025,1,3), Date(2025,1,6), Date(2025,1,7), Date(2025,1,8)]
    @test md.close[:, 1] == 11000.0 .+ 100 .+ dayofyear.(md.dates)
    @test md.spy_close == md.close[:, 1] .+ 200.0
end
@testset "risk-free rate from DTB3" begin
    md = load_market_data(make_fixture(mktempdir(); dtb3=true); start=Date(2025,1,2), stop=Date(2025,1,8))
    # Day t takes the last observation dated before t (H.15 publishes day t's rate on day t+1); Jan 6 is
    # empty, so Jan 7 still takes Jan 3. A 91-day bill at bank discount d (ACT/360) grows at
    # −ln(1 − d·91/360)·365/91 per year.
    pct = [4.2, 4.2, 4.0, 4.0, 5.0]
    @test md.g_f ≈ -log.(1 .- pct ./ 100 .* 91 ./ 360) .* 365 ./ 91 rtol=1e-14
    @test md.g_f[1] ≈ 0.042811 atol=1e-6                                # log(1.042) = 0.041142 would be wrong
end
@testset "risk-free rate: no observation before a trading day is an error" begin
    dir = make_fixture(mktempdir(); dtb3=true)
    write(joinpath(dir, "DTB3.csv"), "observation_date,DTB3\n2025-01-02,4.0\n2025-01-03,4.0\n")
    # Jan 2 has no earlier observation: a later one must not be borrowed
    @test_throws ArgumentError load_market_data(dir; start=Date(2025,1,2), stop=Date(2025,1,8))
    @test load_market_data(dir; start=Date(2025,1,3), stop=Date(2025,1,8)).g_f[1] ≈ -log(1 - 0.04 * 91 / 360) * 365 / 91
end
@testset "real data" begin
    dir = joinpath(@__DIR__, "..", "..", "src", "data")   # the course data folder
    isfile(joinpath(dir, DATA_FILES[3])) || return
    md = load_market_data(dir; start=Date(2014,1,3), stop=Date(2026,9,4))
    @test md.dates[1] == Date(2014,1,3) && md.dates[end] == Date(2026,9,4)
    @test 360 ≤ length(md.tickers) ≤ 430 && "SPY" ∉ md.tickers
    @test Date(2025,7,4) ∉ md.dates && length(md.g_f) == length(md.dates)
    @test all(isfinite, md.open) && all(isfinite, md.close) && all(isfinite, md.volume)
    @test all(isfinite, md.spy_open) && all(isfinite, md.spy_close) && all(isfinite, md.g_f)
    @test issorted(md.dates; lt=<=)
    # split basis: the seven boundary splits in the universe are reconciled and no boundary jump is left
    adj = split_adjustments([JLD2.load(joinpath(dir, f))["dataset"] for f in DATA_FILES], md.tickers)
    @test Set((a.ticker, a.date, a.k) for a in adj) == Set([("FAST", Date(2025,1,2), 2.0), ("NFLX", Date(2025,1,2), 10.0),
        ("NOW", Date(2025,1,2), 5.0), ("ORLY", Date(2025,1,2), 15.0), ("APH", Date(2026,1,2), 2.0),
        ("KLAC", Date(2026,1,2), 10.0), ("MNST", Date(2026,1,2), 2.0)])
    for b in (Date(2025,1,2), Date(2026,1,2))
        i = index_of(md, b)
        @test maximum(abs.(log.(md.open[i, :] ./ md.close[i-1, :]))) < 0.4
    end
end
