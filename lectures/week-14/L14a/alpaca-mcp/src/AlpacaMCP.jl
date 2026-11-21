module L14aAlpacaMCP

    # load external packages -
    import Alpaca # the Alpaca SDK: one endpoint model for each endpoint, api(...) for the calls, and submit(...), cancel(...), and close(...) for orders and positions
    import JSON # write JSON text: the MCP messages
    import TOML # read the credentials file
    import Dates # parse the dates of a request, and write the times of a result as text
    import DataFrames # the Alpaca SDK returns each result as a DataFrame
    import Base64 # write the bytes of an image result as text

    # what do we want to export?
    export MyMCPToolModel, MyMCPServerModel
    export credentials_path, load_server_configuration
    export process_message, serve, build_alpaca_server

    # load my codes. The Alpaca calls go through the Alpaca package -
    include("Types.jl")   # the MCP tool and server models
    include("Factory.jl") # build(...) for tools and servers
    include("Utility.jl") # read the credentials file, and check that it names a paper account
    include("Tools.jl")   # what every tool needs: the arguments, the input schema, and the rows of a result
    include(joinpath("catalog", "Account.jl"))    # the tools of the account, the clock, the assets, and the option contracts
    include(joinpath("catalog", "Orders.jl"))     # the tools of the orders and positions
    include(joinpath("catalog", "Watchlists.jl")) # the tools of the watchlists
    include(joinpath("catalog", "Stocks.jl"))     # the tools of stock market data
    include(joinpath("catalog", "Options.jl"))    # the tools of options
    include(joinpath("catalog", "Crypto.jl"))     # the tools of crypto
    include(joinpath("catalog", "MarketData.jl")) # the tools of news, movers, and other market data
    include("Catalog.jl") # the instructions of the server, and build_alpaca_server(...), which collects the tools
    include("Server.jl")  # the MCP server: process one message, and the server loop
end
