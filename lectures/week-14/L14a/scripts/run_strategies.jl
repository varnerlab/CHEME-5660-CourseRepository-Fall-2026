# L14a: run every strategy on the real 2025–2026 market and on synthetic markets drawn from the sector factor
# model, and save the results that the L14a examples load.
#
# The strategies use the method-v2 engine of the course package (`VLQuantitativeFinancePackage.MPCPortfolio`).
# The model-predictive strategies cross the seven weighting rules (CD, CES, CESw, SG, MinVar, Tangent, LS) with the
# ten selection rules of the INFORMS 2026 talk and the hedge on and off. Betting against beta and two buy-and-hold
# references complete the list. Each strategy is calibrated on 2014–2024 and trades 2025-01-02 to 2026-11-13.
#
# The synthetic markets come from the generator saved by the L14a sector factor example
# (data/JumpHMM-SectorFactor-Universe-2014-2024.jld2), with two settings taken from the INFORMS 2026 study's
# method-v2 generator (data/L14a-Synthetic-Drift-Settings.csv): each stock's α is pulled toward the average
# α (φ = 0.62), and each stock's β drifts around its estimate with a 126-day half-life and the study's drift
# scale. Each synthetic market is a full 2014–2026 history on the real trading days. The strategies calibrate
# on its 2014–2024 part and trade its 2025–2026 part, exactly as on the real market.
#
# Run from the repository root:
#   OMP_NUM_THREADS=1 KMP_GTID_MODE=2 julia --project=. -t 28 lectures/week-14/L14a/scripts/run_strategies.jl
# Options: --paths N (synthetic markets, default 1000), --real-only, --synthetic-only.
#
# Output (in lectures/week-14/L14a/data/):
#   L14a-Strategies-Real-2025-2026.jld2      daily equity of every strategy on the real market, and the run details
#                                            of the γ-per-sector strategies
#   L14a-Strategies-Real-2025-2026.csv       one summary row per strategy on the real market
#   L14a-Strategies-Synthetic-2025-2026.jld2 one summary row per strategy and synthetic market, and the daily equity
#                                            (Float32) of the γ-per-sector strategies and the references
#   L14a-Strategies-Synthetic-2025-2026.csv  the summary rows of the γ-per-sector strategies and the references
#   L14a-Strategies-Synthetic-Markets.csv    one row per synthetic market: SPY's growth rate and drawdown
#   L14a-Strategies-Settings-Real.toml       the settings and inputs of the real-market run
#   L14a-Strategies-Settings-Synthetic.toml  the settings and inputs of the synthetic run

# The SCS fallback solver loads libomp. Without these two settings, threaded runs can crash or hang.
if get(ENV, "OMP_NUM_THREADS", "") != "1" || get(ENV, "KMP_GTID_MODE", "") != "2"
    error("run_strategies.jl needs OMP_NUM_THREADS=1 and KMP_GTID_MODE=2 set before Julia starts")
end

using Pkg
Pkg.activate(normpath(joinpath(@__DIR__, "..", "..", "..", "..")); io=devnull)
using VLQuantitativeFinancePackage
using Dates, DataFrames, CSV, JLD2, Statistics, LinearAlgebra, TOML, Random
import JumpHMM
import Logging
import VLQuantitativeFinancePackage.MPCPortfolio as MPC

const _PATH_TO_L14A = normpath(joinpath(@__DIR__, ".."))
const _PATH_TO_DATA = joinpath(_PATH_TO_L14A, "data")
const _PATH_TO_MARKET_DATA = joinpath(dirname(pathof(VLQuantitativeFinancePackage)), "data")
const _GENERATOR_FILE = joinpath(_PATH_TO_DATA, "JumpHMM-SectorFactor-Universe-2014-2024.jld2")
const _DRIFT_FILE = joinpath(_PATH_TO_DATA, "L14a-Synthetic-Drift-Settings.csv")

# the windows: calibration on 2014–2024, trading from the first trading day of 2025 to the last day of the data
const _TRAIN_START = Date(2014, 1, 3)
const _TRAIN_STOP = Date(2024, 12, 31)
const _RUN_START = Date(2025, 1, 2)
const _RUN_STOP = Date(2026, 11, 13)

