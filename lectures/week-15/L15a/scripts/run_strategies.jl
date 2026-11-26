# L15a: run every strategy of the menu on the real 2025–2026 market and on synthetic markets, and save the results
# that the L15a examples load. Instructor only.
#
# A strategy is one picking rule, one weighting rule, the market hedge on or off, and fixed or updated estimates.
# The engine (`VLQuantitativeFinancePackage.MPCPortfolio`, the INFORMS v2 method) calls the strategy files in
# strategies/picking and strategies/weighting. Every trigger picks a new basket and re-plans the book.
#
# The runs:
#   - real market: 2025-01-02 to 2026-11-24, estimates fit on 2016–2024, 30 seeds of each random picking rule:
#     (6 + 3 × 30) picks × 9 weightings × 2 hedge settings × 2 estimate settings = 3,456 runs
#   - synthetic markets: 252 trading days after 2026-11-24 from the practicum's generator (scripts/synthetic.jl),
#     5 seeds of each random picking rule: (6 + 3 × 5) × 9 × 2 × 2 = 756 runs on each market
#
# Run from the repository root:
#   OMP_NUM_THREADS=1 KMP_GTID_MODE=2 julia --project=. -t 28 lectures/week-15/L15a/scripts/run_strategies.jl
# Options: --paths N (synthetic markets, default 200), --real-only, --synthetic-only, --tag NAME (adds NAME to the
# output file names, for a timing run), --strategies N (runs only the first N strategies of the list, for a test).
#
# Output (in lectures/week-15/L15a/data/):
#   L15a-Strategies-Real-2025-2026.csv        one summary row per run on the real market
#   L15a-Strategies-Real-2025-2026.jld2       the summary rows, the dates, SPY, the T-bill rate, and the daily
#                                             equity of every run (USD)
#   L15a-Strategies-Synthetic.jld2            one summary row per run and synthetic market, SPY and TLT on each
#                                             market, the 5/25/50/75/95 percentile bands of the daily equity of each
#                                             combination, and the daily equity (Float32) of the γ-per-sector runs
#   L15a-Strategies-Synthetic-Markets.csv     one row per synthetic market: SPY's growth rate and largest drawdown,
#                                             the run time, and the error of a market that failed
#   L15a-Strategies-Synthetic-Failures.csv    the failed runs on the synthetic markets, with their errors
#   L15a-Strategies-Settings.toml             the settings and inputs of the runs
#   L15a-Forecast-Models.jld2                 the forecast models of the band trigger, for the examples

# The SCS fallback solver loads libomp. Without these two settings, threaded runs can crash or hang.
if get(ENV, "OMP_NUM_THREADS", "") != "1" || get(ENV, "KMP_GTID_MODE", "") != "2"
    error("run_strategies.jl needs OMP_NUM_THREADS=1 and KMP_GTID_MODE=2 set before Julia starts")
end

include(joinpath(@__DIR__, "setup.jl"))
include(joinpath(@__DIR__, "synthetic.jl"))
using TOML
import Logging

const _SEED = 5660 # the seed of the deterministic picking rules: it also seeds the forecast streams
const _N_SEEDS_REAL = 30 # seeds of each random picking rule on the real market (INFORMS)
const _N_SEEDS_SYNTHETIC = 5 # seeds of each random picking rule on each synthetic market (INFORMS)
const _PERCENTILES = [0.05, 0.25, 0.50, 0.75, 0.95]

"""
    parse_options(args::Vector{String})::NamedTuple

The script's options: `paths` (the number of synthetic markets), `real` and `synthetic` (which parts to run), `tag`
(a suffix of the output file names), and `n_strategies` (the number of strategies to run, `0` for all).
"""
function parse_options(args::Vector{String})::NamedTuple
    paths = 200
    real = true
    synthetic = true
    tag = ""
    n_strategies = 0
    k = 1
    while k <= length(args)
        if args[k] == "--paths"
            paths = parse(Int, args[k + 1])
            k = k + 2
        elseif args[k] == "--strategies"
            n_strategies = parse(Int, args[k + 1])
            k = k + 2
        elseif args[k] == "--tag"
            tag = "-" * args[k + 1]
            k = k + 2
        elseif args[k] == "--real-only"
            synthetic = false
            k = k + 1
        elseif args[k] == "--synthetic-only"
            real = false
            k = k + 1
        else
            error("unknown option $(args[k])")
        end
    end
    return (paths=paths, real=real, synthetic=synthetic, tag=tag, n_strategies=n_strategies)
