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
