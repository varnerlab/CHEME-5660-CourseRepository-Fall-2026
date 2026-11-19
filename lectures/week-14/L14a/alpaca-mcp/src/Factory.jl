# =============================================================================
# CHEME 5660 | L14a Alpaca server: build the tools and the server
# =============================================================================
# The build(...) methods for an MCP tool and an MCP server, as in the CHEME 5800
# L13d FRED server.
# =============================================================================

# --- PUBLIC METHODS BELOW HERE -------------------------------------------------------------------------------- #
"""
    build(model::Type{MyMCPToolModel}, data::NamedTuple) -> MyMCPToolModel

Build an MCP tool from its name, its description, its input schema, and its handler.

### Arguments
- `model::Type{MyMCPToolModel}`: the type of the model to build.
- `data::NamedTuple`: the data of the tool, with the keys `name::String`, `description::String`,
  `inputschema::Dict{String,Any}`, and `handler::Function`.

### Returns
- `MyMCPToolModel`: the tool. A server sends its name, description, and input schema to a client
  in the result of a `tools/list` request.
"""
function build(model::Type{MyMCPToolModel}, data::NamedTuple)::MyMCPToolModel

    # build an empty tool, and fill in its fields from the data -
    tool = model();
    tool.name = data.name;
    tool.description = data.description;
    tool.inputschema = data.inputschema;
    tool.handler = data.handler;

    # return the tool -
    return tool;
end

"""
    build(model::Type{MyMCPServerModel}, data::NamedTuple) -> MyMCPServerModel

Build an MCP server from its identity, its tools, and the configuration that its tools need.

### Arguments
- `model::Type{MyMCPServerModel}`: the type of the model to build.
- `data::NamedTuple`: the data of the server, with the keys `name::String`, `version::String`, `instructions::String`,
  `tools::Array{MyMCPToolModel,1}`, and `configuration::Dict{String,Any}`.

### Returns
- `MyMCPServerModel`: the server, with its tools stored in a dictionary keyed by the tool name.
"""
function build(model::Type{MyMCPServerModel}, data::NamedTuple)::MyMCPServerModel

    # build an empty server, and fill in its identity and configuration -
    server = model();
    server.name = data.name;
    server.version = data.version;
    server.instructions = data.instructions;
    server.configuration = data.configuration;

    # store the tools in a dictionary, so the server can look up a tool by its name -
    tools = Dict{String,MyMCPToolModel}();
    for tool ∈ data.tools
        tools[tool.name] = tool;
    end
    server.tools = tools;

    # return the server -
    return server;
end
# --- PUBLIC METHODS ABOVE HERE -------------------------------------------------------------------------------- #
