### **Options Quiz (10 Questions)**

#### **Question 1**
How is the profit at expiration \\(\hat{P}_{\mathcal{C}}(S(T))\\) of a composite contract calculated, and how is its probability of profit (POP) defined under our belief \\(\mathbb{P}\\) and under the risk-neutral probabilities \\(\mathbb{Q}\\)?
- **A)** The unweighted sum of the leg premiums minus the leg payoffs, with the POP under our belief \\(\mathbb{P}\\) equal to \\(\mathbb{P}(\hat{P}_{\mathcal{C}}(S(T)) < 0)\\).
- **B)** The orientation- and copy-weighted sum of the leg payoffs minus the composite premium grown to expiration, with the POP equal to \\(\mathbb{P}(\hat{P}_{\mathcal{C}}(S(T)) > 0)\\) under our belief \\(\mathbb{P}\\) and \\(\mathbb{Q}(\hat{P}_{\mathcal{C}}(S(T)) > 0)\\) under the risk-neutral probabilities \\(\mathbb{Q}\\).
- **C)** The sum of the leg strike prices minus the share price, with the POP under the risk-neutral probabilities \\(\mathbb{Q}\\) equal to \\(\mathbb{Q}(\hat{P}_{\mathcal{C}}(S(T)) = 0)\\).
- **D)** The composite premium minus the leg payoffs, with the POP under our belief \\(\mathbb{P}\\) equal to \\(\mathbb{P}(S(T) > K_2)\\).

**Answer:** **B) The orientation- and copy-weighted sum of the leg payoffs minus the composite premium grown to expiration, with the POP equal to \\(\mathbb{P}(\hat{P}_{\mathcal{C}}(S(T)) > 0)\\) under our belief \\(\mathbb{P}\\) and \\(\mathbb{Q}(\hat{P}_{\mathcal{C}}(S(T)) > 0)\\) under the risk-neutral probabilities \\(\mathbb{Q}\\).**
**Explanation:** The profit at expiration is the sum of the leg payoffs weighted by orientation \\(\theta_i\\) (+1 long, -1 short) and copy number \\(n_i\\), minus the composite premium grown to expiration, and the POP is the probability that this profit is positive, under our belief \\(\mathbb{P}\\) or under the risk-neutral probabilities \\(\mathbb{Q}\\).

---

#### **Question 2**
For the AMD put credit spread, we sell the 520 put (\\(K_2\\)) and buy the 500 put (\\(K_1\\)). If the maximum profit (the credit grown to expiration) is 8.80 USD/share, what is the maximum loss per share?
- **A)** 11.20 USD/share, for \\(S(T) \le 500\\) USD/share.
- **B)** 20.00 USD/share, for \\(S(T) \ge 520\\) USD/share.
- **C)** 8.80 USD/share, at \\(S(T) = 511.20\\) USD/share.
- **D)** Unlimited, because the short put has no protection.

**Answer:** **A) 11.20 USD/share, for \\(S(T) \le 500\\) USD/share.**
**Explanation:** The maximum loss of a put credit spread is the strike width \\(K_2 - K_1 = 520 - 500 = 20.00\\) USD/share minus the credit grown to expiration, 8.80 USD/share, which gives 11.20 USD/share for \\(S(T) \le K_1 = 500\\) USD/share.

---

#### **Question 3**
The AMD put credit spread (\\(K_1 = 500\\), \\(K_2 = 520\\)) has a breakeven \\(S^\ddagger = 511.20\\) USD/share. How does its probability of profit (POP) under our belief \\(\mathbb{P}\\) compare with its POP under the risk-neutral probabilities \\(\mathbb{Q}\\)?
- **A)** The POP is 0.5402 under our belief \\(\mathbb{P}\\) and 0.7144 under the risk-neutral probabilities \\(\mathbb{Q}\\).
- **B)** The POP is 1.0000 under our belief \\(\mathbb{P}\\) and 0.0000 under the risk-neutral probabilities \\(\mathbb{Q}\\).
- **C)** The POP is 0.4916 under our belief \\(\mathbb{P}\\) and 0.4190 under the risk-neutral probabilities \\(\mathbb{Q}\\).
- **D)** The POP is 0.7144 under our belief \\(\mathbb{P}\\) and 0.5402 under the risk-neutral probabilities \\(\mathbb{Q}\\).

