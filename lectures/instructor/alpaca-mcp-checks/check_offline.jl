# =============================================================================
# CHEME 5660 | L14a Alpaca server checks: the offline check
# =============================================================================
# Run this file after every change to the tools of the server. It needs no
# Alpaca credentials and sends no request. It checks every tool for a unique
# name, a valid input schema, an error for an unknown argument, and the right
# start of the description of each tool that writes to the account.
#
#   julia --startup-file=no lectures/instructor/alpaca-mcp-checks/check_offline.jl
#
# The script prints the number of tools, and exits with a non-zero code when a
# check fails.
# =============================================================================
include(joinpath(@__DIR__, "course_env.jl"));
include(joinpath(COURSE_ROOT, "lectures", "week-14", "L14a", "alpaca-mcp", "src", "AlpacaMCP.jl"));
import JSON
using .L14aAlpacaMCP
import .L14aAlpacaMCP: build # build(...) for the test tool and the test server

# the tools that write to the account. Each description starts with a verb that says what the tool does -
const WRITE_TOOLS = ["update_account_configurations", "submit_order", "submit_option_order", "submit_crypto_order",
    "replace_order", "cancel_order", "cancel_all_orders", "close_position", "close_all_positions", "exercise_option",
    "do_not_exercise_option", "create_watchlist", "update_watchlist", "add_to_watchlist", "remove_from_watchlist",
    "delete_watchlist"];
const WRITE_VERBS = ["Submit", "Replace", "Cancel", "Close", "Exercise", "Tell", "Update", "Create", "Add", "Remove",
    "Delete"];

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# Send one request to the server, and return its result. A response with an error object is a failed check -
function _request(server::MyMCPServerModel, method::String, params::Dict{String,Any})::Dict{String,Any}

    message = Dict{String,Any}("jsonrpc" => "2.0", "id" => 1, "method" => method, "params" => params);
    response = process_message(server, JSON.json(message));
    if (haskey(response, "error") == true)
        error("the server answered $(method) with an error: $(response["error"]["message"])");
    end
    return response["result"];
end

# Check that the tool names are unique. The server keeps its tools in a dictionary, where a second tool of the
# same name replaces the first. So we collect the tools of the seven areas into one array, and count the names there -
function _check_unique_names()::Array{String,1}

    tools = Array{MyMCPToolModel,1}();
    L14aAlpacaMCP._add_account_tools!(tools);
    L14aAlpacaMCP._add_orders_tools!(tools);
    L14aAlpacaMCP._add_watchlists_tools!(tools);
    L14aAlpacaMCP._add_stocks_tools!(tools);
    L14aAlpacaMCP._add_options_tools!(tools);
    L14aAlpacaMCP._add_crypto_tools!(tools);
    L14aAlpacaMCP._add_marketdata_tools!(tools);
    failures = Array{String,1}();
    seen = Dict{String,Bool}();
    for tool ∈ tools
        if (haskey(seen, tool.name) == true)
            push!(failures, "the tool name $(tool.name) is used twice");
        end
        seen[tool.name] = true;
    end
    return failures;
end

# Check the input schema of one tool: an object that rejects other arguments, and every required name is a property -
function _check_schema(tool::AbstractDict)::Array{String,1}

    failures = Array{String,1}();
    name = tool["name"];
    schema = tool["inputSchema"];
    if (get(schema, "type", nothing) != "object")
        push!(failures, "$(name): the input schema type is not object");
    end
    if (get(schema, "additionalProperties", nothing) != false)
        push!(failures, "$(name): the input schema does not set additionalProperties to false");
    end
    properties = get(schema, "properties", Dict{String,Any}());
    for required_name ∈ get(schema, "required", Any[])
        if (haskey(properties, required_name) == false)
            push!(failures, "$(name): the required argument $(required_name) is not in the properties");
        end
    end
    return failures;
end

# Check that a call with an argument that the tool does not take is a tool execution error, with the right message -
function _check_unknown_argument(server::MyMCPServerModel, tool::AbstractDict)::Array{String,1}

    failures = Array{String,1}();
    name = tool["name"];
    params = Dict{String,Any}("name" => name, "arguments" => Dict{String,Any}("not_an_argument" => 1));
    result = _request(server, "tools/call", params);
    if (get(result, "isError", false) != true)
        push!(failures, "$(name): a call with an unknown argument is not an error");
        return failures;
    end
    text = result["content"][1]["text"];
    if (startswith(text, "ArgumentError: unknown argument") == false)
        push!(failures, "$(name): the message for an unknown argument is \"$(text)\"");
    end
    return failures;
end

# Check that the description of a tool that writes to the account starts with a verb of the list -
function _check_write_description(tool::AbstractDict)::Array{String,1}

    failures = Array{String,1}();
    if ((tool["name"] in WRITE_TOOLS) == false)
        return failures;
    end
    starts_well = false;
    for verb ∈ WRITE_VERBS
        if (startswith(tool["description"], verb) == true)
            starts_well = true;
        end
    end
    if (starts_well == false)
        push!(failures, "$(tool["name"]): the description does not start with one of $(join(WRITE_VERBS, ", "))");
    end
    return failures;
