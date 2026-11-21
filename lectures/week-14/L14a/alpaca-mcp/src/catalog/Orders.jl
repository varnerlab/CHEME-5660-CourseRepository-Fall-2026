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

# Read a number argument that can be negative, e.g., the net price of an option structure. A credit is a negative price -
function _signed_number_argument(arguments::AbstractDict, name::String)::Union{Nothing,Float64}

    if (haskey(arguments, name) == false)
        return nothing;
    end
    value = arguments[name];
    if (isa(value, Real) == false || isa(value, Bool) == true)
        throw(ArgumentError("the $(name) must be a number"));
    end
    return Float64(value);
end

# get_order: one order, by its Alpaca identifier or by the client order id that was given when it was submitted -
function _get_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments, and check that exactly one identifier is given -
    _check_argument_names(arguments, ["order_id", "client_order_id"]);
    order_id = _text_argument(arguments, "order_id");
    client_order_id = _text_argument(arguments, "client_order_id");
    if (isnothing(order_id) == isnothing(client_order_id))
        throw(ArgumentError("give exactly one of order_id and client_order_id"));
    end

    # call Alpaca -
    model = Alpaca.MyOrderEndpointModel(id = order_id, client_order_id = client_order_id);
    df = Alpaca.api(_client(configuration), model);
    rows = _rows(df);
    return Dict{String,Any}("order" => rows[1]);
end

# submit_order: one stock order, by share count or by dollar amount, with any order type, and with exit legs -
function _submit_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbol", "side", "qty", "notional", "type", "limit_price", "time_in_force",
        "stop_price", "trail_price", "trail_percent", "extended_hours", "client_order_id", "order_class",
        "take_profit_limit_price", "stop_loss_stop_price", "stop_loss_limit_price"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    side = _choice_argument(arguments, "side", ["buy", "sell"]; required = true);
    qty = _number_argument(arguments, "qty"); # shares
    notional = _number_argument(arguments, "notional"); # USD
    type = _choice_argument(arguments, "type", ["market", "limit", "stop", "stop_limit", "trailing_stop"];
        default = "market");
    limit_price = _number_argument(arguments, "limit_price"); # USD per share
    time_in_force = _choice_argument(arguments, "time_in_force", ["day", "gtc", "opg", "cls", "ioc", "fok"];
        default = "day");
    stop_price = _number_argument(arguments, "stop_price"); # USD per share
    trail_price = _number_argument(arguments, "trail_price"); # USD per share
    trail_percent = _number_argument(arguments, "trail_percent"); # percent
    extended_hours = _boolean_argument(arguments, "extended_hours"; default = false);
    client_order_id = _text_argument(arguments, "client_order_id");
    order_class = _choice_argument(arguments, "order_class", ["simple", "bracket", "oco", "oto"]);
    take_profit_limit_price = _number_argument(arguments, "take_profit_limit_price"); # USD per share
    stop_loss_stop_price = _number_argument(arguments, "stop_loss_stop_price"); # USD per share
    stop_loss_limit_price = _number_argument(arguments, "stop_loss_limit_price"); # USD per share

    # check the order before any request. The SDK checks the prices of each type and the order class rules -
    if (isnothing(qty) == isnothing(notional))
        throw(ArgumentError("give exactly one of qty (shares) and notional (USD)"));
    end
    if (type == "limit" && isnothing(limit_price) == true)
        throw(ArgumentError("a limit order needs a limit_price (USD per share)"));
    end
    if (type == "market" && isnothing(limit_price) == false)
        throw(ArgumentError("a market order takes no limit_price. Use type limit to set a price"));
    end

    # build the order model, and submit the order -
    order_model = nothing;
    if (isnothing(qty) == false)
        order_model = Alpaca.MyEquityOrderModel(symbol = symbol, side = side, qty = qty);
    else
        order_model = Alpaca.MyEquityOrderModel(symbol = symbol, side = side, notional = notional);
    end
    order = Alpaca.submit(_client(configuration), order_model; type = type, time_in_force = time_in_force,
        limit_price = limit_price, stop_price = stop_price, trail_price = trail_price, trail_percent = trail_percent,
        client_order_id = client_order_id, extended_hours = extended_hours, order_class = order_class,
        take_profit_limit_price = take_profit_limit_price, stop_loss_stop_price = stop_loss_stop_price,
        stop_loss_limit_price = stop_loss_limit_price);
    return Dict{String,Any}("order" => _order_summary(order));
end

