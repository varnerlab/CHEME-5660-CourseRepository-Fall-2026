# =============================================================================
# CHEME 5660 | L14a Alpaca server: what every tool needs
# =============================================================================
# Every tool of the server works in the same three steps:
#
#   1. check the arguments of the call, and read them into Julia values,
#   2. call Alpaca through the Alpaca SDK, which returns a DataFrame (a read)
#      or an Alpaca.Order (an order), and
#   3. turn the result into rows of JSON values that the language model reads.
#
# This file holds the helpers of the three steps and the helpers that write the
# input schema of a tool. The tools themselves are in src/Catalog.jl.
# =============================================================================

# a language model reads the whole result of a tool, so the server keeps each result short -
const MAX_ROWS = 300; # the most rows that one tool returns
const MAX_SYMBOLS = 50; # the most symbols in one request

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# The Alpaca client of the server. When the server could not read its credentials file, the configuration holds the
# reason under the key setup_error, and each tool reports it as a tool execution error -
function _client(configuration::AbstractDict)::Alpaca.AlpacaClient

    if (haskey(configuration, "setup_error") == true)
        throw(ArgumentError(configuration["setup_error"]));
    end
    return configuration["client"];
end

# Check that every argument of a call is one that the tool takes. A wrong name is a tool execution error, and the
# language model can read the message -
function _check_argument_names(arguments::AbstractDict, allowed::Array{String,1})::Nothing

    for key ∈ keys(arguments)
        if ((key in allowed) == false)
            if (isempty(allowed) == true)
                throw(ArgumentError("unknown argument: $(key). This tool takes no arguments"));
            end
            throw(ArgumentError("unknown argument: $(key). The arguments of this tool are: $(join(allowed, ", "))"));
        end
    end
    return nothing;
end

# Read a text argument. A required argument that is missing is an error. An optional one gets its default -
function _text_argument(arguments::AbstractDict, name::String; required::Bool = false,
    default::Union{Nothing,String} = nothing)::Union{Nothing,String}

    if (haskey(arguments, name) == false)
        if (required == true)
            throw(ArgumentError("the $(name) argument is required"));
        end
        return default;
    end
    value = arguments[name];
    if (isa(value, AbstractString) == false)
        throw(ArgumentError("the $(name) must be text"));
    end
    return String(value);
end

# Read a number argument, e.g., a share count or a price. Julia counts true and false as numbers, so we rule them out -
function _number_argument(arguments::AbstractDict, name::String)::Union{Nothing,Float64}

    if (haskey(arguments, name) == false)
        return nothing;
    end
    value = arguments[name];
    if (isa(value, Real) == false || isa(value, Bool) == true)
        throw(ArgumentError("the $(name) must be a number"));
    end
    if (value <= 0)
        throw(ArgumentError("the $(name) must be greater than zero"));
    end
    return Float64(value);
end

# Read a whole-number argument with a default and a range -
function _integer_argument(arguments::AbstractDict, name::String, default::Int64, smallest::Int64, largest::Int64)::Int64

    if (haskey(arguments, name) == false)
        return default;
    end
    value = arguments[name];
    if (isa(value, Integer) == false || isa(value, Bool) == true)
        throw(ArgumentError("the $(name) must be a whole number"));
    end
    if (value < smallest || value > largest)
        throw(ArgumentError("the $(name) must be between $(smallest) and $(largest)"));
    end
    return Int64(value);
end

# Read a list of ticker symbols. Each symbol is written in capital letters -
function _symbols_argument(arguments::AbstractDict, name::String; required::Bool = true)::Union{Nothing,Array{String,1}}

    if (haskey(arguments, name) == false)
        if (required == true)
            throw(ArgumentError("the $(name) argument is required"));
        end
        return nothing;
    end
    value = arguments[name];
    if (isa(value, AbstractVector) == false || isempty(value) == true)
        throw(ArgumentError("the $(name) must be a list of ticker symbols, e.g., [\"AAPL\", \"MSFT\"]"));
    end
    if (length(value) > MAX_SYMBOLS)
        throw(ArgumentError("ask for at most $(MAX_SYMBOLS) symbols in one call"));
    end
    symbols = Array{String,1}();
    for item ∈ value
        if (isa(item, AbstractString) == false)
            throw(ArgumentError("each entry of $(name) must be a ticker symbol, as text"));
        end
        push!(symbols, uppercase(String(item)));
    end
    return symbols;
