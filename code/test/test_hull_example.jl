using VLQuantitativeFinancePackage

Sₒ,T,u,d,p = 20.0,2,1.1,0.9,0.6523;

test_model = build(MyBinomialEquityPriceTree, (
        u = u, d = d, p = p)) |> (x-> populate(x, Sₒ = Sₒ, h = T));

hull_price_dictionary = Dict(0=>20.0, 1=>22.0,2=>18.0,3=>24.2,4=>19.8,5=>16.2);
number_of_nodes = length(test_model.data);
hull_test_data_table = Dict{Int64, NamedTuple}();
for i ∈ 0:(number_of_nodes-1)
    
    row_data = (
        index = i,
        hull_price = hull_price_dictionary[i],
        our_price = test_model.data[i].price, 
        isapproxequal = isapprox(hull_price_dictionary[i], test_model.data[i].price, rtol=1e-4)
    );
    
    #push!(hull_test_data_table, row_data)
    hull_test_data_table[i] = row_data;
end