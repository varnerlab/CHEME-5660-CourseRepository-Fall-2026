# =============================================================================
# CHEME 5660 | L14a Alpaca server checks: the live check
# =============================================================================
# Run this file after the offline check passes. It builds the real server with
# the credentials of your paper account, and calls every read tool once through
# the server. It prints one line for each tool:
#
#   ok                        the tool returned a result
#   skipped (403: <message>)  the paper plan has no subscription for this data
#   not exercised (<reason>)  the account has no data for this tool, e.g., no watchlist
#   FAIL <message>            the tool returned any other error
#
#   julia --startup-file=no lectures/instructor/alpaca-mcp-checks/check_live.jl
#
# The credentials come from ALPACA_CREDENTIALS, or from the conf/apidata.toml
# of the Alpaca SDK checkout. The script never prints the key or the secret.
# When you set ALPACA_LIVE_WRITE=1, the script also runs the write block: a
# watchlist from create to delete, a crypto limit order that it submits,
# replaces, and cancels, an update of the account configuration with its
# current value, and a 10 USD market buy of BTC/USD that it reads as a position
# and closes. These calls change the paper account, and the script undoes
# them. The buy and the close leave a few cents of fees and price change in
# the cash. The script ends with the counts, and exits with a non-zero code
# when any tool fails.
# =============================================================================
include(joinpath(@__DIR__, "course_env.jl"));
include(joinpath(COURSE_ROOT, "lectures", "week-14", "L14a", "alpaca-mcp", "src", "AlpacaMCP.jl"));

# the credentials file of the Alpaca SDK checkout, used when ALPACA_CREDENTIALS is not set -
const ALPACA_SDK_CREDENTIALS = expanduser("~/Desktop/julia_work/alpaca-markets-sdk/conf/apidata.toml");
import JSON
import Dates
using .L14aAlpacaMCP

# the pause between a submit, a replace, and a cancel. Alpaca answers HTTP 422 "pending replacement" when an order
# changes again before Alpaca has accepted the last change -
const ORDER_WAIT_SECONDS = 3;

# the crypto position block: the size of the market buy, and how many times we read the position before a FAIL -
const POSITION_NOTIONAL_USD = 10.0;
const POSITION_TRIES = 10;

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# Call one tool through the server. The result is a dictionary with the keys "error" (true when the tool failed),
# "text" (the error message, or the result as JSON text), and "data" (the result as a dictionary, or empty) -
function _call(server::MyMCPServerModel, name::String, arguments::Dict{String,Any})::Dict{String,Any}

    # send the request -
    params = Dict{String,Any}("name" => name, "arguments" => arguments);
    message = Dict{String,Any}("jsonrpc" => "2.0", "id" => 1, "method" => "tools/call", "params" => params);
    response = process_message(server, JSON.json(message));

    # a response with an error object is a failed call -
    if (haskey(response, "error") == true)
        return Dict{String,Any}("error" => true, "text" => response["error"]["message"], "data" => Dict{String,Any}());
    end

    # read the result -
    result = response["result"];
    text = result["content"][1]["text"];
    data = Dict{String,Any}();
    if (haskey(result, "structuredContent") == true)
        data = result["structuredContent"];
    end
    return Dict{String,Any}("error" => result["isError"], "text" => text, "data" => data);
end

# Is the error text a 403 for a data subscription that the paper plan lacks? The SDK prints a failed request as
# AlpacaError(status=403, code=...): <message> -
function _is_subscription_error(text::String)::Bool

    return occursin("status=403", text) && occursin("subscription", lowercase(text));
end

# Record the outcome of one call in the counts, and print one line for the tool. A call whose error text contains
# the text in expected_error is an expected outcome, and counts as ok -
function _record!(counts::Dict{String,Int64}, label::String, call::Dict{String,Any};
    expected_error::String = "")::Nothing

    if (call["error"] == false && isempty(expected_error) == false)
        counts["FAIL"] += 1;
        println(rpad(label, 34), "FAIL expected the row-cap error, and the call returned a result");
    elseif (call["error"] == false)
        counts["ok"] += 1;
        println(rpad(label, 34), "ok");
    elseif (isempty(expected_error) == false && occursin(expected_error, call["text"]) == true)
        counts["ok"] += 1;
        println(rpad(label, 34), "ok (the row-cap message: ", first(call["text"], 60), "...)");
    elseif (_is_subscription_error(call["text"]) == true)
        counts["skipped for subscription"] += 1;
        println(rpad(label, 34), "skipped (403: ", call["text"], ")");
    else
        counts["FAIL"] += 1;
        println(rpad(label, 34), "FAIL ", call["text"]);
    end
    return nothing;
