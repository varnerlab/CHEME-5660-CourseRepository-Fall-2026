# =============================================================================
# CHEME 5660 | L14a Alpaca server: the tools
# =============================================================================
# The handlers of the tools come first, then build_alpaca_server(...), which
# lists each tool's name, description, input schema, and handler. A handler
# takes the arguments of the call and the configuration of the server, and
# returns its result as a dictionary. The reads return rows from the Alpaca SDK.
# The two order tools return a summary of each order.
# =============================================================================

# the instructions that the server sends to the host, which can pass them to its language model -
const SERVER_INSTRUCTIONS = """
Tools for one Alpaca paper trading account. A paper account trades simulated money at real market prices.
Read the account, the market clock, the positions, the orders, the latest quotes, and the daily bars, and submit
or cancel stock orders. Share counts are in shares, prices are in USD per share, and times are in UTC (New York
time is UTC minus 5 hours in winter and UTC minus 4 hours in summer). A paper account receives
quotes from one exchange (IEX), so its bid-ask spreads can be wider than the market's.
Before you submit orders, check the clock: an order submitted while the market is closed waits until the next open.
Submit each order only after the user asks for it.""";

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# get_account: the cash, buying power, equity, and status of the account -
function _get_account(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, String[]);
    df = Alpaca.api(_client(configuration), Alpaca.MyAccountEndpointModel());
    rows = _rows(df);
    return Dict{String,Any}("account" => rows[1]);
end

# get_clock: whether the market is open now, and the times of the next open and close -
function _get_clock(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, String[]);
    df = Alpaca.api(_client(configuration), Alpaca.MyClockEndpointModel());
    rows = _rows(df);
    return Dict{String,Any}("clock" => rows[1]);
end

# get_positions: the open positions of the account -
function _get_positions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, String[]);
    df = Alpaca.api(_client(configuration), Alpaca.MyPositionsEndpointModel());
    rows = _rows(df);
    return Dict{String,Any}("positions" => rows, "count" => length(rows));
end

# get_orders: the orders of the account with a status, newest first -
function _get_orders(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["status", "limit", "symbols"]);
    status = _text_argument(arguments, "status"; default = "open");
    if ((status in ("open", "closed", "all")) == false)
        throw(ArgumentError("the status must be open, closed, or all"));
    end
    limit = _integer_argument(arguments, "limit", 50, 1, 500);
    symbols = _symbols_argument(arguments, "symbols"; required = false);

    # call Alpaca -
    model = Alpaca.MyOrdersEndpointModel(status = status, limit = limit, symbols = symbols);
    df = Alpaca.api(_client(configuration), model);
    rows = _rows(df);
    return Dict{String,Any}("orders" => rows, "count" => length(rows));
end

# get_order: one order, by its identifier -
function _get_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["order_id"]);
    order_id = _text_argument(arguments, "order_id"; required = true);
    df = Alpaca.api(_client(configuration), Alpaca.MyOrderEndpointModel(id = order_id));
    rows = _rows(df);
    return Dict{String,Any}("order" => rows[1]);
end

# get_asset: whether a stock can be traded, bought in fractions of a share, or sold short -
function _get_asset(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    df = Alpaca.api(_client(configuration), Alpaca.MyAssetEndpointModel(symbol = symbol));
    rows = _rows(df);
    return Dict{String,Any}("asset" => rows[1]);
end

# get_latest_quotes: the latest bid and ask of each symbol -
function _get_latest_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols"]);
    symbols = _symbols_argument(arguments, "symbols");

    # one call for each symbol. A symbol without a quote is reported, and the other symbols still come back -
    client = _client(configuration);
    quotes = Array{Dict{String,Any},1}();
    missing_symbols = Array{String,1}();
    for symbol ∈ symbols
        df = nothing;
        try
            df = Alpaca.api(client, Alpaca.MyStockLatestQuoteEndpointModel(symbol = symbol));
        catch
            push!(missing_symbols, symbol);
            continue;
        end
        rows = _rows(df);
        if (isempty(rows) == true)
            push!(missing_symbols, symbol);
            continue;
        end
        row = rows[1];
        row["symbol"] = symbol;
        push!(quotes, row);
    end
    return Dict{String,Any}("quotes" => quotes, "symbols_without_quote" => missing_symbols);
end

# get_daily_bars: the daily open, high, low, close, and volume of each symbol over a range of dates -
function _get_daily_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "start", "end"]);
    symbols = _symbols_argument(arguments, "symbols");
    start = _date_argument(arguments, "start");
    finish = _date_argument(arguments, "end"; required = false);

    # call Alpaca -
    model = Alpaca.MyStockBarsEndpointModel(symbols = symbols, timeframe = "1Day", start = start, finish = finish);
    df = Alpaca.api(_client(configuration), model);
    rows = _rows(df);
    return Dict{String,Any}("bars" => rows, "count" => length(rows));
