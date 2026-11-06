# Tests of the WolframMarkets submodule (the reserve-clearing cellular-automaton market), run in their own
# module so the qualified names stay out of the course package's namespace.
module WolframMarketsTests

using Test, SHA, Statistics
import VLQuantitativeFinancePackage
import VLQuantitativeFinancePackage.WolframMarkets as WM

@testset "WolframMarkets" begin
    include(joinpath(@__DIR__, "test_parity.jl"))
    include(joinpath(@__DIR__, "test_random_edges.jl"))
end

end # module
