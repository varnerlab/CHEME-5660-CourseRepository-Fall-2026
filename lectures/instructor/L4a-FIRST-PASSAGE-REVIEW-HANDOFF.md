# L4a first-passage example — paused interactive review

Saved September 11, 2026 at Jeffrey's request. Stop here until he returns.

## Active notebook and working agreement

[First-passage exit rules](../week-4/L4a/advanced/first-passage/CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb).

Jeffrey requested an **interactive review**, concerned that the theoretical details
were omitted from the lecture. Develop enough theory here for the example to stand
on its own. Propose one concrete issue at a time, wait for approval, apply it, and
show the next issue. Do not implement the pending proposal below until approved.
Do not restart completed sections or reopen the closed L4a lecture.

Follow [the shared notebook style guide](NOTEBOOK-STYLE-GUIDE.md). Preserve the
modern 2026 notation, teaching voice, and explanatory steps. Exactly three
learning objectives and three retrospective key takeaways. **No blank lines or
standalone `>` lines between objective bullets**; Jeffrey corrected this twice.

Other notebooks have separate review records. In particular, the N-ary narrative
review is complete and its obsolete issue file was deleted on explicit instruction.
Do not recreate it. Preserve concurrent changes in other notebooks and AGENTS.md.

## Approved edits already applied

- **Introduction:** Replaced the abstract phrase “an earlier boundary crossing can
  determine the outcome” with a concrete missed-exit explanation: checking only
  the final price can miss a sale that should have occurred when the price reached
  the profit target and subsequently fell below it. After the objectives, the
  approved “In this example…” paragraph promises to develop the probability
  calculation before implementation, then compare with a terminal-only rule.
- **Objectives:** Three adjacent bullets: define a monitored exit rule; compute
  probabilities of the first exit; compare monitored and terminal-only rules.
  The second briefly defines *first-passage time* as the first time the price
  reaches an exit boundary. Jeffrey finds unexplained “first-passage” and
  “propagate surviving probability” difficult; introduce ideas in plain language.
- **Setup:** Standard heading, local Include.jl introduction, labeled Include
  callout and Julia function link, “Let's set up our code environment:”, existing
  include cell, then concise Julia/DataFrames/Distributions/Plots documentation
  links. Removed repeated package narration and premature “real-world probability
  measure” wording.
- **Task 1:** Renamed “Task 1: Define the monitored exit rule,” with a major-section
  rule immediately before it. Defines independent fixed binomial factors and p,
  j steps, k up moves, and `S_{j,k}=S_0 u^k d^(j-k)`. Specifies `L<S_0<U`, checks
  only positions still held, sells at or beyond either boundary, and records
  neither boundary reached by N as still open. Approved opening: “In this task,
  we specify when to sell our shares: when the price reaches our take-profit
  boundary or falls to our stop-loss boundary.” Rejected “which outcomes we want
  to calculate.” Replaced “Equality triggers an exit” with “We also sell when the
  price equals either boundary exactly. Once we sell, we stop monitoring that
  position.” Parameter code unchanged.
- **Worked example:** Inserted after the parameter cell, under H3 “Why can a
  terminal check miss an exit?” Uses S0=100, u=1.06, d=0.97, L=90, U=115:

  | Moves | Step 0 | Step 1 | Step 2 | Step 3 | Step 4 | Step 5 |
  |---|---:|---:|---:|---:|---:|---:|
  | Up, up, up, down, down | 100.00 | 106.00 | 112.36 | **119.10** | 115.53 | 112.06 |
  | Down, down, up, up, up | 100.00 | 97.00 | 94.09 | 99.74 | 105.72 | 112.06 |

  Both paths have three up moves and two down moves. First sells at step 3;
  subsequent prices describe the stock after sale. Second remains open through
  step 5. Checking only step 5 misses the first path's earlier exit. This is a
  five-step illustration, not a change to default N=12. Independently checked
  arithmetic and exit histories in Python; inspected the rendered table.
- **Task 2 opening:** Renamed “Task 2: Calculate the probabilities of the first
  exit,” with a major-section rule. Explicitly defines **open** as still holding
  the shares because neither boundary has been reached, and **closed** as sold.
  Opening states the probabilities sought in concrete terms: selling at the
  take-profit boundary first, selling at the stop-loss boundary first, or still
  holding after N steps. Defines `a_{j,k}` as the joint probability of k up moves
  and a position still open **after checking the boundaries at step j**. Already
  exited paths contribute nothing. Initializes `a_{0,0}=1` and explains that
  `sum_{k=0}^j a_{j,k}=P(position remains open after step j)` can be below one.
  Ends by inviting the next-step update. This opening is **applied**, not pending.
  Equations were rendered and visually checked.

