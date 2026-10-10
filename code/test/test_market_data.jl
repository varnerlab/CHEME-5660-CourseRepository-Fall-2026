using Test
using VLQuantitativeFinancePackage
using DataFrames
using Dates

@testset "frozen testing market data" begin
    default_data = MyTestingMarketDataSet()["dataset"]
    explicit_2025 = MyTestingMarketDataSet(year = 2025)["dataset"]
    @test isequal(default_data, explicit_2025)
    @test_throws ArgumentError MyTestingMarketDataSet(year = 2024)
    @test_throws ArgumentError MyTestingMarketDataSet(year = 2027)

    columns = ["volume", "volume_weighted_average_price", "open", "close",
        "high", "low", "timestamp", "number_of_transactions"]
    snapshots = [
        (year = 2025, stop = Date(2025, 12, 31), tickers = 483, days = 250, complete = 473),
        (year = 2026, stop = Date(2026, 9, 4), tickers = 475, days = 170, complete = 465),
    ]

    for snapshot in snapshots
        @testset "$(snapshot.year) snapshot" begin
            loaded = MyTestingMarketDataSet(year = snapshot.year)
            @test loaded isa Dict{String,Any}
            data = loaded["dataset"]
            @test data isa Dict{String,DataFrame}
            @test length(data) == snapshot.tickers
            @test all(haskey(data, ticker) for ticker in ["AAPL", "SPY", "NVDA", "GLD"])
            @test all(names(df) == columns for df in values(data))
            @test all(0 < nrow(df) <= snapshot.days for df in values(data))
            @test count(df -> nrow(df) == snapshot.days, values(data)) == snapshot.complete

            # Check calendar bounds, ordering, and usable prices for every ticker -
            start = Date(snapshot.year, 1, 2)
            @test all(all(t -> start <= Date(t) <= snapshot.stop, df.timestamp) for df in values(data))
            @test all(issorted(df.timestamp) && allunique(Date.(df.timestamp)) for df in values(data))
            @test all(all(!ismissing, column) for df in values(data) for column in eachcol(df))
            @test all(all(p -> isfinite(p) && p > 0, df[!, column])
                for df in values(data) for column in ["open", "high", "low", "close", "volume_weighted_average_price"])

            # Complete histories must align with the reference ticker's dates -
            reference_dates = Date.(data["AAPL"].timestamp)
            @test length(reference_dates) == snapshot.days
            @test first(reference_dates) == start
            @test last(reference_dates) == snapshot.stop
            @test all(Date.(df.timestamp) == reference_dates
                for df in values(data) if nrow(df) == snapshot.days)
        end
    end
end

@testset "end-of-day options archive" begin
    underlying = MyOptionsEODUnderlyingDataSet()
    @test names(underlying) == ["ticker", "date", "capture_ts", "open", "high", "low", "close", "iex_volume", "iex_vwap"]
    @test length(unique(underlying.ticker)) == 31
    @test length(unique(underlying.date)) == 115
    @test extrema(underlying.date) == (Date(2026, 4, 13), Date(2026, 10, 8))
    @test !any(nonunique(underlying, [:ticker, :date]))
    @test all(p -> isfinite(p) && p > 0, underlying.close)
    @test nrow(MyOptionsEODUnderlyingDataSet(ticker = "pfe")) == 113
    @test_throws ArgumentError MyOptionsEODUnderlyingDataSet(ticker = "TSLA")

    pfe = MyOptionsEODDataSet(ticker = "PFE")
    @test names(pfe) == ["date", "expiration", "dte", "target_dte", "type", "strike", "bid", "ask", "mid",
        "bid_size", "ask_size", "last_price", "last_size", "implied_vol", "delta", "gamma", "theta", "vega", "rho"]
    @test nrow(pfe) == 34_961
    @test issorted(pfe, [:date, :expiration, :type, :strike])
    @test !any(nonunique(pfe, [:date, :expiration, :type, :strike]))
    @test all(pfe.dte .== Dates.value.(pfe.expiration .- pfe.date))
    @test issubset(unique(pfe.type), ["call", "put"])
    @test all(pfe.ask .>= pfe.bid .>= 0)
    @test eltype(pfe.implied_vol) == Union{Missing,Float64}
    @test sort(unique(pfe.date)) == underlying.date[underlying.ticker .== "PFE"]
    window = MyOptionsEODDataSet(ticker = "PFE", from = Date(2026, 9, 1), to = Date(2026, 9, 30))
    @test extrema(window.date) == (Date(2026, 9, 1), Date(2026, 9, 30))
    @test_throws ArgumentError MyOptionsEODDataSet(ticker = "TSLA")

    session = MyOptionsEODChainDataSet(ticker = "PFE", date = Date(2026, 10, 8))
    @test session.metadata["DTE"] === nothing
    @test sort(unique(session.data.expiration)) == session.metadata["expirations"]
    expiration = session.metadata["expirations"][2]
    chain = MyOptionsEODChainDataSet(ticker = "PFE", date = Date(2026, 10, 8), expiration = expiration)
    @test chain.metadata["DTE"] == Dates.value(expiration - Date(2026, 10, 8))
    @test chain.metadata["underlying_close"] == only(underlying.close[(underlying.ticker .== "PFE") .& (underlying.date .== Date(2026, 10, 8))])
    @test all(chain.data.expiration .== expiration) && nrow(chain.data) > 0
    @test_throws ArgumentError MyOptionsEODChainDataSet(ticker = "PFE", date = Date(2026, 4, 14))
    @test_throws ArgumentError MyOptionsEODChainDataSet(ticker = "PFE", date = Date(2026, 10, 8), expiration = Date(2030, 1, 1))
end
