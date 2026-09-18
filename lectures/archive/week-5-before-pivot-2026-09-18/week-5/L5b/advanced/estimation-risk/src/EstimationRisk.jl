"""
    gmv_closed(Σ) -> Vector

Compute fully invested global minimum-variance weights with short positions allowed.

`Σ` is an M × M symmetric positive-definite growth-rate covariance matrix, with
units of inverse years squared. Return M dimensionless weights whose sum is one.
The asset count is inferred from `Σ`. Solve a linear system rather than forming
the inverse covariance explicitly. No expected-growth target is imposed.
"""
function gmv_closed(Σ)
    M = size(Σ, 1); # number of assets
    x = Σ \ ones(M); # inverse-covariance direction for the budget constraint
    return x / sum(x);
end

"""
    tangent_closed(g, Σ, g_f) -> Vector

Normalize the inverse-covariance excess-growth direction to fully invested weights.

`g` is a length-M vector of estimated mean growth rates (inverse years), `Σ` is
the M × M symmetric positive-definite growth-rate covariance (inverse years
squared), and `g_f` is the risk-free growth-rate benchmark (inverse years).
Return M dimensionless weights; short positions are allowed.

For x obtained by solving Σx = g .- g_f and κ = sum(x), positive κ gives the maximum-Sharpe
portfolio. Negative κ gives the minimum-Sharpe portfolio and is deliberately
retained for this notebook's sensitivity diagnostic. Small nonzero κ can produce
very large weights. Exactly zero κ raises `DomainError`, since normalization is
undefined; the function does not silently remove or replace such a resample.
"""
function tangent_closed(g, Σ, g_f)
    x = Σ \ (g .- g_f); # inverse-covariance excess-growth direction
    κ = sum(x); # normalizing constant (units: years)
    iszero(κ) && throw(DomainError(κ, "The excess-growth direction cannot be normalized."));
    return x / κ;
end

"""
    gmv_long_only(g, Σ) -> Vector

Compute fully invested global minimum-variance weights subject to 0 ≤ wᵢ ≤ 1.

`g` contains M estimated mean growth rates (inverse years); `Σ` is their M × M
symmetric positive-definite covariance (inverse years squared). Return M
dimensionless weights from the course package solver, within solver tolerance.
The growth floor is minimum(g), which every feasible long-only allocation meets;
thus the mean vector does not impose an effective growth restriction. The
initial guess gives equal weights. Solver failures propagate to the caller.
"""
function gmv_long_only(g, Σ)
    M = length(g); # number of assets
    bounds = zeros(M, 2); # lower and upper weight bounds
    bounds[:, 2] .= 1.0;
    problem = build(MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem, (
        Σ = Σ,
        μ = g,
        bounds = bounds,
        initial = (1/M)*ones(M),
        R = minimum(g),
    ));
    return solve(problem)["argmax"];
end

