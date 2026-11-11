### **L12a Self-Check (12 Questions)**

#### **Question 1**
Which list gives the five parts that every agent-based model in the lecture shares?
- **A)** Agents, a drift, a volatility, a price, and price noise
- **B)** Agents, the information each agent sees, a decision rule, an aggregate of the agents' decisions, and feedback from the aggregate to the next decisions
- **C)** Value investors, trend followers, a market maker, a price, and a fundamental value
- **D)** A history, a policy, a score, a temperature, and an attendance

**Answer:** **B) Agents, the information each agent sees, a decision rule, an aggregate of the agents' decisions, and feedback from the aggregate to the next decisions**
**Explanation:** These five parts appear in both models; the other lists mix in pieces of geometric Brownian motion or of one particular model.

---

#### **Question 2**
In the Farmer–Joshi market, which quantity is the aggregate of the traders' decisions that the market maker turns into a price change?
- **A)** The log of the fundamental value, \\(\ln V_{t}\\)
- **B)** The entry threshold \\(\chi^{\text{in}}_{i}\\) of trader \\(i\\)
- **C)** The net order, \\(\sum_{i}\omega^{(i)}_{t+1}\\)
- **D)** The noise draw \\(Z_{t+1}\\)

**Answer:** **C) The net order, \\(\sum_{i}\omega^{(i)}_{t+1}\\)**
**Explanation:** Each trader's order is the change in its position, and the market maker moves the log price in proportion to the sum of the orders; the new price then feeds back into every trader's signal.

---

#### **Question 3**
In the minority game, what information does every agent see before it acts in round \\(t\\)?
- **A)** The history \\(\mu_{t}\\), the winning (minority) actions of the last \\(m\\) rounds
- **B)** The gap between the price and its own estimate of the fundamental value
- **C)** The price change over its own lag \\(\theta_{i}\\)
- **D)** The policies that the other agents hold

**Answer:** **A) The history \\(\mu_{t}\\), the winning (minority) actions of the last \\(m\\) rounds**
**Explanation:** Every agent sees the same history, and each policy is a table that gives an action for each of the \\(P=2^{m}\\) possible histories; choices B and C are the signals of the Farmer–Joshi traders.

---

#### **Question 4**
An agent has two policies and uses the Boltzmann rule \\(p_{j}=\exp(U_{j}/T)/\mathcal{Z}\\). The gap between the two scores equals the temperature, \\(U_{1}-U_{2}=T\\). With what probability does the agent use policy 1, the higher-scoring policy?
- **A)** 0.5000
- **B)** 1.0000
- **C)** 0.2689
- **D)** 0.7311

**Answer:** **D) 0.7311**
**Explanation:** Dividing the numerator and denominator by \\(\exp(U_{1}/T)\\) gives \\(p_{1}=1/(1+\exp(-(U_{1}-U_{2})/T))=1/(1+e^{-1})=0.7311\\), the \\(T/\Delta=1\\) row of the table in the example.

---

#### **Question 5**
An agent has \\(J\\) policies with different scores and uses the Boltzmann rule. What happens to its choice in the two temperature limits?
- **A)** As \\(T\to 0\\), it chooses uniformly at random; as \\(T\to\infty\\), it always uses its best policy.
- **B)** As \\(T\to 0\\), it always uses its best policy; as \\(T\to\infty\\), it chooses each policy with probability \\(1/J\\).
- **C)** As \\(T\to 0\\), it always uses its worst policy; as \\(T\to\infty\\), it always uses its best policy.
- **D)** The choice probabilities do not depend on the temperature.

**Answer:** **B) As \\(T\to 0\\), it always uses its best policy; as \\(T\to\infty\\), it chooses each policy with probability \\(1/J\\).**
**Explanation:** The temperature sets how much a difference in scores matters: a small \\(T\\) gives the greedy game, and a very large \\(T\\) makes every \\(\exp(U_{j}/T)\\) close to 1, so every policy has probability \\(1/J\\).

---

#### **Question 6**
In what sense is the Boltzmann rule the maximum-entropy choice?
- **A)** It gives every policy the same probability at every temperature.
- **B)** It always chooses the policy with the highest score.
- **C)** Among all choice probabilities with the same expected score, it has the largest entropy, a measure of how spread out the probabilities are.
- **D)** It gives the smallest volatility per agent in the minority game.

**Answer:** **C) Among all choice probabilities with the same expected score, it has the largest entropy, a measure of how spread out the probabilities are.**
**Explanation:** Maximizing the entropy of the choice probabilities for a fixed expected score gives \\(p_{j}=\exp(U_{j}/T)/\mathcal{Z}\\).

---

