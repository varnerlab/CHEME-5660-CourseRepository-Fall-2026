# =============================================================================
# CHEME 5660 | L14a Alpaca server: the MarketData tools
# =============================================================================
# The handlers of the tools for news, the most active stocks, the movers, corporate actions, company logos, and
# bond prices, followed by _add_marketdata_tools!(...), which lists each tool's name, description, input schema,
# and handler.
# =============================================================================

# the values that a tool of this file accepts for an argument -
const REGIONS = ["us", "non_us", "all"]; # the regions of corporate actions
const DATA_QUALITIES = ["complete", "all"]; # the data quality of corporate actions

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# get_news: the news articles that mention the given symbols, newest first by default. Alpaca sends one page of at
# most 50 articles, so the tool asks for 10 unless the call says more -
function _get_news(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "start", "end", "sort", "limit", "include_content", "exclude_contentless"]);
    symbols = _symbols_argument(arguments, "symbols"; required = false);
    start = _time_argument(arguments, "start");
    finish = _time_argument(arguments, "end");
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]; default = "desc");
    limit = _integer_argument(arguments, "limit", 10, 1, 50);
    include_content = _boolean_argument(arguments, "include_content"; default = false);
    exclude_contentless = _boolean_argument(arguments, "exclude_contentless"; default = false);

    # call Alpaca -
    model = Alpaca.MyNewsEndpointModel(symbols = symbols, start = start, finish = finish, sort = sort, limit = limit,
        include_content = include_content, exclude_contentless = exclude_contentless);
    return _plain_table(configuration, model, "articles");
end

# get_most_actives: the most active stocks of the day, ranked by share volume or by number of trades -
function _get_most_actives(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["by", "top"]);
    by = _choice_argument(arguments, "by", ["volume", "trades"]; default = "volume");
    top = _integer_argument(arguments, "top", 10, 1, 100);

    # call Alpaca -
    model = Alpaca.MyMostActivesEndpointModel(by = by, top = top);
    return _plain_table(configuration, model, "most_actives");
end

# get_movers: the top gainers and the top losers of the day, for stocks or for crypto -
function _get_movers(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["market_type", "top"]);
    market_type = _choice_argument(arguments, "market_type", ["stocks", "crypto"]; default = "stocks");
    top = _integer_argument(arguments, "top", 10, 1, 50);

    # call Alpaca -
    model = Alpaca.MyMoversEndpointModel(market_type = market_type, top = top);
    return _plain_table(configuration, model, "movers");
end

