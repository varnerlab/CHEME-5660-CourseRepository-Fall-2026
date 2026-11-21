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
include(joinpath(@__DIR__, "dev_env.jl"));
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

# the image result -
append!(failures, _check_image_result());

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
