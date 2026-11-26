import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_cobb_douglas(gamma::Vector{Float64})::Vector{Float64}

Find the Cobb–Douglas weights without trading limits. An investor with Cobb–Douglas utility puts the share
`gamma[i] / sum(gamma)` of the wealth in stock `i`. A stock with a preference weight that is not positive gets the
weight `0.0`. When no score is positive, every weight is `0.0`, and the book holds cash.
"""
function weigh_cobb_douglas(gamma::Vector{Float64})::Vector{Float64}

    # Keep the positive part of each preference weight -
    n = length(gamma);
    positive = zeros(n);
    for i in 1:n
        positive[i] = max(gamma[i], 0.0);
    end

    # Divide each positive part by their sum -
    total = sum(positive);
    weights = zeros(n);
    if total > 0.0
        for i in 1:n
            weights[i] = positive[i] / total;
        end
    end
    return weights;
end

# The engine's version of the rule: Cobb–Douglas under the trading limits.
struct MyL15aCobbDouglasRule <: MPC.AbstractPortfolioRule end

# The engine maximizes the same utility under the budget, the single-name cap, the β limit, the volatility cap,
# and the spread-cost budget.
function MPC.allocate(rule::MyL15aCobbDouglasRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    return MPC.allocate(MPC.MyCobbDouglasRule(), p);
end