**Answer:** **D) The POP is 0.7144 under our belief \\(\mathbb{P}\\) and 0.5402 under the risk-neutral probabilities \\(\mathbb{Q}\\).**
**Explanation:** The probability that the share price finishes above the 511.20 USD/share breakeven is 0.7144 under our belief \\(\mathbb{P}\\), whose drift is much higher and whose volatility is lower, compared with 0.5402 under the risk-neutral probabilities \\(\mathbb{Q}\\).

---

#### **Question 4**
What is the outlook of a put credit spread, and on which side can it lose money?
- **A)** Neutral to bearish, with the risk of loss on the call side.
- **B)** Neutral, with an unlimited risk of loss on both sides.
- **C)** Neutral to bullish, with the risk of loss on the put side if the share price falls.
- **D)** Bullish, with the risk of loss on the call side.

**Answer:** **C) Neutral to bullish, with the risk of loss on the put side if the share price falls.**
**Explanation:** A put credit spread has a short put at \\(K_2\\) and a long put at \\(K_1 < K_2\\) on its put side and nothing on its call side, so only the put side can lose, which gives it a neutral to bullish outlook.

---

#### **Question 5**
Compare a short straddle at strike \\(K\\) with a short strangle at strikes \\(K_1 < K_2\\). Which statement correctly describes their breakevens and their maximum losses on the call side?
- **A)** Both have two breakevens and an unlimited maximum loss on the call side.
- **B)** Both have a capped maximum loss on the call side.
- **C)** A short straddle has an unlimited loss on the put side, whereas a short strangle has a capped loss at \\(S(T) = 0\\).
- **D)** A short strangle has only one breakeven.

**Answer:** **A) Both have two breakevens and an unlimited maximum loss on the call side.**
**Explanation:** Short straddles and short strangles both have a short call with no long call to cap its loss, so each has two breakevens and an unlimited maximum loss on the call side.

---

#### **Question 6**
A protected strangle has a short put at \\(K_1\\), a short call at \\(K_2\\), and a long call at \\(K_3\\). Under what condition can its call side not lose money at any share price at expiration?
- **A)** When the credit grown to expiration is less than the strike width \\(K_3 - K_2\\).
- **B)** When the long call is certain to be exercised.
- **C)** When \\(S(T) < K_1\\).
- **D)** When the credit grown to expiration is at least the call strike width \\(K_3 - K_2\\).

**Answer:** **D) When the credit grown to expiration is at least the call strike width \\(K_3 - K_2\\).**
**Explanation:** If the credit grown to expiration is at least \\(K_3 - K_2\\), it covers the largest possible loss of the call credit spread, so the call side cannot lose.

---

#### **Question 7**
An iron condor combines a put credit spread and a call credit spread, with strikes \\(K_1 < K_2 < K_3 < K_4\\). What are its outlook and its maximum loss per share?
- **A)** Bullish, with a maximum loss equal to the sum of all strike prices.
- **B)** Bearish, with an unlimited maximum loss on both sides.
- **C)** Neutral, with a maximum loss equal to the wider strike width minus the credit grown to expiration.
- **D)** Neutral to bullish, with a maximum loss equal to the credit received.

**Answer:** **C) Neutral, with a maximum loss equal to the wider strike width minus the credit grown to expiration.**
**Explanation:** Both sides of an iron condor are credit spreads, so its outlook is neutral, and at most one side can lose at expiration, so its maximum loss is the wider strike width minus the credit grown to expiration.

---

