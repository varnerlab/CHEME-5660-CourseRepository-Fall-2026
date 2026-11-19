"""
    MyMPCSpec

MPC trigger/projection settings: band width `z`, horizon `T` (trading days), projection paths `N`,
drawdown limit `D_max` (fraction), and `cash_revisit_interval` (trading days).

The method-v2 triggers:
- `market_turn::Bool`: re-plan when the market state ξ moves to the other side of 0 from ξ at the last
  decision (bull to bear, or bear to bull).
- `beta_over_cap::Float64`: the margin (dimensionless) by which the whole book's β may exceed its β limit before
  a re-plan; `Inf` turns the trigger off.
- `turn_at_one::Bool`: also re-plan when ξ moves to the other side of 1, where the SPY short starts or stops.

The defaults `false`, `Inf` and `false` are the v1 method.
"""
mutable struct MyMPCSpec
    z::Float64
    T::Int
    N::Int
    D_max::Float64
    cash_revisit_interval::Int
    market_turn::Bool
    beta_over_cap::Float64
    turn_at_one::Bool
    MyMPCSpec() = new(1.96, 21, 1000, 0.08, 21, false, Inf, false)
end

"""
    build(::Type{MyMPCSpec}, data::NamedTuple)::MyMPCSpec

Start from the defaults and override any fields present in `data`.
"""
function build(::Type{MyMPCSpec}, data::NamedTuple)::MyMPCSpec
    model = MyMPCSpec()
    for f ∈ fieldnames(MyMPCSpec)
        haskey(data, f) && setfield!(model, f, data[f])
    end
    return model
end

"""
    MyTriggerState

Daily state for `check_trigger`: days since last decision `τ`, portfolio value `V_t`, running
`wealth_peak`, whether the last allocation was cash, the active `projection` (or `nothing`), and
the flags `initial`, `forced`, `basket_changed`, `natural`.

For the method-v2 triggers: the market state today `ξ_now` and at the last decision `ξ_decision`
(dimensionless, default `0.0`), the whole book's β `book_beta` with the SPY weight included (default `0.0`),
and the full β limit `beta_limit` (`Inf` with the hedge off, the default; it can be below 0).
"""
mutable struct MyTriggerState
    τ::Int
    V_t::Float64
    wealth_peak::Float64
    last_alloc_was_cash::Bool
    projection::Union{Nothing,MyProjection}
    initial::Bool
    forced::Bool
    basket_changed::Bool
    natural::Bool
    ξ_now::Float64
    ξ_decision::Float64
    book_beta::Float64
    beta_limit::Float64
    MyTriggerState() = new(0, 0.0, 0.0, false, nothing, false, false, false, true, 0.0, 0.0, 0.0, Inf)
end

"""
    build(::Type{MyTriggerState}, data::NamedTuple)::MyTriggerState

Start from defaults (τ=0, no flags, `natural=true`) and override any fields present in `data`.
"""
function build(::Type{MyTriggerState}, data::NamedTuple)::MyTriggerState
    model = MyTriggerState()
    for f ∈ fieldnames(MyTriggerState)
        haskey(data, f) && setfield!(model, f, data[f])
    end
    return model
end

