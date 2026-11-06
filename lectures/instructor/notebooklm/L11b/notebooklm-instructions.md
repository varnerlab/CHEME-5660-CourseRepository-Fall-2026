# NotebookLM: L11b, Covered Calls and Protective Collars

## 1. Sources to upload

Upload these four files from this folder as the notebook's sources. Do not upload this
instructions file, `quiz.md`, `quiz-instructions.txt`, or the QTI zip; the prompt below goes in
the Audio Overview "Customize" box.

- `CHEME-5660-L11b-Lecture-CoveredCalls-Collars-Fall-2026.md` (the lecture)
- `CHEME-5660-L11b-Example-AnalysisCoveredCall-Fall-2026.md` (the AMD covered call example, in class)
- `CHEME-5660-L11b-Example-StandardListed-SPY-ProtectiveCollar-Fall-2026.md` (the SPY collar example, in class)
- `CHEME-5660-L11b-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: the covered call fund example and the net Delta derivation notebook
(both review on your own).

## 2. Audio Overview prompt

In the Audio Overview "Customize" dialog, choose Format: Deep Dive and Length: Shorter,
then paste this prompt.

```
Audience: engineering students in a quantitative finance course who already compute the profit at expiration, breakevens, maximum profit, and maximum loss of options and composite contracts, estimate probabilities of outcomes under our forecast P and under the risk-neutral probabilities Q, and know Delta as an estimate of the probability of exercise. New today: positions that combine shares with options.

Frame the episode around the two trades in the examples: an AMD covered call (buy shares at 531.26 USD/share and sell the 570 call for 31.25 USD/share, 53 days to expiration) and a SPY protective collar (buy shares at 763.335 USD/share, buy the 725 put, and sell the 802 call, 63 days to expiration). What can each earn and lose, and how likely is each outcome? Build the episode on these three results:
* A covered call owns 100 shares for each call it sells. The premium lowers the breakeven, and the call caps the profit at the strike: above the strike, the shares are sold at the strike.
* A protective collar adds a long put below the share price to a covered call. The put sets a floor under the loss, the call sets a cap on the profit, and in between the position moves with the shares. The call premium pays for part of the put, all of it (a zero-cost collar), or more than all of it.
* The net Delta is the number of shares plus the weighted Deltas of the option legs. A covered call's net Delta is never negative, and a collar's put and call can only lower its net Delta from that of the shares alone.

Accuracy rules: say whether each probability is under P (our forecast) or Q (the probabilities inside the market price). Explain Q only as the probabilities under which the expected discounted payoff equals the price; never mention replicating or hedging portfolios. The breakeven is today's cost grown to expiration at the risk-free rate, not the share price minus the premium. State maximum losses as positive amounts. The covered call earns its maximum profit above the strike, but the shares alone earn more only above the opportunity point, the strike plus the premium grown to expiration. A zero-cost collar means the two premiums are equal; buying the shares still costs money. Net Delta is measured in shares, not a probability. TJUL holds a deep in-the-money call on SPY instead of SPY shares. JEPI and JEPQ sell calls on their index through bank-issued notes, not on the stocks they own. Treat the net Delta derivation and delta-neutral positions as background. Do not describe results of the covered call fund simulation. Do not preview other lectures.

Tradeoffs: the AMD covered call's maximum profit is 66.98 USD/share and its breakeven 503.02 USD/share. Our forecast P has a much larger drift and a lower volatility than Q, so it gives a lower probability of a loss (about 0.26 against 0.43) but a higher probability of finishing above the opportunity point, where the shares alone would have earned more (about 0.37 against 0.26). In the SPY collar, the put costs more than the call, a net debit of 4.49 USD/share, so the collar is a little more likely to lose money than the shares alone (about 0.55 against 0.51 under Q), but its loss stops at 48.36 USD/share: here the put limits the size of a loss, not its chance. TJUL is a net debit collar on SPY; with SPY at 766.81 on November 4, 2026, above its call strike, if SPY stays there until expiration, TJUL would end about 77 USD/share below holding SPY alone; this is a what-if at expiration, not the fund's return today.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. The self-check quiz

Claude wrote `quiz.md` (11 questions, no flashcards) from these sources and checked every
number against the example outputs. NotebookLM is not used for the quiz. The Canvas package is
`L11b-quiz-canvas-qti.zip`, and the text for the quiz's Instructions box is
`quiz-instructions.txt` (plain text; paste it as is).

## 4. Before sharing

- **Listen** to the audio once. Stop on any of these: P and Q mixed up, a net Delta read as a probability, a breakeven of the share price minus the premium (it is grown to expiration), a negative maximum loss, TJUL described as holding SPY shares, JEPI or JEPQ described as selling calls on their own stocks, results of the covered call fund simulation, "replicating portfolio", a walkthrough of the net Delta derivation, or a preview of a later lecture.
- **Import the quiz.** In Canvas, Settings > Import Course Content > QTI .zip file, and choose `L11b-quiz-canvas-qti.zip`. In New Quizzes the Quiz Type is locked, so set Points to 0, check "Do not count this assignment towards the final grade", paste `quiz-instructions.txt` into the Instructions box, and preview the math.
- **Post** the audio on Canvas. Keep the audio and video out of git and the release zip.

## What was emphasized

- The three bullets are the lecture's "What you need to know" core points, in order. The net Delta derivation and delta-neutral positions are named as background.
- The framing uses both in-class trades, a covered call (income, capped upside) and a collar (a floor bought with part of the call premium), so the episode can contrast the two.
- The breakeven rule is spelled out because a host is likely to say "share price minus premium" and skip the growth to expiration.
- The company profile and TJUL facts a host could get wrong (index calls inside notes; a deep in-the-money call instead of shares) are stated as rules.
- The tradeoffs come from the example outputs (AMD: 66.98 and 503.02 USD/share; P(loss) 0.2561 under P and 0.4280 under Q; P(opportunity loss) 0.3695 under P and 0.2582 under Q; SPY: net debit 4.49, maximum loss 48.36 USD/share; P(loss) 0.5504 for the collar and 0.5122 for the shares alone under Q) and the lecture's TJUL callout (about 77 USD/share).
