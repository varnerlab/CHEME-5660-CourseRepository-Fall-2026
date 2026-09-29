# Nomenclature reference: independent clarity review

Date: September 29, 2026

The instructor requested an early-to-late lecture sequence, reuse of existing
course figures only, and an independent Claude assessment of whether the reference
would help students with the largest engagement-survey themes.

## Outcome

Claude's first verdict was **“needs targeted revision.”** It identified skipped
reasoning in replication, the drift comparison, and the EMA variance update, plus
a confusing choice of growth-rate scale in the CAL example. The revisions address
all ten findings below. Claude's second verdict was **“ready for instructor
review.”** Both complete responses are preserved below.

This is an editorial assessment, not evidence of measured improvement in student
learning. Claude reviewed notebook text and the feedback-theme brief. It did not
inspect the rendered PDF or original lecture notebooks. Codex separately checked
rendering, links, course-source references, and figure provenance.

## How the reference addresses the largest themes

The counts describe submissions requesting clarification; themes overlap. They are
not counts of unique students or measurements of misunderstanding.

| Feedback theme | Requests | Student-facing explanation |
|---|---:|---|
| Model purpose and limits | 51 | L4b translates a trade target into a price threshold and probability, varies an input, and explains how to evaluate later outcomes. |
| Forecasting versus pricing | 46 | L3b asks two questions of the same two future prices, derives the replicating position, and separates the forecast probability from the pricing weight. |
| Correlated shocks | 41 | L5b expands the loading-matrix product into two scalar equations, identifies the shared random input, and checks covariance and time units. |
| Volatility clustering | 39 | L3a uses the lecture's original SPY/AMD figure to distinguish a turbulent sequence from one isolated jump and explains what magnitude autocorrelation measures. |
| Mean growth versus drift | 37 | L4b compares average price with average log growth, develops the half-variance correction, and explains which parameter enters a simulation. |
| Equations and notation | 37 | Each displayed calculation has a question, intermediate reasoning, and interpretation; tables and a context index retain the lookup function. |

The conceptual sections include a changed-example check and answer. The reference
now follows L1b through L6b; the opening guide points to those sections in lecture
order. Within L4b, GBM leads to the trade application, then its notation and general
threshold, then regression uncertainty.

## Disposition of the first review

| Finding | Change |
|---|---|
| CAL growth-rate scale invites confusion with diffusion volatility | Uses a daily observation interval and a growth-rate standard deviation of 3.0 per year; the allocation examples give 1.5 and 4.5 per year. |
| Replicating share and loan amounts appear without derivation | Derives two-thirds of a share from payoff change divided by price change, then the loan from the down-state share value. |
| GBM expectation chain changes parameters without an explanation | Introduces the expected-price relation before averaging the log-price solution and compares the two expressions in words. |
| A 1% daily price change produces an unexplained large annual-scale growth rate | Explains division by a small fraction of a year and separates an observed daily rate from a forecast. |
| EMA variance update skips recentering | Names the squared-shift identity, substitutes the two deviations, and collects the terms explicitly. |
| Regression interrupts the L4b concept-to-application progression | Moves regression uncertainty after the target-probability application and notation table. |
| “Different scoring event” is jargon | Explains checking one future date versus requiring every observed point on a path to remain within a band. |
| Context index omits reused symbols | Adds tau, nu, X, and c with their different contexts. |
| Design-matrix hat exception is repeated | Retains the explanation once in the notation-reading table. |
| Annualized volatility is disconnected from GBM notation | Identifies the annualized volatility as the GBM diffusion volatility under the stated scaling assumption. |

## Follow-up review and final checks

The follow-up found no substantive repair remaining. After that review, four small
clarifications addressed its residual observations: an explicit mean equation for
expected GBM price, a link from the GBM explanation to its notation table, context
index entries for D and n, and explicit labeling of the 3.1749-to-0.20 conversion
as illustrative. These final edits were checked by Codex and were not sent for a
third Claude pass.

Claude's remaining source-verification questions were resolved as follows:

- The [L5a out-of-sample example](../week-5/L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb),
  Task 2, explicitly distinguishes pointwise prediction probabilities from the
  probability that an entire path stays within a band. Task 3 explains the maximum
  standardized deviation and dependence between dates.
