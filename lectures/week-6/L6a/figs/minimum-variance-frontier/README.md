# Minimum-variance frontier

One editable TikZ source, with two vector exports:

- `frontier.svg` for the lecture notebook. Text is outlined, so viewers need no fonts.
- `frontier.pdf` for the lecture slides. Fonts are embedded.

Build both with `make` in this directory. Requires XeLaTeX, `pdf2svg`, and
Python 3. The palette comes from `lectures/templates/vnflow.sty`. Typography uses
Helvetica Neue when available, with TeX Gyre Heros as the fallback.
`make clean` removes intermediate TeX files and keeps both exports.

The canvas is 149 × 95 mm. Axis and direct labels use 10 pt type; projection
labels and the comparison note use 9 pt type. For print, use the native width
or larger to preserve these sizes; the notebook preview uses a width of 760 px.
The solid and dashed branches, and filled and open comparison markers, remain
distinct in grayscale. Both exports use the shared pale gray `vnpanel` color
(`#F2F3F4`) inside the axes, with white margins and fixed canvas dimensions.

The diagram is a schematic hyperbola with short positions allowed: weights may
be negative. This assumption is documented here rather than displayed in the
plot; imposing nonnegative weights can change the frontier's shape. Portfolio
`p₂` is GMV; portfolios `p₁` and `p₃` have equal standard deviation and different expected
growth rates. The solid red upper branch is efficient, including GMV; the dashed
gray lower branch is dominated. A single upward arrow at the shared standard
deviation connects the comparison portfolios. Axis quantities are growth rates and growth-rate
standard deviations in inverse years, not GBM volatility.

The plotted parameterization is `x = x0 + sqrt(s0^2 + k*t^2)` and
`y = g0 + h*t`, so variance is a positive constant plus a squared growth
difference. The two comparison points use equal and opposite `t` values.
The numeric drawing parameters control layout and are not estimates from data.

Notebook reference, relative to the L6a notebook:

```html
<img src="figs/minimum-variance-frontier/frontier.svg" width="760"
     alt="Minimum-variance frontier: portfolio 2 is GMV; portfolios 1 and 3 have equal risk, but portfolio 1 has higher expected growth." />
```

Slide reference, relative to the L6a `slides/` directory:

```latex
\includegraphics[width=0.8\linewidth]{../figs/minimum-variance-frontier/frontier.pdf}
```
