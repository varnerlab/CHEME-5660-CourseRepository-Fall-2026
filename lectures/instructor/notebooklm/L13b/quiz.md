### **L13b Self-Check (13 Questions)**

#### **Question 1**
The jump hidden Markov model of `SPY` was fitted to the daily growth rates from 2014 to 2024. What makes the comparison with the growth rates of 2025 and 2026 an out-of-sample test?
- **A)** The test data hold more trading days than the fitting data
- **B)** The test data come from after the fitting period, so the model has not seen them
- **C)** The model is refitted to the growth rates of 2025 and 2026 before the comparison
- **D)** The test data come from a different ticker than `SPY`

**Answer:** **B) The test data come from after the fitting period, so the model has not seen them**
**Explanation:** An out-of-sample test compares a fitted model with data from after its fitting period. The model is not refitted; we simulate paths from the saved model and compare them with the new data.

---

#### **Question 2**
In the out-of-sample example, the 200 simulated paths without a jump episode passed the Kolmogorov–Smirnov test at a rate of 0.955 and the Anderson–Darling test at a rate of 0.985, with a mean excess kurtosis of 12.479. The 200 paths with an episode passed at rates of 0.125 and 0.070, with a mean excess kurtosis of 6.111. The growth rates of 2025 and 2026 had an excess kurtosis of 18.962. Which statement is correct?
- **A)** The paths with an episode pass more often, because they contain more large moves
- **B)** The model no longer describes the distribution of the daily growth rate in 2025 and 2026
- **C)** The paths with an episode have fatter tails than the test data
- **D)** Most paths without an episode pass both tests, although the test data have fatter tails than the average simulated path

**Answer:** **D) Most paths without an episode pass both tests, although the test data have fatter tails than the average simulated path**
**Explanation:** Of the paths without an episode, 95.5% pass the Kolmogorov–Smirnov test and 98.5% pass the Anderson–Darling test. Their mean excess kurtosis of 12.479 is below the 18.962 of the test data, which hold the sharp fall and rebound of April 2025.

---

#### **Question 3**
Why do most simulated paths with a jump episode fail the tests against the growth rates of 2025 and 2026?
- **A)** An episode lasts many days, and each episode day is a large move from one of the most negative or most positive states. These days add two side bumps to the distribution
- **B)** An episode replaces the Student-t emissions with normal emissions
- **C)** An episode draws only from the most negative states, so the path falls without stopping
- **D)** An episode removes the extreme states from the model, so the path has thin tails

**Answer:** **A) An episode lasts many days, and each episode day is a large move from one of the most negative or most positive states. These days add two side bumps to the distribution**
**Explanation:** The episode days give these paths two side bumps, and most of them fail both tests. The bumps also lower the group's mean excess kurtosis to 6.111, below the 12.479 of the paths without an episode.

---

#### **Question 4**
We set the episode probability \\(\epsilon\\) to zero in a copy of the model and scored 200 of its paths on the same test data. They passed at rates of 0.950 (Kolmogorov–Smirnov) and 0.975 (Anderson–Darling), close to the 0.955 and 0.985 of the paths without an episode. Why are the two groups so close?
- **A)** Setting \\(\epsilon = 0\\) refits the model to the growth rates of 2025 and 2026
- **B)** Setting \\(\epsilon = 0\\) removes the Student-t emissions from the model
- **C)** Both groups come from the same chain and emissions. Turning the episodes off changes only the paths that would have had an episode
- **D)** With \\(\epsilon = 0\\), every day is drawn from the most extreme states

**Answer:** **C) Both groups come from the same chain and emissions. Turning the episodes off changes only the paths that would have had an episode**
**Explanation:** With \\(\epsilon = 0\\), no episode can start, and the transition matrix and the emissions stay the same. The paths of the copy look like the paths of the saved model that had no episode.

---

#### **Question 5**
We compared the autocorrelation of the absolute growth rate \\(|g_{t}|\\) in 2025 and 2026 with that of the simulated paths. Which summary of the volatility clustering is correct?
- **A)** Both groups of simulated paths match the clustering of the test data
- **B)** The test data cluster at short lags. The paths without an episode forget a volatile day within a few days, and the paths with an episode stay clustered for months
- **C)** The paths without an episode stay clustered for months, and the paths with an episode show no clustering
- **D)** The test data show no volatility clustering at any lag

