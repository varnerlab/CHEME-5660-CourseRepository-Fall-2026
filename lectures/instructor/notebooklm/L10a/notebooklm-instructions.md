# NotebookLM: L10a, Monte Carlo Pricing and the Greeks of American Options

## 1. Sources to upload

Upload these four files from this folder as the notebook's sources. Do not upload this
instructions file; its prompts go in the "Customize" boxes.

- `CHEME-5660-L10a-Lecture-American-Derivatives-Greeks.md` (the lecture)
- `CHEME-5660-L10a-Example-Greeks-PutCall.md` (Example 2, in class)
- `CHEME-5660-L10a-Example-POE-POP-Call.md` (Example 3, in class)
- `CHEME-5660-L10a-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: the Longstaff–Schwartz example and the extrinsic-value example
(review on your own), and the two advanced notebooks. The audio stays on the core results.

## 2. Audio Overview prompt

In the Audio Overview "Customize" dialog, choose Format: Deep Dive and Length: Shorter
(the default length gave a 25-minute episode for L10a), then paste this prompt.

```
Audience: engineering students in a quantitative finance course who already price European and American options on a binomial (CRR) tree and by Monte Carlo under the risk-neutral probabilities Q, but are new to the Greeks, the probability of exercise (POE), and the probability of profit (POP).

Frame the episode around the NVDA call contract in the examples: before we sell it, how sensitive is its premium to the market, and how likely is it to be exercised or to make money? Build the episode on the three results students must know:
* An American option's premium is its intrinsic value plus its extrinsic value. Extrinsic value is largest at the money and decays toward expiration. Without dividends, a call is never exercised early; a deep in-the-money put can be.
* What each Greek measures: Delta, Gamma, Theta, Vega, and Rho. Theta is per year, so divide it by 365 for a one-day change. Vega and Rho divided by 100 give the change for a one-point rise in the volatility or the rate.
* The POE and POP come from simulated share prices at expiration, and the POP is the POE with the breakeven price in place of the strike. For a short-dated call, Delta is close to the POE under Q. It is not our forecast under P.

Accuracy rules: say whether each probability is under P (our forecast) or Q (the probabilities inside the market price). Explain Q only as the probabilities under which the expected discounted payoff equals the price; never mention replicating or hedging portfolios. Treat the Longstaff-Schwartz regression, the Taylor expansion, and the Delta-POE proposition as background and do not walk through them. Do not preview other lectures.

Tradeoffs: the Greeks are local, so they describe small moves only. Delta sits above the POE under Q, and the gap grows with the volatility times the square root of the time to expiration. The POE and POP under P depend strongly on our drift estimate; in the NVDA example the POE moves from 0.43 under Q to 0.62 under P.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. Quiz and flashcards prompt

Paste this into the "Customize" box for the Quiz, and again for Flashcards.

```
Write questions only on these three core results: (1) premium equals intrinsic plus extrinsic value, and when early exercise makes sense; (2) what each Greek measures, and converting Theta to a one-day change (divide by 365) and Vega and Rho to a one-percentage-point change (divide by 100); (3) computing the POE and POP from simulated share prices at expiration, the breakeven price, and why Delta is close to the POE under Q but is not our forecast under P. Mix concept questions with short calculations that use the NVDA numbers in the sources. Do not ask about the Longstaff-Schwartz regression, the Taylor expansion, or the Delta-POE proof. In every question and answer, say whether a probability is under P or Q.
```

## 4. Before sharing

- **Listen** to the audio once. Stop on any of these: P and Q mixed up, Theta read as a daily number, "replicating portfolio", or a preview of a later lecture.
- **Copy the quiz and flashcards** as text into `quiz.md` and `flashcards.md` in this folder, and ask Claude to check each item against the lecture. Only checked text belongs in the repo; this repository is public.
- **Post** the audio on Canvas. Keep the audio and video out of git and the release zip.

## What was emphasized

- The framing uses the short NVDA 235 call from Example 3, so the episode has a concrete contract and a question to answer.
- The three bullets are the lecture's must-know box. Longstaff–Schwartz, the Taylor expansion, and the Delta–POE proposition are named as background, which is how the box treats them.
- The accuracy rules target the mistakes we fixed by hand on October 26: P versus Q, Theta's units, and the replication framing the course avoids.
- The tradeoffs come from the lecture (Greeks as a local Taylor expansion, the σ√T gap) and Example 3's four-case table (POE 0.4295 under Q, 0.6185 under P).
