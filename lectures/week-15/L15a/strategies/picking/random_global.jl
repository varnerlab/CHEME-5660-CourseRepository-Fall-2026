using Random # shuffle the tickers using the run's random stream
import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_random_global(tickers, rng::AbstractRNG; count::Int=13)::Vector{String}

Draw `count` distinct tickers from the full universe. Return them in the order they appear in `tickers`.
Keep every ticker when the universe has at most `count` members.
"""
function pick_random_global(tickers, rng::AbstractRNG; count::Int=13)::Vector{String}
    # Each position in the shuffle corresponds to one ticker -
    selected = collect(eachindex(tickers));
    if length(selected) > count
        selected = shuffle(rng, selected)[1:count];
    end
    return tickers[sort!(selected)];
end

struct MyL15aRandomGlobalScreen <: MPC.AbstractScreen
    count::Int
end

function MPC.pick(screen::MyL15aRandomGlobalScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    rng = MersenneTwister(MPC._stream_seed(seed, md.dates[t], 0));
    selected = pick_random_global(md.tickers, rng; count=screen.count);
    return MPC._l15a_screen_columns(md, selected);
end
