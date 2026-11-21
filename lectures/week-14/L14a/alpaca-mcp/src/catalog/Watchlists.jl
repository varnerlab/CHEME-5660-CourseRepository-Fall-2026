# =============================================================================
# CHEME 5660 | L14a Alpaca server: the Watchlists tools
# =============================================================================
# The handlers of the tools for watchlists, followed by _add_watchlists_tools!(...),
# which lists each tool's name, description, input schema, and handler.
# =============================================================================

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# Read the watchlist_id and the name of a call, and check that exactly one is given. Returns the pair (id, name) -
function _watchlist_identifier(arguments::AbstractDict)::Tuple{Union{Nothing,String},Union{Nothing,String}}

    watchlist_id = _text_argument(arguments, "watchlist_id");
    name = _text_argument(arguments, "name");
    if (isnothing(watchlist_id) == isnothing(name))
        throw(ArgumentError("give exactly one of watchlist_id and name"));
    end
    return (watchlist_id, name);
end

# Read the symbols of a watchlist: one row for each asset, so the symbols are the symbol column. A watchlist with no
# assets has no rows, and no symbols -
function _watchlist_symbols(df::DataFrames.DataFrame)::Array{String,1}

    symbols = Array{String,1}();
    for i ∈ 1:DataFrames.nrow(df)
        push!(symbols, String(df[i, "symbol"]));
    end
    return symbols;
end

# get_watchlists: the watchlists of the account, without their assets -
function _get_watchlists(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments, and call Alpaca -
    _check_argument_names(arguments, String[]);
    return _plain_table(configuration, Alpaca.MyWatchlistsEndpointModel(), "watchlists");
end

# get_watchlist: one watchlist with its assets, by identifier or by name -
function _get_watchlist(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["watchlist_id", "name"]);
    (watchlist_id, name) = _watchlist_identifier(arguments);

    # call Alpaca -
    model = Alpaca.MyWatchlistEndpointModel(id = watchlist_id, name = name);
    return _plain_table(configuration, model, "assets");
end

# create_watchlist: a new watchlist, with a name and a list of symbols -
function _create_watchlist(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["name", "symbols"]);
    name = _text_argument(arguments, "name"; required = true);
    symbols = _symbols_argument(arguments, "symbols"; required = false);
    if (isnothing(symbols) == true)
        symbols = Array{String,1}(); # a new watchlist can start empty
    end

    # call Alpaca -
    model = Alpaca.MyCreateWatchlistEndpointModel(name = name, symbols = symbols);
    return _plain_table(configuration, model, "assets");
end

# update_watchlist: a new name, a new list of symbols, or both. Alpaca replaces the whole watchlist, so a rename
# without symbols first reads the current symbols and sends them back -
function _update_watchlist(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments, and check that something changes -
    _check_argument_names(arguments, ["watchlist_id", "name", "new_name", "symbols"]);
    (watchlist_id, name) = _watchlist_identifier(arguments);
    new_name = _text_argument(arguments, "new_name");
    symbols = _symbols_argument(arguments, "symbols"; required = false);
    if (isnothing(new_name) == true && isnothing(symbols) == true)
        throw(ArgumentError("give new_name or symbols, or both"));
    end

    # a rename keeps the symbols of the watchlist -
    client = _client(configuration);
    if (isnothing(symbols) == true)
        current = Alpaca.api(client, Alpaca.MyWatchlistEndpointModel(id = watchlist_id, name = name));
        symbols = _watchlist_symbols(current);
    end

    # call Alpaca -
    model = Alpaca.MyUpdateWatchlistEndpointModel(id = watchlist_id, name = name, new_name = new_name, symbols = symbols);
    return _plain_table(configuration, model, "assets");
end

# add_to_watchlist: one symbol, added to a watchlist -
function _add_to_watchlist(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["watchlist_id", "name", "symbol"]);
    (watchlist_id, name) = _watchlist_identifier(arguments);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));

    # call Alpaca -
    model = Alpaca.MyAddWatchlistAssetEndpointModel(id = watchlist_id, name = name, symbol = symbol);
    return _plain_table(configuration, model, "assets");
end

# remove_from_watchlist: one symbol, removed from a watchlist. Alpaca removes by identifier only, so a call with
# the name of the watchlist first reads the watchlist to find its identifier -
function _remove_from_watchlist(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["watchlist_id", "name", "symbol"]);
    (watchlist_id, name) = _watchlist_identifier(arguments);
    symbol = uppercase(_text_argument(arguments, "symbol"; required = true));

    # find the identifier of a watchlist that is given by name -
    client = _client(configuration);
    if (isnothing(watchlist_id) == true)
        current = Alpaca.api(client, Alpaca.MyWatchlistEndpointModel(name = name));
        if (DataFrames.nrow(current) == 0)
            throw(ArgumentError("the watchlist $(name) has no assets, so there is nothing to remove"));
        end
        watchlist_id = String(current[1, "watchlist_id"]);
    end

    # call Alpaca -
    return _plain_table(configuration, Alpaca.MyRemoveWatchlistAssetEndpointModel(id = watchlist_id, symbol = symbol), "assets");
