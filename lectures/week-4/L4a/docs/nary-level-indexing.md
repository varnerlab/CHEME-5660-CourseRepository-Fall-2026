# N-ary lattice level indexing

These helpers are defined in the **Helper Functions** section of
[the N-ary lattice example](../CHEME-5660-L4a-Example-N-Ary-Lattice-Fall-2026.ipynb).
Run their definition cell before calling them.

The argument `i` is a nonnegative integer counting lattice steps, and `m` is
the number of branches (an integer at least two). They correspond to `t` and
`m` in the lecture. Both arguments and return values are dimensionless counts.
The helpers assume valid arguments; they do not check these bounds.

## nodes_at_level

```julia
nodes_at_level(i::Integer, m::Integer)
```

Returns `binomial(i + m - 1, i)`, the number of nonnegative branch-count
vectors whose entries sum to `i`. This counts states, which need not have
distinct prices. At the root (`i = 0`), it returns one.

## level_offset

```julia
level_offset(i::Integer, m::Integer)
```

Returns the total number of nodes in levels `0` through `i - 1`: zero at the
root and `binomial(i + m - 1, i - 1)` otherwise. Since the model uses
zero-based node IDs, the returned integer is also the first node ID at level `i`.

For example, with three branches, level two has six states and starts at
node ID four. Its node IDs are `4:9`. These are dictionary keys, not
one-based Julia array positions.
