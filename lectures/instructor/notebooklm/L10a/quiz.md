### **Options Quiz (10 Questions)**

#### **Question 1**
An NVDA call option with strike \\(K = \$230.00\\) trades at a premium of \\(\$12.15\\) while NVDA stock is at \\(S_0 = \$230.57\\). What are the intrinsic value and extrinsic value of this contract, and would early exercise be optimal assuming no dividends?
- **A)** Intrinsic value \\(= \$12.15\\), Extrinsic value \\(= \$0.00\\); early exercise is optimal.
- **B)** Intrinsic value \\(= \$0.57\\), Extrinsic value \\(= \$11.58\\); early exercise is not optimal.
- **C)** Intrinsic value \\(= \$0.00\\), Extrinsic value \\(= \$12.15\\); early exercise is optimal.
- **D)** Intrinsic value \\(= \$11.58\\), Extrinsic value \\(= \$0.57\\); early exercise is not optimal.

**Answer:** **B) Intrinsic value \\(= \$0.57\\), Extrinsic value \\(= \$11.58\\); early exercise is not optimal.**
**Explanation:** Intrinsic value is \\(\max(0, S_0 - K) = \max(0, 230.57 - 230.00) = \$0.57\\), leaving extrinsic value as \\(\$12.15 - \$0.57 = \$11.58\\), and early exercise is suboptimal without dividends because it forfeits positive extrinsic value and pays cash early.

---

#### **Question 2**
Under what conditions does early exercise make economic sense for American options?
- **A)** For a call option without dividends when it goes deep in the money.
- **B)** For a deep in-the-money put option to collect cash early, or for a call option the day before an ex-dividend date if the dividend exceeds the remaining extrinsic value.
- **C)** For any call or put option whenever the probability of exercise under our belief \\(\mathbb{P}\\) exceeds 0.50.
- **D)** For a put option only when the probability of profit under \\(\mathbb{Q}\\) is zero.

**Answer:** **B) For a deep in-the-money put option to collect cash early, or for a call option the day before an ex-dividend date if the dividend exceeds the remaining extrinsic value.**
**Explanation:** Exercising a deep in-the-money put allows the holder to collect strike cash \\(K\\) immediately to earn interest, while a call is only exercised early before an ex-dividend date if the dividend outweighs the lost extrinsic value.

---

#### **Question 3**
On the tree, the derivative of the NVDA 230 call premium with respect to calendar time is \\(\Theta_c = -51.56\text{ USD/share per year}\\). What is the estimated 1-day time decay for 1 contract (100 shares)?
- **A)** \\(-\$0.1413\\) per contract per day
- **B)** \\(-\$5.156\\) per contract per day
- **C)** \\(-\$14.13\\) per contract per day
- **D)** \\(-\$51.56\\) per contract per day

**Answer:** **C) \\(-\$14.13\\) per contract per day**
**Explanation:** The 1-day change per share is \\(\Theta_c / 365 = -51.56 / 365 = -\$0.1413\text{ USD/share/day}\\), which equals \\(-\$14.13\\) per day across a 100-share contract.

---

#### **Question 4**
For the NVDA 230 call contract, the derivatives of the premium with respect to the volatility and the rate are \\(\nu_c = 31.34\\) and \\(\rho_c = 13.49\\) USD/share per unit change (a change of 1.00, or 100 percentage points). What are the expected premium changes per share for a \\(+1\text{ percentage point}\\) increase in implied volatility and a \\(+1\text{ percentage point}\\) increase in the risk-free rate, respectively?
- **A)** \\(+\$31.34\\) per share for volatility; \\(+\$13.49\\) per share for rate.
- **B)** \\(+\$0.3134\\) per share for volatility; \\(+\$0.1349\\) per share for rate.
- **C)** \\(+\$3.134\\) per share for volatility; \\(+\$1.349\\) per share for rate.
- **D)** \\(+\$0.0313\\) per share for volatility; \\(+\$0.0135\\) per share for rate.

**Answer:** **B) \\(+\$0.3134\\) per share for volatility; \\(+\$0.1349\\) per share for rate.**
**Explanation:** One percentage point is a change of \\(0.01\\), so the quoted Vega and Rho are the derivatives divided by \\(100\\): \\(\nu_c / 100 = \$0.3134\\) and \\(\rho_c / 100 = \$0.1349\\) per share.

---

#### **Question 5**
For an NVDA 230 call contract with Delta \\(\Delta_c = 0.5538\\), how many shares of NVDA are required to Delta hedge 1 short call contract (\\(n = -1\\))?
- **A)** Sell \\(55.38\\) shares
- **B)** Buy \\(55.38\\) shares
- **C)** Buy \\(100.00\\) shares
- **D)** Sell \\(44.62\\) shares

