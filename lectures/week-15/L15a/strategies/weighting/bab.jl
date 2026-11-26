import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_bab(beta::Vector{Float64}; beta_floor::Float64=0.1)::Vector{Float64}

Find the betting-against-beta weights of Frazzini and Pedersen without trading limits. The stocks whose `beta`
ranks below the middle rank go long, and the stocks above it go short. Each stock weighs in proportion to its
distance from the middle rank, and each side's weights first add to `1`. Then each side is scaled to a β of `1`:
the long side by `1 / beta_low` and the short side by `1 / beta_high`, where `beta_low` and `beta_high` are the
sides' β values. So the book's β is `0`. A side's β below `beta_floor` is raised to `beta_floor` before the
scaling. A short weight is negative. Stocks with the same `beta` keep their order. With fewer than two stocks,
every weight is `0.0`.
"""
function weigh_bab(beta::Vector{Float64}; beta_floor::Float64=0.1)::Vector{Float64}

    # With fewer than two stocks, no stock ranks above or below another -
    n = length(beta);
    weights = zeros(n);
    if n < 2
        return weights;
    end

    # Rank the stocks by beta: the stock with the lowest beta has rank 1 -
    order = sortperm(beta);
    z = zeros(n);
    for r in 1:n
        z[order[r]] = r;
    end

    # Find the mean rank, and the scale that makes each side's weights add to 1 -
    z_bar = sum(z) / n;
    total = 0.0;
    for i in 1:n
        total = total + abs(z[i] - z_bar);
    end
    k = 2.0 / total;

    # Weigh each stock by its distance from the mean rank -
    w_low = zeros(n);
    w_high = zeros(n);
    for i in 1:n
        if z[i] < z_bar
            w_low[i] = k * (z_bar - z[i]);
        elseif z[i] > z_bar
            w_high[i] = k * (z[i] - z_bar);
        end
    end

    # Find each side's beta, and scale each side to a beta of 1 -
    beta_low = 0.0;
    beta_high = 0.0;
    for i in 1:n
        beta_low = beta_low + w_low[i] * beta[i];
        beta_high = beta_high + w_high[i] * beta[i];
    end
    for i in 1:n
        weights[i] = w_low[i] / max(beta_low, beta_floor) - w_high[i] / max(beta_high, beta_floor);
    end
    return weights;
end

# The engine's version of the rule: betting against beta under the trading limits.
struct MyL15aBABRule <: MPC.AbstractPortfolioRule
    long_cap::Float64   # the largest sum of the long weights (fraction of wealth)
    short_cap::Float64  # the largest sum of the short weights (fraction of wealth)
    beta_floor::Float64 # the smallest side β used in the scaling (dimensionless)
end

# The engine marks the picked stocks with the score 1, so the rule can find the basket in the problem.
function MPC.rule_preferences(rule::MyL15aBABRule, γ::Vector{Float64}, picked::Vector{Bool})::Vector{Float64}
    scores = zeros(length(γ));
    for i in eachindex(picked)
        if picked[i] == true
            scores[i] = 1.0;
        end
    end
    return scores;
end

# The rule ranks the basket by the strategy's own single-index β. Then the engine finds the book closest to those
# weights under the long and short caps, the budget, the single-name cap, the β limit, the volatility cap, and the
# spread-cost budget. Where a limit binds, the book's β moves away from 0.
function MPC.allocate(rule::MyL15aBABRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult

    # Find the basket and the β of each picked stock -
    basket = Int[];
    for i in eachindex(p.γ)
        if p.γ[i] > 0.0
            push!(basket, i);
        end
    end
    beta = p.constraints.β[basket];

    # The target weights: the BAB weights on the basket, and 0 everywhere else -
    target = zeros(length(p.γ));
    weights = weigh_bab(beta; beta_floor=rule.beta_floor);
    for k in eachindex(basket)
        target[basket[k]] = weights[k];
    end
    return MPC.closest_book(p, target; long_cap=rule.long_cap, short_cap=rule.short_cap);
end
