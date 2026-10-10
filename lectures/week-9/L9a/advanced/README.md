# L9a optional advanced material

This material extends the lecture's European pricing. It is optional.

- [`contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb`](contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb)
  derives the Black–Scholes–Merton premiums that the lecture states. A
  one-step replicating portfolio gives the risk-neutral probability
  $q=(R_f-d)/(u-d)$, and state prices write any claim's price as an inner
  product over states, with event contracts as the simplest claims. Under
  geometric Brownian motion, a digital claim costs the discounted
  $N(d_{-})$ and an asset-or-nothing claim costs $S(0)N(d_{+})$. The call is
  one asset-or-nothing claim minus $K$ digitals, and put–call parity gives the put.
- [`spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb`](spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb)
  treats an SPXW-style chain as a cross-section of European, cash-settled index
  claims. It pairs calls and puts, estimates the discount factor and forward
  index level from put–call parity, reprices the chain in forward BSM form,
  inverts quote midpoints for implied volatility, and checks parity, price
  bounds, strike monotonicity, and discrete convexity. It also attempts to load
  free Yahoo Finance `^GSPC` history for realized-volatility context and uses a
  deterministic synthetic price path if that optional request is unavailable.
  The bundled option quote fixture is explicitly synthetic and reproducible.
  The notebook documents the schema required to replace it with a timestamp-
  aligned, properly licensed market snapshot.

The SPXW notebook uses SPXW contract conventions to make European exercise and
cash settlement concrete. It does not scrape Cboe quote pages or claim that the
bundled fixture is observed market data. Yahoo history, when available, is used
only for backward-looking percentage volatility and is never combined with the
synthetic chain's price level or parity calculation.
