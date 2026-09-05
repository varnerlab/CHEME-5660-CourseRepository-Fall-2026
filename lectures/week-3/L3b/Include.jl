# setup the course environment: walk up to the nearest Project.toml
# (repo root in a clone; bundle root in an unzipped weekly download) -
import Pkg # activate and instantiate the shared Julia environment
let d = @__DIR__ # begin the search in the directory containing Include.jl
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d) # move upward until a project file or filesystem root is reached
    end
    Pkg.activate(d); Pkg.instantiate(); # select the course environment and install missing dependencies
end

# Load external packages -
using VLQuantitativeFinancePackage # course-specific lattice models and market data
using DataFrames                   # labeled tabular data
using CSV                          # comma-separated data-file input and output
using Dates                        # calendar-date types and arithmetic
using LinearAlgebra                # matrix and vector operations
using Statistics                   # summary statistics such as mean and variance
using StatsBase                    # statistical sampling and estimation utilities
using Plots                        # plotting interface
using Colors                       # color construction and conversion
using StatsPlots                   # statistical plotting recipes
using JLD2                         # Julia-native data serialization
using FileIO                       # common file-loading interface
using Distributions                # probability distributions
using PrettyTables                 # formatted tabular display
