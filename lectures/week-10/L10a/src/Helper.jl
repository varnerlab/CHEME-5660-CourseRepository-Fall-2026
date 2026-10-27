"""
    𝒫(model::AbstractContractModel; S::Float64, σ::Float64, T::Float64, g::Float64, h::Int64) -> Float64

Compute the premium of a call or put on the Leisen–Reimer tree. The name and the
inputs follow the lecture's premium function `𝒫(S, σ, T, g)`: we estimate a Greek by
calling `𝒫` twice, once with one input moved up and once with it moved down, and
holding the other inputs fixed.

The tree's factors depend on every input, so each call builds a new tree. The
backward induction, including the American exercise decision, is the same as on the
CRR tree. The work is done by `binomial_premium(...)` from the course package.

### Arguments
- `model::AbstractContractModel`: the contract, for example a
  `MyAmericanCallContractModel` or a `MyAmericanPutContractModel`. Its strike price `K`
  is used. Its `premium`, `sense`, and `copy` fields are not.
- `S::Float64`: the share price today (USD/share). Must be positive.
- `σ::Float64`: the volatility (units: yr^-1/2). Must be positive.
- `T::Float64`: the time to expiration (years). Must not be negative.
- `g::Float64`: the continuously compounded risk-free rate (units: 1/yr).
- `h::Int64`: the number of levels of the tree. The Leisen–Reimer tree needs an odd
  number, so an even `h` stops with an error.

### Returns
- `Float64`: the premium of one long contract, per share (USD/share), at full
  precision. Multiply by 100 for one contract.

### Example
```julia
𝒫_up = 𝒫(call_option_model; S = Sₒ + ε_S, σ = call_option_model.IV, T = T, g = gᵧ, h = h); # (USD/share)
```
"""
function 𝒫(model::AbstractContractModel; S::Float64, σ::Float64, T::Float64, g::Float64, h::Int64)::Float64

    # checks: the Leisen–Reimer tree is centered on the strike only when h is odd -
    @assert isodd(h) "the Leisen–Reimer tree needs an odd number of levels, but h = $(h)"

    # price the contract on the Leisen–Reimer tree (μ is the package's name for the risk-free rate) -
    premium = binomial_premium(model; method = :leisen_reimer, h = h, Sₒ = S, σ = σ, T = T, μ = g); # (USD/share)

    # return -
    return premium;
end

"""
    show_value(quantity::String, value::Float64, units::String)

Display one computed value as a one-row table with its units, rounded to two
decimal places. We use it to show what a Greek means for one contract, for example
the time decay in USD per day.

### Arguments
- `quantity::String`: what the value is, for example `"time decay, one long call"`.
- `value::Float64`: the number to display.
- `units::String`: the units of the value, for example `"USD per day per contract"`.

### Returns
- Nothing. The table is printed below the cell.

### Example
```julia
show_value("share equivalents, one long call", 100*delta_long_call, "shares per contract")
```
"""
function show_value(quantity::String, value::Float64, units::String)

    # build a one-row table -
    df = DataFrame(quantity = [quantity], value = [value], units = [units]);

    # display: two decimal places in the value column -
    pretty_table(df; column_labels = ["quantity", "value", "units"], alignment = [:l, :r, :l],
        formatters = [fmt__printf("%.2f", [2])], fit_table_in_display_horizontally = false,
        table_format = TextTableFormat(borders = text_table_borders__compact));

    # return -
    return nothing;
end

"""
    compare_greek(name::String, computed::Float64, quoted::Float64, units::String)

Display a Greek we computed next to the Greek quoted in the options archive, and
their difference (computed minus quoted), rounded to four decimal places. The two
numbers must be in the same units, so convert first: the archive quotes Theta per
day, and Vega and Rho per percentage point.

### Arguments
- `name::String`: the Greek, for example `"Delta"`.
- `computed::Float64`: our estimate from the Leisen–Reimer tree.
- `quoted::Float64`: the archive's value for the same contract.
- `units::String`: the units of both numbers, for example `"USD/share per day"`.

### Returns
- Nothing. The table is printed below the cell.

### Example
```julia
compare_greek("Theta", theta_long_call/365, call_row.theta, "USD/share per day")
```
"""
function compare_greek(name::String, computed::Float64, quoted::Float64, units::String)

    # computed, quoted, and their difference -
    difference = computed - quoted;
    df = DataFrame(quantity = ["$(name), Leisen–Reimer", "$(name), archive quote", "difference"],
        value = [computed, quoted, difference], units = [units, units, units]);

    # display: four decimal places in the value column -
    pretty_table(df; column_labels = ["quantity", "value", "units"], alignment = [:l, :r, :l],
        formatters = [fmt__printf("%.4f", [2])], fit_table_in_display_horizontally = false,
        table_format = TextTableFormat(borders = text_table_borders__compact));

    # return -
    return nothing;
