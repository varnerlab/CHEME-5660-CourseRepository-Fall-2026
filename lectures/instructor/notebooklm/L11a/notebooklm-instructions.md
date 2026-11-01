# NotebookLM: L11a, Composite Contracts and Their Probability of Profit

## 1. Sources to upload

Upload these four files from this folder as the notebook's sources. Do not upload this
instructions file, `quiz.md`, `quiz-instructions.txt`, or the QTI zip; the prompt below goes in
the Audio Overview "Customize" box.

- `CHEME-5660-L11a-Lecture-CompositeContracts.md` (the lecture)
- `CHEME-5660-L11a-Example-Delta-VerticalSpread.md` (the put credit spread example, in class)
- `CHEME-5660-L11a-Example-Straddle-AMD-Earnings.md` (the strangle example, in class)
- `CHEME-5660-L11a-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: the derivation notebook (review on your own). The strangle example's
Task 3, closing after the November 3 earnings release, prints a pending message until the
post-release chain is loaded; re-export that example and re-upload it after the release if
you want the outcome in a later episode.

## 2. Audio Overview prompt

In the Audio Overview "Customize" dialog, choose Format: Deep Dive and Length: Shorter,
then paste this prompt.

```
Audience: engineering students in a quantitative finance course who already price single American calls and puts and compute the probability of exercise (POE) and the probability of profit (POP) of one contract from simulated share prices, under our forecast P and under the risk-neutral probabilities Q. New today: composite contracts, which combine several calls and puts on the same share with the same expiration.

Frame the episode around the two AMD trades in the examples, both opened on October 26 with 53 days to expiration: a put credit spread (sell the 520 put, buy the 500 put) and a short strangle (sell the 470 put and the 630 call) opened before AMD's earnings release. When does each make money, how likely is that, and what happens if we close early? Build the episode on these three results:
* The profit at expiration is the sum of the legs' payoffs, each weighted by its orientation (+1 bought, -1 sold) and copy number, minus the composite premium grown to expiration. The POP is the probability that this profit is positive, under P or under Q.
* A profit diagram shows the outlook, the breakevens, the maximum profit (the credit grown to expiration), and the maximum loss of each contract, from the short put to the iron condor.
* Closing before expiration earns less than the profit at expiration, by roughly the extrinsic value left in the legs. Near expiration, a small move in the share price near a strike changes the profit by more.

Accuracy rules: say whether each probability is under P (our forecast) or Q (the probabilities inside the market price). Explain Q only as the probabilities under which the expected discounted payoff equals the price; never mention replicating or hedging portfolios. The composite premium is the premium we pay minus the premium we collect, so it is negative for a credit; do not call it positive for a credit trade. Strikes are numbered low to high: in the spread K1 = 500 is the long put and K2 = 520 the short put. Treat the NPV derivation and the formula tables as background and do not walk through them. Do not re-teach single-contract POE and POP. Do not say how the strangle did after the earnings release; the examples do not have that result yet. Do not preview other lectures.

Tradeoffs: the spread's long put lowers the credit but caps the loss: the maximum profit is 8.80 and the maximum loss 11.20 USD/share, with the breakeven at 511.20. Its POP is 0.71 under P but 0.54 under Q, because our drift estimate is far above the risk-free rate and our volatility is below the implied volatility. The strangle has two breakevens, 435.59 and 664.41 USD/share, and no cap on the call side; its POP is 0.74 under P and 0.67 under Q, and the lower historical volatility is what raises it. Finally, tastylive sells strangles about 45 days before expiration and buys them back at half the maximum profit or about 21 days before expiration, giving up part of the credit to avoid the larger swings near expiration.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. The self-check quiz

Claude wrote `quiz.md` (10 questions, no flashcards) from these sources and checked every
number against the example outputs. NotebookLM is not used for the quiz. The Canvas package is
`L11a-quiz-canvas-qti.zip`, and the text for the quiz's Instructions box is
`quiz-instructions.txt` (plain text; paste it as is).

## 4. Before sharing

- **Listen** to the audio once. Stop on any of these: P and Q mixed up, a positive composite premium for a credit trade, the spread's strikes swapped (K1 = 500 is the long put), an outcome for the strangle after the earnings release, "replicating portfolio", a re-teach of single-contract POE and POP, or a preview of a later lecture.
- **Import the quiz.** In Canvas, Settings > Import Course Content > QTI .zip file, and choose `L11a-quiz-canvas-qti.zip`. In New Quizzes the Quiz Type is locked, so set Points to 0, check "Do not count this assignment towards the final grade", paste `quiz-instructions.txt` into the Instructions box, and preview the math.
- **Post** the audio on Canvas. Keep the audio and video out of git and the release zip.

## What was emphasized

- The three bullets are the lecture's "What you need to know" core points, in order. The NPV derivation and the formula tables are named as background.
- The framing uses both in-class AMD trades, a defined-risk spread and an undefined-risk strangle, so the episode can contrast a capped and an uncapped loss.
- The composite premium sign follows the lecture's buyer convention (negative for a credit), and the prompt says so, because a host is likely to call a credit a positive premium.
- The strangle's post-earnings result is pending, so the prompt forbids an outcome.
- The tradeoffs come from the example outputs (spread: 8.80, 11.20, 511.20 USD/share; POP 0.7144 under P and 0.5402 under Q; strangle: breakevens 435.59 and 664.41 USD/share; POP 0.7384 under P and 0.6714 under Q, 0.7534 with the risk-free drift and historical volatility) and the lecture's "Why Wait to Expiration?" section.
