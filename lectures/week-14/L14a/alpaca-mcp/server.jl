# =============================================================================
# CHEME 5660 | L14a Alpaca server: the program that a host starts
# =============================================================================
# A host, e.g., Claude Code or the Codex command-line tool, starts this file as
# a subprocess, e.g.,
#
#   julia --startup-file=no server.jl
#
# and then talks to it over the standard input and output of the subprocess.
# The standard output is reserved for MCP messages. Julia and Pkg write their
# own messages, e.g., "Activating project ...", to the standard error stream.
# =============================================================================

# activate the course environment, and load the Alpaca server code -
include(joinpath(@__DIR__, "Include.jl"));

# read the credentials file: ALPACA_CREDENTIALS if it is set, otherwise conf/apidata.toml. The key and secret stay
# in this process, and the server refuses any endpoint but the paper trading endpoint -
configuration = load_server_configuration(credentials_path(L14A_ALPACA_MCP_ROOT));

# build the server, and run its loop until the client closes the connection -
server = build_alpaca_server(configuration);
serve(server; input = stdin, output = stdout);
