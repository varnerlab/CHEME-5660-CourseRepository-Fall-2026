# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Crypto tools
# =============================================================================
# The handlers of the tools for crypto market data, followed by _add_crypto_tools!(...), which lists each tool's
# name, description, input schema, and handler. A crypto pair is written as BASE/QUOTE, e.g., BTC/USD. Crypto
# trades every day of the week. Sizes are in coins, and prices are in USD per coin.
# =============================================================================

# the locations of the crypto market data, which the tools take as the loc argument -
const CRYPTO_LOCS = ["us", "us-1", "us-2", "eu-1", "bs-1"];

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# The shared steps of get_crypto_bars, get_crypto_quotes, and get_crypto_trades. The kind is "bars", "quotes", or
# "trades". Only the bars have a timeframe. The helper reads the arguments, builds the model of the kind, and
# returns the first page of the table -
function _crypto_history(arguments::AbstractDict, configuration::AbstractDict, kind::String)::Dict{String,Any}

    # the names of the arguments that the kind takes -
    names = ["symbols", "start", "end", "sort", "loc"];
    if (kind == "bars")
        names = ["symbols", "timeframe", "start", "end", "sort", "loc"];
    end

    # read the arguments -
    _check_argument_names(arguments, names);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]);
    loc = _choice_argument(arguments, "loc", CRYPTO_LOCS; default = "us");

    # build the model of the kind -
    model = nothing;
    if (kind == "bars")
        timeframe = _choice_argument(arguments, "timeframe", BAR_TIMEFRAMES; default = "1Day");
        model = Alpaca.MyCryptoBarsEndpointModel(symbols = symbols, timeframe = timeframe, start = start,
            finish = finish, limit = MAX_ROWS + 1, sort = sort, loc = loc);
    elseif (kind == "quotes")
        model = Alpaca.MyCryptoQuotesEndpointModel(symbols = symbols, start = start, finish = finish,
            limit = MAX_ROWS + 1, sort = sort, loc = loc);
    elseif (kind == "trades")
        model = Alpaca.MyCryptoTradesEndpointModel(symbols = symbols, start = start, finish = finish,
            limit = MAX_ROWS + 1, sort = sort, loc = loc);
    else
        throw(ArgumentError("the kind must be bars, quotes, or trades"));
    end
    return _paged_table(configuration, model, kind);
end

# get_crypto_bars: the open, high, low, close, and volume of each crypto pair over a range of times -
function _get_crypto_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_history(arguments, configuration, "bars");
end

# get_crypto_quotes: the bid and ask quotes of each crypto pair over a range of times -
function _get_crypto_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_history(arguments, configuration, "quotes");
end

# get_crypto_trades: the trades of each crypto pair over a range of times -
function _get_crypto_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_history(arguments, configuration, "trades");
end

# The shared steps of the five tools for the latest data of crypto pairs. The kind is "bars", "quotes", "trades",
# "orderbooks", or "snapshots". The helper reads the arguments, builds the model of the kind, and returns the table -
function _crypto_latest(arguments::AbstractDict, configuration::AbstractDict, kind::String)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "loc"]);
    symbols = _symbols_argument(arguments, "symbols");
    loc = _choice_argument(arguments, "loc", CRYPTO_LOCS; default = "us");

    # build the model of the kind -
    model = nothing;
    if (kind == "bars")
        model = Alpaca.MyCryptoLatestBarsEndpointModel(symbols = symbols, loc = loc);
    elseif (kind == "quotes")
        model = Alpaca.MyCryptoLatestQuotesEndpointModel(symbols = symbols, loc = loc);
    elseif (kind == "trades")
        model = Alpaca.MyCryptoLatestTradesEndpointModel(symbols = symbols, loc = loc);
    elseif (kind == "orderbooks")
        model = Alpaca.MyCryptoLatestOrderbooksEndpointModel(symbols = symbols, loc = loc);
    elseif (kind == "snapshots")
        model = Alpaca.MyCryptoSnapshotsEndpointModel(symbols = symbols, loc = loc);
    else
        throw(ArgumentError("the kind must be bars, quotes, trades, orderbooks, or snapshots"));
    end
    return _plain_table(configuration, model, kind);
