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
import Logging # silence the data loader's notes about split adjustments

# the INFORMS 2026 model-predictive portfolio method, a submodule of the course package: always call it
# qualified (MPC.calibrate, ...), because some of its names are also used by the course package itself.
import VLQuantitativeFinancePackage.MPCPortfolio as MPC

# the course's daily S&P 500 files, sector list, and 13-week bill rates (DTB3) -
const _PATH_TO_MARKET_DATA = joinpath(dirname(pathof(VLQuantitativeFinancePackage)), "data");

# load the functions in the local src directory -
include(joinpath(_PATH_TO_SRC, "Helper.jl"));
