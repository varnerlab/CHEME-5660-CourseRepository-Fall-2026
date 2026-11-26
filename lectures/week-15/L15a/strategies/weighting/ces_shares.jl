import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_ces_shares(gamma::Vector{Float64}, prices::Vector{Float64}; eta::Float64=0.5)::Vector{Float64}

Find the weights of CES utility on share counts without trading limits. The elasticity `eta` sets how easily
the investor trades one stock for another. The share count of stock `i` grows with `(gamma[i] / prices[i])^eta`,
so its weight grows with `prices[i] * (gamma[i] / prices[i])^eta`. A stock with a preference weight that is not
positive gets the weight `0.0`. `eta = 1` gives the Cobb–Douglas weights. The prices are in USD/share.
"""
function weigh_ces_shares(gamma::Vector{Float64}, prices::Vector{Float64}; eta::Float64=0.5)::Vector{Float64}

    # Find the dollar amount of each stock with a positive preference weight -
    n = length(gamma);
    amount = zeros(n);
    for i in 1:n
        if gamma[i] > 0.0
            amount[i] = prices[i] * (gamma[i] / prices[i])^eta;
        end
    end

    # Divide each amount by their sum -
    total = sum(amount);
    weights = zeros(n);
    if total > 0.0
        for i in 1:n
            weights[i] = amount[i] / total;
        end
    end
    return weights;
end

# The engine's version of the rule: CES on share counts under the trading limits.
struct MyL15aCESSharesRule <: MPC.AbstractPortfolioRule
    eta::Float64 # the elasticity (dimensionless)
end

# The engine maximizes the same utility under the budget, the single-name cap, the β limit, the volatility cap,
# and the spread-cost budget.
function MPC.allocate(rule::MyL15aCESSharesRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    return MPC.allocate(MPC.build(MPC.MyCESRule, (η=rule.eta,)), p);
end
