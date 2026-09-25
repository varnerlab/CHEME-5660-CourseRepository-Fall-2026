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

## Prose density and the instructor's voice — September 24, 2026

This applies to authoring and polishing notebooks across the courses covered by
this guide. The instructor explained that repeated assistant passes still leave
hours of manual tightening. In the L6a comparison, he preferred the sharper, less
text-heavy 2025 presentation while explicitly valuing the new 2026 mathematics.
Treat that feedback as evidence that the editorial standard needs adjustment,
not as a request for another round of minor wording substitutions.

- Judge the whole section and its rendered reading burden. Individually useful
  sentences can accumulate into excessive explanation. Correctness and completeness
  alone do not establish that a notebook matches the instructor's voice.
- Let equations, annotated derivations, matrices, and figures carry their share of
  the explanation. Use prose to motivate, define, connect, and interpret; avoid
  routinely announcing a result, showing it, restating it, and summarizing it again.
- Keep complete, natural sentences and the reasoning students need. Tighten repeated
  definitions, obvious-step narration, and transitions that merely repeat headings.
  Preserve new topics and essential mathematical steps while reducing their prose
  overhead. A substantial reduction can be appropriate when the section is overgrown;
  neither a fixed reduction percentage nor a universal limit to small edits applies.
- Compare matched topics with the instructor's reference before expanding a draft.
  Inspect prose between displays, dense inline notation, and visible paragraph length
  at comparable text widths. Word counts help diagnose density; they are not quotas.
- Calibrate one representative section early, then carry the accepted density and
  presentation into subsequent work. Do not defer this comparison until a high
  final score has been assigned. Distinguish an approved general preference from
  a newly drafted passage the instructor has not yet evaluated.
- When an instructor-revised version is available, examine the actual changes and
  record concrete lessons here. Do not infer edit authorship or invent preferences.
  Repeated manual rework is a reason to revisit the approach, not to defend earlier
  assistant scores or shift the problem to classroom pacing.

This refines the earlier preservation guidance: preserve the teaching substance,
not every sentence surrounding it. Historical approvals remain closed unless the
instructor requests another pass. The instructor approved the tightened
[L6a Portfolio Risk passage](../week-6/L6a/CHEME-5660-L6a-Lecture-MAGBM-Data-Portfolios-Fall-2026.ipynb)
on September 24 as the first density calibration: approximately 470 to 270 prose
words, retaining the mathematical development and two-asset example while making
the standard-deviation and volatility formulas separate displays. Use its balance
of prose and mathematics as a reference across courses, not as a word-count target.
On September 25 the instructor approved condensing that passage's closing: the
log-return box and separate GBM-volatility display became a three-sentence note on
conventions. The stated reason was that the lecture never uses log returns or the
covariance rate again, and its examples convert to volatility themselves. The
standard-deviation display and two-asset example remain the reference.

## Algorithm pseudocode formatting — September 25, 2026

The instructor explicitly requested the 2025 pseudocode formatting across algorithm
notebooks. Inspect the corresponding 2025 algorithm before editing. Preserve its
bold initialization label, explicit loop line, ordered algorithm steps, and indented
conditional branches with bold control words such as `do` and `then`. Keep distinct
operations, such as updating the solution and incrementing the counter, as separate
steps when the reference does. Preserve the method-specific recursive or loop
structure; do not flatten it into a generic “Repeat” list during a correctness pass.

The CHEME 5800 Fall 2025 L6c Jacobi, Gauss–Seidel, and SOR notebooks provide the
iterative-solver examples of this format. Retain current mathematical and stopping
corrections: return immediately on termination and distinguish convergence from an
iteration limit. This preference concerns pseudocode formatting and does not call
for rewriting already accepted surrounding sections.

## Voice-calibration experiment — protocol for both courses

Started September 25, 2026, for CHEME 5800 and CHEME 5660, for both Codex and
Claude. The instructor still spends hours hand-editing assistant-revised lecture
and example notebooks in both courses. Rather than guess at his voice, the
assistant learns it from what he actually changes.

**The idea.** Before the instructor hand-edits a notebook the assistant drafted or
revised, freeze a copy. After he finishes, diff the frozen copy against his
version cell by cell, report the patterns in his own words, and record the
concrete lessons in this guide. Each round adds calibration; over rounds the
first draft should need less rework. The instructor asked on September 25 that
this be done often, for lectures and examples in both courses.

