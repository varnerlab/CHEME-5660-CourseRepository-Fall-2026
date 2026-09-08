# Activate the course project and load the packages used by this optional module.
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using DataFrames    # labeled simulation summaries
using Distributions # normal probabilities
using Plots         # convergence and discretization plots
using PrettyTables  # formatted result tables
using Random        # reproducible Monte Carlo streams
using Statistics    # simulation means and standard errors
