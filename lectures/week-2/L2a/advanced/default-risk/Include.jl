# =============================================================================
# CHEME 5660 | L2a advanced default-risk setup
# =============================================================================
# Running `include(joinpath(@__DIR__, "Include.jl"))` from the notebook activates
# the pinned course environment and imports the packages used in this module.
# =============================================================================


# --- 1. ENVIRONMENT ----------------------------------------------------------
# Walk upward from this directory until we find the nearest Project.toml. This
# works from both a repository clone and an unpacked weekly release.
import Pkg                    # Julia's package-environment manager
let project_root = @__DIR__   # keep the changing search path local to this block
    while !isfile(joinpath(project_root, "Project.toml")) &&
            project_root != dirname(project_root)
        project_root = dirname(project_root); # move one directory upward
    end

    # Stop with a useful message if the course environment cannot be located.
    isfile(joinpath(project_root, "Project.toml")) ||
        error("No Project.toml found above $(@__DIR__)");

    Pkg.activate(project_root); # select the recorded course environment
    Pkg.instantiate();          # install missing dependencies without upgrading them
end


# --- 2. IMPORTS --------------------------------------------------------------
using DataFrames     # labeled result and comparison tables
using Distributions  # Bernoulli default and survival events
using Plots          # price and yield-spread figures
using PrettyTables   # formatted display of result tables
using Random         # reproducible pseudo-random number generation
using Statistics     # sample means and standard deviations
