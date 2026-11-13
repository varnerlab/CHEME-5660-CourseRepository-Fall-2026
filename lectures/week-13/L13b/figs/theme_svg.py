#!/usr/bin/env python3
"""Add a dark screen palette to a notebook SVG exported from vntalkfigure.sty.

Keep the original drawing and light/print colors intact. Colors are matched
by nearest rounded RGB value, because pdf2svg writes fractional percentages
that vary slightly across versions. An unmapped color is an error, so a
changed TikZ palette is reviewed rather than silently left light-only.
"""

import re
import sys
from pathlib import Path
from xml.etree import ElementTree


# Light color (the talk's white theme, vntalkfigure.sty) -> dark screen color.
# The dark colors are the talk's own navy theme (talk/vnslides.sty, commit 3bc41cf),
# except the three marked "screen": the notebook's dark page is VS Code's dark gray,
# not the slide's navy, so the field color follows the page, and the two palest
# marks of the dot plots are a step lighter than on the navy slide so they show.
DARK_COLORS = {
    (13, 27, 42): "#f4f1ea",     # vnslideink: emphatic labels, EMA21, crossing rings
    (61, 74, 90): "#b9c3ce",     # vnslidebody, vndottick: ordinary labels and tick labels
    (62, 139, 208): "#5da9e9",   # vnband: forecast bands, shaded days, EMA63
    (242, 245, 249): "#14283c",  # vnplotpanel: plot panel
    (221, 228, 236): "#1f3852",  # vnplotgrid: grid lines on the panel
    (184, 134, 11): "#e3b23c",   # vnfigaccent: SPY, re-plan rings and leaders
    (217, 74, 58): "#ff6f61",    # vnmpcred: the book's wealth
    (47, 107, 154): "#8db4dd",   # vnslidelink: market-state line, group labels of the dot plots
    (63, 127, 192): "#7fa7d1",   # vndotoff: filled dots (hedge off)
    (30, 58, 95): "#c9dcf0",     # vndoton: outline of the hollow dots (hedge on)
    (107, 122, 140): "#9fb0c2",  # vndotew: equal-weight line
    (184, 195, 207): "#3c5570",  # vndotaxis: x axis line and tick marks of the dot plots
    (255, 255, 255): "#1f1f1f",  # vnbg (screen): inside of the hollow dots, legend box; VS Code's dark editor
    (225, 232, 240): "#2f4660",  # vndotbar (screen): range bars; the navy slide uses #1b3047
    (237, 241, 245): "#2a333d",  # vndotgrid (screen): grid of the dot plots; the navy slide uses #14283c
}
# Light fill opacity -> dark fill opacity, by figure. The talk's navy theme sets the
# three forecast bands more opaque than the white theme does, so that they stand
# apart on the dark panel. Other figures keep their opacities.
DARK_OPACITY = {
    "Fig-L13b-ForecastBand": {"0.12": "0.20", "0.16": "0.26", "0.26": "0.38"},
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
    # fill opacities that the dark palette changes, for this figure only
    for light, dark in DARK_OPACITY.get(path.stem, {}).items():
        if not any(e.attrib.get("fill-opacity") == light for e in drawing.iter()):
            raise KeyError(f"No element with fill-opacity {light} in {path.name}")
        rules.append(f'    [fill-opacity="{light}"] {{ fill-opacity: {dark}; }}')
    style = ('<style id="course-theme">\n'
             '  @media screen and (prefers-color-scheme: dark) {\n' +
             '\n'.join(rules) + '\n  }\n'
             '  @media print { svg { background: white; } }\n</style>\n')
    end = source.index(">", source.index("<svg")) + 1
    path.write_text(source[:end] + "\n" + style + source[end:].lstrip("\n"))


if __name__ == "__main__":
    for filename in sys.argv[1:]:
        theme_svg(Path(filename))
