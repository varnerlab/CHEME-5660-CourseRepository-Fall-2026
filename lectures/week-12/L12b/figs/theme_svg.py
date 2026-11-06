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
    # Rule-switch schematic (pdflatex, pastel tiles with paper-palette borders), November 2026:
    (37, 37, 37): "#e3e6ea",     # ink: labels and digits
    (92, 92, 92): "#c9cdd2",     # ink!75: outline of trader i's tile
    (102, 102, 102): "#a9aeb4",  # ink!60: notes, "before/after the switch"
    (124, 124, 124): "#a9aeb4",  # ink!60 arrows (stroke and arrowhead)
    (187, 187, 187): "#6b7075",  # holdgray!80: border of the neighbor-sum box
    (224, 238, 246): "#17324a",  # buyblue!12: Buy tile fill
    (245, 245, 245): "#2c2e31",  # holdgray!12: Hold tile fill
    (248, 248, 248): "#2a2c2f",  # holdgray!8: neighbor-sum box fill
    (249, 231, 217): "#3d2614",  # sellorange!15: Sell tile fill
    (255, 253, 214): "#3a3718",  # yellow!16: band on the c = 1 column
    # Crash timeline (pdflatex, gray cards, teal highlight), November 2026:
    (0, 0, 0): "#e3e6ea",        # black: card text
    (14, 124, 134): "#3fb6c0",   # teal: highlighted card border and dots
    (51, 51, 51): "#d6d9dd",     # black!80: the axis
    (76, 76, 76): "#c9cdd2",     # black!70: dot outlines, key text
    (89, 89, 89): "#b3b8be",     # black!65: year labels
    (185, 185, 185): "#6b7075",  # gray!55: leader lines
    (198, 198, 198): "#5f646a",  # gray!45: card borders
    (231, 242, 243): "#14363a",  # teal!10: highlighted card fill
    (247, 247, 247): "#2c2e31",  # gray!6: card fill
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
