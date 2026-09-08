# Activate the course project and load the packages used by this optional module.
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using DataFrames    # labeled moment and convergence tables
using Distributions # binomial, normal, and lognormal probabilities
using Plots         # distribution and convergence plots
using PrettyTables  # formatted result tables
