import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_global_gamma(tickers, gamma; count::Int=13)::Vector{String}

Pick up to `count` tickers with the highest preference weight `gamma` across the whole universe.
The order in `tickers` breaks ties and sets the order of the result.
"""
function pick_global_gamma(tickers, gamma; count::Int=13)::Vector{String}
    # Rank the entire universe by its preference weights -
    ranking = sortperm(-gamma);
    number_to_pick = min(count, length(ranking));
    return tickers[sort!(ranking[1:number_to_pick])];
end

struct MyL15aGlobalGammaScreen <: MPC.AbstractScreen
    count::Int
end

function MPC.pick(screen::MyL15aGlobalGammaScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    selected = pick_global_gamma(md.tickers, γ_t; count=screen.count);
    return MPC._l15a_screen_columns(md, selected);
end
