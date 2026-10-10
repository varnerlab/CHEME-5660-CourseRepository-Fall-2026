# L9a Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild L9a (October 20, 2026) as "Introduction to Derivatives and European Option Pricing": a lecture assembled from the instructor's Fall-2025 text, two examples, a contingent-claims advanced notebook, TikZ figures that follow light and dark themes, a rebuilt deck, and updated records.

**Architecture:** A Python assembler builds the lecture notebook from the instructor's 2025 cells. It applies a fixed list of replacements, and each replacement asserts its match count. NEW prose lives in separate fragment files that the assembler reads, so his text and the new text stay separable for review. A structural checker encodes the spec's rules, and each task runs the checker groups it owns. Figures are TikZ standalones built to a PDF and an SVG. The SVG gets a dark palette from the L5b post-processor.

**Tech Stack:** Python 3 (stdlib, NumPy, PIL; SciPy's `stats` module is broken in the local Anaconda, so nothing uses it), XeLaTeX + TikZ (`lectures/templates/vnfigure.sty`, `vnflow.sty`), `pdf2svg`, headless Chrome for theme previews, Julia 1.12 via `jupyter nbconvert`, `latexmk` for the deck, Pandoc 3.1.11.1 for the FAQ site.

**Spec:** `lectures/instructor/L9a-REDESIGN-SPEC.md` (read it first; this plan argues from it).

> **Superseded in part (October 9, after the build).** The lecture's sections 4–6 were
> restructured interactively with the instructor. The current outline, the redrawn
> contract figure, and the decisions behind them are in `L9a-REDESIGN-HANDOFF.md`
> under "Interactive restructure". The assembler and the `new/` fragments no longer
> build the lecture.

**Work directory:** `build/notebook-previews/L9a-redesign-2026-10-09/` (gitignored). Below it is called `$W`. Run every command from the repository root unless a step says otherwise.

## Global Constraints

- **Critical path is his text.** Lecture sections 3, 4, 6, 7, and 8 come from his Fall-2025 cells. The only changes are the replacements in Task 7 and the NEW fragments in Task 8. Do not reword anything else.
- **Rules:**
  - Exactly 3 LOs and 3 KTs.
  - `___` ends the cell before each H2, and it closes the Summary and the Disclaimer.
  - In-lecture example stops use `> __Example:__` / `>` / `> [▶ …](…)`.
  - Relative links resolve inside `lectures/week-9/L9a/`, and nothing links into L9b (bundles ship per meeting).
  - No forward pointers to future lectures.
  - No semicolons as clause joiners.
  - No denials of unproposed misreadings.
  - The lecture is markdown only, with no language or package detail.
- **Notation:**
  - The lecture uses his symbols: `\mathcal{P}_{c}`, `\mathcal{P}_{p}`, `V_{c}`, `V_{p}`, `P_{c}^{\text{buyer}}`, `S(T)`, `S(0)`, `\mathcal{D}_{T,0}`, `d_{+}`, `d_{-}`, `N(\cdot)`. The only swap is `\bar{r}` → `g_{y}`.
  - In the examples' markdown, `C_{0}`/`P_{0}` become `\mathcal{P}_{c}`/`\mathcal{P}_{p}`, `h` becomes `V`, and `\Pi` becomes `P`.
  - Code variable names are unchanged.
- **Figures:** every schematic is TikZ in `L9a/figs/`, built to PDF (deck) and themed SVG (notebook). The notebook uses L5b's embed (`<style>` block + `<div><center><img class="course-diagram" …>`).
- **Examples:**
  - Exactly three `## Task N:` sections.
  - Every `@assert` sits in one `# checks` block per cell, after the printout.
  - Stored outputs come from a fresh nbconvert run with no error outputs.
- **Advanced notebooks:** at most 2 in `L9a/advanced/`.
- **Commits:** do not commit. Each task ends by staging its files and proposing a commit message. The instructor decides when to commit (repo rule).
- **Do not touch:**
  - `lectures/week-8/` (the instructor is building the new L8b)
  - `lectures/week-13/` (L13a is paused)
  - the L7b files
  - the archive payloads, except the moves listed here
- **NEW prose:**
  - Read the style guide section "What the rounds show so far, for both courses" in `lectures/instructor/NOTEBOOK-STYLE-GUIDE.md` before Task 8.
  - Every NEW item is shown to the instructor as a before/after preview before the task is called done.
- **Dated facts:** every fact in the profile, the market table, and the hook needs a primary or reputable source. Check it at authoring time.

## Review Focus

1. **VS Code dark theme.** A TikZ color missing from `theme_svg.py`'s map would leave dark text on a dark editor. The build fails on an unmapped color, Task 2 renders both schemes with Chrome, and Task 11 asks the instructor to open the lecture in VS Code dark and light.
2. **The L9a bundle offline.** A student opens the unzipped week-9 L9a bundle without the rest of the repo. Every relative link and image must resolve inside `L9a/`. The checker's link test is in the `lecture`, `ex1`, and `ex2` groups.
3. **Example 1 runs from its new folder.** The archived notebook loads `Include.jl` from `@__DIR__` and uses `Colors`. Task 4 merges `Include.jl` and re-executes the notebook in place with nbconvert.
4. **Theory sprung in an example.** Example 1 checks breakevens and Example 2 checks put–call parity. The checker asserts that each display appears in the lecture before the matching example stop.
5. **Leftover symbols and pointers after the swaps.** A missed `C_{0}`, `h_{c}`, `\Pi`, `S_{0}`, "L8b", or "L9b" would contradict the lecture. The checker counts each banned token in the examples' markdown and requires zero.

---

### Task 1: Structural checker

**Files:**
- Create: `$W/check_l9a.py`

**Interfaces:**
- Produces: `python3 $W/check_l9a.py [group …]` with groups `figures`, `archive`, `ex1`, `ex2`, `advanced`, `lecture`, `records`. It prints `PASS`/`FAIL` lines and exits with the number of failures (0 = all pass).

- [ ] **Step 1: Create the work directory and write the checker**

```bash
mkdir -p build/notebook-previews/L9a-redesign-2026-10-09/new
```

Write `build/notebook-previews/L9a-redesign-2026-10-09/check_l9a.py`:

```python
#!/usr/bin/env python3
"""Structural checks for the L9a redesign (lectures/instructor/L9a-REDESIGN-SPEC.md).

Run from the repository root:
    python3 build/notebook-previews/L9a-redesign-2026-10-09/check_l9a.py [group ...]
Groups: figures, archive, ex1, ex2, advanced, lecture, records. No argument runs all.
Exit status is the number of failed checks.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path.cwd()
L9A = ROOT / "lectures/week-9/L9a"
LECTURE = L9A / "CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb"
EX1 = L9A / "CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb"
EX2 = L9A / "CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb"
ADV = L9A / "advanced/contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb"
FIGS = ["Fig-L9a-Contract-Right-Obligation", "Fig-L9a-Option-CashFlows"]
OLD_FIGS = ["Fig-American-Contract-Decision-Schematic",
            "Fig-HullExample-American-v-European-Schematic", "Fig-Lattice-Schematic"]
H2_ORDER = ["Examples", "Company Profile: Cboe Global Markets", "What is a Derivative?",
            "Call and Put Options Contracts", "Options as Abstract Assets",
            "European Style Contracts", "Summary", "Disclaimer and Risks"]
FORWARD = re.compile(r"\bL9b\b|\bL1[0-4][ab]\b|next lecture|next week", re.I)

failures = []


def check(name, ok, detail=""):
    print(f"{'PASS' if ok else 'FAIL'}  {name}" + (f"  -- {detail}" if detail and not ok else ""))
    if not ok:
        failures.append(name)


def cells(path):
    return json.loads(path.read_text())["cells"]


def src(cell):
    return "".join(cell["source"])


def prose(text):
    """Text with style blocks, math, code spans, HTML tags, and link targets removed.
    Math is removed before tags because inequalities such as S_T<K look like tags."""
    t = re.sub(r"<style>.*?</style>", "", text, flags=re.S)
    t = re.sub(r"\$\$.*?\$\$", "", t, flags=re.S)
    t = re.sub(r"\$[^$]*\$", "", t)
    t = re.sub(r"`[^`]*`", "", t)
    t = re.sub(r"<[^>]+>", "", t)
    t = re.sub(r"\]\([^)]*\)", "]", t)
    t = re.sub(r"^\[\d+\]:.*$", "", t, flags=re.M)
    return t


def relative_links(text):
    links = re.findall(r"\]\(([^)\s]+)\)", text) + re.findall(r'src="([^"]+)"', text)
    return [l for l in links if not re.match(r"[a-z]+:", l) and not l.startswith("#")]


def nospace(text):
    return re.sub(r"\s+", "", text)


def check_figures():
    figs = L9A / "figs"
    for f in FIGS:
        tex, pdf, svg = (figs / f"{f}.{e}" for e in ("tex", "pdf", "svg"))
        check(f"{f}.tex, .pdf, .svg exist", tex.exists() and pdf.exists() and svg.exists())
        if tex.exists() and pdf.exists() and svg.exists():
            check(f"{f} builds are current",
                  pdf.stat().st_mtime >= tex.stat().st_mtime and svg.stat().st_mtime >= pdf.stat().st_mtime)
            text = svg.read_text()
            check(f"{f}.svg carries the dark palette",
                  '<style id="course-theme">' in text and "prefers-color-scheme: dark" in text)
    for name in ("Makefile", "theme_svg.py", "vnfigure.sty", "README.md"):
        check(f"figs/{name} exists", (figs / name).exists())


def check_archive():
    dirs = sorted((ROOT / "lectures/archive").glob("week-9-L9a-before-redesign-*"))
    check("one pre-redesign L9a archive", len(dirs) == 1, f"{[d.name for d in dirs]}")
    if dirs:
        a = dirs[0]
        check("old lecture archived",
              (a / "week-9/L9a/CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb").exists())
        check("old deck archived", (a / "week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.tex").exists())
        check("archive README and SHA256SUMS", (a / "README.md").exists() and (a / "SHA256SUMS").exists())
    check("old lecture gone from L9a",
          not (L9A / "CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb").exists())
    stale = [p.name for p in (L9A / "figs").glob("*") if p.stem in OLD_FIGS]
    check("unused 2025 figures archived", not stale, f"{stale}")


def check_example(path, label, banned, must_contain=()):
    check(f"{label} exists", path.exists())
    if not path.exists():
        return
    cs = cells(path)
    md = "\n".join(src(c) for c in cs if c["cell_type"] == "markdown")
    tasks = re.findall(r"^## Task (\d+):", md, re.M)
    check(f"{label} has Tasks 1-3", tasks == ["1", "2", "3"], f"{tasks}")
    for b in banned:
        n = md.count(b)
        check(f"{label} markdown has no {b!r}", n == 0, f"{n} left")
    for needle in must_contain:
        check(f"{label} markdown contains {needle!r}", needle in md)
    check(f"{label} no forward pointers", not FORWARD.search(prose(md)), str(FORWARD.findall(prose(md))))
    semis = [l.strip()[:70] for l in prose(md).splitlines() if ";" in l]
    check(f"{label} no semicolons in prose", not semis, f"{semis}")
    bad = [l for l in relative_links(md) if l.startswith("..") or not (path.parent / l).exists()]
    check(f"{label} relative links resolve", not bad, f"{bad}")
    for i, c in enumerate(cs):
        if c["cell_type"] != "code":
            continue
        lines = src(c).splitlines()
        asserts = [k for k, l in enumerate(lines) if l.strip().startswith("@assert")]
        if not asserts:
            continue
        heads = [k for k, l in enumerate(lines) if re.match(r"\s*# checks[ :]", l)]
        check(f"{label} cell {i}: one checks header above the asserts",
              len(heads) == 1 and heads[0] < asserts[0], f"headers at {heads}, asserts at {asserts}")
        between = lines[asserts[0]:asserts[-1] + 1]
        stray = [l.strip() for l in between
                 if l.strip() and not re.match(r"\s*(@assert|#|for |end\b|if |else\b)", l)]
        check(f"{label} cell {i}: asserts are contiguous", not stray, f"{stray}")
    errors = [i for i, c in enumerate(cs) if c["cell_type"] == "code"
              for o in c.get("outputs", []) if o.get("output_type") == "error"]
    check(f"{label} no error outputs", not errors, f"cells {errors}")
    unrun = [i for i, c in enumerate(cs)
             if c["cell_type"] == "code" and src(c).strip() and c.get("execution_count") is None]
    check(f"{label} every code cell executed", not unrun, f"cells {unrun}")


def check_advanced():
    nbs = sorted((L9A / "advanced").rglob("*.ipynb"))
    nbs = [p for p in nbs if ".ipynb_checkpoints" not in p.parts]
    check("at most two advanced notebooks", len(nbs) <= 2, f"{[p.name for p in nbs]}")
    check("contingent claims notebook exists", ADV.exists())
    if ADV.exists():
        cs = cells(ADV)
        check("contingent claims is markdown only", all(c["cell_type"] == "markdown" for c in cs))
        md = "\n".join(src(c) for c in cs)
        check("contingent claims has three objectives",
              len(re.findall(r"^> \* __", src(cs[0]), re.M)) == 3)
        for needle in [r"q=\frac{R_f-d}{u-d}", r"\psi_u", "N(d_{-})", "N(d_{+})",
                       r"e^{sz}\varphi(z)=e^{s^{2}/2}\varphi(z-s)"]:
            check(f"contingent claims contains {needle}", nospace(needle) in nospace(md))
        check("contingent claims no forward pointers", not FORWARD.search(prose(md)))
        semis = [l.strip()[:70] for l in prose(md).splitlines() if ";" in l]
        check("contingent claims no semicolons", not semis, f"{semis}")
    readme = (L9A / "advanced/README.md").read_text()
    check("advanced README lists both notebooks", ADV.name in readme and "SPXW-Volatility-Skew" in readme)
    check("advanced README has no forward pointer", not FORWARD.search(readme))


def check_lecture():
    check("lecture exists", LECTURE.exists())
    if not LECTURE.exists():
        return
    cs = cells(LECTURE)
    check("lecture is markdown only", all(c["cell_type"] == "markdown" for c in cs))
    md = [src(c) for c in cs]
    text = "\n".join(md)
    check("title", md[0].startswith("# L9a: Introduction to Derivatives and European Option Pricing\n"))
    lo = md[0].split("> __Learning Objectives:__", 1)
    n_lo = len(re.findall(r"^> \* __", lo[1], re.M)) if len(lo) == 2 else 0
    check("three learning objectives", n_lo == 3, f"found {n_lo}")
    check("notation link", "faq/notation.html#L9a" in md[0])
    above = lo[0].split("\n", 1)[1] if len(lo) == 2 else ""
    n_words = len(prose(above).split())
    check("lead-in is 30-40 words", 30 <= n_words <= 40, f"{n_words} words")
    h2 = [m for s in md for m in re.findall(r"^## (.+)$", s, re.M)]
    check("H2 order", h2 == H2_ORDER, f"{h2}")
    for i, s in enumerate(md):
        if i > 0 and re.search(r"^## ", s, re.M):
            check(f"rule before the H2 in cell {i}", md[i - 1].rstrip().endswith("___"))
    summary = next((s for s in md if s.startswith("## Summary")), "")
    n_kt = len(re.findall(r"^> \* __", summary, re.M))
    check("three key takeaways", n_kt == 3, f"found {n_kt}")
    check("summary ends with a rule", summary.rstrip().endswith("___"))
    check("disclaimer is last and ends with a rule",
          md[-1].startswith("## Disclaimer") and md[-1].rstrip().endswith("___"))
    semis = [l.strip()[:70] for l in prose(text).splitlines() if ";" in l]
    check("no semicolons in prose", not semis, f"{semis}")
    check("no r-bar", r"\bar{r}" not in text)
    check("no max over tau", r"\max_{\tau" not in text)
    check("every expectation is under Q", not re.search(r"\\mathbb\{E\}\\Bigl", text))
    check("no utm links", "utm_source" not in text)
    check("no 2024 raster figure", "Fig-Options-Contracts-Fall-2024" not in text)
    check("no forward pointers", not FORWARD.search(prose(text)), str(FORWARD.findall(prose(text))))
    bad = [l for l in relative_links(text) if l.startswith("..") or not (L9A / l).exists()]
    check("relative links resolve inside L9a", not bad, f"{bad}")
    for fig in FIGS:
        cell = next((s for s in md if f'src="figs/{fig}.svg"' in s), "")
        check(f"{fig} embedded", bool(cell))
        check(f"{fig} has the theme block and class",
              "color-scheme: light dark" in cell and f'class="course-diagram" src="figs/{fig}.svg"' in cell)
        alt = re.search(rf'src="figs/{fig}\.svg"[^>]*alt="([^"]+)"', cell)
        check(f"{fig} alt text", bool(alt) and len(alt.group(1).split()) >= 10)
    callouts = re.findall(r"^> __Example:__\n>\n> \[▶ [^\]]+\]\(([^)]+)\)", text, re.M)
    check("two example stops, in order", callouts == [EX1.name, EX2.name], f"{callouts}")
    stops = [m.start() for m in re.finditer(r"^> __Example:__", text, re.M)]
    flat = text  # positions are compared on the raw text
    if len(stops) == 2:
        call_be = flat.find(r"S_{\text{BE}} = K + \mathcal{P}_{c}")
        put_be = flat.find(r"S_{\text{BE}} = K - \mathcal{P}_{p}")
        parity = flat.find(r"\mathcal{P}_{c}(K,S(0)) - \mathcal{P}_{p}(K,S(0))")
        check("breakevens stated before the Example 1 stop", -1 < call_be < stops[0] and -1 < put_be < stops[0])
        check("put-call parity stated before the Example 2 stop", stops[0] < parity < stops[1])


def check_records():
    d = json.loads((ROOT / "code/docs/faq-src/content.json").read_text())
    check("FAQ notation has an L9a table", any(e.get("lecture") == "L9a" for e in d["notation"]))
    check("FAQ lecture source for L9a", LECTURE.name in d["lecture_sources"].get("L9a", ""))
    check("FAQ notation page rebuilt", 'id="L9a"' in (ROOT / "code/docs/src/faq/notation.html").read_text())
    sched = (ROOT / "lectures/LECTURE-ARTIFACT-SCHEDULE.md").read_text()
    row = next((l for l in sched.splitlines() if l.startswith("| 9a ")), "")
    check("schedule 9a row updated", "Introduction to derivatives" in row, row)
    upd = (ROOT / "schedule-2026-update.md").read_text()
    f40 = next((l for l in upd.splitlines() if l.startswith("| `F40`")), "")
    check("F40 topic updated", "derivatives" in f40.lower(), f40)
    deck = L9A / "slides/CHEME-5660-L9a-Slides-Fall-2026.tex"
    check("deck exists", deck.exists())
    if deck.exists():
        t = deck.read_text()
        check("deck includes both figure PDFs", all(f"../figs/{f}.pdf" in t for f in FIGS))
        check("deck has no PNG figures", ".png" not in t)
        check("deck has no forward pointer", not FORWARD.search(t))
        check("deck has no C_0 or h_c notation", not re.search(r"C_0|C_\{0\}|h_c|h_\{c\}|\\Pi", t))
        pdf = deck.with_suffix(".pdf")
        check("deck PDF is current", pdf.exists() and pdf.stat().st_mtime >= deck.stat().st_mtime)
    l9b = (ROOT / "lectures/week-9/L9b/slides/CHEME-5660-L9b-Slides-Fall-2026.tex").read_text()
    check("L9b deck comment no longer cites L8b", "L8b" not in l9b)


GROUPS = {
    "figures": check_figures,
    "archive": check_archive,
    "ex1": lambda: check_example(
        EX1, "Example 1", ["C_{0}", "P_{0}", "h_{c}", "h_{p}", "\\Pi", "L8b"]),
    "ex2": lambda: check_example(
        EX2, "Example 2", ["C_{0}", "P_{0}", "h_{c}", "h_{p}", "S_{0}"], must_contain=["expected NPV"]),
    "advanced": check_advanced,
    "lecture": check_lecture,
    "records": check_records,
}

if __name__ == "__main__":
    for g in sys.argv[1:] or list(GROUPS):
        print(f"== {g}")
        GROUPS[g]()
    print(f"{len(failures)} failed")
    sys.exit(min(len(failures), 255))
```

- [ ] **Step 2: Run it on the current tree and confirm it fails where expected**

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/check_l9a.py`
Expected: nonzero exit, with FAIL lines for:
- figures that don't exist yet
- the missing archive
- `Example 1 exists`
- Example 2's banned `C_{0}`, `P_{0}`, `h_{c}`, `h_{p}`, `S_{0}`, its semicolons, and its checks headers
- `contingent claims notebook exists`
- `lecture exists`
- the records checks

It must not crash with a traceback. If it does, fix the checker before continuing.

- [ ] **Step 3: Stage nothing.** The checker lives in the ignored work directory.

---

### Task 2: TikZ figures with a light and dark pipeline

**Files:**
- Create: `lectures/week-9/L9a/figs/vnfigure.sty`, `Makefile`, `theme_svg.py`, `README.md`
- Create: `lectures/week-9/L9a/figs/Fig-L9a-Contract-Right-Obligation.tex`, `Fig-L9a-Option-CashFlows.tex`
- Generate: the `.pdf` and `.svg` of both figures
- Create: `$W/preview_themes.sh`

**Interfaces:**
- Produces:
  - `figs/Fig-L9a-Contract-Right-Obligation.{pdf,svg}`, which Task 7 embeds at width 780 and Task 9 includes as a PDF
  - `figs/Fig-L9a-Option-CashFlows.{pdf,svg}`, which Task 7 embeds at width 680 and Task 9 includes as a PDF

- [ ] **Step 1: Run the figures group and confirm it fails**

Run: `python3 $W/check_l9a.py figures` (with `W=build/notebook-previews/L9a-redesign-2026-10-09`)
Expected: FAIL for every figure file.

- [ ] **Step 2: Copy the thin style wrapper from L5b**

```bash
cp lectures/week-5/L5b/figs/vnfigure.sty lectures/week-9/L9a/figs/vnfigure.sty
```

- [ ] **Step 3: Write `figs/Makefile`.** Recipe lines start with a tab character.

```make
# Build standalone L9a figures to PDF (for the deck) and SVG (for the notebook).
#
#   make            build every figure in both formats
#   make pdf        PDF only
#   make svg        SVG only
#   make clean      remove LaTeX intermediates
#   make distclean  also remove the generated PDF/SVG

FIGURES := Fig-L9a-Contract-Right-Obligation Fig-L9a-Option-CashFlows

PDFS := $(addsuffix .pdf,$(FIGURES))
SVGS := $(addsuffix .svg,$(FIGURES))

XELATEX ?= xelatex
PDF2SVG ?= pdf2svg
PYTHON ?= python3
LATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error
STYLE := vnfigure.sty ../../../templates/vnfigure.sty ../../../templates/vnflow.sty

.PHONY: all pdf svg clean distclean
.DEFAULT_GOAL := all

all: pdf svg

pdf: $(PDFS)
svg: $(SVGS)

%.pdf: %.tex $(STYLE)
	$(XELATEX) $(LATEX_FLAGS) $<

# PDF conversion traces glyphs to paths, so the notebook SVG needs no fonts.
# theme_svg.py then adds the dark screen palette the lecture notebook relies on.
# The PDF keeps the light palette for the slides.
%.svg: %.pdf theme_svg.py
	$(PDF2SVG) $< $@
	$(PYTHON) theme_svg.py $@

clean:
	$(RM) *.aux *.log *.xdv *.fls *.fdb_latexmk *.out

distclean: clean
	$(RM) $(PDFS) $(SVGS)

.PRECIOUS: %.pdf
# A failed theme step must not leave an unthemed SVG that later looks current.
.DELETE_ON_ERROR:
```

Verify the tabs: `grep -c $'^\t' lectures/week-9/L9a/figs/Makefile` should print `5`.

- [ ] **Step 4: Copy `theme_svg.py` from L5b and replace its color map**

```bash
cp lectures/week-5/L5b/figs/theme_svg.py lectures/week-9/L9a/figs/theme_svg.py
```

In `lectures/week-9/L9a/figs/theme_svg.py`, replace the whole `DARK_COLORS = { … }` block with:

```python
# Light TikZ color (vnflow.sty palette and its tints) -> dark screen color.
DARK_COLORS = {
    (32, 33, 36): "#e3e6ea",     # vnink: heading, bullets, premium arrows, timeline
    (95, 99, 104): "#aeb4ba",    # vnmuted: sublabels, legends, dotted arrows, annotations, brace
    (26, 82, 118): "#8cc0e6",    # vnlink: call heading, buyer box, received arrow
    (118, 151, 173): "#4f7ea3",  # vnlink!60: call card border and rule
    (179, 27, 27): "#ff8879",    # vncarnelian: put heading, seller box, paid arrow
    (209, 118, 118): "#a3524c",  # vncarnelian!60: put card border and rule
    (255, 255, 255): "#1f1f1f",  # white: time-point unit fill, matched to VS Code's dark editor
}
```

Leave the rest of the file unchanged, including the unmapped-color error and the inline-style refusal.

- [ ] **Step 5: Write `figs/Fig-L9a-Contract-Right-Obligation.tex`**

```latex
% L9a schematic: an option gives the buyer a right and the seller an obligation.
% TikZ remake of the instructor's Fig-Options-Contracts-Fall-2024.png (archived in
% lectures/archive/week-8-L8b-options-2026-10-09/week-8/L8b/figs/), laid out like the
% archived L8b remake. Labels follow the L9a lecture: buyer and seller, strike K,
% premiums \mathcal{P}_c and \mathcal{P}_p. Solid arrow: always paid. Dotted arrow:
% only if the buyer exercises. There is no background fill, so the notebook SVG can
% follow a dark theme (see theme_svg.py). Every color must be mapped there.
\documentclass[tikz,border=4pt]{standalone}
\usepackage{vnfigure}

\newcommand{\fLabel}{\sffamily\fontsize{7.4}{9}\selectfont}
\newcommand{\fMeta}{\sffamily\fontsize{8}{10.2}\selectfont}
\newcommand{\fData}{\sffamily\fontsize{9}{11}\selectfont}
\newcommand{\fHead}{\sffamily\fontsize{12}{14}\selectfont}

\begin{document}
\begin{tikzpicture}[x=1cm,y=1cm,font=\sffamily]
  \path[use as bounding box] (0.50,0.25) rectangle (15.50,8.85);

  % Heading: the instructor's definition from the 2024 figure -----------------
  \node[anchor=north west,font=\fData,text=vnink,text width=14.4cm,align=left] at (0.70,8.75) {%
    \textbf{Equity derivatives (options)} are temporary structured agreements between an
    option seller and an option buyer to transact (buy or sell) an underlying asset
    (shares of stock) at a specified price.};

  % ===================== CALL CARD =========================================
  \draw[vnlink!60,rounded corners=4pt,line width=0.8pt] (0.70,3.95) rectangle (15.30,7.25);
  \node[anchor=west,font=\fHead\bfseries,text=vnlink] at (0.92,6.92) {Call contract};
  \node[anchor=west,font=\fLabel,text=vnmuted] at (0.94,6.60) {THE RIGHT TO BUY AT $K$};
  \draw[vnlink!60,line width=0.5pt] (0.92,6.42) -- (15.08,6.42);
  \node[anchor=north west,font=\fMeta,text=vnink,text width=7.20cm,align=left] at (0.92,6.24) {%
    \textbullet\; The \textbf{buyer} has the right, but not the obligation, to buy
    shares at $K$ from the seller.\\[4pt]
    \textbullet\; The \textbf{seller} has the obligation to sell shares at $K$ if
    the buyer exercises.};

  \draw[vnlink,rounded corners=3pt,line width=0.9pt] (8.40,4.48) rectangle (9.85,5.86);
  \node[font=\fMeta\bfseries,text=vnlink] at (9.125,5.36) {Buyer};
  \node[font=\fLabel,text=vnmuted] at (9.125,4.98) {right};
  \draw[vncarnelian,rounded corners=3pt,line width=0.9pt] (13.65,4.48) rectangle (15.10,5.86);
  \node[font=\fMeta\bfseries,text=vncarnelian] at (14.375,5.36) {Seller};
  \node[font=\fLabel,text=vnmuted] at (14.375,4.98) {obligation};

  \draw[vnink,line width=1.0pt,-{Latex[length=2.4mm]}] (9.95,5.62) -- (13.55,5.62)
    node[midway,above=1.5pt,font=\fLabel,text=vnink] {buyer pays premium $\mathcal{P}_{c}$};
  \draw[vnmuted,line width=0.9pt,densely dotted,-{Latex[length=2.4mm]}] (13.55,4.80) -- (9.95,4.80)
    node[midway,above=1.5pt,font=\fLabel,text=vnmuted] {seller must sell shares at $K$};
  \node[anchor=north east,font=\fLabel,text=vnmuted] at (15.10,4.36)
    {solid: always paid. dotted: only if the buyer exercises.};

  % ===================== PUT CARD ==========================================
  \draw[vncarnelian!60,rounded corners=4pt,line width=0.8pt] (0.70,0.45) rectangle (15.30,3.75);
  \node[anchor=west,font=\fHead\bfseries,text=vncarnelian] at (0.92,3.42) {Put contract};
  \node[anchor=west,font=\fLabel,text=vnmuted] at (0.94,3.10) {THE RIGHT TO SELL AT $K$};
  \draw[vncarnelian!60,line width=0.5pt] (0.92,2.92) -- (15.08,2.92);
  \node[anchor=north west,font=\fMeta,text=vnink,text width=7.20cm,align=left] at (0.92,2.74) {%
    \textbullet\; The \textbf{buyer} has the right, but not the obligation, to sell
    shares at $K$ to the seller.\\[4pt]
    \textbullet\; The \textbf{seller} has the obligation to buy shares at $K$ if
    the buyer exercises.};

  \draw[vnlink,rounded corners=3pt,line width=0.9pt] (8.40,0.98) rectangle (9.85,2.36);
  \node[font=\fMeta\bfseries,text=vnlink] at (9.125,1.86) {Buyer};
  \node[font=\fLabel,text=vnmuted] at (9.125,1.48) {right};
  \draw[vncarnelian,rounded corners=3pt,line width=0.9pt] (13.65,0.98) rectangle (15.10,2.36);
  \node[font=\fMeta\bfseries,text=vncarnelian] at (14.375,1.86) {Seller};
  \node[font=\fLabel,text=vnmuted] at (14.375,1.48) {obligation};

  \draw[vnink,line width=1.0pt,-{Latex[length=2.4mm]}] (9.95,2.12) -- (13.55,2.12)
    node[midway,above=1.5pt,font=\fLabel,text=vnink] {buyer pays premium $\mathcal{P}_{p}$};
  \draw[vnmuted,line width=0.9pt,densely dotted,-{Latex[length=2.4mm]}] (9.95,1.30) -- (13.55,1.30)
    node[midway,above=1.5pt,font=\fLabel,text=vnmuted] {seller must buy shares at $K$};
  \node[anchor=north east,font=\fLabel,text=vnmuted] at (15.10,0.86)
    {solid: always paid. dotted: only if the buyer exercises.};
\end{tikzpicture}
\end{document}
```

- [ ] **Step 6: Write `figs/Fig-L9a-Option-CashFlows.tex`**

```latex
% L9a option cash-flow timeline (lecture section "Options as Abstract Assets").
% Modeled on L2a's Fig-L2a-TBill-CashFlows.tex: same timeline, time-point units,
% and paid/received arrow styles. Keep it structural: the NPV and the pricing
% condition belong in the notebook.
% Flow convention: an arrow leaving a time-point unit is money paid,
% and an arrow entering one is money received.
% color=vnink replaces TikZ's default black, which theme_svg.py cannot map.
\documentclass[tikz,border=6pt]{standalone}
\usepackage{vnfigure}

\begin{document}
\begin{tikzpicture}[x=2.0cm,y=1cm,>=Latex,font=\sffamily\small,color=vnink]

  % Span label ------------------------------------------------
  \draw[vn brace] (0.45,1.65) -- (3.40,1.65)
    node[midway,above=7pt,text=vnink]
    {\bfseries option: premium today, uncertain payoff at expiration};

  % Timeline --------------------------------------------------
  \draw[vn timeline] (0,0) -- (4.05,0) node[right] {time};
  \node[vn unit] (b0) at (0.45,0) {};
  \node[vn unit] (bT) at (3.40,0) {};
  \node[below=4pt] at (b0) {$t=0$};
  \node[below=4pt] at (bT) {$t=T$};

  % Premium paid at the valuation date -------------------------
  \draw[vn paid] (b0.north) -- (0.45,1.05);
  \node[right,text=vncarnelian] at (0.45,0.62) {$-\mathcal{P}$};
  \node[above,vn annotation] at (0.45,1.05) {premium paid};

  % Payoff received at expiration, possibly zero ----------------
  \draw[vn received,dashed] (3.40,1.05) -- (bT.north);
  \node[right,text=vnlink] at (3.40,0.62) {$+V(K,S(T))\geq 0$};
  \node[above,vn annotation] at (3.40,1.05) {payoff received, may be zero};

\end{tikzpicture}
\end{document}
```

- [ ] **Step 7: Build both figures**

Run: `make -C lectures/week-9/L9a/figs distclean all`
Expected: both PDFs and SVGs are written with no `KeyError: No dark color mapped`. If the theme step reports an unmapped color, add that color's dark value to `DARK_COLORS` with a comment naming the TikZ color it comes from. Never remove the error.

- [ ] **Step 8: Write `$W/preview_themes.sh` and render both schemes**

```bash
#!/usr/bin/env bash
# Render each L9a figure SVG in the light and dark color schemes with headless Chrome.
# The <img> color-scheme is what VS Code's theme forwarding sets in the notebook.
# Usage (repo root): bash build/notebook-previews/L9a-redesign-2026-10-09/preview_themes.sh
set -euo pipefail
OUT="build/notebook-previews/L9a-redesign-2026-10-09/figures"
mkdir -p "$OUT"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
for fig in Fig-L9a-Contract-Right-Obligation Fig-L9a-Option-CashFlows; do
  cp "lectures/week-9/L9a/figs/$fig.svg" "$OUT/$fig.svg"
  for scheme in light dark; do
    if [ "$scheme" = dark ]; then bg='#1f1f1f'; else bg='#ffffff'; fi
    cat > "$OUT/$fig-$scheme.html" <<EOF
<!doctype html><html><head><style>:root{color-scheme:$scheme;background:$bg}body{margin:16px}img{color-scheme:$scheme;width:1000px}</style></head><body><img src="$fig.svg"></body></html>
EOF
    "$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1032,760 \
      --screenshot="$OUT/$fig-$scheme.png" "file://$PWD/$OUT/$fig-$scheme.html" >/dev/null 2>&1
  done
done
ls -1 "$OUT"/*.png
```

Run: `bash build/notebook-previews/L9a-redesign-2026-10-09/preview_themes.sh`
Expected: four PNGs. Open each one with the Read tool and check:
- No label overlaps a box, a card edge, or another label.
- In the dark PNG, every text item and arrow is readable. Nothing is dark-on-dark.
- The heading wraps inside the figure and stays above the call card.

If a label collides, move only that node's coordinates, rebuild (Step 7), and re-render.

- [ ] **Step 9: Write `figs/README.md`**

```markdown
# L9a figures

`Fig-L9a-Contract-Right-Obligation` is the call and put schematic at the top of
the lecture's "Call and Put Options Contracts" section. It is a TikZ remake of
the instructor's 2024 raster figure, which is archived in
`lectures/archive/week-8-L8b-options-2026-10-09/week-8/L8b/figs/`.
`Fig-L9a-Option-CashFlows` is the option cash-flow timeline that opens "Options
as Abstract Assets". It is modeled on L2a's T-bill timeline.

`make` builds each figure's PDF with XeLaTeX and converts it to SVG with
`pdf2svg`. The SVG build also runs `theme_svg.py`, which adds a dark screen
palette in a `<style>` block keyed on the light colors. The notebook's image
block passes VS Code's selected theme to the SVG, so changing the editor theme
repaints the figure. Outside VS Code the image follows the viewer's color
scheme, and print uses the light palette. If the TikZ palette changes, update
the color map in `theme_svg.py`. An unmapped color fails the build on purpose.
The white fill of the time-point units maps to VS Code's default dark editor
background.

The slides include the PDFs, which keep the light palette (XeLaTeX cannot
include SVG directly).
```

- [ ] **Step 10: Run the figures group**

Run: `python3 $W/check_l9a.py figures`
Expected: all PASS.

- [ ] **Step 11: Checkpoint A (instructor).** Show the four PNGs with `open build/notebook-previews/L9a-redesign-2026-10-09/figures/*.png`. Then report:
  - The contract figure keeps his definition sentence and his right/obligation layout.
  - Label changes from his 2024 figure:
    - "in T days" is dropped (T is in years in this lecture).
    - "probability p" becomes "only if the buyer exercises" (p is the Kalshi price here).
    - The premium arrow names 𝒫_c and 𝒫_p.
  - The timeline is **NEW**. Ask whether to keep it. If he drops it, set `CASHFLOW_FIGURE = False` in Task 7's assembler. Also remove the figure from the Makefile, the README, the checker's `FIGS`, and Task 9's bridge frame.

  Wait for his answer before Task 7.

- [ ] **Step 12: Stage**

```bash
git add lectures/week-9/L9a/figs/{Makefile,theme_svg.py,vnfigure.sty,README.md} \
        lectures/week-9/L9a/figs/Fig-L9a-*.{tex,pdf,svg}
```

Proposed commit message: `L9a figures: TikZ contract and cash-flow schematics with a dark palette`.

---

### Task 3: Archive the pre-redesign L9a lecture, deck, and unused figures

**Files:**
- Move: `lectures/week-9/L9a/CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb`, `slides/CHEME-5660-L9a-Slides-Fall-2026.{tex,pdf}`, `figs/Fig-American-Contract-Decision-Schematic.{pdf,png}`, `figs/Fig-HullExample-American-v-European-Schematic.{pdf,png}`, `figs/Fig-Lattice-Schematic.{pdf,svg}` → `lectures/archive/week-9-L9a-before-redesign-<YYYY-MM-DD>/week-9/L9a/…` (use the build date)
- Create: that archive's `README.md` and `SHA256SUMS`
- Modify: `lectures/archive/week-8-L8b-options-2026-10-09/README.md` (the `figs/` row)

**Interfaces:**
- Produces: the archived old lecture path, from which Task 7 reads notebook metadata (`kernelspec`, `language_info`). The archived old deck is a source for Task 9.

- [ ] **Step 1: Run the archive group and confirm it fails**

Run: `python3 $W/check_l9a.py archive`
Expected: FAIL for `one pre-redesign L9a archive`, `old lecture gone from L9a`, and `unused 2025 figures archived`.

- [ ] **Step 2: Record what the old lecture links**

Run: `grep -o 'advanced/[^)"]*' lectures/week-9/L9a/CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb | sort -u`
Note the output for the Task 11 handoff. If the old lecture linked the SPXW skew notebook, the new lecture no longer does. That goes in the flags for the instructor. Do not add a link.

- [ ] **Step 3: Move with history**

```bash
D=$(date +%F); A="lectures/archive/week-9-L9a-before-redesign-$D/week-9/L9a"
mkdir -p "$A/slides" "$A/figs"
git mv lectures/week-9/L9a/CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb "$A/"
git mv lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.tex "$A/slides/"
git mv lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.pdf "$A/slides/"
for f in Fig-American-Contract-Decision-Schematic.pdf Fig-American-Contract-Decision-Schematic.png \
         Fig-HullExample-American-v-European-Schematic.pdf Fig-HullExample-American-v-European-Schematic.png \
         Fig-Lattice-Schematic.pdf Fig-Lattice-Schematic.svg; do
  git mv "lectures/week-9/L9a/figs/$f" "$A/figs/"
done
(cd "lectures/archive/week-9-L9a-before-redesign-$D" && git ls-files -z week-9 | xargs -0 shasum -a 256 > SHA256SUMS)
```

If any `git mv` reports "not under version control", run `git ls-files lectures/week-9/L9a` to see what is tracked. Move an untracked file with plain `mv` and note it in the README.

- [ ] **Step 4: Write the archive README** at `lectures/archive/week-9-L9a-before-redesign-<date>/README.md`:

```markdown
# L9a before the October 2026 redesign

L9a was rebuilt as "Introduction to Derivatives and European Option Pricing"
after options moved out of L8b. The design and its steps are in
`lectures/instructor/L9a-REDESIGN-SPEC.md` and `L9a-REDESIGN-PLAN.md`. This
snapshot holds the files the rebuild replaced. `SHA256SUMS` records them.

| File | Status |
| --- | --- |
| `CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb` | Retired. The new lecture is assembled from the instructor's Fall-2025 text. |
| `slides/` | The pre-redesign deck. Its BSM, risk-neutral, and parity frames are a source for the rebuilt deck. |
| `figs/` | Three figures that nothing in week 9 referenced. L9b keeps its own Hull PNG, and L3b and L4a keep their own lattice SVG. |

The instructor asked that cut material not move into a later week. To reuse a
file, move it out with `git mv` rather than editing it here.
```

- [ ] **Step 5: Correct the L8b archive README's `figs/` row**

In `lectures/archive/week-8-L8b-options-2026-10-09/README.md`, replace the `figs/` row with:

```markdown
| `figs/` | `Fig-Options-Contracts-Fall-2024.png` (his raster) and the L8b TikZ remake are the sources of L9a's `Fig-L9a-Contract-Right-Obligation`. Both stay here. |
```

- [ ] **Step 6: Run the archive group**

Run: `python3 $W/check_l9a.py archive`
Expected: all PASS.

- [ ] **Step 7: Stage** with `git add -A lectures/archive/week-9-L9a-before-redesign-*/ lectures/archive/week-8-L8b-options-2026-10-09/README.md lectures/week-9/L9a`. Proposed message: `L9a: archive the pre-redesign lecture, deck, and unused figures`.

---

### Task 4: Example 1 (single-contract payoff and profit)

**Files:**
- Move: `lectures/archive/week-8-L8b-options-2026-10-09/week-8/L8b/CHEME-5660-L8b-Example-SingleContractPayoffProfit-Fall-2026.ipynb` → `lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb`
- Modify: that notebook's markdown cells 0, 14, 15, 17, 23, 28, 34, 37, and 40, and its code cells 24 and 35
- Modify: `lectures/week-9/L9a/Include.jl`
- Modify: `lectures/archive/week-8-L8b-options-2026-10-09/README.md` (the example's row)
- Create: `$W/edit_ex1.py`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `EX1` at the path above. The lecture (Task 7) links it by file name.

- [ ] **Step 1: Run ex1 and confirm it fails**

Run: `python3 $W/check_l9a.py ex1`
Expected: `FAIL  Example 1 exists`.

- [ ] **Step 2: Move it**

```bash
git mv lectures/archive/week-8-L8b-options-2026-10-09/week-8/L8b/CHEME-5660-L8b-Example-SingleContractPayoffProfit-Fall-2026.ipynb \
       lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb
```

In the L8b archive README, change the example's status to: `Moved to L9a as its first example (October 2026).` Leave `SHA256SUMS` alone, because it records the snapshot as taken.

- [ ] **Step 3: Write `$W/edit_ex1.py`.** It makes every markdown and code change and asserts each match count.

```python
#!/usr/bin/env python3
"""Mechanical edits to L9a Example 1 (spec: Examples, item 1). Run from the repo root."""
import json
from pathlib import Path

P = Path("lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb")
nb = json.loads(P.read_text())
C = nb["cells"]


def get(i):
    return "".join(C[i]["source"])


def put(i, s):
    C[i]["source"] = s.splitlines(keepends=True)


def sub(i, old, new, count=1):
    s = get(i)
    n = s.count(old)
    assert n == count, f"cell {i}: expected {count} of {old!r}, found {n}"
    put(i, s.replace(old, new))


# 1. lecture mentions written from L8b's point of view (spec: Examples, item 1)
sub(14, "which is what L9a does", "which is what the BSM premium example does")
sub(14, "and the premium only; the price of the underlying", "and the premium only. The price of the underlying")
sub(15, "L9a and L9b take up the difference.", "The lecture takes up the difference.")

# 2. three-task rule: regroup the side-by-side table as Task 3
sub(37, "## The Four Positions Side by Side\nCollecting the analytical results",
        "## Task 3: The Four Positions Side by Side\nIn this task, we collect the analytical results")

# 3. remaining semicolons
sub(34, "has no finite terminal loss bound; a __short put__ does.",
        "has no finite terminal loss bound. A __short put__ does.")
sub(37, "Same number, two conventions; read the column name.", "Same number, two conventions. Read the column name.")
sub(40, "Payoff is contractual; profit is yours.", "Payoff is contractual. Profit is yours.")

# 4. tie the lecture symbols to the code variables at first use
sub(17, "The buyer pays this premium and the seller collects it.",
        "The buyer pays this premium, $\\mathcal{P}_{c}$ (`C₀` in the code), and the seller collects it.")
sub(28, "Again, the quoted premium is per share",
        "Again, the quoted premium, $\\mathcal{P}_{p}$ (`P₀` in the code), is per share")

# 5. symbol swaps in markdown (code is unchanged)
SWAPS = [
    ("\\Pi_{T}^{\\,c,+1}(S_{T})", "P_{c}^{\\text{buyer}}(K,S_{T})"),
    ("\\Pi_{T}^{\\,p,+1}(S_{T})", "P_{p}^{\\text{buyer}}(K,S_{T})"),
    ("\\Pi_{T}^{\\,c,-1}", "P_{c}^{\\text{seller}}"),
    ("\\Pi_{T}^{\\,c,+1}", "P_{c}^{\\text{buyer}}"),
    ("h_{c}(S_{T};K)", "V_{c}(K,S_{T})"),
    ("h_{p}(S_{T};K)", "V_{p}(K,S_{T})"),
    ("C_{0}", "\\mathcal{P}_{c}"),
    ("P_{0}", "\\mathcal{P}_{p}"),
]
for old, new in SWAPS:
    total = 0
    for i, c in enumerate(C):
        if c["cell_type"] == "markdown" and old in get(i):
            total += get(i).count(old)
            put(i, get(i).replace(old, new))
    print(f"{total:3d} x {old} -> {new}")
    assert total > 0, f"no {old} found"

# 6. checks rule (October 8): compute, print, one checks block, confirmation
put(24, """let
    breakeven   = Kc + C₀;
    i_be        = argmin(abs.(S_expiration .- breakeven));
    i_zero      = argmin(abs.(S_expiration .- 0.0));

    println("  breakeven                       : $(round(breakeven, digits=2)) USD/share");
    println("  long call max loss              : $(round(minimum(profit_call_long[:,2]), digits=2)) USD/share  (= -C₀)");
    println("  long call profit at Sₜ = 2K     : $(round(profit_call_long[end,2], digits=2)) USD/share  (grows without bound)");
    println("  short call max profit           : $(round(maximum(profit_call_short[:,2]), digits=2)) USD/share  (= C₀)");
    println("  short call profit at Sₜ = 2K    : $(round(profit_call_short[end,2], digits=2)) USD/share  (falls without bound)");

    # checks: breakeven, mirror image, and the premium bounds of the call -
    @assert abs(profit_call_long[i_be, 2]) ≤ 0.5   "long call profit is not zero at K + C₀"
    @assert abs(profit_call_short[i_be, 2]) ≤ 0.5  "short call profit is not zero at K + C₀"
    @assert all(isapprox.(profit_call_long[:,2], -profit_call_short[:,2]; atol = 1e-10)) "long and short call profits are not mirror images"
    @assert isapprox(minimum(profit_call_long[:,2]), -C₀; atol = 1e-10) "long call maximum loss is not C₀"
    @assert isapprox(profit_call_long[i_zero, 2], -C₀; atol = 1e-10)    "long call does not lose exactly C₀ at S_T = 0"
    @assert isapprox(maximum(profit_call_short[:,2]), C₀; atol = 1e-10) "short call maximum profit is not C₀"
    println("All call-contract checks passed.");
end""")
put(35, """let
    breakeven = Kp - P₀;
    i_be      = argmin(abs.(S_expiration_put .- breakeven));

    println("  breakeven                    : $(round(breakeven, digits=2)) USD/share");
    println("  long put max loss            : $(round(minimum(profit_put_long[:,2]), digits=2)) USD/share  (= -P₀)");
    println("  long put max profit at Sₜ = 0: $(round(maximum(profit_put_long[:,2]), digits=2)) USD/share  (= K - P₀, FINITE)");
    println("  short put max profit         : $(round(maximum(profit_put_short[:,2]), digits=2)) USD/share  (= P₀)");
    println("  short put worst case         : $(round(minimum(profit_put_short[:,2]), digits=2)) USD/share  = $(round(q*minimum(profit_put_short[:,2]), digits=2)) USD/contract, and it is FINITE");

    # checks: breakeven, mirror image, and the finite bounds of the put -
    @assert abs(profit_put_long[i_be, 2]) ≤ 0.5  "long put profit is not zero at K - P₀"
    @assert all(isapprox.(profit_put_long[:,2], -profit_put_short[:,2]; atol = 1e-10)) "long and short put profits are not mirror images"
    @assert isapprox(minimum(profit_put_long[:,2]), -P₀;      atol = 1e-10) "long put maximum loss is not P₀"
    @assert isapprox(maximum(profit_put_long[:,2]), Kp - P₀;  atol = 1e-10) "long put maximum profit is not K - P₀"
    @assert isapprox(profit_put_long[1,2],          Kp - P₀;  atol = 1e-10) "long put maximum profit is not attained at S_T = 0"
    @assert isapprox(minimum(profit_put_short[:,2]), P₀ - Kp; atol = 1e-10) "short put worst case is not P₀ - K"
    @assert isfinite(minimum(profit_put_short[:,2]))                        "short put worst case is not finite"
    println("All put-contract checks passed.");
end""")

P.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
print("Example 1 edited")
```

Before running it, compare cells 24 and 35 with the archived originals. The `let` bodies above must keep every original assertion and printout, reordered only. If the original has a line not listed here, add it in the same position class (compute, print, or checks).

- [ ] **Step 4: Run it**

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/edit_ex1.py`
Expected: eight swap lines with positive counts (about 10 × `P_{0}`, 7 × `C_{0}`, and the rest), then `Example 1 edited`.

- [ ] **Step 5: Merge `Include.jl`.** In `lectures/week-9/L9a/Include.jl`:
  - Replace the two comment lines under `# setup paths -` with:

    ```julia
    # L9a uses no local source or data: the options chain and the pricing models
    # ship with VLQuantitativeFinancePackage, and the figures are prebuilt in figs/.
    ```

  - Add `using Colors` after `using PrettyTables`.

- [ ] **Step 6: Re-execute in place**

```bash
/opt/anaconda3/bin/jupyter nbconvert --to notebook --execute \
  --ExecutePreprocessor.kernel_name=julia-1.12 --ExecutePreprocessor.timeout=420 \
  --output-dir build/notebook-previews/L9a-redesign-2026-10-09/exec --output ex1.ipynb \
  lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb
python3 -c "import json;nb=json.load(open('build/notebook-previews/L9a-redesign-2026-10-09/exec/ex1.ipynb'));print([i for i,c in enumerate(nb['cells']) for o in c.get('outputs',[]) if o.get('output_type')=='error'])"
```

Expected: `[]`. Then copy the executed notebook over the original:
```bash
cp build/notebook-previews/L9a-redesign-2026-10-09/exec/ex1.ipynb lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb
```

- [ ] **Step 7: Run ex1**

Run: `python3 $W/check_l9a.py ex1`
Expected: all PASS. The Summary's last sentence ("Understanding single contracts prepares us for composite strategies...") is a soft forward pointer that the checker does not catch. Record it for the Task 11 flags and do not edit it.

- [ ] **Step 8: Stage** with `git add lectures/week-9/L9a/CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb lectures/week-9/L9a/Include.jl lectures/archive/week-8-L8b-options-2026-10-09/README.md`. Proposed message: `L9a Example 1: move from the L8b archive, align symbols, regroup checks`.

---

### Task 5: Example 2 (BSM premium)

**Files:**
- Modify: `lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb` (markdown cells 4, 6, 14, 19, 20, 26, 33, 35, and code cells 27 and 30)
- Create: `$W/edit_ex2.py`

**Interfaces:**
- Produces: `EX2` with stored outputs. Task 6's verifier reads the `call premium C₀ (BSM)` and `put premium P₀ (BSM)` rows from cell 27's text output.

- [ ] **Step 1: Run ex2 and confirm it fails**

Run: `python3 $W/check_l9a.py ex2`
Expected: FAIL for:
- the banned `C_{0}`, `P_{0}`, `h_{c}`, `h_{p}`, and `S_{0}`
- the semicolons
- the forward pointer (`L9b`)
- `expected NPV`
- the cell 27 and cell 30 checks headers

- [ ] **Step 2: Write `$W/edit_ex2.py`**

```python
#!/usr/bin/env python3
"""Edits to L9a Example 2 (spec: Examples, item 2). Run from the repo root."""
import json
from pathlib import Path

P = Path("lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb")
nb = json.loads(P.read_text())
C = nb["cells"]


def get(i):
    return "".join(C[i]["source"])


def put(i, s):
    C[i]["source"] = s.splitlines(keepends=True)


def sub(i, old, new, count=1):
    s = get(i)
    n = s.count(old)
    assert n == count, f"cell {i}: expected {count} of {old!r}, found {n}"
    put(i, s.replace(old, new))


# 1. symbol swaps in markdown
sub(6, "{h_{c}}(S_{T};K)", "{V_{c}}(K,S_{T})")
sub(6, "where $h_{c}(S_{T};K) = \\max(S_{T}-K, 0)$", "where $V_{c}(K,S_{T}) = \\max(S_{T}-K, 0)$")
sub(20, "{h_{p}}(S_{T};K)", "{V_{p}}(K,S_{T})")
sub(20, "where $h_{p}(S_{T};K) = \\max(K-S_{T}, 0)$", "where $V_{p}(K,S_{T}) = \\max(K-S_{T}, 0)$")
for i in range(len(C)):
    if C[i]["cell_type"] != "markdown":
        continue
    s = get(i).replace("C_{0}", "\\mathcal{P}_{c}").replace("P_{0}", "\\mathcal{P}_{p}").replace("S_{0}", "S(0)")
    put(i, s)

# 2. semicolons
sub(14, "The package names that field `r`; it carries", "The package names that field `r`. It carries")
sub(35, "implemented consistently; put-call parity provides", "implemented consistently. Put-call parity provides")

# 3. tie the symbols to the code variables used in the checks
sub(26, "Do the checks pass, and by how much?",
        "The code stores $\\mathcal{P}_{c}$ and $\\mathcal{P}_{p}$ as `C₀` and `P₀`.\n\nDo the checks pass, and by how much?")

# 4. forward pointer -> the NPV reading (spec: Examples, item 2)
sub(35, "Next, L9b adds the American exercise right, prices it by backward induction on a lattice, and compares the American premium with the European benchmark computed here.",
        "Both routes compute the same model value, so at the BSM premium the contract's expected NPV under $\\mathbb{Q}$ is zero to within the Monte Carlo standard error.")

# 5. checks rule (October 8)
put(27, """let

    # closed-form premiums -
    C₀ = premium(call_contract_model, bsm_model);
    P₀ = premium(put_contract_model, bsm_model);

    # put-call parity: C₀ - P₀ = Sₒ - K·𝒟⁻¹. The package rounds each premium to four
    # significant digits, so the residual is bounded by that rounding, not by eps() -
    parity_lhs = C₀ - P₀;
    parity_rhs = Sₒ - K*(1/𝒟(gᵧ,T));

    # largest-sample discrepancies in Monte Carlo standard-error units -
    call_row = call_price_df[end,:];
    put_row = put_price_df[end,:];
    call_z = (call_row.mean_premium - C₀)/call_row.SE;
    put_z = (put_row.mean_premium - P₀)/put_row.SE;

    table = DataFrame(
        quantity = ["call premium C₀ (BSM)", "put premium P₀ (BSM)",
                    "C₀ - P₀", "Sₒ - K·𝒟⁻¹", "parity residual",
                    "call (MC - BSM) in SE", "put (MC - BSM) in SE"],
        value = round.([C₀, P₀, parity_lhs, parity_rhs, parity_lhs - parity_rhs,
                        call_z, put_z], digits = 6)
    );

    # checks: premiums are nonnegative, parity holds to the quoted precision, and the
    # seeded Monte Carlo estimates sit within three standard errors of BSM -
    @assert C₀ ≥ 0.0 "the call premium is negative"
    @assert P₀ ≥ 0.0 "the put premium is negative"
    @assert isapprox(parity_lhs, parity_rhs; atol = 1e-3) "put-call parity fails by more than the quoted precision"
    @assert abs(call_z) ≤ 3.0 "seeded call estimate is more than three standard errors from BSM"
    @assert abs(put_z) ≤ 3.0 "seeded put estimate is more than three standard errors from BSM"

    table
end""")
sub(30, "    # a premium is a price: it cannot be negative, and it must move the right way with K -",
        "    # checks: a premium is a price, so it cannot be negative, and it must move the right way with K -")

P.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
print("Example 2 edited")
```

Before running it, compare cell 27 with the current file. Every variable in the new body (`Sₒ`, `K`, `𝒟`, `gᵧ`, `T`, `call_price_df`, `put_price_df`) must already be defined by earlier cells. Check the exact wording of the cell 30 comment line with `grep -n "a premium is a price" …`, and adjust the `old` string if its spacing differs.

- [ ] **Step 3: Run it and re-execute**

```bash
python3 build/notebook-previews/L9a-redesign-2026-10-09/edit_ex2.py
/opt/anaconda3/bin/jupyter nbconvert --to notebook --execute \
  --ExecutePreprocessor.kernel_name=julia-1.12 --ExecutePreprocessor.timeout=420 \
  --output-dir build/notebook-previews/L9a-redesign-2026-10-09/exec --output ex2.ipynb \
  lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb
python3 -c "import json;nb=json.load(open('build/notebook-previews/L9a-redesign-2026-10-09/exec/ex2.ipynb'));print([i for i,c in enumerate(nb['cells']) for o in c.get('outputs',[]) if o.get('output_type')=='error'])"
cp build/notebook-previews/L9a-redesign-2026-10-09/exec/ex2.ipynb lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb
```

Expected: `[]` before the copy.

- [ ] **Step 4: Run ex2**

Run: `python3 $W/check_l9a.py ex2`
Expected: all PASS.

- [ ] **Step 5: Stage** with `git add lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb`. Proposed message: `L9a Example 2: align symbols, NPV reading, regroup checks`.

---

### Task 6: Advanced notebook, contingent claims and BSM

**Files:**
- Create: `lectures/week-9/L9a/advanced/contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb` (markdown only)
- Create: `$W/build_advanced.py`, `$W/advanced/*.md` (one file per cell), `$W/verify_contingent_claims.py`
- Modify: `lectures/week-9/L9a/advanced/README.md`

**Interfaces:**
- Consumes: Example 2's stored cell 27 output (Task 5).
- Produces: `ADV`, which the lecture's arbitrage box links (Task 7).

- [ ] **Step 1: Run advanced and confirm it fails**

Run: `python3 $W/check_l9a.py advanced`
Expected: FAIL for `contingent claims notebook exists` and for both README checks.

- [ ] **Step 2: Write the numerical verifier first**

Write `$W/verify_contingent_claims.py`:

```python
#!/usr/bin/env python3
"""Numerical checks of every step in the contingent-claims notebook and the bridge
section (spec: Verification, Mathematics). Run from the repository root."""
import json
import math
import re
from pathlib import Path

import numpy as np


class norm:  # standard normal CDF from math.erf (SciPy's stats module is broken in this Python)
    @staticmethod
    def cdf(x):
        return 0.5 * (1.0 + math.erf(x / math.sqrt(2.0)))


S0, K, sigma, g, T = 60.0, 60.0, 0.10, 0.05, 1.0  # Example 2's parameters
Dinv = math.exp(-g * T)
dp = (math.log(S0 / K) + (g + sigma**2 / 2) * T) / (sigma * math.sqrt(T))
dm = dp - sigma * math.sqrt(T)
call = S0 * norm.cdf(dp) - K * Dinv * norm.cdf(dm)
put = K * Dinv * norm.cdf(-dm) - S0 * norm.cdf(-dp)

# 1. one-step replication gives q and the risk-neutral price
u, d, Rf, s0, k = 1.1, 0.9, 1.02, 1.0, 1.0
Hu, Hd = max(u * s0 - k, 0.0), max(d * s0 - k, 0.0)
Delta = (Hu - Hd) / ((u - d) * s0)
B = (u * Hd - d * Hu) / ((u - d) * Rf)
q = (Rf - d) / (u - d)
assert abs(Delta * u * s0 + B * Rf - Hu) < 1e-12 and abs(Delta * d * s0 + B * Rf - Hd) < 1e-12
assert abs((Delta * s0 + B) - (q * Hu + (1 - q) * Hd) / Rf) < 1e-12
assert abs((q * u + (1 - q) * d) * s0 / Rf - s0) < 1e-12  # the share is priced by the same rule
assert abs(q / Rf + (1 - q) / Rf - 1 / Rf) < 1e-15        # YES + NO = zero-coupon bond

# 2. the CRR lattice converges to BSM
def crr(n, is_put=False):
    dt = T / n
    uu = math.exp(sigma * math.sqrt(dt)); dd = 1 / uu; R = math.exp(g * dt)
    qq = (R - dd) / (uu - dd)
    j = np.arange(n + 1)
    ST = S0 * uu**j * dd**(n - j)
    V = np.maximum(K - ST, 0.0) if is_put else np.maximum(ST - K, 0.0)
    for _ in range(n):
        V = (qq * V[1:] + (1 - qq) * V[:-1]) / R
    return V[0]
assert abs(crr(4000) - call) < 2e-3 and abs(crr(4000, True) - put) < 2e-3

# 3. digital and asset-or-nothing by Monte Carlo under Q
rng = np.random.default_rng(5660)
Z = rng.standard_normal(4_000_000)
ST = S0 * np.exp((g - sigma**2 / 2) * T + sigma * math.sqrt(T) * Z)
dig, aon = (ST > K), ST * (ST > K)
assert abs(dig.mean() - norm.cdf(dm)) < 4 * dig.std() / math.sqrt(Z.size)
assert abs(aon.mean() - S0 * math.exp(g * T) * norm.cdf(dp)) < 4 * aon.std() / math.sqrt(Z.size)

# 4. the call is asset-or-nothing minus K digitals, and parity gives the put
assert abs(Dinv * (S0 * math.exp(g * T) * norm.cdf(dp) - K * norm.cdf(dm)) - call) < 1e-12
assert abs(call - S0 + K * Dinv - put) < 1e-12

# 5. bridge: the share has zero expected NPV under Q, and L5a's formula gives P(S(T) <= K)
rho_share = Dinv * ST / S0 - 1
assert abs(rho_share.mean()) < 4 * rho_share.std() / math.sqrt(Z.size)
mu_g = 0.12                                     # any real-world mean log growth
rho_star = K * Dinv / S0 - 1                    # L5a: K = S0 (1 + rho*) e^{g_y T}
z_star = (math.log(1 + rho_star) - (mu_g - g) * T) / (sigma * math.sqrt(T))
assert abs(norm.cdf(z_star) - norm.cdf((math.log(K / S0) - mu_g * T) / (sigma * math.sqrt(T)))) < 1e-12
z_q = (math.log(1 + rho_star) - ((g - sigma**2 / 2) - g) * T) / (sigma * math.sqrt(T))
assert abs(z_q + dm) < 1e-12                   # under Q, L5a's z* is -d_minus

# 6. agreement with the package premiums stored in Example 2
nb = json.loads(Path("lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb").read_text())
out = "".join("".join(o.get("data", {}).get("text/plain", "")) for o in nb["cells"][27].get("outputs", []))
pkg_call = float(re.search(r"call premium C₀ \(BSM\)\s+([-\d.]+)", out).group(1))
pkg_put = float(re.search(r"put premium P₀ \(BSM\)\s+([-\d.]+)", out).group(1))
assert abs(pkg_call - call) < 1e-3 and abs(pkg_put - put) < 1e-3, (pkg_call, call, pkg_put, put)

print(f"all checks passed: call {call:.4f} (package {pkg_call}), put {put:.4f} (package {pkg_put}), q = {q:.4f}")
```

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/verify_contingent_claims.py`
Expected: `all checks passed: call 4.0830 (package 4.083), put 1.1567 (package 1.157), q = 0.6000` (confirmed in a dry run on October 9 against Example 2's stored outputs). If the regex for the stored output fails, print `out` and adjust the pattern to the DataFrame's text layout. Do not loosen the tolerances.

- [ ] **Step 3: Confirm the cross-lecture references.** Every lecture named in the notebook must hold the result the notebook attributes to it.
  - Run: `grep -c "q=\\\\frac{R_f-d}{u-d}\|derive this rule" lectures/week-3/L3b/CHEME-5660-L3b-Lecture-*.ipynb`. Expected: nonzero, so L3b states `q` and promises the derivation.
  - Run: `grep -l -i "lattice" lectures/week-4/L4b/*.ipynb`. If no L4b notebook shows the lattice approaching GBM, change the sentence "L4b showed that as the steps shrink, a lattice approaches geometric Brownian motion" in `advanced/04-lattice-limit.md` (below) to "As the steps shrink, a lattice approaches geometric Brownian motion".

- [ ] **Step 4: Write the cell files.** Each file below is one markdown cell. The notebook's cells are, in order: `00-title.md`, `01-law-of-one-price.md`, `02-replication.md`, `03-state-prices.md`, `04-lattice-limit.md`, `05-digital.md`, `06-asset-or-nothing.md`, `07-call-and-put.md`, `08-reading-n.md`, `09-summary.md`, `10-disclaimer.md`. They go in `$W/advanced/`.

`00-title.md`:
```markdown
# Advanced: Contingent Claims and the Black–Scholes–Merton Formulas
In the lecture, we stated the Black–Scholes–Merton (BSM) premiums and checked them. Here we derive them from one rule: two assets that pay the same amount in every state of the world must have the same price.

> __Learning Objectives:__
>
> By the end of this notebook, you should be able to:
> * __Price a claim by replication:__ Build a portfolio of shares and the risk-free asset that matches a claim's payoff on a one-step lattice. Read the risk-neutral probability $q$ from the portfolio's cost.
> * __Price a claim with state prices:__ Write the price of any claim as the sum of state prices times payoffs. Recognize event contracts as the simplest claims.
> * __Derive the BSM formulas:__ Price a digital claim and an asset-or-nothing claim under geometric Brownian motion. Combine them into the European call premium, and obtain the put from put–call parity.

This notebook is optional. It uses the lecture's notation, with the continuously compounded risk-free rate $g_{y}$ and no dividends.
___
```

`01-law-of-one-price.md`:
```markdown
## The Law of One Price
An abstract asset with random cash flows is described by what it pays in every state of the world. Suppose two assets pay the same amount in every state at every date. If their prices differed, we could buy the cheaper one and sell the other. The future cash flows would cancel in every state, and the price difference would be a profit today with no risk. In an arbitrage-free market, this cannot happen.

> __Law of one price:__ In an arbitrage-free market, two assets with identical cash flows in every state have the same price, and therefore the same NPV.

To price an option, we build a portfolio of assets whose prices we know, with the same cash flows as the option in every state. The option's premium is then the portfolio's cost.
___
```

`02-replication.md`:
```markdown
## One-Step Replication
Consider the one-step lattice from L3b. Over one step, the share price moves from $S(0)$ to $uS(0)$ (up) or $dS(0)$ (down), and one dollar in the risk-free asset grows to $R_f$. A claim pays $H_u$ in the up state and $H_d$ in the down state. Let's hold $\Delta$ shares and $B$ dollars in the risk-free asset, and choose them so that the portfolio pays what the claim pays in both states:
$$
\begin{align*}
\Delta\,uS(0) + B\,R_f &= H_u && \text{up state}\\
\Delta\,dS(0) + B\,R_f &= H_d && \text{down state}
\end{align*}
$$
Subtracting the down equation from the up equation removes $B$. Substituting $\Delta$ back into the down equation gives $B$:
$$
\begin{align*}
\Delta &= \frac{H_u - H_d}{(u-d)\,S(0)} && \text{subtract the two states}\\
B &= \frac{uH_d - dH_u}{(u-d)\,R_f} && \text{substitute }\Delta\text{ into the down state}
\end{align*}
$$
By the law of one price, the claim's price $V_0$ is the portfolio's cost $\Delta S(0) + B$:
$$
\begin{align*}
V_0 &= \frac{H_u - H_d}{u-d} + \frac{uH_d - dH_u}{(u-d)\,R_f} && \text{cost of }\Delta\text{ shares and }B\text{ dollars}\\
&= \frac{1}{R_f}\left[\frac{R_f-d}{u-d}\,H_u + \frac{u-R_f}{u-d}\,H_d\right] && \text{common denominator, collect }H_u\text{ and }H_d\\
&= \frac{1}{R_f}\Bigl[q\,H_u + (1-q)\,H_d\Bigr], \qquad q=\frac{R_f-d}{u-d} && 1-q=\frac{u-R_f}{u-d}
\end{align*}
$$
This is the risk-neutral pricing rule that L3b stated without a derivation. Three points follow:
* __The real-world probability never appears.__ The portfolio matches the claim in both states, whatever their probabilities, so $p$ does not enter the price.
* __No arbitrage requires $d<R_f<u$.__ If $R_f\leq d$, borrowing to buy the share never loses and gains in the up state. If $R_f\geq u$, selling the share short and lending the proceeds never loses and gains in the down state. With $d<R_f<u$, the weight $q$ lies strictly between $0$ and $1$.
* __The share is priced by the same rule.__ With $H_u=uS(0)$ and $H_d=dS(0)$, the rule returns $S(0)$, because $qu+(1-q)d=R_f$.
___
```

`03-state-prices.md`:
```markdown
## State Prices and Event Contracts
The pricing rule is linear in the payoffs. Let's define the __state prices__:
$$
\begin{align*}
\psi_u = \frac{q}{R_f}, \qquad \psi_d = \frac{1-q}{R_f}
\end{align*}
$$
The price of any claim is then the inner product of the state prices with its payoffs:
$$
\begin{align*}
V_0 = \psi_u H_u + \psi_d H_d = \bigl\langle \boldsymbol{\psi},\mathbf{H}\bigr\rangle
\end{align*}
$$
In L1b, NPV was an inner product over dates, with each cash flow multiplied by its discount factor. A state price plays the same role across states: $\psi_u$ is the price today of one dollar paid only in the up state.

__Event contracts are the simplest claims.__ A YES contract on the event "the share moves up" pays one dollar in the up state and nothing otherwise, so its price is $\psi_u$. The NO contract pays one dollar in the down state, so its price is $\psi_d$. Holding both pays one dollar in every state, which is a zero-coupon bond:
$$
\begin{align*}
\psi_u + \psi_d = \frac{q + (1-q)}{R_f} = \frac{1}{R_f}
\end{align*}
$$
This is put–call parity in miniature: when two claims' payoffs add to a known amount, their prices add to that amount's present value.
___
```

`04-lattice-limit.md`:
```markdown
## From the Lattice to Geometric Brownian Motion
The one-step rule extends to a lattice with $n$ steps of length $\Delta t=T/n$. We replicate the claim one step at a time, backward from expiration. The price is then the discounted expectation of the payoff under $\mathbb{Q}$, the law that moves up with probability $q$ at every step. L4b showed that as the steps shrink, a lattice approaches geometric Brownian motion. We state the result under $\mathbb{Q}$ without proof.

> __Proposition (lattice limit under $\mathbb{Q}$):__ Let $u=e^{\sigma\sqrt{\Delta t}}$, $d=1/u$, and $R_f=e^{g_{y}\Delta t}$. As $n\to\infty$, the distribution of the share price at expiration under $\mathbb{Q}$ approaches:
> $$
> S(T) = S(0)\exp\Bigl(\bigl(g_{y}-\tfrac{\sigma^{2}}{2}\bigr)T + \sigma\sqrt{T}\,Z\Bigr), \qquad Z\sim\mathcal{N}(0,1)
> $$
> and the price of a European claim with payoff $H(S(T))$ approaches $\mathcal{D}^{-1}_{T,0}(g_{y})\,\mathbb{E}_{\mathbb{Q}}\bigl(H(S(T))\bigr)$.

Under $\mathbb{P}$, L4b and L5a used the same form with mean log growth $\mu_g$. Under $\mathbb{Q}$, the mean log growth is $g_{y}-\sigma^{2}/2$, because the share price drifts at the risk-free rate. The rest of this notebook computes two expectations under this law.
___
```

`05-digital.md`:
```markdown
## Digital Claims
A __digital__ (cash-or-nothing) claim pays one dollar at expiration if $S(T)>K$ and nothing otherwise. Its payoff is $\mathbb{1}\{S(T)>K\}$, the event contract on the share finishing above the strike. Taking logs of the lattice limit:
$$
\begin{align*}
\mathbb{Q}\bigl(S(T)>K\bigr)
&= \mathbb{Q}\Bigl(\bigl(g_{y}-\tfrac{\sigma^{2}}{2}\bigr)T + \sigma\sqrt{T}\,Z > \ln\tfrac{K}{S(0)}\Bigr) && \text{take logs}\\
&= \mathbb{Q}\bigl(Z > -d_{-}\bigr) && d_{-}=\frac{\ln\frac{S(0)}{K}+\bigl(g_{y}-\frac{\sigma^{2}}{2}\bigr)T}{\sigma\sqrt{T}}\\
&= N(d_{-}) && \text{the standard normal is symmetric}
\end{align*}
$$
This is L5a's terminal target probability. L5a computed $\mathbb{P}(S_T>K)=1-\Phi(z_\star)$ with mean log growth $\mu_g$. Replacing $\mu_g$ by $g_{y}-\sigma^{2}/2$ gives $z_\star=-d_{-}$, and $N$ is L5a's $\Phi$. The price of the digital claim is therefore:
$$
\begin{align*}
\mathcal{D}^{-1}_{T,0}(g_{y})\cdot N(d_{-})
\end{align*}
$$
which is also the BSM price of a Kalshi-style contract that pays one dollar if the share finishes above $K$.
___
```

`06-asset-or-nothing.md`:
```markdown
## Asset-or-Nothing Claims
An __asset-or-nothing__ claim pays the share price $S(T)$ at expiration if $S(T)>K$ and nothing otherwise. Write $m=\bigl(g_{y}-\tfrac{\sigma^{2}}{2}\bigr)T$ and $s=\sigma\sqrt{T}$, so that $S(T)=S(0)e^{m+sZ}$ and $S(T)>K$ exactly when $Z>-d_{-}$. With $\varphi$ the standard normal density:
$$
\begin{align*}
\mathbb{E}_{\mathbb{Q}}\bigl(S(T)\,\mathbb{1}\{S(T)>K\}\bigr)
&= S(0)\,e^{m}\int_{-d_{-}}^{\infty} e^{sz}\,\varphi(z)\,dz && \text{expectation over }Z\\
&= S(0)\,e^{m+s^{2}/2}\int_{-d_{-}}^{\infty}\varphi(z-s)\,dz && e^{sz}\varphi(z)=e^{s^{2}/2}\varphi(z-s)\text{, complete the square}\\
&= S(0)\,e^{g_{y}T}\,\mathbb{Q}\bigl(Z>-d_{-}-s\bigr) && m+\tfrac{s^{2}}{2}=g_{y}T\text{, shift the variable}\\
&= S(0)\,e^{g_{y}T}\,N(d_{+}) && d_{-}+\sigma\sqrt{T}=d_{+}
\end{align*}
$$
Discounting by $\mathcal{D}^{-1}_{T,0}(g_{y})=e^{-g_{y}T}$, the price of the asset-or-nothing claim is $S(0)\,N(d_{+})$.
___
```

`07-call-and-put.md`:
```markdown
## The Call and the Put
The call payoff splits into the two claims we just priced:
$$
\begin{align*}
V_{c}(K,S(T)) = \max\bigl(S(T)-K,~0\bigr) = S(T)\,\mathbb{1}\{S(T)>K\} - K\cdot\mathbb{1}\{S(T)>K\}
\end{align*}
$$
The call is therefore one asset-or-nothing claim minus $K$ digital claims. Pricing each piece and adding, by linearity:
$$
\begin{align*}
\mathcal{P}_{c}(K,S(0))
&= \mathcal{D}^{-1}_{T,0}(g_{y})\Bigl[\mathbb{E}_{\mathbb{Q}}\bigl(S(T)\,\mathbb{1}\{S(T)>K\}\bigr) - K\,\mathbb{Q}\bigl(S(T)>K\bigr)\Bigr] && \text{expectation is linear}\\
&= e^{-g_{y}T}\Bigl[S(0)\,e^{g_{y}T}N(d_{+}) - K\,N(d_{-})\Bigr] && \text{asset-or-nothing and digital}\\
&= N(d_{+})\cdot S(0) - N(d_{-})\cdot K\cdot\mathcal{D}^{-1}_{T,0}(g_{y}) && \text{the lecture's BSM call}
\end{align*}
$$
For the put, the lecture's put–call parity gives:
$$
\begin{align*}
\mathcal{P}_{p}(K,S(0))
&= \mathcal{P}_{c}(K,S(0)) - S(0) + K\cdot\mathcal{D}^{-1}_{T,0}(g_{y}) && \text{put–call parity}\\
&= S(0)\bigl[N(d_{+})-1\bigr] + K\cdot\mathcal{D}^{-1}_{T,0}(g_{y})\bigl[1-N(d_{-})\bigr] && \text{substitute the call}\\
&= N(-d_{-})\cdot K\cdot\mathcal{D}^{-1}_{T,0}(g_{y}) - N(-d_{+})\cdot S(0) && 1-N(x)=N(-x)
\end{align*}
$$
which is the lecture's BSM put.
___
```

`08-reading-n.md`:
```markdown
## Reading $N(d_{-})$ and $N(d_{+})$
* __$N(d_{-})$ is the $\mathbb{Q}$-probability of exercise.__ A European call is exercised when $S(T)>K$, and $\mathbb{Q}(S(T)>K)=N(d_{-})$. It is a probability under the pricing measure, so it can differ from the real-world probability $\mathbb{P}(S(T)>K)$ that L5a computes with $\mu_g$.
* __$N(d_{+})$ weights the share received at exercise.__ The asset-or-nothing price $S(0)\,N(d_{+})$ counts the share only in the states where it is delivered. $N(d_{+})$ is the probability of the same event under a different pricing measure, one that uses the share rather than the risk-free asset as its unit of account. Because $d_{+}>d_{-}$, it is the larger of the two.
* __A Kalshi-style contract on the share has a closed form.__ A contract that pays one dollar if $S(T)>K$ costs $\mathcal{D}^{-1}_{T,0}(g_{y})\,N(d_{-})$ under BSM.
___
```

`09-summary.md`:
```markdown
## Summary
We derived the Black–Scholes–Merton premiums from the law of one price. Replication gave the risk-neutral probability, state prices turned pricing into an inner product over states, and two simple claims built the call.

> __Key Takeaways:__
>
> * __Replication prices a claim without real-world probabilities.__ A portfolio of shares and the risk-free asset that matches the claim in every state has the claim's price, and its cost defines $q=(R_f-d)/(u-d)$.
> * __Prices are inner products of state prices and payoffs.__ Event contracts are the claims that pay one dollar in one state, and a YES and NO pair is a zero-coupon bond.
> * __The BSM call is an asset-or-nothing claim minus $K$ digital claims.__ Their prices are $S(0)\,N(d_{+})$ and $\mathcal{D}^{-1}_{T,0}(g_{y})\,N(d_{-})$, and parity gives the put.

__Assumptions.__ The derivation assumes no arbitrage, frictionless trading in the share and the risk-free asset, a constant risk-free rate $g_{y}$ and volatility $\sigma$, no dividends, and the lattice limit stated above without proof.
___
```

`10-disclaimer.md`: copy the "## Disclaimer and Risks" cell verbatim from Fall-2025 L9b cell 8. Use the same text that Task 7 places in the lecture.

- [ ] **Step 5: Write `$W/build_advanced.py`** and build the notebook

```python
#!/usr/bin/env python3
"""Build the L9a contingent-claims notebook from $W/advanced/*.md. Run from the repo root."""
import hashlib
import json
from pathlib import Path

W = Path(__file__).resolve().parent
OUT = Path("lectures/week-9/L9a/advanced/contingent_claims/"
           "CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb")
META = json.loads(Path("lectures/week-9/L9a/CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb").read_text())["metadata"]
parts = sorted((W / "advanced").glob("*.md"))
assert len(parts) == 11, [p.name for p in parts]
cells = [{"cell_type": "markdown", "id": hashlib.sha1(p.name.encode()).hexdigest()[:8],
          "metadata": {}, "source": p.read_text().strip("\n").splitlines(keepends=True)} for p in parts]
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps({"cells": cells, "metadata": META, "nbformat": 4, "nbformat_minor": 5},
                          indent=1, ensure_ascii=False) + "\n")
print(f"wrote {OUT} with {len(cells)} cells")
```

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/build_advanced.py`

- [ ] **Step 6: Rewrite `lectures/week-9/L9a/advanced/README.md`**

```markdown
# L9a optional advanced material

This material extends the lecture's European pricing. It is optional.

- [`contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb`](contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb)
  derives the Black--Scholes--Merton premiums that the lecture states. A
  one-step replicating portfolio gives the risk-neutral probability
  $q=(R_f-d)/(u-d)$, and state prices write any claim's price as an inner
  product over states, with event contracts as the simplest claims. Under
  geometric Brownian motion, a digital claim costs the discounted
  $N(d_{-})$ and an asset-or-nothing claim costs $S(0)N(d_{+})$. The call is
  the second minus $K$ of the first, and put--call parity gives the put.
- [`spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb`](spxw_volatility_skew/CHEME-5660-L9a-Advanced-SPXW-Volatility-Skew-Fall-2026.ipynb)
  treats an SPXW-style chain as a cross-section of European, cash-settled index
  claims. It pairs calls and puts, estimates the discount factor and forward
  index level from put--call parity, reprices the chain in forward BSM form,
  inverts quote midpoints for implied volatility, and checks parity, price
  bounds, strike monotonicity, and discrete convexity. It also attempts to load
  free Yahoo Finance `^GSPC` history for realized-volatility context and uses a
  deterministic synthetic price path if that optional request is unavailable.
  The bundled option quote fixture is explicitly synthetic and reproducible.
  The notebook documents the schema required to replace it with a timestamp-
  aligned, properly licensed market snapshot.

The SPXW notebook uses SPXW contract conventions to make European exercise and
cash settlement concrete. It does not scrape Cboe quote pages or claim that the
bundled fixture is observed market data. Yahoo history, when available, is used
only for backward-looking percentage volatility and is never combined with the
synthetic chain's price level or parity calculation.
```

- [ ] **Step 7: Run advanced and render a check preview**

Run: `python3 $W/check_l9a.py advanced`
Expected: all PASS.

Then render the notebook so KaTeX errors show. Use `$W/preview_cells.py` from Task 8, Step 9, with `--notebook` pointing at the advanced notebook. If you run this task before Task 8, write that script now. Every display must render, with no red KaTeX error text.

- [ ] **Step 8: Stage** with `git add lectures/week-9/L9a/advanced/README.md lectures/week-9/L9a/advanced/contingent_claims`. Proposed message: `L9a advanced: contingent claims derivation of BSM`.

---

### Task 7: Assemble the lecture from the instructor's 2025 text

**Files:**
- Create: `$W/assemble_lecture.py`
- Create (generated): `lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb`

**Interfaces:**
- Consumes:
  - the Fall-2025 notebooks at `../CHEME-5660-CourseRepository-Fall-2025/lectures/…`
  - the figures (Task 2)
  - `EX1` (Task 4), `EX2` (Task 5), `ADV` (Task 6)
  - the archived old lecture's metadata (Task 3)
- Produces: the lecture notebook. It also reads optional NEW fragments from `$W/new/`: `hook.md`, `lo3.md`, `profile.md`, `derivative-sentence.md`, `event-bullet.md`, `market.md`, `bridge.md`, `kt3.md`. Task 8 writes them and re-runs the assembler.

- [ ] **Step 1: Run lecture and confirm it fails**

Run: `python3 $W/check_l9a.py lecture`
Expected: `FAIL  lecture exists`.

- [ ] **Step 2: Write `$W/assemble_lecture.py`**

```python
#!/usr/bin/env python3
"""Assemble the L9a lecture from the instructor's Fall-2025 text.

Spec: lectures/instructor/L9a-REDESIGN-SPEC.md. Run from the repository root:
    python3 build/notebook-previews/L9a-redesign-2026-10-09/assemble_lecture.py
Every replacement asserts how many times its old text occurs, so a drifted
source fails loudly. NEW prose is read from new/*.md. A missing fragment keeps
his text (or omits the item) and prints a warning, so the lecture can be built
before the NEW items exist.
"""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path.cwd()
WORK = Path(__file__).resolve().parent
NEW = WORK / "new"
F25 = ROOT.parent / "CHEME-5660-CourseRepository-Fall-2025/lectures"
SRC = {
    "L9b": F25 / "week-9/L9b/CHEME-5660-L9b-Lecture-IntroductionToDerivativesContracts-Fall-2025.ipynb",
    "L10a": F25 / "week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-CRR-Model-Fall-2025.ipynb",
}
OUT = ROOT / "lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb"
META_FROM = next((ROOT / "lectures/archive").glob(
    "week-9-L9a-before-redesign-*/week-9/L9a/CHEME-5660-L9a-Lecture-European-Options-BSM-Fall-2026.ipynb"))
EX1 = "CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb"
EX2 = "CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb"
ADV = "advanced/contingent_claims/CHEME-5660-L9a-Advanced-ContingentClaims-BSM-Fall-2026.ipynb"
CASHFLOW_FIGURE = True  # set False if the instructor drops the NEW timeline (Task 2, checkpoint A)

log = []


def his(tag, i):
    return "".join(json.loads(SRC[tag].read_text())["cells"][i]["source"])


def frag(name, default=None):
    p = NEW / name
    if p.exists():
        return p.read_text().strip("\n")
    print(f"WARNING: new/{name} missing, using {'his text' if default else 'nothing'}")
    return default


def sub(text, old, new, count=1, why=""):
    n = text.count(old)
    assert n == count, f"[{why}] expected {count} of {old[:70]!r}, found {n}"
    log.append((why, n, old, new))
    return text.replace(old, new)


def resub(text, pattern, new, count=1, why=""):
    out, n = re.subn(pattern, lambda m: new, text)
    assert n == count, f"[{why}] expected {count} matches of {pattern[:70]!r}, found {n}"
    log.append((why, n, pattern, new))
    return out


THEME_STYLE = """<style>
  .course-diagram { color-scheme: light dark; }
  :host-context(body[data-vscode-theme-kind="vscode-light"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast-light"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-light"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast-light"] .course-diagram { color-scheme: light; }
  :host-context(body[data-vscode-theme-kind="vscode-dark"]) .course-diagram,
  :host-context(body[data-vscode-theme-kind="vscode-high-contrast"]) .course-diagram,
  body[data-vscode-theme-kind="vscode-dark"] .course-diagram,
  body[data-vscode-theme-kind="vscode-high-contrast"] .course-diagram { color-scheme: dark; }
  @media print { .course-diagram { color-scheme: only light !important; } }
</style>
"""


def figure(name, width, alt):
    return (THEME_STYLE + "<div>\n    <center>\n"
            f'        <img class="course-diagram" src="figs/{name}.svg" width="{width}" alt="{alt}"/>\n'
            "    </center>\n</div>\n")


CONTRACT_ALT = ("Two rows, a call contract and a put contract. In each row a buyer box, the right, "
                "and a seller box, the obligation, are joined by a solid arrow from buyer to seller "
                "for the premium, which is always paid, and a dotted arrow for the shares that change "
                "hands at the strike price only if the buyer exercises: from seller to buyer for the "
                "call and from buyer to seller for the put.")
CASHFLOW_ALT = ("Cash-flow timeline for an option. At time zero an arrow leaves the time point: the "
                "premium is paid. At expiration T a dashed arrow enters the time point: the payoff, "
                "which depends on the strike price and the share price at expiration, is received "
                "and may be zero.")
NOTATION = ("__Notation:__ The [course notation page](https://varnerlab.org/CHEME-5660-"
            "CourseRepository-Fall-2026/dev/faq/notation.html#L9a) lists this lecture's symbols "
            "with their meanings and units.")

BREAKEVEN_CALL = r"""Setting the buyer's profit to zero gives the __breakeven__ share price at expiration. Above it, the buyer profits and the seller loses:
$$
\begin{align*}
S_{\text{BE}} = K + \mathcal{P}_{c}(K,S(0))\quad\text{(call breakeven)}
\end{align*}
$$
"""
BREAKEVEN_PUT = r"""Setting the buyer's profit to zero gives the put __breakeven__. Below it, the buyer profits and the seller loses:
$$
\begin{align*}
S_{\text{BE}} = K - \mathcal{P}_{p}(K,S(0))\quad\text{(put breakeven)}
\end{align*}
$$
"""
PARITY = r"""__Put–call parity.__ For the same strike and expiration, the call and put payoffs differ by an amount that is linear in the share price, whatever the share price at expiration:
$$
\begin{align*}
V_{c}(K,S(T)) - V_{p}(K,S(T)) = \max\left(S(T)-K,~0\right) - \max\left(K-S(T),~0\right) = S(T) - K
\end{align*}
$$
Subtracting the put premium condition from the call premium condition, and using the share's zero expected NPV under $\mathbb{Q}$ from the previous section, gives:
$$
\begin{align*}
\mathcal{P}_{c}(K,S(0)) - \mathcal{P}_{p}(K,S(0))
& = \mathbb{E}_{\mathbb{Q}}\Bigl(\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\bigl[V_{c}(K,S(T)) - V_{p}(K,S(T))\bigr]\Bigr) && \text{expectation is linear}\\
& = \mathbb{E}_{\mathbb{Q}}\Bigl(\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\bigl[S(T) - K\bigr]\Bigr) && \text{payoff identity}\\
& = S(0) - K\cdot\mathcal{D}^{-1}_{T,0}(g_{y}) && \mathbb{E}_{\mathbb{Q}}\bigl(\mathcal{D}^{-1}_{T,0}(g_{y})\,S(T)\bigr) = S(0)
\end{align*}
$$
Parity uses only the payoff identity and the linearity of the expectation, not the Black–Scholes–Merton formulas, so it holds for any pair of European premiums priced under $\mathbb{Q}$."""


def title_cell():
    c = his("L9b", 0)
    c = sub(c, "# L9b: Introduction to Derivatives\n",
            "# L9a: Introduction to Derivatives and European Option Pricing\n", why="title")
    opener = ("In this lecture, we introduce our next asset class: derivatives. Derivatives are "
              "financial instruments whose value is derived from the value of an __underlying "
              "asset__, such as stocks, bonds, commodities, or currencies. They are widely used "
              "for hedging risk, or speculation.")
    c = sub(c, opener, frag("hook.md", opener), why="NEW hook replaces the opener")
    lo3 = re.search(r"> \* __Construct composite option strategies:__[^\n]*\n", c).group(0)
    new_lo3 = frag("lo3.md", "")
    c = sub(c, lo3, new_lo3 + "\n" if new_lo3 else "", why="NEW LO3 replaces composite strategies")
    c = sub(c, "\nLet's get started!", "\n" + NOTATION + "\n\nLet's get started!", why="notation link")
    return c


def examples_cell():
    return (
        "## Examples\n\n__We will work through these examples in lecture:__\n\n"
        f"> [▶ Let's compute the payoff diagrams for single long and short call and put options]({EX1}). "
        "In this example, we compute and plot the payoff and profit diagrams for single long and short "
        "call and put options contracts. We will analyze how the strike price and premium affect the "
        "profitability of these options at expiration (or exercise).\n\n"
        f"> [▶ Let's compute the BSM premium for European call and put options]({EX2}). In this example, "
        "the premium for a European call and put option contract is computed using the "
        "Black-Scholes-Merton model and Monte Carlo simulation. We then look at how the premium "
        "changes with strike price.\n\n___")


def derivative_cell():
    c = his("L9b", 3)
    s = frag("derivative-sentence.md", "")
    if s:
        anchor = "The value of a derivative is based on the performance of an underlying asset."
        c = sub(c, anchor, anchor + "\n\n" + s, why="NEW abstract-asset sentence")
    c = sub(c, "more flexibility in contract terms; they may have non-standard terms.",
            "more flexibility in contract terms. They may have non-standard terms.", why="semicolon")
    b = frag("event-bullet.md", "")
    if b:
        anchor = "[Chicago Board Options Exchange (CBOE)](https://www.cboe.com)."
        c = sub(c, anchor, anchor + "\n" + b, why="NEW event-contract bullet")
    head, tail = c.split("### How big is the US options market?")
    market = frag("market.md", None)
    if market is None:
        market = ("### How big is the US options market?" + tail.rsplit("___", 1)[0].rstrip()
                  ).replace("?utm_source=chatgpt.com", "")
    return head + market + "\n\n___"


def calls_puts_cell():
    c = his("L9b", 5)
    c = sub(c, "## Call and Put Options Contracts\n",
            "## Call and Put Options Contracts\n"
            + figure("Fig-L9a-Contract-Right-Obligation", 780, CONTRACT_ALT) + "\n",
            why="TikZ figure replaces the 2024 raster (his cell 4)")
    c = sub(c, "Short call contracts have unlimited upside risk; call options are often sold",
            "Short call contracts have unlimited upside risk. Call options are often sold", why="semicolon")
    c = sub(c, "Short put contracts have unlimited downside risk; put options are often sold",
            "Short put contracts have large but bounded downside risk: the loss per share is at most "
            "the strike price minus the premium, reached if the share price falls to zero. "
            "Put options are often sold", why="fix 1: the short put loss is bounded")
    c = sub(c, "This creates extra risk for the contract seller, hence American-style calls typically "
               "have higher premiums than European-style calls.",
            "This creates extra risk for the contract seller, so an American-style call is worth at "
            "least as much as a European-style call with the same strike and expiration.\n"
            "> * __Bermudan-style call options__, a less common hybrid, can be exercised only on "
            "specified dates up to the expiration date.", why="fix 2 and the Bermudan bullet")
    c = sub(c, "This creates extra risk for the contract seller, hence American-style puts typically "
               "have higher premiums than European-style puts.",
            "This creates extra risk for the contract seller, so an American-style put is worth at "
            "least as much as a European-style put with the same strike and expiration.", why="fix 2")
    for side, flip in (("c", BREAKEVEN_CALL), ("p", BREAKEVEN_PUT)):
        seller = (rf"P_{{{side}}}^{{\text{{seller}}}}(K,S(T)) & = \mathcal{{P}}_{{{side}}}(K,S(0)) - "
                  rf"V_{{{side}}}(K,S(T))\quad\text{{(seller's perspective)}}" + "\n\\end{align*}\n$$\n")
        c = sub(c, seller, seller + flip, why="breakeven (Example 1 checks it)")
    c = sub(c, r"\mathbb{E}\Bigl(", r"\mathbb{E}_{\mathbb{Q}}\Bigl(", count=4, why="fix 4: expectation under Q")
    for kind in ("call", "put"):
        c = sub(c, f"For an __American-style {kind}__, the holder can exercise at any optimal time "
                   r"$\tau \in [0,T]$, which increases the premium:",
                f"For an __American-style {kind}__, the holder can exercise at any time "
                r"$\tau\leq T$ chosen using only the information available at that time "
                "(a __stopping time__), which can increase the premium:", why="fix 3: stopping times")
    c = sub(c, r"\max_{\tau \in [0,T]}", r"\sup_{\tau\leq T}", count=2, why="fix 3: sup")
    c = sub(c, r"\bar{r}", "g_{y}", count=8, why="fix 6: r-bar to g_y")
    c = sub(c, "Any deviation from this relationship would create a risk-free profit opportunity: if "
               "the premium were too low relative to expected value, traders would buy the option; if "
               "the premium were too high, traders would sell it.",
            "Any deviation from this relationship would create a risk-free profit opportunity. If the "
            "premium were too low, traders would buy the option and sell a portfolio of shares and the "
            "risk-free asset that replicates its payoff. If the premium were too high, they would do "
            f"the reverse. The [contingent claims notebook]({ADV}) builds this portfolio.",
            why="fix 5: arbitrage names a replicating portfolio")
    c = resub(c, r"> __Example__\n> ?\n> \[▶ Let's compute the payoff diagrams for single long and short "
                 r"call and put options\]\(CHEME-5660-L9b-Example-SingleContractPayoffProfit-Fall-2025\.ipynb\)",
              "> __Example:__\n>\n> [▶ Let's compute the payoff diagrams for single long and short call "
              f"and put options]({EX1})", why="callout format and the 2026 target")
    return c


def bridge_cell():
    body = frag("bridge.md", None)
    if body is None:
        return None
    fig = figure("Fig-L9a-Option-CashFlows", 680, CASHFLOW_ALT) + "\n" if CASHFLOW_FIGURE else ""
    return "## Options as Abstract Assets\n" + fig + body + "\n\n___"


def european_cell():
    c = his("L10a", 3)
    c = sub(c, "Before diving into American style options, let's briefly review European style options. ",
            "", why="fix 8: L10a framing (American pricing is not taught yet)")
    c = sub(c, r"\mathbb{E}\Bigl(", r"\mathbb{E}_{\mathbb{Q}}\Bigl(", count=2, why="fix 4")
    c = sub(c, r"\bar{r}", "g_{y}", count=6, why="fix 6")
    anchor = "where $d_{+}$ and $d_{-}$ are defined as above."
    c = sub(c, anchor, anchor + "\n\n" + PARITY, why="put-call parity (Example 2 checks it)")
    c = resub(c, r"### Example\nLet's look at an example of European option pricing using the BSM model\.\n\n"
                 r"> \[▶ Let's compute the BSM Premium for a European Call and Put Options\]\("
                 r"CHEME-5660-L10a-Example-BSM-Premium-Fall-2025\.ipynb\)\. In this example, the premium "
                 r"for a European call and put option contract is computed using the Black-Scholes-Merton "
                 r"model and Monte Carlo simulation\. We then look at how the premium changes with strike "
                 r"price and time to expiration\.",
              "Let's look at an example of European option pricing using the BSM model.\n\n"
              "> __Example:__\n>\n> [▶ Let's compute the BSM premium for European call and put options]"
              f"({EX2}). In this example, the premium for a European call and put option contract is "
              "computed using the Black-Scholes-Merton model and Monte Carlo simulation. We then look at "
              "how the premium changes with strike price.",
              why="callout format, 2026 target, no H3 for a stop, the example sweeps strike only")
    return c


def summary_cell():
    c = his("L9b", 7)
    kt3 = re.search(r"> \* __Composite option strategies[^\n]*\n", c).group(0)
    new = frag("kt3.md", "")
    c = sub(c, kt3, (new + "\n") if new else "", why="NEW KT3 replaces composite strategies")
    c = sub(c, "payoff structures, and strategic applications is important",
            "payoff structures, and pricing is important", why="closer: composite strategies left")
    return c


def main():
    cells = [title_cell(), examples_cell(), frag("profile.md", None), derivative_cell(),
             calls_puts_cell(), bridge_cell(), european_cell(), summary_cell(), his("L9b", 8)]
    cells = [c for c in cells if c]
    meta = json.loads(META_FROM.read_text())["metadata"]
    nb = {"cells": [{"cell_type": "markdown",
                     "id": hashlib.sha1(c.split("\n", 1)[0].encode()).hexdigest()[:8],
                     "metadata": {}, "source": c.splitlines(keepends=True)} for c in cells],
          "metadata": meta, "nbformat": 4, "nbformat_minor": 5}
    OUT.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
    for why, n, old, new in log:
        print(f"[{why}] x{n}")
    for c in cells:
        print(f"{len(c.split()):5d} words  {c.splitlines()[0][:70]}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 3: Run it with no fragments**

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/assemble_lecture.py`
Expected: eight `WARNING: new/… missing` lines, every `[…] xN` line, and seven cells. An `AssertionError` means his source differs from the string here. In that case:
1. Print the source cell with `python3 -c "import json;print(''.join(json.load(open('<path>'))['cells'][<i>]['source']))"`.
2. Correct the `old` string to match it character for character.
3. Never loosen a count.

- [ ] **Step 4: Run lecture and confirm the expected failures**

Run: `python3 $W/check_l9a.py lecture`
Expected PASS:
- markdown only, title, notation link
- the rule before each H2, summary rule, disclaimer
- no semicolons, no r-bar, no max over tau, expectation under Q
- no utm (fallback), no raster figure, no forward pointers
- relative links, contract figure embedded with theme and alt
- two example stops in order, breakevens before the Example 1 stop, parity before the Example 2 stop

Expected FAIL until Task 8 writes the fragments:
- three learning objectives (2)
- lead-in (about 40 words, his opener)
- H2 order (no profile, no bridge)
- three key takeaways (2)
- Option-CashFlows embedded

- [ ] **Step 5: Do not stage yet.** Task 8 regenerates the notebook.

---

### Task 8: NEW lecture content, with fact checks and previews

**Files:**
- Create: `$W/new/hook.md`, `lo3.md`, `profile.md`, `derivative-sentence.md`, `event-bullet.md`, `market.md`, `bridge.md`, `kt3.md`
- Regenerate: the lecture notebook (Task 7's assembler)
- Create: `$W/preview_cells.py` and the PNGs in `$W/previews/`

**Interfaces:**
- Consumes: `assemble_lecture.py` (Task 7). Fragment names and formats are listed under Task 7's Interfaces. Each fragment is plain markdown with no leading or trailing blank lines.
- Produces: the final lecture notebook and the before/after previews for checkpoint B.

- [ ] **Step 1: Read the voice guidance.** Read the style guide section "What the rounds show so far, for both courses" in `lectures/instructor/NOTEBOOK-STYLE-GUIDE.md`, plus the "Company profiles — CHEME 5660" section. Then read the L4b Jane Street profile (cell 2 of `lectures/week-4/L4b/CHEME-5660-L4b-Lecture-SingleAsset-GeometricBrownianMotion-TradeRule-Fall-2026.ipynb`).

- [ ] **Step 2: Verify the dated facts before writing any.** Use WebSearch, then WebFetch on primary sources. Record each fact with its URL and access date in `$W/facts.md`:
  1. The Chicago Board Options Exchange opened on April 26, 1973. It was the first exchange to list standardized stock options, and it was founded by members of the Chicago Board of Trade. Sources: cboe.com history or the Cboe annual report.
  2. Black and Scholes, "The Pricing of Options and Corporate Liabilities", *Journal of Political Economy*, 1973 (May–June issue).
  3. SPX options are European-style and cash-settled (Cboe SPX product page). Most U.S. equity and ETF options are American-style (OCC or Cboe).
  4. OCC clears all U.S. exchange-listed options as the central counterparty (theocc.com).
  5. Cboe calculates VIX from SPX option prices as a 30-day expected volatility (Cboe VIX page).
  6. OCC 2025 totals: total options volume (about 15.21 billion contracts, about +24.4% over 2024) and the record day (about 110 million contracts, October 10, 2025). Source: the OCC press release for December 2025 or the 2025 year-end figures.
  7. The latest OCC monthly release in 2026: year-to-date total options ADV and the month it runs through.
  8. Notional rows: Cboe's "options flow exceeds 3 trillion USD" (January 24, 2025) and the record 6.6 trillion USD triple witching (December 20, 2024). Search for a 2025 equivalent of each. Use the newer figure if a reputable source has one, and otherwise keep the dated 2024/2025 figure.
  9. Kalshi: one-dollar event contracts priced from 1 to 99 cents, with categories including economics, weather, and financial index levels (kalshi.com). Check whether Kalshi is a CFTC-designated contract market, but do not put that in the text.
  10. Cboe Predicts: check whether Cboe launched event or prediction contracts in 2026 (Cboe press release). If not confirmed by a Cboe source, leave Cboe out of the event-contract bullet and out of the profile.
  11. Links: The Options Institute, Cboe careers, Cboe internships or early careers, and Cboe's official YouTube channel. Open each one, and keep a link only if it resolves to a Cboe-owned page.

  No scandals or litigation (the VIX-manipulation suits stay out).

- [ ] **Step 3: Write `new/hook.md`** (36 words, with link sentence plus question):

```markdown
L1b valued known cash flows by discounting them. A [Kalshi](https://kalshi.com) contract costs less than a dollar today and pays one dollar only if an event occurs. What is a payment that may never arrive worth today?
```

- [ ] **Step 4: Write `new/lo3.md`, `new/derivative-sentence.md`, `new/event-bullet.md`, and `new/kt3.md`**

`lo3.md`:
```markdown
> * __Price European options contracts:__ Explain why an option's premium is the price at which its expected net present value under the risk-neutral measure is zero. Compute European call and put premiums with the Black–Scholes–Merton formulas, and relate them with put–call parity.
```

`derivative-sentence.md`:
```markdown
In the language of L1b, a derivative is an abstract asset: we pay a price today for a future cash flow that depends on the underlying asset and may be zero.
```

`event-bullet.md` (drop the trailing category clause if fact 9 does not confirm it):
```markdown
* __Event contracts__ pay a fixed amount, usually one dollar, if a specified event occurs and nothing otherwise. Exchanges such as [Kalshi](https://kalshi.com) list them on economic data, weather, and financial index levels.
```

`kt3.md`:
```markdown
> * __An option's premium is the price that makes its expected net present value zero__ under the risk-neutral measure $\mathbb{Q}$. The buyer pays $\mathcal{P}$ today for a payoff $V(K,S(T))\geq 0$ at expiration that may be zero. For European contracts, the Black–Scholes–Merton formulas compute this premium, and put–call parity links the call and put premiums.
```

- [ ] **Step 5: Write `new/profile.md`** (about 330 words). Edit any sentence whose fact Step 2 did not confirm. The Explore-further links are the ones confirmed in Step 2, item 11.

```markdown
## Company Profile: Cboe Global Markets

[Cboe Global Markets](https://www.cboe.com/) operates exchanges for options, equities, futures, and foreign exchange. Members of the Chicago Board of Trade founded it in 1973 as the Chicago Board Options Exchange, the first exchange to list standardized stock options. The same year, Fischer Black and Myron Scholes published the option pricing formula that we use in this lecture.

> __What does the firm do?__
>
> * __Listed options:__ Before 1973, each option was negotiated between two parties. Cboe standardized the strike price, the expiration date, and the contract size, so the same contract could trade many times a day. The [Options Clearing Corporation (OCC)](https://www.theocc.com/) stands between the buyer and the seller of every U.S. listed option, so neither side carries the other's default risk.
> * __Index options:__ Options on the S&P 500 index ([SPX](https://www.cboe.com/tradable_products/sp_500/spx_options/)) are European-style and cash-settled: they can be exercised only at expiration, and they pay cash rather than shares. Most options on individual stocks and ETFs are American-style.
> * __Volatility:__ Cboe computes the [VIX index](https://www.cboe.com/tradable_products/vix/) from the premiums of SPX options. The VIX reads the market's expected volatility of the S&P 500 over the next 30 days from option prices.
>

__Explore further:__ Learn about options at [The Options Institute](https://www.cboe.com/optionsinstitute/), browse [Cboe careers](https://careers.cboe.com/), or watch [Cboe's YouTube channel](https://www.youtube.com/@CboeGlobalMarkets).

The connection to today's lecture is the premium. An exchange displays a premium for every listed contract, and the buyer pays it today for a payoff that may be zero at expiration. Where does that number come from? In L2a, the price of a Treasury was the one that made its net present value zero. An option's payoff is uncertain, so its premium is the price that makes its expected net present value zero under a pricing measure. For European contracts, the Black–Scholes–Merton formulas compute that price.
___
```

- [ ] **Step 6: Write `new/market.md`.** Keep his table shape: Metric | 2025 (full year) | 2026 YTD (latest available) | Source / notes. Fill every number from `facts.md`. The structure and wording:

```markdown
### How big is the US options market?

In 2025, the U.S. listed options market set a record of about 15.2 billion contracts, up about 24% from the 2024 record of 12.3 billion. The busiest day on record was October 10, 2025, with about 110 million contracts. In 2026, activity remains elevated: through <MONTH> 2026, total options ADV ran about <ADV> million contracts/day. In “notional” terms, Cboe estimates option flow tops $3 trillion per day (Jan 24, 2025), which is roughly 5 times the average daily notional traded in U.S. cash equities in 2024 (608 billion USD/day).

As a point-in-time gauge of notional outstanding, the Dec 20, 2024, quarterly expiration (“triple witching”) saw a record 6.6 trillion USD of options set to expire.

| Metric | 2025 (full year) | 2026 YTD (latest available) | Source / notes |
| --- | ---: | ---: | --- |
| Options volume (contracts) | ~15.2 billion (record) | ~<ADV> million ADV (through <MONTH> 2026) | [OCC 2025 year-end volume](<URL>). [OCC <MONTH> 2026 volume](<URL>). |
| Options notional (daily flow) | >3 trillion USD per day (Jan 24, 2025) | — | [Cboe Insights](https://www.cboe.com/insights/posts/options-activity-review-and-preview/) |
| U.S. equities ADNV (daily) | ~607.7 billion USD/day (2024) | — | [Cboe “North American Equities Year in Review”](https://www.cboe.com/insights/posts/north-american-equities-year-in-review/), used as a benchmark against options notional |
```

`<MONTH>`, `<ADV>`, and `<URL>` are values that Step 2 looks up (facts 6–8). Fill each one from `facts.md` before running the assembler. If Step 2 found a 2025 figure for a notional row, use it and update that sentence. Otherwise keep his dated 2024/2025 values as shown.

His `**Citations (direct):**` list and the `[1]`–`[4]` reference definitions are replaced by the links in the table, so no `utm_source` link survives.

- [ ] **Step 7: Write `new/bridge.md`** (about 250 words plus three displays). This is the body under the heading and figure.

```markdown
An option is an abstract asset with two cash flows: the buyer pays the premium $\mathcal{P}$ today and receives the payoff $V(K,S(T))\geq 0$ at expiration, where $V$ is $V_{c}$ for a call and $V_{p}$ for a put. This is the share purchase from L4a and L5a with the sale price $S(T)$ replaced by the payoff, so the net present value at $t=0$ is:
$$
\begin{align*}
\operatorname{NPV}_{0} = -\mathcal{P} + \mathcal{D}^{-1}_{T,0}(g_{y})\cdot V(K,S(T))
\end{align*}
$$

__Pricing condition.__ A Treasury's cash flows are known, so in L2a its price was the one that made the NPV zero. An option's payoff is random, so we require a zero __expected__ NPV under the risk-neutral measure $\mathbb{Q}$:
$$
\begin{align*}
\mathbb{E}_{\mathbb{Q}}\bigl(\operatorname{NPV}_{0}\bigr) = 0
\quad\Longrightarrow\quad
\mathcal{P} = \mathbb{E}_{\mathbb{Q}}\Bigl(\mathcal{D}^{-1}_{T,0}(g_{y})\cdot V(K,S(T))\Bigr)
\end{align*}
$$
This is the premium condition of the previous section.

__What $\mathbb{Q}$ means.__ Under $\mathbb{Q}$, the share price grows at the risk-free rate $g_{y}$, so $\mathbb{E}_{\mathbb{Q}}\bigl(\mathcal{D}^{-1}_{T,0}(g_{y})\,S(T)\bigr)=S(0)$ and the share also has zero expected NPV. $\mathbb{Q}$ is a pricing rule under which every traded asset has zero expected NPV. The real-world measure $\mathbb{P}$ still describes how often outcomes occur.

__May or may not have value.__ The scaled NPV $\rho_{T}=\mathcal{D}^{-1}_{T,0}(g_{y})\,V(K,S(T))/\mathcal{P}-1$ equals $-1$ whenever the option expires worthless. For a call, that happens with real-world probability $\mathbb{P}(S(T)\leq K)$, which L5a's terminal target formula computes. A share under GBM never loses its whole value, so its scaled NPV stays above $-1$.

__Event contracts.__ A one-dollar event contract pays $V=\mathbb{1}\{\text{event}\}$, so its price is a discounted probability under the pricing measure, which can differ from the real-world probability $\mathbb{P}(\text{event})$:
$$
\begin{align*}
p = \mathbb{E}_{\mathbb{Q}}\Bigl(\mathcal{D}^{-1}_{T,0}(g_{y})\cdot\mathbb{1}\{\text{event}\}\Bigr) = \mathcal{D}^{-1}_{T,0}(g_{y})\cdot\mathbb{Q}(\text{event})
\end{align*}
$$

__Profit versus NPV.__ The profit $V-\mathcal{P}$ of the previous section adds dollars from different dates. In today's dollars, a long call breaks even at $S(T)=K+\mathcal{P}_{c}\cdot\mathcal{D}_{T,0}(g_{y})$ rather than $K+\mathcal{P}_{c}$.
```

- [ ] **Step 8: Re-assemble and run the full lecture group**

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/assemble_lecture.py && python3 $W/check_l9a.py lecture`
Expected: no WARNING lines, and every lecture check passes. Re-run `verify_contingent_claims.py` (Task 6), whose section 5 checks the bridge identities. Expected: `all checks passed`.

- [ ] **Step 9: Write `$W/preview_cells.py` and render before/after previews.** Use the repository's preview tools (`build/notebook-previews/_tools`: `mark_diff.py`, `render-diff.mjs`, KaTeX):

```python
#!/usr/bin/env python3
"""Before/after PNG previews: his 2025 cell (left) vs the assembled L9a cell (right),
with word-level marks (green new, red struck). Run from the repo root:
    python3 build/notebook-previews/L9a-redesign-2026-10-09/preview_cells.py
    python3 build/notebook-previews/L9a-redesign-2026-10-09/preview_cells.py --notebook <path>
The second form renders every cell of one notebook on the right with no left side."""
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path.cwd()
W = ROOT / "build/notebook-previews/L9a-redesign-2026-10-09"
R = W / "render"
shutil.copytree(ROOT / "build/notebook-previews/_tools", R, dirs_exist_ok=True)
sys.path.insert(0, str(R))
from mark_diff import diff  # noqa: E402

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
F25 = ROOT.parent / "CHEME-5660-CourseRepository-Fall-2025/lectures"
L9B = F25 / "week-9/L9b/CHEME-5660-L9b-Lecture-IntroductionToDerivativesContracts-Fall-2025.ipynb"
L10A = F25 / "week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-CRR-Model-Fall-2025.ipynb"
NEWNB = ROOT / "lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb"


def cell_text(path, i):
    return "".join(json.loads(path.read_text())["cells"][i]["source"])


def md(s, mark=None):
    return {"cell_type": "markdown", "source": s, "mark": mark}


def render(key, title, left, right):
    spec = {"title": title, "left": {"title": "Fall 2025 (his text)", "cells": left},
            "right": {"title": "L9a assembled", "cells": right}}
    (R / f"spec-{key}.json").write_text(json.dumps(spec, ensure_ascii=False))
    subprocess.run(["node", "render-diff.mjs", f"spec-{key}.json", f"{key}.html"], cwd=R, check=True)
    raw = R / f"{key}-raw.png"
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    f"--screenshot={raw}", "--window-size=1860,7000", f"file://{R}/{key}.html"],
                   check=True, capture_output=True)
    from PIL import Image
    import numpy as np
    im = Image.open(raw).convert("RGB")
    rows = np.where((np.asarray(im) < 250).any(axis=(1, 2)))[0]
    out = W / "previews" / f"{key}.png"
    out.parent.mkdir(exist_ok=True)
    im.crop((0, 0, im.size[0], rows.max() + 25)).save(out)
    print(out)


if "--notebook" in sys.argv:
    nb = Path(sys.argv[sys.argv.index("--notebook") + 1])
    cells = [md("".join(c["source"])) for c in json.loads(nb.read_text())["cells"]]
    render(nb.stem[:40], nb.name, [], cells)
    sys.exit()

new = [c for c in json.loads(NEWNB.read_text())["cells"]]
by_head = {"".join(c["source"]).split("\n", 1)[0]: "".join(c["source"]) for c in new}
PAIRS = [  # (key, title, 2025 source, assembled heading)
    ("0-title", "Title, hook, objectives", (L9B, 0), "# L9a: Introduction to Derivatives and European Option Pricing"),
    ("3-derivative", "What is a Derivative? and the market table", (L9B, 3), "## What is a Derivative?"),
    ("4-calls-puts", "Call and Put Options Contracts", (L9B, 5), "## Call and Put Options Contracts"),
    ("6-european", "European Style Contracts", (L10A, 3), "## European Style Contracts"),
    ("7-summary", "Summary", (L9B, 7), "## Summary"),
]
for key, title, (path, i), head in PAIRS:
    l, r = diff(cell_text(path, i), by_head[head])
    render(key, title, [md(l)], [md(r, "changed")])
for key, head in (("2-profile", "## Company Profile: Cboe Global Markets"),
                  ("5-bridge", "## Options as Abstract Assets")):
    render(key, f"NEW: {head[3:]}", [], [md(by_head[head], "new")])
```

Run: `python3 build/notebook-previews/L9a-redesign-2026-10-09/preview_cells.py`
Expected: seven PNGs in `$W/previews/`. Open each one with the Read tool. Check:
- no KaTeX error text
- only the listed fixes are highlighted in his cells
- the two NEW cells read cleanly

If `render-diff.mjs` cannot find markdown-it, open the top of `_tools/render-diff.mjs`. It loads markdown-it from a VS Code extension directory, and the extension version in that path must exist under `~/.vscode/extensions`.

- [ ] **Step 10: Checkpoint B (instructor).** Run `open build/notebook-previews/L9a-redesign-2026-10-09/previews/*.png`. Then post a table with one row per change, showing the item, its word count, and its source, in this order:
  - the NEW items: hook, LO3, profile, derivative sentence, event bullet, market refresh, bridge, KT3, closer word swap
  - fixes 1–8 and the semicolon splits
  - the breakeven and parity additions

  Ask him to mark anything to cut or reword. Apply his answers to the fragment files, re-run Step 8, and re-render. Wait for his approval before staging.

- [ ] **Step 11: Stage** with `git add lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb`. Proposed message: `L9a lecture: introduction to derivatives and European pricing, assembled from the 2025 text`.

---

### Task 9: Rebuild the slide deck

**Files:**
- Create: `lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.tex`
- Generate: `lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.pdf`

**Interfaces:**
- Consumes:
  - the figure PDFs (Task 2)
  - the archived old deck's Disclaimer frame (Task 3)
  - the verified market numbers in `$W/facts.md` (Task 8)
  - the final lecture text (Task 8)

- [ ] **Step 1: Write the deck.** The frames mirror the notebook order. Copy the Disclaimer frame verbatim from the archived old deck, from `\begin{frame}{Disclaimer and Risks}` through its `\end{frame}`. Write everything else as below, and update the market numbers to the verified values.

```latex
% L9a student companion deck: introduction to derivatives and European option pricing.
%
% The frame order mirrors the lecture notebook. The disclaimer is slide 2, by
% instructor preference. Notation follows the lecture: premiums \mathcal{P}_c and
% \mathcal{P}_p, payoffs V_c and V_p, buyer and seller profit, terminal price S(T),
% risk-free rate g_y, and BSM's d_+, d_-, and N. Rebuilt October 2026 from the
% archived L8b deck and the pre-redesign L9a deck (see lectures/archive/).
\documentclass[aspectratio=169,11pt]{beamer}
\usepackage{vnslides}

\newcommand{\E}{\mathbb{E}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\Pc}{\mathcal{P}_{c}}
\newcommand{\Pp}{\mathcal{P}_{p}}
\newcommand{\Dinv}{\mathcal{D}^{-1}_{T,0}(g_{y})}
\newcommand{\ST}{S(T)}

\title{\texorpdfstring{{\vnheavy L9a}}{L9a}: Introduction to Derivatives and European Option Pricing}
\subtitle{CHEME 5660 Cornell University}
\author{Copyright Jeffrey Varner 2026. All Rights Reserved}

\begin{document}

\vntitlepage

% (Disclaimer and Risks frame copied verbatim from the archived old deck)

\begin{frame}{Objectives for Today}
  A derivative is a contract on an underlying asset. The buyer pays a premium
  today for a payoff at expiration that may be zero.

  \vspace{0.5em}
  {\large\textbf{\ink{Today's concepts}}}
  \begin{itemize}\setlength{\itemsep}{0.4em}
    \item \hilite{Define and classify derivatives}: futures, forwards, swaps,
      options, and event contracts.
    \item \hilite{Analyze option payoffs and profits}: long and short calls and
      puts at expiration, breakevens, and loss bounds.
    \item \hilite{Price European options contracts}: the premium as a zero
      expected NPV price under $\Q$, the Black--Scholes--Merton formulas, and
      put--call parity.
  \end{itemize}
\end{frame}

\begin{frame}{Lectures and Examples}
  \vspace{0.3em}
  {\normalsize\textbf{\ink{Lecture:}}\par
  \dimmed{CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb}}

  \vspace{0.6em}
  {\normalsize\textbf{\ink{Example 1:}}\par
  \dimmed{CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb}}

  \vspace{0.6em}
  {\normalsize\textbf{\ink{Example 2:}}\par
  \dimmed{CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb}}

  \vspace{0.5em}
  The first example computes payoff and profit for single long and short call
  and put contracts. The second computes European premiums with
  Black--Scholes--Merton and Monte Carlo simulation.
\end{frame}

\begin{frame}{Company Profile: Cboe Global Markets}
  \hilite{Cboe} opened in 1973 as the Chicago Board Options Exchange, the first
  exchange to list standardized stock options. Black and Scholes published their
  pricing formula the same year.
  \begin{itemize}\setlength{\itemsep}{0.4em}
    \item \hilite{Listed options}: standard strikes, expirations, and contract
      sizes, cleared by the Options Clearing Corporation (OCC).
    \item \hilite{SPX options}: European-style and cash-settled. Most stock and
      ETF options are American-style.
    \item \hilite{VIX}: the market's expected S\&P 500 volatility, read from SPX
      option premiums.
  \end{itemize}
  \vspace{0.4em}
  \textbf{\ink{Today's question:}} the exchange quotes a premium. Where does that
  number come from?
\end{frame}

\begin{frame}{What Is a Derivative?}
  A \hilite{derivative} is a contract between a buyer and a seller whose value
  depends on an underlying asset. In L1b's language, it is an abstract asset: a
  price today for a future cash flow that may be zero.
  \vspace{0.3em}
  \begin{itemize}\setlength{\itemsep}{0.25em}
    \item \hilite{Futures and forwards}: both sides must transact the underlying
      later at a set price. Futures are exchange-traded, and forwards trade over
      the counter.
    \item \hilite{Swaps}: both sides exchange two streams of cash flows, over
      the counter.
    \item \hilite{Options}: the buyer holds a right, and only the seller carries
      an obligation. Listed options trade on exchanges such as Cboe.
    \item \hilite{Event contracts}: pay a fixed amount, usually one dollar, if an
      event occurs. Kalshi lists them.
  \end{itemize}
\end{frame}

\begin{frame}{How Big Is the US Options Market?}
  \begin{itemize}\setlength{\itemsep}{0.5em}
    \item \hilite{2025}: a record of about 15.2 billion listed contracts, up about
      24\% from 2024 (OCC).
    \item \hilite{Busiest day}: about 110 million contracts on October 10, 2025.
    \item \hilite{Notional}: option flow topped 3 trillion USD per day in January
      2025, about 5 times the daily notional of U.S. cash equities (Cboe).
  \end{itemize}
  \slidenote{Sources:}{the lecture notebook's market table, with dates and links.}
\end{frame}

\begin{frame}{Call and Put Contracts: A Right and an Obligation}
  \vspace{-0.4em}
  \begin{center}
    \includegraphics[width=0.80\textwidth,keepaspectratio]{../figs/Fig-L9a-Contract-Right-Obligation.pdf}
  \end{center}
\end{frame}

\begin{frame}{Payoff Belongs to the Contract}
  With strike $K$ and share price $\ST$ at expiration, both in USD/share, the
  payoffs per share are:
  \[
    \boxed{V_{c}(K,\ST)=\max\bigl(\ST-K,~0\bigr),
      \qquad
      V_{p}(K,\ST)=\max\bigl(K-\ST,~0\bigr)}
  \]
  \begin{itemize}\setlength{\itemsep}{0.3em}
    \item The call is exercised only when $\ST>K$, and the put only when
      $\ST<K$. Both payoffs are nonnegative because the buyer may decline.
    \item One standard contract covers 100 shares.
  \end{itemize}
\end{frame}

\begin{frame}{Profit and Breakeven}
  The buyer pays the premium, and the seller collects it:
  \[
    P_{c}^{\text{buyer}}=V_{c}(K,\ST)-\Pc,
    \qquad
    P_{c}^{\text{seller}}=\Pc-V_{c}(K,\ST)
  \]
  The put is the same with $V_{p}$ and $\Pp$. Setting the buyer's profit to zero
  gives the breakeven share price at expiration:
  \[
    \boxed{S_{\text{BE}}=K+\Pc\ \text{(call)},
      \qquad
      S_{\text{BE}}=K-\Pp\ \text{(put)}}
  \]
  Both sides share the breakeven and want opposite sides of it.
  \slidenote{Example 1:}{\dimmed{CHEME-5660-L9a-Example-SingleContractPayoffProfit-Fall-2026.ipynb}}
\end{frame}

\begin{frame}{Loss Bounds and Direction Matter}
  Per share, at expiration:
  \vspace{0.3em}
  \begin{center}\small
  \begin{tabular}{@{}llll@{}}
    \textbf{\ink{Position}} & \textbf{\ink{Maximum profit}} & \textbf{\ink{Maximum loss}} & \textbf{\ink{Breakeven}}\\[2pt]
    \hline\\[-7pt]
    Long call  & unbounded & $\Pc$ & $K+\Pc$\\
    Short call & $\Pc$ & unbounded & $K+\Pc$\\
    Long put   & $K-\Pp$ at $\ST=0$ & $\Pp$ & $K-\Pp$\\
    Short put  & $\Pp$ & $K-\Pp$ at $\ST=0$ & $K-\Pp$\\
  \end{tabular}
  \end{center}
  \vspace{0.4em}
  Only the uncovered short call can lose without bound. A short put's loss is
  large but bounded, because the share price cannot fall below zero.
\end{frame}

\begin{frame}{Exercise Style Sets the Premium Condition}
  \begin{itemize}\setlength{\itemsep}{0.3em}
    \item \hilite{European}: exercise only at expiration $T$.
    \item \hilite{American}: exercise at any time up to $T$.
    \item \hilite{Bermudan}: exercise only on specified dates up to $T$.
  \end{itemize}
  \[
    \Pc^{\text{EU}}=\E_{\Q}\Bigl(\Dinv\cdot V_{c}(K,\ST)\Bigr),
    \qquad
    \Pc^{\text{AM}}=\sup_{\tau\leq T}\E_{\Q}\Bigl(\mathcal{D}^{-1}_{\tau,0}(g_{y})\cdot V_{c}(K,S(\tau))\Bigr)
  \]
  The exercise time $\tau$ may use only the information available at that time
  (a stopping time). An American contract is worth at least as much as the
  European one: $\Pc^{\text{AM}}\geq\Pc^{\text{EU}}$.
\end{frame}

\begin{frame}{Options as Abstract Assets}
  \vspace{-0.3em}
  \begin{center}
    \includegraphics[width=0.48\textwidth,keepaspectratio]{../figs/Fig-L9a-Option-CashFlows.pdf}
  \end{center}
  \vspace{-0.4em}
  \[
    \operatorname{NPV}_{0}=-\mathcal{P}+\Dinv\cdot V(K,\ST),
    \qquad
    \E_{\Q}\bigl(\operatorname{NPV}_{0}\bigr)=0
    \;\Longrightarrow\;
    \boxed{\mathcal{P}=\E_{\Q}\Bigl(\Dinv\cdot V(K,\ST)\Bigr)}
  \]
  A Treasury's price makes its NPV zero (L2a). An option's payoff is random, so
  its premium makes its \hilite{expected} NPV zero under $\Q$.
\end{frame}

\begin{frame}{Risk Neutral Is a Pricing Measure, Not a Forecast}
  Under $\Q$, the share price grows at the risk-free rate $g_{y}$, so the share
  also has zero expected NPV:
  \[
    \E_{\Q}\bigl(\Dinv\cdot\ST\bigr)=S(0)
  \]
  \begin{itemize}\setlength{\itemsep}{0.35em}
    \item \hilite{May or may not have value}: an option that expires worthless
      has scaled NPV $\rho_{T}=-1$. For a call, that happens with real-world
      probability $\mathbb{P}(\ST\leq K)$, which L5a computes.
    \item \hilite{Event contracts}: a one-dollar contract costs
      $p=\Dinv\cdot\Q(\text{event})$, a discounted pricing probability that can
      differ from $\mathbb{P}(\text{event})$.
  \end{itemize}
\end{frame}

\begin{frame}{Black--Scholes--Merton Prices European Contracts}
  With volatility $\sigma$ and $N$ the standard normal CDF:
  \[
    d_{+}=\frac{1}{\sigma\sqrt{T}}\left[\ln\frac{S(0)}{K}+\Bigl(g_{y}+\frac{\sigma^{2}}{2}\Bigr)T\right],
    \qquad d_{-}=d_{+}-\sigma\sqrt{T}
  \]
  \[
    \boxed{\Pc=N(d_{+})\cdot S(0)-N(d_{-})\cdot K\cdot\Dinv}
  \]
  \[
    \boxed{\Pp=N(-d_{-})\cdot K\cdot\Dinv-N(-d_{+})\cdot S(0)}
  \]
  Merton and Scholes received the 1997 Nobel Prize in Economic Sciences for
  this work. Fischer Black had died before the prize was awarded.
\end{frame}

\begin{frame}{Put--Call Parity Links the Premiums}
  The payoffs satisfy $V_{c}(K,\ST)-V_{p}(K,\ST)=\ST-K$ in every outcome.
  Discounting under $\Q$ with $\E_{\Q}\bigl(\Dinv\cdot\ST\bigr)=S(0)$ gives:
  \[
    \boxed{\Pc-\Pp=S(0)-K\cdot\Dinv}
  \]
  \begin{itemize}\setlength{\itemsep}{0.35em}
    \item Parity uses only linearity and the payoff identity, not the BSM
      formulas.
    \item It checks any pair of European premiums priced under $\Q$.
  \end{itemize}
  \slidenote{Example 2:}{\dimmed{CHEME-5660-L9a-Example-BSM-Premium-Fall-2026.ipynb}}
\end{frame}

\begin{frame}{Summary}
  Today we introduced derivatives, read the payoff and profit of call and put
  contracts, and priced European contracts.

  {\large\textbf{\ink{Key takeaways}}}
  \begin{itemize}\setlength{\itemsep}{0.3em}
    \item \hilite{Derivatives derive their value from underlying assets}:
      futures, forwards, swaps, options, and event contracts.
    \item \hilite{Option payoffs are set by the strike and the position}: the
      premium turns payoff into profit and sets the breakeven.
    \item \hilite{The premium makes the expected NPV zero under $\Q$}: the BSM
      formulas compute it for European contracts, and parity links calls and
      puts.
  \end{itemize}
\end{frame}

\end{document}
```

Replace the comment line `% (Disclaimer and Risks frame copied verbatim from the archived old deck)` with that frame. If the instructor dropped the timeline at checkpoint A, delete the `\begin{center}…\end{center}` block in "Options as Abstract Assets".

- [ ] **Step 2: Build the deck and check the layout**

```bash
make -C lectures/week-9/L9a/slides
grep -c "Overfull \\\\vbox" lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.log
pdftoppm -png -r 50 lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.pdf build/notebook-previews/L9a-redesign-2026-10-09/deck/p
```

Expected: the PDF builds and the overfull-vbox count is `0`. Open the page PNGs with the Read tool. No frame should spill its slidenote or table off the page, and the figures must be legible. If a frame overflows, shorten that frame's text and keep its content.

- [ ] **Step 3: Run records (deck checks only)**

Run: `python3 $W/check_l9a.py records`
Expected: the five deck checks PASS. The FAQ, schedule, and L9b checks still FAIL until Task 10.

- [ ] **Step 4: Stage** with `git add lectures/week-9/L9a/slides/CHEME-5660-L9a-Slides-Fall-2026.{tex,pdf}`. Proposed message: `L9a deck: rebuilt to mirror the redesigned lecture`.

---

### Task 10: Records

**Files:**
- Modify:
  - `code/docs/faq-src/content.json` (notation L9a table, Context rows, `lecture_sources`)
  - `code/docs/faq-src/README.md` (the entry count)
  - `code/docs/src/faq/*` (regenerated)
  - `lectures/LECTURE-ARTIFACT-SCHEDULE.md` (row 9a)
  - `schedule-2026-update.md` (row F40)
  - `README.md` (line 142, week 9)
  - `AGENTS.md` (the October 9 entry)
  - `lectures/week-9/L9b/slides/CHEME-5660-L9b-Slides-Fall-2026.tex` (line 11 comment)
- Create: `$W/add_notation.py`

**Interfaces:**
- Consumes: the final lecture file name (Task 7).

- [ ] **Step 1: Write `$W/add_notation.py`.** It copies the `\mathcal D` and `\sigma` row wording from the existing entries so that units match the course.

```python
#!/usr/bin/env python3
"""Add the L9a notation table, two Context rows, and the L9a lecture source. Run from the repo root."""
import json
import re
from pathlib import Path

P = Path("code/docs/faq-src/content.json")
d = json.loads(P.read_text())
assert not any(e.get("lecture") == "L9a" for e in d["notation"]), "L9a already present"


def row(lecture, symbol_pattern):
    for e in d["notation"]:
        if e.get("lecture") == lecture:
            for line in e["markdown"].splitlines():
                if re.match(r"\|\s*" + symbol_pattern, line):
                    return line
    raise SystemExit(f"no row matching {symbol_pattern} in {lecture}")


D_ROW = row("L2a", r"\$\\mathcal\s?D")   # course wording for the discount/growth factor
SIGMA_ROW = row("L4b", r"\$\\sigma\$")   # course wording and units for volatility
table = "\n".join([
    "| Symbol | Meaning and context | Units |",
    "|---|---|---|",
    "| $K$ | Strike price, the price at which shares change hands if the option is exercised. | USD/share |",
    "| $T$ | Expiration, measured from today. | years |",
    "| $S(0)$, $S(T)$ | Share price today and at expiration. $S(T)$ is the terminal price that L4a–L5a write as $S_T$. | USD/share |",
    "| $V_c(K,S(T))$, $V_p(K,S(T))$ | Call and put payoffs per share at expiration, $\\max(S(T)-K,0)$ and $\\max(K-S(T),0)$. | USD/share |",
    "| $\\mathcal P_c$, $\\mathcal P_p$ | Call and put premiums, paid by the buyer today. Superscripts EU and AM mark European and American contracts. | USD/share |",
    "| $P_c^{\\text{buyer}}$, $P_c^{\\text{seller}}$ | Buyer's and seller's profit per share at expiration. Subscript $p$ for a put. | USD/share |",
    "| $S_{\\text{BE}}$ | Breakeven share price at expiration: $K+\\mathcal P_c$ for a call and $K-\\mathcal P_p$ for a put. | USD/share |",
    "| $\\tau$ | Exercise time of an American contract, a stopping time that uses only information available at that time. | years |",
    "| $g_y$ | Continuously compounded risk-free rate. | 1/year |",
    D_ROW,
    "| $\\mathbb Q$, $\\mathbb P$ | Risk-neutral pricing measure, under which every traded asset has zero expected NPV at $g_y$, and the real-world measure. | — |",
    "| $\\operatorname{NPV}_0$, $\\rho_T$ | An option's NPV at $t=0$ and its scaled NPV, $\\mathcal D^{-1}_{T,0}(g_y)\\,V/\\mathcal P-1\\geq-1$. | USD/share; 1 |",
    "| $p$ | Price of a one-dollar event contract, $\\mathcal D^{-1}_{T,0}(g_y)\\,\\mathbb Q(\\text{event})$. | USD |",
    SIGMA_ROW,
    "| $d_+$, $d_-$ | Black–Scholes–Merton arguments, with $d_-=d_+-\\sigma\\sqrt T$. | 1 |",
    "| $N(\\cdot)$ | Standard normal cumulative distribution function, L5a's $\\Phi$. | 1 |",
    "| $\\theta$, $q$ | Example 1: position direction ($+1$ long, $-1$ short) and shares per contract. | 1; shares/contract |",
]) + "\n"
idx = max(i for i, e in enumerate(d["notation"]) if e.get("lecture", "").startswith("L7"))
d["notation"].insert(idx + 1, {"lecture": "L9a", "title": "L9a: Derivatives and European Option Pricing",
                               "markdown": table, "source_cell": "week09-options"})
ctx = next(e for e in d["notation"] if e.get("lecture") == "Context")
ctx["markdown"] = ctx["markdown"].rstrip("\n") + "\n" + "\n".join([
    "| $p$ | Real-world up probability on a lattice; price of a one-dollar event contract. | L3b; L9a |",
    "| $q$ | Risk-neutral up probability; shares per option contract. | L3b, L9a advanced; L9a Example 1 |",
]) + "\n"
d["lecture_sources"]["L9a"] = ("https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/main/"
                               "lectures/week-9/L9a/CHEME-5660-L9a-Lecture-IntroductionToDerivatives-BSM-Fall-2026.ipynb")
P.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n")
print("added L9a notation and lecture source")
```

Before writing, check the file's JSON layout: `head -c 300 code/docs/faq-src/content.json`. If it is not 2-space indented, match its indent in `P.write_text`. Then confirm the change touches only the intended entries: `git diff --stat code/docs/faq-src/content.json` should show one file with additions only. The Context rows above use semicolons inside table cells to separate meanings, which matches the existing Context table.

The `V`/`h` cross-lecture row waits until L9b's notation is added. Note it in the handoff.

- [ ] **Step 2: Run it, then rebuild the FAQ with the pinned Pandoc**

```bash
python3 build/notebook-previews/L9a-redesign-2026-10-09/add_notation.py
cd build/notebook-previews/L9a-redesign-2026-10-09 && \
  curl -sL -o pandoc.zip https://github.com/jgm/pandoc/releases/download/3.1.11.1/pandoc-3.1.11.1-arm64-macOS.zip && \
  unzip -qo pandoc.zip && cd - >/dev/null
PATH="$PWD/build/notebook-previews/L9a-redesign-2026-10-09/pandoc-3.1.11.1-arm64/bin:$PATH" pandoc --version | head -1
PATH="$PWD/build/notebook-previews/L9a-redesign-2026-10-09/pandoc-3.1.11.1-arm64/bin:$PATH" \
  python3 code/docs/faq-src/build_site.py --output code/docs/src/faq
git status --short code/docs/src/faq
```

Expected:
- Pandoc reports `pandoc 3.1.11.1`.
- Only `notation.html` changes. The search index may also change if it covers notation.
- If every FAQ page changes, the wrong Pandoc ran. Discard with `git checkout code/docs/src/faq` and fix the `PATH`.

Then update the entry count in `code/docs/faq-src/README.md`. Count the table rows with `python3 -c "import json;d=json.load(open('code/docs/faq-src/content.json'));print(sum(1 for e in d['notation'] if e['lecture']!='Context' for l in e['markdown'].splitlines() if l.startswith('|') and not l.startswith('|---') and not l.startswith('| Symbol')))"`. Change "with 348 entries through Week 7" to "with <N> entries through L9a".

- [ ] **Step 3: Update the schedules, README, AGENTS.md, and the L9b deck comment**

- `lectures/LECTURE-ARTIFACT-SCHEDULE.md`, replace the `| 9a |` row with:
  `| 9a | Oct 20 | 3 | Introduction to derivatives; calls, puts, exercise styles, and European pricing with Black–Scholes–Merton | `week-9/L9a`; single-contract payoff/profit and BSM premium examples; contingent-claims derivation and SPXW skew notebooks in `advanced/` | Rebuilt October 2026 from the 2025 text; awaiting instructor review |`
- `schedule-2026-update.md`, replace the `F40` row's topic with `Introduction to derivatives and European option pricing with Black–Scholes–Merton`.
- `README.md` line 142: `| 9 | Derivatives, options, and European and American pricing | [Week 9](lectures/week-9/) |`
- `AGENTS.md`, in "## Weeks 8–9 options redesign — October 9, 2026", add a bullet:
  `- The L9a build follows lectures/instructor/L9a-REDESIGN-PLAN.md; its handoff is lectures/instructor/L9a-REDESIGN-HANDOFF.md.`
- `lectures/week-9/L9b/slides/CHEME-5660-L9b-Slides-Fall-2026.tex` line 11: replace `Payoff functions h_c/h_p are L8b/L9a's` with `L9a writes the payoffs as V_c/V_p; this deck keeps h_c/h_p`. Then rebuild that deck with `make -C lectures/week-9/L9b/slides` (comment-only change, so the PDF is unchanged in content).

- [ ] **Step 4: Run records**

Run: `python3 $W/check_l9a.py records`
Expected: all PASS.

- [ ] **Step 5: Stage** with `git add code/docs/faq-src/content.json code/docs/faq-src/README.md code/docs/src/faq lectures/LECTURE-ARTIFACT-SCHEDULE.md schedule-2026-update.md README.md AGENTS.md lectures/week-9/L9b/slides/CHEME-5660-L9b-Slides-Fall-2026.{tex,pdf}`. Proposed message: `L9a records: notation FAQ, schedules, README, and the L9b deck comment`.

---

### Task 11: Final verification, handoff, and instructor review

**Files:**
- Create: `lectures/instructor/L9a-REDESIGN-HANDOFF.md`

- [ ] **Step 1: Clean rebuild and the full checker**

```bash
make -C lectures/week-9/L9a/figs distclean all
bash build/notebook-previews/L9a-redesign-2026-10-09/preview_themes.sh
python3 build/notebook-previews/L9a-redesign-2026-10-09/verify_contingent_claims.py
python3 build/notebook-previews/L9a-redesign-2026-10-09/check_l9a.py
```

Expected: `all checks passed` from the verifier and `0 failed` from the checker. A clean figure rebuild changes the SVG and PDF timestamps. That is expected, and `git diff --stat` must show no content change in them beyond PDF metadata. If a figure PDF differs only in its creation date, restore it with `git checkout` to keep the diff clean.

- [ ] **Step 2: Check the bundle offline.** Copy `lectures/week-9/L9a` alone into a scratch directory, keeping `Project.toml` reachable by placing it at the scratch root as a weekly bundle does. Then confirm that every relative link in the three notebooks resolves there:

```bash
S=build/notebook-previews/L9a-redesign-2026-10-09/bundle; rm -rf "$S"; mkdir -p "$S"
cp -R lectures/week-9/L9a "$S/" && cp Project.toml "$S/"
python3 - "$S/L9a" <<'EOF'
import json, re, sys
from pathlib import Path
root = Path(sys.argv[1]); bad = []
for nb in root.rglob("*.ipynb"):
    for c in json.loads(nb.read_text())["cells"]:
        if c["cell_type"] != "markdown": continue
        s = "".join(c["source"])
        for l in re.findall(r"\]\(([^)\s]+)\)", s) + re.findall(r'src="([^"]+)"', s):
            if not re.match(r"[a-z]+:", l) and not l.startswith("#") and not (nb.parent / l).exists():
                bad.append((nb.name, l))
print(bad or "all links resolve")
EOF
```

Expected: `all links resolve`.

- [ ] **Step 3: Write `lectures/instructor/L9a-REDESIGN-HANDOFF.md`.** Include:
  - what was built (file list)
  - the checker and verifier results
  - the before/after preview paths
  - a table of every change to his text with its reason (from the assembler's log)
  - the NEW items with word counts
  - verified facts with sources (from `facts.md`)
  - flags for him:
    - the soft forward pointer in Example 1's Summary
    - whether the old lecture linked the SPXW notebook (Task 3, Step 2)
    - the `V`/`h` Context row waiting on L9b's notation
    - the spec's out-of-scope items (L9b's `g_f` text, L9b's three examples, L10a's L8b mention)
    - `README.md` line 141 (week 8) left for his L8b work
    - the manifest's 8b unit change to 2

- [ ] **Step 4: Checkpoint C (instructor).** Ask him to open the lecture in VS Code with a dark theme and then a light theme (Review Focus 1). Point him to the handoff and to the previews. When he says he is about to hand-edit:
  1. Get his go-ahead to commit the staged work.
  2. Copy the lecture to `lectures/instructor/voice-calibration/L9a-Lecture-IntroductionToDerivatives-BSM/before.ipynb`, with a README naming the source path, commit, and date.
  3. Commit the backup (voice-calibration protocol).
