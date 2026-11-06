# Acceptance check for the Farmer–Joshi market (run by hand, not part of runtests.jl):
#   julia --project=code code/test/acceptance/abm_acceptance.jl
# Prints ensemble statistics over seeds for the tendencies reported by Farmer and Joshi (2002),
# then a calibration table of the combined market for several reference-value processes.
using VLQuantitativeFinancePackage
using Random, Statistics, Printf

excess_kurtosis(x) = mean((x .- mean(x)) .^ 4) / var(x; corrected=false)^2 - 3
acf1(x) = sample_autocorrelation(x, [1])[1]
interval(x) = (mean(x), mean(x) - 1.96 * std(x) / sqrt(length(x)), mean(x) + 1.96 * std(x) / sqrt(length(x)))

const STEPS, BURN, SEEDS = 20_000, 2_000, 1:20

function market_stats(data::NamedTuple; seeds=SEEDS, path=nothing)
    rows = map(seeds) do k
        model = build(MyFarmerJoshiMarketModel, merge(data, (rng=MersenneTwister(5660 + k),)))
        r = solve(model; number_of_steps=STEPS, burn_in=BURN, rng=MersenneTwister(9000 + k), log_value_path=path)
        volume = r.value_volume .+ r.trend_volume
        (acf_r=acf1(r.returns), kurt=excess_kurtosis(r.returns), acf_abs=acf1(abs.(r.returns)),
            acf_vol=std(volume) > 0 ? acf1(volume) : NaN, sd=std(r.returns))
    end
    return rows
end

report(name, rows, f) = (m = interval([f(r) for r in rows]); @printf("  %-34s mean %8.4f   95%% CI [%8.4f, %8.4f]\n", name, m...))

println("Farmer–Joshi acceptance, Table 1 trader parameters, σ_S = 0.35√252 (0.35 per step), σ_v = 0.16, Δt = 1/252, ",
    STEPS, " steps after ", BURN, " burn-in, ", length(SEEDS), " seeds")
band = 1.96 / sqrt(STEPS)
@printf("  white-noise 95%% band for one series: ±%.4f\n", band)
@time begin
    value_only = market_stats((trend_number=0,))
    trend_only = market_stats((value_number=0,))
    combined = market_stats(NamedTuple())
end
report("value only: lag-1 ACF of returns", value_only, r -> r.acf_r)
report("trend only: lag-1 ACF of returns", trend_only, r -> r.acf_r)
report("combined: lag-1 ACF of returns", combined, r -> r.acf_r)
report("combined: excess kurtosis", combined, r -> r.kurt)
report("combined: lag-1 ACF of |returns|", combined, r -> r.acf_abs)
report("combined: lag-1 ACF of volume", combined, r -> r.acf_vol)
report("combined: std of returns", combined, r -> r.sd)

println("\nCalibration of the combined market (5 seeds each): reference-value process")
@printf("  %-28s %10s %10s %10s %10s\n", "value process", "ACF(r,1)", "kurtosis", "ACF(|r|,1)", "ACF(vol,1)")
for σ_v in (0.016, 0.048, 0.16, 0.48)    # annualized; per step 0.001 to 0.03
    rows = market_stats((σ_v=σ_v,); seeds=1:5)
    @printf("  %-28s %10.4f %10.4f %10.4f %10.4f\n", "random walk σ_v = $(σ_v)", mean(r.acf_r for r in rows),
        mean(r.kurt for r in rows), mean(r.acf_abs for r in rows), mean(r.acf_vol for r in rows))
end
# a smooth stand-in for interpolated dividends: a slow linear rise of 1 in log value over the run
path = collect(range(0.0, 1.0; length=STEPS + BURN + 1))
rows = market_stats(NamedTuple(); seeds=1:5, path=path)
@printf("  %-28s %10.4f %10.4f %10.4f %10.4f\n", "linear path (+1 over run)", mean(r.acf_r for r in rows),
    mean(r.kurt for r in rows), mean(r.acf_abs for r in rows), mean(r.acf_vol for r in rows))
