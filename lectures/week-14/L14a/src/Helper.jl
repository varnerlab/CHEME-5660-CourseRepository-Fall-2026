# Helper.jl: helpers for the L14a examples (the pick days and the γ basket). Loaded by Include.jl.

"""
    pick_days(ξ::Vector{Float64}; repick_interval::Int)::NamedTuple

The days on which we pick a new γ basket, and the reason for each pick. The first day is always a pick day.
After that, we pick again on a day when one of two things happens:

- __Scheduled:__ `repick_interval` trading days have passed since the last pick.
- __Market turn:__ the market state is on the other side of zero from its value on the last pick day. A falling
  market has ξ > 0, and a rising market has ξ ≤ 0, so a market state of exactly zero counts as rising.

When both happen on the same day, the pick counts as scheduled.

### Arguments
- `ξ::Vector{Float64}`: the market state on each trading day of the run, in order (dimensionless).
- `repick_interval::Int`: the trading days between scheduled picks.

### Returns
- `NamedTuple` with two fields:
  - `day::Vector{Int}`: the positions in `ξ` of the pick days, in increasing order. The first entry is `1`.
  - `reason::Vector{String}`: the reason for each pick: `"first"`, `"scheduled"` or `"market turn"`.

Throws `ArgumentError` when `ξ` is empty or `repick_interval < 1`.

### Example
```julia
picks = pick_days(ξ_run; repick_interval = 21);
picks.day[2] # the position of the second pick day in ξ_run
```
"""
function pick_days(ξ::Vector{Float64}; repick_interval::Int)::NamedTuple

    # check the inputs -
    if length(ξ) == 0
        throw(ArgumentError("the market state ξ needs at least one day"));
    end
    if repick_interval < 1
        throw(ArgumentError("repick_interval must be at least 1 trading day"));
    end

    # initialize: the first day is always a pick day -
    day = Int[]; # positions of the pick days in ξ
    reason = String[]; # the reason for each pick
    push!(day, 1);
    push!(reason, "first");
    last_pick = 1; # position of the last pick day
    falling_at_last_pick = ξ[1] > 0; # true when the market was falling on the last pick day

    # walk through the remaining days, and pick when the schedule or the market state says so -
    for k ∈ 2:length(ξ)
        days_since_last_pick = k - last_pick; # trading days since the last pick
        falling_now = ξ[k] > 0; # true when the market is falling today
        if days_since_last_pick >= repick_interval
            push!(day, k);
            push!(reason, "scheduled");
            last_pick = k;
            falling_at_last_pick = falling_now;
        elseif falling_now != falling_at_last_pick
            push!(day, k);
            push!(reason, "market turn"); # the market turned from rising to falling, or from falling to rising
            last_pick = k;
            falling_at_last_pick = falling_now;
        end
    end

    # checks -
    @assert day[1] == 1 "the first day must be a pick day"
    @assert length(day) == length(reason) "one reason per pick day"
    @assert issorted(day) "the pick days must be in increasing order"

    # return -
    return (day = day, reason = reason);
end

"""
    gamma_basket(γ::Vector{Float64}, sector::Vector{String}; N::Int)::Vector{Int}

The γ basket of one pick day: the `N` stocks with the highest γ score in each sector. A sector with `N` stocks
or fewer gives all of its stocks. When two stocks in a sector have the same score, the one that comes first in
`γ` goes first. The sign of the score does not matter here: the basket holds the `N` highest scores, even if
some of them are negative.

### Arguments
- `γ::Vector{Float64}`: the γ score of each stock on the pick day (dimensionless, between `-1` and `1`).
- `sector::Vector{String}`: the GICS sector of each stock, in the same order as `γ`.
- `N::Int`: the number of stocks to pick in each sector.

### Returns
- `Vector{Int}`: the positions in `γ` of the picked stocks, in increasing order.

Throws `ArgumentError` when `γ` and `sector` have different lengths or `N < 1`.

### Example
```julia
basket = gamma_basket(γ_updated[1, :], md.sector; N = 3);
md.tickers[basket] # the tickers of the picked stocks
```
"""
function gamma_basket(γ::Vector{Float64}, sector::Vector{String}; N::Int)::Vector{Int}

    # check the inputs -
    if length(γ) != length(sector)
        throw(ArgumentError("γ and sector must have one entry per stock"));
    end
    if N < 1
        throw(ArgumentError("N must be at least 1"));
    end

    # initialize: the sectors, each listed once, in alphabetical order -
    sector_names = sort(unique(sector));
    basket = Int[]; # positions of the picked stocks

    # pick the N highest scores in each sector -
    for s ∈ sector_names
        members = findall(sector .== s); # positions of the stocks in sector s
        scores = γ[members]; # their γ scores
        order = sortperm(scores; rev = true); # highest score first; ties keep the order of γ
        number_to_pick = min(N, length(members)); # a small sector gives all of its stocks
        for k ∈ 1:number_to_pick
            push!(basket, members[order[k]]);
        end
    end
    sort!(basket); # increasing order, as the positions in γ

    # checks -
    @assert length(unique(basket)) == length(basket) "each stock can be picked once"

    # return -
    return basket;
end