**Answer:** **B) The test data cluster at short lags. The paths without an episode forget a volatile day within a few days, and the paths with an episode stay clustered for months**
**Explanation:** Neither group of paths matches the test data. The chain alone forgets a volatile day within a few steps, while an episode keeps the large moves going for longer than the data do.

---

#### **Question 6**
The first version of the JumpHMM method simulated 424 stocks with the single index model, drawing each stock's residual independently. Why did simulated stocks in the same sector move together less than real stocks?
- **A)** The market sensitivities \\(\beta_{i}\\) were set to zero
- **B)** Each stock had its own market path, so the market part was not shared
- **C)** The residuals were drawn with a nonzero mean
- **D)** In the data, the single index residuals of two stocks in the same sector usually move together, but the single index model assumes the residuals are uncorrelated across stocks

**Answer:** **D) In the data, the single index residuals of two stocks in the same sector usually move together, but the single index model assumes the residuals are uncorrelated across stocks**
**Explanation:** For two banks, for example, \\(\operatorname{Cov}(\varepsilon_{i},\varepsilon_{j})>0\\) in the data. The single index model sets this covariance to zero, so the simulated stocks miss the co-movement within a sector.

---

#### **Question 7**
A synthetic stock has the baseline \\(\alpha_{i} = 0.10\\) (1/yr), the market sensitivity \\(\beta_{i} = 1.2\\), the sector loading \\(\delta_{i} = 0.8\\), and the residual scale \\(\psi_{i} = 1.1\\). On day \\(t\\), the draws are \\(g_{m}(t) = 2.0\\), \\(f_{s}(t) = -0.5\\), and \\(u_{i}(t) = 0.3\\) (all 1/yr). What is the stock's growth rate \\(g_{i}(t)\\)?
- **A)** 2.40 (1/yr)
- **B)** 3.23 (1/yr)
- **C)** 2.43 (1/yr)
- **D)** 2.33 (1/yr)

**Answer:** **C) 2.43 (1/yr)**
**Explanation:** \\(g_{i}(t) = \alpha_{i} + \beta_{i}\,g_{m}(t) + \delta_{i}\,f_{s}(t) + \psi_{i}\,u_{i}(t) = 0.10 + 2.40 - 0.40 + 0.33 = 2.43\\) (1/yr).

---

#### **Question 8**
What is the stock-specific draw \\(u_{i}(t)\\) in the sector factor model?
- **A)** The growth that neither the market nor the sector explains. We fit a single-asset jump hidden Markov model to its daily values and simulate a path from that model
- **B)** A Gaussian shock with the volatility of stock \\(i\\)
- **C)** The growth rate of `SPY`, shared by every stock
- **D)** The average single index residual of the stocks in the sector of stock \\(i\\)

**Answer:** **A) The growth that neither the market nor the sector explains. We fit a single-asset jump hidden Markov model to its daily values and simulate a path from that model**
**Explanation:** The stock-specific residual \\(u_{i}(t)\\) is what is left after removing the baseline, the market part, and the sector part. It averages zero, and its model is fitted the same way as the model of `SPY`.

---

#### **Question 9**
The sector factor \\(f_{s}(t)\\) is the average single index residual of the \\(n_{s}\\) stocks in sector \\(s\\), which works out to \\(f_{s}(t) = \bar{g}_{s}(t) - \bar{\alpha}_{s} - \bar{\beta}_{s}\,g_{m}(t)\\). What does this mean for a market move?
- **A)** A market move enters each stock's growth rate twice, once through \\(\beta_{i}\,g_{m}(t)\\) and once through \\(f_{s}(t)\\)
- **B)** The sector factor has the market part removed, so a market move enters each stock's growth rate only once, through \\(\beta_{i}\,g_{m}(t)\\)
- **C)** The sector factor is the growth rate of `SPY`, so the market part is shared by every sector
- **D)** A market move enters only through the stock-specific draw \\(u_{i}(t)\\)

**Answer:** **B) The sector factor has the market part removed, so a market move enters each stock's growth rate only once, through \\(\beta_{i}\,g_{m}(t)\\)**
**Explanation:** The sector factor is the sector's average growth rate with the baseline and the market part removed. The market part of each stock comes only from \\(\beta_{i}\,g_{m}(t)\\).

