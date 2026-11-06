#!/usr/bin/env python3
"""Add a dark screen palette to a notebook SVG exported from vnfigure.sty.

Keep the original drawing and light/print colors intact. Colors are matched
by nearest rounded RGB value, because pdf2svg writes fractional percentages
that vary slightly across versions. An unmapped color is an error, so a
changed TikZ palette is reviewed rather than silently left light-only.
"""

import re
import sys
from pathlib import Path
from xml.etree import ElementTree


# Light TikZ color (vnfigure.sty palette plus the paper Buy/Hold/Sell colors) -> dark screen color.
DARK_COLORS = {
    (32, 33, 36): "#e3e6ea",     # vnink: labels, arrows, outlines, highlight box
    (0, 114, 178): "#56b4e9",    # buyblue: Buy cells (text on them goes dark)
    (170, 170, 170): "#9aa0a6",  # holdgray: Hold cells
    (213, 94, 0): "#f28e3d",     # sellorange: Sell cells
    (240, 228, 66): "#e0d44a",   # hlyellow: the trader being updated
    (64, 64, 64): "#1f1f1f",     # black!75: dark digit on the Hold and yellow cells
    (255, 255, 255): "#1f1f1f",  # white: cell borders and digits on Buy/Sell cells, matched to VS Code's dark editor
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
