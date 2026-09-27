# Activate the nearest course project and load this example's packages -
import Pkg # package-environment activation
let d = @__DIR__ # start in this folder
    # Walk up one folder at a time until a Project.toml appears or we reach the filesystem root.
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate(); # use the course packages and install any that are missing
end

using VLQuantitativeFinancePackage # course dataset and growth-rate matrix
using DataFrames                   # labeled tabular results
using Distributions                # probability distributions
using LinearAlgebra                # linear solves and quadratic forms
using Statistics                   # sample moments
using Random                       # reproducible sampling
using Plots                        # plotting
using StatsPlots                   # statistical plot recipes
using PrettyTables                 # formatted tables
using JuMP                         # optimization-model construction
using MadNLP                       # nonlinear optimization
using MathOptInterface             # solver statuses

# Load the local frontier calculations -
include(joinpath(@__DIR__, "src", "FrontierGeometry.jl")); # frontier_weights, frontier_variance, solve_frontier_point
