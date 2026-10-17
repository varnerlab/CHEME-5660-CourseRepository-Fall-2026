# L9a optional advanced material

This material extends the lecture's European pricing. It is optional.

- [`contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb`](contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb)
  derives the Black–Scholes–Merton equation and premiums that the lecture states. A
  one-step replicating portfolio gives the risk-neutral probability
  $q=(R_f-d)/(u-d)$, and state prices write any claim's price as an inner
  product over states, with event contracts as the simplest claims. In
  continuous time, hedging the option with $\Delta=\partial\mathcal{P}/\partial S$
  shares gives the equation, and the Feynman–Kac argument
  shows that its solution is the discounted risk-neutral expectation of the
  payoff. Under geometric Brownian motion, a digital claim costs the discounted
  $N(d_{-})$ and an asset-or-nothing claim costs $S(0)N(d_{+})$. The call is
  one asset-or-nothing claim minus $K$ digitals, and put–call parity gives the put.
  The last section compares a client's certainty equivalent for the lecture's
  one-dollar bet with its market price, and shows that $q$ is the real-world
  probability reweighted by marginal utility. The lecture links here as an
  alternative way to think about the premium.
- [`spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb`](spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb)
  applies the lecture's implied-volatility bisection to an end-of-day chain of
  SPXW options, the European, cash-settled S&P 500 index options with weekly
  expirations. It fits put–call parity across strikes to estimate the discount
  factor and the forward index level, so it needs no index level. It then backs
  out the implied volatility of the out-of-the-money quote at every strike in
  the forward (Black) form of the BSM formula, checks each result by repricing,
  and compares the skew with the realized volatility of SPY. The quotes were
  captured from Alpaca Markets after the close on October 16, 2026, for the
  expirations nearest 30, 45, 60, and 90 days. The functions and their
  docstrings are in `spxw_volatility_skew/src/`, and the capture scripts in
  `spxw_volatility_skew/data/` record how the data were collected.
