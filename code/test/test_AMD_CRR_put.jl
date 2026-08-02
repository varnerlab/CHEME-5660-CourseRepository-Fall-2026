using VLQuantitativeFinancePackage

# build an a put contract -
Δt, Sₒ, r̄, IV = (1.0/365), 117.50, 0.0418, 0.5175;
DTE = 31.0*Δt;
K = 110.0;

# build the model -
american_put_contract_model = build(MyAmericanPutContractModel, (
        K = K, IV = IV, DTE = DTE, sense = 1));

# build the tree -
random_test_model = build(MyAdjacencyBasedCRREquityPriceTree, (
    σ = IV, μ = r̄, T = DTE)) |> (x-> populate(x, Sₒ = Sₒ, h = 200));

# random_test_model = build(MyAdjacencyBasedCRREquityPriceTree, μ = r̄, h = 365, 
#     T = DTE, σ = IV, Sₒ = Sₒ)

# compute the premium -
price_value = premium(american_put_contract_model, random_test_model);