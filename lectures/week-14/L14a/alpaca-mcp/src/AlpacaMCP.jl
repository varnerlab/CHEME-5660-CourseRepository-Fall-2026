module L14aAlpacaMCP

    # load external packages -
    import Alpaca # the Alpaca SDK: one endpoint model for each read endpoint, api(...) for the calls, submit(...) and cancel(...) for orders
    import JSON # write JSON text: the MCP messages
    import TOML # read the credentials file
    import Dates # parse the dates of a request, and write the times of a result as text
    import DataFrames # the Alpaca SDK returns each result as a DataFrame

    # what do we want to export?
    export MyMCPToolModel, MyMCPServerModel
    export credentials_path, load_server_configuration
    export process_message, serve, build_alpaca_server

    # load my codes. The Alpaca calls go through the Alpaca package -
    include("Types.jl")   # the MCP tool and server models
    include("Factory.jl") # build(...) for tools and servers
    include("Utility.jl") # read the credentials file, and check that it names a paper account
    include("Tools.jl")   # what every tool needs: the arguments, the input schema, and the rows of a result
    include("Catalog.jl") # the tools of the Alpaca server
    include("Server.jl")  # the MCP server: process one message, and the server loop
end
