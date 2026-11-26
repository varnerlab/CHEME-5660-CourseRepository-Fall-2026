"""Apply the 2026-11-26 wording fixes to an L15a example generator and to its executed notebook, without re-running it.

Usage: python3 tighten_examples.py
Each fix must appear once in the generator and once in the notebook. Only text changes: markdown, and one code comment.
"""
import json

ROOT = "lectures/week-15/L15a/"
TOOLS = "lectures/instructor/L15a-tools/"
MENU = "[the strategy menu](strategies/CHEME-5660-L15a-Strategy-Menu-Fall-2026.ipynb)"
OLD_MENU = "The names on the menu are listed in [the `strategies/menu.jl` file](strategies/menu.jl):"
NEW_MENU = f"The names on the menu are listed in {MENU}:"

FIXES = {
"make_backtest_example.py": ("CHEME-5660-L15a-Example-Strategy-Backtest-Fall-2026.ipynb", [
("In this example, we backtest one strategy from the strategy menu on the trading days from January 2, 2025, to November 24, 2026. A strategy combines one picking rule and one weighting rule from the files in the `strategies` folder, with the market hedge on or off and with fixed or updated estimates. We compare the strategy with `SPY`, place it among the saved backtests of the whole menu, and then run it again with updated estimates.",
 "In this example, we backtest one strategy from the menu on the real market, from January 2, 2025, to November 24, 2026.\n\nWe compare the strategy's wealth with `SPY` and mark the days a trigger fired. Then we place the strategy among the saved backtests of the whole menu, and run it again with updated estimates."),
("reads the INFORMS v2 settings of the trading method from the study configuration.",
 "reads the settings of the trading method from the study configuration."),
("# the INFORMS v2 settings, with our dates, our hedge choice, and fixed estimates -",
 "# the settings of the trading method, with our dates, our hedge choice, and fixed estimates -"),
("Next, we backtest the strategy.\n\n[The `find_rule(...)` function]",
 "__Let's backtest the strategy__. [The `find_rule(...)` function]"),
("> __What do we see?__ Each marker is a day the trading method picked a new basket and set new share counts. Across the menu,",
 "> __What do we see?__ Across the menu,"),
("The band trigger fires about a quarter of the decisions on the menu, when the wealth leaves its forecast band.",
 "The band trigger starts about a quarter of the decisions on the menu."),
("The menu has 8 picking rules (with two hand-picked lists) and 9 weighting rules, 3,456 backtests in all. Each pair runs with the market hedge on and off, and with fixed and updated estimates. Each random picking rule runs with 30 seeds.",
 "The menu has 8 picking rules, one of them with two hand-picked lists, and 9 weighting rules. Each pair runs with the market hedge on and off, and with fixed and updated estimates. With 30 seeds for each random picking rule, the menu has 3,456 backtests."),
("The estimates are part of the shared inputs, so we build new shared inputs with the `MPC.build_context(...)` function.",
 "The estimates are part of the shared inputs. We build new shared inputs with the `MPC.build_context(...)` function."),
(OLD_MENU, NEW_MENU),
]),
"make_stress_example.py": ("CHEME-5660-L15a-Example-Strategy-Stress-Test-Fall-2026.ipynb", [
("In this example, we stress-test one strategy from the strategy menu on 200 synthetic markets. Each market is",
 "In this example, we stress-test one strategy from the menu on 200 synthetic markets.\n\nEach market is"),
("the seed `5660 + p`, the seed of the practicum's stress-test path `p`.",
 "the seed `5660 + p`, as the practicum's stress test does."),
("keeps the market sensitivity of the book below a limit, and the limit falls when the market falls. To meet a low limit, it can buy stocks that move against the market or short `SPY`.",
 "keeps the market sensitivity of the portfolio at or below a limit, and the limit falls when the market falls. To meet a low limit, it can buy stocks that move against the market or sell `SPY` short."),
("A strategy that passes the five gates has done well on synthetic markets. The paper test then trades it with live prices in a paper account.",
 "A strategy that passes the five gates did well on synthetic markets. Next time, we'll trade a strategy in a paper account at live market prices."),
(OLD_MENU, NEW_MENU),
]),
}

for gen, (nbname, fixes) in FIXES.items():
    g = open(TOOLS + gen).read()
    nb = json.load(open(ROOT + nbname))
    texts = ["".join(c["source"]) for c in nb["cells"]]
    for old, new in fixes:
        # the generator holds each text once, with real newlines inside triple-quoted strings -
        assert g.count(old) == 1, (gen, old[:70], g.count(old))
        g = g.replace(old, new)
        hits = [k for k, t in enumerate(texts) if old in t]
        assert len(hits) == 1 and texts[hits[0]].count(old) == 1, (nbname, old[:70], hits)
        texts[hits[0]] = texts[hits[0]].replace(old, new)
    for c, t in zip(nb["cells"], texts):
        lines = t.split("\n")
        c["source"] = [l + "\n" for l in lines[:-1]] + ([lines[-1]] if lines[-1] else [])
    open(TOOLS + gen, "w").write(g)
    json.dump(nb, open(ROOT + nbname, "w"), indent=1, ensure_ascii=False)
    open(ROOT + nbname, "a").write("\n")
    print(gen, nbname, len(fixes), "fixes")
