# This file performs the shared setup for the executable L1b notebooks. Calling
# `include(...)` evaluates these definitions in the notebook's global scope.

# Setup paths relative to Include.jl so they do not depend on Julia's working directory -
const _ROOT = @__DIR__;                            # directory containing Include.jl
const _PATH_TO_SRC = joinpath(_ROOT, "src");       # conventional local source path
const _PATH_TO_DATA = joinpath(_ROOT, "data");     # conventional local data path
const _PATH_TO_FIGS = joinpath(_ROOT, "figs");     # local figure path

# Locate the nearest Project.toml by walking upward from the L1b directory. In a
# repository clone this is the repository root; in a weekly release it is the
# root of the unpacked bundle.
import Pkg                 # access Julia's package-environment tools
let d = @__DIR__           # keep the changing search path local to this block
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d) # stop at the project or filesystem root
        d = dirname(d)     # move one directory upward
    end

    # Guard against reaching the filesystem root without finding a course project -
    isfile(joinpath(d, "Project.toml")) ||
        error("no Project.toml found in any directory above $(@__DIR__)");

    Pkg.activate(d);       # select the course project and its dependency versions
    Pkg.instantiate();     # install missing recorded packages without upgrading them
end

# Load the common course toolkit; an individual notebook uses only a subset -
using VLQuantitativeFinancePackage # course financial models and valuation routines
using DataFrames                   # labeled tabular data
using CSV                          # comma-separated data files
using Dates                        # calendar dates and time periods
using PrettyTables                 # formatted text tables
using LinearAlgebra                # vector and matrix operations, including dot(...)
using Statistics                   # standard descriptive statistics
using StatsBase                    # extended statistical utilities
using Plots                        # general plotting interface
using Colors                       # color definitions and conversions
using StatsPlots                   # statistical plotting recipes
using JLD2                         # Julia-native binary data storage
using FileIO                       # common file input/output interface
using Distributions                # probability distributions
using LsqFit                       # nonlinear least-squares fitting
using MathOptInterface             # common interface to optimization solvers
using DataStructures               # specialized containers
using Flux                         # neural-network models and training tools
using OneHotArrays                 # one-hot representations of categorical data
