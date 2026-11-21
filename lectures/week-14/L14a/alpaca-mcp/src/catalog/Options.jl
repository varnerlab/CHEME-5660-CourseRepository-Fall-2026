# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Options tools
# =============================================================================
# The handlers of the tools for option market data, followed by _add_options_tools!(...), which lists each tool's
# name, description, input schema, and handler. An option is named by its OCC symbol, e.g., AAPL251219C00200000.
# One contract covers 100 shares, and the prices are in USD per share of the underlying.
# =============================================================================

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# The shared steps of get_option_bars and get_option_trades. The kind is "bars" or "trades". Only the bars have a
# timeframe. The helper reads the arguments, builds the model of the kind, and returns the first page of the table -
function _option_history(arguments::AbstractDict, configuration::AbstractDict, kind::String)::Dict{String,Any}

    # the names of the arguments that the kind takes -
    names = ["symbols", "start", "end"];
    if (kind == "bars")
        names = ["symbols", "timeframe", "start", "end"];
    end

    # read the arguments -
    _check_argument_names(arguments, names);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");

    # build the model of the kind -
    model = nothing;
    if (kind == "bars")
        timeframe = _choice_argument(arguments, "timeframe", BAR_TIMEFRAMES; default = "1Day");
        model = Alpaca.MyOptionBarsEndpointModel(symbols = symbols, timeframe = timeframe, start = start,
            finish = finish, limit = MAX_ROWS + 1);
    elseif (kind == "trades")
        model = Alpaca.MyOptionTradesEndpointModel(symbols = symbols, start = start, finish = finish,
            limit = MAX_ROWS + 1);
    else
        throw(ArgumentError("the kind must be bars or trades"));
    end
    return _paged_table(configuration, model, kind);
end

# get_option_bars: the open, high, low, close, and volume of each option contract over a range of times -
function _get_option_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _option_history(arguments, configuration, "bars");
end

# get_option_trades: the trades of each option contract over a range of times -
function _get_option_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _option_history(arguments, configuration, "trades");
end

# The shared steps of the three tools for the latest data of option contracts. The kind is "quotes", "trades", or
# "snapshots". The helper reads the arguments, builds the model of the kind, and returns the table -
function _option_latest(arguments::AbstractDict, configuration::AbstractDict, kind::String)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols"]);
    symbols = _symbols_argument(arguments, "symbols");

    # build the model of the kind -
    model = nothing;
    if (kind == "quotes")
        model = Alpaca.MyOptionLatestQuoteEndpointModel(symbols = symbols);
    elseif (kind == "trades")
        model = Alpaca.MyOptionLatestTradeEndpointModel(symbols = symbols);
    elseif (kind == "snapshots")
        model = Alpaca.MyOptionSnapshotsEndpointModel(symbols = symbols);
    else
        throw(ArgumentError("the kind must be quotes, trades, or snapshots"));
    end
    return _plain_table(configuration, model, kind);
end

# get_option_latest_quotes: the latest bid and ask of each option contract -
function _get_option_latest_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _option_latest(arguments, configuration, "quotes");
end

# get_option_latest_trades: the latest trade of each option contract -
function _get_option_latest_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _option_latest(arguments, configuration, "trades");
end

