
## -- PRIVATE FUNCTIONS BELOW HERE ------------------------------------------------------------------------------ #
function _jld2(path::String)::Dict{String,Any}
    return load(path);
end
# -- PRIVATE FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #

# -- PUBLIC FUNCTIONS BELOW HERE ------------------------------------------------------------------------------- #

"""
    MyTrainingMarketDataSet() -> Dict{String,Any}

Load the SP500 daily open, high, low, close (OHLC) training dataset. The returned
dictionary contains a `"dataset"` entry whose value is a ticker-keyed dictionary
of `DataFrame` objects.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2014, to December 31, 2024.

"""
MyTrainingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2"));

"""
    MyTestingMarketDataSet() -> Dict{String,Any}

Load the SP500 daily OHLC testing dataset. The returned dictionary contains a
`"dataset"` entry whose value is a ticker-keyed dictionary of `DataFrame`
objects.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2025, to the current date (it is updated periodically).

"""
MyTestingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-2-2025-to-12-31-2025.jld2"));

"""
    MyOptionsChainDataSet(ticker::String) -> NamedTuple

Load the options chain dataset for the specified ticker symbol as a NamedTuple.

### Arguments
- `ticker::String`: The ticker symbol for which to load the options chain data (e.g., "amd" for AMD). Defaults to "amd".

### Returns
- `NamedTuple`: A NamedTuple containing two fields:
    - `metadata::Dict{String, Any}`: A dictionary containing metadata about the options chain.
    - `data::DataFrame`: A DataFrame containing the options chain data.

The metadata field has the keys:
- `DTE::String`
- `underlying_share_price_mid::String`
- `underlying_share_price_bid::String`
- `underlying_share_price_ask::String`
- `expiration_date::String`
- `purchase_date::String`
- `is_weekly::Bool`
- `atm_IV::String`
- `historical_volatility::String`
- `source::String`
"""
function  MyOptionsChainDataSet(; ticker::String = "amd")::NamedTuple

    # Set the path the metadata file, load the metadata -
    metadata_path = joinpath(_PATH_TO_OPTIONS_DATA, "$(ticker).toml");
    metadata = TOML.parsefile(metadata_path)["metadata"];

    # load the raw data file -
    path_to_data_file = joinpath(_PATH_TO_OPTIONS_DATA, "$(ticker).csv");
    data = CSV.File(path_to_data_file) |> DataFrame;

    # return the combined dataset as a NamedTuple -
    return (metadata=metadata, data=data);
end

# --- Adaptive portfolio teaching data -----------------------------------------

const _PATH_TO_ADAPTIVE_PORTFOLIO_DATA = joinpath(_PATH_TO_DATA, "adaptive_portfolio")

"""Load the frozen 2014–2024 Single Index Model calibration used by the adaptive-portfolio examples."""
MySIMCalibration() = _jld2(joinpath(_PATH_TO_ADAPTIVE_PORTFOLIO_DATA, "sim-calibration.jld2"))

"""Load the frozen price snapshot paired with [`MySIMCalibration`](@ref)."""
MyCurrentPrices() = _jld2(joinpath(_PATH_TO_ADAPTIVE_PORTFOLIO_DATA, "current-prices.jld2"))

"""
    MyAdaptivePortfolioCourseData(name::Symbol)

Load one of the compact, frozen eCornell-derived teaching artifacts vendored with
the package. Valid names are `:engine_run`, `:scorecard`, `:ewls_replay`,
`:compliance`, `:daily_bars`, and `:daily_tape`.
"""
function MyAdaptivePortfolioCourseData(name::Symbol)::Dict{String,Any}
    filenames = Dict(
        :engine_run => "engine-run-data.jld2",
        :scorecard => "session2-scorecard.jld2",
        :ewls_replay => "ewls-replay-results.jld2",
        :compliance => "compliance-config.jld2",
        :daily_bars => "daily-baseline-bars.jld2",
        :daily_tape => "daily-baseline-tape.jld2",
    )
    haskey(filenames, name) || throw(ArgumentError("unknown adaptive portfolio dataset: $(name)"))
    path = joinpath(_PATH_TO_ADAPTIVE_PORTFOLIO_DATA, filenames[name])
    if name == :engine_run
        # `context` was serialized with the short course's package-specific type.
        # Its inputs are duplicated as portable arrays and dictionaries in this file.
        return jldopen(path, "r") do file
            Dict{String,Any}(key => file[key] for key in keys(file) if key != "context")
        end
    end
    return _jld2(path)
end


# --- U.S. Treasury auction results --------------------------------------------

# Parse the mm/dd/yyyy auction dates the TreasuryDirect export uses, then keep the
# rows falling inside the requested window. The returned frame keeps its original
# String columns, so callers can still parse dates themselves.
function _filter_auction_window(data::DataFrame, from::Union{Nothing,Date}, to::Union{Nothing,Date})::DataFrame

    (isnothing(from) && isnothing(to)) && return data;

    auction = Date.(data[!, Symbol("Auction Date")], dateformat"mm/dd/yyyy");
    keep = trues(nrow(data));
    isnothing(from) == false && (keep .&= auction .>= from);
    isnothing(to) == false && (keep .&= auction .<= to);

    return data[keep, :];
end

"""
    MyTreasuryBillDataSet(; from, to, terms, cmb) -> DataFrame

Load U.S. Treasury bill auction results, newest auction first. The data was
downloaded from [TreasuryDirect](https://www.treasurydirect.gov/) and covers
auctions from October 2022 to the present.

Columns are `CUSIP`, `Security Type`, `Security Term`, `Auction Date`,
`Issue Date`, `Maturity Date`, `Price` (per 100 USD of face value) and
`Investment Rate` (a decimal, so 0.04318 is 4.318%). The three date columns are
strings in `mm/dd/yyyy` form.

### Arguments
- `from::Union{Nothing,Date}`: keep auctions on or after this date. Defaults to `nothing`, i.e. no lower bound.
- `to::Union{Nothing,Date}`: keep auctions on or before this date. Defaults to `nothing`, i.e. no upper bound.
- `terms::Union{Nothing,Vector{String}}`: keep only these security terms, e.g. `["4-Week", "52-Week"]`. Defaults to `nothing`, i.e. every term.
- `cmb::Bool`: include cash-management bills, whose terms are quoted in days rather than weeks. Defaults to `false`.

### Returns
- `DataFrame`: the matching auction records, sorted newest auction first.

Cash-management bills are irregular, one-off issues, some maturing in a single
day, so they are excluded unless `cmb = true`.
"""
function MyTreasuryBillDataSet(; from::Union{Nothing,Date} = nothing, to::Union{Nothing,Date} = nothing,
    terms::Union{Nothing,Vector{String}} = nothing, cmb::Bool = false)::DataFrame

    data = CSV.read(joinpath(_PATH_TO_TREASURY_DATA, "US-TBill-Prices-TD.csv"), DataFrame);

    # cash-management bills carry a day-denominated term, e.g. "42-Day" -
    cmb == false && (data = data[endswith.(data[!, Symbol("Security Term")], "-Week"), :]);
    isnothing(terms) == false && (data = data[in.(data[!, Symbol("Security Term")], Ref(terms)), :]);

    return _filter_auction_window(data, from, to);
end

"""
    MyTreasuryNotesAndBondsDataSet(; from, to, terms, types) -> DataFrame

Load U.S. Treasury note and bond auction results, newest auction first. The data
was downloaded from [TreasuryDirect](https://www.treasurydirect.gov/) and covers
auctions from October 2022 to the present. Inflation-protected securities are
included; TreasuryDirect reports them with a `Security Type` of `Note`, and their
`High Yield` is a real yield rather than a nominal one.

Columns are `CUSIP`, `Security Type`, `Security Term`, `Auction Date`,
`Issue Date`, `Maturity Date`, `Price` (per 100 USD of face value), `High Yield`
and `Interest Rate` (the annual coupon rate). The two rate columns are decimals,
so 0.041250 is 4.125%. The three date columns are strings in `mm/dd/yyyy` form.

### Arguments
- `from::Union{Nothing,Date}`: keep auctions on or after this date. Defaults to `nothing`, i.e. no lower bound.
- `to::Union{Nothing,Date}`: keep auctions on or before this date. Defaults to `nothing`, i.e. no upper bound.
- `terms::Union{Nothing,Vector{String}}`: keep only these security terms, e.g. `["10-Year", "30-Year"]`. Defaults to `nothing`, i.e. every term.
- `types::Union{Nothing,Vector{String}}`: keep only these security types, i.e. `["Note"]` or `["Bond"]`. Defaults to `nothing`, i.e. both.
- `reopenings::Bool`: include reopenings, i.e. additional auctions of an existing security. Defaults to `false`.

### Returns
- `DataFrame`: the matching auction records, sorted newest auction first.

A reopening sells more of a security that already exists, so it carries that
security's original coupon and a fractional remaining term such as
`"9-Year 10-Month"`. Once the coupon no longer matches the prevailing yield, a
reopening clears well away from par: over 2022-2023 the original issues priced
between 97.92 and 100.00, while the reopenings ran from 83.74 to 108.97.
Malkiel's theorems are stated for bonds compared at par, so reopenings are
excluded unless `reopenings = true`.
"""
function MyTreasuryNotesAndBondsDataSet(; from::Union{Nothing,Date} = nothing, to::Union{Nothing,Date} = nothing,
    terms::Union{Nothing,Vector{String}} = nothing, types::Union{Nothing,Vector{String}} = nothing,
    reopenings::Bool = false)::DataFrame

    data = CSV.read(joinpath(_PATH_TO_TREASURY_DATA, "US-TNotesBonds-Prices-TD.csv"), DataFrame);

    # an original issue carries a whole-year term, e.g. "10-Year"; a reopening
    # carries the remaining term, e.g. "9-Year 10-Month" -
    reopenings == false && (data = data[occursin.(r"^\d+-Year$", data[!, Symbol("Security Term")]), :]);
    isnothing(types) == false && (data = data[in.(data[!, Symbol("Security Type")], Ref(types)), :]);
    isnothing(terms) == false && (data = data[in.(data[!, Symbol("Security Term")], Ref(terms)), :]);

    return _filter_auction_window(data, from, to);
