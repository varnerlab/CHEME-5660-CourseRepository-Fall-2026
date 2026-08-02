
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

"""
    function log_growth_matrix(dataset::Dict{String, DataFrame}, 
                firm::String; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0) -> Array{Float64,1}

The `log_growth_matrix` function computes the excess log growth matrix for a given firm where we define the log growth as:

```math
    \\mu_{t,t-1}(r_{f}) = \\frac{1}{\\Delta t} \\log\\left(\\frac{S_{t}}{S_{t-1}}\\right) - r_f
```

where ``S_t`` is the volume weighted average price (units: USD/share) at time `t`, ``\\Delta t`` is the time increment (in years), and ``r_f`` is the annual risk-free rate (units: 1/years) assuming
continuous compounding.

### Arguments
- `dataset::Dict{String, DataFrame}`: A dictionary of data frames where the keys are the firm ticker symbols and the values are the data frames holding price data. We use the `volume_weighted_average_price` column to compute the log growth by default.
- `firm::String`: The firm ticker symbol for which we want to compute the log growth matrix.
- `Δt::Float64`: The time increment used to compute the log growth. The default value is `1/252`, i.e., one trading day in units of years.
- `risk_free_rate::Float64`: The risk-free rate used to compute the log growth. The default value is `0.0`.
- `keycol::Symbol`: The column in the data frame to use to compute the log growth. The default value is `:volume_weighted_average_price`.

### Returns
- `Array{Float64,1}`: An array of the excess log growth values for the given firm.

### See:
* The `DataFrame` type (and methods for working with data frames) is exported from the [DataFrames.jl package](https://dataframes.juliadata.org/stable/)
"""
function log_growth_matrix(dataset::Dict{String, DataFrame}, 
    firm::String; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0, 
    keycol::Symbol = :volume_weighted_average_price)::Array{Float64,1}

    # initialize -
    number_of_trading_days = nrow(dataset["AAPL"]);
    return_matrix = Array{Float64,1}(undef, number_of_trading_days-1);

    # get the firm data -
    firm_data = dataset[firm];

    # compute the log returns -
    for j ∈ 2:number_of_trading_days
        S₁ = firm_data[j-1, keycol];
        S₂ = firm_data[j, keycol];
        return_matrix[j-1] = (1/Δt)*log(S₂/S₁) - risk_free_rate;
    end

    # return -
    return return_matrix;
end

"""
    function log_growth_matrix(dataset::DataFrame; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0,
                keycol::Symbol = :volume_weighted_average_price) -> Array{Float64,1}

Compute the log growth matrix for a given data frame. 
"""
function log_growth_matrix(dataset::DataFrame; 
    Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0,
    keycol::Symbol = :volume_weighted_average_price)::Array{Float64,1}

    # initialize -
    firm_data = dropmissing(dataset, disallowmissing=true)
    number_of_trading_periods = nrow(firm_data);
    return_matrix = Array{Float64,1}(undef, number_of_trading_periods - 1);

    # compute the log returns -
    for j ∈ 2:number_of_trading_periods
        S₁ = firm_data[j-1, keycol];
        S₂ = firm_data[j, keycol];
        return_matrix[j-1] = (1/Δt)*log(S₂/S₁) - risk_free_rate;
    end

    # return -
    return return_matrix;
end

"""
    function log_growth_matrix(dataset::Array{Float64,1}, 
                Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0)::Array{Float64,1}
"""
function log_growth_matrix(dataset::Array{Float64,1}; 
    Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0)::Array{Float64,1}

    # initialize -
    number_of_trading_periods = length(dataset);
    return_matrix = Array{Float64,1}(undef, number_of_trading_periods-1);

    # get the firm data -
    firm_data = dataset;

    # compute the log returns -
    for j ∈ 2:number_of_trading_periods
        S₁ = firm_data[j-1, 1];
        S₂ = firm_data[j, 1];
        return_matrix[j-1] = (1/Δt)*log(S₂/S₁) - risk_free_rate;
    end

    # return -
    return return_matrix;
end

"""
    function typicalprice(data::DataFrame) -> Array{Float64,1}

The `typicalprice` function computes the typical price (h+l+c)/3 for a given time frame. 

### Arguments
- `data::DataFrame`: A data frame holding the price data. To compute the VWAP, we use the `volume` and `open` and `close` price fields.

### Returns
- `Array{Float64,1}`: An array of the typical values for the given time frame.
"""
function typicalprice(data::DataFrame)::Array{Float64,1}

    # initialize -
    number_of_trading_periods = nrow(data);
    pricearray = Array{Float64,1}(undef, number_of_trading_periods);

    # compute the VWAP -
    for i ∈ 1:number_of_trading_periods
        
        # grab data from this data frame
        low = data[i, :low]; # low price during the period i
        high = data[i, :high]; # high price during the period i
        close = data[i, :close]; # closing price during the period i

        # compute the typical price -
        pricearray[i] = (low + high + close)/3;
    end

    # return -
    return pricearray;
end


# --- Discounting functions --------------------------------------------------------------------------- #

function _discount(model::DiscreteCompoundingModel, rate::Float64, periods::Int, λ::Int64)::Dict{Int,Float64}

    # initialize -
    discount = Dict{Int,Float64}()
    Δ = 1/λ; # internal timescale

    for i ∈ 0:periods
        discount[i] = (1+rate/λ)^(i);
    end

    # return -
    return discount;
end

function _discount(model::ContinuousCompoundingModel, rate::Float64, periods::Int, λ::Int64)::Dict{Int,Float64}

    # initialize -
    discount = Dict{Int,Float64}()  
    rᵢ = rate;
    Δ = 1/λ; # internal timescale
    
    # main loop -
    for i ∈ 0:periods

        # update the internal timescale -
        τ = (i)*Δ;

        # compute the discount factor -
        discount[i] = exp(τ*rᵢ);
    end

    # return -
    return discount;
end

"""
    function discount(model::AbstractCompoundingModel, rate::Float64, periods::Int; λ::Int64 = 2)::Dict{Int,Float64}

The `discount` function computes the discount factors for a given compounding model. We assume that the discount rate is constant over all periods.

### Arguments
- `model::AbstractCompoundingModel`: The compounding model to use to compute the discount factors. The model can be an instance of either a `DiscreteCompoundingModel` or a `ContinuousCompoundingModel`.
- `rate::Float64`: The annual discount rate used to compute the discount factors.
- `periods::Int`: The number of periods for which to compute the discount factors.
- `λ::Int64`: The number of compounding events per year. The default value is `2`.

### Returns
- `Dict{Int,Float64}`: A dictionary of the discount factors for the given compounding model. The keys are the period indexes and the values are the discount factors for 0 to `periods`.

"""
function discount(model::AbstractCompoundingModel, rate::Float64, periods::Int; 
    λ::Int64 = 2)::Dict{Int,Float64}
    
    return _discount(model, rate, periods, λ);
end

# ----------------------------------------------------------------------------------------------------- #