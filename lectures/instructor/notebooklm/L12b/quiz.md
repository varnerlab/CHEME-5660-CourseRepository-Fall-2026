### **L12b Self-Check (12 Questions)**

#### **Question 1**
What does an interior trader's rule table map to its next intention in the Wolfram market?
- **A)** The change in the share price over the last four steps
- **B)** The sum of its four neighbors' intentions
- **C)** The dealer's cash divided by its shares
- **D)** The number of Sell orders that filled in the last step

**Answer:** **B) The sum of its four neighbors' intentions**
**Explanation:** Each interior trader adds its four neighbors' intention codes and reads its next intention from the table entry for that sum.

---

#### **Question 2**
Buy is coded as 0, Hold as 1, and Sell as 2. A trader has three Buy neighbors and one Hold neighbor. Rule 19280 gives Buy at neighbor sum 1, while Rule 19286 gives Sell at that sum. What does the trader intend next under each rule?
- **A)** Sell under both rules, because the trader acts against a Buy majority
- **B)** Hold under both rules, because one neighbor holds
- **C)** Buy under Rule 19286 and Sell under Rule 19280
- **D)** Buy under Rule 19280 and Sell under Rule 19286

**Answer:** **D) Buy under Rule 19280 and Sell under Rule 19286**
**Explanation:** The neighbor sum is \\(0+0+0+1=1\\), so each rule uses its entry at sum 1.

---

#### **Question 3**
Rule 19280 is written as \\((222110002)_{3}\\), with entries ordered from neighbor sum 8 down to sum 0. Buy is 0, Hold is 1, and Sell is 2. Which reading of the table is correct?
- **A)** Sell at sum 0, Buy at sum 1, and Sell at sum 8.
- **B)** Buy at sum 0, Sell at sum 1, and Sell at sum 8.
- **C)** Sell at sum 0, Sell at sum 1, and Buy at sum 8.
- **D)** The digits give the numbers of buyers and sellers on the grid.

**Answer:** **A) Sell at sum 0, Buy at sum 1, and Sell at sum 8.**
**Explanation:** Reading the digits from right to left gives \\(a_{0}=2\\), \\(a_{1}=0\\), and, at the far left, \\(a_{8}=2\\).

---

#### **Question 4**
In the one-rule example, every interior trader follows the second rule from the first step. In the rule-switch example, a fraction \\(f=0.25\\) changes rules partway through the run. What changes for those selected traders at the switch?
- **A)** They all immediately sell their entire holdings.
- **B)** Their cash and shares reset to their starting amounts.
- **C)** Their rule tables change, while their current intentions, cash, and shares stay the same.
- **D)** They learn whichever rule earned the most money before the switch.

**Answer:** **C) Their rule tables change, while their current intentions, cash, and shares stay the same.**
**Explanation:** The switch replaces the selected traders' rules, and their next intentions depend on the neighbor sums they subsequently read.

---

#### **Question 5**
How does the dealer quote the share price in the Wolfram market?
- **A)** As the fraction of interior traders who intend to Buy
- **B)** As the average price the traders would like to pay
- **C)** As its shares divided by its cash
- **D)** As its cash divided by its shares

**Answer:** **D) As its cash divided by its shares**
**Explanation:** The dealer quotes \\(S_{t}=W_{t}/Q_{t}\\), and its cash and shares change when it takes the other side of the net trade.

---

#### **Question 6**
At one step, traders buy 10 shares and sell 40 shares in filled orders. The net trade is shares bought minus shares sold. With price noise set to zero, what happens to the dealer's shares and quoted price?
- **A)** The dealer's shares fall by 30, and the quoted price rises.
- **B)** The dealer's shares rise by 30, and the quoted price falls.
- **C)** The dealer's shares rise by 50, and the quoted price stays the same.
- **D)** The dealer's shares and quoted price stay the same because both sides traded.

**Answer:** **B) The dealer's shares rise by 30, and the quoted price falls.**
**Explanation:** The net trade is \\(10-40=-30\\) shares, so the dealer buys the 30 extra shares being sold and lowers its quoted price.