# get_option_snapshots: the latest trade, quote, and bars of each option contract -
function _get_option_snapshots(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _option_latest(arguments, configuration, "snapshots");
end

# get_option_chain: the snapshots of the option contracts of one underlying stock, with filters on the type, the
# strike price, and the expiration date -
function _get_option_chain(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["underlying", "type", "strike_price_gte", "strike_price_lte", "expiration_date",
        "expiration_date_gte", "expiration_date_lte"]);
    underlying = _text_argument(arguments, "underlying"; required = true);
    underlying = uppercase(underlying);
    type = _choice_argument(arguments, "type", ["call", "put"]);
    strike_price_gte = _number_argument(arguments, "strike_price_gte");
    strike_price_lte = _number_argument(arguments, "strike_price_lte");
    expiration_date = _date_argument(arguments, "expiration_date"; required = false);
    expiration_date_gte = _date_argument(arguments, "expiration_date_gte"; required = false);
    expiration_date_lte = _date_argument(arguments, "expiration_date_lte"; required = false);

    # call Alpaca -
    model = Alpaca.MyOptionChainEndpointModel(underlying = underlying, type = type, strike_price_gte = strike_price_gte,
        strike_price_lte = strike_price_lte, expiration_date = expiration_date,
        expiration_date_gte = expiration_date_gte, expiration_date_lte = expiration_date_lte, limit = MAX_ROWS + 1);
    return _paged_table(configuration, model, "chain";
        advice = "Narrow the expiration dates, the strike prices, or the type.");
end

# get_option_exchanges: the name of each exchange code in the option data -
function _get_option_exchanges(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments, and call Alpaca -
    _check_argument_names(arguments, String[]);
    return _plain_table(configuration, Alpaca.MyOptionExchangesEndpointModel(), "exchanges");
end

# get_option_conditions: the meaning of each condition code of the option trades or quotes -
function _get_option_conditions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["ticktype"]);
    ticktype = _choice_argument(arguments, "ticktype", ["trade", "quote"]; default = "trade");

    # call Alpaca -
    model = Alpaca.MyOptionConditionsEndpointModel(ticktype = ticktype);
    return _plain_table(configuration, model, "conditions");
end

# The property of a list of option symbols -
function _option_symbols_property()::Dict{String,Any}

    return _symbols_property("The OCC symbols of the option contracts, e.g., [\"AAPL251219C00200000\"].");
end

# Add the tools of this file to the list of tools of the server -
function _add_options_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    # the sentences that several descriptions share -
    cap_text = "At most $(MAX_ROWS) rows: ask for fewer contracts or a shorter range when the result is too long.";
    unit_text = "Prices are in USD per share of the underlying, one contract covers 100 shares, and sizes are in contracts.";
    start_text = "The first time, as a date (yyyy-mm-dd) or an RFC 3339 time in UTC, e.g., 2026-11-20T14:30:00Z.";
    end_text = "The last time, in the same form as start. Leave out for the latest data.";

    properties = Dict{String,Any}();
    properties["symbols"] = _option_symbols_property();
    properties["timeframe"] = _property("string", "The width of each bar. The default is 1Day."; allowed = BAR_TIMEFRAMES);
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    push!(tools, build(MyMCPToolModel, (name = "get_option_bars",
        description = "The open, high, low, close, and volume of each option contract, one bar for each timeframe, with " *
            "the time of each bar in UTC. " * unit_text * " " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_option_bars)));

    properties = Dict{String,Any}();
    properties["symbols"] = _option_symbols_property();
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    push!(tools, build(MyMCPToolModel, (name = "get_option_trades",
        description = "The historical trades of each option contract: the price and size of each, with the time in UTC. " *
            unit_text * " " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_option_trades)));

    properties = Dict{String,Any}("symbols" => _option_symbols_property());
    push!(tools, build(MyMCPToolModel, (name = "get_option_latest_quotes",
        description = "The latest bid and ask price and size of each option contract, with the time in UTC. " * unit_text *
            " The free paper plan gets the indicative feed, not the OPRA feed.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_option_latest_quotes)));

    push!(tools, build(MyMCPToolModel, (name = "get_option_latest_trades",
        description = "The latest trade of each option contract: the price and size, with the time in UTC. " * unit_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_option_latest_trades)));

    push!(tools, build(MyMCPToolModel, (name = "get_option_snapshots",
        description = "The latest trade, quote, and bars of each option contract, with the implied volatility and the " *
            "Greeks when Alpaca has them, and times in UTC. " * unit_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_option_snapshots)));

    properties = Dict{String,Any}();
    properties["underlying"] = _property("string", "The ticker symbol of the underlying stock, e.g., SPY.");
    properties["type"] = _property("string", "Only call or only put contracts. Leave out for both."; allowed = ["call", "put"]);
    properties["strike_price_gte"] = _property("number", "The lowest strike price, in USD per share.");
    properties["strike_price_lte"] = _property("number", "The highest strike price, in USD per share.");
    properties["expiration_date"] = _property("string", "The exact expiration date, written as yyyy-mm-dd.");
    properties["expiration_date_gte"] = _property("string", "The earliest expiration date, written as yyyy-mm-dd.");
    properties["expiration_date_lte"] = _property("string", "The latest expiration date, written as yyyy-mm-dd.");
    push!(tools, build(MyMCPToolModel, (name = "get_option_chain",
        description = "The snapshots of the option contracts of one underlying stock: the latest trade, quote, and bars, " *
            "with times in UTC. Filter by type, strike, and expiration to keep the chain short. " * unit_text * " " * cap_text,
        inputschema = _input_schema(properties, ["underlying"]), handler = _get_option_chain)));

    push!(tools, build(MyMCPToolModel, (name = "get_option_exchanges",
        description = "The name of each exchange code that appears in the option quotes and trades. Returns the code " *
            "and the name of each exchange.",
        inputschema = _input_schema(Dict{String,Any}(), String[]), handler = _get_option_exchanges)));

    properties = Dict{String,Any}();
    properties["ticktype"] = _property("string", "trade or quote. The default is trade."; allowed = ["trade", "quote"]);
    push!(tools, build(MyMCPToolModel, (name = "get_option_conditions",
        description = "The meaning of each condition code that an option trade or quote can carry. Returns the code and " *
            "the name of each condition.",
        inputschema = _input_schema(properties, String[]), handler = _get_option_conditions)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
