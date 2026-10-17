# Capture the end-of-day SPXW snapshot in spxw-chain-2026-10-16.csv.
#
# This script documents where the bundled data came from. It is not part of the
# notebook and does not run in the course environment: it needs the varnerlab
# Alpaca SDK (https://github.com/varnerlab/alpaca-markets-sdk) and an Alpaca
# account with options market data. Run it after the close from the SDK project:
#
#   ALPACA_SDK=<path to alpaca-markets-sdk> julia --project=<path to alpaca-markets-sdk> capture_spxw_ladder.jl <out.csv>
#
# Alpaca lists SPXW weeklies under the SPX underlying. For each target days to
# expiration, we keep the nearest SPXW expiration within TOL days, then save the
# latest quote of every contract at that expiration (no index level: Alpaca's
# index-option offering has none).
using Alpaca, Dates

const SDK = get(ENV, "ALPACA_SDK", pwd()) # path to the alpaca-markets-sdk project (default: run from it)
const LADDER = [30, 45, 60, 90] # target days to expiration
const TOL = 3 # largest allowed gap between an expiration and its target (days)

client = load_client(joinpath(SDK, "conf", "apidata.toml"))
td = today()

# every SPXW contract out to the longest target -
cs = filter(c -> c.root_symbol == "SPXW",
    list_option_contracts(client; underlying_symbols = "SPX",
        expiration_date_gte = td, expiration_date_lte = td + Day(maximum(LADDER) + TOL)))

# the nearest SPXW expiration to each target, within the tolerance -
exps = sort(unique(c.expiration_date for c in cs))
pick = Dict{Int,Date}()
for t ∈ LADDER
    best = argmin(e -> abs(Dates.value(e - td) - t), exps)
    abs(Dates.value(best - td) - t) <= TOL && (pick[t] = best)
end
target_of = Dict(e => t for (t, e) ∈ pick)
keep = filter(c -> haskey(target_of, c.expiration_date), cs)

# latest quote for each contract, 50 symbols per request -
snaps = Dict{String,Alpaca.OptionSnapshot}()
syms = [c.symbol for c in keep]
for i ∈ 1:50:length(syms)
    merge!(snaps, get_option_snapshots(client, syms[i:min(i + 49, end)]))
end

open(ARGS[1], "w") do io
    println(io, "date,root,expiration,dte,target_dte,type,strike,style,multiplier,bid,ask,mid,bid_size,ask_size,quote_utc")
    for c ∈ sort(keep; by = c -> (c.expiration_date, c.type, c.strike_price))
        s = get(snaps, c.symbol, nothing)
        (s === nothing || s.latest_quote === nothing) && continue
        q = s.latest_quote
        println(io, join([td, c.root_symbol, c.expiration_date, Dates.value(c.expiration_date - td),
            target_of[c.expiration_date], c.type, c.strike_price, c.style, c.multiplier,
            q.bid_price, q.ask_price, (q.bid_price + q.ask_price)/2, q.bid_size, q.ask_size,
            Dates.format(q.t, "yyyy-mm-ddTHH:MM:SS")], ","))
    end
end
