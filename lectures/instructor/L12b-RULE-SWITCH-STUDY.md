# Markets worth a look: other rule switches

The lecture switches a fraction of the traders from Rule 19280 to Rule 19286. This note lists three other baseline rules whose market rises, and then falls when a fraction of the traders change one entry of the rule table. Each case runs in the RuleSwitch example by changing two constants.

## How to run a case

Open `lectures/week-12/L12b/CHEME-5660-L12b-Example-Wolfram-RuleSwitch-Fall-2026.ipynb`. In the Constants cell, set `baseline_rule` and `switch_rule` to a pair from the tables below, and run all cells.

```julia
baseline_rule = 19287; # rule number that every interior trader follows before the switch
switch_rule = 19341; # rule number that the switching traders follow after the switch
f = 0.25; # fraction of interior traders that switch to switch_rule
```

* Every task runs live and follows the constants: the grids, the animation, the Sell fraction, the share price, the orders, the 20 small markets, and the fresh players.
* Task 3 brings in fresh players after step `t_fresh`. The fresh players replace a fraction `fresh_fraction` of the traders and follow `recovery_rule`: Rule `0` always buys, and `baseline_rule` is the rule from before the switch.

## What the numbers are

Every number below comes from the example's default constants: `L = 64`, `f = 0.25`, `h = 100.0`, active edge traders, `seed = 1`, `t_pre = 1000`, and `t_post = 3000`.

* __Price at step 4,000:__ the share price of the switched market at the last step. The control's price at step 4,000 is in the heading of each market.
* __Change:__ the switched price at step 4,000 compared with the control price at step 4,000.
* __Sell reaches one half:__ the first step at which half of the interior traders intend to sell.
* __Small markets:__ the number of the 20 small markets of Task 2 (`L_small = 32`) whose switched price ends at least 10% below the control.

Each rule table lists the next intention for the sums 8 down to 0, the order of the digits of the rule number (B = Buy, H = Hold, S = Sell).

## The lecture's case, for comparison

Rule 19280, table `S S S H H B B B S`. At step 1,000: 52% Buy, 23% Hold, 25% Sell, price 117.3 USD/share. The control ends at 114.7.

| Switch rule | Entry changed | Price at step 4,000 | Change | Sell reaches one half | Small markets |
|---|---|---|---|---|---|
| 19286 | sum 1, Buy → Sell | 84.4 | −26.5% | step 1,402 | 20 of 20 |

## Market 1: Rule 19287, nearly every trader buys

Rule 19287, table `S S S H H B H B B`. At step 1,000: 95% Buy, 5% Hold, 0% Sell, price 122.2 USD/share. The control ends at 119.1.

This market is the closest to a bubble: nineteen traders in twenty intend to buy, and the price is 22% above its starting value.

| Switch rule | Entry changed | Price at step 4,000 | Change | Sell reaches one half | Small markets |
|---|---|---|---|---|---|
| 19341 | sum 3, Buy → Sell | 82.5 | −30.7% | step 1,213 | 20 of 20 |
| 19368 | sum 4, Hold → Sell | 82.6 | −30.6% | step 1,993 | 20 of 20 |
| 19296 | sum 2, Hold → Sell | 82.6 | −30.7% | step 1,896 | 18 of 20 |

Nearly every trader intends to sell at step 4,000 in all three cases. Rules 19368 and 19296 take 900 to 1,000 steps to reach a Sell majority. Add later steps to `steps_to_visualize` to see them, for example `[1000, 1500, 1800, 2000, 2200, 4000]`.

## Market 2: Rule 19257, falls when traders stop buying

Rule 19257, table `S S S H B S B S B`. At step 1,000: 93% Buy, 1% Hold, 6% Sell, price 118.8 USD/share. The control ends at 115.8.

No switch rule here adds a Sell entry. Each one changes a Buy entry to Hold, and the market still falls.

| Switch rule | Entry changed | Price at step 4,000 | Change | Sell reaches one half | Small markets |
|---|---|---|---|---|---|
| 19258 | sum 0, Buy → Hold | 84.6 | −26.9% | step 1,017 | 20 of 20 |
| 19266 | sum 2, Buy → Hold | 86.4 | −25.3% | step 1,082 | 20 of 20 |
| 19338 | sum 4, Buy → Hold | 84.5 | −27.0% | step 1,133 | 20 of 20 |

Rule 19258 is the fastest case in this note: the Sell majority forms 17 steps after the switch.

## Market 3: Rule 19289, falls with one trader in ten

Rule 19289, table `S S S H H B H B S`. At step 1,000: 43% Buy, 50% Hold, 7% Sell, price 121.0 USD/share. The control ends at 117.7.

Rule 19289 differs from Rule 19280 in one entry (sum 2, Buy → Hold). Six switch rules bring this market down, and nearly every trader intends to sell at step 4,000 in each case.

| Switch rule | Entry changed | Price at step 4,000 | Change | Sell reaches one half | Small markets |
|---|---|---|---|---|---|
| 19295 | sum 1, Buy → Sell | 82.5 | −29.9% | step 1,196 | 20 of 20 |
| 19298 | sum 2, Hold → Sell | 82.5 | −29.9% | step 1,054 | 20 of 20 |
| 19316 | sum 3, Buy → Hold | 82.5 | −29.9% | step 2,051 | 20 of 20 |
| 19343 | sum 3, Buy → Sell | 82.5 | −29.9% | step 1,026 | 20 of 20 |
| 19370 | sum 4, Hold → Sell | 82.5 | −29.9% | step 1,028 | 20 of 20 |
| 19532 | sum 5, Hold → Sell | 82.5 | −29.9% | step 1,039 | 20 of 20 |

## Things to try

Set `f = 0.10`, so that one trader in ten switches:

| Baseline rule | Switch rule | Price at step 4,000 | Change | Sell reaches one half | Small markets |
|---|---|---|---|---|---|
| 19289 | 19298 | 82.5 | −29.9% | step 1,244 | 20 of 20 |
| 19257 | 19258 | 106.5 | −8.0% | never | 10 of 20 |
| 19287 | 19341 | 118.8 | −0.2% | never | 1 of 20 |

Rule 19289 falls with one trader in ten. Rule 19287 does not, and it needs a fraction between `0.10` and `0.25`.

Run a market that does not fall. Under Rule 19278, table `S S S H H B B B B`, every trader intends to buy at step 1,000 and the price is 122.2 USD/share. With `f = 0.25`:

| Baseline rule | Switch rule | Entry changed | Price at step 4,000 | Change | Sell reaches one half | Small markets |
|---|---|---|---|---|---|---|
| 19278 | 19280 | sum 0, Buy → Sell | 115.3 | −3.2% | never | 0 of 20 |
| 19278 | 19284 | sum 1, Buy → Sell | 118.7 | −0.3% | never | 0 of 20 |

Other things to change:

* Set `boundary_mode = :hold`. On the 32 × 32 grid, the same switch rules bring all three markets down with the edge traders held.
* Change `seed`. Each seed gives a different starting market.

## How these markets were found

We ran every one of the 19,683 rules alone on a 32 × 32 grid, from four starting grids: mostly Hold, mostly Buy, mostly Sell, and even thirds. For 41 rules, the mostly-Hold start gives a price of 110 USD/share or more, and another start gives a price of 90 USD/share or less. Rules 19280, 19287, 19257, and 19289 are four of the 41.

For each of the 41 rules, we then switched 25% of the traders to each of its 18 one-entry changes, in 10 starting markets. In 30 of the 41 rules, at least one change takes the price 10% or more below the control.
