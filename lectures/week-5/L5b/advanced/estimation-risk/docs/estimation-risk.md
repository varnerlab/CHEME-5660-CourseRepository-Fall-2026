# Estimation-risk portfolio functions

These helpers are defined in [EstimationRisk.jl](../src/EstimationRisk.jl) and
loaded by [Include.jl](../Include.jl). Return to the
[estimation-risk notebook](../CHEME-5660-L5b-Advanced-EstimationRisk-Fall-2026.ipynb).

All weights are dimensionless. Inputs use the same asset ordering. Covariance
matrices are assumed symmetric and positive definite.

<a id="gmv_closed"></a>
## `gmv_closed(Σ)`

`Σ` is an M × M growth-rate covariance matrix (inverse years squared).
Return M fully invested GMV weights, allowing negative weights. The function
solves a linear system and normalizes by the sum; it uses no mean-growth input.

<a id="tangent_closed"></a>
## `tangent_closed(g, Σ, g_f)`

`g` is a length-M vector of mean growth estimates and `g_f` is the risk-free
benchmark (both inverse years); `Σ` is the corresponding growth-rate covariance
(inverse years squared). Return the normalized inverse-covariance excess-growth
direction. A positive normalizer gives the maximum-Sharpe portfolio; a negative
normalizer gives the minimum-Sharpe portfolio, intentionally retained for this
diagnostic. Small nonzero normalizers are retained. An exactly zero normalizer
raises `DomainError`. The function infers the number of assets from the inputs.

<a id="gmv_long_only"></a>
## `gmv_long_only(g, Σ)`

`g` and `Σ` have the dimensions and units above. Return the minimum-variance
weights satisfying the budget and bounds 0 ≤ wᵢ ≤ 1, within solver tolerance.
The growth floor `minimum(g)` is met by every feasible long-only portfolio.
The helper uses the package's
[`build(...)`](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/portfolio/#VLQuantitativeFinancePackage.build-Tuple{Type{MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem},%20NamedTuple})
and [`solve(...)`](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/portfolio/#VLQuantitativeFinancePackage.solve-Tuple{MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem})
functions, with equal weights as the initial guess. Solver failures propagate.

<a id="tangent_long_only"></a>
## `tangent_long_only(g, Σ, g_f; number_of_points::Int = 31)`

Inputs have the dimensions and units above; `number_of_points` is the number
of target floors and must be at least two. Return the largest-Sharpe allocation
among the long-only GMV portfolio and successfully solved frontier candidates.
The target grid starts at the GMV mean and ends at `maximum(g) - 1e-4` inverse
years. The supplied data give an increasing target range. This is a grid
approximation, not an exact maximum-Sharpe optimization.

The baseline GMV solve must succeed. A sweep point is skipped when the package
solver raises an `AssertionError`; other exceptions propagate. Negative and
positive weight tolerances are those of the package solver.


<a id="hyperbola"></a>
## `hyperbola(g, Σ; maximum_growth::Real = 0.6, number_of_points::Int = 80)`

Evaluate the efficient minimum-variance frontier with short positions allowed.
`g` is a length-M mean-growth vector (inverse years); `Σ` is its M × M
symmetric positive-definite covariance (inverse years squared). The means
must not all be equal. `maximum_growth` is the final target (inverse years)
and must be at or above the GMV mean; `number_of_points` must be at least two.

Return a named tuple with fields `σ` and `g`, each a vector with
`number_of_points` entries in inverse years. The targets run from the GMV mean
to `maximum_growth`. The first pair of coordinates is the GMV point.
The function uses two linear solves and the closed-form minimum variance.
An invalid frontier determinant or upper target raises `DomainError`;
too few target points raises `ArgumentError`.


<a id="distances"></a>
## `distances(W)`

`W` is an M × B matrix of dimensionless weights: assets in rows, bootstrap
resamples in columns. At least one resample is required; negative weights are
allowed. Return B dimensionless distances. Each is the sum over assets of
absolute deviations from that asset's median weight across the B resamples.

The median vector is computed separately for each supplied matrix. It need not
sum to one. These distances measure dispersion, not actual trading turnover;
the calculation applies no factor of one half and does not renormalize weights.

<a id="dispersion"></a>
## `dispersion(W)`

`W` has the dimensions, units, and assumptions above. Return the arithmetic
mean of `distances(W)`, a dimensionless measure of spread across resamples.


<a id="buy_and_hold_statistics"></a>
## `buy_and_hold_statistics(prices, w, Δt)`

`prices` is a (K + 1) × M matrix of positive, aligned prices (USD per share),
with time in rows and assets in columns. It needs at least three rows to compute
a sample standard deviation. `w` contains M initial long-only weights summing
to one within solver tolerance. `Δt` is the positive observation interval in
years; the notebook uses 1/252.

Return a named tuple with:

- `wealth_ratio`: the K + 1 dimensionless values W_t/W_0.
- `terminal_ratio`: the final value of that path.
- `σ_g`: the sample standard deviation of successive log wealth changes divided
  by Δt, in inverse years, with denominator K − 1.

Wealth is the weighted sum of each asset's price divided by its first price.
Shares are fixed; portfolio weights change with prices. Fractional shares are
allowed. Prices and the resulting wealth must stay positive. The calculation
uses the weights as supplied and adds no dividend cash flows, trading costs,
taxes, or discounting. It evaluates one supplied price history and does not
simulate future prices.