const _SEED = 5660 # the strategies' seed: the forecast streams of the model-predictive rebalance
const _ALPHA_PULL = 0.62 # φ: each synthetic stock's α is ā + φ(αᵢ − ā), from the INFORMS method-v2 generator
const _BETA_HALFLIFE = 126.0 # the half-life of the β drift (trading days), from the INFORMS method-v2 generator
const _BAB_SHRINK = 0.6 # the weight on each stock's estimated β in betting against beta (Frazzini and Pedersen)
const _N_SEEDS_REAL = 30 # seeds of each bandit and random selection rule on the real market (the INFORMS real-data grid)
const _N_SEEDS_SYNTHETIC = 5 # seeds of each bandit and random selection rule on each synthetic market (INFORMS)

# the screens of the selection rules, in the order of the INFORMS talk; the hand-picked lists come from the study grid -
const _SCREENS = [:gamma, :bandit, :random, :global_gamma, :corr_gamma, :liquid_gamma, :random_liquid, :random_global]
const _RANDOM_SCREENS = [:bandit, :random, :random_liquid, :random_global] # the rules that run with several seeds

"""
    parse_options(args::Vector{String})::NamedTuple

The script's options: `paths` (the number of synthetic markets), `real` and `synthetic` (which parts to run).
"""
function parse_options(args::Vector{String})::NamedTuple
    paths = 1000;
    real = true;
    synthetic = true;
    k = 1;
    while k <= length(args)
        if args[k] == "--paths"
            paths = parse(Int, args[k + 1]);
            k = k + 2;
        elseif args[k] == "--real-only"
            synthetic = false;
            k = k + 1;
        elseif args[k] == "--synthetic-only"
            real = false;
            k = k + 1;
        else
            error("unknown option $(args[k]); use --paths N, --real-only or --synthetic-only");
        end
    end
    return (paths=paths, real=real, synthetic=synthetic);
end

"""
    load_real_market(generator_tickers::Vector{String})::MPC.MyMarketData

The real market from 2014-01-03 to 2026-11-13: `SPY` and every stock of the generator with a full price history
over those dates (the engine's universe rule), in alphabetical order.
"""
function load_real_market(generator_tickers::Vector{String})::MPC.MyMarketData

    # load every stock with a full history and a sector; the loader's notes about split adjustments are silenced
    logger = Logging.global_logger(Logging.SimpleLogger(stderr, Logging.Error));
    md = MPC.load_market_data(_PATH_TO_MARKET_DATA; start=_TRAIN_START, stop=_RUN_STOP, files=MPC.DATA_FILES_NOV2026);
    Logging.global_logger(logger);

    # keep the stocks that the generator also has -
    keep = String[];
    for t in md.tickers
        if t in generator_tickers
            push!(keep, t);
        end
    end
    return MPC.subset_universe(md, keep);
end

"""
    load_generator()::NamedTuple

The generator of the synthetic markets: the sector factor model saved by the L14a sector factor example, with the
pulled α and the drifting β of the INFORMS method-v2 generator (`_DRIFT_FILE`). A stock without a drift scale in
that file gets the median scale. Also returns the model without drift, whose fitted models drive the factor
forecast.
"""
function load_generator()::NamedTuple

    # the saved sector factor model -
    saved = JLD2.load(_GENERATOR_FILE);
    base = saved["portfolio"].dependence;

    # the pulled α: each stock's α moves the fraction φ of the way from the average α to its own estimate -
    n = length(base.tickers);
    ā = mean(base.α);
    α = zeros(Float64, n);
    for i in 1:n
        α[i] = ā + _ALPHA_PULL * (base.α[i] - ā);
    end

    # the β drift scale of each stock, from the INFORMS method-v2 generator -
    drift = CSV.read(_DRIFT_FILE, DataFrame);
    k_of = Dict{String,Float64}();
    for row in eachrow(drift)
        k_of[String(row.ticker)] = Float64(row.k_beta);
    end
    k_median = median(drift.k_beta);
    k = zeros(Float64, n);
    for i in 1:n
        if haskey(k_of, base.tickers[i])
            k[i] = k_of[base.tickers[i]];
        else
            k[i] = k_median;
        end
    end

    model = JumpHMM.with_parameters(base; α=α, β_halflife=_BETA_HALFLIFE, β_scale=k);
    return (model=model, base=base, first_close=saved["first_close"], tickers=saved["tickers"]);
