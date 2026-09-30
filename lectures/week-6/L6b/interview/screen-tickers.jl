# L6b client interview: screen the SIM archive for a client's ticker list.
#
# The screen is a rule, not a judgment. Within each GICS sector, it keeps the names
# whose fitted beta lies in the client's band and ranks them by the SIM's R², the
# fraction of their growth-rate variation the market explains. It never looks at
# mean growth, so a name cannot enter the list because it did well in 2014 to 2024.
#
# Usage, from any folder (the script finds the course environment itself):
#
#   julia screen-tickers.jl --band=defensive --exclude=fossil,defense --wf=0.25
#
# Options:
#   --band=defensive|market|aggressive  beta band: β < 0.8, 0.8 ≤ β < 1.2, or β ≥ 1.2
#   --exclude=group,group               fossil, tobacco-alcohol, defense, gambling
#   --exclude-sector=Sector,Sector      whole GICS sectors to remove, e.g. Utilities
#   --drop=T1,T2                        tickers to remove
#   --add=T1,T2                         tickers to keep even if the rule would not pick them
#   --per-sector=2                      names kept per sector
#   --wf=0.25                           client's risk-free fraction w_f (negative = borrowing)
#   --dry-run                           print the list without writing the files
#
# Writes, next to the SIM archive in ../data:
#   my-tickers.csv   ticker, sector, beta, r_squared (read by the RA and RRFA examples)
#   my-client.toml   the band, exclusions, rule, and w_f (w_f is read by the RRFA example)

# Activate the nearest course environment (repo root or unzipped bundle root) -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d; io = devnull);
end

using VLQuantitativeFinancePackage # market data and the S&P 500 sector table
using DataFrames                   # labeled tabular results
using CSV                          # write my-tickers.csv
using JLD2                         # SIM parameter-archive loading
using Statistics                   # median and mean of the betas
using Printf                       # aligned text output
using TOML                         # write my-client.toml
using Dates                        # date stamp for the client file

# The beta bands, lower bound inclusive and upper bound exclusive -
const BETA_BANDS = Dict(
    "defensive" => (0.0, 0.8),   # moves less than the market
    "market" => (0.8, 1.2),      # moves roughly with the market
    "aggressive" => (1.2, Inf)); # moves more than the market

# Exclusion groups, as GICS sectors or sub-industries -
const EXCLUSION_GROUPS = Dict(
    "fossil" => (sectors = ["Energy"], subindustries = String[]), # oil, gas, and coal
    "tobacco-alcohol" => (sectors = String[], subindustries = ["Tobacco", "Brewers", "Distillers & Vintners"]),
    "defense" => (sectors = String[], subindustries = ["Aerospace & Defense"]),
    "gambling" => (sectors = String[], subindustries = ["Casinos & Gaming"]));

"""
    complete_histories(original::Dict{String,DataFrame}) -> Dict{String,DataFrame}

Keep the tickers whose price table has as many rows as `AAPL`, the same dates, and
finite, positive VWAP prices. These are the checks the RA and RRFA examples make
before they build the growth-rate matrix, so every ticker the screen returns runs there.
"""
function complete_histories(original::Dict{String,DataFrame})::Dict{String,DataFrame}
    reference = original["AAPL"].timestamp; # AAPL has a full history
    kept = Dict{String,DataFrame}();
    for (ticker, data) ∈ original
        prices = data.volume_weighted_average_price; # VWAP (USD/share)
        if (nrow(data) == length(reference)) && (data.timestamp == reference) &&
                all(isfinite, prices) && all(>(0), prices)
            kept[ticker] = data;
        end
    end
    return kept;
end