end
# Check that a call with arguments that are wrong for the tool is a tool execution error, with a message that names
# the problem. The offline server has a setup error, so a message about the arguments shows that the tool checked
# the arguments before it asked for the client -
function _check_argument_error(server::MyMCPServerModel, name::String, arguments::Dict{String,Any},
    expected::String)::Array{String,1}

    failures = Array{String,1}();
    result = _request(server, "tools/call", Dict{String,Any}("name" => name, "arguments" => arguments));
    if (get(result, "isError", false) != true)
        push!(failures, "$(name): a call with wrong arguments is not an error");
        return failures;
    end
    text = result["content"][1]["text"];
    if (occursin(expected, text) == false)
        push!(failures, "$(name): the message is \"$(text)\", and it does not contain \"$(expected)\"");
    end
    return failures;
end

# The handler of the test tool for the image check: a result with PNG bytes and one more key -
function _image_test_handler(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return Dict{String,Any}("image_png" => UInt8[0x89, 0x50, 0x4e, 0x47], "symbol" => "AAPL");
end

# Check that a result with the key image_png becomes an image block, then a text block with the other keys, and no
# structuredContent -
function _check_image_result()::Array{String,1}

    failures = Array{String,1}();

    # a server with one test tool -
    tool = build(MyMCPToolModel, (name = "image_test", description = "Return a test image.",
        inputschema = Dict{String,Any}("type" => "object", "properties" => Dict{String,Any}(), "required" => String[],
        "additionalProperties" => false), handler = _image_test_handler));
    configuration = Dict{String,Any}("key" => "test-key", "secret" => "test-secret");
    server = build(MyMCPServerModel, (name = "image-test", version = "0.0.0", instructions = "", tools = [tool],
        configuration = configuration));

    # call the tool, and read the content -
    result = _request(server, "tools/call", Dict{String,Any}("name" => "image_test"));
    content = result["content"];
    if (length(content) != 2)
        push!(failures, "image result: the content has $(length(content)) blocks, not 2");
        return failures;
    end
    if (content[1]["type"] != "image" || content[1]["data"] != "iVBORw==" || content[1]["mimeType"] != "image/png")
        push!(failures, "image result: the first block is not the PNG image block");
    end
    if (content[2]["type"] != "text" || JSON.parse(content[2]["text"]) != Dict{String,Any}("symbol" => "AAPL"))
        push!(failures, "image result: the second block is not the text block with the other keys");
    end
    if (haskey(result, "structuredContent") == true)
        push!(failures, "image result: the result has structuredContent");
    end
    return failures;
end
# The handler of the test tool for the redaction check: an image result whose text holds the test key -
function _leaky_image_handler(arguments::AbstractDict, configuration::AbstractDict)::Dict{String,Any}

    return Dict{String,Any}("image_png" => UInt8[0x89, 0x50, 0x4e, 0x47], "note" => "the key is test-key");
end

# Check that the text block of an image result does not hold the key -
function _check_image_redaction()::Array{String,1}

    failures = Array{String,1}();
    tool = build(MyMCPToolModel, (name = "leaky_image", description = "Return a test image.",
        inputschema = Dict{String,Any}("type" => "object", "properties" => Dict{String,Any}(), "required" => String[],
        "additionalProperties" => false), handler = _leaky_image_handler));
    configuration = Dict{String,Any}("key" => "test-key", "secret" => "test-secret");
    server = build(MyMCPServerModel, (name = "leaky-test", version = "0.0.0", instructions = "", tools = [tool],
        configuration = configuration));
    result = _request(server, "tools/call", Dict{String,Any}("name" => "leaky_image"));
    text = result["content"][2]["text"];
    if (occursin("test-key", text) == true)
        push!(failures, "image redaction: the text block of an image result holds the key");
    end
    if (occursin("<your Alpaca key>", text) == false)
        push!(failures, "image redaction: the text block does not hold the placeholder of the key");
    end
    return failures;
end

# Check that a table with a next page token is refused, and that a table without one is not -
function _check_next_page_token()::Array{String,1}

    failures = Array{String,1}();
    df = L14aAlpacaMCP.DataFrames.DataFrame(a = [1, 2]);
    L14aAlpacaMCP.DataFrames.metadata!(df, "next_page_token", "p2"; style = :note);
    refused = false;
    try
        L14aAlpacaMCP._check_one_page(df; advice = "Narrow the type.");
    catch exception
        refused = occursin("does not fit in one page", sprint(showerror, exception)) &&
            occursin("Narrow the type.", sprint(showerror, exception));
    end
    if (refused == false)
        push!(failures, "next page token: a table with a next page token is not refused with the advice");
    end
    complete = L14aAlpacaMCP.DataFrames.DataFrame(a = [1, 2]);
    try
        L14aAlpacaMCP._check_one_page(complete);
    catch exception
        push!(failures, "next page token: a table without a token is refused");
    end
    return failures;
end

# Check that a news result with too much article text is refused, and that a short one is not -
function _check_text_budget_refusal()::Array{String,1}

    failures = Array{String,1}();
    long_text = repeat("x", L14aAlpacaMCP.MAX_TEXT_CHARACTERS);
    df = L14aAlpacaMCP.DataFrames.DataFrame(content = [long_text, long_text]);
    refused = false;
    try
        L14aAlpacaMCP._check_text_budget(df, "content"; advice = "Leave out include_content.");
    catch exception
        refused = occursin("characters", sprint(showerror, exception));
    end
    if (refused == false)
        push!(failures, "text budget: an over-budget list of article texts is not refused");
    end
    short = L14aAlpacaMCP.DataFrames.DataFrame(content = ["a short article", missing]);
    try
        L14aAlpacaMCP._check_text_budget(short, "content");
    catch exception
        push!(failures, "text budget: a short list of article texts is refused");
    end
    return failures;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #

# build the server with no credentials. Every tool reports the setup error, so no call goes to Alpaca -
server = build_alpaca_server(Dict{String,Any}("setup_error" => "offline check"));
listing = _request(server, "tools/list", Dict{String,Any}());
tools = listing["tools"];

# run the checks, and collect the failures -
failures = Array{String,1}();
append!(failures, _check_unique_names());
for tool ∈ tools
    append!(failures, _check_schema(tool));
    append!(failures, _check_unknown_argument(server, tool));
    append!(failures, _check_write_description(tool));
end

# the order tools check their arguments before any request -
legs = Any[];
for i ∈ 1:5
    push!(legs, Dict{String,Any}("symbol" => "AAPL261218C00200000", "side" => "buy"));
end
append!(failures, _check_argument_error(server, "submit_option_order", Dict{String,Any}("legs" => legs, "qty" => 1,
    "type" => "limit", "limit_price" => 1.0), "4 legs"));
append!(failures, _check_argument_error(server, "submit_crypto_order", Dict{String,Any}("symbol" => "BTC/USD",
    "side" => "buy", "qty" => 0.1, "time_in_force" => "day"), "time_in_force"));

# the stock and watchlist tools check their arguments before any request -
append!(failures, _check_argument_error(server, "get_bars", Dict{String,Any}("symbols" => ["AAPL"],
    "start" => "2026-11-02", "timeframe" => "2Years"), "timeframe"));
append!(failures, _check_argument_error(server, "get_quotes", Dict{String,Any}("symbols" => ["AAPL"],
    "start" => "2026-11-02", "feed" => "nasdaq"), "feed"));
append!(failures, _check_argument_error(server, "get_global_stock_bars", Dict{String,Any}("feed" => "xetr",
    "symbols" => ["SAP:XETR"]), "start"));
append!(failures, _check_argument_error(server, "get_watchlist", Dict{String,Any}("watchlist_id" => "a",
    "name" => "b"), "exactly one"));
append!(failures, _check_argument_error(server, "update_watchlist", Dict{String,Any}("name" => "tech"),
    "new_name or symbols"));

# get_daily_bars is gone, and get_bars takes a timeframe -
tool_names = String[tool["name"] for tool ∈ tools];
if (("get_daily_bars" in tool_names) == true)
    push!(failures, "get_daily_bars is still a tool. get_bars replaces it");
end
if (("get_bars" in tool_names) == false)
    push!(failures, "the server has no get_bars tool");
else
    for tool ∈ tools
        if (tool["name"] == "get_bars" && haskey(tool["inputSchema"]["properties"], "timeframe") == false)
            push!(failures, "get_bars has no timeframe argument");
        end
    end
end

# every tool that writes to the account is listed by the server, so a renamed write tool fails here -
tool_names_listed = String[tool["name"] for tool ∈ tools];
for name ∈ WRITE_TOOLS
    if ((name in tool_names_listed) == false)
        push!(failures, "the write tool $(name) is not listed by the server");
    end
end

# the image result, and the redaction of its text block -
append!(failures, _check_image_result());
append!(failures, _check_image_redaction());

# the guards on the size of a result: a next page token, and the article text -
append!(failures, _check_next_page_token());
append!(failures, _check_text_budget_refusal());

# the number of tools. Raise this number when a task adds tools -
expected_tools = 74;
if (length(tools) != expected_tools)
    push!(failures, "the server lists $(length(tools)) tools, and the check expects $(expected_tools)");
end

# report -
if (isempty(failures) == true)
    println("$(length(tools)) tools, all checks pass");
else
    println("$(length(tools)) tools, $(length(failures)) checks fail:");
    for failure ∈ failures
        println("  ", failure);
    end
    exit(1);
end
