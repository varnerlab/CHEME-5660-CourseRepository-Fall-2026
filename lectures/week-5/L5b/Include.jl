# Set paths relative to this file so inclusion does not depend on the process directory -
const _ROOT = @__DIR__;
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");
const _PATH_TO_FIGS = joinpath(_ROOT, "figs");

# Activate the nearest course environment (repository root or weekly bundle root) -
import Pkg # package-environment activation
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

# Load external packages -
using VLQuantitativeFinancePackage # course data, models, and portfolio solvers
using DataFrames                   # labeled tabular data
using CSV                          # comma-separated parameter tables
using Dates                        # calendar dates
using LinearAlgebra                # matrix factorizations and quadratic forms
using Statistics                   # sample moments and correlations
using Random                       # reproducible random samples
using StatsBase                    # statistical utilities
using Plots                        # plotting
using Colors                       # color definitions
using StatsPlots                   # statistical plot recipes
using JLD2                         # Julia data files
using FileIO                       # file-format dispatch
using Distributions                # probability distributions
using PrettyTables                 # formatted tables
using HypothesisTests              # statistical tests
using MathOptInterface             # solver termination statuses

# Include local helper code -
include(joinpath(_PATH_TO_SRC, "Compute.jl"));
