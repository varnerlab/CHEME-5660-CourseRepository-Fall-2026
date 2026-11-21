# =============================================================================
# The MCP server: read one JSON-RPC message, route it by its method, and write
# one response. This file implements the tools part of protocol version
# 2026-07-28 over the stdio transport: server/discover, tools/list, and
# tools/call. It also answers the initialize request of the older version
# 2025-06-18, which some hosts still use, e.g., the Codex command-line tool.
# The tools themselves are in src/catalog/. This file is the one of the
# CHEME 5800 L13d FRED server, except that it hides the Alpaca key and secret.
# =============================================================================

# the protocol version of this server -
const MCP_PROTOCOL_VERSION = "2026-07-28";

# the older protocol version. A host of this version names the version once, in its initialize request,
# and its later requests name no version -
const MCP_OLDER_PROTOCOL_VERSION = "2025-06-18";

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# Wrap a result in a JSON-RPC response message. Every result of protocol version 2026-07-28 carries a
# resultType field, and the server names itself in the _meta field of each result.
function _result_message(server::MyMCPServerModel, id, result::Dict{String,Any})::Dict{String,Any}

    # the fields that every result carries -
    result["resultType"] = "complete";
    serverinfo = Dict{String,Any}("name" => server.name, "version" => server.version);
    result["_meta"] = Dict{String,Any}("io.modelcontextprotocol/serverInfo" => serverinfo);

    # the response message: the same id as the request, and the result -
    message = Dict{String,Any}();
    message["jsonrpc"] = "2.0";
    message["id"] = id;
    message["result"] = result;
    return message;
end

# Wrap an error in a JSON-RPC response message. The error object has a numeric code and a message.
# Some errors also carry a data field with more detail.
function _error_message(id, code::Int64, text::String; data = nothing)::Dict{String,Any}

    # the error object -
    error_object = Dict{String,Any}();
    error_object["code"] = code;
    error_object["message"] = text;
    if (isnothing(data) == false)
        error_object["data"] = data;
    end

    # the response message: the same id as the request, and the error -
    message = Dict{String,Any}();
    message["jsonrpc"] = "2.0";
    message["id"] = id;
    message["error"] = error_object;
    return message;
end

# initialize: the handshake of the older protocol version. The server answers with the older version,
# its capabilities, its name, and its instructions -
function _initialize(server::MyMCPServerModel, id)::Dict{String,Any}

    result = Dict{String,Any}();
    result["protocolVersion"] = MCP_OLDER_PROTOCOL_VERSION;
    result["capabilities"] = Dict{String,Any}("tools" => Dict{String,Any}()); # this server offers tools, and nothing else
    result["serverInfo"] = Dict{String,Any}("name" => server.name, "version" => server.version);
    result["instructions"] = server.instructions;
    return _result_message(server, id, result);
end

# server/discover: the protocol versions, the capabilities, and the identity of the server -
function _discover(server::MyMCPServerModel, id)::Dict{String,Any}

    result = Dict{String,Any}();
    result["supportedVersions"] = [MCP_PROTOCOL_VERSION];
    result["capabilities"] = Dict{String,Any}("tools" => Dict{String,Any}()); # this server offers tools, and nothing else
    result["instructions"] = server.instructions;
    result["ttlMs"] = 3600000; # a client may reuse this result for one hour (3,600,000 milliseconds)
    result["cacheScope"] = "public"; # every client gets the same result
    return _result_message(server, id, result);
end

# tools/list: the name, description, and input schema of each tool. The handler stays on the server -
function _list_tools(server::MyMCPServerModel, id)::Dict{String,Any}

    # one entry for each tool, sorted by name, so every client sees the same order -
    tools = Array{Dict{String,Any},1}();
    for name ∈ sort(collect(keys(server.tools)))
        tool = server.tools[name];
        entry = Dict{String,Any}();
        entry["name"] = tool.name;
        entry["description"] = tool.description;
        entry["inputSchema"] = tool.inputschema;
        push!(tools, entry);
    end

    # the result -
    result = Dict{String,Any}();
    result["tools"] = tools;
    result["ttlMs"] = 3600000; # the list does not change while the server runs
    result["cacheScope"] = "public";
    return _result_message(server, id, result);
end

# tools/call: run the handler of the named tool with the arguments of the request -
function _call_tool(server::MyMCPServerModel, id, params::AbstractDict)::Dict{String,Any}

    # which tool? A request that names no tool, or a tool that the server does not have, is a protocol error -
    if (haskey(params, "name") == false)
        return _error_message(id, -32602, "Invalid params: the request does not name a tool");
    end
    name = params["name"];
    if (haskey(server.tools, name) == false)
        return _error_message(id, -32602, "Unknown tool: $(name)");
    end
    tool = server.tools[name];
    arguments = get(params, "arguments", Dict{String,Any}()); # a tool with no arguments may get no arguments field
    if (isa(arguments, AbstractDict) == false)
        return _error_message(id, -32602, "Invalid params: the arguments must be a JSON object");
    end

    # run the tool. An error inside the tool is a tool execution error: the server returns a normal result
    # with isError set to true, and puts the error message in the content, so the language model can read it -
    result = Dict{String,Any}();
    try
        data = tool.handler(arguments, server.configuration);
        if (haskey(data, "image_png") == true)

            # an image result: the image block holds the PNG bytes as text, and a text block holds the other keys.
            # The result has no structuredContent. The key and secret are hidden in the text block, as in an error -
            png = data["image_png"];
            others = Dict{String,Any}();
            for (key_name, value) ∈ data
                if (key_name != "image_png")
                    others[key_name] = value;
                end
            end
            text = JSON.json(others);
            key = get(server.configuration, "key", "");
            if (isempty(key) == false)
                text = replace(text, key => "<your Alpaca key>");
            end
            secret = get(server.configuration, "secret", "");
            if (isempty(secret) == false)
                text = replace(text, secret => "<your Alpaca secret>");
            end
            image = Dict{String,Any}("type" => "image", "data" => Base64.base64encode(png), "mimeType" => "image/png");
            result["content"] = [image, Dict{String,Any}("type" => "text", "text" => text)];
        else
            result["content"] = [Dict{String,Any}("type" => "text", "text" => JSON.json(data))]; # the result as JSON text
            result["structuredContent"] = data; # the same result as a JSON object
        end
        result["isError"] = false;
    catch exception
        text = sprint(showerror, exception); # the error message as text, e.g., "ArgumentError: ..."

        # the Alpaca key and secret never go into an MCP message, even when an error message holds them -
        key = get(server.configuration, "key", "");
        if (isempty(key) == false)
            text = replace(text, key => "<your Alpaca key>");
        end
        secret = get(server.configuration, "secret", "");
        if (isempty(secret) == false)
            text = replace(text, secret => "<your Alpaca secret>");
        end
        result["content"] = [Dict{String,Any}("type" => "text", "text" => text)];
        result["isError"] = true;
    end
    return _result_message(server, id, result);
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #

