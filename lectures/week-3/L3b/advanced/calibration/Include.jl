# Setup the environment for this optional exercise: activate the course project
# and load the packages used by the notebook.
import Pkg # activate and instantiate the shared Julia environment
let d = @__DIR__ # begin the search in the directory containing Include.jl
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d) # move upward until a project file or filesystem root is reached
    end
    Pkg.activate(d); Pkg.instantiate(); # select the course environment and install missing dependencies
end

# Load external packages -
using VLQuantitativeFinancePackage # course-specific lattice calibration and market data
using DataFrames                   # labeled tabular data
using Distributions                # probability distributions and quantiles
using Plots                        # plotting interface
using PrettyTables                 # formatted tabular display
using Random                       # seeded random-number generation
using Statistics                   # summary statistics and quantiles
using StatsBase                    # statistical sampling utilities
