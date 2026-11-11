# NotebookLM: L12a, Agent-Based Markets

## 1. Sources to upload

Upload these four files from this folder as the notebook's sources. Do not upload this
instructions file, `quiz.md`, `quiz-instructions.txt`, or the QTI zip; the prompt below goes in
the Audio Overview "Customize" box.

- `CHEME-5660-L12a-Lecture-AgentBasedMarkets-Fall-2026.md` (the lecture)
- `CHEME-5660-L12a-Example-FarmerJoshi-Fall-2026.md` (the Farmer–Joshi market example, in class)
- `CHEME-5660-L12a-Example-ThermalMinorityGame-Fall-2026.md` (the thermal minority game example, in class)
- `CHEME-5660-L12a-Slides-Fall-2026.pdf` (a copy of the deck)

Left out on purpose: the maximum-entropy derivation and the biased policies derivation
(both optional advanced notebooks).

## 2. Audio Overview prompt

In the Audio Overview "Customize" dialog, choose Format: Deep Dive and Length: Shorter,
then paste this prompt.

```
Audience: engineering students in a quantitative finance course who already simulate share prices with geometric Brownian motion, compute growth rates from prices, and have measured three stylized facts of daily growth rates: fat tails, little autocorrelation, and volatility clustering. New today: agent-based models, which start from the rules of individual traders instead of a model of the price.

Frame the episode around the two simulated markets in the examples: a Farmer-Joshi market, where 1,200 value investors and 1,200 trend followers trade one asset through a market maker, and a minority game, where 641 agents each choose to buy or sell every round and the less crowded side wins. What does each market do, and which trader rules cause it? Build the episode on these three results:
* An agent-based model has five parts: agents, the information each agent sees, a decision rule, an aggregate of the agents' decisions (the net order, the price, the attendance), and feedback from the aggregate to the next decisions. Name the five parts in both markets.
* The Boltzmann rule gives each policy a probability proportional to the exponential of its score divided by the temperature. Among all choice probabilities with the same expected score, it has the largest entropy. As the temperature goes to zero, the agent always uses its best policy. As the temperature goes to infinity, the agent chooses uniformly at random.
* Market-wide behavior comes from the rules, not from assumptions about prices. In the Farmer-Joshi market, value investors and trend followers together produce fat tails and volatility clustering. In the minority game, the volatility per agent depends on the number of histories per agent, alpha, and on the temperature.

Accuracy rules: this lecture has no option pricing; do not bring in P and Q, risk-neutral probabilities, or replicating or hedging portfolios. Say growth rate, not return. The attendance is the number of buyers minus the number of sellers in one round. The number of histories is 2 to the power of the memory, and alpha is the number of histories divided by the number of agents. The volatility per agent is the mean square of the attendance divided by the number of agents; agents who flip fair coins give 1, and a value above 1 is a crowded game. The temperature is a setting of the choice rule; do not explain it with physics. The Farmer-Joshi simulation is our variant of the paper, not a replication, and it matches some stylized facts but not all at once. The original minority game has no price; the price is the instructor's extension, and the agents never see it. Treat that price rule, the threshold rules of the Farmer-Joshi traders, the parameter values, and the maximum-entropy derivation as background. Use the November 5 sell-off only as an example of individual decisions adding up to a price move; do not say the models explain it. Do not preview other lectures.

Tradeoffs: value investors alone give growth rates that look Normal, with an excess kurtosis near zero. With 1,200 trend followers added, the excess kurtosis averages about 46 and the lag-1 autocorrelation of the absolute growth rates about 0.68, so fat tails and volatility clustering appear. But the growth rates then have a lag-1 autocorrelation of about 0.25, where real daily growth rates have almost none, and the clustering fades within about five steps, where the real ticker's lasts for weeks. In the minority game, the same 641 agents give an annualized price volatility of about 145% with a memory of 4 and about 19% with a memory of 8, against about 40% for agents who flip coins: the only difference is how much the agents' policies overlap. In the crowded game, a moderate temperature lowers the volatility below both the greedy game and random choice, because agents with the same best policy no longer switch at the same time.

Keep the tone conversational, not lecture-y. Prefer analogies over formulas read aloud.
```

## 3. The self-check quiz

Claude wrote `quiz.md` (12 questions, no flashcards) from these sources and checked every
number against the example outputs. NotebookLM is not used for the quiz. The Canvas package is
`L12a-quiz-canvas-qti.zip`, and the text for the quiz's Instructions box is
`quiz-instructions.txt` (plain text; paste it as is).

## 4. Before sharing

- **Listen** to the audio once. Stop on any of these: "return" or "log return" in place of growth rate, P and Q or option pricing, the attendance described as a head count, the number of histories read as a probability, the temperature explained with physics, a claim that the model reproduces a real market or explains the November 5 sell-off, the agents described as seeing the minority game's price, a walkthrough of the threshold rules or the maximum-entropy derivation, or a preview of a later lecture.
- **Import the quiz.** In Canvas, Settings > Import Course Content > QTI .zip file, and choose `L12a-quiz-canvas-qti.zip`. In New Quizzes the Quiz Type is locked, so set Points to 0, check "Do not count this assignment towards the final grade", paste `quiz-instructions.txt` into the Instructions box, and preview the math.
- **Post** the audio on Canvas. Keep the audio and video out of git and the release zip.

## What was emphasized

- The three bullets are the lecture's "What you need to know" core points, in order. The Farmer–Joshi threshold rules, the simulation's parameter values, and the price added to the minority game are named as background.
- The framing uses both in-class markets, so the episode can name the five parts twice and contrast traders who react to the price with agents who see only which side won.
- The skill's standing rules about P and Q do not apply to this lecture, which has no option pricing. The prompt tells the hosts to leave P, Q, and option pricing out.
- The definitions a host is likely to get wrong (the attendance, the number of histories, alpha, the volatility per agent, the temperature) are stated as rules.
- The tradeoffs come from the example outputs. Farmer–Joshi: excess kurtosis 0.076 with no trend followers; 46.466 and a lag-1 autocorrelation of the absolute growth rates of 0.675 with 1,200 trend followers and a lag-1 autocorrelation of the growth rates of 0.246 (averages over three markets). Minority game: 641 agents, annualized volatility 145.0% at memory 4, 19.1% at memory 8, and 40.3% for coin flips.
- The examples' numbers come from the stored notebook outputs. Re-export and update the prompt and `quiz.md` if the examples are rerun with different constants.
