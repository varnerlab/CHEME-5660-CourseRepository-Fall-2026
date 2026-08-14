"""
    OrderSide

Side of an incoming or resting order. A `Buy` order consumes asks when it
crosses the book; a `Sell` order consumes bids.
"""
@enum OrderSide Buy Sell

"""
    TimeInForce

Instruction for any unexecuted order quantity: `GTC` rests a limit-order
remainder, `IOC` cancels the remainder, and `FOK` executes the entire order or
does nothing.
"""
@enum TimeInForce GTC IOC FOK

"""
    MyLimitOrder(id, side, price_ticks, quantity; account = nothing)

A limit order with an integer identifier, exact integer price ticks, and an
integer quantity. Use [`price_to_ticks`](@ref) to convert a quoted price.
"""
struct MyLimitOrder
    id::Int
    side::OrderSide
    price_ticks::Int
    quantity::Int
    account::Union{Nothing,Int}

    function MyLimitOrder(
        id::Integer,
        side::OrderSide,
        price_ticks::Integer,
        quantity::Integer;
        account::Union{Nothing,Integer} = nothing,
    )
        price_ticks > 0 || throw(ArgumentError("price_ticks must be positive"))
        quantity > 0 || throw(ArgumentError("quantity must be positive"))
        account_id = isnothing(account) ? nothing : Int(account)
        return new(Int(id), side, Int(price_ticks), Int(quantity), account_id)
    end
end

"""
    MyMarketOrder(side, quantity)

An order to consume up to `quantity` units from the opposite side of the book.
A market order cannot rest because it has no limit price.
"""
struct MyMarketOrder
    side::OrderSide
    quantity::Int

    function MyMarketOrder(side::OrderSide, quantity::Integer)
        quantity > 0 || throw(ArgumentError("quantity must be positive"))
        return new(side, Int(quantity))
    end
end

"""
    MyOrderBookFill

One execution against a resting limit order. `side` is the aggressor's side.
"""
struct MyOrderBookFill
    aggressor_order_id::Union{Nothing,Int}
    resting_order_id::Int
    side::OrderSide
    price_ticks::Int
    quantity::Int
    resting_account::Union{Nothing,Int}
end

"""
    MyOrderBookExecutionReport

Result of [`submit_order!`](@ref). `remaining_quantity` is the unexecuted
quantity; `resting_quantity` is the part of that remainder inserted under GTC.
"""
struct MyOrderBookExecutionReport
    side::OrderSide
    requested_quantity::Int
    executed_quantity::Int
    remaining_quantity::Int
    resting_quantity::Int
    fills::Vector{MyOrderBookFill}
    status::Symbol
    tick_size::Float64
end

"""Aggregated displayed liquidity at one book price."""
struct MyOrderBookLevel
    side::OrderSide
    price_ticks::Int
    price::Float64
    quantity::Int
    order_count::Int
end

"""A best-to-worst snapshot of the bid and ask books."""
struct MyOrderBookSnapshot
    bids::Vector{MyOrderBookLevel}
    asks::Vector{MyOrderBookLevel}
end

Base.:(==)(left::MyOrderBookLevel, right::MyOrderBookLevel) =
    left.side == right.side &&
    left.price_ticks == right.price_ticks &&
    left.price == right.price &&
    left.quantity == right.quantity &&
    left.order_count == right.order_count

Base.:(==)(left::MyOrderBookSnapshot, right::MyOrderBookSnapshot) =
    left.bids == right.bids && left.asks == right.asks

"""
    MyOrderBook(; tick_size = 0.01)

A deterministic price-time-priority limit-order book. Prices are stored as
integer ticks, so matching does not depend on floating-point equality. The
implementation favors transparent mechanics over exchange-scale throughput.
"""
mutable struct MyOrderBook
    tick_size::Float64
    bids::Dict{Int,Vector{MyLimitOrder}}
    asks::Dict{Int,Vector{MyLimitOrder}}
    order_index::Dict{Int,Tuple{OrderSide,Int}}
    account_index::Dict{Int,Set{Int}}

    function MyOrderBook(; tick_size::Real = 0.01)
        isfinite(tick_size) && tick_size > 0 ||
            throw(ArgumentError("tick_size must be positive and finite"))
        return new(
            Float64(tick_size),
            Dict{Int,Vector{MyLimitOrder}}(),
            Dict{Int,Vector{MyLimitOrder}}(),
            Dict{Int,Tuple{OrderSide,Int}}(),
            Dict{Int,Set{Int}}(),
        )
    end
end

Base.isempty(book::MyOrderBook) = isempty(book.bids) && isempty(book.asks)

function Base.show(io::IO, book::MyOrderBook)
    quotes = best_quotes(book)
    print(io, "MyOrderBook(tick_size=$(book.tick_size), bid=$(quotes.bid), ",
        "ask=$(quotes.ask), orders=$(resting_order_count(book)))")