- The [L5a EMA example](../week-5/L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb),
  Tasks 1 and 2, explicitly holds each forecast's parameters fixed over its horizon.
- The value 3.1749 is an illustrative conversion, not an empirical estimate:
  0.20 times the square root of 252 is approximately 3.1749. The final reference
  now labels it accordingly.

Codex validated notebook schema, lecture order, all internal notebook and PDF
links, the worked arithmetic affected by the revisions, and the 23-page PDF.
Rendered PDF pages and notebook HTML were visually inspected. The PDF build
reported no overfull boxes or missing characters. All 12 lecture-source hashes
in the reference's manifest still match the course repository.

The sole figure is an unmodified copy of the L3a volatility-clustering figure.
Both SVG and PDF copies match the original course files byte for byte. The earlier
custom SPY-versus-simulated-GBM chart and its generator were removed from the
reference. Figure hashes are in
[figure-provenance.json](../reference/figs/figure-provenance.json).

The reference remains long and table-heavy. Claude considered that acceptable for
lookup using the theme links; the L4a table still includes m-ary symbols beyond the
worked binomial explanation.

## Review provenance

The independent reviews used the installed Claude CLI with tools and MCP disabled,
no Chrome integration, no session persistence, and high effort. The first prompt
requested a critical assessment of clarity, correctness, feedback-theme coverage,
and potential harm to student understanding. The second supplied the first review
and revised text and requested a fresh recheck without a leading change list.

- Model identifier returned by both calls: `claude-fable-5-1`.
- First reviewed notebook SHA-256: `50a3bfac11c87a83f63bda381c7fb85252d93b5d260c616f9afdc4f720ab54cb`.
- Second reviewed notebook SHA-256: `c42fa8c692c2a334aad762087ec15bedd63a17a6daa7445703defb1cc1fb3a39`.
- Final notebook SHA-256, including the four small follow-up clarifications: `f8fd9bc05ed9d498d893fa9f1a1612f4c6be217d862a628d6c206412f55d9e86`.
- First raw response SHA-256: `e34a752206904ea4b697fcc0abfa4f82b1c6cd11f9b9b1b1b1efa93e18f3878b`.
- Second raw response SHA-256: `e00567d1afb20372ef61a532152b2d255faac487968912d68c9f87cb2cb60f94`.

The prompts, input snapshots, and raw responses are retained in the survey workspace
at `tmp/nomenclature-revision-lecture-order/review/`. The following review text is
verbatim; statements about what the reviewer could not verify describe its own
review scope at that time.

---

## First Claude response (verbatim)

**Verdict: needs targeted revision.** The mathematics is correct throughout. I reworked every numerical example by hand, including the bill price, the duration approximation, the replicating portfolio, the binomial node probability, the half-variance correction, the scaled-NPV probabilities, the EMA variance identity, the two-asset loading matrix and price step, the GMV weights, the frontier units, and the capital allocation line. None contain errors. The question-led structure, the single L3a figure, and the short checks with answers are the right design for a reference that students consult after a lecture. A struggling student who reads a single section will come away able to compute a growth rate in course units, tell a forecast probability from a pricing weight, explain why estimating mean growth from data already includes the half-variance correction, and see where covariance comes from in a two-asset simulation. Those are real gains.

What still hurts is a handful of skipped intermediate steps in exactly the places the feedback asked for reasoning, one numerical example whose scale undercuts the units lesson taught earlier, and an ordering problem inside L4b. None require redesign. The document is long and table-heavy, but that is tolerable for lookup because the theme links at the top route students to the section they need.

## Assessment by feedback theme

