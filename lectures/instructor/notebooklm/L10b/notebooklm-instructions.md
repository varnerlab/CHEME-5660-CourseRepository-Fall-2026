# NotebookLM: L10b, The NPV of Composite Contracts and A New Role for Delta

## 1. Sources to upload

Upload these three files from this folder as the notebook's sources. Do not upload this
instructions file; its prompts go in the "Customize" boxes.

- `CHEME-5660-L10b-Lecture-POP-POE-Delta-CompositeContracts.md` (the lecture)
- `CHEME-5660-L10b-Example-Delta-VerticalSpread.md` (Example 3, in class)
- `CHEME-5660-L10b-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: the "Review: The Greeks, POE, and POP" section (cut from the lecture
export) and its two slides (cut from the deck copy), the two L10a examples worked at the
start of class (the deck copy still names them on its examples slide), and the straddle example (review on your own). The audio stays on
composite contracts.

## 2. Audio Overview prompt

In the Audio Overview "Customize" dialog, choose Format: Deep Dive and Length: Shorter,
then paste this prompt.

```
Audience: engineering students in a quantitative finance course who already price single American calls and puts, know the Greeks, and compute the probability of exercise (POE) and the probability of profit (POP) of one contract from simulated share prices. New today: composite contracts, which combine several calls and puts on the same share with the same expiration.

Frame the episode around the AMD put credit spread in the example: sell the 520 put, buy the 500 put, and collect a credit. When does it make money, how likely is that, and how does its value move with the share price? Build the episode on the three results students must know:
* The profit at expiration is the sum of the legs' payoffs, each weighted by its orientation (+1 bought, -1 sold) and number of contracts, minus the net premium grown to expiration. The POP is the probability that this profit is positive.
* A profit diagram shows the breakevens, the maximum profit, and the maximum loss. For the eight credit contracts in the lecture, the maximum profit is the credit grown to expiration, and the maximum loss comes from the put side or the call side.
* The composite Delta is the sum of the legs' Deltas, weighted the same way, per share. Holding minus the options' Delta in shares makes the position delta-neutral.

Accuracy rules: say whether each probability is under P (our forecast) or Q (the probabilities inside the market price). Explain Q only as the probabilities under which the expected discounted payoff equals the price; never explain Q through a replicating portfolio. Treat the NPV derivation and the formula tables as background and do not walk through them. Do not re-teach the Greeks or the single-contract POE and POP. Strikes are numbered low to high: K1 = 500 is the long put, K2 = 520 the short put. A positive composite Delta is hedged by selling shares. Do not preview other lectures.

Tradeoffs: the long put lowers the credit but caps the loss; in the example the maximum profit is 8.80 and the maximum loss 11.20 USD/share, with the breakeven at 511.20. The POP is 0.71 under P but 0.54 under Q, because our drift estimate is far above the risk-free rate and our volatility below the implied volatility. A composite Delta of zero is not zero risk: Gamma moves the Delta as the share price moves, and closing early costs the extrinsic value left in the legs.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. Quiz and flashcards prompt

Paste this into the "Customize" box for the Quiz, and again for Flashcards.

```
Write questions only on these three core results: (1) the profit at expiration of a composite contract as the orientation- and copy-weighted sum of its legs' payoffs minus the net premium grown to expiration, and the POP as the probability that this profit is positive; (2) reading a profit diagram for the eight credit contracts (short put, short call, put and call credit spreads, short straddle, short strangle, protected strangle, iron condor): the breakevens, the maximum profit, the maximum loss, and the outlook; (3) the composite Delta as the weighted sum of the legs' Deltas, and the number of shares that makes a position delta-neutral. Mix concept questions with short calculations that use the AMD put credit spread numbers in the sources. Do not ask about the NPV derivation or ask students to recall the formula tables. Do not ask about the Greeks or the POE and POP of a single contract. In every question and answer, say whether a probability is under P or Q.
```

## 4. Before sharing

- **Listen** to the audio once. Stop on any of these: P and Q mixed up, the strikes swapped (K1 is the long put), "a zero Delta means no risk", "replicating portfolio", a re-teach of the Greeks, or a preview of a later lecture.
- **Copy the quiz and flashcards** as text into `quiz.md` in this folder, and ask Claude to check each item against the lecture. Only checked text belongs in the repo; this repository is public.
- **Post** the audio on Canvas. Keep the audio and video out of git and the release zip.

## What was emphasized

- The framing uses the AMD put credit spread from Example 3, the composite contract worked in class, so the episode has a concrete defined-risk trade.
- The three bullets are the lecture's must-know box. The NPV derivation and the formula tables are named as background, which is how the box treats them.
- The L10a catch-up (the review section, its two slides, and the two L10a examples) is left out of the sources, so the episode does not drift back to single contracts.
- The tradeoffs come from the example's outputs (maximum profit 8.80, maximum loss 11.20, breakeven 511.20 USD/share; POP 0.7144 under P and 0.5402 under Q) and the lecture's "zero is not zero risk" and time-decay discussions.
