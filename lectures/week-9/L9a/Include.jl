# setup paths -
# L9a uses no local source or data: the pricing models ship with
# VLQuantitativeFinancePackage and the figures are prebuilt in figs/.
const _ROOT = @__DIR__;
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
using DataFrames
using Statistics
using Random
using Plots
using PrettyTables