end

# submit_order: one stock order, by share count or by dollar amount, at the market or at a limit price -
function _submit_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbol", "side", "qty", "notional", "type", "limit_price", "time_in_force"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    side = _text_argument(arguments, "side"; required = true);
    qty = _number_argument(arguments, "qty"); # shares
    notional = _number_argument(arguments, "notional"); # USD
    type = _text_argument(arguments, "type"; default = "market");
    limit_price = _number_argument(arguments, "limit_price"); # USD per share
    time_in_force = _text_argument(arguments, "time_in_force"; default = "day");

    # check the order before any request -
    if ((side in ("buy", "sell")) == false)
        throw(ArgumentError("the side must be buy or sell"));
    end
    if (isnothing(qty) == isnothing(notional))
        throw(ArgumentError("give exactly one of qty (shares) and notional (USD)"));
    end
    if ((type in ("market", "limit")) == false)
        throw(ArgumentError("the type must be market or limit"));
    end
    if (type == "limit" && isnothing(limit_price) == true)
        throw(ArgumentError("a limit order needs a limit_price (USD per share)"));
    end
    if (type == "market" && isnothing(limit_price) == false)
        throw(ArgumentError("a market order takes no limit_price. Use type limit to set a price"));
    end
    if ((time_in_force in ("day", "gtc")) == false)
        throw(ArgumentError("the time_in_force must be day or gtc"));
    end

    # build the order model, and submit the order -
    order_model = nothing;
    if (isnothing(qty) == false)
        order_model = Alpaca.MyEquityOrderModel(symbol = symbol, side = side, qty = qty);
    else
        order_model = Alpaca.MyEquityOrderModel(symbol = symbol, side = side, notional = notional);
    end
    order = Alpaca.submit(_client(configuration), order_model; type = type, time_in_force = time_in_force,
        limit_price = limit_price);
    return Dict{String,Any}("order" => _order_summary(order));
end

# cancel_order: cancel one open order, by its identifier -
function _cancel_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["order_id"]);
    order_id = _text_argument(arguments, "order_id"; required = true);
    Alpaca.cancel(_client(configuration), order_id);
    return Dict{String,Any}("canceled" => order_id);
end

