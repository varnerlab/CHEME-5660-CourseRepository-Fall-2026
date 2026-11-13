# L13b figures

The four L13b figures are the figures of the INFORMS Annual Meeting 2026 talk, rebuilt
here from the talk's own drawing code and data. They come from the `talk/` folder of
[varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab](https://github.com/varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab)
at commit `3bc41cf`.

## The figures

- `Fig-L13b-MarketState` is the figure on the talk's score slide. The top strip shows
  the `SPY` close with its 21-day and 63-day exponential moving averages, each divided
  by the first `SPY` close, from January 2, 2025 to September 4, 2026. The bottom strip
  shows the market state ξ over the same days. A ring marks each day the two averages
  cross, and a dotted line drops from the ring to the point where ξ crosses zero. The
  days with ξ > 0 are shaded in both strips.
- `Fig-L13b-ForecastBand` is the figure on the talk's rebalancing slide. It shows one
  stretch of the real-data run (the 13 hand-picked names, Cobb–Douglas, hedge off),
  from October 10 to December 22, 2025. The red line is the book's wealth divided by
  its starting wealth. Each blue fan is the forecast made at a re-plan: the mean ± 1,
  1.96, and 2.576 standard deviations of the forecast wealth, labeled 68%, 95%, and
  99%. A gold ring marks each re-plan, and the label above the ring gives the reason.
- `Fig-L13b-RealData-Selection` is the dot plot on the talk's real-data slide. Each row
  is a selection rule, and each dot is one weighting rule. A dot is the median over 30
  runs of the ending wealth divided by the starting wealth. A filled dot is a run with
  the hedge off, and a hollow dot is a run with the hedge on. The dashed gold line is
  `SPY` bought and held, and the dotted gray line is the equal-weight portfolio of all
  373 names.
- `Fig-L13b-Synthetic-Sets` is the three-panel dot plot on the talk's synthetic-markets
  slide. It has one panel for each set of synthetic markets: 600 typical markets, the
  200 burst sell-offs, and the 200 bear sell-offs. The rows and dots read as in the
  real-data dot plot, except that a dot is the median across the set's markets. Each
  panel has its own x range and its own lines for synthetic `SPY` and the equal-weight
  portfolio.

`Fig-Crashes-Schematic-2024.png` is an older file. No L13b notebook or slide uses it.

## Sources

- `market_state.tex`, `mpc.tex`, and `dotplot.tex` are the talk's drawing files
  (`talk/figs/`), copied without changes. Each file's header comment describes its
  figure and its options.
- `vnsf.tex` holds the plot-panel style that `market_state.tex` builds on. On the talk's
  slides, that style is defined in `talk/figs/stylized_facts.tex`. Only the style is
  copied here, because L13b does not draw the stylized-fact panels.
- `vntalkfigure.sty` holds the parts of the talk's deck style (`talk/vnslides.sty`,
  white theme) that the drawing files need: the fonts, the colors, the opacities of the
  forecast bands, and the plotting packages. The figures use Helvetica Neue Light and
  Medium, as the talk does, and fall back to Arial when Helvetica Neue is not installed.
- `data/` holds the talk's data files (`talk/data/`), copied without changes. In the talk
  repository, `scripts/30_talk_data.jl` writes these files from the study's results.
- Each `Fig-L13b-*.tex` file is a short standalone document that calls the talk's
  drawing command with the sizes and options used on the slide.

To update a figure after the study's results change, rerun `scripts/30_talk_data.jl` in
the talk repository, copy the new CSV files into `data/`, and run `make`.

## Build

Run `make` in this folder. It builds each figure's PDF with XeLaTeX (for the deck), its
SVG with `pdf2svg` (for the notebook), and its PNG with `pdftoppm`. Run `make clean` to
remove the LaTeX build files.

The SVG build also runs `theme_svg.py`, which adds a dark screen palette in a `<style>`
block keyed on the light colors, so the notebook figure follows the viewer's color
scheme. The dark colors are the talk's navy theme. Three colors differ from the navy
slides, because the notebook's dark page is gray and not navy: the field color follows
the page, and the range bars and grid lines of the dot plots are a step lighter so that
they show. The forecast bands also take the navy theme's opacities. If a color in
`vntalkfigure.sty` changes, update the table in `theme_svg.py`. An unmapped color fails
the build on purpose.
