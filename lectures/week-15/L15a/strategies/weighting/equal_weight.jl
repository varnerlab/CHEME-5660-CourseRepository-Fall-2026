import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_equal(count::Int)::Vector{Float64}

Find the equal weights of `count` picked stocks without trading limits. Every stock gets the weight `1 / count`.
"""
function weigh_equal(count::Int)::Vector{Float64}
    return fill(1.0 / count, count);
end

# The engine's version of the rule: equal weight under the trading limits.
struct MyL15aEqualWeightRule <: MPC.AbstractPortfolioRule end

# The engine marks the picked stocks with the score 1, so the rule can find the basket in the problem.
function MPC.rule_preferences(rule::MyL15aEqualWeightRule, γ::Vector{Float64}, picked::Vector{Bool})::Vector{Float64}
    scores = zeros(length(γ));
    for i in eachindex(picked)
        if picked[i] == true
            scores[i] = 1.0;
        end
    end
    return scores;
end

# The engine invests the largest fraction of the wealth in the equal weights that meets the budget, the single-name
# cap, the β limit, the volatility cap, and the spread-cost budget. Every picked stock keeps the same weight, the rest
# of the wealth stays in cash, and the hedge pool can carry part of the book to meet the β limit.
function MPC.allocate(rule::MyL15aEqualWeightRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult

    # Find the basket -
    basket = Int[];
    for i in eachindex(p.γ)
        if p.γ[i] > 0.0
            push!(basket, i);
        end
    end

    # The target weights: the equal weights on the basket, and 0 everywhere else -
    target = zeros(length(p.γ));
    weights = weigh_equal(length(basket));
    for k in eachindex(basket)
        target[basket[k]] = weights[k];
    end
    return MPC.scaled_book(p, target);
end