end

"""
    check_forecast_draws(model)::Nothing

Check that the engine's forecast draws equal `JumpHMM.simulate` for the fitted SPY model, so the ported forecast
reads the JumpHMM 0.6.0 models correctly.
"""
function check_forecast_draws(model)::Nothing
    X = MPC.forecast_draws(model, 63, 20, 1234);
    Y = JumpHMM.simulate(model, 63; number_of_paths=20, seed=1234).growth_rates;
    @assert X == Y "forecast_draws differs from JumpHMM.simulate"
    return nothing;
end

"""
    selection_name(screen::Symbol, list::Vector{String})::String

The name of a selection rule in the tables, as in the INFORMS talk. `list` holds the tickers of a hand-picked list
(screen `:fixed`) and is empty for the other screens.
"""
function selection_name(screen::Symbol, list::Vector{String})::String
    if screen == :gamma
        return "γ per sector"; # the 3 highest γ in each sector
    elseif screen == :bandit
        return "bandit per sector"; # the bandit's top 3 in each sector
    elseif screen == :random
        return "random per sector"; # 3 at random in each sector
    elseif screen == :global_gamma
        return "global γ"; # the 13 highest γ in the universe, no sector quota
    elseif screen == :corr_gamma
        return "correlation-aware γ"; # down the γ ranking, skipping stocks too correlated with the picks
    elseif screen == :liquid_gamma
        return "liquid then γ"; # the 13 highest γ among the 100 most traded stocks
    elseif screen == :random_liquid
        return "random liquid"; # 13 at random among the 100 most traded stocks
    elseif screen == :random_global
        return "random global"; # 13 at random from the whole universe
    elseif screen == :fixed
        return "hand-picked " * string(length(list)); # a list chosen in advance, never re-picked
    end
    throw(ArgumentError("unknown screen $(screen)"));
end

"""
    mpc_strategy(allocator::String, screen::Symbol, list::Vector{String}, hedge::Bool, covariance::String,
        seed::Int)::NamedTuple

One model-predictive strategy: a weighting rule, a selection rule, the hedge flag, the covariance model and the seed.
`list` holds the tickers of a hand-picked list (screen `:fixed`) and is empty otherwise. The label names the rule,
the selection, the hedge and, for the bandit and random rules, the seed. `main` is true for the γ-per-sector rule,
whose run details and synthetic equity we save.
"""
function mpc_strategy(allocator::String, screen::Symbol, list::Vector{String}, hedge::Bool, covariance::String,
        seed::Int)::NamedTuple

    # the label: rule, selection, hedge, and the seed of a random rule -
    name = allocator;
    if covariance == "sector_factor"
        name = allocator * "-SF";
    end
    label = name * " | " * selection_name(screen, list);
    if hedge == true
        label = label * " | hedge on";
    else
        label = label * " | hedge off";
    end
    if screen in _RANDOM_SCREENS
        label = label * " | seed " * string(seed);
    end

    # return -
    return (label=label, kind=:mpc, allocator=allocator, selection=screen, list=list, hedge=hedge,
        covariance=covariance, seed=seed, main=(screen == :gamma));
end

