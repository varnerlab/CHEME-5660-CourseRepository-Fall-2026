# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Account tools
# =============================================================================
# The handlers of the tools for the account and the clock, followed by _add_account_tools!(...),
# which lists each tool's name, description, input schema, and handler.
# =============================================================================

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

# get_asset: whether a stock can be traded, bought in fractions of a share, or sold short -
function _get_asset(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    _check_argument_names(arguments, ["symbol"]);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));
    df = Alpaca.api(_client(configuration), Alpaca.MyAssetEndpointModel(symbol = symbol));
    rows = _rows(df);
    return Dict{String,Any}("asset" => rows[1]);
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

    properties = Dict{String,Any}();
    properties["symbol"] = _property("string", "The ticker symbol, e.g., JPM.");
    push!(tools, build(MyMCPToolModel, (name = "get_asset",
        description = "Whether a stock can be traded, bought in fractions of a share, or sold short.",
        inputschema = _input_schema(properties, ["symbol"]), handler = _get_asset)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
