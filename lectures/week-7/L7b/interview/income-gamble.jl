# L7b income-gamble interview: bracket a client's relative risk aversion.
#
# The questions are the income gambles of Barsky, Juster, Kimball, and Shapiro (1997),
# in the six-category form of Kimball, Sahm, and Shapiro (2008). Each question offers a
# sure income or a job with equal chances of doubling it or cutting it by a fraction δ.
# The published questions place the client in one of six categories. Two more questions
# in the same form, our extension, then halve the range of cuts inside that category.
#
# At the cut δ⋆ where the client cannot choose, the certainty equivalent of the risky job
# equals the sure income. For a power utility with relative risk aversion r̄, that is:
#
#   (1/2) U(2) + (1/2) U(1 - δ⋆) = U(1),   U(w) = (w^(1-r̄) - 1)/(1 - r̄), U(w) = ln w at r̄ = 1
#
# Accepting a cut δ means r̄ ≤ r̄⋆(δ), and refusing it means r̄ ≥ r̄⋆(δ). The script solves
# this equation for the largest accepted and the smallest refused cut.
#
# Usage, from any folder (it needs only Julia's standard library):
#
#   julia income-gamble.jl --answers=first,first,second,second,first
#
# Options:
#   --answers=a,b,...   the client's answers in the order asked: first (the sure job) or
#                       second (the risky job). Fewer answers than the interview needs
#                       prints the next question and writes nothing.
#   --dry-run           print the result without writing the file
#
# Writes, in ../data:
#   my-risk-aversion.toml   the answers, the category, and the bounds on A (read by the CAL example)

using Printf # aligned text output
using TOML   # write my-risk-aversion.toml
using Dates  # date stamp for the output file

# The sure income in the question (USD per year) -
const SURE_INCOME = 100_000;