end

# Read a date argument, written as yyyy-mm-dd -
function _date_argument(arguments::AbstractDict, name::String; required::Bool = true)::Union{Nothing,Dates.Date}

    text = _text_argument(arguments, name; required = required);
    if (isnothing(text) == true)
        return nothing;
    end
    date = nothing;
    try
        date = Dates.Date(text, Dates.dateformat"yyyy-mm-dd");
    catch
        throw(ArgumentError("the $(name) must be a date written as yyyy-mm-dd, e.g., 2026-11-02"));
    end
    return date;
end

# Turn one value of a result into a JSON value: numbers, text, true or false, or null. Times become text -
function _json_value(value)

    if (isnothing(value) == true || ismissing(value) == true)
        return nothing;
    elseif (isa(value, Bool) == true || isa(value, AbstractString) == true)
        return value;
    elseif (isa(value, AbstractFloat) == true)
        if (isfinite(value) == false)
            return nothing; # JSON has no NaN or Inf
        end
        return value;
    elseif (isa(value, Number) == true)
        return value;
    elseif (isa(value, Dates.TimeType) == true || isa(value, Symbol) == true)
        return string(value);
    end
    return string(value); # anything else, as text
end

# Turn a DataFrame from the Alpaca SDK into rows: one dictionary for each row, keyed by the column names. A result
# with too many rows is an error, and the message tells the language model how to ask for less -
function _rows(df::DataFrames.DataFrame)::Array{Dict{String,Any},1}

    # check the length -
    number_of_rows = DataFrames.nrow(df);
    if (number_of_rows > MAX_ROWS)
        throw(ArgumentError("the result has $(number_of_rows) rows, more than the $(MAX_ROWS) that this server returns. " *
            "Ask for fewer symbols or a shorter date range."));
    end

    # one dictionary for each row -
    rows = Array{Dict{String,Any},1}();
    columns = names(df); # the column names, as text
    for i ∈ 1:number_of_rows
        row = Dict{String,Any}();
        for column ∈ columns
            row[column] = _json_value(df[i, column]);
        end
        push!(rows, row);
    end
    return rows;
end

# The fields of an order that the language model needs: what was ordered, its status, and how much of it filled -
function _order_summary(order::Alpaca.Order)::Dict{String,Any}

    summary = Dict{String,Any}();
    summary["id"] = order.id;
    summary["client_order_id"] = order.client_order_id;
    summary["symbol"] = _json_value(order.symbol);
    summary["side"] = _json_value(order.side);
    summary["type"] = order.type;
    summary["time_in_force"] = order.time_in_force;
    summary["qty"] = _json_value(order.qty);
    summary["notional"] = _json_value(get(order.raw, :notional, nothing)); # the dollar amount of a notional order
    summary["filled_qty"] = order.filled_qty;
    summary["limit_price"] = _json_value(order.limit_price);
    summary["filled_avg_price"] = _json_value(order.filled_avg_price);
    summary["status"] = order.status;
    summary["submitted_at"] = _json_value(order.submitted_at);
    summary["filled_at"] = _json_value(order.filled_at);
    return summary;
end

# The input schema of a tool: an object with the given properties, of which some are required -
function _input_schema(properties::Dict{String,Any}, required::Array{String,1})::Dict{String,Any}

    schema = Dict{String,Any}();
    schema["type"] = "object";
    schema["properties"] = properties;
    schema["required"] = required;
    schema["additionalProperties"] = false; # the server rejects any other argument
    return schema;
end

# One property of an input schema: its JSON type and its description, and the allowed values of a text property -
function _property(type::String, description::String; allowed::Union{Nothing,Array{String,1}} = nothing)::Dict{String,Any}

    property = Dict{String,Any}();
    property["type"] = type;
    property["description"] = description;
    if (isnothing(allowed) == false)
        property["enum"] = allowed;
    end
    return property;
end

# The property of a list of ticker symbols -
function _symbols_property(description::String)::Dict{String,Any}

    property = Dict{String,Any}();
    property["type"] = "array";
    property["items"] = Dict{String,Any}("type" => "string");
    property["maxItems"] = MAX_SYMBOLS;
    property["description"] = description;
    return property;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #
