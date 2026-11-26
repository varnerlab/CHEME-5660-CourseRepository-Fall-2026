# SGOV is a fund of short-term T-bills. The stress-test generator does not model it (the practicum grows it at the
# T-bill rate), so L15a leaves it out of the universe -
const _L15A_LEFT_OUT = ["SGOV"]

"""
    _l15a_tbill_rates(path::AbstractString, dates::Vector{Date})::Vector{Float64}

The risk-free rate (yr⁻¹) on each day of `dates`, by the practicum's rule (`tbill_rate` in the practicum's
`src/Data.jl`): the latest DTB3 rate in the file at `path` dated on or before the day, divided by 100. A day with
no rate in the file (a weekend or a bond-market holiday) takes the rate of the last day before it. Throws an
`ArgumentError` when a day comes before the first rate in the file.
"""
function _l15a_tbill_rates(path::AbstractString, dates::Vector{Date})::Vector{Float64}
    table = sort(CSV.read(path, DataFrame; comment="#"), :date)
    rates = zeros(length(dates))
    for k in eachindex(dates)
        row = searchsortedlast(table.date, dates[k])
        if row == 0
            throw(ArgumentError("the T-bill file has no rate on or before $(dates[k])"))
        end
        rates[k] = table.DTB3[row] / 100
    end
    return rates
end

"""
    load_l15a_market(data_dir::AbstractString; start::Date, stop::Date)::MyMarketData

Load trading days from `start` through `stop`, inclusive, from the practicum's price file `prices.jld2`: the daily
closes and opens (USD/share) and volumes (shares/day).

The universe is the practicum's: every ticker with a close on every trading day from its first close through
the last day of the snapshot, except SGOV (`_L15A_LEFT_OUT`). A ticker that lists after the first day has no
close, open, or volume (`NaN`) before its first trading day. The universe stays the same when the requested dates
change. ETFs share the sector label `ETF`. SPY supplies the benchmark and hedge prices.

The risk-free rate (yr⁻¹) is the practicum's: each day takes the latest 3-month T-bill rate in `tbill.csv` (DTB3,
percent per year) dated on or before that day, divided by 100 (`_l15a_tbill_rates`).
"""
function load_l15a_market(data_dir::AbstractString; start::Date, stop::Date)::MyMarketData
    # Read the aligned arrays and find the requested trading days -
    bars = JLD2.load(joinpath(data_dir, "prices.jld2"));
    dates = bars["dates"];
    tickers = bars["tickers"];
    open = bars["open"];
    close = bars["close"];
    volume = bars["volume"];
    rows = searchsortedfirst(dates, start):searchsortedlast(dates, stop);
    if isempty(rows)
        throw(ArgumentError("no L15a trading days from $(start) through $(stop)"));
    end

    # Keep the same universe even when the caller asks for a shorter date range -
    universe = CSV.read(joinpath(data_dir, "universe.csv"), DataFrame; comment="#");
    sector_of = Dict{String,String}();
    for row in eachrow(universe)
        sector_of[row.ticker] = row.sector;
    end
    columns = Int[];
    sectors = String[];
    spy = findfirst(==("SPY"), tickers);
    if spy === nothing || !all(isfinite, view(close, :, spy))
        throw(ArgumentError("SPY needs a close on every L15a trading day"));
    end
    for j in sortperm(tickers)
        first_close = findfirst(isfinite, view(close, :, j));
        if first_close === nothing || !all(isfinite, view(close, first_close:size(close, 1), j))
            continue;
        end
        ticker = tickers[j];
        if ticker in _L15A_LEFT_OUT
            continue;
        end
        if j != spy
            if !haskey(sector_of, ticker)
                throw(ArgumentError("$(ticker) has no entry in universe.csv"));
            end
            push!(columns, j);
            push!(sectors, sector_of[ticker]);
        end
    end

    # SPY gets separate prices and stays out of the baskets -
    dates = dates[rows];
    rates = _l15a_tbill_rates(joinpath(data_dir, "tbill.csv"), dates);
    return build(MyMarketData, (dates=dates, tickers=tickers[columns], open=open[rows, columns],
        close=close[rows, columns], volume=volume[rows, columns], spy_open=open[rows, spy],
        spy_close=close[rows, spy], sector=sectors, g_f=rates));
end

# The strategy files return tickers. The study loop uses their market-data column indices.
function _l15a_screen_columns(md::MyMarketData, selected::AbstractVector{String})::Vector{Int}
    return sort!(Int.(indexin(selected, md.tickers)));