end


"""
    MyTreasurySTRIPSDataSet() -> DataFrame

Load the Treasury STRIPS quotes for September 10, 2025, downloaded from
[TreasuryDirect](https://www.treasurydirect.gov/marketable-securities/strips/).

Columns are `CUSIP`, `Maturity`, `Coupon`, `YTM_bid`, `YTM_ask`, `Price_bid` and
`Price_ask`. The two yield columns are quoted in percent, so 3.951 is 3.951%,
while the price columns are per 100 USD of face value.

### Returns
- `DataFrame`: one row per STRIPS issue.
"""
MyTreasurySTRIPSDataSet() = CSV.read(joinpath(_PATH_TO_TREASURY_DATA, "US-Treasury-STRIPS-Prices-TD-09-10-25.csv"), DataFrame);

"""
    MyTreasuryParYieldCurveDataSet(; year, ascending) -> DataFrame

Load the daily Treasury par yield curve rates for a calendar year, published by the
[U.S. Treasury](https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics).

The `Date` column is a `mm/dd/yyyy` string; the remaining columns hold the par
yield at a quoted maturity, named `"1 Mo"` through `"30 Yr"`, in percent. Which
maturities are published changes over time, so the column set varies by year.

### Arguments
- `year::Int`: the calendar year to load, from 2020 through 2025. Defaults to 2025.
- `ascending::Bool`: return the rows in date-ascending order. Defaults to `true`; the published file is date-descending.

### Returns
- `DataFrame`: one row per business day.
"""
function MyTreasuryParYieldCurveDataSet(; year::Int = 2025, ascending::Bool = true)::DataFrame

    path = joinpath(_PATH_TO_TREASURY_DATA, "UST-Daily-ParYieldCurveRates-$(year).csv");
    isfile(path) || throw(ArgumentError("no par yield curve data for $(year); 2020 through 2025 are available"));

    data = CSV.read(path, DataFrame);
    return ascending ? reverse(data) : data;
end

"""
    MyTreasuryBillRatesDataSet(; year, ascending) -> DataFrame

Load the daily Treasury bill rates for a calendar year, published by the
[U.S. Treasury](https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics).

Each term carries two columns, a bank-discount rate and a coupon-equivalent rate,
e.g. `"13 WEEKS BANK DISCOUNT"` and `"13 WEEKS COUPON EQUIVALENT"`, both in
percent. The two conventions are not interchangeable.

### Arguments
- `year::Int`: the calendar year to load. Only 2024 is currently vendored. Defaults to 2024.
- `ascending::Bool`: return the rows in date-ascending order. Defaults to `true`.

### Returns
- `DataFrame`: one row per business day.
"""
function MyTreasuryBillRatesDataSet(; year::Int = 2024, ascending::Bool = true)::DataFrame

    path = joinpath(_PATH_TO_TREASURY_DATA, "UST-Daily-TBill-Rates-$(year).csv");
    isfile(path) || throw(ArgumentError("no Treasury bill rate data for $(year); only 2024 is available"));

    data = CSV.read(path, DataFrame);
    return ascending ? reverse(data) : data;
end

# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #
