# Pull SPY one-minute bars (SIP feed, split-adjusted), one month per request, 2025-01-01 through 2026-11-13.
using Alpaca, Dates, DataFrames, CSV
client = load_client("conf/apidata.toml")
out = ARGS[1]
months = [Date(2025, 1, 1) + Month(k) for k in 0:22] # Jan 2025 ... Nov 2026
for m in months
    start = DateTime(m)
    finish = min(DateTime(m + Month(1)), DateTime(2026, 11, 14))
    path = joinpath(out, "SPY-1min-$(Dates.format(m, "yyyy-mm")).csv")
    isfile(path) && continue
    model = MyStockBarsEndpointModel(symbols = "SPY", timeframe = "1Min", start = start, finish = finish,
                                     limit = 10000, adjustment = "split", feed = "sip")
    bars = api(client, model)
    CSV.write(path, bars)
    println(Dates.format(m, "yyyy-mm"), ": ", nrow(bars), " bars")
end