**Answer:** **B) Buy \\(55.38\\) shares**
**Explanation:** A position of \\(n = -1\\) call contract has share equivalents \\(100 \cdot n \cdot \Delta_c = -55.38\text{ shares}\\), so a Delta hedge requires holding \\(-100 \cdot n \cdot \Delta_c = +55.38\text{ shares}\\).

---

#### **Question 6**
Consider the short NVDA call with strike \\(K = \$235.00\\), premium \\(\mathcal{P}_c = \$9.88\\), time to expiration \\(T = 0.1178\text{ years}\\), and risk-free rate \\(g_y = 0.0413\text{ (4.13\%)}\\). What is the breakeven share price \\(S^\ddagger\\) at expiration?
- **A)** \\(\$244.88\text{ USD/share}\\)
- **B)** \\(\$244.93\text{ USD/share}\\)
- **C)** \\(\$235.00\text{ USD/share}\\)
- **D)** \\(\$245.35\text{ USD/share}\\)

**Answer:** **B) \\(\$244.93\text{ USD/share}\\)**
**Explanation:** The breakeven price is \\(S^\ddagger = K + e^{g_y T} \cdot \mathcal{P}_c = 235.00 + e^{0.0413 \times 0.1178} \cdot 9.88 = 235.00 + 1.00488 \cdot 9.88 = \$244.93\text{ USD/share}\\).

---

#### **Question 7**
How do the Probability of Exercise (POE) and Probability of Profit (POP) differ for a long call contract at expiration?
- **A)** POE is the probability that \\(S_T > K + 0.01\\), while POP is the probability that \\(S_T > S^\ddagger\\), where \\(S^\ddagger\\) is the breakeven price; either can be computed under our belief \\(\mathbb{P}\\) or under \\(\mathbb{Q}\\).
- **B)** POE is always calculated under our belief \\(\mathbb{P}\\), while POP is always calculated under the risk-neutral probabilities \\(\mathbb{Q}\\).
- **C)** POE evaluates \\(\mathbb{P}(S_T > S^\ddagger)\\), while POP evaluates \\(\mathbb{P}(S_T > K + 0.01)\\) under our belief \\(\mathbb{P}\\).
- **D)** POE and POP are identical thresholds under the risk-neutral probabilities \\(\mathbb{Q}\\).

**Answer:** **A) POE is the probability that \\(S_T > K + 0.01\\), while POP is the probability that \\(S_T > S^\ddagger\\), where \\(S^\ddagger\\) is the breakeven price; either can be computed under our belief \\(\mathbb{P}\\) or under \\(\mathbb{Q}\\).**
**Explanation:** POE checks whether the option finishes in the money above strike \\(K + 0.01\\), whereas POP checks whether expiration price \\(S_T\\) exceeds the higher breakeven price \\(S^\ddagger\\) under the chosen probabilities (\\(\mathbb{P}\\) or \\(\mathbb{Q}\\)).

---

#### **Question 8**
For the NVDA 235 call, quoted Delta is \\(0.4833\\), whereas the POE under the risk-neutral probabilities \\(\mathbb{Q}\\) is \\(0.4295\\). For a call on a share with no dividends, why is Delta close to, but slightly larger than, the POE under the risk-neutral probabilities \\(\mathbb{Q}\\)?
- **A)** Delta is evaluated under our belief \\(\mathbb{P}\\), which increases its value relative to \\(\mathbb{Q}\\).
- **B)** On a binomial tree, Delta uses up-probability \\(q^* = q \cdot u \cdot e^{-g_y \Delta t}\\), which is strictly greater than the risk-neutral up-probability \\(q\\) under \\(\mathbb{Q}\\) because \\(u > e^{g_y \Delta t}\\).
- **C)** Delta includes the expected profit above breakeven price \\(S^\ddagger\\) under \\(\mathbb{Q}\\).
- **D)** Quoted Delta subtracts extrinsic value from POE under \\(\mathbb{Q}\\).

**Answer:** **B) On a binomial tree, Delta uses up-probability \\(q^* = q \cdot u \cdot e^{-g_y \Delta t}\\), which is strictly greater than the risk-neutral up-probability \\(q\\) under \\(\mathbb{Q}\\) because \\(u > e^{g_y \Delta t}\\).**
**Explanation:** Differentiating the tree premium yields an up-probability \\(q^* > q\\), which places greater weight on in-the-money terminal nodes and makes Delta sit slightly above POE under the risk-neutral probabilities \\(\mathbb{Q}\\).

---

