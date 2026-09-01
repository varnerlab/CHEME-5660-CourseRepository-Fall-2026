# From CIR Short Rates to Treasury Yields

## Short answer

We do not directly convert a CIR short rate into a Treasury auction yield. We first use the short-rate model to price future cash flows, and then express the resulting price using the appropriate Treasury quotation convention.

The conceptual pipeline is

$$
\boxed{\text{CIR short rate}}
\longrightarrow
\boxed{\text{zero-coupon bond prices}}
\longrightarrow
\boxed{\text{zero yields}}
\longrightarrow
\boxed{\text{Treasury security price}}
\longrightarrow
\boxed{\text{Treasury quote}}.
$$

An actual auction yield is ultimately determined by bids submitted to the Treasury. A CIR model can give us a synthetic, model-implied yield, but it does not mechanically predict the result of an auction.

## What is the short rate?

In a CIR model, $r_t$ is the theoretical interest rate for borrowing money over an infinitesimally short interval beginning at time $t$:

$$
r_t \approx \text{continuously compounded rate from }t\text{ to }t+dt.
$$

The short rate is

- an instantaneous rate, not a 13-week or 52-week Treasury rate;
- a model state variable, rather than something directly observed at auction; and
- the starting point from which the model constructs rates for all longer maturities.

The CIR model describes the evolution of the short rate as

$$
dr_t=\kappa(\theta-r_t)\,dt+\sigma\sqrt{r_t}\,dW_t,
$$

where $\kappa$ is the mean-reversion rate, $\theta$ is the long-run level, and $\sigma$ controls volatility. The square-root term helps keep simulated rates nonnegative under suitable parameter conditions.

