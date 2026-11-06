# Runtime.jl -- per-run invariant checks for the reserve-clearing simulator.
# Port of simulate_repaired in rebuild/RebuildRuntime.jl of the paper snapshot,
# without the execution-ledger write.

"""
    simulate_checked(config; kwargs...) → MyModelBSimulationResult

Run [`simulate`](@ref) with `clearing = :reserve` and then assert the run's invariants: cash and shares
(traders plus dealer) are conserved, prices are finite and positive, no trader ends with negative cash or
shares, the dealer's cash times inventory stays constant, and each price equals the dealer's cash-to-inventory
ratio. The configuration must have finite `market_maker_capacity`. `clearing` cannot be passed.
"""
function simulate_checked(config::MyModelBConfiguration; kwargs...)::MyModelBSimulationResult
    isfinite(config.market_maker_capacity) || error("the checked simulation requires finite reserves")
    haskey(kwargs,:clearing) && error("clearing is fixed to :reserve")
    r=simulate(config;clearing=:reserve,kwargs...)
    cash=r.total_cash.+r.market_maker_cash
    shares=r.total_shares.+r.market_maker_inventory
    intervention=get(kwargs,:intervention,nothing)
    spans=if isnothing(intervention)
        (1:length(cash),)
    else
        t=get(kwargs,:rule_activation_step,nothing)
        isnothing(t) && error("resource intervention must identify its scheduled step")
        (1:t,t+1:length(cash))
    end
    for span in spans
        @assert maximum(abs.(cash[span].-cash[first(span)])) < max(1e-5,abs(cash[first(span)])*1e-11)
        @assert all(==(shares[first(span)]),shares[span])
    end
    @assert all(isfinite,r.prices) && all(>(0),r.prices)
    @assert minimum(r.final_books.cash)>=-1e-9 && minimum(r.final_books.shares)>=0
    if config.market_maker_capacity>0
        product=r.market_maker_cash.*r.market_maker_inventory
        @assert maximum(abs.(product./product[1].-1))<1e-9
        @assert r.prices≈r.market_maker_cash./r.market_maker_inventory
    else
        @assert all(==(config.P0),r.prices)
    end
    r
end
