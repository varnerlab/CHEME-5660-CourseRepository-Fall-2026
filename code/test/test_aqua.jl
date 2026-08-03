using Test
using VLQuantitativeFinancePackage
using Aqua

@testset "Aqua QA battery" begin
    Aqua.test_all(VLQuantitativeFinancePackage)
end
