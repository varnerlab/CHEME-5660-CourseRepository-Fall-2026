"""Label the outlined SVG produced by pdf2svg for assistive technology."""

from pathlib import Path
import sys
import xml.etree.ElementTree as ET

path = Path(sys.argv[1])
ET.register_namespace("", "http://www.w3.org/2000/svg")
ET.register_namespace("xlink", "http://www.w3.org/1999/xlink")
tree = ET.parse(path)
root = tree.getroot()
root.set("role", "img")
root.set("aria-labelledby", "cal-title cal-description")
title = ET.Element("{http://www.w3.org/2000/svg}title", id="cal-title")
title.text = "Capital allocation line and tangent portfolio"
description = ET.Element("{http://www.w3.org/2000/svg}desc", id="cal-description")
description.text = (
    "Expected growth rate against growth-rate standard deviation, both in "
    "inverse years. A blue capital allocation line starts at the risk-free "
    "asset, with zero standard deviation and growth rate gf, and touches the "
    "solid red efficient frontier at the tangent portfolio T. Lending, with "
    "risk-free weight between zero and one, lies between the risk-free asset "
    "and T. Borrowing, with negative risk-free weight, extends beyond T. "
    "The global minimum-variance portfolio is marked at the frontier's vertex; "
    "the gray dashed lower branch is dominated. This is a schematic assuming "
    "short positions are allowed and a common lending and borrowing rate."
)
root.insert(0, title)
root.insert(1, description)
tree.write(path, encoding="utf-8", xml_declaration=True)
