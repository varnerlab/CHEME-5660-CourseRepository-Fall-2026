import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_liquid_gamma(tickers, gamma, dollar_volume; count::Int=13, shortlist::Int=100)::Vector{String}

Rank tickers by their median daily `dollar_volume` in USD/day. Keep up to `shortlist` tickers.
Pick up to `count` of those tickers by their preference weight `gamma`. The order in `tickers` breaks
ties in both rankings and sets the order of the result.
"""
function pick_liquid_gamma(tickers, gamma, dollar_volume; count::Int=13, shortlist::Int=100)::Vector{String}
    # Rank the universe by liquidity and then rank the shortlist by score -
    by_volume = sortperm(-dollar_volume);
    liquid = sort(by_volume[1:min(shortlist, length(by_volume))]); # the shortlist in ticker order
    by_score = sortperm(-gamma[liquid]); # highest score first; ticker order breaks ties
    selected = liquid[by_score[1:min(count, length(liquid))]];
    return tickers[sort!(selected)];
end

struct MyL15aLiquidGammaScreen <: MPC.AbstractScreen
    count::Int
    shortlist::Int
    window::Int # trading days in the liquidity window
end

function MPC.pick(screen::MyL15aLiquidGammaScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    dollar_volume = MPC._liquidity_scores(md, t, screen.window);
    selected = pick_liquid_gamma(md.tickers, γ_t, dollar_volume; count=screen.count, shortlist=screen.shortlist);
    return MPC._l15a_screen_columns(md, selected);
end
