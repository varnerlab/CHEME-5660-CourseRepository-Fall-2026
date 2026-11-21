# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Orders tools
# =============================================================================
# The handlers of the tools for orders and positions, followed by _add_orders_tools!(...),
# which lists each tool's name, description, input schema, and handler.
# =============================================================================

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
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

# get_positions: the open positions of the account -
function _get_positions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, String[]);
    df = Alpaca.api(_client(configuration), Alpaca.MyPositionsEndpointModel());
    rows = _rows(df);
    return Dict{String,Any}("positions" => rows, "count" => length(rows));
end

# Add the tools of this file to the list of tools of the server -
function _add_orders_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    none = Dict{String,Any}(); # the properties of a tool that takes no arguments

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

    push!(tools, build(MyMCPToolModel, (name = "get_positions",
        description = "The open positions of the account: the shares of each stock, the average entry price, the market " *
            "value, and the unrealized profit or loss (USD).",
        inputschema = _input_schema(none, String[]), handler = _get_positions)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