- **Model purpose and limits (L4b "What can a price model help us decide?").** Correct. The derivation from target to threshold price to standardized threshold to probability is complete and interpretable, and the "How much should we trust the answer?" paragraph is the strongest treatment of limits in the draft. Two weaknesses. It sits after the regression section, so a student following L4b in order takes a detour through least squares before reaching the section the survey theme points to. The phrase "different scoring event" is jargon that a struggling student will not decode.
- **Forecasting versus pricing (L3b).** Correct and the clearest section in the draft. Holding the two prices fixed while changing only the question is exactly the right move, and the check confirms it. The one gap is that the replicating position appears from nowhere: "Buy 2/3 of a share and borrow 60/1.02 USD" is verified but never derived. A student who could not find those numbers will read the verification as magic.
- **Correlated shocks (L5b).** Correct and concrete. Expanding the matrix product into two scalar equations, naming the shared input, and showing one draw with opposite signs is effective. The follow-up notation cell handles covariance scaling well, including the daily-growth versus daily-log-return distinction. Likely to help.
- **Volatility clustering (L3a).** Correct, and the figure is used well to separate a cluster from a jump. The autocorrelation explanation is adequate. The weak spot is the worked growth rate: a one-percent daily move becomes a rate above two per year, and the only gloss is "This expresses a one-day observation per unit time." That sentence does not tell a student why the number is large or that it is supposed to be. Since the same student later meets a daily growth standard deviation above three next to a diffusion volatility of one fifth, this is the place to build that intuition.
- **Mean growth versus drift (L4b GBM).** Correct, and the paragraph on which number belongs in a simulation is the most practically useful passage in the document. The gap is the chain ending in "$=S_0e^{\mu T}$". That equality is the definition of drift, not a derived step, but it is typeset as the last step of a computation. A student will ask how the exponent changed from mean growth plus half variance to drift, and the text answers only "Matching the two price-growth expressions", which presumes they already know drift is defined by the expected price.
- **Equations and notation (Reading the Notation, tables, context index).** Correct. "Read an expression as a calculation" and "Separate inputs from outputs" are helpful framing. The tables are complete for lookup but long; the L4a table carries m-ary lattice symbols the worked explanation never uses. The context index omits several collisions that are at least as confusing as the ones listed, notably $\tau$ as lag, up-count threshold, and reference year, and $\nu$ as cash-flow direction, Student-t degrees of freedom, and residual degrees of freedom.

The secondary difficulties are handled: covariance scaling in the L5b notation cell, lattice construction in the two-step example, estimation uncertainty in the regression cell and the trust paragraph, portfolio weights in the buy-and-hold wealth example.

## Prioritized problems

1. **L6b Capital Allocation Line, the numerical example. Should fix before release.** The example sets a growth-rate standard deviation of 0.20 with units of inverse years. The value is labeled correctly, but the L3a notation cell has just taught that daily data give a growth standard deviation near three inverse years, which corresponds to a diffusion volatility of 0.20 per root year. Reusing 0.20 here, with the other unit, invites a student to conclude the two quantities are interchangeable after all. The annualized Sharpe ratio scaling in the same table makes the mismatch visible to anyone who tries it. Repair: either state that the example uses a one-year observation interval so that growth-rate and diffusion scales coincide numerically, or use a daily-scale standard deviation and let the annualization row do its job.
2. **L3b "Why is that the price?". High priority, not blocking.** The hedge ratio and loan size are asserted. Add two sentences deriving two thirds from the payoff difference over the price difference, and the loan from the down-state share value. Wording below.
3. **L4b GBM, the expectation chain. High priority, not blocking.** Insert the definition of drift before the chain so that "$=S_0e^{\mu T}$" reads as a comparison rather than a computation. Wording below.
4. **L3a, the worked growth rate. High priority, not blocking.** Replace "This expresses a one-day observation per unit time" with an explanation of why daily growth rates are large and what the number means. Wording below.
5. **L5a "Why is the variance update different?". Medium.** The first form of the update is presented as obvious. It rests on the identity that mean squared deviation about a new center equals the old variance plus the squared shift of the center. Name that identity in one sentence, then note that the second form follows from $m_k-m_{k-1}=(1-\lambda)\delta_k$ and $g_k-m_k=\lambda\delta_k$. Without this, the section reproduces the missing-intermediate-reasoning pattern the survey complained about.
6. **L4b ordering. Medium.** Move the "What can a price model help us decide?" cell to follow the GBM cell and its notation table, and place the regression cell after it. The general scaled-NPV threshold in the GBM notation table currently forward-references "the worked trade example later in this L4b section" three cells ahead. After the move, that reference becomes a backward one and the two derivations reinforce rather than duplicate each other.
7. **L4b "What can a price model help us decide?", trust paragraph. Optional.** Replace "has a different scoring event from a band that must contain an entire path" with plain language: an interval checked at one date is right or wrong once, while a band around a whole path fails if any single day escapes it.
8. **Context index. Optional.** Add rows for $\tau$, $\nu$, $X$, and $c$. The index says it collects common collisions, so this is a completeness improvement rather than an error.
9. **Reading the Notation. Optional.** The exception for the augmented design matrix appears twice in the same cell. Keep one.
10. **L3a notation table. Optional.** The annualized volatility entry defines the same quantity that L4b calls diffusion volatility. Adding "this is the GBM volatility $\sigma$ of L4b" to that row closes a loop a struggling student may not close alone.

