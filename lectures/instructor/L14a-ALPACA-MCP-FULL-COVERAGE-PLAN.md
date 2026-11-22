# L14a Alpaca MCP Server: Full Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the L14a Alpaca MCP server one tool for each endpoint of Alpaca SDK 0.5.0, so Claude Code can explore everything a paper account can do: stocks, options, crypto, watchlists, account settings, news and the other market data.

**Architecture:** Keep the server's three-step tool pattern (check the arguments, call the SDK, return rows). Split `src/Catalog.jl` by area into `src/catalog/*.jl`, one `_add_<area>_tools!` function per file, so no file holds 74 tools. Add one capability to `src/Server.jl`: a tool can return a PNG image, which the logos tool needs.

**Tech Stack:** Julia, the course environment, Alpaca SDK 0.5.0 (`varnerlab/alpaca-markets-sdk`, branch `endpoints-0.5` until it is pushed), MCP over stdio (protocol 2026-07-28, as today).

**Spec:** the SDK plan, `~/Desktop/julia_work/alpaca-markets-sdk/docs/superpowers/plans/2026-11-21-full-endpoint-coverage.md`, whose Interfaces blocks name every model this plan calls, and the endpoint inventory beside it in `docs/superpowers/specs/2026-11-21-alpaca-endpoint-inventory.md`. Scope approved by Jeff on 2026-11-21: "do 1 -> 3 and add crypto".

## Global Constraints

- The server code is student code: plain course-style Julia, documented top-level functions, explicit loops and `if` blocks, a comment for each step. No inner or nested functions, closures, `do` blocks, ternary chains, or `x || throw` / `&& return` one-liners.
- Keep the names of the 11 existing tools except `get_daily_bars`, which becomes `get_bars` (Task 4). The lecture figure shows `get_latest_quotes`, `submit_order` and `get_order`, so those three names never change.
- Naming rule: stock tools have no asset prefix (`get_bars`, `get_latest_quotes`), as in the SDK's legacy names. Options, crypto and non-US stocks carry `option_`, `crypto_` and `global_stock_`.
- Each result stays under `MAX_ROWS = 300` rows and `MAX_SYMBOLS = 50` symbols, as today.
- Every tool on a paginated endpoint calls `api(client, model; max_pages = 1)` (SDK 0.5.0) with `limit` (or `page_size`) set to `MAX_ROWS + 1`. A page that comes back with more than `MAX_ROWS` rows gets the row-cap message, so a table is never cut short without saying so. Without the page cap, `api` follows every page, and a few days of crypto quotes take minutes to download.
- The server refuses any endpoint but `https://paper-api.alpaca.markets/v2`, as today.
- Student docs follow the user's voice rules and the repo rules: no equations, no lecture-asset names, short and plain. The README keeps its shape. Only the tool list and "The Server Code" bullets change.
- The course repo is a shared worktree. Commit with a temporary `GIT_INDEX_FILE` holding only this plan's files. Never push without Jeff's go-ahead.
- Check scripts live in `lectures/instructor/alpaca-mcp-checks/`, which the weekly release does not ship.

## Tool list (74)

| File | Tools (SDK model) |
|---|---|
| `catalog/Account.jl` | `get_account`, `get_account_configurations`, `update_account_configurations`, `get_account_activities`, `get_portfolio_history`, `get_clock`, `get_calendar`, `get_market_calendar` (`MyMarketCalendarEndpointModel`), `get_market_clocks` (`MyMarketClocksEndpointModel`), `get_assets`, `get_asset`, `get_option_contracts`, `get_option_contract` |
| `catalog/Orders.jl` | `get_orders`, `get_order` (adds `client_order_id`), `submit_order` (stocks), `submit_option_order` (1 leg: `submit(client, leg)`; 2 to 4 legs: one multi-leg order), `submit_crypto_order`, `replace_order`, `cancel_order`, `cancel_all_orders`, `get_positions`, `get_position`, `close_position`, `close_all_positions`, `exercise_option`, `do_not_exercise_option` |
| `catalog/Watchlists.jl` | `get_watchlists`, `get_watchlist`, `create_watchlist`, `update_watchlist`, `add_to_watchlist`, `remove_from_watchlist`, `delete_watchlist` |
| `catalog/Stocks.jl` | `get_bars`, `get_quotes`, `get_trades`, `get_latest_bars`, `get_latest_quotes`, `get_latest_trades`, `get_snapshots`, `get_auctions`, `get_stock_conditions`, `get_stock_exchanges`, and the non-US tools `get_global_stock_bars`, `get_global_stock_quotes`, `get_global_stock_trades`, `get_global_stock_latest_bars`, `get_global_stock_latest_quotes`, `get_global_stock_latest_trades`, `get_global_stock_snapshots` |
| `catalog/Options.jl` | `get_option_bars`, `get_option_trades`, `get_option_latest_quotes`, `get_option_latest_trades`, `get_option_snapshots`, `get_option_chain`, `get_option_exchanges`, `get_option_conditions` |
| `catalog/Crypto.jl` | `get_crypto_bars`, `get_crypto_quotes`, `get_crypto_trades`, `get_crypto_latest_bars`, `get_crypto_latest_quotes`, `get_crypto_latest_trades`, `get_crypto_orderbooks`, `get_crypto_snapshots` |
| `catalog/MarketData.jl` | `get_news`, `get_most_actives`, `get_movers`, `get_corporate_actions`, `get_logo`, `get_fixed_income_prices`, `get_fixed_income_quotes` |

