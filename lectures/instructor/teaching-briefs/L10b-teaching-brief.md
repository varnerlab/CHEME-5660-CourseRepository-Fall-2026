# L10b teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Thursday, October 29, 2026. Deck: 28 slides. Delta hedging moved to L11a (October 27). In class: the two L10a examples we did not
reach on Tuesday (Example 1, Greeks; Example 2, POE/POP; both NVDA, numbers in the L10a
brief, where they are Examples 2 and 3), then Example 3, the put credit spread. The straddle example is review on your own:
it has naked legs on both sides, so it is the harder trade to start with. Both L10b
examples use the AMD chain of October 26, 2026 (close 531.26 USD/share, December 18
expiration, 53 days). AMD reports earnings on November 3 after the close.

## The story in five steps

0. **Catch-up (two review slides, then Examples 1 and 2).** The Taylor expansion of
   the premium, the quoted units (Θ/365, ν/100, ρ/100), one contract = 100·Δ shares, and
   the POE and POP formulas. No finite differences and no Delta–POE proposition; the
   examples carry those.
   Then the **tastytrade profile** (one slide): a broker built on teaching people to sell
   strangles and iron condors at ~45 DTE and buy them back at 50% of max profit. Its
   connection is the early-exit section: closing early gives up the premium left in the legs.
1. Last time: one contract. Today: put several together. What is the combination
   worth, and when does it make money?
2. **The profit at expiration is a sum over the legs.** Payoffs weighted by θᵢnᵢ, minus
   the composite premium grown to expiration (𝒟). The NPV is that profit discounted to today,
   so the POP is the chance the profit is positive. The same counting works with two
   breakevens.
3. **Eight credit structures, one idea.** Each has a put side and a call side: empty,
   naked, or a credit spread. The sides give the outlook and the maximum loss. The
   formula tables are reference material, not something to memorize.
4. **Why we wait to expiration (after the diagrams).** Closing early means buying the legs back,
   and their price still includes extrinsic value. Use the strangle time-decay figure.

## What students must know (on slide 4 and in the notebook box)

- **Core:**
  - POE and POP of one contract from simulated share prices; POE ~ |Δ|
  - profit at expiration = legs' payoffs − composite premium grown to expiration; POP = P(profit > 0)
  - read a profit diagram: breakevens, max profit (credit grown to expiration), max loss;
    closing early earns less, by roughly the extrinsic value left in the legs
- **For understanding only:** the NPV derivation and the eight formula tables. Say out
  loud that students won't have to reproduce or memorize them.

## Where students will likely get stuck

- **𝒟, the credit grown to expiration.** It is close to one: 𝒟 = 1.0060 for 53 days.
  The point is that the premium arrives today and the payoff at expiration, not the size
  of the correction.
- **Strike numbering.** Strikes run low to high. In the put credit spread, K₁ is the
  long put (500) and K₂ the short put (520), so the credit is 𝒫₂ − 𝒫₁.
- **Two breakevens.** A short straddle profits between them, a long straddle outside
  them.
- **|Δ| for puts.** A put's Delta is negative; its size approximates the POE. In
  Example 3 the short put has Δ = −0.41 and a POE under ℚ of 0.49 (1 − 0.41 would be
  the chance it finishes out of the money).
- **ℙ versus ℚ again.** The straddle seller's POP is higher under our belief ℙ than
  under ℚ. That is because AMD's historical volatility (0.474) is below the implied
  volatility (0.562), not because of the drift.

## Numbers to point at

**Straddle example (review on your own; short straddle, K = 530):**
- Premiums: put 43.00, call 47.83, credit 90.83 USD/share (91.38 grown to expiration).
- Breakevens: 438.62 and 621.38 USD/share.

  | Distribution of S(T) | POP (short straddle) | POE put | POE call |
  |:--|--:|--:|--:|
  | our belief ℙ | 0.618 | 0.357 | 0.643 |
  | risk-neutral ℚ | 0.584 | 0.527 | 0.473 |
  | Normal IV | 0.578 | 0.484 | 0.516 |

- Task 3 waits for the release (below).

**Example 3 (put credit spread, long 500 / short 520):**
- Premiums: 29.35 (long) and 38.10 (short), credit 8.75 USD/share.
- Breakeven 511.20; max profit 8.80; max loss 11.20 USD/share.
- POP 0.714 under ℙ against 0.540 under ℚ. The short put's POE under ℚ is 0.492.
- Quoted leg Deltas: −0.3406 (long, 500) and −0.4099 (short, 520); POEs under ℚ 0.419
  and 0.492.

## In-class discussion prompts

- Why would anyone sell a straddle right before earnings? (Implied volatility usually
  falls after the release, which lowers the extrinsic value the seller has to buy back.)
- Why does the time-decay figure's cost to close equal the credit on day one?

## After the November 3 release (week-10.2)

Download the AMD chain for the December 18 expiration on November 4, save it as a new
dataset (for example `amd-2026-post`), set `post_release_ticker` in the straddle
example's Task 3, and rerun. Task 3 then prints the cost to buy both legs back and the
profit or loss.
