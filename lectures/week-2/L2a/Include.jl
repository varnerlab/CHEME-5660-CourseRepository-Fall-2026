# =============================================================================
# CHEME 5660 | L2a local setup
# =============================================================================
# Running `include(joinpath(@__DIR__, "Include.jl"))` from a notebook evaluates
# this file in the notebook's global scope. The setup has three sections:
#
#   1. PATHS        locate the L2a data and figure folders
#   2. ENVIRONMENT  activate the pinned course package environment
#   3. IMPORTS      bring the packages used by the L2a notebooks into scope
#
# Keeping this setup in one file makes the executable examples shorter and
# ensures that both notebooks use the same paths and package versions.
# =============================================================================


# --- 1. PATHS ----------------------------------------------------------------
# `@__DIR__` is the directory containing this file. Unlike `pwd()`, it does not
# depend on the directory from which Julia or Jupyter was launched.
const _ROOT = @__DIR__;                        # L2a directory
const _PATH_TO_DATA = joinpath(_ROOT, "data"); # local Treasury data files
const _PATH_TO_FIGS = joinpath(_ROOT, "figs"); # local lecture figures


# --- 2. ENVIRONMENT ----------------------------------------------------------
# Walk upward from the L2a directory until we find the nearest Project.toml. In
# a repository clone this is the repository root; in a weekly release it is the
# root of the unpacked bundle.
import Pkg                    # Julia's package-environment manager
let project_root = @__DIR__   # keep the changing search path local to this block
    while !isfile(joinpath(project_root, "Project.toml")) &&
            project_root != dirname(project_root)
        project_root = dirname(project_root); # move one directory upward
    end

    # Stop with a useful message if no course environment was found.
    isfile(joinpath(project_root, "Project.toml")) ||
        error("No Project.toml found above $(@__DIR__)");

    Pkg.activate(project_root); # select the recorded course environment
    Pkg.instantiate();          # install missing dependencies without upgrading them
end


# --- 3. IMPORTS --------------------------------------------------------------
# One package per line makes the notebook's available tools easy to audit.
using VLQuantitativeFinancePackage # Treasury datasets, security models, and pricing routines
using DataFrames                   # labeled tabular data
using CSV                          # comma-separated data files
using Dates                        # issue dates, maturity dates, and calendar arithmetic
using LinearAlgebra                # vector and matrix operations
using Statistics                   # mean, maximum, and other summary statistics
using StatsBase                    # extended statistical utilities
using Plots                        # general plotting interface
using Colors                       # color definitions and conversions
using StatsPlots                   # statistical plotting recipes
using JLD2                         # Julia-native binary data storage
using FileIO                       # common file input/output interface
using Distributions                # probability distributions
using PrettyTables                 # formatted text tables