**Mechanics.**

1. When the instructor says he is about to edit a notebook, or asks for a backup,
   commit the current state first so the baseline has a commit hash. Then copy the
   notebook to the course's calibration folder as `before.ipynb` and add a short
   `README.md` naming the source notebook path, the commit, and the date. Commit
   the backup. If he had already made some edits before the backup, say so in the
   README; those belong to the baseline, not the round.
   - CHEME 5800: `instructor/voice-calibration/<notebook-slug>/`
   - CHEME 5660: `lectures/instructor/voice-calibration/<notebook-slug>/`
2. When he says the round is done, dump both notebooks cell by cell and produce a
   unified diff of cell text, plus prose word counts per cell (strip style blocks,
   tables, images, and displays before counting). Diff any `src/` changes too.
3. Report what he cut, reworded, reordered, added, or moved, quoting his text.
   Lead with the structural finding, not the word count. Distinguish order and
   framing changes from length changes; the first two rounds changed structure and
   left length alone. Note loose ends his edit left (dangling references, typos,
   inconsistencies) as observations for him to decide, not as fixes.
4. Execute the edited notebook from its own folder before committing it, so a
   broken cell is caught while the edit is fresh.
5. Record the lessons in this guide as a dated section with quoted passages,
   then commit the notebook, the backup, and the guide. Do not infer preferences
   the diff does not show, and do not treat one round's choice as a rule for a
   different kind of notebook; lectures and examples have differed.

**Rounds so far.** L6a flux balance analysis lecture (CHEME 5800, lecture) and
L6a urea-cycle example (CHEME 5800, computational example), both September 25,
2026; their lessons are the two sections that follow.

## Lecture structure lessons from the instructor's L6a edits — September 25, 2026

First round of the voice-calibration experiment. The assistant draft is the CHEME
5800 L6a flux balance analysis lecture at commit `9c4c05a`, backed up in that
repository at `instructor/voice-calibration/L6a-Lecture-FluxBalanceAnalysis/`.
The instructor edited the notebook by hand the same morning. The lessons below
come from that diff; quoted text is his. Do not extend them to preferences the
diff does not show.

The rework was about order, framing, and figures, not length. Body prose stayed
near 1650 words in both versions; total prose rose from about 2050 to 2250 because
the objectives and takeaways grew. Two figures were added.

**Order: build the pieces, then assemble the problem.** The draft went
stoichiometric matrix, linear program, then bounds as a separate H2. He made
`## Flux Balance Analysis` the single main section with H3 subsections in this
order: `### Stoichiometric Matrix`, `### A Model for Flux Bounds`,
`### Linear Programming Formulation`. The formulation comes last because it uses
both pieces. The example callout follows the assembled problem box
("Let's consider an example to illustrate the FBA problem and its solution.") and
the `___` closes the H2 after the callout. One markdown cell per H3.

