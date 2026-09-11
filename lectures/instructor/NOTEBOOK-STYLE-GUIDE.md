# Course notebook voice and formatting

Recorded with Jeffrey Varner on September 10, 2026. Shared guidance for CHEME 5660
and CHEME 5800 Fall 2026, for both Codex and Claude.

## The decision

Write rigorous, formal course materials in the instructor's teaching voice, with
enough explanation for students to follow the reasoning independently. Preserve
the explanation of what we are doing, why we are doing it, how the mathematics
works, and what we learn from the result. Use formatting to make that progression
visible.

The instructor requested a complete reset after repeated formatting and narrative
reviews produced hard-to-read CHEME 5660 material and substantial manual rework.
His revised 2026 L4a notebook contains work to preserve; it is not an untouched
assistant draft or an approved final style exemplar. Do not infer authorship of
individual passages from the current file.

The slide workflow is working well. This reset concerns notebooks and does not
authorize changes to slide style or production. A notebook must carry explanations
that a slide can leave to the instructor's spoken presentation.

This guide replaces older notebook voice and formatting prescriptions for these
two courses, including conflicting instructions in historical CLAUDE.md files,
notebook-style skills, canon.md files, and old review checklists. Do not run legacy
style auto-fix scripts or rewrite to satisfy their findings without first updating
their rules to this agreement. Preserve unrelated course requirements, technical
correctness checks, lab design, and release procedures. Current explicit user
instructions take precedence.

## Reference style

CHEME 5660 Fall 2025 and CHEME 5820 Spring 2026 share the desired teaching voice.
5820 develops that voice with more explicit mathematical organization; 5660 2025
remains a valuable reference for financial scenarios and patient derivations.
Do not describe the older course as merely informal or treat the newer course as
a mandatory template for every subject.

Reference roots on the instructor's computer:

- **5660 Fall 2025:** `/Users/jeffreyvarner/Desktop/julia_work/CHEME-5660-Fall-2025/CHEME-5660-CourseRepository-Fall-2025`
- **5820 Spring 2026:** `/Users/jeffreyvarner/Desktop/julia_work/CHEME-5820-instances/Spring-2026/CHEME-5820-Lectures-Spring-2026`

Before a substantive notebook edit, read the relevant original course material and
one reference passage appropriate to the task. These specific passages were
discussed during the reset:

| Reference, relative to its course root | What to learn from it |
| --- | --- |
| 5660: `lectures/week-5/L5a/CHEME-5660-L5a-Lecture-LatticeModel-TradeRule-Fall-2025.ipynb`, NPV discussion | Introduce the trade, connect it to abstract assets, derive the return, explain its meaning, and develop short and long holding periods. |
| 5660: `lectures/week-7/L7b/CHEME-5660-L7b-Lecture-SIM-Fall-2025.ipynb`, parameter interpretation | Develop a model's meaning through annotated variance and covariance calculations and explanatory prose. |
| 5820: `lectures/week-2/L2a/CHEME-5820-L2a-Lecture-Eigendecomposition-Power-Spring-2026.ipynb`, power iteration | Give mathematical work an explicit sequence: eigenvector, eigenvalue, initialization, iteration, and stopping conditions. |
| 5820: `lectures/week-4/L4c/CHEME-5820-L4c-Lecture-KernelFunctions-Spring-2026.ipynb`, quadratic kernel | Expand a concrete expression, construct the feature map, work through the inner product, and interpret the result. |
| 5820: `lectures/week-6/L6a/CHEME-5820-L6a-Lecture-Classical-HopfieldNetworks-Spring-2026.ipynb`, convergence and retrieval | Prepare students for formal results and explain which question each theorem addresses. |
| 5820: `lectures/week-2/L2a/CHEME-5820-L2a-Example-FunWithPowerIteration-Spring-2026.ipynb`, covariance task | Explain why a computation is needed, connect notation to code, and verify the result. |

For example, the power-iteration example asks “Why are we doing this?” and explains
that the stoichiometric matrix is not square before introducing the covariance
construction. The kernel lecture explicitly expands a quadratic kernel and shows
its feature map. These are examples of explanatory work that tightening must
preserve.

The instructor endorsed the courses as style references. The passages above are
assistant-selected examples of that style, not individual certifications of
mathematical correctness. Verify the mathematics when adapting them. Reference
notebooks also contain incidental formatting inconsistencies; do not copy those
as requirements. If a reference root is unavailable, use this guide and report the
limitation rather than asking the instructor to repeat the style discussion.

## Writing and mathematical exposition

