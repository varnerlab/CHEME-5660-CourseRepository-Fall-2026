# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Stocks tools
# =============================================================================
# The handlers of the tools for stock market data, for US stocks and for stocks on non-US exchanges, followed by
# _add_stocks_tools!(...), which lists each tool's name, description, input schema, and handler.
# =============================================================================

# the values that a tool of this file accepts for an argument -
const STOCK_FEEDS = ["iex", "sip", "delayed_sip", "otc", "boats", "overnight"]; # the feeds of US stocks
const GLOBAL_STOCK_FEEDS = ["euroctp", "xetr", "xhkg", "xlon", "xsau"]; # the feeds of stocks on non-US exchanges
const BAR_TIMEFRAMES = ["1Min", "5Min", "15Min", "30Min", "1Hour", "4Hour", "1Day", "1Week", "1Month"];
const BAR_ADJUSTMENTS = ["raw", "split", "dividend", "spin-off", "all"];

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# Call Alpaca for a table that comes in pages, and keep the first page. The models ask for one row more than the
# server returns, so a page that is full has more rows than the cap, and the result is the message that tells the
# language model to ask for less. Without max_pages = 1, the SDK would download every page -
function _paged_table(configuration::AbstractDict, model, key::String)::Dict{String,Any}

    df = Alpaca.api(_client(configuration), model; max_pages = 1);
    return _table_result(df, key);
end

# Call Alpaca for a table that comes in one piece, e.g., the latest bars -
function _plain_table(configuration::AbstractDict, model, key::String)::Dict{String,Any}

    df = Alpaca.api(_client(configuration), model);
    return _table_result(df, key);
end

# get_bars: the open, high, low, close, and volume of each symbol over a range of times, for one width of bar -
function _get_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "start", "end", "timeframe", "adjustment", "feed"]);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    timeframe = _choice_argument(arguments, "timeframe", BAR_TIMEFRAMES; default = "1Day");
    adjustment = _choice_argument(arguments, "adjustment", BAR_ADJUSTMENTS; default = "raw");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");

    # call Alpaca -
    model = Alpaca.MyStockBarsEndpointModel(symbols = symbols, timeframe = timeframe, start = start, finish = finish,
        limit = MAX_ROWS + 1, adjustment = adjustment, feed = feed);
    return _paged_table(configuration, model, "bars");
end

# get_quotes: the bid and ask quotes of each symbol over a range of times -
function _get_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "start", "end", "feed"]);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");

    # call Alpaca -
    model = Alpaca.MyStockQuotesEndpointModel(symbols = symbols, start = start, finish = finish, limit = MAX_ROWS + 1,
        feed = feed);
    return _paged_table(configuration, model, "quotes");
end

# get_trades: the trades of each symbol over a range of times -
function _get_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "start", "end", "feed"]);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");

    # call Alpaca -
    model = Alpaca.MyStockTradesEndpointModel(symbols = symbols, start = start, finish = finish, limit = MAX_ROWS + 1,
        feed = feed);
    return _paged_table(configuration, model, "trades");
end

# get_latest_bars: the latest bar of each symbol -
function _get_latest_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "feed", "currency"]);
    symbols = _symbols_argument(arguments, "symbols");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");
    currency = _text_argument(arguments, "currency");

    # call Alpaca -
    model = Alpaca.MyStockLatestBarsEndpointModel(symbols = symbols, feed = feed, currency = currency);
    return _plain_table(configuration, model, "bars");
end

# get_latest_quotes: the latest bid and ask of each symbol, in one request. A symbol without a quote is reported,
# and the other symbols still come back -
function _get_latest_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "feed", "currency"]);
    symbols = _symbols_argument(arguments, "symbols");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");
    currency = _text_argument(arguments, "currency");

    # call Alpaca, which returns one row for each symbol that has a quote -
    model = Alpaca.MyStockLatestQuotesEndpointModel(symbols = symbols, feed = feed, currency = currency);
    df = Alpaca.api(_client(configuration), model);
    quotes = _rows(df);

    # the symbols that came back with no row -
    quoted = Dict{String,Bool}();
    for row ∈ quotes
        quoted[string(row["symbol"])] = true;
    end
    missing_symbols = Array{String,1}();
    for symbol ∈ symbols
        if (haskey(quoted, symbol) == false)
            push!(missing_symbols, symbol);
        end
    end
    return Dict{String,Any}("quotes" => quotes, "symbols_without_quote" => missing_symbols);
