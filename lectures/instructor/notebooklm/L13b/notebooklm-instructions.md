# NotebookLM: L13b, Synthetic Markets of Many Stocks

## 1. Sources to upload

Upload these three files from this folder as the notebook's sources. Do not upload this
instructions file, `quiz.md`, `quiz-instructions.txt`, or the QTI zip. The prompt below
goes in the Audio Overview "Customize" box.

- `CHEME-5660-L13b-Lecture-JumpHMM-ManyStocks-Fall-2026.md` (the lecture)
- `CHEME-5660-L13b-Example-JumpHMM-SPY-OutOfSample-Fall-2026.md` (the `SPY` out-of-sample example, in class)
- `CHEME-5660-L13b-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose:

- The sector factor example. Class covered the theory and the sampling algorithm but did
  not reach this example, so it moved to L14a
  (`lectures/week-14/L14a/CHEME-5660-L14a-Example-JumpHMM-SectorFactor-Fall-2026.ipynb`).
  The podcast and the quiz do not use its results.
- Everything in `advanced/` (the sector factor derivation and the one-minute `SPY` notebook).

## 2. Audio Overview prompt

Use the L13a setup: Format: Deep Dive and Length: Shorter. Paste this prompt into
the Audio Overview "Customize" box.

```
Audience: engineering students in quantitative finance who compute daily growth rates, know the single index model with a baseline alpha and a market sensitivity beta, and have simulated many stocks with geometric Brownian motion. They have also built a jump hidden Markov model of SPY. It bins the daily growth rate into states, counts moves between states, and draws each day's growth rate from a Student-t distribution of the day's state. Jump episodes add runs of large moves of both signs. New today: testing that model on data it has not seen, and building a synthetic market of many stocks that move together.

Frame the episode around two questions. Does the SPY model fitted to 2014 to 2024 still describe the growth rates of 2025 and 2026? And how do we simulate stocks such as two banks, whose growth rates move together more than the market alone explains?

Without dwelling on derivations, build the discussion on these three results:
* An out-of-sample test compares a fitted model with data from after its fitting period. We test the SPY model, with and without jump episodes, on the growth rates of 2025 and 2026.
* A synthetic stock's growth rate is g_i = alpha_i + beta_i g_m + delta_i f_s + psi_i u_i: a baseline plus a market part, a sector part, and a stock-specific part. Every stock shares the market draw, and every stock in a sector shares the sector draw, so stocks move together. The stock-specific draw u_i averages zero and is the growth that neither the market nor the sector explains.
* The residual scale psi_i sizes the stock-specific draw. Together, the sector and stock-specific draws keep the variance of each stock's single index residual in the data.

Tradeoffs:
* Episodes are rare on paths as long as the test data, so the example simulated until it had 200 paths with an episode and 200 without one. Of the paths without an episode, 95.5 percent pass the Kolmogorov-Smirnov test and 98.5 percent pass the Anderson-Darling test. Their mean excess kurtosis is 12.5. The test data, which include the sharp fall and rebound of April 2025, have an excess kurtosis of 19.0.
* Of the paths with an episode, only 12.5 and 7.0 percent pass, because the episode days add two side bumps to the distribution. The paths of the model with the episodes turned off pass 95.0 and 97.5 percent of the time. In the example's plot, the test data cluster at short lags. The mean autocorrelation of the paths without an episode fades within a few days, and that of the paths with an episode stays high for months.
* The single index model sets the residual covariance of two stocks to zero, so simulated stocks in the same sector move together less than real ones. The sector draw adds this covariance within each sector, but stocks in different sectors still move together only through the market draw.

Accuracy rules: this lecture has no option pricing, so do not bring in P and Q or risk-neutral probabilities. Say growth rate, not return; growth rates are annualized, in units of 1/yr. Alpha_i is the stock's baseline growth rate; the significance level of the tests is a different alpha. A path passes a test when its p-value is above the significance level, and the pass rate is the share of the paths in a group that pass. The sector factor f_s is the average single index residual of the stocks in sector s. It has the market part removed, so a market move enters a stock's growth rate only once, through beta_i g_m. The market, each sector factor, and each stock-specific part are drawn independently, each as a path from its own single-asset jump hidden Markov model, not as Gaussian shocks. The residual scale is one when the sector factor and the stock-specific residual are uncorrelated in the data. Keep the distribution tests, how we compute the sector loadings and residual scales, and the sampling algorithm step by step as background. The sector factor example has not been worked yet, so do not describe its results. Mention the AQR profile at most in passing. Do not discuss the optional advanced notebooks, claim that the paths forecast prices, or preview other lectures.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. The self-check quiz

`quiz.md` contains 13 questions written from the lecture and the `SPY` out-of-sample
example. NotebookLM is not used for the quiz. The questions check the three core
concepts. Questions 2 to 4 use the example's two printed tables. Questions 7 and 10
to 12 are short calculations with made-up numbers, which each question states. No
numbers are read from plots, and no question uses the sector factor example.

The Canvas package is `L13b-quiz-canvas-qti.zip`. Paste `quiz-instructions.txt`
into the quiz's Instructions box.

## 4. Before sharing

- **Listen** to the audio once. Check that the hosts say growth rate and keep the
  baseline alpha_i apart from the significance level of the tests. The sector factor
  should come across as the sector's average growth with the market part removed. The
  residual scale should come across as a variance match. The hosts should not describe
  results of a synthetic universe of many stocks, which the sources do not contain.
- **Import the quiz** with the L13a Canvas QTI workflow. Choose
  `L13b-quiz-canvas-qti.zip` and paste `quiz-instructions.txt` into the Instructions
  box. The zip imports as an ungraded practice quiz with unlimited attempts. Preview
  all questions and math.
- **Post** the audio on Canvas after listening. Keep audio and video out of git
  and the release zip.

## What was emphasized

- The three results follow the lecture's "What you need to know" core points.
- The out-of-sample numbers come from the example's two printed tables. The clustering
  comparison is described in words only, because it is read from a plot.
- The distribution tests, the sector loadings, the residual scale computation, and the
  sampling algorithm are kept as background, as in the lecture's "For understanding" items.
- The sector factor example is left out until it is worked in L14a. When the L14a set is
  built, add its export to the L14a sources.
- The AQR profile and the Alswaidan and Varner paper are context for the lecture, not
  results. Re-export the sources if the notebooks change, and revisit the prompt and quiz
  if the example's tables change.