- Preserve the current course's standardized 2026 notation. The instructor
  explicitly endorsed the notation updates as a successful part of the
  collaboration. Historical notebooks are references for voice and exposition;
  do not restore their older symbols or conventions while adapting their prose
  or derivations. Use the current 2026 lecture and its prerequisite notebooks to
  resolve notation, and keep prose, equations, figures, and code consistent with
  those conventions. Do not impose one course's symbols on another course.
- Preserve the scenario, motivation, intermediate reasoning, interpretation, and
  transitions that make a section teachable. A shorter paragraph is not inherently
  clearer. Purposeful repetition can reconnect notation with its meaning.
- Once the voice and development are working, tighten repeated explanations,
  transitions that merely repeat headings, and narration of obvious steps. The
  instructor endorsed the conversational voice but found parts of the revised
  N-ary section too wordy. However, the subsequent pass removing roughly one third
  of its prose was explicitly rejected as too large a cut and was reverted.
  Keep the fuller version as the baseline. Any future tightening should be modest,
  localized sentence edits, not a section-wide reduction target. Preserve the
  worked examples, mathematical steps, and explanatory pacing; keeping equations
  intact alone does not mean that the teaching explanation has been preserved.
- Use direct, accessible sentences. “Suppose,” “Let's,” and questions such as “Why
  is this interesting?” belong when they guide the reasoning. Preserve the
  instructor's natural enthusiasm without adding stock exclamations to imitate it.
- Introduce quantities, dimensions, indexing conventions, and assumptions where
  readers need them. Explain mathematical operations and interpret the resulting
  expressions. Precision must remain understandable in context.
- Definitions, theorems, and long blockquotes are welcome when they have a clear
  teaching role. Prepare the reader and connect formal results with prose. Do not
  collect motivation, assumptions, derivation, every edge case, implementation
  advice, and interpretation into one block merely to make it self-contained.
- Retain intermediate algebra that helps students learn. A formal statement may
  precede or follow a derivation according to the lesson; there is no universal
  requirement that every section follow an identical sequence.
- Keep assumptions and limitations needed to interpret the main result in the
  lecture. Place deeper proofs, extensions, and implementation details deliberately;
  do not automatically expand the lecture or move essential explanation elsewhere.
- In computational notebooks, explain the task and its purpose, connect the
  mathematical objects to the functions and variables used, and interpret or check
  meaningful outputs. Choose transitions for the actual computation rather than
  inserting a stock sentence before every cell.

## Formatting

Use the shared visual vocabulary of the reference courses: descriptive headings,
subsections that develop ideas, labeled blockquotes, selective emphasis, displayed
and annotated equations, figures, and linked examples. Ordinary prose connects
these elements. Formatting supports the explanation; it does not determine its
length or force every passage into a blockquote.

For lecture and example notebooks:

- Include exactly three learning objectives and exactly three key takeaways,
  supported by the notebook's actual content. Use the familiar blockquoted panels
  with bold item labels and explanatory text.
- Use `___` only at major-section boundaries immediately before a new level-two
  heading. Do not put it between level-three subsections or after the final section.
- Use a descriptive title and introduction, an appropriate section hierarchy, and
  a closing Summary. Computational notebooks need useful setup and task guidance;
  a conceptual lecture does not need an artificial setup or task structure.
- Check the rendered result when changing layout or mathematics, especially long
  equations, blockquotes, figures, and section boundaries. Source-level checks alone
  do not establish readability.

Do not turn the reference notebooks into a growing catalogue of mandatory phrases,
punctuation rewrites, bans on ordinary teaching language, or fixed paragraph lengths.

For tables, the instructor prefers compact, restrained formatting. The first
decorative HTML-table treatment in L4a was rejected as too large and overdesigned:
avoid badges, shadows, rounded card frames, and excessive padding. Preserve readable
type and clear alignment. Simple notation in raw HTML tables should use HTML
italics, subscripts, and bold vectors rather than relying on LaTeX rendering there.

## Key takeaway voice — all courses

On September 10, 2026, the instructor explicitly approved this preference for
all his courses, for both Codex and Claude. The broader guide was established
for CHEME 5660 and CHEME 5800; this takeaway preference is course-independent.

Use a short, descriptive bold topic label followed by a retrospective account
of what we developed and why it matters. Write in the instructor's shared
teaching voice: “We derived…”, “We used…”, “We generalized…”, followed naturally
by what the result allowed us to explain, calculate, or compare. These are
examples of the voice, not mandatory sentence starters for every item.

Preserve enough explanation to reconnect the method, result, and purpose.
Do not compress takeaways into abstract slogans such as “A terminal target
determines which lattice nodes count as successes.” The instructor rejected
that proposed style as unclear and unlike his voice. Takeaways summarize the
work completed; learning objectives describe what students will be able to do.
Keep the three main takeaways aligned with the material actually developed.
Use current course notation and correct technical scope when adapting an older
summary. Do not carry forward obsolete claims merely to preserve its wording.