end

# get_latest_trades: the latest trade of each symbol -
function _get_latest_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "feed", "currency"]);
    symbols = _symbols_argument(arguments, "symbols");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");
    currency = _text_argument(arguments, "currency");

    # call Alpaca -
    model = Alpaca.MyStockLatestTradesEndpointModel(symbols = symbols, feed = feed, currency = currency);
    return _plain_table(configuration, model, "trades");
end

# get_snapshots: the latest trade, quote, and bars of each symbol -
function _get_snapshots(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "feed"]);
    symbols = _symbols_argument(arguments, "symbols");
    feed = _choice_argument(arguments, "feed", STOCK_FEEDS; default = "iex");

    # call Alpaca -
    model = Alpaca.MyStockSnapshotsEndpointModel(symbols = symbols, feed = feed);
    return _plain_table(configuration, model, "snapshots");
end

# get_auctions: the opening and closing auction prints of each symbol over a range of times. Alpaca has auctions
# from the sip feed only, so the tool takes no feed -
function _get_auctions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "start", "end", "sort"]);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start");
    finish = _time_argument(arguments, "end");
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]);

    # call Alpaca -
    model = Alpaca.MyStockAuctionsEndpointModel(symbols = symbols, start = start, finish = finish,
        limit = MAX_ROWS + 1, sort = sort);
    return _paged_table(configuration, model, "auctions");
end

# get_stock_conditions: the meaning of each condition code of the trades or the quotes of one tape -
function _get_stock_conditions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["ticktype", "tape"]);
    ticktype = _choice_argument(arguments, "ticktype", ["trade", "quote"]; default = "trade");
    tape = _choice_argument(arguments, "tape", ["A", "B", "C"]; default = "A");

    # call Alpaca -
    model = Alpaca.MyStockConditionsEndpointModel(ticktype = ticktype, tape = tape);
    return _plain_table(configuration, model, "conditions");
end

# get_stock_exchanges: the name of each exchange code in the stock data -
function _get_stock_exchanges(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments, and call Alpaca -
    _check_argument_names(arguments, String[]);
    return _plain_table(configuration, Alpaca.MyStockExchangesEndpointModel(), "exchanges");
end

# get_global_stock_bars: the bars of stocks on non-US exchanges over a range of times -
function _get_global_stock_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols", "start", "end", "timeframe", "sort"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    timeframe = _choice_argument(arguments, "timeframe", BAR_TIMEFRAMES; default = "1Day");
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]);

    # call Alpaca -
    model = Alpaca.MyGlobalStockBarsEndpointModel(feed = feed, symbols = symbols, timeframe = timeframe, start = start,
        finish = finish, page_size = MAX_ROWS + 1, sort = sort);
    return _paged_table(configuration, model, "bars");
end

# get_global_stock_quotes: the quotes of stocks on non-US exchanges over a range of times -
function _get_global_stock_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols", "start", "end", "sort"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]);

    # call Alpaca -
    model = Alpaca.MyGlobalStockQuotesEndpointModel(feed = feed, symbols = symbols, start = start, finish = finish,
        page_size = MAX_ROWS + 1, sort = sort);
    return _paged_table(configuration, model, "quotes");
end

# get_global_stock_trades: the trades of stocks on non-US exchanges over a range of times -
function _get_global_stock_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols", "start", "end", "sort"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");
    start = _time_argument(arguments, "start"; required = true);
    finish = _time_argument(arguments, "end");
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]);

    # call Alpaca -
    model = Alpaca.MyGlobalStockTradesEndpointModel(feed = feed, symbols = symbols, start = start, finish = finish,
        page_size = MAX_ROWS + 1, sort = sort);
    return _paged_table(configuration, model, "trades");
end

