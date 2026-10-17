# Capture the SPY daily bars in spy-daily-2026-10-16.csv.
#
# This script documents where the bundled data came from. It is not part of the
# notebook and does not run in the course environment: it needs the varnerlab
# Alpaca SDK (https://github.com/varnerlab/alpaca-markets-sdk) and an Alpaca
# account. Run it from the SDK project:
#
#   ALPACA_SDK=<path to alpaca-markets-sdk> julia --project=<path to alpaca-markets-sdk> capture_spy_daily.jl <out.csv>
#
# Prices are split- and dividend-adjusted, so a dividend does not show up as a
# one-day drop in the realized volatility.
using Alpaca, Dates

const SDK = get(ENV, "ALPACA_SDK", pwd()) # path to the alpaca-markets-sdk project (default: run from it)

client = load_client(joinpath(SDK, "conf", "apidata.toml"))
td = today()
m = get_bars(client, "SPY", "1Day"; start = td - Day(400), finish = td, adjustment = "all")
bars = get(m, "SPY", Alpaca.Bar[])

open(ARGS[1], "w") do io
    println(io, "date,open,high,low,close,volume")
    for b ∈ bars
        println(io, join([Date(b.t), b.o, b.h, b.l, b.c, b.v], ","))
    end
end