#### **Question 8**
Why does closing a short strangle before expiration, at share price \\(S(t)\\), earn less than the profit at expiration at the same share price?
- **A)** Because buying the two legs back early costs their intrinsic value plus the extrinsic value still left in them.
- **B)** Because closing early incurs transaction taxes that reduce the profit.
- **C)** Because the intrinsic value of each leg always increases before expiration.
- **D)** Because long legs lose all of their intrinsic value when sold early.

**Answer:** **A) Because buying the two legs back early costs their intrinsic value plus the extrinsic value still left in them.**
**Explanation:** Closing early means buying both legs back at their current premiums, which include the remaining extrinsic value \\(E_V(t)\\), while at expiration the extrinsic value is zero.

---

#### **Question 9**
A trader opens a short strangle at share price \\(S(0)\\), with both legs out of the money, and buys both legs back right away at \\(S(0)\\). What is the profit?
- **A)** 50% of the maximum profit.
- **B)** The maximum profit minus the risk-free rate.
- **C)** The credit multiplied by the POP.
- **D)** 0.00 USD/share, because the cost to buy both legs back equals the credit collected, all of it extrinsic value.

**Answer:** **D) 0.00 USD/share, because the cost to buy both legs back equals the credit collected, all of it extrinsic value.**
**Explanation:** At the entry share price \\(S(0)\\), both out-of-the-money legs are worth only their extrinsic value, which equals the credit collected, so closing at once earns nothing.

---

#### **Question 10**
Time passes toward expiration while the share price stays at \\(S(0)\\). How does time decay change the profit from closing early?
- **A)** The cost to close increases, which reduces the profit.
- **B)** The cost to close stays constant.
- **C)** The cost to close decreases as the extrinsic value decays, so the profit from closing early rises toward the maximum profit, the credit grown to expiration.
- **D)** The cost to close drops to zero after one day.

**Answer:** **C) The cost to close decreases as the extrinsic value decays, so the profit from closing early rises toward the maximum profit.**
**Explanation:** Time decay lowers the extrinsic value toward zero, which lowers the cost to buy the legs back and raises the profit from closing early toward the credit grown to expiration.

---

### **Options Flashcards (15 Flashcards)**

**Q:** What is the profit at expiration \\(\hat{P}_{\mathcal{C}}(S(T))\\) of a composite contract, and how is its probability of profit (POP) defined under our belief \\(\mathbb{P}\\) and under the risk-neutral probabilities \\(\mathbb{Q}\\)?  
**A:** The profit at expiration is the sum of the leg payoffs weighted by orientation \\(\theta_i\\) (+1 long, -1 short) and copy number \\(n_i\\), minus the composite premium grown to expiration. The POP is \\(\mathbb{P}(\hat{P}_{\mathcal{C}}(S(T)) > 0)\\) under our belief \\(\mathbb{P}\\), or \\(\mathbb{Q}(\hat{P}_{\mathcal{C}}(S(T)) > 0)\\) under the risk-neutral probabilities \\(\mathbb{Q}\\).

**Q:** For the AMD put credit spread (\\(K_1 = 500\\), \\(K_2 = 520\\)), what is the maximum profit per share, and what is the POP under our belief \\(\mathbb{P}\\) and under the risk-neutral probabilities \\(\mathbb{Q}\\)?  
**A:** The maximum profit is the credit grown to expiration, 8.80 USD/share, for \\(S(T) \ge 520\\). The POP is 0.7144 under our belief \\(\mathbb{P}\\) and 0.5402 under the risk-neutral probabilities \\(\mathbb{Q}\\).

**Q:** What is the breakeven share price \\(S^\ddagger\\) of the AMD put credit spread (\\(K_1 = 500\\), \\(K_2 = 520\\), credit grown to expiration 8.80 USD/share)?  
**A:** \\(S^\ddagger = K_2 - \text{credit} = 520 - 8.80 = 511.20\\) USD/share. The profit at expiration is positive above this share price.

**Q:** What is the maximum loss per share of the AMD put credit spread (\\(K_1 = 500\\), \\(K_2 = 520\\), credit grown to expiration 8.80 USD/share), and at what share prices does it occur?  
**A:** The maximum loss is \\((K_2 - K_1) - \text{credit} = (520 - 500) - 8.80 = 11.20\\) USD/share, for \\(S(T) \le K_1 = 500\\) USD/share.