end

"""
    picking_rules(settings, n_seeds::Int)::Vector{NamedTuple}

The picking runs of the menu (strategies/menu.jl): one run of each deterministic rule (seed `_SEED`), and `n_seeds`
runs of each random rule (seeds `1` to `n_seeds`). Each entry holds the rule's `name`, its `screen`, and its `seed`.
"""
function picking_rules(settings::MPC.MyStudySettings, n_seeds::Int)::Vector{NamedTuple}
    menu = picking_menu(settings)
    rules = NamedTuple[]
    for entry in menu
        if entry.random == false
            push!(rules, (name=entry.name, screen=entry.screen, seed=_SEED))
        end
    end
    for seed in 1:n_seeds
        for entry in menu
            if entry.random == true
                push!(rules, (name=entry.name, screen=entry.screen, seed=seed))
            end
        end
    end
    return rules
end

"""
    strategy_list(settings, n_seeds::Int)::Vector{NamedTuple}

Every strategy of the menu: each picking run crossed with each weighting rule, the hedge on and off, and the
estimates updated and fixed. Each entry holds a unique `label`, the `picking` and `weighting` names, the
`combination` (the strategy without its seed), the `hedge` flag, the `estimates` setting, the `seed`, the `screen`,
and the `rule`.
"""
function strategy_list(settings::MPC.MyStudySettings, n_seeds::Int)::Vector{NamedTuple}
    strategies = NamedTuple[]
    for pick in picking_rules(settings, n_seeds)
        for weigh in weighting_menu(settings)
            for hedge in (true, false)
                for estimates in ("updated", "fixed")
                    hedge_name = "hedge off"
                    if hedge == true
                        hedge_name = "hedge on"
                    end
                    combination = pick.name * " | " * weigh.name * " | " * hedge_name * " | " * estimates
                    label = combination * " | seed " * string(pick.seed)
                    push!(strategies, (label=label, combination=combination, picking=pick.name,
                        weighting=weigh.name, hedge=hedge, estimates=estimates, seed=pick.seed,
                        screen=pick.screen, rule=weigh.rule))
                end
            end
        end
    end
    return strategies
end

"""
    first_strategies(strategies::Vector{NamedTuple}, n::Int)::Vector{NamedTuple}

The first `n` strategies of the list, or the whole list when `n` is `0`.
"""
function first_strategies(strategies::Vector{NamedTuple}, n::Int)::Vector{NamedTuple}
    if n == 0
        return strategies
    end
    return strategies[1:min(n, length(strategies))]
end