end

"""
    closest_book(p::MyAllocationProblem, target::Vector{Float64}; long_cap::Float64,
        short_cap::Float64)::MyAllocationResult

Find the book whose weights are closest to the target weights `target` (dimensionless, one per column of `p`)
under the shared trading limits of `p` and the long and short caps. The solve minimizes the sum of the squared
gaps between the book's weights and the target weights. The columns follow three rules:

- A column with a positive target can only be held long, and a column with a negative target can only be held
  short.
- A hedge-pool column with a zero target can be held long, with a target of `0`, so the book can meet the β limit.
- Every other column holds no shares.

The long weights add to at most `long_cap`, the short weights add to at most `short_cap`, and the budget row of
`add_shared_constraints!` keeps cash at or above zero. The single-name cap, the sector cap, the β limit, the
volatility cap, and the spread-cost budget of `p` also apply. An all-zero target leaves the book in cash with the
status `:no_preferred`. When no solver meets the limits, the book keeps the holdings `n_prev` of `p`, with the
status `:infeasible` or `:solver_failed`.

### Arguments
- `p::MyAllocationProblem`: the decision's allocation problem.
- `target::Vector{Float64}`: the target weight of each column (dimensionless).
- `long_cap::Float64`: the largest sum of the long weights (dimensionless).
- `short_cap::Float64`: the largest sum of the short weights (dimensionless).

### Returns
- `MyAllocationResult`: the shares, the weights, the status, and the invested fraction of the book.
"""
function closest_book(p::MyAllocationProblem, target::Vector{Float64}; long_cap::Float64,
        short_cap::Float64)::MyAllocationResult

    # check the inputs -
    _check_problem(p)
    K = length(p.γ)
    if length(target) != K
        throw(DimensionMismatch("target must have length $(K), got $(length(target))"))
    end

    # sort the columns into the long side, the short side, and the columns that hold no shares -
    long_side = Int[]
    short_side = Int[]
    for i in 1:K
        if target[i] > 0
            push!(long_side, i)
        elseif target[i] < 0
            push!(short_side, i)
        elseif p.hedge[i] == true
            push!(long_side, i)
        end
    end

    # an all-zero target holds cash -
    if all(iszero, target)
        return _result(p, zeros(K), :no_preferred)
    end

    # solve for the closest book (Clarabel, then SCS) -
    x, status = _solve_with_fallback(function (opt)
        return _closest_book_model(opt, p, target, long_side, short_side, long_cap, short_cap)
    end)
    if status != :optimal
        return _result(p, copy(p.constraints.n_prev), status)
    end

    # the long side holds positive shares and the short side negative shares -
    n = zeros(K)
    for (k, i) in enumerate(long_side)
        n[i] = x[k]
    end
    for (k, i) in enumerate(short_side)
        n[i] = -x[length(long_side) + k]
    end
    return _result(p, n, :optimal)
end

# The JuMP model of `closest_book` for one solver `opt`. Returns the model and its share variables: the long side
# first, then the short side (both in shares, at or above zero).
function _closest_book_model(opt, p::MyAllocationProblem, target::Vector{Float64}, long_side::Vector{Int},
        short_side::Vector{Int}, long_cap::Float64, short_cap::Float64)
    m = Model(opt)
    set_silent(m)
    K = length(target)
    x_long = @variable(m, [1:length(long_side)], lower_bound = 0.0)
    x_short = @variable(m, [1:length(short_side)], lower_bound = 0.0)

    # the signed shares of every column; a column on neither side stays at zero -
    n = AffExpr[AffExpr(0.0) for _ in 1:K]
    for (k, i) in enumerate(long_side)
        n[i] = AffExpr(0.0, x_long[k] => 1.0)
    end
    for (k, i) in enumerate(short_side)
        n[i] = AffExpr(0.0, x_short[k] => -1.0)
    end

    # the shared limits, then the long and short caps -
    w = add_shared_constraints!(m, n, p; signed=true)
    long_sum = AffExpr(0.0)
    for i in long_side
        add_to_expression!(long_sum, w[i])
    end
    short_sum = AffExpr(0.0)
    for i in short_side
        add_to_expression!(short_sum, -1.0, w[i])
    end
    if isempty(long_side) == false
        @constraint(m, long_sum <= long_cap)
    end
    if isempty(short_side) == false
        @constraint(m, short_sum <= short_cap)
    end

    # the sum of the squared gaps to the target weights -
    gap = QuadExpr()
    for i in vcat(long_side, short_side)
        add_to_expression!(gap, (w[i] - target[i])^2)
    end
    @objective(m, Min, gap)
    return m, vcat(x_long, x_short)