"""
    strategy_list(n_seeds::Int)::Vector{NamedTuple}

The strategies, in the order of the tables. The model-predictive strategies cross the seven weighting rules of the
study grid with the ten selection rules of the INFORMS talk and the hedge on and off:

- __In each sector (33 stocks):__ the 3 highest γ (`:gamma`), the bandit's top 3 (`:bandit`), or 3 at random
  (`:random`).
- __Across the universe (13 stocks):__ the highest γ (`:global_gamma`), the highest γ with a correlation limit
  (`:corr_gamma`), the highest γ among the 100 most traded stocks (`:liquid_gamma`), or at random from those 100
  (`:random_liquid`) or from the whole universe (`:random_global`).
- __Hand-picked:__ the two lists of the study grid (13 and 15 stocks), chosen in advance without 2025 data.

The bandit and random rules run with the seeds `_SEED` to `_SEED + n_seeds - 1`, the others with `_SEED`. The
γ-per-sector rule also runs MinVar and Tangent with the sector factor covariance. Betting against beta and the two
buy-and-hold references come last. Each strategy has the fields of `mpc_strategy(...)`.
"""
function strategy_list(n_seeds::Int)::Vector{NamedTuple}

    # the study grid: the weighting rules and the hand-picked lists -
    grid = MPC.load_study(MPC.default_study_path()).grid;
    out = NamedTuple[];

    # the model-predictive strategies, hedge on, then hedge off -
    for hedge in (true, false)
        for allocator in grid.allocators
            for screen in _SCREENS
                seeds = [_SEED];
                if screen in _RANDOM_SCREENS
                    seeds = collect(_SEED:(_SEED + n_seeds - 1));
                end
                for seed in seeds
                    push!(out, mpc_strategy(allocator, screen, String[], hedge, "shrunk", seed));
                end
            end
            for pair in grid.fixed_lists
                push!(out, mpc_strategy(allocator, :fixed, collect(String, last(pair)), hedge, "shrunk", _SEED));
            end
        end
        for allocator in ("MinVar", "Tangent")
            push!(out, mpc_strategy(allocator, :gamma, String[], hedge, "sector_factor", _SEED));
        end
    end

    # betting against beta and the buy-and-hold references -
    for (label, kind) in (("BAB", :bab), ("SPY buy-and-hold", :passive), ("Equal-weight buy-and-hold", :passive))
        push!(out, (label=label, kind=kind, allocator="", selection=:none, list=String[], hedge=false, covariance="",
            seed=_SEED, main=true));
    end

    # checks -
    labels = String[];
    for st in out
        push!(labels, st.label);
    end
    @assert length(unique(labels)) == length(labels) "every strategy needs its own label"
    @assert grid.base_seed == _SEED "the script's seed must be the study grid's base seed"

    # return -
    return out;
end

"""
    study_settings()::MPC.MyStudySettings

The method-v2 settings of the course package, with the 2025-01-02 to 2026-11-13 trading window.
"""
function study_settings()::MPC.MyStudySettings
    s = MPC.load_study(MPC.default_study_path()).settings;
    return MPC.with_settings(s; start=_RUN_START, stop=_RUN_STOP, train_start=_TRAIN_START, train_stop=_TRAIN_STOP);
end

"""
    empty_row(label::String, kind::Symbol)::Dict{Symbol,Any}

A summary row with every column missing, for a strategy that has not run or that failed.
"""
function empty_row(label::String, kind::Symbol)::Dict{Symbol,Any}
    row = Dict{Symbol,Any}();
    row[:strategy] = label;
    row[:kind] = String(kind);
    row[:status] = "ok";
    row[:error] = "";
    for c in (:realized_growth, :vol, :sharpe, :max_drawdown, :alpha, :alpha_t, :beta, :terminal, :turnover,
        :total_cost, :borrow_fees, :n_decisions, :n_market_turn, :n_beta_over_cap, :n_band_exit, :n_drawdown,
        :n_spy_short, :mean_invested, :mean_book_beta, :mean_gross, :wall_seconds)
        row[c] = missing;
    end
    return row;
end

