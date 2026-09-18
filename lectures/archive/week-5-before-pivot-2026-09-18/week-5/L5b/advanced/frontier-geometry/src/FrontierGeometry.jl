"""
    frontier_weights(g_target::Float64, parameters::NamedTuple)

Compute the fully invested minimum-variance weights at an equality growth target.

# Arguments
- `g_target`: Expected portfolio growth rate, in inverse years.
- `parameters`: The named tuple constructed in Task 1, with fields `x`, `y`,
  `a`, `b`, `c`, and `d`. For the chosen growth covariance `Σ` and mean vector `μ`,
  `x = Σ \\ ones(M)` and `y = Σ \\ μ`. The coefficients are `a = sum(x)`,
  `b = sum(y)`, `c = dot(μ, y)`, and `d = a*c-b^2`.

# Returns and assumptions
Returns a `Vector{Float64}` of dimensionless portfolio weights in the input asset
order. Weights sum to one and may be negative. The covariance must be positive
definite, the asset means must not all be equal, and all tuple fields must come
from those same inputs. These conditions give `d > 0`; they are not rechecked
for each target. The vectors `x` and `y` have units of years squared and years;
`a`, `b`, `c`, and `d` have units of years squared, years, one, and years squared.
"""
function frontier_weights(g_target::Float64, parameters::NamedTuple)
    # Compute the budget and target multipliers -
    λ = (parameters.c - parameters.b*g_target)/parameters.d;
    γ = (parameters.a*g_target - parameters.b)/parameters.d;
    return λ*parameters.x + γ*parameters.y
end

"""
    frontier_variance(g_target::Float64, parameters::NamedTuple)

Compute the minimum growth-rate variance at an equality target `g_target`
(inverse years). `parameters` is the same named tuple used by `frontier_weights`;
its fields `a`, `b`, `c`, and `d` describe one positive-definite growth covariance
and a nonconstant mean-growth vector, with `d > 0`.

Returns a `Float64` variance in inverse years squared. This is the unrestricted
fully invested frontier, including both branches; weights may be negative.
The formula uses `(a*g_target^2 - 2*b*g_target + c)/d`.
"""
function frontier_variance(g_target::Float64, parameters::NamedTuple)
    return (parameters.a*g_target^2 - 2*parameters.b*g_target + parameters.c)/parameters.d
end

"""
    solve_frontier_point(g_target::Float64, mean_growth::Vector{Float64},
        covariance::Matrix{Float64}; lower::Float64 = -Inf, upper::Float64 = Inf)

Numerically minimize growth-rate variance with weights summing to one and
expected growth equal to `g_target`.

# Arguments
- `g_target`: Equality target for expected portfolio growth, in inverse years.
- `mean_growth`: One mean growth rate per asset, in inverse years.
- `covariance`: Positive-definite growth-rate covariance in inverse years squared,
  with rows and columns in the same asset order as `mean_growth`.
- `lower`, `upper`: Dimensionless bounds applied to every weight. Defaults allow
  unrestricted short positions; `lower = 0.0, upper = 1.0` gives long-only weights.

# Returns and assumptions
Returns a `Vector{Float64}` of dimensionless weights when JuMP reports a solved,
feasible model, or `nothing` otherwise (including an infeasible target). Solver
tolerances apply. Inputs must be finite and dimensionally consistent, except
that infinite weight bounds are allowed. The function uses JuMP and MadNLP,
which are loaded by this example's `Include.jl`.
"""
function solve_frontier_point(g_target::Float64, mean_growth::Vector{Float64},
    covariance::Matrix{Float64}; lower::Float64 = -Inf, upper::Float64 = Inf)

    # Construct the equality-constrained portfolio problem -
    M = length(mean_growth); # number of assets
    model = Model(() -> MadNLP.Optimizer(print_level = MadNLP.ERROR, max_iter = 500));
    @variable(model, lower ≤ w[i = 1:M] ≤ upper, start = 1/M);
    @objective(model, Min, w'*covariance*w);
    @constraint(model, sum(w) == 1.0);
    @constraint(model, mean_growth'*w == g_target);

    # Solve and return the portfolio weights -
    optimize!(model);
    is_solved_and_feasible(model) || return nothing
    return value.(w)
end

"""
    interpolate_frontier_risk(frontier::DataFrame, g_target::Float64)

Linearly interpolate growth-rate standard deviation at a target expected growth.

# Arguments
- `frontier`: A nonempty table with Float64 columns `g` (expected growth) and
  `σ` (standard deviation), both in inverse years. Rows must have finite values
  and strictly increasing `g`, as produced by the notebook's frontier sweep.
- `g_target`: A finite expected growth rate, in inverse years.

# Returns and assumptions
Returns a `Float64` standard deviation in inverse years. At a sampled target,
returns its stored risk; between targets, interpolates between the neighboring
rows. Returns `NaN` outside the sampled growth range rather than extrapolating.
This is an approximation between solved portfolios, not another optimization.
"""
function interpolate_frontier_risk(frontier::DataFrame, g_target::Float64)
    # Restrict interpolation to the sampled growth range -
    (g_target < frontier.g[1] || g_target > frontier.g[end]) && return NaN
    k = searchsortedlast(frontier.g, g_target);
    k == nrow(frontier) && return frontier.σ[end]

    # Interpolate between the two neighboring frontier points -
    return frontier.σ[k] + (frontier.σ[k+1] - frontier.σ[k])*
        (g_target - frontier.g[k])/(frontier.g[k+1] - frontier.g[k])
end
