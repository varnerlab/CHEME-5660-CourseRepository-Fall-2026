# L15a: the shared setup of the strategy scripts. Instructor only.
#
# The check and run scripts include this file. It loads the course engine and the 17 strategy files, and it builds
# the L15a settings, the market data, and the calibration.
#
# The L15a dates: the estimates are fit on 2016-01-04 to 2024-12-31, and the backtest runs 2025-01-02 to
# 2026-11-24. The other settings are the INFORMS v2 settings in code/src/data/mpc/study.toml.

using Pkg
Pkg.activate(normpath(joinpath(@__DIR__, "..", "..", "..", "..")); io=devnull)
using VLQuantitativeFinancePackage, Dates, JLD2, CSV, DataFrames, Statistics, LinearAlgebra, Random
import VLQuantitativeFinancePackage.MPCPortfolio as MPC

const _PATH_TO_L15A = normpath(joinpath(@__DIR__, ".."))
const _PATH_TO_L15A_DATA = joinpath(_PATH_TO_L15A, "data")
const _PATH_TO_STRATEGIES = joinpath(_PATH_TO_L15A, "strategies")
const _TRAIN_START = Date(2016, 1, 4)
const _TRAIN_STOP = Date(2024, 12, 31)
const _BACKTEST_START = Date(2025, 1, 2)
const _BACKTEST_STOP = Date(2026, 11, 24)

# the strategy files: 8 picking rules and 9 weighting rules, then the menu that lists them -
for folder in ("picking", "weighting")
    for file in sort(readdir(joinpath(_PATH_TO_STRATEGIES, folder)))
        if endswith(file, ".jl") == true
            include(joinpath(_PATH_TO_STRATEGIES, folder, file))
        end
    end
end
include(joinpath(_PATH_TO_STRATEGIES, "menu.jl"))

"""
    l15a_settings(; hedge::Bool, estimates::String, kw...)::MPC.MyStudySettings

The INFORMS v2 settings on the L15a dates, with the market hedge on or off and the estimates `"updated"` or
`"fixed"`. Other keywords override settings by field name, for example `stop` or `forecast_model`.
"""
function l15a_settings(; hedge::Bool, estimates::String, kw...)::MPC.MyStudySettings
    base = MPC.load_study(MPC.default_study_path()).settings
    return MPC.with_settings(base; start=_BACKTEST_START, stop=_BACKTEST_STOP, train_start=_TRAIN_START,
        train_stop=_TRAIN_STOP, hedge=hedge, estimates=estimates, kw...)
end

"""
    l15a_market()::MPC.MyMarketData

The L15a market data from the first fit day to the last backtest day.
"""
function l15a_market()::MPC.MyMarketData
    return MPC.load_l15a_market(_PATH_TO_L15A_DATA; start=_TRAIN_START, stop=_BACKTEST_STOP)
end

"""
    l15a_calibration(md::MPC.MyMarketData)::MPC.MyCalibration

The 2016–2024 single-index fit and the residual-covariance shrinkage of the L15a market.
"""
function l15a_calibration(md::MPC.MyMarketData)::MPC.MyCalibration
    return MPC.calibrate(md; train_start=_TRAIN_START, train_stop=_TRAIN_STOP)
end