**Open a main section with a definition and a figure, not a verbal preview.** The
draft opened FBA with two paragraphs explaining steady-state balances, bounds, and
the objective in words. He replaced them with two defining sentences ("FBA uses
linear programming to find the flux distribution (reaction rates) that optimizes a
chosen objective function, subject to stoichiometric and capacity constraints, at a
__pseudo-steady state__."), a linear-program geometry figure (null space, bounds
polytope, optimal edge, flux variability bracket), a caption paragraph opened by a
bold run-in label ("__Conservation, bounds, and alternate optima.__ The balance
equations define the null space..."), an attribution line ("Adapted from the
[Varner lab chapter's linear-program geometry figure](...)"), and a roadmap
sentence ("Let's look at the different components of the FBA problem and how they
are formulated, starting with the stoichiometric matrix."). He is comfortable
naming advanced ideas in an overview as forward references without developing them
(null space, flux variability analysis, "the convex decomposition of the
stoichiometric array").

**A toy worked example gets its own H4 and a picture.** He added
`#### Example: Stoichiometric Column` and a control-volume figure (dashed boundary,
∅ for the surroundings) before the column display, then used the figure's vocabulary
in the prose that follows ("A positive flux brings $A$ into the control volume").
The exchange example changed from exporting the product $C$ to importing the
reactant $A$, so uptake is the case shown. The section on data sources lost its
own H3; the resource table survived inside the stoichiometric-matrix subsection
behind a one-sentence definition of a metabolic reconstruction, while the
catabolism/anabolism and compartment paragraphs were cut.

**Motivate from the general biology to the field, and name the field before its
box.** The draft opened with the sharing-of-metabolites argument and, after the
figure, an inventory of branch points. He replaced both: "Metabolic pathways encode
the enzyme catalyzed reactions that convert nutrients into biomass and energy in
living cells. There is an amazing diversity of metabolic pathways in different
organisms, but also some highly conserved pathways that are shared across many
species, such as __central metabolism__ (glycolysis, the pentose phosphate pathway,
and the TCA cycle)." After the figure: "These are the reaction networks that we
need to manipulate in order to produce a desired compound. The systematic study and
analysis of these networks is called __metabolic engineering__." The section closes
on a one-sentence paragraph that names the tool: "Flux balance analysis (FBA) is a
quantitative tool that provides a way to answer these questions."

**Restate definitions in plain words with the vocabulary in bold.** The definition
bullets became "$\sigma_{ij}>0$: species $i$ is __produced__ by the reaction $j$,
i.e., species $i$ is a __product__ of reaction $j$." Jargon gets a parenthetical
gloss on first use: "reaction rates (called fluxes)", "chemical species
(metabolites)", "estimates (optimal) metabolic reaction rates (fluxes)". Inside the
problem box he bolded the words that carry the idea: "A __feasible__ flux
distribution satisfies the balances and bounds. The objective selects an
__optimal__ distribution from the set of feasible distributions. However, the
optimal solution may __not be unique__." He also added the practical remark the
draft lacked: "The sign convention does not affect the FBA solution, but it does
affect the interpretation of the fluxes."

**Parameter models: display, then "where", with dimension words in backticks.**
Directly under the bounds display, with no blank line: "where $V_{max,j}^{\circ}$
denotes the maximum reaction velocity (units: `flux`) computed at some
_characteristic enzyme abundance_. Thus, the maximum reaction velocity is given
by:" and, after that display, "where $k_{cat,j}$ is the catalytic constant or
turnover number for the enzyme (units: `1/time`) and $e^{\circ}$ is a
characteristic enzyme abundance (units: `concentration`)." The full quantity table
stays as well: the prose defines the symbols the reader needs to follow the
argument, the table is the reference. Approximate-to-one assumptions are written
with $\sim$: "Let's initially assume that $(e/e^{\circ})\sim{1}$, there are no
allosteric inputs $\theta_{j}\left(\dots\right)\sim{1}$, and the substrates are
saturating $f_{j}\left(\dots\right)\sim{1}$." The simplified model closes with an
interpretation, not a procedure: "This is a simple model for the flux bounds. It is
easy to see that the flux bounds are a function of the maximum reaction velocity,
the catalytic constant or turnover number, and our assumed value of a
characteristic enzyme abundance." He cut "To set these simplified bounds for each
enzyme-catalyzed reaction, we need estimates of..." and "Not every bound affects
the optimum."

**The central problem statement is boxed and its constraints are labeled.** The
display is wrapped in `\boxed{...}`, the decision variables are enumerated in the
subscript ($\hat{v}_1,\hat{v}_2,\ldots,\hat{v}_{|\mathcal{R}|}$ rather than
$\hat{\mathbf{v}}$), and each constraint line ends with
`\quad\text{(material balance constraints)}` or
`\quad\text{(thermodynamics and kinetic constraints)}`. The box title names the
object, "Flux balance analysis (FBA) problem", not "as a linear program". The
lead-in stays: "Under these assumptions, the __flux balance analysis problem__ is
given by:".

**Framings he reached for.** "Integrative" appears three times: "the flux bounds
are _integrative_, i.e., these constraints integrate many types of genetic and
biochemical information into the problem", again in the example description, and
in the takeaways. The example description gained a generalization sentence: "While
this example is specific to the urea cycle, the same approach can be applied to any
metabolic network." Hedges were removed: "it does not establish how the cell
actually operates" and the closing "An optimal flux distribution tells us what the
model allows under the conditions we specify" became "Flux balance analysis is a
powerful tool for metabolic engineering, allowing us to predict how changes in the
metabolic network can affect the production of desired compounds."

**Cuts that carried no replacement.** The steady-state display
$\mathbf{S}\hat{\mathbf{v}}=\mathbf{0}$ and its three sentences left the
stoichiometric-matrix subsection; the balance now appears only in the problem box.
The question opener "How does material enter or leave the network?" went. The
bounds motivation paragraph ("The material balances require reaction rates to be
consistent with one another, but they do not specify how fast an enzyme can
operate...") went. "We fix all of these quantities before solving, so each bound is
a number and the problem remains a linear program" went. The urea objective-sign
paragraph with the Orth and Heirendt references was parked in an HTML comment
rather than deleted. The L5c link became "the minimum-cost flow problem we explored
previously" with no link. He confirmed the reason on September 25: weekly releases
ship one week's folder, so a relative link into another week's notebook is broken
for students. In lecture prose, refer to earlier weeks' material in words; link
only files that ship in the same weekly release.

**Objectives and takeaways.** Each objective became one sentence saying what the
object is, then one "We'll" sentence: "__Represent a metabolic reaction network as
a stoichiometric matrix:__ The stoichiometric matrix is the digital representation
of the reaction biochemistry occurring inside a cell. We'll construct a
stoichiometric matrix from biochemical reactions and interpret its rows, columns,
and coefficient signs." The labels are longer and more specific than the draft's.
The title cell ends with the example preview and the exclamation in one paragraph:
"We'll demonstrate these concepts with an example, where we estimate the metabolic
fluxes in the urea cycle of a mammalian liver cell. Let's get started!" The
takeaways are concept statements of two to four sentences ("The stoichiometric
matrix is a mathematical representation of the metabolic network, where each row
corresponds to a metabolite and each column corresponds to a reaction...") rather
than the "We derived..." retrospective approved for L4a on September 10. Both
voices are now on record; do not rewrite one into the other.

**Figure HTML.** New figures sit in `<p align="center">` with
`style="max-width:100%; height:auto;"` on the image, widths 1100 for a full-width
panel figure and 780 for the small schematic, and the same theme `<style>` block
as before.

## Example-notebook lessons from the instructor's L6a urea-cycle edits — September 25, 2026

Second round of the voice-calibration experiment, on a computational example
rather than a lecture. The assistant draft is the CHEME 5800 L6a urea-cycle
example at commit `1280c5a`, backed up in that repository at
`instructor/voice-calibration/L6a-Example-UreaCycle-FluxBalance/`. Quoted text
is the instructor's. Prose length was unchanged (about 1,440 words both ways);
the edits changed what the example is for and how the code reads.

**An example ends at the solved, checked result.** He deleted the two analytical
subsections that followed the flux table, "Why does the lyase capacity limit urea
production?" (a three-balance derivation with a capacity-doubling check) and "What
would oxygen uptake imply?" (an oxygen-balance argument with a numeric what-if).
The interpretation that remains is one added clause on the observation: "Reaction
`v2` reaches its upper bound, which matches the maximum export rate." The example
now runs build, bound, solve, inspect, check, summary. Analytical extensions of a
solved example belong elsewhere or nowhere, not after the check cell.

**Example objectives and takeaways follow the lecture pattern.** Each objective is
one sentence saying what the object is, then one action sentence: "**Construct the
reaction model:** The reaction model holds a stoichiometric matrix that describes
the network topology and the steady-state balances. The model includes the
urea-cycle reactions, a nitric oxide synthase branch, and exchange reactions for
the inputs and outputs." The takeaway labels are short claims rather than abstract
nouns: "The network file defines the model", "Two data sources set the bounds",
"The lyase capacity sets the export rate", each followed by two "We read...",
"We maximized..." sentences. The closing line names concrete next moves: "We can
now change the turnover numbers, enzyme abundance, or exchange bounds and see how
the maximum urea export rate responds." The summary opener uses parallel verbs:
"we built a urea-cycle flux balance model, set its bounds from thermodynamic and
kinetic records, and solved for the maximum urea export rate."

**Task prose describes the process and the data structures, with types.** The
draft's Task 1 stated the matrix dimensions and the exchange convention. His
version walks the pipeline: "The first step is to load the reaction network from
the `Network.net` file and build an FBA model. The network file encodes the five
urea cycle reactions and the exchange reactions in a simple text format. From
this, we build a stoichiometric matrix $\mathbf{S}$, a species list, a reaction
list, and a default flux bounds array." The model box became a question,
"__What does the model contain?__", names the concrete type
(`MyPrimalFluxBalanceAnalysisCalculationModel`), and lists fields with an em dash
and the matching mathematics: "`S` — the stoichiometric matrix
$\mathbf{S}\in\mathbb{R}^{|\mathcal{M}|\times|\mathcal{R}|}$", "`objective` — the
coefficient vector $\mathbf{c}$ for the linear objective (initially all zeros)".
Variables named in prose carry their Julia type:
"`reversibility_parameter_dictionary::Dict{String, Int}`",
"`maximum_reaction_velocity_dictionary::Dict{String, Float64}`",
"`fluxbounds::Array{Float64,2}`", "`rd::Dict{String, String}`". He links the
factory function and the language feature the cell uses: "We'll use [the
`build(...)` factory method](src/Factory.jl) to construct the model from a
`NamedTuple` of data. A [let block](...) keeps intermediate variables private —
only `model` and `rd` are returned." The code lead-in is a bold run-in label:
"__Build the model__: Let's load the network and construct the model:". This is the
CHEME 5800 example register; the CHEME 5660 lecture rule of no implementation
detail is unchanged.

**Code cells are staged with labeled comments and teach the idiom.** He inserted
stage comments ending in a dash, separated by blank lines: `# initialize -`,
`# build the dictionary -`, `# main loop -`, `# Display the flux table -`.
Comprehensions use `∈` rather than `in`. Trailing comments explain language
mechanics and label data: `# this means skip to the next iteration of the loop`,
`# reaction name string labels, e.g., "v1", "v2", ..., "b1", "b2", ...`,
`# attach the updated bounds to the model`, and a prompt to the student on the
dictionary comprehension: `# fancy, what is going on here?`. The one-line
attachment `model.fluxbounds = fluxbounds;` moved into the cell with the `let`
block that builds it, so a `let` block plus its single follow-up assignment can
share a cell.

**Tables are plain `pretty_table` text, not styled HTML.** The draft's
`pretty_table(HTML, df; style = HtmlTableStyle(...), highlighters = ...)` with
column widths and wrapping became
`pretty_table(df; show_first_column_label_only = true, display_size = (-1, -1),
alignment = [...])`, with the comment `# show every row and column`.

**Checks are headed "Check:" and start with the solver status.** The heading is
`### Check: Numerical solution`. The prose opens "Let's check that the solver
reports an optimal solution, then check the model dimensions, ..." and the first
test is `@test solution["termination_status"] == JuMP.MOI.OPTIMAL`. To support it
he added `results["termination_status"]` to the solver in `src/Compute.jl` and
its docstring. Adding a small field to local source to make a check honest is in
scope for an example edit.

**Small mechanics.** Two adjacent short paragraphs on the same point were merged
(Step 2). A lead-in sentence naming the target variable precedes a code cell
("The flux bounds are stored in the `fluxbounds::Array{Float64,2}` array:").
The duplicated `___` at the end of the title cell and start of the Setup cell was
reduced to one, directly after "Let's get started!" with no blank line.

## Slides as a note-taking companion — CHEME 5660

Confirmed September 12, 2026. The instructor presents the lecture notebook while
students take notes on the slides. The slides are a concise companion to the
notebook, analogous to Cliff Notes: retain the key equations, definitions, and
reasoning students need to follow the live explanation.

Keep the teaching topics, recognizable headings, subsection sequence, and worked
example stops in the same order. A topic split across several slides should follow
the order in which the notebook develops it. Add a company profile or other
teaching topic to the notebook before including it in the companion deck. Keep
the established front-of-deck title and disclaimer convention. Synchronization
should preserve the notebook's fuller teaching prose and the existing slide design.

### Slide review rules agreed during interactive review

Approved September 12, 2026. Add rules here as the instructor approves them
during the slide review; proposed rules are not yet requirements.

- **Learning objectives:** Preserve the notebook's three learning outcomes,
  use concise action statements, and avoid repeating the same agenda in an
  introductory paragraph.
- **Key takeaways:** Retain three retrospective takeaways in the shared
  teaching voice. Connect the method, result, and purpose using concrete
  language, as in the approved L4b closing takeaway about calculating the
  probability of exceeding a target scaled NPV at the scheduled sale time.
- **Terminology:** Use the same names for quantities across slides and
  notebooks. Shortening prose should preserve distinctions such as growth rate,
  log return, and scaled NPV.
  For L4b, retain the instructor's preferred growth terminology: "mean log
  growth" describes the accumulated quantity over the holding period, while
  "mean growth rate" refers to $\mu_g=\mu-\sigma^2/2$. Keep drift $\mu$
  distinct from $\mu_g$. The compact "mean log growth" underbrace on the
  analytical-solution slide is approved; do not replace it with "mean log
  return" or the longer "mean growth rate × time."
- **Transitions:** Explain why the next topic follows, using a concrete
  question or relationship.
- **Limiting processes:** State what changes and what remains fixed.
- **Model definitions:** At a model's introduction, define its variables,
  parameter assumptions, and units near the equation.
  In L4b's trade rule, retain the broad term "benchmark growth rate" for
  $g_y$, corresponding to yield $y$. The benchmark may be risk-free or an
  alternative such as SPY. The calculation uses a constant assumed growth rate
  for the comparison; do not narrow the benchmark to risk-free by default.
- **Explanatory sequence:** Place explanations where the required concepts
  have been introduced.
- **Probability thresholds:** In the L4b target-probability derivation, refer
  directly to the standard normal random variable $Z$ and events such as
  $Z>z_\star$. The instructor preferred this wording to "shock" when
  explaining the threshold and probability calculation.
- **Optional-example descriptions on slides:** Convey the topic and purpose,
  leaving procedural details to the example. For instance, use "introduce
  variance reduction techniques" in the Monte Carlo overview rather than
  explaining paired draws $Z$ and $-Z$ there.
- **Mathematical conditions:** Explain conditions in terms of the model or
  data when a short, concrete explanation is available.
- **Standard errors:** Explain standard error directly as estimated uncertainty
  in the fitted parameter, with smaller values indicating greater precision
  and units matching the parameter. The instructor found "varies across
  repeated datasets" unclear in the L4b slide explanation. Do not use that
  phrase without explaining the hypothetical repetition, or describe the
  standard error as uncertainty in the "mean of" the fitted parameter.

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
  Keep the fuller N-ary version as that notebook's baseline. That rejection is
  specific to the N-ary revision, not a general prohibition on substantial tightening
  of overgrown prose; follow the September 24 density guidance above. Preserve the
  worked examples, mathematical steps, and explanatory pacing; keeping equations
  intact alone does not mean that the teaching explanation has been preserved.
- Use direct, accessible sentences. “Suppose,” “Let's,” and questions such as “Why
  is this interesting?” belong when they guide the reasoning. Preserve the
  instructor's natural enthusiasm without adding stock exclamations to imitate it.
- Keep complete, natural phrasing when tightening prose. On September 19, 2026,
  the instructor preferred “We estimate the volatility parameter…” to “We
  estimate volatility…” and objected to omitted words that made sentences less
  natural. Retain articles and repeated verbs when they help the sentence read
  smoothly, including explanations of units.
- Introduce quantities, dimensions, indexing conventions, and assumptions where
  readers need them. Explain mathematical operations and interpret the resulting
  expressions. Precision must remain understandable in context.
- Always transition smoothly from prose into displayed equations. Use a natural
  lead-in that identifies what the equation expresses, with a colon when the
  prose introduces the display. On September 12, 2026, the instructor explicitly
  changed “the tree's density is” to “the tree's density is given by:”. Preserve
  the mathematical conditions and logical meaning when improving these transitions.
- Definitions, theorems, and long blockquotes are welcome when they have a clear
  teaching role. Prepare the reader and connect formal results with prose. Do not
  collect motivation, assumptions, derivation, every edge case, implementation
  advice, and interpretation into one block merely to make it self-contained.
- Treat result blockquotes as “lite theorems”: include the mathematical setup,
  assumptions, result, and a short derivation sketch when useful. Keep the lead-in
  brief instead of accumulating the setup in dense paragraphs before the box.
  A linked derivation companion can carry the full calculation. The instructor
  requested this organization for the L6a GMV passage on September 24, 2026.
  “Lite” means offloading the full proof, not omitting definitions. Within each
  box, identify what we solve for, define every mathematical quantity used, and
  distinguish supplied inputs from unknowns and computed shorthand coefficients.
  Retain relevant dimensions and units. Use equation labels and selective
  annotations to explain the objective, constraints, and result. In multiline
  displays, place brief explanations to the right using `\quad\text{...}` or an
  aligned text column. Use underbraces when identifying a particular term helps;
  not every annotation needs an underbrace. Choose the placement that makes the
  reasoning easiest to follow without crowding the equation.
- For geometric explanations, begin with the figure and its interpretation before
  developing the mathematics. Connect to visual ideas already encountered in
  earlier lectures. In L6a, the instructor requested the frontier figure first,
  recalling the random-weight comparisons in L5b; distinguish those long-only
  samples from the short-allowed frontier developed here.
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
- Put each constant or parameter assignment on its own line, with a trailing
  comment explaining its meaning and units where applicable. Do not combine
  separate assignments on one line with semicolons. The instructor confirmed
  this preference on September 14, 2026.
- Use at most one `let` block per code cell. Give separate calculation and
  reporting blocks their own cells, with prose introducing the next step.
  The instructor confirmed this preference during the advanced covariance
  example review on September 14, 2026.
- Keep Julia function definitions in the notebook's local `src/` directory and
  load them through `Include.jl`. Give each function a proper Julia docstring
  describing its arguments, units, returned values, and assumptions. Keep the
  notebook focused on the explanation, function calls, and results. The instructor
  explicitly requested this on September 13, 2026; separate Markdown reference
  pages do not replace source docstrings.

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
- Use `___` at major-section boundaries immediately before a new level-two
  heading, and always end the final Summary with `___`. Do not put it between
  level-three subsections.
- Use a descriptive title and introduction, an appropriate section hierarchy, and
  a closing Summary. Computational notebooks need useful setup and task guidance;
  a conceptual lecture does not need an artificial setup or task structure.
- Check the rendered result when changing layout or mathematics, especially long
  equations, blockquotes, figures, and section boundaries. Source-level checks alone
  do not establish readability.
- Keep complete units inside inline math delimiters, for example
  `$\mathrm{year}^{-1}$`, rather than `year$^{-1}$`. The latter breaks VS Code's
  notebook math parsing and can corrupt subsequent prose and parameter symbols.
  Separate display equations from surrounding prose with blank lines (quoted
  blank lines inside a blockquote). Inspect the notebook renderer's output without
  preprocessing equations in a way that hides Markdown parsing failures.

Do not turn the reference notebooks into a growing catalogue of mandatory phrases,
punctuation rewrites, bans on ordinary teaching language, or fixed paragraph lengths.

For tables, the instructor prefers compact, restrained formatting. The first
decorative HTML-table treatment in L4a was rejected as too large and overdesigned:
avoid badges, shadows, rounded card frames, and excessive padding. Preserve readable
type and clear alignment. Simple notation in raw HTML tables should use HTML
italics, subscripts, and bold vectors rather than relying on LaTeX rendering there.

When presenting consecutive result tables, include a short paragraph between them
that interprets the preceding result and introduces the next comparison. The
instructor confirmed this preference on September 14, 2026.

When a table is followed by a figure, also place connective prose between the
outputs: interpret the table and introduce what the figure will show. The
instructor confirmed this preference on September 15, 2026.

## Key takeaway voice — all courses

On September 10, 2026, the instructor explicitly approved this preference for
all his courses, for both Codex and Claude. The broader guide was established
for CHEME 5660 and CHEME 5800; this takeaway preference is course-independent.

Use a short, descriptive bold topic label followed by a retrospective account
of what we developed and why it matters. Write in the instructor's shared
teaching voice: “We derived…”, “We used…”, “We generalized…”, followed naturally
by what the result allowed us to explain, calculate, or compare. These are
examples of the voice, not mandatory sentence starters for every item.

On September 23, 2026, the instructor clarified that key takeaways should be
conceptual and contain no equations. Explain what we learned and why it matters
in words; keep formulas and algebraic calculation steps in the main development.

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

## Example callouts within lectures — CHEME 5660

Confirmed September 18, 2026. Follow the L4a and L4b format for example stops
within the lecture: a blockquote with a bold `Example:` label, a quoted blank
line, then a linked action title beginning with `▶` and a short description of
the application. Introduce the callout with ordinary prose and follow it with a
connective sentence. Keep the fuller descriptions in the opening Examples
section. Do not create a level-three heading solely for a linked example stop.
Use this format consistently for all main worked examples, including EMA;
the supporting EMA derivation remains a separate link.

## Company profiles — CHEME 5660

Clarified September 18, 2026 after the instructor found the new L5a Renaissance
Technologies profile incomplete. Use the L4b Jane Street company profile as the
reference: introduce the firm, explain its distinctive business in a labeled
panel, provide resources students can explore, and connect it to the lecture.
Include relevant founders and defining funds or products; for Renaissance this
includes Jim Simons and the Medallion Fund. Include verified jobs, internship,
and YouTube resources where available. If no internship is currently posted,
state that accurately and link the official careers page. Identify the publishers
of external interviews rather than implying they are company channels.
Review these substantive teaching elements alongside technical correctness and
rendering; passing mathematical and formatting checks does not establish that
a company profile is complete.

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
formatting, three objectives, three retrospective takeaways, and prose-density guidance
apply to lecture, example, and advanced-example notebooks.

- Introduce the problem before the computation: what we want to calculate, why
  it matters, and how it connects to the lecture.
- Usually place the “In this example, …” overview below the learning objectives,
  following the instructor's preference confirmed September 13, 2026. This is
  flexible: he approved its placement before the objectives in the L4b
  parameter-estimation example because it worked well in that opening.
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
  On September 12, 2026, the instructor reiterated “Always standard opening”
  and named the [L4b parameter example](../week-4/L4b/CHEME-5660-L4b-Example-Parameters-SAGBM-Fall-2026.ipynb)
  as the reference for this setup opening and its documentation references.
- Begin each task section with an explicit “In this task, …” sentence stating
  what we will calculate, construct, or examine. Follow with the motivation and
  explanation needed to begin the work. A question can develop the introduction,
  but does not replace this opening sentence. The instructor clarified this
  convention during the N-ary example review.
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
  In examples where the selected ticker is regularly changed, keep the discussion
  independent of a particular ticker and its default numerical results. Let the
  computed outputs supply the current values, and explain the relationships
  students should compare. The instructor confirmed this preference during the
  N-ary example review on September 13, 2026.
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

## L4b lecture review refinements — September 10, 2026

Jeffrey confirmed the following during the interactive L4b review:

- Keep language/package implementation details out of CHEME 5660 Fall 2026
  lecture notes. Function references and implementation discussion belong in
  companion examples. This overrides the earlier function-link guidance for
  these lecture notebooks; the approved mathematical pseudocode may remain.
- Do not begin prose sentences with an acronym. For example, use “The model's
  independent increments…” rather than “GBM's independent increments…”.
- Preserve established blockquote formatting. Keep a blank line after a panel
  label such as `Parameters:`, and keep its short bullets adjacent. Surround
  selected labeled blockquotes with ordinary explanatory prose.
- Keep optional examples in the bottom Optional Advanced Material section. If
  an example is needed in the main development, do not label it optional there.
- Follow a closing blockquote with a short connective sentence into the next
  topic; do not end the section or subsection on the blockquote.
- Avoid redundant explanations and mathematical side discussions that do not
  support the lecture's calculation. The cumulative-shock correlation discussion
  and a redundant price-path blockquote were rejected in L4b; the one-step
  transition and Monte Carlo procedure already explain the calculation.

For notation, L3a uses $\bar g$ for excess growth. L4b now uses
$\mu_g=\mathbb E[g_j]=\mu-\sigma^2/2$ for mean growth and $\hat{\mu}_g$ for
its estimate, while retaining $\mu$ for arithmetic GBM drift. The completed review
and scope of this migration are recorded in
[the L4b handoff](L4b-INTERACTIVE-REVIEW-HANDOFF.md).

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
