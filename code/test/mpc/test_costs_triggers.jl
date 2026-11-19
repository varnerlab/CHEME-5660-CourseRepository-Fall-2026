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

# ---- Method v2: the market-turn and β triggers (Task 3) ----

"""
    turn_state(ξ_decision::Float64, ξ_now::Float64)::MyTriggerState

A trigger state 5 trading days after a decision, inside its drawdown limit and with no band, where the market
state was `ξ_decision` at the decision and is `ξ_now` today.

### Arguments
- `ξ_decision::Float64`: ξ at the last decision (dimensionless).
- `ξ_now::Float64`: ξ today (dimensionless).

### Returns
- `MyTriggerState`: the state.
"""
function turn_state(ξ_decision::Float64, ξ_now::Float64)::MyTriggerState
    return build(MyTriggerState, (τ=5, V_t=100.0, wealth_peak=100.0, ξ_decision=ξ_decision, ξ_now=ξ_now));
end

"""
    beta_state(book_beta::Float64, beta_limit::Float64; τ::Int=5)::MyTriggerState

A trigger state `τ` trading days after a decision, inside its drawdown limit and with no band, with the whole
book's β `book_beta` and the full β limit `beta_limit`.

### Arguments
- `book_beta::Float64`: the whole book's β (dimensionless).
- `beta_limit::Float64`: the full β limit (dimensionless).
- `τ::Int`: trading days since the last decision.

### Returns
- `MyTriggerState`: the state.
"""
function beta_state(book_beta::Float64, beta_limit::Float64; τ::Int=5)::MyTriggerState
    return build(MyTriggerState, (τ=τ, V_t=100.0, wealth_peak=100.0, book_beta=book_beta, beta_limit=beta_limit));
end

@testset "v2: trigger defaults are v1" begin
    spec = build(MyMPCSpec, (;))
    @test spec.market_turn == false && spec.beta_over_cap == Inf && spec.turn_at_one == false
    s = MyTriggerState()
    @test s.ξ_now == 0.0 && s.ξ_decision == 0.0 && s.book_beta == 0.0 && s.beta_limit == Inf
    # with the v1 spec, a turned market and a book far over its limit change nothing
    @test check_trigger(turn_state(-0.1, 0.1), spec) == :in_spec
    @test check_trigger(beta_state(2.0, 0.5), spec) == :in_spec
    @test check_trigger(beta_state(2.0, 0.5; τ=21), spec) == :horizon_elapsed
end

@testset "v2: the market-turn trigger" begin
    on = build(MyMPCSpec, (market_turn=true,))
    on_at_one = build(MyMPCSpec, (market_turn=true, turn_at_one=true))
    # a sign change of ξ fires in both directions
    @test check_trigger(turn_state(-0.1, 0.1), on) == :market_turn
    @test check_trigger(turn_state(0.1, -0.1), on) == :market_turn
    # crossing 1 fires only with turn_at_one
    @test check_trigger(turn_state(0.9, 1.1), on_at_one) == :market_turn
    @test check_trigger(turn_state(1.1, 0.9), on_at_one) == :market_turn
    @test check_trigger(turn_state(0.9, 1.1), on) == :in_spec
    # the same side of 0 and of 1 does not fire
    @test check_trigger(turn_state(0.1, 0.4), on_at_one) == :in_spec
    @test check_trigger(turn_state(1.1, 1.4), on_at_one) == :in_spec
    # ξ = 0 counts as bullish: from −0.01, the days −0.01, 0.0, 0.01 fire once, on the third day
    fired = Symbol[]
    for ξ in (-0.01, 0.0, 0.01)
        push!(fired, check_trigger(turn_state(-0.01, ξ), on_at_one))
    end
    @test fired == [:in_spec, :in_spec, :market_turn]
    # ξ = 1 counts as not past 1
    @test check_trigger(turn_state(0.9, 1.0), on_at_one) == :in_spec
    @test check_trigger(turn_state(1.0, 1.01), on_at_one) == :market_turn
    # the flags hold every condition on its own; the reason follows the priority order
    s = build(MyTriggerState, (τ=5, V_t=90.0, wealth_peak=100.0, ξ_decision=-0.1, ξ_now=0.1))
    flags = trigger_flags(s, on)
    @test flags.drawdown && flags.market_turn
    @test !flags.beta_over_cap && !flags.horizon && !flags.band_exit && !flags.cash_revisit
    @test check_trigger(s, on) == :drawdown
end

@testset "v2: the β-over-limit trigger" begin                        # Review Focus 3
    spec = build(MyMPCSpec, (beta_over_cap=0.1,))
    # a book at its limit plus a small rise does not fire; past the 0.1 margin it fires
    @test check_trigger(beta_state(0.55, 0.5), spec) == :in_spec
    @test check_trigger(beta_state(0.65, 0.5), spec) == :beta_over_cap
    # no limit with the hedge off
    @test check_trigger(beta_state(5.0, Inf), spec) == :in_spec
    # a limit below 0 (with the SPY short)
    @test check_trigger(beta_state(-0.25, -0.3), spec) == :in_spec
    @test check_trigger(beta_state(-0.1, -0.3), spec) == :beta_over_cap
    # the order: the market turn before the β trigger, and the β trigger before the horizon
    both = build(MyMPCSpec, (market_turn=true, beta_over_cap=0.1))
    s = build(MyTriggerState, (τ=21, V_t=100.0, wealth_peak=100.0, book_beta=0.65, beta_limit=0.5,
        ξ_decision=-0.1, ξ_now=0.1))
    @test check_trigger(s, both) == :market_turn
    @test check_trigger(beta_state(0.65, 0.5; τ=21), spec) == :beta_over_cap
end

@testset "v2: z = Inf switches the band check off for both bands" begin    # Codex review 2026-11-13, item 4
    on = build(MyMPCSpec, (;))
    off = build(MyMPCSpec, (; z=Inf))
    sigma_band = build(MyProjection, (μ=[100.0, 100.0], σ=[1.0, 1.0]))
    quantile_band = build(MyProjection, (μ=[100.0, 100.0], σ=[1.0, 1.0], lo=[99.0, 99.0], hi=[101.0, 101.0]))
    # wealth of 90 is below both bands on day 1; the peak is 90, so the drawdown stop does not fire
    for band in (sigma_band, quantile_band)
        state = build(MyTriggerState, (τ=1, V_t=90.0, wealth_peak=90.0, projection=band))
        @test check_trigger(state, on) == :band_exit
        @test check_trigger(state, off) == :in_spec
        @test trigger_flags(state, off).band_exit == false
    end
end
