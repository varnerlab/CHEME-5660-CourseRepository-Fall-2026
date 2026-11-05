# Fit the synthetic-market generator for L13b, once, and save it to ../data. This follows the INFORMS 2026
# study's generator fit (MPCPortfolio.fit_generator); JumpHMM.jl composes every synthetic market.
# Run from the repository root with threads, for example:
#   julia --project=. -t 10 lectures/week-13/L13b/scripts/fit_generator.jl
using Dates, JLD2, TOML
import VLQuantitativeFinancePackage
import VLQuantitativeFinancePackage.MPCPortfolio as MPC

const DATA = joinpath(@__DIR__, "..", "data")
const MARKET_MODEL = joinpath(DATA, "pretrained-jumphmm-market-surrogate.jld2")   # the INFORMS study's SPY model
const OUT = joinpath(DATA, "MPC-SyntheticGenerator-2014-2024.jld2")
const SUMMARY = joinpath(DATA, "MPC-SyntheticGenerator-2014-2024-summary.toml")

println(Threads.nthreads(), " threads")
t0 = time()
md = MPC.load_market_data(joinpath(dirname(pathof(VLQuantitativeFinancePackage)), "data");
    start = Date(2014, 1, 3), stop = Date(2026, 9, 4))
calib = MPC.calibrate(md; train_start = MPC.SYNTH_TRAIN[1], train_stop = MPC.SYNTH_TRAIN[2])
market = JLD2.load(MARKET_MODEL, "model")
println(length(md.tickers), " names; data and calibration ", round(time() - t0; digits = 1), " s")
fit = MPC.fit_generator(md, calib; market_model = market)
jldsave(OUT; generator = fit.generator, tickers = md.tickers, sectors = md.sector)
open(SUMMARY, "w") do io
    TOML.print(io, fit.summary; sorted = true)
end
println("wrote ", OUT, "; h_β = ", fit.summary["beta"]["h_beta"], ", k median ", round(fit.summary["beta"]["k_median"]; digits = 3),
    ", φ = ", fit.summary["alpha"]["phi"], "; wall ", round(time() - t0; digits = 1), " s")
