using Random # shuffle the tickers using the run's random stream
import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    pick_random_by_sector(tickers, sectors, rng::AbstractRNG; count::Int=3)::Vector{String}

Draw `count` distinct tickers from each sector. Keep every member of a sector with at most `count`
tickers. Return the selected tickers in their original order.
"""
function pick_random_by_sector(tickers, sectors, rng::AbstractRNG; count::Int=3)::Vector{String}
    # Use one random stream, visiting the sectors in alphabetical order -
    selected = Int[];
    for sector in sort(unique(sectors))
        members = Int[];
        for i in eachindex(sectors)
            if sectors[i] == sector
                push!(members, i);
            end
        end
        if length(members) > count
            members = shuffle(rng, members)[1:count];
        end
        append!(selected, members);
    end
    return tickers[sort!(selected)];
end

struct MyL15aRandomSectorScreen <: MPC.AbstractScreen end

function MPC.pick(::MyL15aRandomSectorScreen, md::MPC.MyMarketData, t::Int; X, γ_t, N::Int, seed::Int)::Vector{Int}
    rng = MersenneTwister(MPC._stream_seed(seed, md.dates[t], 0)); # one stream for this decision date
    selected = pick_random_by_sector(md.tickers, md.sector, rng; count=N);
    return MPC._l15a_screen_columns(md, selected);
end
