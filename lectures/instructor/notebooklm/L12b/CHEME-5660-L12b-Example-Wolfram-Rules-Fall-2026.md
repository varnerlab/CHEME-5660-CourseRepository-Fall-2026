# Example: What Does a Rule Do in a Wolfram Market?
In this example, we look at what one rule does in a Wolfram market. We read the table of one rule, run a market in which every interior trader follows that rule, and then compare it with a market that follows a second rule.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Read a rule number:__ Turn a rule number into its table, the next intention of a trader for each sum of its four neighbors' intentions.
> * __Watch a rule act on the grid:__ Run a market in which every interior trader follows the rule, and use the grid, the intentions, and the share price to describe what the rule does.
> * __Compare two rules:__ Run a second market that follows a different rule, and use the two grids and the two share prices to explain what the rule changes.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/).

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).


### Constants
Next, let's set the constants. The first two constants are the rule number and a second rule number, which we compare with the first in Task 3. One step lasts `Δt` years, and the dealer's share price gets noise with annualized volatility `σ_S` at each step.

Change the rule numbers and run the cells again:

___

## Task 1: Read the Rule
In this task, we turn the rule number into its table. Each interior trader adds up the intentions of its four neighbors, with Buy counted as `0`, Hold as `1`, and Sell as `2`. The sum runs from `0` (four Buy neighbors) to `8` (four Sell neighbors). 

A __rule__ is a table with the trader's next intention for each sum, and the __rule number__ is those nine entries read as one number in base 3.

[The rule_table(...) function](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/) returns the nine entries of a rule number, ordered from sum `0` to sum `8`. We store the entries in the `entries::Vector{Int64}` variable:

Output:
```
Rule 19280 in base 3, from sum 8 down to sum 0: 222110002
```

`Unhide` the code block below to see how we drew the rule table with the `plot_rule(...)` helper in `src/Helper.jl`. Each tile shows the next intention of a trader for one sum of its neighbors' intentions.

___

## Task 2: Watch the Rule Act on the Grid
In this task, we give the rule to every interior trader, run the market, and look at the grid at several steps.

At each step, the dealer fills the orders, and then every interior trader reads its next intention from the rule table. The `run_rule_market(...)` function in `src/Helper.jl` runs the market and saves the grid at the steps we pass in `snapshot_steps`.

We store the market in the `market::MyModelBSimulationResult` variable:

Output:
```
run time: 2.3 seconds; saved grids: 5001
```

Let's look at the grid at the steps in `steps_to_visualize`, from the start to the last step. Each tile is one interior trader: Buy is blue, Hold is gray, and Sell is orange:

`Unhide` the code block below to see how we drew the grids with the `plot_grid(...)` helper function in the `src/Helper.jl` file.

> __What do we see?__
>
> * __The start:__ At the first step shown, most traders hold, and a few scattered traders intend to buy or sell.
> * __The first steps:__ The grid changes quickly, because every trader reads its next intention from the table at each step.
> * __The later steps:__ When the later grids look alike, the market has settled into the mix of intentions that the rule keeps.

Next, let's follow the intentions and the share price. The dealer quotes the share price from its cash and shares. Net buying raises the price, and net selling lowers it.

Set `steps_to_plot` to choose how many steps the plots show:

`Unhide` the code block below to see how we plotted the fractions of the three intentions and the share price.

Does the share price follow the intentions?

Output:
```
print device already activated
print device already activated
```

> __What do we see?__
>
> * __Intentions:__ The fractions of the three intentions change in the first few steps. They stay level once the market has settled into its mix.
> * __Share price:__ The share price rises while more traders buy than sell, and it falls while more traders sell than buy.
> * __The price levels off:__ A trader can buy only with the cash it holds, and can sell only the shares it holds. When many orders fail for lack of cash or shares, the share price levels off, even if the Buy and Sell fractions stay apart.

Let's compare our first market rule with a second market that follows a different rule. 

___

## Task 3: Compare Two Rules
In this task, we run a second market that follows `switch_rule`, and compare it with the first market. The second market has the same starting market, the same dealer, and the same noise as the first. Only the rule differs.

We store the entries of the second rule in the `entries_to_compare::Vector{Int64}` variable, and the second market in the `market_to_compare::MyModelBSimulationResult` variable:

Output:
```
run time: 1.1 seconds; saved grids: 5001
```

`Unhide` the code block below to see how we drew the tables of the two rules. The top table is `baseline_rule`, and the bottom table is `switch_rule`.

At which sums do the two rules give a different next intention?

`Unhide` the code block below to see how we drew the grids of the two markets at the same steps. The top row follows `baseline_rule`, and the bottom row follows `switch_rule`.

When do the two grids part?

> __What do we see?__
>
> * __The same start:__ The two markets start from the same grid.
> * __The grids part:__ The two grids stay alike until traders reach a sum at which the two rules differ. From then on, the grids move apart.
> * __The later steps:__ The later grids show the mix of intentions that each rule keeps.

`Unhide` the code block below to see how we plotted the share prices of the two markets.

What does the second rule do to the share price?

Both share prices start at the same value. The two prices move apart once the two grids differ, because the two markets then send different orders to the dealer.

Here every trader followed the second rule from the first step. Next, we ask what happens when only a fraction of the traders change rules partway through a market.

___

## Summary
In this example, we read the table of a rule and ran a market in which every interior trader follows that rule. We then ran a second market under a different rule and compared the two markets.

> __Key Takeaways:__
>
> * __A rule number is a table:__ We read the rule number in base 3 to get nine entries, one for each sum of the four neighbors' intentions. Each entry is the next intention of a trader whose neighbors have that sum.
> * __One rule sets the mix on the grid:__ We gave the rule to every interior trader and saved the grid at each step. The grid moved from its start to the mix of intentions that the rule keeps, and the share price followed the balance of buyers and sellers.
> * __A different rule gives a different market:__ We ran a second market from the same start under a second rule. The two grids moved apart once traders reached a sum at which the two rules differ, and the two share prices moved apart with them.

We can now change either rule number and see what the new rule does to the grid and to the share price.
___
