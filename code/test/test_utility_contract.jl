using VLQuantitativeFinancePackage

# build an a put contract -
Δt, Sₒ, r̄, IV = (1.0/365.0), 117.50, 0.0418, 0.5175;
DTE = 31.0*Δt;
K = 110.0;

# from data -
# p̄, ū, d̄ = 0.5330677290836653,1.0221591439529478,0.9785408557277263
p̄, ū, d̄ = 0.49864256260778633,1.0079252620171597,0.9921370538909811

# build the model -
american_put_contract_model = build(MyAmericanPutContractModel, (
        K = K, IV = IV, DTE = DTE, sense = 1));

# build the tree -
random_test_model = build(MyBinomialEquityPriceTree, (
    u = ū, d = d̄, p = p̄, T = DTE, μ = r̄)) |> (x-> populate(x, Sₒ = Sₒ, h = 365));

# compute the premium -
price_value = premium(american_put_contract_model, random_test_model);

   