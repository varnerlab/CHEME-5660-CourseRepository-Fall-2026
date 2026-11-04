"""
    trade_cost(q, price, adv; half_spread_bps=5.0, κ=0.001)::Float64

Per-fill cost (USD): half-spread `half_spread_bps·1e-4·price·|q|` plus linear impact
`κ·(|q|/adv)·price·|q|`. Zero commission. Returns 0 when `q = 0`.
"""
function trade_cost(q::Real, price::Float64, adv::Float64; half_spread_bps::Float64 = 5.0,
        κ::Float64 = 0.001)::Float64
    q == 0 && return 0.0
    n = abs(q)
    return (half_spread_bps * 1e-4) * price * n + κ * (n / adv) * price * n
end

"""
    borrow_fee(short_notional; rate=0.0075, Δt=1/252)::Float64

Borrow fee (USD) accrued over one step of `Δt` years on `short_notional` USD of shorts.
"""
borrow_fee(short_notional::Float64; rate::Float64 = 0.0075, Δt::Float64 = 1/252)::Float64 =
    rate * abs(short_notional) * Δt
