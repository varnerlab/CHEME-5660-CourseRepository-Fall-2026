# Example: A Rule Switch in a Wolfram Market
In this example, we simulate the Wolfram market, an agent-based model in which interior traders on a grid act on the intentions of their four neighbors. We change one entry of the rule that a fraction of the interior traders follow, and watch the grid and the share price.

> __Learning Objectives:__
>
> By the end of this example, you should be able to:
> * __Watch a rule switch spread:__ Run a switched market and its control, and use the grid at several steps to say where the Sell intention starts and how it spreads.
> * __Explain the path of the share price:__ Compare the share price of the switched market with its control, and use the filled and unfilled orders to explain why the price stops falling.
> * __Bring in fresh players:__ Replace a fraction of the traders with fresh players after the share price has leveled off, and compare the share price with and without the fresh players.

Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/).

Let's set up our code environment:

For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/) and the [CHEME 5660 Quantitative Finance Package documentation](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/).

### Constants
Next, let's set the constants. The live market uses a deep dealer and active edge traders, who buy when the share price is well below its recent average and sell when it is well above it.

Each step lasts `Δt` years, and the default is one minute of trading. At each step, the dealer's share price also changes by a random amount, the __noise__, with annualized volatility `σ_S`. The noise added in one step has standard deviation $\sigma_{S}\sqrt{\Delta t}$, and a longer step gets more noise.

Change the parameters and run the cells again. Every task runs live and follows the constants:

___

## Task 1: Watch a Rule Switch Spread
In this task, we run a switched market and its control, and watch the Sell intention spread across the grid.

In a __rule switch__, all interior traders follow the rule `baseline_rule` until the switch step, and then a fraction $f$ of them change to the rule `switch_rule`. The __control__ shares the history of the switched market and never switches.

The `run_noisy_rule_switch(...)` function in `src/Helper.jl` runs both markets with the same dealer noise, and saves the grid at the steps we pass in `snapshot_steps`. We store the two markets and the saved steps in the `live::NamedTuple` variable:

Output:
```
run time: 2.0 seconds; saved grids: 801
```

Let's look at the grid at six steps, from the switch step to the last step. Each tile is one interior trader: Buy is blue, Hold is gray, and Sell is orange. The top row shows the control, and the bottom row shows the switched market at the same steps:

`Unhide` the code block below to see how we drew the grids with the `plot_grid(...)` helper in `src/Helper.jl`.

Where does the Sell intention start?

The two markets have the same grid at the switch step. After the switch, every difference between the two rows comes from the traders who follow `switch_rule`.

Next, let's watch the two grids and the share price together. `Unhide` the code block below to see how we built the animation, which draws one frame every 20 steps with [the @animate macro](https://docs.juliaplots.org/stable/animations/):

Output:
```
Plots.AnimatedGif(...)
```

Your grids will differ if you change the parameters, because each `seed` gives a different starting market.

___

## Task 2: Follow the Share Price
In this task, we compare the share price of the switched market with its control, and ask why the price stops falling.

The dealer quotes the share price from its cash and shares. Net selling lowers the price, and net buying raises it. The __Sell fraction__ is the fraction of interior traders who intend to sell, and a market has a __Sell majority__ once the Sell fraction reaches one half after the switch.

`Unhide` the code block below to see how we plotted the intentions and the share price of the two markets from Task 1. Each strip on the left shows the fraction of interior traders who intend to buy, hold, and sell, in the colors of the grid. The top of the orange band is the Sell fraction, and the dotted line marks one half.

A trader can sell only the shares it holds, and each trader started with `10` shares.

`Unhide` the code block below to see how we plotted the orders in the switched market at each step: the Sell and Buy orders that the dealer filled, and the Sell orders that failed because the trader had no shares.

Why does the share price stop falling?

A Sell order fails when the trader has no shares left. When the filled Sell orders and the filled Buy orders are about equal, the net trade is close to zero, and only the noise moves the dealer's price.

One market is one starting market. Let's repeat the switch for 20 starting markets on a smaller grid, with the same parameters. We store the share prices of each switched market and its control in the `markets::Vector{NamedTuple}` variable:

Output:
```
run time for 20 starting markets: 2.1 seconds
```

`Unhide` the code block below to see how we plotted the share price of every switched market and every control. Do all the starting markets end at the same share price?

___

## Task 3: Bring in Fresh Players
In this task, we replace a fraction of the traders with fresh players after the share price has leveled off, and compare the share price with the run from Task 1.

After step `t_fresh`, __fresh players__ replace a fraction `fresh_fraction` of the interior traders. A fresh player starts with the cash and shares that every trader had at step `0`, and follows the rule `recovery_rule`. For example, a fresh player that follows Rule `0` intends to buy at every step.

The `run_noisy_rule_switch(...)` function runs the two markets of Task 1 again, with the fresh players. We store the two markets in the `recovery::NamedTuple` variable:

Output:
```
run time: 0.7 seconds
```

`Unhide` the code block below to see how we plotted the intentions and the share price of the switched market, with and without the fresh players. The top strip shows the market without fresh players, and the bottom strip shows the market with fresh players.

Does the share price recover?

Up to step `t_fresh`, the two switched markets have the same share price. After it, every difference between the red line and the green line comes from the fresh players.

Next, let's look at the grid of the switched market at six steps, from the step `t_fresh` to the last step. The top row shows the market without fresh players, and the bottom row shows the market with fresh players:

`Unhide` the code block below to see how we drew the grids. Where do the intentions change first?

Set `recovery_rule = baseline_rule` to give the fresh players the rule from before the switch, and run the cells of Task 3 again.

___

## Summary
In this example, we watched a rule switch spread across the grid of a Wolfram market, followed the share price as it fell and leveled off, and brought in fresh players to move the share price again.

> __Key Takeaways:__
>
> * __A rule switch spreads from neighbor to neighbor:__ We ran a switched market and its control, and looked at the grid at several steps. Each trader acts on the intentions of its four neighbors, and a change in the switching traders reaches the rest of the grid through their neighbors.
> * __The share price falls until the sellers run out of shares:__ We compared the share price of the switched market with its control, and counted the filled and unfilled orders. A trader can sell only the shares it holds, and the price levels off once the filled Sell orders and the filled Buy orders are about equal.
> * __The recovery rule sets the direction of the share price:__ We replaced a fraction of the traders with fresh players, who start with new cash and shares and follow a recovery rule. Fresh players who intend to buy raise the share price, and fresh players who intend to sell lower it.

We can now change the rules, the fraction of switching traders, the fresh players, the dealer's depth and noise, the edge traders, the time step, and the starting market, and watch how the grid and the share price respond.
___
