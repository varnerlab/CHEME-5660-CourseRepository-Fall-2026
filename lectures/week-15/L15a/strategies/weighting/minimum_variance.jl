import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_minimum_variance(beta::Vector{Float64}, sigma_e::Vector{Float64}, sigma_m::Float64)::Vector{Float64}

Find the minimum variance weights under the single-index model without trading limits. The model gives the
covariance matrix `Σ = sigma_m^2 * beta * beta' + diag(sigma_e.^2)`, and the weights that minimize the variance
when they add to `1` are `Σ⁻¹ 1 / (1' Σ⁻¹ 1)`. The book holds no short stocks, so each negative weight is set to
`0.0`, and the other weights are divided by their sum. `sigma_e` and `sigma_m` are in 1/yr.
"""
function weigh_minimum_variance(beta::Vector{Float64}, sigma_e::Vector{Float64}, sigma_m::Float64)::Vector{Float64}

    # Build the single-index covariance matrix entry by entry -
    n = length(beta);
    if n == 0
        return Float64[];
    end
    Σ = zeros(n, n);
    for i in 1:n
        for j in 1:n
            Σ[i, j] = sigma_m^2 * beta[i] * beta[j];
        end
        Σ[i, i] = Σ[i, i] + sigma_e[i]^2;
    end

    # Solve Σ x = 1, and keep the positive part of x -
    x = Σ \ ones(n);
    positive = zeros(n);
    for i in 1:n
        positive[i] = max(x[i], 0.0);
    end

    # Divide each positive part by their sum -
    return positive ./ sum(positive);
end

# The engine's version of the rule: minimum variance under the trading limits.
struct MyL15aMinimumVarianceRule <: MPC.AbstractPortfolioRule end

# The engine finds the long-only book with the least variance under the budget, the single-name cap, the β limit,
# and the spread-cost budget, with the single-index covariance plus the shrunk residual covariance. Then it scales
# the book down onto the volatility cap when the book is too volatile.
function MPC.allocate(rule::MyL15aMinimumVarianceRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    return MPC.allocate(MPC.MyMinVarRule(), p);
end
