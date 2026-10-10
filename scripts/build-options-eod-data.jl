# Build the end-of-day options archive that VLQuantitativeFinancePackage loads as
# the lazy artifact `options_eod`, from the Alpaca DTE-ladder captures in
# varnerlab/alpaca-markets-sdk.
#
# Usage, from the repository root:
#   julia --project=. scripts/build-options-eod-data.jl <alpaca-data-dir> <through YYYY-MM-DD>
#
# <alpaca-data-dir> holds the live capture folders `options-MM-DD-YY/`, one
# `<TICKER>_dte_ladder_<UTC stamp>.csv` per ticker per session. The builder
#   - reads only the live `options-MM-DD-YY/` folders; `options-partial/`
#     (historical backfill with no quotes, IV, or Greeks) is skipped,
#   - keys each capture by the underlying session date `und_session_date`, not
#     by the folder name (some captures ran after midnight UTC or the next day),
#     and keeps sessions on or before <through>,
#   - keeps the latest capture when a folder holds two for one ticker
#     (2026-08-21 has an extra 14:43 UTC intraday pull),
#   - writes one gzipped chain panel per ticker, with the repeated underlying
#     columns factored out into `underlying.csv`. The underlying bars come from
#     Alpaca's IEX feed, so `volume` and `vwap` are renamed `iex_volume` and
#     `iex_vwap`; `dte` is recounted from the session date; no quote, IV, or
#     Greek value is modified,
#   - copies code/src/data/options/EOD-OPTIONS-DATA.md in as the archive README,
#     creates the artifact, writes artifacts/options-eod-<through>.tar.gz, and
#     binds it in code/Artifacts.toml to the download URL of the GitHub release
#     `data-options-eod-<through>`.
# Upload the tarball to that release (and publish it) before students need it.

using CSV, DataFrames, Dates
using Pkg.Artifacts

const SRC = ARGS[1]
const THROUGH = Date(ARGS[2])
const ROOT = normpath(joinpath(@__DIR__, ".."))
const TAG = "data-options-eod-$(THROUGH)"
const TARBALL = "options-eod-$(THROUGH).tar.gz"
const URL = "https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/releases/download/$(TAG)/$(TARBALL)"

const FLOAT_COLS = [:bid, :bid_size, :ask, :ask_size, :mid, :last_price, :last_size,
                    :implied_vol, :delta, :gamma, :theta, :vega, :rho]
const CHAIN_COLS = [:date, :expiration, :dte, :target_dte, :type, :strike,
                    :bid, :ask, :mid, :bid_size, :ask_size, :last_price, :last_size,
                    :implied_vol, :delta, :gamma, :theta, :vega, :rho]

folders = sort(filter(d -> occursin(r"^options-\d\d-\d\d-\d\d$", d), readdir(SRC)))
captures = Dict{String,Vector{String}}()   # ticker => capture files, one per folder
for d in folders
    files = filter(f -> occursin(r"^[A-Z.]+_dte_ladder_\d{8}_\d{6}\.csv$", f), readdir(joinpath(SRC, d)))
    byticker = Dict{String,Vector{String}}()
    for f in files
        push!(get!(byticker, split(f, "_dte_ladder_")[1], String[]), f)
    end
    for (tk, fs) in byticker
        push!(get!(captures, tk, String[]), joinpath(SRC, d, last(sort(fs))))
    end
end

staging = mktempdir()
underlying = DataFrame()
for tk in sort(collect(keys(captures)))
    parts = DataFrame[]
    for path in captures[tk]
        df = CSV.read(path, DataFrame; types = Dict(c => Union{Missing,Float64} for c in FLOAT_COLS))
        nrow(df) == 0 && continue
        length(unique(df.und_session_date)) == 1 || error("$(path): more than one session date")
        first(df.und_session_date) <= THROUGH && push!(parts, df)
    end
    raw = vcat(parts...)
    issubset(unique(raw.underlying), [tk]) || error("$(tk): unexpected underlying symbol")

    # one underlying row per session; the latest capture wins when two folders hold the same session
    und = combine(groupby(raw, :und_session_date), :capture_ts => maximum => :capture_ts)
    und = innerjoin(und, unique(raw[:, [:und_session_date, :capture_ts, :und_open, :und_high,
        :und_low, :und_close, :und_volume, :und_vwap]]), on = [:und_session_date, :capture_ts])
    nrow(und) == length(unique(raw.und_session_date)) || error("$(tk): ambiguous underlying rows")
    raw = semijoin(raw, und[:, [:und_session_date, :capture_ts]], on = [:und_session_date, :capture_ts])

    # the source counts days to expiration from the capture day, which is the next trading
    # morning for the 2026-04-23 and 2026-05-01 sessions, so recount from the session -
    chain = rename(raw, :und_session_date => :date, :actual_dte => :dte)[:, CHAIN_COLS]
    chain.dte = Dates.value.(chain.expiration .- chain.date)
    any(nonunique(chain, [:date, :expiration, :type, :strike])) && error("$(tk): duplicate contracts")
    sort!(chain, [:date, :expiration, :type, :strike])
    path = joinpath(staging, "$(tk).csv")
    CSV.write(path, chain)
    run(`gzip -9 -n -f $(path)`)

    und = rename(und, :und_session_date => :date, :und_open => :open, :und_high => :high,
        :und_low => :low, :und_close => :close, :und_volume => :iex_volume, :und_vwap => :iex_vwap)
    insertcols!(und, 1, :ticker => tk)
    append!(underlying, und)
    println(rpad(tk, 6), lpad(nrow(chain), 8), " contracts  ", lpad(nrow(und), 4), " sessions  ",
        minimum(und.date), " to ", maximum(und.date))
end
sort!(underlying, [:ticker, :date])
CSV.write(joinpath(staging, "underlying.csv"), underlying)
cp(joinpath(ROOT, "code", "src", "data", "options", "EOD-OPTIONS-DATA.md"), joinpath(staging, "README.md"))

# create the artifact in the local depot, archive it, and bind the release URL -
tree = create_artifact(dir -> foreach(f -> cp(joinpath(staging, f), joinpath(dir, f)), readdir(staging)))
mkpath(joinpath(ROOT, "artifacts"))
tarball = joinpath(ROOT, "artifacts", TARBALL)
sha = archive_artifact(tree, tarball)
bind_artifact!(joinpath(ROOT, "code", "Artifacts.toml"), "options_eod", tree;
    download_info = [(URL, sha)], lazy = true, force = true)
println("\nrows: ", sum(nrow(CSV.read(joinpath(staging, f), DataFrame)) for f in readdir(staging) if endswith(f, ".csv.gz")),
    "\ngit-tree-sha1: ", bytes2hex(tree.bytes), "\ntarball: ", tarball, " (", round(filesize(tarball) / 1e6, digits = 1),
    " MB)\nsha256: ", sha, "\nrelease tag: ", TAG)
