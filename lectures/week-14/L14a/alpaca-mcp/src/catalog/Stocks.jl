# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Stocks tools
# =============================================================================
# The handlers of the tools for stock market data, followed by _add_stocks_tools!(...),
# which lists each tool's name, description, input schema, and handler.
# =============================================================================

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
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

# Add the tools of this file to the list of tools of the server -
function _add_stocks_tools!(tools::Array{MyMCPToolModel,1})::Nothing

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

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
