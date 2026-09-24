# Set up paths relative to this file so notebook launches do not depend on pwd() -
const _ROOT = @__DIR__;
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");

# Activate the nearest course environment (repo root or unzipped bundle root) -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d; io = devnull);
    Pkg.instantiate(; io = devnull);
end

# Load the packages used by the L6a examples -
using VLQuantitativeFinancePackage # market data, SIM estimation, bootstrap, and diagnostics
using DataFrames                   # labeled tabular results
using LinearAlgebra                # least-squares factorizations and matrix operations
using Statistics                   # sample moments and correlations
using Plots                        # diagnostic plots
using JLD2                         # parameter-archive storage
using Distributions                # Student t quantiles
using PrettyTables                 # compact text tables

# Load the local lecture source -
include(joinpath(_PATH_TO_SRC, "Compute.jl"));
