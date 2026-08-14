# Setup the environment for this optional exercise: activate the course project
# and load the packages used by the notebook.
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

# load external packages -
using VLQuantitativeFinancePackage
using DataFrames
using LinearAlgebra
using Plots
using Random