end

# delete_watchlist: a watchlist, by identifier or by name. Alpaca answers with no body, so the result is a confirmation -
function _delete_watchlist(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    # read the arguments -
    _check_argument_names(arguments, ["watchlist_id", "name"]);
    (watchlist_id, name) = _watchlist_identifier(arguments);

    # call Alpaca -
    Alpaca.api(_client(configuration), Alpaca.MyDeleteWatchlistEndpointModel(id = watchlist_id, name = name));
    if (isnothing(watchlist_id) == false)
        return Dict{String,Any}("deleted" => true, "watchlist_id" => watchlist_id);
    end
    return Dict{String,Any}("deleted" => true, "name" => name);
end

# Add the tools of this file to the list of tools of the server -
function _add_watchlists_tools!(tools::Array{MyMCPToolModel,1})::Nothing

    # the two ways to name a watchlist -
    id_text = "The identifier of the watchlist. Give watchlist_id or name, not both.";
    name_text = "The name of the watchlist. Give watchlist_id or name, not both.";
    table_text = "Returns one row for each asset, with the watchlist_id and watchlist_name. A watchlist with no assets " *
        "has no rows: read its identifier with get_watchlists.";

    push!(tools, build(MyMCPToolModel, (name = "get_watchlists",
        description = "The watchlists of the paper account: the identifier, name, and times of creation and update of " *
            "each, without the assets. Times are in UTC.",
        inputschema = _input_schema(Dict{String,Any}(), String[]), handler = _get_watchlists)));

    properties = Dict{String,Any}();
    properties["watchlist_id"] = _property("string", id_text);
    properties["name"] = _property("string", name_text);
    push!(tools, build(MyMCPToolModel, (name = "get_watchlist",
        description = "One watchlist of the paper account with its assets. " * table_text,
        inputschema = _input_schema(properties, String[]), handler = _get_watchlist)));

    properties = Dict{String,Any}();
    properties["name"] = _property("string", "The name of the new watchlist.");
    properties["symbols"] = _symbols_property("The ticker symbols that the watchlist starts with, e.g., [\"JPM\", \"KO\"]. " *
        "Leave out for an empty watchlist.");
    push!(tools, build(MyMCPToolModel, (name = "create_watchlist",
        description = "Create a watchlist in the paper account. " * table_text,
        inputschema = _input_schema(properties, ["name"]), handler = _create_watchlist)));

    properties = Dict{String,Any}();
    properties["watchlist_id"] = _property("string", id_text);
    properties["name"] = _property("string", "The current name of the watchlist. Give watchlist_id or name, not both.");
    properties["new_name"] = _property("string", "The new name of the watchlist.");
    properties["symbols"] = _symbols_property("The ticker symbols that replace the assets of the watchlist. " *
        "Leave out to keep the current assets.");
    push!(tools, build(MyMCPToolModel, (name = "update_watchlist",
        description = "Update a watchlist of the paper account: give a new name, a new list of symbols that replaces the " *
            "assets, or both. A new name alone keeps the current assets. " * table_text,
        inputschema = _input_schema(properties, String[]), handler = _update_watchlist)));

    properties = Dict{String,Any}();
    properties["watchlist_id"] = _property("string", id_text);
    properties["name"] = _property("string", name_text);
    properties["symbol"] = _property("string", "The ticker symbol to add, e.g., AAPL.");
    push!(tools, build(MyMCPToolModel, (name = "add_to_watchlist",
        description = "Add one symbol to a watchlist of the paper account. " * table_text,
        inputschema = _input_schema(properties, ["symbol"]), handler = _add_to_watchlist)));

    properties = Dict{String,Any}();
    properties["watchlist_id"] = _property("string", id_text);
    properties["name"] = _property("string", name_text);
    properties["symbol"] = _property("string", "The ticker symbol to remove, e.g., AAPL.");
    push!(tools, build(MyMCPToolModel, (name = "remove_from_watchlist",
        description = "Remove one symbol from a watchlist of the paper account. " * table_text,
        inputschema = _input_schema(properties, ["symbol"]), handler = _remove_from_watchlist)));

    properties = Dict{String,Any}();
    properties["watchlist_id"] = _property("string", id_text);
    properties["name"] = _property("string", name_text);
    push!(tools, build(MyMCPToolModel, (name = "delete_watchlist",
        description = "Delete a watchlist of the paper account. Returns a confirmation.",
        inputschema = _input_schema(properties, String[]), handler = _delete_watchlist)));

    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