---

#### **Question 10**
Stocks 1 and 2 are in sector \\(s\\), with the sector loadings \\(\delta_{1} = 0.9\\) and \\(\delta_{2} = 1.2\\). The sector factor has \\(\operatorname{Var}(f_{s}) = 2.0\\) (1/yr)². What is the residual covariance \\(\operatorname{Cov}(\varepsilon_{1},\varepsilon_{2})\\) in the sector factor model?
- **A)** 0 (1/yr)²
- **B)** 2.0 (1/yr)²
- **C)** 4.2 (1/yr)²
- **D)** 2.16 (1/yr)²

**Answer:** **D) 2.16 (1/yr)²**
**Explanation:** For two stocks in the same sector, \\(\operatorname{Cov}(\varepsilon_{1},\varepsilon_{2}) = \delta_{1}\delta_{2}\operatorname{Var}(f_{s}) = (0.9)(1.2)(2.0) = 2.16\\) (1/yr)². The single index model sets this entry to zero.

---

#### **Question 11**
In the sector factor model, stock \\(i\\) is in sector \\(s\\) and stock \\(j\\) is in a different sector \\(r\\). Their market sensitivities are \\(\beta_{i} = 1.3\\) and \\(\beta_{j} = 0.8\\), and \\(\operatorname{Var}(g_{m}) = 7.5\\) (1/yr)². What is the covariance \\(\operatorname{Cov}(g_{i},g_{j})\\) of their growth rates?
- **A)** 0 (1/yr)²
- **B)** 7.8 (1/yr)²
- **C)** 15.75 (1/yr)²
- **D)** 9.75 (1/yr)²

**Answer:** **B) 7.8 (1/yr)²**
**Explanation:** Stocks in different sectors share only the market draw, so \\(\operatorname{Cov}(g_{i},g_{j}) = \beta_{i}\beta_{j}\operatorname{Var}(g_{m}) = (1.3)(0.8)(7.5) = 7.8\\) (1/yr)². The sector and stock-specific draws add nothing, because they are drawn independently.

---

#### **Question 12**
Stock \\(i\\) has a single index residual with \\(\operatorname{Var}(\varepsilon_{i}) = 6.0\\) (1/yr)² in the data. Its sector loading is \\(\delta_{i} = 1.0\\), its sector factor has \\(\operatorname{Var}(f_{s}) = 2.0\\) (1/yr)², and its stock-specific residual has \\(\operatorname{Var}(u_{i}) = 3.2\\) (1/yr)². With the residual scale \\(\psi_{i}\\) chosen, what is the variance of the simulated residual \\(\delta_{i}\,f_{s} + \psi_{i}\,u_{i}\\)?
- **A)** 6.0 (1/yr)²
- **B)** 5.2 (1/yr)²
- **C)** 2.0 (1/yr)²
- **D)** 3.2 (1/yr)²

**Answer:** **A) 6.0 (1/yr)²**
**Explanation:** The residual scale is chosen so that \\(\delta_{i}^{2}\operatorname{Var}(f_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i})=\operatorname{Var}(\varepsilon_{i})\\), the variance in the data. With \\(\psi_{i} = 1\\), the independent draws would give \\(2.0 + 3.2 = 5.2\\) (1/yr)² instead.

---

#### **Question 13**
Why does the simulation need the residual scale \\(\psi_{i}\\)?
- **A)** It converts the daily growth rates into annual growth rates
- **B)** It makes the stock-specific draw average zero
- **C)** The sector and stock-specific draws are independent in the simulation, which drops the covariance term \\(2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})\\) of the data. The residual scale resizes the stock-specific draw so that each stock keeps the variance of its single index residual
- **D)** It adds the market part back to the sector factor

**Answer:** **C) The sector and stock-specific draws are independent in the simulation, which drops the covariance term \\(2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})\\) of the data. The residual scale resizes the stock-specific draw so that each stock keeps the variance of its single index residual**
**Explanation:** With \\(\psi_{i}\\) chosen, \\(\delta_{i}^{2}\operatorname{Var}(f_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i})=\operatorname{Var}(\varepsilon_{i})\\), so each simulated stock keeps the variance of its single index residual. If \\(f_{s}\\) and \\(u_{i}\\) are uncorrelated in the data, \\(\psi_{i} = 1\\).
