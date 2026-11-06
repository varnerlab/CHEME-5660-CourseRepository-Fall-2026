### **L11b Self-Check (11 Questions)**

#### **Question 1**
In the AMD covered call, we buy shares at \\(S(0) = 531.26\\) USD/share and sell the 570 call for \\(\mathcal{P}_{c} = 31.25\\) USD/share. Today's cost grown to expiration, \\(\mathcal{D}_{T,0}(g_{y})\cdot(S(0) - \mathcal{P}_{c})\\), is 503.02 USD/share. What is the maximum profit?
- **A)** 66.98 USD/share, for \\(S(T) \geq 570\\) USD/share
- **B)** 38.74 USD/share, for \\(S(T) \geq 570\\) USD/share
- **C)** 31.25 USD/share, for \\(S(T) \leq 570\\) USD/share
- **D)** Unlimited, as the share price rises

**Answer:** **A) 66.98 USD/share, for \\(S(T) \geq 570\\) USD/share**
**Explanation:** Above the strike, the call is exercised and we sell the shares at \\(K\\), so the profit is \\(K - \mathcal{D}_{T,0}(g_{y})\cdot(S(0) - \mathcal{P}_{c}) = 570 - 503.02 = 66.98\\) USD/share.

---

#### **Question 2**
The AMD covered call has a breakeven of 503.02 USD/share and a maximum loss of 503.02 USD/share. Why are the two equal?
- **A)** Because the call premium covers the whole loss.
- **B)** Both equal today's cost grown to expiration, \\(\mathcal{D}_{T,0}(g_{y})\cdot(S(0) - \mathcal{P}_{c})\\): the profit is zero when \\(S(T)\\) equals it, and the whole amount is lost when \\(S(T) = 0\\).
- **C)** Because the short call caps the loss at the breakeven.
- **D)** Because the maximum loss is reached at the strike price.

**Answer:** **B) Both equal today's cost grown to expiration, \\(\mathcal{D}_{T,0}(g_{y})\cdot(S(0) - \mathcal{P}_{c})\\): the profit is zero when \\(S(T)\\) equals it, and the whole amount is lost when \\(S(T) = 0\\).**
**Explanation:** Below the strike, the profit is \\(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot(S(0) - \mathcal{P}_{c})\\), which is zero at the breakeven and equals minus that cost when the share price falls to zero.

---

#### **Question 3**
Compared with holding the AMD shares alone, how does selling the 570 call change the breakeven and the profit above the strike?
- **A)** It raises the breakeven and caps the profit.
- **B)** It lowers the breakeven and leaves the profit above the strike unchanged.
- **C)** It lowers the breakeven and caps the profit at the strike.
- **D)** It leaves the breakeven unchanged and caps the profit.

**Answer:** **C) It lowers the breakeven and caps the profit at the strike.**
**Explanation:** The shares alone break even at \\(\mathcal{D}_{T,0}(g_{y})\cdot S(0)\\); the premium lowers this to \\(\mathcal{D}_{T,0}(g_{y})\cdot(S(0) - \mathcal{P}_{c})\\), and above \\(K\\) the call takes the shares at the strike.

---

#### **Question 4**
In the AMD covered call, the call premium grown to expiration is \\(\mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} = 31.44\\) USD/share and the strike is \\(K = 570\\) USD/share. Above which share price at expiration would holding the shares alone have earned more?
- **A)** 538.56 USD/share
- **B)** 570.00 USD/share
- **C)** 503.02 USD/share
- **D)** 601.44 USD/share

**Answer:** **D) 601.44 USD/share**
**Explanation:** The opportunity point is \\(O^{+} = K + \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} = 570 + 31.44 = 601.44\\) USD/share, where the shares alone reach the covered call's maximum profit; it is also the breakeven of the short call alone.

---

#### **Question 5**
For the AMD covered call, the probability of a loss is 0.2561 under our belief \\(\mathbb{P}\\) and 0.4280 under the risk-neutral probabilities \\(\mathbb{Q}\\). Why is it lower under \\(\mathbb{P}\\)?
- **A)** Our drift estimate \\(\hat{\mu} = 0.5521\\) (1/yr) is far above the risk-free rate \\(g_{y} = 0.0413\\) (1/yr), and our volatility \\(\hat{\sigma} = 0.4743\\) is below the call's implied volatility 0.5626.
- **B)** The breakeven is lower under \\(\mathbb{P}\\) than under \\(\mathbb{Q}\\).
- **C)** Our belief \\(\mathbb{P}\\) uses a higher volatility than \\(\mathbb{Q}\\).
- **D)** The risk-neutral probabilities \\(\mathbb{Q}\\) ignore the call premium.

**Answer:** **A) Our drift estimate \\(\hat{\mu} = 0.5521\\) (1/yr) is far above the risk-free rate \\(g_{y} = 0.0413\\) (1/yr), and our volatility \\(\hat{\sigma} = 0.4743\\) is below the call's implied volatility 0.5626.**
**Explanation:** The breakeven is 503.02 USD/share under both, and the larger drift and lower volatility of \\(\mathbb{P}\\) put less probability below it than \\(\mathbb{Q}\\) does.

---

