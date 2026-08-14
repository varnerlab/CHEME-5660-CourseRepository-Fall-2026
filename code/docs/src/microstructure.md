# Market microstructure

The order-book component is a deterministic teaching implementation of a
continuous limit-order book. It supports the mechanics needed to study how
limit orders, cancellations, and aggressive orders change displayed liquidity
and execution cost.

Prices are stored internally as integer ticks. This prevents floating-point
rounding from changing matching decisions. Quantities are positive integers,
and resting orders at the same price execute in arrival order.

## Basic use

```julia
book = MyOrderBook(tick_size = 0.01)

submit_order!(book, MyLimitOrder(1, Sell, 10_001, 100; account = 11))
submit_order!(book, MyLimitOrder(2, Sell, 10_002, 200; account = 12))

midpoint_before = midprice(book) # nothing until the book also has a bid
report = submit_order!(book, MyMarketOrder(Buy, 150))

execution_vwap(report)
executed_notional(report)
order_book_snapshot(book; levels = 5)
validate_order_book(book)
```

A market order is immediate-or-cancel by default. Limit orders are
good-til-cancelled by default, but can instead use `IOC` or `FOK`:

```julia
submit_order!(book, limit_order; tif = IOC)
submit_order!(book, market_order; tif = FOK)
```

## Interpretation boundary

Walking a snapshot measures the mechanical execution cost implied by displayed
depth. It does not, by itself, identify the causal or persistent market impact
of an order. Empirical market-impact models additionally require an event
horizon, a benchmark price, and assumptions or data describing subsequent
order flow and liquidity replenishment.

## Types

```@docs
VLQuantitativeFinancePackage.OrderSide
VLQuantitativeFinancePackage.TimeInForce
VLQuantitativeFinancePackage.MyLimitOrder
VLQuantitativeFinancePackage.MyMarketOrder
VLQuantitativeFinancePackage.MyOrderBookFill
VLQuantitativeFinancePackage.MyOrderBookExecutionReport
VLQuantitativeFinancePackage.MyOrderBookLevel
VLQuantitativeFinancePackage.MyOrderBookSnapshot
VLQuantitativeFinancePackage.MyOrderBook
```

## Book operations

```@docs
VLQuantitativeFinancePackage.submit_order!
VLQuantitativeFinancePackage.cancel_order!
VLQuantitativeFinancePackage.clear_order_book!
VLQuantitativeFinancePackage.order_book_depth
VLQuantitativeFinancePackage.order_book_snapshot
VLQuantitativeFinancePackage.validate_order_book
VLQuantitativeFinancePackage.account_orders
```

## Quotes and displayed liquidity

```@docs
VLQuantitativeFinancePackage.price_to_ticks
VLQuantitativeFinancePackage.ticks_to_price
VLQuantitativeFinancePackage.best_quote_ticks
VLQuantitativeFinancePackage.best_quotes
VLQuantitativeFinancePackage.midpoint_ticks
VLQuantitativeFinancePackage.midprice
VLQuantitativeFinancePackage.bid_ask_spread
VLQuantitativeFinancePackage.displayed_volume
VLQuantitativeFinancePackage.resting_order_count
VLQuantitativeFinancePackage.order_book_imbalance
VLQuantitativeFinancePackage.microprice
```

## Execution measurements

```@docs
VLQuantitativeFinancePackage.execution_vwap_ticks
VLQuantitativeFinancePackage.execution_vwap
VLQuantitativeFinancePackage.executed_notional
VLQuantitativeFinancePackage.implementation_shortfall
```