# --- PUBLIC METHODS BELOW HERE -------------------------------------------------------------------------------- #
"""
    process_message(server::MyMCPServerModel, line::String) -> Union{Nothing, Dict{String,Any}}

Process one JSON-RPC message from a client, and return the response message.

The function parses the message, checks the protocol version in the `_meta` field of the request,
and routes the request by its method to `initialize`, `server/discover`, `tools/list`, or `tools/call`.
A request that names no version is a request of the older version `2025-06-18`.

### Arguments
- `server::MyMCPServerModel`: the server, with its tools and configuration.
- `line::String`: one line of JSON text from the client.

### Returns
- `Dict{String,Any}`: the response message, with either a `result` field or an `error` field.
- `nothing`: when the message is a notification (a message with no `id`), which gets no response.
"""
function process_message(server::MyMCPServerModel, line::String)::Union{Nothing, Dict{String,Any}}

    # parse the JSON text. Text that is not valid JSON gets a parse error, with no id -
    message = nothing;
    try
        message = JSON.parse(line);
    catch
        return _error_message(nothing, -32700, "Parse error: the message is not valid JSON");
    end
    if (isa(message, AbstractDict) == false)
        return _error_message(nothing, -32600, "Invalid request: the message is not a JSON object");
    end

    # every JSON-RPC 2.0 message names its version -
    if (get(message, "jsonrpc", "") != "2.0")
        return _error_message(nothing, -32600, "Invalid request: the jsonrpc field must be \"2.0\"");
    end

    # a message with no id is a notification. The server does not answer a notification -
    if (haskey(message, "id") == false)
        return nothing;
    end

    # the id is a string or a whole number. Julia counts true and false as whole numbers, so we check for them first -
    id = message["id"];
    if (isa(id, Bool) == true || (isa(id, String) == false && isa(id, Integer) == false))
        return _error_message(nothing, -32600, "Invalid request: the id must be a string or a whole number");
    end
    method = get(message, "method", "");
    params = get(message, "params", Dict{String,Any}());
    if (isa(params, AbstractDict) == false)
        return _error_message(id, -32602, "Invalid params: params must be a JSON object");
    end

    # a request of version 2026-07-28 names its protocol version in its _meta field. The server checks it on every
    # request. A request that names no version comes from a host of the older version, which named it in initialize -
    requested = nothing;
    if (haskey(params, "_meta") == true && isa(params["_meta"], AbstractDict) == true)
        requested = get(params["_meta"], "io.modelcontextprotocol/protocolVersion", nothing);
    end
    if (isnothing(requested) == false && requested != MCP_PROTOCOL_VERSION)
        data = Dict{String,Any}("supported" => [MCP_PROTOCOL_VERSION], "requested" => requested);
        return _error_message(id, -32022, "Unsupported protocol version", data = data);
    end

    # route the request by its method -
    if (method == "initialize")
        return _initialize(server, id); # the handshake of the older version
    elseif (method == "server/discover")
        return _discover(server, id); # call the discover method of the server
    elseif (method == "tools/list")
        return _list_tools(server, id); # call the list method of the server
    elseif (method == "tools/call")
        return _call_tool(server, id, params); # call the call method of the server
    end

    # any other method is a protocol error -
    return _error_message(id, -32601, "Method not found: $(method)");
end

"""
    serve(server::MyMCPServerModel; input::IO = stdin, output::IO = stdout)

Run the server loop of the stdio transport. Read one message per line from `input`, and write one response
per line to `output`. The loop ends when `input` reaches its end, i.e., when the client closes the connection.

### Arguments
- `server::MyMCPServerModel`: the server, with its tools and configuration.
- `input::IO = stdin`: the stream that the client writes to.
- `output::IO = stdout`: the stream that the client reads from. Only protocol messages go to this stream.
"""
function serve(server::MyMCPServerModel; input::IO = stdin, output::IO = stdout)

    # read one line at a time, until the client closes the stream -
    for line ∈ eachline(input)

        # skip an empty line -
        if (isempty(strip(line)) == true)
            continue;
        end

        # process the message. If the server itself fails, the client gets an internal error -
        response = nothing;
        try
            response = process_message(server, String(line));
        catch
            response = _error_message(nothing, -32603, "Internal error");
        end

        # write the response as one line of JSON text, and send it now -
        if (isnothing(response) == false)
            println(output, JSON.json(response));
            flush(output);
        end
    end
end
# --- PUBLIC METHODS ABOVE HERE -------------------------------------------------------------------------------- #