#### **Question 7**
In the Farmer–Joshi example, we hold 1,200 value investors and vary the number of trend followers. With no trend followers, the excess kurtosis of the growth rates averages 0.076 and the lag-1 autocorrelation of \\(\lvert g\rvert\\) averages 0.014. With 1,200 trend followers, the two averages are 46.466 and 0.675. What do these numbers show?
- **A)** Value investors alone produce fat tails and volatility clustering.
- **B)** The Normal price noise produces the fat tails.
- **C)** Trend followers make the growth rates follow a Normal distribution.
- **D)** Fat tails and volatility clustering appear only once enough trend followers trade alongside the value investors.

**Answer:** **D) Fat tails and volatility clustering appear only once enough trend followers trade alongside the value investors.**
**Explanation:** An excess kurtosis near zero is the Normal value, and a positive autocorrelation of \\(\lvert g\rvert\\) means large moves follow large moves; neither pattern was put into the model, so both come from the traders' rules and the market maker.

---

#### **Question 8**
In Task 1 of the Farmer–Joshi example, the lag-1 autocorrelation of the growth rates is \\(-0.0240\\) with value investors only, 0.9099 with trend followers only, and 0.3080 with both groups. The white-noise band is \\(\pm 0.0139\\). Which stylized fact of real daily growth rates does our market with both groups fail to match?
- **A)** Little autocorrelation of the growth rates: 0.3080 is far outside the white-noise band.
- **B)** Fat tails: the excess kurtosis of this market is zero.
- **C)** Volatility clustering: the absolute growth rates have no autocorrelation at lag 1.
- **D)** None; the market matches every stylized fact at once.

**Answer:** **A) Little autocorrelation of the growth rates: 0.3080 is far outside the white-noise band.**
**Explanation:** Trend followers push the price further in the direction it has been moving, which gives a positive autocorrelation, and in our variant the value investors do not cancel it; the model produces fat tails and volatility clustering but not every stylized fact at once.

---

#### **Question 9**
The minority game in Task 1 of the example has \\(N=641\\) agents and memory \\(m=6\\). What is the number of histories per agent, \\(\alpha=P/N\\)?
- **A)** 10.02
- **B)** 0.0998
- **C)** 0.0094
- **D)** 0.0562

**Answer:** **B) 0.0998**
**Explanation:** The number of histories is \\(P=2^{m}=2^{6}=64\\), so \\(\alpha=64/641=0.0998\\).

---

#### **Question 10**
The greedy minority game with \\(N=641\\) and \\(\alpha=0.0998\\) has a volatility per agent of \\(\sigma_{A}^{2}/N=2.804\\). What does this value tell us?
- **A)** Each agent wins about 2.8 rounds out of every 641.
- **B)** The numbers of buyers and sellers are closer to equal than if every agent flipped a fair coin.
- **C)** The game is crowded: more agents end up on the same side than if every agent flipped a fair coin, which gives \\(\sigma_{A}^{2}/N\approx 1\\).
- **D)** The agents choose their policies uniformly at random.

**Answer:** **C) The game is crowded: more agents end up on the same side than if every agent flipped a fair coin, which gives \\(\sigma_{A}^{2}/N\approx 1\\).**
**Explanation:** With independent coin flips, the variance of the attendance is \\(N\\), so the volatility per agent is about 1 for any number of agents; with far more agents than histories, many agents hold similar policies and switch to the same action at the same time.

---

#### **Question 11**
In the greedy minority game with \\(J=2\\) policies per agent, how does the volatility per agent \\(\sigma_{A}^{2}/N\\) change as the number of histories per agent \\(\alpha\\) increases from well below 0.2 to well above 0.34?
- **A)** It starts above 1, falls to its smallest value, well below 1, near \\(\alpha=0.34\\), and then rises toward 1 from below.
- **B)** It increases steadily from below 1 to above 1.
- **C)** It stays at the coin-flip value of 1 for every \\(\alpha\\).
- **D)** It decreases steadily toward zero.

**Answer:** **A) It starts above 1, falls to its smallest value, well below 1, near \\(\alpha=0.34\\), and then rises toward 1 from below.**
**Explanation:** At small \\(\alpha\\) many agents hold identical or strongly correlated policies and the game is crowded; near 0.34 buyers and sellers nearly balance; at larger \\(\alpha\\) the agents' policies overlap less and less, and the volatility per agent approaches the coin-flip value.

---

#### **Question 12**
In the crowded minority game of the example, we vary the temperature \\(T\\) of the Boltzmann rule from the greedy game to random choice. How does the volatility change?
- **A)** It is lowest in the greedy game and rises steadily with the temperature.
- **B)** It is lowest for random choice and highest at moderate temperatures.
- **C)** It does not depend on the temperature.
- **D)** At moderate temperatures it falls below both the greedy game and random choice.

**Answer:** **D) At moderate temperatures it falls below both the greedy game and random choice.**
**Explanation:** When every agent always uses its best policy, agents with the same best policy switch together; some randomness in the choice spreads out those switches, and the volatility is lower than at either limit.
