# setup paths -
const _ROOT = @__DIR__;
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");
const _PATH_TO_FIGS = joinpath(_ROOT, "figs");

# activate the nearest course environment -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using DataFrames
using Distributions
using LinearAlgebra
using Plots
using PrettyTables
using Random
using Statistics
using StatsBase
using VLQuantitativeFinancePackage
using Dates # the trading days of the market data
using JLD2 # read the saved forecast models and backtests
using CodecZlib # read the compressed JLD2 files
import JumpHMM # the saved forecast models of the band trigger are JumpHMM models

# the INFORMS 2026 model-predictive portfolio method, a submodule of the course package: always call it
# qualified (MPC.calibrate, ...), because some of its names are also used by the course package itself.
import VLQuantitativeFinancePackage.MPCPortfolio as MPC

# load the functions in the local src directory -
include(joinpath(_PATH_TO_SRC, "Helper.jl"));

# load the strategy files: the picking rules, the weighting rules, and the menu that lists them -
const _PATH_TO_STRATEGIES = joinpath(_ROOT, "strategies");
for folder ∈ ("picking", "weighting")
    for file ∈ sort(readdir(joinpath(_PATH_TO_STRATEGIES, folder)))
        if endswith(file, ".jl") == true
            include(joinpath(_PATH_TO_STRATEGIES, folder, file));
        end
    end
end
include(joinpath(_PATH_TO_STRATEGIES, "menu.jl"));
