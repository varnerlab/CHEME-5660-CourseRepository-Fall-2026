# Activate the course project and load the packages used by this optional module.
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end

using DataFrames         # labeled terminal-outcome tables
using Distributions      # binomial node probabilities
using Plots              # probability and sensitivity plots
using Plots.PlotMeasures # explicit plot margins
