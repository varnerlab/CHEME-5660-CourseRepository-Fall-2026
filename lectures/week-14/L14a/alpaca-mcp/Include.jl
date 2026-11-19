# =============================================================================
# CHEME 5660 | L14a Alpaca server: setup
# =============================================================================
# server.jl runs this file when a host starts the server. It finds this folder,
# activates the course environment, and loads the server code. The server loads
# only the packages it needs, so it starts quickly.
# =============================================================================

# the folder of this file, so nothing depends on the working directory. The guard makes running this file again harmless -
if !isdefined(@__MODULE__, :L14A_ALPACA_MCP_ROOT)
    const L14A_ALPACA_MCP_ROOT = @__DIR__
end

# activate the course environment: walk up to the nearest Project.toml (the repository root in a clone, the bundle
# root in an unzipped weekly download). Pkg writes its messages to the standard error stream -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d);
end

# the server code is wrapped in the L14aAlpacaMCP module:
#   src/Types.jl     the MCP tool and server models
#   src/Factory.jl   build(...) for the tools and the server
#   src/Utility.jl   read the credentials file, and check that it names a paper account
#   src/Tools.jl     what every tool needs: the arguments, the input schema, and the rows of a result
#   src/Catalog.jl   the tools of the server
#   src/Server.jl    the MCP server
if !isdefined(@__MODULE__, :L14aAlpacaMCP)
    include(joinpath(L14A_ALPACA_MCP_ROOT, "src", "AlpacaMCP.jl"))
end
using .L14aAlpacaMCP # the server; the leading dot means the module defined here
