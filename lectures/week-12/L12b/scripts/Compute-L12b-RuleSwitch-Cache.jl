# Compute-L12b-RuleSwitch-Cache.jl
# Big-grid rule-switch experiment for L12b. Writes ../data/L12b-RuleSwitch-Cache.jld2.
#   julia -t auto <this file>                full run (course settings: the paper's model, 20 seeds, the course f grid)
#   julia -t auto <this file> --provisional  L = 32, seeds 1:5, flagged provisional = true
#   julia -t auto <this file> --smoke        tiny run, writes ...-smoke.jld2 (never overwrites the full file)

# activate the course environment: walk up from this file to the nearest Project.toml -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    global const REPO_ROOT = d
    Pkg.activate(d); Pkg.instantiate();
end

using VLQuantitativeFinancePackage
import VLQuantitativeFinancePackage.WolframMarkets as WM
using DataFrames
using JLD2
using Dates

# defaults (full run) -
const L_FULL = 64
const SEEDS_FULL = collect(1:20)
const F_VALUES = [0.10, 0.14, 0.16, 0.18, 0.20, 0.25]
const CONDITIONS = [(h = 100.0, boundary_mode = :hold),
                    (h = 100.0, boundary_mode = :endogenous),
                    (h = 1.0, boundary_mode = :endogenous)]
const HEADLINE_F = [0.10, 0.25]
const HEADLINE_SEED = 1
const T_PRE_FULL = 1000
const T_POST_FULL = 3000

const SMOKE = "--smoke" in ARGS
const PROVISIONAL = "--provisional" in ARGS
(SMOKE && PROVISIONAL) && error("choose one of --smoke or --provisional")

const L = SMOKE ? 24 : (PROVISIONAL ? 32 : L_FULL)
const SEEDS = SMOKE ? collect(1:2) : (PROVISIONAL ? collect(1:5) : SEEDS_FULL)
const T_PRE = SMOKE ? 50 : T_PRE_FULL
const T_POST = SMOKE ? 150 : T_POST_FULL
const OUTFILE = joinpath(@__DIR__, "..", "data",
    SMOKE ? "L12b-RuleSwitch-Cache-smoke.jld2" : "L12b-RuleSwitch-Cache.jld2")

condition_label(c) = "h=$(c.h)/$(c.boundary_mode)"

# every pair uses the largest f as the control -
const F_CONTROL = maximum(F_VALUES)

# the arms' frames at t_pre and the final step -
arm_record(r, t_pre, t_final) = (sell_fraction = r.sell_fraction, buy_fraction = r.buy_fraction,
    prices = r.prices, frames = (pre = r.frames[t_pre], final = r.frames[t_final]))

# one (condition, seed) work item: all f values -
function run_item(c, seed::Int64)
    rows = NamedTuple[]
    pairs = NamedTuple[]
    for f in F_VALUES
        pair = WM.run_rule_switch(; L = L, f = f, h = c.h, seed = seed, boundary_mode = c.boundary_mode,
            t_pre = T_PRE, t_post = T_POST, f_control = F_CONTROL)
        s = WM.rule_switch_summary(pair)
        push!(rows, (L = L, condition = condition_label(c), h = c.h, boundary_mode = c.boundary_mode, f = f,
            seed = seed, transitioned = s.transitioned, onset = s.onset, final_sell_mean = s.final_sell_mean,
            max_drawdown = s.max_drawdown, control_transitioned = s.control_transitioned,
            control_max_drawdown = s.control_max_drawdown))
        if seed == HEADLINE_SEED && f in HEADLINE_F
            push!(pairs, (condition = condition_label(c), h = c.h, boundary_mode = c.boundary_mode, f = f,
                seed = seed, t_pre = T_PRE,
                switched = arm_record(pair.switched, T_PRE, T_PRE + T_POST),
                control = arm_record(pair.control, T_PRE, T_PRE + T_POST)))
        end
    end
    return (rows = rows, pairs = pairs)
end

function main()
    items = [(c, s) for c in CONDITIONS for s in SEEDS]
    results = Vector{Any}(undef, length(items))
    println("threads = $(Threads.nthreads()), work items = $(length(items)), L = $L, ",
        "t_pre = $T_PRE, t_post = $T_POST, provisional = $(SMOKE || PROVISIONAL)")
    t0 = time()
    Threads.@threads for i in eachindex(items)
        results[i] = run_item(items[i]...)
    end
    elapsed = time() - t0

    # build the outputs single-threaded -
    sweep = DataFrame(reduce(vcat, [r.rows for r in results]))
    pairs = reduce(vcat, [r.pairs for r in results])
    githash = try
        readchomp(`git -C $(REPO_ROOT) rev-parse --short HEAD`)
    catch
        "unknown"
    end
    settings = (L = L, t_pre = T_PRE, t_post = T_POST, seeds = SEEDS, f_values = F_VALUES,
        f_control = F_CONTROL, conditions = CONDITIONS,
        paper = (lambda = 0.02, k = 1.0, edge_band_spread = 0.5, cost_basis_rule = false, initial_cash = 1000.0,
            initial_shares = 10, P0 = 100.0, number_of_colors = 3, radius = 4,
            initial_condition = :balanced_perturbation, initial_buy_fraction = 0.05,
            initial_sell_fraction = 0.05, edge_fraction = 0.25, alpha = 1 / 60, rule_major_index = 19280,
            rule_minor_index = 19286, clearing = :reserve, minority_population = :interior),
        julia_version = string(VERSION), package_git_hash = githash, threads = Threads.nthreads(),
        wall_seconds = elapsed, created = string(Dates.now()), provisional = (SMOKE || PROVISIONAL))
    mkpath(dirname(OUTFILE))
    jldsave(OUTFILE; settings = settings, pairs = pairs, sweep = sweep)
    println("wrote $(normpath(OUTFILE)) ($(round(filesize(OUTFILE) / 1e6; digits = 2)) MB), ",
        "$(nrow(sweep)) sweep rows, $(length(pairs)) pairs, wall time $(round(elapsed; digits = 1)) s")
end

main()