#### **Question 9**
For the NVDA 235 call, the POE under our belief \\(\mathbb{P}\\) (forecast drift \\(\hat{\mu} = 0.5788\\)) is \\(0.6185\\), whereas Delta under the risk-neutral probabilities \\(\mathbb{Q}\\) is \\(0.4833\\). Why is Delta under the risk-neutral probabilities \\(\mathbb{Q}\\) not our forecast of exercise probability under our belief \\(\mathbb{P}\\)?
- **A)** Delta under the risk-neutral probabilities \\(\mathbb{Q}\\) relies on the risk-free rate \\(g_y\\), whereas our forecast POE under our belief \\(\mathbb{P}\\) depends on our real-world drift estimate \\(\hat{\mu}\\), which can sit well above or below \\(g_y\\).
- **B)** Delta under the risk-neutral probabilities \\(\mathbb{Q}\\) measures profit above breakeven \\(S^\ddagger\\) rather than exercise at strike \\(K\\).
- **C)** Our belief \\(\mathbb{P}\\) assumes zero volatility, forcing POE under \\(\mathbb{P}\\) to equal 1.0.
- **D)** Delta under \\(\mathbb{Q}\\) applies only to European options, while POE under \\(\mathbb{P}\\) applies to American options.

**Answer:** **A) Delta under the risk-neutral probabilities \\(\mathbb{Q}\\) relies on the risk-free rate \\(g_y\\), whereas our forecast POE under our belief \\(\mathbb{P}\\) depends on our real-world drift estimate \\(\hat{\mu}\\), which can sit well above or below \\(g_y\\).**
**Explanation:** Quoted Delta tracks market pricing under the risk-neutral probabilities \\(\mathbb{Q}\\) with drift \\(g_y = 4.13\%\\), while real-world exercise forecast POE under our belief \\(\mathbb{P}\\) uses projected drift \\(\hat{\mu} = 57.88\%\\), so the two probabilities are conceptually distinct.

---

#### **Question 10**
For a seller of the NVDA 235 call contract (\\(S^\ddagger = \$244.93\\)), the seller's POP is \\(0.6976\\) under the risk-neutral probabilities \\(\mathbb{Q}\\) and \\(0.5034\\) under our belief \\(\mathbb{P}\\). Why is the seller's POP lower under our belief \\(\mathbb{P}\\) than under the risk-neutral probabilities \\(\mathbb{Q}\\)?
- **A)** Our belief \\(\mathbb{P}\\) uses a higher drift \\(\hat{\mu} = 0.5788\\) than risk-free rate \\(g_y = 0.0413\\) under \\(\mathbb{Q}\\), shifting the distribution of \\(S_T\\) upward and increasing the chance that \\(S_T > S^\ddagger\\).
- **B)** Seller profit requires \\(S_T > S^\ddagger\\), which becomes less likely under our belief \\(\mathbb{P}\\).
- **C)** The risk-neutral probabilities \\(\mathbb{Q}\\) assume dividend payments that lower the share price at expiration.
- **D)** The seller's POP under \\(\mathbb{Q}\\) includes intrinsic value, whereas under \\(\mathbb{P}\\) it does not.

**Answer:** **A) Our belief \\(\mathbb{P}\\) uses a higher drift \\(\hat{\mu} = 0.5788\\) than risk-free rate \\(g_y = 0.0413\\) under \\(\mathbb{Q}\\), shifting the distribution of \\(S_T\\) upward and increasing the chance that \\(S_T > S^\ddagger\\).**
**Explanation:** The seller profits when \\(S_T \le S^\ddagger\\); because real-world drift under our belief \\(\mathbb{P}\\) is higher than risk-free rate \\(g_y\\) under the risk-neutral probabilities \\(\mathbb{Q}\\), \\(S_T\\) is more likely to exceed \\(S^\ddagger\\), reducing the seller's POP under \\(\mathbb{P}\\).

---

### **Options Flashcards (15 Flashcards)**

**Q: What two components form an American option's premium, and how is extrinsic value defined?**  
**A:** Premium equals intrinsic value plus extrinsic (time) value; extrinsic value is calculated as \\(\text{Option Premium} - \text{Intrinsic Value}\\).

**Q: For an NVDA call with stock price \\(S_0 = \$230.57\\), strike \\(K = \$230.00\\), and premium \\(\mathcal{P}_c = \$12.15\\), what are the intrinsic and extrinsic values?**  
**A:** Intrinsic value is \\(\max(0, 230.57 - 230.00) = \$0.57\text{ USD/share}\\), and extrinsic value is \\(12.15 - 0.57 = \$11.58\text{ USD/share}\\).

**Q: Why is early exercise never optimal for an American call option on a non-dividend-paying stock?**  
**A:** Exercising early forfeits positive extrinsic value, requires paying the strike price early (losing interest), and eliminates downside protection.

