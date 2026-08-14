using VLQuantitativeFinancePackage
using Test

@testset "VLQuantitativeFinancePackage.jl" verbose = true begin
    include("test_fixed_income.jl")
    include("test_lattice.jl")
    include("test_greeks.jl")
    include("test_portfolio.jl")
    include("test_adaptive_portfolio.jl")
    include("test_order_book.jl")
    include("test_stochastic.jl")
    include("test_smoke.jl")
    include("test_aqua.jl")
end