"""
    run_strategy(contexts::Dict{String,Any}, st::NamedTuple, spy, g_f)::NamedTuple

One strategy on one market. `contexts` holds the market's study context for each estimate setting. Returns the
summary row and the daily equity (USD). A run that throws gets the status `"error"` and NaN equity.
"""
function run_strategy(contexts::Dict{String,Any}, st::NamedTuple, spy::Vector{Float64},
        g_f::Vector{Float64})::NamedTuple

    # the summary row, with the strategy's parts -
    row = Dict{Symbol,Any}()
    row[:strategy] = st.label
    row[:combination] = st.combination
    row[:picking] = st.picking
    row[:weighting] = st.weighting
    row[:hedge] = st.hedge
    row[:estimates] = st.estimates
    row[:seed] = st.seed
    row[:status] = "ok"
    row[:error] = ""
    nd = length(spy)
    W = fill(NaN, nd)
    t0 = time()
    try
        ctx = contexts[st.estimates]
        settings = MPC.with_settings(ctx.settings; hedge=st.hedge)
        run = MPC.build(MPC.MyStudyRun, (settings=settings, allocator=st.rule, screen=st.screen, seed=st.seed,
            label=st.label))
        out = MPC.score_study(ctx, run)
        W = out.result.equity
        for c in (:realized_growth, :vol, :sharpe, :max_drawdown, :alpha, :alpha_t, :beta, :terminal)
            row[c] = getfield(out.scorecard, c)
        end
        for c in (:turnover, :total_cost, :borrow_fees, :n_decisions, :n_market_turn, :n_beta_over_cap,
            :n_band_exit, :n_drawdown, :n_spy_short, :mean_invested, :mean_book_beta)
            row[c] = getfield(out.stats, c)
        end

        # the NPV: the terminal wealth discounted at the T-bill rate, less the starting wealth (USD) -
        discount = 0.0
        for k in 1:(nd - 1)
            discount = discount + g_f[k] * _Δt
        end
        row[:npv] = W[end] * exp(-discount) - settings.W0
    catch err
        row[:status] = "error"
        row[:error] = sprint(showerror, err)
        W = fill(NaN, nd)
    end
    row[:wall_seconds] = time() - t0
    return (row=row, equity=W)
end

"""
    market_contexts(md, calib, fm, settings)::Dict{String,Any}

The study context of each estimate setting on one market: `"updated"` and `"fixed"`.
"""
function market_contexts(md::MPC.MyMarketData, calib::MPC.MyCalibration, fm::MPC.MyForecastModels,
        settings::MPC.MyStudySettings)::Dict{String,Any}
    contexts = Dict{String,Any}()
    for estimates in ("updated", "fixed")
        s = MPC.with_settings(settings; estimates=estimates)
        contexts[estimates] = MPC.build_context(md, calib, s; fm=fm)
    end
    return contexts
end

"""
    run_market(contexts, strategies)::NamedTuple

Every strategy on one market, on all threads. Returns the summary rows, the daily equity of each strategy (USD, one
column per strategy), and SPY's close and the T-bill rate on the run days.
"""
function run_market(contexts::Dict{String,Any}, strategies::Vector{NamedTuple})::NamedTuple

    # SPY and the T-bill rate on the run days -
    ctx = contexts["updated"]
    rows = ctx.rows
    spy = ctx.md.spy_close[rows]
    g_f = ctx.md.g_f[rows]

    # run every strategy on all threads -
    results = Vector{Any}(undef, length(strategies))
    BLAS.set_num_threads(1)
    Threads.@threads :dynamic for k in eachindex(strategies)
        results[k] = run_strategy(contexts, strategies[k], spy, g_f)
    end

    # collect the rows and the equity, in the order of the strategies -
    summary = Dict{Symbol,Any}[]
    equity = zeros(length(rows), length(strategies))
    for k in eachindex(strategies)
        push!(summary, results[k].row)
        equity[:, k] = results[k].equity
    end
    return (rows=summary, equity=equity, spy=spy, g_f=g_f, dates=ctx.md.dates[rows])
end

"""
    rows_to_frame(rows::Vector{Dict{Symbol,Any}})::DataFrame

The summary rows as a table, with the strategy columns first.
"""
function rows_to_frame(rows::Vector{Dict{Symbol,Any}})::DataFrame
    columns = [:path_id, :strategy, :combination, :picking, :weighting, :hedge, :estimates, :seed, :status,
        :realized_growth, :vol, :sharpe, :max_drawdown, :alpha, :alpha_t, :beta, :terminal, :npv, :turnover,
        :total_cost, :borrow_fees, :n_decisions, :n_market_turn, :n_beta_over_cap, :n_band_exit, :n_drawdown,
        :n_spy_short, :mean_invested, :mean_book_beta, :wall_seconds, :error]
    df = DataFrame()
    for c in columns
        values = Any[]
        for r in rows
            push!(values, get(r, c, missing))
        end
        if all(ismissing, values) == false
            df[!, c] = identity.(values) # the narrowest element type, so that JLD2 stores each column as one array
        end
    end
    return df
