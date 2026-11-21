# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Account tools
# =============================================================================
# The handlers of the tools for the account and the clock, followed by _add_account_tools!(...),
# which lists each tool's name, description, input schema, and handler.
# =============================================================================

# The markets that Alpaca keeps a calendar for. The market calendar and the market clocks use these names -
const CALENDAR_MARKETS = [
     "BMO", "BNYM", "BOATS", "CEUX", "CHIX", "HKEX", "IEX", "IEXG", "ISE", "LSE", "MTA", "MTAA", "NASDAQ",
    "NYSE", "OCEA", "OPRA", "OTC", "OTCM", "SIFMA", "TADAWUL", "XAMS", "XBRU", "XDUB", "XETR", "XETRA",
    "XHKG", "XLIS", "XLON", "XNAS", "XNYS", "XPAR", "XSAU"
];

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

# get_asset: whether a stock or a crypto pair can be traded, bought in fractions, or sold short -
function _get_asset(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    df = Alpaca.api(_client(configuration), Alpaca.MyAssetEndpointModel(symbol = symbol));
    rows = _rows(df);
    return Dict{String,Any}("asset" => rows[1]);
end

# get_account_configurations: the settings of the account, e.g., fractional trading and the margin multiplier -
function _get_account_configurations(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, String[]);
    df = Alpaca.api(_client(configuration), Alpaca.MyAccountConfigurationsEndpointModel());
    rows = _rows(df);
    return Dict{String,Any}("account_configurations" => rows[1]);
end

# update_account_configurations: change one or more settings of the account, and read all the settings back -
function _update_account_configurations(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    fields = ["disable_overnight_trading", "fractional_trading", "max_margin_multiplier", "max_options_trading_level",
        "no_shorting", "ptp_no_exception_entry", "suspend_trade", "trade_confirm_email"];
    _check_argument_names(arguments, fields);
    disable_overnight_trading = _boolean_argument(arguments, "disable_overnight_trading");
    fractional_trading = _boolean_argument(arguments, "fractional_trading");
    max_margin_multiplier = _choice_argument(arguments, "max_margin_multiplier", ["1", "2", "4"]);
    no_shorting = _boolean_argument(arguments, "no_shorting");
    ptp_no_exception_entry = _boolean_argument(arguments, "ptp_no_exception_entry");
    suspend_trade = _boolean_argument(arguments, "suspend_trade");
    trade_confirm_email = _choice_argument(arguments, "trade_confirm_email", ["all", "none"]);

    # the options trading level is a whole number from 0 to 3, or it is left out -
    max_options_trading_level = nothing;
    if (haskey(arguments, "max_options_trading_level") == true)
        max_options_trading_level = _integer_argument(arguments, "max_options_trading_level", 0, 0, 3);
    end

    # at least one of the eight settings must be given -
    if (isempty(arguments) == true)
        throw(ArgumentError("set at least one of: $(join(fields, ", "))"));
    end

    # call Alpaca -
    model = Alpaca.MyUpdateAccountConfigurationsEndpointModel(disable_overnight_trading = disable_overnight_trading,
        fractional_trading = fractional_trading, max_margin_multiplier = max_margin_multiplier,
        max_options_trading_level = max_options_trading_level, no_shorting = no_shorting,
        ptp_no_exception_entry = ptp_no_exception_entry, suspend_trade = suspend_trade,
        trade_confirm_email = trade_confirm_email);
    df = Alpaca.api(_client(configuration), model);
    rows = _rows(df);
    return Dict{String,Any}("account_configurations" => rows[1]);
end

# get_account_activities: the fills, dividends, and other activities of the account. Alpaca returns at most 100 at a time -
function _get_account_activities(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["activity_type", "activity_types", "category", "date", "after", "until",
        "direction", "page_size", "page_token", "order_id"]);
    activity_type = _text_argument(arguments, "activity_type"; default = nothing);
    activity_types = _text_list_argument(arguments, "activity_types"; required = false);
    if (isnothing(activity_type) == false && isnothing(activity_types) == false)
        throw(ArgumentError("set at most one of activity_type and activity_types"));
    end
    category = _choice_argument(arguments, "category", ["trade_activity", "non_trade_activity"]);
    date = _date_argument(arguments, "date"; required = false);
    after = _time_argument(arguments, "after");
    until = _time_argument(arguments, "until");
    direction = _choice_argument(arguments, "direction", ["asc", "desc"]; default = "desc");
    page_size = _integer_argument(arguments, "page_size", 100, 1, 100);
    page_token = _text_argument(arguments, "page_token"; default = nothing);
    order_id = _text_argument(arguments, "order_id"; default = nothing);

    # call Alpaca -
    model = Alpaca.MyAccountActivitiesEndpointModel(activity_type = activity_type, activity_types = activity_types,
        category = category, date = date, after = after, until = until, direction = direction, page_size = page_size,
        page_token = page_token, order_id = order_id);
    df = Alpaca.api(_client(configuration), model);
    return _table_result(df, "activities");
end

# get_portfolio_history: the equity and the profit and loss of the account over a period -
function _get_portfolio_history(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["period", "timeframe", "intraday_reporting", "start", "end", "pnl_reset",
        "extended_hours", "cashflow_types"]);
    period = _text_argument(arguments, "period"; default = nothing);
    timeframe = _text_argument(arguments, "timeframe"; default = nothing);
    intraday_reporting = _choice_argument(arguments, "intraday_reporting",
        ["market_hours", "extended_hours", "continuous"]);
    start = _time_argument(arguments, "start");
    finish = _time_argument(arguments, "end");
    pnl_reset = _choice_argument(arguments, "pnl_reset", ["no_reset", "per_day"]);
    extended_hours = _boolean_argument(arguments, "extended_hours");
    cashflow_types = _text_list_argument(arguments, "cashflow_types"; required = false);

    # call Alpaca -
    model = Alpaca.MyPortfolioHistoryEndpointModel(period = period, timeframe = timeframe,
        intraday_reporting = intraday_reporting, start = start, finish = finish, pnl_reset = pnl_reset,
        extended_hours = extended_hours, cashflow_types = cashflow_types);
    df = Alpaca.api(_client(configuration), model);
    return _table_result(df, "history");
end

# get_calendar: the trading days of the US stock market, with the open and close time of each day -
function _get_calendar(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["start", "end"]);
    start = _date_argument(arguments, "start");
    finish = _date_argument(arguments, "end"; required = false);

    # call Alpaca -
    df = Alpaca.api(_client(configuration), Alpaca.MyCalendarEndpointModel(start = start, finish = finish));
    return _table_result(df, "calendar");
end

# get_market_calendar: the trading days and the session times of one market -
function _get_market_calendar(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["market", "start", "end", "timezone"]);
    market = _choice_argument(arguments, "market", CALENDAR_MARKETS; default = "NYSE");
    start = _date_argument(arguments, "start");
    finish = _date_argument(arguments, "end"; required = false);
    timezone = _choice_argument(arguments, "timezone", ["UTC"]);

    # call Alpaca -
    model = Alpaca.MyMarketCalendarEndpointModel(market = market, start = start, finish = finish, timezone = timezone);
    df = Alpaca.api(_client(configuration), model);
    return _table_result(df, "calendar");
end

# get_market_clocks: whether each of several markets is open, and when each opens and closes next -
function _get_market_clocks(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["markets", "time"]);
    markets = _text_list_argument(arguments, "markets"; required = false, uppercase_items = true);
    time = _time_argument(arguments, "time");

    # call Alpaca -
    df = Alpaca.api(_client(configuration), Alpaca.MyMarketClocksEndpointModel(markets = markets, time = time));
    return _table_result(df, "clocks");
end

# get_assets: the assets of one class and status. The full list is far longer than one result can be, so the
# search argument keeps only the assets whose symbol or name contains the text -
function _get_assets(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["status", "asset_class", "search"]);
    status = _choice_argument(arguments, "status", ["active", "inactive"]; default = "active");
    asset_class = _choice_argument(arguments, "asset_class", ["us_equity", "us_option", "crypto"];
        default = "us_equity");
    search = _text_argument(arguments, "search"; default = nothing);

    # call Alpaca -
    model = Alpaca.MyAssetsEndpointModel(status = status, asset_class = asset_class);
    df = Alpaca.api(_client(configuration), model);

    # keep the rows whose symbol or name contains the search text, ignoring capital letters -
    if (isnothing(search) == false)
        needle = lowercase(search);
        keep = Array{Int64,1}();
        for i ∈ 1:DataFrames.nrow(df)
            symbol = lowercase(string(coalesce(df[i, "symbol"], "")));
            name = lowercase(string(coalesce(df[i, "name"], "")));
            if (occursin(needle, symbol) == true || occursin(needle, name) == true)
                push!(keep, i);
            end
        end
        df = df[keep, :];
    end

    # a result that is too long is an error that tells the language model to search -
    number_of_rows = DataFrames.nrow(df);
    if (number_of_rows > MAX_ROWS)
        throw(ArgumentError("the result has $(number_of_rows) assets, more than the $(MAX_ROWS) that this server " *
            "returns. Use the search argument to keep only the assets whose symbol or name contains a text."));
    end
    return _table_result(df, "assets");
end

# get_option_contracts: the option contracts of one or more underlying symbols that match the filters -
function _get_option_contracts(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["underlying_symbols", "status", "expiration_date", "expiration_date_gte",
        "expiration_date_lte", "strike_price_gte", "strike_price_lte", "type", "style"]);
    underlying_symbols = _symbols_argument(arguments, "underlying_symbols");
    status = _choice_argument(arguments, "status", ["active", "inactive"]; default = "active");
    expiration_date = _date_argument(arguments, "expiration_date"; required = false);
    expiration_date_gte = _date_argument(arguments, "expiration_date_gte"; required = false);
    expiration_date_lte = _date_argument(arguments, "expiration_date_lte"; required = false);
    strike_price_gte = _number_argument(arguments, "strike_price_gte");
    strike_price_lte = _number_argument(arguments, "strike_price_lte");
    type = _choice_argument(arguments, "type", ["call", "put"]);
    style = _choice_argument(arguments, "style", ["american", "european"]);

    # call Alpaca for one page of at most MAX_ROWS + 1 contracts, so a longer result is reported, not cut short -
    model = Alpaca.MyOptionContractsEndpointModel(underlying_symbols = underlying_symbols, status = status,
        expiration_date = expiration_date, expiration_date_gte = expiration_date_gte,
        expiration_date_lte = expiration_date_lte, strike_price_gte = strike_price_gte,
        strike_price_lte = strike_price_lte, type = type, style = style, limit = MAX_ROWS + 1);
    df = Alpaca.api(_client(configuration), model; max_pages = 1);
    return _table_result(df, "contracts");
end

# get_option_contract: one option contract, by its symbol or its identifier -
function _get_option_contract(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    df = Alpaca.api(_client(configuration), Alpaca.MyOptionContractEndpointModel(symbol = symbol));
    rows = _rows(df);
    return Dict{String,Any}("contract" => rows[1]);
end

# Add the tools of this file to the list of tools of the server -
function _add_account_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    none = Dict{String,Any}(); # the properties of a tool that takes no arguments

    push!(tools, build(MyMCPToolModel, (name = "get_account",
        description = "Read the paper account: its cash, buying power, equity, and status (USD).",
        inputschema = _input_schema(none, String[]), handler = _get_account)));

    push!(tools, build(MyMCPToolModel, (name = "get_clock",
        description = "Is the market open now? Returns the time now, and the times of the next open and the next close.",
        inputschema = _input_schema(none, String[]), handler = _get_clock)));


    push!(tools, build(MyMCPToolModel, (name = "get_account_configurations",
        description = "Read the settings of the paper account, e.g., fractional trading, the margin multiplier, and the options trading level.",
        inputschema = _input_schema(none, String[]), handler = _get_account_configurations)));

    properties = Dict{String,Any}();
    properties["disable_overnight_trading"] = _property("boolean", "true turns off overnight trading.");
    properties["fractional_trading"] = _property("boolean", "true allows trading in fractions of a share.");
    properties["max_margin_multiplier"] = _property("string", "The largest margin multiplier of the account.";
        allowed = ["1", "2", "4"]);
    properties["max_options_trading_level"] = _property("integer", "The highest options trading level, from 0 to 3.");
    properties["no_shorting"] = _property("boolean", "true blocks short sales.");
    properties["ptp_no_exception_entry"] = _property("boolean", "true blocks entry orders for publicly traded partnerships.");
    properties["suspend_trade"] = _property("boolean", "true suspends all trading in the account.");
    properties["trade_confirm_email"] = _property("string", "Whether Alpaca emails a confirmation of each trade.";
        allowed = ["all", "none"]);
    push!(tools, build(MyMCPToolModel, (name = "update_account_configurations",
        description = "Update settings of the paper account, and return all its settings. Give at least one of the eight settings. " *
            "Settings that are left out stay as they are.",
        inputschema = _input_schema(properties, String[]), handler = _update_account_configurations)));

    properties = Dict{String,Any}();
    properties["activity_type"] = _property("string", "One activity type, e.g., FILL or DIV. Do not combine with activity_types.");
    properties["activity_types"] = _property("array", "Several activity types, e.g., [\"FILL\", \"DIV\"]. Do not combine with activity_type.");
    properties["activity_types"]["items"] = Dict{String,Any}("type" => "string");
    properties["category"] = _property("string", "Trade activities or non-trade activities. Used only when no activity type is given.";
        allowed = ["trade_activity", "non_trade_activity"]);
    properties["date"] = _property("string", "One day, as yyyy-mm-dd.");
    properties["after"] = _property("string", "Only activities after this time (UTC), as yyyy-mm-dd or an RFC 3339 time.");
    properties["until"] = _property("string", "Only activities until this time (UTC), as yyyy-mm-dd or an RFC 3339 time.");
    properties["direction"] = _property("string", "Newest first (desc, the default) or oldest first (asc).";
        allowed = ["asc", "desc"]);
    properties["page_size"] = _property("integer", "The most activities to return, from 1 to 100. The default is 100.");
    properties["page_token"] = _property("string", "The id of the last activity of the previous call, to read the next page.");
    properties["order_id"] = _property("string", "Only the activities of this order.");
    push!(tools, build(MyMCPToolModel, (name = "get_account_activities",
        description = "The fills, dividends, and other activities of the paper account (amounts in USD, times in UTC). " *
            "At most 100 activities for each call: pass the id of the last activity as page_token to read more.",
        inputschema = _input_schema(properties, String[]), handler = _get_account_activities)));

    properties = Dict{String,Any}();
    properties["period"] = _property("string", "The length of the history, e.g., 1W, 1M, or 1A.");
    properties["timeframe"] = _property("string", "The time between rows, e.g., 1Min, 15Min, 1H, or 1D.");
    properties["intraday_reporting"] = _property("string", "Which hours the intraday rows cover.";
        allowed = ["market_hours", "extended_hours", "continuous"]);
    properties["start"] = _property("string", "The start of the history (UTC), as yyyy-mm-dd or an RFC 3339 time.");
    properties["end"] = _property("string", "The end of the history (UTC), as yyyy-mm-dd or an RFC 3339 time.");
    properties["pnl_reset"] = _property("string", "Whether the profit and loss restarts at zero each day.";
        allowed = ["no_reset", "per_day"]);
    properties["extended_hours"] = _property("boolean", "true includes the extended trading hours.");
    properties["cashflow_types"] = _property("array", "The cash flow types to include, e.g., [\"ALL\"].");
    properties["cashflow_types"]["items"] = Dict{String,Any}("type" => "string");
    push!(tools, build(MyMCPToolModel, (name = "get_portfolio_history",
        description = "The equity and the profit and loss (USD) of the paper account over a period, with a time (UTC) for each row. " *
            "At most $(MAX_ROWS) rows: ask for a shorter period or wider timeframe when the result is too long. A value can be null.",
        inputschema = _input_schema(properties, String[]), handler = _get_portfolio_history)));

    properties = Dict{String,Any}();
    properties["start"] = _property("string", "The first day, as yyyy-mm-dd.");
    properties["end"] = _property("string", "The last day, as yyyy-mm-dd. Leave out for no last day.");
    push!(tools, build(MyMCPToolModel, (name = "get_calendar",
        description = "The trading days of the US stock market, with the open and close time of each day (US Eastern time). " *
            "Ask for a range of at most about one year: the result has at most $(MAX_ROWS) rows.",
        inputschema = _input_schema(properties, ["start"]), handler = _get_calendar)));

    properties = Dict{String,Any}();
    properties["market"] = _property("string", "The market, e.g., NYSE, NASDAQ, or XLON. The default is NYSE.";
        allowed = CALENDAR_MARKETS);
    properties["start"] = _property("string", "The first day, as yyyy-mm-dd.");
    properties["end"] = _property("string", "The last day, as yyyy-mm-dd.");
    properties["timezone"] = _property("string", "The time zone of the session times. Leave out for the market's own time zone.";
        allowed = ["UTC"]);
    push!(tools, build(MyMCPToolModel, (name = "get_market_calendar",
        description = "The trading days and the session times of one market. Ask for UTC with the timezone argument. " *
            "Ask for a range of at most about one year: the result has at most $(MAX_ROWS) rows.",
        inputschema = _input_schema(properties, ["start"]), handler = _get_market_calendar)));

    properties = Dict{String,Any}();
    properties["markets"] = _property("array", "The markets, using the same names as get_market_calendar, e.g., [\"NYSE\", \"XLON\"]. Leave out for all markets.");
    properties["markets"]["items"] = Dict{String,Any}("type" => "string");
    properties["time"] = _property("string", "Read the clocks at this time (UTC), as yyyy-mm-dd or an RFC 3339 time. Leave out for now.");
    push!(tools, build(MyMCPToolModel, (name = "get_market_clocks",
        description = "Whether each market is open now (or at the given time), and the times (UTC) of its next open and close.",
        inputschema = _input_schema(properties, String[]), handler = _get_market_clocks)));

    properties = Dict{String,Any}();
    properties["status"] = _property("string", "The status of the assets. The default is active.";
        allowed = ["active", "inactive"]);
    properties["asset_class"] = _property("string", "The class of the assets. The default is us_equity.";
        allowed = ["us_equity", "us_option", "crypto"]);
    properties["search"] = _property("string", "Keep only the assets whose symbol or name contains this text, e.g., bank.");
    push!(tools, build(MyMCPToolModel, (name = "get_assets",
        description = "The assets that Alpaca lists, with whether each can be traded, shorted, or bought in fractions. " *
            "The full list is far longer than $(MAX_ROWS) assets: use search to find the assets you need.",
        inputschema = _input_schema(properties, String[]), handler = _get_assets)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol, e.g., JPM, or a crypto pair, e.g., BTC/USD.");
    push!(tools, build(MyMCPToolModel, (name = "get_asset",
        description = "Whether a stock or a crypto pair, e.g., BTC/USD, can be traded, bought in fractions of a share or coin, or sold short.",
        inputschema = _input_schema(properties, ["symbol"]), handler = _get_asset)));

    properties = Dict{String,Any}();
    properties["underlying_symbols"] = _symbols_property("The underlying ticker symbols, e.g., [\"SPY\"].");
    properties["status"] = _property("string", "The status of the contracts. The default is active.";
        allowed = ["active", "inactive"]);
    properties["expiration_date"] = _property("string", "Only contracts that expire on this day, as yyyy-mm-dd.");
    properties["expiration_date_gte"] = _property("string", "Only contracts that expire on or after this day, as yyyy-mm-dd.");
    properties["expiration_date_lte"] = _property("string", "Only contracts that expire on or before this day, as yyyy-mm-dd.");
    properties["strike_price_gte"] = _property("number", "Only contracts with a strike price of at least this (USD per share).");
    properties["strike_price_lte"] = _property("number", "Only contracts with a strike price of at most this (USD per share).");
    properties["type"] = _property("string", "Calls or puts."; allowed = ["call", "put"]);
    properties["style"] = _property("string", "The exercise style."; allowed = ["american", "european"]);
    push!(tools, build(MyMCPToolModel, (name = "get_option_contracts",
        description = "The option contracts of the underlying symbols: symbol, type, strike price (USD per share), expiration date, " *
            "and size (shares per contract). At most $(MAX_ROWS) rows: narrow the expiration dates or the strike prices when the result is too long.",
        inputschema = _input_schema(properties, ["underlying_symbols"]), handler = _get_option_contracts)));

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The option contract symbol or its id, e.g., SPY261120C00600000.");
    push!(tools, build(MyMCPToolModel, (name = "get_option_contract",
        description = "One option contract: its type, strike price (USD per share), expiration date, size (shares per contract), and status.",
        inputschema = _input_schema(properties, ["symbol"]), handler = _get_option_contract)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
