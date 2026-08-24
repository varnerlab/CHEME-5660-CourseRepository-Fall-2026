# Reuse the production L2b environment and support files from this optional exercise.
const _ROOT = normpath(joinpath(@__DIR__, "..", ".."));
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");
const _PATH_TO_FIGS = joinpath(_ROOT, "figs");

import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using VLQuantitativeFinancePackage
using DataFrames
using CSV
using Dates
using LinearAlgebra
using Statistics
using StatsBase
using Plots
using Colors
using StatsPlots
using JLD2
using FileIO
using Distributions
using PrettyTables

