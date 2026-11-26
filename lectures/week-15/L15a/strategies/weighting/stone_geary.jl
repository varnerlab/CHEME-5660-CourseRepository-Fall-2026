import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_stone_geary(gamma::Vector{Float64}; baseline::Float64=0.01)::Vector{Float64}

Find the Stone–Geary weights without trading limits. Every stock first gets the baseline weight `baseline`.
The rest of the wealth, `1 - n * baseline` for `n` stocks, is split in proportion to the positive preference
scores, as in Cobb–Douglas. When no score is positive, the rest stays in cash. Throws an `ArgumentError` when the
baselines add to more than `1`.
"""
function weigh_stone_geary(gamma::Vector{Float64}; baseline::Float64=0.01)::Vector{Float64}

    # Every stock holds the baseline weight -
    n = length(gamma);
    rest = 1.0 - n * baseline;
    if rest < 0.0
        throw(ArgumentError("the baselines of $(n) stocks add to more than 1"));
    end
    weights = fill(baseline, n);

    # Split the rest of the wealth by the positive preference weights -
    total = 0.0;
    for i in 1:n
        total = total + max(gamma[i], 0.0);
    end
    if total > 0.0
        for i in 1:n
            weights[i] = weights[i] + rest * max(gamma[i], 0.0) / total;
        end
    end
    return weights;
end

# The engine's version of the rule: Stone–Geary under the trading limits.
struct MyL15aStoneGearyRule <: MPC.AbstractPortfolioRule
    baseline::Float64 # the baseline weight of each stock (fraction of wealth)
end

# The engine maximizes the same utility under the budget, the single-name cap, the β limit, the volatility cap,
# and the spread-cost budget.
function MPC.allocate(rule::MyL15aStoneGearyRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    return MPC.allocate(MPC.build(MPC.MyStoneGearyRule, (baseline_frac=rule.baseline,)), p);
end