end

"""
    run_real(md, calib, fm, settings, options)::Nothing

Every strategy on the real market; writes the real-market files.
"""
function run_real(md::MPC.MyMarketData, calib::MPC.MyCalibration, fm::MPC.MyForecastModels,
        settings::MPC.MyStudySettings, options::NamedTuple)::Nothing
    strategies = first_strategies(strategy_list(settings, _N_SEEDS_REAL), options.n_strategies)
    tag = options.tag
    t_ctx = @elapsed contexts = market_contexts(md, calib, fm, settings)
    println("real market: ", length(strategies), " runs; contexts in ", round(t_ctx; digits=1), " s")
    flush(stdout)
    out = run_market(contexts, strategies)
    df = rows_to_frame(out.rows)
    CSV.write(joinpath(_PATH_TO_L15A_DATA, "L15a-Strategies-Real-2025-2026" * tag * ".csv"), df)
    jldsave(joinpath(_PATH_TO_L15A_DATA, "L15a-Strategies-Real-2025-2026" * tag * ".jld2"), true; dates=out.dates,
        spy=out.spy, g_f=out.g_f, equity=out.equity, labels=[st.label for st in strategies], summary=df,
        tickers=md.tickers, sector=md.sector, lambda=calib.λ)
    println("real market: ", nrow(df), " runs, ", count(isequal("error"), df.status), " failed")
    return nothing
end

"""
    percentile_bands(values::Matrix{Float32})::Matrix{Float32}

The percentile bands of the daily equity of one combination: `values` holds one column per run (each seed on each
market), and the result holds one column per percentile in `_PERCENTILES`. NaN entries (failed runs) are left out.
"""
function percentile_bands(values::Matrix{Float32})::Matrix{Float32}
    n_days = size(values, 1)
    bands = fill(Float32(NaN), n_days, length(_PERCENTILES))
    for d in 1:n_days
        finite = Float32[]
        for x in values[d, :]
            if isfinite(x) == true
                push!(finite, x)
            end
        end
        if isempty(finite) == false
            for (k, q) in enumerate(_PERCENTILES)
                bands[d, k] = quantile(finite, q)
            end
        end
    end
    return bands
end

