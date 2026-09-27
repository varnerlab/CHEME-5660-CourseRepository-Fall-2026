"""
    frontier_weights(g_target::Float64, parameters::NamedTuple) -> Vector{Float64}

Compute the fully invested minimum-variance weights at an equality growth target,
using the closed-form solution of the lecture's frontier problem (F-1).

### Arguments
- `g_target`: expected portfolio growth rate, in inverse years.
- `parameters`: the named tuple constructed in Task 1, with fields `x`, `y`,
  `a`, `b`, `c`, and `d`. For the growth covariance `Σ̂` and sample-mean vector
  `g′` (`ĝ` in the notebook), `x = Σ̂ \\ ones(M)` and `y = Σ̂ \\ g′`. The
  coefficients are `a = sum(x)`, `b = sum(y)`, `c = dot(g′, y)`, and `d = a*c-b^2`.

### Returns
- A `Vector{Float64}` of dimensionless portfolio weights `w = λx + γy`, in the
  input asset order. The weights sum to one and may be negative.

### Notes
The multipliers are `λ = (c - b*g_target)/d` for the budget constraint and
`γ = (a*g_target - b)/d` for the growth target. The covariance must be positive
definite, the sample means must not all be equal, and all tuple fields must come
from those same inputs. These conditions give `d > 0`, and they are not rechecked
for each target. The vectors `x` and `y` have units of years squared and years.
The coefficients `a`, `b`, `c`, and `d` have units of years squared, years, one,
and years squared.
"""
function frontier_weights(g_target::Float64, parameters::NamedTuple)

    # Compute the budget and target multipliers -
    λ = (parameters.c - parameters.b*g_target)/parameters.d; # budget constraint 1ᵀw = 1
    γ = (parameters.a*g_target - parameters.b)/parameters.d; # growth target g′ᵀw = g_target

    # Combine the two precomputed solves, w = λΣ̂⁻¹1 + γΣ̂⁻¹g′ -
    return λ*parameters.x + γ*parameters.y
end

"""
    frontier_variance(g_target::Float64, parameters::NamedTuple) -> Float64

Compute the minimum growth-rate variance at an equality growth target, the
lecture's result (F-3).

### Arguments
- `g_target`: expected portfolio growth rate, in inverse years.
- `parameters`: the same named tuple used by `frontier_weights`. Only its fields
  `a`, `b`, `c`, and `d` are used. They must come from one positive-definite
  growth covariance and a sample-mean vector whose entries are not all equal,
  so that `d > 0`.

### Returns
- A `Float64` variance in inverse years squared, equal to
  `(a*g_target^2 - 2*b*g_target + c)/d`.

### Notes
This is the unrestricted fully invested frontier, so weights may be negative.
It covers both the efficient frontier (`g_target ≥ b/a`) and the dominated branch
(`g_target < b/a`). Take `sqrt` of the result for the growth-rate standard deviation.
"""
function frontier_variance(g_target::Float64, parameters::NamedTuple)
    return (parameters.a*g_target^2 - 2*parameters.b*g_target + parameters.c)/parameters.d # (F-3)
end

"""
    solve_frontier_point(g_target::Float64, mean_growth::Vector{Float64},
        covariance::Matrix{Float64}; lower::Float64 = -Inf, upper::Float64 = Inf)
        -> Union{Vector{Float64}, Nothing}

Numerically minimize growth-rate variance with weights summing to one and
expected growth equal to `g_target`, optionally with bounds on every weight.

### Arguments
- `g_target`: equality target for expected portfolio growth, in inverse years.
- `mean_growth`: one sample-mean growth rate per asset, in inverse years.
- `covariance`: positive-definite growth-rate covariance in inverse years squared,
  with rows and columns in the same asset order as `mean_growth`.
- `lower`, `upper`: dimensionless bounds applied to every weight. The defaults
  allow unrestricted short positions. `lower = 0.0, upper = 1.0` gives long-only
  weights, and `lower = -0.5, upper = 0.5` caps each position, long or short, at
  half the budget.

### Returns
- A `Vector{Float64}` of dimensionless weights when JuMP reports a solved,
  feasible model, or `nothing` otherwise (for example, an infeasible target).
  Check the result with `isnothing` before using it.

### Notes
Solver tolerances apply. Inputs must be finite and dimensionally consistent,
except that infinite weight bounds are allowed. The function uses JuMP and MadNLP,
which are loaded by this example's `Include.jl`. With unrestricted bounds it
should match `frontier_weights` to solver tolerance.
"""
function solve_frontier_point(g_target::Float64, mean_growth::Vector{Float64},
    covariance::Matrix{Float64}; lower::Float64 = -Inf, upper::Float64 = Inf)

    # Construct the equality-constrained portfolio problem -
    M = length(mean_growth); # number of assets
    # The anonymous function builds a fresh MadNLP solver that prints only errors.
    model = Model(() -> MadNLP.Optimizer(print_level = MadNLP.ERROR, max_iter = 500));
    @variable(model, lower ≤ w[i = 1:M] ≤ upper, start = 1/M); # M bounded weights, starting from equal weights
    @objective(model, Min, w'*covariance*w); # growth-rate variance wᵀΣ̂w
    @constraint(model, sum(w) == 1.0); # budget: fully invested
    @constraint(model, mean_growth'*w == g_target); # exact growth target

    # Solve and return the portfolio weights -
    optimize!(model);
    is_solved_and_feasible(model) || return nothing # `cond || return x` returns early when cond is false
    return value.(w) # broadcast value over the weight variables to get a Vector{Float64}
end
