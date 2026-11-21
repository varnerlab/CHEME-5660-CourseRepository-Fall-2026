# =============================================================================
# CHEME 5660 | L14a Alpaca server: the server and its tools
# =============================================================================
# The tools are in src/catalog/, one file for each area: the account, the
# orders, the watchlists, stocks, options, crypto, and other market data. Each
# file holds the handlers of its tools and an _add_<area>_tools!(...) function
# that lists each tool's name, description, input schema, and handler. A
# handler takes the arguments of the call and the configuration of the server,
# and returns its result as a dictionary. This file holds the instructions of
# the server and build_alpaca_server(...), which collects the tools of all seven
# files.
# =============================================================================

# the instructions that the server sends to the host, which can pass them to its language model -
const SERVER_INSTRUCTIONS = """
Tools for one Alpaca paper trading account. A paper account trades simulated money at real market prices.
Read the account, the market clock, the positions, the orders, the latest quotes, and the daily bars, and submit
or cancel stock orders. Share counts are in shares, prices are in USD per share, and times are in UTC (New York
time is UTC minus 5 hours in winter and UTC minus 4 hours in summer). A paper account receives
quotes from one exchange (IEX), so its bid-ask spreads can be wider than the market's.
Before you submit orders, check the clock: an order submitted while the market is closed waits until the next open.
Submit each order only after the user asks for it.""";

# --- PUBLIC METHODS BELOW HERE -------------------------------------------------------------------------------- #
"""
    build_alpaca_server(configuration::Dict{String,Any}) -> MyMCPServerModel

Build the Alpaca server: its identity, its instructions, and its tools. Each file in `src/catalog/` adds the tools
of its area.

### Arguments
- `configuration::Dict{String,Any}`: the configuration from `load_server_configuration(...)`, with the Alpaca client.

### Returns
- `MyMCPServerModel`: the server, ready for `serve(...)`.
"""
function build_alpaca_server(configuration::Dict{String,Any})::MyMCPServerModel

    # collect the tools of each area -
    tools = Array{MyMCPToolModel,1}();
    _add_account_tools!(tools);
    _add_orders_tools!(tools);
    _add_watchlists_tools!(tools);
    _add_stocks_tools!(tools);
    _add_options_tools!(tools);
    _add_crypto_tools!(tools);
    _add_marketdata_tools!(tools);

    # build the server -
    server = build(MyMCPServerModel, (name = "alpaca-paper", version = "0.1.0", instructions = SERVER_INSTRUCTIONS,
        tools = tools, configuration = configuration));
    return server;
end
# --- PUBLIC METHODS ABOVE HERE -------------------------------------------------------------------------------- #
