# Ledger parity: the port reproduces the paper snapshot's final-grid SHA-256 and per-run metrics.
# Constants follow SNAP/model-b/Compute-ModelB-FiniteSizeQuench.jl (_config, Full mode) and the rows of
# SNAP/data/Rebuild-Execution-Ledger.csv (phase `size`) and ModelB-FiniteSizeQuench-Full-Summary.csv.

const T_PRE = 1000
const T_POST = 3000
const STEPS = T_PRE + T_POST
const FINAL_WINDOW = min(T_POST, 500)

# every field set explicitly (the inherited build defaults included) -
function _paper_config(L::Int, f::Float64, h::Float64, seed::Int)
    return WM.build(WM.MyModelBConfiguration, (
        number_of_rows = L,
        number_of_cols = L,
        number_of_colors = 3,
        radius = 4,
        steps = STEPS,
        seed = seed,
        initial_condition = :balanced_perturbation,
        initial_buy_fraction = 0.05,
        initial_sell_fraction = 0.05,
        edge_fraction = 0.25,
        α = 1 / 60,
        λ = 0.02,
        k = 1.0,
        minority_fraction = f,
        edge_band_spread = 0.5,
        cost_basis_rule = false,
        initial_cash = 1000.0,
        initial_shares = 10,
        P0 = 100.0,
        market_maker_capacity = h,
        rule_major_index = 19280,
        rule_minor_index = 19286,
    ))
end

# every simulation keyword passed explicitly (clearing is fixed to :reserve by simulate_checked) -
function _run(L, f, h, seed, mode, activation)
    return WM.simulate_checked(_paper_config(L, f, h, seed);
        snapshot_steps = [T_PRE, STEPS],
        minority_population = :interior,
        rule_activation_step = activation,
        boundary_mode = mode,
        activation_action = :rule,
        fixed_band_step = nothing,
        intervention = nothing,
        initial_grid = nothing,
        observer = nothing,
        verbose = false,
    )
end

_sha(r) = bytes2hex(sha256(reinterpret(UInt8, vec(r.frames[STEPS]))))

# the snapshot's _metrics definitions -
function _metrics(r, L)
    final_states = @view r.sell_fraction[(end - FINAL_WINDOW + 1):end]
    post_prices = @view r.prices[(T_PRE + 1):end]
    rejected = sum(@view r.market_maker_rejected_buys[(T_PRE + 1):end]) +
               sum(@view r.market_maker_rejected_sells[(T_PRE + 1):end])
    eligible = sum(@view r.executed_buys[(T_PRE + 1):end]) + sum(@view r.executed_sells[(T_PRE + 1):end]) + rejected
    i = findfirst(≥(0.5), @view r.sell_fraction[(T_PRE + 2):end])
    onset = isnothing(i) ? 0 : i
    return (onset = onset, transitioned = onset > 0, final_sell_mean = mean(final_states),
            maximum_drawdown = WM.compute_max_drawdown(collect(post_prices)),
            maker_rejection_fraction = rejected / max(1, eligible))
end

# (L, seed, f, h, boundary mode, activation step, final-grid SHA-256 from the execution ledger) -
const LEDGER = [
    (32, 1, 0.14, 100.0, :hold, T_PRE + 1, "54c50df1046add0f9f9a0484b688890aa663eed6f0a92b4788dccdb446739246"),
    (32, 1, 0.25, 100.0, :hold, STEPS + 1, "d104612cdcb06aea780a1d13d482bd085a22a5e99bf3f8c350b343651713a06d"),
    (32, 14, 0.25, 100.0, :endogenous, STEPS + 1, "90f52b19d847423e9350b088976f46cd31db0c60bb86cf454cbff586aca084e0"),
    (32, 27, 0.25, 1.0, :endogenous, STEPS + 1, "46c97e2a759aec802530eee88db3fe999f9d5ee1c91aeeabf68496e89ab596e4"),
]

@testset "final-grid SHA-256 matches the execution ledger" begin
    for (L, seed, f, h, mode, activation, sha) in LEDGER
        @testset "L=$L seed=$seed f=$f h=$h $mode activation=$activation" begin
            r = _run(L, f, h, seed, mode, activation)
            @test _sha(r) == sha
        end
    end
end

@testset "WM.simulate with clearing = :reserve agrees with simulate_checked" begin
    L, seed, f, h, mode, activation, sha = LEDGER[1]
    r = WM.simulate(_paper_config(L, f, h, seed); clearing = :reserve, minority_population = :interior,
        boundary_mode = mode, rule_activation_step = activation, snapshot_steps = [T_PRE, STEPS], verbose = false)
    @test _sha(r) == sha
    # the default clearing is :reserve
    r2 = WM.simulate(_paper_config(L, f, h, seed); minority_population = :interior,
        boundary_mode = mode, rule_activation_step = activation, snapshot_steps = [T_PRE, STEPS], verbose = false)
    @test _sha(r2) == sha
end

@testset "per-run metrics match the finite-size summary" begin
    # L=32, seed=1, f=0.14, h=100, :hold; control at f=0.25 with the switch after the horizon
    control = _run(32, 0.25, 100.0, 1, :hold, STEPS + 1)
    treated = _run(32, 0.14, 100.0, 1, :hold, T_PRE + 1)
    @test treated.frames[T_PRE] == control.frames[T_PRE]
    @test treated.prices[1:(T_PRE + 2)] == control.prices[1:(T_PRE + 2)]
    m = _metrics(treated, 32)
    @test m.final_sell_mean ≈ 0.24349555555555555 atol = 1e-12
    @test m.maximum_drawdown ≈ 0.03562218616429291 atol = 1e-12
    @test m.maker_rejection_fraction ≈ 1.5626379516316674e-6 atol = 1e-12
    @test m.transitioned == false

    # L=32, seed=14, f=0.25, h=100, :endogenous
    control = _run(32, 0.25, 100.0, 14, :endogenous, STEPS + 1)
    treated = _run(32, 0.25, 100.0, 14, :endogenous, T_PRE + 1)
    @test treated.frames[T_PRE] == control.frames[T_PRE]
    @test treated.prices[1:(T_PRE + 2)] == control.prices[1:(T_PRE + 2)]
    m = _metrics(treated, 32)
    @test m.final_sell_mean ≈ 0.8276600000000001 atol = 1e-12
    @test m.maximum_drawdown ≈ 0.24713623760264702 atol = 1e-12
    @test m.maker_rejection_fraction ≈ 1.5271792083713855e-6 atol = 1e-12
    @test m.transitioned == true
    @test m.onset == 884
end

@testset "simulate_checked guards" begin
    cfg = _paper_config(32, 0.25, 100.0, 1)
    @test_throws ErrorException WM.simulate_checked(cfg; clearing = :legacy, verbose = false)
    inf = WM.build(WM.MyModelBConfiguration, (number_of_rows = 8, number_of_cols = 8, steps = 5))
    @test_throws ErrorException WM.simulate_checked(inf; verbose = false)
end
