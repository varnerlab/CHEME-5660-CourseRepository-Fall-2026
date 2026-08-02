
## -- PRIVATE FUNCTIONS BELOW HERE ------------------------------------------------------------------------------ #
function _jld2(path::String)::Dict{String,Any}
    return load(path);
end
# -- PRIVATE FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #

# -- PUBLIC FUNCTIONS BELOW HERE ------------------------------------------------------------------------------- #

"""
    MyTrainingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2014, to December 31, 2024.

"""
MyTrainingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2"));

"""
    MyTestingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
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

# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #