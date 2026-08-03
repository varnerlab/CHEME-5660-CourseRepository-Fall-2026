function table(results::Matrix{Float64}, 
    algorithm::MyEpsilonGreedyAlgorithmModel,
    context::MyBanditPortfolioAllocationContextModel)::DataFrame

    # initialize
    df = DataFrame();
    K = algorithm.K; # number of arms
    n = algorithm.n; # number of rounds we played
    γ = context.γ; # user preference for each good

    # compute the best collection of goods -
    K = algorithm.K; # number of arms in the algorithm
    C = context.Sₒ; # cost of each good
    N = 2^K; # number of possible goods combinations (2^K) - this is the total number of combinations of goods we can have 

    μ = zeros(Float64, N); # average reward for each possible goods combination
    for a ∈ 1:N
        μ[a] = filter(x -> x != 0.0, results[:,a]) |> x-> mean(x)

        # fix NaN -
        if (isnan(μ[a]) == true)
            μ[a] = -Inf; # replace NaN with a big negative
        end
    end
    î = argmax(μ); # compute the arm with best average reward
    aₜ = digits(î, base=2, pad=K); # which goods do we select?

    # build the table -
    U = Array{Float64,1}(undef, K); # initialize the array to store the goods selected
    for i ∈ 1:K
       U[i] = aₜ[i]*(n[i]^γ[i]); # store the goods selected in the array
    end


    for i ∈ 1:K
        row_df = (
            good = i,
            purchase = aₜ[i] == 1 ? "Yes" : "No", # determine if the good is purchased or not
            cost = aₜ[i]*n[i]*C[i],
        );
        push!(df, row_df); # add the row to the dataframe
    end

    # return -
    return df; # return the dataframe
end