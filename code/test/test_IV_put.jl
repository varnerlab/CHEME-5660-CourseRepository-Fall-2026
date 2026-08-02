using VLQuantitativeFinancePackage

# parameters -
r̄ = 0.049; # risk free rate
Δt = (1/365); # step-size, assuming 365-trading days per year
T = 62*Δt; # duration of the contract (units: years)
IV = 0.4005; # implied volatility - we are estimating this
Sₒ = 79.50; # share price at contract purchase (units: USD/share)
K = 60.0; # strike price for the MU contract (units: USD/share)
h = 100; # number of levels in the binomial tree
𝒫 = 0.38; # contract premium


test_american_put_contract_model = build(MyAmericanPutContractModel, (
        K = K, sense = 1, copy = 1, DTE = T, IV = 0.0, premium = 𝒫));


tmp = Array{Float64,1}();
IV_initial_guess = range(0.1,stop=0.2,length=10) |> collect;
for guess ∈ IV_initial_guess
    test_american_put_contract_model.IV = guess;

    # compute the implied volatility -
    test_IV = estimate_implied_volatility(test_american_put_contract_model, Sₒ = Sₒ, h = h, r̄ = r̄)
    push!(tmp, test_IV)
end


# build contract


