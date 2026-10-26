# L10a teaching brief

Instructor notes. Public in the repository, not in the student release zip.

Tuesday, October 27, 2026. Deck: 28 slides. In class: Example 2 (Greeks) and Example 3 (POE/POP), both NVDA. Example 1 (Longstaff–Schwartz) is review on your own.

## The story in six steps

1. Last time we priced American options on a tree. Today: can simulation do it, and how sensitive is the premium to its inputs?
2. **Longstaff–Schwartz:** simulate paths, walk backward, and at each date regress "what holding is worth" on the share price. Exercise when the payoff beats the fitted value of holding. Show the Task 2 table (below) for about three minutes and leave the rest of Example 1 to students.
3. **Premium = intrinsic + extrinsic.** Extrinsic value is largest at the money and decays toward expiration. Without dividends you never exercise a call early, but you might exercise a deep in-the-money put early.
4. **The Greeks** are the coefficients of a Taylor expansion of the premium. We get them by repricing the tree with one input nudged up and down. With enough tree steps, CRR gives a good Delta; its Gamma can be zero or erratic when the step is smaller than the spacing between the tree's corners, which is why we use Leisen–Reimer.
5. **Delta has three jobs:**
   - premium change per 1 USD/share
   - share equivalent and hedge ratio
   - close to (and a bit above) a call's POE under ℚ. Quoted Deltas come from pricing models under ℚ, so this is the right comparison; our ℙ forecast can be above or below Delta.
6. **POE and POP** come from simulated prices at expiration. The POP is the POE with the breakeven in place of the strike.

## What students must know (on slide 4 and in the notebook box)

- **Core:**
  - premium = intrinsic + extrinsic value
  - what each Greek means, per day (Θ/365) and per point (ν/100, ρ/100)
  - POE and POP from simulated prices; for a short-dated call, Delta ≈ the POE under ℚ
- **For understanding only:**
  - the Longstaff–Schwartz regression
  - the Taylor expansion
  - the Delta–POE proposition

  Say out loud that students won't have to reproduce these.

## Where students will likely get stuck

- **Units of Theta and Vega.** The tree gives Θ = −51.56 per year. Per day that is −0.1413 USD/share, or −14.13 USD per contract. Vega is 31.34 per unit of σ, which is 0.3134 USD/share per volatility point. Platforms quote the per-day and per-point numbers.
- **ℙ versus ℚ.** For the NVDA 235 call (Example 3), three numbers look like "the probability":

  | Quantity | Value |
  |:--|--:|
  | Delta (quote) | 0.483 |
  | ℚ POE | 0.430 |
  | Our-belief ℙ POE | 0.619 |

  Delta tracks the ℚ number, not our forecast. This is the one point worth slowing down for.
- **Short contracts.** Every Greek flips sign; long plus short is zero (Example 2, Task 3 table).
- **Why an American call costs the same as a European call.** You pay K later and earn interest on it, and you can walk away below K.

## Numbers to point at

**Example 1 (LSM put), review on your own; show only the Task 2 table:**
- By hand on 8 paths: the American premium is 0.1144 and the European 0.0564.
- Task 2 (K = S(0) = 60, σ = 10%, 1 year):

  | Method | American | European |
  |:--|--:|--:|
  | Longstaff–Schwartz | 1.4543 | 1.1526 |
  | CRR lattice | 1.4625 | 1.1578 |

  The early-exercise premium is about 0.30 USD/share by both methods.

**Example 2 (NVDA, 230 call and put, 43 DTE):**
- Leisen–Reimer Delta is 0.5481 against the quoted 0.5538. One call behaves like about 55 shares.
- For the call, Gamma, Theta, Vega, and Rho are within 0.002 of the quotes.
- **The put's Rho is the exception:** −0.114 on the American tree against a quoted −0.134. The quote matches the European value, −0.135. If someone asks, early exercise makes the American put less sensitive to the rate.

**Example 3 (NVDA 235 call):**
- The breakeven is 244.93, and the seller collects 988 USD per contract.
- The seller's POP is 0.698 under ℚ against 0.503 under our belief.

## In-class discussion prompts already in the materials

- Why do people pay for something "worthless"? (the Extrinsic Value slide)
- Would you ever exercise early? (the slide after it)
- From the Example 1 Discussion (only if time allows; Example 1 is review on your own):
  - Why does the early-exercise premium grow with K/S(0)?
  - Why is the American premium exactly K − S(0) at K/S(0) = 1.08 and 1.17?

## A candidate for a handwritten derivation (later, once there is a tablet)

The POP chain on the "Probability of Profit" slide is four lines from "profit > 0" to "S_T > breakeven". It is short, it is the core result, and it works well written by hand.