# get_global_stock_latest_bars: the latest bar of each stock on a non-US exchange -
function _get_global_stock_latest_bars(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");

    # call Alpaca -
    model = Alpaca.MyGlobalStockLatestBarsEndpointModel(feed = feed, symbols = symbols);
    return _plain_table(configuration, model, "bars");
end

# get_global_stock_latest_quotes: the latest quote of each stock on a non-US exchange -
function _get_global_stock_latest_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");

    # call Alpaca -
    model = Alpaca.MyGlobalStockLatestQuotesEndpointModel(feed = feed, symbols = symbols);
    return _plain_table(configuration, model, "quotes");
end

# get_global_stock_latest_trades: the latest trade of each stock on a non-US exchange -
function _get_global_stock_latest_trades(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");

    # call Alpaca -
    model = Alpaca.MyGlobalStockLatestTradesEndpointModel(feed = feed, symbols = symbols);
    return _plain_table(configuration, model, "trades");
end

# get_global_stock_snapshots: the latest trade, quote, and bars of each stock on a non-US exchange -
function _get_global_stock_snapshots(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["feed", "symbols"]);
    feed = _choice_argument(arguments, "feed", GLOBAL_STOCK_FEEDS; required = true);
    symbols = _symbols_argument(arguments, "symbols");

    # call Alpaca -
    model = Alpaca.MyGlobalStockSnapshotsEndpointModel(feed = feed, symbols = symbols);
    return _plain_table(configuration, model, "snapshots");
end

# The properties of a tool of US stock market data that reads a list of symbols and a feed. The caller adds the rest -
function _stock_properties(symbols_text::String)::Dict{String,Any}

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property(symbols_text);
    properties["feed"] = _property("string", "The market data feed. The default is iex, the free feed of the paper account.";
        allowed = STOCK_FEEDS);
    return properties;
end

# The properties of a tool of non-US stock market data: the feed, which is the exchange, and the symbols -
function _global_stock_properties()::Dict{String,Any}

    properties = Dict{String,Any}();
    properties["feed"] = _property("string", "The exchange feed. euroctp is Cboe Europe, xetr is Xetra, xhkg is Hong Kong, " *
        "xlon is London, and xsau is Saudi Arabia."; allowed = GLOBAL_STOCK_FEEDS);
    properties["symbols"] = _symbols_property("The symbols, each written as SYMBOL:MIC, e.g., [\"SAP:XETR\"].");
    return properties;
end

# Add the tools of this file to the list of tools of the server -
function _add_stocks_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    # the sentences that several descriptions share -
    cap_text = "At most $(MAX_ROWS) rows: ask for fewer symbols or a shorter range when the result is too long.";
    start_text = "The first time, as a date (yyyy-mm-dd) or an RFC 3339 time in UTC, e.g., 2026-11-20T14:30:00Z.";
    end_text = "The last time, in the same form as start. Leave out for the latest data.";
    global_text = "Needs a market-data subscription that the free paper plan lacks, so the paper account gets an " *
        "error for these exchanges. Prices are in the currency of the exchange per share.";

    properties = _stock_properties("The ticker symbols, e.g., [\"SPY\"].");
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["timeframe"] = _property("string", "The width of each bar. The default is 1Day."; allowed = BAR_TIMEFRAMES);
    properties["adjustment"] = _property("string", "The correction of the prices for corporate actions. The default is raw, " *
        "which is no correction."; allowed = BAR_ADJUSTMENTS);
    push!(tools, build(MyMCPToolModel, (name = "get_bars",
        description = "The open, high, low, close (USD per share), and volume (shares) of each symbol, one bar for each " *
            "timeframe, with the time of each bar in UTC. " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_bars)));

    properties = _stock_properties("The ticker symbols, e.g., [\"SPY\"].");
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    push!(tools, build(MyMCPToolModel, (name = "get_quotes",
        description = "The historical bid and ask price (USD per share) and size (shares) of each symbol, with the time " *
            "of each quote in UTC. " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_quotes)));

    push!(tools, build(MyMCPToolModel, (name = "get_trades",
        description = "The historical trades of each symbol: the price (USD per share) and size (shares) of each, with " *
            "the time in UTC. " * cap_text,
        inputschema = _input_schema(properties, ["symbols", "start"]), handler = _get_trades)));

    properties = _stock_properties("The ticker symbols, e.g., [\"JPM\", \"KO\"].");
    properties["currency"] = _property("string", "The currency of the prices, e.g., USD. Leave out for the default of Alpaca.");
    push!(tools, build(MyMCPToolModel, (name = "get_latest_bars",
        description = "The latest bar of each symbol: open, high, low, close (USD per share), and volume (shares), with the " *
            "time in UTC.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_latest_bars)));

    push!(tools, build(MyMCPToolModel, (name = "get_latest_quotes",
        description = "The latest bid and ask price (USD per share) and size (shares) of each symbol, from IEX unless " *
            "the feed says otherwise. Symbols without a quote are listed under symbols_without_quote.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_latest_quotes)));

    push!(tools, build(MyMCPToolModel, (name = "get_latest_trades",
        description = "The latest trade of each symbol: the price (USD per share) and size (shares), with the time in UTC.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_latest_trades)));

    properties = _stock_properties("The ticker symbols, e.g., [\"SPY\"].");
    push!(tools, build(MyMCPToolModel, (name = "get_snapshots",
        description = "The latest trade, the latest quote, and the latest minute, daily, and previous daily bars of each " *
            "symbol (USD per share, shares), with times in UTC.",
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_snapshots)));

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property("The ticker symbols, e.g., [\"SPY\"].");
    properties["start"] = _property("string", start_text * " Leave out for the earliest.");
    properties["end"] = _property("string", end_text);
    properties["sort"] = _property("string", "The order of the prints in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_auctions",
        description = "The opening and closing auction prints of each symbol (USD per share, shares), with times in UTC. " *
            "Alpaca has auctions from the sip feed only, which the free paper plan can lack. " * cap_text,
        inputschema = _input_schema(properties, ["symbols"]), handler = _get_auctions)));

    properties = Dict{String,Any}();
    properties["ticktype"] = _property("string", "trade or quote. The default is trade."; allowed = ["trade", "quote"]);
    properties["tape"] = _property("string", "The tape, A, B, or C. The default is A."; allowed = ["A", "B", "C"]);
    push!(tools, build(MyMCPToolModel, (name = "get_stock_conditions",
        description = "The meaning of each condition code that a trade or a quote of one tape can carry. Returns the code " *
            "and the name of each condition.",
        inputschema = _input_schema(properties, String[]), handler = _get_stock_conditions)));

    push!(tools, build(MyMCPToolModel, (name = "get_stock_exchanges",
        description = "The name of each exchange code that appears in the stock quotes and trades. Returns the code and " *
            "the name of each exchange.",
        inputschema = _input_schema(Dict{String,Any}(), String[]), handler = _get_stock_exchanges)));

    properties = _global_stock_properties();
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["timeframe"] = _property("string", "The width of each bar. The default is 1Day."; allowed = BAR_TIMEFRAMES);
    properties["sort"] = _property("string", "The order of the bars in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_bars",
        description = "The open, high, low, close, and volume (shares) of each stock on a non-US exchange, with times in " *
            "UTC. " * global_text * " " * cap_text,
        inputschema = _input_schema(properties, ["feed", "symbols", "start"]), handler = _get_global_stock_bars)));

    properties = _global_stock_properties();
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["sort"] = _property("string", "The order of the quotes in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_quotes",
        description = "The historical bid and ask price and size (shares) of each stock on a non-US exchange, with times " *
            "in UTC. " * global_text * " " * cap_text,
        inputschema = _input_schema(properties, ["feed", "symbols", "start"]), handler = _get_global_stock_quotes)));

    properties = _global_stock_properties();
    properties["start"] = _property("string", start_text);
    properties["end"] = _property("string", end_text);
    properties["sort"] = _property("string", "The order of the trades in time. The default is asc."; allowed = ["asc", "desc"]);
    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_trades",
        description = "The historical trades of each stock on a non-US exchange: the price and size (shares) of each, with " *
            "times in UTC. " * global_text * " " * cap_text,
        inputschema = _input_schema(properties, ["feed", "symbols", "start"]), handler = _get_global_stock_trades)));

    properties = _global_stock_properties();
    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_latest_bars",
        description = "The latest bar of each stock on a non-US exchange, with the time in UTC. " * global_text,
        inputschema = _input_schema(properties, ["feed", "symbols"]), handler = _get_global_stock_latest_bars)));

    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_latest_quotes",
        description = "The latest bid and ask price and size (shares) of each stock on a non-US exchange, with the time " *
            "in UTC. " * global_text,
        inputschema = _input_schema(properties, ["feed", "symbols"]), handler = _get_global_stock_latest_quotes)));

    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_latest_trades",
        description = "The latest trade of each stock on a non-US exchange: the price and size (shares), with the time in " *
            "UTC. " * global_text,
        inputschema = _input_schema(properties, ["feed", "symbols"]), handler = _get_global_stock_latest_trades)));

    push!(tools, build(MyMCPToolModel, (name = "get_global_stock_snapshots",
        description = "The latest trade, quote, and bars of each stock on a non-US exchange, with times in UTC. " * global_text,
        inputschema = _input_schema(properties, ["feed", "symbols"]), handler = _get_global_stock_snapshots)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