---

#### **Question 7**
Most interior traders still intend to Sell late in the rule-switch run, but the price has leveled off. The filled Buy and Sell orders are nearly equal, and many Sell orders fail. What explains this?
- **A)** Many sellers have run out of shares, so the Sell majority no longer produces net selling.
- **B)** A Sell intention automatically changes to Hold when the price falls.
- **C)** The dealer stops using trades to set its price after a Sell majority forms.
- **D)** Every trader has learned that the share price is too low.

**Answer:** **A) Many sellers have run out of shares, so the Sell majority no longer produces net selling.**
**Explanation:** A trader needs a share to fill a Sell order, and a net trade near zero leaves only the added noise to move the dealer's price.

---

#### **Question 8**
Two dealers start at the same quoted price, but one holds more cash and shares in the same proportion. For the same feasible, nonzero net trade and with price noise set to zero, how does the deeper dealer's price move compare with the shallower dealer's?
- **A)** The deeper dealer's price always moves upward, even for net selling.
- **B)** Both prices move by the same amount because the rule tables are identical.
- **C)** The deeper dealer's price moves less because the net trade is smaller relative to its shares.
- **D)** The deeper dealer's price moves more because it has more cash.

**Answer:** **C) The deeper dealer's price moves less because the net trade is smaller relative to its shares.**
**Explanation:** Greater dealer depth gives more liquidity, which reduces the price impact of a given net trade.

---

#### **Question 9**
Why do we compare the switched market with a control that shares its history and the same dealer noise but never switches?
- **A)** The control keeps its share price fixed at the starting price.
- **B)** The control removes all randomness from both markets.
- **C)** The control guarantees that any rule switch will produce a Sell majority.
- **D)** The control shows what the market would have done without the rule change.

**Answer:** **D) The control shows what the market would have done without the rule change.**
**Explanation:** Holding the starting history and dealer noise the same lets us attribute differences between the paired markets to the rule switch.

---

#### **Question 10**
Only 25% of the interior traders receive the switch rule, yet later more than half intend to Sell. How can this happen?
- **A)** The dealer secretly assigns the switch rule to every trader.
- **B)** Traders whose rules stayed the same can also choose Sell as their neighbors' intentions change.
- **C)** Every trader learns a new table after observing the falling price.
- **D)** The Sell fraction counts unfilled orders repeatedly until it exceeds one half.

**Answer:** **B) Traders whose rules stayed the same can also choose Sell as their neighbors' intentions change.**
**Explanation:** Intentions feed into neighboring traders' decisions, so the fraction intending to Sell can grow beyond the fraction whose rules changed.

---

#### **Question 11**
After the switched price has leveled off, Task 3 replaces a fraction of the traders with fresh players who have their starting cash and shares. These fresh players follow Rule 0, which gives Buy at every neighbor sum. Why can the price rise again?
- **A)** Fresh players force every other trader to adopt Rule 0.
- **B)** Replacing traders resets the dealer's quote to the original share price.
- **C)** The fresh players can fund Buy orders, which can turn the net trade toward buying.
- **D)** Any new player raises the price regardless of its rule or holdings.

**Answer:** **C) The fresh players can fund Buy orders, which can turn the net trade toward buying.**
**Explanation:** Fresh cash and an always-Buy rule can produce net buying, while fresh players with a different rule need not move the price upward.

---

#### **Question 12**
What can we conclude when a one-entry rule switch produces a Sell majority and a falling price in this model?
- **A)** A local change in trader behavior can spread through this simulated market, but the result does not establish what caused a real crash.
- **B)** Every historical crash was caused by a quarter of traders changing one rule entry.
- **C)** All agent-based markets reproduce every stylized fact of real growth rates.
- **D)** The four-neighbor grid and rule parameters have been estimated from historical crashes.

**Answer:** **A) A local change in trader behavior can spread through this simulated market, but the result does not establish what caused a real crash.**
**Explanation:** The simulation depends on its chosen grid, update order, and parameters, while real markets can also face common outside shocks.