Every tool's arguments are the SDK model's keywords, by the same names, with `finish` exposed as `end` as `get_daily_bars` does today. Every description states the units (shares, contracts, USD per share, USD per contract, coins) and the time zone (UTC), as the existing descriptions do.

---

### Task 1: Development environment, check script, shared helpers, image results, catalog split

**Files:**
- Create: `lectures/instructor/alpaca-mcp-checks/dev_env.jl` (builds a scratch environment from the course `Project.toml` and `Manifest.toml` under `tempdir()`, then runs `Pkg.develop(path = expanduser("~/Desktop/julia_work/alpaca-markets-sdk"))`), `lectures/instructor/alpaca-mcp-checks/check_offline.jl`, `lectures/instructor/alpaca-mcp-checks/README.md` (three lines: what each script checks and how to run it)
- Create: `lectures/week-14/L14a/alpaca-mcp/src/catalog/{Account,Orders,Watchlists,Stocks,Options,Crypto,MarketData}.jl`
- Modify: `alpaca-mcp/src/Catalog.jl` (keeps `SERVER_INSTRUCTIONS` and `build_alpaca_server`, which calls each `_add_<area>_tools!`), `alpaca-mcp/src/AlpacaMCP.jl` (includes, `import Base64`), `alpaca-mcp/src/Tools.jl`, `alpaca-mcp/src/Server.jl`, `alpaca-mcp/Include.jl` (the file map comment)

**Interfaces:**
- Produces, in `src/Tools.jl`:
  - `_boolean_argument(arguments, name; default::Union{Nothing,Bool} = nothing)::Union{Nothing,Bool}`
  - `_choice_argument(arguments, name, allowed::Array{String,1}; default = nothing, required = false)::Union{Nothing,String}`
  - `_time_argument(arguments, name; required = false)::Union{Nothing,String}`, which accepts `yyyy-mm-dd` or an RFC 3339 time and returns the text unchanged after checking it
  - `_text_list_argument(arguments, name; required = true, uppercase_items = false)::Union{Nothing,Array{String,1}}` (for ISINs, markets and activity types; `_symbols_argument` stays for ticker symbols)
  - `_table_result(df::DataFrames.DataFrame, key::String)::Dict{String,Any}`, which returns `Dict(key => _rows(df), "count" => n)`
- Produces, in `src/Server.jl`: when a handler's result has the key `"image_png"` (a `Vector{UInt8}`), `_call_tool` returns `content = [{"type": "image", "data": <base64>, "mimeType": "image/png"}]`, then one text block with the other keys as JSON, and no `structuredContent`.
- Produces, per area file: `_add_<area>_tools!(tools::Array{MyMCPToolModel,1})::Nothing`.