The approved L4a calibration is:

> __Key Takeaways__
>
> * **NPV-based trading framework**: We derived an expression for the net present value of a long stock position and scaled it by the initial investment to obtain a dimensionless discounted fractional return. This allowed us to account for the holding period and compare the present value of the sale proceeds with the purchase cost.
>
> * **Cumulative probability calculations for terminal targets**: We used the binomial lattice to compute the probability of exceeding a target scaled NPV at a scheduled sale time. We derived the minimum number of up moves needed to exceed the target and added the probabilities of the corresponding terminal nodes. The complementary probability describes finishing at or below the target.
>
> * **Extension to N-ary lattice models**: We generalized the binomial framework to allow $m$ possible price movements at each step. We used branch counts to calculate node prices and multinomial probabilities, and derived an expression for the number of states at each level. This gives us more flexibility in representing price movements, at the expense of additional computational cost.

The instructor's 2025 L5a takeaways supplied the structure and voice; the
2026 revision updates the scheduled-sale interpretation and branch-count notation.
This preference is also recorded in the user-level Codex and Claude instruction
files so it is available when working in other course repositories on this machine.

## Optional example descriptions — all courses

Approved September 10, 2026 after reviewing and lightly tightening the L4a
optional-example descriptions. Apply this preference across the instructor's
courses, for both Codex and Claude.

- Start with a linked, descriptive example title and a natural question that
  explains what the example adds to the main lecture.
- Follow with a compact paragraph in the instructor's teaching voice: explain
  what we will compute, derive, track, or compare, and what students will learn
  from the result. Use accessible “we” language and concrete actions.
- Give enough detail to help students decide why to explore the example. Read
  the linked notebook before describing it; do not promise work it does not do.
  Explain unfamiliar terms briefly where needed, as with slippage below.
- Preserve the connection to the lecture and any meaningful comparison with its
  simpler model. Avoid terse implementation summaries such as “propagating only
  the probability mass” when readers have not yet learned what that means.
- Use the approved passages below to calibrate length and detail. The instructor
  requested two successive reductions of about 5% for these descriptions. That
  demonstrates modest, local tightening while retaining the question, method,
  and teaching purpose; it is not a universal percentage target or a required
  two-pass workflow. Avoid repeated introductory filler and unnecessary modifiers.
- Keep existing working links and the course's restrained formatting. This
  writing pattern is a guide, not a requirement for identical sentence counts
  or stock phrases in every description.

Approved descriptions from the 2026 L4a lecture:

* [▶ First-passage exit rules](../week-4/L4a/advanced/first-passage/CHEME-5660-L4a-Advanced-FirstPassage-ExitRules-Fall-2026.ipynb). What changes if we check the price after every lattice step and sell when a take-profit or stop-loss boundary is reached? We compute the probability of reaching either boundary first, or reaching neither during the holding period. We track open positions and compare with a calculation that checks only the final price. This explains why paths ending at the same price can produce different outcomes.

* [▶ Execution-aware probability of profit](../week-4/L4a/advanced/execution/CHEME-5660-L4a-Advanced-ExecutionAware-ProbabilityOfProfit-Fall-2026.ipynb). How do trading costs change the probability of exceeding our target return? We extend the NPV calculation to include buying at the ask, selling at the bid, transaction fees, and an allowance for unfavorable execution prices (slippage). We derive the terminal price needed to exceed the target and compare the probability with the frictionless model. We examine how the individual costs, benchmark growth rate, and holding period affect the calculation.

## Computational and advanced examples

Approved September 10, 2026 when beginning the L4a cumulative-probability example
review. Extend this shared guide for examples; do not create a separate voice or
competing style memory. The same teaching voice, current course notation,
formatting, three objectives, three retrospective takeaways, and modest tightening
apply to lecture, example, and advanced-example notebooks.

- Introduce the problem before the computation: what we want to calculate, why
  it matters, and how it connects to the lecture.
- Organize each example notebook, including advanced examples, into exactly
  three tasks. Group related calculations under descriptive subsections within
  those tasks; setup, summary, and limitations need not be separate tasks.
  The instructor confirmed this requirement during the execution-aware example
  review on September 11, 2026.
- Use the standard setup demonstrated in
  [the L4a cumulative-probability example](../week-4/L4a/CHEME-5660-L4a-Example-CumulativeProbabilityLattice-Fall-2026.ipynb)
  for computational notebooks, including advanced examples. Retain the
  “Setup, Data, and Prerequisites” heading, brief introduction to the local
  `Include.jl` file, labeled `Include` blockquote with its Julia documentation
  link, “Let's set up our code environment:” line, include cell, and documentation
  references afterward. Adapt factual descriptions to the actual setup file
  and add data-loading subsections only when needed. Do not replace this shared
  setup with a newly composed package overview or rename it for each example.
  The instructor explicitly confirmed this standard on September 10, 2026
  during the execution-aware example review.
