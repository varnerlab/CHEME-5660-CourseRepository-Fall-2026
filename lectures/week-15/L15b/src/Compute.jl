"""
    function log_growth_matrix(dataset::Dict{String, DataFrame}, 
                firms::Array{String,1}; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0) -> Array{Float64,2}

The `log_growth_matrix` function computes the excess log growth matrix for a given set of firms where we define the log growth as:

```math
    \\mu_{t,t-1}(r_{f}) = \\frac{1}{\\Delta t} \\log\\left(\\frac{S_{t}}{S_{t-1}}\\right) - r_f
```

where ``S_t`` is the volume weighted average price (units: USD/share) at time `t`, ``\\Delta t`` is the time increment (in years), and ``r_f`` is the annual risk-free rate (units: 1/years) assuming
continuous compounding.

### Arguments
- `dataset::Dict{String, DataFrame}`: A dictionary of data frames where the keys are the firm ticker symbols and the values are the data frames holding price data. We use the `volume_weighted_average_price` column to compute the log growth by default.
- `firms::Array{String,1}`: An array of firm ticker symbols for which we want to compute the log growth matrix.
- `Δt::Float64`: The time increment used to compute the log growth. The default value is `1/252`, i.e., one trading day in units of years.
- `risk_free_rate::Float64`: The risk-free rate used to compute the log growth. The default value is `0.0`.
- `keycol::Symbol`: The column in the data frame to use to compute the log growth. The default value is `:volume_weighted_average_price`.
- `testfirm::String`: The firm ticker symbol to use to determine the number of trading days. By default, we use "AAPL".

### Returns
- `Array{Float64,2}`: An array of the excess log growth values for the given set of firms. The time series is the rows and the firms are the columns. The columns are ordered according to the order of the `firms` array.

### See:
* The `DataFrame` type (and methods for working with data frames) is exported from the [DataFrames.jl package](https://dataframes.juliadata.org/stable/)
"""
function log_growth_matrix(dataset::Dict{String, DataFrame}, 
    firms::Array{String,1}; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0, 
    testfirm="AAPL", keycol::Symbol = :volume_weighted_average_price)::Array{Float64,2}

    # initialize -
    number_of_firms = length(firms);
    number_of_trading_days = nrow(dataset[testfirm]);
    return_matrix = Array{Float64,2}(undef, number_of_trading_days-1, number_of_firms);

    # main loop -
    for i ∈ eachindex(firms) 

        # get the firm data -
        firm_index = firms[i];
        firm_data = dataset[firm_index];

        # compute the log returns -
        for j ∈ 2:number_of_trading_days
            S₁ = firm_data[j-1, keycol];
            S₂ = firm_data[j, keycol];
            return_matrix[j-1, i] = (1/Δt)*(log(S₂/S₁)) - risk_free_rate;
        end
    end

    # return -
    return return_matrix;
end