_𝔼(X::Array{Float64,1}, p::Array{Float64,1}) = sum(X.*p) # probability-weighted sum over aligned outcomes and weights

"""
    𝔼(model::MyBinomialEquityPriceTree; level::Int = 0) -> Float64

Compute the probability-weighted expected share price at one zero-based financial
tree level. The returned value has units of USD/share when node prices do.
"""
function 𝔼(model::MyBinomialEquityPriceTree; level::Int = 0)::Float64

    # Initialize node-level outcomes and probabilities -
    expected_value = 0.0;
    X = Array{Float64,1}(); # share-price outcomes on the requested level, USD/share
    p = Array{Float64,1}(); # probability mass aligned elementwise with X

    # Collect values from the model's level-to-node-index mapping -
    levels = model.levels; # dictionary keyed by financial level 0,1,...
    nodes_on_this_level = levels[level] # internal node identifiers at the requested level
    for i ∈ nodes_on_this_level # i is a node identifier, not a Julia array position

        # Get the node record -
        node = model.data[i]; # price and probability stored under node identifier i

        # Extract the aligned outcome and probability -
        x_value = node.price; # USD/share
        p_value = node.probability; # dimensionless probability mass

        # Store the aligned pair -
        push!(X,x_value); # append the node's share price
        push!(p,p_value); # append the same node's probability
    end

    # Compute the probability-weighted mean -
    expected_value = _𝔼(X,p) # USD/share

    # Return -
    return expected_value
end

"""
    𝔼(model::MyBinomialEquityPriceTree, levels::Array{Int64,1};
        startindex::Int64 = 0) -> Array{Float64,2}

Compute expected share prices at several zero-based financial tree levels. The
first output column stores the optionally shifted level index and the second stores
the expected share price. Each row corresponds to one requested level.
"""
function 𝔼(model::MyBinomialEquityPriceTree, levels::Array{Int64,1};
    startindex::Int64 = 0)::Array{Float64,2}

    # Initialize -
    number_of_levels = length(levels); # number of requested time slices
    expected_value_array = Array{Float64,2}(undef, number_of_levels, 2); # columns: level index, expected price

    # Populate one output row per requested financial level -
    for i ∈ 0:(number_of_levels-1) # financial offset i maps to Julia row i + 1

        # Get the financial level stored at Julia position i + 1 -
        level = levels[i+1];

        # Compute the expected share price at this level -
        expected_value = 𝔼(model, level=level); # USD/share

        # Store the plotting coordinate and expected price -
        expected_value_array[i+1,1] = level + startindex; # optional level-axis offset
        expected_value_array[i+1,2] = expected_value; # USD/share
    end

    # Return -
    return expected_value_array;
end

Var(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0) = 𝕍(model, levels, startindex = startindex) # familiar alias for the Unicode variance method

"""
    𝕍(model::MyBinomialEquityPriceTree; level::Int = 0) -> Float64

Compute the probability-weighted share-price variance at one zero-based financial
tree level. The returned value has squared price units.
"""
function 𝕍(model::MyBinomialEquityPriceTree; level::Int = 0)::Float64

    # Initialize node-level outcomes and probabilities -
    variance_value = 0.0;
    X = Array{Float64,1}(); # share-price outcomes on the requested level, USD/share
    p = Array{Float64,1}(); # probability mass aligned elementwise with X

    # Collect values from the model's level-to-node-index mapping -
    levels = model.levels; # dictionary keyed by financial level 0,1,...
    nodes_on_this_level = levels[level] # internal node identifiers at the requested level
    for i ∈ nodes_on_this_level # i is a node identifier, not a Julia array position

        # Get the node record -
        node = model.data[i]; # price and probability stored under node identifier i

        # Extract the aligned outcome and probability -
        x_value = node.price; # USD/share
        p_value = node.probability; # dimensionless probability mass

        # Store the aligned pair -
        push!(X,x_value); # append the node's share price
        push!(p,p_value); # append the same node's probability
    end

    # Compute Var(X) = E[X²] - E[X]² -
    variance_value = (_𝔼(X.^2,p) - (_𝔼(X,p))^2) # squared USD/share units

    # Return -
    return variance_value;
end

"""
    𝕍(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0) -> Array{Float64,2}

Compute share-price variances at several zero-based financial tree levels. The
first output column stores the optionally shifted level index and the second stores
the price variance. Each row corresponds to one requested level.
"""
function 𝕍(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0)::Array{Float64,2}

    # Initialize -
    number_of_levels = length(levels); # number of requested time slices
    variance_value_array = Array{Float64,2}(undef, number_of_levels, 2); # columns: level index, price variance

    # Populate one output row per requested financial level -
    for i ∈ 0:(number_of_levels - 1) # financial offset i maps to Julia row i + 1
        level = levels[i+1]; # financial level stored at Julia position i + 1
        variance_value = 𝕍(model, level=level); # price variance at this level
        variance_value_array[i+1,1] = level + startindex # optional level-axis offset
        variance_value_array[i+1,2] = variance_value; # squared USD/share units
    end

    # Return -
    return variance_value_array;
end