**Q: When is early exercise economically rational for American options?**  
**A:** Early exercise makes sense for a deep in-the-money put to collect strike cash and earn interest, or for a call the trading day before an ex-dividend date if the dividend exceeds remaining extrinsic value.

**Q: What does Delta (\\(\Delta\\)) measure for an option contract?**  
**A:** Delta measures the sensitivity of the option premium to a \\(+\$1.00\text{ USD/share}\\) change in the underlying stock price.

**Q: How do you convert the per-year derivative \\(\Theta_{\star}\\) into the quoted 1-day Theta per share?**  
**A:** Divide \\(\Theta_{\star}\\) by \\(365\\) (e.g., for the NVDA 230 call, \\(-51.56 / 365 = -\$0.1413\text{ USD/share/day}\\)).

**Q: How do you convert the derivatives \\(\nu_{\star}\\) and \\(\rho_{\star}\\) into the quoted Vega and Rho, the price changes for a 1-percentage-point move in volatility or interest rates?**  
**A:** Divide \\(\nu_{\star}\\) by \\(100\\) for a one-point rise in volatility, and divide \\(\rho_{\star}\\) by \\(100\\) for a one-point rise in the risk-free rate.

**Q: What do Gamma (\\(\Gamma\\)) and Vega (\\(\nu\\)) measure?**  
**A:** Gamma measures the change in Delta per \\(+\$1.00\text{ USD/share}\\) move in stock price (curvature), while quoted Vega measures the premium change for a one-point rise in volatility (for example, 35% to 36%), which is \\(\nu_{\star}/100\\).

**Q: How is the breakeven share price \\(S^\ddagger\\) defined for a call option at expiration?**  
**A:** \\(S^\ddagger = K + \mathcal{D}_{T,0}(g_y) \cdot \mathcal{P}_c = K + e^{g_y T} \cdot \mathcal{P}_c\\), which adds the future value of the premium to the strike price.

**Q: What is the breakeven price \\(S^\ddagger\\) for the NVDA 235 call (\\(K = \$235.00\\), \\(\mathcal{P}_c = \$9.88\\), \\(g_y = 4.13\%\\), \\(T = 0.1178\text{ years}\\))?**  
**A:** \\(S^\ddagger = 235.00 + e^{0.0413 \times 0.1178} \times 9.88 = 235.00 + 1.00488 \times 9.88 = \$244.93\text{ USD/share}\\).

**Q: How is the Probability of Exercise (POE) defined for a call option under the risk-neutral probabilities \\(\mathbb{Q}\\) versus our belief \\(\mathbb{P}\\)?**  
**A:** Under the risk-neutral probabilities \\(\mathbb{Q}\\), \\(\text{POE} = \mathbb{Q}(S_T > K + 0.01)\\); under our belief \\(\mathbb{P}\\), \\(\text{POE} = \mathbb{P}(S_T > K + 0.01)\\).

**Q: How is the Probability of Profit (POP) defined for a long call option under the risk-neutral probabilities \\(\mathbb{Q}\\) versus our belief \\(\mathbb{P}\\)?**  
**A:** For a long call, \\(\text{POP} = \mathbb{Q}(S_T > S^\ddagger)\\) under the risk-neutral probabilities \\(\mathbb{Q}\\) and \\(\text{POP} = \mathbb{P}(S_T > S^\ddagger)\\) under our belief \\(\mathbb{P}\\), evaluating simulated prices against breakeven price \\(S^\ddagger\\).

**Q: Why is quoted Delta close to, but slightly larger than, the POE under the risk-neutral probabilities \\(\mathbb{Q}\\) for a call on a share with no dividends?**  
**A:** On a binomial tree, Delta uses up-probability \\(q^* = q \cdot u \cdot e^{-g_y \Delta t} > q\\), placing slightly more weight on the in-the-money terminal nodes than the risk-neutral up probability \\(q\\) does.

**Q: Why is Delta under the risk-neutral probabilities \\(\mathbb{Q}\\) not our forecast of exercise probability under our belief \\(\mathbb{P}\\)?**  
**A:** Delta follows market pricing under the risk-neutral probabilities \\(\mathbb{Q}\\) with drift \\(g_y\\), whereas our forecast POE under our belief \\(\mathbb{P}\\) depends on our real-world expected drift \\(\hat{\mu}\\).

**Q: For the NVDA 235 call, why does POE increase from \\(0.4295\\) under the risk-neutral probabilities \\(\mathbb{Q}\\) to \\(0.6185\\) under our belief \\(\mathbb{P}\\)?**  
**A:** Real-world forecast drift \\(\hat{\mu} = 0.5788\\) under our belief \\(\mathbb{P}\\) is much higher than risk-free rate \\(g_y = 0.0413\\) under the risk-neutral probabilities \\(\mathbb{Q}\\), shifting expected terminal prices higher.
