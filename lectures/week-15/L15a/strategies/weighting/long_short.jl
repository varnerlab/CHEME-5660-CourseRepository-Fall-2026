import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_long_short(gamma::Vector{Float64}; long_cap::Float64=1.30, short_cap::Float64=0.30)::Vector{Float64}

Find the 130/30 long-short Cobb–Douglas weights without trading limits. The stocks with a positive preference
score go long, and the long weights add to `long_cap`, split in proportion to the scores. The stocks with a
negative score go short, and the short weights add to `short_cap`, split in proportion to the size of the scores.
A short weight is negative. When no score is negative, the book is the long-only Cobb–Douglas book.
"""
function weigh_long_short(gamma::Vector{Float64}; long_cap::Float64=1.30, short_cap::Float64=0.30)::Vector{Float64}

    # Add up the positive scores and the size of the negative scores -
    n = length(gamma);
    long_total = 0.0;
    short_total = 0.0;
    for i in 1:n
        if gamma[i] > 0.0
            long_total = long_total + gamma[i];
        elseif gamma[i] < 0.0
            short_total = short_total - gamma[i];
        end
    end

    # With no negative score, the long side holds the whole wealth -
    long_size = long_cap;
    if short_total == 0.0
        long_size = 1.0;
    end

    # Split each side in proportion to the scores -
    weights = zeros(n);
    for i in 1:n
        if gamma[i] > 0.0
            weights[i] = long_size * gamma[i] / long_total;
        elseif gamma[i] < 0.0
            weights[i] = short_cap * gamma[i] / short_total;
        end
    end
    return weights;
end

# The engine's version of the rule: 130/30 long-short Cobb–Douglas under the trading limits.
struct MyL15aLongShortRule <: MPC.AbstractPortfolioRule
    long_cap::Float64  # the largest sum of the long weights (fraction of wealth)
    short_cap::Float64 # the largest sum of the short weights (fraction of wealth)
    net_cap::Float64   # the largest net weight (fraction of wealth)
end

# The engine ranks the universe by preference weight to find the short candidates for this rule.
function MPC.uses_short_candidates(rule::MyL15aLongShortRule)::Bool
    return true;
end

# The engine maximizes the same utility under the long and short caps, the budget, the single-name cap, the β
# limit, the volatility cap, and the spread-cost budget.
function MPC.allocate(rule::MyL15aLongShortRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    engine_rule = MPC.build(MPC.MyLongShortCDRule, (long_cap=rule.long_cap, short_cap=rule.short_cap,
        net_cap=rule.net_cap));
    return MPC.allocate(engine_rule, p);
end
