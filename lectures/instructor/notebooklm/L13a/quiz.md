### **L13a Self-Check (13 Questions)**

#### **Question 1**
A Markov chain has \\(N\\) states and the transition matrix \\(\mathbf{P}\\). What does row \\(i\\) of \\(\mathbf{P}\\) hold?
- **A)** The emission distribution of the growth rate in state \\(s_{i}\\)
- **B)** The probability of each state tomorrow, given the state today is \\(s_{i}\\); the entries of the row sum to one
- **C)** The number of days the chain spent in state \\(s_{i}\\); the entries of the row sum to the number of days
- **D)** The long-run share of time the chain spends in each state; the entries of the column sum to one

**Answer:** **B) The probability of each state tomorrow, given the state today is \\(s_{i}\\); the entries of the row sum to one**
**Explanation:** The entry \\(p_{ij}\\) is the probability of moving from \\(s_{i}\\) today to \\(s_{j}\\) tomorrow, so each row is a categorical distribution over tomorrow's state.

---

#### **Question 2**
In a sequence of observed states, the days in state \\(s_{2}\\) are followed by a day in \\(s_{1}\\) twice, by a day in \\(s_{2}\\) once, and by a day in \\(s_{3}\\) five times. They are never followed by any other state. What is the counting estimate \\(\hat{p}_{23}\\)?
- **A)** \\(1/3\\)
- **B)** \\(5/7\\)
- **C)** \\(5/8\\)
- **D)** \\(5\\)

**Answer:** **C) \\(5/8\\)**
**Explanation:** The estimate is \\(\hat{p}_{23} = n_{23}/\sum_{k} n_{2k} = 5/(2+1+5) = 5/8\\), the share of the days in \\(s_{2}\\) that moved to \\(s_{3}\\).

---

#### **Question 3**
What does the stationary distribution \\(\bar{\pi}\\) of a Markov chain describe?
- **A)** The probability of each state on the last day of the data
- **B)** The average growth rate in each state
- **C)** The probability that a jump episode starts
- **D)** The long-run share of time the chain spends in each state

**Answer:** **D) The long-run share of time the chain spends in each state**
**Explanation:** The stationary distribution solves \\(\bar{\pi} = \bar{\pi}\mathbf{P}\\) and gives the long-run share of time the chain spends in each state.
---

#### **Question 4**
A two-state chain has the transition matrix \\(\mathbf{P}\\) with row 1 equal to \\((0.9, 0.1)\\) and row 2 equal to \\((0.5, 0.5)\\). Which row vector satisfies \\(\bar{\pi} = \bar{\pi}\mathbf{P}\\) and sums to one?
- **A)** \\((5/6, 1/6)\\)
- **B)** \\((1/2, 1/2)\\)
- **C)** \\((1/6, 5/6)\\)
- **D)** \\((0.9, 0.5)\\)

**Answer:** **A) \\((5/6, 1/6)\\)**
**Explanation:** \\((5/6)(0.9)+(1/6)(0.5) = 5/6\\) and \\((5/6)(0.1)+(1/6)(0.5) = 1/6\\), so the vector is unchanged by \\(\mathbf{P}\\). Choice D does not sum to one.

---

#### **Question 5**
When we fit the jump hidden Markov model to the `SPY` data, how is each day assigned to a state?
- **A)** Each day's state is drawn at random from the stationary distribution
- **B)** Each day gets the state whose bin holds its growth rate, so the states of the data are known
- **C)** Each day's state is the calendar month of that day
- **D)** The days of the data are never assigned to states; only simulated paths have states

**Answer:** **B) Each day gets the state whose bin holds its growth rate, so the states of the data are known**
**Explanation:** Each state is a bin of the growth rate, so every day of the data falls in a known state. We count the moves between these states to estimate the transition matrix.
---

#### **Question 6**
The `SPY` model has \\(N = 100\\) states, binned with equal probability under a fitted Laplace distribution. In the training data, state 1 holds 44 days and state 100 holds 20 days. Why are these counts different?
- **A)** The bins have equal probability under the fitted Laplace distribution, which only approximates the data
- **B)** The bins were chosen to hold an equal number of days, and the counting has an error
- **C)** State 1 is visited by jump episodes during fitting
- **D)** The transition matrix moves the data into the negative states

**Answer:** **A) The bins have equal probability under the fitted Laplace distribution, which only approximates the data**
**Explanation:** Each bin holds probability \\(1/N\\) under the fitted Laplace distribution, not \\(1/N\\) of the days. The number of days per bin varies because the fitted distribution approximates the data.

---

#### **Question 7**
In the `SPY` model, state 75 has the emission location \\(\mu_{75} = 1.365\\) (1/yr) and scale \\(\sigma_{75} = 0.018\\) (1/yr). A Student-t draw gives \\(T_{\nu} = -2.0\\). What growth rate does the model emit?
- **A)** 1.401 (1/yr)
- **B)** 1.347 (1/yr)
- **C)** 1.329 (1/yr)
- **D)** -2.730 (1/yr)