- [ ] **Step 1: Record the current tool list.** Before any edit, run the server's `tools/list` through `process_message` with a configuration that has only `setup_error`, and save the JSON, sorted by tool name, to a file in the session scratchpad.
- [ ] **Step 2: Write `check_offline.jl`.** It activates the scratch environment, includes `alpaca-mcp/src/AlpacaMCP.jl`, builds the server with `Dict{String,Any}("setup_error" => "offline check")`, and checks: the tool names are unique; each input schema has `type == "object"`, `additionalProperties == false`, and every `required` name in `properties`; and each tool, called with the argument `{"not_an_argument": 1}`, returns `isError == true` with a message that starts `ArgumentError: unknown argument`; and the description of each write tool that exists (`update_account_configurations`, `submit_order`, `submit_option_order`, `submit_crypto_order`, `replace_order`, `cancel_order`, `cancel_all_orders`, `close_position`, `close_all_positions`, `exercise_option`, `do_not_exercise_option`, `create_watchlist`, `update_watchlist`, `add_to_watchlist`, `remove_from_watchlist`, `delete_watchlist`) starts with one of Submit, Replace, Cancel, Close, Exercise, Tell, Update, Create, Add, Remove, Delete. It prints the number of tools and exits non-zero on any failure.
- [ ] **Step 3: Run it on the current code.** Expected: `11 tools, all checks pass`.
- [ ] **Step 4: Move the 11 existing tools, unchanged, into the area files**, add the helpers and the image branch, and update the file map comment in `Include.jl`.
- [ ] **Step 5: Prove nothing changed.** Re-run Step 1's export and `diff` it against the saved file. Expected: no difference. Re-run `check_offline.jl`. Expected: `11 tools, all checks pass`.
- [ ] **Step 6: Add a test of the image branch** to `check_offline.jl`: a server holding one test tool whose handler returns `Dict("image_png" => UInt8[0x89, 0x50, 0x4e, 0x47], "symbol" => "AAPL")` gives content type `"image"`, `data == "iVBORw=="`, and `mimeType == "image/png"`.
- [ ] **Step 7: Commit** with a temporary index: `Restructure the L14a Alpaca server's tools by area, and add shared argument helpers and image results`.

### Task 2: Account, calendar and clock, assets and contracts

**Files:**
- Modify: `alpaca-mcp/src/catalog/Account.jl`
- Test: `lectures/instructor/alpaca-mcp-checks/check_offline.jl` (expected tool count)

**Interfaces:**
- Consumes: Task 1 helpers; SDK models `MyAccountConfigurationsEndpointModel`, `MyUpdateAccountConfigurationsEndpointModel`, `MyAccountActivitiesEndpointModel`, `MyPortfolioHistoryEndpointModel`, `MyCalendarEndpointModel`, `MyMarketCalendarEndpointModel`, `MyMarketClocksEndpointModel`, `MyAssetsEndpointModel(; status, asset_class)`, `MyOptionContractsEndpointModel`, `MyOptionContractEndpointModel`.
- Produces: the 13 tools of the `Account.jl` row. `get_assets` takes `status` and `asset_class` (`us_equity`, `us_option`, `crypto`) and adds a `search` text argument that keeps only the rows whose symbol or name contains it (case-insensitive), because the full asset list is far longer than 300 rows. `update_account_configurations` takes the eight fields of the SDK model, at least one required.

- [ ] **Step 1: Raise the expected tool count** in `check_offline.jl` to 21 and run it. Expected: FAIL, 11 tools.
- [ ] **Step 2: Implement the new tools.**
- [ ] **Step 3: Run `check_offline.jl`.** Expected: `21 tools, all checks pass`.
- [ ] **Step 4: Commit** (temporary index): `Add the account, calendar, clock, asset, and contract tools`.

### Task 3: Orders and positions

**Files:**
- Modify: `alpaca-mcp/src/catalog/Orders.jl`

**Interfaces:**
- Consumes: `submit(client, MyEquityOrderModel; ..., order_class, take_profit_limit_price, stop_loss_stop_price, stop_loss_limit_price)`, `submit(client, MyCryptoOrderModel; type, time_in_force, limit_price, stop_price, client_order_id)`, `submit(client, leg::MyOptionLegModel; qty, type, time_in_force, limit_price)`, `submit(client, legs::Vector{MyOptionLegModel}; qty, type, limit_price)`, `MyReplaceOrderEndpointModel`, `close(client, symbol; qty, percentage)`, `close(client; all = true, cancel_orders)`, `MyPositionEndpointModel`, `MyExerciseOptionEndpointModel`, `MyDoNotExerciseOptionEndpointModel`.
- Produces: the 14 tools of the `Orders.jl` row. `submit_order` keeps today's arguments and defaults and adds `stop_price`, `trail_price`, `trail_percent`, `extended_hours`, `client_order_id`, `order_class`, `take_profit_limit_price`, `stop_loss_stop_price`, `stop_loss_limit_price`; `type` and `time_in_force` widen to the SDK's allowed values. `submit_option_order` takes `legs` (1 to 4 objects with `symbol`, `side`, `ratio`), `qty` (whole contracts), `type`, `limit_price` (USD per contract unit, as Alpaca quotes it), `time_in_force`. Each order tool returns `_order_summary`.