# get_corporate_actions: corporate actions such as cash dividends and splits. The start and the end are dates -
function _get_corporate_actions(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbols", "cusips", "types", "start", "end", "ids", "sort", "region", "data_quality"]);
    symbols = _symbols_argument(arguments, "symbols"; required = false);
    cusips = _text_list_argument(arguments, "cusips"; required = false, uppercase_items = true);
    types = _text_list_argument(arguments, "types"; required = false);
    start = _date_argument(arguments, "start"; required = false);
    finish = _date_argument(arguments, "end"; required = false);
    ids = _text_list_argument(arguments, "ids"; required = false);
    sort = _choice_argument(arguments, "sort", ["asc", "desc"]);
    region = _choice_argument(arguments, "region", REGIONS);
    data_quality = _choice_argument(arguments, "data_quality", DATA_QUALITIES);

    # call Alpaca -
    model = Alpaca.MyCorporateActionsEndpointModel(symbols = symbols, cusips = cusips, types = types, start = start,
        finish = finish, ids = ids, limit = MAX_ROWS + 1, sort = sort, region = region, data_quality = data_quality);
    return _paged_table(configuration, model, "actions");
end

# get_logo: the logo of a company, as a PNG image. The server sends the image as an image block, and the symbol as text -
function _get_logo(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["symbol", "placeholder"]);
    symbol = _text_argument(arguments, "symbol"; required = true);
    symbol = uppercase(symbol);
    placeholder = _boolean_argument(arguments, "placeholder"; default = true);

    # call Alpaca, which returns the bytes of the PNG image -
    model = Alpaca.MyLogoEndpointModel(symbol = symbol, placeholder = placeholder);
    bytes = Alpaca.api(_client(configuration), model);
    return Dict{String,Any}("image_png" => bytes, "symbol" => symbol);
end

# The shared steps of get_fixed_income_prices and get_fixed_income_quotes. The kind is "prices" or "quotes". Only the
# quotes have a trade size. The helper reads the arguments, builds the model of the kind, and returns the table -
function _fixed_income(arguments::AbstractDict, configuration::AbstractDict, kind::String)::Dict{String,Any}

    # the names of the arguments that the kind takes -
    names = ["isins"];
    if (kind == "quotes")
        names = ["isins", "trade_size"];
    end

    # read the arguments -
    _check_argument_names(arguments, names);
    isins = _text_list_argument(arguments, "isins"; uppercase_items = true);
    trade_size = nothing;
    if (kind == "quotes" && haskey(arguments, "trade_size") == true)
        trade_size = _integer_argument(arguments, "trade_size", 1, 1, 1000000000);
    end

    # build the model of the kind -
    model = nothing;
    if (kind == "prices")
        model = Alpaca.MyFixedIncomeLatestPricesEndpointModel(isins = isins);
    elseif (kind == "quotes")
        model = Alpaca.MyFixedIncomeLatestQuotesEndpointModel(isins = isins, trade_size = trade_size);
    else
        throw(ArgumentError("the kind must be prices or quotes"));
    end
    return _plain_table(configuration, model, kind);
end

# get_fixed_income_prices: the latest price and yield of each bond -
function _get_fixed_income_prices(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _fixed_income(arguments, configuration, "prices");
end

# get_fixed_income_quotes: the latest bid and ask quotes of each bond -
function _get_fixed_income_quotes(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return _fixed_income(arguments, configuration, "quotes");
end

# Add the tools of this file to the list of tools of the server -
function _add_marketdata_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    # the sentences that several descriptions share -
    cap_text = "At most $(MAX_ROWS) rows: ask for fewer symbols or a shorter range when the result is too long.";
    paid_text = "Needs a paid market-data subscription that the free paper plan lacks, so the paper account gets an error.";
    time_text = "The time, as a date (yyyy-mm-dd) or an RFC 3339 time in UTC, e.g., 2026-11-20T14:30:00Z.";

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property("Only the articles that mention these ticker symbols, e.g., [\"AAPL\"]. " *
        "Leave out for all symbols.");
    properties["start"] = _property("string", "The earliest creation time of an article. " * time_text);
    properties["end"] = _property("string", "The latest creation time of an article. " * time_text);
    properties["sort"] = _property("string", "The order of the articles by creation time. The default is desc, newest first.";
        allowed = ["asc", "desc"]);
    properties["limit"] = _property("integer", "The number of articles, from 1 to 50. The default is 10.");
    properties["include_content"] = _property("boolean", "True to include the full text of each article. The default is " *
        "false, which keeps the result short.");
    properties["exclude_contentless"] = _property("boolean", "True to leave out the articles that have no content. The " *
        "default is false.");
    push!(tools, build(MyMCPToolModel, (name = "get_news",
        description = "The latest news articles, with the headline, the summary, the symbols, and the creation time in UTC. " *
            "One call returns one page. To get older articles, call again with end set to the created_at of the last " *
            "article of the previous call.",
        inputschema = _input_schema(properties, String[]), handler = _get_news)));

    properties = Dict{String,Any}();
    properties["by"] = _property("string", "Rank by volume (shares traded) or by trades (number of trades). The default is " *
        "volume."; allowed = ["volume", "trades"]);
    properties["top"] = _property("integer", "The number of stocks, from 1 to 100. The default is 10.");
    push!(tools, build(MyMCPToolModel, (name = "get_most_actives",
        description = "The most active stocks of the day, ranked by volume (shares) or by number of trades, with the " *
            "volume and the trade count of each. The update time is in UTC.",
        inputschema = _input_schema(properties, String[]), handler = _get_most_actives)));

    properties = Dict{String,Any}();
    properties["market_type"] = _property("string", "The market to screen. The default is stocks."; allowed = ["stocks", "crypto"]);
    properties["top"] = _property("integer", "The number of gainers and the number of losers, from 1 to 50. The default is 10.");
    push!(tools, build(MyMCPToolModel, (name = "get_movers",
        description = "The top gainers and the top losers of the day, for stocks or for crypto: the price (USD per share, " *
            "or USD per coin) and the change since the previous close, in USD and in percent. The update time is in UTC.",
        inputschema = _input_schema(properties, String[]), handler = _get_movers)));

    properties = Dict{String,Any}();
    properties["symbols"] = _symbols_property("The ticker symbols, e.g., [\"AAPL\"].");
    properties["cusips"] = _property("array", "The CUSIPs of the securities.");
    properties["cusips"]["items"] = Dict{String,Any}("type" => "string");
    properties["types"] = _property("array", "The types of corporate action, e.g., [\"cash_dividend\", \"forward_split\"].");
    properties["types"]["items"] = Dict{String,Any}("type" => "string");
    properties["ids"] = _property("array", "The identifiers of corporate actions.");
    properties["ids"]["items"] = Dict{String,Any}("type" => "string");
    properties["start"] = _property("string", "The first date, written as yyyy-mm-dd.");
    properties["end"] = _property("string", "The last date, written as yyyy-mm-dd.");
    properties["sort"] = _property("string", "The order of the actions in time. Leave out for the default of Alpaca.";
        allowed = ["asc", "desc"]);
    properties["region"] = _property("string", "The region of the securities: us, non_us, or all."; allowed = REGIONS);
    properties["data_quality"] = _property("string", "complete or all."; allowed = DATA_QUALITIES);
    push!(tools, build(MyMCPToolModel, (name = "get_corporate_actions",
        description = "Corporate actions such as cash dividends (USD per share) and splits (ratios), with the dates of " *
            "each action. " * cap_text,
        inputschema = _input_schema(properties, String[]), handler = _get_corporate_actions)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol of the company, e.g., AAPL.");
    properties["placeholder"] = _property("boolean", "True to get a placeholder image when the company has no logo. The " *
        "default is true.");
    push!(tools, build(MyMCPToolModel, (name = "get_logo",
        description = "The logo of a company, as a PNG image. " * paid_text,
        inputschema = _input_schema(properties, ["symbol"]), handler = _get_logo)));

    properties = Dict{String,Any}();
    properties["isins"] = _property("array", "The ISINs of the bonds, e.g., [\"US912810TW84\"].");
    properties["isins"]["items"] = Dict{String,Any}("type" => "string");
    properties["isins"]["maxItems"] = MAX_SYMBOLS;
    push!(tools, build(MyMCPToolModel, (name = "get_fixed_income_prices",
        description = "The latest price (USD per bond unit, as Alpaca quotes it), the yield to maturity, and the yield to " *
            "worst of each bond (percent per year), with the time in UTC. " * paid_text,
        inputschema = _input_schema(properties, ["isins"]), handler = _get_fixed_income_prices)));

    properties = Dict{String,Any}();
    properties["isins"] = _property("array", "The ISINs of the bonds, e.g., [\"US912810TW84\"].");
    properties["isins"]["items"] = Dict{String,Any}("type" => "string");
    properties["isins"]["maxItems"] = MAX_SYMBOLS;
    properties["trade_size"] = _property("integer", "The trade size that the quotes are for. Leave out for the default of Alpaca.");
    push!(tools, build(MyMCPToolModel, (name = "get_fixed_income_quotes",
        description = "The latest bid and ask quotes of each bond: the bid and ask price (USD per bond unit, as Alpaca " *
            "quotes it) and size, with the time in UTC. " * paid_text,
        inputschema = _input_schema(properties, ["isins"]), handler = _get_fixed_income_quotes)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
