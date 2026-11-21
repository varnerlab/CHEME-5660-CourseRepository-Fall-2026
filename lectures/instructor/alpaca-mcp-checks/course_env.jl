# =============================================================================
# CHEME 5660 | L14a Alpaca server checks: the course environment
# =============================================================================
# The check scripts run the server in the course environment, the same
# environment that server.jl uses. The course Manifest.toml pins the Alpaca SDK
# 0.5.0. The check scripts run this file with include("course_env.jl").
# =============================================================================
import Pkg

# the root of the course repository: this file is in lectures/instructor/alpaca-mcp-checks -
const COURSE_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."));

# activate the course environment -
Pkg.activate(COURSE_ROOT);