"""
    screen_tickers(parameters, sectors, eligible; band, exclude, exclude_sectors,
        drop, add, per_sector) -> (DataFrame, DataFrame)

Apply the L6b interview rule. `parameters` is the SIM archive's ticker-keyed data,
`sectors` the table from `MySP500SectorDataSet()`, and `eligible` the set of tickers
with complete 2014 to 2024 and 2025 histories. A ticker qualifies if it is eligible,
has a current GICS sector, and is not excluded. Within each sector, the qualifying
names whose beta lies in `band` are ranked by R² (ties broken alphabetically), and
the first `per_sector` are kept. Tickers in `add` are then kept even if the rule did
not pick them.

Returns the chosen list, sorted by sector and R², and the table of every qualifying
ticker with its sector, sub-industry, beta, and R².
"""
function screen_tickers(parameters::Dict, sectors::DataFrame, eligible::Set{String};
        band::String, exclude::Vector{String} = String[], exclude_sectors::Vector{String} = String[],
        drop::Vector{String} = String[], add::Vector{String} = String[], per_sector::Int = 2)

    # Collect the excluded sectors and sub-industries -
    excluded_sectors = Set(exclude_sectors);
    excluded_subindustries = Set{String}();
    for group ∈ exclude
        haskey(EXCLUSION_GROUPS, group) || error("unknown exclusion group $(group); use one of $(join(sort(collect(keys(EXCLUSION_GROUPS))), ", "))")
        union!(excluded_sectors, EXCLUSION_GROUPS[group].sectors);
        union!(excluded_subindustries, EXCLUSION_GROUPS[group].subindustries);
    end

    # Look up each firm's sector. ETFs and firms no longer in the index have none -
    sector_of = Dict(String(row.Symbol) => (String(row[Symbol("GICS Sector")]),
        String(row[Symbol("GICS Sub-Industry")])) for row ∈ eachrow(sectors));

    # Build the table of qualifying tickers -
    table = DataFrame(ticker = String[], sector = String[], subindustry = String[],
        beta = Float64[], r_squared = Float64[]);
    for (ticker, p) ∈ parameters
        (ticker ∈ eligible) && haskey(sector_of, ticker) || continue # full histories and a sector
        (sector, subindustry) = sector_of[ticker];
        ((sector ∈ excluded_sectors) || (subindustry ∈ excluded_subindustries)) && continue
        (ticker ∈ drop) && continue
        push!(table, (ticker, sector, subindustry, p.beta, p.r_squared));
    end

    # Keep the top per_sector names by R² inside the band, one sector at a time -
    (β_low, β_high) = BETA_BANDS[band];
    sort!(table, [:sector, order(:r_squared, rev = true), :ticker]);
    chosen = similar(table, 0); # same columns, no rows
    for group ∈ groupby(table, :sector)
        in_band = filter(row -> β_low ≤ row.beta < β_high, group); # keeps the R² order
        append!(chosen, first(in_band, per_sector));
    end

    # Keep the added tickers even if the rule did not pick them -
    for ticker ∈ add
        (ticker ∈ chosen.ticker) && continue
        k = findfirst(==(ticker), table.ticker);
        isnothing(k) && error("$(ticker) is excluded, lacks full 2014 to 2025 histories, or has no current sector")
        push!(chosen, table[k, :]);
    end
    sort!(chosen, [:sector, order(:r_squared, rev = true)]);
    return (chosen, table);
end

"""
    parse_options(args::Vector{String}) -> Dict{String,String}

Read `--key=value` and `--flag` command-line options into a dictionary.
"""
function parse_options(args::Vector{String})::Dict{String,String}
    options = Dict{String,String}();
    for arg ∈ args
        startswith(arg, "--") || error("options look like --band=defensive, not $(arg)")
        key, value = occursin("=", arg) ? split(arg[3:end], "=", limit = 2) : (arg[3:end], "true");
        options[String(key)] = String(value);
    end
    return options;
end

# Comma-separated list option, empty if absent -
list_option(options, key) = haskey(options, key) ? String.(Base.strip.(split(options[key], ","))) : String[];