The original CIR paper uses this structure to derive an entire term structure from the short rate: [Cox, Ingersoll, and Ross (1985)](https://www.jstor.org/stable/1911242).

## Connection to L1b: the continuously compounded growth rate

The [L1b Time Value of Money lecture](../week-1/L1b/CHEME-5660-L1b-Lecture-TimeValueMoney-Fall-2026.ipynb) already contains the main mathematical doorway into CIR. It defines a possibly time-varying continuously compounded growth rate $g(t)$ and the corresponding forward accumulation and discount factors:

$$
\mathcal D_{T,0}(g)
=
\exp\left(\int_0^T g(u)\,du\right),
\qquad
\mathcal D_{T,0}^{-1}(g)
=
\exp\left(-\int_0^T g(u)\,du\right).
$$

L1b then specializes to the constant-rate case:

$$
g(t)=g
\quad\Longrightarrow\quad
\mathcal D_{T,0}^{-1}(g)=e^{-gT}.
$$

CIR can be presented as a stochastic extension of this model rather than as unrelated new machinery. We replace the known growth-rate function $g(t)$ with a stochastic, mean-reverting short-rate process $r_t$:

$$
g(t)\quad\longrightarrow\quad r_t.
$$

For one realized CIR path, the forward accumulation and discount factors retain exactly the L1b form:

$$
\mathcal D_{T,t}(r)
=
\exp\left(\int_t^T r_u\,du\right),
\qquad
\mathcal D_{T,t}^{-1}(r)
=
\exp\left(-\int_t^T r_u\,du\right).
$$

Thus, the CIR short rate is the stochastic, mean-reverting version of the continuously compounded growth rate introduced in L1b. The new idea is not continuous compounding; it is that the future growth-rate path is uncertain.

## From the short rate to zero-coupon prices

In L1b, once the path $g(u)$ is specified, its discount factor is known. In CIR, the future values $r_u$ for $u>t$ are unknown at time $t$, so the future discount factor is random. Under a risk-neutral CIR model, the time-$t$ price of receiving one dollar at maturity $T$ is

$$
P(t,T)
=
\mathbb{E}^{Q}_{t}
\left[
\exp\left(-\int_t^T r_s\,ds\right)
\right].
$$

This expectation is the extra pricing step introduced by stochastic rates. In general,

$$
\mathbb E\left[e^{-X}\right]
\neq
e^{-\mathbb E[X]},
$$

so we cannot simply replace a random CIR path with its average and apply the constant-rate formula.

CIR has a closed-form zero-coupon bond price of the form

$$
P(t,T)=A(T-t)\exp\left[-B(T-t)r_t\right].
$$

The functions $A$ and $B$ depend on the CIR parameters and the time remaining to maturity. Once we have the zero-coupon price, we can calculate a continuously compounded zero yield:

$$
z(t,T)=-\frac{\ln P(t,T)}{T-t}.
$$

Therefore, a short rate of 4% does not imply that the one-year, five-year, and seven-year yields are all 4%. Longer-maturity yields depend on the possible future paths of the short rate, mean reversion, volatility, and the market price of interest-rate risk.

### Connection to L2a: a bill's price-implied growth rate

The [L2a Treasury Securities lecture](../week-2/L2a/CHEME-5660-L2a-Lecture-TreasurySecurities-Fall-2026.ipynb) defines the price-implied annualized log growth rate of a bill with purchase price $V_B$, par value $V_P$, and maturity $T$ as

$$
g_B
=
\frac{1}{T}
\log\left(\frac{V_P}{V_B}\right).
$$

If we normalize the bill price by its par value,

$$
P(0,T)=\frac{V_B}{V_P},
$$

then the same growth rate can be written as

$$
g_B
=
-\frac{1}{T}\log P(0,T).
$$

This is the continuously compounded zero-coupon spot yield. The CIR short rate is the limiting value of precisely this price-implied growth rate as the maturity interval shrinks toward zero:

$$
\boxed{
r_t
=
\lim_{\tau\rightarrow 0}
\left[
-\frac{1}{\tau}
\log P(t,t+\tau)
\right].
}
$$

This supplies an intuitive meaning for the word *short*: a Treasury bill has a finite-maturity price-implied growth rate, while the short rate is the limiting growth rate for an infinitesimally short maturity.

## From a zero-coupon price to a Treasury bill quote

Suppose the model gives the price $P_D$, per \$100 of face value, of a Treasury bill maturing in $D$ days. Under the Treasury bank-discount-rate convention,

$$
P_D=100\left(1-d\frac{D}{360}\right),
$$

so the quoted discount rate is

$$
d=\left(\frac{100-P_D}{100}\right)\frac{360}{D}.
$$

The discount rate $d$ is calculated relative to the bill's face value and uses a 360-day year. It is not the actual return earned on the dollars invested. These are the Treasury's official bill-pricing conventions: [TreasuryDirect pricing explanation](https://www.treasurydirect.gov/marketable-securities/understanding-pricing/) and [31 CFR Part 356](https://www.ecfr.gov/current/title-31/subtitle-B/chapter-II/subchapter-A/part-356).

For an investment or bill-rolling calculation, the more useful quantity is the growth factor

$$
G=\frac{100}{P_D}.
$$

For example, if a bill costs \$96 and pays \$100 at maturity, every dollar invested becomes

$$
\frac{100}{96}=1.04167
$$

dollars at maturity. This growth factor, rather than the quoted bank discount rate, should drive a student's portfolio recursion.

## Why several reported rates can describe the same investment

As a deliberately simplified example, suppose the short rate is flat at 4% for one year and we ignore CIR mean reversion and volatility. The one-year zero-coupon price would be approximately

$$
P=100e^{-0.04}=96.079.
$$

This one economic situation produces several different reported numbers:

- Instantaneous continuously compounded short rate:

  $$
  4.000\%.
  $$

- One-year effective holding-period yield:

  $$
  \frac{100}{96.079}-1=4.081\%.
  $$

- Approximate 365-day Treasury bank discount rate:

  $$
  \frac{100-96.079}{100}\frac{360}{365}=3.867\%.
  $$

None of these numbers is wrong. They are different quotation or compounding conventions applied to the same price.

## From zero prices to a Treasury note yield

For a coupon-paying seven-year note, the CIR zero prices are used to price each individual cash flow:

$$
V
=
\sum_{i=1}^{N} C_iP(t,t_i)
+
100P(t,T),
$$

where $C_i$ denotes the coupon payment at date $t_i$. We can then solve for the single yield to maturity $y$ that reproduces that price under a semiannual compounding convention:

$$
V
=
\sum_{i=1}^{N}
\frac{C_i}{(1+y/2)^i}
+
\frac{100}{(1+y/2)^N}.
$$

This calculation gives a model-implied seven-year yield. At an actual Treasury auction, investors submit bids and the accepted bids determine the auction result: [How Treasury auctions work](https://www.treasurydirect.gov/auctions/how-auctions-work/).

## Connection to L2b: the yield curve, duration, and convexity

The [L2b Yield, Duration, Convexity, and the Yield Curve lecture](../week-2/L2b/CHEME-5660-L2b-Lecture-Yield-Duration-Convexity-Curve-Fall-2026.ipynb) distinguishes spot rates, yield to maturity, and par yields. CIR connects most directly to the spot curve. The current short-rate state $r_t$, together with the CIR parameters, generates zero-coupon prices at every maturity, and those prices generate maturity-specific spot rates:

$$
r_t
\longrightarrow
\left\{P(t,T_1),P(t,T_2),\ldots\right\}
\longrightarrow
\left\{z(t,T_1),z(t,T_2),\ldots\right\}.
$$

The resulting spot curve prices the individual cash flows of a coupon note:

$$
V_B
=
\sum_{j=1}^{N}C_jP(t,t_j)
+
V_PP(t,T).
$$

A single yield to maturity can then be solved from this price. Thus, CIR naturally generates the spot curve, the spot curve prices the note, and YTM is a summary quotation of that price.

The duration and convexity material in L2b asks how a security's price changes when its yield changes. CIR provides a model for one source of those changing yields. For a CIR zero-coupon price

$$
P(t,T)=A(\tau)e^{-B(\tau)r_t},
$$

the sensitivity to the current short-rate state is

$$
\frac{\partial P(t,T)}{\partial r_t}
=
-B(\tau)P(t,T).
$$

This has the same local-sensitivity structure as the duration approximation

$$
\frac{\Delta V}{V}
\approx
-D_{\mathrm{mod}}\Delta y.
$$

We do not need to derive CIR state sensitivity in PS1. Its value is conceptual: CIR-generated rate scenarios provide a model-based source of the yield and price movements studied with duration and convexity in L2b.

## Physical scenarios versus risk-neutral pricing

There are conceptually two versions of the interest-rate model:

- The physical-measure model, conventionally denoted by $P$, describes plausible future rate scenarios.
- The risk-neutral model, conventionally denoted by $Q$, prices securities.

Connecting the two requires a market price of interest-rate risk. Consequently, a simulated real-world short-rate path alone is not sufficient to produce bond prices unless we also specify the pricing relationship.

For PS1, a reasonable pedagogical simplification is to use a single calibrated CIR specification as both the scenario generator and the pricing model. The assignment should explicitly say that this simplification suppresses the distinction between physical and risk-neutral dynamics. The resulting quantities should be described as **synthetic model-implied Treasury rates**, rather than simulated auction yields.

## Recommended instructional framing

CIR can be introduced in PS1 using three connections to material the students have already seen:

1. **Recall L1b.** A time-varying continuously compounded growth rate produces the discount factor

   $$
   \exp\left(-\int_t^T g(u)\,du\right).
   $$

2. **Introduce the CIR extension.** Replace the known function $g(u)$ with an uncertain, mean-reverting short rate $r_u$.

3. **Return to week 2.** Average the random discount factors to obtain zero-coupon prices, then use the week-2 price, yield, and quotation conversions.

The conceptual mapping is:

| Existing course idea | CIR extension |
|:--|:--|
| Continuously compounded growth rate $g(t)$ | Stochastic short rate $r_t$ |
| Discount factor $e^{-\int g\,du}$ | Random discount factor $e^{-\int r\,du}$ |
| Bill-implied growth rate $g_B$ | Model-implied zero spot rate $z(t,T)$ |
| One constant YTM | Maturity-specific spot curve |
| Yield perturbation | Rate scenarios generated by a stochastic model |

There is one notation issue to flag. L2a uses $r_B$ for a bill's finite holding-period log return, whereas the standard CIR notation uses $r_t$ for the instantaneous short rate. These quantities should be explicitly distinguished in PS1.

## Recommended PS1 data design

Use CIR to generate annual scenario observations and convert each observation into a model-implied one-year zero-coupon price. A supplied data file could contain

```text
scenario_id,year,short_rate,one_year_price,growth_factor,bill_discount_rate
```

Students would use

$$
W_{t+1}=W_t\times\texttt{growth\_factor}_t
$$

for the rolling strategy. The `short_rate` and `bill_discount_rate` columns provide useful context, but students would not need to run the CIR simulation or perform Treasury quote conversions themselves.

Using seven successive 52-week zero-coupon investments keeps the advanced-track comparison focused. Introducing two-year coupon notes would require generating a fuller term structure and repricing a coupon-paying security at every rollover date, which may distract from the central lock-versus-roll decision.