I found no places where the draft is mathematically wrong, no invented denials beyond the two in L3b and L5b, both of which answer misreadings students genuinely make, and no cases where a check answer disagrees with the text.

## Proposed wording for the three most consequential repairs

**L3a, replacing the sentence after the worked growth rate.**

> A change from 100 to 101 USD/share over $1/252$ year gives a log return $\ln(1.01)\approx0.00995$ and a growth rate $252\ln(1.01)\approx2.508\,\mathrm{yr}^{-1}$. The rate is large because we divide a small one-day change by a small fraction of a year. It answers the question: if every trading day looked like this one, how much would the log price grow in a year? Daily growth rates are therefore large in magnitude, and their standard deviation $\sigma_g$ is large as well. The diffusion volatility $\sigma$ that we meet in L4b is on a different scale; the notation table below shows how the two are related.

**L3b, replacing the opening of "Why is that the price?".**

> **Why is that the price?** We can build the claim's payoff from the share and a loan. Between the two states the claim's payoff changes by $H_u-H_d=20$ USD while the share price changes by $120-90=30$ USD, so holding $20/30=2/3$ of a share reproduces the change in the payoff. In the down state, $2/3$ of a share is worth 60 USD but the claim pays nothing, so we borrow the amount that will require a repayment of exactly 60 USD after one step, which is $60/1.02$ USD today. After one step the shares are worth 80 or 60 USD, and the loan repayment is 60 USD. The net payoff is therefore 20 or zero, exactly the claim's payoff. The initial cost is $100(2/3)-60/1.02\approx7.84$ USD.

The remainder of the paragraph stays as written.

**L4b GBM, replacing the text between the price equation and the expectation chain.**

> Here $W(t)$ is a Wiener process; its increment over $\Delta t$ has variance $\Delta t$. The drift is defined through the expected price. Averaging the price equation term by term, the $dW(t)$ term contributes nothing because a Wiener increment has mean zero, so the expected price grows at the constant rate $\mu$ and $\mathbb E[S_T]=S_0e^{\mu T}$. For the price itself at a fixed time $T$, we use the solution of the equation, which is written in terms of a different rate, the mean growth $\mu_g$:
>
> [existing solution equation]
>
> Notice that the exponent uses $\mu_g$ rather than $\mu$. The rest of this section explains why the two rates differ and by how much. Averaging this equation makes the random term vanish because $\mathbb E[Z]=0$. Thus $\mu_g$ is expected log growth per unit time. To average the price itself, we exponentiate first. The normal identity $\mathbb E[e^{aZ}]=e^{a^2/2}$, valid for any real number $a$, gives:
>
> [existing chain, ending at $S_0e^{(\mu_g+\sigma^2/2)T}$]
>
> Comparing this with the expected price $S_0e^{\mu T}$ yields $\mu_g=\mu-\sigma^2/2$.

Dropping "$=S_0e^{\mu T}$" from the chain and stating the comparison in words removes the appearance of an unexplained algebraic step.

## Limitations of this review

- I reviewed the notebook text only. I did not see the rendered figure, the PDF, the SVG file, or the cell layout, so I cannot confirm that the figure renders, that its axes are in the course's growth-rate units, or that the anchor links resolve.
- I did not have the lecture notebooks, so I cannot verify that every symbol and convention in the tables matches the lectures. Entries such as the annualized volatility symbol, the node function $\rho(k)$, and the use of $T$ as a count of prices in L3a are plausible but unverified against the source.
- The numerical checks were done by hand and confirm the arithmetic in the draft; they do not confirm the course's data-derived values, such as the daily growth standard deviation quoted in the L3a notation cell.
- The judgment that a passage will help or hurt is editorial. Clarification-request counts measure what students asked about, not what they misunderstand, and nothing here substitutes for asking a few struggling students to work a check problem and reporting what they got wrong.

---

