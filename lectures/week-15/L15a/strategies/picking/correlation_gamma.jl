using Statistics # calculate correlations between growth-rate series
import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_correlation_gamma(tickers, gamma, growth; count::Int=13, max_correlation::Real=0.7)::Vector{String}

Visit the tickers in descending preference-score order. Take a ticker when its growth-rate correlation
with every pick is at most `max_correlation`. Each column of `growth` holds one ticker's recent daily
growth rates. A constant column has an undefined correlation and can be picked.

If the screen leaves fewer than `count` picks, fill the basket in score order from the remaining tickers.
Return the basket in the order of `tickers`.
"""
function pick_correlation_gamma(tickers, gamma, growth; count::Int=13, max_correlation::Real=0.7)::Vector{String}
    ranking = sortperm(-gamma);
    selected = Int[];

    # Accept a ticker only when it passes the limit against every earlier pick -
    for j in ranking
        if length(selected) >= count
            break;
        end
        passes = true;
        for k in selected
            correlation = cor(view(growth, :, j), view(growth, :, k));
            if correlation > max_correlation
                passes = false;
                break;
            end
        end
        if passes
            push!(selected, j);
        end
    end

    # Finish a short basket with the highest-scoring tickers still available -
    for j in ranking
        if length(selected) >= count
            break;
        end
        if !(j in selected)
            push!(selected, j);
        end
    end
    return tickers[sort!(selected)];
end

struct MyL15aCorrelationGammaScreen <: MPC.AbstractScreen
    count::Int
    max_correlation::Float64
    window::Int # trading days of growth rates
end

function MPC.pick(screen::MyL15aCorrelationGammaScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    first_row = t - screen.window; # the close before the first growth day
    if first_row < 1
        throw(ArgumentError("need $(screen.window) trading days of growth before and including row $(t)"));
    end
    growth = MPC.growth_rates(md.close[first_row:t, :]);
    selected = pick_correlation_gamma(md.tickers, γ_t, growth; count=screen.count,
        max_correlation=screen.max_correlation);
    return MPC._l15a_screen_columns(md, selected);
end
