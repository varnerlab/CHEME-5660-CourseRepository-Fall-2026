"""
`VLQuantitativeFinancePackage.WolframMarkets`: the reserve-clearing cellular-automaton market of the
Wolfram-rule market paper (J. D. Varner, github.com/varnerlab/Wolfram-markets-abm-paper, executed snapshot
at commit 33ebbaa).

Traders sit on a grid and update by a two-dimensional totalistic Wolfram rule over three states (Buy, Hold,
Sell). A ring of edge traders reads an exponential-moving-average band on the price and feeds that signal
into the grid, and the orders clear against a finite constant-product dealer whose cash-to-inventory ratio
is the price. The code is the paper's simulator, copied from the snapshot's `src/` with the edits listed
below.

Use it qualified: `import VLQuantitativeFinancePackage.WolframMarkets as WM`. Build a configuration with
`WM.build(WM.MyModelBConfiguration, data)` and run it with `WM.simulate` (or `WM.simulate_checked`, which
also asserts the conservation and price identities). `:reserve` is the supported clearing mechanism.

Non-verbatim edits to the snapshot files -
1. Wrapped in this module; `build` is imported from the course package so the constructors extend it.
2. Dropped Model A (open model) with its types, builders, `simulate` method and `Files.jl`, together with
   the unused `MyBandEdgeAgentModel`, `MyEndogenousPriceModel` and `MyModelBSimulation` types and builders.
3. Dropped the Following, FollowingMetrics, PaperStyle and StripPanels files (figures and advice only).
4. Removed the two ProgressMeter uses in the Model B `simulate` (no random draws involved).
5. The default of the `clearing` keyword is `:reserve` (the snapshot's default is `:legacy`, which is kept
   in place but is internal and undocumented).
6. `Runtime.jl` is `simulate_repaired` of the snapshot's `rebuild/RebuildRuntime.jl` as `simulate_checked`,
   without the ledger write.
7. Course addition, not a paper result: `Simulate.jl` accepts `boundary_mode = :random` with the keywords
   `random_edge_probabilities` and `random_edge_seed`. Only the edge-classification branch changes; the draws
   come from a separate `Xoshiro` stream (default seed `config.seed + 7919`), so the main RNG draw order and
   the parity SHA-256 fingerprints of the paper modes are untouched. The `boundary_mode` error message now
   names all three modes.
8. The `verbose` docstring line of `simulate` no longer claims a ProgressMeter bar (the keyword is a no-op
   since edit 4).
"""
module WolframMarkets

    # the course package's build: the constructors below add methods to it
    import ..VLQuantitativeFinancePackage: build

    # external dependencies -
    using Random
    using LinearAlgebra
    using Statistics
    using StatsBase
    using DataFrames

    # the simulator, in the snapshot's include order (Simulate.jl includes ReserveClearing.jl) -
    include(joinpath(@__DIR__, "Types.jl"))
    include(joinpath(@__DIR__, "Factory.jl"))
    include(joinpath(@__DIR__, "Wolfram.jl"))
    include(joinpath(@__DIR__, "Compute.jl"))
    include(joinpath(@__DIR__, "Simulate.jl"))
    include(joinpath(@__DIR__, "Runtime.jl"))
    include(joinpath(@__DIR__, "Course.jl"))

end
