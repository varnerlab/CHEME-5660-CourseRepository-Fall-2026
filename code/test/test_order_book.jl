using Test
using Random
using VLQuantitativeFinancePackage

function _seeded_order_book()
    book = MyOrderBook(tick_size = 0.01)
    submit_order!(book, MyLimitOrder(1, Buy, 9_999, 100; account = 10))
    submit_order!(book, MyLimitOrder(2, Buy, 9_998, 200; account = 10))
    submit_order!(book, MyLimitOrder(3, Sell, 10_001, 80; account = 20))
    submit_order!(book, MyLimitOrder(4, Sell, 10_002, 120; account = 20))
    return book
end

@testset "order book: construction and quoted state" begin
    book = _seeded_order_book()
    @test price_to_ticks(book, 100.01) == 10_001
    @test ticks_to_price(book, 10_001) ≈ 100.01
    @test_throws ArgumentError price_to_ticks(book, 100.005)
    @test_throws ArgumentError MyOrderBook(tick_size = 0.0)
    @test_throws ArgumentError MyLimitOrder(1, Buy, 0, 10)
    @test_throws ArgumentError MyMarketOrder(Buy, 0)

    @test best_quote_ticks(book) == (bid = 9_999, ask = 10_001)
    @test best_quotes(book).bid ≈ 99.99
    @test best_quotes(book).ask ≈ 100.01
    @test midpoint_ticks(book) == 10_000.0
    @test midprice(book) ≈ 100.0
    @test bid_ask_spread(book) ≈ 0.02
    @test displayed_volume(book, Buy) == 300
    @test displayed_volume(book, Sell) == 200
    @test resting_order_count(book) == 4
    @test validate_order_book(book)

    view = order_book_snapshot(book; levels = 1)
    @test only(view.bids).price_ticks == 9_999
    @test only(view.bids).quantity == 100
    @test only(view.asks).price_ticks == 10_001
    @test only(view.asks).quantity == 80
    @test order_book_imbalance(book) ≈ (100 - 80) / 180
    @test microprice(book) ≈ (100.01 * 100 + 99.99 * 80) / 180
end

@testset "order book: price-time priority and partial resting fill" begin
    book = MyOrderBook(tick_size = 0.01)
    submit_order!(book, MyLimitOrder(1, Sell, 10_001, 50; account = 7))
    submit_order!(book, MyLimitOrder(2, Sell, 10_001, 70; account = 8))
    report = submit_order!(book, MyMarketOrder(Buy, 80))

    @test report.status == :filled
    @test report.executed_quantity == 80
    @test [fill.resting_order_id for fill in report.fills] == [1, 2]
    @test [fill.quantity for fill in report.fills] == [50, 30]
    @test isnothing(cancel_order!(book, 1))
    @test isempty(account_orders(book, 7))
    @test only(account_orders(book, 8)).quantity == 40
    @test only(book.asks[10_001]).quantity == 40
    @test validate_order_book(book)
end

@testset "order book: multi-level market impact accounting" begin
    book = _seeded_order_book()
    benchmark = midprice(book)
    report = submit_order!(book, MyMarketOrder(Buy, 150))

    @test report.status == :filled
    @test report.requested_quantity == 150
    @test report.executed_quantity == 150
    @test [fill.price_ticks for fill in report.fills] == [10_001, 10_002]
    @test [fill.quantity for fill in report.fills] == [80, 70]
    @test execution_vwap_ticks(report) ≈ (10_001 * 80 + 10_002 * 70) / 150
    @test execution_vwap(report) ≈ 100.01466666666667
    @test executed_notional(report) ≈ 15_002.2
    @test implementation_shortfall(report, benchmark) ≈ 2.2
    @test best_quote_ticks(book).ask == 10_002
    @test displayed_volume(book, Sell) == 50
    @test validate_order_book(book)
end

@testset "order book: sell-side walk" begin
    book = _seeded_order_book()
    report = submit_order!(book, MyMarketOrder(Sell, 250))
    @test [fill.price_ticks for fill in report.fills] == [9_999, 9_998]
    @test [fill.quantity for fill in report.fills] == [100, 150]
    @test execution_vwap(report) ≈ 99.984
    @test best_quote_ticks(book).bid == 9_998
    @test displayed_volume(book, Buy) == 50
    @test validate_order_book(book)