end

"""
    scaled_book(p::MyAllocationProblem, target::Vector{Float64})::MyAllocationResult

Find the largest multiple `c ≤ 1` of the target weights `target` (dimensionless, one per column of `p`, none
negative) that meets the shared trading limits of `p`. The columns with a positive target keep the weights
`c * target`, so their weights keep the target's proportions. The rest of the wealth stays in cash. A hedge-pool
column with a zero target can be held long, so the book can meet the β limit. With `c` fixed, a second solve holds
the least hedge that meets the limits. Every other column holds no shares.

The budget, the single-name cap, the sector cap, the β limit, the volatility cap, and the spread-cost budget of `p`
apply. An all-zero target leaves the book in cash with the status `:no_preferred`. When no solver meets the limits,
the book keeps the holdings `n_prev` of `p`, with the status `:infeasible` or `:solver_failed`.

### Arguments
- `p::MyAllocationProblem`: the decision's allocation problem.
- `target::Vector{Float64}`: the target weight of each column (dimensionless, at or above `0`).

### Returns
- `MyAllocationResult`: the shares, the weights, the status, and the invested fraction of the book.
"""
function scaled_book(p::MyAllocationProblem, target::Vector{Float64})::MyAllocationResult

    # check the inputs -
    _check_problem(p)
    K = length(p.γ)
    if length(target) != K
        throw(DimensionMismatch("target must have length $(K), got $(length(target))"))
    end
    if any(<(0.0), target)
        throw(ArgumentError("scaled_book: every target weight must be at or above 0"))
    end

    # the columns that follow the target, and the free hedge-pool columns -
    held = Int[]
    hedge = Int[]
    for i in 1:K
        if target[i] > 0
            push!(held, i)
        elseif p.hedge[i] == true
            push!(hedge, i)
        end
    end

    # an all-zero target holds cash -
    if isempty(held)
        return _result(p, zeros(K), :no_preferred)
    end

    # stage 1: the largest multiple of the target (Clarabel, then SCS) -
    x, status = _solve_with_fallback(function (opt)
        return _scaled_book_model(opt, p, target, held, hedge)
    end)
    if status != :optimal
        return _result(p, copy(p.constraints.n_prev), status)
    end
    c = x[1]
    n = zeros(K)
    for i in held
        n[i] = c * target[i] * p.W / p.prices[i]
    end
    for (k, i) in enumerate(hedge)
        n[i] = x[1 + k]
    end

    # stage 2: with the multiple fixed, hold the least hedge that meets the limits -
    if isempty(hedge) == false
        n, status = _min_hedge(p, n, held, hedge, zeros(length(hedge)))
        if status != :optimal
            return _result(p, copy(p.constraints.n_prev), status)
        end
    end
    return _result(p, n, :optimal)
end

# The JuMP model of stage 1 of `scaled_book` for one solver `opt`. Returns the model and its variables: the multiple
# c first, then the shares of the free hedge-pool columns.
function _scaled_book_model(opt, p::MyAllocationProblem, target::Vector{Float64}, held::Vector{Int},
        hedge::Vector{Int})
    m = Model(opt)
    set_silent(m)
    K = length(target)
    c = @variable(m, lower_bound = 0.0, upper_bound = 1.0)
    h = @variable(m, [1:length(hedge)], lower_bound = 0.0)

    # the shares of every column: the target columns move with c, and the others stay at zero -
    n = AffExpr[AffExpr(0.0) for _ in 1:K]
    for i in held
        n[i] = AffExpr(0.0, c => target[i] * p.W / p.prices[i])
    end
    for (k, i) in enumerate(hedge)
        n[i] = AffExpr(0.0, h[k] => 1.0)
    end

    # the shared limits, and the largest multiple with a small cost on the hedge weights -
    w = add_shared_constraints!(m, n, p)
    objective = AffExpr(0.0, c => 1.0)
    for i in hedge
        add_to_expression!(objective, -_HEDGE_TIEBREAK, w[i])
    end
    @objective(m, Max, objective)
    return m, vcat(c, h)
end
