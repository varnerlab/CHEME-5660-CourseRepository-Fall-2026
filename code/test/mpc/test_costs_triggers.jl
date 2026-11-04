using Test
@testset "costs and triggers" begin
    @test trade_cost(100, 50.0, 1e6) ≈ 5e-4*50*100 + 0.001*(100/1e6)*50*100
    @test trade_cost(-100, 50.0, 1e6) ≈ trade_cost(100, 50.0, 1e6)
    @test trade_cost(0, 50.0, 1e6) == 0
    @test borrow_fee(10_000.0) ≈ 0.0075*10_000/252

    spec = build(MyMPCSpec, (;))
    @test (spec.z, spec.T, spec.N, spec.D_max, spec.cash_revisit_interval) == (1.96, 21, 1000, 0.08, 21)
    @test build(MyMPCSpec, (; T = 10)).T == 10

    proj = build(MyProjection, (μ = [100.0, 110.0, 120.0], σ = [1.0, 1.0, 1.0]))
    st(; kw...) = build(MyTriggerState, merge((τ = 5, V_t = 100.0, wealth_peak = 100.0), NamedTuple(kw)))

    @test check_trigger(st(initial = true, τ = 0), spec) == :initial
    @test check_trigger(st(forced = true, τ = 0), spec) == :forced
    @test check_trigger(st(initial = true, forced = true), spec) == :initial
    @test check_trigger(st(τ = 21, last_alloc_was_cash = true), spec) == :cash_revisit
    @test check_trigger(st(V_t = 90.0), spec) == :drawdown
    @test check_trigger(st(V_t = 90.0, τ = 30), spec) == :drawdown
    @test check_trigger(st(τ = 21), spec) == :horizon_elapsed
    @test check_trigger(st(τ = 0, basket_changed = true), spec) == :in_spec
    @test check_trigger(st(basket_changed = true, projection = proj, V_t = 120.0, wealth_peak = 120.0), spec) == :basket_change
    @test check_trigger(st(τ = 30, natural = false), spec) == :in_spec
    @test check_trigger(st(τ = 30, natural = false, basket_changed = true), spec) == :basket_change
    @test check_trigger(st(τ = 30, natural = false, initial = true), spec) == :initial

    # band uses the τ-th entry: V=110 in-band at τ=2, out of band at τ=1 and τ=3
    @test check_trigger(st(τ = 2, V_t = 110.0, wealth_peak = 110.0, projection = proj), spec) == :in_spec
    @test check_trigger(st(τ = 1, V_t = 110.0, wealth_peak = 110.0, projection = proj), spec) == :band_exit
    @test check_trigger(st(τ = 3, V_t = 110.0, wealth_peak = 110.0, projection = proj), spec) == :band_exit
    # nothing projection skips band; other natural triggers still apply
    @test check_trigger(st(τ = 2, V_t = 110.0, wealth_peak = 110.0, projection = nothing), spec) == :in_spec
    @test check_trigger(st(τ = 21, projection = nothing), spec) == :horizon_elapsed
    # index clamps to projection length
    @test check_trigger(st(τ = 10, V_t = 120.0, wealth_peak = 120.0, projection = proj), spec) == :in_spec
end
