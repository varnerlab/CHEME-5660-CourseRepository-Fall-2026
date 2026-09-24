# Set up paths relative to this file so notebook launches do not depend on pwd() -
const _ROOT = @__DIR__;
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

# Load the packages used by the L6b examples -
using VLQuantitativeFinancePackage # market data and portfolio models
using DataFrames                   # labeled tabular results
using LinearAlgebra                # covariance and quadratic-form operations
using Statistics                   # sample moments
using Plots                        # frontier and wealth plots
using JLD2                         # SIM parameter-archive loading
using MathOptInterface             # solver status codes
using PrettyTables                 # compact text tables