end

# Call one tool, and record the outcome -
function _check_tool!(server::MyMCPServerModel, counts::Dict{String,Int64}, name::String,
    arguments::Dict{String,Any}; expected_error::String = "", label::String = "")::Dict{String,Any}

    # the line shows the label when we give one, and the tool name otherwise -
    line_label = label;
    if (isempty(label) == true)
        line_label = name;
    end
    call = _call(server, name, arguments);
    _record!(counts, line_label, call; expected_error = expected_error);
    return call;
end

# Record a tool that we could not call, and count it as not exercised, because the account holds nothing to ask about -
function _skip_tool!(counts::Dict{String,Int64}, name::String, reason::String)::Nothing

    counts["not exercised"] += 1;
    println(rpad(name, 34), "not exercised (", reason, ")");
    return nothing;
end

# The first row of the list under key_name in a result, or an empty dictionary when the list is empty -
function _first_row(data::Dict{String,Any}, key_name::String)::Dict{String,Any}

    rows = get(data, key_name, Any[]);
    if (isempty(rows) == false)
        return Dict{String,Any}(rows[1]);
    end
    return Dict{String,Any}();
end

# The most recent weekday before today, as a date. Stock markets are closed on Saturday and Sunday, so a request for
# stock data asks for the last session -
function _last_weekday()::Dates.Date

    day = Dates.today() - Dates.Day(1);
    while (Dates.dayofweek(day) > 5)
        day = day - Dates.Day(1);
    end
    return day;
end