#### **Question 6**
For the AMD covered call under the risk-neutral probabilities \\(\mathbb{Q}\\), the probability of the maximum profit, \\(S(T) \geq K\\), is 0.3448, and the probability of an opportunity loss, \\(S(T) > O^{+}\\), is 0.2582. Why is the second probability smaller?
- **A)** Because an opportunity loss requires the call to expire worthless.
- **B)** Because \\(O^{+}\\) lies above \\(K\\), so every share price above \\(O^{+}\\) is also above \\(K\\), but not the other way around.
- **C)** Because \\(O^{+}\\) lies below \\(K\\).
- **D)** Because the opportunity point is below the breakeven.

**Answer:** **B) Because \\(O^{+}\\) lies above \\(K\\), so every share price above \\(O^{+}\\) is also above \\(K\\), but not the other way around.**
**Explanation:** \\(O^{+} = K + \mathcal{D}_{T,0}(g_{y})\cdot\mathcal{P}_{c} > K\\), so the event \\(S(T) > O^{+}\\) is part of the event \\(S(T) \geq K\\) and cannot be more likely, under \\(\mathbb{Q}\\) or under our belief \\(\mathbb{P}\\).

---

#### **Question 7**
In the SPY collar, we buy shares at \\(S(0) = 763.335\\) USD/share, buy the \\(K_{1} = 725\\) put for 8.44 USD/share, and sell the \\(K_{2} = 802\\) call for 3.95 USD/share. Today's cost grown to expiration is 773.36 USD/share. What is the profit if \\(S(T) = 700\\) USD/share?
- **A)** A loss of 73.36 USD/share
- **B)** A loss of 63.34 USD/share
- **C)** A loss of 48.36 USD/share
- **D)** A profit of 28.64 USD/share

**Answer:** **C) A loss of 48.36 USD/share**
**Explanation:** Below \\(K_{1}\\), the put is exercised and we sell the shares at 725, so the profit is \\(K_{1} - 773.36 = -48.36\\) USD/share, the collar's maximum loss, whatever the share price below the floor.

---

#### **Question 8**
The SPY collar's breakeven is 773.36 USD/share, above today's share price of 763.335 USD/share. Why?
- **A)** The breakeven is \\(S(0)\\) plus the call premium.
- **B)** The call premium raises the breakeven.
- **C)** The breakeven is always above \\(S(0)\\) for a collar.
- **D)** The breakeven is today's cost, the share price plus the net debit \\(\mathcal{P}_{1} - \mathcal{P}_{2} = 4.49\\) USD/share, grown to expiration.

**Answer:** **D) The breakeven is today's cost, the share price plus the net debit \\(\mathcal{P}_{1} - \mathcal{P}_{2} = 4.49\\) USD/share, grown to expiration.**
**Explanation:** The breakeven is \\(S^{\ddagger} = \mathcal{D}_{T,0}(g_{y})\cdot(S(0) + \mathcal{P}_{1} - \mathcal{P}_{2})\\), so both the net debit and the growth at the risk-free rate push it above \\(S(0)\\).

---

#### **Question 9**
Under the risk-neutral probabilities \\(\mathbb{Q}\\), the SPY collar, a net debit, loses money with probability 0.5504 and the shares alone with probability 0.5122. What does the put buy us in this collar?
- **A)** A lower chance of a loss.
- **B)** A limit on the size of a loss, not a lower chance of one.
- **C)** A higher maximum profit.
- **D)** A zero-cost position.

**Answer:** **B) A limit on the size of a loss, not a lower chance of one.**
**Explanation:** Here the net debit raises the collar's breakeven above that of the shares alone, so a loss is a little more likely, but below \\(K_{1}\\) the put stops the loss at 48.36 USD/share.

---

#### **Question 10**
In a zero-cost collar, \\(\mathcal{P}_{1} = \mathcal{P}_{2}\\). Between the strikes, \\(K_{1} \leq S(T) \leq K_{2}\\), how does its profit at expiration compare with that of the shares alone?
- **A)** The two are the same, \\(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot S(0)\\).
- **B)** The collar earns more by the call premium grown to expiration.
- **C)** The collar earns less by the put premium grown to expiration.
- **D)** The collar's profit is flat between the strikes.

**Answer:** **A) The two are the same, \\(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot S(0)\\).**
**Explanation:** Between the strikes neither option pays, so the profit is \\(S(T) - \mathcal{D}_{T,0}(g_{y})\cdot(S(0) + \mathcal{P}_{1} - \mathcal{P}_{2})\\), and with \\(\mathcal{P}_{1} = \mathcal{P}_{2}\\) this is the profit of the shares alone.

---

#### **Question 11**
The SPY collar's legs have quoted Deltas \\(\Delta_{p} = -0.2251\\) (the 725 put) and \\(\Delta_{c} = 0.1965\\) (the 802 call). What is the net Delta of one collar, \\(m = 100\\) shares and \\(n = 1\\) contract?
- **A)** 102.86 shares
- **B)** 80.35 shares
- **C)** 57.84 shares
- **D)** 100.00 shares

**Answer:** **C) 57.84 shares**
**Explanation:** The net Delta is \\(mn(1 + \Delta_{p} - \Delta_{c}) = 100\,(1 - 0.2251 - 0.1965) = 57.84\\), so the long put and the short call both lower it from the 100 of the shares alone.
