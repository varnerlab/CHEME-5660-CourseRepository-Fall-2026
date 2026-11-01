### **L11a Self-Check (10 Questions)**

#### **Question 1**
In the AMD put credit spread, we buy the 500 put for 29.35 USD/share and sell the 520 put for 38.10 USD/share. What is the composite premium \\(\mathcal{P}_{\mathcal{C}}\\)?
- **A)** \\(+8.75\\) USD/share, a debit of 8.75 USD/share
- **B)** \\(-8.75\\) USD/share, a credit of 8.75 USD/share
- **C)** \\(+67.45\\) USD/share, a debit of 67.45 USD/share
- **D)** \\(-67.45\\) USD/share, a credit of 67.45 USD/share

**Answer:** **B) \\(-8.75\\) USD/share, a credit of 8.75 USD/share**
**Explanation:** The composite premium is the premium we pay minus the premium we collect, \\(29.35 - 38.10 = -8.75\\) USD/share, and a negative composite premium means the spread opens for a credit of 8.75 USD/share.

---

#### **Question 2**
Why is the probability of profit of a composite contract, \\(\mathbb{P}(\operatorname{NPV}_{0}(\mathcal{C}) > 0)\\) under our belief \\(\mathbb{P}\\), the same as the probability that its profit at expiration is positive?
- **A)** Because the composite premium is always negative.
- **B)** Because each leg's payoff is never negative.
- **C)** Because the risk-free rate is close to zero.
- **D)** Because the NPV is the profit at expiration multiplied by the positive discount factor \\(\mathcal{D}^{-1}_{T,0}(g_{y})\\), so the two always have the same sign.

**Answer:** **D) Because the NPV is the profit at expiration multiplied by the positive discount factor \\(\mathcal{D}^{-1}_{T,0}(g_{y})\\), so the two always have the same sign.**
**Explanation:** Multiplying by a positive number does not change the sign, so the NPV is positive exactly when the profit at expiration is positive, under \\(\mathbb{P}\\) or under \\(\mathbb{Q}\\).

---

#### **Question 3**
The AMD put credit spread has strikes \\(K_{1} = 500\\) and \\(K_{2} = 520\\) USD/share, and its credit grown to expiration is 8.80 USD/share. What is its maximum loss?
- **A)** 11.20 USD/share, for \\(S(T) \leq 500\\) USD/share
- **B)** 20.00 USD/share, for \\(S(T) \leq 500\\) USD/share
- **C)** 8.80 USD/share, for \\(S(T) \geq 520\\) USD/share
- **D)** Unlimited, as the share price falls

**Answer:** **A) 11.20 USD/share, for \\(S(T) \leq 500\\) USD/share**
**Explanation:** Below the long strike, the long put gains every dollar the short put loses, so the loss stops at the strike width minus the credit grown to expiration, \\(20.00 - 8.80 = 11.20\\) USD/share.

---

#### **Question 4**
The AMD put credit spread has a POP of 0.7144 under our belief \\(\mathbb{P}\\) and 0.5402 under the risk-neutral probabilities \\(\mathbb{Q}\\). Why is the POP higher under \\(\mathbb{P}\\)?
- **A)** Our belief \\(\mathbb{P}\\) uses a higher volatility than \\(\mathbb{Q}\\).
- **B)** Our belief \\(\mathbb{P}\\) uses a lower breakeven than \\(\mathbb{Q}\\).
- **C)** Our drift estimate \\(\hat{\mu} = 0.5521\\) (1/yr) is far above the risk-free rate \\(g_{y} = 0.0413\\) (1/yr), and our volatility \\(\hat{\sigma} = 0.4743\\) is below the implied volatility 0.5617.
- **D)** The risk-neutral probabilities \\(\mathbb{Q}\\) ignore the credit we collect.

**Answer:** **C) Our drift estimate \\(\hat{\mu} = 0.5521\\) (1/yr) is far above the risk-free rate \\(g_{y} = 0.0413\\) (1/yr), and our volatility \\(\hat{\sigma} = 0.4743\\) is below the implied volatility 0.5617.**
**Explanation:** The breakeven is 511.20 USD/share under both, and the larger drift and lower volatility of \\(\mathbb{P}\\) put less probability below it than \\(\mathbb{Q}\\) does.

