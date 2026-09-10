# Activate the nearest course project and load this example's packages -
import Pkg # package-environment activation
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using VLQuantitativeFinancePackage # course data and portfolio solvers
using DataFrames                   # labeled tabular results
using Distributions                # probability distributions
using LinearAlgebra                # linear solves and quadratic forms
using Statistics                   # sample and bootstrap summaries
using Random                       # reproducible bootstrap draws
using Plots                        # plotting
using StatsPlots                   # box-plot recipes
using PrettyTables                 # formatted tables
using JuMP                         # optimization-model construction
using MadNLP                       # nonlinear optimization
using MathOptInterface             # solver statuses
