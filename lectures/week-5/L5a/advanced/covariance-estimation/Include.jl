# Activate the nearest course project and load this example's packages -
import Pkg # package-environment activation
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using VLQuantitativeFinancePackage # course dataset and growth-rate matrix
using DataFrames                   # labeled tabular results
using Distributions                # multivariate-normal simulation
using LinearAlgebra                # eigenvalues and linear solves
using Statistics                   # sample moments
using Random                       # reproducible simulation
using Plots                        # plotting
using PrettyTables                 # formatted tables