# Check every read tool once. The counts hold the outcomes. The function returns nothing -
function _check_reads!(server::MyMCPServerModel, counts::Dict{String,Int64})::Nothing

    # the dates that the calls use. The windows are on the last weekday, so they are valid on a weekend -
    session = _last_weekday();
    session_start = "$(session)T16:00:00Z";
    session_end = "$(session)T16:00:01Z";
    week_start = string(session - Dates.Day(7));
    week_end = string(session);
    expiration_start = string(Dates.today() + Dates.Day(7));
    expiration_end = string(Dates.today() + Dates.Day(21));

    # the account -
    println("--- the account");
    _check_tool!(server, counts, "get_account", Dict{String,Any}());
    _check_tool!(server, counts, "get_account_configurations", Dict{String,Any}());
    _check_tool!(server, counts, "get_account_activities", Dict{String,Any}("page_size" => 5));
    _check_tool!(server, counts, "get_portfolio_history", Dict{String,Any}("period" => "1W", "timeframe" => "1D"));
    _check_tool!(server, counts, "get_clock", Dict{String,Any}());
    _check_tool!(server, counts, "get_calendar", Dict{String,Any}("start" => week_start, "end" => week_end));
    _check_tool!(server, counts, "get_market_calendar", Dict{String,Any}("market" => "NYSE", "start" => week_start,
        "end" => week_end));
    _check_tool!(server, counts, "get_market_clocks", Dict{String,Any}());
    _check_tool!(server, counts, "get_assets", Dict{String,Any}(); expected_error = "search argument");
    _check_tool!(server, counts, "get_assets", Dict{String,Any}("search" => "apple"); label = "get_assets (search)");
    _check_tool!(server, counts, "get_asset", Dict{String,Any}("symbol" => "BTC/USD"));

    # the orders and the positions. get_order, get_position, and get_watchlist need something that exists in the
    # account, so we read the id or the symbol from the list first -
    println("--- the orders, positions, and watchlists");
    orders = _check_tool!(server, counts, "get_orders", Dict{String,Any}("status" => "all", "limit" => 5));
    order_row = _first_row(orders["data"], "orders");
    if (haskey(order_row, "id") == true)
        _check_tool!(server, counts, "get_order", Dict{String,Any}("order_id" => order_row["id"]));
    else
        _skip_tool!(counts, "get_order", "the account has no order to read");
    end
    positions = _check_tool!(server, counts, "get_positions", Dict{String,Any}());
    position_row = _first_row(positions["data"], "positions");
    if (haskey(position_row, "symbol") == true)
        _check_tool!(server, counts, "get_position", Dict{String,Any}("symbol" => position_row["symbol"]));
    else
        _skip_tool!(counts, "get_position", "the account has no position to read");
    end
    watchlists = _check_tool!(server, counts, "get_watchlists", Dict{String,Any}());
    watchlist_row = _first_row(watchlists["data"], "watchlists");
    if (haskey(watchlist_row, "id") == true)
        _check_tool!(server, counts, "get_watchlist", Dict{String,Any}("watchlist_id" => watchlist_row["id"]));
    else
        _skip_tool!(counts, "get_watchlist", "the account has no watchlist to read");
    end

    # the stocks -
    println("--- the stocks");
    _check_tool!(server, counts, "get_bars", Dict{String,Any}("symbols" => ["AAPL"], "timeframe" => "1Day",
        "start" => week_start, "end" => week_end));
    _check_tool!(server, counts, "get_quotes", Dict{String,Any}("symbols" => ["AAPL"], "start" => session_start,
        "end" => session_end));
    _check_tool!(server, counts, "get_trades", Dict{String,Any}("symbols" => ["AAPL"], "start" => session_start,
        "end" => session_end));
    _check_tool!(server, counts, "get_latest_bars", Dict{String,Any}("symbols" => ["AAPL"]));
    latest_trades = _check_tool!(server, counts, "get_latest_trades", Dict{String,Any}("symbols" => ["SPY"]));
    _check_tool!(server, counts, "get_latest_quotes", Dict{String,Any}("symbols" => ["AAPL"]));
    _check_tool!(server, counts, "get_snapshots", Dict{String,Any}("symbols" => ["AAPL"]));
    _check_tool!(server, counts, "get_auctions", Dict{String,Any}("symbols" => ["AAPL"], "start" => week_start,
        "end" => week_end));
    _check_tool!(server, counts, "get_stock_conditions", Dict{String,Any}("ticktype" => "trade", "tape" => "A"));
    _check_tool!(server, counts, "get_stock_exchanges", Dict{String,Any}());

    # the stocks outside the US. A paper plan without the subscription gets HTTP 403 -
    println("--- the stocks outside the US");
    _check_tool!(server, counts, "get_global_stock_bars", Dict{String,Any}("symbols" => ["SAP:XETR"],
        "feed" => "xetr", "start" => week_start, "end" => week_end));
    _check_tool!(server, counts, "get_global_stock_quotes", Dict{String,Any}("symbols" => ["SAP:XETR"],
        "feed" => "xetr", "start" => session_start, "end" => session_end));
    _check_tool!(server, counts, "get_global_stock_trades", Dict{String,Any}("symbols" => ["SAP:XETR"],
        "feed" => "xetr", "start" => session_start, "end" => session_end));
    for name ∈ ["get_global_stock_latest_bars", "get_global_stock_latest_quotes", "get_global_stock_latest_trades",
        "get_global_stock_snapshots"]
        _check_tool!(server, counts, name, Dict{String,Any}("symbols" => ["SAP:XETR"], "feed" => "xetr"));
    end

    # the options. The strikes come from the latest price of SPY, and the contract symbol from the contracts -
    println("--- the options");
    strike_low = 600.0;
    strike_high = 800.0;
    trade_row = _first_row(latest_trades["data"], "trades");
    if (haskey(trade_row, "price") == true)
        strike_low = floor(trade_row["price"]) - 1.0;
        strike_high = floor(trade_row["price"]) + 1.0;
    end
    option_arguments = Dict{String,Any}("underlying_symbols" => ["SPY"], "type" => "call",
        "strike_price_gte" => strike_low, "strike_price_lte" => strike_high, "expiration_date_gte" => expiration_start,
        "expiration_date_lte" => expiration_end);
    contracts = _check_tool!(server, counts, "get_option_contracts", option_arguments);
    contract_row = _first_row(contracts["data"], "contracts");
    if (haskey(contract_row, "symbol") == true)
        option_symbol = contract_row["symbol"];
        _check_tool!(server, counts, "get_option_contract", Dict{String,Any}("symbol" => option_symbol));
        _check_tool!(server, counts, "get_option_bars", Dict{String,Any}("symbols" => [option_symbol],
            "timeframe" => "1Day", "start" => week_start, "end" => week_end));
        _check_tool!(server, counts, "get_option_trades", Dict{String,Any}("symbols" => [option_symbol],
            "start" => week_start, "end" => week_end));
        _check_tool!(server, counts, "get_option_latest_quotes", Dict{String,Any}("symbols" => [option_symbol]));
        _check_tool!(server, counts, "get_option_latest_trades", Dict{String,Any}("symbols" => [option_symbol]));
        _check_tool!(server, counts, "get_option_snapshots", Dict{String,Any}("symbols" => [option_symbol]));
    else
        for name ∈ ["get_option_contract", "get_option_bars", "get_option_trades", "get_option_latest_quotes",
            "get_option_latest_trades", "get_option_snapshots"]
            _skip_tool!(counts, name, "get_option_contracts found no SPY contract");
        end
    end
    _check_tool!(server, counts, "get_option_chain", Dict{String,Any}("underlying" => "SPY", "type" => "call",
        "strike_price_gte" => strike_low, "strike_price_lte" => strike_high, "expiration_date_gte" => expiration_start,
        "expiration_date_lte" => expiration_end));
    _check_tool!(server, counts, "get_option_exchanges", Dict{String,Any}());
    _check_tool!(server, counts, "get_option_conditions", Dict{String,Any}("ticktype" => "trade"));

    # the crypto. Crypto trades all week, so the last day is a valid window -
    println("--- the crypto");
    crypto_start = "$(Dates.today() - Dates.Day(1))T00:00:00Z";
    crypto_end = "$(Dates.today() - Dates.Day(1))T00:00:20Z";
    _check_tool!(server, counts, "get_crypto_bars", Dict{String,Any}("symbols" => ["BTC/USD"], "timeframe" => "1Hour",
        "start" => crypto_start, "end" => "$(Dates.today())T00:00:00Z"));
    _check_tool!(server, counts, "get_crypto_quotes", Dict{String,Any}("symbols" => ["BTC/USD"],
        "start" => crypto_start, "end" => crypto_end));
    _check_tool!(server, counts, "get_crypto_trades", Dict{String,Any}("symbols" => ["BTC/USD"],
        "start" => crypto_start, "end" => crypto_end));
    for name ∈ ["get_crypto_latest_bars", "get_crypto_latest_quotes", "get_crypto_latest_trades",
        "get_crypto_orderbooks", "get_crypto_snapshots"]
        _check_tool!(server, counts, name, Dict{String,Any}("symbols" => ["BTC/USD"]));
    end

    # the news and the other market data -
    println("--- the news and the other market data");
    _check_tool!(server, counts, "get_news", Dict{String,Any}("symbols" => ["AAPL"], "limit" => 3));
    _check_tool!(server, counts, "get_most_actives", Dict{String,Any}("by" => "volume", "top" => 5));
    _check_tool!(server, counts, "get_movers", Dict{String,Any}("top" => 5));
    _check_tool!(server, counts, "get_corporate_actions", Dict{String,Any}("symbols" => ["AAPL"],
        "start" => string(Dates.today() - Dates.Day(90)), "end" => string(Dates.today())));
    _check_tool!(server, counts, "get_logo", Dict{String,Any}("symbol" => "AAPL"));
    _check_tool!(server, counts, "get_fixed_income_prices", Dict{String,Any}("isins" => ["US912828ZT04"]));
    _check_tool!(server, counts, "get_fixed_income_quotes", Dict{String,Any}("isins" => ["US912828ZT04"]));
    return nothing;