end

_order_book_side(book::MyOrderBook, side::OrderSide) = side == Buy ? book.bids : book.asks
_opposite_order_book_side(book::MyOrderBook, side::OrderSide) =
    _order_book_side(book, side == Buy ? Sell : Buy)

function _best_ticks(levels::Dict{Int,Vector{MyLimitOrder}}, side::OrderSide)
    isempty(levels) && return nothing
    return side == Buy ? maximum(keys(levels)) : minimum(keys(levels))
end

"""Return best bid and ask as integer ticks; either value may be `nothing`."""
best_quote_ticks(book::MyOrderBook) =
    (bid = _best_ticks(book.bids, Buy), ask = _best_ticks(book.asks, Sell))

"""Convert exact integer price ticks to quoted price units."""
ticks_to_price(book::MyOrderBook, ticks::Integer) = Int(ticks) * book.tick_size

"""Convert a quoted price to exact ticks, rejecting prices off the tick grid."""
function price_to_ticks(book::MyOrderBook, price::Real)
    isfinite(price) && price > 0 ||
        throw(ArgumentError("price must be positive and finite"))
    raw_ticks = Float64(price) / book.tick_size
    ticks = round(Int, raw_ticks)
    isapprox(raw_ticks, ticks; atol = 1e-8, rtol = 1e-12) ||
        throw(ArgumentError("price $price is not on the $(book.tick_size) tick grid"))
    return ticks
end

"""Return best bid and ask in quoted price units."""
function best_quotes(book::MyOrderBook)
    quotes = best_quote_ticks(book)
    return (
        bid = isnothing(quotes.bid) ? nothing : ticks_to_price(book, quotes.bid),
        ask = isnothing(quotes.ask) ? nothing : ticks_to_price(book, quotes.ask),
    )
end

"""Return the midpoint in tick units, including half ticks, or `nothing`."""
function midpoint_ticks(book::MyOrderBook)
    quotes = best_quote_ticks(book)
    (isnothing(quotes.bid) || isnothing(quotes.ask)) && return nothing
    return (quotes.bid + quotes.ask) / 2
end

"""Return the quoted midpoint price, or `nothing` for a one-sided book."""
function midprice(book::MyOrderBook)
    midpoint = midpoint_ticks(book)
    return isnothing(midpoint) ? nothing : midpoint * book.tick_size
end

"""Return the quoted bid-ask spread, or `nothing` for a one-sided book."""
function bid_ask_spread(book::MyOrderBook)
    quotes = best_quote_ticks(book)
    (isnothing(quotes.bid) || isnothing(quotes.ask)) && return nothing
    return (quotes.ask - quotes.bid) * book.tick_size
end

function _sorted_order_book_prices(book::MyOrderBook, side::OrderSide)
    prices = collect(keys(_order_book_side(book, side)))
    sort!(prices; rev = side == Buy)
    return prices
end

"""Return aggregated levels from best to worst on `side`."""
function order_book_depth(book::MyOrderBook, side::OrderSide; levels::Integer = typemax(Int))
    levels >= 0 || throw(ArgumentError("levels must be nonnegative"))
    result = MyOrderBookLevel[]
    sidebook = _order_book_side(book, side)
    for price_ticks in Iterators.take(_sorted_order_book_prices(book, side), Int(levels))
        queue = sidebook[price_ticks]
        push!(result, MyOrderBookLevel(
            side,
            price_ticks,
            ticks_to_price(book, price_ticks),
            sum(order.quantity for order in queue),
            length(queue),
        ))
    end
    return result
end

"""Return a best-to-worst snapshot of both sides of the book."""
function order_book_snapshot(book::MyOrderBook; levels::Integer = 10)
    return MyOrderBookSnapshot(
        order_book_depth(book, Buy; levels = levels),
        order_book_depth(book, Sell; levels = levels),
    )
end

"""Return total displayed quantity on `side`."""
displayed_volume(book::MyOrderBook, side::OrderSide) =
    sum(order.quantity for queue in values(_order_book_side(book, side)) for order in queue; init = 0)

"""Return the number of resting orders, optionally restricted to one side."""
resting_order_count(book::MyOrderBook) = length(book.order_index)
resting_order_count(book::MyOrderBook, side::OrderSide) =
    sum(length(queue) for queue in values(_order_book_side(book, side)); init = 0)

function _index_order!(book::MyOrderBook, order::MyLimitOrder)
    book.order_index[order.id] = (order.side, order.price_ticks)
    if !isnothing(order.account)
        push!(get!(Set{Int}, book.account_index, order.account), order.id)
    end
    return order
end