**Q:** Why does our belief \\(\mathbb{P}\\) give the AMD put credit spread a higher POP (0.7144) than the risk-neutral probabilities \\(\mathbb{Q}\\) (0.5402)?  
**A:** Our belief \\(\mathbb{P}\\) uses a much higher estimated drift \\(\hat{\mu}\\) and a lower volatility \\(\hat{\sigma}\\) than the risk-neutral probabilities \\(\mathbb{Q}\\), which use the risk-free rate \\(g_y\\) and the implied volatility, so \\(\mathbb{P}\\) puts less probability below the breakeven.

**Q:** What are the outlook and the sides that can lose for a short put?  
**A:** A short put is neutral to bullish. Only its put side can lose, with a maximum loss of \\(K\\) minus the credit grown to expiration at \\(S(T) = 0\\), and its call side is empty.

**Q:** What are the outlook and the sides that can lose for a short call?  
**A:** A short call is neutral to bearish. Only its call side can lose, and the loss is unlimited as \\(S(T) \to \infty\\); its put side is empty.

**Q:** What are the breakevens, the call-side maximum loss, and the POP of a short straddle at strike \\(K\\)?  
**A:** A short straddle has two breakevens, \\(S^\ddagger_\pm = K \pm\\) the credit grown to expiration, and an unlimited maximum loss on the call side. Its POP is \\(\mathbb{P}(S^\ddagger_- < S(T) < S^\ddagger_+)\\) under our belief \\(\mathbb{P}\\), or \\(\mathbb{Q}(S^\ddagger_- < S(T) < S^\ddagger_+)\\) under the risk-neutral probabilities \\(\mathbb{Q}\\).

**Q:** How does a short strangle differ from a short straddle in its strikes and in the range of share prices where it keeps its credit?  
**A:** A short strangle sells a put at \\(K_1\\) and a call at \\(K_2 > K_1\\). It collects less credit than a straddle, but it keeps the maximum profit over a wider range of share prices, \\(K_1 \le S(T) \le K_2\\).

**Q:** How does a protected strangle (jade lizard) change a short strangle, and what is its outlook?  
**A:** A protected strangle adds a long call at \\(K_3 > K_2\\), so its call side becomes a call credit spread while its put side has no long put to cap its loss. Its outlook is neutral, leaning bullish.

**Q:** Under what condition can the call side of a protected strangle not lose money at any share price at expiration?  
**A:** When the credit grown to expiration is at least the call strike width \\(K_3 - K_2\\); then the call side cannot lose at any share price at expiration.

**Q:** What are the structure, the outlook, and the maximum loss of an iron condor?  
**A:** An iron condor combines a put credit spread (long put at \\(K_1\\), short put at \\(K_2\\)) and a call credit spread (short call at \\(K_3\\), long call at \\(K_4\\)), with \\(K_1 < K_2 < K_3 < K_4\\). Its outlook is neutral, and its maximum loss is the wider strike width minus the credit grown to expiration.

**Q:** Why does closing a short strangle early, at share price \\(S(t)\\), earn less than the profit at expiration at the same share price?  
**A:** Buying both legs back before expiration costs their current premiums, which include the remaining extrinsic value \\(E_V(t)\\) as well as the intrinsic value.

**Q:** What is the profit from closing a short strangle right after opening it, at the entry share price \\(S(0)\\)?  
**A:** 0.00 USD/share. Both out-of-the-money legs are worth only their extrinsic value, which equals the credit collected, so buying them back costs the whole credit.

**Q:** If the share price stays at the entry price \\(S(0)\\), between the strikes of a short strangle, how does time decay change the profit from closing early as expiration approaches?  
**A:** As the time to expiration falls, the extrinsic value decays toward zero, which lowers the cost to buy the legs back, so the profit from closing early rises toward the maximum profit, the credit grown to expiration.
