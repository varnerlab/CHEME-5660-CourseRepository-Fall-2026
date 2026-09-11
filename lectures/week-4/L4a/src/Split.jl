

# --- Cleaning & transforms ----------------------------------------------------

# Drop missings/non-finite, convert to Float64
function clean_growth_rates(g::AbstractVector{<:Real})
    out = Float64[]
    for x in g
        if x !== missing && isfinite(x)
            push!(out, float(x))
        end
    end
    @assert !isempty(out) "Input g contains no finite values."
    return out
end

# Movement factors for log-return growth rates: F = exp(g * Δt)
movement_factors_from_growth_rates(g::AbstractVector{<:Real}, dt::Real=1.0) =
    exp.(g .* dt)

# --- Bin edge constructors ----------------------------------------------------

# Equal-mass (quantile) edges; ensures strictly increasing edges
function compute_edges_quantile(v::AbstractVector{<:Real}, n::Int)
    @assert n ≥ 2 "n must be ≥ 2"
    qs = collect(LinRange(0.0, 1.0, n+1))
    edges = similar(qs, Float64)
    for (i,q) in enumerate(qs)
        edges[i] = quantile(v, q)
    end
    # Nudge ties upward so bins are well-ordered
    for i in 2:length(edges)
        if edges[i] <= edges[i-1]
            edges[i] = nextfloat(edges[i-1])
        end
    end
    return edges
end

# Equal-width edges over the data range
function compute_edges_equalwidth(v::AbstractVector{<:Real}, n::Int)
    @assert n ≥ 2 "n must be ≥ 2"
    rmin, rmax = extrema(v)
    if rmax == rmin
        δ = max(abs(rmin), 1.0) * 1e-12
        rmin -= δ; rmax += δ
    end
    return collect(range(rmin, rmax; length=n+1))
end

# --- Binning & aggregation ----------------------------------------------------

# Left-closed, right-open bins [e_{k-1}, e_k), except the last which is closed
function bin_index(x::Real, edges::AbstractVector{<:Real})
    i = searchsortedlast(edges, x)         # gives i with edges[i] ≤ x
    return clamp(i, 1, length(edges)-1)    # map to 1..n, last bin absorbs the top edge
end

function assign_bins(v::AbstractVector{<:Real}, edges::AbstractVector{<:Real})
    idx = Vector{Int}(undef, length(v))
    @inbounds for i in eachindex(v)
        idx[i] = bin_index(v[i], edges)
    end
    return idx
end

# Sum/average movement factors and counts per bin
function aggregate_bin_stats(factors::AbstractVector{<:Real},
                             idx::AbstractVector{Int}, n::Int)
    counts = zeros(Int, n)
    sums   = zeros(Float64, n)
    @inbounds for (b, f) in zip(idx, factors)
        counts[b] += 1
        sums[b]   += f
    end
    avg_factor = [c > 0 ? sums[k]/c : NaN for (k,c) in enumerate(counts)]
    freq       = [c / length(idx) for c in counts]
    return counts, sums, avg_factor, freq
end

# --- Main builder -------------------------------------------------------------

"""
    build_nary_lattice_from_growth_rate(g; n=3, dt=1.0, method=:quantile)

Construct an n-state one-step lattice from growth rates g (log-returns per unit time).

Inputs
- `g`      :: Vector of growth rates g_{j,j-1}
- `n`      :: number of next-day states (n ≥ 2)
- `dt`     :: Δt for your g definition (e.g., 1.0 for daily if g is per day)
- `method` :: :quantile (equal-mass bins) or :equalwidth (uniform in g space)

Returns NamedTuple:
- `edges`       :: bin edges in g-space (e₀ < … < eₙ)
- `avg_factor`  :: f_k = mean(exp(gΔt) | g ∈ bin k)
- `freq`        :: p_k = count_k / N
- `counts`      :: counts per bin
- `labels`      :: ["S1", …, "Sn"]
- `method`, `dt`, `N`
"""
function build_nary_lattice_from_growth_rate(g::AbstractVector{<:Real};
    n::Int=3, dt::Real=1.0, method::Symbol=:quantile)

    @assert n ≥ 2 "n must be ≥ 2"
    gv = clean_growth_rates(g)
    N  = length(gv)
    F  = movement_factors_from_growth_rates(gv, dt)

    edges = method === :quantile  ? compute_edges_quantile(gv, n) :
            method === :equalwidth ? compute_edges_equalwidth(gv, n) :
            error("method must be :quantile or :equalwidth")

    idx = assign_bins(gv, edges)
    counts, _, avg_factor, freq = aggregate_bin_stats(F, idx, n)
    empty_bins = findall(iszero, counts)
    isempty(empty_bins) || throw(ArgumentError(
        "Binning produced empty branches $(empty_bins); use fewer branches or a different binning method.",
    ))
    labels = ["S$(k)" for k in 1:n]

    return (edges=edges, avg_factor=avg_factor, freq=freq, counts=counts,
            labels=labels, method=method, dt=dt, N=N)
end

# --- Pretty printer (optional) -----------------------------------------------

"""
    print_lattice(summary; digits=6)

Display estimated branch parameters as a DataFrame using the course's compact
PrettyTables format. Round displayed values to `digits` decimal places without
changing the estimates. The final growth interval includes its upper boundary.
Returns `nothing`.
"""
function print_lattice(summary; digits=6)
    # Preserve the interval convention: left-closed, with the final upper edge included.
    m = length(summary.labels)
    intervals = [
        "[$(round(summary.edges[j]; digits=digits)), $(round(summary.edges[j+1]; digits=digits))" *
        (j == m ? "]" : ")") for j in 1:m
    ]

    # Keep each branch's factor, probability, and observation count together.
    table = DataFrame(
        branch = summary.labels,
        growth_interval = intervals,
        factor = summary.avg_factor,
        probability = summary.freq,
        observations = summary.counts,
    )

    println("N-ary lattice (method=$(summary.method), Δt=$(summary.dt), observations=$(summary.N))")
    pretty_table(table;
        formatters = [fmt__printf("%.$(digits)f", [3, 4])],
        table_format = TextTableFormat(borders=text_table_borders__compact))
    return nothing
end
