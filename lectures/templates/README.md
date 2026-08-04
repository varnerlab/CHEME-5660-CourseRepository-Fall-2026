# CHEME 5660 lecture-note house style

The shared `varnernotes.sty` package defines the visual and structural language
for all CHEME 5660 lecture notes. The following authoring rules are mandatory.

`week-1/L1b/docs/Style-Specimen.tex` is the canonical production example for
all lecture notes. Each substantive lecture owns a `docs/Notes.tex`, a
`docs/Notes.pdf`, a thin local `varnernotes.sty` wrapper, and a `Makefile` that
includes `lectures/templates/lecture.mk`. From `lectures/`, run `make notes` to
build the complete note set or `make -C week-N/Lxx/docs notes` to build one.

## Projector-friendly notebook view

Long-form lecture notebooks remain the canonical source for the annotated
in-class presentation. A lecture directory can define `NOTEBOOK` in a local
`Makefile` and include `../../templates/notebook.mk` to generate a standalone
HTML lecture view next to the notebook. For example:

```make
NOTEBOOK := CHEME-5660-L2a-Lecture-TreasurySecurities-Fall-2026.ipynb
include ../../templates/notebook.mk
```

Run `make` in that lecture directory. The HTML view uses 28 px body text and
larger display mathematics on projector-sized screens, hides notebook prompts,
and retains ordinary scrolling rather than forcing content into fixed-height
slides. Its toolbar changes the text size and enters fullscreen; the keyboard
shortcuts are `+`, `-`, `0` (reset), and `f` (fullscreen). Equations scroll
horizontally when necessary rather than being reduced to an unreadable size.

The generated HTML is a presentation artifact, not a second source document:
edit the notebook, then rebuild the HTML. Relative links to figures and worked
examples continue to resolve because the two files live in the same directory.

## Semantic cross-references

Every numbered figure, table, equation, definition, theorem, proposition, and
remark must be introduced or interpreted in the surrounding prose. The lead-in
sentence must state what the object shows, establishes, or contributes, with the
reference embedded naturally in that same sentence.

Good:

> An abstract asset represents the economic value of a process, good, or idea
> as a sequence of dated signed cash flows (Fig. 1).

Avoid bare directions such as “see the figure below,” references that appear
only after the object, and numbered objects that are never cited in the prose.
A caption or theorem title does not replace the required lead-in sentence.

Use the house macros with label suffixes:

```tex
\figref{cash-flow}       % label: fig:cash-flow
\tabref{parameters}      % label: tab:parameters
\eqnref{discount-factor} % label: eq:discount-factor
\defnref{abstract-asset} % tcolorbox key: abstract-asset
\thmref{limit}           % tcolorbox key: limit
\propref{no-arbitrage}   % tcolorbox key: no-arbitrage
\remref{units}           % tcolorbox key: units
```

The preferred inline forms are `Fig.`, `Table`, `Eq.`, `Defn.`, `Thm.`,
`Prop.`, and `Remark`. References remain clickable in the generated PDF.

## Prose-to-equation transitions

Every displayed equation must be introduced by helper text that makes the
prose and mathematics one grammatical unit. End the lead-in with a colon when
the display completes the sentence. Useful transitions include “is given by,”
“can be written as,” “therefore satisfies,” “follows from,” and “reduces to.”
Choose the phrase that explains the mathematical role of the display rather
than repeating a generic transition throughout the notes.

Good:

> The value after one year is given by Eq. 1:
> \[
> F=(1+r)P.
> \]

Avoid dropping directly from a complete prose paragraph into a display with no
transition. Also avoid fragments such as “where:” and vague directives such as
“we have:” when a more informative mathematical verb is available.

## Defined terms and local completeness

Define every symbol and notation when it first appears, including its
mathematical role, domain or admissible values, and physical or financial units
when applicable. This rule includes operators, subscripts, superscripts,
summation indices, norms, asymptotic notation such as $O(x^3)$, and conventional
constants such as $e$; familiarity is not a substitute for a definition.
Pair the descriptive term with its symbol in prose: write “the discount rate
$r$,” “the investment horizon $T$,” or “the compounding frequency $n$” rather
than introducing a bare $r$, $T$, or $n$. Reintroduce the descriptive term when
a symbol returns after a substantial gap or when doing so prevents ambiguity.

Every definition, theorem, proposition, and remark must be locally complete and
understandable on its own. Restate the meanings of all symbols used inside the
formal statement even when they were defined earlier in the notes. State the
assumptions and conventions needed to interpret the result; do not require the
reader to search the surrounding paragraphs for them.

Good:

> Let the nominal annual discount rate be $r\in\mathbb{R}$, let the investment
> horizon be $T\geq 0$ years, and let the positive integer $n$ denote the number
> of compounding intervals per year.

Avoid:

> For fixed $r$ and $T$, as $n\to\infty$, ...

## Required review check

Before a note is complete, enumerate every numbered object and confirm that it
has a substantive inline reference in the prose. The reference must communicate
the object’s message, not merely prove that the object exists. Then inspect
every displayed equation and confirm that its lead-in contains grammatical,
informative helper text. Finally, inspect every symbol in the prose and every
formal statement: confirm that its name, role, admissible values, and units are
defined locally wherever the reader needs them. Include mathematical notation
and operators in this symbol-by-symbol audit.
