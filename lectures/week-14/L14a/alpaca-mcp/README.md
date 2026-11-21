# Example: Paper Trading the γ Basket
In this example, we connect [Claude Code](https://code.claude.com/docs/en/overview) to an [Alpaca](https://alpaca.markets/) paper trading account through a Model Context Protocol (MCP) server. We ask about the account and place orders in plain English, and Claude Code turns each request into calls to Alpaca's API.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Check the account and the market:__ Ask whether the market is open and how much the account can spend. Read the quotes of the stocks in the γ basket, and compare their bid-ask spreads.
> * __Place limit orders:__ Place a `day` limit order for each stock in the γ basket, and approve each order before it is sent.
> * __Follow the orders:__ Read the status of each order, cancel the orders that have not filled, and read the positions of the account.

Let's get started!

___

## Setup and Prerequisites
The server in this folder offers 74 tools, which reach the paper account through the [Alpaca SDK](https://github.com/varnerlab/alpaca-markets-sdk). The tools fall into seven areas:

* __Account:__ The `get_account`, `get_clock`, `get_calendar`, and `get_portfolio_history` tools read the cash, the market hours, the trading days, and the value of the account over time. The `update_account_configurations` tool changes the settings of the account.
* __Orders and positions:__ The `submit_order`, `submit_option_order`, and `submit_crypto_order` tools place orders for stocks, option contracts, and crypto pairs. The `get_orders`, `replace_order`, `cancel_order`, `get_positions`, and `close_position` tools read, change, and cancel the orders, and read and close the positions.
* __Watchlists:__ The `create_watchlist`, `get_watchlists`, and `add_to_watchlist` tools keep named lists of symbols in the account.
* __Stocks:__ The `get_latest_quotes`, `get_bars`, and `get_snapshots` tools read the latest quotes, the prices over time, and a summary of each stock. The seven tools whose names start with `get_global_stock_` read stocks on exchanges outside the US.
* __Options:__ The `get_option_contracts`, `get_option_chain`, and `get_option_latest_quotes` tools find option contracts and read their quotes.
* __Crypto:__ The `get_crypto_latest_quotes`, `get_crypto_bars`, and `get_crypto_orderbooks` tools read the quotes, the prices over time, and the order book of crypto pairs such as `BTC/USD`. Crypto trades around the clock, every day of the week.
* __News and other market data:__ The `get_news`, `get_most_actives`, `get_movers`, and `get_corporate_actions` tools read news articles, the most active stocks, the largest gainers and losers, and dividends and splits.

The tools for stocks outside the US, company logos, and bond prices need a paid market-data subscription, and they return an error on a free paper account.

Before you start, set up the course environment, your credentials, and Claude Code:

1. __Install the course environment.__ Open a terminal at the root of the course repository, and run `julia --project=. -e "import Pkg; Pkg.instantiate()"`. The environment includes the Alpaca SDK.
2. __Add your paper credentials.__ Copy `conf/apidata-template.toml` to `conf/apidata.toml`, and paste the key and secret of your paper account between the quotes. Git does not track this file. If you already have a credentials file for the Alpaca SDK, you can leave it where it is and set `ALPACA_CREDENTIALS` to its path instead.
3. __Install Claude Code.__ Claude Code needs a Claude plan or a Claude Console account.

The server works only with the paper endpoint, `https://paper-api.alpaca.markets/v2`, and refuses a credentials file with any other endpoint. Your key and secret stay in the server, and the language model never sees them.

Open a terminal in this folder, and start Claude Code. If you keep your credentials file outside this folder, give its path when you start:

```sh
ALPACA_CREDENTIALS=path/to/apidata.toml claude
```

Claude Code finds the `alpaca` server in [.mcp.json](.mcp.json) and asks whether to use it. Choose __Use this MCP server__, and type `/mcp` to check that the server is connected.

___

## Task 1: Check the Account and the Market
In this task, we check that the market is open, how much the account can spend, and how wide the bid-ask spread of each stock in the γ basket is.

The γ basket is the last table of the [updating example](../CHEME-5660-L14a-Example-Updating-SIM-Gamma-Fall-2026.ipynb). Paste its tickers into the second prompt:

> Is the market open? How much cash and buying power does my paper account have?

> Here are the stocks of the γ basket: <paste the tickers>. What are the latest bid and ask of each stock? How wide is each spread, as a percent of the price?

The quotes come from one exchange, IEX. A stock with few shares quoted on IEX can show a much wider spread than its national best bid and offer.

___

## Task 2: Place Limit Orders for the γ Basket
In this task, we place one `day` limit order for each stock in the γ basket.

> Buy 1 share of each stock in the γ basket with a day limit order at the latest bid price.

Claude Code shows each `submit_order` call and asks for your approval before it runs. You can approve each order, or tell Claude Code not to ask again for this tool in this folder. A buy limit order at the bid fills only when a seller accepts our price, and some of the orders may not fill.

___

## Task 3: Follow and Cancel the Orders
In this task, we read the status of each order, cancel the orders that have not filled, and read the positions of the account.

> What is the status of each order I placed today? How many shares of each order filled, and at what average price?

> Cancel the orders that have not filled.

> What positions do I hold now? What is the unrealized profit or loss of each position?

A `day` order that has not filled by the close is canceled. Canceling the open orders ourselves makes the account match what the trading method holds.

___

## Summary
In this example, we checked a paper account and the quotes of the γ basket, placed a limit order for each of its stocks, and followed each order until it filled or we canceled it.

> __Key Takeaways:__
>
> * __A trading API in plain English:__ The MCP server offers one tool for each request to the account. Claude Code picks the tools that answer a request, and we approve each order before it is sent.
> * __Quotes set the order:__ The bid and the ask set the limit price of each order. The free quotes come from one exchange, and their spread can be wider than the market's.
> * __Limit orders may not fill:__ A buy limit order at the bid fills only when a seller accepts our price. We read the status of each order and canceled the orders that did not fill.

___

## The Server Code
* The [server.jl](server.jl) file loads the code, reads the credentials file, builds the server, and runs the server loop.
* The [src/Catalog.jl](src/Catalog.jl) file holds the instructions that the server sends to Claude Code, and builds the server from the tools of each area.
* The files in [src/catalog](src/catalog) hold the tools of one area each: the handler of each tool, and its name, description, and input schema.
* The [src/Tools.jl](src/Tools.jl) file checks the arguments of a call and turns each result into rows that the language model reads.
* The [src/Utility.jl](src/Utility.jl) file reads the credentials file and checks the paper endpoint.
* The [src/Server.jl](src/Server.jl), [src/Types.jl](src/Types.jl), and [src/Factory.jl](src/Factory.jl) files hold the server loop and the models of a tool and a server.

___

## Disclaimer and Risks
__This content is offered solely for training and informational purposes__. No offer or solicitation to buy or sell securities or derivative products or any investment or trading advice or strategy is made, given, or endorsed by the teaching team.

__Trading involves risk__. Carefully review your financial situation before investing in securities, futures contracts, options, or commodity interests. Past performance, whether actual or indicated by historical tests of strategies, is no guarantee of future performance or success.

Trading is generally inappropriate for someone with limited resources, investment or trading experience, or a low-risk tolerance. Only risk capital that is not required for living expenses should be used.

__You are fully responsible for any investment or trading decisions you make__. Such decisions should be based solely on evaluating your financial circumstances, investment or trading objectives, risk tolerance, and liquidity needs.