end

# get_crypto_latest_bars: the latest bar of each crypto pair -
function _get_crypto_latest_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_latest(arguments, configuration, "bars");
end

# get_crypto_latest_quotes: the latest bid and ask of each crypto pair -
function _get_crypto_latest_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_latest(arguments, configuration, "quotes");
end

# get_crypto_latest_trades: the latest trade of each crypto pair -
function _get_crypto_latest_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_latest(arguments, configuration, "trades");
end

# get_crypto_orderbooks: the latest order book of each crypto pair -
function _get_crypto_orderbooks(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_latest(arguments, configuration, "orderbooks");
end

# get_crypto_snapshots: the latest trade, quote, and bars of each crypto pair -
function _get_crypto_snapshots(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _crypto_latest(arguments, configuration, "snapshots");
end

# The properties of a crypto tool that reads a list of pairs and a location. The caller adds the rest -
function _crypto_properties()::Dict{String,Any}

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property("The crypto pairs, each written as BASE/QUOTE, e.g., [\"BTC/USD\"].");
    properties["loc"] = _property("string", "The location of the crypto market data. The default is us."; allowed = CRYPTO_LOCS);
    return properties;
end

# Add the tools of this file to the list of tools of the server -
function _add_crypto_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    # the sentences that several descriptions share -
    cap_text = "At most $(MAX_ROWS) rows: ask for fewer pairs or a shorter range when the result is too long.";
    unit_text = "Prices are in USD per coin and sizes are in coins. Crypto trades every day of the week.";
    start_text = "The first time, as a date (yyyy-mm-dd) or an RFC 3339 time in UTC, e.g., 2026-11-20T14:30:00Z.";
    end_text = "The last time, in the same form as start. Leave out for the latest data.";

    properties = _crypto_properties();
    properties["timeframe"] = _property("string", "The width of each bar. The default is 1Day."; allowed = BAR_TIMEFRAMES);
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["sort"] = _property("string", "The order of the bars in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_crypto_bars",
        description = "The open, high, low, close (USD per coin), and volume (coins) of each crypto pair, one bar for each " *
            "timeframe, with the time of each bar in UTC. " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_crypto_bars)));

    properties = _crypto_properties();
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["sort"] = _property("string", "The order of the quotes in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_crypto_quotes",
        description = "The historical bid and ask price and size of each crypto pair, with the time of each quote in UTC. " *
            unit_text * " " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_crypto_quotes)));

    properties = _crypto_properties();
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["sort"] = _property("string", "The order of the trades in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_crypto_trades",
        description = "The historical trades of each crypto pair: the price and size of each, with the time in UTC. " *
            unit_text * " " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_crypto_trades)));

    properties = _crypto_properties();
    push!(tools, build(MyMCPToolModel, (name = "get_crypto_latest_bars",
        description = "The latest bar of each crypto pair: open, high, low, close (USD per coin), and volume (coins), " *
            "with the time in UTC.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_crypto_latest_bars)));

    push!(tools, build(MyMCPToolModel, (name = "get_crypto_latest_quotes",
        description = "The latest bid and ask price and size of each crypto pair, with the time in UTC. " * unit_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_crypto_latest_quotes)));

    push!(tools, build(MyMCPToolModel, (name = "get_crypto_latest_trades",
        description = "The latest trade of each crypto pair: the price and size, with the time in UTC. " * unit_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_crypto_latest_trades)));

    push!(tools, build(MyMCPToolModel, (name = "get_crypto_orderbooks",
        description = "The latest order book of each crypto pair: the bids and the asks, each with a price and a size, " *
            "with the time in UTC. " * unit_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_crypto_orderbooks)));

    push!(tools, build(MyMCPToolModel, (name = "get_crypto_snapshots",
        description = "The latest trade, quote, and bars of each crypto pair, with times in UTC. " * unit_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_crypto_snapshots)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