"""
    run_synthetic(md, calib, fm, generator, settings, options)::Nothing

Every strategy on `n_paths` synthetic markets, one market after another, with the strategies on all threads;
writes the synthetic-market files.
"""
function run_synthetic(md::MPC.MyMarketData, calib::MPC.MyCalibration, fm::MPC.MyForecastModels,
        generator::NamedTuple, settings::MPC.MyStudySettings, options::NamedTuple)::Nothing
    n_paths = options.paths
    tag = options.tag

    # the synthetic days, the volumes, the generator columns, and the strategies -
    sessions = nyse_sessions_after(md.dates[end], _SYNTHETIC_DAYS)
    volume = training_volume(md)
    columns = generator_columns(generator, md)
    # the first decision is made after the close of the last real day, and its orders fill at the first synthetic open -
    synthetic_settings = MPC.with_settings(settings; start=md.dates[end], stop=sessions[end],
        estimates_start=_BACKTEST_START)
    strategies = first_strategies(strategy_list(synthetic_settings, _N_SEEDS_SYNTHETIC), options.n_strategies)
    println("synthetic markets: ", n_paths, " markets × ", length(strategies), " runs, ", sessions[1], " to ",
        sessions[end])
    flush(stdout)

    # the combinations, and the columns of each one -
    combinations = String[]
    members = Dict{String,Vector{Int}}()
    for (k, st) in enumerate(strategies)
        if haskey(members, st.combination) == false
            push!(combinations, st.combination)
            members[st.combination] = Int[]
        end
        push!(members[st.combination], k)
    end

    # each market: draw it, build its contexts, and run every strategy. Market p draws with the seed 5660 + p, the
    # seed of the practicum's stress-test path p, so the two stress tests run on the same markets -
    rows = Dict{Symbol,Any}[]
    n_days = _SYNTHETIC_DAYS + 1
    equity = fill(Float32(NaN), n_days, length(strategies), n_paths)
    spy = fill(NaN, n_days, n_paths) # SPY closes (USD/share), in Float64 so the 60/40 benchmark is exact
    tlt = fill(NaN, n_days, n_paths) # TLT closes, for the practicum's 60/40 benchmark (USD/share)
    j_tlt = 0
    for j in eachindex(md.tickers)
        if md.tickers[j] == "TLT"
            j_tlt = j
        end
    end
    if j_tlt == 0
        throw(ArgumentError("the market has no TLT, which the 60/40 benchmark needs"))
    end
    markets = DataFrame(path_id=Int[], spy_growth=Float64[], spy_max_drawdown=Float64[], seconds=Float64[],
        error=String[])
    started = time()
    for p in 1:n_paths
        t0 = time()

        # a market that cannot be built or run is recorded and skipped, so one bad market does not stop the run -
        local out, tlt_close
        try
            G = synthetic_growth(generator, _SYNTHETIC_DAYS, _SEED + p)
            smd = synthetic_market(md, G, columns, sessions, volume)
            tlt_close = smd.close[(end - _SYNTHETIC_DAYS):end, j_tlt] # the last real day, then the synthetic days
            contexts = market_contexts(smd, calib, fm, synthetic_settings)
            out = run_market(contexts, strategies)
        catch err
            push!(markets, (p, NaN, NaN, time() - t0, sprint(showerror, err)))
            println("synthetic market ", p, " of ", n_paths, ": failed, ", sprint(showerror, err))
            flush(stdout)
            continue
        end
        for row in out.rows
            row[:path_id] = p
            push!(rows, row)
        end
        equity[:, :, p] = Float32.(out.equity)
        spy[:, p] = out.spy
        tlt[:, p] = tlt_close

        # SPY on this market: its growth rate and its largest drawdown -
        peak = out.spy[1]
        drawdown = 0.0
        for k in eachindex(out.spy)
            peak = max(peak, out.spy[k])
            drawdown = max(drawdown, 1 - out.spy[k] / peak)
        end
        growth = log(out.spy[end] / out.spy[1]) / ((n_days - 1) * _Δt)
        push!(markets, (p, growth, drawdown, time() - t0, ""))
        println("synthetic market ", p, " of ", n_paths, ": ", round(time() - t0; digits=1), " s (",
            round((time() - started) / 60; digits=1), " min so far)")
        flush(stdout)
    end

    # the percentile bands of each combination, pooled over its seeds and the markets -
    bands = Dict{String,Matrix{Float32}}()
    for c in combinations
        values = reshape(equity[:, members[c], :], n_days, length(members[c]) * n_paths)
        bands[c] = percentile_bands(values)
    end

    # the daily equity of the γ-per-sector runs, every market -
    gamma_equity = Dict{String,Matrix{Float32}}()
    for (k, st) in enumerate(strategies)
        if st.picking == "gamma by sector"
            gamma_equity[st.combination] = equity[:, k, :]
        end
    end

    # write the files: the failed runs and their errors go to a CSV file, and the saved summary leaves out the run
    # label, the error, and the run time, so that the file stays under 100 MB (the combination and the seed give the
    # label) -
    df = rows_to_frame(rows)
    dates = vcat(md.dates[end], sessions)
    CSV.write(joinpath(_PATH_TO_L15A_DATA, "L15a-Strategies-Synthetic-Markets" * tag * ".csv"), markets)
    failed = df[df.status .!= "ok", [:path_id, :strategy, :error]]
    CSV.write(joinpath(_PATH_TO_L15A_DATA, "L15a-Strategies-Synthetic-Failures" * tag * ".csv"), failed)
    summary = select(df, Not([:strategy, :error, :wall_seconds]))
    jldsave(joinpath(_PATH_TO_L15A_DATA, "L15a-Strategies-Synthetic" * tag * ".jld2"), true; dates=dates, spy=spy,
        tlt=tlt, summary=summary, combinations=combinations, percentiles=_PERCENTILES, bands=bands,
        gamma_equity=gamma_equity)
    println("synthetic markets: ", nrow(df), " runs, ", count(isequal("error"), df.status), " failed, ",
        round((time() - started) / 60; digits=1), " min")
    return nothing