# submit_option_order: one option order, for one leg or for a structure of two to four legs -
function _submit_option_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["legs", "qty", "type", "limit_price", "time_in_force", "client_order_id",
        "extended_hours"]);
    if (haskey(arguments, "legs") == false)
        throw(ArgumentError("the legs argument is required"));
    end
    legs_argument = arguments["legs"];
    if (isa(legs_argument, AbstractVector) == false || isempty(legs_argument) == true)
        throw(ArgumentError("the legs must be a list of 1 to 4 legs, each with a symbol and a side"));
    end
    if (length(legs_argument) > 4)
        throw(ArgumentError("a structure has at most 4 legs, and the legs list has $(length(legs_argument))"));
    end
    qty = _integer_argument(arguments, "qty", 1, 1, 1000); # contracts
    type = _choice_argument(arguments, "type", ["market", "limit"]; default = "limit");
    limit_price = _signed_number_argument(arguments, "limit_price"); # USD per contract unit
    time_in_force = _choice_argument(arguments, "time_in_force", ["day", "gtc", "ioc", "fok"]; default = "day");
    client_order_id = _text_argument(arguments, "client_order_id");
    extended_hours = _boolean_argument(arguments, "extended_hours"; default = false);

    # read each leg: its option symbol, its side, and its ratio -
    legs = Array{Alpaca.MyOptionLegModel,1}();
    for leg_argument ∈ legs_argument
        if (isa(leg_argument, AbstractDict) == false)
            throw(ArgumentError("each leg must be an object with a symbol, a side, and optionally a ratio"));
        end
        _check_argument_names(leg_argument, ["symbol", "side", "ratio"]);
        leg_symbol = uppercase(_text_argument(leg_argument, "symbol"; required = true));
        leg_side = _choice_argument(leg_argument, "side", ["buy", "sell"]; required = true);
        leg_ratio = _integer_argument(leg_argument, "ratio", 1, 1, 100);
        push!(legs, Alpaca.MyOptionLegModel(symbol = leg_symbol, side = leg_side, ratio = leg_ratio));
    end

    # check the order before any request -
    if (type == "limit" && isnothing(limit_price) == true)
        throw(ArgumentError("a limit order needs a limit_price (USD per contract unit)"));
    end
    if (type == "market" && isnothing(limit_price) == false)
        throw(ArgumentError("a market order takes no limit_price. Use type limit to set a price"));
    end

    # call Alpaca -
    order = Alpaca.submit(_client(configuration), legs; qty = qty, type = type, time_in_force = time_in_force,
        limit_price = limit_price, client_order_id = client_order_id, extended_hours = extended_hours);
    return Dict{String,Any}("order" => _order_summary(order));
end

# submit_crypto_order: one crypto order, by coin count or by dollar amount -
function _submit_crypto_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbol", "side", "qty", "notional", "type", "time_in_force", "limit_price",
        "stop_price", "client_order_id"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    side = _choice_argument(arguments, "side", ["buy", "sell"]; required = true);
    qty = _number_argument(arguments, "qty"); # coins
    notional = _number_argument(arguments, "notional"); # USD
    type = _choice_argument(arguments, "type", ["market", "limit", "stop_limit"]; default = "market");
    time_in_force = _choice_argument(arguments, "time_in_force", ["gtc", "ioc"]; default = "gtc");
    limit_price = _number_argument(arguments, "limit_price"); # USD per coin
    stop_price = _number_argument(arguments, "stop_price"); # USD per coin
    client_order_id = _text_argument(arguments, "client_order_id");

    # check the order before any request. The SDK checks the prices of each type -
    if (isnothing(qty) == isnothing(notional))
        throw(ArgumentError("give exactly one of qty (coins) and notional (USD)"));
    end

    # build the order model, and submit the order -
    order_model = nothing;
    if (isnothing(qty) == false)
        order_model = Alpaca.MyCryptoOrderModel(symbol = symbol, side = side, qty = qty);
    else
        order_model = Alpaca.MyCryptoOrderModel(symbol = symbol, side = side, notional = notional);
    end
    order = Alpaca.submit(_client(configuration), order_model; type = type, time_in_force = time_in_force,
        limit_price = limit_price, stop_price = stop_price, client_order_id = client_order_id);
    return Dict{String,Any}("order" => _order_summary(order));
end

