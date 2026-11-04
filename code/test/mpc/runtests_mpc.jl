# Tests of the MPCPortfolio submodule (the INFORMS 2026 engine), run in their own module because the
# submodule's exports share names with the course package's adaptive-portfolio exports.
module MPCPortfolioTests

using Test, Dates, Random, LinearAlgebra, Statistics, DataFrames, CSV, JLD2, JuMP
import VLQuantitativeFinancePackage
import VLQuantitativeFinancePackage: build
using VLQuantitativeFinancePackage.MPCPortfolio

include(joinpath(@__DIR__, "helpers.jl"))

@testset "MPCPortfolio" begin
    include(joinpath(@__DIR__, "test_namespace_and_course.jl"))
    for f in ("test_data.jl", "test_sim.jl", "test_covariance.jl", "test_allocators_utility.jl",
              "test_allocators_mv_ls.jl", "test_projection.jl", "test_costs_triggers.jl", "test_metrics.jl",
              "test_backtest.jl", "test_bandit.jl", "test_market_inputs.jl", "test_calibration.jl",
              "test_allocators_hedge.jl", "test_allocators_caps.jl", "test_allocators_eta.jl",
              "test_online_sim.jl", "test_hedge_pool.jl", "test_screens.jl", "test_screens_universe.jl",
              "test_study_config.jl", "test_growth_scorecard.jl", "test_study_backtest.jl", "test_limits.jl", "test_real_pipeline.jl", "test_synthetic.jl")
        include(joinpath(@__DIR__, f))
    end
end

end # module
