using Random # shuffle the shortlisted tickers using the run's random stream
import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_random_liquid(tickers, dollar_volume, rng::AbstractRNG; count::Int=13, shortlist::Int=100)::Vector{String}

Rank tickers by their median daily `dollar_volume` in USD/day. Draw `count` distinct tickers from the
first `shortlist`, or keep every member when the shortlist is smaller than the requested basket.
Return the selected tickers in their original order.
"""
function pick_random_liquid(tickers, dollar_volume, rng::AbstractRNG; count::Int=13,
        shortlist::Int=100)::Vector{String}
    # Sort by liquidity before drawing from the shortlist -
    by_volume = sortperm(-dollar_volume);
    liquid = by_volume[1:min(shortlist, length(by_volume))];
    if length(liquid) > count
        liquid = shuffle(rng, liquid)[1:count];
    end
    return tickers[sort!(liquid)];
end

struct MyL15aRandomLiquidScreen <: MPC.AbstractScreen
    count::Int
    shortlist::Int
    window::Int # trading days in the liquidity window
end

function MPC.pick(screen::MyL15aRandomLiquidScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    rng = MersenneTwister(MPC._stream_seed(seed, md.dates[t], 0));
    dollar_volume = MPC._liquidity_scores(md, t, screen.window);
    selected = pick_random_liquid(md.tickers, dollar_volume, rng; count=screen.count, shortlist=screen.shortlist);
    return MPC._l15a_screen_columns(md, selected);
end
