# L7b Income-Gamble Interview: How Much Income Risk Would You Take?

A client chooses between two job offers, one with a sure salary and one whose salary may double or be cut. Three to five answers bracket the client's relative risk aversion $\bar{r}$, which plays the role of $A$ in the lecture's mean-variance utility. [The capital allocation line example](../CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb) reads the result and compares it with the risk aversion behind the client's L6b answer.

The questions are the income gambles of [Barsky, Juster, Kimball, and Shapiro (1997)](https://doi.org/10.1162/003355397555280), asked in the Health and Retirement Study (HRS) since 1992. From 1998, the HRS offered two new jobs, so that no respondent was choosing whether to leave a current job. We use that version and the six response categories of [Kimball, Sahm, and Shapiro (2008)](https://doi.org/10.1198/016214508000000139). Our wording replaces the HRS household and its doctor-ordered move with a graduating student's two offers. Steps 1 to 3 are the published questions. Step 4 is our extension: two more questions in the same form narrow the range inside the client's category.

To run it with Claude Code, from the repository root:

```
Run the L7b income-gamble interview at lectures/week-7/L7b/interview/interview.md
and walk me through it interactively. Use the AskUserQuestion UI.
```

You can also ask the questions yourself and run the script in Step 5 with the answers.

> __For assistants running this interview:__
>
> * Ask one question per screen with the AskUserQuestion UI, in the order below. Use each step's question text with that step's cut and low income, and keep the sentence "All salaries are in today's dollars and rise with inflation." on every screen.
> * Offer two options: __First job__ (description: "\$100,000 a year, guaranteed") and __Second job__ (description: "50–50: \$200,000 or [low income] a year"). Record each answer as `first` or `second`.
> * The script in Step 5 computes the category and the range of $A$. Do not compute or suggest them yourself. To check which question comes next, run the script with the answers so far.
> * Stop after Step 5. Do not execute the notebooks. The instructor runs them in class so that students watch each output appear.


## Why the answers measure risk aversion

Measure income in units of the sure salary. The first job pays $1$, and the second pays $2$ or $1-\delta$ with equal probability, where $\delta$ is the cut. At the cut $\delta^{\star}$ where the client cannot choose, the certainty equivalent of the second job equals the sure salary:

$$
\frac{1}{2}\,U(2)+\frac{1}{2}\,U(1-\delta^{\star}) = U(1)
$$

For a power utility with relative risk aversion $\bar{r}$, this equation fixes $\bar{r}$. Log utility ($\bar{r}=1$) is indifferent at a cut of one half, and $U(w)=-1/w$ ($\bar{r}=2$) at a cut of one third. A more risk-averse client accepts only smaller cuts, so accepting a cut puts an upper bound on $\bar{r}$, and refusing one puts a lower bound on it.


## Step 1: The first question

> Suppose you are about to graduate and have two job offers. Whichever job you take will be your household's only income for life. All salaries are in today's dollars and rise with inflation. The first job guarantees \$100,000 a year for life. The second job is possibly better paying, but the income is also less certain. There is a 50–50 chance it doubles your lifetime income to \$200,000 a year and a 50–50 chance it cuts it by a third, to about \$66,700 a year. Which job would you take, the first or the second?

## Step 2: The second question

Every later question changes only the cut:

> Now suppose the second job has a 50–50 chance of doubling your income to \$200,000 a year and a 50–50 chance of cutting it __[by the cut]__, to __[low income]__ a year. All salaries are in today's dollars and rise with inflation. Which job would you take, the first or the second?

| Step 1 answer | Step 2 cut | Low income |
|---|---|---|
| Second job | in half | \$50,000 |
| First job | by 20 percent | \$80,000 |

## Step 3: The third question, if needed

| Steps 1 and 2 answers | Step 3 cut | Low income |
|---|---|---|
| Second, then second | by three quarters | \$25,000 |
| First, then first | by 10 percent | \$90,000 |
| Second, then first | none, go to Step 4 | |
| First, then second | none, go to Step 4 | |

The published questions place the client in one of six categories. The bounds on $\bar{r}$ solve the equation above at the largest cut accepted and the smallest cut refused:

| Category | Accepts | Refuses | Relative risk aversion $\bar{r}$ | HRS 2002 share |
|:-:|:-:|:-:|:-:|--:|
| 1 | none | 10% | above 7.53 | 44.8% |
| 2 | 10% | 20% | 3.76 to 7.53 | 18.6% |
| 3 | 20% | a third | 2 to 3.76 | 15.3% |
| 4 | a third | half | 1 to 2 | 9.6% |
| 5 | half | three quarters | 0.31 to 1 | 6.1% |
| 6 | three quarters | none | below 0.31 | 5.6% |

The HRS shares are the 3,591 responses of 2002, the latest wave in Table 2 of Kimball, Sahm, and Shapiro (2008). The HRS surveys adults over 50, and from 2000 it asked these questions only of those under 65.

__Class poll (optional):__ Ask the whole class Steps 1 to 3 by a show of hands, tally the six categories, and compare the tally with the HRS column.

## Step 4: Narrow the range (our extension)

Two more questions in the Step 2 form each halve the range of cuts inside the category. A client in category 6 skips this step.

| Category | First cut (low income) | Next cut after the first job | Next cut after the second job |
|:-:|:-:|:-:|:-:|
| 1 | 5% (\$95,000) | 2.5% (\$97,500) | 7.5% (\$92,500) |
| 2 | 15% (\$85,000) | 12.5% (\$87,500) | 17.5% (\$82,500) |
| 3 | 25% (\$75,000) | 22.5% (\$77,500) | 30% (\$70,000) |
| 4 | 40% (\$60,000) | 35% (\$65,000) | 45% (\$55,000) |
| 5 | 60% (\$40,000) | 55% (\$45,000) | 67.5% (\$32,500) |


## Step 5: Run the script

From the repository root, with the answers in the order asked:

```
julia lectures/week-7/L7b/interview/income-gamble.jl --answers=first,first,second,second,first
```

The script replays the questions, prints the published category with its HRS share, and solves the indifference equation for the bounds on $\bar{r}$. It writes `data/my-risk-aversion.toml` in the L7b folder. Show its full output to the client. It uses only Julia's standard library and takes about a second. With fewer answers than the interview needs, it prints the next question and writes nothing. Add `--dry-run` to print the result without writing the file.


## Step 6: Run the example in class

Open [the capital allocation line example](../CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb) and run it from the top. If `data/my-client.toml` has been copied from L6b, it also uses the client's risk-free fraction. Uncommenting its ticker-file lines adds the client's firms from `data/my-tickers.csv`.

__What to look for:__

* __Two measures of one client:__ Task 3 adds the two ends of the client's range of $A$ to the table of interview answers, with the risk-free fraction each end would choose. It also says whether the $A$ behind the client's L6b answer lies inside the range.
* __The client and the market:__ The range of $A$ belongs to the client, while the fraction it implies also depends on the firms. A different ticker list changes $\mathbb{E}[g_{\mathcal{T}}]$ and $\sigma_{g,\mathcal{T}}$, so the same range gives different fractions.

__After class:__ close the example without saving, or restore it with `git checkout -- lectures/week-7/L7b/CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb`, so its stored outputs keep the defaults. Git ignores `data/my-risk-aversion.toml`, so delete it to return to the defaults:

```
rm lectures/week-7/L7b/data/my-risk-aversion.toml
```
