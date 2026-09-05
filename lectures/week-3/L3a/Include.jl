# Setup paths -
const _ROOT = pwd();                          # working directory from which the notebook was launched
const _PATH_TO_SRC = joinpath(_ROOT, "src"); # local helper-code directory
const _PATH_TO_DATA = joinpath(_ROOT, "data"); # local data directory
const _PATH_TO_FIGS = joinpath(_ROOT, "figs"); # local figure directory

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
using VLQuantitativeFinancePackage # course-specific market-data and quantitative-finance tools
using DataFrames                   # labeled tabular data
using CSV                          # comma-separated data-file input and output
using Dates                        # calendar-date types and arithmetic
using LinearAlgebra                # matrix decompositions and vector operations
using Statistics                   # summary statistics such as mean and std
using StatsBase                    # statistical utilities such as autocorrelation
using Plots                        # plotting interface
using Colors                       # color construction and conversion
using StatsPlots                   # statistical plotting recipes
using JLD2                         # Julia-native data serialization
using FileIO                       # common file-loading interface
using Distributions                # probability distributions and density functions
using PrettyTables                 # formatted tabular display
using ColorVectorSpace             # arithmetic on color-valued arrays
using Images                       # image data structures and transformations
using HypothesisTests              # statistical hypothesis tests
