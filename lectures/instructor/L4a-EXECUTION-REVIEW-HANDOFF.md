# L4a execution-aware notebook review — restart note

Saved September 10, 2026 at the instructor's request to pause and resume later.

## Current status — interactive review complete

All agreed revisions through the Summary have been applied. The final Summary
has three retrospective takeaways aligned with the three tasks, with no blank
lines between bullet points, as explicitly requested. The limitations and all
Task 3 introductions and interpretations have also been approved and applied.
No proposed review passage remains pending. The older progress entries below
are historical; do not resume from their superseded “Next” instructions.

The notebook has exactly three tasks, three adjacent learning-objective bullets,
and three adjacent takeaway bullets. Local links and major-section rules were
checked. The code was executed successfully when the target plot was changed,
including targeted checks of the step thresholds and strict comparison. Edits
since that execution have changed only Markdown. The step-plot output was
refreshed; other stored outputs and the existing disclaimer were preserved.
After completion, the instructor authorized committing and pushing this review.

## Notebook and workflow

Target: [Execution-aware probability of profit](../week-4/L4a/advanced/execution/CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb).

Read [NOTEBOOK-STYLE-GUIDE.md](NOTEBOOK-STYLE-GUIDE.md) before continuing.
We are interactively reviewing manageable passages: propose wording, incorporate
the instructor's corrections, and apply agreed wording when requested. Do not
rewrite the remainder of the notebook automatically. Preserve the main L4a
lecture and unrelated working-tree changes. Commit scope is the reviewed
execution notebook, its local function references, this handoff, and the shared
style preferences established during this review.

## Completed and saved

- Opening cell: approved short introduction, exactly three learning objectives
  with no blank lines between their bullets, and the overview paragraph below
  the objectives, immediately before “Let's get started!”
- Setup: follows the standard setup in the L4a cumulative-probability example,
  with the original “Setup, Data, and Prerequisites” heading, a labeled Include
  blockquote, the setup invitation, include cell, and documentation references.
  The local setup-file description was kept accurate. The instructor's request
  to always use this standard setup is recorded in the shared style guide.
- Task 1 opening: approved compact cash-flow scenario, followed by the explanation
  that the lattice models the mid-price and we translate it into purchase and
  sale prices before calculating NPV.
- Spread and slippage: explicitly defines the full spread as a fraction of the
  mid-price, constant over the holding period; explains the ask, terminal bid,
  and adverse exit slippage before their equations.
- Cash flows: separately develops the initial outlay C₀, discounted net sale
  proceeds and NPV, and the dimensionless return ρ_N(k). Explains that C₀ includes
  entry fees and that zero costs recover the frictionless expression.
- Parameter introduction: approved illustrative trade and basis-point explanation
  appended to Task 1 before the parameter cell. Uses 100 shares at an initial
  mid-price of 100 USD/share, 20 trading days, 4% continuous annual benchmark,
  and a strict 4% discounted-return target. At that mid-price, 1 basis point
  corresponds to 0.01 USD/share; 50 basis points gives a full spread of 0.50
  USD/share, ask 100.25 and bid 99.75. Exit slippage is 0.15 USD per 100 USD of
  terminal bid price. Fees are 1 USD plus 0.005 USD/share at each side, hence
  F₀ = F_T = 1.50 USD.

All edits so far are Markdown only. Code and stored outputs have been preserved.
The cash-flow passage was exported with nbconvert and visually checked: equations
rendered properly. The latest parameter introduction was source-checked after
that render; it has not yet been visually checked. Temporary review artifacts
were written under /private/tmp; they are not required to resume.

## Instructor preferences clarified in this review

- At most one short paragraph above the learning objectives.
- No blank lines between the learning-objective bullets.
- Put the “In this example, …” overview after the objectives and before
  “Let's get started!”
- Always use the standard setup demonstrated by the cumulative-probability
  example; do not invent a different setup for each notebook.
- Keep the “In this task, …” opening and explanatory voice, with modest local
  tightening when a passage is too long.
- In the parameter explanation, omit “The lattice parameters are specified
  below rather than estimated from historical data.”
- Explain basis points with a concrete price reference rather than introducing
  the 10⁻⁴ definition there. A basis point is not a fixed dollar amount: the
  approved prose explicitly ties its dollar value to the relevant price.

## Task 2 opening — applied September 11, 2026

The instructor approved the following replacement on September 11, 2026, and it
has been applied immediately under “## 2. Evaluate every terminal node” (cell
index 7). Continue with the helper-function explanation and comparison tables.

In this task, we will calculate the discounted fractional return at every terminal node and find the probability of exceeding our target. For each up-move count $k=0,\ldots,N$, we compute the terminal mid-price, apply the execution costs, and evaluate $\rho_N(k)$ using the cash-flow expressions from Task 1.

As in L4a, the probability of reaching terminal node $k$ is:

$$
P(K=k)=\binom{N}{k}p^k(1-p)^{N-k}.
$$