end

@testset "order book: marketable limit and time in force" begin
    gtc_book = _seeded_order_book()
    gtc = submit_order!(gtc_book, MyLimitOrder(5, Buy, 10_001, 100; account = 30))
    @test gtc.status == :partially_filled_and_resting
    @test gtc.executed_quantity == 80
    @test gtc.remaining_quantity == 20
    @test gtc.resting_quantity == 20
    @test only(account_orders(gtc_book, 30)).quantity == 20
    @test best_quote_ticks(gtc_book) == (bid = 10_001, ask = 10_002)
    @test validate_order_book(gtc_book)

    ioc_book = _seeded_order_book()
    ioc = submit_order!(ioc_book, MyLimitOrder(5, Buy, 10_001, 100); tif = IOC)
    @test ioc.status == :partially_filled
    @test ioc.executed_quantity == 80
    @test ioc.remaining_quantity == 20
    @test ioc.resting_quantity == 0
    @test !haskey(ioc_book.order_index, 5)
    @test validate_order_book(ioc_book)
end

@testset "order book: fill-or-kill is atomic" begin
    book = _seeded_order_book()
    before = order_book_snapshot(book)
    rejected = submit_order!(book, MyMarketOrder(Buy, 201); tif = FOK)
    @test rejected.status == :rejected
    @test rejected.executed_quantity == 0
    @test order_book_snapshot(book) == before
    @test validate_order_book(book)

    filled = submit_order!(book, MyMarketOrder(Buy, 200); tif = FOK)
    @test filled.status == :filled
    @test filled.executed_quantity == 200
    @test isempty(book.asks)
    @test validate_order_book(book)
end

@testset "order book: cancellation and account cleanup" begin
    book = _seeded_order_book()
    @test_throws ArgumentError submit_order!(book, MyLimitOrder(1, Buy, 9_997, 10))
    cancelled = cancel_order!(book, 1)
    @test cancelled.id == 1
    @test isnothing(cancel_order!(book, 1))
    @test [order.id for order in account_orders(book, 10)] == [2]
    @test best_quote_ticks(book).bid == 9_998
    @test validate_order_book(book)
end

@testset "order book: static-book slicing identity" begin
    block_book = _seeded_order_book()
    block = submit_order!(block_book, MyMarketOrder(Buy, 150))

    sliced_book = _seeded_order_book()
    slices = [submit_order!(sliced_book, MyMarketOrder(Buy, 50)) for _ in 1:3]
    @test sum(executed_notional(report) for report in slices) ≈ executed_notional(block)
    @test order_book_snapshot(sliced_book) == order_book_snapshot(block_book)
    @test validate_order_book(sliced_book)
end

@testset "order book: deterministic event-stream invariants" begin
    rng = MersenneTwister(5660)
    book = MyOrderBook(tick_size = 0.01)
    next_id = 1
    for _ in 1:500
        event = rand(rng)
        if event < 0.65
            side = rand(rng, (Buy, Sell))
            quantity = rand(rng, 1:100)
            report = submit_order!(book, MyLimitOrder(
                next_id, side, 10_000 + rand(rng, -5:5), quantity;
                account = rand(rng, 1:5),
            ))
            @test report.executed_quantity + report.remaining_quantity == quantity
            @test report.resting_quantity == report.remaining_quantity
            next_id += 1
        elseif event < 0.9
            side = rand(rng, (Buy, Sell))
            quantity = rand(rng, 1:150)
            report = submit_order!(book, MyMarketOrder(side, quantity))
            @test report.executed_quantity + report.remaining_quantity == quantity
        elseif !isempty(book.order_index)
            id = rand(rng, collect(keys(book.order_index)))
            @test cancel_order!(book, id).id == id
        end
        @test validate_order_book(book)
    end
end

@testset "order book: clearing" begin
    book = _seeded_order_book()
    @test clear_order_book!(book) === book
    @test isempty(book)
    @test validate_order_book(book)
end
