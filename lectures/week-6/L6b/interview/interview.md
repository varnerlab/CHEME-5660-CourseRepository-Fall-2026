# L6b Client Interview: Which Firms Go in the Portfolio?

A client answers three questions, and a fixed rule turns the answers into the list of firms for the L6b portfolio examples and the client's risk-free fraction $w_f$. The rule uses the single index model (SIM) parameters saved by [the estimation example](../CHEME-5660-L6b-Example-SVD-SIM-Estimation-Fall-2026.ipynb). It picks firms by their beta and fit, never by their past growth. [The SIM portfolio example](../CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb) and [the tangent portfolio example](../CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb) read the result.

To run it with Claude Code, from the repository root:

```
Run the L6b client interview at lectures/week-6/L6b/interview/interview.md
and walk me through it interactively. Use the AskUserQuestion UI.
```

You can also skip the assistant and run the screen in Step 4 yourself with the options your answers select.

> __For assistants running this interview:__
>
> * Ask one question per screen with the AskUserQuestion UI, in the order below, using the option labels and descriptions given in each step.
> * Every ticker comes from the screen in Step 4. Do not suggest, add, or remove tickers yourself. A client's change of mind goes through the script's options and a rerun.
> * Stop after Step 5. Do not execute the notebooks. The instructor runs them in class so that students watch each output appear.


## Step 1: How strongly should the firms move with the market?

In the SIM, firm $i$'s growth rate has the market term $\beta_i\,g_M$. A firm with $\beta_i = 0.8$ moves, on average, 0.8 times as far as the market, so beta measures how much market risk each firm carries. This answer sets the beta band:

| Answer | The client says | Beta band | Option |
|---|---|---|---|
| __Defensive__ | "In a downturn, I want to lose less than the market, even if I gain less in a rally." | $\beta < 0.8$ | `--band=defensive` |
| __Market-like__ | "I am comfortable moving roughly with the market." | $0.8 \leq \beta < 1.2$ | `--band=market` |
| __Aggressive__ | "I accept larger swings than the market in both directions." | $\beta \geq 1.2$ | `--band=aggressive` |

Step 1 picks the kind of firms. Step 3 sets how much of the account is exposed to them.

## Step 2: Is anything off-limits?

Ask as a multiple-selection question. Each group removes a GICS sector or sub-industry:

| Answer | Removes | Option |
|---|---|---|
| __None__ | nothing | (omit `--exclude`) |
| __Fossil fuels__ | the Energy sector (oil, gas, and coal) | `--exclude=fossil` |
| __Tobacco and alcohol__ | Tobacco, Brewers, Distillers & Vintners | `--exclude=tobacco-alcohol` |
| __Weapons and defense__ | Aerospace & Defense | `--exclude=defense` |

Combine groups with commas, for example `--exclude=fossil,defense`. Free-text answers map to three more options: gambling is `--exclude=gambling` (Casinos & Gaming), a whole sector is `--exclude-sector=Utilities`, and a specific company is `--drop=TICKER`.

## Step 3: Hold T-bills, stay fully invested, or borrow?

By two-fund separation, every client with our inputs and risk-free rate holds the same risky fund, the tangent portfolio. This answer sets only the fraction $w_f$ of the account in the risk-free asset:

| Answer | Risk-free fraction | Option |
|---|---|---|
| __Keep half in T-bills__ | $w_f = 0.50$ | `--wf=0.5` |
| __Keep a quarter in T-bills__ | $w_f = 0.25$ | `--wf=0.25` |
| __Fully invested__ | $w_f = 0$ | `--wf=0` |
| __Borrow a quarter more__ | $w_f = -0.25$, borrowing at the risk-free rate | `--wf=-0.25` |

A free-text answer can give any value, such as `--wf=0.75` for three quarters in T-bills.


## Step 4: Run the screen

From the repository root, with the options from Steps 1 to 3:

```
julia lectures/week-6/L6b/interview/screen-tickers.jl --band=defensive --exclude=fossil --wf=0.25
```

The screen applies one rule to every firm in the SIM archive:

* __Candidates:__ firms with complete 2014 to 2024 and 2025 price histories and a current GICS sector. ETFs and firms that have since left the index have no sector, so the screen skips them.
* __Band and exclusions:__ the firm's fitted beta lies in the Step 1 band, and the firm is not in a Step 2 group.
* __Ranking:__ within each sector, the two firms with the highest $R^2$, the fraction of their growth-rate variation that the market explains. These are the firms the SIM describes best.
* __Never used:__ mean growth. A firm cannot enter the list because it did well in 2014 to 2024.

The script prints the list with its sectors, median beta, and equal-weight portfolio beta, and names any sector with no firm in the band. It writes `data/my-tickers.csv` and `data/my-client.toml` in the L6b folder. Show its full output to the client. It takes about ten seconds.

## Step 5: Confirm the list

Ask whether to keep the list:

| Answer | What happens |
|---|---|
| __Accept the list__ | Done. Go to Step 6. |
| __Swap a firm__ | Rerun with `--drop=TICKER` and `--add=TICKER`. The printout marks an added firm outside the band. |
| __Change the band__ | Return to Step 1. |
| __More firms per sector__ | Rerun with `--per-sector=3`. |

Add `--dry-run` to preview a change without writing the files.


## Step 6: Run the examples in class

Open the [SIM portfolio example](../CHEME-5660-L6b-Example-SIM-MinVar-RA-Fall-2026.ipynb), then the [tangent portfolio example](../CHEME-5660-L6b-Example-SIM-MinVar-RRFA-Fall-2026.ipynb), and run each from the top. The ticker cell in Task 1 prints the client's list. Without the two files, both examples use the thirteen L6a firms.

__What to look for:__

* __Missed co-movement:__ The screen takes two firms per sector, so the residual-correlation table in Task 1 of the SIM portfolio example shows whether firms in the same sector move together more than their betas explain.
* __One risky fund:__ In the tangent portfolio example, the client's fraction changes only how much of the account sits in $\mathcal{T}$. Task 3 labels the client's wealth path and table row "(client)".
* __Against the index:__ Compare the client's 2025 wealth with SPY's at similar realized risk, as the tangent portfolio example's Task 3 reading suggests.

__After class:__ close both examples without saving, or restore them with `git checkout`, so their stored outputs keep the default firms. The two client files are ignored by git. To return to the default firms, delete them:

```
rm lectures/week-6/L6b/data/my-tickers.csv lectures/week-6/L6b/data/my-client.toml
```
