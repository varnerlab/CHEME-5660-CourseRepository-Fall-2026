# NotebookLM: L10b, The Greeks, POE, and POP in Practice

Redone October 29, 2026. Class ran behind: L10b covered the review of the Greeks,
the POE, and the POP, the Akuna Capital profile, and the two L10a examples. The
composite contract material moved to L11a, and the earlier L10b set (which covered
it) is in `../L11a/`.

## 1. Sources to upload

Upload these four files from this folder as the notebook's sources. Do not upload this
instructions file; its prompts go in the "Customize" boxes.

- `CHEME-5660-L10b-Lecture-Review-Greeks-POE-POP.md` (the lecture's review section and the Akuna Capital profile only)
- `CHEME-5660-L10a-Example-Greeks-PutCall.md` (Example 1, in class)
- `CHEME-5660-L10a-Example-POE-POP-Call.md` (Example 2, in class)
- `CHEME-5660-L10b-Slides-Review-Fall-2026.pdf` (deck pages 6 to 10: the four review frames and the Akuna frame)

Left out on purpose: the lecture's title block, learning objectives, and every
composite contract section, and the matching deck frames, because class did not reach
them. The put credit spread and strangle examples are left out for the same reason.

## 2. Audio Overview prompt

In the Audio Overview "Customize" dialog, choose Format: Deep Dive and Length: Shorter,
then paste this prompt.

```
Audience: engineering students in a quantitative finance course who already price American calls and puts on a binomial (CRR) tree under the risk-neutral probabilities Q, and who met the Greeks, the probability of exercise (POE), and the probability of profit (POP) in the previous class. Today they used them on real NVDA contracts.

Frame the episode around one question: suppose we sell the NVDA 235 call that expires in 43 days. How sensitive is its premium to the market, and how likely is it to be exercised or to make money? Build the episode on these three results:
* What each Greek measures: Delta and Gamma (the share price), Theta (time), Vega (volatility), and Rho (the risk-free rate). Our Theta is per year, so divide by 365 for one day; divide Vega and Rho by 100 for one percentage point. One contract covers 100 shares, so it acts like 100 times Delta shares, and a short contract's Greeks are the long contract's with the sign flipped.
* The POE is the probability the contract finishes in the money by more than 0.01 USD/share. The POP is the probability its profit at expiration is positive, which is decided by the breakeven: the strike plus the premium grown to expiration for a call. Both come from simulated share prices at expiration.
* The size of Delta approximates the POE under Q, the probabilities inside the market price. It is not our forecast. The same simulation with our own drift and volatility gives the POE and POP under P, our belief.

Accuracy rules: say whether each probability is under P (our belief) or Q (the risk-neutral probabilities). Explain Q only as the probabilities under which the expected discounted payoff equals the price; never explain Q through a replicating or hedging portfolio. Say "our belief P", not "the physical measure". Never read our per-year Theta as a daily number. Treat the Taylor expansion, the Leisen-Reimer tree, and the CRR sums behind Delta as background and do not walk through them. Do not discuss composite contracts or spreads, and do not preview other lectures.

Tradeoffs: the Greeks describe small moves; for a 5 percent rise in the share price, Delta alone predicts a gain of 631.88 USD for one long 230 call, while repricing gives 722.20 USD. The quoted Delta of the 235 call, 0.4833, sits above its POE under Q, 0.4295. Under P, with our historical drift of 0.5788 per year instead of the risk-free rate of 0.0413, the POE rises to 0.6185 and the seller's POP falls from 0.6976 under Q to 0.5034.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. Quiz

Claude writes the 10-question quiz from these sources (`quiz.md`), so NotebookLM is used
for the audio only. There are no flashcards, because Canvas has no flashcard tool. The
scope the quiz follows:

```
Write questions only on these three core results: (1) what each Greek measures, converting Theta to a one-day change (divide by 365) and Vega and Rho to a one-percentage-point change (divide by 100), share equivalents of 100 times Delta per contract, and the sign flip for short contracts; (2) the POE and the POP from simulated share prices at expiration, the 0.01 USD/share exercise threshold, and the breakeven price; (3) the size of Delta as an approximation of the POE under Q, and how the POE and POP change under P, our belief. Mix concept questions with short calculations that use the NVDA numbers in the sources. Do not ask about the Taylor expansion, the Leisen-Reimer tree, or the CRR sums. Do not ask about composite contracts. In every question and answer, say whether a probability is under P or Q.
```

## 4. Before sharing

- **Listen** to the audio once. Stop on any of these: P and Q mixed up, Theta read as a daily number, "replicating portfolio", composite contracts or spreads, or a preview of a later lecture.
- **Build the Canvas quiz.** Import `L10b-quiz-canvas-qti.zip` in Canvas (Settings > Import Course Content > QTI .zip file), set Points to 0, check "Do not count this assignment towards the final grade", preview the math, and paste `quiz-instructions.txt` into the Instructions box.
- **Post** the audio on Canvas. Keep the audio and video out of git and the release zip.

## What was emphasized

- The framing uses the short NVDA 235 call from the POE and POP example, and the tradeoffs add the 230 call from the Greeks example, so the episode stays on the two examples worked in class.
- The three bullets are the first must-know point of the L10b box (POE, POP, and Delta), split out, with the Greeks units from the review section in front of it.
- The lecture export holds only the review section and the Akuna profile. The Akuna profile's connection paragraph names a put credit spread; the prompt says not to discuss spreads.
- The tradeoffs come from example outputs: the Delta-only, Delta-Gamma, and repriced changes for a 5 percent move (631.88, 726.28, and 722.20 USD); the quoted Delta 0.4833 against the POE under Q 0.4295; and the four-case table (POE 0.6185 and seller's POP 0.5034 under P; 0.4295 and 0.6976 under Q).