"""
    trigger_flags(s::MyTriggerState, spec::MyMPCSpec)::NamedTuple

Every natural trigger condition on its own, before `check_trigger` picks one reason by priority.

### Arguments
- `s::MyTriggerState`: today's trigger state.
- `spec::MyMPCSpec`: the trigger settings.

### Returns
- `NamedTuple` of `Bool`:
  - `cash_revisit`: the last allocation was cash and τ ≥ `cash_revisit_interval`.
  - `drawdown`: equity `V_t` is more than `D_max` below `wealth_peak`.
  - `market_turn`: with `market_turn` on, ξ is on the other side of 0 from ξ at the last decision, or, with
    `turn_at_one`, on the other side of 1. ξ exactly 0 counts as bullish (not above 0), and ξ exactly 1 counts
    as not past 1.
  - `beta_over_cap`: `book_beta` > `beta_limit` + `beta_over_cap` (never with an `Inf` limit or margin).
  - `horizon`: τ ≥ `T`.
  - `band_exit`: `V_t` is outside the projection's band at index min(τ, length(μ)): the quantile band [`lo`, `hi`]
    when the projection has one, else μ ± z·σ. `false` with no projection, with τ < 1, or with z = Inf (the
    switch that turns the band check off).
"""
function trigger_flags(s::MyTriggerState, spec::MyMPCSpec)::NamedTuple

    # back to the market after an all-cash allocation
    cash_revisit = false;
    if s.last_alloc_was_cash && s.τ >= spec.cash_revisit_interval
        cash_revisit = true;
    end

    # equity fell more than D_max below its running peak
    drawdown = false;
    if s.wealth_peak > 0.0 && (s.wealth_peak - s.V_t) / s.wealth_peak > spec.D_max
        drawdown = true;
    end

    # the market turned: ξ crossed 0 (bull and bear), or crossed 1 (the SPY short starts or stops)
    market_turn = false;
    if spec.market_turn
        if (s.ξ_now > 0) != (s.ξ_decision > 0)
            market_turn = true;
        end
        if spec.turn_at_one && (s.ξ_now > 1) != (s.ξ_decision > 1)
            market_turn = true;
        end
    end

    # the whole book's β is past its limit by more than the margin
    beta_over_cap = false;
    if s.book_beta > s.beta_limit + spec.beta_over_cap
        beta_over_cap = true;
    end

    # the forecast horizon has passed
    horizon = false;
    if s.τ >= spec.T
        horizon = true;
    end

    # equity left the projection's band on day τ (the last day of the projection after it ends): the quantile
    # band when the forecast keeps one, else μ ± z·σ. z = Inf switches the band check off for both bands (the
    # calendar baseline runs).
    band_exit = false;
    p = s.projection;
    if p !== nothing && s.τ >= 1 && isfinite(spec.z)
        i = min(s.τ, length(p.μ));
        if length(p.lo) > 0
            lower = p.lo[i];
            upper = p.hi[i];
        else
            lower = p.μ[i] - spec.z * p.σ[i];
            upper = p.μ[i] + spec.z * p.σ[i];
        end
        if s.V_t < lower || s.V_t > upper
            band_exit = true;
        end
    end

    return (cash_revisit=cash_revisit, drawdown=drawdown, market_turn=market_turn, beta_over_cap=beta_over_cap,
        horizon=horizon, band_exit=band_exit);
end

"""
    check_trigger(s::MyTriggerState, spec::MyMPCSpec)::Symbol

The re-plan reason for today, in priority order: `:initial`, `:forced`, then (if `s.natural`) the conditions of
`trigger_flags` in the order `:cash_revisit`, `:drawdown`, `:market_turn`, `:beta_over_cap`, `:horizon_elapsed`,
`:band_exit`, then `:basket_change`, else `:in_spec`.

`:initial` and `:forced` fire regardless of τ; otherwise τ ≤ 0 gives `:in_spec`. `wealth_peak` is never reset
here. With the v1 spec (`market_turn = false`, `beta_over_cap = Inf`) the two v2 triggers never fire, and the
reasons are those of v1.

### Arguments
- `s::MyTriggerState`: today's trigger state.
- `spec::MyMPCSpec`: the trigger settings.

### Returns
- `Symbol`: today's re-plan reason.
"""
function check_trigger(s::MyTriggerState, spec::MyMPCSpec)::Symbol

    # the first day and a forced day decide whatever the state
    if s.initial
        return :initial;
    end
    if s.forced
        return :forced;
    end

    # no natural trigger on a decision day
    if s.τ <= 0
        return :in_spec;
    end

    # the natural triggers, in priority order
    if s.natural
        flags = trigger_flags(s, spec);
        if flags.cash_revisit
            return :cash_revisit;
        end
        if flags.drawdown
            return :drawdown;
        end
        if flags.market_turn
            return :market_turn;
        end
        if flags.beta_over_cap
            return :beta_over_cap;
        end
        if flags.horizon
            return :horizon_elapsed;
        end
        if flags.band_exit
            return :band_exit;
        end
    end

    # a basket change with no trigger re-plans too
    if s.basket_changed
        return :basket_change;
    end
    return :in_spec;
end