end

# Run the write block: the watchlist lifecycle, the crypto order, and the account configuration. A step that fails
# is a FAIL, and the cleanup at the end removes what the block created. The function returns nothing -
function _check_writes!(server::MyMCPServerModel, counts::Dict{String,Int64})::Nothing

    println("--- the write block");
    watchlist_name = "mcp-live-" * Dates.format(Dates.now(), "yyyymmddHHMMSS");
    renamed_name = watchlist_name * "-renamed";
    watchlist_exists = false;
    client_id = "mcp-live-" * Dates.format(Dates.now(), "yyyymmddHHMMSS"); # marks every order of this run
    order_id = "";
    order_open = false;

    try

        # the watchlist lifecycle: create with AAPL, add MSFT, remove MSFT, rename without symbols, delete -
        call = _check_tool!(server, counts, "create_watchlist", Dict{String,Any}("name" => watchlist_name,
            "symbols" => ["AAPL"]));
        if (call["error"] == false)
            watchlist_exists = true;
        end
        _check_tool!(server, counts, "add_to_watchlist", Dict{String,Any}("name" => watchlist_name,
            "symbol" => "MSFT"));
        _check_tool!(server, counts, "remove_from_watchlist", Dict{String,Any}("name" => watchlist_name,
            "symbol" => "MSFT"));
        call = _check_tool!(server, counts, "update_watchlist", Dict{String,Any}("name" => watchlist_name,
            "new_name" => renamed_name); label = "update_watchlist (rename)");
        if (call["error"] == false)
            watchlist_name = renamed_name;
        end

        # the rename must keep AAPL. get_watchlist also gets its call here, because the account may have no
        # watchlist when the read block runs -
        call = _check_tool!(server, counts, "get_watchlist", Dict{String,Any}("name" => watchlist_name));
        if (call["error"] == false)
            symbols = String[];
            for asset ∈ get(call["data"], "assets", Any[])
                push!(symbols, string(asset["symbol"]));
            end
            if (symbols == ["AAPL"])
                counts["ok"] += 1;
                println(rpad("rename keeps the symbols", 34), "ok (AAPL is still there)");
            else
                counts["FAIL"] += 1;
                println(rpad("rename keeps the symbols", 34), "FAIL the symbols are $(symbols), not [\"AAPL\"]");
            end
        end
        call = _check_tool!(server, counts, "delete_watchlist", Dict{String,Any}("name" => watchlist_name));
        if (call["error"] == false)
            watchlist_exists = false;
        end

        # the crypto order: a gtc limit buy at half of the latest bid, so it does not fill -
        call = _check_tool!(server, counts, "get_crypto_latest_quotes", Dict{String,Any}("symbols" => ["BTC/USD"]);
            label = "get_crypto_latest_quotes (bid)");
        bid = 0.0;
        for quote_row ∈ get(call["data"], "quotes", Any[])
            bid = Float64(quote_row["bid_price"]);
        end
        if (bid > 0.0)
            call = _check_tool!(server, counts, "submit_crypto_order", Dict{String,Any}("symbol" => "BTC/USD",
                "side" => "buy", "type" => "limit", "time_in_force" => "gtc", "qty" => 0.001,
                "limit_price" => round(0.5 * bid; digits = 2), "client_order_id" => client_id));
            if (call["error"] == false)
                order_open = true; # set first, so the cleanup finds the order even when we cannot read its id
                order_id = call["data"]["order"]["id"];
            end
        end
        if (bid <= 0.0)
            for step_name ∈ ["submit_crypto_order", "replace_order", "cancel_order"]
                _skip_tool!(counts, step_name, "no BTC/USD bid");
            end
        end
        if (isempty(order_id) == false)
            sleep(ORDER_WAIT_SECONDS);
            _check_tool!(server, counts, "get_order", Dict{String,Any}("order_id" => order_id); label = "get_order (the new order)");
            call = _check_tool!(server, counts, "replace_order", Dict{String,Any}("order_id" => order_id,
                "limit_price" => round(0.45 * bid; digits = 2), "client_order_id" => client_id * "-replaced"));
            if (call["error"] == false)
                order_id = call["data"]["order"]["id"]; # a replacement is a new order with a new id
            end
            sleep(ORDER_WAIT_SECONDS);
            call = _check_tool!(server, counts, "cancel_order", Dict{String,Any}("order_id" => order_id));
            if (call["error"] == false)
                order_open = false;
            end
        end

        # the account configuration, changed to the value that it already has -
        call = _call(server, "get_account_configurations", Dict{String,Any}());
        if (call["error"] == false)
            current = call["data"]["account_configurations"]["trade_confirm_email"];
            _check_tool!(server, counts, "update_account_configurations", Dict{String,Any}(
                "trade_confirm_email" => current));
        end
    catch exception
        counts["FAIL"] += 1;
        println(rpad("write block", 34), "FAIL ", sprint(showerror, exception));
    finally

        # the cleanup: delete the watchlist and cancel the order if a step left them behind. Each step has its own
        # try, so one failure does not stop the other -
        if (watchlist_exists == true)
            try
                _check_tool!(server, counts, "delete_watchlist", Dict{String,Any}("name" => watchlist_name);
                    label = "cleanup: delete_watchlist");
            catch exception
                counts["FAIL"] += 1;
                println(rpad("cleanup: delete_watchlist", 34), "FAIL ", sprint(showerror, exception));
            end
        end
        if (order_open == true)
            try
                sleep(ORDER_WAIT_SECONDS);
                open_orders = _call(server, "get_orders", Dict{String,Any}("status" => "open", "symbols" => ["BTC/USD"]));
                for row ∈ get(open_orders["data"], "orders", Any[])
                    if (startswith(string(get(row, "client_order_id", "")), "mcp-live-") == true)
                        _check_tool!(server, counts, "cancel_order", Dict{String,Any}("order_id" => row["id"]);
                            label = "cleanup: cancel_order");
                    end
                end
            catch exception
                counts["FAIL"] += 1;
                println(rpad("cleanup: cancel_order", 34), "FAIL ", sprint(showerror, exception));
            end
        end
    end

    # the cleanup check: no mcp-live- watchlist and no open BTC/USD order with an mcp-live- client order id remain -
    sleep(ORDER_WAIT_SECONDS);
    watchlists = _call(server, "get_watchlists", Dict{String,Any}());
    leftover_watchlist = false;
    for row ∈ get(watchlists["data"], "watchlists", Any[])
        if (startswith(string(get(row, "name", "")), "mcp-live-") == true)
            leftover_watchlist = true;
        end
    end
    orders = _call(server, "get_orders", Dict{String,Any}("status" => "open", "symbols" => ["BTC/USD"]));
    leftover_order = false;
    for row ∈ get(orders["data"], "orders", Any[])
        if (startswith(string(get(row, "client_order_id", "")), "mcp-live-") == true)
            leftover_order = true;
        end
    end
    if (watchlists["error"] == true || orders["error"] == true)
        counts["FAIL"] += 1;
        println(rpad("cleanup check", 34), "FAIL could not read the watchlists or the orders");
    elseif (leftover_watchlist == false && leftover_order == false)
        counts["ok"] += 1;
        println(rpad("cleanup check", 34), "ok (no mcp-live- watchlist and no open BTC/USD order from this run remain)");
    else
        counts["FAIL"] += 1;
        println(rpad("cleanup check", 34), "FAIL a watchlist or an order of this run remains");
    end
    return nothing;