function _unindex_order!(book::MyOrderBook, order::MyLimitOrder)
    delete!(book.order_index, order.id)
    if !isnothing(order.account) && haskey(book.account_index, order.account)
        ids = book.account_index[order.account]
        delete!(ids, order.id)
        isempty(ids) && delete!(book.account_index, order.account)
    end
    return order
end

function _rest_order!(book::MyOrderBook, order::MyLimitOrder)
    haskey(book.order_index, order.id) &&
        throw(ArgumentError("order id $(order.id) is already resting"))
    push!(get!(Vector{MyLimitOrder}, _order_book_side(book, order.side), order.price_ticks), order)
    return _index_order!(book, order)
end

function _crosses(side::OrderSide, opposite_price::Int, limit::Union{Nothing,Int})
    isnothing(limit) && return true
    return side == Buy ? opposite_price <= limit : opposite_price >= limit
end

function _available_quantity(book::MyOrderBook, side::OrderSide, limit::Union{Nothing,Int})
    opposite_side = side == Buy ? Sell : Buy
    levels = _opposite_order_book_side(book, side)
    available = 0
    for price in _sorted_order_book_prices(book, opposite_side)
        _crosses(side, price, limit) || break
        available += sum(order.quantity for order in levels[price])
    end
    return available
end

function _match_order!(
    book::MyOrderBook,
    side::OrderSide,
    quantity::Int;
    limit::Union{Nothing,Int} = nothing,
    aggressor_order_id::Union{Nothing,Int} = nothing,
)
    remaining = quantity
    fills = MyOrderBookFill[]
    opposite_side = side == Buy ? Sell : Buy
    levels = _opposite_order_book_side(book, side)

    while remaining > 0 && !isempty(levels)
        best_price = _best_ticks(levels, opposite_side)::Int
        _crosses(side, best_price, limit) || break
        queue = levels[best_price]

        while remaining > 0 && !isempty(queue)
            resting = first(queue)
            fill_quantity = min(remaining, resting.quantity)
            push!(fills, MyOrderBookFill(
                aggressor_order_id,
                resting.id,
                side,
                resting.price_ticks,
                fill_quantity,
                resting.account,
            ))
            remaining -= fill_quantity

            if fill_quantity == resting.quantity
                popfirst!(queue)
                _unindex_order!(book, resting)
            else
                queue[1] = MyLimitOrder(
                    resting.id,
                    resting.side,
                    resting.price_ticks,
                    resting.quantity - fill_quantity;
                    account = resting.account,
                )
            end
        end
        isempty(queue) && delete!(levels, best_price)
    end
    return fills, remaining
end

function _execution_status(executed::Int, remaining::Int, resting::Int)
    remaining == 0 && return :filled
    executed > 0 && resting > 0 && return :partially_filled_and_resting
    executed > 0 && return :partially_filled
    resting > 0 && return :resting
    return :unfilled
end

"""Submit a limit order using price-time priority and the selected time in force."""
function submit_order!(book::MyOrderBook, order::MyLimitOrder; tif::TimeInForce = GTC)
    haskey(book.order_index, order.id) &&
        throw(ArgumentError("order id $(order.id) is already resting"))

    if tif == FOK && _available_quantity(book, order.side, order.price_ticks) < order.quantity
        return MyOrderBookExecutionReport(
            order.side, order.quantity, 0, order.quantity, 0,
            MyOrderBookFill[], :rejected, book.tick_size,
        )
    end

    fills, remaining = _match_order!(
        book,
        order.side,
        order.quantity;
        limit = order.price_ticks,
        aggressor_order_id = order.id,
    )
    executed = order.quantity - remaining
    resting = tif == GTC ? remaining : 0
    if resting > 0
        _rest_order!(book, MyLimitOrder(
            order.id, order.side, order.price_ticks, resting; account = order.account,
        ))
    end
    return MyOrderBookExecutionReport(
        order.side, order.quantity, executed, remaining, resting, fills,
        _execution_status(executed, remaining, resting), book.tick_size,
    )
end

"""Submit an IOC or FOK market order using price-time priority."""
function submit_order!(book::MyOrderBook, order::MyMarketOrder; tif::TimeInForce = IOC)
    tif == GTC && throw(ArgumentError("a market order cannot use GTC"))
    if tif == FOK && _available_quantity(book, order.side, nothing) < order.quantity
        return MyOrderBookExecutionReport(
            order.side, order.quantity, 0, order.quantity, 0,
            MyOrderBookFill[], :rejected, book.tick_size,
        )
    end
    fills, remaining = _match_order!(book, order.side, order.quantity)
    executed = order.quantity - remaining
    return MyOrderBookExecutionReport(
        order.side, order.quantity, executed, remaining, 0, fills,
        _execution_status(executed, remaining, 0), book.tick_size,
    )
end

