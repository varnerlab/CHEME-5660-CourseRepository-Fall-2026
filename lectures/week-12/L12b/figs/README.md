# L12b figures

`Fig-L12b-RuleNumber` (November 2026) shows Rule 19280 as a base-3 number, in the
layout of the Fall 2025 "Two-dimensional Wolfram Totalistic Rules" slide and the
style of the rule-switch figure. Each column is one neighbor sum, from c = 8 on
the left to c = 0 on the right, with one arrangement of four neighbors, the next
intention, and the place value 3^c. The digits are decoded from the rule number
inside the TikZ file.

`Fig-L12b-RuleSwitch` is the rule-switch schematic, the same drawing as panels A
and B of Figure 1 in the Wolfram markets paper (commit 5cee50d), except that the
table columns run from c = 8 down to c = 0, so that each row reads as the rule
number. Trader i's four
neighbors (Buy, Buy, Buy, Hold) give neighbor sum c = 1. The neighbor sum points
into the highlighted c = 1 column of the two lookup tables: Rule 19280 (before
the switch) and Rule 19286 (after). The tables differ only in that column. The
table digits are decoded from the rule numbers inside the TikZ file. Style: a
plain pdflatex standalone in the default LaTeX font, pastel tiles with borders
in the paper palette (Buy #0072B2, Hold #AAAAAA, Sell #D55E00).

`make` builds the PDF and PNG (light palette, for the deck) and the SVG (for
the notebook) with pdflatex, `pdf2svg`, and `pdftoppm`. The SVG build runs
`theme_svg.py`, which adds a dark screen palette in a `<style>` block keyed on
the light colors, so the notebook figure follows the viewer's color scheme.
If the TikZ palette changes, update the mapping in `theme_svg.py`; an unmapped
color fails the build on purpose. `Fig-Crashes-Schematic-2024` is the older
crash figure, kept but no longer used; the other older files are not built by
the Makefile either.

## Wolfram market loop

`Fig-L12b-WolframMarket` (November 2026) shows one step of the model as a loop,
in the same style as the rule-switch figure. The grid's net trade goes to the
dealer, the dealer's price moves technical trader j's band, and the band sets
the edge intentions. A teal ring marks the edge (technical traders). It is a
schematic only; simulation results stay in the examples. The teal fill and the
band outline have dark mappings in `theme_svg.py`.

## Crash timeline

`Fig-L12b-CrashTimeline` (November 2026) remakes `Fig-Crashes-Schematic-2024` in the reference
style (pdflatex, Computer Modern, pastel cards), after the 2024 figure's staggered layout. Events
are evenly spaced along the axis (the dense 1987-2025 stretch makes a to-scale axis unreadable),
alternate above and below, and step down in cascades of three heights joined by vertical leaders.
Each card gives the date and a one-line description; the full descriptions below are the sources.
The three episodes described in the lecture's "Historical Market Crashes" box (1929, 1987, April
2025) are teal. Added events: 27 January 2025, April 2025, and 4-6 November 2025.

Corrections to the 2024 entries (instructor approved keeping his entries and
wording, fixing only facts a source contradicts):

- The Friday 13th mini-crash (UAL buyout collapse) was 13 October 1989, not
  1987. Black Monday, 19 October 1987, is unchanged.
- 1962: the low was retested in October 1962; new highs came in September 1963
  ("recovered by October 1962" removed).
- 1990-1991 recession: stocks fell about 20% from July to October 1990; the
  decline is no longer described as the trigger.
- 2008: 15 September (Lehman Brothers bankruptcy), not 16 September.
- 2010 flash crash: "a large automated sell order set it off" replaces
  "algorithmic fraud" (SEC/CFTC joint report, September 30, 2010).
- 2020: the S&P 500 peak was 19 February, the start of its 34% fall.
- 2022: the stale "Now (12/2024): peak?" is replaced by the 12 October 2022
  S&P 500 low.
- The 1990s and 2011 markers sat at about 1995 and 2013 on the old axis; they
  are now at their dates.

Sources for the new and corrected entries:

- Black Monday: https://en.wikipedia.org/wiki/Black_Monday_(1987)
- Friday 13th mini-crash: https://en.wikipedia.org/wiki/Friday_the_13th_mini-crash
- Kennedy Slide of 1962: https://en.wikipedia.org/wiki/Kennedy_Slide_of_1962
- DeepSeek, 27 January 2025 (Nvidia -17%, about 589 billion USD):
  https://www.bloomberg.com/news/articles/2025-01-27/asml-sinks-as-china-ai-startup-triggers-panic-in-tech-stocks
- April 2025 tariffs (S&P 500 -4.8% and -6% on 3-4 April; +9.5% on 9 April):
  https://russellinvestments.com/content/ri/us/en/insights/russell-research/2025/04/tariff-pause-one-day-relief.html and
  https://www.federalreserve.gov/publications/April-2025-financial-stability-report-Asset-Valuations.htm
- 4 November 2025 AI-valuation selloff (Nasdaq about -2%):
  https://www.fool.com/investing/breakfast-news/2025/11/05/breakfast-news-tech-stock-sell-off and
  https://www.hl.co.uk/shares/stock-market-news/market-reports/us-close-nasdaq-sees-worst-day-in-three-weeks-on-ai-sell-off

