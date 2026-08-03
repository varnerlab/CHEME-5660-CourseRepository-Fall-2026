# ---- PRIVATE FUNCTIONS BELOW HERE ------------------------------------------------------------------------------- #
function _sample_sim_model(model::MySingleIndexModel, Rₘ::Array{Float64,1}; 
    number_of_paths::Int64 = 100)::Array{Float64,2}

    # compute the model estimate of the excess retrurn for firm i -
    α = model.α
    β = model.β
    ϵ = model.ϵ

    # how many time samples do we have?
    N = length(Rₘ)

    # initialize some storage -
    X = Array{Float64,2}(undef, N, number_of_paths);

    for t ∈ 1:N
        for p ∈ 1:number_of_paths
            X[t,p] = α + β*Rₘ[t] + rand(ϵ)
        end
    end

    # return -
    return X
end


function _evaluate_expected_return_sim_model(model::MySingleIndexModel, Rₘ::Array{Float64,1})::Array{Float64,1}

    # compute the model estimate of the excess retrurn for firm i -
    α = model.α
    β = model.β

    # compute ex return -
    R̂ = α .+ β .* Rₘ

    # return -
    return R̂
end

function _extract_portfolio_expected_return(μ::Array{Float64,1}, tickers::Array{Int64,1})::Array{Float64,1}

    # initialize -
    μ̂ = Array{Float64,1}();

    # main loop -
    for firm_index ∈ tickers
        push!(μ̂, μ[firm_index])
    end

    # return -
    return μ̂;
end

function _extract_portfolio_covariance_matrix(Σ::Array{Float64,2}, tickers::Array{Int64,1})::Array{Float64,2}

   # initialize
    my_number_of_selected_firms = length(tickers)
    Σ̂ = Array{Float64,2}(undef, my_number_of_selected_firms, my_number_of_selected_firms);
    for i ∈ eachindex(tickers)
        row_firm_index = tickers[i]
        for j ∈ eachindex(tickers)
            col_firm_index = tickers[j]
            Σ̂[i,j] = Σ[row_firm_index, col_firm_index]
        end
    end

    # return -
    return Σ̂;
end
# ---- PRIVATE FUNCTIONS ABOVE HERE ------------------------------------------------------------------------------- #

# ---- PUBLIC FUNCTIONS BELOW HERE -------------------------------------------------------------------------------- #
(model::MySingleIndexModel)(Rₘ::Array{Float64,1}, paths::Int64)::Array{Float64,2} = _sample_sim_model(model, Rₘ, number_of_paths=paths);
(model::MySingleIndexModel)(Rₘ::Array{Float64,1})::Array{Float64,1} = _evaluate_expected_return_sim_model(model, Rₘ);
(μ::Array{Float64,1})(tickers::Array{Int64,1})::Array{Float64,1} = _extract_portfolio_expected_return(μ, tickers);
(Σ::Array{Float64,2})(tickers::Array{Int64,1})::Array{Float64,2} = _extract_portfolio_covariance_matrix(Σ, tickers);

function log_return_matrix(dataset::Dict{String, DataFrame}, 
    firms::Array{String,1}; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0)::Array{Float64,2}

    # initialize -
    number_of_firms = length(firms);
    number_of_trading_days = nrow(dataset["AAPL"]);
    return_matrix = Array{Float64,2}(undef, number_of_trading_days-1, number_of_firms);

    # main loop -
    for i ∈ eachindex(firms) 

        # get the firm data -
        firm_index = firms[i];
        firm_data = dataset[firm_index];

        # compute the log returns -
        for j ∈ 2:number_of_trading_days
            S₁ = firm_data[j-1, :volume_weighted_average_price];
            S₂ = firm_data[j, :volume_weighted_average_price];
            return_matrix[j-1, i] = (1/Δt)*log(S₂/S₁) - risk_free_rate;
        end
    end

    # return -
    return return_matrix;
end