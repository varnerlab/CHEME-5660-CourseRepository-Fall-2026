import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_gamma_by_sector(tickers, sectors, gamma; count::Int=3)::Vector{String}

Pick up to `count` tickers in each sector, starting with the highest preference weight `gamma`.
The three vectors share the same order. The output follows that order, which also breaks score ties.
"""
function pick_gamma_by_sector(tickers, sectors, gamma; count::Int=3)::Vector{String}
    # Rank the tickers separately in each sector -
    selected = Int[];
    for sector in sort(unique(sectors))
        members = Int[];
        for i in eachindex(sectors)
            if sectors[i] == sector
                push!(members, i);
            end
        end
        ranking = sortperm(-gamma[members]); # highest score first
        number_to_pick = min(count, length(members));
        append!(selected, members[ranking[1:number_to_pick]]);
    end
    return tickers[sort!(selected)];
end

struct MyL15aGammaSectorScreen <: MPC.AbstractScreen end

function MPC.pick(::MyL15aGammaSectorScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    selected = pick_gamma_by_sector(md.tickers, md.sector, γ_t; count=N);
    return MPC._l15a_screen_columns(md, selected);
end
