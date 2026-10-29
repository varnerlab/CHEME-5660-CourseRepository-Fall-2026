### **Options Quiz (10 Questions)**

#### **Question 1**
Our Theta estimate for the long NVDA 230 call is \\(-51.56\\) USD/share per year. About how much value does one contract (100 shares) lose in one day?
- **A)** 51.56 USD
- **B)** 0.14 USD
- **C)** 14.13 USD
- **D)** 5,156 USD

**Answer:** **C) 14.13 USD**
**Explanation:** Divide by 365 for one day: \\(-51.56/365 = -0.1413\\) USD/share. One contract covers 100 shares, so it loses about 14.13 USD per day.

---

#### **Question 2**
Our Vega estimate for the long NVDA 230 call is 31.34 USD/share for a change of 1 in the volatility. If the implied volatility goes up by one percentage point, how much does the premium of one contract change?
- **A)** It goes up by about 0.31 USD
- **B)** It goes up by about 31.34 USD
- **C)** It goes down by about 31.34 USD
- **D)** It goes up by about 3,134 USD

**Answer:** **B) It goes up by about 31.34 USD**
**Explanation:** One percentage point is 0.01, so the premium goes up by \\(31.34 \cdot 0.01 = 0.3134\\) USD/share, or about 31.34 USD for 100 shares.

---

#### **Question 3**
The long NVDA 230 put has a Delta of \\(-0.4560\\). One **short** put contract acts like how many shares?
- **A)** \\(-45.60\\) shares, like a short position in the shares
- **B)** \\(-0.46\\) shares
- **C)** 45.60 shares, like owning shares
- **D)** 54.40 shares

**Answer:** **C) 45.60 shares, like owning shares**
**Explanation:** Selling flips the sign of Delta, so the short put's Delta is 0.4560. One contract covers 100 shares, so it acts like owning \\(100 \cdot 0.4560 = 45.60\\) shares.

---

#### **Question 4**
In the Greeks example, which Greeks have opposite signs for a long call and a long put?
- **A)** Theta and Vega
- **B)** Delta and Rho
- **C)** Gamma and Vega
- **D)** All five Greeks

**Answer:** **B) Delta and Rho**
**Explanation:** A long call has a positive Delta and Rho, and a long put has a negative Delta and Rho. Both have a positive Gamma and Vega and a negative Theta.

---

#### **Question 5**
We sell the NVDA 235 call for 9.88 USD/share. Grown to expiration at the risk-free rate, this premium is 9.93 USD/share. What is the breakeven price, and when does the seller make money?
- **A)** 225.07 USD/share; the seller makes money if the share price ends above it
- **B)** 244.88 USD/share; the seller makes money if the share price ends above it
- **C)** 244.93 USD/share; the seller makes money if the share price ends below it
- **D)** 235.00 USD/share; the seller makes money if the share price ends below it

**Answer:** **C) 244.93 USD/share; the seller makes money if the share price ends below it**
**Explanation:** For a call, the breakeven is the strike plus the premium grown to expiration: \\(235 + 9.93 = 244.93\\) USD/share. The seller makes money if the share price at expiration ends below it.

---

#### **Question 6**
How do we estimate the probability of exercise (POE) of the NVDA 235 call under the risk-neutral probabilities \\(\mathbb{Q}\\)?
- **A)** Simulate share prices at expiration and count the samples that end above the breakeven
- **B)** Simulate share prices at expiration with the drift set to the risk-free rate and the volatility set to the implied volatility, then count the samples that end above \\(K + 0.01\\) USD/share
- **C)** Simulate share prices at expiration with our historical drift and volatility, then count the samples that end below \\(K\\)
- **D)** Use the quoted Delta, with no simulation

**Answer:** **B) Simulate share prices at expiration with the drift set to the risk-free rate and the volatility set to the implied volatility, then count the samples that end above \\(K + 0.01\\) USD/share**
**Explanation:** A call is exercised if it ends more than 0.01 USD/share in the money. The risk-free drift and the implied volatility give the probabilities under \\(\mathbb{Q}\\), not our forecast.