- [ ] **Step 1: Raise the expected count** to 29 in `check_offline.jl`, and add two argument checks that run before any request: `submit_option_order` with 5 legs returns `isError` with a message naming the 4-leg limit, and `submit_crypto_order` with `time_in_force = "day"` returns `isError`. Run. Expected: FAIL.
- [ ] **Step 2: Implement.**
- [ ] **Step 3: Run `check_offline.jl`.** Expected: `29 tools, all checks pass`.
- [ ] **Step 4: Commit** (temporary index): `Add the option, crypto, replace, position, and exercise tools`.

### Task 4: Watchlists, stocks, and non-US stocks

**Files:**
- Modify: `alpaca-mcp/src/catalog/Watchlists.jl`, `alpaca-mcp/src/catalog/Stocks.jl`

**Interfaces:**
- Consumes: the SDK watchlist models (Task 4 of the SDK plan), `MyStockBarsEndpointModel`, `MyStockQuotesEndpointModel`, `MyStockTradesEndpointModel`, `MyStockLatestBarsEndpointModel`, `MyStockLatestQuotesEndpointModel`, `MyStockLatestTradesEndpointModel`, `MyStockSnapshotsEndpointModel`, `MyStockAuctionsEndpointModel`, `MyStockConditionsEndpointModel`, `MyStockExchangesEndpointModel`, and the seven `MyGlobalStock...EndpointModel` types.
- Produces: the 7 watchlist tools and the 17 stock tools. `get_bars` replaces `get_daily_bars`, with the same arguments plus `timeframe` (default `1Day`). `get_latest_quotes` keeps its result keys (`quotes`, `symbols_without_quote`) and now makes one request for all symbols. The watchlist tools that take a watchlist accept `watchlist_id` or `name`, exactly one. Alpaca's watchlist update replaces the whole list, so `update_watchlist` called without `symbols` first reads the watchlist and sends its current symbols back, and a rename keeps the list.

- [ ] **Step 1: Raise the expected count** to 51 and add a check that `get_daily_bars` is gone and `get_bars` takes `timeframe`. Run. Expected: FAIL.
- [ ] **Step 2: Implement.**
- [ ] **Step 3: Run `check_offline.jl`.** Expected: `51 tools, all checks pass`.
- [ ] **Step 4: Commit** (temporary index): `Add the watchlist, stock, and non-US stock tools`.

### Task 5: Options data, crypto data, and market-wide data

**Files:**
- Modify: `alpaca-mcp/src/catalog/Options.jl`, `alpaca-mcp/src/catalog/Crypto.jl`, `alpaca-mcp/src/catalog/MarketData.jl`

**Interfaces:**
- Consumes: the option, crypto and market-data models of SDK plan Tasks 9 and 10, plus the existing option read models.
- Produces: the 23 tools of these three rows. `get_logo` returns `Dict("image_png" => bytes, "symbol" => symbol)`. `get_news` defaults to `limit = 10` and `include_content = false`, so one result stays short. Its description says how to get older articles: pass the `created_at` of the last article as `end`.

- [ ] **Step 1: Raise the expected count** to 74 and run. Expected: FAIL.
- [ ] **Step 2: Implement.**
- [ ] **Step 3: Run `check_offline.jl`.** Expected: `74 tools, all checks pass`.
- [ ] **Step 4: Commit** (temporary index): `Add the option data, crypto data, news, screener, corporate action, logo, and fixed income tools`.

### Task 6: Instructions, README, live checks

**Files:**
- Modify: `alpaca-mcp/src/Catalog.jl` (`SERVER_INSTRUCTIONS`, server version `0.2.0`), `alpaca-mcp/README.md` (the tool list under "Setup and Prerequisites", and "The Server Code" bullets), `lectures/week-14/L14a/figs/Fig-L14a-PaperTrading-Schematic.tex` (source comment only: "three of its eleven tools" becomes "three of its tools"; no redraw)
- Create: `lectures/instructor/alpaca-mcp-checks/check_live.jl`

**Interfaces:**
- Consumes: everything above.