"""
    tangent_long_only(g, Σ, g_f; number_of_points::Int = 31) -> Vector

Select the largest-Sharpe long-only allocation among sampled frontier candidates.

`g` contains M mean growth estimates (inverse years), `Σ` is their M × M
symmetric positive-definite covariance (inverse years squared), and `g_f` is
the risk-free benchmark (inverse years). `number_of_points` must be at least two.
Return M dimensionless weights with 0 ≤ wᵢ ≤ 1 and sum(w) = 1, within solver
tolerance. This is a grid approximation, not an exact maximum-Sharpe solve.

Include the long-only GMV allocation, then solve at `number_of_points` evenly
spaced growth floors from its estimated mean to maximum(g) - 1e-4 inverse years.
This retains the notebook's endpoint offset and grid. For an increasing sweep,
the upper endpoint must exceed the GMV mean; the supplied data satisfy this.
Rank candidates by (dot(g,w) - g_f)/sqrt(dot(w,Σ*w)). The baseline GMV solve
must succeed. Skip sweep points for which the package solver raises an
`AssertionError`, preserving the original failure handling; other errors propagate.
"""
function tangent_long_only(g, Σ, g_f; number_of_points::Int = 31)
    number_of_points >= 2 || throw(ArgumentError("At least two grid points are required."));
    M = length(g); # number of assets
    bounds = zeros(M, 2); # lower and upper weight bounds
    bounds[:, 2] .= 1.0;
    problem = build(MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem, (
        Σ = Σ,
        μ = g,
        bounds = bounds,
        initial = (1/M)*ones(M),
        R = minimum(g),
    ));

    # Include the GMV portfolio before sweeping the growth targets -
    w_gmv = solve(problem)["argmax"];
    best_w = w_gmv;
    best_SR = (g'*w_gmv - g_f)/sqrt(w_gmv'*Σ*w_gmv);
    for target ∈ range(g'*w_gmv, stop = maximum(g) - 1e-4, length = number_of_points)
        problem.R = target;
        w = try
            solve(problem)["argmax"]
        catch err
            err isa AssertionError ? continue : rethrow();
        end
        SR = (g'*w - g_f)/sqrt(w'*Σ*w);
        if SR > best_SR
            best_SR = SR;
            best_w = w;
        end
    end
    return best_w;
end

"""
    hyperbola(g, Σ; maximum_growth::Real = 0.6,
              number_of_points::Int = 80) -> NamedTuple

Evaluate the efficient branch of the fully invested minimum-variance frontier,
allowing short positions.

`g` is a length-M vector of estimated mean growth rates (inverse years), and `Σ`
is the M × M symmetric positive-definite growth-rate covariance (inverse years
squared). The means must not all be equal. `maximum_growth` is the largest growth
target (inverse years), at or above the GMV mean. `number_of_points` must be at
least two. The number of assets is inferred from `g`.

Return `(σ, g)` as a named tuple of vectors, both with `number_of_points` entries
and units of inverse years. Field `g` contains evenly spaced targets from the
GMV mean to `maximum_growth`; field `σ` contains the minimum standard deviations
at those targets. The first pair is the GMV point. The calculation solves two
linear systems and evaluates the closed-form variance; it does not run a solver.
The determinant d must be positive. Invalid d or an upper target below the GMV
mean raises `DomainError`; fewer than two targets raises `ArgumentError`.
"""
function hyperbola(g, Σ; maximum_growth::Real = 0.6, number_of_points::Int = 80)
    number_of_points >= 2 || throw(ArgumentError("At least two frontier points are required."));
    M = length(g); # number of assets
    e = ones(M); # vector for the budget constraint

    # Solve for the directions used in the frontier coefficients -
    x = Σ \ e;
    y = Σ \ g;
    a = e'*x; # units: years squared
    b = e'*y; # units: years
    c = g'*y; # dimensionless
    d = a*c - b^2; # units: years squared
    d > 0 || throw(DomainError(d, "The frontier determinant must be positive."));

    # Start at the GMV mean and follow the efficient branch -
    g_gmv = b/a; # GMV mean growth rate (inverse years)
    maximum_growth >= g_gmv || throw(DomainError(
        maximum_growth, "The upper target must be at or above the GMV mean."));
    targets = collect(range(g_gmv, stop = maximum_growth, length = number_of_points));
    σ = sqrt.((a .* targets.^2 .- 2*b .* targets .+ c) ./ d);
    return (σ = σ, g = targets);
end

"""
    distances(W) -> Vector

Measure each portfolio's distance from the componentwise median weights.

`W` is an M × B matrix of dimensionless portfolio weights, with assets in rows
and bootstrap resamples in columns. At least one resample is required. Negative
weights are allowed. Compute each asset's median across columns and return B
dimensionless distances, each the sum of absolute deviations across assets.
The median vector need not sum to one, so these distances describe dispersion
and do not measure trades between two feasible portfolios. No normalization
or factor of one half is applied.
"""
function distances(W)
    return vec(sum(abs.(W .- median(W, dims = 2)), dims = 1));
end

"""
    dispersion(W) -> Real

Return the mean distance from the componentwise median portfolio weights.

`W` is an M × B matrix of dimensionless weights, with assets in rows and
resamples in columns; at least one resample is required. Negative weights are
allowed. Return the arithmetic mean of `distances(W)`, also dimensionless.
This summarizes dispersion across resamples; it is not realized trading turnover.
"""
function dispersion(W)
    return mean(distances(W));
end

"""
    buy_and_hold_statistics(prices, w, Δt) -> NamedTuple

Evaluate a fixed-share allocation on one observed price history.

`prices` is a (K + 1) × M matrix of positive, aligned share prices (USD per
share), with trading days in rows and assets in columns. At least three price
rows are needed for a sample standard deviation of the K growth observations.
`w` contains M dimensionless initial long-only weights summing to one, within
solver tolerance. `Δt` is the positive observation interval in years.

Return `(wealth_ratio, terminal_ratio, σ_g)`: the K + 1 values of W_t/W_0,
the final dimensionless wealth ratio, and the sample standard deviation of
successive log wealth ratios divided by Δt (inverse years). The standard
deviation uses the K - 1 denominator. The wealth path must remain positive.

The first price row is the purchase-price reference. Fractional shares are
allowed and shares stay fixed; weights drift as prices change. The calculation
adds no dividend cash flows, costs, or taxes and applies no discounting.
Weights are used as supplied, without rounding or normalization.
"""
function buy_and_hold_statistics(prices, w, Δt)
    ratios = prices ./ prices[1, :]'; # asset prices relative to the first day
    R = ratios*w; # wealth divided by initial wealth (dimensionless)
    g = diff(log.(R)) ./ Δt; # observed wealth growth rates (inverse years)
    return (wealth_ratio = R, terminal_ratio = R[end], σ_g = std(g));
end
