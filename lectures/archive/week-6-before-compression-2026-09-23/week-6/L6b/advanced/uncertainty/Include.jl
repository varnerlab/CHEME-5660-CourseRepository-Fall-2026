# Activate the nearest course environment (repo root or unzipped bundle root) -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d; io = devnull);
    Pkg.instantiate(; io = devnull);
end

# Load the packages used by the uncertainty example -
using VLQuantitativeFinancePackage # market data, SIM bootstrap, and uncertainty propagation
using DataFrames                   # labeled tabular results
using LinearAlgebra                # portfolio covariance operations
using Statistics                   # sample moments and quantiles
using Plots                        # uncertainty plots
using PrettyTables                 # compact text tables
