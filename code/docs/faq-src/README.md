# CHEME 5660 course FAQ

The course companion contains 31 questions across seven themes and a separate notation lookup with 348 entries through Week 7. The maintained content source is `content.json`: synthesized questions, short answers, Markdown explanations, lecture links, and notation tables. No individual survey responses or student identifiers are included.

The FAQ is published with the course's existing Documenter/GitHub Pages site at [Course questions](https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/faq/). Its HTML templates and base stylesheet were designed with Claude. Search, build, integration, and local refinements are maintained alongside them.

## Update and build

Edit `content.json`, preserving the course's notation and the assumptions in each answer. Build with Pandoc 3.1.11.1, which reproduces the published pages exactly. Pandoc 3.5 and later write different MathML on every page, for example minus signs as identifiers. With Python 3 and that Pandoc first on the `PATH`, run from the repository root:

```sh
python3 code/docs/faq-src/build_site.py --output code/docs/src/faq
```

Commit the content source and regenerated files together. Documenter copies the static files from `src/faq` into the documentation build. The publishing workflow needs no additional service or frontend build. Search uses the local index; equations use native MathML. The FAQ adds no analytics, external fonts, or runtime network dependencies.

`design.json` holds the original templates and stylesheet, and `refinements.css` holds integration adjustments. `design-provenance.json` records the designer and template hash.

## Review and verification

[The answer audit](ANSWER-AUDIT.md) records the prepublication corrections, assumptions, and review coverage. The numeric checks require NumPy and SciPy:

```sh
python3 code/docs/faq-src/verify_math.py
```

After building the documentation, browser checks require Beautiful Soup and Playwright with Chromium:

```sh
python3 code/docs/faq-src/verify_site.py --site code/docs/build/faq
```

These checks cover internal links and anchors, search/filter state, notation symbols, keyboard controls, no-JavaScript navigation, and page overflow at 360 pixels. Reports and screenshots are written to the ignored `qa` directory beside the scripts.

All fourteen question areas in the earlier survey FAQ are represented: drift versus mean growth; growth/return/volatility units; correlated shocks; independence; covariance scaling; forecasting versus pricing; lattice calibration; volatility's purpose; model limitations; prediction-band coverage; terminal NPV probabilities; EMA updates; portfolio weights; and daily leveraged compounding. Additional questions follow the Weeks 1–6 course reference. This is thematic coverage, not a claim that each individual response has its own page.