## Exact pending proposal — NOT approved or applied

The assistant proposed the following addition **before the original helper
function cell**. Jeffrey then said “save state - I have to take off.” Resume by
reviewing this proposal, not by applying it silently:

### Move to the next lattice step

Suppose the position is open after step $j-1$. There are two ways to arrive at node $(j,k)$:

- An up move from $(j-1,k-1)$ increases the up-move count to $k$.
- A down move from $(j-1,k)$ leaves the up-move count unchanged.

Multiplying each open-node probability by its next-move probability and adding the two contributions gives:

$$
b_{j,k}=p\,a_{j-1,k-1}+(1-p)a_{j-1,k}.
$$

Here, $b_{j,k}$ is the probability of arriving at this node **before checking its price against the exit boundaries**. Only positions still open at the previous step contribute. At the edges of the lattice, a missing predecessor contributes zero.

Now check the price $S_{j,k}$. If it lies strictly between the boundaries, we continue holding the shares. Otherwise, we sell:

$$
a_{j,k}=\begin{cases}
b_{j,k}, & L<S_{j,k}<U,\\
0, & S_{j,k}\le L\ \text{or}\ S_{j,k}\ge U.
\end{cases}
$$

When we sell, we record $b_{j,k}$ as the probability of a new stop-loss or take-profit exit at step $j$. That probability is not carried forward to another step.

## Remaining review work

- After the pending derivation, explain sums over nodes and steps for each exit
  side and conservation: cumulative lower exits + cumulative upper exits + open
  probability = 1. Not yet drafted or approved. Avoid jumping directly into code.
- Review helper documentation, comments, summary tables, and figure interpretation.
  Local helper function references need local docs links; none created yet here.
- Review terminal-only comparison and later exhaustive path-history demonstration.
  Assess any redundancy with the new worked example interactively; do not delete
  the later section without approval.
- Review remaining task headings/major-section rules and rewrite terse existing
  key takeaways in the approved retrospective voice. These are not revised yet.
- Execute/check the notebook when appropriate. **No full execution or independent
  algorithm audit of this first-passage notebook has been performed in this review.**
  Changes so far are Markdown only, including one inserted cell; code and outputs
  are preserved. Notebook schema validated with nbformat.

## Implementation context

Current notebook has 20 cells. Zero-based indices (verify after any hand edits):
0 intro/objectives; 1–4 setup; 5 Task 1; 6 parameters; 7 new worked example;
8 Task 2 opening; 9 original helper code; later cells unchanged.

Defaults: S0=100, u=1.06, d=0.97, p=0.55, N=12, L=90, U=115.
Local Include.jl finds/activates the course project, instantiates, imports
DataFrames, Distributions, and Plots. It does not currently import PrettyTables.

- `price_at(S₀,u,d,j,k)` computes the binomial node price.
- `first_passage_binomial(...; lower,upper)` propagates only open probabilities,
  tests destination prices inclusively, and returns per-step summaries, terminal
  open vector, cumulative lower/upper exit probabilities, and still-open probability.
  It checks conservation each step. Julia position k+1 represents up count k.
  Code sends each incoming contribution separately and checks the common node
  price; this is equivalent to summing into b before testing that price.
- `terminal_upper_probability(...)` directly checks binomial terminal node prices.
  Comparison disables the lower barrier with `lower=0.0`. Hitting-by-N is at least
  terminal-at-or-above-U probability in that upper-only case; do not claim this
  inequality when both exit boundaries are active.
- `enumerate_exit_histories(...)` enumerates 2^N paths and records first exit while
  continuing the underlying stock price to N. Groups by up count to show differing
  exit histories at shared terminal nodes. Post-sale stock prices are hypothetical
  for the closed position, not prices at which it is sold again.

The notebook computes exit probabilities, not discounting or realized payoffs.
Fixed price boundaries are illustrative; do not identify them with the lecture's
discounted-NPV thresholds without deriving that connection.

## Temporary previews

- `/private/tmp/first-passage-worked-example.html` and `.png`.
- `/private/tmp/first-passage-open-probability.html` and `.png`.

Anaconda Python nbformat/HTMLExporter exported selected cells. Playwright confirmed
math/table rendering. Chromium requires execution outside the sandbox on this
machine; the initial sandboxed screenshot failed with a macOS permission error,
then succeeded with escalation. Temporary files may disappear; this handoff is
the durable record. AGENTS.md links here, and CLAUDE.md instructs Claude to read it.