# cancel_all_orders: cancel every open order of the account -
function _cancel_all_orders(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, String[]);
    df = Alpaca.cancel(_client(configuration); all = true);
    rows = _rows(df);
    return Dict{String,Any}("canceled" => rows, "count" => length(rows));
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE -------------------------------------------------------------------------------- #
"""
    build_alpaca_server(configuration::Dict{String,Any}) -> MyMCPServerModel

Build the Alpaca server: its identity, its instructions, and its tools. Eight tools read the account and the market,
and three tools submit or cancel orders.

### Arguments
- `configuration::Dict{String,Any}`: the configuration from `load_server_configuration(...)`, with the Alpaca client.

### Returns
- `MyMCPServerModel`: the server, ready for `serve(...)`.
"""
function build_alpaca_server(configuration::Dict{String,Any})::MyMCPServerModel

    # initialize -
    tools = Array{MyMCPToolModel,1}();
    none = Dict{String,Any}(); # the properties of a tool that takes no arguments

    # the reads of the account -
    push!(tools, build(MyMCPToolModel, (name = "get_account",
        description = "Read the paper account: its cash, buying power, equity, and status (USD).",
        inputschema = _input_schema(none, String[]), handler = _get_account)));
    push!(tools, build(MyMCPToolModel, (name = "get_clock",
        description = "Is the market open now? Returns the time now, and the times of the next open and the next close.",
        inputschema = _input_schema(none, String[]), handler = _get_clock)));
    push!(tools, build(MyMCPToolModel, (name = "get_positions",
        description = "The open positions of the account: the shares of each stock, the average entry price, the market " *
            "value, and the unrealized profit or loss (USD).",
        inputschema = _input_schema(none, String[]), handler = _get_positions)));

    properties = Dict{String,Any}();
    properties["status"] = _property("string", "Which orders: open (the default), closed, or all.";
        allowed = ["open", "closed", "all"]);
    properties["limit"] = _property("integer", "The most orders to return, from 1 to 500. The default is 50.");
    properties["symbols"] = _symbols_property("Only the orders of these ticker symbols. Leave out for every symbol.");
    push!(tools, build(MyMCPToolModel, (name = "get_orders",
        description = "The orders of the account, newest first, with their status and filled share counts.",
        inputschema = _input_schema(properties, String[]), handler = _get_orders)));

    properties = Dict{String,Any}();
    properties["order_id"] = _property("string", "The identifier of the order, from submit_order or get_orders.");
    push!(tools, build(MyMCPToolModel, (name = "get_order",
        description = "One order, by its identifier: its status, filled share count, and average fill price.",
        inputschema = _input_schema(properties, ["order_id"]), handler = _get_order)));

    # the reads of the market -
    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol, e.g., JPM.");
    push!(tools, build(MyMCPToolModel, (name = "get_asset",
        description = "Whether a stock can be traded, bought in fractions of a share, or sold short.",
        inputschema = _input_schema(properties, ["symbol"]), handler = _get_asset)));

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property("The ticker symbols, e.g., [\"JPM\", \"KO\"].");
    push!(tools, build(MyMCPToolModel, (name = "get_latest_quotes",
        description = "The latest bid and ask price (USD per share) and size (shares) of each symbol, from IEX.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_latest_quotes)));

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property("The ticker symbols, e.g., [\"SPY\"].");
    properties["start"] = _property("string", "The first date, as yyyy-mm-dd.");
    properties["end"] = _property("string", "The last date, as yyyy-mm-dd. Leave out for the latest bar.");
    push!(tools, build(MyMCPToolModel, (name = "get_daily_bars",
        description = "The daily open, high, low, close (USD per share), and volume (shares) of each symbol, from IEX. " *
            "At most $(MAX_ROWS) rows: ask for fewer symbols or a shorter range when the result is too long.",
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_daily_bars)));

    # the orders -
    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol, e.g., JPM.");
    properties["side"] = _property("string", "buy or sell."; allowed = ["buy", "sell"]);
    properties["qty"] = _property("number", "The number of shares. Give qty or notional, not both.");
    properties["notional"] = _property("number", "The dollar amount to trade (USD), for a fractional order. Give qty or notional, not both.");
    properties["type"] = _property("string", "market (the default) fills at the best available price. limit fills " *
        "at the limit_price or better."; allowed = ["market", "limit"]);
    properties["limit_price"] = _property("number", "The limit price (USD per share). Required for a limit order.");
    properties["time_in_force"] = _property("string", "day (the default) cancels the order at the close if it has " *
        "not filled. gtc keeps it open until it fills or is canceled."; allowed = ["day", "gtc"]);
    push!(tools, build(MyMCPToolModel, (name = "submit_order",
        description = "Submit one stock order to the paper account. Returns the order with its identifier and status.",
        inputschema = _input_schema(properties, ["symbol", "side"]), handler = _submit_order)));

    properties = Dict{String,Any}();
    properties["order_id"] = _property("string", "The identifier of the open order to cancel.");
    push!(tools, build(MyMCPToolModel, (name = "cancel_order",
        description = "Cancel one open order of the paper account.",
        inputschema = _input_schema(properties, ["order_id"]), handler = _cancel_order)));
    push!(tools, build(MyMCPToolModel, (name = "cancel_all_orders",
        description = "Cancel every open order of the paper account.",
        inputschema = _input_schema(none, String[]), handler = _cancel_all_orders)));

    # build the server -
    server = build(MyMCPServerModel, (name = "alpaca-paper", version = "0.1.0", instructions = SERVER_INSTRUCTIONS,
        tools = tools, configuration = configuration));
    return server;
end
# --- PUBLIC METHODS ABOVE HERE -------------------------------------------------------------------------------- #
