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


# Light TikZ color (vnflow.sty palette and its tints) -> dark screen color.
DARK_COLORS = {
    (32, 33, 36): "#e3e6ea",     # vnink: lattice edges, node labels, the decision rule
    (95, 99, 104): "#aeb4ba",    # vnmuted: "today", the "exercise now"/"hold for the future" labels
    (26, 82, 118): "#8cc0e6",    # vnlink: root node, panel and rule headings
    (118, 151, 173): "#4f7ea3",  # vnlink!60: zoom panel border and dotted connectors
    (179, 27, 27): "#ff8879",    # vncarnelian: lattice nodes, "uncertain future" arrow
    (174, 180, 186): "#6b7178",  # vnrule: dashed time lines
    (227, 234, 239): "#1c2b36",  # vnlink!12: decision-cell shading
    (223, 224, 225): "#3a3d41",  # vnmuted!20: "exercise now" box
    (240, 209, 209): "#4a2826",  # vncarnelian!20: "hold for the future" box
    (159, 203, 224): "#7fb6d3",  # f25sky: panel border, headings, root node, zoom lines (2025 sky blue)
    (164, 208, 229): "#22404f",  # f25skyfill: decision-cell shading
    (207, 66, 56): "#ff8879",    # f25red: nodes, uncertain-future arrow, panel time lines
    (150, 150, 150): "#6b7178",  # f25line: lattice time lines
    (85, 86, 89): "#c9ccd1",     # f25edge: lattice edges
    (95, 95, 95): "#aeb4ba",     # f25label: today, box captions
    (220, 221, 223): "#3a3d41",  # f25exercise: exercise-now box
    (236, 176, 143): "#5c3a26",  # f25hold: hold-for-the-future box (2025 peach)
    (255, 255, 255): "#1f1f1f",  # white: node fill, matched to VS Code's dark editor
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
