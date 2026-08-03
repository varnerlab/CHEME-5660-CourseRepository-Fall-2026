function _build(modeltype::Type{T}, data::NamedTuple) where T <: AbstractSimpleChoiceProblem
    
    # build an empty model
    model = modeltype();

    # if we have options, add them to the contract model -
    if (isempty(data) == false)
        for key ∈ fieldnames(modeltype)
            
            # check the for the key - if we have it, then grab this value
            value = nothing
            if (haskey(data, key) == true)
                # get the value -
                value = data[key]
            end

            # set -
            setproperty!(model, key, value)
        end
    end
 
    # return -
    return model
end

# -- PUBLIC METHODS BELOW HERE ---------------------------------------------------------------------------------------- #

function build(modeltype::Type{MyEpsilonGreedyAlgorithmModel}, data::NamedTuple)

    # initialize -
    model = modeltype(); # build an empty model
    
    # get the data -    
    K = data.K; # number of arms
    α = data.α; # learning rate

    # add the data to the model -
    model.K = K;
    model.α = α;

    # return -
    return model;
end

function build(modeltype::Type{MyEpsilonGreedyStaticNoiseAlgorithmModel}, data::NamedTuple)

    # initialize -
    model = modeltype(); # build an empty model
    
    # get the data -    
    K = data.K; # number of arms
    α = data.α; # learning rate

    # add the data to the model -
    model.K = K;
    model.α = α;

    # return -
    return model;
end

function build(modeltype::Type{MyEpsilonGreedyDynamicNoiseAlgorithmModel}, data::NamedTuple)

    # initialize -
    model = modeltype(); # build an empty model
    
    # get the data -    
    K = data.K; # number of arms
    α = data.α; # learning rate

    # add the data to the model -
    model.K = K;
    model.α = α;

    # return -
    return model;
end

function build(modeltype::Type{MyDynamicBanditPortfolioAllocationContextModel}, data::NamedTuple)::MyDynamicBanditPortfolioAllocationContextModel

    # initialize -
    model = modeltype(); # build an empty model

    # get the data -
    bounds = data.bounds; # bounds on the assets that we can purchase
    B = data.B; # budget that we have to spend on the collection of assets
    nₒ = data.nₒ; # initial guess for the solution
    number_of_assets = length(nₒ);
    dataset = data.dataset; # dataset that we are using
    tickers = data.tickers; # tickers for each asset
    singleindexmodels = data.singleindexmodels; # single index models for each asset
    X̄ = data.X̄; # inv(X^T*X)*X^T
    number_of_samples_to_draw = data.number_of_samples_to_draw; # number of samples needed by the error model -
    μₒ = data.μₒ; # initial guess for the average returns from the different arms
    R̄ₘ = data.R̄ₘ; # average return of the market (to use in the SIM)

    # add the data to the model -
    model.bounds = bounds;
    model.B = B;
    model.nₒ = nₒ;
    model.number_of_assets = number_of_assets;
    model.dataset = dataset;
    model.tickers = tickers;
    model.singleindexmodels = singleindexmodels;
    model.X̄ = X̄;
    model.number_of_samples_to_draw = number_of_samples_to_draw;
    model.μₒ = μₒ; # initial guess for the average returns from the different arms
    model.R̄ₘ = R̄ₘ; # average return of the market (to use in the SIM)

    # return -
    return model;
end 

function build(modeltype::Type{MyBanditPortfolioAllocationContextModel}, data::NamedTuple)::MyBanditPortfolioAllocationContextModel

    # initialize -
    model = modeltype(); # build an empty model

    # get the data -
    γ = data.γ; # investors preference for each category of goods
    Sₒ = data.Sₒ; # share price at which we can purchase the asset
    bounds = data.bounds; # bounds on the assets that we can purchase
    B = data.B; # budget that we have to spend on the collection of assets
    nₒ = data.nₒ; # initial guess for the solution
    number_of_assets = length(Sₒ);

    # add the data to the model -
    model.γ = γ;
    model.Sₒ = Sₒ;
    model.bounds = bounds;
    model.B = B;
    model.nₒ = nₒ;
    model.number_of_assets = number_of_assets;


    # return -
    return model;
end


build(model::Type{MySimpleCobbDouglasChoiceProblem}, data::NamedTuple)::MySimpleCobbDouglasChoiceProblem = _build(model, data);
# --- PUBLIC METHODS ABOVE HERE --------------------------------------------------------------------------------------- #