end

"""
    write_settings(settings, options)::Nothing

Record the settings and inputs of the runs in `L15a-Strategies-Settings.toml`.
"""
function write_settings(settings::MPC.MyStudySettings, options::NamedTuple)::Nothing
    d = Dict{String,Any}()
    d["written"] = string(now())
    d["windows"] = Dict("train_start" => string(_TRAIN_START), "train_stop" => string(_TRAIN_STOP),
        "backtest_start" => string(_BACKTEST_START), "backtest_stop" => string(_BACKTEST_STOP))
    d["engine"] = Dict("config" => "code/src/data/mpc/study.toml (INFORMS v2) with the L15a dates",
        "trigger_rule" => "every trigger picks a new basket and re-plans the book",
        "seed_deterministic" => _SEED, "seeds_real" => _N_SEEDS_REAL, "seeds_synthetic" => _N_SEEDS_SYNTHETIC,
        "basket_K" => settings.basket_K, "N_per_sector" => settings.N_per_sector,
        "forecast_model" => settings.forecast_model, "forecast_band" => settings.forecast_band,
        "forecast_models" => "the practicum generator (scripts/synthetic.jl, l15a_forecast_models)")
    d["strategies"] = Dict("picking" => [r.name for r in picking_menu(settings)],
        "weighting" => [r.name for r in weighting_menu(settings)], "hedge" => [true, false],
        "estimates" => ["updated", "fixed"])
    d["synthetic"] = Dict("paths" => options.paths, "days" => _SYNTHETIC_DAYS,
        "seeds" => "5660 + path (synthetic_growth), the practicum's stress-test seeds",
        "start" => "the real history to " * string(_BACKTEST_STOP),
        "generator" => "data/generator.jld2 with scripts/practicum/src/Generator.jl (see data/SOURCE.md)",
        "volume" => "median 2016-2024 volume", "risk_free" => "the last real T-bill rate")
    io = open(joinpath(_PATH_TO_L15A_DATA, "L15a-Strategies-Settings" * options.tag * ".toml"), "w")
    TOML.print(io, d)
    close(io)
    return nothing
end

# main -
options = parse_options(ARGS)
println("threads: ", Threads.nthreads(), ", synthetic markets: ", options.paths)
md = Logging.with_logger(l15a_market, Logging.NullLogger()) # silence the loader's notes
calib = l15a_calibration(md)
settings = l15a_settings(; hedge=true, estimates="updated")
t_gen = @elapsed generator = load_generator(_GENERATOR_FILE)
println("generator: ", length(generator.tickers), " tickers in ", round(t_gen; digits=1), " s")
t_fm = @elapsed fm = l15a_forecast_models(generator, md)
println("forecast models: ", round(t_fm; digits=1), " s; median sector share ρ = ", round(median(fm.ρ); digits=3))
jldsave(joinpath(_PATH_TO_L15A_DATA, "L15a-Forecast-Models.jld2"), true; fm=fm) # the examples load these
flush(stdout)
write_settings(settings, options)
if options.real == true
    t_real = @elapsed run_real(md, calib, fm, settings, options)
    println("real market: ", round(t_real / 60; digits=1), " min")
end
if options.synthetic == true
    t_syn = @elapsed run_synthetic(md, calib, fm, generator, settings, options)
    println("synthetic markets: ", round(t_syn / 60; digits=1), " min")
end
