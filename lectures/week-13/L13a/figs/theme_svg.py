#!/usr/bin/env python3
"""Add a dark screen palette to a notebook SVG drawn with jumphmm-diagram.tex.

Keep the original drawing and light/print colors intact. Colors are matched
by nearest rounded RGB value, because pdf2svg writes fractional percentages
that vary slightly across versions. An unmapped color is an error, so a
changed TikZ palette is reviewed rather than silently left light-only.
"""

import re
import sys
from pathlib import Path
from xml.etree import ElementTree


# Light TikZ color (the jumphmm-diagram.tex palette) -> dark screen color.
# Same pairs as week-12/L12a/figs/theme_svg.py.
DARK_COLORS = {
    (32, 33, 36): "#e3e6ea",     # vnink: text, axes, curves, boxes, arrows
    (0, 145, 255): "#4fb0ff",    # gdblue: the most positive states
    (224, 32, 32): "#ff6b6b",    # gdred: the most negative states
    (109, 114, 120): "#aeb4ba",  # gdgray: notes, dashed state boundaries, the series line
    (240, 140, 0): "#ffad33",    # saorange: the counted moves
    (255, 255, 255): "#1f1f1f",  # white: box and marker interiors, matched to VS Code's dark editor
    (241, 243, 244): "#2b2e33",  # boxfill: boxes, table header, states 2 and 4
    (255, 232, 199): "#5a3d10",  # orangefill: the highlighted moves and their count
    (229, 243, 255): "#123a5c",  # bluefill: the most positive states
    (253, 232, 232): "#4a1c1c",  # redfill: the most negative states
    (227, 229, 232): "#3a3d42",  # gridgray: table grid lines, emission base lines
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