"""
    run_strategy(ctx, md, settings, st, passive, spy, g_f, nd, keep_details::Bool)::NamedTuple

One strategy `st` on one market. Returns the summary row, the daily equity (USD) and, with `keep_details` and a
`main` strategy, the run details that the examples plot (`nothing` otherwise).
"""
function run_strategy(ctx, md::MPC.MyMarketData, settings::MPC.MyStudySettings, st::NamedTuple, passive,
        spy::Vector{Float64}, g_f::Vector{Float64}, nd::Int, keep_details::Bool)::NamedTuple

    # the summary row, with the strategy's rule, selection, hedge, covariance and seed -
    row = empty_row(st.label, st.kind);
    row[:allocator] = st.allocator;
    row[:selection] = "";
    if st.kind == :mpc
        row[:selection] = selection_name(st.selection, st.list);
    end
    row[:hedge] = st.hedge;
    row[:covariance] = st.covariance;
    row[:seed] = st.seed;
    detail = nothing;
    W = fill(NaN, nd);
    t0 = time();
    try
        if st.kind == :mpc
            # the model-predictive rebalance with this rule, selection, hedge and covariance -
            s = MPC.with_settings(settings; hedge=st.hedge, covariance_model=st.covariance);
            if st.selection == :fixed
                s = MPC.with_settings(s; fixed_tickers=st.list, basket_K=length(st.list)); # a hand-picked list
            end
            run = MPC.build(MPC.MyStudyRun, (settings=s, allocator=st.allocator, screen=st.selection, seed=st.seed,
                label=st.label));
            out = MPC.score_study(ctx, run);
            W = out.result.equity;
            for c in (:turnover, :total_cost, :borrow_fees, :n_decisions, :n_market_turn, :n_beta_over_cap,
                :n_band_exit, :n_drawdown, :n_spy_short, :mean_invested, :mean_book_beta)
                row[c] = getfield(out.stats, c);
            end
            if keep_details == true && st.main == true
                detail = run_details(out.result);
            end
        elseif st.kind == :bab
            # betting against beta on every stock, rebalanced monthly -
            bab = MPC.run_bab(ctx; shrink=_BAB_SHRINK, W0=settings.W0);
            W = bab.equity;
            row[:turnover] = bab.turnover;
            row[:total_cost] = bab.total_cost;
            row[:borrow_fees] = sum(bab.borrow_fees);
            row[:n_decisions] = nrow(bab.rebalances);
            row[:mean_gross] = mean(bab.gross);
            if bab.ruined == true
                row[:status] = "ruined";
            end
            if keep_details == true
                detail = (rebalances=bab.rebalances, gross=bab.gross, cash=bab.cash);
            end
        else
            # the buy-and-hold references -
            if st.label == "SPY buy-and-hold"
                W = passive.spy;
            else
                W = passive.equal_weight;
            end
        end
        sc = MPC.growth_scorecard(W, spy, g_f);
        for c in (:realized_growth, :vol, :sharpe, :max_drawdown, :alpha, :alpha_t, :beta, :terminal)
            row[c] = getfield(sc, c);
        end
    catch err
        row[:status] = "error";
        row[:error] = sprint(showerror, err);
        W = fill(NaN, nd);
    end
    row[:wall_seconds] = time() - t0;

    # return -
    return (row=row, equity=W, detail=detail);
end

"""
    run_market(md, calib, fm, settings, strategies; keep_details::Bool=false, threaded::Bool=false)::NamedTuple

Every strategy on one market. Returns the summary rows, the daily equity of each strategy (USD), SPY's close on the
run days (USD), and, with `keep_details`, the run details of the `main` strategies (`run_details(...)`) and betting
against beta's rebalances. With `threaded`, the strategies run on all threads; they share one context.
"""
function run_market(md::MPC.MyMarketData, calib::MPC.MyCalibration, fm::MPC.MyForecastModels,
        settings::MPC.MyStudySettings, strategies::Vector{NamedTuple}; keep_details::Bool=false,
        threaded::Bool=false)::NamedTuple

    # one context serves every strategy: the hedge, the rule and the selection are not part of the context key -
    ctx = MPC.build_context(md, calib, settings; fm=fm);
    i0 = first(ctx.rows);
    i1 = last(ctx.rows);
    spy = md.spy_close[i0:i1];
    g_f = md.g_f[i0:i1];
    nd = length(ctx.rows);
    passive = MPC.buy_and_hold_equity(md, ctx.rows; W0=settings.W0);

    # run every strategy, on all threads or one after another -
    results = Vector{Any}(undef, length(strategies));
    if threaded == true
        BLAS.set_num_threads(1);
        Threads.@threads :dynamic for k in eachindex(strategies)
            results[k] = run_strategy(ctx, md, settings, strategies[k], passive, spy, g_f, nd, keep_details);
        end
    else
        for k in eachindex(strategies)
            results[k] = run_strategy(ctx, md, settings, strategies[k], passive, spy, g_f, nd, keep_details);
        end
    end

    # collect the rows, the equity and the details, in the order of the strategies -
    rows = Dict{Symbol,Any}[];
    equity = Dict{String,Vector{Float64}}();
    details = Dict{String,Any}();
    for k in eachindex(strategies)
        push!(rows, results[k].row);
        equity[strategies[k].label] = results[k].equity;
        if isnothing(results[k].detail) == false
            details[strategies[k].label] = results[k].detail;
        end
    end

    # checks -
    @assert length(rows) == length(strategies) "one summary row per strategy"

    # return -
    return (rows=rows, equity=equity, spy=spy, g_f=g_f, dates=md.dates[i0:i1], details=details);
