# Fixed Income Treasury Securities
Fixed income securities are financial instruments that pay a fixed amount of interest over a specified period of time. The most common fixed income securities are bonds, which are issued by governments, municipalities, and corporations. The fixed income market is one of the largest financial markets in the world, and it plays a critical role in the global economy.

## Discounting model
In the `VLQuantitativeFinancePackage` we allow computing the present value of a cash flow stream using a discounting model. The present value of a cash flow stream can be computed using a [`ContinuousCompoundingModel`](@ref) or a [`DiscreteCompoundingModel`](@ref).

```@docs
VLQuantitativeFinancePackage.DiscreteCompoundingModel
VLQuantitativeFinancePackage.ContinuousCompoundingModel
```

Using the [`DiscreteCompoundingModel`](@ref) and [`ContinuousCompoundingModel`](@ref) types, we can compute the discount factors using the `discount` function. The `discount` function takes a discounting model, a discount rate, and the number of periods as input arguments and returns the discount factors for each period as a [Dictionary](https://docs.julialang.org/en/v1/base/collections/#Base.Dict) object.

```@docs
VLQuantitativeFinancePackage.discount(model::AbstractCompoundingModel, rate::Float64, periods::Int; 
    λ::Int64 = 2)
```

## Treasury secruity model types
We model [United States Treasury debt securities](https://www.treasurydirect.gov), e.g., [Treasury bills](https://www.treasurydirect.gov/marketable-securities/treasury-bills/), [Treasury notes](https://www.treasurydirect.gov/marketable-securities/treasury-notes/), and [Treasury bonds](https://www.treasurydirect.gov/marketable-securities/treasury-bonds/) using 
the [`MyUSTreasuryZeroCouponBondModel`](@ref) and [`MyUSTreasuryCouponSecurityModel`](@ref) types, which are subtypes of the `AbstractTreasuryDebtSecurity` abstract type.  

```@docs
VLQuantitativeFinancePackage.MyUSTreasuryZeroCouponBondModel
VLQuantitativeFinancePackage.MyUSTreasuryCouponSecurityModel
VLQuantitativeFinancePackage.build(model::Type{MyUSTreasuryZeroCouponBondModel}, data::NamedTuple)
VLQuantitativeFinancePackage.build(model::Type{MyUSTreasuryCouponSecurityModel}, data::NamedTuple)
```

## Computing Treasury security prices
To compute the price of a Treasury security, we use the [`price`](@ref) function that takes a `AbstractTreasuryDebtSecurity` object and a discounting model as input arguments. We construct [`MyUSTreasuryZeroCouponBondModel`](@ref) and [`MyUSTreasuryCouponSecurityModel`](@ref) objects by specifying the maturity date, the face value of the bond the effective annual interest rate and other data that are specific to the bill, note or bond in a `build` function where the data is specified in a [NamedTuple](https://docs.julialang.org/en/v1/base/base/#Core.NamedTuple) format. 


```@docs
VLQuantitativeFinancePackage.price
```

### Short-cut syntax
We also provide a short-cut syntax to compute the price of a Treasury security which indirectly calls the `price` function. The short-cut syntax allows the user to specify the data required to construct a `AbstractTreasuryDebtSecurity` object, and then pass the data to the `price` function in a single call. 

The short-cut syntax is as follows:
```julia
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_discrete_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_continuous_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryZeroCouponBondModel) = _price_discrete_compounding(model::MyUSTreasuryZeroCouponBondModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryZeroCouponBondModel) = _price_continuous_compounding(model::MyUSTreasuryZeroCouponBondModel)
```

To use the short-cut syntax, the user must first construct a `AbstractTreasuryDebtSecurity` object using the `build` function and then pass the object to the short-cut syntax function. For example, to compute the price of a 20-year Treasury bond with a coupon rate of 1.750%, a yield (discount rate) of 1.850%, two coupon payments per year, and a face value of 100 USD, the user can use the following code:

```julia
test_bond = build(MyUSTreasuryCouponSecurityModel, (
    T = 20.0, rate = 0.01850, coupon = 0.01750, λ = 2, par = 100.0
)) |> discount_model;
```

where the `discount_model` refers to either a [`DiscreteCompoundingModel`](@ref) or a [`ContinuousCompoundingModel`](@ref) instance.


## Term structure of interest rates
Fill me in
    
```@docs
VLQuantitativeFinancePackage.MySymmetricBinaryInterestRateLatticeModel
VLQuantitativeFinancePackage.MyBinaryInterestRateLatticeNodeModel
VLQuantitativeFinancePackage.build(model::Type{MySymmetricBinaryInterestRateLatticeModel}, data::NamedTuple)
VLQuantitativeFinancePackage.populate(model::MySymmetricBinaryInterestRateLatticeModel)
VLQuantitativeFinancePackage.expectation(model::MySymmetricBinaryInterestRateLatticeModel)
VLQuantitativeFinancePackage.variance(model::MySymmetricBinaryInterestRateLatticeModel)
```

## Separating the principal and interest payments
[Registered Interest and Principal of Securities (STRIPS) bonds](https://en.wikipedia.org/wiki/United_States_Treasury_security#STRIPS) are a unique type of fixed-income investment instrument that provides investors with an alternative way to access the coupon payments of Treasury securities. STRIPS bonds are created by separating a Treasury securities coupon and principal components and trading them as individual  zero-coupon securities. This process allows investors to purchase and trade the coupon or principal components separately, providing greater flexibility in managing their investment portfolios.

For example, a 5-year Treasury note with annual coupon payments of $C$ USD and a face (par) value of $V_{P}$ (USD)
can be stripped into six separate zero-coupon securities, i.e., five zero-coupon bonds, each with face values of $C$ 
and maturity of $T$= 1,2,3,4 and 5 years, and a six security with face  (par) value of $V_{P}$ USD with a duration of $T$ = 5 years. In the general case, a treasury note or bond with $N=\lambda{T}$ coupon payments, where $T$ denotes the maturity in years, and $\lambda$ represents the number of coupon payments per year, can be stripped into $N+1$ separate zero-coupon securities.

```@docs
VLQuantitativeFinancePackage.strip
VLQuantitativeFinancePackage.YTM
```
