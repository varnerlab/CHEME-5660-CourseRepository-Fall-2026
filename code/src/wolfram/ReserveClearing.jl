# Uniform-price batch execution against a cash-and-share reserve curve.

function build_reserve_dealer(config, n_traders::Int64)
    h = config.market_maker_capacity
    isfinite(h) && h >= 0 || throw(ArgumentError("reserve clearing requires finite nonnegative reserves"))
    H = round(Int64, h*n_traders)
    h > 0 && H < 1 && throw(ArgumentError("positive reserves must contain at least one share"))
    MyMarketMaker(config.P0*H, H, config.P0*H, H, H==0 ? 0 : 1,
                  typemax(Int64), 0., false)
end

"""
    execute_reserve_orders!(books, grid, edges, states, last_price; market_maker, ...)

Find a feasible net dealer trade at a single execution price C/(Q-x), where
x is executed trader buys minus sells. Affordability and the optional sale
restriction use that price. Cash times inventory is preserved, and the new
marginal quote is the final reserve ratio. No further price impact is applied.
"""
function execute_reserve_orders!(books::MyAgentBooks, grid::Array{Int64,2},
    edges::Vector{Tuple{Int64,Int64}}, states::Vector{Int64}, last_price::Float64;
    market_maker::MyMarketMaker, cost_basis_rule::Bool=false,
    seed::Int64=0, step::Int64=1, trace::Union{Nothing,MyOrderTrace}=nothing)
    dealer = market_maker
    dealer.unlimited && throw(ArgumentError("reserve dealer cannot borrow or short"))
    dealer.max_inventory == typemax(Int64) || throw(ArgumentError("use build_reserve_dealer"))
    if dealer.initial_inventory==0
        counts=execute_orders!(books,grid,edges,states,last_price;
            market_maker=MyMarketMaker(0.,0,0.,0,0,0,0.,false),cost_basis_rule,seed,step,trace)
        return merge(counts,(execution_price=last_price,next_price=last_price))
    end
    dealer.cash>0 && dealer.inventory>=1 || error("nonpositive reserve")
    if !isnothing(trace)
        for buffer in (trace.desired,trace.eligible,trace.filled)
            size(buffer)==size(grid) || throw(DimensionMismatch("order trace dimensions"))
            fill!(buffer,0)
        end
    end
    buyers=NTuple{3,Int64}[]; sellers=NTuple{3,Int64}[]
    linear=LinearIndices(grid)
    function request(r,c,state)
        order=compute_desired_order(state)
        isnothing(trace) || (trace.desired[r,c]=order)
        order==0 && return
        push!(order==1 ? buyers : sellers, (Int64(r),Int64(c),Int64(linear[r,c])))
    end
    for c in 2:size(grid,2)-1, r in 2:size(grid,1)-1
        request(r,c,grid[r,c])
    end
    for (i,(r,c)) in enumerate(edges)
        request(r,c,states[i])
    end
    cash, inventory=dealer.cash,dealer.inventory
    clearing_price(x)=cash/(inventory-x)
    function excess(x)
        candidate_price=clearing_price(x)
        candidate_buys=count(b->books.cash[b[3]]>=candidate_price,buyers)
        candidate_sells=count(s->books.shares[s[3]]>=1 &&
                   (!cost_basis_rule || candidate_price>books.avg_cost[s[3]]),sellers)
        candidate_buys-candidate_sells
    end
    initial_excess=excess(0)
    direction=sign(initial_excess)
    # Excess demand decreases with candidate quantity. Find the last feasible
    # integer quantity; residual rationing resolves indivisible unit orders.
    lo=0
    hi=direction>0 ? min(initial_excess,inventory-1) : -initial_excess
    while lo<hi
        mid=lo+(hi-lo+1)÷2
        feasible=direction*excess(direction*mid)>=mid
        feasible ? (lo=mid) : (hi=mid-1)
    end
    net=direction*lo
    price=clearing_price(net)
    eligible_b=filter(b->books.cash[b[3]]>=price,buyers)
    eligible_s=filter(s->books.shares[s[3]]>=1 &&
                        (!cost_basis_rule || price>books.avg_cost[s[3]]),sellers)
    B,S=length(eligible_b),length(eligible_s)
    fill_b=direction>=0 ? S+net : B
    fill_s=direction>=0 ? S : B-net
    0<=fill_b<=B && 0<=fill_s<=S || error("infeasible reserve auction")
    if !isnothing(trace)
        for b in eligible_b; trace.eligible[b[3]]=1; end
        for s in eligible_s; trace.eligible[s[3]]=-1; end
    end
    0<fill_b<B && _rank_for_rationing!(eligible_b,seed,step,1)
    0<fill_s<S && _rank_for_rationing!(eligible_s,seed,step,-1)
    for i in 1:fill_b
        r,c,id=eligible_b[i]
        _settle_agent_order!(books,r,c,1,price)
        isnothing(trace) || (trace.filled[id]=1)
    end
    for i in 1:fill_s
        r,c,id=eligible_s[i]
        _settle_agent_order!(books,r,c,-1,price)
        isnothing(trace) || (trace.filled[id]=-1)
    end
    dealer.inventory=inventory-net
    dealer.cash=cash*inventory/dealer.inventory
    (;executed_buys=fill_b,executed_sells=fill_s,
       suppressed_buys=length(buyers)-B,suppressed_sells=length(sellers)-S,
       market_maker_rejected_buys=B-fill_b,market_maker_rejected_sells=S-fill_s,
       execution_price=price,next_price=dealer.cash/dealer.inventory)
end