end

"""
    run_details(res::MPC.MyStudyResult)::NamedTuple

The parts of a model-predictive run that the examples plot: the daily table, the decisions, the re-picks, the
target weights and each decision's forecast (mean, standard deviation and 95% band of wealth, USD).
"""
function run_details(res::MPC.MyStudyResult)::NamedTuple
    bands = Dict{Date,NamedTuple}();
    for d in keys(res.projections)
        p = res.projections[d];
        bands[d] = (μ=p.μ, σ=p.σ, lo=p.lo, hi=p.hi);
    end
    return (daily=res.daily, decisions=res.decisions, repicks=res.repicks, targets=res.targets, bands=bands,
        cash=res.cash, borrow_fees=res.borrow_fees);
end

"""
    rows_to_frame(rows::Vector{Dict{Symbol,Any}})::DataFrame

The summary rows as a table, with the strategy columns first.
"""
function rows_to_frame(rows::Vector{Dict{Symbol,Any}})::DataFrame
    columns = [:path_id, :strategy, :kind, :allocator, :selection, :hedge, :covariance, :seed, :status, :realized_growth, :vol, :sharpe, :max_drawdown, :alpha, :alpha_t,
        :beta, :terminal, :turnover, :total_cost, :borrow_fees, :n_decisions, :n_market_turn, :n_beta_over_cap,
        :n_band_exit, :n_drawdown, :n_spy_short, :mean_invested, :mean_book_beta, :mean_gross, :wall_seconds, :error];
    df = DataFrame();
    for c in columns
        values = Any[];
        for r in rows
            push!(values, get(r, c, missing));
        end
        if all(ismissing, values) == false
            df[!, c] = values;
        end
    end
    return df;
end

"""
    run_real(generator, fm, strategies)::Nothing

Every strategy on the real market; writes the real-market files.
"""
function run_real(generator::NamedTuple, fm::MPC.MyForecastModels, strategies::Vector{NamedTuple})::Nothing
    md = load_real_market(generator.model.tickers);
    println("real market: ", length(md.tickers), " stocks, ", md.dates[1], " to ", md.dates[end]);
    calib = MPC.calibrate(md; train_start=_TRAIN_START, train_stop=_TRAIN_STOP);
    out = run_market(md, calib, fm, study_settings(), strategies; keep_details=true, threaded=true);
    df = rows_to_frame(out.rows);
    CSV.write(joinpath(_PATH_TO_DATA, "L14a-Strategies-Real-2025-2026.csv"), df);
    jldsave(joinpath(_PATH_TO_DATA, "L14a-Strategies-Real-2025-2026.jld2"); dates=out.dates, spy=out.spy,
        g_f=out.g_f, equity=out.equity, details=out.details, summary=df, tickers=md.tickers, sector=md.sector,
        lambda=calib.λ);
    println("real market: ", nrow(df), " strategy runs, ", count(isequal("error"), df.status), " failed");
    return nothing;
end

"""
    synthetic_market(generator, real_md, volume, columns, p::Int)::NamedTuple

Synthetic market `p`: one draw of the whole universe from the generator with seed `p`, on the real trading days,
with the real starting closes, each stock's median 2014–2024 volume `volume` (shares/day) and the real risk-free
rate. `columns` holds the generator's column of each stock of `real_md`. Returns the market and SPY's statistics
on the trading window.
"""
function synthetic_market(generator::NamedTuple, real_md::MPC.MyMarketData, volume::Vector{Float64},
        columns::Vector{Int}, p::Int)::NamedTuple

    # one draw of the universe, and the columns of the real market's stocks -
    n = length(real_md.dates) - 1;
    draw = JumpHMM.sample_dependence(generator.model, n; seed=p);
    G = draw.G[:, columns];
    md = MPC.market_data_from_growth(real_md.dates, real_md.tickers, real_md.sector, real_md.close[1, :],
        real_md.spy_close[1], volume, real_md.g_f, draw.g_m, G);

    # SPY on the trading window: its growth rate, its largest drawdown and its jump-episode days -
    i0 = MPC.index_of(md, _RUN_START);
    i1 = MPC.index_of(md, _RUN_STOP);
    S = md.spy_close[i0:i1];
    peak = S[1];
    drawdown = 0.0;
    for k in eachindex(S)
        peak = max(peak, S[k]);
        drawdown = max(drawdown, 1 - S[k] / peak);
    end
    growth = log(S[end] / S[1]) / ((i1 - i0) / 252);
    t0 = MPC.index_of(md, _TRAIN_START);
    t1 = MPC.index_of(md, _TRAIN_STOP);
    train_growth = log(md.spy_close[t1] / md.spy_close[t0]) / ((t1 - t0) / 252);
    jump_days = sum(draw.episodes[i0:(i1 - 1)]);
    return (md=md, stats=(path_id=p, spy_growth=growth, spy_max_drawdown=drawdown, spy_train_growth=train_growth,
        market_jump_days=jump_days));
