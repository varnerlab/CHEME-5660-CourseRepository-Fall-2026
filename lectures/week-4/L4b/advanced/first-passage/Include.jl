# Activate the course project and load the packages used by this optional module.
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using DataFrames    # labeled exit-probability summaries
using Distributions # normal and binomial probabilities
using Plots         # barrier and convergence plots
using PrettyTables  # formatted result tables
using Random        # reproducible path simulation
using Statistics    # Monte Carlo means

# Load the first-passage probability and simulation functions -
include(joinpath(@__DIR__, "src", "Probabilities.jl"))
include(joinpath(@__DIR__, "src", "Lattice.jl"))
include(joinpath(@__DIR__, "src", "Simulation.jl"))