- [ ] **Step 1: Instructions.** Rewrite `SERVER_INSTRUCTIONS` for all asset classes: the units of each, UTC times, IEX quotes for stocks, crypto trading around the clock, and "Submit, replace, cancel, close, or exercise, and change settings or watchlists, only after the user asks for it." Keep the existing sentences that still hold.
- [ ] **Step 2: README.** Replace "offers eleven tools" and the three bullets with the count and one bullet per area (account, orders and positions, watchlists, stocks, options, crypto, news and other market data), naming the most-used tools of each area. Update "The Server Code" bullets for `src/catalog/`. Check the edit against the voice rules (full sentences, exact terms, no hedging) and check that the word count of the changed section grows by no more than the new areas need.
- [ ] **Step 3: Write `check_live.jl`.** It activates the scratch environment, reads `ALPACA_CREDENTIALS` or `~/Desktop/julia_work/alpaca-markets-sdk/conf/apidata.toml`, builds the real server, and calls every read tool once through `process_message` with small arguments (e.g., `get_crypto_orderbooks` on `["BTC/USD"]`, `get_news` on `["AAPL"]` with `limit = 3`, `get_logo` on `AAPL`, `get_asset` on `BTC/USD`). It also calls `get_assets` with no `search` and expects the row-cap message. It prints one line per tool: `ok`, `skipped (403: <message>)` for a data subscription the paper plan lacks, or `FAIL <message>`. It never prints the key or the secret.
- [ ] **Step 4: Run `check_live.jl`.** Expected: no `FAIL`. Report the skipped tools. The SDK's live run on 2026-11-21 showed the course paper account gets HTTP 403 "Subscription does not permit ..." for the seven `get_global_stock_*` tools, `get_logo`, and both fixed-income tools, so expect those ten as skips.
- [ ] **Step 5: Live write checks**, only with `ALPACA_LIVE_WRITE=1`, in `check_live.jl`: the watchlist lifecycle (create, add, remove, rename without `symbols` and check that the added symbol is still there, delete); a `gtc` crypto limit buy of `BTC/USD` at half the latest bid, `replace_order` to a new limit, `cancel_order`, waiting about 3 seconds between these three calls (Alpaca answers HTTP 422 "pending replacement" when an order changes again before it has accepted the last change); `update_account_configurations` with the current value of `trade_confirm_email`. A cleanup block deletes the watchlist and cancels the order on any failure. Expected: all `ok`.
- [ ] **Step 6: Commit** (temporary index): `Update the L14a Alpaca server instructions and README for the full tool set, and add live checks`.

### Task 7: Point the course environment at SDK 0.5.0 (after Jeff's go-ahead to push the SDK)

**Files:**
- Modify: `Manifest.toml` (repository root)

- [ ] **Step 1: Wait for the go-ahead.** The SDK branch is merged to `main` and pushed only after Jeff says so.
- [ ] **Step 2: Update.** From the repository root, run `julia --project=. -e 'import Pkg; Pkg.update("Alpaca")'`. Expected: `Alpaca v0.5.0` in the output. Run `git diff --stat Manifest.toml`. Expected: only the `Alpaca` entry changes.
- [ ] **Step 3: Check the real entry point.** Pipe an `initialize` request and a `tools/list` request into `julia --startup-file=no lectures/week-14/L14a/alpaca-mcp/server.jl`. Expected: two responses on standard output, and the second lists 74 tools. Then run `check_offline.jl` and `check_live.jl` against the course environment, not the scratch one.
- [ ] **Step 4: Commit** (temporary index, `Manifest.toml` only): `Use Alpaca SDK 0.5.0 in the course environment`. Do not push until Jeff says so.

## Review Focus

1. **A crypto pair in a tool argument.** `get_position`, `close_position` and `get_asset` with `BTC/USD` must reach Alpaca, and `_symbols_argument` must not split or mangle the slash. `check_live.jl` calls `get_asset` with `BTC/USD`.
2. **A result that is too long.** `get_assets` with no `search`, `get_option_chain` on SPY, and `get_news` with content can pass 300 rows or become very long. Each must fail with the row-cap message that tells the model how to ask for less, never a truncated table. `check_live.jl` calls `get_assets` with no `search` and expects that message.
3. **A data feed that the paper plan lacks.** A 403 must reach the model as a readable tool error, not crash the server. `check_live.jl` reports these calls as skipped, and the error path is the existing one.
4. **A write the user did not ask for.** Every write tool's description says it changes the account. `check_offline.jl` checks that each write tool's description starts with a verb that names the change (Submit, Replace, Cancel, Close, Exercise, Update, Create, Add, Remove, Delete).
5. **The renamed bar tool.** A user who follows an old prompt that names `get_daily_bars` gets an "Unknown tool" error. The README is the only student text that names the tool, and Task 6 updates it.