We add the probabilities of the nodes where $\rho_N(k)>\rho_\star$. Execution costs change which nodes exceed the target, while the node probabilities remain determined by the same lattice parameters. We will compare this result with the frictionless calculation by setting all execution costs to zero.

## Subsequent review items

### Current structural decision — September 11, 2026

The instructor clarified that example notebooks must have exactly three tasks
and requested a redesign before continuing the pending Task 4 prose. This
requirement is recorded in the shared style guide. The instructor approved the
organization below and it has been applied:

1. Specify the executable cash flows (original Task 1).
2. Calculate and verify the target probability (original Tasks 2 and 3, as
   subsections for node evaluation/comparison and threshold derivation/check).
3. Examine how trading assumptions affect the probability (original Tasks 4 and
   5, with subsections for cost components, target-return sweep, and benchmark
   and holding-period sensitivity).

Model Limitations is now an unnumbered section, followed by Summary and the
existing disclaimer. Approved derivations and prose are preserved, with task
openings and internal references adjusted to fit the grouping. Code order and
outputs are unchanged. Each task has descriptive level-three subsections, and
major sections are separated by the standard rule. The threshold function's
local documentation now identifies its location in Task 2. Resume the prose
review at Summary and the three key takeaways. Model Limitations was approved,
lightly tightened (about 5%), and applied. It now covers constant execution
costs, fixed one-step lattice parameters across horizons, and the possibility
that node- or path-dependent costs require more than one up-move cutoff.
Task 3's benchmark growth-rate and holding-period
table introduction and interpretation have been approved and applied. The
introduction includes the bold opening question, rates and horizons, and fixed
4% target. The interpretation was tightened by roughly 20% at the instructor's
request, preserving the contrasting numerical examples and parameter reminder.
The cost-components introduction and table
interpretation have been approved and applied, explaining the cumulative cost
scenarios and why lower node returns need not change the probability. The target
plot's introduction and interpretation are also approved and applied: the opening
question is bold, the redundant “So far” sentence and plateau sentence were
removed. The figure uses right-continuous steps with every calculated node return
inside the plotted range included in `target_grid`, and the y-axis reads
“Probability of exceeding target.” Its stored image was refreshed. All notebook
code cells ran successfully in Julia; targeted checks passed for jump locations,
strict equality, plateau probabilities, monotonicity, and cost ordering. Other
stored outputs were preserved. Next review the Summary and takeaways.
Earlier references below
to Tasks 3–5 describe the old structure.

After Task 2's opening, connect the calculation to the locally
defined terminal_outcomes helper and explain the comparison and boundary-node
tables. The shared style guide requires local function documentation under the
notebook's docs/ directory when introducing a local helper in prose; create and
link the relevant reference when that portion is applied. A reference has been
prepared at `advanced/execution/docs/terminal-outcomes.md` relative to L4a;
the explanatory notebook passage introducing the helper and the paragraph before
the comparison cell were approved and applied on September 11, 2026. The helper
reference is linked from the notebook. The comparison-table interpretation,
boundary-table introduction, and boundary-node interpretation were also approved
and applied on September 11, 2026. The question “Why does one additional up move
make such a difference?” is bold, as explicitly requested. Task 3's opening
and the derivation of the terminal mid-price threshold were approved and applied
on September 11, 2026, with the final result boxed and followed by
`\quad\blacksquare`, as requested. The conversion from the terminal-price
threshold to the minimum successful integer up-move count was then approved and
applied, including the logarithm steps, boxed real threshold, strict-integer
examples, and attainable-count bounds. The numerical threshold helper explanation
and its result interpretation were approved and applied, including the sentence
“These values reflect the parameters above; your results may differ if you change
them.” Next: Task 4's introduction to the cumulative spread, fees, and slippage
scenarios, followed by interpretation of the component table and target plot.
Those revisions remain pending. A local
reference is prepared at `advanced/execution/docs/analytic-execution-threshold.md`
relative to L4a. The helper calculates the price and real count thresholds
analytically but determines `k_min` by scanning the same computed-return
comparison as Task 2. Avoid claiming this eliminates floating-point errors.
The notebook now has additional Markdown cells `ex-cases-intro`,
`ex-comparison-interpretation`, and `ex-boundary-interpretation`; use cell IDs to
locate subsequent cells rather than relying on old numeric indices.

Remaining sections are the analytic threshold, cost components, benchmark and
holding-period sensitivity, limitations, and Summary/key takeaways. They remain
unreviewed interactively. Task openings should follow the shared convention;
takeaways must be exactly three retrospective explanations in the instructor's
voice. Review terminal-target wording carefully: the variable named
probability_of_profit sums probabilities above the selected target, which is
4% in the default example, rather than merely above zero.

Stored default results that will help interpret Task 2: frictionless cutoff
10 up moves and probability 0.656841; execution-aware cutoff 11 and probability
0.483443. Execution-aware initial outlay is 10026.50 USD; the return at 10 up
moves is approximately 0.039161, below the strict 0.04 target. Existing comparison
tables truncate important columns in their stored text display; consider their
readability during that review. These are existing outputs, not a fresh run.
