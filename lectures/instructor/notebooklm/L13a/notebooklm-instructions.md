# NotebookLM: L13a, Synthetic Markets with Jump Hidden Markov Models

## 1. Sources to upload

Upload these three files from this folder as the notebook's sources. Do not upload this
instructions file, `quiz.md`, `quiz-instructions.txt`, or the QTI zip. The prompt below
goes in the Audio Overview "Customize" box.

- `CHEME-5660-L13a-Lecture-JumpHMM-SyntheticMarkets-Fall-2026.md` (the lecture)
- `CHEME-5660-L13a-Example-JumpHMM-SPY-Fall-2026.md` (the `SPY` example, in class)
- `CHEME-5660-L13a-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: everything in `advanced/markov/` (the Markov models notebook
and its two examples). The lecture lists only the `SPY` example for class.

## 2. Audio Overview prompt

Use the L12a setup: Format: Deep Dive and Length: Shorter. Paste this prompt into
the Audio Overview "Customize" box.

```
Audience: engineering students in quantitative finance who simulate share prices with geometric Brownian motion, compute daily growth rates, and have measured three stylized facts of real growth rates: fat tails, near-zero autocorrelation, and volatility clustering. They have also simulated agent-based markets. New today: Markov chains and hidden Markov models, used to build synthetic markets, which are simulated price histories with the features of real ones.

Frame the episode around one question: can we fit a model to the daily growth rate of SPY from 2014 to 2024 and simulate many plausible paths for testing a trading method? Which features of the real series do the paths get right, and which do they miss?

Without dwelling on derivations, build the discussion on these three results:
* A Markov chain is a set of states and a transition matrix whose rows sum to one. Row i gives the probability of each state tomorrow, given state i today. We estimate each entry by counting: the share of the days in state i that were followed by a day in state j. The stationary distribution is the long-run share of time in each state.
* The jump hidden Markov model cuts the growth rate into bins of equal probability under a fitted Laplace distribution, so the states run from very bearish to very bullish. It counts moves between bins on consecutive days and draws each simulated day's growth rate from a Student-t distribution for that day's state. Jump episodes, runs of days drawn from the most extreme states, start with probability epsilon per day and last lambda days on average. They keep volatile periods going.
* Jump episodes add volatility clustering, but more or longer episodes thin the simulated tails and overstate the spread of the growth rates.

Tradeoffs:
* Without jumps, the simulated paths match the spread and fat tails of SPY: an excess kurtosis of about 13.1 against 13.8. But the lag-5 autocorrelation of the absolute growth rate is 0.003 against 0.325 for SPY, so volatility clustering fades within a few days.
* On the tuned paths that contain an episode, that lag-5 autocorrelation rises to 0.135. The excess kurtosis falls to about 12.0, and the standard deviation is about 12 percent above the real one. The tuned settings change with the random seed.
* An episode keeps volatility near one level for about lambda days, while SPY volatility in 2020 spiked and then faded.

Accuracy rules: this lecture has no option pricing. The bold P is the transition matrix, not a probability measure, so do not bring in P and Q or risk-neutral probabilities. Say growth rate, not return; growth rates are annualized, in units of 1/yr. When we fit, each day's state is known from the bin that holds its growth rate; the states are hidden only in simulation. Do not describe the Baum-Welch or expectation-maximization algorithms. The number of days per bin varies, because the fitted Laplace distribution only approximates the data. Epsilon is a per-day probability that an episode starts when none is under way, not the share of paths with an episode. An episode day draws from the most negative states slightly more than half the time and from the most positive states otherwise, so an episode is a run of large moves of both signs, not a one-way crash. Keep the fitting and sampling algorithms, the tuning score, and the Kolmogorov-Smirnov test as background. Mention the Wolfram market review and the State Street profile at most in passing. Do not discuss the optional Markov models notebook, claim that the paths forecast prices, or preview other lectures.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. The self-check quiz

`quiz.md` contains 13 questions written from the lecture and the `SPY` example.
NotebookLM is not used for the quiz. The questions check the three core concepts.
The numbers come from the example's printed tables and are given in each question.
No numbers are read from plots.

The Canvas package is `L13a-quiz-canvas-qti.zip`. Paste `quiz-instructions.txt`
into the quiz's Instructions box.

## 4. Before sharing

- **Listen** to the audio once. Check that the hosts say growth rate, describe the
  states as bins of the growth rate rather than inferred market regimes, and keep
  the per-day episode probability apart from the share of paths with an episode.
  An episode should come across as a run of large moves of both signs.
- **Import the quiz** using the same Canvas QTI workflow as L12b. Choose
  `L13a-quiz-canvas-qti.zip`, keep it ungraded, allow repeated attempts, and paste
  `quiz-instructions.txt` into the Instructions box. Preview all questions and math.
- **Post** the audio on Canvas after listening. Keep audio and video out of git
  and the release zip.

## What was emphasized

- The three results follow the lecture's "What you need to know" core points.
- The tradeoff numbers come from the example's two printed tables (no jumps, and
  tuned jumps on paths with an episode). The tuned epsilon and lambda change with
  the random seed, so the prompt does not quote them.
- The 2020 comparison is described in words only. Its values are read from a plot,
  and the lecture lists it under "For understanding".
- The fitting and sampling algorithms, the tuning score, and the Kolmogorov-Smirnov
  test are kept as background, as in the lecture's "For understanding" items.
- The Wolfram market review and the State Street profile are context for the
  lecture, not results. Re-export the sources if the notebooks change, and revisit
  the prompt and quiz if the example's tables change.