## Second Claude response (verbatim)

# Assessment of the revised nomenclature reference

**Verdict: ready for instructor review.** I rechecked every changed passage and the numbers around it. No new errors appeared, and every substantive concern from my prior review is resolved in the text itself.

## 1. Status of prior concerns

- **Daily growth-rate scale (L3a): resolved.** The worked example now explains why 2.508 yr⁻¹ is large: a small change divided by a small fraction of a year. It also says what the number means, which is 252 repetitions of that day's log change. It separates recording one day from forecasting. The link to diffusion volatility is in two places: the "Growth variability versus diffusion volatility" paragraph ($3.1749/\sqrt{252}\approx0.200$ checks) and the σ_ann row.
- **CAL scale (L6b): resolved.** The example now uses σ_g,p = 3.0 yr⁻¹ with Δt = 1/252 and refers back to L3a. The mean and standard deviation values of 0.05/1.5 and 0.11/4.5 check. Daily-scale growth variability no longer sits beside a number that looks like diffusion volatility.
- **Replication (L3b): resolved.** The text now derives the hedge ratio as 20/30 and the loan as the down-state share value discounted one step. The cost of 66.67 − 58.82 ≈ 7.84 checks.
- **Drift comparison (L4b): resolved.** The definition $\mathbb E[S_T]=S_0e^{\mu T}$ now comes before the chain, the chain stops at $\mu_g+\sigma^2/2$, and the comparison is stated in words. One small gap remains: the definition is asserted as a model property. It gives no reason such as "the dW term has mean zero." The pointer to Itô's lemma in the lecture makes this acceptable, and it is not a blocker.
- **EMA reasoning (L5a): resolved.** The text names the recentering identity and gives both deviation substitutions. The algebra checks: $\lambda(1-\lambda)^2\delta^2+(1-\lambda)\lambda^2\delta^2=\lambda(1-\lambda)\delta^2$. The identity is stated rather than justified, which is adequate for a reference.
- **L4b progression: resolved.** The order is now GBM → decision → notation → regression. The scaled-NPV note correctly says "preceding," so the two derivations reinforce each other. The decision section restates the log-price solution. That is mild duplication, but it lets the section stand alone for a student arriving from the theme link.
- **Secondary items: all resolved.**
  - "Different scoring event" is replaced with plain language.
  - The duplicate design-matrix note is gone.
  - The σ_ann row now names L4b's σ.
  - The context index has rows for τ, ν, X, and c.

## 2. Remaining risk for a struggling student

Nothing I found is misleading. A few minor lookup frictions remain, and none require revision before instructor review:

- **Placement of the L4b notation table.** The table defining μ, W(t), and the simulation array now sits under the "What Can a Price Model Help Us Decide?" heading. A student who looks up drift from the GBM section has to scroll past the decision example. One option is a single pointer sentence at the end of the GBM cell.
- **Collisions still missing from the context index.** Two are about as confusing as the ones already listed:
  - $n$: compounding frequency in yr⁻¹, tail sample size, and regression count.
  - $D$: days to maturity, spot discount factor, the observed down-multiplier set, and $\mathbf D_g$.
  
  Adding them is optional.
- **Unused L4a symbols.** The L4a table still carries m-ary lattice symbols that the worked explanation never uses. This is tolerable in a lookup table.
- **Length.** The document is still long and table-heavy. For a reference entered through theme links, it is not overwhelming.

The sentence "Here, we use the per-year scale to record one observed day" is slightly stiff. It is not unclear, so I would leave the instructor's phrasing alone.

## 3. Readiness

No substantive repair remains. The document keeps the L1b–L6b sequence, reuses only the L3a figure, preserves the course's growth-rate notation ($g$, $g'$, $\mu_g$, $\sigma_g$ against $\sigma$), and stays within reference scope. It does not become a replacement lecture.

## Limits of this review

- I reviewed the text only. I did not examine rendering, anchors, or the figure file.
- I could not confirm several cross-references against the lecture notebooks:
  - that "the L5a out-of-sample example" exists and develops the date-versus-path distinction;
  - that the course EMA example holds estimates fixed over each horizon;
  - that the data value σ_g ≈ 3.1749 yr⁻¹ is correct.
  
  The instructor should spot-check these.
- My judgments about what will help students are editorial, not measured.
