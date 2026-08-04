function _jld2(path::String)::Dict{String,Any}
    return load(path);
end

MyInSampleMarketDataSet() = _jld2(joinpath(_PATH_TO_DATA, "SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2"));