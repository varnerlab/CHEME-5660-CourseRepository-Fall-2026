#!/usr/bin/env python3
"""Add a dark screen palette to the L10b profit-diagram SVGs.

Adapted from the CHEME 5800 L9c convexity figure script.

Keep the original drawing and light/print colors intact. Colors are matched
by nearest rounded RGB value, because pdf2svg writes fractional percentages
that vary slightly across versions. An unmapped color is an error, so a
changed TikZ palette is reviewed rather than silently left light-only.
"""

import re
import sys
from pathlib import Path
from xml.etree import ElementTree


# Light TikZ color (the .tex palette) -> dark screen color.
DARK_COLORS = {
    (32, 33, 36): "#e3e6ea",     # vnink: axes, profit curves, labels, gap arrows
    (0, 145, 255): "#4fb0ff",    # gdblue: payoff curves and their labels
    (224, 32, 32): "#ff6b6b",    # gdred: breakeven markers and labels
    (109, 114, 120): "#aeb4ba",  # gdgray: zero line, strike drops and labels, notes
    (240, 140, 0): "#ffad33",    # saorange: profit 10 days before expiration (time-decay figure)
    (244, 174, 76): "#c88a2e",   # saorange!70: profit 20 days before expiration
    (248, 198, 128): "#8c6428",  # saorange!50: profit at entry, 30 days before expiration
    (255, 255, 255): "#1f1f1f",  # white: open-marker interiors, matched to VS Code's dark editor
}
TOLERANCE = 2


def rgb(color):
    if color.startswith("rgb("):
        return tuple(round(float(v.strip().rstrip("%")) *
                           (255 / 100 if "%" in v else 1))
                     for v in color[4:-1].split(","))
    if re.fullmatch(r"#[0-9a-fA-F]{6}", color):
        return tuple(int(color[i:i + 2], 16) for i in (1, 3, 5))
    raise ValueError(f"Unsupported SVG color: {color}")


def dark_color(color):
    value = rgb(color)
    for light, dark in DARK_COLORS.items():
        if max(abs(a - b) for a, b in zip(light, value)) <= TOLERANCE:
            return dark
    raise KeyError(f"No dark color mapped for {color} = {value}")


def theme_svg(path):
    source = path.read_text()
    # Re-running the postprocessor replaces its own style block.
    source = re.sub(r'<style id="course-theme">.*?</style>\n?', "", source,
                    flags=re.DOTALL)
    drawing = ElementTree.fromstring(source)
    # The rules below match presentation attributes only, so paint set through
    # an inline style would stay light in dark mode; refuse it.
    for element in drawing.iter():
        if re.search(r"\b(fill|stroke)\s*:", element.attrib.get("style", "")):
            raise ValueError(f"Inline style paint cannot be themed: {element.attrib['style']}")
    rules = []
    for attribute in ("fill", "stroke"):
        colors = sorted({e.attrib[attribute] for e in drawing.iter()
                         if attribute in e.attrib and e.attrib[attribute] != "none"})
        for color in colors:
            rules.append(f'    [{attribute}="{color}"] {{ {attribute}: {dark_color(color)}; }}')
    style = ('<style id="course-theme">\n'
             '  @media screen and (prefers-color-scheme: dark) {\n' +
             '\n'.join(rules) + '\n  }\n'
             '  @media print { svg { background: white; } }\n</style>\n')
    end = source.index(">", source.index("<svg")) + 1
    path.write_text(source[:end] + "\n" + style + source[end:].lstrip("\n"))


if __name__ == "__main__":
    for filename in sys.argv[1:]:
        theme_svg(Path(filename))