---

#### **Question 5**
In the AMD short strangle, we sell the 470 put and the 630 call, and the credit grown to expiration is 34.41 USD/share. What are the two breakevens?
- **A)** 470.00 and 630.00 USD/share
- **B)** 435.59 and 664.41 USD/share
- **C)** 504.41 and 595.59 USD/share
- **D)** 452.80 and 647.20 USD/share

**Answer:** **B) 435.59 and 664.41 USD/share**
**Explanation:** The lower breakeven is the put strike minus the credit grown to expiration, \\(470 - 34.41 = 435.59\\) USD/share, and the upper breakeven is the call strike plus it, \\(630 + 34.41 = 664.41\\) USD/share.

---

#### **Question 6**
The AMD short strangle has a POP of 0.7384 under our belief \\(\mathbb{P}\\) and 0.6714 under the risk-neutral probabilities \\(\mathbb{Q}\\). Keeping the risk-free drift of \\(\mathbb{Q}\\) but using our historical volatility gives 0.7534, and keeping the implied volatility but using our historical drift gives 0.6655. What raises the POP under \\(\mathbb{P}\\)?
- **A)** The lower historical volatility, which keeps more share prices between the breakevens.
- **B)** The larger historical drift, which moves share prices toward the call strike.
- **C)** The larger credit under \\(\mathbb{P}\\).
- **D)** The narrower breakevens under \\(\mathbb{P}\\).

**Answer:** **A) The lower historical volatility, which keeps more share prices between the breakevens.**
**Explanation:** Changing only the volatility raises the POP from 0.6714 to 0.7534, while changing only the drift lowers it to 0.6655, so under \\(\mathbb{P}\\) the lower volatility wins.

---

#### **Question 7**
Which of these credit contracts buys a long leg to cap the loss on both its put side and its call side?
- **A)** Short straddle
- **B)** Short strangle
- **C)** Protected strangle
- **D)** Iron condor

**Answer:** **D) Iron condor**
**Explanation:** An iron condor is a put credit spread plus a call credit spread, so a long put caps the loss on the put side and a long call caps it on the call side; the short straddle and short strangle have no long legs, and the protected strangle has only a long call.

---

#### **Question 8**
A protected strangle sells a put at \\(K_{1}\\) and a call at \\(K_{2}\\), and buys a call at \\(K_{3} > K_{2}\\). Why is its outlook neutral, leaning bullish?
- **A)** Its put side is a credit spread, and its call side is uncapped.
- **B)** It opens for a debit.
- **C)** Its call side is capped by the long call, but its put side is not.
- **D)** It has no breakevens.

**Answer:** **C) Its call side is capped by the long call, but its put side is not.**
**Explanation:** The long call at \\(K_{3}\\) caps the loss as the share price rises, but there is no long put below \\(K_{1}\\), so the loss keeps growing as the share price falls toward zero; the trade is exposed mainly to a falling share price.

---

#### **Question 9**
We open a short strangle with both legs out of the money and buy both legs back right away, at the same share price \\(S(0)\\). What is the profit?
- **A)** The whole credit, because both legs are out of the money.
- **B)** Zero, because buying the legs back costs the credit, all of it extrinsic value.
- **C)** Half the credit.
- **D)** The credit times the POP under our belief \\(\mathbb{P}\\).

**Answer:** **B) Zero, because buying the legs back costs the credit, all of it extrinsic value.**
**Explanation:** Out-of-the-money legs have no intrinsic value, so their premiums are all extrinsic value, and buying them back at once costs exactly what we collected.

---

#### **Question 10**
If the share price stays at \\(S(0)\\), the profit if we close a short strangle rises toward the whole credit as expiration nears. Why do many premium sellers still close early instead of waiting?
- **A)** Closing early always earns more than the profit at expiration.
- **B)** The extrinsic value grows as expiration nears.
- **C)** The POP under the risk-neutral probabilities \\(\mathbb{Q}\\) falls to zero at expiration.
- **D)** Near expiration, a small move in the share price near a strike changes the profit by more.

**Answer:** **D) Near expiration, a small move in the share price near a strike changes the profit by more.**
**Explanation:** As expiration nears, the profit curves bend toward the kinks at the strikes, so closing early gives up part of the credit to avoid the larger swings near a strike.
