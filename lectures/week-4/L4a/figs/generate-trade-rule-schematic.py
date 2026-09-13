"""Render the lecture's discounted NPV illustration with Matplotlib."""

import argparse
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output", type=Path,
        default=Path(__file__).with_name("Fig-TradeRule-Schematic.svg"),
    )
    args = parser.parse_args()

    # Use a one-year holding period so discounting is visible at notebook width.
    initial_price = 100.0  # USD/share
    benchmark_growth_rate = 0.05  # inverse years
    holding_period = 1.0  # years
    discount_factor = np.exp(-benchmark_growth_rate * holding_period)
    break_even_price = initial_price / discount_factor
    npv_at_purchase_price = initial_price * discount_factor - initial_price
    sale_prices = np.linspace(72.0, 138.0, 331)
    discounted_npv = sale_prices * discount_factor - initial_price

    plt.rcParams.update({
        "font.family": "Arial", "font.size": 15,
        "mathtext.fontset": "custom", "mathtext.rm": "Arial",
        "mathtext.it": "Arial:italic", "mathtext.bf": "Arial:bold",
        "mathtext.fallback": "stix", "svg.hashsalt": "cheme5660-l4a-npv",
        "axes.edgecolor": "#434343", "axes.labelcolor": "#171717",
        "axes.linewidth": 1.1,
        "xtick.color": "#333333", "ytick.color": "#333333",
        "xtick.labelsize": 13, "ytick.labelsize": 13,
    })
    fig, ax = plt.subplots(figsize=(10, 7.4))
    fig.subplots_adjust(left=0.13, right=0.97, bottom=0.13, top=0.9)
    fig.text(
        0.55, 0.94,
        r"$S_0 = 100$ USD/share     $g_y = 5\%\ \mathrm{year}^{-1}$     $T = 1$ year",
        ha="center", fontsize=14, color="#333333",
    )

    ax.set_facecolor("#fffaf0")
    text_background = {"facecolor": "#fffaf0", "edgecolor": "none", "pad": 2.0}
    ax.set_axisbelow(True)
    ax.set_xlim(70, 140)
    ax.set_ylim(-38, 36)
    ax.set_xticks(np.arange(70, 141, 10))
    ax.set_yticks(np.arange(-30, 31, 10))
    ax.grid(color="#e5dfd4", linewidth=0.7, alpha=0.62)
    ax.axhline(0, color="#999184", linewidth=1)
    ax.plot(sale_prices, discounted_npv, color="#545454", linewidth=3.0,
            solid_capstyle="round")
    ax.text(
        73, 29, r"$S_0\rho_T = S_Te^{-g_yT} - S_0$",
        fontsize=17, color="#303030", bbox=text_background,
    )

    # These are two possible sale outcomes, not points on a time axis.
    ax.scatter([initial_price], [npv_at_purchase_price], marker="s",
               s=60, facecolor="#fffaf0", edgecolor="#333333", linewidth=1.5, zorder=4)
    ax.scatter([break_even_price], [0],
               s=85, color="#333333", edgecolor="#fffaf0", linewidth=1, zorder=4)
    ax.annotate(
        "Sale at the purchase price\n"
        r"$S_T = S_0 = 100$" + "\n"
        r"$S_0\rho_T = " + f"{npv_at_purchase_price:.2f}" + "$ USD/share",
        xy=(initial_price, npv_at_purchase_price), xytext=(initial_price, -27),
        ha="center", va="top", fontsize=14, color="#222222", bbox=text_background,
        arrowprops={"arrowstyle": "-", "color": "#666666", "linewidth": 1.1,
                    "shrinkA": 5, "shrinkB": 6},
    )
    ax.annotate(
        "Break-even sale price\n"
        r"$S_0e^{g_yT} = " + f"{break_even_price:.2f}" + "$ USD/share",
        xy=(break_even_price, 0), xytext=(break_even_price, 20),
        ha="center", va="top", fontsize=15, color="#222222", bbox=text_background,
        arrowprops={"arrowstyle": "-", "color": "#666666", "linewidth": 1.1,
                    "shrinkA": 6, "shrinkB": 6},
    )
    for price, letter, color, label, label_y in [
        (80.0, "L", "#ca3984", "Negative NPV", -7),
        (125.0, "P", "#008748", "Positive NPV", -7),
    ]:
        npv = price * discount_factor - initial_price
        ax.scatter([price], [npv], s=100, facecolor="#fffaf0",
                   edgecolor=color, linewidth=1.9, zorder=4)
        ax.annotate(letter, xy=(price, npv), xytext=(0, -9 if letter == "L" else 9),
                    textcoords="offset points", ha="center",
                    va="top" if letter == "L" else "bottom", fontsize=15,
                    fontweight="bold", color=color)
        ax.annotate(label, xy=(price, npv), xytext=(price, label_y),
                    ha="center", va="center", fontsize=15, color="#222222",
                    bbox=text_background,
                    arrowprops={"arrowstyle": "-", "color": "#666666", "linewidth": 1.1,
                                "shrinkA": 9, "shrinkB": 8})
    ax.annotate("B", xy=(break_even_price, 0), xytext=(-10, 8),
                textcoords="offset points", ha="right", va="bottom", fontsize=15,
                fontweight="bold", color="#333333")
    ax.set_xlabel(r"Terminal sale price $S_T$ (USD/share)", labelpad=12, fontsize=17)
    ax.set_ylabel("Discounted NPV per share (USD/share)", labelpad=12, fontsize=17)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.output, metadata={
        "Date": None,
        "Title": "Discounted NPV per share versus terminal sale price",
        "Description": (
            "At an initial price of 100 USD/share, a continuous annual benchmark "
            "rate of 5%, and a one-year holding period, selling at 100 USD/share "
            "gives an NPV of -4.88 USD/share. The break-even sale price is "
            "105.13 USD/share."
        ),
    })
    plt.close(fig)
    if args.output.suffix.lower() == ".svg":
        svg = args.output.read_text()
        args.output.write_text("\n".join(line.rstrip() for line in svg.splitlines()) + "\n")
    print(f"Saved {args.output}")
    print(f"Break-even price: {break_even_price:.8f} USD/share")
    print(f"NPV when selling at the purchase price: {npv_at_purchase_price:.8f} USD/share")


if __name__ == "__main__":
    main()
