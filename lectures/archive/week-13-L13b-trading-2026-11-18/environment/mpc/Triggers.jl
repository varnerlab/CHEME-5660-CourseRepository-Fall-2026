"""
    MyMPCSpec

MPC trigger/projection settings: band width `z`, horizon `T` (trading days), projection paths `N`,
drawdown limit `D_max` (fraction), and `cash_revisit_interval` (trading days).
"""
mutable struct MyMPCSpec
    z::Float64
    T::Int
    N::Int
    D_max::Float64
    cash_revisit_interval::Int
    MyMPCSpec() = new(1.96, 21, 1000, 0.08, 21)
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
    MyTriggerState() = new(0, 0.0, 0.0, false, nothing, false, false, false, true)
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
    check_trigger(s::MyTriggerState, spec::MyMPCSpec)::Symbol

Rebalance reason in priority order: `:initial`, `:forced`, (if `s.natural`) `:cash_revisit`,
`:drawdown`, `:horizon_elapsed`, `:band_exit`, then `:basket_change`, else `:in_spec`.
`:initial`/`:forced` fire regardless of τ; otherwise τ ≤ 0 gives `:in_spec`. The band check uses
index `min(τ, length(μ))` and is skipped when no projection exists. `wealth_peak` is never reset here.
"""
function check_trigger(s::MyTriggerState, spec::MyMPCSpec)::Symbol
    s.initial && return :initial
    s.forced && return :forced
    s.τ <= 0 && return :in_spec
    if s.natural
        s.last_alloc_was_cash && s.τ >= spec.cash_revisit_interval && return :cash_revisit
        if s.wealth_peak > 0.0 && (s.wealth_peak - s.V_t) / s.wealth_peak > spec.D_max
            return :drawdown
        end
        s.τ >= spec.T && return :horizon_elapsed
        p = s.projection
        if p !== nothing
            i = min(s.τ, length(p.μ))
            (s.V_t < p.μ[i] - spec.z * p.σ[i] || s.V_t > p.μ[i] + spec.z * p.σ[i]) && return :band_exit
        end
    end
    s.basket_changed && return :basket_change
    return :in_spec
end
