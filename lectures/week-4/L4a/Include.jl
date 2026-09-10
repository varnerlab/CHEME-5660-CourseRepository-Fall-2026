# setup paths -
const _ROOT = @__DIR__; # keep local paths stable when the notebook is launched from another directory
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");
const _PATH_TO_FIGS = joinpath(_ROOT, "figs");

# setup the course environment: walk up to the nearest Project.toml
# (repo root in a clone; bundle root in an unzipped weekly download) -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

# load external packages -
using VLQuantitativeFinancePackage # course models, market data, and lattice utilities
using DataFrames                   # labeled tabular data
using CSV                          # delimited data input and output
using Dates                        # trading-date values and operations
using LinearAlgebra                # matrix operations and vector norms
using Statistics                   # sample means and standard deviations
using StatsBase                    # descriptive statistics and sampling helpers
using Plots                        # graphical output
using Colors                       # plot color construction
using StatsPlots                   # statistical plotting recipes
using JLD2                         # Julia-native data loading
using FileIO                       # common data-file interface
using Distributions                # probability distributions and tail probabilities
using PrettyTables                 # formatted result tables
using UnicodePlots                 # terminal histograms

# include some local codes -
include(joinpath(_PATH_TO_SRC, "Compute.jl"));
include(joinpath(_PATH_TO_SRC, "Split.jl"));
