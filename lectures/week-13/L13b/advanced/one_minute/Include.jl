# setup paths -
const _ROOT = @__DIR__;
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");

# setup the course environment: walk up to the nearest Project.toml
# (repo root in a clone; bundle root in an unzipped weekly download) -
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
using Statistics
using Plots
using Colors
using PrettyTables
using FileIO
using JLD2
using HypothesisTests
using StatsPlots
using Dates # the time stamps of the one-minute bars
import JumpHMM # synthetic markets: always call JumpHMM functions qualified
import StatsBase # kurtosis and autocorrelations

# load the local helper functions -
include(joinpath(_PATH_TO_SRC, "Helper.jl"));
