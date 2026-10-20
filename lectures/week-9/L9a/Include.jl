# setup paths -
# The options chains and the pricing models ship with VLQuantitativeFinancePackage
# (the end-of-day options archive downloads on first use). The BSM premium example
# also reads an SPXW snapshot from data/, a copy of the file captured by
# ../L9b/advanced/spxw_volatility_skew/data/capture_spxw_ladder.jl. The figures are
# prebuilt in figs/.
const _ROOT = @__DIR__;
const _PATH_TO_DATA = joinpath(_ROOT, "data");
const _PATH_TO_FIGS = joinpath(_ROOT, "figs");

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
using CSV
using DataFrames
using Dates
using Statistics
using Random
using Plots
using PrettyTables
using Colors