# replace_order: change the quantity, the prices, or the time in force of an open order, which gets a new identifier -
function _replace_order(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    changes = ["qty", "time_in_force", "limit_price", "stop_price", "trail", "client_order_id"];
    _check_argument_names(arguments, vcat(["order_id"], changes));
    order_id = _text_argument(arguments, "order_id"; required = true);
    qty = _number_argument(arguments, "qty"); # shares, contracts, or coins
    time_in_force = _choice_argument(arguments, "time_in_force", ["day", "gtc", "opg", "cls", "ioc", "fok"]);
    limit_price = _number_argument(arguments, "limit_price"); # USD per share, contract unit, or coin
    stop_price = _number_argument(arguments, "stop_price"); # USD per share or coin
    trail = _number_argument(arguments, "trail"); # USD per share, or percent
    client_order_id = _text_argument(arguments, "client_order_id");

    # at least one change must be given -
    if (length(arguments) < 2)
        throw(ArgumentError("give at least one change: $(join(changes, ", "))"));
    end

    # call Alpaca -
    model = Alpaca.MyReplaceOrderEndpointModel(id = order_id, qty = qty, time_in_force = time_in_force,
        limit_price = limit_price, stop_price = stop_price, trail = trail, client_order_id = client_order_id);
    df = Alpaca.api(_client(configuration), model);
    rows = _rows(df);
    return Dict{String,Any}("order" => rows[1]);
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

# get_position: the open position in one symbol -
function _get_position(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    df = Alpaca.api(_client(configuration), Alpaca.MyPositionEndpointModel(symbol = symbol));
    rows = _rows(df);
    return Dict{String,Any}("position" => rows[1]);
end

# close_position: close all or part of the position in one symbol at market -
function _close_position(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbol", "qty", "percentage"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    qty = _number_argument(arguments, "qty"); # shares, contracts, or coins
    percentage = _number_argument(arguments, "percentage"); # percent of the position
    if (isnothing(qty) == false && isnothing(percentage) == false)
        throw(ArgumentError("give qty or percentage, not both"));
    end
    if (isnothing(percentage) == false && percentage > 100)
        throw(ArgumentError("the percentage must be at most 100"));
    end

    # call Alpaca -
    order = Base.close(_client(configuration), symbol; qty = qty, percentage = percentage);
    return Dict{String,Any}("order" => _order_summary(order));
end

# close_all_positions: close every position of the account at market -
function _close_all_positions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["cancel_orders"]);
    cancel_orders = _boolean_argument(arguments, "cancel_orders"; default = false);
    df = Base.close(_client(configuration); all = true, cancel_orders = cancel_orders);
    rows = _rows(df);
    return Dict{String,Any}("closed" => rows, "count" => length(rows));
end

# exercise_option: ask Alpaca to exercise an option position. Alpaca answers with no body -
function _exercise_option(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol_or_contract_id"]);
    symbol = _text_argument(arguments, "symbol_or_contract_id"; required = true);
    Alpaca.api(_client(configuration), Alpaca.MyExerciseOptionEndpointModel(symbol = symbol));
    return Dict{String,Any}("exercise_requested" => symbol);
end

# do_not_exercise_option: tell Alpaca not to exercise an option position at expiration. Alpaca answers with no body -
function _do_not_exercise_option(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol_or_contract_id"]);
    symbol = _text_argument(arguments, "symbol_or_contract_id"; required = true);
    Alpaca.api(_client(configuration), Alpaca.MyDoNotExerciseOptionEndpointModel(symbol = symbol));
    return Dict{String,Any}("do_not_exercise_requested" => symbol);
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
        description = "The orders of the account, newest first, with their status and filled quantities.",
        inputschema = _input_schema(properties, String[]), handler = _get_orders)));

    properties = Dict{String,Any}();
    properties["order_id"] = _property("string", "The identifier of the order, from submit_order or get_orders. Give order_id or client_order_id, not both.");
    properties["client_order_id"] = _property("string", "The client order id that was given when the order was submitted. Give order_id or client_order_id, not both.");
    push!(tools, build(MyMCPToolModel, (name = "get_order",
        description = "One order, by its identifier or its client order id: its status, filled quantity, and average fill price (USD).",
        inputschema = _input_schema(properties, String[]), handler = _get_order)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol, e.g., JPM.");
    properties["side"] = _property("string", "buy or sell."; allowed = ["buy", "sell"]);
    properties["qty"] = _property("number", "The number of shares. Give qty or notional, not both.");
    properties["notional"] = _property("number", "The dollar amount to trade (USD), for a fractional order. Give qty or notional, not both.");
    properties["type"] = _property("string", "market (the default) fills at the best available price. limit fills " *
        "at the limit_price or better. stop becomes a market order at the stop_price. stop_limit becomes a limit " *
        "order at the stop_price. trailing_stop follows the price by trail_price or trail_percent.";
        allowed = ["market", "limit", "stop", "stop_limit", "trailing_stop"]);
    properties["limit_price"] = _property("number", "The limit price (USD per share). Required for a limit or stop_limit order.");
    properties["time_in_force"] = _property("string", "day (the default) cancels the order at the close if it has " *
        "not filled. gtc keeps it open until it fills or is canceled. opg and cls fill at the open and at the close. " *
        "ioc and fok fill at once, or are canceled."; allowed = ["day", "gtc", "opg", "cls", "ioc", "fok"]);
    properties["stop_price"] = _property("number", "The stop price (USD per share), for a stop or stop_limit order.");
    properties["trail_price"] = _property("number", "The distance that a trailing_stop order follows the price (USD per share). Give trail_price or trail_percent.");
    properties["trail_percent"] = _property("number", "The distance that a trailing_stop order follows the price (percent). Give trail_price or trail_percent.");
    properties["extended_hours"] = _property("boolean", "true lets the order fill outside regular trading hours. It needs a limit order with time_in_force day.");
    properties["client_order_id"] = _property("string", "An identifier of your own for the order, to read it back with get_order.");
    properties["order_class"] = _property("string", "simple (one order), bracket (an entry with a take-profit and a stop-loss exit), " *
        "oco (a take-profit and a stop-loss exit for an open position), or oto (an entry with one exit).";
        allowed = ["simple", "bracket", "oco", "oto"]);
    properties["take_profit_limit_price"] = _property("number", "The limit price of the take-profit exit (USD per share).");
    properties["stop_loss_stop_price"] = _property("number", "The stop price of the stop-loss exit (USD per share).");
    properties["stop_loss_limit_price"] = _property("number", "The limit price of the stop-loss exit (USD per share). Needs stop_loss_stop_price.");
    push!(tools, build(MyMCPToolModel, (name = "submit_order",
        description = "Submit one stock order to the paper account, with an optional take-profit and stop-loss exit. " *
            "Returns the order with its identifier and status.",
        inputschema = _input_schema(properties, ["symbol", "side"]), handler = _submit_order)));

    properties = Dict{String,Any}();
    leg_properties = Dict{String,Any}();
    leg_properties["symbol"] = _property("string", "The option contract symbol, e.g., AAPL261218C00200000.");
    leg_properties["side"] = _property("string", "buy or sell."; allowed = ["buy", "sell"]);
    leg_properties["ratio"] = _property("integer", "The contracts of this leg for each unit of the structure. The default is 1.");
    properties["legs"] = _property("array", "One to four legs. Each leg is an object with a symbol and a side, and optionally a ratio.");
    properties["legs"]["items"] = _input_schema(leg_properties, ["symbol", "side"]);
    properties["legs"]["minItems"] = 1;
    properties["legs"]["maxItems"] = 4;
    properties["qty"] = _property("integer", "The number of units of the structure, in whole contracts. The default is 1.");
    properties["type"] = _property("string", "limit (the default) fills at the limit_price or better. market fills at the best available price.";
        allowed = ["market", "limit"]);
    properties["limit_price"] = _property("number", "The limit price (USD per contract unit, as Alpaca quotes option prices). " *
        "For two or more legs it is the net price of one unit: positive is a debit, negative is a credit.");
    properties["time_in_force"] = _property("string", "day (the default) cancels the order at the close if it has not filled.";
        allowed = ["day", "gtc", "ioc", "fok"]);
    properties["client_order_id"] = _property("string", "An identifier of your own for the order, to read it back with get_order.");
    properties["extended_hours"] = _property("boolean", "true lets the order fill outside regular trading hours.");
    push!(tools, build(MyMCPToolModel, (name = "submit_option_order",
        description = "Submit one option order to the paper account that opens one leg, or a structure of two to four legs as a " *
            "single order. Quantities are in contracts. Returns the order with its identifier and status.",
        inputschema = _input_schema(properties, ["legs"]), handler = _submit_option_order)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The crypto pair, e.g., BTC/USD.");
    properties["side"] = _property("string", "buy or sell."; allowed = ["buy", "sell"]);
    properties["qty"] = _property("number", "The number of coins. Give qty or notional, not both.");
    properties["notional"] = _property("number", "The dollar amount to trade (USD). Give qty or notional, not both.");
    properties["type"] = _property("string", "market (the default) fills at the best available price. limit fills at the " *
        "limit_price or better. stop_limit becomes a limit order at the stop_price."; allowed = ["market", "limit", "stop_limit"]);
    properties["time_in_force"] = _property("string", "gtc (the default) keeps the order open until it fills or is canceled. " *
        "ioc fills at once, or is canceled."; allowed = ["gtc", "ioc"]);
    properties["limit_price"] = _property("number", "The limit price (USD per coin). Required for a limit or stop_limit order.");
    properties["stop_price"] = _property("number", "The stop price (USD per coin), for a stop_limit order.");
    properties["client_order_id"] = _property("string", "An identifier of your own for the order, to read it back with get_order.");
    push!(tools, build(MyMCPToolModel, (name = "submit_crypto_order",
        description = "Submit one crypto order to the paper account, by coins or by dollar amount. " *
            "Returns the order with its identifier and status.",
        inputschema = _input_schema(properties, ["symbol", "side"]), handler = _submit_crypto_order)));

    properties = Dict{String,Any}();
    properties["order_id"] = _property("string", "The identifier of the open order to replace.");
    properties["qty"] = _property("number", "The new quantity (shares, contracts, or coins).");
    properties["time_in_force"] = _property("string", "The new time in force.";
        allowed = ["day", "gtc", "opg", "cls", "ioc", "fok"]);
    properties["limit_price"] = _property("number", "The new limit price (USD per share, per contract unit, or per coin).");
    properties["stop_price"] = _property("number", "The new stop price (USD per share or per coin).");
    properties["trail"] = _property("number", "The new trail of a trailing stop order (USD per share, or percent).");
    properties["client_order_id"] = _property("string", "A new identifier of your own for the order.");
    push!(tools, build(MyMCPToolModel, (name = "replace_order",
        description = "Replace an open order of the paper account with new values, and return the new order, which has a new " *
            "identifier. Give at least one change. Alpaca answers \"pending replacement\" when the order is replaced " *
            "or canceled again before Alpaca has accepted the last change: wait, and try again.",
        inputschema = _input_schema(properties, ["order_id"]), handler = _replace_order)));

    properties = Dict{String,Any}();
    properties["order_id"] = _property("string", "The identifier of the open order to cancel.");
    push!(tools, build(MyMCPToolModel, (name = "cancel_order",
        description = "Cancel one open order of the paper account. Alpaca answers \"pending replacement\" when the order was " *
            "replaced or canceled before Alpaca has accepted the last change: wait, and try again.",
        inputschema = _input_schema(properties, ["order_id"]), handler = _cancel_order)));

    push!(tools, build(MyMCPToolModel, (name = "cancel_all_orders",
        description = "Cancel every open order of the paper account.",
        inputschema = _input_schema(none, String[]), handler = _cancel_all_orders)));

    push!(tools, build(MyMCPToolModel, (name = "get_positions",
        description = "The open positions of the account: the quantity of each (shares, contracts, or coins), the average " *
            "entry price, the market value, and the unrealized profit or loss (USD).",
        inputschema = _input_schema(none, String[]), handler = _get_positions)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol, the option contract symbol, or the crypto pair, e.g., AAPL or BTC/USD.");
    push!(tools, build(MyMCPToolModel, (name = "get_position",
        description = "The open position in one symbol: its quantity (shares, contracts, or coins), average entry price, " *
            "market value, and unrealized profit or loss (USD).",
        inputschema = _input_schema(properties, ["symbol"]), handler = _get_position)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The symbol of the position to close, e.g., AAPL or BTC/USD.");
    properties["qty"] = _property("number", "The quantity to close (shares, contracts, or coins). Give qty or percentage, not both.");
    properties["percentage"] = _property("number", "The percent of the position to close, up to 100. Give qty or percentage, not both.");
    push!(tools, build(MyMCPToolModel, (name = "close_position",
        description = "Close all or part of the position in one symbol at market. Leave out qty and percentage to close the " *
            "whole position. Returns the closing order.",
        inputschema = _input_schema(properties, ["symbol"]), handler = _close_position)));

    properties = Dict{String,Any}();
    properties["cancel_orders"] = _property("boolean", "true cancels the open orders before the positions close. The default is false.");
    push!(tools, build(MyMCPToolModel, (name = "close_all_positions",
        description = "Close every position of the paper account at market. Returns the status of each position.",
        inputschema = _input_schema(properties, String[]), handler = _close_all_positions)));

    properties = Dict{String,Any}();
    properties["symbol_or_contract_id"] = _property("string", "The option contract symbol, or the contract identifier, of the position.");
    push!(tools, build(MyMCPToolModel, (name = "exercise_option",
        description = "Exercise an option position of the paper account. The position is in contracts.",
        inputschema = _input_schema(properties, ["symbol_or_contract_id"]), handler = _exercise_option)));

    push!(tools, build(MyMCPToolModel, (name = "do_not_exercise_option",
        description = "Tell Alpaca not to exercise an option position of the paper account at expiration.",
        inputschema = _input_schema(properties, ["symbol_or_contract_id"]), handler = _do_not_exercise_option)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