- Connect mathematics to code. Explain how the calculation works and identify
  the relevant variables and functions. Do not replace that explanation with
  function-call instructions or internal dispatch details unless the Julia
  mechanism is itself part of the lesson.
- Link function references in notebook prose to their documentation, using the
  instructor's form `[The function_name(...) function](documentation-target)`
  (adjust capitalization to the sentence). Use a verified function-specific
  reference, not a guessed URL or a general package homepage. For locally defined
  helpers without existing documentation, add a concise local Markdown reference
  under the notebook's `docs/` directory and link to it with a relative path.
  Include the signature, arguments and units, return behavior, and a link back
  to the notebook defining the helper. For library functions, link directly to
  the appropriate hosted VLQuantitativeFinancePackage.jl/course-package, Julia,
  or other package documentation; do not duplicate those references locally.
  The instructor explicitly endorsed this local-versus-hosted distinction after
  reviewing the `strict_lattice_threshold` reference. Keep the teaching explanation
  in the notebook. This convention applies to lecture, example, and advanced-example
  prose, not function names in code.
- Interpret meaningful outputs. Explain what students should notice in parameter
  tables, histograms, and calculated probabilities. Displaying a result alone
  does not complete its explanation; routine setup cells need no forced commentary.
  When prose gives numerical results for selected parameters, briefly remind
  readers that their results may differ if they change those parameters. The
  instructor approved this reminder during the execution-aware example review
  on September 11, 2026.
- Check agreement between the narrative, equations, and implementation, including
  data selection, units, assumptions, and boundary cases. Preserve working code
  unless a change has a clear purpose. Validate behavior-changing edits with
  appropriate execution and checks; prose-only edits do not require code rewrites.
- Give advanced examples the same readable voice. They may assume more background
  and develop deeper mathematics, while still explaining purpose and reasoning.

The 2025 cumulative-probability example explains how historical growth observations
become up and down factors and an up probability. Much of that development was
lost in the 2026 version. Recover useful explanatory steps from the older example
while checking them against the current implementation and notation; the old
formulas and code are not automatically authoritative.

The instructor explicitly praised the revised opening of Task 2 in the 2026
cumulative-probability example as capturing his voice. Its sequence is a useful
calibration: state the trading question, recall the relevant equation, explain
why the result changes with the up-move count, and connect that reasoning to the
next code variable. Numerical implementation details follow where needed.
Preserve this explanatory progression when tightening other examples; it is not
a mandatory sentence template.

For the current L4a example review, propose edits for instructor approval in
manageable sections, then apply approved wording. Start with the introduction
and objectives, then setup and data, estimation, model construction, target
probabilities, output interpretation, and takeaways. Preserve the closed L4a
lecture. This agreed review process does not require repeated approval for
previously authorized edits or impose a universal notebook section template.

## Editing and review

Keep edits proportionate to the teaching problem. Correct a mathematical error and
its consequences without automatically rewriting the surrounding lecture, renaming
everything, adding advanced topics, or erasing instructor revisions. Preserve
working code and outputs during prose-only changes unless a correction requires
otherwise.

Review the explanation as a student encountering the topic: is the purpose clear,
can the reasoning be followed, and is the result interpreted? Separately check
technical correctness and consistency between prose, equations, examples, and
code. For example, “at least” and a strict greater-than predicate must agree.
Formatting checks and self-assigned quality scores cannot establish that a notebook
teaches well. Report concrete changes and the verification actually performed.

The first approved calibration is the revised 2026 L4a NPV section in
[L4a-NPV-STYLE-CALIBRATION.md](L4a-NPV-STYLE-CALIBRATION.md), informed by the 2025
discussion and the 5820 references. The instructor approved it ("the NPV draft
looks really good") and requested its application to the 2026 L4a lecture on
September 10, 2026. It has been applied with the standardized 2026 notation.
Use this section as a concrete reference for subsequent edits. Its approval does
not authorize wholesale changes to other notebook sections. Calibrate a
representative section when introducing a substantially different rewriting
approach; this is not a requirement to seek approval for every routine edit.

## Maintenance

This is the single maintained guide, stored in the CHEME 5660 Fall 2026 repository
at `lectures/instructor/NOTEBOOK-STYLE-GUIDE.md`. Both courses' root AGENTS.md and
CLAUDE.md files point here. Update this guide when the instructor refines the
agreement or approves a calibration passage. Keep confirmed preferences distinct
from pending proposals. Do not require the instructor to repeat this conversation.
