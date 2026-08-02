# ── combinatorics helpers ──────────────────────────────────────────────────────
nodes_at_level(i::Integer, n::Integer) = binomial(i + n - 1, i)
level_offset(i::Integer, n::Integer) = i == 0 ? 0 : binomial(i + n - 1, i - 1) # start of level i

# Find level i s.t. offset(i) ≤ j < offset(i+1)
function level_of(j::Integer, n::Integer)
    @assert j ≥ 0 && n ≥ 2
    i = 0
    while true
        next_off = binomial(i + n, i)   # = level_offset(i+1, n)
        if j < next_off
            return i
        end
        i += 1
    end
end

# Unrank: given rank r at level i, return composition k⃗ (length n, sum = i), lex order
function unrank_comp(r::Integer, i::Integer, n::Integer)
    k = zeros(Int, n)
    rem = i
    rcur = r
    for m in 1:(n-1)
        km = 0
        while true
            c = binomial(rem - km + (n - m) - 1, (n - m) - 1)
            if rcur < c
                break
            end
            rcur -= c
            km += 1
        end
        k[m] = km
        rem -= km
    end
    k[n] = rem
    return k
end

# Rank: given composition k⃗ at level i, return its 0-based rank within that level (lex order)
function rank_comp(k::AbstractVector{<:Integer}, i::Integer, n::Integer)
    @assert length(k) == n
    @assert sum(k) == i
    rank = 0
    rem = i
    for m in 1:(n-1)
        km = k[m]
        for j in 0:(km-1)
            rank += binomial(rem - j + (n - m) - 1, (n - m) - 1)
        end
        rem -= km
    end
    return rank
end

# ── PACKAGE API BELOW ───────────────────────────────────────────────────────────────────--------- #
function children_indices(j::Integer, n::Integer; base::Integer=0)
    i  = level_of(j, n)
    r  = j - level_offset(i, n)              # rank within level i
    k  = unrank_comp(r, i, n)                # counts (k1,…,kn), sum = i
    off_next = level_offset(i + 1, n)

    out = Vector{Int}(undef, n)
    for m in 1:n
        k[m] += 1                            # bump one move for the child
        rc = rank_comp(k, i + 1, n)          # rank at next level
        out[m] = off_next + rc + base
        k[m] -= 1                            # restore
    end
    return out |> sort
end

function index_counts(j::Integer, n::Integer)
    i = level_of(j, n)
    r = j - level_offset(i, n)
    return i, unrank_comp(r, i, n) |> reverse
end

"""
    populate(model::MyGeneralAdjacencyRecombiningCommodityPriceTree, price::Float64, Δ::Array{Float64,1})

This function populates the price tree model with the given price and price change factors.
This method updates the model in place.

### Arguments
- `model::MyGeneralAdjacencyRecombiningCommodityPriceTree`: The price tree model to populate.
- `price::Float64`: The initial price to set at the root of the tree.
- `Δ::Array{Float64,1}`: The array of price change factors for each level of the tree.

"""
function populate(model::MyGeneralAdjacencyRecombiningCommodityPriceTree, 
    price::Float64, Δ::Array{Float64,1})::MyGeneralAdjacencyRecombiningCommodityPriceTree

    # initialize -
    P = Dict{Int64,NamedTuple}() 
    n = model.n; # branching factor
    h = model.h; # height of the tree
    Nₕ = binomial(h + n, h) # number of nodes in the tree

    # compute the commodity price -
    (_, k) = index_counts(0, n) # up, down, ....
    P[0] = (price = price, path = k) # set root price
    number_of_moves = length(Δ);
    for i ∈ 0:(Nₕ - 1)
        (_, k) = index_counts(i, n) # up, down, ....

        tmp = 1.0;
        for j ∈ 1:number_of_moves
            tmp *= Δ[j]^(k[j]) # accumulate the price factor for each move
        end
        P[i] = (price = price * tmp, path = k);
    end

    # update the model -
    model.data = P;

    # return the updated model -
    return model;
end
# -- PACKAGE API ABOVE ───────────────────────────────────────────────────────────────────--------- #