using Test
using VLQuantitativeFinancePackage

@testset "fixed income" begin

    @testset "discount factors" begin
        dd = discount(DiscreteCompoundingModel(), 0.06, 4; λ = 2)
        @test length(dd) == 5                     # keys 0:4
        @test isapprox(dd[0], 1.0; atol = 1e-12)
        for i ∈ 0:4
            @test isapprox(dd[i], (1 + 0.06/2)^i; atol = 1e-12)
        end

        dc = discount(ContinuousCompoundingModel(), 0.06, 4; λ = 2)
        for i ∈ 0:4
            @test isapprox(dc[i], exp(0.06 * i / 2); atol = 1e-12)
        end
    end

    @testset "zero coupon pricing + compounding limit" begin
        # discrete, n = 2: P = par / (1 + r/n)^(nT)
        z = build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, rate = 0.05, T = 2.0, n = 2)) |> DiscreteCompoundingModel()
        @test isapprox(z.price, 100.0 / (1 + 0.05/2)^4; atol = 1e-10)
        @test isapprox(z.cashflow[0], -z.price; atol = 1e-10)
        @test isapprox(z.cashflow[1], 100.0; atol = 1e-12)

        # continuous: P = par * exp(-rT)
        zc = build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, rate = 0.05, T = 2.0, n = 2)) |> ContinuousCompoundingModel()
        @test isapprox(zc.price, 100.0 * exp(-0.05 * 2.0); atol = 1e-10)

        # compounding-gap asymptotics: discrete price ↓ continuous price as n grows
        p1   = (build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, rate = 0.05, T = 2.0, n = 1))   |> DiscreteCompoundingModel()).price
        p365 = (build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, rate = 0.05, T = 2.0, n = 365)) |> DiscreteCompoundingModel()).price
        @test p1 > p365 > zc.price
        @test isapprox(p365, zc.price; atol = 1e-2)
    end

    @testset "coupon security pricing" begin
        # at par: coupon rate == yield (discrete) → price == par
        atpar = build(MyUSTreasuryCouponSecurityModel, (par = 100.0, rate = 0.04, coupon = 0.04, T = 2.0, λ = 2)) |> DiscreteCompoundingModel()
        @test isapprox(atpar.price, 100.0; atol = 1e-8)

        # general case vs annuity closed form: y = rate/λ, N = λT, C = (coupon/λ)par
        b = build(MyUSTreasuryCouponSecurityModel, (par = 100.0, rate = 0.05, coupon = 0.06, T = 3.0, λ = 2)) |> DiscreteCompoundingModel()
        y = 0.05 / 2
        N = 6
        C = 3.0
        expected = C * (1 - (1 + y)^(-N)) / y + 100.0 * (1 + y)^(-N)
        @test isapprox(b.price, expected; atol = 1e-8)
        @test length(b.cashflow) == N + 1
        @test isapprox(b.cashflow[0], -b.price; atol = 1e-10)

        # continuous compounding vs directly-summed closed form
        bc = build(MyUSTreasuryCouponSecurityModel, (par = 100.0, rate = 0.05, coupon = 0.06, T = 3.0, λ = 2)) |> ContinuousCompoundingModel()
        expected_c = sum(C * exp(-0.05 * i / 2) for i ∈ 1:N) + 100.0 * exp(-0.05 * 3.0)
        @test isapprox(bc.price, expected_c; atol = 1e-8)
    end

    @testset "STRIPS" begin
        parent = build(MyUSTreasuryCouponSecurityModel, (par = 100.0, rate = 0.05, coupon = 0.05, T = 2.0, λ = 2))
        strips = VLQuantitativeFinancePackage.strip(parent)
        @test length(strips) == 5                          # N = λT = 4 coupon strips + 1 principal strip
        for i ∈ 1:4
            @test isapprox(strips[i].par, 2.5; atol = 1e-12)   # (coupon/λ)*par
            @test isapprox(strips[i].T, i / 2; atol = 1e-12)
        end
        @test isapprox(strips[5].par, 100.0; atol = 1e-12)
        @test isapprox(strips[5].T, 2.0; atol = 1e-12)
    end

    @testset "YTM round trips" begin
        # continuous: price set from known rate, recover it
        zc = build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, T = 2.0, n = 2, price = 100.0 * exp(-0.04 * 2.0)))
        @test isapprox(YTM(zc, ContinuousCompoundingModel()), 0.04; atol = 1e-4)

        # discrete: price and YTM should be consistent when both use the same n parameter (B6)
        z_discrete = build(MyUSTreasuryZeroCouponBondModel, (par = 100.0, rate = 0.05, T = 2.0, n = 2)) |> DiscreteCompoundingModel()
        @test isapprox(YTM(z_discrete, DiscreteCompoundingModel()), 0.05; atol = 1e-4)
    end

    @testset "interest-rate lattice populate/expectation/variance" begin
        m = build(MySymmetricBinaryInterestRateLatticeModel, (u = 1.1, d = 0.9, p = 0.5, rₒ = 0.05, T = 2)) |> populate
        @test length(m.data) == 6                      # levels 0,1,2 → 1+2+3 nodes
        @test isapprox(m.data[0].rate, 0.05; atol = 1e-12)
        @test isapprox(m.data[1].rate, 0.055; atol = 1e-12)   # up
        @test isapprox(m.data[2].rate, 0.045; atol = 1e-12)   # down

        E = expectation(m)
        @test isapprox(E[1], 0.5 * 0.055 + 0.5 * 0.045; atol = 1e-12)
        V = variance(m)
        @test isapprox(V[0], 0.0; atol = 1e-12)
        @test isapprox(V[1], 0.5 * (0.055^2 + 0.045^2) - 0.05^2; atol = 1e-12)
    end

    @testset "rate-lattice solve backward induction" begin
        m = build(MySymmetricBinaryInterestRateLatticeModel, (u = 1.1, d = 0.9, p = 0.5, rₒ = 0.05, T = 2)) |> populate
        m = solve(m; Vₚ = 100.0)
        # leaves = 100; level-1: 100/1.055, 100/1.045; root = 0.5*(sum)/1.05 = 90.704957…
        @test isapprox(m.data[1].price, 100.0 / 1.055; atol = 1e-8)
        @test isapprox(m.data[2].price, 100.0 / 1.045; atol = 1e-8)
        @test isapprox(m.data[0].price, 0.5 * (100.0 / 1.055 + 100.0 / 1.045) / 1.05; atol = 1e-8)
    end
end