end

"""
    run_synthetic(generator, fm, strategies, n_paths::Int)::Nothing

Every strategy on `n_paths` synthetic markets, threaded over the markets; writes the synthetic-market files.
"""
function run_synthetic(generator::NamedTuple, fm::MPC.MyForecastModels, strategies::Vector{NamedTuple},
        n_paths::Int)::Nothing

    # the real market fixes the days, the stocks, the starting closes, the volumes and the risk-free rate -
    real_md = load_real_market(generator.model.tickers);
    columns = Int[];
    for t in real_md.tickers
        push!(columns, findfirst(isequal(t), generator.model.tickers));
    end
    t1 = MPC.index_of(real_md, _TRAIN_STOP);
    volume = zeros(Float64, length(real_md.tickers));
    for j in eachindex(real_md.tickers)
        volume[j] = median(real_md.volume[1:t1, j]);
    end
    settings = study_settings();

    # each market: draw, calibrate on its 2014–2024 part, run every strategy -
    results = Vector{Any}(undef, n_paths);
    BLAS.set_num_threads(1);
    started = time();
    done = Threads.Atomic{Int}(0);
    Threads.@threads :dynamic for p in 1:n_paths
        try
            sm = synthetic_market(generator, real_md, volume, columns, p);
            calib = MPC.calibrate(sm.md; train_start=_TRAIN_START, train_stop=_TRAIN_STOP);
            out = run_market(sm.md, calib, fm, settings, strategies);
            results[p] = (stats=sm.stats, out=out, lambda=calib.λ);
        catch err
            results[p] = (stats=(path_id=p,), error=sprint(showerror, err));
        end
        k = Threads.atomic_add!(done, 1) + 1;
        if k % 25 == 0
            println("synthetic markets: ", k, " of ", n_paths, " in ", round((time() - started) / 60; digits=1), " min");
            flush(stdout);
        end
    end

    # combine: one summary row per market and strategy, one row per market, and the equity matrices -
    rows = Dict{Symbol,Any}[];
    markets = DataFrame(path_id=Int[], spy_growth=Float64[], spy_max_drawdown=Float64[], spy_train_growth=Float64[],
        market_jump_days=Int[], lambda=Float64[], status=String[]);
    nd = 0;
    for p in 1:n_paths
        if haskey(results[p], :out)
            nd = length(results[p].out.dates);
            break;
        end
    end
    equity = Dict{String,Matrix{Float32}}(); # the daily equity of the main strategies only, to keep the file small
    main_labels = String[];
    for st in strategies
        if st.main == true
            equity[st.label] = fill(Float32(NaN), nd, n_paths);
            push!(main_labels, st.label);
        end
    end
    spy = fill(Float32(NaN), nd, n_paths);
    dates = Date[];
    for p in 1:n_paths
        r = results[p];
        if haskey(r, :out) == false
            println("synthetic market ", p, " failed: ", r.error);
            push!(markets, (p, NaN, NaN, NaN, 0, NaN, "error"));
            continue;
        end
        dates = r.out.dates;
        push!(markets, (p, r.stats.spy_growth, r.stats.spy_max_drawdown, r.stats.spy_train_growth,
            r.stats.market_jump_days, r.lambda, "ok"));
        spy[:, p] = Float32.(r.out.spy);
        for row in r.out.rows
            row[:path_id] = p;
            push!(rows, row);
            if haskey(equity, row[:strategy]) == true
                equity[row[:strategy]][:, p] = Float32.(r.out.equity[row[:strategy]]);
            end
        end
    end
    df = rows_to_frame(rows);
    df_main = df[in.(df.strategy, Ref(Set(main_labels))), :]; # the rows of the main strategies
    CSV.write(joinpath(_PATH_TO_DATA, "L14a-Strategies-Synthetic-2025-2026.csv"), df_main);
    CSV.write(joinpath(_PATH_TO_DATA, "L14a-Strategies-Synthetic-Markets.csv"), markets);
    jldsave(joinpath(_PATH_TO_DATA, "L14a-Strategies-Synthetic-2025-2026.jld2"), true; dates=dates, spy=spy,
        equity=equity, summary=df, labels=[st.label for st in strategies]);
    println("synthetic markets: ", count(isequal("ok"), markets.status), " of ", n_paths, " ran; ",
        count(isequal("error"), df.status), " strategy runs failed, ", count(isequal("ruined"), df.status), " ruined");
    return nothing;
