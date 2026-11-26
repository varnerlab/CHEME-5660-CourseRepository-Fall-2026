# ONE-TIME conversion, already applied on 2026-11-26. Do not rerun: its old strings are gone from the notebook.
# Convert the updating example to the practicum's data: 2016 to 2024 fit, data to November 24, 2026,
# and the practicum universe (491 stocks and 14 ETFs). Every old string must appear exactly once in its cell.
import json, sys
path = sys.argv[1]
nb = json.load(open(path))
cells = ["".join(c["source"]) for c in nb["cells"]]
URL_LOAD = "https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/mpc-trading/#VLQuantitativeFinancePackage.MPCPortfolio.load_l15a_market-Tuple{AbstractString}"
URL_MD = "https://varnerlab.org/CHEME-5660-CourseRepository-Fall-2026/dev/mpc-data/#VLQuantitativeFinancePackage.MPCPortfolio.MyMarketData"
NEW_DATA_MD = f"""### Data
We load the daily prices of the stocks and exchange-traded funds (ETFs) that the trading method can pick, from January 4, 2016, to November 24, 2026, with [the `MPC.load_l15a_market(...)` function]({URL_LOAD}). Each stock has its sector in the [Global Industry Classification Standard (GICS)](https://www.msci.com/our-solutions/indexes/gics), and each ETF has the sector `ETF`. For a ticker that began trading after January 4, 2016, the prices hold `NaN` before its first trading day.

We store the data in the [`md::MPC.MyMarketData` variable]({URL_MD}). The `md.dates` field holds the trading days, `md.tickers` the tickers in alphabetical order, and `md.sector` the sector of each ticker. The `md.close` field holds the closing prices (days × tickers, USD/share), and `md.spy_close` the closing prices of `SPY`:"""
NEW_DATA_CODE = """md = let

    # load the prices and sectors from January 4, 2016, through November 24, 2026 -
    md = MPC.load_l15a_market(_PATH_TO_DATA; start = Date(2016, 1, 4), stop = Date(2026, 11, 24));

    # checks -
    @assert md.dates[1] == Date(2016, 1, 4) && md.dates[end] == Date(2026, 11, 24) "the data must run from 2016-01-04 to 2026-11-24"
    @assert size(md.close) == (length(md.dates), length(md.tickers)) "one closing price per trading day and ticker"
    @assert all(md.close[searchsortedfirst(md.dates, Date(2025, 1, 2)):end, :] .> 0) "every ticker must have a price on every trading day of 2025 and 2026"

    # return -
    md
end;
println("$(length(md.tickers)) tickers ($(count(md.sector .== "ETF")) ETFs) in $(length(unique(md.sector))) sectors, $(length(md.dates)) trading days");"""
assert cells[4].startswith("### Data\nWe load daily prices from January 3, 2014")
cells[4] = NEW_DATA_MD
assert cells[5].startswith("md = let") and "load_market_data" in cells[5]
cells[5] = NEW_DATA_CODE
R = {
0: [("of every stock with each trading day of 2025 and 2026, starting from the 2014 to 2024 fit.", "of every ticker with each trading day of 2025 and 2026, starting from the 2016 to 2024 fit."),
    ("compute each stock's preference weight $\\gamma_{i}(t)$, and pick a basket of the stocks with", "compute each ticker's preference weight $\\gamma_{i}(t)$, and pick a basket of the tickers with"),
    ("Then we pick the basket again from the fixed 2014 to 2024 estimates, and compare the two baskets.", "Then we pick the basket again from the fixed 2016 to 2024 estimates, and compare the two baskets."),
    ("Start from the 2014 to 2024 fit, and update each stock's baseline", "Start from the 2016 to 2024 fit, and update each ticker's baseline"),
    ("Compute the preference weight of every stock from", "Compute the preference weight of every ticker from"),
    ("Pick the stocks with the highest preference weights in each sector once a month", "Pick the tickers with the highest preference weights in each sector once a month"),
    ("Pick the basket again from the fixed 2014 to 2024 estimates. Compare the market sensitivity of the two baskets, and count the stocks they share.",
     "Pick the basket again from the fixed 2016 to 2024 estimates. Compare the market sensitivity of the two baskets, and count the tickers they share.")],
7: [("train_start = Date(2014, 1, 3);", "train_start = Date(2016, 1, 4);"),
    ("run_stop = Date(2026, 11, 13);", "run_stop = Date(2026, 11, 24);"),
    ("# weight of the 2014 to 2024 fit", "# weight of the 2016 to 2024 fit"),
    ("N_per_sector = 3; # stocks picked in each sector (count)", "N_per_sector = 3; # tickers picked in each sector (count)")],
9: [("we fit the single index model of every stock on 2014 to 2024, then update each stock's estimates", "we fit the single index model of every ticker on 2016 to 2024, then update each ticker's estimates"),
    ("fits the single index model of each stock by least squares", "fits the single index model of each ticker by least squares"),
    ("then updates the estimates of every stock with each trading day", "then updates the estimates of every ticker with each trading day"),
    ("The 2014 to 2024 fit enters at the start", "The 2016 to 2024 fit enters at the start")],
10: [("# fit the single index model of every stock on 2014 to 2024 (the fixed estimates) -", "# fit the single index model of every ticker on 2016 to 2024 (the fixed estimates) -"),
     ("# update the estimates of every stock with each trading day", "# update the estimates of every ticker with each trading day"),
     ('"one updated β per run day and stock"', '"one updated β per run day and ticker"')],
12: [("# the 2014 to 2024 estimate (dimensionless)", "# the 2016 to 2024 estimate (dimensionless)"),
     ('label = "$(my_ticker), 2014 to 2024 fit"', 'label = "$(my_ticker), 2016 to 2024 fit"')],
13: [("market sensitivities of every stock on the last trading day", "market sensitivities of every ticker on the last trading day"),
     ("Each point is one stock. A stock below the dashed line has a lower updated market sensitivity than its 2014 to 2024 estimate, and a stock above the dashed line has a higher one.",
      "Each point is one ticker. A ticker below the dashed line has a lower updated market sensitivity than its 2016 to 2024 estimate, and a ticker above the dashed line has a higher one."),
     ("labels each shaded area with its number of stocks:", "labels each shaded area with its number of tickers:")],
14: [("# initialize: the fixed and the last updated β of every stock -", "# initialize: the fixed and the last updated β of every ticker -"),
     ("# the 2014 to 2024 estimates (dimensionless)", "# the 2016 to 2024 estimates (dimensionless)"),
     ("# count the stocks below the dashed line", "# count the tickers below the dashed line"),
     ('label = "one stock"', 'label = "one ticker"'),
     ('$(number_below) of $(number_of_stocks) stocks"', '$(number_below) of $(number_of_tickers) tickers"'),
     ('$(number_above) of $(number_of_stocks) stocks"', '$(number_above) of $(number_of_tickers) tickers"'),
     ('xlabel!(p, "market sensitivity β, 2014 to 2024 fit");', 'xlabel!(p, "market sensitivity β, 2016 to 2024 fit");')],
15: [("Most stocks sit below the dashed line. In late 2026, most stocks moved less with the market than they did from 2014 to 2024.",
      "Most points sit below the dashed line. In late 2026, most stocks moved less with the market than they did from 2016 to 2024.")],
16: [("chooses the gain $G$ from the 2014 to 2024 closes.", "chooses the gain $G$ from the 2016 to 2024 closes."),
     ("we compute the preference weight of every stock on every trading day", "we compute the preference weight of every ticker on every trading day")],
17: [("the gain G from the 2014 to 2024 closes of SPY", "the gain G from the 2016 to 2024 closes of SPY"),
     ("# the preference weight of every stock on every run day", "# the preference weight of every ticker on every run day")],
18: [("picks the `N_per_sector` stocks with the highest", "picks the `N_per_sector` tickers with the highest"),
     ("of the basket and of all stocks, and the positions of the basket's stocks in `md.tickers`:", "of the basket and of all tickers, and the positions of the basket's tickers in `md.tickers`:")],
19: [("average updated β of the basket and of all stocks -", "average updated β of the basket and of all tickers -"),
     ('"N_per_sector stocks from each sector"', '"N_per_sector tickers from each sector"')],
20: [("of the preference basket and of all stocks.", "of the preference basket and of all tickers.")],
21: [("# average β of all stocks", "# average β of all tickers"),
     ('label = "all stocks, average β"', 'label = "all tickers, average β"'),
     ("ylims = (-1.0, 2.3)", "ylims = (-1.0, 2.8)")],
23: [("These are the stocks the trading method would choose from", "These are the tickers the trading method would choose from"),
     ("The table lists each stock's sector,", "The table lists each ticker's sector,")],
24: [("# positions of the basket's stocks in md.tickers", "# positions of the basket's tickers in md.tickers"),
     ("# one row per stock, in sector order -", "# one row per ticker, in sector order -"),
     ('"β, 2014 to 2024"', '"β, 2016 to 2024"')],
26: [("from the fixed 2014 to 2024 estimates, and compare it", "from the fixed 2016 to 2024 estimates, and compare it"),
     ("which describe how each stock moves with the market", "which describe how each ticker moves with the market"),
     ("the number of stocks the two baskets share", "the number of tickers the two baskets share")],
27: [("# initialize: the fixed 2014 to 2024 estimates of every stock -", "# initialize: the fixed 2016 to 2024 estimates of every ticker -"),
     ("# stocks in both baskets", "# tickers in both baskets"),
     ("# the average number of shared stocks", "# the average number of shared tickers"),
     ("$(length(picks_updated.basket[1])) stocks.", "$(length(picks_updated.basket[1])) tickers.")],
28: [("of the two baskets and of all stocks:", "of the two baskets and of all tickers:")],
29: [("# all stocks", "# all tickers"), ('label = "all stocks"', 'label = "all tickers"'),
     ("ylims = (0.25, 1.5)", "ylims = (0.25, 1.75)")],
30: [("The two baskets share few stocks,", "The two baskets share few tickers,"),
     ("the weight of the 2014 to 2024 fit.", "the weight of the 2016 to 2024 fit."),
     ("use each stock's market sensitivity", "use each ticker's market sensitivity")],
31: [("we updated the single index model of every stock with each trading day", "we updated the single index model of every ticker with each trading day"),
     ("We started from the 2014 to 2024 fit and updated each stock's estimates", "We started from the 2016 to 2024 fit and updated each ticker's estimates"),
     ("We picked the stocks with the highest preference weights", "We picked the tickers with the highest preference weights"),
     ("which shared few stocks with the updated one.", "which shared few tickers with the updated one."),
     ("says which stocks to consider.", "says which tickers to consider."),
     ("how many shares of each stock to buy", "how many shares of each ticker to buy")],
}
for k, pairs in R.items():
    for a, b in pairs:
        assert cells[k].count(a) == 1, (k, a[:70], cells[k].count(a))
        cells[k] = cells[k].replace(a, b)
# the local count variable says what it counts -
for k in (14, 27):
    cells[k] = cells[k].replace("number_of_stocks", "number_of_tickers")
for k, c in enumerate(cells):
    assert "2014" not in c.replace("Frazzini and Pedersen (2014)", ""), (k, c[c.find("2014")-80:c.find("2014")+40])
    assert "November 13" not in c and "Date(2026, 11, 13)" not in c, k
for c, t in zip(nb["cells"], cells):
    lines = t.split("\n")
    c["source"] = [l + "\n" for l in lines[:-1]] + ([lines[-1]] if lines[-1] else [])
    if c["cell_type"] == "code":
        c["outputs"] = []; c["execution_count"] = None
json.dump(nb, open(sys.argv[2], "w"), indent=1, ensure_ascii=False); open(sys.argv[2], "a").write("\n")
print("converted", sum(len(v) for v in R.values()) + 2, "edits")
