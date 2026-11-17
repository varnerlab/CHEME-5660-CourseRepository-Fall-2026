# L13b figures

The portfolio feedback schematic was drawn for the lecture. The other four figures
are from the INFORMS Annual Meeting 2026 talk, rebuilt here from the talk's drawing
code and data. They come from the `talk/` folder of
[varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab](https://github.com/varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab)
at commit `3bc41cf`.

## The figures

- `Fig-L13b-Portfolio-Feedback` separates measurement, input updates, and trigger
  checks at every close from allocation, forecasting, and new orders at a re-plan.
  A no-trigger branch holds the shares and active forecast. Its complete drawing is
  in its standalone TeX source. The notebook uses this schematic and the forecast-band
  figure below.
- `Fig-L13b-JumpHMM-Schematic` (PDF and SVG) is a copy of L13a's
  `Fig-L13a-JumpHMM-Schematic`, shown in the lecture's JumpHMM review. It is copied, not
  linked, because each meeting ships as its own release bundle, and a link into the L13a
  folder would break. If the L13a figure changes, rebuild it there and copy it again.
- `Fig-L13b-MarketState` is the figure on the talk's score slide. The top strip shows
  the `SPY` close with its 21-day and 63-day exponential moving averages, each divided
  by the first `SPY` close, from January 2, 2025 to September 4, 2026. The bottom strip
  shows the market state ξ over the same days. A ring marks each day the two averages
  cross, and a dotted line drops from the ring to the point where ξ crosses zero. The
  days with ξ > 0 are shaded in both strips.
- `Fig-L13b-ForecastBand` was redrawn for the lecture on November 16, 2026, from the data
  of the talk's rebalancing slide. It shows one stretch of the real-data run (13 names
  picked by hand without 2025 data, Cobb–Douglas, hedge off), from October 10 to
  December 22, 2025. The red line is the book's wealth divided by its starting wealth.
  Each blue region is one plan's 95% band (mean ± 1.96 standard deviations) with its
  edges drawn and its mean dashed. A gold ring marks each re-plan, and its reason sits
  under the date axis. A note marks the November 20 exit, 2.1 standard deviations below
  the mean. The talk's version showed 68%, 95%, and 99% fans and was replaced.
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
  figure and its options. No figure uses `mpc.tex` now. It is kept as the source of
  the talk's forecast-band slide.
- `forecast_band.tex` holds the drawing commands of the redrawn forecast-band figure.
- `vnsf.tex` holds the plot-panel style that `market_state.tex` builds on. On the talk's
  slides, that style is defined in `talk/figs/stylized_facts.tex`. Only the style is
  copied here, because L13b does not draw the stylized-fact panels.
- `vntalkfigure.sty` holds the parts of the talk's deck style (`talk/vnslides.sty`,
  white theme) that the drawing files need: the fonts, the colors, the opacities of the
  forecast bands, and the plotting packages. The figures use Helvetica Neue Light and
  Medium, as the talk does, and fall back to Arial when Helvetica Neue is not installed.
- `data/` holds the talk's data files (`talk/data/`), copied without changes. In the talk
  repository, `scripts/30_talk_data.jl` writes these files from the study's results.
- The four study figures have short standalone `Fig-L13b-*.tex` documents that call
  the talk's drawing commands. `Fig-L13b-Portfolio-Feedback.tex` contains its complete
  TikZ drawing and uses the same fonts, colors, and theme conversion.

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