# The published questions: the next cut for each range (largest accepted, smallest refused) -
# The range starts at (0, 1): no cut accepted yet, and a 100% cut is never asked.
const PUBLISHED_NEXT_CUT = Dict(
    (0//1, 1//1) => 1//3,   # the first question
    (1//3, 1//1) => 1//2,   # took the second job at a third
    (1//2, 1//1) => 3//4,   # took the second job at a half
    (0//1, 1//3) => 1//5,   # took the first job at a third
    (0//1, 1//5) => 1//10); # took the first job at a fifth

# The six published categories, from most to least risk averse -
const CATEGORIES = Dict(
    (0//1, 1//10) => 1,
    (1//10, 1//5) => 2,
    (1//5, 1//3) => 3,
    (1//3, 1//2) => 4,
    (1//2, 3//4) => 5,
    (3//4, 1//1) => 6);

# Share of each category among the 3,591 HRS 2002 responses (percent), Kimball, Sahm, and Shapiro (2008), Table 2 -
const HRS_2002_SHARE = Dict(1 => 44.8, 2 => 18.6, 3 => 15.3, 4 => 9.6, 5 => 6.1, 6 => 5.6);

# Our two refinement questions: the next cut for each range inside a category -
# Each cut sits near the middle of its range, rounded to a whole number of USD 2,500 steps.
const REFINEMENT_NEXT_CUT = Dict(
    (0//1, 1//10) => 1//20,     # category 1: 5%
    (0//1, 1//20) => 1//40,     #   then 2.5%
    (1//20, 1//10) => 3//40,    #   or 7.5%
    (1//10, 1//5) => 3//20,     # category 2: 15%
    (1//10, 3//20) => 1//8,     #   then 12.5%
    (3//20, 1//5) => 7//40,     #   or 17.5%
    (1//5, 1//3) => 1//4,       # category 3: 25%
    (1//5, 1//4) => 9//40,      #   then 22.5%
    (1//4, 1//3) => 3//10,      #   or 30%
    (1//3, 1//2) => 2//5,       # category 4: 40%
    (1//3, 2//5) => 7//20,      #   then 35%
    (2//5, 1//2) => 9//20,      #   or 45%
    (1//2, 3//4) => 3//5,       # category 5: 60%
    (1//2, 3//5) => 11//20,     #   then 55%
    (3//5, 3//4) => 27//40);    #   or 67.5%
const NUMBER_OF_REFINEMENTS = 2; # category 6 has none

"""
    utility(w::Float64, r̄::Float64) -> Float64

Power utility of income `w` (in units of the sure income) with relative risk aversion `r̄`,
written as (w^(1-r̄) - 1)/(1 - r̄) so that it equals ln w at r̄ = 1 and U(1) = 0 for every r̄.
"""
function utility(w::Float64, r̄::Float64)::Float64
    abs(1 - r̄) < 1e-10 && return log(w); # the r̄ → 1 limit
    return expm1((1 - r̄)*log(w))/(1 - r̄); # expm1 keeps precision when (1 - r̄) log w is small
end

"""
    indifference_risk_aversion(δ::Real) -> Float64

The relative risk aversion r̄⋆ at which a 50-50 chance of doubling income or cutting it by
the fraction `δ` has a certainty equivalent equal to the sure income:
(1/2) U(2) + (1/2) U(1 - δ) = U(1) = 0. The expected-utility gain of the gamble falls as r̄
rises, so bisection finds the single root. A zero cut is pure upside (r̄⋆ = ∞), and at a
100% cut only a risk-neutral client (r̄⋆ = 0) is indifferent.
"""
function indifference_risk_aversion(δ::Real)::Float64
    δ == 0 && return Inf;
    δ == 1 && return 0.0;
    gain(r̄) = 0.5*utility(2.0, r̄) + 0.5*utility(1.0 - Float64(δ), r̄); # expected-utility gain of the gamble
    (low, high) = (0.0, 1000.0); # gain(low) > 0 > gain(high) for every cut asked
    for _ ∈ 1:200
        middle = (low + high)/2;
        gain(middle) > 0 ? (low = middle) : (high = middle); # still takes the gamble: r̄⋆ is higher
    end
    return (low + high)/2;
end

"""
    replay(answers::Vector{String}) -> NamedTuple

Replay the interview. Returns the questions asked (cut and answer), the final range of cuts
(largest accepted, smallest refused), the published category, and the next cut if the
answers stop before the interview is complete (`nothing` otherwise).
"""
function replay(answers::Vector{String})
    (accepted, refused) = (0//1, 1//1); # no cut accepted yet, and a 100% cut is never asked
    asked = Tuple{Rational{Int},String}[];
    category = nothing;
    refinements = 0;
    for answer ∈ answers
        answer ∈ ("first", "second") || error("answers are first or second, not $(answer)")

        # Find the cut this answer responds to -
        cut = if isnothing(category)
            PUBLISHED_NEXT_CUT[(accepted, refused)]
        elseif (category < 6) && (refinements < NUMBER_OF_REFINEMENTS)
            REFINEMENT_NEXT_CUT[(accepted, refused)]
        else
            error("the interview ended after $(length(asked)) answers, but $(length(answers)) were given")
        end
        isnothing(category) || (refinements += 1);

        # The second job accepts the cut, the first job refuses it -
        answer == "second" ? (accepted = cut) : (refused = cut);
        push!(asked, (cut, answer));

        # Check whether the published questions have placed the client -
        if isnothing(category) && haskey(CATEGORIES, (accepted, refused))
            category = CATEGORIES[(accepted, refused)];
        end
    end

    # Find the next question, if the interview is not complete -
    next_cut = if isnothing(category)
        PUBLISHED_NEXT_CUT[(accepted, refused)]
    elseif (category < 6) && (refinements < NUMBER_OF_REFINEMENTS)
        REFINEMENT_NEXT_CUT[(accepted, refused)]
    else
        nothing
    end
    return (asked = asked, accepted = accepted, refused = refused, category = category, next_cut = next_cut);
end

# Format a cut as a percentage and an income in dollars with thousands separators -
percent(δ) = @sprintf("%.1f%%", 100*Float64(δ));
dollars(x) = "\$" * reverse(join(Iterators.partition(reverse(string(round(Int, x))), 3), ",")); # 66667 → $66,667
low_income(δ) = dollars(SURE_INCOME*(1 - Float64(δ))); # the risky job's income after the cut

# Read the options -
options = Dict{String,String}();
for arg ∈ ARGS
    startswith(arg, "--") || error("options look like --answers=first,second, not $(arg)")
    key, value = occursin("=", arg) ? split(arg[3:end], "=", limit = 2) : (arg[3:end], "true");
    options[String(key)] = String(value);
end
haskey(options, "answers") || error("give the answers in order, e.g. --answers=first,first,second")
answers = lowercase.(String.(strip.(split(options["answers"], ","))));
dry_run = haskey(options, "dry-run");

# Replay the interview and print the questions asked -
result = replay(answers);
println("\nIncome-gamble interview: a sure $(dollars(SURE_INCOME)) a year, or 50-50 double it or cut it\n")
for (k, (cut, answer)) ∈ enumerate(result.asked)
    @printf("  Q%d  cut %6s (low income %s)   answer: %s job\n", k, percent(cut), low_income(cut), answer);
end

# Stop here if the interview is not complete -
if !isnothing(result.next_cut)
    @printf("\nNext question: cut %s, so the second job pays %s or %s a year.\n",
        percent(result.next_cut), dollars(2*SURE_INCOME), low_income(result.next_cut));
    exit(0);
end

# Bracket the relative risk aversion -
r̄_low = indifference_risk_aversion(result.refused); # refusing a cut means r̄ ≥ r̄⋆(cut)
r̄_high = indifference_risk_aversion(result.accepted); # accepting a cut means r̄ ≤ r̄⋆(cut)
@printf("\nPublished category: %d of 6. HRS 2002 share of respondents: %.1f%%\n",
    result.category, HRS_2002_SHARE[result.category]);
@printf("Range of cuts: accepts %s, refuses %s\n",
    result.accepted == 0 ? "none" : percent(result.accepted), result.refused == 1 ? "none" : percent(result.refused));
@printf("Relative risk aversion: %.2f < r̄ < %s, so A lies in the same range\n",
    r̄_low, isinf(r̄_high) ? "∞" : @sprintf("%.2f", r̄_high));

# Write the file the CAL example reads -
if !dry_run
    path_to_data = joinpath(@__DIR__, "..", "data");
    output = Dict("income_gamble" => Dict(
        "answers" => answers,
        "largest_accepted_cut" => Float64(result.accepted),
        "smallest_refused_cut" => Float64(result.refused),
        "category" => result.category,
        "risk_aversion_low" => r̄_low,
        "risk_aversion_high" => r̄_high,
        "source" => "Barsky, Juster, Kimball, and Shapiro (1997); categories of Kimball, Sahm, and Shapiro (2008)",
        "created" => string(today())));
    open(joinpath(path_to_data, "my-risk-aversion.toml"), "w") do io
        TOML.print(io, output);
    end
    println("\nWrote data/my-risk-aversion.toml")
end