**Answer:** **C) 1.329 (1/yr)**
**Explanation:** The emission is \\(g_{t} = \mu_{k} + \sigma_{k}T_{\nu} = 1.365 + (0.018)(-2.0) = 1.329\\) (1/yr).

---

#### **Question 8**
Which parts of the jump hidden Markov model give the simulated growth rates fat tails, even with no jump episodes?
- **A)** The stationary distribution and the counted transition matrix
- **B)** The Laplace location \\(\mu\\) and the number of states \\(N\\)
- **C)** Only the jump episodes; without them, the growth rates are normal
- **D)** The Student-t emissions and the wide extreme bins

**Answer:** **D) The Student-t emissions and the wide extreme bins**
**Explanation:** The extreme states cover the widest ranges of growth rates, and Student-t draws produce more large values than normal draws. Together they give the simulated growth rates fat tails.
---

#### **Question 9**
Without jump episodes, the simulated `SPY` paths had a standard deviation of 2.793 (1/yr) against 2.741 for `SPY`, and an excess kurtosis of 13.137 against 13.768. The autocorrelation of \\(|g_{t}|\\) at lag 5 was 0.003 on the paths against 0.325 for `SPY`. Which feature does the model without jumps miss?
- **A)** The spread of the growth rates
- **B)** The fat tails of the growth rates
- **C)** Volatility clustering, because the counted chain forgets a volatile day within a few steps
- **D)** Near-zero autocorrelation of the growth rate \\(g_{t}\\)

**Answer:** **C) Volatility clustering, because the counted chain forgets a volatile day within a few steps**
**Explanation:** The spread and excess kurtosis are close to the data, but the autocorrelation of \\(|g_{t}|\\) falls to almost zero by lag 5. In real data, large moves keep following large moves for months.

---

#### **Question 10**
Which description of a jump episode matches the model?
- **A)** On a day with no episode under way, an episode starts with probability \\(\epsilon\\) and lasts \\(\lambda\\) days on average. Its days are drawn from the most extreme states, so it is a run of large daily moves
- **B)** An episode starts every \\(\lambda\\) days and draws only from the most negative states, so it models a crash
- **C)** An episode replaces the transition matrix with the stationary distribution for \\(\epsilon\\) days
- **D)** An episode multiplies every growth rate by \\(\lambda\\) until the path ends

**Answer:** **A) On a day with no episode under way, an episode starts with probability \\(\epsilon\\) and lasts \\(\lambda\\) days on average. Its days are drawn from the most extreme states, so it is a run of large daily moves**
**Explanation:** Episode days come from the most negative or the most positive states, so an episode is a run of large moves of both signs, not a one-way crash. It keeps a volatile period going.
---

#### **Question 11**
The tuned `SPY` model has \\(\epsilon = 0.0001\\) per day, and in the example run 27% of the simulated paths contained a jump episode. What does \\(\epsilon\\) measure?
- **A)** The share of simulated paths that contain an episode
- **B)** The probability that an episode starts on a day with no episode under way
- **C)** The share of days in each path that are episode days
- **D)** The probability that an episode day is negative

**Answer:** **B) The probability that an episode starts on a day with no episode under way**
**Explanation:** \\(\epsilon\\) is a per-day probability. The share of paths with an episode is a different number, which also depends on how many days each path has.

---

#### **Question 12**
In the example run, on the simulated paths that contain an episode, the autocorrelation of \\(|g_{t}|\\) at lag 25 was 0.102 (`SPY`: 0.146; no jumps: -0.001). The excess kurtosis was 12.018 (`SPY`: 13.768; no jumps: 13.137), and the standard deviation was 1.123 times the real one. Which summary is correct?
- **A)** Jump episodes improve every feature at once
- **B)** Jump episodes raise the kurtosis above the real value and leave the clustering unchanged
- **C)** Jump episodes have no effect, because the tuned \\(\epsilon\\) is small
- **D)** Jump episodes add volatility clustering, but they lower the kurtosis and raise the spread above the real one

**Answer:** **D) Jump episodes add volatility clustering, but they lower the kurtosis and raise the spread above the real one**
**Explanation:** The lag-25 autocorrelation moves from about zero toward the real value, while the excess kurtosis falls from 13.137 to 12.018 and the standard deviation rises to 1.123 times the real one.
---

#### **Question 13**
In the example's study of jump settings, why do frequent episodes thin the tails of the simulated distribution?
- **A)** Episode days draw their growth rates from a few extreme states, which adds two side bumps to the distribution and lowers the kurtosis
- **B)** Episodes remove the extreme states from the model
- **C)** Episodes replace the Student-t emissions with normal emissions
- **D)** Episodes shrink the standard deviation of every state

**Answer:** **A) Episode days draw their growth rates from a few extreme states, which adds two side bumps to the distribution and lowers the kurtosis**
**Explanation:** The bumps come from the episode days, whose growth rates come from a few extreme states. The real distribution has no such bumps, and the simulated kurtosis falls below the real value.