# Read the options -
options = parse_options(ARGS);
band = get(options, "band", "");
haskey(BETA_BANDS, band) || error("choose --band=defensive, --band=market, or --band=aggressive");
exclude = list_option(options, "exclude");
exclude_sectors = list_option(options, "exclude-sector");
drop = uppercase.(list_option(options, "drop"));
add = uppercase.(list_option(options, "add"));
per_sector = parse(Int, get(options, "per-sector", "2"));
w_f = parse(Float64, get(options, "wf", "0.0")); # risk-free fraction, negative = borrowing
dry_run = haskey(options, "dry-run");

# Load the SIM archive, the sector table, and both price datasets -
path_to_data = joinpath(@__DIR__, "..", "data");
archive = JLD2.load(joinpath(path_to_data, "SIMs-SP500-01-03-14-to-12-31-24.jld2"));
@assert archive["market_ticker"] == "SPY" # betas are measured against SPY
parameters = filter(p -> p.first != "SPY", archive["data"]); # SPY is the market, not a candidate
training = complete_histories(MyTrainingMarketDataSet()["dataset"]); # 2014 to 2024
testing = complete_histories(MyTestingMarketDataSet()["dataset"]); # 2025
eligible = intersect(Set(keys(training)), Set(keys(testing)));

# Apply the rule -
chosen, table = screen_tickers(parameters, MySP500SectorDataSet(), eligible; band = band,
    exclude = exclude, exclude_sectors = exclude_sectors, drop = drop, add = add, per_sector = per_sector);
nrow(chosen) ≥ 2 || error("fewer than two tickers survive the screen; loosen the exclusions")

# Report the list -
(β_low, β_high) = BETA_BANDS[band];
@printf("\nBand: %s (%.1f ≤ β < %s), top %d by R² per sector, from %d qualifying tickers\n\n",
    band, β_low, isinf(β_high) ? "∞" : @sprintf("%.1f", β_high), per_sector, nrow(table));
@printf("%-7s %-24s %-40s %6s %6s\n", "ticker", "sector", "sub-industry", "β", "R²");
for row ∈ eachrow(chosen)
    note = (β_low ≤ row.beta < β_high) ? "" : "  (added, outside the band)";
    @printf("%-7s %-24s %-40s %6.2f %6.2f%s\n", row.ticker, row.sector, first(row.subindustry, 40),
        row.beta, row.r_squared, note);
end
all_sectors = sort(unique(String.(MySP500SectorDataSet()[!, Symbol("GICS Sector")])));
missing_sectors = setdiff(all_sectors, unique(chosen.sector));
@printf("\n%d tickers, %d of %d sectors. Median β = %.2f, equal-weight portfolio β = %.2f, range %.2f to %.2f\n",
    nrow(chosen), length(unique(chosen.sector)), length(all_sectors), median(chosen.beta),
    mean(chosen.beta), minimum(chosen.beta), maximum(chosen.beta));
isempty(missing_sectors) || println("No names from: ", join(missing_sectors, ", "));
@printf("Client risk-free fraction w_f = %.2f (%s)\n", w_f,
    w_f > 0 ? "lend, hold T-bills" : (w_f < 0 ? "borrow" : "fully invested"));

# Write the two files the examples read -
if !dry_run
    CSV.write(joinpath(path_to_data, "my-tickers.csv"), chosen[:, [:ticker, :sector, :beta, :r_squared]]);
    client = Dict(
        "client" => Dict("band" => band, "beta_rule" => isinf(β_high) ? "beta >= $(β_low)" : "$(β_low) <= beta < $(β_high)",
            "exclude" => exclude, "exclude_sectors" => exclude_sectors, "drop" => drop, "add" => add,
            "risk_free_fraction" => w_f),
        "screen" => Dict("rule" => "top $(per_sector) SIM R² per GICS sector inside the beta band",
            "archive" => "SIMs-SP500-01-03-14-to-12-31-24.jld2", "created" => string(today())));
    open(joinpath(path_to_data, "my-client.toml"), "w") do io
        TOML.print(io, client);
    end
    println("\nWrote data/my-tickers.csv and data/my-client.toml")
end
