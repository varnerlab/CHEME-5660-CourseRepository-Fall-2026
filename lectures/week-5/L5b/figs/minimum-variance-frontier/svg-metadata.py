"""Add accessible labels to the font-independent SVG exported by pdf2svg."""

from pathlib import Path
import sys
import xml.etree.ElementTree as ET

path = Path(sys.argv[1])
ET.register_namespace("", "http://www.w3.org/2000/svg")
ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")
tree = ET.parse(path)
root = tree.getroot()
root.set("role", "img")
root.set("aria-labelledby", "frontier-title frontier-description")
title = ET.Element("{http://www.w3.org/2000/svg}title", id="frontier-title")
title.text = "Minimum-variance frontier with short positions allowed"
description = ET.Element(
    "{http://www.w3.org/2000/svg}desc", id="frontier-description"
)
description.text = (
    "Expected growth rate against growth-rate standard deviation, both in "
    "inverse years. The red upper branch is the efficient frontier. Portfolio "
    "2, in blue, is the global minimum-variance portfolio. Portfolios 1 and 3 "
    "have the same risk, but portfolio 1 has higher expected growth. Portfolio "
    "3 lies on the gray dashed lower branch. This is a schematic, not fitted data."
)
root.insert(0, title)
root.insert(1, description)
tree.write(path, encoding="utf-8", xml_declaration=True)
