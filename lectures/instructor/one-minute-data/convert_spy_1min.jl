# Convert the pulled bars to New York time, keep the regular session (09:30 to 15:59), save one JLD2 file.
include(joinpath(@__DIR__, "..", "..", "week-13", "L13b", "Include.jl"))
using CSV, DataFrames, Dates, JLD2
indir = ARGS[1]; outpath = ARGS[2]
# US daylight saving time: from the second Sunday of March, 2:00, to the first Sunday of November, 2:00 (local)
function nth_sunday(y, m, n)
    d = Date(y, m, 1)
    while dayofweek(d) != 7; d += Day(1); end
    return d + Week(n - 1)
end
function to_new_york(t_utc::DateTime)
    y = year(t_utc)
    dst_start_utc = DateTime(nth_sunday(y, 3, 2)) + Hour(7)  # 2:00 EST = 7:00 UTC
    dst_end_utc = DateTime(nth_sunday(y, 11, 1)) + Hour(6)   # 2:00 EDT = 6:00 UTC
    offset = (dst_start_utc <= t_utc < dst_end_utc) ? Hour(4) : Hour(5)
    return t_utc - offset
end
frames = DataFrame[]
for f in sort(filter(x -> endswith(x, ".csv"), readdir(indir)))
    push!(frames, CSV.read(joinpath(indir, f), DataFrame))
end
raw = vcat(frames...)
ny = [to_new_york(DateTime(String(s)[1:19])) for s in string.(raw.timestamp)]
half_days = [Date(2025, 7, 3), Date(2025, 11, 28), Date(2025, 12, 24)] # NYSE early closes (13:00) in the window
function in_session(t)
    close_time = (Date(t) in half_days) ? Time(13, 0) : Time(16, 0)
    return Time(9, 30) <= Time(t) < close_time
end
keep = [in_session(t) for t in ny]
df = DataFrame(timestamp = ny[keep], open = Float64.(raw.open[keep]), high = Float64.(raw.high[keep]),
               low = Float64.(raw.low[keep]), close = Float64.(raw.close[keep]),
               volume = Float64.(raw.volume[keep]), vwap = Float64.(raw.vwap[keep]))
sort!(df, :timestamp)
@assert allunique(df.timestamp)
days = Date.(df.timestamp)
counts = combine(groupby(DataFrame(day = days), :day), nrow => :n)
println("rows=", nrow(df), " days=", nrow(counts), " first=", df.timestamp[1], " last=", df.timestamp[end])
println("bars per day: ", sort(collect(StatsBase.countmap(counts.n)), by = first))
println("short days: ", counts[counts.n .< 390, :])
println("first bar each day 09:30? ", all(Time.(combine(groupby(DataFrame(t = df.timestamp, day = days), :day), :t => first => :t).t) .== Time(9, 30)))
jldsave(outpath; dataset = df, ticker = "SPY", feed = "sip", adjustment = "split", source = "Alpaca market data API, pulled 2026-11-18")
println("saved ", outpath, " ", filesize(outpath) / 1e6, " MB")
