## -- PRIVATE FUNCTIONS BELOW HERE ------------------------------------------------------------------------------ #
"""
    _jld2(path::String) -> Dict{String, Any}

Internal helper to load a JLD2 file located at `path` and return its contents.
"""
function _jld2(path::String)::Dict{String,Any}
    return load(path);
end
# -- PRIVATE FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #

# -- PUBLIC FUNCTIONS BELOW HERE ------------------------------------------------------------------------------- #

"""
    MyTestingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2025, to the current date (it is updated periodically).

"""
MyTestingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2025-to-11-18-2025.jld2"));

"""
    MyTrainingMarketDataSet() -> Dict{String, DataFrame}

Load the components of the SP500 Daily open, high, low, close (OHLC) dataset as a dictionary of DataFrames.
This data was provided by [Polygon.io](https://polygon.io/) and covers the period from January 3, 2014, to December 31, 2024.

"""
MyTrainingMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2"));

"""
    MyTickerPickerBanditModelResults() -> Dict{String, Any}

Load the ticker-picker bandit model results computed in the `Setup-L14a-Example-RiskAware-BBBP-Ticker-Picker-Fall-2025.ipynb` notebook.

### Arguments
- `mood::Symbol = :neutral`: Which preference set to load. Accepts `:optimistic`, `:neutral`, or `:pessimistic`.

### Returns
- `Dict{String, Any}`: Model results keyed by ticker for the requested mood.
"""
function MyTickerPickerBanditModelResults(;mood::Symbol = :neutral)::Dict{String, Any}
    if (mood == :optimistic) 
        return _jld2(joinpath(_PATH_TO_DATA, "Ticker-Picker-Preferences-Optimistic-Fall-2025.jld2"));
    elseif (mood == :pessimistic)
        return _jld2(joinpath(_PATH_TO_DATA, "Ticker-Picker-Preferences-Pessimistic-Fall-2025.jld2"));
    elseif (mood == :neutral)
        return _jld2(joinpath(_PATH_TO_DATA, "Ticker-Picker-Preferences-Neutral-Fall-2025.jld2"));
    else
        error("Invalid mood specified: $mood. Valid options are :optimistic, :neutral, :pessimistic.");
    end
end
# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------ #
