import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    weigh_maximum_sharpe(alpha::Vector{Float64}, beta::Vector{Float64}, sigma_e::Vector{Float64}, sigma_m::Float64,
        g_market::Float64, g_f::Float64)::Vector{Float64}

Find the maximum Sharpe ratio weights under the single-index model without trading limits. The expected growth
rate of stock `i` is `alpha[i] + beta[i] * g_market`, and its excess growth `e[i]` subtracts the risk-free rate
`g_f`. With the covariance matrix `Σ = sigma_m^2 * beta * beta' + diag(sigma_e.^2)`, the weights are proportional
to `Σ⁻¹ e`. The book holds no short stocks, so each negative weight is set to `0.0`, and the other weights are
divided by their sum. When no weight is positive, the rule returns the minimum variance weights. The growth
rates and volatilities are in 1/yr.
"""
function weigh_maximum_sharpe(alpha::Vector{Float64}, beta::Vector{Float64}, sigma_e::Vector{Float64},
        sigma_m::Float64, g_market::Float64, g_f::Float64)::Vector{Float64}

    # Find the excess growth rate of each stock -
    n = length(beta);
    if n == 0
        return Float64[];
    end
    e = zeros(n);
    for i in 1:n
        e[i] = alpha[i] + beta[i] * g_market - g_f;
    end

    # Build the single-index covariance matrix entry by entry -
    Σ = zeros(n, n);
    for i in 1:n
        for j in 1:n
            Σ[i, j] = sigma_m^2 * beta[i] * beta[j];
        end
        Σ[i, i] = Σ[i, i] + sigma_e[i]^2;
    end

    # Solve Σ x = e, and keep the positive part of x -
    x = Σ \ e;
    positive = zeros(n);
    for i in 1:n
        positive[i] = max(x[i], 0.0);
    end

    # With no positive weight, fall back to minimum variance: solve Σ x = 1 instead -
    if sum(positive) <= 0.0
        x = Σ \ ones(n);
        for i in 1:n
            positive[i] = max(x[i], 0.0);
        end
    end
    return positive ./ sum(positive);
end

# The engine's version of the rule: maximum Sharpe ratio under the trading limits.
struct MyL15aMaximumSharpeRule <: MPC.AbstractPortfolioRule end

# The engine finds the long-only book with the largest Sharpe ratio under the budget, the single-name cap, the β
# limit, and the spread-cost budget. Then it scales the book down onto the volatility cap when the book is too
# volatile. When no book has a positive excess growth rate, it returns the minimum variance book.
function MPC.allocate(rule::MyL15aMaximumSharpeRule, p::MPC.MyAllocationProblem)::MPC.MyAllocationResult
    return MPC.allocate(MPC.MyTangentRule(), p);
end