end

"""
    write_settings(generator, strategies, options, part::String)::Nothing

Record the settings and inputs of one part of the run, `part` = `"Real"` or `"Synthetic"`, in
`L14a-Strategies-Settings-<part>.toml`.
"""
function write_settings(generator::NamedTuple, strategies::Vector{NamedTuple}, options::NamedTuple,
        part::String)::Nothing
    s = study_settings();
    d = Dict{String,Any}();
    d["written"] = string(now());
    d["windows"] = Dict("train_start" => string(_TRAIN_START), "train_stop" => string(_TRAIN_STOP),
        "run_start" => string(_RUN_START), "run_stop" => string(_RUN_STOP));
    d["strategies"] = [st.label for st in strategies];
    d["engine"] = Dict("config" => "code/src/data/mpc/study.toml (method v2)",
        "selection_rules" => "the ten of the INFORMS 2026 talk (see strategy_list)", "basket_K" => s.basket_K,
        "seeds_real" => _N_SEEDS_REAL, "seeds_synthetic" => _N_SEEDS_SYNTHETIC, "seed" => _SEED, "N_per_sector" => s.N_per_sector, "forecast_model" => s.forecast_model,
        "forecast_band" => s.forecast_band, "market_turn" => s.market_turn, "beta_over_cap" => s.beta_over_cap,
        "spy_short" => s.spy_short, "beta_min" => s.beta_min, "half_spread_bps" => s.half_spread_bps,
        "borrow_rate" => s.borrow_rate);
    d["bab"] = Dict("shrink" => _BAB_SHRINK, "rebalance" => "first trading day of each month",
        "universe" => "every stock of the market");
    d["synthetic"] = Dict("paths" => options.paths, "seeds" => "1 to paths (JumpHMM.sample_dependence)",
        "generator" => "data/JumpHMM-SectorFactor-Universe-2014-2024.jld2",
        "alpha_pull" => _ALPHA_PULL, "beta_halflife" => _BETA_HALFLIFE,
        "beta_scale" => "data/L14a-Synthetic-Drift-Settings.csv (INFORMS method-v2 generator, sha1 a0732f54)");
    io = open(joinpath(_PATH_TO_DATA, "L14a-Strategies-Settings-" * part * ".toml"), "w");
    TOML.print(io, d);
    close(io);
    return nothing;
end

# main -
options = parse_options(ARGS);
println("threads: ", Threads.nthreads(), ", synthetic markets: ", options.paths);
generator = load_generator();
check_forecast_draws(generator.base.market_model);
t_fm = @elapsed fm = MPC.build_forecast_models(generator.base);
println("forecast models: ", round(t_fm; digits=1), " s; median sector share ρ = ", round(median(fm.ρ); digits=3));
if options.real == true
    strategies = strategy_list(_N_SEEDS_REAL);
    write_settings(generator, strategies, options, "Real");
    t_real = @elapsed run_real(generator, fm, strategies);
    println("real market: ", round(t_real; digits=1), " s");
end
if options.synthetic == true
    strategies = strategy_list(_N_SEEDS_SYNTHETIC);
    write_settings(generator, strategies, options, "Synthetic");
    t_syn = @elapsed run_synthetic(generator, fm, strategies, options.paths);
    println("synthetic markets: ", round(t_syn / 60; digits=1), " min");
end
