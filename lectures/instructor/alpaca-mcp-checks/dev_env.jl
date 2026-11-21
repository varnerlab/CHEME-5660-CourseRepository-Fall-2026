# =============================================================================
# CHEME 5660 | L14a Alpaca server checks: the development environment
# =============================================================================
# The Alpaca SDK 0.5.0 is not released yet. It lives on a local checkout. This
# file copies the Project.toml and Manifest.toml of the course into a scratch
# folder, gives the course code package its full path, and points the scratch
# environment at the checkout. The Project.toml
# and Manifest.toml of the course repository stay as they are.
# The check scripts run this file with include("dev_env.jl").
# =============================================================================
import Pkg

# the local checkout of the Alpaca SDK 0.5.0 (branch endpoints-0.5) -
const ALPACA_SDK_PATH = expanduser("~/Desktop/julia_work/alpaca-markets-sdk");

# the root of the course repository: this file is in lectures/instructor/alpaca-mcp-checks -
const COURSE_ROOT = normpath(joinpath(@__DIR__, "..", "..", ".."));

# --- PRIVATE METHODS BELOW HERE ------------------------------------------------------------------------------- #
# Build the scratch environment, and activate it. The environment is built once, and later runs reuse it -
function _activate_scratch_environment()::Nothing

    # the scratch folder, with a copy of the course Project.toml and Manifest.toml -
    scratch = joinpath(tempdir(), "cheme5660-alpaca-mcp-dev-env");
    if (isfile(joinpath(scratch, "Manifest.toml")) == false)
        mkpath(scratch);
        cp(joinpath(COURSE_ROOT, "Project.toml"), joinpath(scratch, "Project.toml"); force = true);
        manifest = read(joinpath(COURSE_ROOT, "Manifest.toml"), String);
        manifest = replace(manifest, "path = \"code\"" => "path = \"$(joinpath(COURSE_ROOT, "code"))\""); # the course code package, by its full path
        write(joinpath(scratch, "Manifest.toml"), manifest);
        Pkg.activate(scratch);
        Pkg.develop(path = ALPACA_SDK_PATH); # use the checkout in place of the released Alpaca package
        Pkg.instantiate();
    else
        Pkg.activate(scratch);
    end
    return nothing;
end
# --- PRIVATE METHODS ABOVE HERE ------------------------------------------------------------------------------- #

_activate_scratch_environment();