end

"""
    backward_step!(cash_flow::Vector{Float64}, S::Matrix{Float64}, t::Int64; K::Float64, gᵧ::Float64, Δt::Float64) -> Tuple

Take one backward step of the Longstaff–Schwartz method for an American put at
exercise date `t`. The step has three parts:

1. Discount: every path's later cash flow is multiplied by `exp(-gᵧ*Δt)`, so it is
   valued at date `t`.
2. Regress: on the in-the-money paths only, fit the value of holding
   `Ĥ(X) = β₀ + β₁X + β₂X²` to the discounted cash flows by least squares, where `X`
   is the share price at date `t`.
3. Decide: an in-the-money path exercises when its payoff now, `max(K - X, 0)`, is
   larger than `Ĥ(X)`. Exercising replaces the path's later cash flow with the payoff.

The `!` in the name means the function changes `cash_flow` in place: after the call,
it holds each path's cash flow valued at date `t`, ready for the next step back.

### Arguments
- `cash_flow::Vector{Float64}`: each path's cash flow valued at date `t + 1`
  (USD/share). It is overwritten.
- `S::Matrix{Float64}`: the simulated share prices (USD/share), one path per row and
  one date per column. Column 1 holds `t = 0`.
- `t::Int64`: the exercise date of this step, from `1` to the next-to-last date.
- `K::Float64`: the strike price of the put (USD/share).
- `gᵧ::Float64`: the continuously compounded risk-free rate (units: 1/yr).
- `Δt::Float64`: the time between exercise dates (years).

### Returns
- `Tuple` with two entries:
    - `β::Vector{Float64}`: the least-squares coefficients `[β₀, β₁, β₂]`.
    - `step::DataFrame`: one row per in-the-money path, with the columns `path`,
      `X` (share price at date `t`), `exercise` (payoff now), `later` (cash flow valued
      at date `t + 1`), `Y` (that cash flow discounted to date `t`), `Ĥ` (fitted value
      of holding), and `decision` (`"exercise"` or `"hold"`).

The regression needs at least three in-the-money paths. With fewer, the fit is not
unique.

### Example
```julia
β_step2, step_2 = backward_step!(cash_flow, S, 2; K = K, gᵧ = gᵧ, Δt = Δt);
```
"""
function backward_step!(cash_flow::Vector{Float64}, S::Matrix{Float64}, t::Int64;
    K::Float64, gᵧ::Float64, Δt::Float64)::Tuple{Vector{Float64}, DataFrame}

    # initialize -
    number_of_paths = length(cash_flow); # how many simulated paths
    column = t + 1; # column of S that holds date t (column 1 holds t = 0)
    discount = exp(-gᵧ*Δt); # one-step discount factor
    later = copy(cash_flow); # cash flows valued at date t + 1, kept for the table (USD/share)

    # discount: the later cash flows, seen from date t -
    for i ∈ 1:number_of_paths
        cash_flow[i] = discount*cash_flow[i]; # (USD/share)
    end

    # find the in-the-money paths at date t: the put pays K - S when S < K -
    itm = Int64[]; # path numbers of the in-the-money paths
    for i ∈ 1:number_of_paths
        payoff_now = max(K - S[i, column], 0.0); # payoff if exercised at date t (USD/share)
        if payoff_now > 0.0
            push!(itm, i);
        end
    end

    # checks: the quadratic fit has three coefficients, so it needs three paths -
    @assert length(itm) ≥ 3 "only $(length(itm)) paths are in the money at t = $(t), too few to fit three coefficients"

    # regress: in-the-money paths only -
    X = S[itm, column]; # share price at date t (USD/share)
    Y = cash_flow[itm]; # discounted later cash flow (USD/share), a copy taken before any exercise
    A = hcat(ones(length(X)), X, X.^2); # basis 1, X, X²: one row per path
    β = A \ Y; # least-squares coefficients β₀, β₁, β₂ (the backslash solves the least-squares problem)
    Ĥ = A*β; # fitted value of holding (USD/share)

    # decide: exercise where the payoff now beats the value of holding -
    exercise = zeros(length(itm)); # payoff now on each in-the-money path (USD/share)
    decision = String[]; # "exercise" or "hold" for each in-the-money path
    for j ∈ 1:length(itm)
        exercise[j] = max(K - X[j], 0.0); # (USD/share)
        if exercise[j] > Ĥ[j]
            cash_flow[itm[j]] = exercise[j]; # exercising replaces the later cash flow
            push!(decision, "exercise");
        else
            push!(decision, "hold");
        end
    end

    # record the step for the table -
    step = DataFrame(path = itm, X = X, exercise = exercise, later = later[itm], Y = Y, Ĥ = Ĥ, decision = decision);

    # return -
    return (β, step);
end
