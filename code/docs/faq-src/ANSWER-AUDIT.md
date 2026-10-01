# Answer audit — October 1, 2026

All 31 answers and all 22 notation tables (273 entries) were reviewed before publication. The review compared definitions, equations, assumptions, units, and interpretations with the current Fall 2026 lecture notebooks, and checked the independently recomputed examples. No unresolved mathematical findings remain in this snapshot.

## Corrections and clarifications

- Corrected the short NPV definition: the present value of future net cash flows must exceed the initial cost; NPV itself need only exceed zero.
- Corrected the daily-growth illustration: `252 × log(1.01) = 2.507483…`, which rounds to 2.507 at three decimal places.
- Made the logarithmic lattice-target domain, lattice calibration's handling of zero-change observations, EMA variance convention, regression rank/sample-size conditions, and jointly Gaussian assumption explicit.
- Qualified borrowing's expected-growth effect by a positive risky excess mean, identified the CAL calculation as the course's linear growth proxy, specified positive wealth for realized log growth, and limited the tangent rescaling statement to feasible targets.
- Specified coupon valuation immediately after a payment. Replaced a dangling “defined above” reference in notation with a direct link to the exact-target formula. Student-t degrees of freedom are dimensionless.

## Verification

`verify_math.py` passes 108 independent numerical and matrix-identity checks. These include strict lattice-boundary events, replicating payoffs, GBM probabilities and time units, the EMA centered-moment identity, Monte Carlo standard errors, bond pricing and duration, a direct KKT check of frontier weights, least-squares/SIM covariance identities, and a constrained optimization check of the common tangent direction.

The review keeps three distinctions explicit: fitted probabilities versus later observed outcomes; coefficient/Monte Carlo uncertainty versus outcome spread; and the linear growth proxy versus exact buy-and-hold wealth. Classical regression intervals are conditional on their stated error assumptions. A pointwise band is not a whole-path coverage claim.

External checks used [TreasuryDirect's pricing explanation](https://www.treasurydirect.gov/marketable-securities/understanding-pricing/), [the SEC bulletin on leveraged ETFs](https://www.investor.gov/introduction-investing/general-resources/news-alerts/alerts-bulletins/investor-alerts/sec), and [Sharpe's time-aggregation discussion](https://web.stanford.edu/~wfsharpe/art/sr/SR.htm). All other source links are the course notebooks recorded in `content.json`.

## Answer coverage

| Answer | Course sources | Review |
|---|---|---|
| What can a price model help us decide? | L4b, L5a | Equations, units, assumptions, and interpretation checked |
| Why study models that miss important market behavior? | L3b, L4b, L5a | Equations, units, assumptions, and interpretation checked |
| How do mean growth and drift differ? | L4b | Equations, units, assumptions, and interpretation checked |
| How do growth rate, log return, and volatility differ? | L3a, L4b | Equations, units, assumptions, and interpretation checked |
| If volatility cannot predict direction, why is it useful? | L3a | Equations, units, assumptions, and interpretation checked |
| What persists during a volatile period? | L3a | Equations, units, assumptions, and interpretation checked |
| Why does one tree use two probabilities? | L3b | Equations, units, assumptions, and interpretation checked |
| How do we construct a lattice from observations? | L3b | Equations, units, assumptions, and interpretation checked |
| Which lattice prices beat a trading target? | L4a | Equations, units, assumptions, and interpretation checked |
| How do independent inputs produce correlated movements? | L5b | Equations, units, assumptions, and interpretation checked |
| How do observations become a covariance matrix? | L5b | Equations, units, assumptions, and interpretation checked |
| When do independent single-asset models agree with MA-GBM? | L5b | Equations, units, assumptions, and interpretation checked |
| What does a fitted log-price line predict? | L4b | Equations, units, assumptions, and interpretation checked |
| What changes when another price observation arrives? | L5a | Equations, units, assumptions, and interpretation checked |
| Does a 95% band contain 95% of complete price paths? | L4b, L5a | Equations, units, assumptions, and interpretation checked |
| What uncertainty does a Monte Carlo simulation measure? | L6a | Equations, units, assumptions, and interpretation checked |
| What do alpha, beta, and residuals tell us? | L6b | Equations, units, assumptions, and interpretation checked |
| How uncertain are the fitted alpha and beta? | L6b | Equations, units, assumptions, and interpretation checked |
| What stays fixed when we buy and hold? | L5b | Equations, units, assumptions, and interpretation checked |
| How do individual growth rates become portfolio risk? | L6a | Equations, units, assumptions, and interpretation checked |
| Why mix assets when one has a smaller variance? | L6a | Equations, units, assumptions, and interpretation checked |
| How do exact growth targets differ from growth floors? | L6a | Equations, units, assumptions, and interpretation checked |
| How does an NPV target become a normal probability? | L4b, L5a | Equations, units, assumptions, and interpretation checked |
| Why does daily leverage not multiply the long-run return? | L3a | Equations, units, assumptions, and interpretation checked |
| How do portfolio weights become wealth and NPV? | L6a | Equations, units, assumptions, and interpretation checked |
| Which covariance does the single index model keep or omit? | L6b | Equations, units, assumptions, and interpretation checked |
| What changes when we lend or borrow? | L6b | Equations, units, assumptions, and interpretation checked |
| Which weights describe the risky fund and the whole investment? | L6b | Equations, units, assumptions, and interpretation checked |
| Why discount cash flows, and what does positive NPV mean? | L1b | Equations, units, assumptions, and interpretation checked |
| How do coupon payments and yield determine a bond price? | L2a | Equations, units, assumptions, and interpretation checked |
| Why does a higher yield lower a bond’s price? | L2b | Equations, units, assumptions, and interpretation checked |

Audited content SHA-256: `ac7e823e5bdedee3121a507e992ce5f3bda8dff0111492f50777599c585f596d`. These checks document this snapshot; future content changes should receive a corresponding review.