---

#### **Question 7**
For the NVDA 235 call, the quoted Delta is 0.4833 and the POE under the risk-neutral probabilities \\(\mathbb{Q}\\) is 0.4295. Which statement is true?
- **A)** Delta equals the POE under \\(\mathbb{Q}\\), so the gap is a simulation error.
- **B)** Delta is our own forecast of the POE under our belief \\(\mathbb{P}\\).
- **C)** Delta is close to the POE under \\(\mathbb{Q}\\), but a little larger.
- **D)** Delta is always smaller than the POE under \\(\mathbb{Q}\\).

**Answer:** **C) Delta is close to the POE under \\(\mathbb{Q}\\), but a little larger.**
**Explanation:** Delta approximates the POE under \\(\mathbb{Q}\\) but overstates it (0.4833 against 0.4295), and the gap grows with the volatility and the time to expiration. It is not our forecast under \\(\mathbb{P}\\).

---

#### **Question 8**
For the NVDA 235 call, the POE is 0.4295 under the risk-neutral probabilities \\(\mathbb{Q}\\) and 0.6185 under our belief \\(\mathbb{P}\\). What mainly causes the difference?
- **A)** Under \\(\mathbb{P}\\), we use our historical drift (0.5788 per year), which is far above the risk-free rate (0.0413 per year).
- **B)** Under \\(\mathbb{P}\\), we use fewer simulated samples.
- **C)** Under \\(\mathbb{P}\\), we use a lower strike price.
- **D)** Under \\(\mathbb{Q}\\), we use a much larger volatility.

**Answer:** **A) Under \\(\mathbb{P}\\), we use our historical drift (0.5788 per year), which is far above the risk-free rate (0.0413 per year).**
**Explanation:** A higher drift pushes the simulated share prices up, so more of them end in the money. In the example's four-case table, changing only the volatility moves the POE much less, from 0.6342 to 0.6185.

---

#### **Question 9**
We sold the NVDA 235 call. The seller's probability of profit (POP) is 0.6976 under the risk-neutral probabilities \\(\mathbb{Q}\\) and 0.5034 under our belief \\(\mathbb{P}\\). What does this mean?
- **A)** Our forecast says the trade is more likely to make money than \\(\mathbb{Q}\\) says.
- **B)** Our forecast says the trade is less likely to make money than \\(\mathbb{Q}\\) says, because we expect NVDA to grow faster.
- **C)** The two numbers should be equal, so one of them is wrong.
- **D)** The seller's POP is one minus the quoted Delta in both cases.

**Answer:** **B) Our forecast says the trade is less likely to make money than \\(\mathbb{Q}\\) says, because we expect NVDA to grow faster.**
**Explanation:** The seller makes money if NVDA ends below 244.93 USD/share. Our higher drift under \\(\mathbb{P}\\) makes that less likely: 0.5034 under \\(\mathbb{P}\\) against 0.6976 under \\(\mathbb{Q}\\).

---

#### **Question 10**
To simulate share prices under our belief \\(\mathbb{P}\\), which drift and volatility do we use?
- **A)** The risk-free rate and the implied volatility
- **B)** The drift \\(\hat{\mu} = \hat{\mu}_g + \hat{\sigma}^2/2\\) and the volatility \\(\hat{\sigma}\\), estimated from historical prices
- **C)** The mean growth rate \\(\hat{\mu}_g\\) and the implied volatility
- **D)** Zero drift and the quoted Delta

**Answer:** **B) The drift \\(\hat{\mu} = \hat{\mu}_g + \hat{\sigma}^2/2\\) and the volatility \\(\hat{\sigma}\\), estimated from historical prices**
**Explanation:** Our belief \\(\mathbb{P}\\) uses our historical estimates: \\(\hat{\mu} = 0.5033 + 0.3886^2/2 = 0.5788\\) per year and \\(\hat{\sigma} = 0.3886\\). The risk-free rate and the implied volatility give \\(\mathbb{Q}\\) instead.
