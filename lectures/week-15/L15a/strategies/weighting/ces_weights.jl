import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_ces_weights(gamma::Vector{Float64}; eta::Float64=0.5)::Vector{Float64}

Find the weights of CES utility on portfolio weights without trading limits. The weight of stock `i` grows with
`gamma[i]^eta`. A stock with a preference weight that is not positive gets the weight `0.0`. As `eta` falls toward
`0`, every stock gets the same weight (the Leontief end). As `eta` grows, the wealth moves to the stock with the
top score (the linear end). `eta = 1` gives the Cobb–Douglas weights.
"""
function weigh_ces_weights(gamma::Vector{Float64}; eta::Float64=0.5)::Vector{Float64}

    # Raise each positive preference weight to the power eta -
    n = length(gamma);
    amount = zeros(n);
    for i in 1:n
        if gamma[i] > 0.0
            amount[i] = gamma[i]^eta;
        end
    end

    # Divide each result by their sum -
    total = sum(amount);
    weights = zeros(n);
    if total > 0.0
        for i in 1:n
            weights[i] = amount[i] / total;
        end
    end
    return weights;
end

# The engine's version of the rule: CES on portfolio weights under the trading limits.
struct MyL15aCESWeightsRule <: MPC.AbstractPortfolioRule
    eta::Float64 # the elasticity (dimensionless)
end

# The engine maximizes the same utility under the budget, the single-name cap, the β limit, the volatility cap,
# and the spread-cost budget.
function MPC.allocate(rule::MyL15aCESWeightsRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    return MPC.allocate(MPC.build(MPC.MyCESWeightRule, (η=rule.eta,)), p);
end
