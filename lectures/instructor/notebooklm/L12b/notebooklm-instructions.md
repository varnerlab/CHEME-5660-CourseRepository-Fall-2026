# NotebookLM: L12b, Why Do Markets Crash?

## 1. Sources to upload

Upload these four files from this folder as the notebook's sources. Do not upload this
instructions file, `quiz.md`, `quiz-instructions.txt`, or the QTI zip. The prompt below
goes in the Audio Overview "Customize" box.

- `CHEME-5660-L12b-Lecture-WhyDoMarketsCrash-ABM-Fall-2026.md` (the lecture)
- `CHEME-5660-L12b-Example-Wolfram-Rules-Fall-2026.md` (the one-rule example, in class)
- `CHEME-5660-L12b-Example-Wolfram-RuleSwitch-Fall-2026.md` (the rule-switch example, in class)
- `CHEME-5660-L12b-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: the stylized-facts and closed/open-market examples (review on
your own), and the optional Q-learning notebook. This follows the current lecture's
Examples section.

## 2. Audio Overview prompt

Use the L12a setup: Format: Deep Dive and Length: Shorter. Paste this prompt into
the Audio Overview "Customize" box.

```
Audience: engineering students in quantitative finance who know the Farmer-Joshi market and the minority game. New today: a Wolfram market, where traders on a grid read their neighbors' intentions.

Frame the episode around one question: can changing one entry of some traders' rule table cause a wave of selling? Use the two in-class examples: first compare markets where every interior trader follows Rule 19280 or Rule 19286, then switch only a quarter of the interior traders partway through a shared history.

Without dwelling on derivations, build the discussion on these three results:
* A rule maps the sum of four neighbors' intentions to the next intention. Buy is 0, Hold is 1, and Sell is 2, so there are nine possible sums, 0 through 8. The nine table entries, read from sum 8 to sum 0, form a base-3 rule number. With three Buy neighbors and one Hold neighbor, the sum is 1: Rule 19280 buys and Rule 19286 sells. The rules agree at every other sum.
* The dealer quotes the price as its cash divided by its shares. Net buying raises the price and net selling lowers it, apart from the added price noise. An intention is not a completed trade: a buyer needs cash and a seller needs shares.
* Compare the switched market with a control that shares its history and the same dealer noise but never switches. The Sell intention can spread beyond the traders whose rule changed. The price levels off when sellers run out of shares and filled buying and selling nearly balance, even if most traders still intend to sell.

Tradeoffs:
* Upside: changing one table entry lets us trace how a local decision spreads through neighbors and changes the price. Fresh players with cash, shares, and an always-Buy rule can move the price upward again.
* Downside: these traders are handed rules and do not learn them. The four-neighbor grid and the parameters are modeling choices, not a fit to real crashes. This is an analogy for a crash, not evidence that the same mechanism caused a historical one.

Accuracy rules: say growth rate rather than return. Do not bring in option pricing or risk-neutral probabilities. Distinguish the fraction whose rules change from the fraction who intend to Sell. The switch changes rules, not cash, shares, or current intentions. Keep the dealer derivation, clearing algorithm, and technical-trader band as background. Do not discuss results from the review-on-your-own examples, teach Q-learning, promise that every rule switch causes a crash, or preview later lectures.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. The self-check quiz

`quiz.md` contains 12 questions written from the lecture and the two in-class
examples. NotebookLM is not used for the quiz. The questions check the three core
concepts and use no numerical results read from plots.

The Canvas package is `L12b-quiz-canvas-qti.zip`. Paste `quiz-instructions.txt`
into the quiz's Instructions box.

## 4. Before sharing

- **Listen** to the audio once. Check that the hosts distinguish intentions from
  filled orders, rule changes from intention changes, and a simulation from an
  explanation of a historical crash. The rule table, dealer, and control should
  carry the discussion.
- **Import the quiz** using the same Canvas QTI workflow as L12a. Choose
  `L12b-quiz-canvas-qti.zip`, keep it ungraded, allow repeated attempts, and paste
  `quiz-instructions.txt` into the Instructions box. Preview all questions and math.
- **Post** the audio on Canvas after listening. Keep audio and video out of git
  and the release zip.

## What was emphasized

- The three results follow the lecture's "What you need to know" core points.
- The lecture and both current in-class examples use Rules 19280 and 19286.
  The rule-switch example changes a fraction `f = 0.25` of the interior traders.
  The commented 19287/19341 case is not the current setting.
- The two experiments differ: the one-rule example changes every interior
  trader's rule from the start; the rule-switch example changes a fraction
  partway through a shared history.
- The plateau and fresh-player discussion comes from Tasks 2 and 3 of the
  rule-switch example. No price levels, crash times, or ensemble statistics are
  inferred from the plots.
- The limitations come from the lecture's Summary. Re-export the sources if the
  notebooks change, and revisit the prompt and quiz if the rule pair changes.