"""Cancel and return the resting order with `id`, or return `nothing`."""
function cancel_order!(book::MyOrderBook, id::Integer)
    order_id = Int(id)
    location = get(book.order_index, order_id, nothing)
    isnothing(location) && return nothing
    side, price = location
    queue = _order_book_side(book, side)[price]
    position = findfirst(order -> order.id == order_id, queue)
    isnothing(position) && error("order index is inconsistent for order $order_id")
    order = popat!(queue, position)
    isempty(queue) && delete!(_order_book_side(book, side), price)
    return _unindex_order!(book, order)
end

"""Remove every resting order and return the empty order book."""
function clear_order_book!(book::MyOrderBook)
    empty!(book.bids)
    empty!(book.asks)
    empty!(book.order_index)
    empty!(book.account_index)
    return book
end

"""Return the resting orders associated with `account`."""
function account_orders(book::MyOrderBook, account::Integer)
    ids = get(book.account_index, Int(account), Set{Int}())
    orders = MyLimitOrder[]
    for side in (Buy, Sell), price in _sorted_order_book_prices(book, side)
        append!(orders, (order for order in _order_book_side(book, side)[price] if order.id in ids))
    end
    return orders
end

"""Return displayed depth imbalance over the best `levels` prices."""
function order_book_imbalance(book::MyOrderBook; levels::Integer = 1)
    bid_volume = sum(level.quantity for level in order_book_depth(book, Buy; levels = levels); init = 0)
    ask_volume = sum(level.quantity for level in order_book_depth(book, Sell; levels = levels); init = 0)
    total = bid_volume + ask_volume
    return total == 0 ? 0.0 : (bid_volume - ask_volume) / total
end

"""Return the top-of-book depth-weighted microprice, or `nothing`."""
function microprice(book::MyOrderBook)
    quotes = best_quote_ticks(book)
    (isnothing(quotes.bid) || isnothing(quotes.ask)) && return nothing
    bid_quantity = sum(order.quantity for order in book.bids[quotes.bid])
    ask_quantity = sum(order.quantity for order in book.asks[quotes.ask])
    total = bid_quantity + ask_quantity
    total == 0 && return nothing
    weighted_ticks = (quotes.ask * bid_quantity + quotes.bid * ask_quantity) / total
    return weighted_ticks * book.tick_size
end

"""Return fill-weighted execution price in tick units, or `nothing`."""
function execution_vwap_ticks(report::MyOrderBookExecutionReport)
    report.executed_quantity == 0 && return nothing
    return sum(fill.price_ticks * fill.quantity for fill in report.fills) /
        report.executed_quantity
end

"""Return fill-weighted execution price in quoted units, or `nothing`."""
function execution_vwap(report::MyOrderBookExecutionReport)
    value = execution_vwap_ticks(report)
    return isnothing(value) ? nothing : value * report.tick_size
end

"""Return the quoted notional value executed by `report`."""
executed_notional(report::MyOrderBookExecutionReport) =
    sum(fill.price_ticks * fill.quantity for fill in report.fills) * report.tick_size

"""Return signed execution cost relative to `benchmark_price`, or `nothing`."""
function implementation_shortfall(
    report::MyOrderBookExecutionReport,
    benchmark_price::Real,
)
    average_price = execution_vwap(report)
    isnothing(average_price) && return nothing
    direction = report.side == Buy ? 1 : -1
    return direction * (average_price - benchmark_price) * report.executed_quantity
end

"""
    validate_order_book(book)

Check structural, index, account, and uncrossed-book invariants. Return `true`
or throw an `AssertionError` describing the violated invariant.
"""
function validate_order_book(book::MyOrderBook)
    seen_ids = Set{Int}()
    expected_accounts = Dict{Int,Set{Int}}()
    for side in (Buy, Sell)
        for (price, queue) in _order_book_side(book, side)
            @assert !isempty(queue) "empty price queue at $price"
            for order in queue
                @assert order.side == side "order $(order.id) is on the wrong side"
                @assert order.price_ticks == price "order $(order.id) is at the wrong price"
                @assert order.quantity > 0 "order $(order.id) has nonpositive quantity"
                @assert order.id ∉ seen_ids "duplicate resting order id $(order.id)"
                push!(seen_ids, order.id)
                @assert get(book.order_index, order.id, nothing) == (side, price) "incorrect order index for $(order.id)"
                if !isnothing(order.account)
                    push!(get!(Set{Int}, expected_accounts, order.account), order.id)
                end
            end
        end
    end
    @assert seen_ids == Set(keys(book.order_index)) "order index contains stale entries"
    @assert expected_accounts == book.account_index "account index is inconsistent"
    quotes = best_quote_ticks(book)
    if !isnothing(quotes.bid) && !isnothing(quotes.ask)
        @assert quotes.bid < quotes.ask "resting book is crossed or locked"
    end
    return true
end
