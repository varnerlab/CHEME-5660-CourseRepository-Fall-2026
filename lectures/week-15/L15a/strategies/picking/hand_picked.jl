import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_hand_picked(tickers, basket)::Vector{String}

Keep the tickers in the chosen `basket` for every decision. Return them in their universe order.
Each ticker in `basket` must appear in `tickers`.
"""
function pick_hand_picked(tickers, basket)::Vector{String}
    # Find each hand-picked ticker in the market universe -
    columns = Int[];
    for ticker in basket
        j = 0;
        for i in eachindex(tickers)
            if tickers[i] == ticker
                j = i;
                break;
            end
        end
        if j == 0
            throw(ArgumentError("fixed-list ticker $(ticker) is missing from the universe"));
        end
        push!(columns, j);
    end
    return tickers[sort!(columns)];
end

struct MyL15aHandPickedScreen <: MPC.AbstractScreen
    basket::Vector{String}
end

function MPC.pick(screen::MyL15aHandPickedScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    selected = pick_hand_picked(md.tickers, screen.basket);
    return MPC._l15a_screen_columns(md, selected);
end
