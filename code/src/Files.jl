
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

# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #
