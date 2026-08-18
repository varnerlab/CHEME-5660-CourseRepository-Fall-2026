# L9a optional advanced material

This material extends the European Black--Scholes--Merton workflow from L9a. It
is optional and is not a prerequisite for L9b.

- [`spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb`](spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb)
  treats an SPXW-style chain as a cross-section of European, cash-settled index
  claims. It pairs calls and puts, estimates the discount factor and forward
  index level from put--call parity, reprices the chain in forward BSM form,
  inverts quote midpoints for implied volatility, and checks parity, price
  bounds, strike monotonicity, and discrete convexity. It also attempts to load
  free Yahoo Finance `^GSPC` history for realized-volatility context and uses a
  deterministic synthetic price path if that optional request is unavailable.
  The bundled option quote fixture is explicitly synthetic and reproducible;
  the notebook documents the schema required to replace it with a timestamp-
  aligned, properly licensed market snapshot.

The notebook uses SPXW contract conventions to make European exercise and cash
settlement concrete. It does not scrape Cboe quote pages or claim that the
bundled fixture is observed market data. Yahoo history, when available, is used
only for backward-looking percentage volatility and is never combined with the
synthetic chain's price level or parity calculation.