end

# Read the BTC/USD position until it answers as we want: open (expect_open = true) or gone (expect_open = false).
# The function asks up to POSITION_TRIES times, with a pause between tries, and returns the last call -
function _wait_for_position(server::MyMCPServerModel, expect_open::Bool)::Dict{String,Any}

    call = Dict{String,Any}();
    for try_number ∈ 1:POSITION_TRIES

        # read the position: an open position returns a result, and a closed one returns "position does not exist" -
        sleep(ORDER_WAIT_SECONDS);
        call = _call(server, "get_position", Dict{String,Any}("symbol" => "BTC/USD"));
        if (expect_open == true && call["error"] == false)
            return call;
        end
        if (expect_open == false && call["error"] == true && occursin("position does not exist", call["text"]) == true)
            return call;
        end
    end
    return call;
end

# Run the crypto position block: a market buy of POSITION_NOTIONAL_USD of BTC/USD, a read of the position, and a close
# of the position. The block runs only when the account holds no crypto, so it never closes a position that it did
# not open. The function returns nothing -
function _check_crypto_position!(server::MyMCPServerModel, counts::Dict{String,Int64})::Nothing

    println("--- the crypto position");
    position_open = false;

    # check that the account holds no crypto before we buy any -
    call = _call(server, "get_positions", Dict{String,Any}());
    if (call["error"] == true)
        counts["FAIL"] += 1;
        println(rpad("get_positions (before the buy)", 34), "FAIL ", call["text"]);
        return nothing;
    end
    holds_crypto = false;
    for row ∈ get(call["data"], "positions", Any[])
        if (string(get(row, "asset_class", "")) == "crypto")
            holds_crypto = true;
        end
    end
    if (holds_crypto == true)
        for step_name ∈ ["submit_crypto_order (market)", "get_position (BTC/USD)", "close_position (BTC/USD)"]
            _skip_tool!(counts, step_name, "the account already holds crypto, and the check does not touch it");
        end
        return nothing;
    end

    try

        # buy BTC/USD at market. The order fills within seconds, because crypto trades around the clock -
        client_id = "mcp-live-" * Dates.format(Dates.now(), "yyyymmddHHMMSS") * "-buy";
        call = _check_tool!(server, counts, "submit_crypto_order", Dict{String,Any}("symbol" => "BTC/USD",
            "side" => "buy", "type" => "market", "time_in_force" => "gtc", "notional" => POSITION_NOTIONAL_USD,
            "client_order_id" => client_id); label = "submit_crypto_order (market)");
        if (call["error"] == true)
            return nothing;
        end
        position_open = true; # set first, so the cleanup closes the position even when a later step fails

        # read the position by its pair, BTC/USD. Alpaca names the position BTCUSD -
        call = _wait_for_position(server, true);
        if (call["error"] == false)
            symbol = string(call["data"]["position"]["symbol"]);
            counts["ok"] += 1;
            println(rpad("get_position (BTC/USD)", 34), "ok (the position is ", symbol, ")");
        else
            counts["FAIL"] += 1;
            println(rpad("get_position (BTC/USD)", 34), "FAIL ", call["text"]);
        end

        # close the position by its pair, and read it again until it is gone -
        call = _check_tool!(server, counts, "close_position", Dict{String,Any}("symbol" => "BTC/USD");
            label = "close_position (BTC/USD)");
        if (call["error"] == false)
            call = _wait_for_position(server, false);
            if (call["error"] == true && occursin("position does not exist", call["text"]) == true)
                position_open = false;
                counts["ok"] += 1;
                println(rpad("the position is closed", 34), "ok");
            else
                counts["FAIL"] += 1;
                println(rpad("the position is closed", 34), "FAIL the BTC/USD position is still open");
            end
        end
    catch exception
        counts["FAIL"] += 1;
        println(rpad("crypto position block", 34), "FAIL ", sprint(showerror, exception));
    finally

        # the cleanup: close the position if a step left it open -
        if (position_open == true)
            try
                sleep(ORDER_WAIT_SECONDS);
                _check_tool!(server, counts, "close_position", Dict{String,Any}("symbol" => "BTC/USD");
                    label = "cleanup: close_position");
            catch exception
                counts["FAIL"] += 1;
                println(rpad("cleanup: close_position", 34), "FAIL ", sprint(showerror, exception));
            end
        end
    end
    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #

# the credentials: ALPACA_CREDENTIALS, or the file of the SDK checkout. The server code checks the paper endpoint -
credentials = get(ENV, "ALPACA_CREDENTIALS", "");
if (isempty(credentials) == true)
    credentials = ALPACA_SDK_CREDENTIALS;
end
configuration = load_server_configuration(expanduser(credentials));
if (haskey(configuration, "setup_error") == true)
    println("setup error: ", configuration["setup_error"]);
    exit(1);
end
server = build_alpaca_server(configuration);

# run the checks -
counts = Dict{String,Int64}("ok" => 0, "skipped for subscription" => 0, "not exercised" => 0, "FAIL" => 0);
_check_reads!(server, counts);
if (get(ENV, "ALPACA_LIVE_WRITE", "") == "1")
    _check_writes!(server, counts);
    _check_crypto_position!(server, counts);
else
    println("--- the write block is off. Set ALPACA_LIVE_WRITE=1 to run it");
end

# report -
println("ok: ", counts["ok"], ", skipped for subscription: ", counts["skipped for subscription"],
    ", not exercised: ", counts["not exercised"], ", FAIL: ", counts["FAIL"]);
if (counts["FAIL"] > 0)
    exit(1);
end
